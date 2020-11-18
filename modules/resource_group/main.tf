provider "azurerm" {
  version = ">=2.20.0"
  features{}
}

resource "azurerm_resource_group" "main" {
  name = var.name
  location = var.location
}
