# terraform-randompet-pet


<!-- BEGIN_TF_DOCS -->


# Azure Function Terraform Module

## Introduction
This specialized module has been developed to enhance the efficiency and user experience in creating Azure Function apps through a streamlined process. It aims to improve speed and ease of use while ensuring security, efficiency, and built-in connectivity. The module supports the creation of both Linux and Windows function apps, offering a variety of pricing plans to cater to diverse requirements. Key features include the ability to create inbound private endpoints, automatically generate outbound subnets (or with user-specified CIDR ranges), seamlessly integrate Azure Application Insights with the Azure Function, and provide flexibility in choosing the desired runtime and runtime versions for the function.

When selecting a pricing plan for your Azure Function, we generally recommend starting with one of the Basic (B1, B2, B3) or Standard (S1, S2, S3) pricing tiers. These tiers are designed to be cost-effective, while still providing a robust set of features suitable for a wide variety of workloads.

The table below shows the available runtimes, and their associated versions for both Windows and Linux function apps.

| Runtime     | Supported Versions (Windows)           | Supported Versions (Linux)                 |
|-------------|--------------------------------------|------------------------------------------|
| Dotnet      | 3.0, 4.0, 6.0, 7.0                    | 3.1, 6.0, 7.0                            |
| Java        | 1.8, 11, 17                           | 8, 11, 17                                |
| Node        | 12, 14, 16, 18                        | 12, 14, 16, 18                           |
| Powershell  | 7, 7.2                                | 7, 7.2                                   |
| Python      | -                                     | 3.11, 3.10, 3.9, 3.8, 3.7                |

**Note:** Only StorageV2 storage account types can be associated with this Azure Function.



## Pre-requisites

This module operates under the assumption that the specified resources have already been provisioned and deployed. Consequently, the module will not initiate the creation of these resources.
- Resource Group
- Virtual Network
- Subnet
- Storage account


## Troubleshooting

This section will undergo continuous updates with the purpose of providing explanations and assistance in resolving common issues or errors that users may encounter while utilizing this module.

## Sample Code


### Windows function app


```hcl
module "resource-group" {
  source  = "app.terraform.io/sseplc/resourcegroup/azure"
  version = "1.1.4" #Insert Latest Version here

  app_name            = "test-app"
  data_classification = "Internal"
  env                 = "dev"
  location            = "uksouth"
  optional_field      = "001"

  supportinfo_app_team = "SSE"
  application_service  = "rg-testing"
  supportinfo_inf_team = "Testing"
  service_tier         = "Standard"

  optional_tags = {
    ApplicationService = "Testing-Dev"
    BusinessUnit       = "CC1"
  }
}

module "subnet-with-nsg" {
  source  = "app.terraform.io/sseplc/subnet-with-nsg/azure"
  version = "1.8.2" #Insert Latest Version here

  location          = "uksouth"
  subnet_name       = "private-endpoint-subnet"
  subnet_cidr_range = "10.224.45.16/28"
}

module "appserviceplan" {
  source  = "app.terraform.io/sseplc/appserviceplan/azure"
  version = "1.2.4" #Insert Latest Version here

  resource_group_name = module.resource-group.name
  location            = "uksouth"
  app_name            = "test-functionapp"
  env                 = "dev"
  pricing_plan        = "B1"
  os_type             = "Windows"
  worker_count        = 3
}

module "storageaccount" {
  source                     = "app.terraform.io/sseplc/storageaccount/azure"
  version                    = "1.5.0" #Insert Latest Version here
  location                   = "uksouth"
  resource_group_name        = module.resource-group.name
  data_classification        = "Internal"
  enable_trusted_services    = true
  env                        = "dev"
  app_name                   = "teststoragename"
  optional_field             = "007"
  private_endpoint_subnet_id = module.subnet-with-nsg.subnet_id
}


module "azure_functions" {
  source  = "app.terraform.io/sseplc/functionapp/azure"
  version = "1.7.0" #Insert Latest Version here

  depends_on          = [module.resource-group, module.subnet-with-nsg.subnet_id]
  os_type             = "Windows"
  location            = "uksouth"
  env                 = "dev"
  resource_group_name = module.resource-group.name
  app_name            = "test-function-app"
  data_classification = "Internal"
  optional_field      = "012"
  app_service_plan_id = module.appserviceplan.app_service_id
  application_type    = "other"
  
  function_app_subnet_id = var.function_app_subnet_id # Update the function_app_subnet_id variable value with your existing function app subnet id in dev.auto.tfvars file.

  private_endpoint_subnet_id = module.subnet-with-nsg.subnet_id

  storage_connection_string = module.storageaccount.connection_string

  runtime         = "dotnet"
  runtime_version = "4.0"

}
```

### Linux function app

```hcl
module "resource-group" {
  source  = "app.terraform.io/sseplc/resourcegroup/azure"
  version = "1.1.4" #Insert Latest Version here

  app_name            = "test-app"
  data_classification = "Internal"
  env                 = "dev"
  location            = "uksouth"
  optional_field      = "001"

  supportinfo_app_team = "SSE"
  application_service  = "rg-testing"
  supportinfo_inf_team = "Testing"
  service_tier         = "Standard"

  optional_tags = {
    ApplicationService = "Testing-Dev"
    BusinessUnit       = "CC1"
  }
}

module "subnet-with-nsg" {
  source  = "app.terraform.io/sseplc/subnet-with-nsg/azure"
  version = "1.8.2" #Insert Latest Version here

  location          = "uksouth"
  subnet_name       = "private-endpoint-subnet"
  subnet_cidr_range = "10.224.46.16/28"
}

module "appserviceplan" {
  source  = "app.terraform.io/sseplc/appserviceplan/azure"
  version = "1.2.4" #Insert Latest Version here

  resource_group_name = module.resource-group.name
  location            = "uksouth"
  app_name            = "test-linux-asp"
  env                 = "dev"
  pricing_plan        = "B1"
  os_type             = "Linux"
  worker_count        = 3
}

module "storageaccount" {
  source                     = "app.terraform.io/sseplc/storageaccount/azure"
  version                    = "1.5.0" #Insert Latest Version here
  location                   = "uksouth"
  resource_group_name        = module.resource-group.name
  data_classification        = "Internal"
  enable_trusted_services    = true
  env                        = "dev"
  app_name                   = "teststorage"
  optional_field             = "007"
  private_endpoint_subnet_id = module.subnet-with-nsg.subnet_id
}

module "azure_functions" {
  source  = "app.terraform.io/sseplc/functionapp/azure"
  version = "1.7.0" #Insert Latest Version here
  
  depends_on = [module.resource-group, module.subnet-with-nsg]

  os_type             = "Linux"
  location            = "uksouth"
  env                 = "dev"
  resource_group_name = module.resource-group.name
  app_name            = "test-linux-functionapp"
  data_classification = "Internal"
  optional_field      = "007"
  app_service_plan_id = module.appserviceplan.app_service_id
  application_type    = "other"
  
  function_app_subnet_id = var.function_app_subnet_id # Update the function_app_subnet_id variable value with your existing function app subnet id in dev.auto.tfvars file.
  
  private_endpoint_subnet_id = module.subnet-with-nsg.subnet_id
  
  storage_connection_string = module.storageaccount.connection_string
  
  runtime         = "python"
  runtime_version = "3.10"
}


```

### ASE Supported function app

```hcl
module "resourcegroup" {
  source  = "app.terraform.io/sseplc/resourcegroup/azure"
  version = "1.1.4" #Insert Latest Version here

  location             = "uksouth"
  app_name             = "functionapp"
  data_classification  = "Internal"
  env                  = "dev"
  optional_field       = "314"
  supportinfo_app_team = "module-development"
  application_service  = "module-development"
  supportinfo_inf_team = "module-development"
  service_tier         = "module-development"
}

module "subnet-with-nsg" {
  source  = "app.terraform.io/sseplc/subnet-with-nsg/azure"
  version = "1.8.2" #Insert Latest Version here

  location          = "uksouth"
  subnet_name       = "logic-app"
  subnet_cidr_range = "10.224.45.16/28"
}

module "storage_account" {
  source  = "app.terraform.io/sseplc/storageaccount/azure"
  version = "1.5.0" #Insert Latest Version here

  location            = module.resourcegroup.location
  resource_group_name = module.resourcegroup.name
  data_classification = "Internal"
  account_type        = "StorageV2"
  replication_type    = "LRS"
  env                 = "dev"
  app_name            = "logicappdev"

  private_endpoint_subnet_id = module.subnet-with-nsg.subnet_id

  depends_on = [
    module.subnet-with-nsg,
    module.resourcegroup,
  ]
}

module "appserviceplan" {
  source  = "app.terraform.io/sseplc/appserviceplan/azure"
  version = "1.2.4" #Insert Latest Version here

  resource_group_name = module.resourcegroup.name
  location            = "uksouth"
  app_name            = "logicapp"
  env                 = "dev"
  pricing_plan        = "I1"
  os_type             = "Windows"
  optional_field      = "002"
  ase_id              = "/subscriptions/268e4f6e-2828-4f50-aa55-5222943c99d5/resourceGroups/asetestingb905vb-rg/providers/Microsoft.Web/hostingEnvironments/ase-appserviceb905vb-dev-uks-arr"
}

module "azure_functions" {
  source  = "app.terraform.io/sseplc/functionapp/azure"
  version = "1.6.1" #Insert Latest Version here

  location            = "uksouth"
  resource_group_name = module.resourcegroup.name
  env                 = "dev"
  app_name            = "logicappABCDEF"
  data_classification = "Internal"

  os_type                   = "Linux"
  runtime                   = "python"
  runtime_version           = "3.10"
  storage_connection_string = module.storage_account.connection_string

  app_service_plan_id        = module.appserviceplan.app_service_id
  app_service_environment_id = "/subscriptions/268e4f6e-2828-4f50-aa55-5222943c99d5/resourceGroups/asetestingb905vb-rg/providers/Microsoft.Web/hostingEnvironments/ase-appserviceb905vb-dev-uks-arr"
  application_type           = "other"
}
```



## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.7 |
| <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) | >=1.6.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >=3.65.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >=3.1.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_app-insights"></a> [app-insights](#module\_app-insights) | app.terraform.io/sseplc/applicationinsights/azure | 1.0.0 |
| <a name="module_privatendpoint"></a> [privatendpoint](#module\_privatendpoint) | app.terraform.io/sseplc/privateendpoint/azure | 1.1.2 |
| <a name="module_subscriptionmetadata"></a> [subscriptionmetadata](#module\_subscriptionmetadata) | app.terraform.io/sseplc/subscriptionmetadata/azure | 1.0.2 |

## Resources

| Name | Type |
|------|------|
| [azurerm_linux_function_app.this](https://registry.terraform.io/providers/azurerm/latest/docs/resources/linux_function_app) | resource |
| [azurerm_storage_share.fileshare](https://registry.terraform.io/providers/azurerm/latest/docs/resources/storage_share) | resource |
| [azurerm_windows_function_app.this](https://registry.terraform.io/providers/azurerm/latest/docs/resources/windows_function_app) | resource |
| [random_string.random](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [azurerm_virtual_network.identify_dns_servers](https://registry.terraform.io/providers/azurerm/latest/docs/data-sources/virtual_network) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_name"></a> [app\_name](#input\_app\_name) | This free-form field, affixed to the resource name, should appropriately reflect the application or service with which it is associated. | `string` | n/a | yes |
| <a name="input_app_service_plan_id"></a> [app\_service\_plan\_id](#input\_app\_service\_plan\_id) | The ID of the application service plan that will be used by the function app. | `string` | n/a | yes |
| <a name="input_data_classification"></a> [data\_classification](#input\_data\_classification) | The data classification of the function app and associated data. Will appear as a tag and must follow SSE standards. Accepted values are Public, Internal, Confidential or HighlyConfidential. | `string` | n/a | yes |
| <a name="input_env"></a> [env](#input\_env) | The environment the resource will be deployed into. Accepted values are dev, uat, prd, sbx, sit, fit, int, nft, trn, pre or npd. | `string` | n/a | yes |
| <a name="input_os_type"></a> [os\_type](#input\_os\_type) | The OS type associated with the function app. Accepted values are Windows or Linux. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group in which the function app will be provisioned. | `string` | n/a | yes |
| <a name="input_runtime"></a> [runtime](#input\_runtime) | The runtime associated with the function app. Valid values are 'node', 'dotnet', 'java', 'powershell', and 'python'. | `string` | n/a | yes |
| <a name="input_runtime_version"></a> [runtime\_version](#input\_runtime\_version) | The version of the runtime associated with the function app. The valid version depends on the selected runtime. For example, for 'node', valid values are '12', '14', '16', and '18'. Please see the table in the `introduction` section for the valid values for each runtime. | `string` | n/a | yes |
| <a name="input_storage_connection_string"></a> [storage\_connection\_string](#input\_storage\_connection\_string) | The connection string for the storage account to allow the function app to connect to the storage account. This will be the function app's storage account to store function app code and logs. | `string` | n/a | yes |
| <a name="input_always_on"></a> [always\_on](#input\_always\_on) | Enable or disable always on feature of the funtion app. Default is false. | `bool` | `false` | no |
| <a name="input_app_service_environment_id"></a> [app\_service\_environment\_id](#input\_app\_service\_environment\_id) | The ID of the App Service Environment to be used for the function app. If passed, the function app will deploy with ASE support, meaning no creation of private endpoints or additional subnets for VNet integrations. | `string` | `""` | no |
| <a name="input_application_insights_instrumentation_key"></a> [application\_insights\_instrumentation\_key](#input\_application\_insights\_instrumentation\_key) | The instrumentation key of the application insights resource to be associated with the function app. If not provided, module will create a new application insights resource and associate it with function app. | `string` | `null` | no |
| <a name="input_application_type"></a> [application\_type](#input\_application\_type) | (Required if deploying a new App Insights instance with the Function App) Specifies the type of Application Insights to create. Valid values are ios for iOS, java for Java web, MobileCenter for App Center, Node.JS for Node.js, other for General, phone for Windows Phone, store for Windows Store and web for ASP.NET. Please note these values are case sensitive; unmatched values are treated as ASP.NET by Azure. Changing this forces a new resource to be created. | `string` | `null` | no |
| <a name="input_custom_app_settings"></a> [custom\_app\_settings](#input\_custom\_app\_settings) | A map variable to configure any additional app settings required by the function app. Please see the custom\_app\_settings section below for more information. | `map(string)` | `{}` | no |
| <a name="input_custom_file_share"></a> [custom\_file\_share](#input\_custom\_file\_share) | The name of a pre-created fileshare associated with the storage account. If not provided, module will create a new fileshare and associate it with function app. | `string` | `""` | no |
| <a name="input_disable_private_endpoint"></a> [disable\_private\_endpoint](#input\_disable\_private\_endpoint) | [ADVANCED\_SETTING] Boolean flag to disable the private endpoint. By default this is false, and the module will try to create a private endpoint. If set to false, the module will not create a private endpoint. | `bool` | `false` | no |
| <a name="input_enable_ssl_offloading"></a> [enable\_ssl\_offloading](#input\_enable\_ssl\_offloading) | Enable or disable SSL offloading. If true https\_only setting will be disabled to allow for SSL offloading. Default is false. | `bool` | `false` | no |
| <a name="input_function_app_subnet_id"></a> [function\_app\_subnet\_id](#input\_function\_app\_subnet\_id) | The ID of the existing subnet used for provisioning the function apps, BU users can pass their existing subnet ID value. | `string` | `null` | no |
| <a name="input_function_enable"></a> [function\_enable](#input\_function\_enable) | Enable or disable the funtion app. Default is True which means the function app is enabled. | `bool` | `true` | no |
| <a name="input_identity_principal_type"></a> [identity\_principal\_type](#input\_identity\_principal\_type) | The identity type to be associated with the function app. Accepted values are 'UserAssigned', 'SystemAssigned', 'SystemAssigned, UserAssigned' or 'none'. | `string` | `"none"` | no |
| <a name="input_ip_restriction"></a> [ip\_restriction](#input\_ip\_restriction) | [ADVANCED\_SETTING] Configure the IP restrictions for the function app | <pre>list(object({<br>    name                      = string<br>    ip_address                = string<br>    service_tag               = string<br>    virtual_network_subnet_id = string<br>    priority                  = string<br>    action                    = string<br>    headers = list(object({<br>      x_azure_fdid      = list(string)<br>      x_fd_health_probe = list(string)<br>      x_forwarded_for   = list(string)<br>      x_forwarded_host  = list(string)<br>    }))<br>  }))</pre> | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | The Azure region in which the function app will be provisioned. Accepted values are uksouth, ukwest, northeurope or westeurope. | `string` | `"uksouth"` | no |
| <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id) | (Required if deploying a new App Insights instance with the Function App) Log Analytics Workspace based workspace id | `string` | `null` | no |
| <a name="input_optional_field"></a> [optional\_field](#input\_optional\_field) | This free-form field, affixed to the resource name, allows for added flexibility in naming conventions. Allowed characters are a-z, A-Z, 0-9 and - | `string` | `""` | no |
| <a name="input_optional_tags"></a> [optional\_tags](#input\_optional\_tags) | A map variable that defines additional optional tags to be assigned to the function app. eg: `optional_tags = {BU = 'Finance', Owner = 'John Doe'}` | `map(string)` | `{}` | no |
| <a name="input_private_endpoint_subnet_id"></a> [private\_endpoint\_subnet\_id](#input\_private\_endpoint\_subnet\_id) | ID of the subnet used for provisioning the private endpoints of the storage account | `string` | `""` | no |
| <a name="input_restrict_inbound_access_to_afd"></a> [restrict\_inbound\_access\_to\_afd](#input\_restrict\_inbound\_access\_to\_afd) | Restrict inbound traffic to Azure Front Door. | `bool` | `false` | no |
| <a name="input_use_32_bit_worker_linux"></a> [use\_32\_bit\_worker\_linux](#input\_use\_32\_bit\_worker\_linux) | Should the function app use a 32-bit worker process | `bool` | `false` | no |
| <a name="input_use_32_bit_worker_windows"></a> [use\_32\_bit\_worker\_windows](#input\_use\_32\_bit\_worker\_windows) | Should the function app use a 32-bit worker process | `bool` | `true` | no |
| <a name="input_user_assigned_identity_ids"></a> [user\_assigned\_identity\_ids](#input\_user\_assigned\_identity\_ids) | The IDs of the user assigned managed identities to be associated with the function app. This variable is only used when identity\_principal\_type is set to 'UserAssigned' or 'SystemAssigned, UserAssigned'. | `list(string)` | `[]` | no |

## custom_app_settings
Please refer to the [official documentation](https://docs.microsoft.com/en-us/azure/azure-functions/functions-app-settings) for more information on the available application settings.

Please note that the following application settings are automatically generated by the module and should not be specified in the custom_app_settings variable:
- APPINSIGHTS_INSTRUMENTATIONKEY
- AzureWebJobsDashboard
- AzureWebJobsStorage
- FUNCTIONS_WORKER_RUNTIME
- WEBSITE_CONTENTAZUREFILECONNECTIONSTRING
- WEBSITE_CONTENTOVERVNET
- WEBSITE_CONTENTSHARE
- WEBSITE_DNS_SERVER

The table below outlines some of the frequently used application settings available for configuring your Azure Function App. However, it is important to note that this does not represent an exhaustive list. For a comprehensive overview, including detailed examples and in-depth explanations of each setting, as well as their default states, it is recommended to consult the official documentation.

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| WEBSITE_NODE_DEFAULT_VERSION | The default version of Node.js used by the function app. | string | null | no |
| WEBSITE_RUN_FROM_PACKAGE | Specifies whether the function app runs from a package. | string | 0 | no |
| WEBSITE_SLOT_NAME | The name of the deployment slot used by the function app. | string | null | no |
| WEBSITE_TIME_ZONE | The time zone used by the function app. | string | null | no |
| WEBSITE_USE_ZIP | Specifies whether the function app uses a zip file. | string | 0 | no |
| WEBSITE_WEBDEPLOY_USE_SCM | Specifies whether the function app uses source control. | string | 0 | no |
| AzureWebJobsDisableHomepage | Disables the default home page for the function app. | string | 0 | no |
| ENABLE_ORYX_BUILD | Enables Oryx build for the function app. | string | 0 | no |
| SCM_DO_BUILD_DURING_DEPLOYMENT | Specifies whether to build the function app during deployment. | string | 0 | no |


## Outputs

| Name | Description |
|------|-------------|
| <a name="output_default_hostname"></a> [default\_hostname](#output\_default\_hostname) | Default hostname belonging to resource. |
| <a name="output_function_app_id"></a> [function\_app\_id](#output\_function\_app\_id) | Function app ID for the function app created by the terraform module. |
| <a name="output_function_app_principal_id"></a> [function\_app\_principal\_id](#output\_function\_app\_principal\_id) | Principal ID of the Function app. This output will only be populated when identity\_principal\_type is not null. |
| <a name="output_function_kind"></a> [function\_kind](#output\_function\_kind) | What type of app resource has been provisioned. |
| <a name="output_function_name"></a> [function\_name](#output\_function\_name) | Function app name |
| <a name="output_instrumentation_key"></a> [instrumentation\_key](#output\_instrumentation\_key) | The Instrumentation Key for this Application Insights component. |
<!-- END_TF_DOCS -->
