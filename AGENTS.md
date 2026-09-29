# AGENTS.md — Infrastructure Agent Operating Rules

This repository controls a real, physical Raspberry Pi running a live 3D-printer stack.

## Core Rules

1. **Git is the single source of truth** for managed server configuration.
2. **Inspect before modifying.** Always inspect existing state before proposing or writing changes.
3. **Prefer idempotent Ansible built-in modules** over raw shell commands (`ansible.builtin.apt`, `ansible.builtin.systemd_service`, `ansible.builtin.file`, `ansible.builtin.template`).
4. **Never make undocumented permanent SSH changes.**
5. **Never commit secrets.** Keep SSH passwords, sudo passwords, tokens, private keys, and session data in local, gitignored `.env` files only.
6. **Never collect printer runtime data** (G-code, timelapse videos, print history, logs, runtime databases, sockets).
7. **Never update printer MCU firmware automatically.**
8. **Never modify networking, routing, or firewall** without explicit human authorization (`ALLOW_NETWORK_CHANGES=true`).
9. **Never modify SSH access** in a way that risks lockout without explicit human authorization (`ALLOW_SSH_CHANGES=true`).
10. **Never reboot automatically** unless explicitly permitted (`ALLOW_REBOOT=true`).
11. **Always plan before apply.** Never run apply without reviewing check/diff output.
12. **Always verify after apply.** Run `scripts/verify.sh` to confirm intended services and reachability.
13. **Preserve existing unknown configuration.** Never delete or "clean up" unfamiliar settings or files.

---

## 10-Step Change Workflow

For every server change or feature request:

1. **Inspect repository** — check current roles, playbooks, variables, and lockfiles.
2. **Inspect relevant actual server state** — query the target host in read-only mode to understand current reality.
3. **Modify desired state in Git** — edit `ansible/group_vars/all.yml`, roles, or playbooks.
4. **Lint and validate** — run syntax checks and linting locally.
5. **Run plan/check/diff** — execute `./scripts/plan.sh` to preview changes.
6. **Review unexpected changes** — confirm only the declared changes appear in the diff.
7. **Apply** — execute `./scripts/apply.sh`.
8. **Verify** — execute `./scripts/verify.sh` and observe service health.
9. **Show Git diff** — inspect `git status` and `git diff` for accidental secret leaks.
10. **Commit** — create a focused, descriptive Git commit.
