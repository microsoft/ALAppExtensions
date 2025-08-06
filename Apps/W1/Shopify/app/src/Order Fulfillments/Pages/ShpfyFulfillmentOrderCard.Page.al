// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

page 30140 "Shpfy Fulfillment Order Card"
{
    ApplicationArea = All;
    Caption = 'Shopify Fulfillment Order';
    PageType = Card;
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    UsageCategory = None;
    SourceTable = "Shpfy FulFillment Order Header";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Shopify Fulfillment Order Id"; Rec."Shopify Fulfillment Order Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Shopify Fulfillment Order Id field.';
                }
                field("Shopify Order Id"; Rec."Shopify Order Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Shopify Order Id field.';
                    Visible = false;
                }
                field("Shopify Order No."; Rec."Shopify Order No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the unique identifier for the order that appears on the order page in the Shopify admin and the order status page. For example, "#1001", "EN1001", or "1001-A".';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Status field.';
                }
                field("Shop Code"; Rec."Shop Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Shop Code field.';
                }
                field("Shop Id"; Rec."Shop Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Shop Id field.';
                    Visible = false;
                }
            }
            part(Lines; "Shpfy Fulfillment Order Lines")
            {
                ApplicationArea = All;
                Caption = 'Lines';
                SubPageLink = "Shopify Fulfillment Order Id" = field("Shopify Fulfillment Order Id");
            }
        }
    }
}