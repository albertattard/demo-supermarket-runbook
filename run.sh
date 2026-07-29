#!/bin/bash

set -e

TARGET='/tmp/demo-supermarket'
REPOSITORY="${TARGET}/repository"

rm -rf   "${TARGET}"
mkdir -p "${REPOSITORY}"
cp -R    './fixtures' "${TARGET}/"
cp -R    './tools'    "${TARGET}/"

sw run --working-directory "${REPOSITORY}" --verbose
