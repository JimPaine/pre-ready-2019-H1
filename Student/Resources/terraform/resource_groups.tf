resource "azurerm_resource_group" "aks" {
  name     = "${var.resource_name}-AKS"
  location = "${var.location}"
}

resource "azurerm_resource_group" "hack" {
  name     = "${var.resource_name}"
  location = "${var.location}"
}

resource "random_id" "aks" {
  keepers = {
    resource_group = "${azurerm_resource_group.aks.name}"
  }

  byte_length = 2
}

resource "random_id" "hack" {
  keepers = {
    resource_group = "${azurerm_resource_group.hack.name}"
  }

  byte_length = 2
}