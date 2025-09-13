#!/usr/bin/env bash
set -e

# ========================
# GUI Setup Script for WSL2 / Packer
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

echo "=== Installing KDE Plasma Desktop, xRDP, and TightVNC ==="
sudo apt-get install -y \
    kde-plasma-desktop \
    tightvncserver \
    xrdp

# ========================
# VNC setup (non-interactive)
# ========================
echo "=== Configuring VNC ==="
VNC_PASSWD="${VNC_PASSWORD:-packer}"  # default password 'packer', can be overridden
mkdir -p ~/.vnc
echo "$VNC_PASSWD" | vncpasswd -f > ~/.vnc/passwd
chmod 600 ~/.vnc/passwd
# Do not start VNC now; user can start at runtime:
echo "To start VNC server at runtime, run:"
echo "  vncserver :1 -geometry 1920x1080 -depth 24"

# ========================
# xRDP setup
# ========================
echo "=== Configuring xRDP ==="
sudo systemctl enable xrdp || true
# Do not start xRDP in Packer; user can start at runtime:
echo "To start xRDP at runtime, run:"
echo "  sudo service xrdp start"
echo "Connect via RDP to localhost:3389"

# ========================
# Optional directories for dev
# ========================
mkdir -p ~/repos
echo "Created ~/repos for project code."

# ========================
# pyenv and Python setup
# ========================
PYTHON_VERSION="${PYTHON_VERSION:-3.13.7}"
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PYENV_ROOT/shims:$PATH"

echo "=== Installing pyenv and Python $PYTHON_VERSION ==="
curl https://pyenv.run | bash

# Add pyenv init to shell startup
if ! grep -q 'pyenv init' ~/.bashrc; then
    echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
    echo 'export PATH="$PYENV_ROOT/bin:$PYENV_ROOT/shims:$PATH"' >> ~/.bashrc
    echo 'eval "$(pyenv init -)"' >> ~/.bashrc
fi

# Source pyenv immediately
export PATH="$PYENV_ROOT/bin:$PYENV_ROOT/shims:$PATH"
eval "$(pyenv init -)"

# Install Python
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

# Add NVM to shell startup
if ! grep -q 'nvm.sh' ~/.bashrc; then
    echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.bashrc
    echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> ~/.bashrc
fi

# Source NVM immediately
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Install Node
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
# Verify installations
# ========================
echo "=== Verifying installations ==="
python --version
python -m pip --version
node -v
npm -v
dotnet --version

echo "=== Setup complete! ==="
echo "Your code folder is at ~/repos"
echo "Start VNC at runtime with: vncserver :1 -geometry 1920x1080 -depth 24"
echo "Start xRDP at runtime with: sudo service xrdp start"
