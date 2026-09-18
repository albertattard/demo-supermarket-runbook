#!/bin/bash

set -euo pipefail

PARENT='/tmp'
REPOSITORY="${PARENT}/demo-supermarket"

rm -rf "${REPOSITORY}"

sw format --input-file 'workshop-task-runbook.yaml'
sw run \
  --input-file 'workshop-task-runbook.yaml' \
  --working-directory "${PARENT}" \
  --output-file 'runbooks/README.md' \
  --verbose

demo=~/Projects/albertattard/demo/workshop-java-with-ai/examples
if [[ -d "$demo" ]]; then
  rm -rf "$demo/assets"
  mkdir -p "$demo/assets/images"
  cp runbooks/README.md "$demo/README.md"
  cp runbooks/assets/images/*.png "$demo/assets/images"
fi
