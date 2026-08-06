#!/bin/bash

set -euo pipefail

TARGET='/tmp/demo-supermarket-starter'
REPOSITORY="${TARGET}/repository"

rm -rf "${TARGET}"
mkdir -p "${REPOSITORY}"
cp -R './fixtures' "${TARGET}/"
cp -R './tools' "${TARGET}/"

sw format --input-file starter-project-runbook.yaml
sw run \
  --input-file starter-project-runbook.yaml \
  --working-directory "${REPOSITORY}" \
  --output-file "${TARGET}/STARTER.md" \
  --verbose
