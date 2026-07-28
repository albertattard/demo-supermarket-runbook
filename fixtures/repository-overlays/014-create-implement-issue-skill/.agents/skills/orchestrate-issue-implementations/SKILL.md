---
name: orchestrate-issue-implementations
description: Coordinate a primary and an alternative implementation of a ready GitHub issue in pre-provisioned Git worktrees. Use when the user wants two comparable approaches, isolated implementation agents, or a comparison of a conventional design with a viable alternative.
---

# Orchestrate Issue Implementations

## Plan the pair

1. Read the issue, applicable repository instructions, and enough relevant code and tests to identify genuine design choices.
2. Treat the primary design as the simplest defensible implementation that follows existing repository conventions.
3. Treat the alternative design as a materially different but viable implementation that exposes a useful trade-off. It may be less preferred, but it must satisfy all acceptance criteria and must not weaken security or essential reliability.
4. If no useful alternative exists, state that clearly and leave the alternative worktree unchanged. Do not manufacture a duplicate or a contrived design.
5. Label both designs with their expected strengths, weaknesses, and learning objective.

## Locate prepared worktrees

1. Extract the issue number from the issue URL.
2. Derive the repository name from the `origin` remote URL. Fall back to the current repository directory name only when no `origin` remote is configured.
3. Expect sibling worktrees named `../<repository>-issue-<number>-primary` and `../<repository>-issue-<number>-alternative`.
4. Confirm both worktrees exist, are clean, are on branches `issue-<number>-primary` and `issue-<number>-alternative`, and point to the same commit as the current repository.
5. If either worktree is missing or mismatched, stop and report the exact problem. Do not create, remove, switch, reset, merge, or repair worktrees or branches.
6. Before changing files, run `./mvnw clean verify` in each assigned worktree. Record any pre-existing failures as baseline failures and do not mask them with unrelated changes.

For any required verification that fails only because the current sandbox lacks necessary access, request one scoped approval to rerun the exact command with the necessary access when the session supports approvals. Do not request broader access, a broader sandbox mode, or unrelated filesystem or network access. If approval is unavailable or declined, record the failure as an environmental blocker and continue only where that blocker does not invalidate the result.

## Coordinate implementation

1. Assign exactly one writing implementation agent to each worktree. Never allow concurrent writers in the same worktree.
2. Give the primary agent the issue URL and instruct it to use `$implement-issue` for the simplest design consistent with existing conventions.
3. Give the alternative agent the issue URL and instruct it to use `$implement-issue` for a meaningfully different viable design, or to explain why no useful alternative exists without changing files.
4. Require each agent’s handoff to map every issue acceptance scenario to the test that demonstrates it. For user-facing flows, the evidence must cover the final observable result, including redirects and access control where applicable.
5. Allow additional agents only for read-only investigation or review after the writing agent has finished. If subagents are unavailable, coordinate the two worktrees sequentially; do not launch nested Codex processes.

## Verify and hand off

1. Require each changed worktree to add or update tests, run `./mvnw clean verify` after implementation, inspect its final diff, and provide acceptance-scenario-to-test evidence. Do not accept a passing build or an intermediate-response test as evidence that a user journey is complete.
2. Leave each changed worktree ready to commit after the implementation agent finishes.
3. Collect a concise handoff from each worktree: implementation summary, tests and outcomes, assumptions, risks, and whether it produced a commit.
4. Do not merge, delete, or clean up branches or worktrees. Hand them to an independent comparison or review workflow that recommends one design.
