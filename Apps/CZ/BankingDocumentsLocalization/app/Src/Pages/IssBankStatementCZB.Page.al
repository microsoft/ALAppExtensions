// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Documents;

using Microsoft.Foundation.Attachment;

page 31258 "Iss. Bank Statement CZB"
{
    Caption = 'Issued Bank Statement';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Document;
    RefreshOnActivate = true;
    SourceTable = "Iss. Bank Statement Header CZB";

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
                    Editable = false;
                    ToolTip = 'Specifies the number of the bank statement.';
                }
                field("Bank Account No."; Rec."Bank Account No.")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the name of bank account.';
                }
                field("Bank Account Name"; Rec."Bank Account Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of bank account.';
                }
                field("Account No."; Rec."Account No.")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the number used by the bank for the bank account.';
                }
                field("Document Date"; Rec."Document Date")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the date on which you created the document.';
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the currency of amounts on the document.';
                    Importance = Additional;
                }
                field("Bank Statement Currency Code"; Rec."Bank Statement Currency Code")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the bank statement currency code which is setup in the bank card.';
                }
                field("External Document No."; Rec."External Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the external document number received from bank.';
                }
                field("No. of Lines"; Rec."No. of Lines")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of lines in the bank statement.';
                    Importance = Additional;
                }
                field("Search Rule Code"; Rec."Search Rule Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the rule code for matching lines from bank statements.';
                    Importance = Additional;
                }
                field("Payment Journal Status"; Rec."Payment Journal Status")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the posting status of the payment journal.';
                }
                field("Payment Reconciliation Status"; Rec."Payment Reconciliation Status")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies payment reconciliation status.';
                    Visible = false;
                }
            }
            part(Lines; "Iss. Bank Statement Subf. CZB")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "Bank Statement No." = field("No.");
            }
            group("Debit/Credit")
            {
                Caption = 'Debit/Credit';
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the total amount for bank statement lines. The program calculates this amount from the sum of line amount fields on bank statement lines.';
                }
                field(Debit; Rec.Debit)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the total amount that the line consists of, if it is a debit amount.';
                }
                field(Credit; Rec.Credit)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the total amount that the line consists of, if it is a credit amount.';
                }
                field("Amount (LCY)"; Rec."Amount (LCY)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the total amount that the line consists of. The amount is in the local currency.';
                }
                field("Debit (LCY)"; Rec."Debit (LCY)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the total amount that the line consists of, if it is a debit amount. The amount is in the local currency.';
                }
                field("Credit (LCY)"; Rec."Credit (LCY)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the total amount that the line consists of, if it is a credit amount. The amount is in the local currency.';
                }
            }
        }
        area(FactBoxes)
        {
            part("Attached Documents"; "Document Attachment Factbox")
            {
                ApplicationArea = All;
                Caption = 'Attachments';
                SubPageLink = "Table ID" = const(31254), "No." = field("No.");
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
                ToolTip = 'View the statistics on the selected bank statement.';

                trigger OnAction()
                begin
                    Rec.ShowStatistics();
                end;
            }
            action(OpenReconciliationOrJournal)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Open Reconciliation or Journal';
                Image = OpenJournal;
                ToolTip = 'Open the payment reconciliation or joural.';

                trigger OnAction()
                begin
                    Rec.OpenReconciliationOrJournal();
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
            action(CreateJournal)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Create Journal';
                Ellipsis = true;
                Image = PaymentJournal;
                ToolTip = 'The batch job create payment reconciliation journal or payment journal.';

                trigger OnAction()
                begin
                    CreatePaymentReconciliationJournalOrGeneralJournal();
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
            action(IssuedBankStatement)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Issued Bank Statement';
                Ellipsis = true;
                Image = PrintReport;
                ToolTip = 'Open the report for issued bank statement.';

                trigger OnAction()
                begin
                    PrintBankStatement();
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
                actionref(CreateJournal_Promoted; CreateJournal)
                {
                }
            }
            group(Category_Category6)
            {
                Caption = 'Print';

                actionref(IssuedBankStatement_Promoted; IssuedBankStatement)
                {
                }
                actionref(PrintToAttachment_Promoted; PrintToAttachment)
                {
                }
            }
            group(Category_Category7)
            {
                Caption = 'Bank Statement';

                actionref(Statistics_Promoted; Statistics)
                {
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        Rec.FilterGroup(2);
        if not (Rec.GetFilter("Bank Account No.") <> '') then
            if Rec."Bank Account No." <> '' then
                Rec.SetRange("Bank Account No.", Rec."Bank Account No.");
        Rec.FilterGroup(0);
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec.FilterGroup := 2;
        Rec.Validate("Bank Account No.", Rec.GetFilter("Bank Account No."));
        Rec.FilterGroup := 0;
    end;

    local procedure PrintBankStatement()
    var
        IssBankStatementHeaderCZB: Record "Iss. Bank Statement Header CZB";
    begin
        CurrPage.SetSelectionFilter(IssBankStatementHeaderCZB);
        IssBankStatementHeaderCZB.PrintRecords(true);
    end;

    local procedure CreatePaymentReconciliationJournalOrGeneralJournal()
    var
        IssBankStatementHeaderCZB: Record "Iss. Bank Statement Header CZB";
    begin
        IssBankStatementHeaderCZB := Rec;
        IssBankStatementHeaderCZB.SetRecFilter();
        IssBankStatementHeaderCZB.CreateJournal(true);
    end;
}
