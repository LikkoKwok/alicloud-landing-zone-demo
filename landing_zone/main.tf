locals {
  base_tags = merge(var.common_tags, {
    Environment = var.environment
    ManagedBy   = "Terraform"
    Project     = "LandingZone"
  })
}

module "master_account" {
  source      = "./modules/master_account"
  environment = var.environment
  tags        = local.base_tags
  providers   = { alicloud = alicloud.master }
}

module "identity_sso" {
  source                = "./modules/identity_sso"
  azure_ad_metadata_url = var.azure_ad_metadata_url
  tags                  = local.base_tags
  providers             = { alicloud = alicloud.master }
}

module "logging_account" {
  source             = "./modules/logging_account"
  environment        = var.environment
  log_retention_days = var.log_retention_days
  tags               = local.base_tags
  providers          = { alicloud = alicloud.log }
}

module "hub_security" {
  source                  = "./modules/hub_security"
  environment             = var.environment
  region                  = var.region
  secondary_region        = var.secondary_region
  hub_vpc_cidr            = var.hub_vpc_cidr
  firewall_instance_type  = var.firewall_instance_type
  backbone_bandwidth_mbps = var.backbone_bandwidth_mbps
  az_count                = var.az_count
  tags                    = local.base_tags
  providers = {
    alicloud           = alicloud.hub
    alicloud.singapore = alicloud.singapore
  }
}

module "cyberark_bastion" {
  source        = "./modules/cyberark_bastion"
  count         = var.enable_cyberark ? 1 : 0
  vpc_id        = module.hub_security.hub_vpc_id
  ops_vswitch_id = module.hub_security.ops_vswitch_id
  tags          = local.base_tags
  providers     = { alicloud = alicloud.hub }
}

# Update core_insurance_app module to receive palo_alto_trust_eni_id
module "core_insurance_app" {
  source         = "./modules/core_insurance_app"
  environment_prefix = var.environment
  core_insurance_vpc_cidr = var.core_insurance_vpc_cidr
  transit_router = module.hub_security.transit_router_id
  cen_id         = module.hub_security.cen_id
  kms_key_id     = module.hub_security.kms_key_id
  palo_alto_trust_eni_id = module.hub_security.palo_alto_trust_eni_id
  tags           = local.base_tags
  providers      = { alicloud = alicloud.app }
}

module "pai_platform" {
  source            = "./modules/pai_platform"
  count             = var.enable_gpu_cluster ? 1 : 0
  environment       = var.environment
  ai_lab_vpc_cidr   = var.ai_lab_vpc_cidr 
  gpu_instance_type = var.gpu_instance_type
  kms_key_id        = module.hub_security.kms_key_id
  tags              = local.base_tags
  providers         = { alicloud = alicloud.ai }
}

module "ai_data_security" {
  source      = "./modules/ai_data_security"
  environment = var.environment
  kms_key_id  = module.hub_security.kms_key_id
  tags        = local.base_tags
  providers   = { alicloud = alicloud.ai }
}

module "ai_guardrails" {
  source      = "./modules/ai_guardrails"
  environment = var.environment
  tags        = local.base_tags
  providers   = { alicloud = alicloud.ai }
}

module "model_governance" {
  source      = "./modules/model_governance"
  environment = var.environment
  kms_key_id  = module.hub_security.kms_key_id
  tags        = local.base_tags
  providers   = { alicloud = alicloud.ai }
}

module "financial_governance" {
  source      = "./modules/financial_governance"
  environment = var.environment
  tags        = local.base_tags
  providers   = { alicloud = alicloud.master }
}

module "observability" {
  source        = "./modules/observability"
  environment   = var.environment
  sls_project   = module.logging_account.sls_project_name
  tags          = local.base_tags
  providers     = { alicloud = alicloud.log }
}
