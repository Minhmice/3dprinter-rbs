# 3D Printer Raspberry Pi Infrastructure Repository

Reproducible, Git-managed infrastructure configuration for a Raspberry Pi 2 Model B running MainsailOS / Klipper.

## Objective

- **Git repository** = desired state
- **Raspberry Pi** = disposable runtime

When the SD card or OS fails, a fresh compatible base image can be flashed and restored using this repository without manual snowflake configuration.

---

## Scope: What is Managed vs Unmanaged

### Managed by this Repository
- Base OS identity lock (`os/image.lock.yml`)
- Infrastructure package declarations (`managed_packages`)
- Server directories and permissions (`managed_directories`)
- Custom systemd services and drop-ins (`managed_services`)
- Reverse proxy configurations and lightweight web apps (`web_apps`)
- Disaster recovery procedures and plan/apply/verify tooling

### Intentionally Excluded (Not Managed)
- G-code files (`/home/kero/printer_data/gcodes`)
- Printer history, timelapse recordings, webcam streams
- System and service log files (`klippy.log`, `moonraker.log`)
- Moonraker runtime database (`/home/kero/printer_data/database`)
- Printer MCU firmware flashing
- Daily `printer.cfg` calibration data (unless explicitly requested)

---

## Prerequisites

Local workstation requirements:
- Python 3.10+
- `ansible-core` (or run `make init-venv` to create `./.venv`)
- Standard SSH client (`sshpass` optional if using password authentication)
- Git

---

## Getting Started

1. Copy environment template:
   ```bash
   cp .env.example .env
   ```
2. Edit `.env` with host credentials and safety controls:
   ```dotenv
   SSH_HOST=192.168.x.x
   SSH_PORT=22
   SSH_USER=kero
   SSH_PASSWORD=your_password
   SUDO_PASSWORD=your_password
   ```
3. Initialize local Python virtual environment:
   ```bash
   make init-venv
   ```

---

## Operating Workflow

The repository separates server operations into 4 distinct phases:

### 1. Discover
Inspects target machine in read-only mode and captures system state:
```bash
./scripts/discover.sh
# or
make discover
```

### 2. Plan (Preview)
Runs Ansible in `--check --diff` mode to preview proposed changes without touching the system:
```bash
./scripts/plan.sh
# or
make plan
```

### 3. Apply
Applies declared desired state safely:
```bash
./scripts/apply.sh
# or
make apply
```

### 4. Verify
Validates server reachability, disk space, and service endpoints:
```bash
./scripts/verify.sh
# or
make verify
```

---

## Disaster Recovery

See [`docs/RECOVERY.md`](docs/RECOVERY.md) for full disaster recovery instructions when replacing an SD card or rebuilding the node.
