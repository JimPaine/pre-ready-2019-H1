data "azurerm_key_vault_secret" "sshkey" {
  name      = "hackkey"
  vault_uri = "${var.sshkey_vault_uri}"
}