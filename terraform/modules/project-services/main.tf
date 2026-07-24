# terraform/modules/project-services/main.tf

variable "project_id" { type = string }
variable "required_apis" { type = list(string) }

resource "google_project_service" "this" {
  for_each = toset(var.required_apis)

  project            = var.project_id
  service            = each.value
  disable_on_destroy = false # Fails fast without breaking the project on teardown
}
