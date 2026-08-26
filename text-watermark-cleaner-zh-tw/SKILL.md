---
name: text-watermark-cleaner-zh-tw
description: >-
  清理使用者擁有或獲授權文字中的不可見 Unicode、zero-width、tag characters、異形空白與文字型 AI provenance/watermark，並提供統計式改寫的 best-effort 流程。適用於繁體中文、簡體中文、英文、Markdown、HTML 與純文字；當使用者說「去文字浮水印」、「去 Claude 浮水印」、「清理不可見字元」、「清除 AI provenance」或要求檢查文字標記時使用。文字浮水印與檔案 C2PA/EXIF metadata、可見圖片浮水印是不同問題，後兩者不由本 skill 直接處理。
---

# 文字浮水印清理（繁體中文）

## 工作邊界

只處理使用者擁有或獲授權的內容。把結果描述為「清理可驗證的文字載體」或「降低統計相似度」，不可宣稱內容已證明為人類撰寫、不可偵測或已破解 Claude 的私有演算法。

文字型標記分成兩層：

- **Layer A：確定性文字衛生處理**。檢查並清理高可信的不可見 Unicode、zero-width、tag characters、異形空白與部分 homoglyph。這一層可用前後統計驗證。
- **Layer B：統計式標記降低**。透過改變 token、詞序、連接詞、句界與句長來改寫。這不是解碼器；沒有 vendor detector 或相同 key/config 時，不能證明標記已移除。

不要把「去 AI 味」和「去文字浮水印」當成同一個動作。只有使用者明確要求浮水印或 provenance 清理時才執行本 skill；單純要求文字更自然時，使用 `humanizer-zh-tw`。

## 模式選擇

- **inspect**：只檢查並報告，不修改內容。
- **layer-a**：只做不可見文字清理，預設保守模式。
- **layer-b**：只做一次統計式改寫；需明確同意可能的語意與語氣漂移。
- **full**：`inspect → Layer A → Layer B（可選）→ Layer A → after inspect`。

如果使用者同時要求去 AI 味與去浮水印，採用：

```text
保護非 prose 區段 → inspect → Layer A → humanizer-zh-tw → 可選 Layer B → Layer A → after inspect
```

## 執行流程

### 1. 先分類與保護內容

先確認輸入是貼上文字、`.txt`、`.md` 還是 `.html`。在任何改寫前，保護下列內容，除非使用者明確要求修改：

- Markdown fenced code、inline code、HTML tag、attribute、script、style。
- URL、檔案路徑、API 名稱、變數名、錯誤碼、版本號與其他技術識別字。
- 數字、日期、專有名詞、引用、參考文獻、法律／學術／平台必要揭露。
- 使用者要求逐字保留的句子。

不要把 DOCX、PDF、圖片、音訊、影片或 ZIP/Office 容器當成純文字讀寫。這些檔案需要另外的容器或 metadata 工具；否則可能破壞二進位內容。

### 2. Inspect first

本技能優先使用內附的本地 deterministic scripts；它們是從 [`guillaumemeyer/watermarks-remover`](https://github.com/guillaumemeyer/watermarks-remover) 的 `service/scripts` 擷取，並保留上游 MIT 授權。Windows PowerShell 執行方式：

```powershell
$skillRoot = (Resolve-Path .\text-watermark-cleaner-zh-tw).Path
& "$skillRoot\scripts\run-text-watermark.ps1" `
  -Mode Inspect -InputPath .\article.md -Json
```

需要較嚴格的檢查時才加上 `-Aggressive` 或 `-StripEmojiGlue`。若要同時取得統計式報告，可加 `-Stylometry`；這是分析訊號，不是 Claude 官方 detector。

若部署環境提供相容的 `watermarks-remover` HTTP service，也可先檢查：

```text
GET  $WATERMARKS_SERVICE_URL/health
GET  $WATERMARKS_SERVICE_URL/capabilities
POST $WATERMARKS_SERVICE_URL/inspect
```

服務不可達時，不要假裝完成服務端清理；可使用本地腳本完成 Layer A，並在報告中分別標示「本地腳本已驗證」與「服務端未驗證」。聊天中的文字沒有可保證的 post-send Unicode filter；只能進行受保護的模型內處理，並在報告中標示限制。

### 3. 執行 Layer A

使用內附 `scripts/run-text-watermark.ps1 -Mode Clean`、服務的 `/clean` 或等效 deterministic cleaner，並保留原檔，預設產生 `*.cleaned.*`。本地入口範例：

```powershell
& "$skillRoot\scripts\run-text-watermark.ps1" `
  -Mode Clean -InputPath .\article.md -OutputPath .\article.cleaned.md -Stats
```

採用保守選項：

- 不預設套用 NFKC。
- 不預設把所有特殊空白改成半形空白。
- 不預設使用 aggressive homoglyph mapping。
- 不預設刪除合法 RTL/LTR 控制、emoji glue、CJK variation selector 或其他有排版／語意作用的不可見字元。

本地 wrapper 預設加入 `--no-normalize-spaces`；只有使用者明確接受版面、方向性或多語文字形可能改變時，才啟用 `-Aggressive`、`-NormalizeSpaces`、`-Nfkc` 或 `-StripBidi`。不要使用 `--force-text` 處理 DOCX、PDF 或其他二進位容器。

### 4. 執行 Layer B（可選）

只有在使用者明確選擇 `layer-b` 或 `full` 時執行。若來源疑似為 Claude，優先使用本地模型或不同供應商；不要把同一來源模型的輸出當成獨立驗證。

改寫要求：

- 改變詞彙、功能詞、子句順序、連接詞、句界與句長。
- 保留所有事實、數字、名稱、引用、技術識別字、必要揭露與原作者真正的觀點。
- 不新增第一人稱經驗、對話、來源、回饋、數據或背景故事。
- 不為了增加變化而翻譯、改成簡體、改寫引用或改動程式碼。
- 預設只做一輪；若使用者要求更強改寫，先提醒語意與文風漂移風險。

改寫後再跑一次 Layer A；Layer B 的結果只能標示為 **best-effort**。若有相同 watermark key/config 的研究性 detector，才可報告該特定設定的 before/after，不能外推成 Claude 官方偵測結果。

### 5. 交付報告

分開報告三種結果：

1. **可驗證**：刪除／替換哪些 Unicode、數量多少、metadata 是否仍存在。
2. **Best-effort**：文字是否經過統計式改寫、改寫輪數與使用的 backend。
3. **尚未建立**：官方 Claude detector、秘密 key watermark、可見像素浮水印、soft binding 或「人類作者身份」。

如果沒有實際 inspect/after evidence，就寫「未驗證」，不要用文字看起來更自然來代替證據。

## 繁體中文規則

繁體中文是本 skill 的主體語境；英文技術名詞只用於觸發與服務介面。詳細的中文保護規則見 [`references/chinese-text.md`](references/chinese-text.md)。

- 保留繁體字、全形標點、中文引號「」與『』，不要擅自翻譯或簡繁轉換。
- 不把中文沒有空格誤判為異常，也不把 U+3000、NBSP 或窄不換行空白一律改掉。
- 保留 emoji 組合、CJK variation selector、合法中文排版與引用格式。
- 中文可讀性以本地語感判斷；不要用英文 token 數、MATTR 或句長閾值單獨判定浮水印。
- 「此外」「值得注意的是」「在……背景下」「這不僅……而且……」等屬於語氣修訂範圍，不是 Layer A 的證據；需要時交給 `humanizer-zh-tw`，不要把它們當作已偵測到 watermark。

## 失敗處理

- 原檔、輸出檔與報告分開保存；除非使用者明確要求，不要 in-place 覆寫。
- 清理前後都無差異時，回報 `no actionable text marks found`，不要製造新的檔案變更。
- 格式未知、檔案過大、service 不可達或 detector 未設定時，清楚回報原因並停止該層，不要靜默 fallback。
- 任何必要揭露、作者聲明、引用或合規文字都必須保留。

## 本地資源與來源

- `scripts/common.py`、`scripts/text_unicode.py`、`scripts/clean_text.py`、`scripts/inspect_text.py` 與 `scripts/score_stylometry.py` 來自上游 `watermarks-remover` 的 `service/scripts`。
- `scripts/run-text-watermark.ps1` 是本 repo 的 Windows PowerShell 入口，負責傳入 UTF-8、保守清理選項與 `.cleaned` 輸出路徑。
- 上游授權副本見 [`scripts/LICENSE-watermarks-remover.txt`](scripts/LICENSE-watermarks-remover.txt)；擷取版本為 commit `4a0fbc312f2e5138c35d270d9db284cc07689930`。

## 典型請求

- 「請只檢查這段繁中是否有不可見文字標記，不要改內容。」→ `inspect`
- 「請清理這個 Markdown 的 zero-width 字元，保留程式碼與引用。」→ `layer-a`
- 「請降低這段 Claude 文字的統計式標記，允許輕微改寫，但不要新增事實。」→ `layer-b`
- 「先去浮水印，再幫我去 AI 味。」→ `full`，並依序執行保護、Layer A、humanizer、可選 Layer B、Layer A。
