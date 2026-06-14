# PVWA instance
resource "alicloud_instance" "cyberark_pvwa" {
  instance_name         = "cyberark-pvwa-${var.environment}"
  instance_type         = var.instance_type
  image_id              = var.image_id
  vswitch_id            = var.ops_vswitch_id
  security_groups       = [alicloud_security_group.cyberark_pvwa.id]
  system_disk_category  = "cloud_essd"
  system_disk_encrypted = true
  tags                  = merge(var.tags, { Role = "CyberArk-PVWA", Mock = "true" })
}

# Vault instance (separate, private)
resource "alicloud_instance" "cyberark_vault" {
  instance_name         = "cyberark-vault-${var.environment}"
  instance_type         = var.instance_type
  image_id              = var.image_id
  vswitch_id            = var.ops_vswitch_id
  security_groups       = [alicloud_security_group.cyberark_vault.id]
  system_disk_category  = "cloud_essd"
  system_disk_encrypted = true
  tags                  = merge(var.tags, { Role = "CyberArk-Vault", Mock = "true" })
}