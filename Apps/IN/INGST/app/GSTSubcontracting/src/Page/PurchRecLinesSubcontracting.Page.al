// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Subcontracting;

using Microsoft.Purchases.Document;

page 18488 "Purch Rec Lines Subcontracting"
{
    Caption = 'Purchase Rec Lines Subcontracting';
    DeleteAllowed = false;
    Editable = true;
    InsertAllowed = false;
    ModifyAllowed = true;
    PageType = ListPart;
    SourceTable = "Purchase Line";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                field("Buy-from Vendor No."; Rec."Buy-from Vendor No.")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Subcontractor No.';
                    ToolTip = 'Specifies the subcontracting vendor number.';
                    Editable = false;
                    Visible = false;
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Subcontracting Order No.';
                    Tooltip = 'Specifies the subcontracting order number.';
                    Editable = false;

                }
                field("Prod. Order No."; Rec."Prod. Order No.")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Production Order No.';
                    Tooltip = 'Specifies the production order number this order is linked to.';
                    Editable = false;
                }
                field("Prod. Order Line No."; Rec."Prod. Order Line No.")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Production Order Line No';
                    Tooltip = 'Specifies the released production order line number.';
                    Editable = false;
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Item No.';
                    Tooltip = 'Specifies the item number of document.';
                    Editable = false;
                }
                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Line No';
                    ToolTip = 'Specifies the line number of document.';
                    Editable = false;
                    Visible = false;
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Quantity';
                    ToolTip = 'Specifies the total quantity of the order.';
                    Editable = false;
                }
                field("Qty. to Receive"; Rec."Qty. to Receive")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Quantity to Receive';
                    ToolTip = 'Specifies the quantity that needs to be received.';

                    trigger OnValidate()
                    begin
                        QtytoReceiveOnAfterValidate();
                    end;
                }
                field("Quantity Received"; Rec."Quantity Received")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Quantity Received';
                    ToolTip = 'Specifies the quantity received.';
                }
                field("Qty. to Reject (C.E.)"; Rec."Qty. to Reject (C.E.)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Quantity to Reject CE';
                    ToolTip = 'Specifies the quantity that needs to be rejected CE';
                }
                field("Qty. to Reject (V.E.)"; Rec."Qty. to Reject (V.E.)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Quantity to Reject VE';
                    ToolTip = 'Specifies the quantity that needs to be rejected VE';
                }
                field("Applies-to ID (Receipt)"; Rec."Applies-to ID (Receipt)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Applies to ID Receipt';
                    ToolTip = 'Specifies the applied entry number.';
                }
            }
        }
    }
    actions
    {
        area(processing)
        {
            group("&Line")
            {
                Caption = '&Line';
                Image = Line;
                action("&Order Subcon. Details")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = '&Order Subcon. Details';
                    ToolTip = 'Subcontractor Order Details';
                    Image = View;

                    trigger OnAction()
                    begin
                        ShowSubOrderRcpt();
                    end;
                }
                action(Dimensions)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Dimensions';
                    ToolTip = 'Dimensions';
                    Image = Dimensions;
                    ShortCutKey = 'Shift+Ctrl+D';

                    trigger OnAction()
                    begin
                        ShowDimension();
                    end;
                }
                action("<Action2>")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Apply Line';
                    ToolTip = 'Apply Line';
                    Image = SelectLineToApply;

                    trigger OnAction()
                    var
                        PurchLine: Record "Purchase Line";
                        MultipleSubconOrderDetails: Record "Multiple Subcon. Order Details";
                    begin
                        PurchLine.Copy(Rec);
                        CurrPage.SetSelectionFilter(PurchLine);
                        MultipleSubconOrderDetails.Reset();
                        MultipleSubconOrderDetails.SetRange("Subcontractor No.", Rec."Buy-from Vendor No.");
                        if MultipleSubconOrderDetails.FindFirst() then
                            SubcontractingValidations.SetSubconAppliestoID(MultipleSubconOrderDetails."No.", PurchLine, false);
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        Rec.ShowShortcutDimCode(ShortcutDimCode);
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        CLEAR(ShortcutDimCode);
    end;

    procedure ShowSubOrderDetails()
    begin
        SubcontractingValidations.ShowSubOrderDetailsForm(Rec);
    end;

    procedure SetAppliestoID(var ID: Code[20])
    begin
    end;

    procedure ShowDimension()
    begin
        Rec.ShowDimensions();
    end;

    procedure ShowSubOrderRcpt()
    begin
        SubcontractingValidations.ShowSubOrderRcptForm(Rec);
    end;

    local procedure QtytoReceiveOnAfterValidate()
    var
        SubOrderCompListVend: Record "Sub Order Comp. List Vend";
    begin
        SubOrderCompListVend.UpdateReceiptDetails(Rec, Rec."Qty. to Reject (C.E.)", Rec."Qty. to Reject (V.E.)");
    end;

    var
        SubcontractingValidations: Codeunit "Subcontracting Validations";
        ShortcutDimCode: array[8] of Code[20];
}
