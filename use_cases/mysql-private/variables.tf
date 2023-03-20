

variable "project_id" {
  type        = string
  description = "The project to run tests against"
}

variable "network_name" {
  default = "mysql-privat"
  type    = string
}

variable "db_name" {
  description = "The name of the SQL Database instance"
  default     = "example-mysql-private"
}

