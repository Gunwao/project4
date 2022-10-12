terraform {
  backend "azurerm" {
    resource_group_name  = "tfstateRG01"
    storage_account_name = "tfstate01back134"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}