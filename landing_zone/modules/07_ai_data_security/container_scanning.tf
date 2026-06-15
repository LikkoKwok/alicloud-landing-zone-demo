# ============================================
# CONTAINER IMAGE SCANNING ENFORCEMENT
# Note: Use ACR Enterprise with built-in scanning
# ============================================

# Valid instance_type values: Basic, Standard, Advanced (not Enterprise)
resource "alicloud_cr_ee_instance" "acr" {
  count          = var.enable_container_scanning ? 1 : 0
  instance_name  = "ai-acr-${var.environment}"
  instance_type  = "Standard"  # Changed from "Enterprise"
  payment_type   = "Subscription"
}

# Note: Vulnerability scanning is enabled automatically on ACR EE