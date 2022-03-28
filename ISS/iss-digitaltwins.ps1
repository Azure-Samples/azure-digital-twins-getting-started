Param([string] $SubscriptionId, [string] $ResourceGroupLocation, [string] $ResourceSuffix, [string] $iss_domain)

function CheckAzLogin () {
    $Error.Clear()
    try {
        Get-AzContext    
    }
    catch {
        Connect-AzAccount
        $Error.Clear();    
    }
}

Clear-Host

$host.UI.RawUI.ForegroundColor = "Yellow"

Write-Output ' __       _______.     _______.    _______   __    _______  __  .___________.    ___       __         .___________.____    __    ____  __  .__   __. '
Write-Output '|  |     /       |    /       |   |       \ |  |  /  _____||  | |           |   /   \     |  |        |           |\   \  /  \  /   / |  | |  \ |  | '
Write-Output '|  |    |   (----`   |   (----`   |  .--.  ||  | |  |  __  |  | `---|  |----`  /  ^  \    |  |        `---|  |----` \   \/    \/   /  |  | |   \|  | '
Write-Output '|  |     \   \        \   \       |  |  |  ||  | |  | |_ | |  |     |  |      /  /_\  \   |  |            |  |       \            /   |  | |  . `  | '
Write-Output "|  | .----)   |   .----)   |      |  '--'  ||  | |  |__| | |  |     |  |     /  _____  \  |  `-----.       |  |        \    /\    /    |  | |  |\   | "
Write-Output '|__| |_______/    |_______/       |_______/ |__|  \______| |__|     |__|    /__/     \__\ |_______|       |__|         \__/  \__/     |__| |__| \__| '


$host.UI.RawUI.ForegroundColor = "White"

$ResourceGroupName = 'iss_digital_twins_' + $ResourceSuffix

Write-Output 'Logging in to Azure...'

CheckAzLogin

Write-Output 'Setting Subscription to '+$SubscriptionId

Set-AzContext -Subscription $SubscriptionId

Write-Output 'Creating Resource group '+$ResourceGroupName

az group create --name  $ResourceGroupName --location $ResourceGroupLocation

Write-Output 'Deploying Azure Resoures to Resource group '+$ResourceGroupName

$iss_bicep_template = $(Get-Location).Path + "\\iss-bicep\\iss.azure.bicep"
$iss_deployment_name = "iss.azure"

./step-1-deploy-iss-azure.ps1 $ResourceGroupName $ResourceSuffix $iss_bicep_template $iss_domain
./step-2-configure-iss-dashboards.ps1 $ResourceGroupName $iss_deployment_name
./step-3-configure-iss-data-history.ps1 $ResourceGroupName $iss_deployment_name 
./step-4-publish-iss-applications.ps1 $ResourceGroupName $iss_deployment_name
./step-5-start-iss-digital-twins.ps1 $ResourceGroupName $iss_deployment_name