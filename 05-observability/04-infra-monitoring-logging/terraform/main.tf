terraform {
  required_version = ">= 1.6"

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.114"
    }
  }
}

// Snippets (cloud-init user data) are uploaded to the node over SSH,
// with the key file if set, otherwise with the key loaded in ssh-agent
provider "proxmox" {
  endpoint  = var.proxmox_endpoint
  api_token = var.proxmox_api_token
  insecure  = var.proxmox_insecure

  ssh {
    username    = var.proxmox_ssh_user
    agent       = var.proxmox_ssh_key_file == ""
    private_key = var.proxmox_ssh_key_file == "" ? null : file(pathexpand(var.proxmox_ssh_key_file))
  }
}

// Ubuntu 24.04 cloud image. The .img is qcow2 inside, the file name tells Proxmox the format for import
resource "proxmox_download_file" "ubuntu" {
  content_type = "import"
  datastore_id = var.files_datastore
  node_name    = var.node_name
  url          = var.ubuntu_image_url
  file_name    = "${var.vm_name}-noble-server-cloudimg-amd64.qcow2"
  // Don't download again when Ubuntu publishes a newer image
  overwrite = false
}

// Cloud-init: installs Docker and starts Prometheus, Loki and Grafana with docker compose
resource "proxmox_virtual_environment_file" "user_data" {
  content_type = "snippets"
  datastore_id = var.files_datastore
  node_name    = var.node_name

  source_raw {
    file_name = "${var.vm_name}.yaml"
    data = templatefile("${path.module}/files/cloud-init.yaml.tftpl", {
      hostname        = var.vm_name
      ssh_public_key  = var.ssh_public_key
      compose_b64     = filebase64("${path.module}/files/docker-compose.yml")
      prometheus_b64  = filebase64("${path.module}/files/prometheus.yml")
      loki_b64        = filebase64("${path.module}/files/loki.yml")
      datasources_b64 = filebase64("${path.module}/files/grafana-datasources.yml")
    })
  }
}

resource "proxmox_virtual_environment_vm" "monitoring" {
  name      = var.vm_name
  node_name = var.node_name
  tags      = ["monitoring", "grafana"]
  on_boot   = true

  // qemu-guest-agent is installed by cloud-init, Proxmox reads the VM's IP through it
  agent {
    enabled = true
  }

  cpu {
    cores = var.cores
    type  = "x86-64-v2-AES"
  }

  memory {
    dedicated = var.memory
  }

  disk {
    datastore_id = var.vm_datastore
    import_from  = proxmox_download_file.ubuntu.id
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    size         = var.disk_size
  }

  network_device {
    bridge = var.network_bridge
  }

  operating_system {
    type = "l26"
  }

  // Ubuntu cloud images expect a serial console
  serial_device {}

  initialization {
    datastore_id = var.vm_datastore

    ip_config {
      ipv4 {
        address = "${var.vm_ip}/${var.subnet_prefix}"
        gateway = var.gateway
      }
    }

    dns {
      servers = var.dns_servers
    }

    user_data_file_id = proxmox_virtual_environment_file.user_data.id
  }
}
