output "name" {
  description = "Name of the provisioned resource group"
  value = azurerm_resource_group.main.name
}

output "location" {
  description = "Location of the provisioned resource group"
  value = azurerm_resource_group.main.location
}
