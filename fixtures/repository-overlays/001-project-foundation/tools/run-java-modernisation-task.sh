#!/usr/bin/env bash

set -euo pipefail

codex exec \
  --ephemeral \
  --sandbox workspace-write \
  --output-last-message '/tmp/codex-modernisation-task.md' \
  - <<'EOF' > '/tmp/codex-modernisation-task.log' 2>&1
Find exactly one worthwhile Java modernisation opportunity in this codebase and implement it in a focused commit.

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
  2. Briefly explain the candidate and the intended modernisation before editing.
  3. Create a branch named `codex/modernise-<short-description>`.
  4. Implement the focused change and commit it with a clear message.
  5. Run `./mvnw test` and `./mvnw verify`; fix any failures caused by your change.
  6. Review the final diff for scope and correctness.
  7. Write the proposed pull-request description to
     `target/codex-modernisation-pr.md`. It must state:
     - the legacy-style code found;
     - the Java 25 idiom adopted;
     - why the change improves maintainability;
     - the test commands run and their results.

Do not run `git push` or `gh pr create`. Stop after the local commit and writing the pull-request description.
EOF

branch="$(git branch --show-current)"
case "$branch" in
  codex/modernise-*) ;;
  *)
    echo "Expected a codex/modernise-* branch, but found: $branch" >&2
    exit 1
    ;;
esac

if [ ! -s 'target/codex-modernisation-pr.md' ]; then
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
  --body-file 'target/codex-modernisation-pr.md'
