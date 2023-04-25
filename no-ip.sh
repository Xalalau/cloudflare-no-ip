# ENV
BASE_DIR="$HOME/cloudflare-ddns-updater"
SCRIPT="$BASE_DIR/cloudflare-template.sh"
SERVICE_NAME="no-ip"
SERVICE_FILE="/lib/systemd/system/$SERVICE_NAME.service"
LOG="$BASE_DIR/update.log"

AUTH_EMAIL=
AUTH_METHOD=
AUTH_KEY=
ZONE_IDENTIFIER=
RECORD_NAME=
TTL=
PROXY=
SITENAME=
SLACKCHANNEL=
SLACKURI=
DISCORDURI=

INTERVAL_SEC=

# APT
sudo apt update
sudo apt upgrade -y
sudo apt install git sed -y

# Download cloudflare-ddns-updater script
sudo rm -r "$BASE_DIR"
git clone https://github.com/K0p1-Git/cloudflare-ddns-updater.git "$BASE_DIR"

# Redirect logs
sed -i 's/#!\/bin\/bash//g' "$SCRIPT"
echo '#!/bin/bash' > temp
echo 'function logger() {' >> temp
echo "    local out='$LOG'" >> temp
echo '    echo "$1" >> "$out"' >> temp
echo '}' >> temp
cat "$SCRIPT" >> temp
mv temp "$SCRIPT"
sed -i "s/logger -s/logger/g" "$SCRIPT"

# Apply settings
sed -i "s/auth_email=\"\"/auth_email=\"$AUTH_EMAIL\"/g" "$SCRIPT"
sed -i "s/auth_method=\"token\"/auth_method=\"$AUTH_METHOD\"/g" "$SCRIPT"
sed -i "s/auth_key=\"\"/auth_key=\"$AUTH_KEY\"/g" "$SCRIPT"
sed -i "s/zone_identifier=\"\"/zone_identifier=\"$ZONE_IDENTIFIER\"/g" "$SCRIPT"
sed -i "s/record_name=\"\"/record_name=\"$RECORD_NAME\"/g" "$SCRIPT"
sed -i "s/ttl=\"3600\"/ttl=\"$TTL\"/g" "$SCRIPT"
sed -i "s/proxy=\"false\"/proxy=\"$PROXY\"/g" "$SCRIPT"
sed -i "s/sitename=\"\"/sitename=\"$SITENAME\"/g" "$SCRIPT"
sed -i "s/slackchannel=\"\"/slackchannel=\"$SLACKCHANNEL\"/g" "$SCRIPT"
sed -i "s/slackuri=\"\"/slackuri=\"$SLACKURI\"/g" "$SCRIPT"
sed -i "s/discorduri=\"\"/discorduri=\"$DISCORDURI\"/g" "$SCRIPT"

# Add executable permission
sudo chmod +x "$SCRIPT"

# Create log
touch "$LOG"
echo "Cloudflare DNS script installed." >> "$LOG"

# Create and exec service
SERVICE_CONTENT="
[Unit]
Description=NO-IP
After=network.target
StartLimitIntervalSec=0

[Service]
Type=simple
Restart=always
RestartSec=$INTERVAL_SEC
User=$(whoami)
ExecStart=$SCRIPT
WorkingDirectory=$BASE_DIR

[Install]
WantedBy=multi-user.target
"

no_ip_exists=false

if [ -f "$SERVICE_FILE" ]; then
    sudo rm "$SERVICE_FILE"
    no_ip_exists=true
fi

echo "${SERVICE_CONTENT}" | sudo tee -a "$SERVICE_FILE" &>> /dev/null

if [ $no_ip_exists == true ]; then
    sudo systemctl daemon-reload
    sudo service $SERVICE_NAME restart
else
    sudo service $SERVICE_NAME start
fi
