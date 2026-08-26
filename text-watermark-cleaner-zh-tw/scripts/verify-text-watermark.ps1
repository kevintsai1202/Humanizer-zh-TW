[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$env:PYTHONDONTWRITEBYTECODE = '1'

# 建立可重現的混合文字 fixture，驗證中文、Markdown、emoji 與不可見字元的邊界。
$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$wrapper = Join-Path $scriptRoot 'run-text-watermark.ps1'
$tempRoot = Join-Path ([IO.Path]::GetTempPath()) ('watermark-fixture-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Force -Path $tempRoot | Out-Null
$inputFile = Join-Path $tempRoot 'mixed.md'
$outputFile = Join-Path $tempRoot 'mixed.cleaned.md'
$normalizedFile = Join-Path $tempRoot 'mixed.normalized.md'
$binaryFile = Join-Path $tempRoot 'fake.docx'

try {
    $zeroWidthSpace = [char]0x200B
    $softHyphen = [char]0x00AD
    $wordJoiner = [char]0x2060
    $noBreakSpace = [char]0x00A0
    $familyEmoji = [char]::ConvertFromUtf32(0x1F468) + [char]0x200D + [char]::ConvertFromUtf32(0x1F469) + [char]0x200D + [char]::ConvertFromUtf32(0x1F467)
    $fixtureText = @"
# 測試標題

這是${zeroWidthSpace}繁體中文${softHyphen}段落，含${wordJoiner}不可見標記與${noBreakSpace}不換行空白。

English sentence stays readable, and the following code must remain unchanged:
```powershell
Write-Output "keep this code"
```

Emoji family: $familyEmoji
"@
    [IO.File]::WriteAllText($inputFile, $fixtureText, [Text.UTF8Encoding]::new($false))

    # inspect 應回報不可見標記，但不能因為只是短文而誤判執行失敗。
    $inspectRaw = (& $wrapper -Mode Inspect -InputPath $inputFile -Json | Out-String).Trim()
    $inspect = $inspectRaw | ConvertFrom-Json
    if ([int]$inspect.suspicious_total -lt 1) {
        throw 'inspect did not report the injected invisible marks'
    }

    # clean 預設保留 NBSP 與 emoji ZWJ，並移除明確的不可見標記。
    $cleanRaw = (& $wrapper -Mode Clean -InputPath $inputFile -OutputPath $outputFile -Stats 2>&1 | Out-String).Trim()
    if (-not (Test-Path -LiteralPath $outputFile -PathType Leaf)) {
        throw 'clean did not create the output file'
    }
    $cleanedText = [IO.File]::ReadAllText($outputFile, [Text.UTF8Encoding]::new($false))
    foreach ($mark in @($zeroWidthSpace, $softHyphen, $wordJoiner)) {
        if ($cleanedText.Contains([string]$mark)) {
            throw ('clean output still contains U+{0:X4}' -f [int][char]$mark)
        }
    }
    if (-not $cleanedText.Contains([string]$noBreakSpace)) {
        throw 'conservative clean unexpectedly normalized NBSP'
    }
    if (-not $cleanedText.Contains('Write-Output "keep this code"')) {
        throw 'clean changed the fenced code block'
    }
    if (-not $cleanedText.Contains($familyEmoji)) {
        throw 'conservative clean changed emoji ZWJ sequence'
    }

    $afterRaw = (& $wrapper -Mode Inspect -InputPath $outputFile -Json | Out-String).Trim()
    $after = $afterRaw | ConvertFrom-Json
    if ([int]$after.suspicious_total -ne 1) {
        throw ('conservative after inspect expected only the preserved NBSP, got {0} findings' -f $after.suspicious_total)
    }

    # 明確要求空白正規化後，才應連 NBSP 一起清理並通過 after inspect。
    & $wrapper -Mode Clean -InputPath $inputFile -OutputPath $normalizedFile -NormalizeSpaces *> $null
    $normalizedRaw = (& $wrapper -Mode Inspect -InputPath $normalizedFile -Json | Out-String).Trim()
    $normalized = $normalizedRaw | ConvertFrom-Json
    if ([int]$normalized.suspicious_total -ne 0) {
        throw ('normalized after inspect still reports {0} suspicious marks' -f $normalized.suspicious_total)
    }

    # 二進位 magic bytes 應被 common.py 拒絕，避免誤把 DOCX 當文字重寫。
    [IO.File]::WriteAllBytes($binaryFile, [byte[]](0x50, 0x4B, 0x03, 0x04, 0x00, 0x00))
    & $wrapper -Mode Inspect -InputPath $binaryFile -Json *> $null
    $binaryExitCode = $LASTEXITCODE
    if ($binaryExitCode -ne 2) {
        throw ('binary refusal exit code was {0}, expected 2' -f $binaryExitCode)
    }

    [pscustomobject]@{
        inspect_suspicious_total = [int]$inspect.suspicious_total
        clean_stats = $cleanRaw
        conservative_after_suspicious_total = [int]$after.suspicious_total
        normalized_after_suspicious_total = [int]$normalized.suspicious_total
        binary_refusal_exit_code = $binaryExitCode
        output_preserved = Test-Path -LiteralPath $outputFile -PathType Leaf
    } | ConvertTo-Json -Depth 5
}
finally {
    # 只刪除本次明確建立的 fixture 檔案與空目錄。
    foreach ($path in @($inputFile, $outputFile, $normalizedFile, $binaryFile)) {
        if (Test-Path -LiteralPath $path) { Remove-Item -LiteralPath $path -Force }
    }
    if (Test-Path -LiteralPath $tempRoot) { Remove-Item -LiteralPath $tempRoot -Force }
}
