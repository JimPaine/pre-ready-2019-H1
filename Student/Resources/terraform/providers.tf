provider "azurerm" {
  subscription_id = "${var.subscription_id}"
  version         = "~> 1.21"
  client_id       = "${var.client_id}"
  client_secret   = "${var.client_secret}"
  tenant_id       = "${var.tenant_id}"
}

provider "azuread" {
  version = "~>0.1.0"  
  subscription_id = "${var.subscription_id}"
  client_id       = "${var.client_id}"
  client_secret   = "${var.client_secret}"
  tenant_id       = "${var.tenant_id}"
}

provider "random" {
  version = "~> 1.3"
}

provider "kubernetes" {
  version                = "~> 1.1"
  host                   = "${azurerm_kubernetes_cluster.akscluster.kube_config.0.host}"
  client_certificate     = "${base64decode(azurerm_kubernetes_cluster.akscluster.kube_config.0.client_certificate)}"
  client_key             = "${base64decode(azurerm_kubernetes_cluster.akscluster.kube_config.0.client_key)}"
  cluster_ca_certificate = "${base64decode(azurerm_kubernetes_cluster.akscluster.kube_config.0.cluster_ca_certificate)}"
  insecure               = false
  load_config_file       = false
}
