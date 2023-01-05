Param([string]$ResourceGroupName,[string]$iss_bicep_name)

$deployment_job = Get-AzResourceGroupDeployment -ResourceGroupName $ResourceGroupName -Name $iss_bicep_name

if ($null -eq $deployment_job.Outputs.iss_adt_host_name.Value) {
    Write-Error 'Failed to deploy ISS Digital Twins.  Please check the Azure portal for more information.'    
    Exit
}

$iss_adt_instance_name = $deployment_job.Outputs.iss_adt_instance_name.Value 
$iss_adt_principal_id = $deployment_job.Outputs.iss_adt_principal_id.Value 
$iss_adx_history_cluster = $deployment_job.Outputs.iss_adx_history_cluster.Value
$iss_adx_history_cluster_db = $deployment_job.Outputs.iss_adx_history_cluster_db.Value
$iss_adt_egress_event_hub = $deployment_job.Outputs.iss_adt_egress_event_hub.Value
$iss_adt_ingress_event_hub_namespace = $deployment_job.Outputs.iss_adt_ingress_event_hub_namespace.Value
$iss_digital_twins_history_identity_id = $deployment_job.Outputs.iss_digital_twins_history_identity_id
$iss_data_history_table_name = $iss_adt_instance_name.replace("-","_") 

Write-Output 'Making current user owner of  '$iss_adt_instance_name

$Azcontext = Get-AzContext    
$myId = $Azcontext[0].Account

az kusto database add-principal --cluster-name $iss_adx_history_cluster --database-name $iss_adx_history_cluster_db --value name=$iss_adt_instance_name type="App" app-id=$iss_adt_principal_id role="Admin" fqn="aadapp=$iss_adt_principal_id" --resource-group $ResourceGroupName

Write-Output 'Configuring Azure Digital Twins Data History'

## Setup Azure Digital Twins Data History
az dt data-history connection create adx -n $iss_adt_instance_name --cn "adtdatahistory" --adx-cluster-name $iss_adx_history_cluster --adx-database-name $iss_adx_history_cluster_db --adx-table-name $iss_data_history_table_name --eventhub $iss_adt_egress_event_hub --eventhub-namespace $iss_adt_ingress_event_hub_namespace

