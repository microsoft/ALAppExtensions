// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.PowerBIReports;

using Microsoft.Projects.Resources.Resource;

query 37070 "Resources - PBI API"
{
    Access = Internal;
    Caption = 'Power BI Resources';
    QueryType = API;
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    ApiVersion = 'v0.5', 'v1.0';
    EntityName = 'resource';
    EntitySetName = 'resources';
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(resource; Resource)
        {
            column(resourceNo; "No.")
            {
            }
            column(resourceName; Name)
            {
            }
            column(baseUnitofMeasure; "Base Unit of Measure")
            {
            }
            column(unitCost; "Unit Cost")
            {
            }
            column(unitPrice; "Unit Price")
            {
            }
        }
    }
}