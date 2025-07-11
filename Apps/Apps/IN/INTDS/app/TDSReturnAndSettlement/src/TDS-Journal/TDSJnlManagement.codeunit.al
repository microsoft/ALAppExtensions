// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TDS.TDSReturnAndSettlement;

using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Sales.Customer;
using Microsoft.Purchases.Vendor;
using Microsoft.Bank.BankAccount;

codeunit 18747 "TDS Jnl Management"
{
    Access = Internal;

    var
        LastTDSJournalLine: Record "TDS Journal Line";
        TDSJournalTemplate: Record "TDS Journal Template";
        OpenFromBatch: Boolean;
        TemplateTypeLbl: Label 'TDS Jnl';
        JnlBatchNameLbl: Label 'DEFAULT';
        BatchDescriptionLbl: Label 'Default Journal';

    procedure TaxTemplateSelection(
        FormID: Integer;
        var TDSJournalLine: Record "TDS Journal Line";
        var JnlSelected: Boolean)
    begin
        JnlSelected := true;
        TDSJournalTemplate.DeleteAll();
        TDSJournalTemplate.Reset();
        if not OpenFromBatch then
            TDSJournalTemplate.SetRange("Form ID", FormID);

        case TDSJournalTemplate.Count() of
            0:
                begin
                    TDSJournalTemplate.Init();
                    TDSJournalTemplate.Name := TemplateTypeLbl;
                    TDSJournalTemplate.Description := TemplateTypeLbl;
                    TDSJournalTemplate.Insert();
                    Commit();
                end;
            1:
                TDSJournalTemplate.FindFirst();
            else
                JnlSelected := Page.RunModal(0, TDSJournalTemplate) = Action::LookupOK;
        end;

        if JnlSelected = false then
            exit;

        TDSJournalLine.FilterGroup := 2;
        TDSJournalLine.SetRange("Journal Template Name", TDSJournalTemplate.Name);
        TDSJournalLine.FilterGroup := 0;
        if OpenFromBatch then begin
            TDSJournalLine."Journal Template Name" := '';
            Page.Run(TDSJournalTemplate."Form ID", TDSJournalLine);
        end;
    end;

    procedure TemplateSelectionFromTaxBatch(var TDSJournalBatch: Record "TDS Journal Batch")
    var
        TDSJournalLine: Record "TDS Journal Line";
        JnlSelected: Boolean;
    begin
        OpenFromBatch := true;
        TDSJournalLine."Journal Batch Name" := TDSJournalBatch.Name;
        TaxTemplateSelection(0, TDSJournalLine, JnlSelected);
    end;

    procedure OpenTaxJnl(var CurrentTaxJnlBatchName: Code[10]; var TDSJournalLine: Record "TDS Journal Line")
    begin
        CheckTaxTemplateName(TDSJournalLine.GetRangeMax("Journal Template Name"), CurrentTaxJnlBatchName);
        TDSJournalLine.FilterGroup := 2;
        TDSJournalLine.SetRange("Journal Batch Name", CurrentTaxJnlBatchName);
        TDSJournalLine.FilterGroup := 0;
    end;

    procedure OpenTaxJnlBatch(var TDSJournalBatch: Record "TDS Journal Batch")
    var
        CopyOfTDSJournalBatch: Record "TDS Journal Batch";
    begin
        CopyOfTDSJournalBatch := TDSJournalBatch;
        if not TDSJournalBatch.FindFirst() then begin
            CheckTaxTemplateName(TDSJournalTemplate.Name, TDSJournalBatch.Name);
            if TDSJournalBatch.FindFirst() then;
            CopyOfTDSJournalBatch := TDSJournalBatch;
        end;

        if TDSJournalBatch.GetFilter("Journal Template Name") = '' then begin
            TDSJournalBatch.FilterGroup(2);
            TDSJournalBatch.SetRange("Journal Template Name", TDSJournalBatch."Journal Template Name");
            TDSJournalBatch.FilterGroup(0);
        end;
        TDSJournalBatch := CopyOfTDSJournalBatch;
    end;

    procedure CheckTaxTemplateName(CurrentTaxTemplateName: Code[10]; var CurrentTaxBatchName: Code[10])
    var
        TDSJournalBatch: Record "TDS Journal Batch";
    begin
        TDSJournalBatch.SetRange("Journal Template Name", CurrentTaxTemplateName);
        if not TDSJournalBatch.Get(CurrentTaxTemplateName, CurrentTaxBatchName) then begin
            if not TDSJournalBatch.FindFirst() then begin
                TDSJournalBatch.Init();
                TDSJournalBatch."Journal Template Name" := CurrentTaxTemplateName;
                TDSJournalBatch.SetupNewBatch();
                TDSJournalBatch.Name := JnlBatchNameLbl;
                TDSJournalBatch.Description := BatchDescriptionLbl;
                TDSJournalBatch.Insert(true);
                Commit();
            end;
            CurrentTaxBatchName := TDSJournalBatch.Name
        end;
    end;

    procedure SetNameTax(CurrentTaxJnlBatchName: Code[10]; var TDSJournalLine: Record "TDS Journal Line")
    begin
        TDSJournalLine.FilterGroup := 2;
        TDSJournalLine.SetRange("Journal Batch Name", CurrentTaxJnlBatchName);
        TDSJournalLine.FilterGroup := 0;
        if TDSJournalLine.FindFirst() then;
    end;

    procedure CheckNameTax(CurrentTaxJnlBatchName: Code[10]; var TDSJournalLine: Record "TDS Journal Line")
    var
        TDSJournalBatch: Record "TDS Journal Batch";
    begin
        TDSJournalBatch.Get(TDSJournalLine.GetRangeMax("Journal Template Name"), CurrentTaxJnlBatchName);
    end;

    procedure LookupNameTax(var CurrentTaxJnlBatchName: Code[10]; var TDSJournalLine: Record "TDS Journal Line")
    var
        TDSJournalBatch: Record "TDS Journal Batch";
    begin
        Commit();
        TDSJournalBatch."Journal Template Name" := TDSJournalLine.GetRangeMax("Journal Template Name");
        TDSJournalBatch.Name := TDSJournalLine.GetRangeMax("Journal Batch Name");
        TDSJournalBatch.FilterGroup := 2;
        TDSJournalBatch.SetRange("Journal Template Name", TDSJournalBatch."Journal Template Name");
        TDSJournalBatch.FilterGroup := 0;
        if Page.RunModal(0, TDSJournalBatch) = Action::LookupOK then begin
            CurrentTaxJnlBatchName := TDSJournalBatch.Name;
            SetNameTax(CurrentTaxJnlBatchName, TDSJournalLine);
        end;
    end;

    procedure GetAccountsTax(
        var TDSJournalLine: Record "TDS Journal Line";
        var AccName: Text[100];
        var BalAccName: Text[100])
    begin
        if (TDSJournalLine."Account Type" <> LastTDSJournalLine."Account Type") or
           (TDSJournalLine."Account No." <> LastTDSJournalLine."Account No.")
        then
            AccName := GetAccountName(TDSJournalLine."Account Type", TDSJournalLine."Account No.");

        if (TDSJournalLine."Bal. Account Type" <> LastTDSJournalLine."Bal. Account Type") or
           (TDSJournalLine."Bal. Account No." <> LastTDSJournalLine."Bal. Account No.")
        then
            BalAccName := GetAccountName(TDSJournalLine."Bal. Account Type", TDSJournalLine."Bal. Account No.");

        LastTDSJournalLine := TDSJournalLine;
    end;

    local procedure GetAccountName(AccountType: Enum "Gen. Journal Account Type"; AccountNo: Code[20]) AccountName: Text[100]
    var
        GLAccount: Record "G/L Account";
        Customer: Record Customer;
        Vendor: Record Vendor;
        BankAccount: Record "Bank Account";
    begin
        if AccountNo = '' then
            exit;

        case AccountType of
            AccountType::"G/L Account":
                begin
                    GLAccount.Get(AccountNo);
                    AccountName := GLAccount.Name;
                end;
            AccountType::Customer:
                begin
                    Customer.Get(AccountNo);
                    AccountName := Customer.Name;
                end;
            AccountType::Vendor:
                begin
                    Vendor.Get(AccountNo);
                    AccountName := Vendor.Name;
                end;
            AccountType::"Bank Account":
                begin
                    BankAccount.Get(AccountNo);
                    AccountName := BankAccount.Name;
                end;
        end;
    end;
}
