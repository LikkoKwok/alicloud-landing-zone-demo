output "resource_directory_id" {
  value = alicloud_resource_manager_resource_directory.rd.id
}

output "root_folder_id" {
  value = alicloud_resource_manager_resource_directory.rd.root_folder_id
}

output "insurance_account_ids" {
  value = { for k, a in alicloud_resource_manager_account.insurance : k => a.id }
}

output "ai_account_ids" {
  value = { for k, a in alicloud_resource_manager_account.ai : k => a.id }
}


output "hub_account_id" {
  description = "Hub Security member account ID"
  value       = alicloud_resource_manager_account.hub[0].id
}

output "log_account_id" {
  description = "Logging member account ID"
  value       = alicloud_resource_manager_account.log[0].id
}

output "app_account_id" {
  description = "Core Insurance App member account ID"
  value       = alicloud_resource_manager_account.app[0].id
}

output "ai_lab_account_id" {
  description = "AI Lab member account ID"
  value       = alicloud_resource_manager_account.ai_lab[0].id
}