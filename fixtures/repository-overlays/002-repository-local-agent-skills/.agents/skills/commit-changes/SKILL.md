---
name: commit-changes
description: Use this skill when I ask you to commit changes, create a Git commit, or otherwise commit the current changes.
---

# Commit behavior

Treat a request to commit as permission to inspect and prepare the proposed commit. Do not treat it as permission to overlook material issues or silently split unrelated work.

## Before committing

Inspect the repository state and complete relevant diff. Check for accidental or suspicious changes, debug output, generated files, unrelated formatting churn, and prose issues in comments, documentation, user-facing text, and changed strings. Also check whether the diff is internally incomplete or unrelated to the requested work.

If a material concern is found, stop and state the issue, where it appears, and why it matters. Wait for explicit direction before committing. Do not block a commit for purely subjective or trivial stylistic preferences.

## Decide the commit shape

Create a single commit without another approval only when the changes are clean and form one coherent logical unit: they share a clear purpose and can reasonably be reviewed, reverted, and described together.

If changes contain independently meaningful work, such as an unrelated fix, refactor, documentation change, or formatting chore, do not commit yet. Propose a focused commit sequence in execution order, including the subject and affected files or change groups for each. Wait for the user's explicit approval before creating any split commits. Split by logical intent, not file count; split hunks only when the diff clearly supports it.

## Commit messages and identity

Use a concise imperative subject (for example, `Add`, `Fix`, `Update`, `Refactor`, `Remove`, `Document`, or `Improve`). Add a body only when the rationale, user impact, or a significant trade-off would help a future reader.

Use the repository's configured Git author identity and any established signing convention. Do not invent either. If Git lacks an author identity or signing is required but cannot be completed, stop and ask the user for the necessary direction.

## Create and verify the commit

After selecting a coherent commit shape and message, stage only the intended files or hunks. Do not use a broad staging command that includes unrelated, pre-existing, generated, or suspicious changes.

Create the commit with the selected subject and optional body. Then inspect the commit and Git status to confirm that the new commit contains only the intended change set and that any remaining worktree changes are intentionally uncommitted. If the commit fails or this final check reveals a material concern, stop and report it; do not claim that the commit succeeded.

## Report

After committing, report the commit hash and subject concisely. If stopped, make the finding or proposed split easy to approve or revise.
