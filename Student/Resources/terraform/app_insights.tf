resource "azurerm_application_insights" "hack" {
  name                = "${var.envPrefixName}hackAppInsights"
  location            = "${azurerm_resource_group.hack.location}"
  resource_group_name = "${azurerm_resource_group.hack.name}"
  application_type    = "Web"
}

resource "azurerm_template_deployment" "webtest" {
  name                = "${var.envPrefixName}hackAppInsights"
  resource_group_name = "${azurerm_resource_group.hack.name}"

  template_body = <<DEPLOY
{
    "$schema": "http://schema.management.azure.com/schemas/2014-04-01-preview/deploymentTemplate.json",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "appLocation": {
            "type": "String"
        },
        "appName": {
            "type": "String"
        },
        "webSrvPublicIP": {
            "type": "String"
        },
        "subscription_id": {
            "type": "String"
        }
    },
    "variables": {
        "testlocations": [
                {
                    "Id": "us-il-ch1-azr"
                },
                {
                    "Id": "us-ca-sjc-azr"
                },
                {
                    "Id": "us-tx-sn1-azr"
                }
            ],
        
        "pingguid": "[guid(parameters(subscription_id))]",        
        "pingexpected": 200,
        "pingname": "eShopPingTest"
    },
    "resources": [
        {
            "name": "[variables('pingname')]",
            "apiVersion": "2015-05-01",
            "type": "microsoft.insights/webtests",
            "location": "[parameters('appLocation')]",
            "properties": {
                "Name": "[variables('pingname')]",
                "Description": "[variables('pingname')]",
                "Enabled": true,
                "Frequency": 300,
                "Timeout": 30,
                "Kind": "ping",
                "Locations": "[variables('testlocations')]",
                "Configuration": {
                    "WebTest": "[concat('<WebTest Name=\"', variables('pingname'), '\"',  ' Id=\"', variables('pingguid') ,'\"    Enabled=\"True\" CssProjectStructure=\"\" CssIteration=\"\" Timeout=\"0\" WorkItemIds=\"\" xmlns=\"http://microsoft.com/schemas/VisualStudio/TeamTest/2010\" Description=\"\" CredentialUserName=\"\" CredentialPassword=\"\" PreAuthenticate=\"True\" Proxy=\"default\" StopOnError=\"False\" RecordedResultFile=\"\" ResultsLocale=\"\">        <Items>        <Request Method=\"GET\" Guid=\"a5f10126-e4cd-570d-961c-cea43999a200\" Version=\"1.1\" Url=\"', parameters('webSrvPublicIP') ,'\" ThinkTime=\"0\" Timeout=\"300\" ParseDependentRequests=\"True\" FollowRedirects=\"True\" RecordResult=\"True\" Cache=\"False\" ResponseTimeGoal=\"0\" Encoding=\"utf-8\" ExpectedHttpStatusCode=\"', variables('pingexpected') ,'\" ExpectedResponseUrl=\"\" ReportingName=\"\" IgnoreHttpStatusCode=\"False\" /></Items></WebTest>')]"
                },
                "SyntheticMonitorId": "[variables('pingname')]"
            }
        }
    ]
}
DEPLOY

  parameters {
    "appName"     = "${azurerm_application_insights.hack.name}"
    "appLocation" = "${azurerm_resource_group.hack.location}"
    "webSrvPublicIP" = "${azurerm_public_ip.vmss.fqdn}"
    "subscription_id" = "${var.subscription_id}"
  }

  deployment_mode = "Incremental"
}