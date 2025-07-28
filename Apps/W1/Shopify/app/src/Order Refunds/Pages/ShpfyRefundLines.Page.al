// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

page 30146 "Shpfy Refund Lines"
{
    Caption = 'Refund Lines';
    PageType = ListPart;
    SourceTable = "Shpfy Refund Line";
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item No. field.';
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Variant Code field.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field.';
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the quantity of a refunded line item.';
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the price of a refunded line item.';
                }
                field(LineDiscount; (Rec.Quantity * Rec.Amount) - Rec."Subtotal Amount")
                {
                    ApplicationArea = All;
                    Caption = 'Line Discount';
                    ToolTip = 'Specifies the line discount of a refunded line item.';
                    Editable = false;
                    BlankZero = true;
                    AutoFormatType = 1;
                    AutoFormatExpression = Rec.OrderCurrencyCode();
                }
                field("Subtotal Amount"; Rec."Subtotal Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the subtotal price of a refunded line item.';
                }
                field("Total Tax Amount"; Rec."Total Tax Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the total tax charged on a refunded line item.';
                }
                field("Restock Type"; Rec."Restock Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the type of restock for the refunded line item.';
                }
                field(Restocked; Rec.Restocked)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether the refunded line item was restocked.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(RetrievedShopifyData)
            {
                ApplicationArea = All;
                Caption = 'Retrieved Shopify Data';
                Image = Entry;
                ToolTip = 'View the data retrieved from Shopify.';

                trigger OnAction();
                var
                    DataCapture: Record "Shpfy Data Capture";
                begin
                    DataCapture.SetCurrentKey("Linked To Table", "Linked To Id");
                    DataCapture.SetRange("Linked To Table", Database::"Shpfy Refund Line");
                    DataCapture.SetRange("Linked To Id", Rec.SystemId);
                    Page.Run(Page::"Shpfy Data Capture List", DataCapture);
                end;
            }
        }
    }
}