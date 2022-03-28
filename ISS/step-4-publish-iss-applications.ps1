Param([string]$ResourceGroupName,[string]$iss_bicep_name)

$deployment_job = Get-AzResourceGroupDeployment -ResourceGroupName $ResourceGroupName -Name $iss_bicep_name

if ($null -eq $deployment_job.Outputs.iss_adt_host_name.Value) {
    Write-Error 'Failed to deploy ISS Digital Twins.  Please check the Azure portal for more information.'    
    Exit
}

$iss_telemetry_adapter_name = $deployment_job.Outputs.iss_telemetry_adapter_name.Value 
$iss_position_adapter_name = $deployment_job.Outputs.iss_position_adapter_name.Value
$iss_signalr_broadcaster_name = $deployment_job.Outputs.iss_signalr_broadcaster_name.Value 
$iss_ingestor_name = $deployment_job.Outputs.iss_ingestor_name.Value

Remove-Item -Recurse -Force .\\iss-applications

## Create Application Deployment Directory - and set scope to it
mkdir iss-applications
Set-Location iss-applications

Write-Output 'deploying iss telemetry adapter to '+$iss_telemetry_adapter_name

git clone https://github.com/WaywardHayward/iss_azure_data_adapter

Set-Location iss_azure_data_adapter

dotnet publish -c Release -f netcoreapp3.1 -o ./publish -r linux-x64 --self-contained true

Compress-Archive -Path ./publish/* -DestinationPath publish.zip

$iss_telemetry_adapter_zip = $(Get-Location).Path + "\\publish.zip"

$iss_telemetry_app = Get-AzWebApp -Name $iss_telemetry_adapter_name -ResourceGroupName $ResourceGroupName
Write-Output "Stopping Web App "+$iss_telemetry_adapter_name
Stop-AzWebApp -WebApp  $iss_telemetry_app
Write-Output "Publishing Web App "+$iss_telemetry_adapter_name
Publish-AzWebApp -WebApp $iss_telemetry_app -ArchivePath $iss_telemetry_adapter_zip -Force 
Write-Output "Starting Web App "+$iss_telemetry_adapter_name
Start-AzWebApp -WebApp  $iss_telemetry_app

Write-Output 'deploying iss-location-ingestor to '+$iss_position_adapter_name

Set-Location ..

git clone https://github.com/WaywardHayward/iss-location-ingestor

Set-Location iss-location-ingestor

dotnet publish -c Release -o ./publish -r linux-x64 --self-contained true

Compress-Archive -Path ./publish/* -DestinationPath publish.zip

$iss_position_adapter_zip = $(Get-Location).Path + "\\publish.zip"

$iss_position_app = Get-AzWebApp -Name $iss_position_adapter_name -ResourceGroupName $ResourceGroupName
Write-Output "Stopping Web App "+$iss_position_adapter_name
Stop-AzWebApp -WebApp  $iss_position_app
Write-Output "Publishing Web App "+$iss_position_adapter_name
Publish-AzWebApp -WebApp $iss_position_app -ArchivePath $iss_position_adapter_zip -Force
Write-Output "Starting Web App "+$iss_position_adapter_name
Start-AzWebApp -WebApp  $iss_position_app

Set-Location ..

Write-Output 'deploying iss-auto-ingestor'

git clone https://github.com/WaywardHayward/adt-auto-ingestor

Set-Location adt-auto-ingestor/src

func azure functionapp publish $iss_ingestor_name --csharp 

Write-Output 'deploying iss-signalr-broadcaster'

Set-Location ..
Set-Location ..

git clone https://github.com/WaywardHayward/adt-signalr-broadcaster

Set-Location adt-signalr-broadcaster


Set-Location ..

func azure functionapp publish $iss_signalr_broadcaster_name --csharp
