variable "environment" { type = string }
variable "kms_key_id"  { type = string }
variable "tags"        { 
    type = map(string)
    default = {} 
    }

variable "enable_container_scanning" {
  description = "Enable container image vulnerability scanning for AI workloads"
  type        = bool
  default     = true
}