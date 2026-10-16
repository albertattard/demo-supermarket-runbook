#!/usr/bin/env bash
# Copy local Codex credentials directly to the OCI worker's agent account.
# Credentials travel over SSH stdin, never through Terraform or opc-owned files.
set -euo pipefail

script_directory="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
if (( $# > 2 )); then
  printf 'Usage: %s [worker-host [ssh-private-key-path]]\n' "$0" >&2
  exit 1
fi
worker_host="${1:-${CODEX_MODERNISATION_WORKER_HOST:-}}"
ssh_key="${2:-${CODEX_MODERNISATION_SSH_PRIVATE_KEY_PATH:-${SSH_PRIVATE_KEY_PATH:-}}}"
auth_file="${CODEX_AUTH_FILE:-${CODEX_HOME:-$HOME/.codex}/auth.json}"

if [[ ! -f "$auth_file" || ! -r "$auth_file" || ! -s "$auth_file" ]]; then
  printf 'Codex auth file is missing, unreadable, or empty: %s\n' "$auth_file" >&2
  exit 1
fi
# Default to the VM provisioned by this directory. Explicit host/environment
# configuration also works without Terraform installed on the controller.
if [[ -z "$worker_host" ]]; then
  worker_host="$(terraform -chdir="$script_directory" output -raw public_ip)"
fi
[[ "$worker_host" =~ ^[a-zA-Z0-9][a-zA-Z0-9.-]*$ ]] || {
  printf 'Invalid worker host: %s\n' "$worker_host" >&2
  exit 1
}
ssh_options=(-o BatchMode=yes -o ConnectTimeout=10 -o ConnectionAttempts=1
  -o StrictHostKeyChecking=accept-new -o ForwardAgent=no -o ClearAllForwardings=yes
  -o ServerAliveInterval=15 -o ServerAliveCountMax=3)
if [[ -n "$ssh_key" ]]; then
  [[ -f "$ssh_key" && -r "$ssh_key" ]] || {
    printf 'SSH private key is missing or unreadable: %s\n' "$ssh_key" >&2
    exit 1
  }
  ssh_options+=(-i "$ssh_key" -o IdentitiesOnly=yes)
fi

# Run the receiving process as agent, so both directory and file have the right
# owner. Replace atomically only after a complete, nonempty transfer; on failure
# retain the previous auth.json and remove the temporary credential file.
remote_script="$(cat <<'REMOTE'
set -euo pipefail
umask 077
cd /home/agent
mkdir -p .codex
chmod 700 .codex
auth_tmp="$(mktemp .codex/auth.json.XXXXXX)"
trap "rm -f -- \"$auth_tmp\"" EXIT
cat > "$auth_tmp"
test -s "$auth_tmp"
chmod 600 "$auth_tmp"
mv -f -- "$auth_tmp" .codex/auth.json
REMOTE
)"
# The fixed script above contains no single quotes. Single-quote it for the
# remote login shell; no local path or credential content enters that command.
ssh "${ssh_options[@]}" "opc@$worker_host" \
  "sudo -n -u agent -- /bin/bash -c '$remote_script'" < "$auth_file"
printf 'Copied Codex auth to %s:/home/agent/.codex/auth.json (agent, mode 600).\n' "$worker_host"
