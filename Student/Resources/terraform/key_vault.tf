resource "azurerm_key_vault" "hack" {
  name                = "${var.resource_name}${random_id.hack.dec}MonWorkshopVault"
  location            = "${azurerm_resource_group.hack.location}"
  resource_group_name = "${azurerm_resource_group.hack.name}"
  tenant_id           = "${data.azurerm_client_config.hack.tenant_id}"

  enabled_for_template_deployment = true

  sku {
    name = "standard"
  }
}

resource "random_string" "password" {
  length  = "32"
  special = true
}

resource "azurerm_key_vault_secret" "password" {
  name      = "password"
  value     = "${random_string.password.result}"
  vault_uri = "${azurerm_key_vault.hack.vault_uri}"
}

resource "azurerm_key_vault_secret" "sshkey" {
  name      = "sshkey"
  value     = "${file("id_rsa.pub")}"
  vault_uri = "${azurerm_key_vault.hack.vault_uri}"
}

resource "azurerm_monitor_diagnostic_setting" "keyvault" {
  name               = "${azurerm_key_vault.hack.name}/Microsoft.Insights/setByARM"
  
  log_analytics_workspace_id = "${azurerm_log_analytics_workspace.log.id}"
  
  target_resource_id = "${azurerm_key_vault.hack.id}"
  storage_account_id = "${azurerm_storage_account.hack.id}"

  log {
    category = "AuditEvent"
    enabled  = true

    retention_policy {
        enabled = true
        days = "${var.retentionPolicy}"
    }
  }

  metric {
    category = "AllMetrics"
    enabled = true

    retention_policy {
      enabled = true
      days = "${var.retentionPolicy}"
    }
  }
}