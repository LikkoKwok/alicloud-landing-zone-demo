# ============================================
# 4 ENVIRONMENT SUBNETS (SIT / UAT / PREPROD / PROD)
# Requirement: Resources within each deployment environment
# must be fully isolated.
# ============================================

locals {
  environments = {
    sit = {
      web_cidr = cidrsubnet(var.vpc_cidr, 8, 1)
      db_cidr  = cidrsubnet(var.vpc_cidr, 8, 2)
    }
    uat = {
      web_cidr = cidrsubnet(var.vpc_cidr, 8, 11)
      db_cidr  = cidrsubnet(var.vpc_cidr, 8, 12)
    }
    preprod = {
      web_cidr = cidrsubnet(var.vpc_cidr, 8, 21)
      db_cidr  = cidrsubnet(var.vpc_cidr, 8, 22)
    }
    prod = {
      web_cidr = cidrsubnet(var.vpc_cidr, 8, 31)
      db_cidr  = cidrsubnet(var.vpc_cidr, 8, 32)
    }
  }
}

resource "alicloud_vswitch" "web" {
  for_each      = local.environments
  vpc_id        = alicloud_vpc.core_insurance.id
  cidr_block    = each.value.web_cidr
  zone_id       = data.alicloud_zones.available.zones[0].id
  vswitch_name  = "${var.environment}-${each.key}-web"
  tags          = merge(var.tags, { Environment = each.key, Tier = "web" })
}

resource "alicloud_vswitch" "db" {
  for_each      = local.environments
  vpc_id        = alicloud_vpc.core_insurance.id
  cidr_block    = each.value.db_cidr
  zone_id       = data.alicloud_zones.available.zones[0].id
  vswitch_name  = "${var.environment}-${each.key}-db"
  tags          = merge(var.tags, { Environment = each.key, Tier = "db" })
}