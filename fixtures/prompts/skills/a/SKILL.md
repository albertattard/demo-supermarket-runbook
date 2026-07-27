---
name: review-issue-readiness
description: Review a GitHub issue or story before implementation. Identify blockers, missing acceptance criteria, risky assumptions, and unclear scope; ask one material clarification at a time and recommend whether work is ready to begin.
---

# Review issue readiness

Use this skill when the user asks whether a GitHub issue, story, or ticket is sufficiently defined to implement.

## Gather context

1. Read the issue title, description, labels, comments, linked issues/PRs, and relevant repository guidance.
2. Inspect only the code or documentation needed to validate claims, dependencies, constraints, and affected areas.
3. Distinguish facts in the issue from inferences based on the repository.

## Assess readiness

Evaluate whether the issue defines:

- the intended user or business outcome;
- clear, observable acceptance criteria;
- scope boundaries and non-goals;
- affected behaviour, including errors and edge cases;
- dependencies, ownership, and decisions required before implementation;
- any compatibility, security, data, migration, or operational implications.

Challenge ambiguity. Do not silently invent product decisions or treat implementation ideas as requirements.

## Conversation flow

If there are material concerns, begin with a numbered summary of all concerns, using one short sentence per item.

Then expand only the highest-impact concern. If resolving it requires user input, ask one concise question and stop. Do not advance to another concern until the user responds.

If no clarification is required, provide the complete assessment.

## Recommendation

End with exactly one recommendation:

- **Ready to implement** — requirements and acceptance criteria are sufficiently testable.
- **Ready with explicit assumptions** — remaining gaps are low-risk; list each assumption and its implementation impact.
- **Blocked** — one or more unresolved decisions materially affect scope, behaviour, architecture, or testability.

Do not recommend “ready with explicit assumptions” for unresolved product, security, data-loss, compatibility, or user-visible behaviour decisions.
