## Summary

Adds the issue 14 implementation skills for Demo Supermarket.

Closes #14.

- Adds `$implement-issue` for focused implementation of a ready GitHub issue.
- Adds `$orchestrate-issue-implementations` for coordinating a primary and an alternative implementation in prepared worktrees.
- Requires targeted repository discovery, full verification, final-diff review, and one writing agent per worktree.
- Preserves independently verified candidates for a later comparison workflow.

## Verification

- Validate both skill metadata files and folder structures.
- Invoke `$orchestrate-issue-implementations` against a ready repository issue and confirm that it creates isolated, independently verified candidates using `$implement-issue`.
