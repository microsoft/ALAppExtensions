// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Subcontracting;

using Microsoft.Purchases.Document;

page 18487 "Purchase Lines Subcontracting"
{
    Caption = 'Purchase Lines Subcontracting';
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
                    ToolTip = 'Specifies the subcontracting order number.';
                    Caption = 'Subcontracting Order No.';
                    Editable = false;

                }
                field("Prod. Order No."; Rec."Prod. Order No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the production order number this order is linked to.';
                    Editable = false;
                }
                field("Prod. Order Line No."; Rec."Prod. Order Line No.")
                {

                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the released production order line number.';
                    Editable = false;

                }
                field("Line No."; Rec."Line No.")
                {

                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the line number of document.';
                    Editable = false;
                    Visible = false;
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Item No.';
                    ToolTip = 'Specifies the line number of document.';
                    Editable = false;
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the total quantity of the order.';
                    Editable = false;
                }
                field("Deliver Comp. For"; Rec."Deliver Comp. For")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the quantity of finished item for which components has to be sent to the vendor.';
                }
                field("Qty. to Reject (Rework)"; Rec."Qty. to Reject (Rework)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the quantity that needs to be rejected and will be sent for rework.';
                }
                field("Applies-to ID (Delivery)"; Rec."Applies-to ID (Delivery)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the applied entry number.';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group("&Lines")
            {
                Caption = '&Lines';
                Image = AllLines;
                action("&Order Subcon. Details")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = '&Order Subcon. Details';
                    ToolTip = 'Suncontractor Order Details';
                    Image = View;

                    trigger OnAction()
                    begin
                        ShowSubOrderDetails();
                    end;
                }
                action("&Delivery Challan Posted")
                {
                    Caption = '&Delivery Challan Posted';
                    Tooltip = 'Posted Delivery challan';
                    ApplicationArea = Basic, Suite;
                    Image = Delivery;

                    trigger OnAction()
                    begin
                        DeliveryChallanPostedList();
                    end;
                }
                action(Dimensions)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Dimensions';
                    Tooltip = 'Dimensions';
                    Image = Dimensions;
                    ShortCutKey = 'Shift+Ctrl+D';

                    trigger OnAction()
                    begin
                        ShowDimension();
                    end;
                }
                action("<Action3>")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Apply Line';
                    Tooltip = 'Apply Line';
                    Image = SelectLineToApply;

                    trigger OnAction()
                    var
                        MultipleSubconOrderDetails: Record "Multiple Subcon. Order Details";
                        PurchLine: Record "Purchase Line";
                    begin
                        PurchLine.Copy(Rec);
                        CurrPage.SetSelectionFilter(PurchLine);
                        MultipleSubconOrderDetails.Reset();
                        MultipleSubconOrderDetails.SetRange("Subcontractor No.", Rec."Buy-from Vendor No.");
                        if MultipleSubconOrderDetails.FindFirst() then
                            SubcontractingValidations.SetSubconAppliestoID(MultipleSubconOrderDetails."No.", PurchLine, TRUE);
                        SetAppliestoID(SubconAppliesToID);
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
        Clear(ShortcutDimCode);
    end;

    procedure ShowSubOrderDetails()
    begin
        SubcontractingValidations.ShowSubOrderDetailsForm(Rec);
    end;

    procedure SetAppliestoID(var ID: Code[20])
    begin
    end;

    procedure DeliveryChallanPostedList()
    begin
        SubcontractingValidations.MultipleDeliveryChallanList(Rec);
    end;

    procedure ShowDimension()
    begin
        Rec.ShowDimensions();
    end;

    procedure SetSubconAppliesToID(ID: Code[20])
    begin
        SubconAppliesToID := ID
    end;

    var
        SubcontractingValidations: Codeunit "Subcontracting Validations";
        ShortcutDimCode: array[8] of Code[20];
        SubconAppliesToID: Code[20];
}
