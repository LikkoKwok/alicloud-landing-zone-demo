variable "environment"      { type = string }
variable "environment_prefix" {
  description = "Prefix for naming resources (e.g., 'demo', 'prod')"
  type        = string
}

variable "vpc_cidr" {
  description = "DEPRECATED: Use core_insurance_vpc_cidr instead"
  type        = string
  default     = null
}

variable "core_insurance_vpc_cidr" {
  description = "CIDR block for Core Insurance VPC. Must be /16 to accommodate 4 environments"
  type        = string
  default     = "10.1.0.0/16"
  
  validation {
    condition     = can(regex("^10\\.([0-9]{1,3})\\.0\\.0/16$", var.core_insurance_vpc_cidr))
    error_message = "CIDR must be a /16 block in 10.x.0.0/16 format (e.g., 10.1.0.0/16)"
  }
}


variable "transit_router" {
  description = "CEN Transit Router ID for VPC attachment"
  type        = string
}

variable "cen_id" {
  description = "CEN instance ID"
  type        = string
  default     = ""
}

variable "kms_key_id" {
  description = "KMS key ID for encryption at rest"
  type        = string
}

variable "db_instance_class" {
  description = "RDS instance class for SQL Server"
  type        = string
  default     = "rds.mssql.s2.large"
}

variable "db_storage_gb" {
  description = "Database storage in GB"
  type        = number
  default     = 50
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}

variable "palo_alto_trust_eni_id" {
  description = "ENI ID of Palo Alto's Trust interface for traffic inspection"
  type        = string
  default     = ""
}

# assume 10.0.0.0/8 as the internal network for admin access to CyberArk and bastion host, can be adjusted as needed
variable "admin_source_cidr" {
  description = "CIDR block allowed to access CyberArk PVWA (HTTPS) and SSH"
  type        = string
}

# validate CIDR is /16
locals {
  effective_cidr = var.core_insurance_vpc_cidr != "" ? var.core_insurance_vpc_cidr : var.vpc_cidr
}