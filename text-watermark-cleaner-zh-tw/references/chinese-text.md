# 中文文字保護規則

這份參考只在處理中文、混合中英或含多語排版的文字浮水印時讀取。

## 預設保留

- 繁體字、簡體字與使用者原本的語言，不做自動翻譯或簡繁轉換。
- 全形標點：`，。！？：；（）「」『』【】`。
- 中文段落中有意義的 U+3000 ideographic space、NBSP 與窄不換行空白。
- emoji 的 zero-width joiner、variation selector、旗幟 tag sequence。
- 中文、日文、韓文文字附近的 variation selector 與其他字形控制。
- Markdown code、URL、HTML attribute、JSON、YAML、SQL、程式碼註解中的精確字串，除非使用者指定要清理該區段。

## 可檢查但不要直接刪除

下列字元可能是浮水印載體，也可能是合法文字方向或排版控制；先報告位置與數量，只有使用者同意 aggressive 清理才移除：

- LRM、RLM、LRI、RLI、FSI、PDI。
- 中文或其他 CJK 內容中的特殊空白。
- 位於 emoji、CJK、阿拉伯文、Indic script 或其他複雜文字序列中的 ZWJ/ZWNJ/variation selector。

## 高可信清理候選

孤立的 zero-width space、word joiner、soft hyphen、combining grapheme joiner、tag character、非字元與沒有語意上下文的 private-use code point 可以列為 Layer A 候選。仍然要保留 before/after 統計，並重新檢查輸出。

## 中文驗收

至少確認：

1. 繁體字數量與簡繁狀態沒有被意外改變。
2. 全形標點、中文引號與段落換行仍然存在。
3. 程式碼、URL、數字、日期、名稱、引用與必要揭露保持不變。
4. 沒有把「中文本來沒有空格」誤判為異常。
5. Layer B 改寫後仍然保留原文的觀點與不確定性，沒有新增「我曾經……」等虛構經歷。
