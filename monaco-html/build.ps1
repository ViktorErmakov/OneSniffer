# Build multi-file Monaco bundle (AMD vs/ + glue) + single-page HTML, pack editor.zip
# Usage: .\build.ps1   OR   npm run build
#
# =============================================================================
# CHECKLIST: importing patterns from a new salexdv/bsl_console release
# https://github.com/salexdv/bsl_console/
# OneSniffer does NOT vendor the full bsl_console (no bslGlobals / metadata).
# 1C bridge: V8Proxy + #V8_request (Kanban-style) — see .cursor/rules/html-v8proxy-bridge.mdc
# =============================================================================
# BEFORE bump:
#   1. Read upstream CHANGELOG.md and monaco-editor version in their package.json / webpack branch.
#   2. WebKit of 1C HTML field: prefer monaco-editor <= 0.30.1; we pin 0.20.0 — do not raise without
#      manual thin-client check (Список Запрос/Ответ, Просмотр, произвольный rest).
#   3. Diff only borrowed themes: MonacoEnvironment/workers stub, automaticLayout/resize.
# DO NOT port from bsl_console:
#   full bsl_query / dcs_query, metadata, snippets, code lens, debug, compare,
#   themes bsl-white / bsl-dark (we use vs / vs-dark / hc-black), TEMP *.html as primary load.
# Light Monarch bsl (keywords/comments/strings only, no metadata) — OK via bsl-language.js.
# MUST keep after any bump:
#   languages json | rest | bsl | plaintext
#   #V8_request + window.V8Proxy (fetch/sendResponse); ready / requestExport / exportText / setState
#   workers stub; default theme vs, fontSize 15, formatOnPaste true
#   single HTML -> CommonTemplate.OneSniffer_MonacoEditorSingle
#   bump OneSniffer_РедакторКодаКлиентСервер.ВерсияМакетаРедактора()
#   load: web HTML string / thin IB-nav + temp storage (not TEMP file path)
# Commands:
#   cd monaco-html; npm i; npm run build; cd ..; .\tools\sync-monaco-maket.ps1
# =============================================================================

$ErrorActionPreference = "Stop"
$Root = $PSScriptRoot
$NodeModules = Join-Path $Root "node_modules\monaco-editor"
$VsSource = Join-Path $NodeModules "min\vs"
$Dist = Join-Path $Root "dist"
$ZipPath = Join-Path $Dist "editor.zip"

if (-not (Test-Path $VsSource)) {
    Write-Error "Monaco not found: $VsSource. Run: npm i"
}

if (Test-Path $Dist) {
    Remove-Item $Dist -Recurse -Force
}
New-Item -ItemType Directory -Path $Dist | Out-Null

Write-Host "Copy vs/ ..."
Copy-Item -Path $VsSource -Destination (Join-Path $Dist "vs") -Recurse -Force

Write-Host "Copy glue ..."
Copy-Item (Join-Path $Root "index.html") (Join-Path $Dist "index.html") -Force
Copy-Item (Join-Path $Root "src\editor.js") (Join-Path $Dist "editor.js") -Force
Copy-Item (Join-Path $Root "src\rest-language.js") (Join-Path $Dist "rest-language.js") -Force
Copy-Item (Join-Path $Root "src\bsl-language.js") (Join-Path $Dist "bsl-language.js") -Force

Write-Host "Zip editor.zip ..."
if (Test-Path $ZipPath) {
    Remove-Item $ZipPath -Force
}

$ZipStaging = Join-Path $Root ".zip-staging"
if (Test-Path $ZipStaging) {
    Remove-Item $ZipStaging -Recurse -Force
}
New-Item -ItemType Directory -Path $ZipStaging | Out-Null
Copy-Item (Join-Path $Dist "*") $ZipStaging -Recurse -Force

Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::CreateFromDirectory($ZipStaging, $ZipPath)
Remove-Item $ZipStaging -Recurse -Force

$sizeMb = [math]::Round((Get-Item $ZipPath).Length / 1MB, 2)
Write-Host "OK: $ZipPath ($sizeMb MB)"

Write-Host "Build editor.single.html ..."
$Node = Get-Command node -ErrorAction SilentlyContinue
if (-not $Node) {
    Write-Error "node not found. Install Node.js to build editor.single.html"
}
Push-Location $Root
try {
    & node .\build-single.mjs
    if ($LASTEXITCODE -ne 0) {
        Write-Error "build-single.mjs failed with exit $LASTEXITCODE"
    }
}
finally {
    Pop-Location
}

Write-Host "Then: ..\tools\sync-monaco-maket.ps1"
