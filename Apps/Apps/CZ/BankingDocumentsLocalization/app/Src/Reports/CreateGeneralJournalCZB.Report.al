// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Documents;

using Microsoft.Bank.BankAccount;
using Microsoft.Finance.GeneralLedger.Journal;
using System.Utilities;

report 31287 "Create General Journal CZB"
{
    Caption = 'Create Payment Journal';
    Permissions = tabledata "Iss. Bank Statement Header CZB" = m;
    ProcessingOnly = true;

    dataset
    {
        dataitem("Iss. Bank Statement Header CZB"; "Iss. Bank Statement Header CZB")
        {
            RequestFilterFields = "No.";
            dataitem("Iss. Bank Statement Line CZB"; "Iss. Bank Statement Line CZB")
            {
                DataItemLink = "Bank Statement No." = field("No.");
                DataItemTableView = sorting("Bank Statement No.", "Line No.");

                trigger OnAfterGetRecord()
                begin
                    if not HideMessages then
                        WindowDialog.Update(1, "Line No.");

                    CreateGeneralJournalLine("Iss. Bank Statement Header CZB", "Iss. Bank Statement Line CZB");
                end;

                trigger OnPostDataItem()
                begin
                    if not HideMessages then begin
                        WindowDialog.Close();
                        WindowDialog.Open(ApplyingLinesMsg);
                    end;

                    if not BankAccount."Post Per Line CZB" then
                        CreateSummaryLines("Iss. Bank Statement Header CZB");

                    if not ApplyGeneralJournalLine("Iss. Bank Statement Header CZB") then
                        ApplyingFailed := true;

                    if not HideMessages then
                        WindowDialog.Close();
                end;

                trigger OnPreDataItem()
                begin
                    if not HideMessages then
                        WindowDialog.Open(CreatingLinesMsg);
                    CreditTotal := 0;
                    DebitTotal := 0;
                end;
            }

            trigger OnAfterGetRecord()
            var
                GenJournalLine: Record "Gen. Journal Line";
                ConfirmManagement: Codeunit "Confirm Management";
                ExistJournallinesQst: Label '%1 %2 already exist. Existing journal lines will be deleted and new ones will be created based on the bank statement lines. Do you want to continue?', Comment = '%1 = TableCaption, %2 = No.';
            begin
                if PaymentReconcialiationOrGeneralJournalExist() then
                    if not ConfirmManagement.GetResponseOrDefault(StrSubstNo(ExistJournallinesQst, GenJournalLine.TableCaption(), "No."), false) then
                        Error('');
                GetBankAccount("Iss. Bank Statement Header CZB");
                DeleteGeneralJournalLines("Iss. Bank Statement Header CZB");
                LastLineNo := GetLastLineNo();
            end;

            trigger OnPostDataItem()
            begin
                if not HideMessages then
                    if ApplyingFailed then
                        Message(ApplyingFailedMsg)
                    else
                        Message(SuccessCreatedMsg);
            end;
        }
    }

    requestpage
    {
        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(VariableSymbolToDescriptionCZB; VariableSymbolToDescription)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Variable Symbol to Description';
                        ToolTip = 'Specifies if variable symbol will be transferred to description';
                    }
                    field(VariableSymbolToVariableSymbolCZB; VariableSymbolToVariableSymbol)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Variable S. to Variable S.';
                        ToolTip = 'Specifies if variable symbol will be transferred to variable symbol';
                    }
                    field(VariableToExtDocNo; VariableSymbolToExtDocNo)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Variable S. to External Doc. No.';
                        ToolTip = 'Specifies if variable symbol will be transferred to external document no.';
                    }
                }
            }
        }
        trigger OnOpenPage()
        begin
            GetParameters();
        end;
    }

    trigger OnPreReport()
    begin
        if not CurrReport.UseRequestPage then
            GetParameters();
    end;

    var
        BankAccount: Record "Bank Account";
        WindowDialog: Dialog;
        VariableSymbolToDescription, VariableSymbolToVariableSymbol, VariableSymbolToExtDocNo, VarJournalCreated : Boolean;
        CreatingLinesMsg: Label 'Creating payment journal lines...\\Line No. #1##########', Comment = '%1 = Progress bar';
        ApplyingLinesMsg: Label 'Applying payment journal lines...\\Line No. #1##########', Comment = '%1 = Progress bar';
        SuccessCreatedMsg: Label 'Payment journal lines were successfully created.';
        ApplyingFailedMsg: Label 'One or more errors were found when matching the statement lines in the payment journal. For more information, open the payment journal and run the Match by Search Rule function for the unapplied lines.';
        ApplyingFailed: Boolean;
        HideMessages: Boolean;
        LastLineNo: Integer;
        CreditTotal: Decimal;
        DebitTotal: Decimal;

    procedure SetHideMessages(HideMessagesNew: Boolean)
    begin
        HideMessages := HideMessagesNew;
    end;

    procedure JournalCreated(): Boolean
    begin
        exit(VarJournalCreated);
    end;

    local procedure GetParameters()
    var
        IssBankStatementHeaderCZB: Record "Iss. Bank Statement Header CZB";
        BankStatementNo: Code[20];
    begin
        BankStatementNo := CopyStr("Iss. Bank Statement Header CZB".GetFilter("No."), 1, MaxStrLen(BankStatementNo));
        if BankStatementNo = '' then
            exit;

        IssBankStatementHeaderCZB.Get(BankStatementNo);
        GetBankAccount(IssBankStatementHeaderCZB);
        VariableSymbolToDescription := BankAccount."Variable S. to Description CZB";
        VariableSymbolToVariableSymbol := BankAccount."Variable S. to Variable S. CZB";
        VariableSymbolToExtDocNo := BankAccount."Variable S. to Ext.Doc.No. CZB";
    end;

    local procedure GetBankAccount(IssBankStatementHeaderCZB: Record "Iss. Bank Statement Header CZB")
    begin
        IssBankStatementHeaderCZB.TestField("Bank Account No.");
        if BankAccount."No." <> IssBankStatementHeaderCZB."Bank Account No." then begin
            BankAccount.Get(IssBankStatementHeaderCZB."Bank Account No.");
            BankAccount.TestField("Payment Jnl. Template Name CZB");
            BankAccount.TestField("Payment Jnl. Batch Name CZB");
            BankAccount.TestField("Non Assoc. Payment Account CZB");
        end;
        OnAfterGetBankAccount(IssBankStatementHeaderCZB, BankAccount);
    end;

    local procedure GetLastLineNo(): Integer;
    var
        CurrentGenJournalLine: Record "Gen. Journal Line";
    begin
        CurrentGenJournalLine.SetRange("Journal Template Name", BankAccount."Payment Jnl. Template Name CZB");
        CurrentGenJournalLine.SetRange("Journal Batch Name", BankAccount."Payment Jnl. Batch Name CZB");
        if CurrentGenJournalLine.FindLast() then
            exit(CurrentGenJournalLine."Line No.");
    end;

    local procedure DeleteGeneralJournalLines(IssBankStatementHeaderCZB: Record "Iss. Bank Statement Header CZB")
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        GenJournalLine.SetRange("Journal Template Name", BankAccount."Payment Jnl. Template Name CZB");
        GenJournalLine.SetRange("Journal Batch Name", BankAccount."Payment Jnl. Batch Name CZB");
        GenJournalLine.SetRange("Document No.", IssBankStatementHeaderCZB."No.");
        OnDeleteGeneralJournalLinesOnAfterSetGenJournalLineFilters(GenJournalLine, IssBankStatementHeaderCZB, BankAccount);
        GenJournalLine.DeleteAll(true);
    end;

    local procedure CreateGeneralJournalLine(IssBankStatementHeaderCZB: Record "Iss. Bank Statement Header CZB"; IssBankStatementLineCZB: Record "Iss. Bank Statement Line CZB")
    var
        GenJournalLine: Record "Gen. Journal Line";
        GenJournalTemplate: Record "Gen. Journal Template";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCreateGenJournalLine(IssBankStatementHeaderCZB, IssBankStatementLineCZB, IsHandled);
        if IsHandled then
            exit;

        GenJournalLine.SetSuppressCommit(true);
        GenJournalLine.Init();
        GenJournalLine."Journal Template Name" := BankAccount."Payment Jnl. Template Name CZB";
        GenJournalLine."Journal Batch Name" := BankAccount."Payment Jnl. Batch Name CZB";
        GenJournalLine."Line No." := LastLineNo + IssBankStatementLineCZB."Line No.";
        GenJournalLine."Bank Statement No. CZB" := IssBankStatementLineCZB."Bank Statement No.";
        GenJournalTemplate.Get(GenJournalLine."Journal Template Name");
        GenJournalLine."Source Code" := GenJournalTemplate."Source Code";

        GenJournalLine.Validate("Posting Date", IssBankStatementHeaderCZB."Document Date");
        GenJournalLine.Validate("Document No.", IssBankStatementHeaderCZB."No.");
        case IssBankStatementLineCZB.Type of
            IssBankStatementLineCZB.Type::Customer:
                GenJournalLine.Validate("Account Type", GenJournalLine."Account Type"::Customer);
            IssBankStatementLineCZB.Type::Vendor:
                GenJournalLine.Validate("Account Type", GenJournalLine."Account Type"::Vendor);
            IssBankStatementLineCZB.Type::"Bank Account":
                GenJournalLine.Validate("Account Type", GenJournalLine."Account Type"::"Bank Account");
            IssBankStatementLineCZB.Type::Employee:
                GenJournalLine.Validate("Account Type", GenJournalLine."Account Type"::Employee);
        end;
        GenJournalLine.InitDocumentTypeCZB(-IssBankStatementLineCZB."Amount (Bank Stat. Currency)");
        GenJournalLine.Validate("Document Type");

        OnCreateGeneralJournalLineOnAfterValidateAccountType(IssBankStatementHeaderCZB, IssBankStatementLineCZB, GenJournalLine);

        if IssBankStatementLineCZB."No." <> '' then
            GenJournalLine.Validate("Account No.", IssBankStatementLineCZB."No.")
        else
            GenJournalLine.Validate("Account No.", BankAccount."Non Assoc. Payment Account CZB");
        GenJournalLine.Validate(Amount, -IssBankStatementLineCZB."Amount (Bank Stat. Currency)");
        GenJournalLine.Validate("Currency Code", IssBankStatementLineCZB."Bank Statement Currency Code");
        GenJournalLine.Validate("Currency Factor", IssBankStatementLineCZB."Bank Statement Currency Factor");
        GenJournalLine."Bank Account No. CZL" := IssBankStatementLineCZB."Account No.";
        GenJournalLine."Bank Account Code CZL" := IssBankStatementLineCZB."Cust./Vendor Bank Account Code";
        GenJournalLine."IBAN CZL" := IssBankStatementLineCZB.IBAN;
        GenJournalLine.Description := IssBankStatementLineCZB.Description;
        GenJournalLine."Keep Description" := true;
        GenJournalLine.SetVariableSymbolCZB(
            IssBankStatementLineCZB."Variable Symbol", VariableSymbolToDescription, VariableSymbolToVariableSymbol, VariableSymbolToExtDocNo);
        GenJournalLine."Specific Symbol CZL" := IssBankStatementLineCZB."Specific Symbol";
        GenJournalLine."Constant Symbol CZL" := IssBankStatementLineCZB."Constant Symbol";
        GenJournalLine.Validate("Search Rule Code CZB", IssBankStatementHeaderCZB."Search Rule Code");
        if BankAccount."Post Per Line CZB" then begin
            GenJournalLine.Validate("Bal. Account Type", GenJournalLine."Bal. Account Type"::"Bank Account");
            GenJournalLine.Validate("Bal. Account No.", BankAccount."No.");
        end;
        OnAfterAssignGenJournalLine(IssBankStatementHeaderCZB, IssBankStatementLineCZB, BankAccount, GenJournalLine);
        GenJournalLine.Insert();

        if GenJournalLine.Amount > 0 then
            DebitTotal += IssBankStatementLineCZB."Amount (Bank Stat. Currency)"
        else
            CreditTotal += IssBankStatementLineCZB."Amount (Bank Stat. Currency)";
        VarJournalCreated := true;
    end;

    local procedure CreateSummaryLines(IssBankStatementHeaderCZB: Record "Iss. Bank Statement Header CZB")
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCreateSummaryLines(IssBankStatementHeaderCZB, CreditTotal, DebitTotal, IsHandled);
        if IsHandled then
            exit;

        LastLineNo := GetLastLineNo();
        if CreditTotal <> 0 then
            CreateSummaryLine(IssBankStatementHeaderCZB, CreditTotal, true);
        if DebitTotal <> 0 then
            CreateSummaryLine(IssBankStatementHeaderCZB, DebitTotal, false);
    end;

    local procedure CreateSummaryLine(IssBankStatementHeaderCZB: Record "Iss. Bank Statement Header CZB"; AmountTotal: Decimal; IsCreditAmount: Boolean)
    var
        GenJournalLine: Record "Gen. Journal Line";
        GenJournalTemplate: Record "Gen. Journal Template";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCreateSummaryLine(IssBankStatementHeaderCZB, LastLineNo, AmountTotal, IsCreditAmount, IsHandled);
        if IsHandled then
            exit;

        GenJournalLine.SetSuppressCommit(true);
        GenJournalLine.Init();
        GenJournalLine."Journal Template Name" := BankAccount."Payment Jnl. Template Name CZB";
        GenJournalLine."Journal Batch Name" := BankAccount."Payment Jnl. Batch Name CZB";
        GenJournalLine."Line No." := LastLineNo + 10000;
        GenJournalLine."Bank Statement No. CZB" := IssBankStatementHeaderCZB."No.";
        GenJournalTemplate.Get(GenJournalLine."Journal Template Name");
        GenJournalLine."Source Code" := GenJournalTemplate."Source Code";
        GenJournalLine.Validate("Posting Date", IssBankStatementHeaderCZB."Document Date");
        GenJournalLine.Validate("Document No.", IssBankStatementHeaderCZB."No.");
        GenJournalLine.Validate("Account Type", GenJournalLine."Account Type"::"Bank Account");
        GenJournalLine.Validate("Account No.", BankAccount."No.");
        GenJournalLine.Validate("Currency Code", BankAccount."Currency Code");
        GenJournalLine.Validate(Amount, AmountTotal);
        OnCreateSummaryLineOnBeforeInsertGenJournalLine(IssBankStatementHeaderCZB, BankAccount, LastLineNo, AmountTotal, IsCreditAmount, GenJournalLine);
        GenJournalLine.Insert();

        LastLineNo += GenJournalLine."Line No.";
    end;

    local procedure ApplyGeneralJournalLine(IssBankStatementHeaderCZB: Record "Iss. Bank Statement Header CZB") Result: Boolean
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        Result := true;
        GetBankAccount(IssBankStatementHeaderCZB);
        GenJournalLine.SetRange("Journal Template Name", BankAccount."Payment Jnl. Template Name CZB");
        GenJournalLine.SetRange("Journal Batch Name", BankAccount."Payment Jnl. Batch Name CZB");
        GenJournalLine.SetRange("Document No.", IssBankStatementHeaderCZB."No.");
        GenJournalLine.SetFilter("Search Rule Code CZB", '<>%1', '');
        OnApplyGeneralJournalLineOnAfterSetGenJournalLineFilters(GenJournalLine, IssBankStatementHeaderCZB, BankAccount);
        if GenJournalLine.FindSet() then begin
            Commit(); // the matching bank payment should not rollback already created general journal lines in case of error
            repeat
                if not HideMessages then
                    WindowDialog.Update(1, GenJournalLine."Line No.");
                if not Codeunit.Run(Codeunit::"Match Bank Payment CZB", GenJournalLine) then
                    Result := false;
                OnAfterMatchingBankPayment(IssBankStatementHeaderCZB, GenJournalLine);
            until GenJournalLine.Next() = 0;
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreateGenJournalLine(IssBankStatementHeaderCZB: Record "Iss. Bank Statement Header CZB"; IssBankStatementLineCZB: Record "Iss. Bank Statement Line CZB"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterAssignGenJournalLine(IssBankStatementHeaderCZB: Record "Iss. Bank Statement Header CZB"; IssBankStatementLineCZB: Record "Iss. Bank Statement Line CZB"; BankAccount: Record "Bank Account"; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterMatchingBankPayment(IssBankStatementHeaderCZB: Record "Iss. Bank Statement Header CZB"; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreateSummaryLines(IssBankStatementHeaderCZB: Record "Iss. Bank Statement Header CZB"; CreditTotal: Decimal; DebitTotal: Decimal; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreateSummaryLine(IssBankStatementHeaderCZB: Record "Iss. Bank Statement Header CZB"; LastLineNo: Integer; AmountTotal: Decimal; IsCreditAmount: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCreateSummaryLineOnBeforeInsertGenJournalLine(IssBankStatementHeaderCZB: Record "Iss. Bank Statement Header CZB"; BankAccount: Record "Bank Account"; LastLineNo: Integer; AmountTotal: Decimal; IsCreditAmount: Boolean; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnApplyGeneralJournalLineOnAfterSetGenJournalLineFilters(var GenJournalLine: Record "Gen. Journal Line"; IssBankStatementHeaderCZB: Record "Iss. Bank Statement Header CZB"; BankAccount: Record "Bank Account")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnDeleteGeneralJournalLinesOnAfterSetGenJournalLineFilters(var GenJournalLine: Record "Gen. Journal Line"; IssBankStatementHeaderCZB: Record "Iss. Bank Statement Header CZB"; BankAccount: Record "Bank Account")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCreateGeneralJournalLineOnAfterValidateAccountType(IssBankStatementHeaderCZB: Record "Iss. Bank Statement Header CZB"; IssBankStatementLineCZB: Record "Iss. Bank Statement Line CZB"; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetBankAccount(IssBankStatementHeaderCZB: Record "Iss. Bank Statement Header CZB"; var BankAccount: Record "Bank Account")
    begin
    end;
}
