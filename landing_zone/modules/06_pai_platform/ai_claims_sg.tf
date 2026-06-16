# ============================================
# AI CLAIMS SERVICE SECURITY GROUP
# Requirement: End-user facing AI service with API key authentication
# ============================================

resource "alicloud_security_group" "ai_claims_sg" {
  vpc_id      = alicloud_vpc.ai.id
  security_group_name        = "sg-ai-claims-service"
  description = "AI Claims service - end-user facing, API key authenticated"
  tags        = merge(var.tags, { Service = "AI-Claims", EndUser = "external" })
}

# ============================================
# INBOUND RULES (from internet via Palo Alto)
# ============================================

# REST API endpoint for claims submission
resource "alicloud_security_group_rule" "claims_api" {
  type              = "ingress"
  ip_protocol       = "tcp"
  port_range        = "8443/8443"
  security_group_id = alicloud_security_group.ai_claims_sg.id
  cidr_ip    = "10.10.1.0/24"  # AI Gateway in Shared Service VPC
  description       = "Claims API - from AI Gateway only, not directly from internet"
}

# gRPC endpoint for streaming responses (if needed)
resource "alicloud_security_group_rule" "claims_grpc" {
  type              = "ingress"
  ip_protocol       = "tcp"
  port_range        = "50051/50051"
  security_group_id = alicloud_security_group.ai_claims_sg.id
  cidr_ip    = "10.10.1.0/24"
  description       = "gRPC claims inference from AI Gateway"
}

# Health check from AI Gateway
resource "alicloud_security_group_rule" "claims_health" {
  type              = "ingress"
  ip_protocol       = "tcp"
  port_range        = "8080/8080"
  security_group_id = alicloud_security_group.ai_claims_sg.id
  cidr_ip    = "10.10.1.0/24"
  description       = "Health check from AI Gateway"
}

# ============================================
# OUTBOUND RULES (to AI platform and dependencies)
# ============================================

# Outbound to Model Studio (Alibaba Cloud AI SaaS)
resource "alicloud_security_group_rule" "claims_to_model_studio" {
  type              = "egress"
  ip_protocol       = "tcp"
  port_range        = "443/443"
  security_group_id = alicloud_security_group.ai_claims_sg.id
  cidr_ip           = "0.0.0.0/0"
  description       = "HTTPS to Model Studio / Qwen API"
}

# Outbound to OSS for document storage (encrypted)
resource "alicloud_security_group_rule" "claims_to_oss" {
  type              = "egress"
  ip_protocol       = "tcp"
  port_range        = "443/443"
  security_group_id = alicloud_security_group.ai_claims_sg.id
  cidr_ip           = "10.2.1.0/24"  # AI Data subnet (OSS VPC endpoint)
  description       = "To OSS for document retrieval"
}

# Outbound to Vector DB for RAG (retrieval-augmented generation)
resource "alicloud_security_group_rule" "claims_to_vector_db" {
  type              = "egress"
  ip_protocol       = "tcp"
  port_range        = "9200/9200"
  security_group_id = alicloud_security_group.ai_claims_sg.id
  cidr_ip    = "10.2.40.0/24"  # Claims subnet
  description       = "To OpenSearch vector DB for RAG"
}

# ============================================
# EXPLICIT DENY: No direct internet inbound
# ============================================
resource "alicloud_security_group_rule" "claims_deny_direct" {
  type              = "ingress"
  ip_protocol       = "all"
  port_range        = "-1/-1"
  security_group_id = alicloud_security_group.ai_claims_sg.id
  cidr_ip           = "0.0.0.0/0"
  policy            = "drop"
  priority          = 100
  description       = "Block direct internet access - must go through AI Gateway and Palo Alto"
}