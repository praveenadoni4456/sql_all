

variable "project_id" {
  type        = string
  description = "The project to run tests against"
}

variable "name" {
  type        = string
  description = "The name for Cloud SQL instance"
  default     = "tf-mssql-public"
}

variable "region" {
  default = "us-central1"
  type    = string
}
