# Use the correct resource names from your main.tf
output "bastion_private_ip" {
  value = alicloud_instance.cyberark_pvwa.private_ip  # Changed from cyberark to cyberark_pvwa
}

output "bastion_security_group_id" {
  value = alicloud_security_group.cyberark_pvwa.id  # Changed from cyberark to cyberark_pvwa
}

# Optional: add vault outputs
output "vault_private_ip" {
  value = alicloud_instance.cyberark_vault.private_ip
}

output "vault_security_group_id" {
  value = alicloud_security_group.cyberark_vault.id
}