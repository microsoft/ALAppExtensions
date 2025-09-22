// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.PowerBIReports;

using Microsoft.Warehouse.Structure;

query 36966 Bins
{
    Access = Internal;
    Caption = 'Power BI Bins';
    QueryType = API;
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    ApiVersion = 'v0.5', 'v1.0';
    EntityName = 'bin';
    EntitySetName = 'bins';
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(bin; Bin)
        {
            column(binCode; "Code")
            {
            }
            column(description; Description)
            {
            }
            column(locationCode; "Location Code")
            {
            }
            column(binType; "Bin Type Code")
            {
            }
            column(zoneCode; "Zone Code")
            {
            }
        }
    }
}