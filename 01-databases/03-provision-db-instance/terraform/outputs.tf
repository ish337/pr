output "vm_id" {
  value = proxmox_virtual_environment_vm.db.vm_id
}

output "ssh" {
  value       = "ssh ubuntu@${var.vm_ip}"
  description = "Run 'cloud-init status --wait' there, PostgreSQL is ready when it says done"
}

output "db_connection" {
  value = {
    host     = var.vm_ip
    port     = 5432
    database = var.db_name
    user     = var.db_user
  }
  description = "Connection settings for a DB client such as DBeaver, the password is db_password"
}
