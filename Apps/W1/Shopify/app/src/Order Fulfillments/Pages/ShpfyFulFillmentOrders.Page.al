// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

page 30141 "Shpfy Fulfillment Orders"
{
    ApplicationArea = All;
    Caption = 'Fulfillment Orders';
    PageType = List;
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    UsageCategory = None;
    SourceTable = "Shpfy FulFillment Order Header";
    CardPageId = "Shpfy Fulfillment Order Card";

    layout
    {
        area(content)
        {
            repeater(General)
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
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the status of the fulfillment order.';
                }
            }
        }
    }
}