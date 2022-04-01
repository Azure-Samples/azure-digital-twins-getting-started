Param([string] $iss_adt_instance_name, [string] $ResourceGroupName)

$iss_sensors = $(az dt twin query -n $iss_adt_instance_name -g $ResourceGroupName -q "SELECT * FROM DigitalTwins WHERE MessageType = 'IssSensor'" --output tsv ) | ConvertFrom-Object 

Write-Output $iss_sensors

foreach ($twinList in $iss_sensors) {
    
    ## get the discipline of the sensor 

    ## split by / (a sensor can be in muplitple disciplines)

    ## for each discipline

        ## create disicipline twin if not exists

        ## add sensor to disicpline using discipline "HasMember Relationship"

}