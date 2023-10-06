// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Subcontracting;

page 18479 "Multiple Order Subcon Receipt"
{
    Caption = 'Multiple Order Subcon Receipt';
    PageType = Document;
    SourceTable = "Multiple Subcon. Order Details";
    SourceTableView = sorting("No.") order(Ascending) where("No." = filter(<> ''));

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the multiple order subcon. receipt number.';
                    AssistEdit = true;

                    trigger OnAssistEdit()
                    begin
                        if Rec.AssistEdit(xRec) then
                            CurrPage.Update();
                    end;
                }
                field("Subcontractor No."; Rec."Subcontractor No.")
                {

                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the subcontracting order number.';
                    trigger OnValidate()
                    begin
                        SubcontractorNoOnAfterValidate();
                    end;
                }
                field("Vendor Shipment No."; Rec."Vendor Shipment No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the vendor shipment number.';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the posting date of entry.';
                }
                field("Document Date"; Rec."Document Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the document date of entry.';
                }
            }
            part(PurchRecLines; "Purch Rec Lines Subcontracting")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "Document Type" = const(Order),
                              "Buy-from Vendor No." = field("Subcontractor No."),
                              Subcontracting = const(true);
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("Multiple Order Subcon Details")
            {
                Caption = 'Multiple Order Subcon Details';
                Image = View;
                action("&List")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'List';
                    ToolTip = 'List View';
                    Image = OpportunitiesList;
                    RunObject = Page "Multiple Order Subcon Rcp List";
                    ShortCutKey = 'Shift+Ctrl+L';
                }
            }
        }
        area(processing)
        {
            group("Receive")
            {
                Caption = 'Receive Subcontract Quantity';
                Image = ReceiveLoaner;
                action("&Receive")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = '&Receive';
                    ToolTip = 'Received';
                    Image = ReceiveLoaner;
                    Promoted = true;
                    PromotedCategory = Process;

                    trigger OnAction()
                    var
                        SubconPostBatch: Codeunit "Subcontracting Post Batch";
                    begin
                        SubconPostBatch.PostPurchorder(Rec);
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        MultipleOrdSubconNo := Rec."No.";
    end;

    local procedure SubcontractorNoOnAfterValidate()
    begin
        CurrPage.Update();
    end;

    var
        MultipleOrdSubconNo: Code[20];
}
