using IoTHubTrigger = Microsoft.Azure.WebJobs.EventHubTriggerAttribute;

using Azure;
using Azure.Core.Pipeline;
using Azure.DigitalTwins.Core;
using Azure.Identity;
using Microsoft.Azure.EventGrid.Models;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.EventGrid;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.Net.Http;
using System.Linq;

namespace AdtDevKitFunctions
{
    public class ProcessHubToDTEvents
    {
        private static HttpClient _httpClient = new HttpClient();
        private static string _adtServiceUrl = Environment.GetEnvironmentVariable("ADT_SERVICE_URL");


        /// <summary>
        /// This function is used to process the data as it is ingested into event hub and then sets the property 
        /// values of the devices in azure digital twins. In this instance, the messages come devices in IoT Hub 
        /// that are used to track temperature and humidity values.
        /// 
        /// 1) each message contains humidity and temperature data. Temp is in celsius format and needs to be converted into fahrenheit
        /// 2) humidity and temp need to be rounded up
        /// 3) devices are a 1-1 match to a room, we need to update the temp and humidity properties for the associated room
        /// </summary>
        /// <param name="message"></param>
        /// <param name="log"></param>
        [FunctionName("ProcessHubToDTEvents")]
        public async void Run([EventGridTrigger] EventGridEvent message, ILogger log)
        {
            DigitalTwinsClient client;
            DefaultAzureCredential credentials;

            log.LogInformation(message.Data.ToString());

            // check for url, exit method if empty
            if (_adtServiceUrl == null)
            {
                log.LogError("Application setting \"ADT_SERVICE_URL\" not set");
                return;
            }

            try
            {
                //Authenticate with Digital Twins
                credentials = new DefaultAzureCredential();
                client = new DigitalTwinsClient(new Uri(_adtServiceUrl), credentials, new DigitalTwinsClientOptions { Transport = new HttpClientTransport(_httpClient) });

                log.LogInformation($"ADT service client connection created.");

                // continue if message is not empty
                if (message != null && message.Data != null)
                {
                    // deserialize message into object
                    JObject deviceMessage = (JObject)JsonConvert.DeserializeObject(message.Data.ToString());

                    string deviceId = (string)deviceMessage["systemProperties"]["iothub-connection-device-id"];
                    string body = deviceMessage["body"].ToString();

                    // not all devices encode the body, so we need to check and decode as needed
                    if (this.IsBase64Encoded(body)) {
                        byte[] data = System.Convert.FromBase64String(body);
                        string decodedBody = System.Text.ASCIIEncoding.ASCII.GetString(data);

                        log.LogInformation($"decodedBody: {decodedBody}");
                        body = decodedBody;
                    }                    

                    // deserialize body into a sensor data object
                    JObject sensorData = (JObject)JsonConvert.DeserializeObject(body);

                    // get values from our device message
                    JToken temeratureData = sensorData["temperature"];
                    JToken humidityData = sensorData["humidity"];
                    JToken messageId = sensorData["messageId"];

                    double temperature = -99;
                    double humidity = -99;

                    // convert temp to fahrenheit & round values
                    if (temeratureData != null) { temperature = Math.Round(temeratureData.Value<double>() * 9 / 5 + 32, 2); }
                    if (humidityData != null) { humidity = Math.Round(humidityData.Value<double>(), 2); }

                    // do some logging
                    log.LogInformation($"Device Id: {deviceId};");

                    if (temperature != -99) { log.LogInformation($"temperature: {temperature}"); }
                    if (humidity != -99) { log.LogInformation($"humidity: {humidity}"); }

                    var updateTwinData = new JsonPatchDocument();

                    // update twin data when variables are not null
                    if (temperature != -99) updateTwinData.AppendAdd("/temperature", temperature);
                    if (humidity != -99) updateTwinData.AppendAdd("/humidity", humidity);

                    // get room twin that is linked to the device
                    Pageable<IncomingRelationship> incomingRelationship = client.GetIncomingRelationships(deviceId);
                    string sourceId = incomingRelationship.First<IncomingRelationship>().SourceId;

                    log.LogInformation($"Room Twin Id: {sourceId};");

                    // update twin 
                    if (!(temperature == -99 && humidity == -99))
                    {
                        log.LogInformation($"Executed update!");
                        log.LogInformation($" ");

                        // update device
                        await client.UpdateDigitalTwinAsync(deviceId, updateTwinData);

                        // update room
                        if (!string.IsNullOrEmpty(sourceId)) { await client.UpdateDigitalTwinAsync(sourceId, updateTwinData); }
                    }
                }
            }
            catch (Exception ex)
            {
                log.LogError($"Exception: {ex.Message}");
            }
            finally
            {
                client = null;
                credentials = null;
            }
        }

        private bool IsBase64Encoded(string base64String)
        {
            if (string.IsNullOrEmpty(base64String) || base64String.Length % 4 != 0 || base64String.Contains(" ") || base64String.Contains("\t") || base64String.Contains("\r") || base64String.Contains("\n"))
                return false;
            try
            {
                Convert.FromBase64String(base64String);
                return true;
            }
            catch (Exception)
            {
                // Handle the exception
            }

            return false;
        }
    }
}