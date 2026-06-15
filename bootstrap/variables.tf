variable "region" {
  description = "Primary Alibaba Cloud region"
  type        = string
  default     = "cn-hongkong"
}

variable "bucket_name" {
  description = "OSS bucket name for Terraform state (must be globally unique)"
  type        = string
  default     = "oss-alicloud-sso-demo-tfstate-01"
}