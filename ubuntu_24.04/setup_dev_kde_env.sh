#!/usr/bin/env bash
set -e

# ========================
# GUI + Dev Setup Script for WSL2 / Packer
# ========================

echo "=== Updating system and installing base packages ==="
sudo apt-get update
sudo apt-get install -y \
    build-essential \
    ca-certificates \
    curl \
    git \
    gzip \
    jq \
    libssl-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    lsb-release \
    nano \
    openssh-client \
    shellcheck \
    tar \
    unzip \
    wget \
    zip \
    zlib1g-dev \
    software-properties-common \
    gnupg \
    x11-apps

echo "=== Installing KDE Plasma Desktop, xRDP, and VNC ==="
sudo apt-get install -y \
    kde-plasma-desktop \
    tightvncserver \
    xrdp \
    xorgxrdp

# ========================
# VNC setup
# ========================
echo "=== Configuring VNC ==="
VNC_PASSWD="${VNC_PASSWORD:-packer}"  # default 'packer', override with env
mkdir -p ~/.vnc
echo "$VNC_PASSWD" | vncpasswd -f > ~/.vnc/passwd
chmod 600 ~/.vnc/passwd
echo "To start VNC server at runtime, run:"
echo "  vncserver :1 -geometry 1920x1080 -depth 24"

# ========================
# xRDP setup
# ========================
echo "=== Configuring xRDP ==="
# Ensure KDE starts in RDP sessions
echo 'exec startplasma-x11' > ~/.xsession
chmod +x ~/.xsession

# Set a default password for the current user (testing only)
USERNAME="$(whoami)"
echo "${USERNAME}:packer" | sudo chpasswd

# Enable xrdp if systemd is present (won’t break WSL if not)
sudo systemctl enable xrdp || true

echo "To start xRDP at runtime, run:"
echo "  sudo service xrdp start"
echo "Then connect via RDP to localhost:3389"
echo "  username: $USERNAME"
echo "  password: packer"

# ========================
# Dev directories
# ========================
mkdir -p ~/repos
echo "Created ~/repos for project code."

# ========================
# pyenv + Python
# ========================
PYTHON_VERSION="${PYTHON_VERSION:-3.13.7}"
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PYENV_ROOT/shims:$PATH"

echo "=== Installing pyenv and Python $PYTHON_VERSION ==="
curl https://pyenv.run | bash

if ! grep -q 'pyenv init' ~/.bashrc; then
    echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
    echo 'export PATH="$PYENV_ROOT/bin:$PYENV_ROOT/shims:$PATH"' >> ~/.bashrc
    echo 'eval "$(pyenv init -)"' >> ~/.bashrc
fi

export PATH="$PYENV_ROOT/bin:$PYENV_ROOT/shims:$PATH"
eval "$(pyenv init -)"

pyenv install -s $PYTHON_VERSION
pyenv global $PYTHON_VERSION

# ========================
# pip
# ========================
echo "=== Installing/upgrading pip ==="
python -m ensurepip --upgrade || true
python -m pip install --upgrade pip setuptools wheel

# ========================
# Node LTS via NVM
# ========================
echo "=== Installing Node LTS via NVM ==="
export NVM_DIR="$HOME/.nvm"
mkdir -p $NVM_DIR
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash

if ! grep -q 'nvm.sh' ~/.bashrc; then
    echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.bashrc
    echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> ~/.bashrc
fi

[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

nvm install --lts
nvm alias default lts/*

# ========================
# .NET SDK 8.0
# ========================
echo "=== Installing .NET SDK 8.0 ==="
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor \
    | sudo tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null
echo "deb [arch=amd64] https://packages.microsoft.com/ubuntu/24.04/prod noble main" \
    | sudo tee /etc/apt/sources.list.d/microsoft.list
sudo apt-get update
sudo apt-get install -y dotnet-sdk-8.0

# ========================
# Verify installs
# ========================
echo "=== Verifying installs ==="
python --version
python -m pip --version
node -v
npm -v
dotnet --version

# ========================
# Done
# ========================
echo "=== Setup complete! ==="
echo "Your code folder is at ~/repos"
echo "Start VNC: vncserver :1 -geometry 1920x1080 -depth 24"
echo "Start RDP: sudo service xrdp start"
echo "Connect RDP -> localhost:3389 (user: $USERNAME / password: packer)"
