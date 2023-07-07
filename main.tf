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

resource "azurerm_container_app" "app01" {
  name                         = "app01"
  container_app_environment_id = azurerm_container_app_environment.containerapp.id
  resource_group_name          = azurerm_resource_group.containerapp_rg.name
  revision_mode                = "Single"

  template {
    container {
      name   = "examplecontainerapp"
      image  = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
      cpu    = 0.25
      memory = "0.5Gi"
    }
  }

  ingress {
    allow_insecure_connections = true
    external_enabled = true
    target_port = 80

    traffic_weight {
      percentage = 100
    }
  }
}