#!/bin/bash

set -e

echo "🔄 Updating system packages..."
sudo apt update && sudo apt install -y curl gnupg2 ca-certificates build-essential

echo "🧱 Removing old Node.js if exists..."
sudo apt remove -y nodejs || true

echo "⬇️ Installing Node.js 20.x..."
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs

echo "🟢 Node version:"
node -v
npm -v

echo "🚀 Installing n8n globally..."
sudo npm install -g n8n

echo "📍 Finding n8n binary path..."
N8N_PATH=$(which n8n)
echo "➡️ n8n is installed at $N8N_PATH"

echo "📝 Creating systemd service..."

SERVICE_FILE="/etc/systemd/system/n8n.service"

sudo bash -c "cat > $SERVICE_FILE" <<EOF
[Unit]
Description=n8n Workflow Automation
After=network.target

[Service]
ExecStart=${N8N_PATH}
Restart=always
RestartSec=5
User=${USER}
Environment=NODE_ENV=production
Environment=N8N_SECURE_COOKIE=false

[Install]
WantedBy=multi-user.target
EOF

echo "🔄 Reloading systemd and enabling n8n service..."
sudo systemctl daemon-reload
sudo systemctl enable n8n
sudo systemctl start n8n

echo "✅ n8n installed and running on port 5678"
echo "🔎 Check status with: sudo systemctl status n8n"