#!/usr/bin/env bash
set -euo pipefail

if [[ "$#" -ne 1 || -z "$1" ]]; then
  printf 'Usage: %s <worker-public-ip>\n' "$0" >&2
  exit 1
fi

ssh_options=(-o BatchMode=yes -o ConnectTimeout=5 -o ConnectionAttempts=1
  -o StrictHostKeyChecking=accept-new -o ServerAliveInterval=15 -o ServerAliveCountMax=3)
if [[ -n "${SSH_PRIVATE_KEY_PATH:-}" ]]; then
  ssh_options+=(-i "$SSH_PRIVATE_KEY_PATH" -o IdentitiesOnly=yes)
fi
worker="opc@$1"

# SSH can become available before cloud-init finishes. Bound both waits.
printf 'Waiting for SSH on %s...\n' "$worker"
connected=false
for ((attempt = 1; attempt <= 60; attempt++)); do
  if ssh "${ssh_options[@]}" "$worker" true; then
    connected=true
    break
  fi
  if ((attempt < 60)); then
    sleep 5
  fi
done
if [[ "$connected" != true ]]; then
  printf 'Cannot connect to %s. Check the SSH key, host key, and source CIDR.\n' "$worker" >&2
  exit 1
fi

printf 'Waiting for cloud-init and checking bootstrap...\n'
ssh "${ssh_options[@]}" "$worker" 'sudo -n bash -s' <<'REMOTE'
set -euo pipefail
if timeout 900 cloud-init status --wait --long \
    && test -f /var/lib/java-worker/ready \
    && test ! -f /var/lib/java-worker/failed; then
  printf 'Worker bootstrap succeeded.\n'
else
  printf 'Worker bootstrap failed or timed out. Last cloud-init output:\n' >&2
  tail -n 80 /var/log/cloud-init-output.log >&2 || true
  exit 1
fi
REMOTE
