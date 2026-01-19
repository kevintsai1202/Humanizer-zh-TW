# Humanizer-zh-TW: AI 寫作人性化工具（繁體中文版）

> **聲明：**
>
> - 本專案由 [op7418/Humanizer-zh](https://github.com/op7418/Humanizer-zh) 繁體化而來
> - 本專案的核心檔案翻譯自 [blader/humanizer](https://github.com/blader/humanizer/tree/main)
> - 實用工具部分（核心規則、快速檢查清單、品質評分）參考了 [hardikpandya/stop-slop](https://github.com/hardikpandya/stop-slop)
> - 原專案基於維基百科的 [Signs of AI writing](https://en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing) 指南

---

## 專案簡介

Humanizer-zh-TW 是一個用於去除文字中 AI 生成痕跡的工具，幫助你將 AI 生成的內容改寫得更自然、更像人類書寫的文字。

本專案適用於：

- 編輯和審閱 AI 生成的內容
- 提升文章的人性化程度
- 學習辨識 AI 寫作的常見模式

## 安裝

### 方式一：透過 npx 一鍵安裝(Claude Code)

```bash
npx skills add https://github.com/kevintsai1202/Humanizer-zh-TW.git
```

這是最簡單的安裝方式，會自動將技能安裝到正確的目錄。

### 方式二：透過 Git 複製

```bash
# 複製到 Claude Code 的 skills 目錄
git clone https://github.com/kevintsai1202/Humanizer-zh-TW.git ~/.claude/skills/humanizer-zh-tw
# 複製到 Antigravity 的 skills 目錄
git clone https://github.com/kevintsai1202/Humanizer-zh-TW.git ~/.gemini/antigravity/skills/humanizer-zh-tw
# 複製到 Roo Code 的 skills 目錄
git clone https://github.com/kevintsai1202/Humanizer-zh-TW.git ~/.roocode/skills/humanizer-zh-tw
# 複製到 Codex 的 skills 目錄
git clone https://github.com/kevintsai1202/Humanizer-zh-TW.git ~/.codex/skills/humanizer-zh-tw
# 複製到 Gemini CLI 的 skills 目錄
git clone https://github.com/kevintsai1202/Humanizer-zh-TW.git ~/.gemini/cli/skills/humanizer-zh-tw
```

### 方式三：手動安裝

1. 下載本專案的 ZIP 檔案或複製到本機
2. 將 `Humanizer-zh-TW` 資料夾複製到對應工具的技能目錄：

   - **Claude Code**:
     - **macOS/Linux**: `~/.claude/skills/`
     - **Windows**: `%USERPROFILE%\.claude\skills\`
   - **Antigravity**:
     - **macOS/Linux**: `~/.gemini/antigravity/skills/`
     - **Windows**: `%USERPROFILE%\.gemini\antigravity\skills\`

3. 確保資料夾結構如下（以 Claude Code 為例）：

   ```
   ~/.claude/skills/humanizer-zh-tw/
   ├── SKILL.md       # 技能定義檔案（繁體中文版）
   └── README.md      # 說明文件
   ```

### 驗證安裝

重新啟動 Claude Code / Antigravity 或重新載入 skills 後，在對話中輸入：

```
/humanizer-zh
```

如果安裝成功，該技能將被啟用。

## 使用

### 基礎用法

在 Claude Code 或 Antigravity 中，你可以透過以下方式使用 Humanizer：

#### 1. 直接呼叫技能

```
/humanizer-zh 請幫我人性化以下文字：

[貼上你的 AI 生成文字]
```

#### 2. 在對話中使用

```
請用 humanizer 幫我改寫這段話，讓它更自然：

這個專案作為我們團隊致力於創新的證明。此外，它展示了我們在不斷演進的技術佈局中的關鍵角色。
```

#### 3. 處理檔案內容

```
/humanizer-zh 請人性化 article.md 檔案中的內容
```

### 使用場景範例

#### 場景 1：改寫行銷文案

**輸入：**

```
/humanizer-zh
坐落在風景如畫的台北市中心，這家咖啡館擁有豐富的文化底蘊和令人讚嘆的裝飾。它作為城市咖啡文化的焦點，為顧客提供無縫、直觀和充滿活力的體驗。
```

**輸出範例：**

> 這家咖啡館在台北市中心開了三年，以手沖咖啡和老建築改造的空間聞名。

#### 場景 2：改寫學術摘要

**輸入：**

```
/humanizer-zh
本研究深入探討了機器學習在醫療診斷中的關鍵角色，突顯了其在不斷演進的醫療佈局中的重要性。此外，它為該領域的未來發展奠定了堅實的基礎。
```

**輸出範例：**

> 本研究分析了機器學習在醫療診斷中的應用，重點是肺癌早期篩查。研究使用了 2019-2023 年間 5000 例病歷資料。

#### 場景 3：改寫部落格文章

**輸入：**

```
/humanizer-zh
人工智慧不僅僅是一種技術，它是我們思考未來方式的革命。業界專家認為這將對整個社會產生長遠影響。
```

**輸出範例：**

> 我一直在想 AI 會怎麼改變我們的工作方式。上週和幾個做產品的朋友聊，有人覺得很興奮，有人擔心失業，大概率真相在中間某個無聊的地方。

## 偵測的 AI 寫作模式

本工具能夠辨識並修復 **24 種** AI 寫作痕跡，分為四大類：

### 📝 內容模式（6種）

1. 過度強調意義、遺產和更廣泛的趨勢
2. 過度強調知名度和媒體報導
3. 以 -ing 結尾的膚淺分析
4. 宣傳和廣告式語言
5. 模糊歸因和含糊措辭
6. 提綱式的「挑戰與未來展望」部分

### 🔤 語言和語法模式（6種）

7. 過度使用的「AI 詞彙」
8. 避免使用「是」（繫詞迴避）
9. 否定式排比
10. 三段式法則過度使用
11. 刻意換詞（同義詞循環）
12. 虛假範圍

### 🎨 風格模式（6種）

13. 破折號過度使用
14. 粗體過度使用
15. 內嵌標題垂直列表
16. 標題中的首字母大寫（針對英文）
17. 表情符號
18. 彎引號

### 💬 交流模式和填充詞（6種）

19. 共用交流痕跡
20. 知識截止日期免責聲明
21. 諂媚/卑躬屈膝的語氣
22. 填充短語
23. 過度限定
24. 通用積極結論

## 檔案說明

- **`SKILL.md`** - 繁體中文版技能定義檔案
- **`README.md`** - 本說明文件

**註：** 英文原版請參考 [blader/humanizer](https://github.com/blader/humanizer)

## 手動使用方法

### 基本流程

1. **辨識 AI 模式** - 對照 `SKILL.md` 中列出的 24 種模式掃描文字
2. **重寫問題片段** - 用自然的表達替換 AI 痕跡
3. **保留核心含義** - 確保資訊完整性
4. **維持適當語調** - 匹配文字應有的風格
5. **注入真實個性** - 讓文字有「人味」

### 關鍵原則

#### ✨ 不僅要「乾淨」，更要「鮮活」

避免 AI 模式只是基礎，好的寫作需要真實的人類聲音：

- **有觀點** - 不要只報告事實，要對它們做出反應
- **變化節奏** - 混合使用長短句
- **承認複雜性** - 真實的人有複雜感受
- **適當使用「我」** - 第一人稱是誠實的表現
- **允許一些混亂** - 完美的結構反而顯得機械
- **對感受要具體** - 用具體細節替代抽象概括

#### 範例對比

**改寫前（AI 味道）：**

> 新的軟體更新作為公司致力於創新的證明。此外，它提供了無縫、直觀和強大的使用者體驗——確保使用者能夠高效地達成目標。這不僅僅是一次更新，而是我們思考生產力方式的革命。

**改寫後（人性化）：**

> 軟體更新加入了批次處理、鍵盤快捷鍵和離線模式。來自測試使用者的早期回饋是積極的，大多數報告任務達成速度更快。

**變化：**

- 刪除了誇大的象徵意義（「作為……的證明」）
- 刪除了 AI 詞彙（「此外」、「無縫」）
- 刪除了三段式法則（「無縫、直觀和強大」）
- 刪除了否定式排比（「不僅僅是……而是……」）
- 加入了具體功能和真實回饋

## 常見 AI 詞彙警示列表

以下詞彙在 AI 生成文字中出現頻率異常高：

- 此外、至關重要、深入探討、強調
- 持久的、增強、培養、獲得
- 突顯、相互作用、複雜/複雜性
- 佈局（抽象名詞）、關鍵性的、展示
- 織錦（抽象名詞）、證明、強調
- 寶貴的、充滿活力的

## 貢獻

如果你發現翻譯問題或想要改進文件，歡迎提交 Issue 或 Pull Request。

### 中文語境特殊性

在翻譯和適配過程中，我們考慮了中文寫作的特點：

- 某些英文模式在中文中表現不同（如標題大小寫問題）
- 加入了適合中文語境的範例
- 調整了部分表達以符合中文習慣

## 參考資源

- [Wikipedia: Signs of AI writing](https://en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing) - 原始指南來源
- [WikiProject AI Cleanup](https://en.wikipedia.org/wiki/Wikipedia:WikiProject_AI_Cleanup) - 維基百科 AI 清理專案
- [blader/humanizer](https://github.com/blader/humanizer) - 原始英文版專案
- [hardikpandya/stop-slop](https://github.com/hardikpandya/stop-slop) - 實用工具部分的靈感來源

## 許可

本翻譯專案遵循原專案的許可協定。核心內容基於維基百科社群的觀察和總結。

---

**提示：** 這個工具不是為了「欺騙」 AI 偵測器，而是為了真正提升寫作品質。最好的「去 AI 化」方法是讓文字有真實的人類思考和聲音。
