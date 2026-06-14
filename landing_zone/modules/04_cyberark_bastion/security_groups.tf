# ============================================
# CYBERARK PROPER SECURITY GROUP RULES
# Requirement: PVWA on port 443, Vault on port 1858
# Only PVWA can communicate with Vault
# ============================================

# Security group for PVWA (web interface)
resource "alicloud_security_group" "cyberark_pvwa" {
  security_group_name = "cyberark-pvwa-sg-${var.environment}"
  vpc_id              = var.vpc_id
  description         = "CyberArk PVWA - web interface for PAM access"
  tags                = merge(var.tags, { Role = "CyberArk-PVWA" })
}

# Security group for Vault (credential storage)
resource "alicloud_security_group" "cyberark_vault" {
  security_group_name = "cyberark-vault-sg-${var.environment}"
  vpc_id              = var.vpc_id
  description         = "CyberArk Vault - secured credential storage"
  tags                = merge(var.tags, { Role = "CyberArk-Vault" })
}

# PVWA inbound: HTTPS from admin sources
resource "alicloud_security_group_rule" "pvwa_https_in" {
  type              = "ingress"
  ip_protocol       = "tcp"
  port_range        = "443/443"
  security_group_id = alicloud_security_group.cyberark_pvwa.id
  cidr_ip           = var.admin_source_cidr
  description       = "HTTPS access to PVWA from admin network"
}

# PVWA inbound: SSH from admin sources
resource "alicloud_security_group_rule" "pvwa_ssh_in" {
  type              = "ingress"
  ip_protocol       = "tcp"
  port_range        = "22/22"
  security_group_id = alicloud_security_group.cyberark_pvwa.id
  cidr_ip           = var.admin_source_cidr
  description       = "SSH access to PVWA for management"
}

# PVWA outbound to Vault on port 1858 (CyberArk proprietary protocol)
resource "alicloud_security_group_rule" "pvwa_to_vault" {
  type                     = "egress"
  ip_protocol              = "tcp"
  port_range               = "1858/1858"
  security_group_id        = alicloud_security_group.cyberark_pvwa.id
  source_security_group_id = alicloud_security_group.cyberark_vault.id
  description              = "PVWA to Vault communication on CyberArk port 1858"
}

# Vault inbound from PVWA only
resource "alicloud_security_group_rule" "vault_from_pvwa" {
  type                     = "ingress"
  ip_protocol              = "tcp"
  port_range               = "1858/1858"
  security_group_id        = alicloud_security_group.cyberark_vault.id
  source_security_group_id = alicloud_security_group.cyberark_pvwa.id
  description              = "Allow Vault connections only from PVWA"
}

# Vault outbound to managed targets (SSH/RDP)
resource "alicloud_security_group_rule" "vault_to_targets" {
  type              = "egress"
  ip_protocol       = "tcp"
  port_range        = "22/22"
  security_group_id = alicloud_security_group.cyberark_vault.id
  cidr_ip           = "10.0.0.0/8"
  description       = "Vault SSH to managed targets"
}

resource "alicloud_security_group_rule" "vault_to_targets_rdp" {
  type              = "egress"
  ip_protocol       = "tcp"
  port_range        = "3389/3389"
  security_group_id = alicloud_security_group.cyberark_vault.id
  cidr_ip           = "10.0.0.0/8"
  description       = "Vault RDP to managed Windows targets"
}