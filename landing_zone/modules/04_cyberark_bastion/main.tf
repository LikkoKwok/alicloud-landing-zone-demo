# ============================================
# SHARED SERVICE VPC
# Contains: Unified Ingress SLB, CyberArk, Ops Bastion, AI Gateway
# ============================================

data "alicloud_zones" "available" {
  available_resource_creation = "VSwitch"
}

# Shared Service VPC
resource "alicloud_vpc" "shared_service" {
  vpc_name   = "${var.environment}-shared-service-vpc"
  cidr_block = var.vpc_cidr
  tags       = merge(var.tags, { Service = "shared-services" })
}

# Subnets
resource "alicloud_vswitch" "unified_ingress" {
  vpc_id       = alicloud_vpc.shared_service.id
  cidr_block   = cidrsubnet(var.vpc_cidr, 8, 1)
  zone_id      = data.alicloud_zones.available.zones[0].id
  vswitch_name = "${var.environment}-unified-ingress"
  tags         = merge(var.tags, { Tier = "ingress" })
}

resource "alicloud_vswitch" "ai_gateway" {
  vpc_id       = alicloud_vpc.shared_service.id
  cidr_block   = cidrsubnet(var.vpc_cidr, 8, 10)
  zone_id      = data.alicloud_zones.available.zones[0].id
  vswitch_name = "${var.environment}-ai-gateway"
  tags         = merge(var.tags, { Tier = "ai-gateway" })
}

resource "alicloud_vswitch" "cyberark_pvwa" {
  vpc_id       = alicloud_vpc.shared_service.id
  cidr_block   = cidrsubnet(var.vpc_cidr, 8, 20)
  zone_id      = data.alicloud_zones.available.zones[0].id
  vswitch_name = "${var.environment}-cyberark-pvwa"
  tags         = merge(var.tags, { Tier = "cyberark" })
}

resource "alicloud_vswitch" "cyberark_vault" {
  vpc_id       = alicloud_vpc.shared_service.id
  cidr_block   = cidrsubnet(var.vpc_cidr, 8, 21)
  zone_id      = data.alicloud_zones.available.zones[0].id
  vswitch_name = "${var.environment}-cyberark-vault"
  tags         = merge(var.tags, { Tier = "cyberark" })
}

resource "alicloud_vswitch" "ops_bastion" {
  vpc_id       = alicloud_vpc.shared_service.id
  cidr_block   = cidrsubnet(var.vpc_cidr, 8, 30)
  zone_id      = data.alicloud_zones.available.zones[0].id
  vswitch_name = "${var.environment}-ops-bastion"
  tags         = merge(var.tags, { Tier = "ops" })
}

# ============================================
# UNIFIED INGRESS SLB
# ============================================

resource "alicloud_slb_load_balancer" "unified_ingress" {
  load_balancer_name   = "${var.environment}-unified-ingress"
  vswitch_id           = alicloud_vswitch.unified_ingress.id
  load_balancer_spec   = "slb.s2.small"
  address_type         = "intranet"
  tags                 = var.tags
}

# ============================================
# ATTACH SHARED SERVICE VPC TO CEN
# ============================================

resource "alicloud_cen_transit_router_vpc_attachment" "shared_service" {
  count             = var.cen_id != "" ? 1 : 0
  cen_id            = var.cen_id
  transit_router_id = var.transit_router_id
  vpc_id            = alicloud_vpc.shared_service.id
  zone_mappings {
    zone_id    = data.alicloud_zones.available.zones[0].id
    vswitch_id = alicloud_vswitch.unified_ingress.id
  }
}