#!/bin/bash

# Variables
APXTRI_USER="apxtri"

# Créer l'utilisateur avec un répertoire home et un shell bash
echo "Création de l'utilisateur $APXTRI_USER..."
sudo useradd -m -s /bin/bash "$APXTRI_USER"

# Définir un mot de passe pour l'utilisateur (modifiable selon le besoin)
echo "Définir le mot de passe pour $APXTRI_USER :"
sudo passwd "$APXTRI_USER"

# Ajouter l'utilisateur au groupe sudo pour lui donner des privilèges administratifs
echo "Ajout de $APXTRI_USER au groupe sudo..."
sudo usermod -aG sudo "$APXTRI_USER"

# Vérifier que l'utilisateur est bien ajouté au groupe sudo
if id "$APXTRI_USER" | grep -q 'sudo'; then
    echo "$APXTRI_USER a été ajouté au groupe sudo avec succès."
else
    echo "Erreur : $APXTRI_USER n'a pas été ajouté au groupe sudo."
    exit 1
fi

# Vérifier que l'utilisateur a bien un répertoire home et les bonnes permissions
echo "Vérification des permissions sur le répertoire home de $APXTRI_USER..."
sudo chown -R "$APXTRI_USER":"$APXTRI_USER" /home/"$APXTRI_USER"
sudo chmod 755 /home/"$APXTRI_USER"

# Vérification de la création de l'utilisateur et de ses droits sudo
echo "Vérification de la création de l'utilisateur $APXTRI_USER..."
sudo su - "$APXTRI_USER" -c "echo 'User $APXTRI_USER created and sudo access granted!'"

# Confirmation
echo "Utilisateur $APXTRI_USER créé avec succès et a les droits sudo."

# Script terminé
echo "Installation et configuration terminées !"

