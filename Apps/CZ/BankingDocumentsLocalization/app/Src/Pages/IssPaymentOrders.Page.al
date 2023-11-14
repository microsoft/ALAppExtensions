// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Documents;

using Microsoft.Foundation.Attachment;

page 31265 "Iss. Payment Orders CZB"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Issued Payment Orders';
    CardPageID = "Iss. Payment Order CZB";
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Iss. Payment Order Header CZB";
    UsageCategory = History;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                Editable = false;
                ShowCaption = false;
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of the payment order.';
                }
                field("Account No."; Rec."Account No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number used by the bank for the bank account.';
                }
                field("Document Date"; Rec."Document Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the date on which you created the document.';
                }
                field("Bank Account No."; Rec."Bank Account No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of bank account.';
                }
                field("Bank Account Name"; Rec."Bank Account Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of bank account.';
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the currency of amounts on the document.';
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the total amount for payment order lines. The program calculates this amount from the sum of line amount fields on payment order lines.';
                }
                field("Amount (LCY)"; Rec."Amount (LCY)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the total amount that the line consists of. The amount is in the local currency.';
                }
                field("No. of Lines"; Rec."No. of Lines")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of lines in the payment order.';
                }
                field("File Name"; Rec."File Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies internally field.';
                    Visible = false;
                }
            }
        }
        area(FactBoxes)
        {
            part("Attached Documents"; "Document Attachment Factbox")
            {
                ApplicationArea = All;
                Caption = 'Attachments';
                SubPageLink = "Table ID" = const(31258), "No." = field("No.");
            }
            systempart(Links; Links)
            {
                ApplicationArea = RecordLinks;
                Visible = false;
            }
            systempart(Notes; Notes)
            {
                ApplicationArea = Notes;
                Visible = true;
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action(Statistics)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Statistics';
                Image = Statistics;
                ShortCutKey = 'F7';
                ToolTip = 'View the statistics on the selected payment order.';

                trigger OnAction()
                begin
                    Rec.ShowStatistics();
                end;
            }
            action(DocAttach)
            {
                ApplicationArea = All;
                Caption = 'Attachments';
                Image = Attach;
                ToolTip = 'Add a file as an attachment. You can attach images as well as documents.';

                trigger OnAction()
                var
                    DocumentAttachmentDetails: Page "Document Attachment Details";
                    RecRef: RecordRef;
                begin
                    RecRef.GetTable(Rec);
                    DocumentAttachmentDetails.OpenForRecRef(RecRef);
                    DocumentAttachmentDetails.RunModal();
                end;
            }
        }
        area(Processing)
        {
            action("Payment Order Export")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Payment Order Export';
                Ellipsis = true;
                Image = ExportToBank;
                ToolTip = 'Open the report for expor payment order to the bank.';

                trigger OnAction()
                begin
                    Rec.ExportPaymentOrder();
                end;
            }
            action("&Navigate")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Find Entries';
                Ellipsis = true;
                Image = Navigate;
                ShortCutKey = 'Ctrl+Alt+Q';
                ToolTip = 'Find all entries and documents that exist for the document number and posting date on the selected entry or document.';

                trigger OnAction()
                begin
                    Rec.Navigate();
                end;
            }
        }
        area(Reporting)
        {
            action(IssuedPaymentOrder)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Issued Payment Order';
                Ellipsis = true;
                Image = BankAccountStatement;
                ToolTip = 'Open the report for payment order.';

                trigger OnAction()
                begin
                    PrintPaymentOrder();
                end;
            }
            action(PrintToAttachment)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Attach as PDF';
                Image = PrintAttachment;
                ToolTip = 'Create a PDF file and attach it to the document.';

                trigger OnAction()
                begin
                    Rec.PrintToDocumentAttachment();
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                actionref("&Navigate_Promoted"; "&Navigate")
                {
                }
                actionref("Payment Order Export_Promoted"; "Payment Order Export")
                {
                }
            }
            group(Category_Category6)
            {
                Caption = 'Print';

                actionref(IssuedPaymentOrder_Promoted; IssuedPaymentOrder)
                {
                }
                actionref(PrintToAttachment_Promoted; PrintToAttachment)
                {
                }
            }
            group(Category_Category7)
            {
                Caption = 'Payment Order';

                actionref(Statistics_Promoted; Statistics)
                {
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        PaymentOrderManagementCZB: Codeunit "Payment Order Management CZB";
        SelectedBankAccountForPaymentOrder: Boolean;
    begin
        PaymentOrderManagementCZB.IssuedPaymentOrderSelection(Rec, SelectedBankAccountForPaymentOrder);
        if not SelectedBankAccountForPaymentOrder then
            Error('');
    end;

    local procedure PrintPaymentOrder()
    var
        IssPaymentOrderHeaderCZB: Record "Iss. Payment Order Header CZB";
    begin
        IssPaymentOrderHeaderCZB := Rec;
        IssPaymentOrderHeaderCZB.SetRecFilter();
        IssPaymentOrderHeaderCZB.PrintRecords(true);
    end;
}
