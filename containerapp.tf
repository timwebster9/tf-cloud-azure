resource "azurerm_log_analytics_workspace" "containerapp_ws" {
  name                = "containerapp-ws"
  location            = azurerm_resource_group.containerapp_rg.location
  resource_group_name = azurerm_resource_group.containerapp_rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_container_app_environment" "containerapp_env" {
  name                       = "capp-01"
  location                   = azurerm_resource_group.containerapp_rg.location
  resource_group_name        = azurerm_resource_group.containerapp_rg.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.containerapp_ws.id
  infrastructure_subnet_id   = azurerm_subnet.containerapp_subnet.id
}

/*
data "azurerm_user_assigned_identity" "acr_mi" {
  name                = "acr-mi"
  resource_group_name = "acr-rg"
}
*/

resource "azurerm_container_app" "nginx" {
  name                         = "nginx"
  container_app_environment_id = azurerm_container_app_environment.containerapp_env.id
  resource_group_name          = azurerm_resource_group.containerapp_rg.name
  revision_mode                = "Single"

  identity {
    type = "SystemAssigned"
  }

  template {

    min_replicas = 1
    max_replicas = 1

    container {
      name   = "nginx"
      image  = var.nginx_image
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
    target_port = 8536

    traffic_weight {
      percentage = 100
      latest_revision = true
    }
  }
}

resource "azurerm_container_app" "lemmy_ui" {
  name                         = "lemmy-ui"
  container_app_environment_id = azurerm_container_app_environment.containerapp_env.id
  resource_group_name          = azurerm_resource_group.containerapp_rg.name
  revision_mode                = "Single"

  template {

    min_replicas = 1
    max_replicas = 1

    container {
      name   = "lemmy-ui"
      image  = var.lemmy_ui_image
      cpu    = 0.5
      memory = "1Gi"

      env {
        name = "LEMMY_UI_LEMMY_INTERNAL_HOST"
        value = "lemmy:8536"
      }
      env {
        name = "LEMMY_UI_LEMMY_EXTERNAL_HOST"
        value = "feddit.deggymacets.com"
      }
      env {
        name = "LEMMY_UI_HTTPS"
        value = "false"
      }
    }
  }

  ingress {
    allow_insecure_connections = true
    target_port = 1234

    traffic_weight {
      percentage = 100
      latest_revision = true
    }
  }
}

resource "azurerm_container_app" "lemmy" {
  name                         = "lemmy"
  container_app_environment_id = azurerm_container_app_environment.containerapp_env.id
  resource_group_name          = azurerm_resource_group.containerapp_rg.name
  revision_mode                = "Single"

  template {

    min_replicas = 1
    max_replicas = 1

    container {
      name   = "lemmy"
      image  = var.lemmy_image
      cpu    = 0.5
      memory = "1Gi"

      env {
        name = "RUST_LOG"
        value = "warn"
      }
      env {
        name = "LEMMY_DATABASE_URL"
        secret_name = "pgconnectionstring"
      }
    }
  }

  secret {
    name = "pgconnectionstring"
    value = var.pgconnectionstring
  }

  ingress {
    allow_insecure_connections = true
    target_port = 8536

    traffic_weight {
      percentage = 100
      latest_revision = true
    }
  }

}

/*
resource "azurerm_container_app" "postgres" {
  name                         = "postgres"
  container_app_environment_id = azurerm_container_app_environment.containerapp_env.id
  resource_group_name          = azurerm_resource_group.containerapp_rg.name
  revision_mode                = "Single"

  template {
    container {
      name   = "postgres"
      image  = "docker.io/postgres:15-alpine"
      cpu    = 0.5
      memory = "1Gi"

      env {
        name = "POSTGRES_USER"
        value = "lemmy"
      }
      env {
        name = "POSTGRES_PASSWORD"
        value = "lemmy"
      }
      env {
        name = "POSTGRES_DB"
        value = "lemmy"
      }
    }
  }

  ingress {
    allow_insecure_connections = true
    target_port = 5432

    traffic_weight {
      percentage = 100
      latest_revision = true
    }
  }
}

*/

/*
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
*/