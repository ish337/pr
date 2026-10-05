output "vm_id" {
  value = proxmox_virtual_environment_vm.monitoring.vm_id
}

output "ssh" {
  value       = "ssh ubuntu@${var.vm_ip}"
  description = "Run 'cloud-init status --wait' there, the stack is up when it says done"
}

output "grafana_url" {
  value       = "http://${var.vm_ip}:3000"
  description = "First login is admin / admin, Grafana asks to change the password"
}

output "prometheus_url" {
  value = "http://${var.vm_ip}:9090"
}
