# ============================================
# AI GATEWAY SECURITY GROUP
# Requirement: Centralized API key management, rate limiting, canary deployments
# Note: AI Gateway is placed in Hub Security VPC (shared with Palo Alto and Ingress)
# ============================================

resource "alicloud_security_group" "ai_gateway_sg" {
  vpc_id      = var.hub_vpc_id
  security_group_name        = "sg-ai-gateway-${var.environment}"
  description = "AI Gateway - API key validation, rate limiting, routing to AI services"
  tags        = merge(var.tags, { Service = "AI-Gateway" })
}

# ============================================
# INBOUND FROM PALO ALTO (internet traffic after inspection)
# ============================================
resource "alicloud_security_group_rule" "gateway_from_palo_alto" {
  type              = "ingress"
  ip_protocol       = "tcp"
  port_range        = "443/443"
  security_group_id = alicloud_security_group.ai_gateway_sg.id
  cidr_ip           = "10.20.2.0/24"  # Palo Alto Trust subnet
  description       = "HTTPS from Palo Alto after inspection"
}

# ============================================
# INBOUND FROM INTERNAL SERVICES (if any)
# ============================================
resource "alicloud_security_group_rule" "gateway_from_internal" {
  type              = "ingress"
  ip_protocol       = "tcp"
  port_range        = "443/443"
  security_group_id = alicloud_security_group.ai_gateway_sg.id
  cidr_ip           = "10.0.0.0/8"
  description       = "Internal service calls"
}

# ============================================
# OUTBOUND TO AI SERVICES (Claims, Customer Service, Inference)
# ============================================

# Route to AI Claims service (in AI Lab VPC)
resource "alicloud_security_group_rule" "gateway_to_claims" {
  type              = "egress"
  ip_protocol       = "tcp"
  port_range        = "8443/8443"
  security_group_id = alicloud_security_group.ai_gateway_sg.id
  cidr_ip           = "10.2.40.0/24"  # Claims subnet in AI Lab VPC
  description       = "Route to AI Claims service"
}

# Route to AI Customer Service (in AI Lab VPC)
resource "alicloud_security_group_rule" "gateway_to_customer_service" {
  type              = "egress"
  ip_protocol       = "tcp"
  port_range        = "8443/8443"
  security_group_id = alicloud_security_group.ai_gateway_sg.id
  cidr_ip           = "10.2.60.0/24"  # Customer Service subnet
  description       = "Route to AI Customer Service"
}

# Route to AI Inference endpoints
resource "alicloud_security_group_rule" "gateway_to_inference" {
  type              = "egress"
  ip_protocol       = "tcp"
  port_range        = "8080/8080"
  security_group_id = alicloud_security_group.ai_gateway_sg.id
  cidr_ip           = "10.2.30.0/24"  # Inference subnet
  description       = "Route to AI Inference services"
}

# Outbound to Alibaba Cloud Model Studio (SaaS)
resource "alicloud_security_group_rule" "gateway_to_model_studio" {
  type              = "egress"
  ip_protocol       = "tcp"
  port_range        = "443/443"
  security_group_id = alicloud_security_group.ai_gateway_sg.id
  cidr_ip           = "0.0.0.0/0"
  description       = "To Alibaba Cloud Model Studio / Qwen API"
}

# Outbound to OSS for model artifacts
resource "alicloud_security_group_rule" "gateway_to_oss" {
  type              = "egress"
  ip_protocol       = "tcp"
  port_range        = "443/443"
  security_group_id = alicloud_security_group.ai_gateway_sg.id
  cidr_ip           = "10.2.1.0/24"  # AI Data subnet (OSS VPC endpoint)
  description       = "To OSS for model storage"
}

# ============================================
# EXPLICIT DENY: No direct internet inbound
# ============================================
resource "alicloud_security_group_rule" "gateway_deny_direct" {
  type              = "ingress"
  ip_protocol       = "all"
  port_range        = "-1/-1"
  security_group_id = alicloud_security_group.ai_gateway_sg.id
  cidr_ip           = "0.0.0.0/0"
  policy            = "drop"
  priority          = 100
  description       = "Block direct internet access - must go through Palo Alto first"
}

# ============================================
# HEALTH CHECK FROM UNIFIED INGRESS (if needed)
# ============================================
resource "alicloud_security_group_rule" "gateway_health_check" {
  type              = "ingress"
  ip_protocol       = "tcp"
  port_range        = "8080/8080"
  security_group_id = alicloud_security_group.ai_gateway_sg.id
  cidr_ip           = "10.20.2.0/24"  # From Palo Alto Trust subnet
  description       = "Health check from unified ingress / Palo Alto"
}