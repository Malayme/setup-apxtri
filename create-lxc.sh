#!/bin/bash

sudo lxc-create --name apxtri --template download -- --dist ubuntu --release noble --arch amd64
sudo lxc-start --name apxtri
sudo lxc-attach --name apxtri
