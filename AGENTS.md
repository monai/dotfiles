## Rules

- Tell the user to refresh generated state after source changes that invalidate it.
- Add compatibility shims only when requested.
- Zsh has no real file-local named functions; avoid pretend-local helper functions. Use anonymous functions or inline code for private logic, and `ng` names for shared zsh functions.
- Report architecture tradeoffs before changing an agreed implementation shape.

## Agent skills

### Issue tracker

Issues and specs are tracked as local markdown files under `.scratch/`. See `docs/agents/issue-tracker.md`.

### Triage labels

This repo uses the default engineering-skill triage labels. See `docs/agents/triage-labels.md`.

### Domain docs

This repo uses a single-context domain docs layout. See `docs/agents/domain.md`.
