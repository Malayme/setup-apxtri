#!/bin/bash



REPO_APXTRI="https://gitea.ndda.fr/apxtri/apxtri.git"
REPO_OBJECTS="https://gitea.ndda.fr/apxtri/objects.git"
DATAPATH="/var/lib/apxtowns"
NODEPATH="/opt/apxtowns"
LOGPATH="/var/log/apxtowns"


echo "Starting up..."
sleep 1

sudo apt updtae && sudo apt install curl git -y

echo "Install NVM..."

export NVM_VERSION="v0.39.7"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/$NVM_VERSION/install.sh | bash

# Load NVM
export NVM_DIR="$HOME/.nvm"
source "$NVM_DIR/nvm.sh"

echo "Install Node.js..."
nvm install --lts
nvm use --lts
nvm alias default 'lts/*'

echo "Install Yarn..."
corepack enable
corepack prepare yarn@4.9.1 --activate

echo "Clone apxtri..."
git clone $REPO_APXTRI

echo "Clone objects..."
git clone $REPO_OBJECTS

cd apxtri

echo "Install depedencies Yarn..."
yarn install

echo "Launch in dev..."
yarn dev 

echo "Install complete..."
