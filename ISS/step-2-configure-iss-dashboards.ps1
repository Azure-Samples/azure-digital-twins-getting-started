Param([string]$ResourceGroupName, [string]$iss_bicep_name)

$deployment_job = Get-AzResourceGroupDeployment -ResourceGroupName $ResourceGroupName -Name $iss_bicep_name

if ($null -eq $deployment_job.Outputs.iss_adt_host_name.Value) {
    Write-Error 'Failed to deploy ISS Digital Twins.  Please check the Azure portal for more information.'    
    Exit
}

$iss_adt_instance_name = $deployment_job.Outputs.iss_adt_instance_name.Value 
$iss_adt_history_table = $deployment_job.Outputs.iss_adt_instance_name.Value 
$iss_adx_history_cluster = $deployment_job.Outputs.iss_adx_history_cluster.Value
$iss_adx_history_cluster_db = $deployment_job.Outputs.iss_adx_history_cluster_db.Value
$iss_digital_twins_history_cluster_url = $deployment_job.Outputs.iss_digital_twins_history_cluster_url.Value
$iss_storage_account_name = $deployment_job.Outputs.iss_storage_account_name.Value
$iss_grafana_name = $deployment_job.Outputs.iss_grafana_name.Value
$iss_adt_dashboard_url = $deployment_job.Outputs.iss_adt_dashboard_url.Value

$iss_digital_twin_dashboard_url = "https://$iss_adt_dashboard_url"

Write-Output 'Generating Grafana AAD Credentials'

$iss_app_reg_details = $(az ad sp create-for-rbac -n $iss_adt_instance_name --query "[appId,tenant,password,displayName,objectId]" -o tsv)

$iss_app_id = "" + $iss_app_reg_details[0]
$iss_reply_url_root = "$iss_digital_twin_dashboard_url"
$iss_reply_url_azuread ="$iss_digital_twin_dashboard_url/login/azuread"

## Seem to need to do this as well as sp create-for-rbac in order to update reply urls
az ad sp create  --id $iss_app_id
## Update the reply urls for the app
az ad app update --id $iss_app_id --display-name $iss_adt_instance_name  --reply-urls $iss_reply_url_root $iss_reply_url_azuread 

Write-Output 'Assigning permissions to ISS ADT Service Principal as Reader'

## Assign permissions to the service principal
az role assignment create --assignee $iss_app_id --role Reader

Write-Output 'Adding redirect url to app registration'

Write-Output 'Updating app registration'

#az rest -m patch -u "https://graph.microsoft.com/v1.0/applications/$iss_app_id" --headers 'Content-Type=application/json' -b "$iss_app_patch_body"

Write-Output 'Generating Grafana Azure Data Explorer Connection'
## Update Grafana Datasource Provisioning File - ISS Digital Twins
(Get-Content ./iss-grafana-resources/datasource-template.yml).replace("[SUBSCRIPTION_ID]", $SubscriptionId) | Set-Content ./iss-grafana-resources/datasource.yml
(Get-Content ./iss-grafana-resources/datasource.yml).replace("[ADX_CLUSTER_URL]", $iss_digital_twins_history_cluster_url) | Set-Content ./iss-grafana-resources/datasource.yml
(Get-Content ./iss-grafana-resources/datasource.yml).replace("[CLIENT_ID]", $iss_app_id) | Set-Content ./iss-grafana-resources/datasource.yml
(Get-Content ./iss-grafana-resources/datasource.yml).replace("[TENANT_ID]", $iss_app_reg_details[1]) | Set-Content ./iss-grafana-resources/datasource.yml
(Get-Content ./iss-grafana-resources/datasource.yml).replace("[CLIENT_SECRET]", $iss_app_reg_details[2]) | Set-Content ./iss-grafana-resources/datasource.yml

$iss_history_table = $iss_adt_history_table.Replace("-", "_")

## Update Grafana Example Dashboards
(Get-Content ./iss-grafana-resources/dashboard-templates/iss-position-dashboard-template.json).replace("[ISS_DATABASE_NAME]", $iss_adx_history_cluster_db) | Set-Content ./iss-grafana-resources/iss-position-dashboard.json
(Get-Content ./iss-grafana-resources/dashboard-templates/iss-data-collection-statistics-template.json).replace("[ISS_DATABASE_NAME]", $iss_adx_history_cluster_db) | Set-Content ./iss-grafana-resources/iss-data-collection-statistics-dashboard.json

(Get-Content ./iss-grafana-resources/iss-position-dashboard.json).replace("[ISS_DATABASE_TABLE_NAME]", $iss_history_table) | Set-Content ./iss-grafana-resources/iss-position-dashboard.json
(Get-Content ./iss-grafana-resources/iss-data-collection-statistics-dashboard.json).replace("[ISS_DATABASE_TABLE_NAME]", $iss_history_table) | Set-Content ./iss-grafana-resources/iss-data-collection-statistics-dashboard.json

## Write Grafana Datasource Provisioning File
Write-Output 'Updating Grafana Configurations'
## Stop Grafana Service
Stop-AzWebApp -Name $iss_grafana_name -ResourceGroupName $ResourceGroupName

## Get Existing Grafana Configurations
$iss_grafana_site = Get-AzWebApp -Name $iss_grafana_name
$iss_grafana_settings = ($iss_grafana_site.SiteConfig.AppSettings | ForEach-Object { $h = @{} } { $h[$_.Name] = $_.Value } { $h })

## Apply Azure AD Credentials
$iss_grafana_settings.GF_AUTH_AZUREAD_CLIENT_ID = "" + $iss_app_reg_details[0]
$iss_grafana_settings.GF_AUTH_AZUREAD_TENANT_ID = "" + $iss_app_reg_details[1]
$iss_grafana_settings.GF_AUTH_AZUREAD_CLIENT_SECRET = "" + $iss_app_reg_details[2]
$iss_grafana_settings.GF_AUTH_AZUREAD_TOKEN_URL = $iss_grafana_settings.GF_AUTH_AZUREAD_TOKEN_URL.Replace("[your-tenant-id]", "" + $iss_app_reg_details[1])
$iss_grafana_settings.GF_AUTH_AZUREAD_AUTH_URL = $iss_grafana_settings.GF_AUTH_AZUREAD_AUTH_URL.Replace("[your-tenant-id]", "" + $iss_app_reg_details[1])

Write-Output 'Uploading default grafana db'

## Get the Grafana Storage Account
Set-AzCurrentStorageAccount -ResourceGroupName $ResourceGroupName -StorageAccountName $iss_storage_account_name
## Get the Grafana Fileshare
$fileShare = Get-AzStorageShare -Name 'grafana' 

## Provision Provisioning Directories
New-AzStorageDirectory -ShareName $fileShare.Name -Path "/provisioning"
New-AzStorageDirectory -ShareName $fileShare.Name -Path "/dashboards"
New-AzStorageDirectory -ShareName $fileShare.Name -Path "/provisioning/dashboards" 
New-AzStorageDirectory -ShareName $fileShare.Name -Path "/provisioning/notifiers" 
New-AzStorageDirectory -ShareName $fileShare.Name -Path "/provisioning/datasources" 
New-AzStorageDirectory -ShareName $fileShare.Name -Path "/provisioning/plugins" 

## Upload Fresh Grafana DB
Set-AzStorageFileContent -ShareName $fileShare.Name -Source "./iss-grafana-resources/grafana.db" -Path "/" -Force
## Upload Data Source Provisioning File
Set-AzStorageFileContent -ShareName $fileShare.Name -Source "./iss-grafana-resources/datasource.yml" -Path "/provisioning/datasources/" -Force
## Upload Dashboard Provisioning File
Set-AzStorageFileContent -ShareName $fileShare.Name -Source "./iss-grafana-resources/dashboards.yml" -Path "/provisioning/dashboards/" -Force

## Upload Iss Dashboards
Set-AzStorageFileContent -ShareName $fileShare.Name -Source "./iss-grafana-resources/iss-position-dashboard.json" -Path "/dashboards/" -Force
Set-AzStorageFileContent -ShareName $fileShare.Name -Source "./iss-grafana-resources/iss-data-collection-statistics-dashboard.json" -Path "/dashboards/" -Force

## Delete provisioning.yaml prevent credential leakage
Remove-Item .\\iss-grafana-resources\\datasource.yml
Remove-Item .\\iss-grafana-resources\\iss-position-dashboard.json
Remove-Item .\\iss-grafana-resources\\iss-data-collection-statistics-dashboard.json

## Update Grafana Configurations in Azure
Set-AzWebApp -ResourceGroupName $ResourceGroupName -Name $iss_grafana_name -AppSettings ($iss_grafana_settings)

## Start Grafana Web App
Start-AzWebApp -Name $iss_grafana_name -ResourceGroupName $ResourceGroupName

Write-Output 'Uploaded default gradana db'

Write-Output 'Adding Grafana to ADX as database viewer'

## Add App Registration for Grafana to the correct database as a reader so our queries work
az kusto database add-principal --cluster-name $iss_adx_history_cluster --database-name $iss_adx_history_cluster_db --value name=$iss_adt_instance_name type="App" app-id=$iss_app_id email="" fqn="aadapp="$iss_app_id role="Viewer" --resource-group $ResourceGroupName