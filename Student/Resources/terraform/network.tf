resource "azurerm_virtual_network" "hack" {
  name                = "${var.envPrefixName}Vnet"
  location            = "${azurerm_resource_group.hack.location}"
  resource_group_name = "${azurerm_resource_group.hack.name}"
  address_space       = ["10.0.0.0/16"]

  tags {
    displayName = "VirtualNetwork"
  }
}

resource "azurerm_subnet" "fe" {
  name                 = "FESubnetName"
  resource_group_name  = "${azurerm_resource_group.hack.name}"
  virtual_network_name = "${azurerm_virtual_network.hack.name}"
  address_prefix       = "10.0.0.0/24"
}

resource "azurerm_subnet_network_security_group_association" "fe" {
  subnet_id                 = "${azurerm_subnet.fe.id}"
  network_security_group_id = "${azurerm_network_security_group.fensg.id}"
}

resource "azurerm_subnet" "db" {
  name                 = "DBSubnetName"
  resource_group_name  = "${azurerm_resource_group.hack.name}"
  virtual_network_name = "${azurerm_virtual_network.hack.name}"
  address_prefix       = "10.0.2.0/24"
}

resource "azurerm_subnet_network_security_group_association" "db" {
  subnet_id                 = "${azurerm_subnet.db.id}"
  network_security_group_id = "${azurerm_network_security_group.dbnsg.id}"
}

resource "azurerm_subnet" "aks" {
  name                 = "aksSubnetName"
  resource_group_name  = "${azurerm_resource_group.hack.name}"
  virtual_network_name = "${azurerm_virtual_network.hack.name}"
  address_prefix       = "10.0.3.0/24"
}