# Azure Function Examples

## Incoming Messages

This function is used to process the data as it is ingested into event hub and then sets the property values of the devices in azure digital twins. In this instance, the messages come devices in IoT Hub that are used to track temperature and humidity values.
        
1. Each message contains humidity and temperature data. Temp is in celsius format and needs to be converted into fahrenheit
2. Humidity and temp need to be rounded up
3. Devices are a 1-1 match to a room, we need to update the temp and humidity properties for the associated room

## Twin Updates

The outcome of this function is to get the average floor temp and humidity values based on the rooms on that floor. 
         
1. Get the incoming relationship of the room. This will get the floor twin id
2. Get a list of all the rooms on the floor and get the humidity and temp properties for each
3. Calculate the average temp and humidity across all the rooms
4. Update the temp and humidity properties on the floor