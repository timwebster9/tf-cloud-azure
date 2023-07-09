resource "azurerm_postgresql_flexible_server" "postgres" {
  name                   = "lemmyserver"
  resource_group_name    = azurerm_resource_group.containerapp_rg.name
  location               = azurerm_resource_group.containerapp_rg.location
  version                = "15"
  administrator_login    = var.db_username
  administrator_password = var.db_password
  storage_mb             = 32768
  sku_name               = "B_Standard_B1ms"
}

resource "azurerm_postgresql_flexible_server_database" "lemmy_db" {
  name      = "lemmy"
  server_id = azurerm_postgresql_flexible_server.postgres.id
  collation = "en_US.utf8"
  charset   = "utf8"
}