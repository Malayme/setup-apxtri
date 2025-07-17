#!/bin/bash

# This script only serves to rename the town and the nation (by default farm-ants) of your actual apXtri configuration.

DATAPATH="/var/lib/apxtowns"
NODEPATH="/opt/apxtowns"
LOGPATH="/var/log/apxtowns"
NATION="farm"
TOWN="ants"
APP_DIR="$NODEPATH/$TOWN"

# Generating .env file

read -p "Do you want to change the default nation and town ? (default : /farm/ants)... Yes or Not then click Enter : " RESPONSE

case "$RESPONSE" in
    Yes)
        while true; do
            read -p "Choose the name of your TOWN : " TOWN
            if [ -z "$TOWN" ]; then
                echo "Please choose the name of your TOWN ! It can't be void..."
            else
                echo "The name of your TOWN is $TOWN. I really like it !"
                sleep 3
            fi

            read -p "Choose the name of your NATION : " NATION
            if [ -z "$NATION" ]; then
                echo "Please choose the name of your NATION ! It can't be void..."
            else
                echo "The name of your NATION is $NATION. This is very cool !"
                sleep 3
                break
            fi
        done
        # Generating .env file my modified town and nation
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
        ;;
    No)
        echo "Abandon in progress..."
        ;;

    *)
        echo "Please write Yes or No correctly..."
        sleep 2
        exit 1
        ;;
esac

exit 0
