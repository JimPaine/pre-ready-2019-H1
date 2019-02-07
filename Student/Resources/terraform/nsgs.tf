resource "azurerm_network_security_group" "fensg" {
  name                = "feNsg"
  location            = "${azurerm_resource_group.hack.location}"
  resource_group_name = "${azurerm_resource_group.hack.name}"

  tags = {
      displayName = "FrontEndNSG"
  }
}

resource "azurerm_network_security_rule" "fensgrdprule" {
  name                        = "rdp_rule"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = "Internet"
  destination_address_prefix  = "*"
  resource_group_name         = "${azurerm_resource_group.hack.name}"
  network_security_group_name = "${azurerm_network_security_group.fensg.name}"
  description = "Allow RDP"
}

resource "azurerm_network_security_rule" "fensgwebrule" {
  name                        = "web_rule"
  priority                    = 101
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "Internet"
  destination_address_prefix  = "*"
  resource_group_name         = "${azurerm_resource_group.hack.name}"
  network_security_group_name = "${azurerm_network_security_group.fensg.name}"
  description = "Allow WEB"
}

resource "azurerm_network_security_rule" "fensgpublishrule" {
  name                        = "publish_rule"
  priority                    = 102
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "8172"
  source_address_prefix       = "Internet"
  destination_address_prefix  = "*"
  resource_group_name         = "${azurerm_resource_group.hack.name}"
  network_security_group_name = "${azurerm_network_security_group.fensg.name}"
  description = "Allow Web Publish"
}

resource "azurerm_monitor_diagnostic_setting" "fensg" {
  name               = "${azurerm_network_security_group.fensg.name}setForSecurity"
  
  log_analytics_workspace_id = "${azurerm_log_analytics_workspace.log.id}"
  
  target_resource_id = "${azurerm_network_security_group.fensg.id}"
  storage_account_id = "${azurerm_storage_account.hack.id}"

  log {
    category = "NetworkSecurityGroupEvent"
    enabled  = true

    retention_policy {
      enabled = true,
      days = "${var.retentionPolicy}"
    }
  }

  log {
    category = "NetworkSecurityGroupRuleCounter"
    enabled  = true

    retention_policy {
      enabled = true,
      days = "${var.retentionPolicy}"
    }
  }
}

resource "azurerm_network_security_group" "dbnsg" {
  name                = "dbNsg"
  location            = "${azurerm_resource_group.hack.location}"
  resource_group_name = "${azurerm_resource_group.hack.name}"

  tags = {
      displayName = "BackEndNSG"
  }
}

resource "azurerm_network_security_rule" "dbnsgferule" {
  name                        = "Allow_FE"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "1433"
  source_address_prefix       = "10.0.0.0/24"
  destination_address_prefix  = "*"
  resource_group_name         = "${azurerm_resource_group.hack.name}"
  network_security_group_name = "${azurerm_network_security_group.dbnsg.name}"
  description = "Allow FE Subnet"
}

resource "azurerm_network_security_rule" "dbnsgaksrule" {
  name                        = "Allow_AKS"
  priority                    = 101
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "1433"
  source_address_prefix       = "10.0.3.0/24"
  destination_address_prefix  = "*"
  resource_group_name         = "${azurerm_resource_group.hack.name}"
  network_security_group_name = "${azurerm_network_security_group.dbnsg.name}"
  description = "Allow AKS Subnet"
}

resource "azurerm_network_security_rule" "dbnsgrdprule" {
  name                        = "rdp_rule"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = "Internet"
  destination_address_prefix  = "*"
  resource_group_name         = "${azurerm_resource_group.hack.name}"
  network_security_group_name = "${azurerm_network_security_group.dbnsg.name}"
  description = "Allow RDP"
}

resource "azurerm_network_security_rule" "dbnsgblockferule" {
  name                        = "Block_FE"
  priority                    = 121
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "10.0.0.0/24"
  destination_address_prefix  = "*"
  resource_group_name         = "${azurerm_resource_group.hack.name}"
  network_security_group_name = "${azurerm_network_security_group.dbnsg.name}"
  description = "Block App Subnet"
}

resource "azurerm_monitor_diagnostic_setting" "dbnsg" {
  name               = "${azurerm_network_security_group.dbnsg.name}setForSecurity"
  
  log_analytics_workspace_id = "${azurerm_log_analytics_workspace.log.id}"
  
  target_resource_id = "${azurerm_network_security_group.dbnsg.id}"
  storage_account_id = "${azurerm_storage_account.hack.id}"

  log {
    category = "NetworkSecurityGroupEvent"
    enabled  = true

    retention_policy {
      enabled = true,
      days = "${var.retentionPolicy}"
    }
  }

  log {
    category = "NetworkSecurityGroupRuleCounter"
    enabled  = true

    retention_policy {
      enabled = true,
      days = "${var.retentionPolicy}"
    }
  }
}