# Dairy scenario with data history (Azure Digital Twins query plugin for Azure Data Explorer)

This folder contains:

| File/folder | Description |
| --- | --- |
| *ContosoDairyDataHistoryGraphUpdatesQueries.kql* | Sample graph update queries reflecting a dairy operation, that can be run on Azure Data Explorer web UI. These queries can also be used in a larger solution that includes the Azure Digital Twins data history feature.<br><br>For walkthrough information and help running these queries in context, see [Use data history with Azure Data Explorer](https://docs.microsoft.com/azure/digital-twins/how-to-use-data-history) in the Azure Digital Twins documentation. |
| *ContosoDairyDataHistoryQueries.kql* | Sample queries reflecting a dairy operation, that can be run with the Azure Digital Twins query plugin for Azure Data Explorer. These queries can also be used in a larger solution that includes the Azure Digital Twins data history feature.<br><br>For walkthrough information and help running these queries in context, see [Use data history with Azure Data Explorer](https://docs.microsoft.com/azure/digital-twins/how-to-use-data-history) in the Azure Digital Twins documentation. |
| *Visualize_with_Grafana* | Contains a walkthrough document for creating dashboards with Azure Digital Twins, Azure Data Explorer, and Grafana. Also contains files for three sample dashboards.  Based on the blog [Creating Dashboards with Azure Digital Twins, Azure Data Explorer, and Grafana](https://techcommunity.microsoft.com/t5/internet-of-things-blog/creating-dashboards-with-azure-digital-twins-azure-data-explorer/ba-p/3277879) |


# Graph updates Walkthrough

This walkthrough assumes that you have set up data history connection that historizes twin property updates, twin lifecycle events, and relationship lifecycle events.  Once you’ve set up data history, use the [Azure Digital Twins Data Simulator](https://docs.microsoft.com/en-us/azure/digital-twins/how-to-use-data-history?tabs=cli#create-a-sample-graph) to automatically provision a twin graph of a dairy operation in your ADT instance.  Be sure to select the “Dairy Facility” simulation type when generating the twin graph. Twin and relationship creation events will be generated and historized to your Azure Data Explorer database by this step. 

 

Open [Azure Digital Explorer](https://docs.microsoft.com/en-us/azure/digital-twins/how-to-use-azure-digital-twins-explorer) and run the query “SELECT * FROM digitaltwins” to visualize the twin graph. Make a note of the time, then wait a few minutes to establish an interval before you modify the twin graph.  Then, delete the twins as annotated in the red box in the figure below by right-clicking on the twins.  This will create twin/relationship deletion events.  



 


Open the [Azure Data Explorer web UI](https://docs.microsoft.com/en-us/azure/data-explorer/web-query-data), and click on the database that you selected when you created the data history connection.

Run the example kql queries from file **ContosoDairyDataHistoryGraphUpdatesQueries.kql** in this GitHub folder.


