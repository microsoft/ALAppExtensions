// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Subcontracting;

page 18466 "Applied Delivery Challan"
{
    Caption = 'Applied Delivery Challan';
    PageType = List;
    SourceTable = "Applied Delivery Challan";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                field("App. Delivery Challan Line No."; Rec."App. Delivery Challan Line No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the delivery challan line number against which the item has to be applied.';
                }
                field("Applied Delivery Challan No."; Rec."Applied Delivery Challan No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the applied delivery challan.';
                }
                field("Qty. to Receive"; Rec."Qty. to Receive")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the quantity of components that will be returned to company location.';
                }
                field("Qty. to Consume"; Rec."Qty. to Consume")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the quantity that needs to be consumed.';
                }
                field("Qty. to Return (C.E.)"; Rec."Qty. to Return (C.E.)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the quantity of finished item which needs to be returned to subcontracting vendor. Expense will be born by the company.';
                }
                field("Qty. To Return (V.E.)"; Rec."Qty. To Return (V.E.)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the quantity of finished item which needs to be returned to subcontracting vendor. Expense will be born by the vendor.';
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("&Line")
            {
                Caption = '&Line';
                Image = Line;
                group("Item &Tracking Lines")
                {
                    Caption = 'Item &Tracking Lines';
                    Image = AllLines;
                    action("Qty. to &Consume")
                    {
                        Caption = 'Qty. to &Consume';
                        ToolTip = 'Quantity to Consume';
                        Image = UntrackedQuantity;
                        ApplicationArea = Basic, Suite;

                        trigger OnAction()
                        begin
                            Rec.OpenItemTrackingLinesSubcon(Type::Consume);
                        end;
                    }
                    action("Qty to Return (C.E.)")
                    {
                        Caption = 'Qty. to Return (C.E.)';
                        ToolTip = 'Quantity to Return (C.E.)';
                        Image = ReturnShipment;
                        ApplicationArea = Basic, Suite;
                        trigger OnAction()
                        begin
                            Rec.OpenItemTrackingLinesSubcon(Type::RejectCE);
                        end;
                    }
                    action("Qty To Return (V.E.)")
                    {
                        Caption = 'Qty. To Return (V.E.)';
                        ToolTip = 'Quantity To Return (V.E.)';
                        Image = ReturnReceipt;
                        ApplicationArea = Basic, Suite;

                        trigger OnAction()
                        begin
                            Rec.OpenItemTrackingLinesSubcon(Type::RejectVE);
                        end;
                    }
                    action("Qty to Receive")
                    {
                        Caption = 'Qty. to Receive';
                        ToolTip = 'Quantity to Receive';
                        Image = Receipt;
                        ApplicationArea = Basic, Suite;

                        trigger OnAction()
                        begin
                            Rec.OpenItemTrackingLinesSubcon(Type::Receive);
                        end;
                    }
                }
            }
        }
    }

    trigger OnDeleteRecord(): Boolean
    begin
        CurrPage.SaveRecord();
        if not Rec.DeleteLineConfirm(Rec) then
            exit(false);

        Rec.DeleteLine(Rec);
    end;

    var
        Type: Option Consume,RejectVE,RejectCE,Receive,Rework;
}
