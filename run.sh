#!/bin/bash

set -e

TARGET='/tmp/demo-supermarket'

rm -rf   "${TARGET}"
mkdir -p "${TARGET}"

sw run --working-directory "${TARGET}" --verbose
