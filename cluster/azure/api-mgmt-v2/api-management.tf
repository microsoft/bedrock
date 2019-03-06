resource "azurerm_resource_group" "api_mgmt_rg" {
  name     = "${var.api_management_resource_group_name}"
  location = "${var.region}"
}

resource "azurerm_template_deployment" "api_mgmt_deployment" {
  name                = "apiterraarmdeploy"
  resource_group_name = "${azurerm_resource_group.api_mgmt_rg.name}"

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
        "apis_titles_name": {
            "defaultValue": "titles",
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
        "apis_titles_name_1": {
            "defaultValue": "titles",
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
        },
        "secondary_region_waf_url": {
            "type": "string",
            "defaultValue": ""
        },
        "tertiary_region_waf_url": {
            "type": "string",
            "defaultValue": ""
        }

    },
    "variables": {
        "primary_region_waf_fqdn": "[replace(parameters('primary_region_waf_url'),'http://','')]",
        "secondary_region_waf_fqdn": "[replace(parameters('secondary_region_waf_url'),'http://','')]",
        "tertiary_region_waf_fqdn": "[replace(parameters('tertiary_region_waf_url'),'http://','')]"

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
                "publisherEmail": "sudhiraw@microsoft.com",
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
            "name": "[concat(parameters('service_cust_option1apim_name'), '/', parameters('apis_titles_name'))]",
            "apiVersion": "2018-01-01",
            "scale": null,
            "properties": {
                "displayName": "[concat(parameters('apis_titles_name'),'Titles', parameters('apis_titles_name'))]",
                "apiRevision": "1",
                "description": "",
                "serviceUrl": "http://wafoptionone.centralus.cloudapp.azure.com",
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
            "type": "Microsoft.ApiManagement/service/policies",
            "name": "[concat(parameters('service_cust_option1apim_name'), '/', parameters('policies_policy_name'))]",
            "apiVersion": "2018-01-01",
            "scale": null,
            "properties": {
                "policyContent": "[concat('<!--\r\n    IMPORTANT:\r\n    - Policy elements can appear only within the <inbound>, <outbound>, <backend> section elements.\r\n    - Only the <forward-request> ', parameters('policies_policy_name'),' element can appear within the <backend> section element.\r\n    - To apply a ', parameters('policies_policy_name'),' to the incoming request (before it is forwarded to the backend service), place a corresponding ', parameters('policies_policy_name'),' element within the <inbound> section element.\r\n    - To apply a ', parameters('policies_policy_name'),' to the outgoing response (before it is sent back to the caller), place a corresponding ', parameters('policies_policy_name'),' element within the <outbound> section element.\r\n    - To add a ', parameters('policies_policy_name'),' position the cursor at the desired insertion point and click on the round button associated with the ', parameters('policies_policy_name'),'.\r\n    - To remove a ', parameters('policies_policy_name'),', delete the corresponding ', parameters('policies_policy_name'),' statement from the ', parameters('policies_policy_name'),' document.\r\n    - Policies are applied in the order of their appearance, from the top down.\r\n-->\r\n<policies>\r\n  <inbound />\r\n  <backend>\r\n    <forward-request />\r\n  </backend>\r\n  <outbound />\r\n</policies>')]",
                "contentFormat": "xml"
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
                "displayName": "[concat(parameters('operations_gettitles_name'),'getTitles', parameters('operations_gettitles_name'))]",
                "method": "GET",
                "urlTemplate": "/titles",
                "templateParameters": [],
                "description": "",
                "responses": []
            },
            "dependsOn": [
                "[resourceId('Microsoft.ApiManagement/service', parameters('service_cust_option1apim_name'))]",
                "[resourceId('Microsoft.ApiManagement/service/apis', parameters('service_cust_option1apim_name'), parameters('apis_titles_name'))]"
            ]
        },
        {
            "type": "Microsoft.ApiManagement/service/apis/operations/policies",
            "name": "[concat(parameters('service_cust_option1apim_name'), '/', parameters('apis_titles_name'), '/', parameters('operations_gettitles_name'), '/', parameters('policies_policy_name_2'))]",
            "apiVersion": "2018-06-01-preview",
            "scale": null,
            "properties": {
                "policyContent": "[concat('<!--\r\n    IMPORTANT:\r\n    - Policy elements can appear only within the <inbound>, <outbound>, <backend> section elements.\r\n    - To apply a ', parameters('policies_policy_name_2'),' to the incoming request (before it is forwarded to the backend service), place a corresponding ', parameters('policies_policy_name_2'),' element within the <inbound> section element.\r\n    - To apply a ', parameters('policies_policy_name_2'),' to the outgoing response (before it is sent back to the caller), place a corresponding ', parameters('policies_policy_name_2'),' element within the <outbound> section element.\r\n    - To add a ', parameters('policies_policy_name_2'),', place the cursor at the desired insertion point and select a ', parameters('policies_policy_name_2'),' from the sidebar.\r\n    - To remove a ', parameters('policies_policy_name_2'),', delete the corresponding ', parameters('policies_policy_name_2'),' statement from the ', parameters('policies_policy_name_2'),' document.\r\n    - Position the <base> element within a section element to inherit all policies from the corresponding section element in the enclosing scope.\r\n    - Remove the <base> element to prevent inheriting policies from the corresponding section element in the enclosing scope.\r\n    - Policies are applied in the order of their appearance, from the top down.\r\n    - Comments within ', parameters('policies_policy_name_2'),' elements are not supported and may disappear. Place your comments between ', parameters('policies_policy_name_2'),' elements or at a higher level scope.\r\n-->\r\n<policies>\r\n  <inbound>\r\n    <!--\r\n        -  Below inbound logic routes request to nearest region.\r\n    -->\r\n    <base />\r\n    <choose>\r\n      <when condition=\"@(&quot;West US&quot;.Equals(context.Deployment.Region, StringComparison.OrdinalIgnoreCase))\">\r\n        <set-backend-service base-url=\"',parameters('primary_region_waf_url'),'\" />\r\n      </when>\r\n      <when condition=\"@(&quot;East US&quot;.Equals(context.Deployment.Region, StringComparison.OrdinalIgnoreCase))\">\r\n        <set-backend-service base-url=\"',parameters('secondary_region_waf_url'),'\" />\r\n      </when>\r\n      <otherwise>\r\n        <set-backend-service base-url=\"',parameters('tertiary_region_waf_url'),'\" />\r\n      </otherwise>\r\n    </choose>\r\n  </inbound>\r\n  <backend>\r\n    <!--\r\n            - Below retry logic acts if requested region (let say WestUS) is not available then route to second region (East US).\r\n            - If second region (\"East US\") is not available then route to third region (Central US).\r\n            - If third region is not available then there is serious problem and Manual check is required.  \r\n        -->\r\n    <retry condition=\"@(context.Response.StatusCode &gt;= 12500)\" count=\"1\" interval=\"0\" first-fast-retry=\"true\">\r\n      <choose>\r\n        <when condition=\"@(&quot;',variables('tertiary_region_waf_fqdn'),'&quot;.Equals(context.Request.Url.Host.ToString()) &amp;&amp; context.Response.StatusCode &gt;= 500 )\">\r\n          <set-backend-service base-url=\"',parameters('secondary_region_waf_url'),'\" />\r\n        </when>\r\n      </choose>\r\n      <forward-request />\r\n      <choose>\r\n        <when condition=\"@(&quot;',variables('secondary_region_waf_fqdn'),'&quot;.Equals(context.Request.Url.Host.ToString()) &amp;&amp; context.Response.StatusCode &gt;= 500 )\">\r\n          <set-backend-service base-url=\"',parameters('primary_region_waf_url'),'\" />\r\n        </when>\r\n      </choose>\r\n      <forward-request />\r\n      <choose>\r\n        <when condition=\"@(&quot;',variables('primary_region_waf_fqdn'),'&quot;.Equals(context.Request.Url.Host.ToString()) &amp;&amp; context.Response.StatusCode &gt;= 500 )\">\r\n          <set-backend-service base-url=\"',parameters('tertiary_region_waf_url'),'\" />\r\n        </when>\r\n      </choose>\r\n      <forward-request />\r\n    </retry>\r\n  </backend>\r\n  <outbound>\r\n    <base />\r\n    <!--\r\n        <set-header name=\"ErrorSource\" exists-action=\"override\">\r\n            <value>@(context.Request.Url.Path + context.Request.Url.QueryString )</value>\r\n        </set-header>\r\n        <set-header name=\"ErrorReason\" exists-action=\"override\">\r\n            <value>@(context.Request.Url.Host)</value>\r\n        </set-header>\r\n    -->\r\n  </outbound>\r\n  <on-error>\r\n    <base />\r\n  </on-error>\r\n</policies>')]",
                "contentFormat": "xml"
            },
            "dependsOn": [
                "[resourceId('Microsoft.ApiManagement/service', parameters('service_cust_option1apim_name'))]",
                "[resourceId('Microsoft.ApiManagement/service/apis', parameters('service_cust_option1apim_name'), parameters('apis_titles_name'))]",
                "[resourceId('Microsoft.ApiManagement/service/apis/operations', parameters('service_cust_option1apim_name'), parameters('apis_titles_name'), parameters('operations_gettitles_name'))]"
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
    "primary_region_waf_url" = "${var.primary_region_waf_url}"
    "secondary_region_waf_url" = "${var.secondary_region_waf_url}"
    "tertiary_region_waf_url" = "${var.tertiary_region_waf_url}"
    "service_cust_option1apim_name" = "${var.service_cust_option1apim_name}"

  }

  deployment_mode = "Incremental"
}

output "gatewayurl" {
    value = "${lookup(azurerm_template_deployment.api_mgmt_deployment.outputs, "gatewayurl")}"
#   value = "${lookup(azurerm_template_deployment.test.outputs, "storageAccountName")}"
}