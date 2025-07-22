#!/bin/bash

# This file is used to install or your device apXtri.
# You will find more informations at [url]
# This setup respects the Linux architecture and will automatically install all the necessary tools for the proper functioning of apXtri.

# This will allow you to choose between 2 install modes. First, the 'dev' mode which is recommended only for developpers or if you have the necessary knowledge to install manually apXtri. The second mode is the 'prod' mode is the default mode to use apXtri and for every normal user.


SSH_KEY="path_to_key" #key for rsync
GIT_REPO="url"  #Replace by real url

echo "Welcome to the setup of apXtri ! Thanks you to have choosen us !"
sleep 2
echo "Now, you will choose if you want to install apXtri in dev mode or in prod mode."
sleep 2
echo "1) Dev mode (recommended for developpers or for install on an USB key)"
echo "2) Prod mode (standard Linux Ubuntu Server install)"
sleep 2

read -p "Enter the correspondent mode (1 or 2) then click Enter : " MODE

case "$MODE" in
    1)
        echo "Install in dev mode..."
        DEV=true
        DATAPATH="" #path put by the user
        NODEPATH="" #path put by the user
        LOGPATH="" #path put by the user
        ;;
    2)
        echo "PROD mode selected"
        DEV=false
        DATAPATH="/var/lib/apxtowns"
        NODEPATH="/opt/apxtowns"
        LOGPATH="/var/log/apxtowns"
        ;;
    *)
        echo "Wrong number. Please choose between 1 or 2."
        sleep 2
        exit 1
        ;;
esac

# Create base dirs
sudo mkdir -p "$DATAPATH" "$NODEPATH" "$LOGPATH"
sudo chown -R $USER:$USER "$DATAPATH" "$NODEPATH" "$LOGPATH"

# Ask user inputs
echo "Now you will choose names of your field. Your tribe respects rules of your town which respects rules of your nation. tribe < town < nation."

#Put in infinite loop and verif if empty for each properties
read -p "Choose your TRIBE name: " TRIBE
read -p "Choose your TOWN name: " TOWN
read -p "Choose your NATION name: " NATION
read -p "Username for Express app (used in .env): " USERNAME

APP_DIR="$NODEPATH/$TOWN"


echo "Cloning apxtri into $APP_DIR..."
git clone "$GIT_REPO" "$APP_DIR" || {
  echo "Git clone failed"; exit 1;
}
sleep 2

# Synchronization
echo "Now your server will synchronize data by an other server...."
sleep 2
echo "Syncing town objects from smatchit server..."
sleep 2

OBJECTS=(articles jobads jobsteps jobtitles options persons quizz recruiters seekers sirets)
for OBJ in "${OBJECTS[@]}"; do
    rsync -avz -e "ssh -i ${SSH_KEY} -p 2230" --delete \
        phil@apptest.smatchit.io:/home/phil/apxtowns/${TOWN}/smatchit/objects/${OBJ}/ \
        ${DATAPATH}/${TOWN}/smatchit/objects/${OBJ}/
done

#.env generation, verify later
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

# --- HOSTS ---
DOMAIN="${TOWN}.apxtri.local"
echo "Updating /etc/hosts for $DOMAIN..."
if ! grep -q "$DOMAIN" /etc/hosts; then
    echo "127.0.0.1   $DOMAIN" | sudo tee -a /etc/hosts
fi

#Install caddy, verif configure and install with other script
echo "Installing Caddy web server..."
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

