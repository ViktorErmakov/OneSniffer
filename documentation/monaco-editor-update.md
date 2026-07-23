# Обновление Monaco Editor в OneSniffer

Редактор — **multi-file AMD** (паттерн [bsl_console](https://github.com/salexdv/bsl_console)): ZIP в общем макете `OneSniffer_MonacoEditor`, на клиенте распаковка во временный каталог, поле HTML открывает **уникальную копию** `*.html` (обход кеша WebBrowser).

Дополнительно: **single-page** HTML в макете `OneSniffer_MonacoEditorSingle` — эксперимент для вкладки **Ответ** (тот же window API).

Бандл **без** метаданных 1С: нет `bslGlobals` / `bslMetadata` / `bsl_language`. Языки: встроенный Monaco `json` / `plaintext` + кастомный `rest` (HTTP).

## Структура

```
monaco-html/
  package.json          # monaco-editor 0.20.0
  build.ps1             # multi-file + checklist bsl_console + вызов build-single
  build-single.mjs      # esbuild → editor.single.html
  index.html            # AMD loader + MonacoEnvironment (workers stub)
  src/
    editor.js           # глобальные API: init, updateText, getText, setTheme, …
    rest-language.js    # Monarch: rest / HTTP
    single-entry.js     # entry для single-page (тот же API)
  dist/                 # артефакт (в .gitignore)
    index.html, editor.js, rest-language.js, vs/, editor.zip
    editor.single.html

bp3.OneSniffer/.../OneSniffer_MonacoEditor/       Template.bin = editor.zip
bp3.OneSniffer/.../OneSniffer_MonacoEditorSingle/ Template.bin = editor.single.html
```

## Чеклист: импорт паттернов из новой bsl_console

OneSniffer **не** вендорит весь [bsl_console](https://github.com/salexdv/bsl_console/) (нет bslGlobals / metadata / V8Proxy). При релизе upstream обновляйте только заимствованные паттерны и pin Monaco.

**Перед bump**

1. Прочитать upstream `CHANGELOG.md` и версию `monaco-editor` в их `package.json` / ветке webpack.
2. Совместимость WebKit поля HTML 1С: ориентир **≤ 0.30.1**; у нас **0.20.0** — не поднимать без ручной проверки тонкого клиента.
3. Diff только по темам: `MonacoEnvironment` / stub workers; AMD `loader` + `editor.main`; уникальная копия `*.html`; лимиты веб (`defaultView`); `automaticLayout` / resize.

**Не переносить:** `bsl` / `bsl_query` / `dcs_query`, метаданные, сниппеты, code lens, debug, compare, V8Proxy; темы `bsl-white` / `bsl-dark`.

**Обязательно сохранить:** языки `json` \| `rest` \| `plaintext`; window API (`init`, `updateText`, `getText`, `setLanguageMode`, `setReadOnly`, `setTheme`, `formatDocument`, …); workers stub; default theme `vs`, fontSize 15, formatOnPaste true; ZIP → `OneSniffer_MonacoEditor`; single → `OneSniffer_MonacoEditorSingle`; bump `ВерсияМакетаРедактора()`; без метаданных конфигурации в JS.

Полный текст чеклиста также в комментарии в начале [`monaco-html/build.ps1`](../monaco-html/build.ps1).

## Обновление версии Monaco (перед релизом)

1. В `monaco-html/package.json` измените версию `monaco-editor` (по чеклисту выше).
2. Сборка и запись в макеты:

```powershell
cd monaco-html
npm i
npm run build
cd ..
.\tools\sync-monaco-maket.ps1
```

3. Увеличьте `OneSniffer_РедакторКодаКлиентСервер.ВерсияМакетаРедактора()`.
4. EDT: обновите проект (`F5`).
5. Ручная проверка:
   - Список → содержание → **Запрос** (переключатель HTTP / Curl), **Ответ** (single-page);
   - Произвольный запрос (`rest`);
   - Просмотр;
   - Настройки → «Редактор кода» (тема, шрифт, **Адрес статики**) → сохранить.
6. Зафиксируйте версию в `PROJECT.md` / changelog.

## Рантайм

1. `ПриСозданииНаСервере` → `ПодготовитьМакетРедактораНаФорме` → ZIP (+ single для Список) во ВХ.
2. Клиент → `ОбеспечитьЗагрузкуМакета`:
   - **Запрос / произвольный / Просмотр (ZIP):** TEMP + уникальный `*.html` / веб URL из настроек.
   - **Ответ (single):** TEMP `editor.single.html` (уникальная копия) / веб — HTML-строка из макета (эксперимент), иначе URL статики.
3. `ДокументСформирован` → `init` + настройки + `updateText`; для `json` — `formatDocument`.

### Веб-клиент

1. **Приоритет эксперимента:** single-page макет для **Ответа** (без внешней публикации).
2. **Fallback для multi-file полей:** выложить `monaco-html/dist/` (без `editor.single.html` обязательно) **на тот же origin**, что публикация ИБ; URL `…/index.html` — в Настройках → «Адрес статики (веб)».
3. **GitHub Pages / чужой CDN — не для моста 1С↔JS.** Same-Origin Policy: страница может открыться, но `Документ.defaultView.init()` с формы 1С на другом домене — нет. У [bsl_console](https://github.com/salexdv/bsl_console/) в веб-клиенте взаимодействие с 1С часто недоступно.

Тонкий/толстый: внешний хост не нужен.

## Языки

| Сценарий | Language id |
|----------|-------------|
| Тело с `Content-Type: …json…` | `json` |
| HTTP (.rest) / произвольный запрос | `rest` |
| Curl / прочее | `plaintext` |

## Протокол 1С ↔ JS

| Функция | Назначение |
|---------|------------|
| `init` / `applyState` | первичная инициализация / пакет |
| `updateText` / `getText` | запись / чтение текста |
| `setLanguageMode` | `json` \| `rest` \| `plaintext` |
| `setReadOnly` | только просмотр |
| `setTheme` / `setFontSize` / `minimap` / `wordWrap` | настройки UI |
| `showLineNumbers` / `hideLineNumbers` | номера строк |
| `setOption` | folding, tabSize, formatOnPaste, … |
| `formatDocument` | pretty-print JSON |

Click-мост `V8Proxy` **не используется**.

## Усечение двоичных данных

| Место | Поведение |
|-------|-----------|
| Список, вкладки Запрос/Ответ | усечённый текст |
| Список, вкладка Картинки | полное превью |
| Форма Просмотр | полный текст протокола |
