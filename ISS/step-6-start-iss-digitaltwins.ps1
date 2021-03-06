Param([string] $ResourceGroupName, [string] $iss_deployment_name)

$deployment_job = Get-AzResourceGroupDeployment -ResourceGroupName $ResourceGroupName -Name $iss_deployment_name

if ($null -eq $deployment_job.Outputs.iss_adt_host_name.Value) {
    Write-Error 'Failed to deploy ISS Digital Twins.  Please check the Azure portal for more information.'    
    Exit
}

$iss_adt_instance_hostname = $deployment_job.Outputs.iss_adt_host_name.Value
$iss_adt_dashboard_url = $deployment_job.Outputs.iss_adt_dashboard_url.Value
$iss_adx_history_cluster = $deployment_job.Outputs.iss_adx_history_cluster.Value
$iss_adx_history_cluster_db = $deployment_job.Outputs.iss_adx_history_cluster_db.Value
$iss_digital_twins_history_cluster_url = $deployment_job.Outputs.iss_digital_twins_history_cluster_url.Value
$iss_grafana_name = $deployment_job.Outputs.iss_grafana_name.Value

$iss_kusto_host =  $iss_digital_twins_history_cluster_url.replace("https://","").split('.')[0];
$iss_kusto_location =$iss_digital_twins_history_cluster_url.replace("https://","").split('.')[1];

$iss_digital_twin_explorer_url = "https://explorer.digitaltwins.azure.net?eid=$iss_adt_instance_hostname&query=Select%20*%20From%20DigitalTwins"
$iss_adx_cluster_url = "https://dataexplorer.azure.com/clusters/$iss_kusto_host.$iss_kusto_location/"
$iss_digital_twin_data_url =  "$iss_adx_cluster_url/databases/$iss_adx_history_cluster_db"
$iss_digital_twin_dashboard_url = "https://$iss_adt_dashboard_url" 

$iss_grafana_site = Get-AzWebApp -Name $iss_grafana_name
$iss_grafana_settings = ($iss_grafana_site.SiteConfig.AppSettings | ForEach-Object { $h = @{} } { $h[$_.Name] = $_.Value } { $h })
$iss_digital_twin_dashboard_password = $iss_grafana_settings.GF_SECURITY_ADMIN_PASSWORD

Write-Information 'Houston We Have Lift Off!!!'
Write-Output 'ISS Digital Twin Sucessfully Provisioned' 
Write-Output "Your ISS Digital Twin instance is here: $iss_digital_twin_explorer_url"
Write-Output "Your ISS Digital Twin dashboard is here: $iss_digital_twin_dashboard_url"
Write-Output "    Use the following credentials to login:"
Write-Output "    Username: admin"
Write-Output "    Password: $iss_digital_twin_dashboard_password"
Write-Output "Your ISS Digital Twin data is here: $iss_digital_twin_data_url"

Start-Process $iss_digital_twin_explorer_url
Start-Process $iss_digital_twin_dashboard_url
Start-Process $iss_digital_twin_data_url
