#!/bin/bash

# This file is used to install or your device apXtri.
# You will find more informations at [url]
# This setup respects the Linux architecture and will automatically install all the necessary tools for the proper functioning of apXtri.

set -e  # stop the script if error

REPO_APXTRI="https://gitea.ndda.fr/apxtri/apxtri.git"
REPO_OBJECTS="https://gitea.ndda.fr/apxtri/objects.git"
DATAPATH="/var/lib/apxtowns" 
NODEPATH="/opt/apxtowns"
LOGPATH="/var/log/apxtowns"
NATION="ants"
TOWN="farm"
APP_DIR="$NODEPATH/$NATION-$TOWN"
APXTRI_USER="apxtri"

echo "Welcome to the setup of apXtri ! Thank you for choosing us!"
sleep 1
echo "Starting up the installation..."

# Update and useful tools
sudo apt update
sudo apt install -y curl git build-essential

# Create user apxtri if not existing
if id "$APXTRI_USER" &>/dev/null; then
    echo "User $APXTRI_USER already exists."
else
    echo "Creating user $APXTRI_USER..."
    sudo useradd -m -s /bin/bash "$APXTRI_USER"
    echo "Set password for $APXTRI_USER:"
    sudo passwd "$APXTRI_USER"
    sudo usermod -aG sudo "$APXTRI_USER"
fi

# Create necessaries reposetories and apply good permissions
sudo mkdir -p "$APP_DIR"
sudo mkdir -p "$DATAPATH"
sudo mkdir -p "$LOGPATH"
sudo chown -R "$APXTRI_USER":"$APXTRI_USER" "$NODEPATH"
sudo chown -R "$APXTRI_USER":"$APXTRI_USER" "$DATAPATH"
sudo chown -R "$APXTRI_USER":"$APXTRI_USER" "$LOGPATH"

echo "Switch user to $APXTRI_USER for install packages..."

sudo -i -u "$APXTRI_USER" bash << EOF

set -e

# Install NVM
export NVM_VERSION="v0.39.7"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/\$NVM_VERSION/install.sh | bash

export NVM_DIR="\$HOME/.nvm"
[ -s "\$NVM_DIR/nvm.sh" ] && \. "\$NVM_DIR/nvm.sh"

echo "Install Node.js LTS version..."
nvm install --lts
nvm use --lts
nvm alias default 'lts/*'

echo "Install Yarn..."
corepack enable
corepack prepare yarn@4.9.1 --activate
yarn --version

echo "Cloning apXtri into $APP_DIR..."
git clone $REPO_APXTRI "$APP_DIR"

echo "Cloning objects into $DATAPATH/data/objects..."
mkdir -p "$DATAPATH/data"
git clone $REPO_OBJECTS "$DATA_PATH/data/objects"
echo "Creating useful repos..."
mkdir -p "$DATAPATH/data/logs"

echo "Installing dependencies with Yarn..."
cd "$APP_DIR"
yarn install

echo "Generating .env file..."
cat << EOL > "$APP_DIR/.env"
TOWN=$TOWN
NATION=$NATION
UBUNTU=server
ETCCONF=/etc/apxtowns/apxtowns
DATAPATH=$DATAPATH
NODEPATH=$NODEPATH
LOGPATH=$LOGPATH
APIPORT=3021
ACTIVELOG=apxtri,Odmdb,Wwws,Trackings,Notifications
EXPOSEDHEADERS=xdays,xhash,xalias,xlang,xtribe,xapp,xuuid
SOCKETPORT=3031
BACKENDURL=localhost
CADDYAPIURL=http://localhost:2019/
# Personalised install
EOL

EOF

# Check if Caddy exist
echo "Checking if Caddy is already running..."
if pgrep -x caddy > /dev/null; then
    echo "Caddy appears to be running."

    existing_routes=$(curl -s http://localhost:2019/config/ | jq -r '.apps.http.servers | keys[]?' 2>/dev/null)

    if [ -n "$existing_routes" ] && [ "$existing_routes" != "srv0" ]; then
        echo "Caddy is configured with non-default routes: $existing_routes"
        read -p "Do you want to overwrite the current Caddy configuration? [y/N]: " confirm
        if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
            echo "Installation aborted to preserve existing Caddy setup."
            exit 1
        fi
    else
        echo "Caddy is running but appears to use the default config."
    fi
fi

# Check default ports in 
echo "Check if default ports are already in use..."
PORTS=(3021 3031)
for PORT in "${PORTS[@]}"; do
    if ss -tuln | grep -q ":$PORT "; then
        echo "Port $PORT is already in use. This may conflict with apXtri."
        read -p "Do you want to continue and risk overwriting services on port $PORT? [y/N]: " port_confirm
        if [[ "$port_confirm" != "y" && "$port_confirm" != "Y" ]]; then
            echo "Installation aborted to avoid port conflict."
            exit 1
        fi
    fi
done


echo "Installing Caddy web server..."

sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https curl jq
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo tee /etc/apt/trusted.gpg.d/caddy.gpg > /dev/null
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy.list
sudo apt update
sudo apt install -y caddy

# Add admin.apxtri domain to /etc/hosts
if ! grep -q "admin.apxtri.farm.ants" /etc/hosts; then
    echo "127.0.0.1    admin.apxtri.farm.ants" | sudo tee -a /etc/hosts
else
    echo "admin.apxtri already present in /etc/hosts"
fi


echo "Launching apXtri as $APXTRI_USER..."

sudo -i -u "$APXTRI_USER" bash -c "cd $APP_DIR && yarn dev"

echo "Installation complete!"

