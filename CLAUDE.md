# CLAUDE.md

Behavioral guidelines to reduce common LLM coding mistakes. Merge with project-specific instructions as needed.

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

## 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

## 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:
```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

---

**These guidelines are working if:** fewer unnecessary changes in diffs, fewer rewrites due to overcomplication, and clarifying questions come before implementation rather than after mistakes.

---

## Repo-specific rules for this mirror

This repo is a **learning mirror** of `anthropics/financial-services`. It is
not a product. Read `UPSTREAM.md` before editing anything under
`learn-from-anthropic/`.

### Scope

- Anything under `learn-from-anthropic/equity-research-pipeline/` is
  upstream-imported content. Treat it as read-mostly: do not refactor, rename,
  or "improve" it, because that breaks resync (`rsync -a --delete` from upstream
  will overwrite your changes anyway).
- Root files (`README.md`, `LEARNING_PATH.md`, `UPSTREAM.md`, `CLAUDE.md`,
  `scripts/`, `.gitignore`) are local-only and safe to edit.

### Validation

The single validation command is:

```bash
bash scripts/check.sh
```

It checks JSON/YAML syntax, Python compilation, and SKILL.md path references.
Known-missing upstream files are listed in `scripts/known-gaps.txt` and surface
as WARN, not FAIL. Run it after any change.

### Definition of done

A change is done when:

1. `bash scripts/check.sh` exits 0.
2. If you modified anything under `learn-from-anthropic/`, you also explained
   in your reply why upstream-mirror divergence is justified.
3. If you added a new doc reference, the referenced file exists or is listed in
   `scripts/known-gaps.txt`.

### Do not, without explicit instruction

- Modify files under `learn-from-anthropic/equity-research-pipeline/`.
- Add runtime/CI infrastructure (GitHub Actions, Docker, deploy scripts).
- Install new dependencies or change `scripts/check.sh` to require non-stdlib
  packages beyond `pyyaml`.
- Delete `scripts/known-gaps.txt` entries to "make checks pass"; the right fix
  is to either resync from upstream or add a `references/...` note.
- Commit, push, branch, or open PRs unless the user explicitly asks.
