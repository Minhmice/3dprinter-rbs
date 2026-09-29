#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/common.sh
source "${SCRIPT_DIR}/common.sh"

printf "=====================================================\n"
printf "APPLY MODE: Applying desired state to %s\n" "${SSH_HOST}"
printf "Target inventory: %s\n" "${ANSIBLE_INVENTORY}"
printf "Safety flags:\n"
printf "  ALLOW_REBOOT: %s\n" "${ALLOW_REBOOT:-false}"
printf "  ALLOW_PACKAGE_REMOVAL: %s\n" "${ALLOW_PACKAGE_REMOVAL:-false}"
printf "  ALLOW_NETWORK_CHANGES: %s\n" "${ALLOW_NETWORK_CHANGES:-false}"
printf "  ALLOW_SSH_CHANGES: %s\n" "${ALLOW_SSH_CHANGES:-false}"
printf "=====================================================\n"

"${ANSIBLE_PLAYBOOK}" \
  -i "${ANSIBLE_INVENTORY}" \
  "${REPO_ROOT}/ansible/playbooks/site.yml" \
  "${ANSIBLE_EXTRA_ARGS[@]}" \
  "$@"
