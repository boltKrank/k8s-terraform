#!/bin/bash

# This installs Kubeadm, Kubelet, and Kubectl 
#
# Has only been tested on Ubuntu 18.04.05 LTS
#
# docker_ubuntu.sh needs to be run before as a pre-req.

# Install the k8s GPG key
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

# Add the k8s repo (bionic isn't available at time of writing)
cat << EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF

# Update packages
sudo apt-get update

# Install kubelet, kubeadm, and kubectl:
sudo apt-get install -y kubelet=1.14.5-00 kubeadm=1.14.5-00 kubectl=1.14.5-00

# Keep k8s at that version:
sudo apt-mark hold kubelet kubeadm kubectl

