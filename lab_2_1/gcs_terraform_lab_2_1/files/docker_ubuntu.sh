#!/bin/bash
# sets up Docker CE version 18.06.1
#
# only been tested on ubuntu 18.04.05
#

# Clear existing apt repos
sudo rm -rf /var/lib/apt/lists
sudo apt-get clean
sudo mkdir /var/lib/apt/lists

# Get needed packages for https apt-get (should be there by default, this is just a precaution)
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release

# get the Docker GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

# install Docker
sudo apt-get install -y docker-ce=18.06.1~ce~3-0~ubuntu
sudo apt-mark hold docker-ce

# check Docker service is running
sudo systemctl status docker --no-pager