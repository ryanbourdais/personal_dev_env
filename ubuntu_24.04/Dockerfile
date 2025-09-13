FROM ubuntu:24.04

LABEL maintainer="Ryan Bourdais"

# Install basic tools and setup
RUN apt-get update && apt-get install -y \
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
        python-is-python3 \
        shellcheck \
        tar \
        unzip \
        wget \
        zip \
        zlib1g-dev \
    && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir /home/repos

# Python and Pyenv setup
ENV PYENV_ROOT=/root/.pyenv
ENV PATH=$PYENV_ROOT/bin:$PYENV_ROOT/shims:$PATH
ENV PYTHON_VERSION=3.13.7
ENV PIPENV_DEFAULT_PYTHON_VERSION=3.13.7

RUN curl https://pyenv.run | bash && \
    export PATH=$PYENV_ROOT/bin:$PYENV_ROOT/shims:$PATH && \
    pyenv install ${PYTHON_VERSION} && \
    pyenv global ${PYTHON_VERSION} && \
    python -m ensurepip --upgrade

# NVM and Node setup  
ENV NVM_DIR=/root/.nvm
RUN mkdir -p ${NVM_DIR} && \
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash && \
    . "$NVM_DIR/nvm.sh" && nvm install --lts && \
    nvm alias default lts/* && \
    echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.bashrc && \
    echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> ~/.bashrc && \
    node -v && \
    npm -v

ENV PATH=$NVM_DIR/versions/node/default/bin:$PATH

# Dotnet and Microsoft tools setup
RUN wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor \
    | tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null && \
    echo "deb [arch=amd64] https://packages.microsoft.com/ubuntu/24.04/prod noble main" \
    > /etc/apt/sources.list.d/microsoft.list && \
    apt-get update && apt-get install -y dotnet-sdk-8.0 && \
    rm -rf /var/lib/apt/lists/*

# Confirm installations
RUN python --version && \
    python -m pip --version && \
    dotnet --version

WORKDIR /home/repos