#!/bin/bash
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg -i google-chrome-stable_current_amd64.deb

sudo apt-get install zsh -y
sudo curl -L http://install.ohmyz.sh | sh
git clone https://github.com/bhilburn/powerlevel9k.git ~/.oh-my-zsh/custom/themes/powerlevel9k
chsh -s $(which zsh)


sudo apt install git -y

curl -sL https://deb.nodesource.com/setup_14.x | sudo bash -
sudo apt -y install nodejs

sudo npm install -g @vue/cli

sudo apt install docker.io
sudo chmod 666 /var/run/docker.sock

sudo apt-get install ibus-unikey -y

docker run -d --network=host --name=redis redis
docker run --name rabbitmq -d --network=host -e RABBITMQ_DEFAULT_USER=guest -e RABBITMQ_DEFAULT_PASS=guest  bitnami/rabbitmq:latest

