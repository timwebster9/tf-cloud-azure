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

resource "azurerm_container_app" "nginx" {
  name                         = "nginx"
  container_app_environment_id = azurerm_container_app_environment.containerapp.id
  resource_group_name          = azurerm_resource_group.containerapp_rg.name
  revision_mode                = "Single"

  template {
    container {
      name   = "nginx"
      image  = "docker.io/nginx:1-alpine"
      cpu    = 0.5
      memory = "1Gi"

      env {
        name = "RUST_LOG"
        value = "warn"
      }
    }
  }

  ingress {
    allow_insecure_connections = false
    external_enabled = true
    target_port = 1236

    traffic_weight {
      percentage = 100
    }
  }
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
      cpu    = 0.5
      memory = "1Gi"

      env {
        name = "LEMMY_UI_LEMMY_INTERNAL_HOST"
        value = "lemmy:8536"
      }
      env {
        name = "LEMMY_UI_LEMMY_EXTERNAL_HOST"
        value = ""
      }
      env {
        name = "LEMMY_UI_HTTPS"
        value = "true"
      }
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
      cpu    = 0.5
      memory = "1Gi"

      env {
        name = "RUST_LOG"
        value = "warn"
      }
    }
  }
}

resource "azurerm_container_app" "pictrs" {
  name                         = "pictrs"
  container_app_environment_id = azurerm_container_app_environment.containerapp.id
  resource_group_name          = azurerm_resource_group.containerapp_rg.name
  revision_mode                = "Single"

  template {
    container {
      name   = "pictrs"
      image  = "asonix/pictrs:0.4.0-rc.7"
      cpu    = 0.25
      memory = "0.5Gi"

      env {
        name = "PICTRS_OPENTELEMETRY_URL"
        value = "http://otel:4137"
      }
      env {
        name = "PICTRS__API_KEY"
        value = "postgres_password"
      }
      env {
        name = "RUST_LOG"
        value = "debug"
      }
      env {
        name = "RUST_BACKTRACE"
        value = "full"
      }
      env {
        name = "PICTRS__MEDIA__VIDEO_CODEC"
        value = "vp9"
      }
      env {
        name = "PICTRS__MEDIA__GIF__MAX_WIDTH"
        value = "256"
      }
      env {
        name = "PICTRS__MEDIA__GIF__MAX_HEIGHT"
        value = "256"
      }
      env {
        name = "PICTRS__MEDIA__GIF__MAX_AREA"
        value = "65536"
      }
      env {
        name = "PICTRS__MEDIA__GIF__MAX_FRAME_COUNT"
        value = "400"
      }
    }
  }
}