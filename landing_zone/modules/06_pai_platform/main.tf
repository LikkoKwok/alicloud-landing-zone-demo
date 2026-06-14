data "alicloud_zones" "gpu" {
  available_instance_type = var.gpu_instance_type
  available_disk_category = "cloud_essd"
}

# Dedicated VPC for AI workloads with 3 segments
# Change from hardcoded 10.30.0.0/16 to variable
resource "alicloud_vpc" "ai" {
  vpc_name   = "${var.environment}-ai-vpc"
  cidr_block = var.ai_lab_vpc_cidr  # Add this variable
  tags       = merge(var.tags, { Workload = "AI" })
}

# Update subnet CIDRs using cidrsubnet relative to the new /16
resource "alicloud_vswitch" "data" {
  vpc_id       = alicloud_vpc.ai.id
  cidr_block   = cidrsubnet(var.ai_lab_vpc_cidr, 8, 1)   # 10.2.1.0/24
  zone_id      = data.alicloud_zones.gpu.zones[0].id
  vswitch_name = "${var.environment}-ai-data"
  tags         = var.tags
}

resource "alicloud_vswitch" "training" {
  vpc_id       = alicloud_vpc.ai.id
  cidr_block   = cidrsubnet(var.ai_lab_vpc_cidr, 8, 2)   # 10.2.2.0/24 (RDMA ready)
  zone_id      = data.alicloud_zones.gpu.zones[0].id
  vswitch_name = "${var.environment}-ai-training-rdma"
  tags         = merge(var.tags, { Network = "RDMA" })
}

resource "alicloud_vswitch" "inference" {
  vpc_id       = alicloud_vpc.ai.id
  cidr_block   = cidrsubnet(var.ai_lab_vpc_cidr, 8, 3)   # 10.2.3.0/24
  zone_id      = data.alicloud_zones.gpu.zones[0].id
  vswitch_name = "${var.environment}-ai-inference"
  tags         = var.tags
}

# Workspace-level Resource Groups (Claims vs Actuarial isolation)
resource "alicloud_resource_manager_resource_group" "claims" {
  resource_group_name = "rg-ai-claims-${var.environment}"
  display_name        = "AI-Claims-${var.environment}"
}

resource "alicloud_resource_manager_resource_group" "actuarial" {
  resource_group_name = "rg-ai-actuarial-${var.environment}"
  display_name        = "AI-Actuarial-${var.environment}"
}

# ACK managed Kubernetes cluster for GPU training
resource "alicloud_cs_managed_kubernetes" "gpu" {
  name               = "${var.environment}-gpu-ack"
  vswitch_ids = [alicloud_vswitch.training.id]
  pod_cidr           = "172.20.0.0/16"
  service_cidr       = "172.21.0.0/20"
  new_nat_gateway    = false
  tags               = var.tags
}

# GPU node pool with auto-scaling (dynamic GPU allocation)
resource "alicloud_cs_kubernetes_node_pool" "gpu_pool" {
  cluster_id    = alicloud_cs_managed_kubernetes.gpu.id
  node_pool_name = "gpu-autoscale"
  vswitch_ids   = [alicloud_vswitch.training.id]
  instance_types = [var.gpu_instance_type]

  scaling_config {
    enable   = true
    min_size = 0
    max_size = var.gpu_max_nodes
  }
  system_disk_category = "cloud_essd"
  tags                 = merge(var.tags, { Network = "eRDMA" })
}

# Encrypted OSS for training datasets and model artifacts
resource "alicloud_oss_bucket" "training_data" {
  bucket = "ai-training-data-${var.environment}"
  tags   = merge(var.tags, { DataClass = "sensitive" })
}

resource "alicloud_oss_bucket_server_side_encryption" "training_enc" {
  bucket            = alicloud_oss_bucket.training_data.bucket
  sse_algorithm     = "KMS"
  kms_master_key_id = var.kms_key_id
}
