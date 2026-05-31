---
name: handoff
description: "Compact the current conversation into a self-contained handoff document so a fresh agent (new chat, another machine, another AI client) can continue the work without re-discovering the context. References durable artifacts (`PROJECT.md`, commits) instead of duplicating them. Use when the user says 'handoff', 'compact session', 'save context for continuation'."
argument-hint: "Optional: focus of the next session, or a target path/folder for the handoff file."
---

# handoff — session transfer to the next agent

Compresses the current conversation into a self-contained document for the next session. Principle: **reference durable artifacts, do not duplicate them**.

## Triggers

- "handoff", "compact session"
- "save context for continuation", "brief the next session"
- Russian: "сделай handoff", "передай контекст", "сохрани контекст для продолжения"

## Where to write

1. Default: `handoffs/handoff-<YYYYMMDD-HHMMSS>.md` at project root.
2. Create `handoffs/` if missing.
3. User-provided path overrides the default.

PowerShell path conventions — see `powershell-windows` skill (Windows).

## Document structure

```markdown
# Handoff: <one-line session goal>

**When**: <YYYY-MM-DD HH:MM local>
**Branch / commit**: <branch>, latest commit <short SHA + subject>
**Next session focus**: <focus, if provided>

## Current State
What was done, what remains, what is blocked.

## Open Questions
Unresolved questions. Omit if empty.

## Files Changed In This Session
- `path/to/file` — what changed and why.

## Verification State
EDT validation result (`revalidate_objects`, `get_project_errors`, `get_problem_summary`).

## Next Steps
1-5 imperative items for the next session.

## What To Load Next Session
- **Rules**: from `AGENTS.md → Additional rules` by task type.
- **Skills**: `edt-mcp-tools`, `1c-metadata-manage`, etc.
- **MCP**: relevant EDT tools for the next task.

## Links (DO NOT copy content)
- `PROJECT.md` — relevant sections
- Commits / PR / Issue
```

## What NOT to write

- Full module code — path and summary only.
- Secrets, tokens, passwords, `.dev.env` contents.
- Long MCP output dumps.

## After writing

Tell the user the file path. If durable facts emerged, suggest updating `PROJECT.md` — do not create separate memory files.

## Boundaries

- Handoff is a session artifact, not configuration.
- Written in normal grammar, not caveman style.
