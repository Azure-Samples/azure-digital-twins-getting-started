Param([string] $ResourceGroupName, [string] $ResourceSuffix , [string] $iss_bicep_template, [string] $iss_domain)

az extension add --upgrade --name azure-iot
az deployment group create --resource-group $ResourceGroupName --template-file $iss_bicep_template --parameters resource_suffix=$ResourceSuffix iss_domain=$iss_domain