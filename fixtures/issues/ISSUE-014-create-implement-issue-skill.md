# Goal

Add repository-local skills that guide contributors through implementing a ready GitHub issue, either as one focused change or as several independently evaluated candidates in isolated Git worktrees.

The `implement-issue` skill must turn a ready issue into a focused, verified repository change. The `orchestrate-issue-implementations` skill must coordinate meaningful alternatives without allowing parallel agents to overwrite each other's work.

## Scope

- Add `.agents/skills/implement-issue/SKILL.md` to the repository.
- Add `.agents/skills/implement-issue/agents/openai.yaml` with a display name, short description, and default prompt suitable for invoking the skill.
- Add `.agents/skills/orchestrate-issue-implementations/SKILL.md` to the repository.
- Add `.agents/skills/orchestrate-issue-implementations/agents/openai.yaml` with a display name, short description, and default prompt suitable for invoking the skill.
- Define each skill trigger in frontmatter so it is used for its intended implementation workflow.
- Require both skills to read the issue, applicable repository instructions, and only the relevant code, tests, and documentation before changing files.
- Require both skills to keep changes within the issue's scope, add or update tests for changed behaviour, run relevant verification, and inspect the final diff.
- Allow exactly one clarification question only when an ambiguity materially affects user-visible behaviour, security, data, compatibility, or scope.
- Require each skill to summarize changes, verification, assumptions, and remaining risks or blockers in its handoff.
- Require `orchestrate-issue-implementations` to compare a primary design with at most one viable alternative. It must not manufacture an alternative when no genuine design or educational trade-off exists.
- Prepare primary and alternative worktrees and branches from the same clean base commit. Each implementation agent must work only in its assigned worktree and must not create, remove, switch, or reset branches or worktrees.
- Require exactly one writing implementation agent per candidate worktree. Restrict any additional agents to read-only investigation or review after implementation finishes.
- Permit viable less-preferred candidates when they reveal useful trade-offs, but prohibit candidates that violate acceptance criteria, security requirements, or essential reliability constraints.
- Require each candidate to use `$implement-issue`, commit independently, and hand off its test results, assumptions, risks, and commit SHA for later comparison.
- Add concise invocation examples for both skills against a ready GitHub issue.

## Out of Scope

- Reassessing issue readiness or replacing the `review-issue-readiness` skill.
- Selecting or merging a winning implementation candidate.
- Deleting candidate worktrees or branches.
- Running concurrent writers in one worktree.
- Changing the application's runtime behaviour.
- Adding generic issue templates or additional skills.

## Acceptance Criteria

- `.agents/skills/implement-issue/SKILL.md` has valid YAML frontmatter with the name `implement-issue` and a description that states when to use it.
- Both skill instructions implement every workflow and guardrail in this issue's scope.
- `.agents/skills/implement-issue/agents/openai.yaml` provides discoverable UI metadata and a default prompt that invokes `$implement-issue`.
- `.agents/skills/orchestrate-issue-implementations/SKILL.md` has valid YAML frontmatter with the name `orchestrate-issue-implementations` and a description that states when to use it.
- `.agents/skills/orchestrate-issue-implementations/agents/openai.yaml` provides discoverable UI metadata and a default prompt that invokes `$orchestrate-issue-implementations`.
- Both skills can be invoked against a real ready issue in this repository without requiring an attachment or an external copy of their instructions.
- The orchestration skill defines a conventional primary design and, only when useful, one viable alternative with a clear learning objective.
- Prepare both isolated worktrees from the same clean base commit. Assign one writing agent to each worktree, and require `./mvnw clean verify` before and after implementation.
- Repository documentation includes invocation examples using `$implement-issue` and `$orchestrate-issue-implementations` with an issue URL.
- Both skills are committed as ordinary repository source so later changes are reviewable and versioned with the project.
