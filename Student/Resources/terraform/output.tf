output "kube_config" {
  value = "${azurerm_kubernetes_cluster.akscluster.kube_config_raw}"
}

output "host" {
  value = "${azurerm_kubernetes_cluster.akscluster.kube_config.0.host}"
}

output "aksclusterprofile" {
  value = {
    network_profile           = "${azurerm_kubernetes_cluster.akscluster.network_profile}"
    AKS-LogAnalyticsWorkspace = "${azurerm_kubernetes_cluster.akscluster.addon_profile}"
    agent_pool_Profile        = "${azurerm_kubernetes_cluster.akscluster.agent_pool_profile}"
  }
}

output "configure" {
  value = <<CONFIGURE

Run the following commands to configure kubernetes client:

$ terraform output kube_config > ~/.kube/aksconfig
$ export KUBECONFIG=~/.kube/aksconfig

Test configuration using kubectl

$ kubectl get nodes
CONFIGURE
}
