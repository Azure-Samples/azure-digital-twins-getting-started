# Table of Contents

1.  [Introduction](#org090f007)
2.  [Github Setup](#orgf0ebe80)
    1.  [Authenticating GitHub Repository](#org4434ffa)
    2.  [Actions Workflow](#org05247f9)
3.  [Power Automate Flow](#org77099f9)



<a id="org090f007"></a>

# Introduction

This example demonstrates how PowerPlatform can be used in combination with GitHub Acitons to automate the process of updating the model version twins are referencing in an Azure Digital Twins instance. It is important to note that this writeup assumes the following:

-   You have have **owner** role over the ADT instance you are using (for assigning roles)
-   Your ADT instance has a **system managed identity** assigned to it
-   You have ownership over the GitHub repository that you will be using.


<a id="orgf0ebe80"></a>

# Github Setup


<a id="org4434ffa"></a>

## Authenticating GitHub Repository

First create an [Azure AD application](https://learn.microsoft.com/en-us/azure/active-directory/develop/howto-create-service-principal-portal) and assign the **Azure Digital Twins Owner Role** to the newly registered AD application.

Now, we can generate federated credentials that your GitHub repository will use. To do this, first naviagate to the AD application your registered in the **Azure Portal** and click on the **Certificates & Secrets** tab on the left.

Click on the **Federated credentials** tab and select **Add credential**.
![img](./images/add_credential.png)

Select **Github Actions deploying Azure resources**
![img](./images/add_scenerio.png)

Now fill out the following fields:

<table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">


<colgroup>
<col  class="org-left" />

<col  class="org-left" />

<col  class="org-left" />
</colgroup>
<thead>
<tr>
<th scope="col" class="org-left">Field</th>
<th scope="col" class="org-left">Description</th>
<th scope="col" class="org-left">Example</th>
</tr>
</thead>

<tbody>
<tr>
<td class="org-left">Organization</td>
<td class="org-left">Your Github organization anme or Github username.</td>
<td class="org-left"><b>contoso</b></td>
</tr>


<tr>
<td class="org-left">Repository</td>
<td class="org-left">Your repository name.</td>
<td class="org-left"><b>contoso-models</b></td>
</tr>


<tr>
<td class="org-left">Entity Type</td>
<td class="org-left">The filter used to scope the OIDC requests from GitHub workflows. In our case, we&rsquo;ve set it filter based on our main branches</td>
<td class="org-left"><b>Environment</b>, <b>Branch</b>, <b>Pull Request</b>, <b>Tag</b></td>
</tr>
</tbody>
</table>

Lastly retrieve the following values from your Azure AD application and add them as secrets to your GitHub repository:

<table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">


<colgroup>
<col  class="org-left" />

<col  class="org-left" />
</colgroup>
<thead>
<tr>
<th scope="col" class="org-left">GitHub Secret</th>
<th scope="col" class="org-left">Value from Azure AD Application</th>
</tr>
</thead>

<tbody>
<tr>
<td class="org-left">AZURE_CLIENT_ID</td>
<td class="org-left">Application (client) ID</td>
</tr>
</tbody>

<tbody>
<tr>
<td class="org-left">AZURE_TENANT_ID</td>
<td class="org-left">Directory (tenant) ID</td>
</tr>
</tbody>

<tbody>
<tr>
<td class="org-left">AZURE_SUBSCRIPTION_ID</td>
<td class="org-left">Subscription ID</td>
</tr>
</tbody>

<tbody>
<tr>
<td class="org-left">AZURE_URL</td>
<td class="org-left">The endpoint for your Digital Twins instance</td>
</tr>
</tbody>
</table>

Additional Resources:

-   [Use the portal to create an Azure AD Applicaiton](https://learn.microsoft.com/en-us/azure/active-directory/develop/howto-create-service-principal-portal)
-   [Use Github Actions to connect to Azure](https://learn.microsoft.com/en-us/azure/active-directory/develop/howto-create-service-principal-portal)


<a id="org05247f9"></a>

## Actions Workflow

In order to setup Github Actions you first need to create **Yaml** file in the **.github/workflows** path of your repository that defines the workflow.

    name: CI
    on:
      push:
        branches: [ "main" ]                                                  # Action triggered on push to main branch
      # pull_request:
        # branches: [ "main" ]
      # workflow_dispatch:
      # Allows you to run this workflow manually from the Actions tab​
    
    permissions:
      id-token: write
      contents: read
    
    jobs:
      build:
        runs-on: ubuntu-latest
        steps
          - uses: actions/checkout@v3                                         # Checks out repository content​
    
          - name: AZ Login                                                    # Logins in to Azure CLI using secrets that are managed by GitHub
            uses: azure/login@v1
            with:
              client-id: ${{ secrets.AZURE_CLIENT_ID }}
              tenant-id: ${{ secrets.AZURE_TENANT_ID }}
              subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
    
          - name: Changed Files                                               # Stores changed files in a variable that can be referenced in later steps.
            id: changed_files
            uses: tj-actions/changed-files@v32.1.2
            with:
              separator: " "
    
          - name: Setup Python Environment                                    # We're using a Python script to upload models. If using a different language different steps would be required to
            uses: actions/setup-python@v4.3.0                                 # Setup execution environment
            with:
              python-version: 3.11.0-rc.2
    
          - name: Install dependencies
            run: |
              python -m pip install --upgrade pip
              python -m pip install -r ./.pipeline/UploadModels/requirements.txt
    
          - name: Run Script to Upload Models                                 # Executes script that uploads models.
            run: |
              python ./.pipeline/UploadModels/main.py ${{ secrets.AZURE_URL }} ${{ steps.changed_files.outputs.all_changed_files }}

For more information on Github Actions, visit the offical [documentation.](https://docs.github.com/en/actions)

The script that gets executed can be found [here](./.pipeline/UploadModels/main.py).


<a id="org77099f9"></a>

# Power Automate Flow

Handling the upload of models using Github Actions, by contrast, required a lot more effort than what will be presented in this section. As such, I want to emphasize the convenience of low-code/no-code solutions and their value. Even though the flow diagram pictures below may present itself as a complex sequence of events the implementation is actually quite the opposite in that things like authentication and authorization to both GitHub and your Azure Digital Twins instance are all managed by Power Automate through the use of first party connectors to these resources.

![img](./images/sequence_diagram.png "The flow of events after a pull request gets created.")

To begin, navigate to the **My Flows** tab in Power Automate and click on **Import Package** option.

![img](./images/upload_flow.png)

From there, click on the **Upload** botton and select the zip file included in this sample.

Authenticate the connectors used in this sample by clicking on **Select during import** in the **Review Package Content** for each of the resources listed.

![img](./images/import_connections.png)

Lastly click import and go to your newly added flow.
![img](./images/flow.png)

