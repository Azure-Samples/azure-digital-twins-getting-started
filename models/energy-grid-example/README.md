# Example Data for digital-twins-explorer

This directory contains a set of example DTDL files (*.json) that you can load into into your Azure Digital Twins instance using digital-twins-explorer. 

The twins graph created by the models and data files in this folder looks like this:
![Image of digital-twins-explorer](https://github.com/Azure-Samples/digital-twins-explorer/blob/main/media/digital-twins-explorer.png)

The DTDL files model a fictive energy grid. They are not intended to represent a realistic model that matches real-world entities or devices used in a real energy grid. 
They were just created to quickly test and demonstrate digital-twins-explorer and to provide an example for a visualization. They may aslo serve as an example for DTDL syntax.

This directory also contains two spreadsheet files (*.xlsx) that you can use to create a twin graph in your Azure Digital Twins instance with digital-twins-explorer.
See the [main readme](https://github.com/Azure-Samples/digital-twins-explorer/tree/main/README.md) for instructions. The file you want to start with is `distributionGrid.xlsx`.

It also contains a json file, `distributionGridBulkImport.json`, that can be used to import models, twins, and relationships for the distribution grid scenario in bulk, using the [Import Jobs API](https://learn.microsoft.com/rest/api/digital-twins/dataplane/jobs/import-jobs-add).



