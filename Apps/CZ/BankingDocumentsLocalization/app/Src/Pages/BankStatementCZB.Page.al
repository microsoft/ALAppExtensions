// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Documents;

using Microsoft.Bank.BankAccount;
using Microsoft.Finance.Currency;
using Microsoft.Foundation.Attachment;
using Microsoft.Utilities;

page 31254 "Bank Statement CZB"
{
    Caption = 'Bank Statement';
    PageType = Document;
    RefreshOnActivate = true;
    SourceTable = "Bank Statement Header CZB";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of the bank statement.';
                    Visible = NoFieldVisible;

                    trigger OnAssistEdit()
                    begin
                        if Rec.AssistEdit(xRec) then
                            CurrPage.Update();
                    end;
                }
                field("Bank Account No."; Rec."Bank Account No.")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the no. of bank account.';
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
                    ShowMandatory = true;
                    ToolTip = 'Specifies the date on which you created the document.';

                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the currency of amounts on the document.';
                    Importance = Additional;

                    trigger OnAssistEdit()
                    var
                        ChangeExchangeRate: Page "Change Exchange Rate";
                    begin
                        ChangeExchangeRate.SetParameter(Rec."Currency Code", Rec."Currency Factor", Rec."Document Date");
                        if ChangeExchangeRate.RunModal() = Action::OK then begin
                            Rec.Validate("Currency Factor", ChangeExchangeRate.GetParameter());
                            CurrPage.Update();
                        end;
                        Clear(ChangeExchangeRate);
                    end;
                }
                field("Bank Statement Currency Code"; Rec."Bank Statement Currency Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the bank statement currency code in the bank statement.';

                    trigger OnAssistEdit()
                    var
                        ChangeExchangeRate: Page "Change Exchange Rate";
                    begin
                        ChangeExchangeRate.SetParameter(Rec."Bank Statement Currency Code", Rec."Bank Statement Currency Factor", Rec."Document Date");
                        if ChangeExchangeRate.RunModal() = Action::OK then begin
                            Rec.Validate("Bank Statement Currency Factor", ChangeExchangeRate.GetParameter());
                            CurrPage.Update();
                        end;
                        Clear(ChangeExchangeRate);
                    end;
                }
                field("External Document No."; Rec."External Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    ShowMandatory = true;
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
            }
            part(Lines; "Bank Statement Subform CZB")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "Bank Statement No." = field("No.");
                UpdatePropagation = Both;
            }
            group("Debit/Credit")
            {
                Caption = 'Debit/Credit';
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the total amount that the line consists of.';
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

                actionref("Bank Statement Import_Promoted"; "Bank Statement Import")
                {
                }
            }
            group(Category_Category4)
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

    trigger OnAfterGetRecord()
    begin
        Rec.FilterGroup(2);
        if not (Rec.GetFilter("Bank Account No.") <> '') then
            if Rec."Bank Account No." <> '' then
                Rec.SetRange("Bank Account No.", Rec."Bank Account No.");
        Rec.FilterGroup(0);
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    var
        BankAccount: Record "Bank Account";
    begin
        Rec.FilterGroup := 2;
        Rec."Document Date" := WorkDate();
        Rec."Bank Account No." := CopyStr(Rec.GetFilter("Bank Account No."), 1, MaxStrLen(Rec."Bank Account No."));
        Rec.FilterGroup := 0;
        CurrPage.Lines.Page.SetParameters(Rec."Bank Account No.");

        if BankAccount.Get(Rec."Bank Account No.") then
            BankAccount.CheckCurrExchRateExistCZB(Rec."Document Date");

        Rec.Validate("Bank Account No.");
    end;

    trigger OnOpenPage()
    begin
        SetNoFieldVisible();
    end;

    var
        DocumentNoVisibility: Codeunit DocumentNoVisibility;
        InstructionMgt: Codeunit "Instruction Mgt.";
        InstructionMgtCZB: Codeunit "Instruction Mgt. CZB";
        NoFieldVisible: Boolean;
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

    local procedure SetNoFieldVisible()
    begin
        if Rec."No." <> '' then
            NoFieldVisible := false
        else
            NoFieldVisible := DocumentNoVisibility.ForceShowNoSeriesForDocNo(DetermineBankStatementCZBSeriesNo());
    end;

    local procedure DetermineBankStatementCZBSeriesNo(): Code[20]
    var
        BankAccount: Record "Bank Account";
        BankStatementHeaderCZB: Record "Bank Statement Header CZB";
    begin
        BankAccount.Get(Rec."Bank Account No.");
        DocumentNoVisibility.CheckNumberSeries(BankStatementHeaderCZB, BankAccount."Bank Statement Nos. CZB", BankStatementHeaderCZB.FieldNo("No."));
        exit(BankAccount."Bank Statement Nos. CZB");
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
