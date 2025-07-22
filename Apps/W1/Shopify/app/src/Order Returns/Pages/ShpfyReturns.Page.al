// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

page 30150 "Shpfy Returns"
{
    ApplicationArea = All;
    Caption = 'Shopify Returns';
    PageType = List;
    SourceTable = "Shpfy Return Header";
    UsageCategory = Lists;
    Editable = false;
    CardPageId = "Shpfy Return";
    SourceTableView = sorting("Return Id") order(descending);

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Return No."; Rec."Return No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the No. of the return.';
                }
                field("Shopify Order No."; Rec."Shopify Order No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the unique identifier for the order that appears on the order page in the Shopify admin and the order status page. For example, "#1001", "EN1001", or "1001-A".';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the status of the return.';
                }
                field("Sell-to Customer No."; Rec."Sell-to Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sell-to Customer No. field.';
                }
                field("Sell-to Customer Name"; Rec."Sell-to Customer Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sell-to Customer Name field.';
                }
                field("Bill-to Customer No."; Rec."Bill-to Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Bill-to Customer No. field.';
                }
                field("Bill-to Customer Name"; Rec."Bill-to Customer Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Bill-to Customer Name field.';
                }
                field("Decline Note"; Rec.GetDeclineNote())
                {
                    ApplicationArea = All;
                    Caption = 'Decline Note';
                    ToolTip = 'Specifies the notification message sent to the customer about their declined return request.';
                }
                field("Decline Reason"; Rec."Decline Reason")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the reason the customer''s return request was declined.';
                }
                field("Total Quantity"; Rec."Total Quantity")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the sum of all line item quantities for the return.';
                }
            }
        }
    }
}