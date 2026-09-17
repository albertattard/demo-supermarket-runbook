#!/usr/bin/env bash

set -euo pipefail

# Check if a modernisation PR already exists and exit if so. We don't want to
# create too many PRs when no-one is looking into them.
repository="$(git remote get-url origin | sed -E 's#^.*[:/]([^/]+/[^/]+)\.git$#\1#')"
existing_prs="$(gh pr list \
  --repo "$repository" \
  --state open \
  --json url,headRefName \
  --jq '.[] | select(.headRefName | startswith("codex/modernise-")) | .url')"

if [[ -n "$existing_prs" ]]; then
  echo "An open modernisation PR already exists:"
  echo "$existing_prs"
  exit 0
fi

assessment_outcome_file='target/codex-modernisation-v2-assessment-outcome'
proposal_file='target/codex-modernisation-v2-proposal.md'
no_improvement_report_file='target/codex-modernisation-v2-no-improvement.md'
outcome_file='target/codex-modernisation-v2-outcome'
pr_body_file='target/codex-modernisation-v2-pr.md'

rm -f "$assessment_outcome_file" "$proposal_file" "$no_improvement_report_file" \
  "$outcome_file" "$pr_body_file"

# Agent 1 is deliberately limited to assessment. Its only hand-off is one of
# the outcome files below; it must not alter the repository or Git state.
codex exec \
  --ephemeral \
  --sandbox read-only \
  --output-last-message '/tmp/codex-modernisation-v2-assessment.md' \
  - <<'EOF' > '/tmp/codex-modernisation-v2-assessment.log' 2>&1
You are the assessment agent in a two-agent Java-modernisation workflow.

Your role ends at a written recommendation. Do not edit, create, delete, stage, commit, or revert repository files, except for the explicit hand-off files under `target/` described below. Do not create or switch branches, push, or create a pull request. Do not run commands that change Git state.

Inspect this Java 25 codebase and identify at most one worthwhile, focused modernisation opportunity.

Assess candidates such as:

- unnecessarily Java-8-era or older expression of otherwise straightforward logic;
- mutable JavaBean-style value objects that could be better expressed with modern Java constructs;
- boilerplate `equals`, `hashCode`, or `toString`;
- manual collection transformation/filtering/aggregation that can be expressed more clearly with current Java APIs;
- avoidable nullable control flow;
- verbose conditional or type-dispatch logic that a modern Java construct can simplify;
- other clearly obsolete patterns where a Java 25 idiom improves clarity, safety, or maintainability.

Do not recommend a change merely because it is newer. Prefer an idiom that makes the code materially clearer, less error-prone, or easier to maintain. Avoid stylistic churn, speculative redesign, performance-motivated changes without evidence, and refactors whose primary benefit is novelty.

For each plausible candidate, consider:

1. Is the existing code meaningfully harder to understand, maintain, or modify than a Java 25 equivalent?
2. Is the modernisation local and cohesive enough to review safely?
3. Can observable behaviour remain unchanged?
4. Could the change affect public APIs, serialization, persistence, reflection, framework integration, null semantics, equality semantics, ordering, concurrency, or tests?
5. Is there a credible regression risk that outweighs the maintenance benefit?

Select the single strongest candidate only. Do not propose broad refactoring, cleanup, dependency upgrades, redesign, or multiple unrelated changes.

Preserve observable behaviour, public routes/APIs, persistence behaviour, serialization contracts, and test intent. Treat framework conventions and reflection-based behaviour as compatibility constraints unless the repository provides clear evidence that they are unaffected.

Use repository evidence, not assumptions. Inspect relevant source, tests, configuration, and usages needed to establish the candidate and its risks. Do not invent missing context.

If no candidate materially improves the code, write a concise explanation to:

`target/codex-modernisation-v2-no-improvement.md`

Then write exactly:

`no-improvement`

to:

`target/codex-modernisation-v2-assessment-outcome`

and stop successfully.

Otherwise, write the implementation hand-off to:

`target/codex-modernisation-v2-proposal.md`

The hand-off must contain:

- **Candidate**: the selected files and relevant types, methods, or code regions.
- **Current pattern**: the specific legacy-style code and why it is unnecessarily verbose, mutable, fragile, or dated.
- **Modernisation**: the specific Java 25 language or standard-library idiom to adopt and why it is a better fit.
- **Evidence and rationale**: the concrete repository evidence showing this is a worthwhile change rather than stylistic novelty.
- **Bounded change plan**: exactly what should change and what should remain untouched.
- **Behaviour and compatibility risks**: including API, equality/hash semantics, null handling, ordering, serialization/persistence, reflection/framework integration, and test implications where relevant; explain why the remaining risks are acceptable.
- **Validation**: tests to add or adjust, existing tests to run, and the commands to run them.
- **Suggested Git metadata**: a concise branch suffix and commit subject.
- **Confidence**: high, medium, or low, with a brief justification.

The proposal must be implementable by a second agent without needing to rediscover the assessment.

After successfully writing the proposal, write exactly:

`approved`

to:

`target/codex-modernisation-v2-assessment-outcome`

and stop successfully.

Do not modify any source, test, configuration, build, or Git files.
EOF

assessment_outcome="$(tr -d '\r\n' < "$assessment_outcome_file" 2>/dev/null || true)"
case "$assessment_outcome" in
  no-improvement)
    if [ ! -s "$no_improvement_report_file" ]; then
      echo 'The assessment agent reported no improvement without an explanation.' >&2
      exit 1
    fi
    echo 'No worthwhile Java modernisation opportunity was found; no pull request was created.'
    exit 0
    ;;
  approved)
    if [ ! -s "$proposal_file" ]; then
      echo 'The assessment agent approved a change without a proposal.' >&2
      exit 1
    fi
    ;;
  *)
    echo "Expected $assessment_outcome_file to contain 'approved' or 'no-improvement', but found: ${assessment_outcome:-<missing>}" >&2
    exit 1
    ;;
esac

# Agent 2 owns all repository mutations. It receives Agent 1's proposal as a
# recommendation, not an instruction to proceed regardless of current facts.
codex exec \
  --ephemeral \
  --sandbox workspace-write \
  --output-last-message '/tmp/codex-modernisation-v2-implementation.md' \
  - <<'EOF' > '/tmp/codex-modernisation-v2-implementation.log' 2>&1
You are the implementation agent in a two-agent Java-modernisation workflow.

Read `target/codex-modernisation-v2-proposal.md`, which contains the assessment agent's recommendation. You own the implementation decision and all repository mutations. Do not assume the proposal is correct without validating it against the current code.

## Validate the proposal

Inspect the proposal and the relevant current source, tests, configuration, build files, and usages.

Proceed only if the proposal is still:

- one focused, cohesive Java 25 modernisation;
- materially beneficial for clarity, maintainability, safety, or reduction of unnecessary boilerplate;
- narrowly bounded and easy to review;
- compatible with the repository's architecture and framework conventions;
- reasonably demonstrable as behaviour-preserving.

Do not implement a proposal merely because a newer Java construct exists. Reject changes whose primary benefit is novelty, stylistic preference, speculative performance improvement, broad cleanup, or redesign.

Pay particular attention to:

- public APIs and routes;
- persistence and database mappings;
- serialization and deserialization;
- reflection and framework conventions;
- equality, hashing, ordering, and null semantics;
- concurrency or mutability semantics;
- generated code and annotation processing;
- existing test intent.

If the proposal is no longer sound, do not create or switch branches and do not modify source files, tests, configuration, or Git history. Write a concise reason to:

`target/codex-modernisation-v2-no-improvement.md`

Then write exactly:

`no-improvement`

to:

`target/codex-modernisation-v2-outcome`

and stop successfully.

## Implement the modernisation

If the proposal is sound:

1. Create a branch named: `codex/modernise-<short-description>`

2. Implement only the approved cohesive opportunity.
   - Keep Java 25 as the runtime and toolchain baseline.
   - Do not lower source, target, compiler, or runtime versions.
   - Do not introduce unrelated cleanup, formatting churn, dependency upgrades, redesign, or opportunistic refactoring.
   - Do not expand the change beyond the proposal merely because adjacent improvements are discovered.

3. Add or adjust tests where needed to demonstrate that behaviour and important semantics are preserved.

4. Run the relevant focused tests, then run:
   `./mvnw test`
   `./mvnw verify`

5. If failures occur:
   - Fix failures caused by this implementation when the fix remains within scope.
   - Do not alter unrelated code simply to make pre-existing failures pass.
   - Record any pre-existing or environment-related failures accurately in the final hand-off.

6. Review the final diff and Git status before committing.
   Confirm that:
   - only files required for this modernisation changed;
   - the implementation matches the approved proposal;
   - no unrelated cleanup slipped in;
   - no source, test, configuration, or build file was changed unnecessarily.

7. Stage only the implementation files belonging to this modernisation.

8. Commit them with a concise, specific commit subject.

9. Verify after the commit that the committed diff contains only the intended modernisation.

Do not commit the assessment proposal, outcome files, or no-improvement file unless the repository workflow explicitly requires it.

## Completion hand-off

Write:

`target/codex-modernisation-v2-pr.md`

It must state:

- the legacy-style code identified;
- the specific Java 25 idiom adopted;
- the files and relevant types or methods changed;
- why the change materially improves maintainability;
- the scope of the implementation;
- important compatibility or behavioural considerations;
- the test and verification commands run;
- the result of those commands;
- any pre-existing or environment-related failures;
- the final commit hash;
- the final commit subject;
- the branch name.

Only after the implementation, validation, review, and commit are complete, write exactly:

`modernised`

to:

`target/codex-modernisation-v2-outcome`

and stop successfully.

Do not run `git push` or `gh pr create`; the calling script performs publication after this hand-off is complete.
EOF

outcome="$(tr -d '\r\n' < "$outcome_file" 2>/dev/null || true)"
case "$outcome" in
  no-improvement)
    if [ ! -s "$no_improvement_report_file" ]; then
      echo 'The implementation agent reported no improvement without an explanation.' >&2
      exit 1
    fi
    echo 'The proposed modernisation was not implemented; no pull request was created.'
    exit 0
    ;;
  modernised) ;;
  *)
    echo "Expected $outcome_file to contain 'modernised' or 'no-improvement', but found: ${outcome:-<missing>}" >&2
    exit 1
    ;;
esac

branch="$(git branch --show-current)"
case "$branch" in
  codex/modernise-*) ;;
  *)
    echo "Expected a codex/modernise-* branch, but found: $branch" >&2
    exit 1
    ;;
esac

if [ ! -s "$pr_body_file" ]; then
  echo 'The implementation agent did not create a pull-request description.' >&2
  exit 1
fi

git push --set-upstream origin "$branch"

repository="$(git remote get-url origin | sed -E 's#^.*[:/]([^/]+/[^/]+)\.git$#\1#')"
title="$(git log -1 --format=%s)"

gh pr create \
  --repo "$repository" \
  --base main \
  --head "$branch" \
  --title "$title" \
  --body-file "$pr_body_file"
