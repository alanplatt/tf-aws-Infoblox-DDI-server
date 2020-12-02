output "infoblox_mgmt_ip" {
  value       = var.include_public_ip == true ? aws_eip.infoblox_mgmt_ip[0].public_ip : ""
  description = "The public IP address of the Infoblox mgmt console."
}

output "infoblox_admin_password" {
  value       = var.admin_password != "" ? var.admin_password : random_password.admin_password.result
  description = "The admin password for the Infoblox mgmt console."
}