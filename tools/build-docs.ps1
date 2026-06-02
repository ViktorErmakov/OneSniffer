#Requires -Version 5.1
<#
.SYNOPSIS
  Build OneSniffer embedded HTML help from README.md.
#>
param(
    [string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
)

$ErrorActionPreference = "Stop"
$encBom = New-Object System.Text.UTF8Encoding($true)

$ReadmePath = Join-Path $RepoRoot "README.md"

$RegisterDir = Get-ChildItem -LiteralPath (Join-Path $RepoRoot "bp3.OneSniffer\src\InformationRegisters") -Directory |
    Where-Object { Test-Path (Join-Path $_.FullName "ManagerModule.bsl") } |
    Select-Object -First 1

if (-not $RegisterDir) {
    throw "Information register folder not found under bp3.OneSniffer/src/InformationRegisters"
}

$HelpDir = Join-Path $RegisterDir.FullName "Ext\Help"
$HelpHtmlPath = Join-Path $HelpDir "ru.html"
$HelpXmlPath = Join-Path $RegisterDir.FullName "Ext\Help.xml"
$PackagesDir = Join-Path $PSScriptRoot ".packages"

function Remove-GithubOnlySections {
    param([string]$Content)

    $Content = [regex]::Replace(
        $Content,
        '(?s)<!--\s*github-only:start\s*-->.*?<!--\s*github-only:end\s*-->',
        '')

    $Content = [regex]::Replace(
        $Content,
        '(?s)^## Star History\r?\n.*?(?=^\r?\n## |\z)',
        '',
        [System.Text.RegularExpressions.RegexOptions]::Multiline)

    return $Content.Trim()
}

function Convert-MarkdownImagesToHelpText {
    param([string]$Content)

    return [regex]::Replace(
        $Content,
        '!\[([^\]]*)\]\([^)]+\)',
        { param($m) "[$($m.Groups[1].Value)]" })
}

function Initialize-Markdig {
    $markdigDll = Get-ChildItem -Path $PackagesDir -Recurse -Filter "Markdig.dll" -ErrorAction SilentlyContinue |
        Select-Object -First 1

    if (-not $markdigDll) {
        Write-Host "Downloading Markdig from NuGet..."
        New-Item -ItemType Directory -Force -Path $PackagesDir | Out-Null
        $zipPath = Join-Path $PackagesDir "markdig.zip"
        $nugetUrl = "https://www.nuget.org/api/v2/package/Markdig/0.37.0"
        Invoke-WebRequest -Uri $nugetUrl -OutFile $zipPath -UseBasicParsing
        Expand-Archive -Path $zipPath -DestinationPath (Join-Path $PackagesDir "markdig") -Force
        Remove-Item $zipPath -Force
        $markdigDll = Get-ChildItem -Path $PackagesDir -Recurse -Filter "Markdig.dll" | Select-Object -First 1
    }

    if (-not $markdigDll) {
        throw "Markdig.dll not found after download."
    }

    $dllPath = $markdigDll.FullName
    if ($dllPath -notmatch 'net462') {
        $net462 = Get-ChildItem -Path $PackagesDir -Recurse -Filter "Markdig.dll" |
            Where-Object { $_.FullName -match 'net462' } |
            Select-Object -First 1
        if ($net462) {
            $dllPath = $net462.FullName
        }
    }

    Add-Type -Path $dllPath
}

function Convert-MarkdownToHtml {
    param([string]$Markdown)

    try {
        Initialize-Markdig
        $pipeline = [Markdig.MarkdownPipelineBuilder]::new().Build()
        return [Markdig.Markdown]::ToHtml($Markdown, $pipeline)
    }
    catch {
        Write-Warning "Markdig unavailable ($($_.Exception.Message)), using simple converter."
        return Convert-MarkdownToHtmlSimple -Markdown $Markdown
    }
}

function Convert-InlineMarkdown {
    param([string]$Text)

    $Text = [System.Web.HttpUtility]::HtmlEncode($Text)
    $Text = [regex]::Replace($Text, '`([^`]+)`', '<code>$1</code>')
    $Text = [regex]::Replace($Text, '\*\*(.+?)\*\*', '<strong>$1</strong>')
    return $Text
}

function Convert-MarkdownToHtmlSimple {
    param([string]$Markdown)

    $lines = $Markdown -split "`r?`n"
    $html = New-Object System.Collections.Generic.List[string]
    $script:inCode = $false
    $script:codeBuffer = New-Object System.Collections.Generic.List[string]
    $script:inList = $false
    $script:listOrdered = $false
    $script:tableRows = New-Object System.Collections.Generic.List[string]

    function Flush-CodeBlock {
        if ($script:codeBuffer.Count -gt 0) {
            $html.Add("<pre><code>" + ($script:codeBuffer -join "`n") + "</code></pre>")
            $script:codeBuffer.Clear()
        }
        $script:inCode = $false
    }

    function Flush-ListBlock {
        if ($script:inList) {
            if ($script:listOrdered) { $html.Add("</ol>") } else { $html.Add("</ul>") }
            $script:inList = $false
            $script:listOrdered = $false
        }
    }

    function Flush-TableBlock {
        if ($script:tableRows.Count -eq 0) { return }
        $html.Add("<table border=""1"" cellpadding=""4"" cellspacing=""0"">")
        $rowIndex = 0
        foreach ($row in $script:tableRows) {
            if ($row -match '^\|\s*[-:\s|]+\|\s*$') { continue }
            $cells = ($row.Trim('|') -split '\|') | ForEach-Object { $_.Trim() }
            $tag = if ($rowIndex -eq 0) { "th" } else { "td" }
            $html.Add("<tr>")
            foreach ($cell in $cells) {
                $html.Add("<$tag>" + (Convert-InlineMarkdown -Text $cell) + "</$tag>")
            }
            $html.Add("</tr>")
            $rowIndex++
        }
        $html.Add("</table>")
        $script:tableRows.Clear()
    }

    foreach ($line in $lines) {
        if ($line -match '^\|(.+)\|\s*$') {
            Flush-ListBlock
            Flush-CodeBlock
            $script:tableRows.Add($line)
            continue
        }
        elseif ($script:tableRows.Count -gt 0) {
            Flush-TableBlock
        }

        if ($line -match '^```') {
            if ($script:inCode) { Flush-CodeBlock } else { Flush-ListBlock; $script:inCode = $true }
            continue
        }
        if ($script:inCode) {
            $script:codeBuffer.Add([System.Web.HttpUtility]::HtmlEncode($line))
            continue
        }

        if ($line -match '^(#{1,4})\s+(.+)$') {
            Flush-ListBlock
            $level = $Matches[1].Length
            $html.Add("<h$level>" + (Convert-InlineMarkdown -Text $Matches[2]) + "</h$level>")
            continue
        }

        if ($line -match '^-\s+(.+)$') {
            if (-not $script:inList -or $script:listOrdered) {
                Flush-ListBlock
                $html.Add("<ul>")
                $script:inList = $true
            }
            $html.Add("<li>" + (Convert-InlineMarkdown -Text $Matches[1]) + "</li>")
            continue
        }

        if ($line -match '^\d+\.\s+(.+)$') {
            if (-not $script:inList -or -not $script:listOrdered) {
                Flush-ListBlock
                $html.Add("<ol>")
                $script:inList = $true
                $script:listOrdered = $true
            }
            $html.Add("<li>" + (Convert-InlineMarkdown -Text $Matches[1]) + "</li>")
            continue
        }

        if ([string]::IsNullOrWhiteSpace($line)) {
            Flush-ListBlock
            continue
        }

        Flush-ListBlock
        $html.Add("<p>" + (Convert-InlineMarkdown -Text $line) + "</p>")
    }

    Flush-CodeBlock
    Flush-ListBlock
    Flush-TableBlock
    return ($html -join "`n")
}

function Wrap-HelpHtml {
    param([string]$BodyHtml)

    return @"
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <link rel="stylesheet" type="text/css" href="v8help://service_book/service_style"/>
    <title>OneSniffer</title>
</head>
<body>
$BodyHtml
</body>
</html>
"@
}

function Ensure-HelpXml {
    param(
        [Parameter(Mandatory)]
        [string]$TargetHelpXmlPath
    )

    if (Test-Path $TargetHelpXmlPath) {
        return
    }

    $helpXmlDir = Split-Path $TargetHelpXmlPath -Parent
    New-Item -ItemType Directory -Force -Path $helpXmlDir | Out-Null

    $helpXml = @"
<?xml version="1.0" encoding="UTF-8"?>
<Help xmlns="http://v8.1c.ru/8.3/xcf/extrnprops" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="2.17">
	<Page>ru</Page>
</Help>
"@

    [System.IO.File]::WriteAllText($TargetHelpXmlPath, $helpXml, $encBom)
    Write-Host "Created $TargetHelpXmlPath"
}

if (-not (Test-Path $ReadmePath)) {
    throw "README.md not found: $ReadmePath"
}

Add-Type -AssemblyName System.Web

$markdown = [System.IO.File]::ReadAllText($ReadmePath, [System.Text.Encoding]::UTF8)
$markdown = Remove-GithubOnlySections -Content $markdown
$markdown = Convert-MarkdownImagesToHelpText -Content $markdown

$bodyHtml = Convert-MarkdownToHtml -Markdown $markdown
$fullHtml = Wrap-HelpHtml -BodyHtml $bodyHtml

New-Item -ItemType Directory -Force -Path $HelpDir | Out-Null
Ensure-HelpXml -TargetHelpXmlPath $HelpXmlPath
[System.IO.File]::WriteAllText($HelpHtmlPath, $fullHtml, $encBom)

$formsRoot = Join-Path $RegisterDir.FullName "Forms"
if (Test-Path $formsRoot) {
    # Help only for two forms: Список (логи) и Настройки.
    $targetFormNames = @("Список", "Настройки")
    foreach ($formName in $targetFormNames) {
        $formDir = Join-Path $formsRoot $formName
        if (-not (Test-Path $formDir)) { continue }

        $formHelpDir = Join-Path $formDir "Help"
        New-Item -ItemType Directory -Force -Path $formHelpDir | Out-Null

        $formHelpHtmlPath = Join-Path $formHelpDir "ru.html"
        [System.IO.File]::WriteAllText($formHelpHtmlPath, $fullHtml, $encBom)
    }
}

Write-Host "OK: $HelpHtmlPath"
