---
id: TASK-015
title: Create issue implementation skills
status: ready
depends_on: []
---
# Goal

Add repository-local skills that guide contributors through implementing a ready GitHub issue, either as one focused change or as several independently reviewed candidates in isolated Git worktrees.

The `implement-issue` skill must turn a ready issue into a focused, verified repository change. The `orchestrate-issue-implementations` skill must coordinate meaningful alternatives without allowing parallel agents to overwrite each other's work. The `review-implementation` skill must independently review one candidate's actual worktree and report a complete, evidence-based readiness verdict.

## Scope

- Add `.agents/skills/implement-issue/SKILL.md` to the repository.
- Add `.agents/skills/implement-issue/agents/openai.yaml` with a display name, short description, and default prompt suitable for invoking the skill.
- Add `.agents/skills/orchestrate-issue-implementations/SKILL.md` to the repository.
- Add `.agents/skills/orchestrate-issue-implementations/agents/openai.yaml` with a display name, short description, and default prompt suitable for invoking the skill.
- Add `.agents/skills/review-implementation/SKILL.md` to the repository.
- Add `.agents/skills/review-implementation/agents/openai.yaml` with a display name, short description, and default prompt suitable for invoking the skill.
- Define each skill trigger in frontmatter so it is used for its intended implementation or review workflow.
- Require the two implementation skills to read the issue, applicable repository instructions, and only the relevant code, tests, and documentation before changing files. Require the review skill to read the same relevant context before inspecting a candidate.
- Require the two implementation skills to keep changes within the issue's scope, add or update tests for changed behaviour, run relevant verification, and inspect the final diff. Require the review skill to remain read-only.
- Allow exactly one clarification question only when an ambiguity materially affects user-visible behaviour, security, data, compatibility, or scope.
- Require each skill to summarize verification, assumptions, and remaining risks or blockers in its handoff; implementation skills also summarize their changes.
- Require `orchestrate-issue-implementations` to compare a primary design with at most one viable alternative. It must not manufacture an alternative when no genuine design or educational trade-off exists.
- Prepare primary and alternative worktrees and branches from the same clean base commit. Each implementation agent must work only in its assigned worktree and must not create, remove, switch, or reset branches or worktrees.
- Require exactly one writing implementation agent per candidate worktree. Restrict any additional agents to read-only investigation or review after implementation finishes.
- Permit viable less-preferred candidates when they reveal useful trade-offs, but prohibit candidates that violate acceptance criteria, security requirements, or essential reliability constraints.
- Require each candidate to use `$implement-issue`, commit independently, and hand off its test results, assumptions, risks, and commit SHA for later comparison.
- Require `orchestrate-issue-implementations` to inventory fixed shared resources (including ports, databases, filesystem paths, and external services) before it assigns parallel work. It must isolate them or reserve a serialized verification phase before writers begin.
- Require `orchestrate-issue-implementations` to give each reviewer only its assigned candidate worktree, exact baseline commit, issue, canonical evidence matrix, explicit exclusions, and relevant verification commands. It must not use the writer's self-assessment or another candidate's review as review evidence.
- Require each independent reviewer to inspect the actual candidate diff, relevant surrounding code, tests, and verification output against the issue and canonical evidence matrix. The reviewer must return exactly one terminal verdict: `ACCEPT`, `CHANGES_REQUESTED`, or `BLOCKED`.
- Define the pending-task source for reviews as the target repository's open GitHub issues, queried with `gh issue list --state open`. A reviewer may suppress a finding only when an open issue documents the same pre-existing defect and the candidate neither introduces nor materially worsens it; otherwise it must report the finding and reference the related issue.
- Require review reports to contain all material findings in one severity-ordered response. Each finding must identify the affected code, evidence, impact, and a concrete recommendation. A reviewer must not invent requirements, report style-only concerns, or rely on a passing build as proof of correctness.
- Require at most one consolidated review-driven repair cycle per candidate. The original writer addresses the complete finding set in its own worktree, maps every finding to code or test changes and verification, and the same independent reviewer re-reviews the new diff. The orchestrator decides eligibility; a reviewer does not select a winner.
- Require the orchestrator to emit a compact evidence index mapping every matrix ID to the exact test(s), relevant file(s), and final verdict before candidate selection.
- Add concise invocation examples for all three skills against a ready GitHub issue.
- Forward-test the revised orchestration and review flow on a fresh ready issue and clean candidate worktrees after the skills are installed. Do not reuse issue 4 or expose the reviewers to the intended solution, prior review conclusions, or known defects.

## Out of Scope

- Reassessing issue readiness or replacing the `review-issue-readiness` skill.
- Selecting or merging a winning implementation candidate.
- Deleting candidate worktrees or branches.
- Running concurrent writers in one worktree.
- Changing the application's runtime behaviour.
- Adding generic issue templates or skills beyond the three named in this issue.

## Acceptance Criteria

- `.agents/skills/implement-issue/SKILL.md` has valid YAML frontmatter with the name `implement-issue` and a description that states when to use it.
- All three skill instructions implement every workflow and guardrail in this issue's scope.
- `.agents/skills/implement-issue/agents/openai.yaml` provides discoverable UI metadata and a default prompt that invokes `$implement-issue`.
- `.agents/skills/orchestrate-issue-implementations/SKILL.md` has valid YAML frontmatter with the name `orchestrate-issue-implementations` and a description that states when to use it.
- `.agents/skills/orchestrate-issue-implementations/agents/openai.yaml` provides discoverable UI metadata and a default prompt that invokes `$orchestrate-issue-implementations`.
- `.agents/skills/review-implementation/SKILL.md` has valid YAML frontmatter with the name `review-implementation` and a description that states when to use it.
- `.agents/skills/review-implementation/agents/openai.yaml` provides discoverable UI metadata and a default prompt that invokes `$review-implementation`.
- All three skills can be invoked against a real ready issue in this repository without requiring an attachment or an external copy of their instructions.
- The orchestration skill defines a conventional primary design and, only when useful, one viable alternative with a clear learning objective.
- Prepare both isolated worktrees from the same clean base commit, record that commit as the review baseline, and assign one writing agent to each worktree. Require `./mvnw clean verify` before and after implementation, with any fixed-resource verification serialized when preflight requires it.
- Each review uses the actual assigned worktree and returns a complete `ACCEPT`, `CHANGES_REQUESTED`, or `BLOCKED` report. A `CHANGES_REQUESTED` report is repaired once and then re-reviewed before the orchestrator determines eligibility.
- A forward test on a fresh ready issue demonstrates the preflight, independent review, complete reviewer report, and bounded repair/re-review path without relying on issue 4's known implementation history.
- Repository documentation includes invocation examples using `$implement-issue`, `$orchestrate-issue-implementations`, and `$review-implementation` with an issue URL.
- All three skills are committed as ordinary repository source so later changes are reviewable and versioned with the project.
