This is an example of an Azure API Management running in front of an Azure Function or Dynamics 365 F&O that run a calculator REST API.

The AzureFunction folder contains the code for the Azure Function that creates the calculator API.

The X++ folder contains the Dynamics 365 F&O code to create a custom web service that will create the calculator API.

The Bicep folder contains the code to create the infrastructure for both the Azure Function and Dynamics 365 solutions.

You can read more details reading this post on my blog: https://ariste.info/en/2022/09/bicep-azure-api-management-architecture/

Azure Function: [![.NET](https://github.com/aariste/APIMIntegration/actions/workflows/mainCI.yml/badge.svg?branch=main)](https://github.com/aariste/APIMIntegration/actions/workflows/mainCI.yml)

You can learn further about using Azure API Management with Dynamics 365 reading these posts:
-  Azure API Management for Dynamics 365 F&O (https://ariste.info/en/2022/02/azure-api-management-dynamics-365-fo/)
-  Azure API Management for your integrations (https://ariste.info/en/2022/09/azure-api-management-architecture/)
