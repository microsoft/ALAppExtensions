// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Subcontracting;

using Microsoft.Purchases.Document;

page 18480 "Order Subcon. Details Delivery"
{
    Caption = 'Order Subcon. Details Delivery';
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
                    Editable = false;
                    ToolTip = 'Specifies the number of the subcontracting order.';
                }
                field("Prod. Order No."; Rec."Prod. Order No.")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the production order number this order is linked to.';
                }
                field("Document No."; Rec."Document No.")
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the document number.';
                }
                field("Deliver Comp. For"; Rec."Deliver Comp. For")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the quantity of finished goods for which components need to be sent.';

                    trigger OnValidate()
                    begin
                        DeliverCompForOnAfterValidate();
                    end;
                }
                field("Qty. to Reject (Rework)"; Rec."Qty. to Reject (Rework)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the quantity that need to be rejected and will be sent for rework.';

                    trigger OnValidate()
                    begin
                        QtytoRejectReworkOnAfterValida();
                    end;
                }
                field("Delivery Challan Date"; Rec."Delivery Challan Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the posting date of delivery challan.';
                }
                field(Quantity; Rec.Quantity)
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the to total quantity of ordered finished material.';
                }
                field("Quantity Accepted"; Rec."Quantity Received")
                {

                    Caption = 'Quantity Accepted';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the quantity of finished material received from vendor.';
                }
                field("Qty. Rej. (Rework)"; Rec."Qty. Rejected (Rework)")
                {
                    Caption = 'Qty. Rej. (Rework)';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the rejected quantity that has been sent for rework.';
                }
                field("Qty. Rej. (V.E.)"; Rec."Qty. to Reject (V.E.)")
                {

                    Caption = 'Qty. Rej. (V.E.)';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the rejected finished material, for which expenses will be borne by the vendor.';
                    Editable = false;
                }
                field("Qty. Rej. (C.E.)"; Rec."Qty. Rejected (V.E.)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Qty. Rej. (C.E.)';
                    ToolTip = 'Specifies the rejected finished material, for which expenses will be borne by the customer.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the status of the document.';
                }
                field("Delivery Challan Posted"; Rec."Delivery Challan Posted")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of delivery challan posted.';
                    Editable = false;

                    trigger OnDrillDown()
                    begin
                        DeliveryChallanHeader.Reset();
                        DeliveryChallanHeader.SetFilter("Prod. Order No.", Rec."Prod. Order No.");
                        DeliveryChallanHeader.SetRange("Prod. Order Line No.", Rec."Prod. Order Line No.");

                        Page.Run(Page::"Delivery Challan List", DeliveryChallanHeader);
                    end;
                }
            }
            part(SubOrderComponents; "Sub Order Components")
            {
                ApplicationArea = Suite;
                Editable = Rec."Buy-from Vendor No." <> '';
                Enabled = Rec."Buy-from Vendor No." <> '';
                SubPageLink = "Document No." = field("Document No."),
                              "Document Line No." = field("Line No."),
                              "Parent Item No." = field("No.");
                UpdatePropagation = Both;
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
                    ApplicationArea = Suite;
                    Caption = 'List';
                    ToolTip = 'List View';
                    Image = OpportunitiesList;
                    RunObject = Page "Ord. Subcon Details Delv. List";
                    ShortCutKey = 'Shift+Ctrl+L';
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
                        Rec.ShowDimensions();
                        CurrPage.SaveRecord();
                    end;
                }
                action("&Delivery Challan")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = '&Delivery Challan';
                    Tooltip = 'Delivery Challan';
                    Image = OutboundEntry;

                    trigger OnAction()
                    begin
                        SubcontractingValidations.MultipleDeliveryChallanList(Rec);
                    end;
                }
            }
        }
        area(processing)
        {
            action("&Send")
            {
                ApplicationArea = Basic, Suite;
                Caption = '&Send';
                Tooltip = 'Send';
                Image = SendTo;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    Codeunit.Run(Codeunit::"Subcontracting Confirm-Post", Rec);
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

    local procedure DeliverCompForOnAfterValidate()
    begin
        CurrPage.Update();
    end;

    local procedure QtytoRejectReworkOnAfterValida()
    begin
        CurrPage.Update();
    end;

    local procedure MakeConfirmation(DocumentNo: code[20])
    begin
        if not Confirm(SendPostQst, true, DocumentNo) then
            exit;
    end;

    var
        DeliveryChallanHeader: Record "Delivery Challan Header";
        SubcontractingValidations: Codeunit "Subcontracting Validations";
        SendPostQst: Label 'Do you want to post the %1?', Comment = '%1 = Document No';
}
