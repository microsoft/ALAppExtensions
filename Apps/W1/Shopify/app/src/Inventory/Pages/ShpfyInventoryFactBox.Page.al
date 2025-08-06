// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

/// <summary>
/// Page Shpfy Inventory FactBox (ID 30116).
/// </summary>
page 30116 "Shpfy Inventory FactBox"
{
    Caption = 'Shopify Inventory Factbox';
    PageType = ListPart;
    SourceTable = "Shpfy Shop Inventory";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(ShopifyStock; Rec."Shopify Stock")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the stock value on Shopify.';
                }
                field(Stock; Rec.Stock)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the stock value in D365BC';
                }
                field(LastSyncedOn; Rec."Last Synced On")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date and time when the stock was last synchronized from Shopify.';
                }
                field(LastCalculatedOn; Rec."Last Calculated On")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date and time when the stock of D365BC was last calculated.';
                }
                field(LocationName; Rec."Location Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the location name.';
                }
                field(ShopCode; Rec."Shop Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the Shopify Shop.';
                }
            }
        }
    }

}
