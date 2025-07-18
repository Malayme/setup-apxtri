#!/bin/bash

REPO_APXTRI="https://gitea.ndda.fr/apxtri/apxtri.git"
REPO_OBJECTS="https://gitea.ndda.fr/apxtri/objects.git"
DATAPATH="/var/lib/apxtowns"
NODEPATH="/opt/apxtowns"
LOGPATH="/var/log/apxtowns"
NATION="ants"
TOWN="farm"
APP_DIR="$NODEPATH/$TOWN"

echo "Welcome to the setup of apXtri ! Thanks you to have chosen us!"
sleep 1
echo "Starting up the installation..."

# Mise à jour et installation outils nécessaires (sans sudo)
apt update && apt install -y curl git

echo "Install NVM..."

export NVM_VERSION="v0.39.7"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/$NVM_VERSION/install.sh | bash

export NVM_DIR="$HOME/.nvm"
# Charge NVM dans ce shell
source "$NVM_DIR/nvm.sh"

echo "Install Node.js..."
nvm install --lts
nvm use --lts
nvm alias default 'lts/*'

echo "Install Yarn..."
corepack enable
corepack prepare yarn@4.9.1 --activate
yarn --version

# Création des dossiers nécessaires
mkdir -p "$APP_DIR"
mkdir -p "$DATAPATH"
mkdir -p "$LOGPATH"

echo "Clone apXtri in $APP_DIR ..."
git clone $REPO_APXTRI "$APP_DIR"

echo "Clone objects in data directory..."
mkdir -p "$APP_DIR/data"
git clone $REPO_OBJECTS "$APP_DIR/data/objects"

echo "Install dependencies with Yarn..."
cd "$APP_DIR"
yarn install

echo "Generating .env file..."
cat <<EOF > "$APP_DIR/.env"
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
EOF

echo "Install Caddy web Server..."
apt install -y debian-keyring debian-archive-keyring apt-transport-https curl jq
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | tee /etc/apt/trusted.gpg.d/caddy.gpg > /dev/null
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | tee /etc/apt/sources.list.d/caddy.list
apt update
apt install -y caddy

echo "Launch apXtri..."
cd "$APP_DIR"
yarn dev

echo "Install complete...."

