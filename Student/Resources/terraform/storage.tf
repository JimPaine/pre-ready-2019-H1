resource "azurerm_storage_account" "hack" {
  name                     = "${random_id.hack.dec}mondiagact"
  resource_group_name      = "${azurerm_resource_group.hack.name}"
  location                 = "${azurerm_resource_group.hack.location}"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}