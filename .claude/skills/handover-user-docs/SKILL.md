---
name: handover-user-docs
description: >
  Produce end-user and administrator documentation for a client handover — getting-started guide,
  feature walkthroughs, admin/configuration guide, role & permissions reference, common workflows,
  FAQ, and troubleshooting. Trigger on "user guide", "user documentation", "admin guide", or
  "end-user docs".
---

# /handover-user-docs — User & Admin Guide

Produces deliverable **06**: documentation for the humans who will *use* and *administer* the product — not the engineers. Two audiences: end users (how to get work done) and administrators (how to configure and manage).

> **Shared contract** — output location & numbering, secrets → doc 05, actual-state-not-plan, cross-referencing, and completeness rules live in [`handover/references/handover-conventions.md`](../handover/references/handover-conventions.md). Follow it; don't restate it.

## When to use

- The client's staff or customers will operate the product without training from us.
- The product has admin/configuration surfaces the client must manage themselves.

## Inputs to gather

- The actual UI/screens and primary user journeys (run the app; capture screenshots).
- User roles and what each can do; admin/settings areas.
- Common tasks and their step-by-step flows.
- Known rough edges users will hit (cross-reference doc 07).

## Process

1. Write a **getting-started** section: access, login, first-run, orientation.
2. Document **core features / workflows** as task-based how-tos with screenshots.
3. Write the **admin guide**: configuration, user management, roles/permissions, settings.
4. Build a **roles & permissions** reference matrix.
5. Add a **FAQ** and a **troubleshooting** section keyed to real, likely problems.
6. Keep language non-technical; define any unavoidable jargon.

## Output template — `handover/06-user-admin-guide.md`

```markdown
# User & Admin Guide — <Product Name>

## Part A — End-User Guide

### 1. Getting started
- Access: <url>  ·  Supported browsers/devices: <...>
- Signing in: <steps>
- The interface at a glance: <annotated screenshot>

### 2. Core workflows
#### How to <do the primary task>
1. <step + screenshot>
2. <step>
3. Result: <what success looks like>

<Repeat for each major workflow.>

### 3. FAQ
**Q: <common question>?** A: <answer>

### 4. Troubleshooting (users)
| Symptom | Likely cause | What to do |
|---------|--------------|------------|
| | | |

## Part B — Administrator Guide

### 5. Admin overview
<Where admin lives, who should have access.>

### 6. User & access management
- Adding / removing users: <steps>
- Resetting access: <steps>

### 7. Roles & permissions

| Capability | Admin | Manager | Member | Viewer |
|------------|:-----:|:-------:|:------:|:------:|
| | Yes | Yes | No | No |

### 8. Configuration & settings
| Setting | What it controls | Default | Notes |
|---------|------------------|---------|-------|
| | | | |

### 9. Admin troubleshooting
| Symptom | Cause | Resolution | Escalate to (doc 08) |
|---------|-------|------------|----------------------|
| | | | |
```

## Quality checklist

- Written for non-engineers; jargon is defined or removed.
- Workflows are task-based ("How to...") and include screenshots from the real app.
- The roles matrix matches the system's actual permission model.
- Troubleshooting points to the support/escalation path in doc 08.
- Admin steps that touch credentials defer to doc 05 rather than embedding secrets.
