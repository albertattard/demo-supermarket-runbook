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
6. Before assigning writers, derive one shared requirements-to-evidence matrix from every acceptance criterion and every specific observable, data, migration, security, or integrity requirement in scope. A requirement is not covered merely because a similar lower-level test exists. Give the same matrix to both writers.

## Locate prepared worktrees

1. Extract the issue number from the issue URL.
2. Derive the repository name from the `origin` remote URL. Fall back to the current repository directory name only when no `origin` remote is configured.
3. Expect sibling worktrees named `../repository-worktree-issue-<number>-primary` and `../repository-worktree-issue-<number>-alternative`.
4. Confirm both worktrees exist, are clean, are on branches `issue-<number>-primary` and `issue-<number>-alternative`, and point to the same commit as the current repository.
5. If either worktree is missing or mismatched, stop and report the exact problem. Do not create, remove, switch, reset, merge, or repair worktrees or branches.
6. Before changing files, run `./mvnw clean verify` in each assigned worktree. Record any pre-existing failures as baseline failures and do not mask them with unrelated changes.

For any required verification that fails only because the current sandbox lacks necessary access, request one scoped approval to rerun the exact command with the necessary access when the session supports approvals. Do not request broader access, a broader sandbox mode, or unrelated filesystem or network access. If approval is unavailable or declined, record the failure as an environmental blocker and continue only where that blocker does not invalidate the result.

## Coordinate implementation

1. Assign exactly one writing implementation agent to each worktree. Never allow concurrent writers in the same worktree.
2. Give the primary agent the issue URL and instruct it to use `$implement-issue` for the simplest design consistent with existing conventions.
3. Give the alternative agent the issue URL and instruct it to use `$implement-issue` for a meaningfully different viable design, or to explain why no useful alternative exists without changing files.
4. Treat a writing agent’s handoff as a checkpoint, not completion. Require it to complete the shared matrix with exact test class and method, starting state and action, and the final result asserted. For user-facing flows, evidence must follow redirects and inspect the final rendered content. For migrations, evidence must exercise the actual database constraint. For snapshots, evidence must assert every required snapshot field.
5. Audit the completed matrix against the issue and the test code before commissioning independent review. A passing build, an implementation summary, or a claim that a scenario is covered is not evidence by itself.
6. If the handoff omits a matrix row, required verification, or a material route, security, data-integrity, migration, or user-visible behaviour check, send the same writer a focused repair task in its existing worktree. Require it to implement the repair, add the missing evidence, rerun relevant verification, and return an updated matrix.
7. Each candidate has two total repair cycles after its initial checkpoint. A material finding from either the evidence audit or independent review consumes one cycle. After a repair, repeat the evidence audit; if it passes, repeat independent review. If material gaps remain after the second repair cycle, a final review finds a new material gap, or the writer identifies a genuine blocker, mark the candidate ineligible and report the unresolved gaps. Do not waive a finding or start a third repair cycle.
8. Allow additional agents only for read-only investigation or review after the writing agent has finished a checkpoint. If subagents are unavailable, coordinate the two worktrees sequentially; do not launch nested Codex processes.

## Verify and hand off

1. Require each changed worktree to add or update tests, run `./mvnw clean verify` after implementation, inspect its final diff, and provide the completed shared matrix. Do not accept a passing build or an intermediate-response test as evidence that a user journey is complete.
2. Commission an independent, read-only review for every candidate whose initial evidence audit has no material finding; this is an audit candidate, not yet a candidate eligible for selection. Give the reviewer the issue, the final diff, and the completed matrix.
3. Audit the reviewer’s findings against the issue. Send material findings through the bounded repair process in Coordinate implementation; do not reinterpret them as follow-ups to make a candidate selectable.
4. A candidate is eligible for selection only when its evidence audit and final independent review have no unresolved material findings. If neither candidate is eligible, report that outcome and the specific blockers; do not select the least-bad implementation.
5. Leave eligible changed worktrees ready to commit after the final verification.
6. Collect a concise final handoff from each candidate: implementation summary, tests and outcomes, completed requirements-to-evidence matrix, assumptions, risks, unresolved blockers, and whether it produced a commit.
7. Do not merge, delete, or clean up branches or worktrees. Hand eligible candidates to the selection workflow.
