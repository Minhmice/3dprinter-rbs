# Disaster Recovery Procedure

This procedure guides restoring the server onto a new SD card when the current storage medium fails completely.

> **Status Notice:** This procedure is derived from discovery evidence (`os/image.lock.yml`). It has not yet been subjected to an automated end-to-end bare-metal recovery test.

---

## Step 1: Base Operating System Selection

- **Target Board:** Raspberry Pi 2 Model B Rev 1.1
- **Architecture:** 32-bit `armv7l` (ARMv7)
- **Base Image:** MainsailOS Release 2.0.0 (based on Debian Bookworm / Raspbian 12)
- **Source:** [MainsailOS Official Releases](https://github.com/mainsail-crew/MainsailOS/releases) (Select 32-bit armv7l image)
- **Tool:** Use Raspberry Pi Imager or `dd` to flash image to a MicroSD card (>= 16GB).

---

## Step 2: First Boot & Network Provisioning

1. Insert SD card into Raspberry Pi.
2. Connect Ethernet cable to local network.
3. Power on Raspberry Pi.
4. Verify host obtains DHCP address (default hostname `mainsailos.local` or scan LAN for IP).
5. Verify SSH is accessible on port 22.

---

## Step 3: Clone Repository & Configure Credentials

On your local workstation:

1. Clone this repository:
   ```bash
   git clone <repo-url> 3dprinter-rbs
   cd 3dprinter-rbs
   ```
2. Copy `.env.example` to `.env`:
   ```bash
   cp .env.example .env
   ```
3. Set your target IP and credentials in `.env`:
   ```dotenv
   SSH_HOST=192.168.0.103
   SSH_PORT=22
   SSH_USER=kero
   SSH_PASSWORD=your_initial_password
   SUDO_PASSWORD=your_initial_password
   ```

---

## Step 4: Preview Restoration (Plan)

Run:
```bash
./scripts/plan.sh
```
Review the check-mode diff to ensure only expected changes will be applied.

---

## Step 5: Apply Desired State

Run:
```bash
./scripts/apply.sh
```

---

## Step 6: Verify Recovery

Run:
```bash
./scripts/verify.sh
```
Confirm:
- SSH reachable
- Root disk usage healthy
- Nginx port 80 returns status 200
- Moonraker API port 7125 returns status 200

---

## What Cannot Be Reconstructed by this Repository

The following items must be backed up separately or recalibrated:
1. **Physical printer calibration:** Bed mesh, Z-offset, stepper calibration in `printer.cfg`.
2. **G-code history & uploads:** User slicing outputs.
3. **Timelapse recordings & logs.**
4. **Tailscale authorization key:** If Tailscale was joined, re-authenticate node using `sudo tailscale up`.
