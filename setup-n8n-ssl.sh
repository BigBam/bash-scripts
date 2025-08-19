#!/bin/bash

# =========================================================
# Script to configure SSL for n8n using Nginx + Let's Encrypt
# Usage: ./setup-n8n-ssl.sh yourdomain.com your@email.com
# =========================================================

# --- Variables ---
DOMAIN=$1
EMAIL=$2

if [ -z "$DOMAIN" ] || [ -z "$EMAIL" ]; then
  echo "Usage: $0 <yourdomain.com> <email@example.com>"
  exit 1
fi

echo ">>> Installing dependencies..."
sudo apt update
sudo apt install -y nginx certbot python3-certbot-nginx

echo ">>> Creating Nginx reverse proxy config for $DOMAIN..."

# Create Nginx server block
NGINX_CONF="/etc/nginx/sites-available/n8n"
sudo bash -c "cat > $NGINX_CONF" <<EOL
server {
    listen 80;
    server_name $DOMAIN;

    location / {
        proxy_pass http://localhost:5678/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOL

# Enable the config
sudo ln -sf $NGINX_CONF /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl reload nginx

echo ">>> Requesting SSL certificate from Let's Encrypt..."
sudo certbot --nginx -d $DOMAIN --non-interactive --agree-tos -m $EMAIL

echo ">>> Setting up auto-renewal (already handled by Certbot systemd timer)"
sudo systemctl status certbot.timer

echo ">>> All done!"
echo "Visit: https://$DOMAIN"