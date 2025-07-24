#!/bin/bash

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

# Create necessaries reposetories and apply good permissions
sudo mkdir -p "$APP_DIR"
sudo mkdir -p "$DATAPATH"
sudo mkdir -p "$LOGPATH"
sudo chown -R "$APXTRI_USER":"$APXTRI_USER" "$NODEPATH"
sudo chown -R "$APXTRI_USER":"$APXTRI_USER" "$DATAPATH"
sudo chown -R "$APXTRI_USER":"$APXTRI_USER" "$LOGPATH"

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
#curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo tee /etc/apt/trusted.gpg.d/caddy.gpg > /dev/null
#curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy.list
curl -fsSL https://dl.cloudsmith.io/public/caddy/stable/gpg.key | gpg --dearmor | sudo tee /etc/apt/keyrings/caddy-stable.gpg > /dev/null
echo "deb [signed-by=/etc/apt/keyrings/caddy-stable.gpg] https://dl.cloudsmith.io/public/caddy/stable/deb/debian any-version main" | sudo tee /etc/apt/sources.list.d/caddy-stable.list
sudo apt update
sudo apt install -y caddy

# Add admin.apxtri domain to /etc/hosts
if ! grep -q "admin.apxtri.farm.ants" /etc/hosts; then
    echo "127.0.0.1    admin.apxtri.farm.ants" | sudo tee -a /etc/hosts
else
    echo "admin.apxtri already present in /etc/hosts"
fi

 # Create user apxtri if not existing
if id "$APXTRI_USER" &>/dev/null; then
    echo "User $APXTRI_USER already exists."
else
    echo "Creating user $APXTRI_USER..."
    sudo useradd -m -s /bin/bash "$APXTRI_USER"
    echo "Set password for $APXTRI_USER:"
    sudo passwd "$APXTRI_USER"
    #sudo usermod -aG sudo "$APXTRI_USER"
fi

sudo -u "$APXTRI_USER" #changer mdp

echo "Cloning objects into $DATAPATH/data/objects..."
mkdir -p "$DATAPATH/data"
cd $DATAPATH/data
git clone $REPO_OBJECTS

echo "Creating useful repos..."
mkdir -p "$DATAPATH/data/apxtri/logs"
mkdir -p "$DATAPATH/data/apxtri/backups"
mkdir -p "$DATAPATH/data/apxtri/tmp"
echo "Switch user to $APXTRI_USER for install packages..."
echo "Cloning apXtri into $APP_DIR..."
cd $APP_DIR
git clone $REPO_APXTRI
cd apxtri

# Installer NVM
export NVM_VERSION="v0.39.7"
echo "Installing NVM version $NVM_VERSION..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/$NVM_VERSION/install.sh | bash

# Charger NVM dans le shell courant
export NVM_DIR="$HOME/.nvm"
# Source le script nvm.sh si disponible
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

echo "NVM loaded from $NVM_DIR"

echo "Installing Node.js LTS version..."
nvm install --lts
nvm use --lts
nvm alias default 'lts/*'

# Vérification
node -v
npm -v

echo "Installing Yarn..."
npm install -g corepack
corepack enable
corepack prepare yarn@stable --activate
yarn --version

echo "Installing dependencies with Yarn..."
yarn install


echo "Installing dependencies with Yarn..."
yarn install

echo "Generating .env file..."
cat << EOL > ".env"
TOWN=$TOWN
NATION=$NATION
UBUNTU=server
ETCCONF=/etc/apxtowns/apxtowns
DATAPATH=$DATAPATH
NODEPATH=$NODEPATH
LOGPATH=$LOGPATH
APIPORT=3021
ACTIVELOG=
EXPOSEDHEADERS=xdays,xalias,xlang,xtribe,xapp,xuuid
SOCKETPORT=3031
BACKENDURL=localhost
CADDYAPIURL=http://localhost:2019/
# Personalised install
EOL

echo "Launching apXtri as $APXTRI_USER..."
yarn dev

echo "Installation complete!"
