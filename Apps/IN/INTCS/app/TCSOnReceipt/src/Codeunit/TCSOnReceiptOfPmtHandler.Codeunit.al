// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TCS.TCSOnReceipt;

using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.TaxEngine.TaxTypeHandler;
using Microsoft.Finance.TCS.TCSBase;
using Microsoft.Finance.Currency;
using Microsoft.Finance.TaxBase;
using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Sales.Customer;
using Microsoft.Foundation.NoSeries;

codeunit 18903 "TCS On Receipt Of Pmt. Handler"
{
    var
        TCSPostingSetupErr: Label 'TCS Posting Setup not defined for TCS Nature of Collection %1.', Comment = '%1 = TCS Nature of Collection';

    local procedure GetTCSAmount(GenJnlLine: Record "Gen. Journal Line"): Decimal
    var
        TaxTransactionValue: Record "Tax Transaction Value";
        TCSSetup: Record "TCS Setup";
    begin
        if not TCSSetup.Get() then
            exit;

        TCSSetup.TestField("Tax Type");

        TaxTransactionValue.SetRange("Tax Record ID", GenJnlLine.RecordId);
        TaxTransactionValue.SetRange("Value Type", TaxTransactionValue."Value Type"::COMPONENT);
        TaxTransactionValue.SetRange("Tax Type", TCSSetup."Tax Type");
        TaxTransactionValue.SetFilter(Percent, '<>%1', 0);
        if not TaxTransactionValue.IsEmpty() then
            TaxTransactionValue.CalcSums(Amount);

        exit(TaxTransactionValue.Amount);
    end;

    local procedure GetTCSAmountLCY(GenJnlLine: Record "Gen. Journal Line"; TCSAmount: Decimal): Decimal
    var
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        TCSManagement: Codeunit "TCS Management";
        TCSAmt: Decimal;
    begin
        TCSAmt := CurrencyExchangeRate.ExchangeAmtFCYToLCY(GenJnlLine."Posting Date", GenJnlLine."Currency Code", TCSAmount, GenJnlLine."Currency Factor");
        exit(TCSManagement.RoundTCSAmount(TCSAmt));
    end;

    local procedure GetTCSComponentValues(GenJnlLine: Record "Gen. Journal Line"; var ComponentRate: Decimal; var ComponentAmount: Decimal; ComponentID: Integer)
    var
        TCSSetup: Record "TCS Setup";
        TaxBaseSubscriber: Codeunit "Tax Base Subscribers";
    begin
        if not TCSSetup.Get() then
            exit;

        TCSSetup.TestField("Tax Type");
        TaxBaseSubscriber.OnBeforeGetTaxComponentValuesFromRecID(GenJnlLine.RecordId, TCSSetup."Tax Type", ComponentID, ComponentRate, ComponentAmount);
    end;

    local procedure PostCustomerEntry(var GenJnlLine: Record "Gen. Journal Line"; sender: Codeunit "Gen. Jnl.-Post Line")
    var
        GLSetup: Record "General Ledger Setup";
        GenJournalLine: Record "Gen. Journal Line";
        TaxTransactionValue: Record "Tax Transaction Value";
        TCSPostingSetup: Record "TCS Posting Setup";
        Customer: Record Customer;
        NoSeriesMgt: Codeunit NoSeriesManagement;
        TCSManagement: Codeunit "TCS Management";
        TCSAmount, TCSAmountLCY : Decimal;
        TCSAccount: Code[20];
        TCSDebitNoteNo: Code[20];
    begin
        TaxTransactionValue.SetRange("Tax Record ID", GenJnlLine.RecordId);
        if TaxTransactionValue.IsEmpty() then
            exit;

        if (GenJnlLine."TCS Nature of Collection" = '') or (GenJnlLine."TCS on Recpt. Of Pmt. Amount" = 0) then
            exit;

        GLSetup.Get();
        GLSetup.TestField("TCS Debit Note No.");
        TCSDebitNoteNo := NoSeriesMgt.GetNextNo(GLSetup."TCS Debit Note No.", GenJnlLine."Posting Date", true);

        TCSPostingSetup.SetRange("TCS Nature of Collection", GenJnlLine."TCS Nature of Collection");
        TCSPostingSetup.SetFilter("Effective Date", '<=%1', GenJnlLine."Posting Date");
        if TCSPostingSetup.FindLast() then begin
            TCSPostingSetup.TestField("TCS Account No.");
            TCSAccount := TCSPostingSetup."TCS Account No.";
        end else
            Error(TCSPostingSetupErr, GenJnlLine."TCS Nature of Collection");

        GenJnlLine.TestField("Document Type", GenJnlLine."Document Type"::Payment);
        GenJnlLine.TestField("Account Type", GenJnlLine."Account Type"::Customer);
        Customer.Get(GenJnlLine."Account No.");
        Customer.TestField("Customer Posting Group");
        GenJnlLine.TestField("TCS Nature of Collection");

        TCSAmount := TCSManagement.RoundTCSAmount(GetTCSAmount(GenJnlLine));
        if TCSAmount = 0 then
            exit;

        if GenJnlLine."Currency Code" <> '' then
            TCSAmountLCY := GetTCSAmountLCY(GenJnlLine, TCSAmount)
        else
            TCSAmountLCY := TCSAmount;

        GenJournalLine := GenJnlLine;
        Clear(GenJournalLine."Tax ID");
        Clear(GenJournalLine."Line No.");
        Clear(GenJnlLine."TCS On Recpt. Of Pmt. Amount");
        Clear(GenJournalLine."Applies-to ID");
        Clear(GenJournalLine."Applies-to Doc. Type");
        Clear(GenJournalLine."Applies-to Doc. No.");
        Clear(GenJournalLine."Applies-to Ext. Doc. No.");
        Clear(GenJournalLine."Applies-to Invoice Id");
        GenJournalLine."Document Type" := GenJournalLine."Document Type"::Invoice;
        GenJournalLine."Document No." := TCSDebitNoteNo;
        GenJournalLine."Account Type" := GenJournalLine."Account Type"::Customer;
        GenJournalLine."Account No." := Customer."No.";
        GenJournalLine."Bal. Account Type" := GenJournalLine."Bal. Account Type"::"G/L Account";
        GenJournalLine."Bal. Account No." := TCSAccount;
        GenJournalLine."System-Created Entry" := true;
        GenJournalLine.Validate(Amount, TCSAmount);
        GenJournalLine.Validate("Amount (LCY)", TCSAmountLCY);
        InsertTCSEntryDebitNote(GenJnlLine, GenJournalLine, sender);
        sender.RunWithCheck(GenJournalLine);
    end;

    local procedure InsertTCSEntryDebitNote(GenJnlLine: Record "Gen. Journal Line"; GenJournalLine: Record "Gen. Journal Line"; sender: Codeunit "Gen. Jnl.-Post Line")
    var
        Customer: Record Customer;
        CustomerPostingGroup: Record "Customer Posting Group";
        TCSEntry: Record "TCS Entry";
        CustomerConcessionalCode: Record "Customer Concessional Code";
        ConcessionalCode: Code[10];
        ConcessionalFormNo: Code[20];
        ComponentRate: Decimal;
        ComponentAmount: Decimal;
    begin
        if (GenJournalLine."TCS Nature of Collection" = '') or (GenJournalLine."TCS on Recpt. Of Pmt. Amount" = 0) then
            exit;

        Customer.Get(GenJournalLine."Account No.");
        CustomerPostingGroup.Get(Customer."Customer Posting Group");
        CustomerConcessionalCode.SetRange("Customer No.", Customer."No.");
        CustomerConcessionalCode.SetRange("TCS Nature of Collection", GenJournalLine."TCS Nature of Collection");
        if CustomerConcessionalCode.FindFirst() then begin
            ConcessionalCode := CustomerConcessionalCode."Concessional Code";
            ConcessionalFormNo := CustomerConcessionalCode."Concessional Form No.";
        end;

        TCSEntry.Init();
        TCSEntry."Entry No." := 0;
        TCSEntry."Document Type" := GenJnlLine."Document Type"; // Payment
        TCSEntry."Document No." := GenJnlLine."Document No."; // Payment Document No.
        TCSEntry."Posting Date" := GenJournalLine."Posting Date";
        TCSEntry."Account Type" := TCSEntry."Account Type"::"G/L Account";
        TCSEntry.Description := GenJournalLine.Description;
        TCSEntry."Account No." := GenJournalLine."Bal. Account No.";
        TCSEntry."Customer Account No." := CustomerPostingGroup."Receivables Account";
        TCSEntry."TCS Nature of Collection" := GenJournalLine."TCS Nature of Collection";
        TCSEntry."Customer No." := Customer."No.";
        TCSEntry."Assessee Code" := Customer."Assessee Code";
        TCSEntry."Transaction No." := sender.GetNextTransactionNo();
        GetTCSComponentValues(GenJnlLine, ComponentRate, ComponentAmount, 1);
        TCSEntry."TCS %" := ComponentRate;
        TCSEntry."TCS Amount" := Abs(GenJournalLine.Amount);
        GetTCSComponentValues(GenJnlLine, ComponentRate, ComponentAmount, 2);
        TCSEntry."eCESS %" := ComponentRate;
        TCSEntry."eCESS Amount" := ComponentAmount;
        GetTCSComponentValues(GenJnlLine, ComponentRate, ComponentAmount, 3);
        TCSEntry."Surcharge %" := ComponentRate;
        TCSEntry."Surcharge Amount" := ComponentAmount;
        GetTCSComponentValues(GenJnlLine, ComponentRate, ComponentAmount, 4);
        TCSEntry."SHE Cess %" := ComponentRate;
        TCSEntry."SHE Cess Amount" := ComponentAmount;
        TCSEntry."TCS Amount Including Surcharge" := TCSEntry."TCS Amount" + TCSEntry."Surcharge Amount";
        TCSEntry."Total TCS Including SHE CESS" := TCSEntry."TCS Amount" + TCSEntry."Surcharge Amount" + TCSEntry."eCESS Amount" + TCSEntry."SHE Cess Amount";
        TCSEntry."Bal. TCS Including SHE CESS" := TCSEntry."Total TCS Including SHE CESS";
        TCSEntry."Remaining TCS Amount" := TCSEntry."TCS Amount";
        TCSEntry."Remaining Surcharge Amount" := TCSEntry."Surcharge Amount";
        TCSEntry."Rem. Total TCS Incl. SHE CESS" := TCSEntry."Total TCS Including SHE CESS";
        TCSEntry."Customer P.A.N. No." := Customer."P.A.N. No.";
        GetTCSComponentValues(GenJnlLine, ComponentRate, ComponentAmount, 7);
        TCSEntry."TCS Base Amount" := ComponentAmount;
        TCSEntry."Surcharge Base Amount" := TCSEntry."TCS Amount";
        TCSEntry."Payment Amount" := TCSEntry."TCS Amount" + Abs(GenJnlLine.Amount);
        TCSEntry."TCS on Recpt. Of Pmt." := true;
        TCSEntry."T.C.A.N. No." := GenJournalLine."T.C.A.N. No.";
        TCSEntry."Concessional Code" := ConcessionalCode;
        TCSEntry."Concessional Form No." := ConcessionalFormNo;
        TCSEntry."User ID" := CopyStr(UserId(), 1, 50);
        TCSEntry."Source Code" := GenJnlLine."Source Code";
        TCSEntry.Applied := (GenJnlLine."Applies-to Doc. No." <> '') or (GenJnlLine."Applies-to ID" <> '');
        TCSEntry.Insert(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnAfterRunWithoutCheck', '', false, false)]
    local procedure PostCustomerEntryTCSOnRecptOfPmt(var GenJnlLine: Record "Gen. Journal Line"; sender: Codeunit "Gen. Jnl.-Post Line")
    begin
        PostCustomerEntry(GenJnlLine, sender);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnNextTransactionNoNeeded', '', false, false)]
    local procedure HandleNewTransactionNoForTCSOnRecptOfPmt(GenJnlLine: Record "Gen. Journal Line"; var NewTransaction: Boolean)
    begin
        if not GenJnlLine."System-Created Entry" then
            exit;

        if GenJnlLine."TCS On Recpt. Of Pmt. Amount" = 0 then
            exit;

        NewTransaction := false;
    end;
}
