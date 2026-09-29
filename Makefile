.PHONY: help init-venv discover plan apply verify lint

SHELL := /usr/bin/env bash

help:
	@echo "Available targets:"
	@echo "  make init-venv  - Create local .venv and install ansible-core"
	@echo "  make discover   - Run read-only discovery against target Pi"
	@echo "  make plan       - Preview configuration changes (--check --diff)"
	@echo "  make apply      - Apply desired configuration state"
	@echo "  make verify     - Verify server health and service status"
	@echo "  make lint       - Syntax-check playbooks and scripts"

init-venv:
	python3 -m venv .venv
	./.venv/bin/pip install --upgrade pip
	./.venv/bin/pip install ansible-core

discover:
	./scripts/discover.sh

plan:
	./scripts/plan.sh

apply:
	./scripts/apply.sh

verify:
	./scripts/verify.sh

lint:
	@echo "Checking playbook syntax..."
	ANSIBLE_CONFIG=ansible/ansible.cfg ./.venv/bin/ansible-playbook -i ansible/inventory/hosts.yml ansible/playbooks/site.yml --syntax-check
	ANSIBLE_CONFIG=ansible/ansible.cfg ./.venv/bin/ansible-playbook -i ansible/inventory/hosts.yml ansible/playbooks/verify.yml --syntax-check
	@echo "Checking shell scripts..."
	@bash -n scripts/*.sh
	@echo "Syntax checks passed."
