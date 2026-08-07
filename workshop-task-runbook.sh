#!/bin/bash

set -euo pipefail

PARENT='/tmp'
REPOSITORY="${PARENT}/demo-supermarket"

sw format --input-file workshop-task-runbook.yaml
sw run \
  --input-file workshop-task-runbook.yaml \
  --working-directory "${PARENT}" \
  --output-file "runbooks/README.md" \
  --verbose
