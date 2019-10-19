#!/bin/bash

set -eu

export DEBIAN_FRONTEND=noninteractive

UPGRADE_PACKAGES=${1:-none}

if [ "${UPGRADE_PACKAGES}" != "none" ]; then
  echo "==> Updating and upgrading packages ..."

  # Add third party repositories
  sudo add-apt-repository ppa:keithw/mosh-dev -y
  echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
  apt-get install apt-transport-https ca-certificates
  curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
  sudo apt-get update && sudo apt-get install google-cloud-sdk-engine-go

  CLOUD_SDK_SOURCE="/etc/apt/sources.list.d/google-cloud-sdk.list"
  CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)"
  if [ ! -f "${CLOUD_SDK_SOURCE}" ]; then
    echo "deb http://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" | tee -a ${CLOUD_SDK_SOURCE}
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
  fi

  sudo apt-get update
  sudo apt-get upgrade -y
fi

sudo apt-get install -qq \
  apache2-utils \
  apt-transport-https \
  build-essential \
  bzr \
  ca-certificates \
  clang \
  cmake \
  curl \
  direnv \
  dnsutils \
  docker.io \
  fakeroot-ng \
  gdb \
  git \
  git-crypt \
  gnupg \
  gnupg2 \
  google-cloud-sdk \
  google-cloud-sdk-app-engine-go \
  htop \
  hugo \
  ipcalc \
  jq \
  less \
  libclang-dev \
  liblzma-dev \
  libpq-dev \
  libprotoc-dev \
  libsqlite3-dev \
  libssl-dev \
  libvirt-clients \
  libvirt-daemon-system \
  lldb \
  locales \
  man \
  mosh \
  mtr-tiny \
  musl-tools \
  ncdu \
  netcat-openbsd \
  openssh-server \
  pkg-config \
  protobuf-compiler \
  pwgen \
  python \
  python3 \
  python3-flake8 \
  python3-pip \
  python3-setuptools \
  python3-venv \
  python3-wheel \
  qemu-kvm \
  qrencode \
  quilt \
  shellcheck \
  silversearcher-ag \
  socat \
  software-properties-common \
  sqlite3 \
  stow \
  sudo \
  tig \
  tmate \
  tree \
  unzip \
  wget \
  zgen \
  zip \
  zlib1g-dev \
  vim-gtk \
  libncurses5-dev \
  libgnome2-dev \
  libgnomeui-dev \
  libgtk2.0-dev \
  libatk1.0-dev \
  libbonoboui2-dev \
  libcairo2-dev \
  libx11-dev \
  libxpm-dev \
  libxt-dev \
  python-dev \
  python3-dev \
  ctags \
  vim-gtk \
  --no-install-recommends \

rm -rf /var/lib/apt/lists/*

# install Go
if ! [ -x "$(command -v go)" ]; then
  export GO_VERSION="1.13"
  wget "https://dl.google.com/go/go${GO_VERSION}.linux-amd64.tar.gz" 
  tar -C /usr/local -xzf "go${GO_VERSION}.linux-amd64.tar.gz" 
  rm -f "go${GO_VERSION}.linux-amd64.tar.gz"
  export PATH="/usr/local/go/bin:$PATH"
fi


# install kubectl
if ! [ -x "$(command -v kubectl)" ]; then
  curl -L -o /usr/local/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
  chmod 755 /usr/local/bin/kubectl
fi


# install terraform
if ! [ -x "$(command -v terraform)" ]; then
  export TERRAFORM_VERSION="0.12.9"
  wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip 
  unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip 
  chmod +x terraform
  mv terraform /usr/local/bin
  rm -f terraform_${TERRAFORM_VERSION}_linux_amd64.zip
fi

# install protobuf
if ! [ -x "$(command -v protoc)" ]; then
  export PROTOBUF_VERSION="3.8.0"
  mkdir -p protobuf_install 
  pushd protobuf_install
  wget https://github.com/protocolbuffers/protobuf/releases/download/v${PROTOBUF_VERSION}/protoc-${PROTOBUF_VERSION}-linux-x86_64.zip
  unzip protoc-${PROTOBUF_VERSION}-linux-x86_64.zip
  mv bin/protoc /usr/local/bin
  mv include/* /usr/local/include/
  popd
  rm -rf protobuf_install
fi

# install cloud_sql_proxy
if ! [ -x "$(command -v cloud_sql_proxy)" ]; then
  wget https://dl.google.com/cloudsql/cloud_sql_proxy.linux.amd64 -O cloud_sql_proxy
  chmod +x cloud_sql_proxy 
  mv cloud_sql_proxy /usr/local/bin
fi

# install tools
if ! [ -x "$(command -v jump)" ]; then
  echo " ==> Installing jump .."
  export JUMP_VERSION="0.23.0"
  wget https://github.com/gsamokovarov/jump/releases/download/v${JUMP_VERSION}/jump_${JUMP_VERSION}_amd64.deb
  sudo dpkg -i jump_${JUMP_VERSION}_amd64.deb
  rm -f jump_${JUMP_VERSION}_amd64.deb
fi

if ! [ -x "$(command -v hub)" ]; then
  echo " ==> Installing hub .."
  export HUB_VERSION="2.12.3"
  wget https://github.com/github/hub/releases/download/v${HUB_VERSION}/hub-linux-amd64-${HUB_VERSION}.tgz
  tar xf hub-linux-amd64-${HUB_VERSION}.tgz
  chmod +x hub-linux-amd64-${HUB_VERSION}/bin/hub
  cp hub-linux-amd64-${HUB_VERSION}/bin/hub /usr/local/bin
  rm -rf hub-linux-amd64-${HUB_VERSION}
  rm -f hub-linux-amd64-${HUB_VERSION}.tgz*
fi

if [ ! -d "~/.vim_runtime" ]; then
  echo " ==> Installing vim with plugins"
  
  git clone https://github.com/diverdane/vim-go-ide.git ~/.vim_runtime
  ~/.vim_runtime/install.sh
fi


echo "==> Creating dev directories"
mkdir -p /root/code

echo ""
echo "==> Done!"
