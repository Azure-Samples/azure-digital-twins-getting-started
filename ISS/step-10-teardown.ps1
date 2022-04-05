
Param([string]$ResourceGroupName, [string] $deploymentName)

Write-Output "Tearing Down deployment $deploymentName in resource group $ResourceGroupName"

Remove-AzResourceGroup -Name $ResourceGroupName -Force