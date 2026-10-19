#!/usr/bin/env bash
# Source this file in Bash or Zsh to configure the controller's worker access.
# Resolve Terraform state relative to this file, regardless of the caller's cwd.
# Do not enable shell options here: they would change the caller's shell.

if [[ -n "${BASH_VERSION:-}" && "${BASH_SOURCE[0]}" == "$0" ]]; then
  printf 'Source this script to set variables in your current shell: source %s\n' "$0" >&2
  exit 1
fi

_oci_worker_set_modernisation_env() {
  local script_path script_directory worker_host ssh_private_key_path
  if [[ -n "${BASH_VERSION:-}" ]]; then
    script_path="${BASH_SOURCE[0]}"
  elif [[ -n "${ZSH_VERSION:-}" ]]; then
    script_path="${(%):-%x}"
  else
    printf 'Error: source this script from Bash or Zsh.\n' >&2
    return 1
  fi
  script_directory="$(cd -- "$(dirname -- "$script_path")" && pwd)" || return 1

  command -v terraform >/dev/null 2>&1 || {
    printf 'Error: Terraform is required to read the OCI worker outputs.\n' >&2
    return 1
  }
  worker_host="$(terraform -chdir="$script_directory" output -raw public_ip)" || return 1
  ssh_private_key_path="$(terraform -chdir="$script_directory" output -raw ssh_private_key_path)" || return 1

  [[ "$worker_host" =~ ^[a-zA-Z0-9][a-zA-Z0-9.-]*$ ]] || {
    printf 'Error: Terraform public_ip must contain a worker IPv4 address or hostname.\n' >&2
    return 1
  }
  [[ -n "$ssh_private_key_path" && -f "$ssh_private_key_path" && -r "$ssh_private_key_path" ]] || {
    printf 'Error: Terraform SSH private key is missing or unreadable: %s\n' "$ssh_private_key_path" >&2
    return 1
  }

  # Resolve and validate both outputs before changing the caller's environment.
  export CODEX_MODERNISATION_WORKER_HOST="$worker_host"
  export CODEX_MODERNISATION_SSH_PRIVATE_KEY_PATH="$ssh_private_key_path"
}

if _oci_worker_set_modernisation_env; then
  unset -f _oci_worker_set_modernisation_env
else
  unset -f _oci_worker_set_modernisation_env
  return 1
fi
