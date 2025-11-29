resource "null_resource" "k3s_kube_vip_rbac" {
  connection {
    type        = "ssh"
    user        = var.vm_user
    private_key = var.ssh_private_key
    host        = split("/", var.vm_ipv4[0])[0]
    agent       = false
    timeout     = "5m"
  }

  provisioner "remote-exec" {
    inline = [
      <<-EOT
        sudo mkdir -p /var/lib/rancher/k3s/server/manifests/ && sudo chmod 0755 /var/lib/rancher/k3s/server/manifests/
        if [ ! -f /var/lib/rancher/k3s/server/manifests/kube-vip-rbac.yaml ]; then
          echo 'Downloading kube-vip rbac.yaml...'
          sudo curl -sL https://kube-vip.io/manifests/rbac.yaml -o /var/lib/rancher/k3s/server/manifests/kube-vip-rbac.yaml
          sudo chmod 0755 /var/lib/rancher/k3s/server/manifests/kube-vip-rbac.yaml
        else
          echo 'kube-vip rbac.yaml already exists. Skipping download.'
        fi
        echo 'Applying kube-vip rbac...'
        sudo kubectl apply -f /var/lib/rancher/k3s/server/manifests/kube-vip-rbac.yaml
      EOT
    ]
  }

  depends_on = [null_resource.remote_k3s_master_setup]
}

resource "null_resource" "k3s_kube_vip_manifests" {
  connection {
    type        = "ssh"
    user        = var.vm_user
    private_key = var.ssh_private_key
    host        = split("/", var.vm_ipv4[0])[0]
    agent       = false
    timeout     = "5m"
  }

  provisioner "remote-exec" {
    inline = [
      <<-EOT
        echo "Configuring and applying Kube-VIP manifests..."
        export VIP=${var.kube_vip}
        export INTERFACE=eth0
        KVVERSION=$(curl -sL https://api.github.com/repos/kube-vip/kube-vip/releases | jq -r ".[0].name")
        alias kube-vip='ctr image pull ghcr.io/kube-vip/kube-vip:$KVVERSION; ctr run --rm --net-host ghcr.io/kube-vip/kube-vip:$KVVERSION vip /kube-vip'
        kube-vip manifest daemonset \
          --interface $INTERFACE \
          --address $VIP \
          --inCluster \
          --taint \
          --controlplane \
          --services \
          --arp \
          --leaderElection
        
        cat <<EOF_MANIFEST | sudo tee /var/lib/rancher/k3s/server/manifests/kube-vip-manifest.yaml > /dev/null
        apiVersion: apps/v1
        kind: DaemonSet
        metadata:
          name: kube-vip-ds
          namespace: kube-system
        spec:
          selector:
            matchLabels:
              name: kube-vip-ds
          template:
            metadata:
              labels:
                name: kube-vip-ds
            spec:
              affinity:
                nodeAffinity:
                  requiredDuringSchedulingIgnoredDuringExecution:
                    nodeSelectorTerms:
                    - matchExpressions:
                      - key: node-role.kubernetes.io/control-plane
                        operator: Exists
              containers:
              - args:
                - manager
                env:
                - name: vip_arp
                  value: "true"
                - name: port
                  value: "6443"
                - name: vip_interface
                  value: eth0
                - name: vip_cidr
                  value: "32"
                - name: cp_enable
                  value: "true"
                - name: cp_namespace
                  value: "kube-system"
                - name: vip_ddns
                  value: "false"
                - name: svc_enable
                  value: "true"
                - name: vip_leaderelection
                  value: "true"
                - name: vip_leaseduration
                  value: "5"
                - name: vip_renewdeadline
                  value: "3"
                - name: vip_retryperiod
                  value: "1"
                - name: address
                  value: ${var.kube_vip}
                image: ghcr.io/kube-vip/kube-vip:v0.4.0
                imagePullPolicy: Always
                name: kube-vip
                resources: {}
                securityContext:
                  capabilities:
                    add:
                    - NET_ADMIN
                    - NET_RAW
                    - SYS_TIME
              hostNetwork: true
              serviceAccountName: kube-vip
              tolerations:
              - effect: NoSchedule
                operator: Exists
              - effect: NoExecute
                operator: Exists
          updateStrategy: {}
        EOF_MANIFEST

        sudo kubectl apply -f /var/lib/rancher/k3s/server/manifests/kube-vip-manifest.yaml
        sudo kubectl apply -f https://raw.githubusercontent.com/kube-vip/kube-vip-cloud-provider/main/manifest/kube-vip-cloud-controller.yaml
      EOT
    ]
  }

  depends_on = [null_resource.k3s_kube_vip_rbac]
}

resource "null_resource" "k3s_kube_vip_configmap" {
  connection {
    type        = "ssh"
    user        = var.vm_user
    private_key = var.ssh_private_key
    host        = split("/", var.vm_ipv4[0])[0]
    agent       = false
    timeout     = "5m"
  }

  provisioner "remote-exec" {
    inline = [
      <<-EOT
        echo "Creating/Updating kubevip configmap..."
        sudo kubectl apply -f - <<EOF
        apiVersion: v1
        kind: ConfigMap
        metadata:
          name: kubevip
          namespace: kube-system
        data:
          range-global: "${var.kube_vip_range[0]}-${var.kube_vip_range[1]}"
        EOF
      EOT
    ]
  }

  depends_on = [null_resource.k3s_kube_vip_manifests]
}
