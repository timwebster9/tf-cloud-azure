resource "azurerm_resource_group" "containerapp_rg" {
  name     = "containerapp-rg"
  location = var.location
}

resource "azurerm_log_analytics_workspace" "containerapp_ws" {
  name                = "containerapp-ws"
  location            = azurerm_resource_group.containerapp_rg.location
  resource_group_name = azurerm_resource_group.containerapp_rg.name
  sku                 = "Free"
  retention_in_days   = 7
}