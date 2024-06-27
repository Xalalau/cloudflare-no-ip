# cloudflare-no-ip
This script is nothing more than an aid in the configuration and installation of [cloudflare-ddns-updater](https://github.com/K0p1-Git/cloudflare-ddns-updater) as an Ubuntu service - still pure BASH.

If you are interested, I also created a [docker composer stack to run the same script as a cron job in a container](https://github.com/Xalalau/docker-stacks/tree/master/cloudflare-dns) (but I'm using a minimal Ubuntu as base instead of Alpine Linux, so the image is a little bigger).

## Usage

Naturally we have the same settings as the original script but I added some variables to control new locations, names and the time between IP checks. Just edit ``no-ip.sh`` with your own values.
```sh
BASE_DIR=         # Base directory
                  #     Default: "$HOME/cloudflare-ddns-updater"
SCRIPT_PATH=      # Full path to the cloudflare-template.sh script
                  #     Default: "$BASE_DIR/cloudflare-template.sh"
SERVICE_NAME=     # Name for the new Ubuntu service
                  #     Default: "no-ip"
SERVICE_PATH=     # Full path for the Ubuntu service
                  #     Default: "/lib/systemd/system/$SERVICE_NAME.service"
LOG_PATH=         # Full path for the log file
                  #     Default: "$BASE_DIR/update.log"
```

```sh
AUTH_EMAIL=       # The email used to login 'https://dash.cloudflare.com'
AUTH_METHOD=      # Set to "global" for Global API Key or "token" for Scoped API Token
                  #     Default: token
AUTH_KEY=         # Your API Token or Global API Key
ZONE_IDENTIFIER=  # Can be found in the "Overview" tab of your domain
RECORD_NAME=      # Which record you want to be synced
TTL=              # Set the DNS TTL (seconds)
                  #     Default: 3600
PROXY=            # Set the proxy to true or false
                  #     Default: false
SITENAME=         # Title of site "Example Site"
SLACKCHANNEL=     # Slack Channel #example
SLACKURI=         # URI for Slack WebHook "https://hooks.slack.com/services/xxxxx"
DISCORDURI=       # URI for Discord WebHook "https://discordapp.com/api/webhooks/xxxxx"
```

```sh
INTERVAL_SEC=     # Seconds between ddns renewal checks
                  #     Default: 300
```

### Example

Install:

```sh
cd ~
git clone https://github.com/Xalalau/cloudflare-no-ip.git
cd cloudflare-no-ip
nano no-ip.sh
```

Edit ``no-ip.sh``. E.g.:

```sh
AUTH_EMAIL=my@email.com
AUTH_METHOD=global
AUTH_KEY=e99e9719868eef6f9fce5d36kfa702ze92j0a
ZONE_IDENTIFIER=9f8l2ceb95431f418c3373226z5a325b
RECORD_NAME=subdomain.domain.com
TTL=120
PROXY=true
SITENAME=MyWebsite

INTERVAL_SEC=5
```

Execute ``no-ip.sh``

```sh
./no-ip.sh
```

Check the log:

![image](https://user-images.githubusercontent.com/5098527/234381134-75175904-b42e-49b9-97ed-6d74b291674c.png)

Remove the script:

```sh
cd ~
rm -r cloudflare-no-ip
```

I hope this is useful to someone.
