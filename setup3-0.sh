#!/bin/bash

# This file is used to install or your device apXtri.
# You will find more informations at [url]
# This setup respects the Linux architecture and will automatically install all the necessary tools for the proper functioning of apXtri.

# This will allow you to choose between 2 install modes. First, the 'dev' mode which is recommended only for developpers or if you have the necessary knowledge to install manually apXtri. The second mode is the 'prod' mode is the default mode to use apXtri and for every normal user.

REPO_APXTRI="https://gitea.ndda.fr/apxtri/apxtri.git"
REPO_OBJECTS="https://gitea.ndda.fr/apxtri/objects.git"
DATAPATH="/var/lib/apxtowns"
NODEPATH="/opt/apxtowns"
LOGPATH="/var/log/apxtowns"


echo "Welcome to the setup of apXtri ! Thanks you to have choosen us !"
sleep 1
echo "Starting up the installation..."

sudo apt update && sudo apt install curl git -y

echo "Install NVN..."

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
yarn --version

# Add an user
$ sudo useradd -s /bin/bash -m -d /home/{apxuser} -c "{apxuser}" {apxuser}
$ sudo passwd {apxuser}
$ sudo usermod -aG sudo {apxuser}
# Switch to the new user:
$ su {apxuser}

while true; do
    echo "Enter the name of your tribe..."
    sleep 1
    read -p "Choose your TRIBE name then click Enter : " TRIBE
    if [ TRIBE -z ] ; then
        echo "Please enter a valid tribe name not empty : "
    else
        echo "Your TRIBE is : $TRIBE !"
        break
    fi
done

echo "Clone apXtri..."
git clone $REPO_APXTRI

cd apxtri
mkdir data
cd data

echo "Clone objects in data..."
git clone $REPO_OBJECTS

cd
cd apxtri

echo "Install depedencies Yarn..."
yarn install
cd

echo "Install Caddy web Server..."
sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https curl jq
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo tee /etc/apt/trusted.gpg.d/caddy.gpg > /dev/null
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy.list
sudo apt update
sudo apt install -y caddy

# --- CONFIGURE CADDY ---
echo "Configuring Caddy..."
CADDYFILE="/etc/caddy/Caddyfile"
sudo tee "$CADDYFILE" > /dev/null <<EOF
$DOMAIN {
    root * $APP_DIR/public
    encode gzip
    file_server
    reverse_proxy localhost:3000
}
EOF

echo "Reloading Caddy..."
sudo systemctl reload caddy || sudo systemctl restart caddy

#Opening browser for admin, verif too
echo "Opening browser to http://$DOMAIN ..."
xdg-open "http://$DOMAIN" >/dev/null 2>&1 &

echo "apXtri installed successfully at http://$DOMAIN"
echo "You can now configure your apXtri domain at this link http://$DOMAIN"


cd apxtri
echo "Launch..."
yarn apxtri

echo "Install complete...."



