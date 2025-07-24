#!/bin/bash

APXTRI_USER="apxtri"

if id "$APXTRI_USER" &>/dev/null; then
	echo "User $APXTRI_USER already exists."
else
	echo "Creating user $APXTRI_USER..."
	sudo useradd -m -s /bin/bash "$APXTRI_USER"
	echo "Set password for $APXTRI_USER:"
	sudo passwd "$APXTRI_USER"
	#sudo usermod -aG sudo "$APXTRI_USER"
fi

sudo su $APXTRI_USER
