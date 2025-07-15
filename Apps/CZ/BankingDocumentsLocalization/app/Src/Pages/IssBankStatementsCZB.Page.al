// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Documents;

using Microsoft.Foundation.Attachment;
using Microsoft.Utilities;

page 31257 "Iss. Bank Statements CZB"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Issued Bank Statements';
    CardPageID = "Iss. Bank Statement CZB";
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Iss. Bank Statement Header CZB";
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
                    ToolTip = 'Specifies the number of the bank statement.';
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
                    Visible = false;
                }
                field("Bank Account Name"; Rec."Bank Account Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of bank account.';
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the total amount for bank statement lines. The program calculates this amount from the sum of line amount fields on bank statement lines.';
                }
                field("Amount (LCY)"; Rec."Amount (LCY)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the total amount that the line consists of. The amount is in the local currency.';
                }
                field("No. of Lines"; Rec."No. of Lines")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of lines in the bank statement.';
                }
                field("File Name"; Rec."File Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name and address of bank statement file uploaded from bank.';
                    Visible = false;
                }
                field("Payment Journal Status"; Rec."Payment Journal Status")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the posting status of the payment journal.';
                }
            }
        }
        area(FactBoxes)
        {
#if not CLEAN25
            part("Attached Documents"; "Document Attachment Factbox")
            {
                ObsoleteTag = '25.0';
                ObsoleteState = Pending;
                ObsoleteReason = 'The "Document Attachment FactBox" has been replaced by "Doc. Attachment List Factbox", which supports multiple files upload.';
                ApplicationArea = All;
                Caption = 'Attachments';
                SubPageLink = "Table ID" = const(Database::"Iss. Bank Statement Header CZB"), "No." = field("No.");
            }
#endif
            part("Attached Documents List"; "Doc. Attachment List Factbox")
            {
                ApplicationArea = All;
                Caption = 'Documents';
                SubPageLink = "Table ID" = const(Database::"Iss. Bank Statement Header CZB"), "No." = field("No.");
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
#if not CLEAN27
            action(Statistics)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Statistics';
                Image = Statistics;
                ShortCutKey = 'F7';
                ToolTip = 'View the statistics on the selected bank statement.';
                ObsoleteReason = 'The statistics action will be replaced with the IssBankStatementStatistics action. The new action uses RunObject and does not run the action trigger. Use a page extension to modify the behaviour.';
                ObsoleteState = Pending;
                ObsoleteTag = '27.0';

                trigger OnAction()
                begin
                    Rec.ShowStatistics();
                end;
            }
#endif
            action(IssBankStatementStatistics)
            {
                ApplicationArea = VAT;
                Caption = 'Statistics';
                Image = Statistics;
                ShortcutKey = 'F7';
                Enabled = Rec."No." <> '';
                ToolTip = 'View statistical information for the record.';
#if CLEAN27
                Visible = true;
#else
                Visible = false;
#endif
                RunObject = Page "Iss. Bank Stmt. Statistics CZB";
                RunPageOnRec = true;
            }
            action(OpenReconciliationOrJournal)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Open Reconciliation or Journal';
                Image = OpenJournal;
                ToolTip = 'Open the payment reconciliation or journal.';

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
                var
                    InstructionMgt: Codeunit "Instruction Mgt.";
                    InstructionMgtCZB: Codeunit "Instruction Mgt. CZB";
                    OpenCreatedJnlQst: Label 'The journal was successfully created.\\Do you want to open the created journal and check it now?';
                begin
                    if CreatePaymentReconciliationJournalOrGeneralJournal() then
                        if Rec.PaymentReconcialiationOrGeneralJournalExist() then
                            if InstructionMgt.IsEnabled(InstructionMgtCZB.ShowCreatedJnlIssBankStmtConfirmationMessageCode()) then
                                if InstructionMgt.ShowConfirm(OpenCreatedJnlQst, InstructionMgtCZB.ShowCreatedJnlIssBankStmtConfirmationMessageCode()) then
                                    Rec.OpenReconciliationOrJournal();
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

#if not CLEAN27
                actionref(Statistics_Promoted; Statistics)
                {
                    ObsoleteReason = 'The statistics action will be replaced with the IssBankStatementStatistics action. The new action uses RunObject and does not run the action trigger. Use a page extension to modify the behaviour.';
                    ObsoleteState = Pending;
                    ObsoleteTag = '27.0';
                }
#else
                actionref(IssBankStatementStatistics_Promoted; IssBankStatementStatistics)
                {
                }
#endif
            }
        }
    }

    trigger OnOpenPage()
    var
        BankStatementManagementCZB: Codeunit "Bank Statement Management CZB";
        SelectedBankAccountForBankStatement: Boolean;
    begin
        BankStatementManagementCZB.IssuedBankStatementSelection(Rec, SelectedBankAccountForBankStatement);
        if not SelectedBankAccountForBankStatement then
            Error('');
    end;

    local procedure PrintBankStatement()
    var
        IssBankStatementHeaderCZB: Record "Iss. Bank Statement Header CZB";
    begin
        CurrPage.SetSelectionFilter(IssBankStatementHeaderCZB);
        IssBankStatementHeaderCZB.PrintRecords(true);
    end;

    local procedure CreatePaymentReconciliationJournalOrGeneralJournal(): Boolean
    var
        IssBankStatementHeaderCZB: Record "Iss. Bank Statement Header CZB";
        InstructionMgt: Codeunit "Instruction Mgt.";
        InstructionMgtCZB: Codeunit "Instruction Mgt. CZB";
    begin
        IssBankStatementHeaderCZB := Rec;
        IssBankStatementHeaderCZB.SetRecFilter();
        exit(IssBankStatementHeaderCZB.IsCreatedJournal(true, InstructionMgt.IsEnabled(InstructionMgtCZB.ShowCreatedJnlIssBankStmtConfirmationMessageCode())));
    end;
}
