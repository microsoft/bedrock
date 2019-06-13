resource "azurerm_template_deployment" "api_mgmt_deployment" {
  name                = "${var.api_mgmt_name}"
  resource_group_name = "${var.resource_group_name}"

  template_body = <<DEPLOY
{
    "$schema": "https://schema.management.azure.com/schemas/2018-05-01/deploymentTemplate.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "service_cust_option1apim_name": {
            "defaultValue": "custoption1apim713",
            "type": "string"
        },
        "users_1_name": {
            "defaultValue": "1",
            "type": "string"
        },
        "apis_traffic_manager_name": {
            "defaultValue": "Voting",
            "type": "string"
        },
        "apis_echo_api_name": {
            "defaultValue": "echo-api",
            "type": "string"
        },
        "groups_guests_name": {
            "defaultValue": "guests",
            "type": "string"
        },
        "policies_policy_name": {
            "defaultValue": "policy",
            "type": "string"
        },
        "products_starter_name": {
            "defaultValue": "starter",
            "type": "string"
        },
        "groups_developers_name": {
            "defaultValue": "developers",
            "type": "string"
        },
        "notifications_BCC_name": {
            "defaultValue": "BCC",
            "type": "string"
        },
        "products_unlimited_name": {
            "defaultValue": "unlimited",
            "type": "string"
        },
     
        "subscriptions_master_name": {
            "defaultValue": "master",
            "type": "string"
        },
        "groups_administrators_name": {
            "defaultValue": "administrators",
            "type": "string"
        },
        "diagnostics_azuremonitor_name": {
            "defaultValue": "azuremonitor",
            "type": "string"
        },
        "users_1_name_1": {
            "defaultValue": "1",
            "type": "string"
        },
        "apis_titles_name": {
            "defaultValue": "voting",
            "type": "string"
        },
        "users_1_name_2": {
            "defaultValue": "1",
            "type": "string"
        },
        "apis_echo_api_name_1": {
            "defaultValue": "echo-api",
            "type": "string"
        },
        "groups_guests_name_1": {
            "defaultValue": "guests",
            "type": "string"
        },
        "apis_titles_name_2": {
            "defaultValue": "titles",
            "type": "string"
        },
        "templates_AccountClosedDeveloper_name": {
            "defaultValue": "AccountClosedDeveloper",
            "type": "string"
        },
        "operations_gettitles_name": {
            "defaultValue": "gettitles",
            "type": "string"
        },
        "policies_policy_name_1": {
            "defaultValue": "policy",
            "type": "string"
        },
        "apis_echo_api_name_2": {
            "defaultValue": "echo-api",
            "type": "string"
        },
        "groups_guests_name_2": {
            "defaultValue": "guests",
            "type": "string"
        },
        "groups_developers_name_1": {
            "defaultValue": "developers",
            "type": "string"
        },
        "notifications_AccountClosedPublisher_name": {
            "defaultValue": "AccountClosedPublisher",
            "type": "string"
        },
        "templates_EmailChangeIdentityDefault_name": {
            "defaultValue": "EmailChangeIdentityDefault",
            "type": "string"
        },
        "groups_developers_name_2": {
            "defaultValue": "developers",
            "type": "string"
        },
        "templates_NewIssueNotificationMessage_name": {
            "defaultValue": "NewIssueNotificationMessage",
            "type": "string"
        },
        "subscriptions_5c779367a8c35f008f070001_name": {
            "defaultValue": "5c779367a8c35f008f070001",
            "type": "string"
        },
        "subscriptions_5c779367a8c35f008f070002_name": {
            "defaultValue": "5c779367a8c35f008f070002",
            "type": "string"
        },
        "templates_ConfirmSignUpIdentityDefault_name": {
            "defaultValue": "ConfirmSignUpIdentityDefault",
            "type": "string"
        },
        "templates_PasswordResetIdentityDefault_name": {
            "defaultValue": "PasswordResetIdentityDefault",
            "type": "string"
        },
        "groups_administrators_name_1": {
            "defaultValue": "administrators",
            "type": "string"
        },
        "templates_InviteUserNotificationMessage_name": {
            "defaultValue": "InviteUserNotificationMessage",
            "type": "string"
        },
        "templates_NewCommentNotificationMessage_name": {
            "defaultValue": "NewCommentNotificationMessage",
            "type": "string"
        },
        "operations_create_resource_name": {
            "defaultValue": "create-resource",
            "type": "string"
        },
        "operations_modify_resource_name": {
            "defaultValue": "modify-resource",
            "type": "string"
        },
        "operations_remove_resource_name": {
            "defaultValue": "remove-resource",
            "type": "string"
        },
        "groups_administrators_name_2": {
            "defaultValue": "administrators",
            "type": "string"
        },
        "templates_NewDeveloperNotificationMessage_name": {
            "defaultValue": "NewDeveloperNotificationMessage",
            "type": "string"
        },
        "operations_retrieve_resource_name": {
            "defaultValue": "retrieve-resource",
            "type": "string"
        },
        "templates_RejectDeveloperNotificationMessage_name": {
            "defaultValue": "RejectDeveloperNotificationMessage",
            "type": "string"
        },
        "templates_RequestDeveloperNotificationMessage_name": {
            "defaultValue": "RequestDeveloperNotificationMessage",
            "type": "string"
        },
        "operations_retrieve_header_only_name": {
            "defaultValue": "retrieve-header-only",
            "type": "string"
        },
        
        "templates_PurchaseDeveloperNotificationMessage_name": {
            "defaultValue": "PurchaseDeveloperNotificationMessage",
            "type": "string"
        },
        "notifications_NewApplicationNotificationMessage_name": {
            "defaultValue": "NewApplicationNotificationMessage",
            "type": "string"
        },
        "templates_ApplicationApprovedNotificationMessage_name": {
            "defaultValue": "ApplicationApprovedNotificationMessage",
            "type": "string"
        },
        "policies_policy_name_2": {
            "defaultValue": "policy",
            "type": "string"
        },
        "notifications_RequestPublisherNotificationMessage_name": {
            "defaultValue": "RequestPublisherNotificationMessage",
            "type": "string"
        },
        "templates_PasswordResetByAdminNotificationMessage_name": {
            "defaultValue": "PasswordResetByAdminNotificationMessage",
            "type": "string"
        },
        "operations_retrieve_resource_cached_name": {
            "defaultValue": "retrieve-resource-cached",
            "type": "string"
        },
        "notifications_PurchasePublisherNotificationMessage_name": {
            "defaultValue": "PurchasePublisherNotificationMessage",
            "type": "string"
        },
        "notifications_NewIssuePublisherNotificationMessage_name": {
            "defaultValue": "NewIssuePublisherNotificationMessage",
            "type": "string"
        },
        "policies_policy_name_3": {
            "defaultValue": "policy",
            "type": "string"
        },
        "templates_QuotaLimitApproachingDeveloperNotificationMessage_name": {
            "defaultValue": "QuotaLimitApproachingDeveloperNotificationMessage",
            "type": "string"
        },
        "policies_policy_name_4": {
            "defaultValue": "policy",
            "type": "string"
        },
        "notifications_QuotaLimitApproachingPublisherNotificationMessage_name": {
            "defaultValue": "QuotaLimitApproachingPublisherNotificationMessage",
            "type": "string"
        },
        "policies_policy_name_5": {
            "defaultValue": "policy",
            "type": "string"
        },
        "primary_region_waf_url": {
            "type": "string",
            "defaultValue": ""
        }


    },
    "variables": {
        "primary_region_waf_fqdn": "[replace(parameters('primary_region_waf_url'),'http://','')]"

    },
    "resources": [
        {
            "type": "Microsoft.ApiManagement/service",
            "sku": {
                "name": "Premium",
                "capacity": 1
            },
            "name": "[parameters('service_cust_option1apim_name')]",
            "apiVersion": "2018-01-01",
            "location": "Central US",
            "tags": {},
            "scale": null,
            "properties": {
                "publisherEmail": "apisample@microsoft.com",
                "publisherName": "Microsoft",
                "notificationSenderEmail": "apimgmt-noreply@mail.windowsazure.com",
                "hostnameConfigurations": [],
                "additionalLocations": [
                    {
                        "location": "East US",
                        "sku": {
                            "name": "Premium",
                            "capacity": 1
                        }
                    },
                    {
                        "location": "West US",
                        "sku": {
                            "name": "Premium",
                            "capacity": 1
                        }
                    }
                ],
                
                "customProperties": {
                    "Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Protocols.Tls10": "False",
                    "Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Protocols.Tls11": "False",
                    "Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Protocols.Ssl30": "False",
                    "Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TripleDes168": "False",
                    "Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Tls10": "False",
                    "Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Tls11": "False",
                    "Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Ssl30": "False",
                    "Microsoft.WindowsAzure.ApiManagement.Gateway.Protocols.Server.Http2": "False"
                },
                "virtualNetworkType": "None"
            },
            "dependsOn": []
        },
        {
            "type": "Microsoft.ApiManagement/service/apis",
            "name": "[concat(parameters('service_cust_option1apim_name'), '/', parameters('apis_echo_api_name'))]",
            "apiVersion": "2018-01-01",
            "scale": null,
            "properties": {
                "displayName": "Echo API",
                "apiRevision": "1",
                "serviceUrl": "http://echoapi.cloudapp.net/api",
                "path": "echo",
                "protocols": [
                    "https"
                ]
            },
            "dependsOn": [
                "[resourceId('Microsoft.ApiManagement/service', parameters('service_cust_option1apim_name'))]"
            ]
        },
        {
            "type": "Microsoft.ApiManagement/service/apis",
            "name": "[concat(parameters('service_cust_option1apim_name'), '/', parameters('apis_traffic_manager_name'))]",
            "apiVersion": "2018-01-01",
            "scale": null,
            "properties": {
                "displayName": "Voting",
                "apiRevision": "1",
                "description": "",
                "serviceUrl": "[concat('http://', parameters('primary_region_waf_url'))]",
                "path": "",
                "protocols": [
                    "http"
                ]
            },
            "dependsOn": [
                "[resourceId('Microsoft.ApiManagement/service', parameters('service_cust_option1apim_name'))]"
            ]
        },
        {
            "type": "Microsoft.ApiManagement/service/apis/operations",
            "name": "[concat(parameters('service_cust_option1apim_name'), '/', parameters('apis_titles_name'), '/', parameters('operations_gettitles_name'))]",
            "apiVersion": "2018-01-01",
            "scale": null,
            "properties": {
                "displayName": "getcount",
                "method": "GET",
                "urlTemplate": "/counts",
                "templateParameters": [],
                "description": "",
                "responses": []
            },
            "dependsOn": [
                "[resourceId('Microsoft.ApiManagement/service', parameters('service_cust_option1apim_name'))]",
                "[resourceId('Microsoft.ApiManagement/service/apis', parameters('service_cust_option1apim_name'), parameters('apis_titles_name'))]"
            ]
        }
        
        
        
    ],
    "outputs": {
        "gatewayurl": {
            "type": "string",
            "value": "[resourceId('Microsoft.ApiManagement/service', parameters('service_cust_option1apim_name'))]"
        }
    }
}
DEPLOY

  # these key-value pairs are passed into the ARM Template's `parameters` block
  parameters {
    "primary_region_waf_url" = "${var.traffic_manager_fqdn}"

    "service_cust_option1apim_name" = "${var.service_apim_name}"
  }

  deployment_mode = "Incremental"
}
