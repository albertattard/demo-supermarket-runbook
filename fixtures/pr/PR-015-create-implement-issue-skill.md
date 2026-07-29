## Summary

Adds the issue 15 implementation skills for Demo Supermarket.

Closes #15.

- Adds `$implement-issue` for focused implementation of a ready GitHub issue.
- Adds `$orchestrate-issue-implementations` for coordinating a primary and an alternative implementation in prepared worktrees.
- Adds `$review-implementation` for an independent, candidate-scoped implementation review.
- Requires targeted repository discovery, shared-resource preflight, full verification, evidence-matrix audit, and one writing agent per worktree.
- Preserves independently reviewed candidates for a later comparison workflow, with one bounded review-driven repair cycle.

## Verification

- Validate all skill metadata files and folder structures.
- Invoke `$orchestrate-issue-implementations` against a ready repository issue and confirm that it creates isolated candidates using `$implement-issue`, then sends each eligible candidate to `$review-implementation` for a complete terminal verdict.
- Forward-test the combined workflow on a fresh ready issue rather than issue 4, and preserve the resulting candidate evidence for review.
