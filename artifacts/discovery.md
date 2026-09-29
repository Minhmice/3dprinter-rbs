# Server Discovery Report: Raspberry Pi / MainsailOS

- **Discovered Date:** 2026-09-29
- **Target Host:** 192.168.0.103:22
- **Discovered Users:** `kero` (UID 1000), `minhmice` (UID 1001, created per request)
- **Status:** Reachable, sudo functional

---

## 1. Proven Facts (FACT)

### Hardware & Firmware
- **Board Model:** Raspberry Pi 2 Model B Rev 1.1 (`/proc/device-tree/model`)
- **CPU Architecture:** 32-bit `armv7l` (4 cores)
- **Memory:** ~1 GB RAM
- **Bootloader/Firmware partition:** `/boot/firmware` (vfat, 510MB total, 99MB used)
- **Root partition:** `/dev/mmcblk0p2` (ext4, 14GB total, 8.9GB used, 69% usage)

### Operating System & Distribution
- **OS:** Raspbian GNU/Linux 12 (bookworm)
- **Kernel:** Linux `6.12.25+rpt-rpi-v7` (#1 SMP Raspbian 1:6.12.25-1+rpt1)
- **MainsailOS Release:** 2.0.0 (bookworm) (`/etc/mainsailos-release`)
- **Image Provenance:** Raspberry Pi reference 2025-05-13 generated with `pi-gen` stage2 commit `f548f25325e28bea61904f5038a9b9fd0c92b07b` (`/boot/firmware/issue.txt`)
- **Default Shell & Python:** `/bin/bash`, Python 3.11.2, Git 2.39.5

### Network & Access
- **Primary Interface:** `eth0` with static/DHCP IP `192.168.0.103/24`
- **Default Route:** `192.168.0.1` via `eth0`
- **DNS Server:** `192.168.0.1` (managed by NetworkManager)
- **SSH:** Listening on `0.0.0.0:22` and `[::]:22`
- **Tailscale:** `tailscaled.service` is loaded and running; status is currently logged out.

### Sudo & Permissions
- User `kero` has passwordless sudo configured via group membership / defaults.
- User `minhmice` created with full sudo privileges (`/etc/sudoers.d/010_minhmice-nopasswd`).

### Services & Web Architecture
- **Nginx:** Version 1.22.1 (`/usr/sbin/nginx`), running on port 80.
- **Active site:** `/etc/nginx/sites-available/mainsail` symlinked to `sites-enabled/mainsail`.
- **Static Web Root:** `/home/kero/mainsail` serving Mainsail web interface.
- **Reverse Proxy Endpoints:**
  - `/websocket` -> `http://127.0.0.1:7125/websocket` (Moonraker)
  - `/printer`, `/api`, `/access`, `/machine`, `/server` -> `http://127.0.0.1:7125$request_uri`
  - `/webcam/` through `/webcam4/` -> `http://127.0.0.1:8080/` through `:8083/`
- **Klipper Service:** `klipper.service` (active, running `klippy.py` from `/home/kero/klippy-env/bin/python`).
- **Moonraker Service:** `moonraker.service` (active, port 7125, running from `/home/kero/moonraker-env/bin/python`).
- **Crowsnest Service:** `crowsnest.service` (loaded, failed, webcam daemon).
- **Sonar Service:** `sonar.service` (active, WiFi keepalive daemon).

---

## 2. Inferences (INFERENCE)

- **Installation Method:** The host was installed directly from an official MainsailOS v2.0.0 32-bit image, rather than via KIAUH on a bare Debian install. Evidence: `/etc/mainsailos-release`, standard user `kero`, `/boot/firmware/issue.txt` referencing pi-gen stage2.
- **Crowsnest Failure Cause:** Likely no physical USB/CSI camera is currently connected to the Pi 2.
- **MCU Connection:** Klipper service is active, but whether the 3D printer MCU is currently powered on via USB cannot be safely confirmed without querying Klipper socket (which is avoided in read-only infra discovery).

---

## 3. Unknowns (UNKNOWN)

- **MainsailOS image download exact URL and sha256 checksum:** The base image was flashed previously; exact binary download source hash is not stored on disk.
- **Future additional web app ports:** To be assigned when new apps are declared.
- **Printer calibration & printer.cfg specifics:** Excluded intentionally from server infra configuration.

---

## 4. Excluded Runtime Data (EXCLUDED RUNTIME DATA)

The following paths belong strictly to user/runtime printer operation and **MUST NOT** be managed or committed by this repository:
- `/home/kero/printer_data/gcodes/*` (print files)
- `/home/kero/printer_data/logs/*` (`klippy.log`, `moonraker.log`, `crowsnest.log`)
- `/home/kero/printer_data/comms/*` (`klippy.sock`, `klippy.serial`)
- `/home/kero/printer_data/database/*` (Moonraker SQLite/lmdb runtime state)
- `/home/kero/printer_data/timelapse/*`
