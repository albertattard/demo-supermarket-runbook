#!/usr/bin/env bash

set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <pull-request-url-file>" >&2
  exit 2
fi

pr_url_file="$1"
if [[ ! -r "${pr_url_file}" ]]; then
  echo "Pull request URL file is not readable: ${pr_url_file}" >&2
  exit 2
fi

pr_url="$(<"${pr_url_file}")"
if [[ -z "${pr_url}" ]]; then
  echo "Pull request URL file is empty: ${pr_url_file}" >&2
  exit 2
fi

pr_number="$(gh pr view "${pr_url}" --json number --jq '.number')"

while true; do
  if checks_output="$(gh pr checks "${pr_number}" --watch --required --fail-fast 2>&1)"; then
    printf '%s\n' "${checks_output}"
    break
  fi

  case "${checks_output}" in
    *"no checks reported"*|*"no required checks reported"*)
      echo "Waiting for checks to be reported for pull request #${pr_number}."
      sleep 5
      ;;
    *)
      printf '%s\n' "${checks_output}" >&2
      echo "Required checks failed for pull request #${pr_number}." >&2
      exit 1
      ;;
  esac
done

while true; do
  merge_state="$(gh pr view "${pr_number}" --json mergeStateStatus --jq '.mergeStateStatus')"

  case "${merge_state}" in
    CLEAN|HAS_HOOKS|UNSTABLE)
      break
      ;;
    BLOCKED)
      echo "Waiting for pull request #${pr_number} to become mergeable: ${merge_state}"
      sleep 10
      ;;
    BEHIND)
      echo "Updating pull request #${pr_number} branch before merging."
      gh pr update-branch "${pr_number}"
      sleep 10
      ;;
    DIRTY|DRAFT)
      echo "Pull request #${pr_number} is not ready to merge: ${merge_state}" >&2
      exit 1
      ;;
    *)
      echo "Waiting for pull request #${pr_number} to become mergeable: ${merge_state}"
      sleep 10
      ;;
  esac
done

gh pr merge "${pr_number}" --merge --delete-branch
