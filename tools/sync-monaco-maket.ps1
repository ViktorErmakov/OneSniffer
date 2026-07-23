# Pack monaco-html/dist into common template BinaryData (ZIP + single HTML).
# Usage: .\tools\sync-monaco-maket.ps1
# Prerequisite: cd monaco-html; npm i; npm run build

$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent $PSScriptRoot
$ZipSource = Join-Path $RepoRoot "monaco-html\dist\editor.zip"
$SingleSource = Join-Path $RepoRoot "monaco-html\dist\editor.single.html"
$TemplateZip = Join-Path $RepoRoot "bp3.OneSniffer\src\CommonTemplates\OneSniffer_MonacoEditor\Template.bin"
$TemplateSingle = Join-Path $RepoRoot "bp3.OneSniffer\src\CommonTemplates\OneSniffer_MonacoEditorSingle\Template.bin"

if (-not (Test-Path $ZipSource)) {
    Write-Error "Not found: $ZipSource. Run: cd monaco-html; npm i; npm run build"
}
if (-not (Test-Path $SingleSource)) {
    Write-Error "Not found: $SingleSource. Run: cd monaco-html; npm i; npm run build"
}

$SingleDir = Split-Path -Parent $TemplateSingle
if (-not (Test-Path $SingleDir)) {
    New-Item -ItemType Directory -Path $SingleDir -Force | Out-Null
}

Copy-Item -Path $ZipSource -Destination $TemplateZip -Force
Copy-Item -Path $SingleSource -Destination $TemplateSingle -Force

$zipMb = [math]::Round((Get-Item $TemplateZip).Length / 1MB, 2)
$singleMb = [math]::Round((Get-Item $TemplateSingle).Length / 1MB, 2)
Write-Host "OK: editor.zip -> $TemplateZip ($zipMb MB)"
Write-Host "OK: editor.single.html -> $TemplateSingle ($singleMb MB). Refresh EDT project (F5)."
