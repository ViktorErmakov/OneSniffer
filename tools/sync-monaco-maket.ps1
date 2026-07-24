# Pack monaco-html/dist/editor.single.html into CommonTemplate BinaryData.
# Usage: .\tools\sync-monaco-maket.ps1
# Prerequisite: cd monaco-html; npm i; npm run build

$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent $PSScriptRoot
$SingleSource = Join-Path $RepoRoot "monaco-html\dist\editor.single.html"
$TemplateSingle = Join-Path $RepoRoot "bp3.OneSniffer\src\CommonTemplates\OneSniffer_MonacoEditorSingle\Template.bin"

if (-not (Test-Path $SingleSource)) {
    Write-Error "Not found: $SingleSource. Run: cd monaco-html; npm i; npm run build"
}

$SingleDir = Split-Path -Parent $TemplateSingle
if (-not (Test-Path $SingleDir)) {
    New-Item -ItemType Directory -Path $SingleDir -Force | Out-Null
}

Copy-Item -Path $SingleSource -Destination $TemplateSingle -Force

$singleMb = [math]::Round((Get-Item $TemplateSingle).Length / 1MB, 2)
Write-Host "OK: editor.single.html -> $TemplateSingle ($singleMb MB). Refresh EDT project (F5)."
