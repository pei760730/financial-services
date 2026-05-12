# financial-services (learning mirror)

This repo is **not a product**. It is a curated, read-mostly mirror of the
equity-research pipeline examples from
[anthropics/financial-services](https://github.com/anthropics/financial-services),
kept here for study and personal experimentation.

## Start here

| File | Purpose |
|---|---|
| [`LEARNING_PATH.md`](LEARNING_PATH.md) | Suggested reading order through the five pipeline folders. |
| [`UPSTREAM.md`](UPSTREAM.md) | Where the content came from, how to track upstream changes, how to resync. |
| [`CLAUDE.md`](CLAUDE.md) | Behaviour rules for AI coding agents working in this repo. |

## Layout

```
learn-from-anthropic/equity-research-pipeline/
  1-market-researcher/      managed-agent cookbook
  2-equity-research/        Claude Code plugin
  3-earnings-reviewer/      managed-agent cookbook
  4-financial-analysis/     Claude Code plugin
  5-model-builder/          managed-agent cookbook
scripts/check.sh            smoke validator (JSON + YAML + Python + doc refs)
scripts/known-gaps.txt      paths referenced in docs but intentionally absent
```

## Validate

```bash
bash scripts/check.sh
```

The validator is read-only. It checks every tracked JSON/YAML file for syntax,
compiles every tracked Python file, and verifies that paths referenced from
`SKILL.md` files actually exist (warnings for entries in `known-gaps.txt`).

## What this repo is not

- Not a runnable product.
- Not a fork (no PRs flow back to upstream from here).
- Not a place to add new application code — see `UPSTREAM.md` before changing
  anything under `learn-from-anthropic/`.
