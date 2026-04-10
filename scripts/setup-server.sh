#!/bin/bash
# Setup script for a fresh Digital Ocean Droplet (Ubuntu 22.04).
# Run as root: bash scripts/setup-server.sh
set -e

echo "==> Updating system packages..."
apt-get update && apt-get upgrade -y

echo "==> Installing Docker..."
apt-get install -y ca-certificates curl gnupg lsb-release
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
    | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg
echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
    https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
    | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io \
    docker-buildx-plugin docker-compose-plugin

echo "==> Enabling and starting Docker service..."
systemctl enable docker
systemctl start docker

echo "==> Creating deploy directory..."
APP_DIR=/opt/phillyfaithful.com
mkdir -p "$APP_DIR"

echo "==> Server setup complete."
echo ""
echo "Next steps:"
echo "  1. Clone your repository into ${APP_DIR}"
echo "  2. Copy .env.example to .env and fill in the values"
echo "  3. Run: cd ${APP_DIR} && docker compose up -d --build"
echo "  4. Run: docker compose exec wordpress bash /scripts/install-wordpress.sh"
