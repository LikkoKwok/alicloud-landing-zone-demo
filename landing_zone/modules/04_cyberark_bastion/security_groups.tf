# ============================================
# UNIFIED INGRESS SECURITY GROUP
# ============================================
resource "alicloud_security_group" "unified_ingress_sg" {
  vpc_id      = alicloud_vpc.shared_service.id
  security_group_name        = "${var.environment}-unified-ingress-sg"
  description = "Unified ingress load balancer security group"
  tags        = merge(var.tags, { Service = "ingress" })
}

# Inbound from Palo Alto Trust subnet only
resource "alicloud_security_group_rule" "ingress_from_palo_alto" {
  type              = "ingress"
  ip_protocol       = "tcp"
  port_range        = "443/443"
  security_group_id = alicloud_security_group.unified_ingress_sg.id
  cidr_ip           = "10.20.2.0/24"
  description       = "HTTPS from Palo Alto Trust subnet"
}

# Outbound to application VPCs
resource "alicloud_security_group_rule" "ingress_to_apps" {
  type              = "egress"
  ip_protocol       = "tcp"
  port_range        = "80/443"
  security_group_id = alicloud_security_group.unified_ingress_sg.id
  cidr_ip           = "10.0.0.0/8"
  description       = "Forward to applications in all VPCs"
}

# ============================================
# AI GATEWAY SECURITY GROUP
# ============================================
resource "alicloud_security_group" "ai_gateway_sg" {
  vpc_id      = alicloud_vpc.shared_service.id
  security_group_name         = "${var.environment}-ai-gateway-sg"
  description = "AI Gateway - API key validation, rate limiting"
  tags        = merge(var.tags, { Service = "ai-gateway" })
}

resource "alicloud_security_group_rule" "gateway_from_palo_alto" {
  type              = "ingress"
  ip_protocol       = "tcp"
  port_range        = "443/443"
  security_group_id = alicloud_security_group.ai_gateway_sg.id
  cidr_ip           = "10.20.2.0/24"
  description       = "HTTPS from Palo Alto"
}

resource "alicloud_security_group_rule" "gateway_to_claims" {
  type              = "egress"
  ip_protocol       = "tcp"
  port_range        = "8443/8443"
  security_group_id = alicloud_security_group.ai_gateway_sg.id
  cidr_ip           = "10.2.40.0/24"
  description       = "To AI Claims service"
}

resource "alicloud_security_group_rule" "gateway_to_customer_service" {
  type              = "egress"
  ip_protocol       = "tcp"
  port_range        = "8443/8443"
  security_group_id = alicloud_security_group.ai_gateway_sg.id
  cidr_ip           = "10.2.60.0/24"
  description       = "To AI Customer Service"
}

resource "alicloud_security_group_rule" "gateway_to_model_studio" {
  type              = "egress"
  ip_protocol       = "tcp"
  port_range        = "443/443"
  security_group_id = alicloud_security_group.ai_gateway_sg.id
  cidr_ip           = "0.0.0.0/0"
  description       = "To Model Studio SaaS"
}

# ============================================
# CYBERARK SECURITY GROUPS
# ============================================
resource "alicloud_security_group" "cyberark_pvwa_sg" {
  vpc_id      = alicloud_vpc.shared_service.id
  security_group_name        = "${var.environment}-cyberark-pvwa-sg"
  description = "CyberArk PVWA - web interface for PAM access"
  tags        = merge(var.tags, { Service = "cyberark" })
}

# PVWA inbound from Management Subnet only
resource "alicloud_security_group_rule" "pvwa_https_in" {
  type              = "ingress"
  ip_protocol       = "tcp"
  port_range        = "443/443"
  security_group_id = alicloud_security_group.cyberark_pvwa_sg.id
  cidr_ip           = cidrsubnet(var.management_vpc_cidr, 8, 1)  # 10.100.1.0/24
  description       = "HTTPS from management subnet"
}

resource "alicloud_security_group_rule" "pvwa_ssh_in" {
  type              = "ingress"
  ip_protocol       = "tcp"
  port_range        = "22/22"
  security_group_id = alicloud_security_group.cyberark_pvwa_sg.id
  cidr_ip           = cidrsubnet(var.management_vpc_cidr, 8, 1)  # 10.100.1.0/24
  description       = "SSH from management subnet"
}

resource "alicloud_security_group" "cyberark_vault_sg" {
  vpc_id      = alicloud_vpc.shared_service.id
  security_group_name        = "${var.environment}-cyberark-vault-sg"
  description = "CyberArk Vault - credential storage"
  tags        = merge(var.tags, { Service = "cyberark" })
}

resource "alicloud_security_group_rule" "vault_from_pvwa" {
  type                     = "ingress"
  ip_protocol              = "tcp"
  port_range               = "1858/1858"
  security_group_id        = alicloud_security_group.cyberark_vault_sg.id
  source_security_group_id = alicloud_security_group.cyberark_pvwa_sg.id
  description              = "Vault connections only from PVWA"
}

resource "alicloud_security_group_rule" "pvwa_to_vault" {
  type                     = "egress"
  ip_protocol              = "tcp"
  port_range               = "1858/1858"
  security_group_id        = alicloud_security_group.cyberark_pvwa_sg.id
  source_security_group_id = alicloud_security_group.cyberark_vault_sg.id
  description              = "PVWA to Vault communication"
}