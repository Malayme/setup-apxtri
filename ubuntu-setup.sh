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
APP_DIR="$NODEPATH/$TOWN"
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

echo "Cloning objects into $APP_DIR/data/objects..."
mkdir -p "$APP_DIR/data"
git clone $REPO_OBJECTS "$APP_DIR/data/objects"

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

echo "Installing Caddy web server..."

sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https curl jq
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo tee /etc/apt/trusted.gpg.d/caddy.gpg > /dev/null
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy.list
sudo apt update
sudo apt install -y caddy

echo "Launching apXtri as $APXTRI_USER..."

sudo -i -u "$APXTRI_USER" bash -c "cd $APP_DIR && yarn dev"

echo "Installation complete!"

