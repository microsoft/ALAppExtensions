// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.PowerBIReports;

using Microsoft.Inventory.Item;
page 36967 "Item Category - PBI API"
{
    PageType = API;
    Caption = 'Power BI Item Categories';
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    ApiVersion = 'v0.5', 'v1.0';
    EntityName = 'itemCategory';
    EntitySetName = 'itemCategories';
    SourceTable = "Item Category";
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
                field(code; Rec.Code) { }
                field(description; Rec.Description) { }
                field(parentCategory; Rec."Parent Category") { }
                field(systemId; Rec.SystemId) { }
            }
        }
    }
}