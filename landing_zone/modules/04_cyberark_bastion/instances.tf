# ============================================
# CYBERARK INSTANCES
# ============================================

# PVWA Instance
resource "alicloud_instance" "cyberark_pvwa" {
  instance_name         = "${var.environment}-cyberark-pvwa"
  instance_type         = var.instance_type
  image_id              = var.image_id
  vswitch_id            = alicloud_vswitch.cyberark_pvwa.id
  security_groups       = [alicloud_security_group.cyberark_pvwa_sg.id]
  system_disk_category  = "cloud_essd"
  system_disk_encrypted = true
  tags                  = merge(var.tags, { Role = "CyberArk-PVWA", Mock = "true" })
}

# Vault Instance
resource "alicloud_instance" "cyberark_vault" {
  instance_name         = "${var.environment}-cyberark-vault"
  instance_type         = var.instance_type
  image_id              = var.image_id
  vswitch_id            = alicloud_vswitch.cyberark_vault.id
  security_groups       = [alicloud_security_group.cyberark_vault_sg.id]
  system_disk_category  = "cloud_essd"
  system_disk_encrypted = true
  tags                  = merge(var.tags, { Role = "CyberArk-Vault", Mock = "true" })
}

# Ops Bastion Instance
resource "alicloud_instance" "ops_bastion" {
  instance_name         = "${var.environment}-ops-bastion"
  instance_type         = var.instance_type
  image_id              = var.image_id
  vswitch_id            = alicloud_vswitch.ops_bastion.id
  security_groups       = [alicloud_security_group.ops_bastion_sg.id]
  system_disk_category  = "cloud_essd"
  system_disk_encrypted = true
  tags                  = merge(var.tags, { Role = "Ops-Bastion", Mock = "true" })
}