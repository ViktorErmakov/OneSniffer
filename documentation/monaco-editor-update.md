# Обновление Monaco Editor в OneSniffer

Редактор — **одна HTML-страница** (esbuild IIFE) в общем макете `OneSniffer_MonacoEditorSingle`. На сервере при открытии формы строка UTF-8 кладётся в реквизит `ТекстМакетаРедактора` (вариант A). Клиент: веб — присваивает HTML в поле; тонкий/толстый — пишет `editor.single.html` в TEMP по `ВерсияМакетаРедактора()` и открывает **уникальную копию** `*.html` (обход кеша WebBrowser).

Бандл **без** метаданных 1С: нет `bslGlobals` / `bslMetadata`. Языки: Monaco `json` / `plaintext` + кастомные `rest` (HTTP) и лёгкий `bsl` (без метаданных). ZIP-макет и «Адрес статики» **не используются**.

## Структура

```
monaco-html/
  package.json          # monaco-editor 0.20.0
  build.ps1             # multi-file dist (опционально) + build-single
  build-single.mjs      # esbuild → editor.single.html
  src/
    editor.js / rest-language.js / bsl-language.js  # для AMD-сборки
    single-entry.js     # entry single-page (тот же window API)
  dist/
    editor.single.html  # единственный артефакт для макета конфигурации

bp3.OneSniffer/.../OneSniffer_MonacoEditorSingle/ Template.bin = editor.single.html
```

## Чеклист: импорт паттернов из bsl_console

OneSniffer **не** вендорит весь [bsl_console](https://github.com/salexdv/bsl_console/). При релизе upstream — только заимствованные паттерны и pin Monaco.

**Перед bump**

1. Прочитать upstream `CHANGELOG.md` и версию `monaco-editor`.
2. WebKit поля HTML 1С: ориентир **≤ 0.30.1**; у нас **0.20.0** — не поднимать без ручной проверки.
3. Diff: stub workers; уникальная копия `*.html`; `automaticLayout` / resize.

**Не переносить:** полный `bsl` из bsl_console с метаданными, V8Proxy, темы `bsl-white` / `bsl-dark`.

**Обязательно сохранить:** языки `json` \| `rest` \| `bsl` \| `plaintext`; window API; workers stub; theme `vs`, fontSize 15, formatOnPaste; single → `OneSniffer_MonacoEditorSingle`; bump `ВерсияМакетаРедактора()`; без метаданных конфигурации в JS.

## Обновление версии Monaco

```powershell
cd monaco-html
npm i
npm run build
cd ..
.\tools\sync-monaco-maket.ps1
```

Увеличьте `OneSniffer_РедакторКодаКлиентСервер.ВерсияМакетаРедактора()`. EDT: `F5`. Проверка: Список (Запрос/Ответ), Просмотр (в т.ч. Развернуть с правкой), Настройки редактора (без адреса статики).

## Рантайм

1. `ПриСозданииНаСервере` → `ПодготовитьМакетРедактораНаФорме` → `ТекстМакетаРедактора` (HTML UTF-8 из макета Single).
2. Клиент → `ОбеспечитьЗагрузкуМакета`: веб — строка в поле HTML; тонкий — TEMP + уникальный `*_single.html`.
3. `ДокументСформирован` → `init` + настройки + `updateText`; для `json` — `formatDocument`.

Внешняя HTTP-публикация статики Monaco **не нужна** (ни веб, ни тонкий клиент).

## Языки

| Сценарий | Language id |
|----------|-------------|
| Тело с `Content-Type: …json…` (pretty на стороне BSL в `.rest`) | в `.rest`-документе как текст |
| HTTP (.rest) / лог / правка запроса | `rest` |
| Код 1С (форма Просмотр) | `bsl` |
| Прочее | `plaintext` |

## Протокол 1С ↔ JS

| Функция | Назначение |
|---------|------------|
| `init` / `applyState` | первичная инициализация / пакет |
| `updateText` / `getText` | запись / чтение текста |
| `setLanguageMode` | `json` \| `rest` \| `bsl` \| `plaintext` |
| `setReadOnly` | только просмотр |
| `setTheme` / `setFontSize` / `minimap` / `wordWrap` | настройки UI |
| `showLineNumbers` / `hideLineNumbers` | номера строк |
| `formatDocument` | pretty JSON (если язык `json`) |
