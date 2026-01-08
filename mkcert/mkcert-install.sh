#!/bin/bash

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

install_mkcert_apt() {
  echo "Detected Linux OS"

  if ! dpkg -s libnss3-tools >/dev/null 2>&1; then
    echo "libnss3-tools is missing, installing..."
    sudo apt-get update && sudo apt-get install -y libnss3-tools
  else
    echo "libnss3-tools is already installed."
  fi

  if ! command_exists mkcert; then
    echo "mkcert is not installed, installing..."
    wget -q --show-progress -O mkcert https://dl.filippo.io/mkcert/latest?for=linux/amd64
    chmod +x mkcert
    sudo mv mkcert /usr/local/bin/
  else
    echo "mkcert is already installed."
  fi
}

install_mkcert_dnf() {
  echo "Detected Fedora OS"

  if ! rpm -q nss-tools >/dev/null 2>&1; then
    echo "nss-tools is missing, installing..."
    sudo dnf install -y nss-tools
  else
    echo "nss-tools is already installed."
  fi

  if ! command_exists mkcert; then
    echo "mkcert is not installed, installing..."
    sudo dnf install mkcert -y
  else
    echo "mkcert is already installed."
  fi
}

install_mkcert_macos() {
  echo "Detected macOS"

  if ! command_exists brew; then
    echo "Homebrew is not installed, please install it first (https://brew.sh)."
    exit 1
  fi

  if ! command_exists mkcert; then
    echo "mkcert is not installed, installing..."
    brew install mkcert
  else
    echo "mkcert is already installed."
  fi

  if ! brew list nss >/dev/null 2>&1; then
    echo "Installing nss (needed for Firefox support)..."
    brew install nss
  else
    echo "nss is already installed."
  fi
}

main() {
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if [[ -f /etc/fedora-release ]]; then
      install_mkcert_dnf
    else
      install_mkcert_apt
    fi
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    install_mkcert_macos
  else
    echo "Unsupported OS: $OSTYPE"
    exit 1
  fi

  echo "mkcert installation completed."
}

main

mkcert -install
