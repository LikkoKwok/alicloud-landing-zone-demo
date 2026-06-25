output "vpc_id" {
  value = alicloud_vpc.shared_service.id
}

output "vpc_cidr" {
  value = alicloud_vpc.shared_service.cidr_block
}

output "unified_ingress_slb_id" {
  value = alicloud_slb_load_balancer.unified_ingress.id
}

output "ai_gateway_security_group_id" {
  value = alicloud_security_group.ai_gateway_sg.id
}

# uncomment if using cyberark instances for demo purposes
# output "pvwa_instance_id" {
#   value = alicloud_instance.cyberark_pvwa.id
# }

# output "vault_instance_id" {
#   value = alicloud_instance.cyberark_vault.id
# }

output "shared_service_vpc_attachment_id" {
  value = alicloud_cen_transit_router_vpc_attachment.shared_service.id
}
