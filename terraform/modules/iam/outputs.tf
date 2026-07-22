# terraform/modules/iam/outputs.tf

output "service_account_emails" {
  description = "Map of workload keys to their Service Account emails."
  value       = { for k, v in google_service_account.this : k => v.email }
}
