resource "azurerm_public_ip" "vmss" {
  name                = "${var.envPrefixName}webscalesetpip"
  location            = "${azurerm_resource_group.hack.location}"
  resource_group_name = "${azurerm_resource_group.hack.name}"
  allocation_method   = "Dynamic"
  idle_timeout_in_minutes = 4

  domain_name_label = "${var.envPrefixName}webscalesetlb"

  tags {
    displayName = "WebSrvPIP for LB"
  }
}

resource "azurerm_monitor_diagnostic_setting" "vmssip" {
  name               = "${azurerm_public_ip.vmss.vmss.name}/Microsoft.Insights/setByARM"
  
  log_analytics_workspace_id = "${azurerm_log_analytics_workspace.log.id}"
  
  target_resource_id = "${azurerm_public_ip.vmss.id}"
  storage_account_id = "${azurerm_storage_account.hack.id}"

  log {
    category = "DDoSProtectionNotifications"
    enabled  = true

    retention_policy {
        enabled = false
    }
  }

  metric {
    category = "AllMetrics"
    enabled = true

    retention_policy {
      enabled = false
      days = "${var.retentionPolicy}"
    }
  }
}

resource "azurerm_lb" "vmss" {
  name                = "${var.envPrefixName}webScaleSetlb"
  location            = "${azurerm_resource_group.hack.location}"
  resource_group_name = "${azurerm_resource_group.hack.name}"

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = "${azurerm_public_ip.vmss.id}"
  }

  tags {
      displayName = "Web LB"
  }
}

resource "azurerm_lb_backend_address_pool" "vmss" {
  resource_group_name = "${azurerm_resource_group.hack.name}"
  loadbalancer_id     = "${azurerm_lb.vmss.id}"
  name                = "BackendPool1"
}

resource "azurerm_lb_nat_pool" "vmss" {
  resource_group_name            = "${azurerm_resource_group.hack.name}"
  loadbalancer_id                = "${azurerm_lb.vmss.id}"
  name                           = "natpool"
  protocol                       = "Tcp"
  frontend_port_start            = 50000
  frontend_port_end              = 50119
  backend_port                   = 3389
  frontend_ip_configuration_name = "PublicIPAddress"
}

resource "azurerm_lb_probe" "vmss" {
  resource_group_name = "${azurerm_resource_group.hack.name}"
  loadbalancer_id     = "${azurerm_lb.vmss.id}"
  name                = "tcpProbe"
  port                = 80
  interval_in_seconds = 5  
}

resource "azurerm_lb_rule" "vmss" {
  resource_group_name            = "${azurerm_resource_group.hack.name}"
  loadbalancer_id                = "${azurerm_lb.vmss.id}"
  name                           = "LBRule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "PublicIPAddress"
  backend_address_pool_id = "${azurerm_lb_backend_address_pool.vmss.id}"
  idle_timeout_in_minutes = 5
  probe_id = "${azurerm_lb_probe.vmss.id}"
}

resource "azurerm_monitor_diagnostic_setting" "vmsslbdiag" {
  name               = "${azurerm_lb.vmss.name}}/Microsoft.Insights/setByARM"
  
  log_analytics_workspace_id = "${azurerm_log_analytics_workspace.log.id}"
  
  target_resource_id = "${azurerm_lb.vmss.id}"
  storage_account_id = "${azurerm_storage_account.hack.id}"

  log {
    category = "LoadBalancerAlertEvent"
    enabled  = true
    retention_policy {
        enabled = false
    }
  }

  log {
    category = "LoadBalancerProbeHealthStatus"
    enabled  = true
    retention_policy {
        enabled = false
    }
  }

  metric {
    category = "AllMetrics"
    enabled = true

    retention_policy {
      enabled = false
      days = "${var.retentionPolicy}"
    }
  }
}

resource "azurerm_virtual_machine_scale_set" "vmss" {
  name                = "${var.envPrefixName}vmsss"
  location            = "${azurerm_resource_group.hack.location}"
  resource_group_name = "${azurerm_resource_group.hack.name}"

  # automatic rolling upgrade
  automatic_os_upgrade = false
  upgrade_policy_mode  = "manual"

  sku {
    name     = "Standard_DS3_v2"
    tier     = "Standard"
    capacity = 2
  }

  storage_profile_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }

  storage_profile_os_disk {
    name              = ""
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_profile_data_disk {
    lun           = 0
    caching       = "ReadWrite"
    create_option = "Empty"
    disk_size_gb  = 10
  }

  os_profile {
    computer_name_prefix = "${var.envPrefixName}vmsss"
    admin_username       = "${var.username}"
  }

  network_profile {
    name    = "${var.envPrefixName}vmssnic"
    primary = true

    ip_configuration {
      name                                   = "${var.envPrefixName}IpConfig"
      primary                                = true
      subnet_id                              = "${azurerm_subnet.fe.id}"
      load_balancer_backend_address_pool_ids = ["${azurerm_lb_backend_address_pool.vmss.id}"]
      load_balancer_inbound_nat_rules_ids    = ["${element(azurerm_lb_nat_pool.vmss.*.id, count.index)}"]
    }
  }

  extension {
      name = "CustomScriptExtension"
      publisher = "Microsoft.Compute"
      type = "CustomScriptExtension"
      type_handler_version = "1.9"
      auto_upgrade_minor_version = true
      settings = <<CUSTOMSCRIPTSETTINGS
        {
            "fileUris": [
                "https://raw.githubusercontent.com/rkuehfus/pre-ready-2019-H1/master/Student/Resources/SetupWebServers.ps1"
            ],
            "commandToExecute": "[concat('powershell.exe -ExecutionPolicy Unrestricted -File SetupWebServers.ps1 ', ${azurerm_virtual_machine.vs.name}, ' ', ${var.username}, ' ', ${random_string.password.result})]"
        }
CUSTOMSCRIPTSETTINGS
  }

    extension {
      name = "logAnalyticsPolicy"
      publisher = "Microsoft.EnterpriseCloud.Monitoring"
      type = "MicrosoftMonitoringAgent"
      type_handler_version = "1.0"
      auto_upgrade_minor_version = true
      settings = <<LOGSETTINGS
        {
            "workspaceId": "${azurerm_log_analytics_workspace.log.workspace_id}"
        }
LOGSETTINGS
      protected_settings = <<LOGPROTECTED
        {
            "workspaceKey": "${azurerm_log_analytics_workspace.log.primary_access_key}"
        }
LOGPROTECTED
    }

    extension {
      name = "VMSSWADextension"
      publisher = "Microsoft.ManagedIdentity"
      type = "ManagedIdentityExtensionForWindows"
      type_handler_version = "1.0"
      auto_upgrade_minor_version = true
      settings = <<WADSETTINGS
        {
            "port": "50342"
        }
WADSETTINGS
    }

    extension {
      name = "DependencyAgent"
      publisher = "Microsoft.Azure.Monitoring.DependencyAgent"
      type = "DependencyAgentWindows"
      type_handler_version = "9.4"
      auto_upgrade_minor_version = true
    }

    extension {
      name = "IaaSDiagnostics"
      publisher = "Microsoft.Azure.Diagnostics"
      type = "IaaSDiagnostics"
      type_handler_version = "1.5"
      auto_upgrade_minor_version = true
      settings = <<DIAGSETTINGS
        {
            "StorageAccount": "${azurerm_storage_account.hack.name}",
            "WadCfg": {
                "DiagnosticMonitorConfiguration": {
                    "overallQuotaInMB": 50000,
                    "Metrics": {
                        "resourceId": "Microsoft.Compute/virtualMachineScaleSets/${var.envPrefixName}vmsss",
                        "MetricAggregation": [
                            {
                                "scheduledTransferPeriod": "PT1H"
                            },
                            {
                                "scheduledTransferPeriod": "PT1M"
                            }
                        ]
                    },
                    "DiagnosticInfrastructureLogs": {
                        "scheduledTransferLogLevelFilter": "Error"
                    },
                    "PerformanceCounters": {
                        "scheduledTransferPeriod": "PT1M",
                        "sinks": "AzMonSink",
                        "PerformanceCounterConfiguration": [
                            {
                                "counterSpecifier": "\\Processor Information(_Total)\\% Processor Time",
                                "sampleRate": "PT1M"
                            },
                            {
                                "counterSpecifier": "\\Processor Information(_Total)\\% Privileged Time",
                                "sampleRate": "PT1M"
                            },
                            {
                                "counterSpecifier": "\\Processor Information(_Total)\\% User Time",
                                "sampleRate": "PT1M"
                            },
                            {
                                "counterSpecifier": "\\Processor Information(_Total)\\Processor Frequency",
                                "sampleRate": "PT1M"
                            },
                            {
                                "counterSpecifier": "\\System\\Processes",
                                "sampleRate": "PT1M"
                            },
                            {
                                "counterSpecifier": "\\Process(_Total)\\Thread Count",
                                "sampleRate": "PT1M"
                            },
                            {
                                "counterSpecifier": "\\Process(_Total)\\Handle Count",
                                "sampleRate": "PT1M"
                            },
                            {
                                "counterSpecifier": "\\System\\System Up Time",
                                "sampleRate": "PT1M"
                            },
                            {
                                "counterSpecifier": "\\System\\Context Switches/sec",
                                "sampleRate": "PT1M"
                            },
                            {
                                "counterSpecifier": "\\System\\Processor Queue Length",
                                "sampleRate": "PT1M"
                            },
                            {
                                "counterSpecifier": "\\Memory\\% Committed Bytes In Use",
                                "sampleRate": "PT1M"
                            },
                            {
                                "counterSpecifier": "\\Memory\\Available Bytes",
                                "sampleRate": "PT1M"
                            },
                            {
                                "counterSpecifier": "\\Memory\\Committed Bytes",
                                "sampleRate": "PT1M"
                            },
                            {
                                "counterSpecifier": "\\Memory\\Cache Bytes",
                                "sampleRate": "PT1M"
                            },
                            {
                                "counterSpecifier": "\\Memory\\Pool Paged Bytes",
                                "sampleRate": "PT1M"
                            },
                            {
                                "counterSpecifier": "\\Memory\\Pool Nonpaged Bytes",
                                "sampleRate": "PT1M"
                            },
                            {
                                "counterSpecifier": "\\Memory\\Pages/sec",
                                "sampleRate": "PT1M"
                            },
                            {
                                "counterSpecifier": "\\Memory\\Page Faults/sec",
                                "sampleRate": "PT1M"
                            },
                            {
                                "counterSpecifier": "\\Process(_Total)\\Working Set",
                                "sampleRate": "PT1M"
                            },
                            {
                                "counterSpecifier": "\\Process(_Total)\\Working Set - Private",
                                "sampleRate": "PT1M"
                            },
                            {
                                "counterSpecifier": "\\LogicalDisk(_Total)\\% Disk Time",
                                "sampleRate": "PT1M"
                            },
                            {
                                "counterSpecifier": "\\LogicalDisk(_Total)\\% Disk Read Time",
                                "sampleRate": "PT1M"
                            },
                            {
                                "counterSpecifier": "\\LogicalDisk(_Total)\\% Disk Write Time",
                                "sampleRate": "PT1M"
                            },
                            {
                                "counterSpecifier": "\\LogicalDisk(_Total)\\% Idle Time",
                                "sampleRate": "PT1M"
                            },
                            {
                                "counterSpecifier": "\\LogicalDisk(_Total)\\Disk Bytes/sec",
                                "sampleRate": "PT1M"
                            },
                            {
                                "counterSpecifier": "\\LogicalDisk(_Total)\\Disk Read Bytes/sec",
                                "sampleRate": "PT1M"
                            },
                            {
                                "counterSpecifier": "\\LogicalDisk(_Total)\\Disk Write Bytes/sec",
                                "sampleRate": "PT1M"
                            },
                            {
                                "counterSpecifier": "\\LogicalDisk(_Total)\\Disk Transfers/sec",
                                "sampleRate": "PT1M"
                            },
                            {
                                "counterSpecifier": "\\LogicalDisk(_Total)\\Disk Reads/sec",
                                "sampleRate": "PT1M"
                            },
                            {
                                "counterSpecifier": "\\LogicalDisk(_Total)\\Disk Writes/sec",
                                "sampleRate": "PT1M"
                            },
                            {
                                "counterSpecifier": "\\LogicalDisk(_Total)\\Avg. Disk sec/Transfer",
                                "sampleRate": "PT1M"
                            },
                            {
                                "counterSpecifier": "\\LogicalDisk(_Total)\\Avg. Disk sec/Read",
                                "sampleRate": "PT1M"
                            },
                            {
                                "counterSpecifier": "\\LogicalDisk(_Total)\\Avg. Disk sec/Write",
                                "sampleRate": "PT1M"
                            },
                            {
                                "counterSpecifier": "\\LogicalDisk(_Total)\\Avg. Disk Queue Length",
                                "sampleRate": "PT1M"
                            },
                            {
                                "counterSpecifier": "\\LogicalDisk(_Total)\\Avg. Disk Read Queue Length",
                                "sampleRate": "PT1M"
                            },
                            {
                                "counterSpecifier": "\\LogicalDisk(_Total)\\Avg. Disk Write Queue Length",
                                "sampleRate": "PT1M"
                            },
                            {
                                "counterSpecifier": "\\LogicalDisk(_Total)\\% Free Space",
                                "sampleRate": "PT1M"
                            },
                            {
                                "counterSpecifier": "\\LogicalDisk(_Total)\\Free Megabytes",
                                "sampleRate": "PT1M"
                            },
                            {
                                "counterSpecifier": "\\Network Interface(*)\\Bytes Total/sec",
                                "sampleRate": "PT1M"
                            },
                            {
                                "counterSpecifier": "\\Network Interface(*)\\Bytes Sent/sec",
                                "sampleRate": "PT1M"
                            },
                            {
                                "counterSpecifier": "\\Network Interface(*)\\Bytes Received/sec",
                                "sampleRate": "PT1M"
                            },
                            {
                                "counterSpecifier": "\\Network Interface(*)\\Packets/sec",
                                "sampleRate": "PT1M"
                            },
                            {
                                "counterSpecifier": "\\Network Interface(*)\\Packets Sent/sec",
                                "sampleRate": "PT1M"
                            },
                            {
                                "counterSpecifier": "\\Network Interface(*)\\Packets Received/sec",
                                "sampleRate": "PT1M"
                            },
                            {
                                "counterSpecifier": "\\Network Interface(*)\\Packets Outbound Errors",
                                "sampleRate": "PT1M"
                            },
                            {
                                "counterSpecifier": "\\Network Interface(*)\\Packets Received Errors",
                                "sampleRate": "PT1M"
                            }
                        ]
                    },
                    "WindowsEventLog": {
                        "scheduledTransferPeriod": "PT1M",
                        "DataSource": [
                            {
                                "name": "Application!*[System[(Level = 1 or Level = 2 or Level = 3)]]"
                            },
                            {
                                "name": "Security!*[System[band(Keywords,4503599627370496)]]"
                            },
                            {
                                "name": "System!*[System[(Level = 1 or Level = 2 or Level = 3)]]"
                            }
                        ]
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
            }
        }
DIAGSETTINGS
    }
    protected_settings = <<DIAGPROTECTED
        {
            "storageAccountName": "${azurerm_storage_account.hack.name}",
            "storageAccountKey": "${azurerm_storage_account.hack.primary_access_key}",
            "storageAccountEndPoint": "https://core.windows.net/"
        }
DIAGPROTECTED
}

resource "azurerm_autoscale_setting" "vmss" {
  name                = "cpuautoscale${var.envPrefixName}vmss"
  resource_group_name = "${azurerm_resource_group.hack.name}"
  location            = "${azurerm_resource_group.hack.location}"
  target_resource_id  = "${azurerm_virtual_machine_scale_set.vmss.id}"

  profile {
    name = "Profile1"

    capacity {
      default = 2
      minimum = 2
      maximum = 4
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = "${azurerm_virtual_machine_scale_set.vmss.id}"
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 75
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = "${azurerm_virtual_machine_scale_set.vmss.id}"
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 25
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }
  }

  notification {
    email {
      send_to_subscription_administrator    = true
      send_to_subscription_co_administrator = true
      custom_emails                         = ["admin@contoso.com"]
    }
  }
}