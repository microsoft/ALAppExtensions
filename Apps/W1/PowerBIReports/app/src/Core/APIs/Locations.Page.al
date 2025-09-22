// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.PowerBIReports;

using Microsoft.Inventory.Location;

page 36957 Locations
{
    PageType = API;
    Caption = 'Power BI Locations';
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    ApiVersion = 'v0.5', 'v1.0';
    EntityName = 'location';
    EntitySetName = 'locations';
    SourceTable = Location;
    DelayedInsert = true;
    DataAccessIntent = ReadOnly;
    Editable = false;
    Extensible = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(locationCode; Rec."Code")
                {
                }
                field(locationName; Rec.Name)
                {
                }
                field(adjustmentBinCode; Rec."Adjustment Bin Code")
                {
                }
            }
        }
    }
}
