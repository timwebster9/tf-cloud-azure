resource "azurerm_resource_group" "containerapp_rg" {
  name     = "containerapp-rg"
  location = var.location
}

resource "azurerm_log_analytics_workspace" "containerapp_ws" {
  name                = "containerapp-ws"
  location            = azurerm_resource_group.containerapp_rg.location
  resource_group_name = azurerm_resource_group.containerapp_rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_container_app_environment" "containerapp" {
  name                       = "capp-01"
  location                   = azurerm_resource_group.containerapp_rg.location
  resource_group_name        = azurerm_resource_group.containerapp_rg.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.containerapp_ws.id
}