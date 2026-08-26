[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('Inspect', 'Clean')]
    [string]$Mode,

    [Parameter(Mandatory = $true)]
    [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf })]
    [string]$InputPath,

    [string]$OutputPath,
    [switch]$Json,
    [switch]$Aggressive,
    [switch]$Stylometry,
    [switch]$StripEmojiGlue,
    [switch]$NormalizeSpaces,
    [switch]$Nfkc,
    [switch]$StripBidi,
    [switch]$Stats
)

$ErrorActionPreference = 'Stop'

# 以 wrapper 所在目錄定位上游 Python 腳本，讓命令不受目前工作目錄影響。
$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$resolvedInputPath = (Resolve-Path -LiteralPath $InputPath).Path
$pythonArgs = @('-3', '-X', 'utf8')

if ($Mode -eq 'Inspect') {
    # Inspect 只讀取並輸出報告，不會改寫輸入檔。
    $pythonArgs += Join-Path $scriptRoot 'inspect_text.py'
    if ($Json) { $pythonArgs += '--json' }
    if ($Aggressive) { $pythonArgs += '--aggressive' }
    if ($Stylometry) { $pythonArgs += '--stylometry' }
    if ($StripEmojiGlue) { $pythonArgs += '--strip-emoji-glue' }
    $pythonArgs += $resolvedInputPath
}
else {
    if ($Json) {
        throw '-Json 只適用於 Inspect；Clean 請使用 -Stats 取得統計 JSON。'
    }

    # Clean 預設建立 .cleaned 檔案，保留原檔並避免 in-place 覆寫。
    $cleanScript = Join-Path $scriptRoot 'clean_text.py'
    $inputItem = Get-Item -LiteralPath $resolvedInputPath
    if ([string]::IsNullOrWhiteSpace($OutputPath)) {
        $OutputPath = Join-Path $inputItem.DirectoryName ($inputItem.BaseName + '.cleaned' + $inputItem.Extension)
    }

    $pythonArgs += $cleanScript
    $pythonArgs += @('--output', $OutputPath)
    if (-not $NormalizeSpaces) { $pythonArgs += '--no-normalize-spaces' }
    if ($Aggressive) { $pythonArgs += '--aggressive-homoglyphs' }
    if ($Nfkc) { $pythonArgs += '--nfkc' }
    if ($StripEmojiGlue) { $pythonArgs += '--strip-emoji-glue' }
    if ($StripBidi) { $pythonArgs += '--strip-bidi' }
    if ($Stats) { $pythonArgs += '--stats' }
    $pythonArgs += $resolvedInputPath
}

# 使用 Python launcher，明確要求 Python 3 與 UTF-8，避免 Windows code page 破壞隱形字元報告。
& py @pythonArgs
$exitCode = $LASTEXITCODE
if ($null -eq $exitCode) { $exitCode = 0 }
exit $exitCode
