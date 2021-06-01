#!/bin/bash

# This will finalise the setup of the k8s master:
#
# Has only been tested on Ubuntu 18.04.05
#

# Bootstrap the cluster on the Kube master node On the Kube master node (may take a few minutes):
sudo kubeadm init --pod-network-cidr=10.244.0.0/16

#TODO: use the output of the init command above and send it back to Terraform.

# set up local kubeconfig:
mkdir -p "$HOME"/.kube
sudo cp -i /etc/kubernetes/admin.conf "$HOME"/.kube/config
sudo chown "$(id -u)":"$(id -g)" "$HOME"/.kube/config

# check k8s version:
kubectl version

