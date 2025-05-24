resource "local_sensitive_file" "ssh_private_key_temp" {
  content = var.ssh_private_key
  filename          = "${path.cwd}/.ssh_private_key"
  file_permission   = "0600"
}

resource "null_resource" "local_make_kubeconfig_dir" {
  provisioner "local-exec" {
    command = "mkdir -p ~/.kube/ && chmod 0755 ~/.kube/"
  }
}

resource "null_resource" "local_install_curl" {
  provisioner "local-exec" {
    command = <<-EOT
      if command -v curl &> /dev/null; then
        echo "curl is already installed. Skipping installation."
        exit 0
      fi
      echo "curl not found. Installing curl..."
      sudo apt update && sudo apt install -y curl
    EOT
  }
  depends_on = [null_resource.local_make_kubeconfig_dir]
}

resource "null_resource" "local_download_k3sup" {
  triggers = {
    k3sup_version = var.k3sup_version
  }

  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command = <<-EOT
      if [[ -f /tmp/k3sup ]]; then
        current_version=$(/tmp/k3sup version --client | grep -oP 'Version: \\Kv\\d+\\.\\d+\\.\\d+')
        if [[ "$current_version" == "${var.k3sup_version}" ]]; then
          echo "k3sup version ${var.k3sup_version} already exists at /tmp/k3sup. Skipping download."
          exit 0
        fi
      fi
      echo "Downloading k3sup version ${var.k3sup_version}..."
      curl -L https://github.com/alexellis/k3sup/releases/download/${var.k3sup_version}/k3sup -o /tmp/k3sup && chmod +x /tmp/k3sup
    EOT
  }

  depends_on = [null_resource.local_install_curl]
}

resource "null_resource" "local_install_k3sup" {
  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command = <<-EOT
      SOURCE_PATH="/tmp/k3sup"
      DEST_PATH="/usr/local/bin/k3sup"
      DESIRED_VERSION="${var.k3sup_version}"

      if [[ ! -f "$SOURCE_PATH" ]]; then
        echo "Source file $SOURCE_PATH not found. Skipping installation."
        exit 0
      fi

      if [[ -f "$DEST_PATH" ]]; then
        CURRENT_INSTALLED_VERSION=$("$DEST_PATH" version --client 2>/dev/null | grep -oP 'Version: \\Kv\\d+\\.\\d+\\.\\d+')
        if [[ "$CURRENT_INSTALLED_VERSION" == "$DESIRED_VERSION" ]]; then
          echo "k3sup version $DESIRED_VERSION already installed at $DEST_PATH. Skipping move."
          rm -f "$SOURCE_PATH"
          exit 0
        else
          echo "Existing k3sup version ($CURRENT_INSTALLED_VERSION) found at $DEST_PATH does not match desired version ($DESIRED_VERSION). Proceeding with update."
        fi
      fi

      echo "Moving $SOURCE_PATH to $DEST_PATH..."
      sudo mv "$SOURCE_PATH" "$DEST_PATH"
      sudo chmod +x "$DEST_PATH"
    EOT
  }

  depends_on = [null_resource.local_download_k3sup]
}

resource "null_resource" "wait_for_ssh" {
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
      "echo 'SSH connection to VM established successfully!'"
    ]
  }

  depends_on = [
    proxmox_virtual_environment_vm.ubuntu_vm[0],
    null_resource.local_install_k3sup
  ]
}

resource "null_resource" "remote_k3s_master_setup" {
  provisioner "local-exec" {
    command = <<-EOT
      k3sup install \
        --cluster \
        --ip ${split("/", var.vm_ipv4[0])[0]} \
        --local-path ${var.kubeconfig_path} \
        --k3s-version ${var.k3s_version} \
        --no-extras \
        --tls-san ${var.kube_vip} \
        --tls-san ${var.kube_fqdn} \
        --user ${var.vm_user} \
        --ssh-key ${path.cwd}/.ssh_private_key
    EOT
    
  }
  depends_on = [null_resource.wait_for_ssh]
}

resource "null_resource" "remote_k3s_node_setup" {
  count = (length(var.hostname) - 1)

  provisioner "local-exec" {
    command = <<-EOT
      k3sup join \
        --ip ${split("/", var.vm_ipv4[count.index + 1])[0]} \
        --k3s-version ${var.k3s_version} \
        --no-extras \
        --server \
        --server-ip ${split("/", var.vm_ipv4[0])[0]} \
        --tls-san ${var.kube_vip} \
        --tls-san ${var.kube_fqdn} \
        --user ${var.vm_user} \
        --ssh-key ${path.cwd}/.ssh_private_key
    EOT
    
  }
  depends_on = [null_resource.k3s_kube_vip_configmap]
}
