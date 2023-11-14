// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Documents;

using Microsoft.Foundation.Attachment;
using Microsoft.Utilities;

page 31253 "Bank Statements CZB"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Bank Statements';
    CardPageID = "Bank Statement CZB";
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Bank Statement Header CZB";
    UsageCategory = Lists;

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
                }
            }
        }
        area(FactBoxes)
        {
            part("Attached Documents"; "Document Attachment Factbox")
            {
                ApplicationArea = All;
                Caption = 'Attachments';
                SubPageLink = "Table ID" = const(31252), "No." = field("No.");
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
            group("F&unctions")
            {
                Caption = 'F&unctions';
                action("Bank Statement Import")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Bank Statement Import';
                    Ellipsis = true;
                    Image = ImportChartOfAccounts;
                    ToolTip = 'Allows import bank statement in the system.';

                    trigger OnAction()
                    begin
                        Rec.ImportBankStatement();
                    end;
                }
                action("Copy Payment Order")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Copy Payment Order';
                    Ellipsis = true;
                    Image = Copy;
                    ToolTip = 'Allows copy payment order in the bank statement.';

                    trigger OnAction()
                    begin
                        CopyPaymentOrder();
                    end;
                }
            }
            group("&Issuing")
            {
                Caption = '&Issuing';
                action("Test Report")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Test Report';
                    Ellipsis = true;
                    Image = TestReport;
                    ToolTip = 'Report specifies how the bank statement entries will be applied.';

                    trigger OnAction()
                    begin
                        TestPrintBankStatement();
                    end;
                }
                action(Issue)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Issue';
                    Ellipsis = true;
                    Image = ReleaseDoc;
                    ShortCutKey = 'F9';
                    ToolTip = 'Issue the bank statement to indicate that it has been printed or exported. Bank statement will be moved to issued bank statement.';

                    trigger OnAction()
                    begin
                        IssueBankStatement(Codeunit::"Issue Bank Statement YesNo CZB");
                    end;
                }
                action(IssueAndPrint)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Issue and &Print';
                    Ellipsis = true;
                    Image = ConfirmAndPrint;
                    ShortCutKey = 'Shift+F9';
                    ToolTip = 'Issue and print the bank statement. Bank statement will be moved to issued bank statement.';

                    trigger OnAction()
                    begin
                        IssueBankStatement(Codeunit::"Issue Bank Statement Print CZB");
                    end;
                }
            }
        }
        area(Reporting)
        {
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

                group(Category_Issuing)
                {
                    Caption = 'Issuing';
                    ShowAs = SplitButton;
                    actionref(Issue_Promoted; Issue)
                    {
                    }
                    actionref(IssueAndPrint_Promoted; IssueAndPrint)
                    {
                    }
                    actionref(TestReport_Promoted; "Test Report")
                    {
                    }
                }
                actionref("Bank Statement Import_Promoted"; "Bank Statement Import")
                {
                }
            }
            group(Category_Category6)
            {
                Caption = 'Print';

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

    trigger OnOpenPage()
    var
        BankStatementManagementCZB: Codeunit "Bank Statement Management CZB";
        SelectedBankAccountForBankStatement: Boolean;
    begin
        BankStatementManagementCZB.BankStatementSelection(Rec, SelectedBankAccountForBankStatement);
        if not SelectedBankAccountForBankStatement then
            Error('');
    end;

    var
        InstructionMgt: Codeunit "Instruction Mgt.";
        InstructionMgtCZB: Codeunit "Instruction Mgt. CZB";
        OpenIssuedBankStmtQst: Label 'The bank statement has been issued and moved to the Issued Bank Statements window.\\Do you want to open the issued bank statements?';

    local procedure IssueBankStatement(IssuingCodeunitId: Integer)
    begin
        Codeunit.Run(IssuingCodeunitId, Rec);
        CurrPage.Update(false);

        if IssuingCodeunitId <> Codeunit::"Issue Bank Statement YesNo CZB" then
            exit;

        if InstructionMgt.IsEnabled(InstructionMgtCZB.GetOpeningIssuedDocumentNotificationId()) then
            ShowIssuedConfirmationMessage(Rec."No.");
    end;

    local procedure ShowIssuedConfirmationMessage(PreAssignedNo: Code[20])
    var
        IssBankStatementHeaderCZB: Record "Iss. Bank Statement Header CZB";
    begin
        IssBankStatementHeaderCZB.SetRange("Pre-Assigned No.", PreAssignedNo);
        if IssBankStatementHeaderCZB.FindFirst() then
            if InstructionMgt.ShowConfirm(OpenIssuedBankStmtQst, InstructionMgtCZB.ShowIssuedConfirmationMessageCode()) then
                Page.Run(Page::"Iss. Bank Statement CZB", IssBankStatementHeaderCZB);
    end;

    local procedure CopyPaymentOrder()
    var
        BankStatementHeaderCZB: Record "Bank Statement Header CZB";
        CopyPaymentOrderCZB: Report "Copy Payment Order CZB";
    begin
        BankStatementHeaderCZB.Get(Rec."No.");
        BankStatementHeaderCZB.SetRecFilter();
        CopyPaymentOrderCZB.SetBankStatementHeader(BankStatementHeaderCZB);
        CopyPaymentOrderCZB.RunModal();
        CurrPage.Update(false);
    end;

    local procedure TestPrintBankStatement()
    var
        BankStatementHeaderCZB: Record "Bank Statement Header CZB";
    begin
        CurrPage.SetSelectionFilter(BankStatementHeaderCZB);
        BankStatementHeaderCZB.TestPrintRecords(true);
    end;
}
