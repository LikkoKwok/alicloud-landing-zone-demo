# landing_zone/providers.tf
provider "alicloud" {
  alias  = "master"
  region = var.region
}

provider "alicloud" {
  alias  = "singapore"
  region = var.secondary_region
}

provider "alicloud" {
  alias  = "hub"
  region = var.region
}

provider "alicloud" {
  alias  = "log"
  region = var.region
}

provider "alicloud" {
  alias  = "app"
  region = var.region
}

provider "alicloud" {
  alias  = "ai"
  region = var.region
}