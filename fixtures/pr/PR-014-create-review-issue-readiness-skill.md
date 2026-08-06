## Summary

Adds the issue 14 `review-issue-readiness` skill for Demo Supermarket.

Implements [TASK-014](docs/tasks/TASK-014-create-review-issue-readiness-skill.md).

- Adds a repository-local skill for assessing whether GitHub issues are ready to implement.
- Defines an evidence-based review workflow that identifies ambiguity, dependencies, scope gaps, and relevant operational risks.
- Requires one material clarification at a time and a clear final readiness recommendation.
- Adds skill UI metadata and documentation showing how to invoke the skill before implementation starts.

## Verification

- Validate the skill metadata and folder structure.
- Invoke `$review-issue-readiness` against a repository issue and confirm that it follows the staged review flow.
