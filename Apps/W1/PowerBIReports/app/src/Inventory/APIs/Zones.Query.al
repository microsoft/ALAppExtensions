// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.PowerBIReports;

using Microsoft.Warehouse.Structure;

query 36982 Zones
{
    Access = Internal;
    Caption = 'Power BI Zones';
    QueryType = API;
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    ApiVersion = 'v0.5', 'v1.0';
    EntityName = 'zone';
    EntitySetName = 'zones';
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(zone; Zone)
        {
            column(zoneCode; "Code")
            {
            }
            column(zoneDescription; Description)
            {
            }
            column(locationCode; "Location Code")
            {
            }
            column(binTypeCode; "Bin Type Code")
            {
            }
        }
    }
}