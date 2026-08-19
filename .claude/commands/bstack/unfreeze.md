---
name: bstack:unfreeze
description: 'Clear the freeze boundary set by /bstack:freeze, allowing edits to all directories again'
model: haiku
---

> **TASK TRACKING:** Single task: apply the toggle and confirm state. Mark complete when done.

# /bstack:unfreeze — Clear freeze boundary

Remove the edit restriction set by `/bstack:freeze`.

## Steps

```bash
STATE_FILE=".claude/state/freeze-dir.txt"
if [ -f "$STATE_FILE" ]; then
  PREV=$(cat "$STATE_FILE")
  rm -f "$STATE_FILE"
  echo "Freeze boundary cleared (was: $PREV). Edits are allowed everywhere."
else
  echo "No freeze boundary was set."
fi
```

Tell the user the result. The PreToolUse hook is still registered for the session — it will simply allow all paths since no state file exists. To re-freeze, run `/bstack:freeze` again.
