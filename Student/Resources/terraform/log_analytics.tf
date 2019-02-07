resource "azurerm_log_analytics_workspace" "log" {
  name                = "${var.envPrefixName}1hacklogworkspace"
  location            = "${azurerm_resource_group.hack.location}"
  resource_group_name = "${azurerm_resource_group.hack.name}"
  sku                 = "Standalone"
  retention_in_days   = "${var.retentionPolicy}"
}

resource "azurerm_log_analytics_solution" "Security" {
  solution_name         = "Security"
  location              = "${azurerm_resource_group.hack.location}"
  resource_group_name   = "${azurerm_resource_group.hack.name}"
  workspace_resource_id = "${azurerm_log_analytics_workspace.log.id}"
  workspace_name        = "${azurerm_log_analytics_workspace.log.name}"

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/Security"
  }
}

resource "azurerm_log_analytics_solution" "AgentHealthAssessment" {
  solution_name         = "AgentHealthAssessment"
  location              = "${azurerm_resource_group.hack.location}"
  resource_group_name   = "${azurerm_resource_group.hack.name}"
  workspace_resource_id = "${azurerm_log_analytics_workspace.log.id}"
  workspace_name        = "${azurerm_log_analytics_workspace.log.name}"

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/AgentHealthAssessment"
  }
}

resource "azurerm_log_analytics_solution" "ContainerInsights" {
  solution_name         = "ContainerInsights"
  location              = "${azurerm_resource_group.hack.location}"
  resource_group_name   = "${azurerm_resource_group.hack.name}"
  workspace_resource_id = "${azurerm_log_analytics_workspace.log.id}"
  workspace_name        = "${azurerm_log_analytics_workspace.log.name}"

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }
}

resource "azurerm_log_analytics_solution" "AzureSQLAnalytics" {
  solution_name         = "AzureSQLAnalytics"
  location              = "${azurerm_resource_group.hack.location}"
  resource_group_name   = "${azurerm_resource_group.hack.name}"
  workspace_resource_id = "${azurerm_log_analytics_workspace.log.id}"
  workspace_name        = "${azurerm_log_analytics_workspace.log.name}"

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/AzureSQLAnalytics"
  }
}

resource "azurerm_log_analytics_solution" "ChangeTracking" {
  solution_name         = "ChangeTracking"
  location              = "${azurerm_resource_group.hack.location}"
  resource_group_name   = "${azurerm_resource_group.hack.name}"
  workspace_resource_id = "${azurerm_log_analytics_workspace.log.id}"
  workspace_name        = "${azurerm_log_analytics_workspace.log.name}"

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ChangeTracking"
  }
}

resource "azurerm_log_analytics_solution" "Updates" {
  solution_name         = "Updates"
  location              = "${azurerm_resource_group.hack.location}"
  resource_group_name   = "${azurerm_resource_group.hack.name}"
  workspace_resource_id = "${azurerm_log_analytics_workspace.log.id}"
  workspace_name        = "${azurerm_log_analytics_workspace.log.name}"

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/Updates"
  }
}

resource "azurerm_log_analytics_solution" "AzureActivity" {
  solution_name         = "AzureActivity"
  location              = "${azurerm_resource_group.hack.location}"
  resource_group_name   = "${azurerm_resource_group.hack.name}"
  workspace_resource_id = "${azurerm_log_analytics_workspace.log.id}"
  workspace_name        = "${azurerm_log_analytics_workspace.log.name}"

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/AzureActivity"
  }
}

resource "azurerm_log_analytics_solution" "AzureAutomation" {
  solution_name         = "AzureAutomation"
  location              = "${azurerm_resource_group.hack.location}"
  resource_group_name   = "${azurerm_resource_group.hack.name}"
  workspace_resource_id = "${azurerm_log_analytics_workspace.log.id}"
  workspace_name        = "${azurerm_log_analytics_workspace.log.name}"

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/AzureAutomation"
  }
}

resource "azurerm_log_analytics_solution" "ADAssessment" {
  solution_name         = "ADAssessment"
  location              = "${azurerm_resource_group.hack.location}"
  resource_group_name   = "${azurerm_resource_group.hack.name}"
  workspace_resource_id = "${azurerm_log_analytics_workspace.log.id}"
  workspace_name        = "${azurerm_log_analytics_workspace.log.name}"

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ADAssessment"
  }
}

resource "azurerm_log_analytics_solution" "SQLAssessment" {
  solution_name         = "SQLAssessment"
  location              = "${azurerm_resource_group.hack.location}"
  resource_group_name   = "${azurerm_resource_group.hack.name}"
  workspace_resource_id = "${azurerm_log_analytics_workspace.log.id}"
  workspace_name        = "${azurerm_log_analytics_workspace.log.name}"

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/SQLAssessment"
  }
}

resource "azurerm_log_analytics_solution" "ServiceMap" {
  solution_name         = "ServiceMap"
  location              = "${azurerm_resource_group.hack.location}"
  resource_group_name   = "${azurerm_resource_group.hack.name}"
  workspace_resource_id = "${azurerm_log_analytics_workspace.log.id}"
  workspace_name        = "${azurerm_log_analytics_workspace.log.name}"

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ServiceMap"
  }
}

resource "azurerm_log_analytics_solution" "InfrastructureInsights" {
  solution_name         = "InfrastructureInsights"
  location              = "${azurerm_resource_group.hack.location}"
  resource_group_name   = "${azurerm_resource_group.hack.name}"
  workspace_resource_id = "${azurerm_log_analytics_workspace.log.id}"
  workspace_name        = "${azurerm_log_analytics_workspace.log.name}"

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/InfrastructureInsights"
  }
}

resource "azurerm_log_analytics_solution" "AzureAppGatewayAnalytics" {
  solution_name         = "AzureAppGatewayAnalytics"
  location              = "${azurerm_resource_group.hack.location}"
  resource_group_name   = "${azurerm_resource_group.hack.name}"
  workspace_resource_id = "${azurerm_log_analytics_workspace.log.id}"
  workspace_name        = "${azurerm_log_analytics_workspace.log.name}"

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/AzureAppGatewayAnalytics"
  }
}

resource "azurerm_log_analytics_solution" "AzureNSGAnalytics" {
  solution_name         = "AzureNSGAnalytics"
  location              = "${azurerm_resource_group.hack.location}"
  resource_group_name   = "${azurerm_resource_group.hack.name}"
  workspace_resource_id = "${azurerm_log_analytics_workspace.log.id}"
  workspace_name        = "${azurerm_log_analytics_workspace.log.name}"

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/AzureNSGAnalytics"
  }
}

