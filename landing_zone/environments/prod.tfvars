region                  = "cn-hongkong"
secondary_region        = "ap-southeast-1"
environment             = "prod"

# VPC CIDR
hub_vpc_cidr            = "10.20.0.0/16"
core_insurance_vpc_cidr = "10.1.0.0/16"
ai_lab_vpc_cidr         = "10.2.0.0/16"
shared_service_vpc_cidr = "10.10.0.0/16"

# Production Level Compute Resources
az_count                = 2
enable_gpu_cluster      = true
firewall_instance_type  = "ecs.g6.large"
bastion_instance_type   = "ecs.g6.large"
gpu_instance_type       = "ecs.gn7-c12g1.3xlarge"

# Security
log_retention_days      = 1095   # 3 years requirement
management_vpc_cidr     = "10.100.0.0/16"