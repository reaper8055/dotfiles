#!/usr/bin/env bash

set -euo pipefail

# Logging utilities (following your bash preferences)
log_info() { echo "[INFO] $*"; }
log_warn() { echo "[WARN] $*" >&2; }
log_error() { echo "[ERROR] $*" >&2; }

verify_cluster() {
    log_info "=== Cluster State Verification ==="

    # Verify all nodes are Ready
    sudo kubectl get nodes -o wide

    # Check master node taints (important for scheduling)
    sudo kubectl describe nodes | grep -A5 "Taints:"

    # Verify storage class availability
    sudo kubectl get storageclass

    # Check Traefik ingress controller
    sudo kubectl get pods -n kube-system | grep traefik

    # Verify cluster has sufficient resources
    sudo kubectl describe nodes | grep -A3 "Allocated resources:"
}

setup_helm_repos() {
    log_info "=== Setting up Helm repositories ==="

    # CRITICAL: Ensure helm uses k3s kubeconfig
    export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

    # CORRECTED: Use consistent naming per official docs
    # Using stable for production (recommended)
    helm repo add rancher-stable https://releases.rancher.com/server-charts/stable

    # Add Jetstack for cert-manager
    helm repo add jetstack https://charts.jetstack.io

    # Update repositories
    helm repo update

    # Verify repository addition
    helm repo list | grep -E "(rancher|jetstack)"
}

install_cert_manager() {
    log_info "=== Installing cert-manager (Official Rancher Method) ==="

    # CRITICAL: Ensure helm uses k3s kubeconfig
    export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

    # NOTE: jetstack repo already added in setup_helm_repos()
    # Update repo cache (redundant but ensures latest)
    helm repo update

    # Install cert-manager using official method
    helm install cert-manager jetstack/cert-manager \
        --namespace cert-manager \
        --create-namespace \
        --set crds.enabled=true

    log_info "Waiting for cert-manager pods to be ready..."

    # Wait for cert-manager to be ready (per official docs)
    sudo kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=cert-manager -n cert-manager --timeout=300s

    # Verification (as per official docs)
    log_info "Verifying cert-manager deployment:"
    sudo kubectl get pods --namespace cert-manager

    # Expected output verification
    local expected_pods=("cert-manager-" "cert-manager-cainjector-" "cert-manager-webhook-")
    for pod_prefix in "${expected_pods[@]}"; do
        if ! sudo kubectl get pods -n cert-manager | grep -q "$pod_prefix"; then
            log_error "Missing expected pod: $pod_prefix"
            return 1
        fi
    done

    log_info "✅ cert-manager installation verified"
}

prepare_rancher_deployment() {
    log_info "=== Preparing Rancher deployment ==="

    # Create cattle-system namespace (per official docs)
    sudo kubectl create namespace cattle-system

    # Label master nodes for Rancher placement (your addition - good practice)
    sudo kubectl label nodes k8s-master-node-01 k8s-master-node-02 k8s-master-node-03 \
        node-role.kubernetes.io/rancher=true

    log_info "Rancher deployment preparation completed"
}

install_rancher() {
    log_info "=== Installing Rancher HA ==="

    # CRITICAL: Ensure helm uses k3s kubeconfig
    export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

    # CORRECTED: Install Rancher using official method
    # Using rancher-stable (matches repository name)
    helm install rancher rancher-stable/rancher \
        --namespace cattle-system \
        --set hostname=rancher.spacectl.arpa \
        --set bootstrapPassword=admin \
        --set replicas=3 \
        --set nodeSelector."node-role\.kubernetes\.io/rancher"=true

    # Monitor deployment progress (per official docs)
    log_info "Monitoring Rancher deployment..."
    sudo kubectl -n cattle-system rollout status deploy/rancher

    # Additional verification
    sudo kubectl wait --for=condition=ready pod -l app=rancher -n cattle-system --timeout=600s

    log_info "✅ Rancher installation completed"
}

verify_rancher_deployment() {
    log_info "=== Rancher Deployment Verification ==="

    # Per official docs verification steps
    sudo kubectl -n cattle-system get deploy rancher

    # Check pod distribution
    log_info "Pod distribution across nodes:"
    sudo kubectl get pods -n cattle-system -o wide | grep rancher

    # Verify ingress
    log_info "Ingress configuration:"
    sudo kubectl get ingress -n cattle-system

    # Check service endpoints
    sudo kubectl get svc -n cattle-system

    # Certificate verification
    sudo kubectl get certificates -n cattle-system 2>/dev/null || log_info "No certificates found (expected for rancher-generated)"

    log_info "✅ Rancher deployment verification completed"
}

get_rancher_endpoint() {
    log_info "=== Rancher Access Information ==="

    # Get Traefik service details
    local traefik_service
    traefik_service=$(sudo kubectl get svc -n kube-system traefik -o jsonpath='{.spec.type}' 2>/dev/null || echo "NotFound")

    if [[ "$traefik_service" == "LoadBalancer" ]]; then
        local traefik_ip
        traefik_ip=$(sudo kubectl get svc -n kube-system traefik -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
        if [[ -n "$traefik_ip" ]]; then
            log_info "Traefik LoadBalancer IP: $traefik_ip"
            log_info "Add DNS entry: rancher.spacectl.arpa -> $traefik_ip"
        else
            log_warn "LoadBalancer service exists but no external IP assigned"
        fi
    else
        # Fall back to NodePort or master node IPs
        log_info "Traefik running as: $traefik_service"
        log_info "Master Node IPs:"
        sudo kubectl get nodes -l node-role.kubernetes.io/control-plane -o wide
        log_info "Add DNS entry: rancher.spacectl.arpa -> [Any Master IP]"
    fi

    # Show ingress configuration
    log_info "Ingress Configuration:"
    sudo kubectl get ingress -n cattle-system

    # Bootstrap password reminder
    log_info "Bootstrap password: admin"
    log_info "Access URL: https://rancher.spacectl.arpa"
}

install_helm() {
    log_info "=== Installing Helm ==="

    # Check if helm is already installed
    if command -v helm >/dev/null 2>&1; then
        log_info "Helm already installed: $(helm version --short)"
        return 0
    fi

    # Official Helm installer script
    curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

    # Verify installation
    helm version --short
    log_info "✅ Helm installation completed"
}

configure_k3s_kubeconfig() {
    log_info "=== Configuring k3s KUBECONFIG ==="

    # Set for current session
    export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

    # Make persistent across sessions
    if ! grep -q "KUBECONFIG=/etc/rancher/k3s/k3s.yaml" ~/.bashrc 2>/dev/null; then
        echo 'export KUBECONFIG=/etc/rancher/k3s/k3s.yaml' >> ~/.bashrc
        log_info "Added KUBECONFIG export to ~/.bashrc"
    else
        log_info "KUBECONFIG export already exists in ~/.bashrc"
    fi

    # Verify kubectl works
    if sudo kubectl get nodes >/dev/null 2>&1; then
        log_info "✅ kubectl working with k3s kubeconfig"
    else
        log_error "❌ kubectl failed with k3s kubeconfig"
        return 1
    fi

    # Verify helm works
    if helm version --short >/dev/null 2>&1; then
        log_info "✅ helm working with k3s kubeconfig"
    else
        log_error "❌ helm failed with k3s kubeconfig"
        return 1
    fi

    log_info "✅ k3s KUBECONFIG configuration completed"
    log_info "Current KUBECONFIG: ${KUBECONFIG}"
}

cleanup_rancher() {
    log_info "=== Cleaning up Rancher installation ==="

    # CRITICAL: Ensure helm uses k3s kubeconfig
    export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

    # Remove Rancher (per official uninstall process)
    helm uninstall rancher -n cattle-system 2>/dev/null || log_warn "Rancher not found"

    # Remove cert-manager
    helm uninstall cert-manager -n cert-manager 2>/dev/null || log_warn "cert-manager not found"

    # Clean up namespaces
    sudo kubectl delete namespace cattle-system cert-manager 2>/dev/null || log_warn "Namespaces already deleted"

    # Remove node labels
    sudo kubectl label nodes k8s-master-node-01 k8s-master-node-02 k8s-master-node-03 \
        node-role.kubernetes.io/rancher- 2>/dev/null || log_warn "Labels already removed"

    log_info "✅ Cleanup completed"
}

# Complete installation workflow
install_complete() {
    log_info "=== Starting complete Rancher HA installation ==="

    install_helm
    configure_k3s_kubeconfig  # KEY FIX: Set KUBECONFIG for k3s
    verify_cluster
    setup_helm_repos
    install_cert_manager
    prepare_rancher_deployment
    install_rancher
    verify_rancher_deployment
    get_rancher_endpoint

    log_info "🎉 Rancher HA installation completed successfully!"
    log_info "Next steps:"
    log_info "1. Add DNS entry: rancher.spacectl.arpa -> [Master Node IP]"
    log_info "2. Access: https://rancher.spacectl.arpa"
    log_info "3. Login with bootstrap password: admin"
    log_info ""
    log_info "💡 Note: KUBECONFIG is set to /etc/rancher/k3s/k3s.yaml for k3s compatibility"
}

$1
