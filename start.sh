#!/bin/bash
sudo apt-get install zsh -y
sudo curl -L http://install.ohmyz.sh | sh
sudo apt install git -y

curl -sL https://deb.nodesource.com/setup_14.x | sudo bash -
sudo apt -y install nodejs

sudo npm install -g @vue/cli

sudo apt install docker.io
sudo chmod 666 /var/run/docker.sock

sudo apt-get update && sudo apt-get install ibus-bamboo –y


