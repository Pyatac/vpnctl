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
apt install -y jq openssl curl

if ! command -v sing-box >/dev/null 2>&1; then
  echo
  echo "sing-box not found."
  read -p "Install sing-box now? [y/N]: " INSTALL_SINGBOX

  if [ "$INSTALL_SINGBOX" = "y" ] || [ "$INSTALL_SINGBOX" = "Y" ]; then
    echo "Installing sing-box..."

    mkdir -p /etc/apt/keyrings
    curl -fsSL https://sing-box.app/gpg.key -o /etc/apt/keyrings/sagernet.asc
    chmod a+r /etc/apt/keyrings/sagernet.asc

    cat > /etc/apt/sources.list.d/sagernet.sources <<EOF
Types: deb
URIs: https://deb.sagernet.org/
Suites: *
Components: *
Enabled: yes
Signed-By: /etc/apt/keyrings/sagernet.asc
EOF

    apt update
    apt install -y sing-box
  else
    echo "sing-box is required. Aborted."
    exit 1
  fi
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
