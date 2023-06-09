

provider "google" {
  version = "~> 3.22"
}

provider "google-beta" {
  version = "~> 3.22"
}

provider "null" {
  version = "~> 2.1"
}

provider "random" {
  version = "~> 2.2"
}

resource "random_id" "suffix" {
  byte_length = 5
}

locals {
  /*
    Random instance name needed because:
    "You cannot reuse an instance name for up to a week after you have deleted an instance."
    See https://cloud.google.com/sql/docs/mysql/delete-instance for details.
  */
  network_name = "${var.network_name}-safer-${random_id.suffix.hex}"
}

module "network-safer-mysql-simple" {
  source  = "terraform-google-modules/network/google"
  version = "~> 2.5"

  project_id   = var.project_id
  network_name = local.network_name

  subnets = []
}

module "private-service-access" {
  source      = "../../modules/private_service_access"
  project_id  = var.project_id
  vpc_network = module.network-safer-mysql-simple.network_name
}

module "safer-mysql-db" {
  source               = "../../modules/safer_mysql"
  name                 = var.db_name
  random_instance_name = true
  project_id           = var.project_id

  deletion_protection = false

  database_version = "MYSQL_5_6"
  region           = "us-central1"
  zone             = "us-central1-c"
  tier             = "db-n1-standard-1"

  // By default, all users will be permitted to connect only via the
  // Cloud SQL proxy.
  additional_users = [
    {
      name     = "app"
      password = "PaSsWoRd"
      host     = "localhost"
    },
    {
      name     = "readonly"
      password = "PaSsWoRd"
      host     = "localhost"
    },
  ]

  assign_public_ip = "true"
  vpc_network      = module.network-safer-mysql-simple.network_self_link

  // Optional: used to enforce ordering in the creation of resources.
  module_depends_on = [module.private-service-access.peering_completed]
}
