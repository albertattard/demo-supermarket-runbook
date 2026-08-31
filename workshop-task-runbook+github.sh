#!/bin/bash

set -euo pipefail

PARENT='/tmp'
REPOSITORY="${PARENT}/demo-supermarket"
GITHUB_HOST='github.com'
WORKSHOP_GITHUB_USER="${WORKSHOP_GITHUB_USER:-change-this-to-your-gh-username}"

# `sw run` executes the commands embedded in the workshop runbook. Use the
# facilitator test account for those commands, then restore the account that was
# active before this script started. The account must already be authenticated in gh.
ORIGINAL_GITHUB_USER="$(gh api user --hostname "${GITHUB_HOST}" --jq '.login')"

restore_github_user() {
  local exit_status=$?

  trap - EXIT

  if ! gh auth switch \
    --hostname "${GITHUB_HOST}" \
    --user "${ORIGINAL_GITHUB_USER}"; then
    echo "Warning: could not restore GitHub account ${ORIGINAL_GITHUB_USER}." >&2
  fi

  exit "${exit_status}"
}

trap restore_github_user EXIT

if [[ "${ORIGINAL_GITHUB_USER}" != "${WORKSHOP_GITHUB_USER}" ]]; then
  gh auth switch \
    --hostname "${GITHUB_HOST}" \
    --user "${WORKSHOP_GITHUB_USER}"
fi

sw format --input-file workshop-task-runbook.yaml
sw run \
  --input-file workshop-task-runbook.yaml \
  --working-directory "${PARENT}" \
  --output-file "runbooks/README.md" \
  --verbose
