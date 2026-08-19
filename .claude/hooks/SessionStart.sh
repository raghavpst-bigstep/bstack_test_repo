#!/bin/bash
# bstack — SessionStart hook
# Bootstraps the session with current branch, recent commits, and
# pointers to the most-relevant institutional knowledge.

set -u

echo "=== bstack session ==="
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Branch: $(git branch --show-current)"
  echo "Last 3 commits:"
  git log --oneline -3
  CHANGED=$(git status --porcelain | wc -l | tr -d ' ')
  echo "Uncommitted changes: ${CHANGED} files"
else
  echo "(not a git repo)"
fi

echo ""

# Reminders that compound over time
if [ -d docs/solutions ]; then
  echo "Knowledge-first: run 'bin/bstack-solutions search \"<keywords>\"' BEFORE writing code."
fi
if [ -f .claude/rules/critical-patterns.md ]; then
  echo "Read .claude/rules/critical-patterns.md for the known landmines."
fi
if [ -f governance/domain-boundaries.md ]; then
  echo "DDD: governance/domain-boundaries.md defines domain placement."
fi

# Learnings — surface count + most recent 3, if any
if [ -x "bin/bstack-learn" ] && [ -s "docs/solutions/learnings.jsonl" ]; then
  COUNT=$(bin/bstack-learn count 2>/dev/null || echo 0)
  if [ "$COUNT" != "0" ]; then
    echo "Learnings on file: $COUNT  (run /bstack:learn to browse)"
    bin/bstack-learn recent 3 2>/dev/null | sed 's/^/  /'
    echo ""
  fi
fi

# Active session guards
if [ -f .claude/state/freeze-dir.txt ]; then
  echo "FREEZE active: $(cat .claude/state/freeze-dir.txt) (run /bstack:unfreeze to lift)"
fi
if [ -f .claude/state/careful-active ]; then
  echo "CAREFUL active: destructive bash commands will prompt"
fi

echo ""
echo "Model overlay: read .claude/overlays/<your-tier>.md (haiku|sonnet|opus) at command start."
echo ""
echo "bstack commands: /bstack:strategy /bstack:office-hours /bstack:brainstorm /bstack:spec"
echo "                 /bstack:plan /bstack:autoplan /bstack:implement /bstack:review /bstack:debug"
echo "                 /bstack:compound /bstack:qa /bstack:preset-e2e"
echo "                 /bstack:migrate /bstack:hotfix /bstack:ship /bstack:deploy"
echo "       devops:   /bstack:devops /bstack:setup /bstack:improve /bstack:auto"
echo "       audit:    /bstack:cso /bstack:health"
echo "       safety:   /bstack:freeze /bstack:unfreeze /bstack:careful"
echo "       memory:   /bstack:learn /bstack:compound /bstack:retro"
echo "======================"
