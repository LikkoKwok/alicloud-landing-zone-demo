resource "alicloud_resource_manager_resource_directory" "rd" {
  status = "Enabled"
}

resource "alicloud_resource_manager_folder" "management" {
  folder_name      = "Management-OU"
  parent_folder_id = alicloud_resource_manager_resource_directory.rd.root_folder_id
}

resource "alicloud_resource_manager_folder" "core_insurance" {
  folder_name      = "Core-Insurance-OU"
  parent_folder_id = alicloud_resource_manager_resource_directory.rd.root_folder_id
}

resource "alicloud_resource_manager_folder" "ai_lab" {
  folder_name      = "AI-Innovation-Lab-OU"
  parent_folder_id = alicloud_resource_manager_resource_directory.rd.root_folder_id
}

locals {
  insurance_envs = ["prod", "preprod", "uat", "sit"]
  ai_accounts    = ["ai-training", "ai-inference"]
}

resource "alicloud_resource_manager_account" "insurance" {
  for_each     = toset(local.insurance_envs)
  display_name = "core-insurance-${each.key}"
  folder_id    = alicloud_resource_manager_folder.core_insurance.id
}

resource "alicloud_resource_manager_account" "ai" {
  for_each     = toset(local.ai_accounts)
  display_name = each.key
  folder_id    = alicloud_resource_manager_folder.ai_lab.id
}

# Control Policy: forbid deletion of central log store (Requirement 6)
resource "alicloud_resource_manager_control_policy" "protect_logs" {
  control_policy_name = "deny-logstore-deletion"
  description         = "Prevents deletion of central audit logs"
  effect_scope        = "RAM"
  policy_document = jsonencode({
    Version = "1"
    Statement = [{
      Effect   = "Deny"
      Action   = ["log:DeleteLogStore", "log:DeleteProject"]
      Resource = "*"
    }]
  })
}

resource "alicloud_resource_manager_control_policy_attachment" "root" {
  policy_id = alicloud_resource_manager_control_policy.protect_logs.id
  target_id = alicloud_resource_manager_resource_directory.rd.root_folder_id
}

# Control Policy: deny disabling ActionTrail
resource "alicloud_resource_manager_control_policy" "protect_trail" {
  control_policy_name = "deny-actiontrail-stop"
  description         = "Prevents stopping or deleting ActionTrail"
  effect_scope        = "RAM"
  policy_document = jsonencode({
    Version = "1"
    Statement = [{
      Effect   = "Deny"
      Action   = ["actiontrail:DeleteTrail", "actiontrail:StopLogging"]
      Resource = "*"
    }]
  })
}

resource "alicloud_resource_manager_control_policy_attachment" "trail_root" {
  policy_id = alicloud_resource_manager_control_policy.protect_trail.id
  target_id = alicloud_resource_manager_resource_directory.rd.root_folder_id
}

resource "alicloud_resource_manager_account" "hub" {
  count       = 1
  display_name = "hub-account"
}

resource "alicloud_resource_manager_account" "log" {
  count       = 1
  display_name = "log-account"
}

resource "alicloud_resource_manager_account" "app" {
  count       = 1
  display_name = "app-account"
}

resource "alicloud_resource_manager_account" "ai_lab" {
  count       = 1
  display_name = "ai-lab-account"
}