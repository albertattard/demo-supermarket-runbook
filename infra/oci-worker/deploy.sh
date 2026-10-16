#!/usr/bin/env bash
set -euo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

terraform init -upgrade
terraform fmt
terraform apply -auto-approve -input=false

worker_host="$(terraform output -raw public_ip)"
ssh_private_key_path="$(terraform output -raw ssh_private_key_path)"
./copy-codex-auth.sh "$worker_host" "$ssh_private_key_path"
