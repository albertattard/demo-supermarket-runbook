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
# A successful probe does not guarantee the next SSH connection will succeed.
# Retry transport failures only, sharing one cloud-init wait budget across them.
bootstrap_deadline=$((SECONDS + 900))
for ((attempt = 1; attempt <= 60; attempt++)); do
  remaining_seconds=$((bootstrap_deadline - SECONDS))
  if ((remaining_seconds <= 0)); then
    break
  fi
  if ssh "${ssh_options[@]}" "$worker" "sudo -n bash -s -- $remaining_seconds" <<'REMOTE'
set -euo pipefail
if timeout "$1" cloud-init status --wait --long \
    && test -f /var/lib/java-worker/ready \
    && test ! -f /var/lib/java-worker/failed; then
  printf 'Worker bootstrap succeeded.\n'
else
  printf 'Worker bootstrap failed or timed out. Last cloud-init output:\n' >&2
  tail -n 80 /var/log/cloud-init-output.log >&2 || true
  exit 1
fi
REMOTE
  then
    exit 0
  else
    ssh_status=$?
  fi
  # SSH uses 255 for connection/transport errors. A remote bootstrap failure
  # exits 1 and must be reported immediately rather than hidden by retries.
  if ((ssh_status != 255)); then
    exit "$ssh_status"
  fi
  printf 'SSH connection lost or unavailable during bootstrap check (attempt %s/60).\n' "$attempt" >&2
  if ((attempt < 60 && SECONDS < bootstrap_deadline)); then
    sleep 5
  fi
done
printf 'Cannot complete the bootstrap check on %s. Check SSH connectivity and rerun the readiness check.\n' "$worker" >&2
exit 1
