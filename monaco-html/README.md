# OneSniffer Monaco — multi-file AMD + single-page

Сборка кладёт в `dist/`:

- `index.html`, `editor.js`, `rest-language.js`, `vs/` — multi-file (как bsl_console)
- `editor.zip` — для макета `OneSniffer_MonacoEditor`
- `editor.single.html` — одна страница (esbuild) для макета `OneSniffer_MonacoEditorSingle`

```powershell
npm i
npm run build
cd ..
.\tools\sync-monaco-maket.ps1
```

Версия: `monaco-editor` **0.20.0** (совместимость со старым WebKit поля HTML 1С).

Default theme: **`vs`** (светлая), fontSize 15, formatOnPaste true.

Глобальные JS API (из 1С через `Документ.defaultView`): `init`, `updateText`, `getText`, `setReadOnly`, `setLanguageMode`, `setTheme`, `setFontSize`, `minimap`, `wordWrap`, `showLineNumbers`, `hideLineNumbers`, `setOption`, `applyState`, `formatDocument`.

## Импорт паттернов из salexdv/bsl_console

См. комментарий в начале `build.ps1` и `documentation/monaco-editor-update.md` § «Чеклист».
Не переносить bsl/метаданные/V8Proxy; сохранять наш API и языки `json`/`rest`/`plaintext`.
