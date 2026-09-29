#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/common.sh
source "${SCRIPT_DIR}/common.sh"

printf "=====================================================\n"
printf "VERIFY MODE: Checking system health on %s\n" "${SSH_HOST}"
printf "Target inventory: %s\n" "${ANSIBLE_INVENTORY}"
printf "=====================================================\n"

"${ANSIBLE_PLAYBOOK}" \
  -i "${ANSIBLE_INVENTORY}" \
  "${REPO_ROOT}/ansible/playbooks/verify.yml" \
  "${ANSIBLE_EXTRA_ARGS[@]}" \
  "$@"
