variable "environment" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "ai_lab_vpc_cidr" {
  description = "CIDR block for AI Lab VPC"
  type        = string
  default     = "10.2.0.0/16"
}

variable "hub_vpc_id" {
  description = "Hub Security VPC ID for AI Gateway placement (shared with Palo Alto)"
  type        = string
}

variable "kms_key_id" {
  description = "KMS key ID for encryption"
  type        = string
}

variable "gpu_instance_type" {
  description = "GPU instance type for AI workloads"
  type        = string
  default     = "ecs.gn6i-c4g1.xlarge"
}

variable "enable_dsw_instance" {
  description = "Enable PAI DSW instance for demo purposes"
  type        = bool
  default     = false
}

variable "transit_router_id" {
  description = "CEN Transit Router ID for VPC attachment"
  type        = string
}

variable "cen_id" {
  description = "CEN instance ID"
  type        = string
}