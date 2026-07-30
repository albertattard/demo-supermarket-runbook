#!/bin/bash

set -euo pipefail

TARGET='/tmp/demo-supermarket-starter'
REPOSITORY="${TARGET}/repository"
BRANCH='add-workshop-runbook'
PR_URL_FILE="${TARGET}/workshop-task-runbook-pr-url"

if [ ! -d "${REPOSITORY}/.git" ]; then
  echo "Starter repository not found at ${REPOSITORY}. Run ./starter-project-runbook.sh first." >&2
  exit 1
fi

sw validate --input-file workshop-task-runbook.yaml

git -C "${REPOSITORY}" switch main
git -C "${REPOSITORY}" pull --ff-only
git -C "${REPOSITORY}" switch --create "${BRANCH}"

sw run \
  --input-file workshop-task-runbook.yaml \
  --working-directory "${REPOSITORY}" \
  --output-file "${REPOSITORY}/RUNBOOK.md" \
  --verbose

git -C "${REPOSITORY}" add RUNBOOK.md
git -C "${REPOSITORY}" commit --message 'Add workshop runbook'
git -C "${REPOSITORY}" push --set-upstream origin "${BRANCH}"

(
  cd "${REPOSITORY}"
  gh pr create \
    --title 'Add workshop runbook' \
    --body 'Adds the generated attendee workshop guide to the starter repository.' \
    > "${PR_URL_FILE}"
)

"${TARGET}/tools/merge-pull-request.sh" "${PR_URL_FILE}"
git -C "${REPOSITORY}" switch main
git -C "${REPOSITORY}" pull --ff-only
