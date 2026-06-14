# ============================================
# CONTAINER IMAGE SCANNING ENFORCEMENT
# Requirement: All AI training and inference images must be scanned
# for vulnerabilities before deployment
# ============================================

resource "alicloud_cr_ee_instance" "acr" {
  count          = var.enable_container_scanning ? 1 : 0
  instance_name  = "ai-acr-${var.environment}"
  instance_type  = "Enterprise"
  payment_type   = "Subscription"
}

resource "alicloud_cr_ee_vulnerability_scanning" "scan" {
  count        = var.enable_container_scanning ? 1 : 0
  instance_id  = alicloud_cr_ee_instance.acr[0].id
  scan_engine  = "Trivy"
}

# Security Hub integration to enforce blocking of vulnerable images
resource "alicloud_security_center_scan_config" "container" {
  count          = var.enable_container_scanning ? 1 : 0
  scan_type      = "image"
  target_account = "all"
}