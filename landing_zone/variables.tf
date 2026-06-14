variable "region" {
  description = "Primary Alibaba Cloud region"
  type        = string
  default     = "cn-hongkong"
}

variable "secondary_region" {
  description = "Secondary region for HK<->SG backbone"
  type        = string
  default     = "ap-southeast-1"
}

variable "environment" {
  description = "Deployment environment: demo, sit, uat, preprod, prod"
  type        = string
}

variable "hub_account_id" { type = string }
variable "log_account_id" { type = string }
variable "app_account_id" { type = string }
variable "ai_account_id"  { type = string }

variable "vpc_cidr" {
  description = "DEPRECATED: Use core_insurance_vpc_cidr"
  type        = string
  default     = null
}

variable "az_count" {
  description = "Number of availability zones to span"
  type        = number
  default     = 2
}

variable "enable_gpu_cluster" {
  description = "Toggle GPU/AI training workloads"
  type        = bool
  default     = false
}

variable "enable_cyberark" {
  description = "Deploy CyberArk PAM mock"
  type        = bool
  default     = false
}

variable "gpu_instance_type" {
  type    = string
  default = "ecs.gn7-c12g1.3xlarge"
}

variable "firewall_instance_type" {
  type    = string
  default = "ecs.g6.large"
}

variable "backbone_bandwidth_mbps" {
  type    = number
  default = 2
}

variable "azure_ad_metadata_url" {
  type    = string
  default = ""
}

variable "log_retention_days" {
  type    = number
  default = 30
}

variable "common_tags" {
  type    = map(string)
  default = {}
}

# variables added for multi-vpc design in the landing zone
variable "hub_vpc_cidr" {
  description = "CIDR for Hub Security VPC (Palo Alto, WAF, security services)"
  type        = string
  default     = "10.20.0.0/16"
}

variable "core_insurance_vpc_cidr" {
  description = "CIDR for Core Insurance VPC (4 environments)"
  type        = string
  default     = "10.1.0.0/16"
}

variable "ai_lab_vpc_cidr" {
  description = "CIDR for AI Lab VPC (training + inference)"
  type        = string
  default     = "10.2.0.0/16"
}

variable "shared_service_vpc_cidr" {
  description = "CIDR for Shared Service VPC (ingress, CyberArk, bastion)"
  type        = string
  default     = "10.10.0.0/16"
}

variable "logging_vpc_cidr" {
  description = "CIDR for Logging VPC (central SLS)"
  type        = string
  default     = "10.30.0.0/16"
}

# Keep but rename the old one for backward compatibility
variable "vpc_cidr" {
  description = "DEPRECATED: Use core_insurance_vpc_cidr instead"
  type        = string
  default     = "10.1.0.0/16"
}

# assume 10.0.0.0/8 as the internal network for admin access to CyberArk and bastion host
variable "admin_source_cidr" {
  description = "CIDR block allowed to access CyberArk PVWA (HTTPS) and SSH"
  type        = string
  default     = "10.0.0.0/8"  # Default to internal network, change as needed or for demo
}