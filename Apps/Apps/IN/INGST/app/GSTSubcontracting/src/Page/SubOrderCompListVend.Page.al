// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Subcontracting;

page 18495 "Sub Order Comp. List Vend"
{
    Caption = 'Sub Order Comp. List Vend';
    DelayedInsert = true;
    DeleteAllowed = false;
    PageType = ListPart;
    SourceTable = "Sub Order Comp. List Vend";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the item number is linked to.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the description of the item.';
                }
                field("Unit of Measure"; Rec."Unit of Measure")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the unit of measure of the item.';
                }
                field("Expected Quantity"; Rec."Expected Quantity")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the expected quantity of the item is linked to.';
                }
                field("Quantity Dispatched"; Rec."Quantity Dispatched")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the quantity despatched of the item is linked to.';
                }
                field("Qty. Consumed"; Rec."Qty. Consumed")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the quantity consumed of the item is linked to.';
                }
                field("Scrap %"; Rec."Scrap %")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the scrap % of the item is linked to.';
                }
                field("Quantity at Vendor Location"; Rec."Quantity at Vendor Location")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the quantity of the item at vendor location';
                }
                field("Qty. to Consume"; Rec."Qty. to Consume")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the quantity that needs to be consumed.';
                    Style = Strong;
                    StyleExpr = true;
                }
                field("Qty. to Return (C.E.)"; Rec."Qty. to Return (C.E.)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the quantity that needs to be returned C.E.';
                }
                field("Qty. To Return (V.E.)"; Rec."Qty. To Return (V.E.)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the quantity that needs to be V.E.';
                    Style = Strong;
                    StyleExpr = true;
                }
                field("Qty. to Receive"; Rec."Qty. to Receive")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the quantity that needs to be received.';
                }
                field("Company Location"; Rec."Company Location")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the company location code for the document.';
                }
                field("Bin Code"; Rec."Bin Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the company bin code for the document.';
                }
                field("Vendor Location"; Rec."Vendor Location")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the vendor location code for the document.';
                }
                field("Charge Recoverable"; Rec."Charge Recoverable")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the change recoverable from vendor.';
                }
                field("Debit Note Amount"; Rec."Debit Note Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the debit note amount raised to vendor.';
                }
            }
        }

    }
    actions
    {
        area(processing)
        {
            action("&Apply Delivery Challan")
            {
                Caption = '&Apply Delivery Challan';
                ToolTip = 'Apply Delivery Challan';
                Image = Delivery;
                Promoted = true;
                PromotedCategory = Process;
                ApplicationArea = Basic, Suite;

                trigger OnAction()
                begin
                    ViewAppDeliveryChallan();
                end;
            }
        }
    }

    procedure ViewAppDeliveryChallan()
    begin
        Rec.ApplyDeliveryChallan();
    end;
}
