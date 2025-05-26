#!/usr/bin/env bash

prepare() {
    # stop sevices
    sudo systemctl stop k3s-agent
    sudo systemctl stop rke2-agent

    # Unisntall rke2/k3s
    curl https://raw.githubusercontent.com/rancher/system-agent/main/system-agent-uninstall.sh | sudo sh
    sudo /usr/local/bin/k3s-agent-uninstall.sh
    sudo rke2-uninstall.sh

    # Clean-up config dirs
    sudo rm -rf /etc/ceph \
           /etc/cni \
           /etc/kubernetes \
           /etc/rancher \
           /opt/cni \
           /opt/rke \
           /run/secrets/kubernetes.io \
           /run/calico \
           /run/flannel \
           /var/lib/calico \
           /var/lib/etcd \
           /var/lib/cni \
           /var/lib/kubelet \
           /var/lib/rancher\
           /var/log/containers \
           /var/log/kube-audit \
           /var/log/pods \
           /var/run/calico

    sudo apt purge haproxy -y
    sudo apt update
    sudo apt full-upgrade -y
    sudo apt dist-upgrade -y
    sudo apt autoclean -y
    sudo apt autoremove -y
    sudo reboot
}

install() {
    # Set the token
    export K3S_TOKEN="K1010eb30e18fa4e582987b2aa652d4e57224d4fafacc6f8aada8c18d3c96fe7b20::server:Reenact-Empathic3-Rush-Sinless-Pardon"

    # Set the node name for this specific worker
    export NODE_NAME="$(hostname -s)"
    echo "$NODE_NAME"

    # Install k3s as agent (worker)
    curl -sfL https://get.k3s.io | sudo sh -s - agent \
      --token="${K3S_TOKEN}" \
      --server https://k8s-master-node-01.spacectl.arpa:6443 \
      --node-name="${NODE_NAME}" \
      --node-label "node.kubernetes.io/instance-type=worker"

    # Verify agent is running
    sudo systemctl status k3s-agent
}

$1
