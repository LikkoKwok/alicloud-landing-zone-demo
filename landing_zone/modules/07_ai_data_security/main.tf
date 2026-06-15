# Raw zone — encrypted, pre-masking
resource "alicloud_oss_bucket" "raw_zone" {
  bucket = "insurance-raw-zone-${var.environment}"
  tags   = merge(var.tags, { DataClass = "raw-pii" })
}

resource "alicloud_oss_bucket_server_side_encryption" "raw_enc" {
  bucket            = alicloud_oss_bucket.raw_zone.bucket
  sse_algorithm     = "KMS"
  kms_master_key_id = var.kms_key_id
}

# Curated zone — masked, training-ready
resource "alicloud_oss_bucket" "curated_zone" {
  bucket = "insurance-curated-zone-${var.environment}"
  tags   = merge(var.tags, { DataClass = "masked" })
}

resource "alicloud_oss_bucket_server_side_encryption" "curated_enc" {
  bucket            = alicloud_oss_bucket.curated_zone.bucket
  sse_algorithm     = "KMS"
  kms_master_key_id = var.kms_key_id
}

# DataWorks project orchestrating the PII scan + redaction job
# The display_name field has validation rules (no spaces? special chars?)
resource "alicloud_data_works_project" "dsc_pipeline" {
  project_name    = "pii_masking_${var.environment}"  # Use underscores, no hyphens
  pai_task_enabled = true
  display_name    = "PII_Masking_${var.environment}"  # Use underscores, no spaces
  description     = "Scans raw_zone, redacts PII, writes to curated_zone before training"
}

# NOTE: Sensitive Data Discovery (DSC/SDDP) classification rules are configured
# on raw_zone; the redaction task is orchestrated by the DataWorks node.
