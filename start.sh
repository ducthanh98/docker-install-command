#!/bin/bash
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg -i google-chrome-stable_current_amd64.deb
sudo apt-get install -y curl
sudo apt-get install -y tmux
sudo apt -y install python3
sudo apt install -y python3-pip
pip3 install virtualenv

sudo add-apt-repository ppa:fossfreedom/indicator-sysmonitor
sudo apt-get update
sudo apt-get install -y indicator-sysmonitor


sudo apt-get install -y zsh
sudo curl -L http://install.ohmyz.sh | sh
git clone https://github.com/bhilburn/powerlevel9k.git ~/.oh-my-zsh/custom/themes/powerlevel9k
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
chsh -s $(which zsh)


sudo apt install -y git
git config --global credential.helper store

curl -sL https://deb.nodesource.com/setup_14.x | sudo bash -
sudo apt -y install nodejs
curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt-get update && sudo apt-get install yarn


sudo npm install -g @vue/cli

sudo apt install -y docker.io
sudo chmod 666 /var/run/docker.sock

sudo apt-get install -y ibus-unikey

docker run -d --network=host --name=redis redis
docker run --name rabbitmq -d --network=host -e RABBITMQ_DEFAULT_USER=guest -e RABBITMQ_DEFAULT_PASS=guest  bitnami/rabbitmq:latest

