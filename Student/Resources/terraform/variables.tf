variable "resource_name" {}
variable "subscription_id" {}
variable "client_id" {}
variable "client_secret" {}
variable "tenant_id" {}
variable "agent_count" {}
variable "vm_size"{}
variable "location" {}
variable "admin_user" {}
variable "k8s_version" {}
variable "envPrefixName" {}
variable "retentionPolicy" {}
variable "sqlVmSize" {}
variable "username" {}
variable "diskType" {}
variable "sqlConnectivityType" {}
variable "sqlAuthenticationLogin" {}
variable "sshkey_vault_uri" {}

variable "namespace" {}

data "azurerm_client_config" "hack" {}
