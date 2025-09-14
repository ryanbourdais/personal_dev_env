# Dev Environment Setup

This repository provides multiple ways to set up a development environment on Windows, Linux, or macOS, using **Docker**, **WSL2**, or a fully automated **Packer GUI VM**.

---

## 1. Docker-Based Development Environment

### Building the Docker Image

From the directory containing the Dockerfile (`Dockerfile` or `Dockerfile.gui`), build the image with:

```bash
docker build -t <image-name> .
```

### Running the Docker Container

#### Linux / macOS

To run the container with a project directory mounted into `/home/repos`:

```bash
docker run -it -v ~/projects/myapp:/home/repos <image-name> bash
```

* Changes in `/home/repos` persist back to `~/projects/myapp`.
* Omit `-v` if you don’t want changes to persist.
* To mount the current directory:

```bash
docker run -it -v "$(pwd):/home/repos" <image-name> bash
```

#### Windows PowerShell

```powershell
docker run -it `
  -v ${HOME}\projects\myapp:/home/repos `
  <image-name> `
  bash
```

#### Windows CMD

```cmd
docker run -it ^
  -v %USERPROFILE%\projects\myapp:/home/repos ^
  <image-name> ^
  bash
```

#### Permissions Note

Because the container runs as root, files in the mounted directory may be owned by root. To fix ownership:

```bash
sudo chown -R $(id -u):$(id -g) ~/projects/myapp
```

---

## 2. WSL2-Based Development Environment

### Prerequisites

* Windows 10/11 with **WSL2 enabled**.
* Optional: Hyper-V enabled for VM builds.

### Running the Non-GUI Setup

1. Open a WSL2 terminal.
2. Navigate to your project or any folder you want to host the environment.
3. Run the setup script:

```bash
bash setup_dev_env.sh
```

* Installs Python, Node.js, .NET SDK, and sets up `~/repos`.

### Running the GUI Setup (KDE + VNC/RDP)

```bash
bash setup_dev_kde_env.sh
```

* Installs KDE Plasma Desktop.
* Starts a VNC server on `:1` (port 5901).
* Starts xRDP on port 3389.
* You can connect using:

  * VNC client to `localhost:5901`
  * RDP client to `localhost:3389`

---

## 3. Fully Automated Packer + WSL2 GUI VM

### Prerequisites

* Windows 10/11 with **WSL2** enabled.
* [Packer](https://developer.hashicorp.com/packer/install) installed.
* Hyper-V is **not required** for running the GUI with xRDP — this works on Windows Home editions too.

### Building the GUI WSL2 VM

1. Place your GUI setup script (`setup_dev_kde_env.sh`) in the same directory as `packer_wsl_gui_dev_env.json`.
2. Run Packer:

```powershell
packer build packer_wsl_gui_dev_env.json
```

* This will:

  * Download the Ubuntu ISO and verify checksum.
  * Build a Hyper-V VM with Ubuntu.
  * Run `setup_dev_kde_env.sh` to configure KDE Plasma, xRDP, VNC, Python, Node, and .NET.
  * Import the VM as a WSL2 distro named `dev-ubuntu-gui` (or whatever you set in the template).

### Running the GUI WSL2 Distro

Start the WSL2 distro:

```powershell
wsl -d dev-ubuntu-gui
```

Then inside the distro:

* To start **xRDP**:
  ```bash
  sudo service xrdp start
  ```
  Connect via RDP to `localhost:3389` using your Linux username (default: `packer`) and password (`packer`).

* To start **VNC**:
  ```bash
  vncserver :1 -geometry 1920x1080 -depth 24
  ```
  Connect via VNC to `localhost:5901` with the password set during installation (default: `packer`).

### Notes

* GUI services (RDP/VNC) do **not** auto-start in WSL2. You must start them manually after launching the distro.
* Use `~/repos` inside WSL for your project code.
* For non-GUI use, run `setup_dev_env.sh` instead of `setup_dev_kde_env.sh`.
* After import, you may safely delete the intermediate Hyper-V VHD to reclaim disk space.

---

## Summary

| Method              | Persistent? | GUI | Notes                                           |
| ------------------- | ----------- | --- | ----------------------------------------------- |
| Docker              | Optional    | No  | Lightweight, isolated, quick setup              |
| WSL2 CLI            | Optional    | No  | Ideal for lightweight development and scripting |
| WSL2 GUI via Packer | Yes         | Yes | Full desktop environment, connect via VNC/RDP   |

---

This README now covers **Docker**, **WSL CLI**, and **fully automated GUI WSL VM builds** for fresh Windows setups.
