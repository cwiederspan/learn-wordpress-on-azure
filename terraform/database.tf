resource "azurerm_mysql_server" "mysql" {
  name                = "${local.base_name}-mysql"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  administrator_login          = var.db_username
  administrator_login_password = var.db_password

  sku_name   = "GP_Gen5_4"
  storage_mb = 102400
  version    = "5.7"

  auto_grow_enabled                 = true
  backup_retention_days             = 7
  geo_redundant_backup_enabled      = false
  infrastructure_encryption_enabled = false
  public_network_access_enabled     = false
  ssl_enforcement_enabled           = true
  ssl_minimal_tls_version_enforced  = "TLS1_2"
}

resource "azurerm_private_endpoint" "dbpe" {
  name                = "${local.base_name}-dbpe"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  subnet_id           = azurerm_subnet.data.id

  private_service_connection {
    name                           = "${local.base_name}-dbpe"
    private_connection_resource_id = azurerm_mysql_server.mysql.id
    subresource_names              = ["mysqlServer"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "${local.base_name}-dbpe"
    private_dns_zone_ids = [azurerm_private_dns_zone.dnsdb.id]
  }
}