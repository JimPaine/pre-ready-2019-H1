resource "azurerm_log_analytics_workspace" "log" {
  name                = "${var.envPrefixName}1hacklogworkspace"
  location            = "${azurerm_resource_group.hack.location}"
  resource_group_name = "${azurerm_resource_group.hack.name}"
  sku                 = "Standalone"
  retention_in_days   = "${var.retentionPolicy}"
}

data "azurerm_subscription" "current" {}

resource "azurerm_management_group" "log" {
  subscription_ids = [
    "${data.azurerm_subscription.current.id}",
  ]
}

resource "azurerm_log_analytics_solution" "Security" {
  solution_name         = "Security${azurerm_log_analytics_workspace.log.name}"
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
  solution_name         = "AgentHealthAssessment${azurerm_log_analytics_workspace.log.name}"
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
  solution_name         = "ContainerInsights${azurerm_log_analytics_workspace.log.name}"
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
  solution_name         = "AzureSQLAnalytics${azurerm_log_analytics_workspace.log.name}"
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
  solution_name         = "ChangeTracking${azurerm_log_analytics_workspace.log.name}"
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
  solution_name         = "Updates${azurerm_log_analytics_workspace.log.name}"
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
  solution_name         = "AzureActivity${azurerm_log_analytics_workspace.log.name}"
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
  solution_name         = "AzureAutomation${azurerm_log_analytics_workspace.log.name}"
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
  solution_name         = "ADAssessment${azurerm_log_analytics_workspace.log.name}"
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
  solution_name         = "SQLAssessment${azurerm_log_analytics_workspace.log.name}"
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
  solution_name         = "ServiceMap${azurerm_log_analytics_workspace.log.name}"
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
  solution_name         = "InfrastructureInsights${azurerm_log_analytics_workspace.log.name}"
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
  solution_name         = "AzureAppGatewayAnalytics${azurerm_log_analytics_workspace.log.name}"
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
  solution_name         = "AzureNSGAnalytics${azurerm_log_analytics_workspace.log.name}"
  location              = "${azurerm_resource_group.hack.location}"
  resource_group_name   = "${azurerm_resource_group.hack.name}"
  workspace_resource_id = "${azurerm_log_analytics_workspace.log.id}"
  workspace_name        = "${azurerm_log_analytics_workspace.log.name}"

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/AzureNSGAnalytics"
  }
}

