#!/bin/bash

# Définir le nom de l'utilisateur
APXTRI_USER="apxtri"

# Vérifier si l'utilisateur existe déjà
if id "$APXTRI_USER" &>/dev/null; then
    echo "L'utilisateur $APXTRI_USER existe déjà."
else
    # Créer l'utilisateur apxtri
    echo "Création de l'utilisateur $APXTRI_USER..."
    sudo useradd -m -s /bin/bash "$APXTRI_USER"
    echo "Définir un mot de passe pour $APXTRI_USER :"
    sudo passwd "$APXTRI_USER"
fi

# Ajouter l'utilisateur apxtri au groupe sudo
echo "Ajout de l'utilisateur $APXTRI_USER au groupe sudo..."
sudo usermod -aG sudo "$APXTRI_USER"

# Vérifier si l'utilisateur a été ajouté au groupe sudo
if id -nG "$APXTRI_USER" | grep -qw "sudo"; then
    echo "$APXTRI_USER a été ajouté au groupe sudo avec succès."
else
    echo "Échec de l'ajout de $APXTRI_USER au groupe sudo."
    exit 1
fi

# Ajouter l'utilisateur au fichier sudoers pour pouvoir utiliser sudo sans mot de passe (optionnel)
echo "Ajout de $APXTRI_USER au fichier sudoers pour permettre l'utilisation de sudo sans mot de passe..."
echo "$APXTRI_USER  ALL=(ALL) NOPASSWD: ALL" | sudo tee -a /etc/sudoers

# Vérifier que l'utilisateur apxtri peut utiliser sudo
echo "Vérification de l'accès sudo pour $APXTRI_USER..."
sudo -u "$APXTRI_USER" sudo -l

echo "Utilisateur $APXTRI_USER créé et configuré avec les droits sudo."

sudo su $APXTRI_USER
cd /home/apxtri
