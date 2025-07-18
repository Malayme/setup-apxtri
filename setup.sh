#!/bin/bash

# This file is used to install or your device apXtri.
# You will find more informations at [url]
# This setup respects the Linux architecture and will automatically install all the necessary tools for the proper functioning of apXtri.

# This will allow you to choose between 2 install modes. First, the 'dev' mode which is recommended only for developpers or if you have the necessary knowledge to install manually apXtri. The second mode is the 'prod' mode is the default mode to use apXtri and for every normal user.

echo "Welcome to the setup of apXtri ! Thanks you to have choosen us !"
sleep 2
echo "Now, you will choose if you want to install apXtri in dev mode or in prod mode."
sleep 2
echo "1) Dev mode (recommended for developpers)"
echo "2) Prod mode (user)"
sleep 2

read -p "Enter the correspondent mode (1 or 2) then click Enter : " mode

case "$mode" in
    1)
        echo "Install in dev mode..."
        
        while true; do
            read -p "Choose the name of your tribe : " TRIBE

            if [ -z "$TRIBE" ]; then
                echo "Please choose the name of your tribe !"
            else
                echo "The name of your tribe is $TRIBE. This is very cool !"
                sleep 3
                break
            fi
        done

        echo "Your tribe is $TRIBE"
        echo "Verification of existing tribe..."
        sleep 2
        #echo "Installation de caddy..."
        #wait 1

        #DATA_PATH=/var/lib/adminapi/
        
        #sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https
        #curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo tee /etc/apt/trusted.gpg.d/caddy.gpg > /dev/null
        #curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy.list
        #sudo apt update
        #sudo apt install caddy
        #sudo apt install acl
        #sudo find $DATA_PATH -type d -name "wwws" -exec setfacl -R -m u:caddy:rx {} \;
        #sudo apt install libnss3-tools
        #sudo caddy trust

        sleep 2
        ;;
    2)
        echo "Install in prod mode..."
        
        while true; do
            read -p "Choose the name of your tribe : " TRIBE

            if [ -z "$TRIBE" ]; then
                echo "Please choose the name of your tribe !"
            else
                echo "The name of your tribe is $TRIBE. This is very cool !"
                sleep 3
                break
            fi
        done

        echo "Your tribe is $TRIBE"
        echo "Verification of existing tribe..."
        sleep 2

        #echo "Installation de caddy..."
        #wait 1
        
        #DATA_PATH=/var/lib/adminapi
        ##sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https
        #curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo tee /etc/apt/trusted.gpg.d/caddy.gpg > /dev/null
        #curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy.list
        #sudo apt update
        #sudo apt install caddy
        #sudo apt install acl
        #sudo find $DATA_PATH -type d -name "wwws" -exec setfacl -R -m u:caddy:rx {} \;


        sleep 2
        ;;
    *)
        echo "Wrong number. Please choose between 1 or 2."
        sleep 2
        exit 1
        ;;
esac


