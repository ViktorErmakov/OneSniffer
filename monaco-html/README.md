# OneSniffer Monaco — single-page HTML

В конфигурацию попадает только `dist/editor.single.html` → макет `OneSniffer_MonacoEditorSingle`.

AMD multi-file (`index.html` + `vs/` + `editor.zip`) собирается в `dist/` для отладки, **в конфигурацию не синхронизируется**.

```powershell
npm i
npm run build
cd ..
.\tools\sync-monaco-maket.ps1
```

Версия: `monaco-editor` **0.20.0** (совместимость со старым WebKit поля HTML 1С).

Default theme: **`vs`** (светлая), fontSize 15, formatOnPaste true.

Глобальные JS API (из 1С через `Документ.defaultView`): `init`, `updateText`, `getText`, `setReadOnly`, `setLanguageMode`, `setTheme`, `setFontSize`, `minimap`, `wordWrap`, `showLineNumbers`, `hideLineNumbers`, `setOption`, `applyState`, `formatDocument`.

Языки: `json` | `rest` | `bsl` | `plaintext`.

## Импорт паттернов из salexdv/bsl_console

См. комментарий в начале `build.ps1` и `documentation/monaco-editor-update.md` § «Чеклист».
Не переносить полный bsl/метаданные из bsl_console. Канал с 1С — **V8Proxy + `#V8_request`** (см. `.cursor/rules/html-v8proxy-bridge.mdc`).
