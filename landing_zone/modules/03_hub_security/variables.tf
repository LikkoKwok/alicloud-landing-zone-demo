variable "environment"             { type = string }
variable "region"                  { type = string }
variable "secondary_region"        { type = string }

variable "firewall_instance_type"  { 
    type = string
    default = "ecs.g6.large"
    }

variable "backbone_bandwidth_mbps" { 
    type = number
    default = 2
    }

variable "az_count" { 
    type = number
    default = 2 
    }

variable "image_id" { 
    type = string
    default = "aliyun_3_x64_20G_alibase_20240528.vhd"
    }

variable "tags" { 
    type = map(string)
    default = {} 
    }

# Add this variable
variable "hub_vpc_cidr" {
  description = "CIDR block for Hub Security VPC"
  type        = string
  default     = "10.20.0.0/16"
}

output "palo_alto_trust_eni_id" {
  value       = alicloud_instance.palo_alto[0].primary_network_interface_id
  description = "ENI ID of Palo Alto primary interface for route table next-hop"
}
