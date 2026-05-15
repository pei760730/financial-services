# 上游同步紀錄

這個 repo 的內容是從 Anthropic 官方範例 repo 挑選後複製過來的學習素材。
本檔案紀錄「來源、版本、怎麼追蹤更新、怎麼同步」。

## 來源

- 上游 repo：https://github.com/anthropics/financial-services
- License：見上游 `LICENSE`（MIT）
- 同步基準 commit：`853f755a61f7bbb045c681327f46b354419030a1`
- 同步基準日期：2026-05-09
- 上次同步 commit message：`feat(claude-in-office): add disabled_features manifest param (#154)`

## 已複製的內容

只挑「股票研究 pipeline」相關的 5 個資料夾，重新命名加上順序前綴：

| 本 repo 路徑 | 上游路徑 |
|---|---|
| `learn-from-anthropic/equity-research-pipeline/1-market-researcher/` | `managed-agent-cookbooks/market-researcher/` |
| `learn-from-anthropic/equity-research-pipeline/2-equity-research/` | `plugins/vertical-plugins/equity-research/` |
| `learn-from-anthropic/equity-research-pipeline/3-earnings-reviewer/` | `managed-agent-cookbooks/earnings-reviewer/` |
| `learn-from-anthropic/equity-research-pipeline/4-financial-analysis/` | `plugins/vertical-plugins/financial-analysis/` |
| `learn-from-anthropic/equity-research-pipeline/5-model-builder/` | `managed-agent-cookbooks/model-builder/` |

## 追蹤上游更新

### 方法 A：路徑 RSS（推薦，精準到資料夾）

把下列網址加進你的 RSS 閱讀器（Feedly / Inoreader / NetNewsWire 等）。
只要對應資料夾有 commit 就會跳通知，不會被無關更新打擾。

```
https://github.com/anthropics/financial-services/commits/main/managed-agent-cookbooks/market-researcher.atom
https://github.com/anthropics/financial-services/commits/main/plugins/vertical-plugins/equity-research.atom
https://github.com/anthropics/financial-services/commits/main/managed-agent-cookbooks/earnings-reviewer.atom
https://github.com/anthropics/financial-services/commits/main/plugins/vertical-plugins/financial-analysis.atom
https://github.com/anthropics/financial-services/commits/main/managed-agent-cookbooks/model-builder.atom
```

### 方法 B：GitHub Watch（粗略，整個 repo）

到 https://github.com/anthropics/financial-services 右上角點 `Watch` →
`Custom` → 勾 `Pushes`。任何更新都會通知你，雜訊較多。

### 方法 C：本機加 upstream remote（主動查詢）

```bash
git remote add upstream https://github.com/anthropics/financial-services.git
git fetch upstream

# 看自上次同步以來，上游某個資料夾的所有 commit
git log --oneline 853f755..upstream/main -- managed-agent-cookbooks/market-researcher
```

## 怎麼把上游更新同步進來

當 RSS 跳通知，例如 `market-researcher` 有新 commit：

```bash
# 1. 拿一份最新的上游 clone（或 git pull 已有的）
cd /tmp && git clone --depth 1 https://github.com/anthropics/financial-services.git tmp-upstream

# 2. 看 diff，確認你想不想要這次的改動
diff -ru \
  /home/user/financial-services/learn-from-anthropic/equity-research-pipeline/1-market-researcher \
  /tmp/tmp-upstream/managed-agent-cookbooks/market-researcher

# 3. 想要的話，整個資料夾覆蓋
rsync -a --delete \
  /tmp/tmp-upstream/managed-agent-cookbooks/market-researcher/ \
  /home/user/financial-services/learn-from-anthropic/equity-research-pipeline/1-market-researcher/

# 4. 更新本檔的「同步基準 commit」欄位
# 5. commit：例如 "sync: market-researcher to upstream <new-hash>"
```

> 提醒：如果你已經對 `1-market-researcher/` 做過自己的修改，rsync 覆蓋會蓋掉你的改動。
> 那種情況改用 `diff` 看清楚再手動 merge，或先 commit 自己的修改、再用 `git checkout -p`
> 挑揀上游的改動。

## 已知缺漏（Known gaps from upstream）

下列檔案在上游 SKILL.md / README 內被引用，但目前的本機鏡像沒有複製進來
（多半是二進位資產或 orchestration script）。`scripts/check.sh` 會把它們列為
WARN 而不是 FAIL，名單放在 `scripts/known-gaps.txt`：

- `4-financial-analysis/skills/ppt-template-creator/assets/template.pptx` — 簡報模板，二進位檔。
- `1-market-researcher/scripts/orchestrate.py`
- `3-earnings-reviewer/scripts/orchestrate.py`
- `5-model-builder/scripts/orchestrate.py`

`orchestrate.py` 是 cookbook 在 Anthropic 雲端執行時用的協調腳本，本機學習用不到，
故未複製。`template.pptx` 同步時若想補進來，從上游
`plugins/vertical-plugins/financial-analysis/skills/ppt-template-creator/assets/`
拉一份再從 `scripts/known-gaps.txt` 移除對應行即可。

## License 注意事項

上游採 MIT License。你保留本資料夾結構即視為合理使用，
若公開散佈衍生作品，記得在你的 repo 補上對上游的歸屬說明。
