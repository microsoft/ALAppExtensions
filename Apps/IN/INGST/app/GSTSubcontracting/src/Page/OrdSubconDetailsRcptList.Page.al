// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Subcontracting;

using Microsoft.Purchases.Document;

page 18483 "Ord. Subcon Details Rcpt.List"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Ord. Subcon Details Rcpt. List';
    CardPageID = "Order Subcon Details Receipt";
    DataCaptionFields = "Document Type";
    Editable = false;
    InsertAllowed = false;
    PageType = List;
    UsageCategory = Lists;
    SourceTable = "Purchase Line";
    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                field("Subcontractor No."; Rec."Buy-from Vendor No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the subcontracting vendor number.';
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the subcontracting item number.';
                }
                field("Prod. Order No."; Rec."Prod. Order No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the production order number this order is linked to.';
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the document number.';
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
                    ToolTip = 'Specifies the quantity to accept';
                }
                field("Qty. to Reject (C.E.)"; Rec."Qty. to Reject (C.E.)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the quantity to Reject CE';
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the quantity for the subcontrcting item.';
                }
                field("Quantity Received"; Rec."Quantity Received")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the quantity received';
                }
                field("Qty. Rej. (Rework)"; Rec."Qty. Rejected (Rework)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the quantity rejected for rework.';
                }
                field("Qty. Rejected (V.E.)"; Rec."Qty. Rejected (V.E.)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the quantity rejected VE';
                }
                field("Qty. Rejected (C.E.)"; Rec."Qty. Rejected (C.E.)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the quantity rejected CE';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the status of the document.';
                }
                field("Qty. to Reject (V.E.)"; Rec."Qty. to Reject (V.E.)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the quantity to Reject VE';
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
                action(Card)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Card';
                    Tooltip = 'Card';
                    Image = EditLines;
                    ShortCutKey = 'Shift+F7';

                    trigger OnAction()
                    begin
                        Page.RunModal(Page::"Order Subcon Details Receipt", Rec);
                    end;
                }
            }
        }
    }

    trigger OnDeleteRecord(): Boolean
    var
        UpdateSubcontractDetails: Codeunit "Update Subcontract Details";
    begin
        UpdateSubcontractDetails.ValidateOrUpdateBeforeSubConOrderLineDelete(Rec);
    end;
}
