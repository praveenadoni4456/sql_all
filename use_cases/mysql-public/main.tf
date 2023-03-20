
provider "google" {
  version = "~> 3.22"
}

provider "null" {
  version = "~> 2.1"
}

provider "random" {
  version = "~> 2.2"
}

resource "random_id" "name" {
  byte_length = 2
}

module "mysql-db" {
  source               = "../../modules/mysql"
  name                 = var.db_name
  random_instance_name = true
  database_version     = "MYSQL_5_6"
  project_id           = var.project_id
  zone                 = "us-central1-c"
  region               = "us-central1"
  tier                 = "db-n1-standard-1"

  deletion_protection = false

  ip_configuration = {
    ipv4_enabled        = true
    private_network     = null
    require_ssl         = true
    authorized_networks = var.authorized_networks
  }


  database_flags = [
    {
      name  = "log_bin_trust_function_creators"
      value = "on"
    },
  ]
}

