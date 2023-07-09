resource "azurerm_postgresql_flexible_server" "postgres" {
  name                   = "lemmyserver"
  resource_group_name    = azurerm_resource_group.containerapp_rg.name
  location               = azurerm_resource_group.containerapp_rg.location
  version                = "15"
  administrator_login    = var.db_username
  administrator_password = var.db_password
  storage_mb             = 32768
  sku_name               = "B_Standard_B1ms"
  zone                   = "1"
}

resource "azurerm_postgresql_flexible_server_configuration" "postgres_config" {
  name      = "azure.extensions"
  server_id = azurerm_postgresql_flexible_server.postgres.id
  value     = "PGCRYPTO,LTREE"
}

resource "azurerm_postgresql_flexible_server_firewall_rule" "home" {
  name             = "home"
  server_id        = azurerm_postgresql_flexible_server.postgres.id
  start_ip_address = var.home_ip
  end_ip_address   = var.home_ip
}

resource "azurerm_postgresql_flexible_server_firewall_rule" "container_apps" {
  name             = "container-apps"
  server_id        = azurerm_postgresql_flexible_server.postgres.id
  start_ip_address = azurerm_container_app_environment.containerapp_env.static_ip_address
  end_ip_address   = azurerm_container_app_environment.containerapp_env.static_ip_address
}

resource "azurerm_postgresql_flexible_server_database" "lemmy_db" {
  name      = "lemmy"
  server_id = azurerm_postgresql_flexible_server.postgres.id
  collation = "en_US.utf8"
  charset   = "utf8"
}
