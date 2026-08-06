---
id: TASK-014
title: Create review-issue-readiness skill
status: ready
depends_on: []
---
# Goal

Add a repository-local `review-issue-readiness` skill that lets contributors assess whether a GitHub issue is sufficiently defined before implementation.

The skill must make the readiness-review workflow repeatable and demonstrate how project-specific skills can be versioned alongside the application.

## Scope

- Add `skills/review-issue-readiness/SKILL.md` to the repository.
- Add `skills/review-issue-readiness/agents/openai.yaml` with a display name, short description, and default prompt suitable for invoking the skill.
- Define the skill's trigger in frontmatter so it is used when someone asks to review a GitHub issue, story, or ticket for implementation readiness.
- Instruct the skill to gather evidence from the issue and only the relevant repository context.
- Instruct the skill to assess the intended outcome, acceptance criteria, scope boundaries, non-goals, edge cases, dependencies, and relevant data, security, compatibility, migration, or operational implications.
- Require the skill to distinguish documented facts from repository-based inferences and to challenge material ambiguity instead of inventing product decisions.
- Require a staged review: list material concerns briefly, expand only the highest-impact concern, ask at most one material clarification at a time, and wait for an answer before continuing.
- Require the final assessment to use exactly one recommendation: `Ready to implement`, `Ready with explicit assumptions`, or `Blocked`.
- Do not allow `Ready with explicit assumptions` for unresolved product, security, data-loss, compatibility, or user-visible behaviour decisions.
- Add a concise example to the repository documentation showing how to invoke the skill against a GitHub issue before starting implementation.

## Out of Scope

- Changing the application's runtime behaviour.
- Adding a generic issue template or automating issue creation.
- Attaching the skill files to this GitHub issue.
- Creating additional skills.

## Acceptance Criteria

- `skills/review-issue-readiness/SKILL.md` has valid YAML frontmatter with the name `review-issue-readiness` and a description that states when to use it.
- The skill instructions implement every workflow and recommendation rule in this issue's scope.
- `skills/review-issue-readiness/agents/openai.yaml` provides discoverable UI metadata and a default prompt that invokes `$review-issue-readiness`.
- The skill can be invoked against a real issue in this repository without requiring an attachment or an external copy of its instructions.
- Repository documentation includes one invocation example using `$review-issue-readiness` and an issue URL.
- The skill is committed as ordinary repository source so later changes are reviewable and versioned with the project.
