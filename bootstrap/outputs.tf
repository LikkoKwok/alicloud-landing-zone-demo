output "main_project_backend_config" {
  description = "Copy and paste this block directly into 02-main-project/providers.tf"
  value = <<EOF
  backend "oss" {
    bucket = "${alicloud_oss_bucket.tf_state_bucket.bucket}"
    prefix = "main-project/"
    key    = "terraform.tfstate"
    region = "${var.region}"
  }
EOF
}

output "bucket_name" {
  description = "Name of the created OSS bucket"
  value       = alicloud_oss_bucket.tf_state_bucket.bucket
}