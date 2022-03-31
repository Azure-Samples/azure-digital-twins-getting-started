Params([string] $ResourceGroupName, [string] $iss_deployment_name)

$deployment_job = Get-AzResourceGroupDeployment -ResourceGroupName $ResourceGroupName -Name $iss_deployment_name

if ($null -eq $deployment_job.Outputs.iss_adt_host_name.Value) {
    Write-Error 'Failed to deploy ISS Digital Twins.  Please check the Azure portal for more information.'    
    Exit
}

$iss_signalr_broadcaster_url = $deployment_job.Outputs.iss_signalr_broadcaster_url.Value

Write-Output 'Updating Hololens App Credentials'

(Get-Content ./iss-hololens/Assets/Scripts/Signalr/ADTDataHandler.cs).replace("[SIGNALR_URL]", $iss_signalr_broadcaster_url) | Set-Content ./iss-hololens/Assets/Scripts/Signalr/ADTDataHandler.cs
