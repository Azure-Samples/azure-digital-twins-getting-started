param resource_suffix string
param resource_location string = resourceGroup().location
param iss_domain string // eg https://login.microsoftonline.com/

var unique_resource_suffix = uniqueString(resource_suffix)
var storage_safe_suffix = replace(replace(replace(unique_resource_suffix, '.', ''), '-', ''), '_', '')
var url_safe_suffix = replace(replace(unique_resource_suffix, '.', ''), '_', '-')
var iss_storage_name = 'issstorage${storage_safe_suffix}'
var iss_digital_twins_name = 'iss-azure-digital-twins-${url_safe_suffix}'
var iss_eventhub_namespace_name = 'iss-event-hub-ns-${url_safe_suffix}'
var iss_ground_position_adapter_name = 'iss-position-adapter-${url_safe_suffix}'
var iss_adt_ingestor_name = 'iss-adt-ingestor-${url_safe_suffix}'
var iss_adapter_name = 'iss-telemetry-adapter-${url_safe_suffix}'
var iss_signalr_service_name = 'iss-signalr-service-${url_safe_suffix}'
var iss_grafana_name = 'iss-dashboards-${url_safe_suffix}'
var iss_grafana_server_farm_name = 'iss-grafana-asp-${url_safe_suffix}'
var iss_signalr_broadcaster_name = 'iss-signalr-broadcaster-${url_safe_suffix}'
var iss_io_server_farm_name = 'iss-io-asp-${url_safe_suffix}'

module twins 'iss.digitaltwins.bicep' = {
  name: '${deployment().name}-twins'
  params: {
    resource_location: resource_location
    iss_digital_twins_name: iss_digital_twins_name
  }
}

module adx 'iss.adx.bicep' = {
  name: '${deployment().name}-adx'
  params: {
    resource_location: resource_location
    iss_digital_twins_adx_name: 'issadx${storage_safe_suffix}'
    iss_digital_twins_db_name: 'db${storage_safe_suffix}'
  }
}

module storage 'iss.storage.bicep' = {
  name: '${deployment().name}-storage'
  params: {
    resource_location: resource_location
    iss_storage_name: iss_storage_name
  }
}

module grafanaDashboards 'iss.grafana.bicep' = {
  name: '${deployment().name}-dashboards'
  params: {
    iss_storage_account_name: storage.outputs.iss_storage_account_name
    iss_grafana_name: iss_grafana_name
    iss_grafana_server_farm_name: iss_grafana_server_farm_name
    resource_location: resource_location
    iss_domain: iss_domain
  }
  dependsOn: [
    storage
  ]
}

module io 'iss.digitaltwins.io.bicep' = {
  name: '${deployment().name}-io'
  params: {
    resource_location: resource_location
    iss_eventhub_namespace_name: iss_eventhub_namespace_name
    iss_ground_position_adapter_name: iss_ground_position_adapter_name
    iss_adapter_name: iss_adapter_name
    iss_adt_ingestor_name: iss_adt_ingestor_name
    iss_digital_twins_name: iss_digital_twins_name
    iss_azure_digital_twins_host_name: twins.outputs.iss_azure_digital_twins_host_name
    iss_io_server_farm_name: iss_io_server_farm_name
    iss_storage_name: iss_storage_name
  }
  dependsOn: [
    storage
    twins
  ]
}

module signalrHololens 'iss.hololens.bicep' = {
  name: '${deployment().name}-signalr'
  params: {
    iss_eventhub_namespace_name: iss_eventhub_namespace_name
    iss_eventhub_egress_name: io.outputs.iss_egress_eventhub_name
    iss_egress_consumer_group: io.outputs.iss_egress_consumer_group_name
    iss_io_server_farm_id: io.outputs.iss_io_server_farm_id
    resource_location: resource_location
    iss_signalr_broadcaster_name: iss_signalr_broadcaster_name
    iss_signalr_service_name: iss_signalr_service_name
    iss_storage_name: iss_storage_name
  }
  dependsOn: [
    io
    storage
  ]
}

output iss_adt_dashboard_url string = grafanaDashboards.outputs.iss_adt_dashboard_url
output iss_adt_host_name string = twins.outputs.iss_azure_digital_twins_host_name
output iss_adt_instance_name string = iss_digital_twins_name
output iss_adt_principal_id string = twins.outputs.iss_azure_digital_twins_principal_id
output iss_adt_endpoint_name string = io.outputs.iss_digital_twins_egress_event_hub_name
output iss_telemetry_adapter_name string = iss_adapter_name
output iss_ingestor_name string = iss_adt_ingestor_name
output iss_position_adapter_name string = iss_ground_position_adapter_name
output iss_signalr_broadcaster_name string = iss_signalr_broadcaster_name
output iss_adx_history_cluster string = adx.outputs.iss_digital_twins_history_cluster
output iss_adx_history_cluster_db string = adx.outputs.iss_digital_twins_history_database_name
output iss_adx_history_cluster_location string = adx.outputs.iss_digital_twins_history_database_location
output iss_digital_twins_history_cluster_url string = adx.outputs.iss_digital_twins_history_cluster_url
output iss_adt_egress_event_hub string = io.outputs.iss_egress_eventhub_name
output iss_adt_ingress_event_hub_namespace string = io.outputs.iss_eventhub_namespace_name
output iss_storage_account_name string = storage.outputs.iss_storage_account_name
output iss_grafana_name string = iss_grafana_name
