Param([string] $ResourceGroupName, [string] $ResourceSuffix , [string] $iss_bicep_template,[string] $subscriptionId, [string] $iss_domain)

az extension add --upgrade --name azure-iot

Write-Output "Go to this link to see your deployment progress https://ms.portal.azure.com/resource/subscriptions/"$subscriptionId"/resourceGroups/"$ResourceGroupName"/deployments "

az deployment group create --resource-group $ResourceGroupName --template-file $iss_bicep_template --parameters resource_suffix=$ResourceSuffix iss_domain=$iss_domain