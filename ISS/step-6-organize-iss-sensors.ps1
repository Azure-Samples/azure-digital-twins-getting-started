Param([string] $iss_adt_instance_name, [string] $ResourceGroupName)

Install-Module -Name Az.DigitalTwins

$iss_sensors = $(az dt twin query -n $iss_adt_instance_name -g $ResourceGroupName -q "SELECT * FROM DigitalTwins WHERE MessageType = 'IssSensor'" ) | ConvertFrom-Object 

Write-Output $iss_sensors

foreach ($twin in $iss_sensors) {
    Write-Output 'Hello'
}