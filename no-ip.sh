# Base directory
BASE_DIR="$HOME/cloudflare-ddns-updater"
# Full path to the cloudflare-template.sh script
SCRIPT_PATH="$BASE_DIR/cloudflare-template.sh"
# Name for the new Ubuntu service
SERVICE_NAME="no-ip"
# Full path for the Ubuntu service
SERVICE_PATH="/lib/systemd/system/$SERVICE_NAME.service"
# Full path for the log file
LOG_PATH="$BASE_DIR/update.log"

# The email used to login 'https://dash.cloudflare.com'
AUTH_EMAIL=
# Set to "global" for Global API Key or "token" for Scoped API Token
AUTH_METHOD=token
# Your API Token or Global API Key
AUTH_KEY=
# Can be found in the "Overview" tab of your domain
ZONE_IDENTIFIER=
# Which record you want to be synced
RECORD_NAME=
# Set the DNS TTL (seconds)
TTL=3600
# Set the proxy to true or false
PROXY=false
# Title of site "Example Site"
SITENAME=
# Slack Channel #example
SLACKCHANNEL=
# URI for Slack WebHook "https://hooks.slack.com/services/xxxxx"
SLACKURI=
# URI for Discord WebHook "https://discordapp.com/api/webhooks/xxxxx"
DISCORDURI=

# Seconds between ddns renewal checks
INTERVAL_SEC=$((5 * 60))



# APT
sudo apt update
sudo apt upgrade -y
sudo apt install git sed -y

# Download cloudflare-ddns-updater script
sudo rm -r "$BASE_DIR"
git clone https://github.com/K0p1-Git/cloudflare-ddns-updater.git "$BASE_DIR"

# Redirect logs (removes logger dependency)
sed -i 's/#!\/bin\/bash//g' "$SCRIPT_PATH"
echo '#!/bin/bash' > temp
echo 'function logger() {' >> temp
echo '    local now=$(date +"%h %d %H:%M:%S")' >> temp
echo "    local out='$LOG_PATH'" >> temp
echo '    echo "$now $1" >> "$out"' >> temp
echo '}' >> temp
cat "$SCRIPT_PATH" >> temp
mv temp "$SCRIPT_PATH"
sed -i "s/logger -s/logger/g" "$SCRIPT_PATH"

# Apply settings
sed -i "s/auth_email=\"\"/auth_email=\"$AUTH_EMAIL\"/g" "$SCRIPT_PATH"
sed -i "s/auth_method=\"token\"/auth_method=\"$AUTH_METHOD\"/g" "$SCRIPT_PATH"
sed -i "s/auth_key=\"\"/auth_key=\"$AUTH_KEY\"/g" "$SCRIPT_PATH"
sed -i "s/zone_identifier=\"\"/zone_identifier=\"$ZONE_IDENTIFIER\"/g" "$SCRIPT_PATH"
sed -i "s/record_name=\"\"/record_name=\"$RECORD_NAME\"/g" "$SCRIPT_PATH"
sed -i "s/ttl=\"3600\"/ttl=\"$TTL\"/g" "$SCRIPT_PATH"
sed -i "s/proxy=\"false\"/proxy=\"$PROXY\"/g" "$SCRIPT_PATH"
sed -i "s/sitename=\"\"/sitename=\"$SITENAME\"/g" "$SCRIPT_PATH"
sed -i "s/slackchannel=\"\"/slackchannel=\"$SLACKCHANNEL\"/g" "$SCRIPT_PATH"
sed -i "s/slackuri=\"\"/slackuri=\"$SLACKURI\"/g" "$SCRIPT_PATH"
sed -i "s/discorduri=\"\"/discorduri=\"$DISCORDURI\"/g" "$SCRIPT_PATH"

# Add executable permission
sudo chmod +x "$SCRIPT_PATH"

# Create log
touch "$LOG_PATH"

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
ExecStart=$SCRIPT_PATH
WorkingDirectory=$BASE_DIR

[Install]
WantedBy=multi-user.target
"

no_ip_exists=false

if [ -f "$SERVICE_PATH" ]; then
    sudo rm "$SERVICE_PATH"
    no_ip_exists=true
fi

echo "${SERVICE_CONTENT}" | sudo tee -a "$SERVICE_PATH" &>> /dev/null

if [ $no_ip_exists == true ]; then
    sudo systemctl daemon-reload
    sudo service $SERVICE_NAME restart
else
    sudo service $SERVICE_NAME start
fi

echo "Cloudflare DNS script installed."

