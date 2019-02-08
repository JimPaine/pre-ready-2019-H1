
resource "azurerm_public_ip" "hack" {
  name                = "${var.envPrefixName}SqlPip"
  location            = "${azurerm_resource_group.hack.location}"
  resource_group_name = "${azurerm_resource_group.hack.name}"
  allocation_method   = "Dynamic"
  idle_timeout_in_minutes = 4

  tags {
    displayName = "SqlPIP"
  }
}

resource "azurerm_network_interface" "sql" {
  name                = "${var.envPrefixName}sqlSrv16Nic"
  location            = "${azurerm_resource_group.hack.location}"
  resource_group_name = "${azurerm_resource_group.hack.name}"

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = "${azurerm_subnet.db.id}"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = "${azurerm_public_ip.hack.id}"
  }

  tags {
    displayName = "SQLSrvDBNic"
  }
}

resource "azurerm_virtual_machine" "sql" {
  name                  = "${var.envPrefixName}sqlSrv16"
  location              = "${azurerm_resource_group.hack.location}"
  resource_group_name   = "${azurerm_resource_group.hack.name}"
  network_interface_ids = ["${azurerm_network_interface.sql.id}"]
  vm_size               = "${var.sqlVmSize}"

  delete_os_disk_on_termination = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "MicrosoftSQLServer"
    offer     = "SQL2016SP1-WS2016"
    sku       = "Standard"
    version   = "latest"
  }
  storage_os_disk {
    name              = "${var.envPrefixName}sqlSrv16_OSDisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "${var.diskType}"
  }
  os_profile {
    computer_name  = "${var.envPrefixName}sqlSrv16"
    admin_username = "${var.username}"
    admin_password = "${random_string.password.result}"
  }

  os_profile_windows_config {
    
  }

  identity {
    type = "SystemAssigned"
  }

  tags {
    displayName = "SQL-Svr-DB"
  }
}

resource "azurerm_virtual_machine_extension" "sqlwad" {
  name                 = "${var.envPrefixName}sqlSrv16/WADExtensionSetup"
  location             = "${azurerm_resource_group.hack.location}"
  resource_group_name  = "${azurerm_resource_group.hack.name}"
  virtual_machine_name = "${azurerm_virtual_machine.sql.name}"
  publisher            = "Microsoft.ManagedIdentity"
  type                 = "ManagedIdentityExtensionForWindows"
  type_handler_version = "1.0"

  settings = <<SETTINGS
    {
        "port": 50342
    }
SETTINGS
}

resource "azurerm_virtual_machine_extension" "sqldiag" {
  name                 = "${var.envPrefixName}sqlSrv16/VMDiagnosticsSettings"
  location             = "${azurerm_resource_group.hack.location}"
  resource_group_name  = "${azurerm_resource_group.hack.name}"
  virtual_machine_name = "${azurerm_virtual_machine.sql.name}"
  publisher            = "Microsoft.Azure.Diagnostics"
  type                 = "IaaSDiagnostics"
  type_handler_version = "1.5"
  auto_upgrade_minor_version = true

  settings = <<SETTINGS
    {
        "WadCfg": {
                        "DiagnosticMonitorConfiguration": {
                            "overallQuotaInMB": 4096,
                            "DiagnosticInfrastructureLogs": {
                                "scheduledTransferLogLevelFilter": "Error"
                            },
                            "Directories": {
                                "scheduledTransferPeriod": "PT1M",
                                "IISLogs": {
                                    "containerName": "wad-iis-logfiles"
                                },
                                "FailedRequestLogs": {
                                    "containerName": "wad-failedrequestlogs"
                                }
                            },
                            "PerformanceCounters": {
                                "scheduledTransferPeriod": "PT1M",
                                "sinks": "AzMonSink",
                                "PerformanceCounterConfiguration": [
                                    {
                                        "counterSpecifier": "\\Memory\\Available Bytes",
                                        "sampleRate": "PT15S"
                                    },
                                    {
                                        "counterSpecifier": "\\Memory\\% Committed Bytes In Use",
                                        "sampleRate": "PT15S"
                                    },
                                    {
                                        "counterSpecifier": "\\Memory\\Committed Bytes",
                                        "sampleRate": "PT15S"
                                    }
                                ]
                            },
                            "WindowsEventLog": {
                                "scheduledTransferPeriod": "PT1M",
                                "DataSource": [
                                    {
                                        "name": "Application!*"
                                    }
                                ]
                            },
                            "Logs": {
                                "scheduledTransferPeriod": "PT1M",
                                "scheduledTransferLogLevelFilter": "Error"
                            }
                        },
                        "SinksConfig": {
                            "Sink": [
                                {
                                    "name": "AzMonSink",
                                    "AzureMonitor": {}
                                }
                            ]
                        }
                    },
                    "StorageAccount": "${azurerm_storage_account.hack.name}"
                }
    }
SETTINGS

  protected_settings = <<PROTECTEDSETTINGS
    {
        "storageAccountName": "${azurerm_storage_account.hack.name}",
        "storageAccountKey": "${azurerm_storage_account.hack.primary_access_key}",
        "storageAccountEndPoint": "https://core.windows.net/"
    }
PROTECTEDSETTINGS

}

resource "azurerm_virtual_machine_extension" "sqliaas" {
  name                 = "${var.envPrefixName}sqlSrv16/SqlIaasExtension"
  location             = "${azurerm_resource_group.hack.location}"
  resource_group_name  = "${azurerm_resource_group.hack.name}"
  virtual_machine_name = "${azurerm_virtual_machine.sql.name}"
  publisher            = "Microsoft.SqlServer.Management"
  type                 = "SqlIaaSAgent"
  type_handler_version = "1.2"
  auto_upgrade_minor_version = true

  settings = <<SETTINGS
    {
                    "AutoTelemetrySettings": {
                        "Region": "${azurerm_resource_group.hack.location}"
                    },
                    "AutoPatchingSettings": {
                        "PatchCategory": "WindowsMandatoryUpdates",
                        "Enable": false
                    },
                    "KeyVaultCredentialSettings": {
                        "Enable": false,
                        "CredentialName": ""
                    },
                    "ServerConfigurationsManagementSettings": {
                        "SQLConnectivityUpdateSettings": {
                            "ConnectivityType": "${var.sqlConnectivityType}",
                            "Port": "1433"
                        },
                        "AdditionalFeaturesServerConfigurations": {
                            "IsRServicesEnabled": false
                        }
                    }
                }
SETTINGS

  protected_settings = <<PROTECTEDSETTINGS
    {
        "SQLAuthUpdateUserName": "${var.sqlAuthenticationLogin}",
        "SQLAuthUpdatePassword": "${random_string.password.result}"
    }
PROTECTEDSETTINGS

}

resource "azurerm_virtual_machine_extension" "sqlagent" {
  name                 = "${var.envPrefixName}sqlSrv16/DependencyAgent"
  location             = "${azurerm_resource_group.hack.location}"
  resource_group_name  = "${azurerm_resource_group.hack.name}"
  virtual_machine_name = "${azurerm_virtual_machine.sql.name}"
  publisher            = "Microsoft.Azure.Monitoring.DependencyAgent"
  type                 = "DependencyAgentWindows"
  type_handler_version = "9.4"
  auto_upgrade_minor_version = true
}

resource "azurerm_virtual_machine_extension" "sqlpolicy" {
  name                 = "${var.envPrefixName}sqlSrv16/laPolicy"
  location             = "${azurerm_resource_group.hack.location}"
  resource_group_name  = "${azurerm_resource_group.hack.name}"
  virtual_machine_name = "${azurerm_virtual_machine.sql.name}"
  publisher            = "Microsoft.EnterpriseCloud.Monitoring"
  type                 = "MicrosoftMonitoringAgent"
  type_handler_version = "1.0"
  auto_upgrade_minor_version = true

  settings = <<SETTINGS
    {
        "workspaceId": "${azurerm_log_analytics_workspace.log.workspace_id}"
    }
SETTINGS

  protected_settings = <<PROTECTEDSETTINGS
    {
        "workspaceKey": "${azurerm_log_analytics_workspace.log.primary_shared_key}"
    }
PROTECTEDSETTINGS

}