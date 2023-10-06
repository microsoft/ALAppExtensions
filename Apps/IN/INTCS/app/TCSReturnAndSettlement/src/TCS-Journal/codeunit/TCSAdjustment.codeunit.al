// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TCS.TCSReturnAndSettlement;

using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Sales.Customer;
using Microsoft.Purchases.Vendor;
using Microsoft.Bank.BankAccount;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.TCS.TCSBase;

codeunit 18870 "TCS Adjustment"
{
    var
        LastTCSJournalLine: Record "TCS Journal Line";
        OpenFromBatch: Boolean;
        JournalLbl: Label '%1 journal', Comment = '%1=Journal';
        DefaultLbl: Label 'DEFAULT';
        DefaultJnlLbl: Label 'Default Journal';
        TCSTemplateNameLbl: Label 'TCS Adjustment';

    procedure TCSTemplateSelection(
        FormID: Integer;
        var TCSJournalLine: Record "TCS Journal Line";
        var JnlSelected: Boolean)
    var
        TCSJournalTemplate: Record "TCS Journal Template";
    begin
        JnlSelected := true;
        TCSJournalTemplate.DeleteAll();
        TCSJournalTemplate.Reset();
        if not OpenFromBatch then
            TCSJournalTemplate.SetRange("Form ID", FormID);

        case TCSJournalTemplate.Count() of
            0:
                begin
                    TCSJournalTemplate.Init();
                    TCSJournalTemplate.Name := CopyStr(TCSTemplateNameLbl, 1, MaxStrLen(TCSJournalTemplate.Name));
                    TCSJournalTemplate.Description := StrSubstNo(JournalLbl, TCSTemplateNameLbl);
                    TCSJournalTemplate."Form ID" := Page::"TCS Adjustment Journal";
                    TCSJournalTemplate.Insert();
                    Commit();
                end;
            1:
                TCSJournalTemplate.FindFirst();
            else
                JnlSelected := Page.RunModal(0, TCSJournalTemplate) = Action::LookupOK;
        end;

        if JnlSelected then begin
            TCSJournalLine.FilterGroup := 2;
            TCSJournalLine.SetRange("Journal Template Name", TCSJournalTemplate.Name);
            TCSJournalLine.FilterGroup := 0;
            if OpenFromBatch then begin
                TCSJournalLine."Journal Template Name" := '';
                Page.Run(TCSJournalTemplate."Form ID", TCSJournalLine);
            end;
        end;
    end;

    procedure TemplateSelectionFromTCSBatch(var TCSJournalBatch: Record "TCS Journal Batch")
    var
        TCSJournalLine: Record "TCS Journal Line";
        JnlSelected: Boolean;
    begin
        OpenFromBatch := true;
        TCSJournalLine."Journal Batch Name" := TCSJournalBatch.Name;
        TCSTemplateSelection(0, TCSJournalLine, JnlSelected);
    end;

    procedure OpenTCSJnl(
        var CurrentTCSJnlBatchName: Code[10];
        var TCSJournalLine: Record "TCS Journal Line")
    begin
        CheckTCSTemplateName(TCSJournalLine.GetRangeMax("Journal Template Name"), CurrentTCSJnlBatchName);
        TCSJournalLine.FilterGroup := 2;
        TCSJournalLine.SetRange("Journal Batch Name", CurrentTCSJnlBatchName);
        TCSJournalLine.FilterGroup := 0;
    end;

    procedure OpenTCSJnlBatch(var TCSJournalBatch: Record "TCS Journal Batch")
    var
        CopyOfTCSJournalBatch: Record "TCS Journal Batch";
        TCSJournalTemplate: Record "TCS Journal Template";
        TCSJournalLine: Record "TCS Journal Line";
        JnlSelected: Boolean;
    begin
        CopyOfTCSJournalBatch := TCSJournalBatch;
        if not TCSJournalBatch.FindFirst() then begin
            if not TCSJournalTemplate.FindFirst() then
                TCSTemplateSelection(0, TCSJournalLine, JnlSelected);

            if not TCSJournalTemplate.IsEmpty then
                CheckTCSTemplateName(TCSJournalTemplate.Name, TCSJournalBatch.Name);

            if TCSJournalBatch.FindFirst() then;
            CopyOfTCSJournalBatch := TCSJournalBatch;
        end;

        if TCSJournalBatch.GetFilter("Journal Template Name") = '' then begin
            TCSJournalBatch.FilterGroup(2);
            TCSJournalBatch.SetRange("Journal Template Name", TCSJournalBatch."Journal Template Name");
            TCSJournalBatch.FilterGroup(0);
        end;

        TCSJournalBatch := CopyOfTCSJournalBatch;
    end;

    procedure CheckTCSTemplateName(CurrentTCSTemplateName: Code[10]; var CurrentTCSBatchName: Code[10])
    var
        TCSJournalBatch: Record "TCS Journal Batch";
    begin
        TCSJournalBatch.SetRange("Journal Template Name", CurrentTCSTemplateName);
        if not TCSJournalBatch.Get(CurrentTCSTemplateName, CurrentTCSBatchName) then begin
            if not TCSJournalBatch.FindFirst() then begin
                TCSJournalBatch.Init();
                TCSJournalBatch."Journal Template Name" := CurrentTCSTemplateName;
                TCSJournalBatch.SetupNewBatch();
                TCSJournalBatch.Name := DefaultLbl;
                TCSJournalBatch.Description := DefaultJnlLbl;
                TCSJournalBatch.Insert(true);
                Commit();
            end;
            CurrentTCSBatchName := TCSJournalBatch.Name
        end;
    end;

    procedure SetNameTCS(CurrentTCSJnlBatchName: Code[10]; var TCSJournalLine: Record "TCS Journal Line")
    begin
        TCSJournalLine.FilterGroup := 2;
        TCSJournalLine.SetRange("Journal Batch Name", CurrentTCSJnlBatchName);
        TCSJournalLine.FilterGroup := 0;
        if TCSJournalLine.FindFirst() then;
    end;

    procedure CheckNameTCS(CurrentTCSJnlBatchName: Code[10]; var TCSJournalLine: Record "TCS Journal Line")
    var
        TCSJournalBatch: Record "TCS Journal Batch";
    begin
        TCSJournalBatch.Get(TCSJournalLine.GetRangeMax("Journal Template Name"), CurrentTCSJnlBatchName);
    end;

    procedure LookupNameTCS(
        var CurrentTCSJnlBatchName: Code[10];
        var TCSJournalLine: Record "TCS Journal Line")
    var
        TCSJournalBatch: Record "TCS Journal Batch";
    begin
        Commit();
        TCSJournalBatch."Journal Template Name" := TCSJournalLine.GetRangeMax("Journal Template Name");
        TCSJournalBatch.Name := TCSJournalLine.GetRangeMax("Journal Batch Name");
        TCSJournalBatch.FilterGroup := 2;
        TCSJournalBatch.SetRange("Journal Template Name", TCSJournalBatch."Journal Template Name");
        TCSJournalBatch.FilterGroup := 0;
        if Page.RunModal(0, TCSJournalBatch) = Action::LookupOK then begin
            CurrentTCSJnlBatchName := TCSJournalBatch.Name;
            SetNameTCS(CurrentTCSJnlBatchName, TCSJournalLine);
        end;
    end;

    procedure GetAccountsTCS(
        var TCSJournalLine: Record "TCS Journal Line";
        var AccName: Text[100];
        var BalAccName: Text[100])
    var
        GLAccount: Record "G/L Account";
        Customer: Record Customer;
        Vendor: Record Vendor;
        BankAccount: Record "Bank Account";
    begin
        if (TCSJournalLine."Account Type" <> LastTCSJournalLine."Account Type") or
           (TCSJournalLine."Account No." <> LastTCSJournalLine."Account No.")
        then begin
            AccName := '';
            if TCSJournalLine."Account No." <> '' then
                case TCSJournalLine."Account Type" of
                    TCSJournalLine."Account Type"::"G/L Account":
                        if GLAccount.Get(TCSJournalLine."Account No.") then
                            AccName := GLAccount.Name;
                    TCSJournalLine."Account Type"::Customer:
                        if Customer.Get(TCSJournalLine."Account No.") then
                            AccName := Customer.Name;
                end;
        end;

        if (TCSJournalLine."Bal. Account Type" <> LastTCSJournalLine."Bal. Account Type") or
           (TCSJournalLine."Bal. Account No." <> LastTCSJournalLine."Bal. Account No.") then begin
            BalAccName := '';
            if TCSJournalLine."Bal. Account No." <> '' then
                case TCSJournalLine."Bal. Account Type" of
                    TCSJournalLine."Bal. Account Type"::"G/L Account":
                        if GLAccount.Get(TCSJournalLine."Bal. Account No.") then
                            BalAccName := GLAccount.Name;
                    TCSJournalLine."Bal. Account Type"::Customer:
                        if Customer.Get(TCSJournalLine."Bal. Account No.") then
                            BalAccName := Customer.Name;
                    TCSJournalLine."Bal. Account Type"::Vendor:
                        if Vendor.Get(TCSJournalLine."Bal. Account No.") then
                            BalAccName := Vendor.Name;
                    TCSJournalLine."Bal. Account Type"::"Bank Account":
                        if BankAccount.Get(TCSJournalLine."Bal. Account No.") then
                            BalAccName := BankAccount.Name;
                end;
        end;
        LastTCSJournalLine := TCSJournalLine;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Check Line", 'OnAfterCheckGenJnlLine', '', false, false)]
    local procedure UpdateTCSEntryOnAdjustment(var GenJournalLine: Record "Gen. Journal Line")
    var
        TCSJournalLine: Record "TCS Journal Line";
    begin
        TCSJournalLine.SetRange("Journal Template Name", GenJournalLine."Journal Template Name");
        TCSJournalLine.SetRange("Journal Batch Name", GenJournalLine."Journal Batch Name");
        TCSJournalLine.SetRange("Line No.", GenJournalLine."Line No.");
        TCSJournalLine.SetRange("Document No.", GenJournalLine."Document No.");
        TCSJournalLine.SetRange(Adjustment, true);
        if TCSJournalLine.FindFirst() then
            UpdateTCSEntry(TCSJournalLine);
    end;

    local procedure UpdateTCSEntry(TCSJournalLine: Record "TCS Journal Line")
    var
        TCSEntry: Record "TCS Entry";
    begin
        TCSEntry.SetRange("Entry No.", TCSJournalLine."TCS Transaction No.");
        TCSEntry.SetRange("Document No.", TCSJournalLine."TCS Invoice No.");
        if not TCSEntry.FindFirst() then
            exit;

        TCSEntry.TestField("TCS Paid", false);
        TCSEntry."Challan Date" := TCSJournalLine."Challan Date";
        TCSEntry."Challan No." := TCSJournalLine."Challan No.";
        TCSEntry.Adjusted := TCSJournalLine.Adjustment;
        TCSEntry."Bal. TCS Including SHE CESS" := TCSJournalLine."Bal. TCS Including SHECESS";
        TCSEntry."Total TCS Including SHE CESS" := TCSJournalLine."Total TCS Incl. SHE CESS";
        if (TCSJournalLine."TCS % Applied" <> 0) or TCSJournalLine."TCS Adjusted" then
            TCSEntry."Adjusted TCS %" := TCSJournalLine."TCS % Applied"
        else
            TCSEntry."Adjusted TCS %" := TCSJournalLine."TCS %";

        if (TCSJournalLine."Surcharge % Applied" <> 0) or TCSJournalLine."Surcharge Adjusted" then
            TCSEntry."Adjusted Surcharge %" := TCSJournalLine."Surcharge % Applied"
        else
            TCSEntry."Adjusted Surcharge %" := TCSJournalLine."Surcharge %";

        if (TCSJournalLine."eCESS % Applied" <> 0) or TCSJournalLine."eCess Adjusted" then
            TCSEntry."Adjusted eCESS %" := TCSJournalLine."eCESS % Applied"
        else
            TCSEntry."Adjusted eCESS %" := TCSJournalLine."eCESS %";

        if (TCSJournalLine."SHE Cess % Applied" <> 0) or TCSJournalLine."SHE Cess Adjusted" then
            TCSEntry."Adjusted SHE CESS %" := TCSJournalLine."SHE Cess % Applied"
        else
            TCSEntry."Adjusted SHE CESS %" := TCSJournalLine."SHE Cess % on TCS";

        if (TCSJournalLine."Balance TCS Amount" <> 0) or TCSJournalLine."TCS Adjusted" then
            TCSEntry."TCS Amount" := TCSJournalLine."Balance TCS Amount";

        TCSEntry."Remaining TCS Amount" := TCSEntry."TCS Amount";
        if (TCSJournalLine."Balance Surcharge Amount" <> 0) or TCSJournalLine."Surcharge Adjusted" then
            TCSEntry."Surcharge Amount" := TCSJournalLine."Balance Surcharge Amount";

        if (TCSJournalLine."Balance eCESS on TCS Amt" <> 0) or TCSJournalLine."eCess Adjusted" then
            TCSEntry."eCESS Amount" := TCSJournalLine."Balance eCESS on TCS Amt";

        if (TCSJournalLine."Bal. SHE Cess on TCS Amt" <> 0) or TCSJournalLine."SHE Cess Adjusted" then
            TCSEntry."SHE Cess Amount" := TCSJournalLine."Bal. SHE Cess on TCS Amt";

        TCSEntry."Remaining Surcharge Amount" := TCSEntry."Surcharge Amount";
        TCSEntry."TCS Amount Including Surcharge" := TCSEntry."TCS Amount" + TCSEntry."Surcharge Amount";
        TCSEntry."Total TCS Including SHE CESS" := TCSJournalLine."Bal. TCS Including SHECESS";
        TCSEntry."Rem. Total TCS Incl. SHE CESS" := TCSJournalLine."Bal. TCS Including SHECESS";
        if TCSJournalLine."TCS Base Amount Adjusted" then begin
            TCSEntry."Original TCS Base Amount" := TCSEntry."TCS Base Amount";
            TCSEntry."TCS Base Amount" := TCSJournalLine."TCS Base Amount Applied";
            TCSEntry."TCS Base Amount Adjusted" := TCSJournalLine."TCS Base Amount Adjusted";
            TCSEntry."Surcharge Base Amount" := TCSJournalLine."Surcharge Base Amount";
        end;

        if TCSJournalLine."TCS Adjusted" then
            TCSEntry."Surcharge Base Amount" := TCSJournalLine."Surcharge Base Amount";
        TCSEntry.Modify();
    end;
}
