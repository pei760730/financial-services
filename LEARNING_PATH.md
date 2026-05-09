# 股票研究 Pipeline 學習導讀

這份導讀帶你按順序讀完 `learn-from-anthropic/equity-research-pipeline/` 下面 5 個資料夾，
最後你會理解 Anthropic 怎麼用 multi-agent 設計一條完整的股票研究流程。

## 大圖：四個階段，五個 agent

```
[產業層] 1-market-researcher    → 從產業/主題挑出值得追蹤的個股清單
              ↓ handoff
[個股層] 2-equity-research      → 對選定的股票做覆蓋研究、發 morning note、追 thesis
              ↓
[事件層] 3-earnings-reviewer    → 每季財報出來時，更新模型 + 寫 note
              ↓ handoff
[模型層] 5-model-builder        → DCF / LBO / 三表模型，給上面三層當 handoff 對象

[工具層] 4-financial-analysis   → 通用財務建模工具，本機 Claude Code plugin，可獨立使用
```

## 兩種包裝形式（重要觀念）

讀之前先理解這個，否則會覺得內容重複：

| 形式 | 路徑特徵 | 跑在哪 | 學到什麼 |
|---|---|---|---|
| **Managed Agent cookbook** | `agent.yaml` + `subagents/*.yaml` | Anthropic 雲端，要付 API 費 | multi-agent 設計、權限隔離、handoff |
| **Claude Code plugin** | `.claude-plugin/` + `commands/` + `skills/` | 你本機的 Claude Code | 同樣概念，但變成本機指令 + 技能 |

本 repo 5 個資料夾的對照：

| 資料夾 | 形式 |
|---|---|
| 1-market-researcher | Cookbook（雲端） |
| 2-equity-research | Plugin（本機） |
| 3-earnings-reviewer | Cookbook（雲端） |
| 4-financial-analysis | Plugin（本機） |
| 5-model-builder | Cookbook（雲端） |

## 推薦閱讀順序

### 第 1 站：`1-market-researcher/`（最小，先讀懂 cookbook 結構）

**目標**：搞懂 Anthropic 的 managed agent 是怎麼設計的。

**讀的順序**：
1. `README.md` — 看 Overview 那張安全表格，理解三層隔離（讀取者 / 協調者 / 寫入者）
2. `agent.yaml` — 主 agent 的設定，看它有哪些 tools、connectors
3. `subagents/sector-reader.yaml` — 唯一接觸「不可信外部文件」的子 agent，注意它的 tools 為什麼最少
4. `subagents/comps-spreader.yaml` — 跑同業比較
5. `subagents/note-writer.yaml` — 唯一持有 `Write` 權限的子 agent
6. `steering-examples.json` — 看怎麼觸發這個 agent

**重點觀察**：
- 為什麼 `sector-reader` 不能用 `Write`？→ 安全設計：碰過外部資料的子 agent 不能寫檔，避免 prompt injection 把惡意內容寫到輸出
- 為什麼 `note-writer` 不能用任何 connector？→ 同理，能寫檔的子 agent 不准接觸外部資料
- 這個「**讀寫分離 + 信任分層**」是後面所有 cookbook 都會重複出現的設計模式

### 第 2 站：`5-model-builder/`（看 handoff 的對象長怎樣）

**為什麼先跳到 5？** 因為 `1-market-researcher` 的 README 說它會 handoff 給 `model-builder`，
你不看 5 就不知道在 handoff 什麼。

**讀的順序**：
1. `README.md` — 注意 `builder` 這個子 agent 同時有 `Write` + `Bash`，但 Bash 是 sandboxed
2. `subagents/` 三個檔 — `data-puller` / `builder` / `auditor` 的角色分工
3. 關鍵設計：**`auditor` 在 `builder` 寫完 xlsx 之後再驗算一次**——這是 LLM 容易算錯時的補救機制

**重點觀察**：
- 比較 1 跟 5 的隔離模式：1 是「來源不可信」，5 是「來源可信但結果要驗算」，所以隔離方式不同
- handoff 怎麼運作 → 看 README 提到的 `scripts/orchestrate.py`（不在本 repo，有興趣去上游看）

### 第 3 站：`3-earnings-reviewer/`（驗證你看懂模式了沒）

**目標**：自己動手分析這個 cookbook 的設計，不要看我寫的，看你能不能自己看出三層隔離。

**讀的順序**：
1. `README.md`、`agent.yaml`、`subagents/*.yaml`
2. 自問：哪個子 agent 接觸不可信資料？哪個持有 `Write`？handoff 給誰？

如果你能回答出來，代表 cookbook 的設計模式已經吃進去了。

### 第 4 站：`2-equity-research/`（換成本機 plugin 形式）

**目標**：看同樣的 agent 概念，怎麼包裝成本機 Claude Code 外掛。

**讀的順序**：
1. `.claude-plugin/plugin.json` — plugin 元資料
2. `commands/` 資料夾下的每個 `.md` 檔 — 這些就是你之後在 Claude Code 打 `/earnings`、`/morning-note` 之類的 slash command
3. `skills/` 資料夾下的每個子資料夾 — Claude Code 的 skill 機制，看 `SKILL.md`

**重點觀察**：
- cookbook 用 yaml 描述子 agent，plugin 用 markdown 描述 command/skill —— 但**核心 prompt 工程是一樣的**
- 你之後可以在本機把這個 plugin 裝進 Claude Code 直接玩（裝法見上游 README）

### 第 5 站：`4-financial-analysis/`（工具箱）

**目標**：這個是「通用財務建模工具」，不只給股票研究用。看完前面四個再來看，
你會發現它就是 5-model-builder 的「散裝零件版」（DCF / comps / LBO / 三表 / 簡報 QC 各自獨立）。

**讀的順序**：
1. `commands/dcf.md` — 最經典的估值方法
2. `commands/comps.md` — 同業比較（呼應 `1-market-researcher` 的 `comps-spreader`）
3. `skills/dcf-model/` 跟 `skills/comps-analysis/` — 對應的技能定義
4. 其他 LBO / 三表模型 / 簡報自動化 …… 看你需求

## 學完之後你會有的能力

1. 看懂 Anthropic 的 multi-agent 設計模式（讀寫分離、信任分層）
2. 知道 cookbook（雲端）跟 plugin（本機）兩種包裝怎麼選
3. 能自己改一個現成的 cookbook，套到自己關心的研究主題上
4. 能在本機 Claude Code 裝起 `2-equity-research` plugin 跑跑看

## 跟著上游一起進步

當你開始改造其中某個資料夾時，記得讀 `UPSTREAM.md`，
裡面寫了怎麼追蹤上游更新、怎麼把上游新版本同步進來而不蓋掉你的改動。
