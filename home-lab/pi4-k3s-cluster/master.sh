#!/usr/bin/env bash

prepare() {
    # stop sevices
    sudo systemctl stop k3s-agent
    sudo systemctl stop rke2-agent

    # Uninstall rke2/k3s
    curl https://raw.githubusercontent.com/rancher/system-agent/main/system-agent-uninstall.sh | sudo sh
    sudo rke2-uninstall.sh
    sudo /usr/local/bin/k3s-uninstall.sh

    # Cleanup config dirs
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
    export K3S_TOKEN="Reenact-Empathic3-Rush-Sinless-Pardon"

    # Set the node name for this specific worker
    export NODE_NAME="$(hostname -s)"
    echo "$NODE_NAME"

    # Install k3s as additional master
    curl -sfL https://get.k3s.io | sudo sh -s - server \
      --token="${K3S_TOKEN}" \
      --server https://k8s-master-node-01.spacectl.arpa:6443 \
      --disable-cloud-controller \
      --write-kubeconfig-mode=644 \
      --node-name="${NODE_NAME}"

    # Verify it's running
    sudo systemctl status k3s

    # get pods/nodes
    sudo k3s kubectl get pods -n kube-system
    sudo k3s kubectl get nodes
}

$1

