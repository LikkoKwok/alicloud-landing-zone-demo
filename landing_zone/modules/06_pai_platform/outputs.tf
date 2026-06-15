output "ai_vpc_id"             { value = alicloud_vpc.ai.id }
output "ack_cluster_id"        { value = alicloud_cs_managed_kubernetes.gpu.id }
output "claims_rg_id"          { value = alicloud_resource_manager_resource_group.claims.id }
output "actuarial_rg_id"       { value = alicloud_resource_manager_resource_group.actuarial.id }
output "training_bucket"       { value = alicloud_oss_bucket.training_data.bucket }
output "inference_vswitch_id"  { value = alicloud_vswitch.inference.id }