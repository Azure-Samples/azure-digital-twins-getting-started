Param([string] $iss_adt_instance_name, [string] $ResourceGroupName)

Write-Output "Querying for Sensor Twins"

$iss_sensors = $(az dt twin query -n $iss_adt_instance_name -g $ResourceGroupName -q 'SELECT $dtId as "Id", Discipline FROM DigitalTwins WHERE MessageType = ''IssSensor''' ) | ConvertFrom-Json 

Write-Output "Found $($iss_sensors.result.Count) Sensor Twins"

Write-Output 'Generating Disciplines'

$disiplines = @()

foreach ($twin in $iss_sensors.result) {
    
    if ($twin.Discipline.IndexOf("N/A") -eq -1) {

        $possible_disc = $twin.Discipline.split("/");

        foreach ($disc in $possible_disc) {
            if ($disiplines.IndexOf($disc) -eq -1) {
                Write-Output "  Found New Discipline: $disc"      
                $disiplines += $disc
            }
        }
        
    }
}

Write-Output "Uploading Models from ./iss-dtdl/"

az dt model create -n $iss_adt_instance_name --from-directory ./iss-dtdl/

Write-Output "Uploaded Models from ./iss-dtdl/"

foreach($disipline in $disiplines)
{
    Write-Output "Creating Discipline Twin with id:'$disipline'"
    $disipline_name = "$disipline"
    $discipline_twin = '{"name":"'+$disipline_name+'", "$metadata":{}}'    
    Write-Output "Creating Twin $discipline_twin"
    az dt twin create -n $iss_adt_instance_name --dtmi "dtmi:com:iss:discipline;1" --twin-id "$disipline" --if-none-match 
    Write-Output "Created Discipline Twin: $discipline"
}

Write-Output "Organizing Sensor Twins by Discipline"

foreach($twin in $iss_sensors.result)
{
    $current_discipline = $twin.Discipline
    $twinId = $twin.Id
    $current_twin = "$twinId"

    Write-Output "Twin $current_twin belongs to Discipline $current_discipline ... Creating Relationship(s)"

    if ($current_discipline.IndexOf("N/A") -eq -1) {

        $possible_disc = $current_discipline.split("/");

        foreach ($disc in $possible_disc) {
            $relationship_id = [guid]::NewGuid().ToString()           
            $discId = "$disc"
            Write-Output "  Creating Relationship: $relationship_id From $current_twin to $discId"
            az dt twin relationship create -n $iss_adt_instance_name --relationship-id $relationship_id --relationship HasMember --twin-id "$discId" --target-twin-id "$current_twin"
        }
        
    }
}



$disiplineCount = $disiplines.Count

Write-Output "Found $disiplineCount disciplines"