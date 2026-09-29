#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Load .env safely if present
if [[ -f "${REPO_ROOT}/.env" ]]; then
  # Sourcing .env without export leaks or set -x
  set -a
  # shellcheck source=/dev/null
  source "${REPO_ROOT}/.env"
  set +a
fi

# Locate ansible-playbook
if [[ -x "${REPO_ROOT}/.venv/bin/ansible-playbook" ]]; then
  ANSIBLE_PLAYBOOK="${REPO_ROOT}/.venv/bin/ansible-playbook"
elif command -v ansible-playbook >/dev/null 2>&1; then
  ANSIBLE_PLAYBOOK="$(command -v ansible-playbook)"
else
  printf "FAILURE: ansible-playbook not found\nCAUSE: Neither .venv/bin/ansible-playbook nor system ansible-playbook is installed.\nFIX / NEXT ACTION: Run 'python3 -m venv .venv && .venv/bin/pip install ansible-core'.\n" >&2
  exit 1
fi

export ANSIBLE_CONFIG="${REPO_ROOT}/ansible/ansible.cfg"
ANSIBLE_INVENTORY="${ANSIBLE_INVENTORY:-${REPO_ROOT}/ansible/inventory/hosts.yml}"

# Mandatory environment checks
if [[ -z "${SSH_HOST:-}" ]]; then
  printf "FAILURE: Missing SSH_HOST\nCAUSE: SSH_HOST is not set in environment or .env\nFIX / NEXT ACTION: Copy .env.example to .env and configure SSH_HOST.\n" >&2
  exit 1
fi

if [[ -z "${SSH_USER:-}" ]]; then
  printf "FAILURE: Missing SSH_USER\nCAUSE: SSH_USER is not set in environment or .env\nFIX / NEXT ACTION: Set SSH_USER in .env.\n" >&2
  exit 1
fi
