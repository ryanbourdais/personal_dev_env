#!/usr/bin/env bash
set -e

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
    gnupg

echo "=== Setting up directories ==="
mkdir -p ~/repos

echo "=== Installing pyenv and Python ${PYTHON_VERSION:=3.13.7} ==="
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PYENV_ROOT/shims:$PATH"

# Install pyenv
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
pyenv install -s ${PYTHON_VERSION}
pyenv global ${PYTHON_VERSION}

echo "=== Installing pip ==="
python -m ensurepip --upgrade
python -m pip install --upgrade pip setuptools wheel

echo "=== Installing Node LTS via NVM ==="
export NVM_DIR="$HOME/.nvm"
mkdir -p $NVM_DIR
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash

# Add NVM to shell startup
if ! grep -q 'nvm.sh' ~/.bashrc; then
    echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.bashrc
    echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> ~/.bashrc
fi

# Source nvm immediately
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Install Node
nvm install --lts
nvm alias default lts/*

echo "=== Installing .NET SDK 8.0 ==="
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor \
    | sudo tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null
echo "deb [arch=amd64] https://packages.microsoft.com/ubuntu/24.04/prod noble main" \
    | sudo tee /etc/apt/sources.list.d/microsoft.list
sudo apt-get update
sudo apt-get install -y dotnet-sdk-8.0

echo "=== Verifying installations ==="
python --version
python -m pip --version
node -v
npm -v
dotnet --version

echo "=== Setup complete! Your repos folder is at ~/repos ==="
