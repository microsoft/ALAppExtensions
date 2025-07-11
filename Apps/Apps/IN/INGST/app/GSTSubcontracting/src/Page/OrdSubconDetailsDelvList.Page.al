// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Subcontracting;

using Microsoft.Purchases.Document;

page 18482 "Ord. Subcon Details Delv. List"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Ord. Subcon Details Delv. List';
    CardPageID = "Order Subcon. Details Delivery";
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
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the description.';
                }
                field("Prod. Order No."; Rec."Prod. Order No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the production order number this order is linked to.';
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    Tooltip = 'Specifies the document number.';
                }
                field("Deliver Comp. For"; Rec."Deliver Comp. For")
                {
                    ApplicationArea = Basic, Suite;
                    Tooltip = 'Specifies the quantity to deliver Component for ';
                }
                field("Qty. to Reject (Rework)"; Rec."Qty. to Reject (Rework)")
                {
                    ApplicationArea = Basic, Suite;
                    Tooltip = 'Specifies the quantity to reject for rework.';
                }
                field("Delivery Challan Posted"; Rec."Delivery Challan Posted")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of delivery challan posted.';
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the quantity of the item is linked to.';
                }
                field("Quantity Accepted"; Rec."Quantity Received")
                {
                    ApplicationArea = Basic, Suite;
                    Tooltip = 'Specifies the accepted quantity.';
                }
                field("Qty. Rej. (Rework)"; Rec."Qty. Rejected (Rework)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the quantity rejected for rework.';
                }
                field("Qty. Rej. (V.E.)"; Rec."Qty. to Reject (V.E.)")
                {
                    ApplicationArea = Basic, Suite;
                    Tooltip = 'Specifies the quantity rejected VE.';
                }
                field("Qty. Rej. (C.E.)"; Rec."Qty. to Reject (C.E.)")
                {
                    ApplicationArea = Basic, Suite;
                    Tooltip = 'Specifies the quantity rejected CE.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = Basic, Suite;
                    Tooltip = 'Specifies the status of the document.';
                }
                field("Delivery Challan Posted2"; Rec."Delivery Challan Posted")
                {
                    ApplicationArea = Basic, Suite;
                    Tooltip = 'Specifies the delivery challan number posted.';
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
                    ToolTip = 'Casrd View';
                    Image = EditLines;
                    ShortCutKey = 'Shift+F7';
                    trigger OnAction()
                    begin
                        Page.Run(Page::"Ord. Subcon Details Delv. List", Rec);
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
