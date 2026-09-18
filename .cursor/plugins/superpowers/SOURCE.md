# Superpowers (vendored for Cloud Agents)

Upstream: https://github.com/obra/superpowers  
Version: **v6.3.0**  
Commit: `b36e0829c6d0140e93cfef2ca599b1b07d4a7797`  
License: MIT (see `LICENSE`)

## Why this is vendored

Cursor marketplace plugins (including [Superpowers](https://cursor.com/marketplace/superpowers)) install in the desktop Agent UI via `/add-plugin superpowers`, but Cloud Agents do not reliably receive user-scoped marketplace installs. Cursor’s recommended workaround is to commit skills under `.cursor/skills/` so every Cloud Agent checkout can load them.

## Layout

| Path | Purpose |
|------|---------|
| `.cursor/skills/*` | Skill library (auto-discovered by Cursor Agent / Cloud Agents) |
| `.cursor/hooks.json` | Session-start bootstrap that injects `using-superpowers` |
| `.cursor/plugins/superpowers/hooks/` | Hook scripts adapted for this repo |

## Desktop install (recommended for local IDE)

In Cursor Agent chat:

```text
/add-plugin superpowers
```

Or install from https://cursor.com/marketplace/superpowers

## Updating

Re-copy skills from a newer upstream tag and bump the version/commit in this file.
