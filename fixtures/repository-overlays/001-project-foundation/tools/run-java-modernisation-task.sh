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


outcome_file='target/codex-modernisation-outcome'
pr_body_file='target/codex-modernisation-pr.md'
no_improvement_report_file='target/codex-modernisation-no-improvement.md'
rm -f "${outcome_file}" "${pr_body_file}" "${no_improvement_report_file}"

codex exec \
  --ephemeral \
  --sandbox workspace-write \
  --output-last-message '/tmp/codex-modernisation-task.md' \
  - <<'EOF' > '/tmp/codex-modernisation-task.log' 2>&1
Look for one worthwhile Java modernisation opportunity in this codebase and, only if one exists, implement it in a focused commit.

Constraints:
  - Keep the project on Java 25. Do not lower the Java version or alter the runtime/toolchain baseline.
  - Look for code that is unnecessarily Java-8-style or older in expression: for example mutable JavaBean-style value objects, boilerplate equals/hashCode/toString, manual collection processing, nullable control flow, or verbose conditional logic.
  - Choose one cohesive opportunity only. Do not perform a broad refactor or mix unrelated cleanup into the change.
  - Preserve observable behaviour, public routes, persistence behaviour, and existing test intent.
  - Prefer a clear Java 25-era idiom when it materially improves the code. Do not modernise merely for novelty.
  - Add or adjust tests where needed to prove the behaviour remains correct.
  - Do not overwrite, revert, stage, or commit unrelated existing changes.

Process:
  1. Inspect the codebase and identify the best single candidate.
  2. If no candidate materially improves the code, do not create or switch branches, modify source files, commit, push, or create a pull request. Write a concise explanation of the assessment to `target/codex-modernisation-no-improvement.md`, write exactly `no-improvement` to `target/codex-modernisation-outcome`, and stop successfully.
  3. Otherwise, briefly explain the candidate and the intended modernisation before editing.
  4. Create a branch named `codex/modernise-<short-description>`.
  5. Implement the focused change and commit it with a clear message.
  6. Run `./mvnw test` and `./mvnw verify`; fix any failures caused by your change.
  7. Review the final diff for scope and correctness.
  8. Write the proposed pull-request description to `target/codex-modernisation-pr.md`. It must state:
     - the legacy-style code found;
     - the Java 25 idiom adopted;
     - why the change improves maintainability;
     - the test commands run and their results.
     Then write exactly `modernised` to `target/codex-modernisation-outcome`.

Do not run `git push` or `gh pr create`. Stop after the local commit and writing the pull-request description.
EOF

outcome="$(tr -d '\r\n' < "$outcome_file" 2>/dev/null || true)"
case "$outcome" in
  no-improvement)
    echo 'No worthwhile Java modernisation opportunity was found; no pull request was created.'
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
  echo 'The agent did not create a pull-request description.' >&2
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
