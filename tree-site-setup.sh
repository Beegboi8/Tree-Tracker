#!/bin/bash

set -e

REPO="https://github.com/Beegboi8/tree-backend.git"
INSTALL_DIR="/srv/tree-backend"

echo "================================="
echo " Tree Tracker Installer"
echo "================================="

# Check for sudo
if ! command -v sudo >/dev/null; then
    echo "sudo is required."
    exit 1
fi

echo "[1/8] Installing dependencies..."

sudo apt update

sudo apt install -y \
    git \
    nodejs \
    npm \
    apache2 \
    sqlite3


echo "[2/8] Setting up installation directory..."

sudo mkdir -p /srv

if [ -d "$INSTALL_DIR/.git" ]; then
    echo "Updating Tree Tracker..."
    cd "$INSTALL_DIR"
    git pull
else
    sudo git clone "$REPO" "$INSTALL_DIR"
fi

sudo chown -R "$USER:$USER" "$INSTALL_DIR"


echo "[3/8] Installing Node dependencies..."

cd "$INSTALL_DIR"

npm install


echo "[4/8] Creating database..."

if [ ! -f "$INSTALL_DIR/climbs.db" ]; then

    if [ -f "$INSTALL_DIR/database.sql" ]; then
        sqlite3 "$INSTALL_DIR/climbs.db" < "$INSTALL_DIR/database.sql"
        echo "Database created."
    else
        echo "No database.sql found. Skipping database creation."
    fi

else
    echo "Database already exists."
fi


echo "[5/8] Configuring Apache..."

sudo a2enmod proxy
sudo a2enmod proxy_http


sudo tee /etc/apache2/sites-available/tree-tracker.conf > /dev/null <<EOF
<VirtualHost *:80>

    DocumentRoot /srv/tree-backend/html

    <Directory /srv/tree-backend/html>
        AllowOverride All
        Require all granted
    </Directory>


    ProxyPass /save http://localhost:3000/save
    ProxyPassReverse /save http://localhost:3000/save

    ProxyPass /stats http://localhost:3000/stats
    ProxyPassReverse /stats http://localhost:3000/stats

    ProxyPass /climbs http://localhost:3000/climbs
    ProxyPassReverse /climbs http://localhost:3000/climbs


    ErrorLog \${APACHE_LOG_DIR}/tree-tracker-error.log
    CustomLog \${APACHE_LOG_DIR}/tree-tracker-access.log combined

</VirtualHost>
EOF


sudo a2dissite 000-default.conf
sudo a2ensite tree-tracker.conf

sudo systemctl reload apache2


echo "[6/8] Setting up backend service..."

sudo tee /etc/systemd/system/tree-tracker.service > /dev/null <<EOF
[Unit]
Description=Tree Tracker Backend
After=network.target

[Service]
WorkingDirectory=/srv/tree-backend
ExecStart=/usr/bin/node /srv/tree-backend/server.js
Restart=always
User=$USER

[Install]
WantedBy=multi-user.target
EOF


sudo systemctl daemon-reload
sudo systemctl enable tree-tracker
sudo systemctl restart tree-tracker


echo "[7/8] Setting up automatic backups..."

sudo chmod +x "$INSTALL_DIR/backup.sh"


sudo tee /etc/systemd/system/tree-backup.service > /dev/null <<EOF
[Unit]
Description=Tree Tracker Database Backup

[Service]
Type=oneshot
ExecStart=/srv/tree-backend/backup.sh
EOF


sudo tee /etc/systemd/system/tree-backup.timer > /dev/null <<EOF
[Unit]
Description=Daily Tree Tracker Backup

[Timer]
OnCalendar=*-*-* 03:00:00
Persistent=true

[Install]
WantedBy=timers.target
EOF


sudo systemctl daemon-reload

sudo systemctl enable tree-backup.timer
sudo systemctl start tree-backup.timer


echo "[8/8] Finished!"

echo ""
echo "================================="
echo " Tree Tracker installed!"
echo "================================="

read -p "Press Enter to exit..."