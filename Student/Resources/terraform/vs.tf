resource "azurerm_public_ip" "vs" {
  name                = "${var.envPrefixName}VSPIP"
  location            = "${azurerm_resource_group.hack.location}"
  resource_group_name = "${azurerm_resource_group.hack.name}"
  allocation_method   = "Dynamic"
  idle_timeout_in_minutes = 4

  tags {
    displayName = "VSPIP"
  }
}

resource "azurerm_network_interface" "vs" {
  name                = "${var.envPrefixName}VSSrv17Nic"
  location            = "${azurerm_resource_group.hack.location}"
  resource_group_name = "${azurerm_resource_group.hack.name}"

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = "${azurerm_subnet.fe.id}"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = "${azurerm_public_ip.vs.id}"
  }

  tags {
    displayName = "VSNic"
  }
}

resource "azurerm_virtual_machine" "vs" {
  name                  = "${var.envPrefixName}VSSrv17"
  location              = "${azurerm_resource_group.hack.location}"
  resource_group_name   = "${azurerm_resource_group.hack.name}"
  network_interface_ids = ["${azurerm_network_interface.vs.id}"]
  vm_size               = "Standard_DS3_v2"

  delete_os_disk_on_termination = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "MicrosoftVisualStudio"
    offer     = "VisualStudio"
    sku       = "VS-2017-Comm-Latest-Win10-N"
    version   = "latest"
  }
  storage_os_disk {
    name              = "${var.envPrefixName}VSSrv17_OSDisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "${var.diskType}"
  }
  os_profile {
    computer_name  = "vssrv17"
    admin_username = "${var.username}"
    admin_password = "${random_string.password.result}"
  }

  os_profile_windows_config {

  }

  identity {
    type = "SystemAssigned"
  }

  tags {
    displayName = "VSSrv"
  }
}

resource "azurerm_virtual_machine_extension" "vsscript" {
  name                 = "vssrv17CustomScriptExtension"
  location             = "${azurerm_resource_group.hack.location}"
  resource_group_name  = "${azurerm_resource_group.hack.name}"
  virtual_machine_name = "${azurerm_virtual_machine.vs.name}"
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.9"
  auto_upgrade_minor_version = true

  settings = <<SETTINGS
    {
        "fileUris": [
            "https://raw.githubusercontent.com/rkuehfus/pre-ready-2019-H1/master/Student/Resources/SetupVSServer.ps1"
        ],
        "commandToExecute": "[concat('powershell.exe -ExecutionPolicy Unrestricted -File SetupVSServer.ps1 ', ' ', ${azurerm_virtual_machine.sql.name}, ' ', ${random_string.password.result})]"
    }
SETTINGS

}