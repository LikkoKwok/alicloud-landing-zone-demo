variable "vpc_id"           { type = string }
variable "environment"      { type = string }
variable "ops_vswitch_id"   { type = string }

variable "instance_type"    {
    type = string
    default = "ecs.g6.large"
    }

variable "image_id"         { 
    type = string
    default = "aliyun_3_x64_20G_alibase_20240528.vhd"
    }


variable "tags"             { 
    type = map(string)
    default = {}
    }

# assume 10.0.0.0/8 as the internal network for admin access to CyberArk and bastion host, can be adjusted as needed
variable "admin_source_cidr" {
  description = "CIDR block allowed to access CyberArk PVWA (HTTPS) and SSH"
  type        = string
}