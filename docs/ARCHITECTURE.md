# System Architecture

## Overview

The target machine is a **Raspberry Pi 2 Model B Rev 1.1** (32-bit `armv7l`) acting as a dedicated 3D-printer host running MainsailOS.

```text
                  +-----------------------------------+
                  |            LAN Clients            |
                  +-----------------------------------+
                                    |
                            HTTP Port 80
                                    v
+-----------------------------------------------------------------------+
|  Raspberry Pi (mainsailos)                                            |
|                                                                       |
|  +-----------------------------------------------------------------+  |
|  |  Nginx (Reverse Proxy & Web Host)                               |  |
|  |  - /             -> /home/kero/mainsail (Static SPA)            |  |
|  |  - /websocket    -> http://127.0.0.1:7125/websocket (Moonraker) |  |
|  |  - /printer, api -> http://127.0.0.1:7125 (Moonraker HTTP API)  |  |
|  |  - /webcam/      -> http://127.0.0.1:8080 (Crowsnest stream)    |  |
|  +-----------------------------------------------------------------+  |
|                                    |                                  |
|         +--------------------------+--------------------------+       |
|         v                                                     v       |
|  +-----------------------+                         +---------------+  |
|  | Moonraker (Port 7125) |                         | Future Apps   |  |
|  +-----------------------+                         +---------------+  |
|         | Unix socket                                                 |
|         v                                                             |
|  +-----------------------+                                            |
|  | Klipper (klippy.py)   |                                            |
|  +-----------------------+                                            |
|         | USB Serial                                                  |
|         v                                                             |
|  +-----------------------+                                            |
|  | 3D Printer MCU        |                                            |
|  +-----------------------+                                            |
+-----------------------------------------------------------------------+
```

---

## Configuration Layout & Single Source of Truth

The repository uses Ansible for configuration management with strict file boundaries:

```text
ansible/
├── ansible.cfg
├── inventory/
│   ├── hosts.yml              # Target definitions (no secrets, no hardcoded IPs)
│   └── group_vars/
│       └── all.yml            # SINGLE SOURCE OF TRUTH for desired state
├── playbooks/
│   ├── site.yml               # Idempotent apply playbook
│   └── verify.yml             # Health verification playbook
└── roles/
    ├── base/
    ├── system/
    ├── web/
    └── custom/
```

- **Inventory (`hosts.yml`):** Contains only host definitions and dynamic environment variable lookups. No passwords or fallback IPs are tracked.
- **Desired State (`group_vars/all.yml`):** All managed variables, user declarations, and safety controls live here. No duplicate `group_vars` files exist.

---

## Layer Separation

1. **Base OS Layer (OBSERVED / UNMANAGED):**
   - Distribution: Raspbian GNU/Linux 12 (bookworm)
   - Product: MainsailOS 2.0.0
   - Stack: Klipper, Moonraker, Mainsail SPA, nginx reverse proxy, Avahi, Crowsnest
   - Network tools: Tailscale (installed, observed)
   - Hardware: Raspberry Pi 2 Model B Rev 1.1 (armv7l / 32-bit)
   - Locked in: `os/image.lock.yml`
   - Policy: Do not duplicate or manage standard MainsailOS internals in Ansible.

2. **Managed Infrastructure Layer (This Repository):**
   - Administrative users: `admin_users` (`minhmice` with dedicated `/etc/sudoers.d/010_minhmice-nopasswd`)
   - Package additions: `managed_packages`
   - Infrastructure directories: `managed_directories`
   - Custom systemd units & drop-ins: `managed_services`
   - Nginx reverse proxies & static assets: `web_apps`

3. **Printer Runtime Layer (Excluded):**
   - G-code files, timelapse media, camera feeds
   - Printer execution logs (`klippy.log`, `moonraker.log`)
   - Moonraker database

---

## Connection & Security Model

```text
.env (local gitignored)
  ↓
scripts/common.sh (exports environment & extra args)
  ↓
Ansible Playbook execution (receives credentials dynamically)
```

No passwords, authentication tokens, private keys, or machine secrets are tracked in Git.

---

## Adding Future Lightweight Web Apps

To introduce a new web application:

1. **Deploy app files:**
   Declare target directories in `managed_directories` or install packages in `managed_packages`.
2. **Systemd service:**
   Declare unit in `managed_services` with user and listening port (e.g. `127.0.0.1:8090`).
3. **Nginx reverse proxy:**
   Expose route in `web_apps` (e.g. `/my-dashboard` -> `http://127.0.0.1:8090`).
4. **Plan & Apply:**
   Run `./scripts/plan.sh` then `./scripts/apply.sh`.
5. **Verify:**
   Add healthcheck check to `ansible/playbooks/verify.yml` and run `./scripts/verify.sh`.
