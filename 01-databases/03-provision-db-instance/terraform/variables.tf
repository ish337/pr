// Proxmox API
variable "proxmox_endpoint" {
  type        = string
  description = "Proxmox API URL, e.g. https://192.168.1.10:8006/"
}

variable "proxmox_api_token" {
  type        = string
  description = "API token as user@realm!tokenid=secret"
  sensitive   = true
}

variable "proxmox_insecure" {
  type        = bool
  description = "Skip TLS verification, true for the node's default self-signed certificate"
  default     = true
}

variable "proxmox_ssh_user" {
  type        = string
  description = "SSH user on the node, used to upload the cloud-init snippet"
  default     = "root"
}

variable "proxmox_ssh_key_file" {
  type        = string
  description = "Private key without a passphrase for SSH to the node, e.g. ~/.ssh/proxmox_tf, leave empty to use ssh-agent"
  default     = ""
}

// Where the VM goes
variable "node_name" {
  type    = string
  default = "pve"
}

variable "vm_datastore" {
  type        = string
  description = "Storage for the VM disk and the cloud-init drive"
  default     = "local-lvm"
}

variable "files_datastore" {
  type        = string
  description = "Storage for the Ubuntu image and the cloud-init snippet, needs the import and snippets content types"
  default     = "local"
}

variable "network_bridge" {
  type    = string
  default = "vmbr0"
}

variable "ubuntu_image_url" {
  type    = string
  default = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
}

// VM
variable "vm_name" {
  type    = string
  default = "pg-db"
}

variable "cores" {
  type    = number
  default = 2
}

variable "memory" {
  type        = number
  description = "MB"
  default     = 2048
}

variable "disk_size" {
  type        = number
  description = "GB"
  default     = 10
}

variable "ssh_public_key" {
  type        = string
  description = "Public key for the default ubuntu user"
}

// Network, a static IP so clients know where the DB is
variable "vm_ip" {
  type = string

  validation {
    condition     = can(cidrhost("${var.vm_ip}/32", 0))
    error_message = "vm_ip must be an IPv4 address, e.g. 192.168.1.60."
  }
}

variable "subnet_prefix" {
  type    = number
  default = 24
}

variable "gateway" {
  type = string
}

variable "dns_servers" {
  type    = list(string)
  default = ["1.1.1.1", "8.8.8.8"]
}

// Database
variable "db_name" {
  type    = string
  default = "appdb"
}

variable "db_user" {
  type        = string
  description = "Application role: connect + read/write data, can't create databases or change the schema"
  default     = "app_user"
}

variable "db_password" {
  type        = string
  description = "Password for db_user"
  sensitive   = true

  validation {
    condition     = length(var.db_password) >= 12
    error_message = "db_password must be at least 12 characters."
  }
}

// Sample database loaded into db_name: Northwind (customers, orders, products, ...)
variable "sample_data_url" {
  type    = string
  default = "https://raw.githubusercontent.com/pthom/northwind_psql/master/northwind.sql"
}
