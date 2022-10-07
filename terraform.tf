terraform {

  cloud {
    organization = "fstfctest"

    workspaces {
      name = "tf-cloud-azure"
    }
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.26.0"
    }
  }

  required_version = ">= 1.2.8"
}

provider "azurerm" {
  features {}
}