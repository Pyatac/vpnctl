#!/bin/bash
set -e

APP_NAME="vpnctl"
INSTALL_DIR="/opt/vpnctl"
BIN_PATH="/usr/local/bin/vpnctl"

echo "=== vpnctl installer ==="

if [ "$EUID" -ne 0 ]; then
  echo "Run as root:"
  echo "sudo ./install.sh"
  exit 1
fi

SCRIPT_DIR="$(cd -- "$(dirname -- "$(readlink -f "$0")")" && pwd)"

echo "[1/5] Installing dependencies..."
apt update
apt install -y jq openssl

if ! command -v sing-box >/dev/null 2>&1; then
  echo
  echo "sing-box not found."
  echo "Install sing-box first, then run this installer again."
  echo
  echo "For now:"
  echo "https://sing-box.sagernet.org/installation/package-manager/"
  exit 1
fi

echo "[2/5] Creating install directory..."
mkdir -p "$INSTALL_DIR"

echo "[3/5] Copying files..."
cp "$SCRIPT_DIR/vpnctl" "$INSTALL_DIR/vpnctl"
chmod +x "$INSTALL_DIR/vpnctl"

echo "[4/5] Creating runtime directories..."
mkdir -p \
  "$INSTALL_DIR/clients" \
  "$INSTALL_DIR/links" \
  "$INSTALL_DIR/builds" \
  "$INSTALL_DIR/backups"

echo "[5/5] Creating command..."
ln -sf "$INSTALL_DIR/vpnctl" "$BIN_PATH"

echo
echo "Installation complete."
echo
echo "Command:"
echo "  vpnctl"
echo
echo "Next step:"
echo "  vpnctl setup"
