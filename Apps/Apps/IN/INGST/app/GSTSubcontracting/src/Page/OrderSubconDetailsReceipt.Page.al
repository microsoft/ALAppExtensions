// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Subcontracting;

using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;

page 18481 "Order Subcon Details Receipt"
{

    Caption = 'Order Subcon Details Receipt';
    PageType = Document;
    SourceTable = "Purchase Line";
    InsertAllowed = false;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Subcontractor No."; Rec."Buy-from Vendor No.")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Subcontractor No.';
                    ToolTip = 'Specifies the subcontracting vendor number.';
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the finished material code.';
                    Editable = false;
                }
                field("Prod. Order No."; Rec."Prod. Order No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the production order number this order is linked to.';
                    Editable = false;
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the subcontracting number.';
                    Editable = false;
                }
                field("Vendor Shipment No."; Rec."Vendor Shipment No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the vendor shipment number.';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the posting date of the entry.';
                }
                field("Qty. to Accept"; Rec."Qty. to Receive")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Qty. to Accept';
                    ToolTip = 'Specifies the quantity that has to be received form vendor.';

                    trigger OnValidate()
                    begin
                        QtytoReceiveOnAfterValidate();
                    end;
                }
                field("Qty. to Reject (C.E.)"; Rec."Qty. to Reject (C.E.)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the quantity of finished item that needs to be returned to subcontracting vendor. Expense will be borne by the company.';

                    trigger OnValidate()
                    begin
                        QtytoRejectCEOnAfterValidate();
                    end;
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the total order quantity.';
                    Editable = false;
                }
                field("Quantity Received"; Rec."Quantity Received")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the quantity of finished material received from vendor.';
                }
                field("Qty. Rej. (Rework)"; Rec."Qty. Rejected (Rework)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Qty. Rej. (Rework)';
                    ToolTip = 'Specifies the rejected quantity that has been sent for rework.';
                }
                field("Qty. Rej. (V.E.)"; Rec."Qty. Rejected (V.E.)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Qty. Rej. (V.E.)';
                    ToolTip = 'Specifies the quantity of finished item that has been returned to subcontracting vendor. Expense will be borne by the vendor.';
                }
                field("Qty. Rej. (C.E.)"; Rec."Qty. Rejected (C.E.)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Qty. Rej. (C.E.)';
                    ToolTip = 'Specifies the quantity of finished item that has been returned to subcontracting vendor. Expense will be borne by the company.';

                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the status of the document.';
                }
                field("Qty. to Reject (V.E.)"; Rec."Qty. to Reject (V.E.)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the rejected quantities of finished material, for which expenses will be borne by the vendor.';
                    trigger OnValidate()
                    begin
                        QtytoRejectVEOnAfterValidate();
                    end;
                }
            }
            part(SubOrderCompListVend; "Sub Order Comp. List Vend")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "Document No." = field("Document No."),
                              "Document Line No." = field("Line No."),
                              "Parent Item No." = field("No.");
            }
        }
    }
    actions
    {
        area(navigation)
        {
            group("&Order Subcon. Details")
            {
                Caption = '&Order Subcon. Details';
                Image = View;
                action(List)
                {
                    Caption = 'List';
                    ToolTip = 'List View';
                    Image = OpportunitiesList;
                    RunObject = Page "Ord. Subcon Details Rcpt.List";
                    ShortCutKey = 'Shift+Ctrl+L';
                    ApplicationArea = Basic, Suite;
                }
                action(Dimensions)
                {
                    Caption = 'Dimensions';
                    Tooltip = 'Dimensions';
                    Image = Dimensions;
                    ShortCutKey = 'Shift+Ctrl+D';
                    ApplicationArea = Basic, Suite;

                    trigger OnAction()
                    begin
                        Rec.ShowDimensions();
                    end;
                }
                action("Posted Debit Notes")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Posted Debit Notes';
                    Tooltip = 'Posted Debit Notes';
                    Image = PostedCreditMemo;

                    trigger OnAction()
                    begin
                        PurchCrMemoHdr.Reset();
                        PurchCrMemoHdr.SetRange("Subcon. Order No.", Rec."Document No.");
                        PurchCrMemoHdr.SetRange("Subcon. Order Line No.", Rec."Line No.");
                        Page.Run(Page::"Posted Purchase Credit Memos", PurchCrMemoHdr)
                    end;
                }
                action("Debit Notes")
                {
                    Caption = 'Debit Notes';
                    Tooltip = 'Debit Notes';
                    Image = CreditMemo;
                    ApplicationArea = Basic, Suite;

                    trigger OnAction()
                    begin
                        DebitNote.Reset();
                        DebitNote.SetRange("Document Type", DebitNote."Document Type"::"Credit Memo");
                        DebitNote.SetFilter("Subcon. Order No.", Rec."Document No.");
                        DebitNote.SetRange("Subcon. Order Line No.", Rec."Line No.");
                        Page.Run(Page::"Purchase List", DebitNote);
                    end;
                }
                action("Create Debit Note")
                {
                    Caption = 'Create Debit Note';
                    Tooltip = 'Create Debit Note';
                    Image = CreateCreditMemo;
                    ApplicationArea = Basic, Suite;

                    trigger OnAction()
                    begin
                        Report.Run(Report::"Create Vendor Exp. Debit Note", false, true, Rec);
                    end;
                }
            }
        }
        area(processing)
        {
            action("&Receive")
            {
                Caption = '&Receive';
                ToolTip = 'Receive';
                Image = ReceiveLoaner;
                Promoted = true;
                PromotedCategory = Process;
                ApplicationArea = Basic, Suite;

                trigger OnAction()
                begin
                    Rec.SubConReceive := true;
                    SubConPost.PostPurchOrder(Rec)
                end;
            }
        }
    }

    trigger OnDeleteRecord(): Boolean
    var
        UpdateSubcontractDetails: Codeunit "Update Subcontract Details";
    begin
        UpdateSubcontractDetails.ValidateOrUpdateBeforeSubConOrderLineDelete(Rec);
    end;

    local procedure QtytoReceiveOnAfterValidate()
    begin
        SubOrderCompListVend.UpdateReceiptDetails(Rec, Rec."Qty. to Reject (C.E.)", Rec."Qty. to Reject (V.E.)");
        CurrPage.Update();
    end;

    local procedure QtytoRejectCEOnAfterValidate()
    begin
        SubOrderCompListVend.UpdateReceiptDetails(Rec, Rec."Qty. to Reject (C.E.)", Rec."Qty. to Reject (V.E.)");
        CurrPage.Update();
    end;

    local procedure QtytoRejectVEOnAfterValidate()
    begin
        SubOrderCompListVend.UpdateReceiptDetails(Rec, Rec."Qty. to Reject (C.E.)", Rec."Qty. to Reject (V.E.)");
        CurrPage.Update();
    end;

    var
        SubOrderCompListVend: Record "Sub Order Comp. List Vend";
        DebitNote: Record "Purchase Header";
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        SubConPost: Codeunit "Subcontracting Post";
}
