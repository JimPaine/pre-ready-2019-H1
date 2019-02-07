data "azurerm_key_vault_secret" "aksvault" {
  name      = "${var.ssh_keyvault_secret_name}"
  vault_uri = "${var.keyvault_uri}"
}

data "azurerm_key_vault_secret" "aksspnsecret" {
  name      = "${var.spn_keyvault_secret_name}"
  vault_uri = "${var.keyvault_uri}"
}

resource "azurerm_kubernetes_cluster" "akscluster" {
  name                = "${var.resource_name}aksdemo"
  location            = "${azurerm_resource_group.aksrg.location}"
  resource_group_name = "${azurerm_resource_group.aksrg.name}"
  dns_prefix          = "${var.resource_name}aksdemo"
  kubernetes_version  = "${var.k8s_version}"

  linux_profile {
    admin_username = "${var.admin_user}"

    ssh_key {
      key_data = "${file("id_rsa.pub")}"
    }
  }

  agent_pool_profile {
    name            = "${var.resource_name}tfaks"
    count           = "${var.agent_count}"
    vm_size         = "${var.vm_size}"
    os_type         = "Linux"
    os_disk_size_gb = 30
    vnet_subnet_id  = "${var.aks_subnetId}"
  }

  addon_profile {
    oms_agent {
      enabled                    = true
      log_analytics_workspace_id = "${azurerm_log_analytics_workspace.log.id}"
    }

  }

  service_principal {
    client_id     = "${azuread_application.aks.application_id}"
    client_secret = "${azuread_service_principal_password.aks.value}"
  }

  network_profile {
    network_plugin     = "azure"
    docker_bridge_cidr = "172.17.0.1/16"
    dns_service_ip     = "10.240.0.10"
    service_cidr       = "10.240.0.0/16"
  }

  tags {
    Enviornment = "Container Insights - AKS"
  }
}
