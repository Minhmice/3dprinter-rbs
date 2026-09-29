#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/common.sh
source "${SCRIPT_DIR}/common.sh"

SSH_PORT="${SSH_PORT:-22}"
ARTIFACTS_DIR="${REPO_ROOT}/artifacts"
mkdir -p "${ARTIFACTS_DIR}"

printf "Starting read-only discovery against %s:%s as %s...\n" "${SSH_HOST}" "${SSH_PORT}" "${SSH_USER}"

SSH_CMD=(ssh -o StrictHostKeyChecking=accept-new -o ConnectTimeout=10 -p "${SSH_PORT}")

if [[ -n "${SSH_PASSWORD:-}" ]]; then
  if command -v sshpass >/dev/null 2>&1; then
    SSH_RUNNER=(sshpass -e "${SSH_CMD[@]}" "${SSH_USER}@${SSH_HOST}")
    export SSHPASS="${SSH_PASSWORD}"
  else
    printf "WARNING: sshpass not installed. Standard SSH will prompt for password.\n" >&2
    SSH_RUNNER=("${SSH_CMD[@]}" "${SSH_USER}@${SSH_HOST}")
  fi
else
  SSH_RUNNER=("${SSH_CMD[@]}" "${SSH_USER}@${SSH_HOST}")
fi

printf "Running remote inspection...\n"
"${SSH_RUNNER[@]}" '
  export PATH="$PATH:/usr/sbin:/sbin"
  printf "=== DISCOVERY_START ===\n"
  printf "hostname=%s\n" "$(hostname)"
  printf "model="; tr -d "\000" < /proc/device-tree/model 2>/dev/null || true; printf "\n"
  printf "arch=%s\n" "$(uname -m)"
  printf "kernel=%s\n" "$(uname -r)"
  cat /etc/os-release
  cat /etc/mainsailos-release 2>/dev/null || true
  printf "=== DISK ===\n"
  df -hT
  printf "=== SERVICES ===\n"
  systemctl list-units --type=service --state=running --no-legend --no-pager
  printf "=== PORTS ===\n"
  ss -lntup
  printf "=== NGINX ===\n"
  /usr/sbin/nginx -v 2>&1 || true
  printf "=== DISCOVERY_END ===\n"
' > "${ARTIFACTS_DIR}/discovery.raw.tmp"

printf "Discovery data collected in %s/discovery.raw.tmp\n" "${ARTIFACTS_DIR}"
printf "Inspect and update artifacts/discovery.md and artifacts/discovery.json as needed.\n"
rm -f "${ARTIFACTS_DIR}/discovery.raw.tmp"
