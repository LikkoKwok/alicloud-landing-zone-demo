terraform {
  required_version = ">= 1.5.0"
  required_providers {
    alicloud = {
      source  = "hashicorp/alicloud"
      version = "~> 1.200"
    }
  }
  # Bootstrap uses local state file to build the remote home
  backend "local" {}
}


provider "alicloud" {
  region = var.region
}