#!/bin/bash

curl -fsSL https://get.docker.com | sudo bash
sudo curl -fsSL "https://github.com/docker/compose/releases/download/1.25.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo usermod -aG docker vagrant

sudo curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind


sudo apt update && sudo apt install -y ca-certificates curl apt-transport-https
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-archive-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt update && sudo apt install -y kubectl

echo 'source <(kubectl completion bash)' >> .bashrc
source .bashrc

# Alguns comandos

# systemctl status docker


# kubectl version
# kubectl cluster-info --context kind-kind

# kind version
# kind create cluster 
# kind create cluster --name kind-2

# kind get clusters
# kind delete cluster


# Criar cluster via arquivo

# kind create cluster --config /vagrant/kind-example-config.yaml --name cluster-triplo

# https://kind.sigs.k8s.io/docs/user/quick-start/#installing-with-a-package-manager
