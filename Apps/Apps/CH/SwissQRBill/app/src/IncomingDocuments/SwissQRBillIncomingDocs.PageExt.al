// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;

using Microsoft.EServices.EDocument;

pageextension 11511 "Swiss QR-Bill Incoming Docs" extends "Incoming Documents"
{
    actions
    {
        modify(CreateDocument) { Visible = not "Swiss QR-Bill"; }
        modify(CreateGenJnlLine) { Visible = not "Swiss QR-Bill"; }
        modify(CreateManually) { Visible = not "Swiss QR-Bill"; }

        addlast(processing)
        {
            group("Swiss QR-Bill")
            {
                Caption = 'Create From QR-Bill';
                ToolTip = 'QR-Bill processing.';

                action("Swiss QR-Bill Scan")
                {
                    Caption = 'Scan QR-Bill';
                    ToolTip = 'Create a new incoming document record from the scanning of QR-bill with an input scanner, or from manual (copy/paste) of the decoded QR-Code text value into a field.';
                    ApplicationArea = All;
                    Image = CreateDocument;

                    trigger OnAction()
                    begin
                        SwissQRBillIncomingDoc.CreateNewIncomingDocFromQRBill(false);
                    end;
                }
                action("Swiss QR-Bill Import")
                {
                    ApplicationArea = All;
                    Caption = 'Import Scanned QR-Bill File';
                    ToolTip = 'Creates a new incoming document record by importing a scanned QR-bill that is saved as a text file.';
                    Image = Import;

                    trigger OnAction()
                    begin
                        SwissQRBillIncomingDoc.CreateNewIncomingDocFromQRBill(true);
                    end;
                }
                action("Swiss QR-Bill Create Journal")
                {
                    ApplicationArea = All;
                    Caption = 'Create Journal Line';
                    ToolTip = 'Creates a new journal line from the incoming QR-bill document.';
                    Enabled = "Swiss QR-Bill";
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedOnly = true;
                    Image = TransferToGeneralJournal;
                    Visible = "Swiss QR-Bill";

                    trigger OnAction()
                    begin
                        SwissQRBillIncomingDoc.CreateJournalAction(Rec);
                    end;
                }
                action("Swiss QR-Bill Create Purchase Invoice")
                {
                    ApplicationArea = All;
                    Caption = 'Create Purchase Invoice';
                    ToolTip = 'Creates a new purchase invoice from the incoming QR-bill document.';
                    Enabled = "Swiss QR-Bill";
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedOnly = true;
                    Image = CreateDocument;
                    Visible = "Swiss QR-Bill";

                    trigger OnAction()
                    begin
                        SwissQRBillIncomingDoc.CreatePurchaseInvoiceAction(Rec);
                    end;
                }
            }

        }
    }

    var
        SwissQRBillIncomingDoc: Codeunit "Swiss QR-Bill Incoming Doc";
}
