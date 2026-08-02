# Обновление Monaco Editor в OneSniffer

Редактор — **одна HTML-страница** (esbuild IIFE) в общем макете `OneSniffer_MonacoEditorSingle`. Страница попадает в реквизит поля HTML **только на сервере** в `ПриСозданииНаСервере` (`OneSniffer_РедакторКода.ПодготовитьРедакторыНаФорме` → `ЗагрузитьПриложение`): веб — HTML-строка; тонкий/толстый — URL `НавигационнаяСсылкаИБ / АдресВременногоХранилища` (BinaryData страницы). Клиент страницу не загружает.

**Туннель 1С ↔ JS — только V8Proxy** (обязательное правило: `.cursor/rules/html-v8proxy-bridge.mdc`). Прямые вызовы `Документ.defaultView.updateText/getText/...` из BSL запрещены.

Бандл **без** метаданных 1С. Языки: `json` / `plaintext` + кастомные `rest` и лёгкий `bsl`.

## Структура

```
monaco-html/
  package.json          # monaco-editor 0.20.0
  build.ps1             # multi-file dist (опционально) + build-single
  build-single.mjs      # esbuild → editor.single.html (+ #V8_request)
  src/
    single-entry.js     # V8Proxy + Monaco
  dist/
    editor.single.html  # артефакт для макета конфигурации

bp3.OneSniffer/.../OneSniffer_MonacoEditorSingle/ Template.bin = editor.single.html
```

## Чеклист: импорт паттернов из bsl_console / Kanban

OneSniffer **не** вендорит весь [bsl_console](https://github.com/salexdv/bsl_console/). Мост кликов — по образцу Kanban_for_1C (`V8Proxy` + `#V8_request`).

**Перед bump Monaco**

1. Прочитать upstream `CHANGELOG.md` и версию `monaco-editor`.
2. WebKit поля HTML 1С: ориентир **≤ 0.30.1**; у нас **0.20.0** — не поднимать без ручной проверки.
3. Сохранить stub workers; `automaticLayout` / resize.

**Не переносить:** полный `bsl` с метаданными, темы `bsl-white` / `bsl-dark`, TEMP-файл как основной способ загрузки.

**Обязательно сохранить:** языки `json` \| `rest` \| `bsl` \| `plaintext`; `#V8_request` + `window.V8Proxy`; workers stub; theme `vs`, fontSize 15; bump `ВерсияМакетаРедактора()`; без метаданных конфигурации в JS.

## Обновление версии Monaco

```powershell
cd monaco-html
npm i
npm run build
cd ..
.\tools\sync-monaco-maket.ps1
```

Увеличьте `OneSniffer_РедакторКодаКлиентСервер.ВерсияМакетаРедактора()`. EDT: `F5`.

## Рантайм

1. `ПриСозданииНаСервере` → `ПодготовитьРедакторыНаФорме(Форма, ИменаПолейHTML)` → страница прямо в реквизиты полей HTML (веб — строка; тонкий/толстый — URL ВХ).
2. `ПриОткрытии` поля HTML **не готовит**; обработчиков `ДокументСформирован` (`DocumentComplete`) нет.
3. Страница: bootstrap Monaco → отложенный `V8Proxy.fetch('ready')` (`setTimeout` после `DOMContentLoaded`; синхронный click до подписки хоста на `ПриНажатии` теряется).
4. Форма: `ПриНажатии` → `ОбработчикПриНажатии` → на `ready` шлёт `setState`.
5. Текст до готовности страницы хранится в реквизите формы `КэшМостаРедактора` и уходит в редактор ответом на `ready`.
6. Чтение текста: `ЗапроситьТекстРедактора` → `requestExport` → `exportText` → оповещение.

## Языки

| Сценарий | Language id |
|----------|-------------|
| HTTP (.rest) / лог / правка запроса | `rest` |
| Код 1С (форма Просмотр) | `bsl` |
| JSON-тело (pretty на стороне BSL при необходимости) | `json` |
| Прочее | `plaintext` |

## Протокол 1С ↔ JS (V8Proxy)

| Событие | Направление | Назначение |
|---------|-------------|------------|
| `ready` | JS→1С | страница готова |
| `requestExport` | 1С→JS | запросить текст |
| `exportText` | JS→1С | `textContent` = текст редактора |
| `setState` | 1С→JS | `{text, language, readOnly, options, formatJson}` |
| `applyOptions` | 1С→JS | настройки UI |

Внутренние `window.updateText` / `getText` и т.п. — только для отладки JS; BSL их не вызывает.
