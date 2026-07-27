---
name: review-issue-readiness
description: Review a GitHub issue, story, or ticket before implementation. Use when the user wants to assess implementation readiness, identify blockers, test acceptance criteria, expose risky assumptions, tighten scope, or decide whether work may start.
---

# Review Issue Readiness

## Gather evidence

1. Read the issue title, body, labels, comments, and linked issues or pull requests.
2. Read applicable repository instructions and inspect only the code or documentation needed to verify the issue's claims, dependencies, constraints, and likely affected areas.
3. Distinguish issue facts from repository-based inferences. State when required context is unavailable rather than guessing.

## Assess readiness

Check whether the issue defines a user or business outcome, observable acceptance criteria, scope boundaries and non-goals, errors and edge cases, dependencies and ownership, and relevant compatibility, security, data, migration, or operational implications.

Challenge unclear, contradictory, or weak requirements. Do not silently fill product, user-visible behaviour, security, data, or compatibility gaps with implementation choices.

## Conduct the review

1. If there are material concerns, begin with a numbered summary only: one short sentence per concern, ordered by implementation impact.
2. Expand only the first concern. If it needs clarification, ask exactly one concise question that materially affects implementation, then stop and wait for the user's answer.
3. Do not move to another concern until the user answers or explicitly asks to continue. Reassess the remaining concerns after each answer.
4. If no clarification is required, give the complete assessment.

## Recommend a status

End the completed review with exactly one of these recommendations:

- **Ready to implement** — requirements and acceptance criteria are sufficiently clear and testable.
- **Ready with explicit assumptions** — remaining gaps are low-risk; list every assumption and its implementation impact.
- **Blocked** — an unresolved decision materially affects scope, behaviour, architecture, or testability.

Do not use “Ready with explicit assumptions” for unresolved product, security, data-loss, compatibility, or user-visible behaviour decisions.
