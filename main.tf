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

resource "azurerm_container_app" "ui" {
  name                         = "ui"
  container_app_environment_id = azurerm_container_app_environment.containerapp.id
  resource_group_name          = azurerm_resource_group.containerapp_rg.name
  revision_mode                = "Single"

  template {
    container {
      name   = "ui"
      image  = "docker.io/dessalines/lemmy-ui:0.18.1"
      cpu    = 0.25
      memory = "0.5Gi"

      env {
        name = "LEMMY_UI_LEMMY_INTERNAL_HOST"
        value = "lemmy:8536"
      }
    }
  }

  ingress {
    allow_insecure_connections = false
    external_enabled = true
    target_port = 80

    traffic_weight {
      percentage = 100
    }
  }
}

resource "azurerm_container_app" "server" {
  name                         = "server"
  container_app_environment_id = azurerm_container_app_environment.containerapp.id
  resource_group_name          = azurerm_resource_group.containerapp_rg.name
  revision_mode                = "Single"

  template {
    container {
      name   = "server"
      image  = "docker.io/dessalines/lemmy:0.18.1"
      cpu    = 0.25
      memory = "0.5Gi"

      env {
        name = "LEMMY_UI_LEMMY_INTERNAL_HOST"
        value = "lemmy:8536"
      }
    }
  }
}