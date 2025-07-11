// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

using Microsoft.Finance.Dimension;
using Microsoft.Finance.VAT.Setup;
using Microsoft.Foundation.AuditCodes;
using Microsoft.Utilities;

codeunit 5291 "Mapping Helper SAF-T"
{
    Access = Internal;

    var
        AssortedJournalsSourceCodeDescriptionLbl: label 'Assorted Journals';
        GeneralLedgerJournalsSourceCodeDescriptionLbl: label 'General Ledger Journals';
        AccountReceivablesSourceCodeDescriptionLbl: label 'Account Receivables';
        AccountPayablesSourceCodeDescriptionLbl: label 'Account Payables';
        CountOutOfTotalTxt: label '%1/%2', Comment = '%1 - count, %2 - total count';

    procedure GetGenLedgerSourceCodeSAFT(): Code[9]
    begin
        exit('GL');
    end;

    procedure GetAccReceivableSourceCodeSAFT(): Code[9]
    begin
        exit('AR');
    end;

    procedure GetAccPayableSourceCodeSAFT(): Code[9]
    begin
        exit('AP');
    end;

    procedure GetAssortedSourceCodeSAFT(): Code[9]
    begin
        exit('A');
    end;

    procedure GetAssortedSourceCodeSAFTDescr(): Text[100]
    begin
        exit(AssortedJournalsSourceCodeDescriptionLbl);
    end;

    procedure GetVATPostingSetupMappedCount(): Text[20]
    var
        VATPostingSetup: Record "VAT Posting Setup";
        TotalCount: Integer;
        Count: Integer;
    begin
        TotalCount := VATPostingSetup.Count();
        if VATPostingSetup.FindSet() then
            repeat
                if (VATPostingSetup."Sale VAT Reporting Code" <> '') or (VATPostingSetup."Purch. VAT Reporting Code" <> '') then
                    Count += 1;
            until VATPostingSetup.Next() = 0;
        exit(StrSubstNo(CountOutOfTotalTxt, Count, TotalCount));
    end;

    procedure GetVATPostingSetupWithStartingDateCount(): Text[20]
    var
        VATPostingSetup: Record "VAT Posting Setup";
        TotalCount: Integer;
        Count: Integer;
    begin
        TotalCount := VATPostingSetup.Count();
        if VATPostingSetup.FindSet() then
            repeat
                if VATPostingSetup."Starting Date" <> 0D then
                    Count += 1;
            until VATPostingSetup.Next() = 0;
        exit(StrSubstNo(CountOutOfTotalTxt, Count, TotalCount));
    end;

    procedure InsertSAFTSourceCodes()
    begin
        InsertSAFTSourceCode(GetGenLedgerSourceCodeSAFT(), GeneralLedgerJournalsSourceCodeDescriptionLbl);
        InsertSAFTSourceCode(GetAccReceivableSourceCodeSAFT(), AccountReceivablesSourceCodeDescriptionLbl);
        InsertSAFTSourceCode(GetAccPayableSourceCodeSAFT(), AccountPayablesSourceCodeDescriptionLbl);
        InsertSAFTSourceCode(GetAssortedSourceCodeSAFT(), GetAssortedSourceCodeSAFTDescr());
    end;

    local procedure InsertSAFTSourceCode(Code: Code[9]; Description: Text[100])
    var
        SourceCodeSAFT: Record "Source Code SAF-T";
    begin
        SourceCodeSAFT.Validate(Code, Code);
        if SourceCodeSAFT.Find() then
            exit;
        SourceCodeSAFT.Validate(Description, Description);
        SourceCodeSAFT.Insert(true);
    end;

    local procedure InsertTempNameValueBuffer(var TempNameValueBuffer: Record "Name/Value Buffer" temporary; ID: Integer; Name: Text[250])
    begin
        TempNameValueBuffer.ID := ID;
        TempNameValueBuffer.Name := Name;
        if not TempNameValueBuffer.Insert() then
            TempNameValueBuffer.Modify(); // make it possible to overwrite by subscriber
    end;

    local procedure MapSourceCodeToSAFTSourceCodeFromBuffer(var TempNameValueBuffer: Record "Name/Value Buffer" temporary)
    var
        SourceCode: Record "Source Code";
        SourceCodeSetup: Record "Source Code Setup";
        RecRef: RecordRef;
        FieldRef: FieldRef;
        SourceCodeSAFT: Code[9];
    begin
        if not TempNameValueBuffer.FindSet() then
            exit;

        if not SourceCodeSetup.Get() then
            exit;

        RecRef.GetTable(SourceCodeSetup);
        repeat
            FieldRef := RecRef.Field(TempNameValueBuffer.ID);
            if Format(FieldRef.Value()) <> '' then
                if SourceCode.Get(FieldRef.Value()) then begin
                    SourceCodeSAFT := CopyStr(TempNameValueBuffer.Name, 1, MaxStrLen(SourceCode."Source Code SAF-T"));
                    SourceCode."Source Code SAF-T" := SourceCodeSAFT;
                    if SourceCode.Modify() then;
                end;
        until TempNameValueBuffer.Next() = 0;
    end;

    procedure MapRestSourceCodesToAssortedJournals()
    var
        SourceCode: Record "Source Code";
    begin
        SourceCode.SetRange("Source Code SAF-T", '');
        if SourceCode.FindSet() then
            repeat
                SourceCode."Source Code SAF-T" := GetAssortedSourceCodeSAFT();
                if SourceCode.Modify() then;
            until SourceCode.Next() = 0;
    end;

    local procedure SetRestFieldsOfSourceCodeSetupToAssortedJournals(var TempNameValueBuffer: Record "Name/Value Buffer" temporary)
    var
        RecRef: RecordRef;
        PrimaryKeyFieldRef: FieldRef;
        FieldRef: FieldRef;
        KeyRef: KeyRef;
        i: Integer;
    begin
        RecRef.Open(Database::"Source Code Setup");
        KeyRef := RecRef.KeyIndex(1);
        PrimaryKeyFieldRef := KeyRef.FieldIndex(1);
        for i := 1 to RecRef.FieldCount() do begin
            FieldRef := RecRef.FieldIndex(i);
            if FieldRef.Number() <> PrimaryKeyFieldRef.Number() then
                if not TempNameValueBuffer.Get(FieldRef.Number()) then
                    InsertTempNameValueBuffer(TempNameValueBuffer, FieldRef.Number(), GetAssortedSourceCodeSAFT());
        end;
    end;

    procedure UpdateSAFTSourceCodesBySetup()
    var
        TempNameValueBuffer: Record "Name/Value Buffer" temporary;
        SourceCodeSetup: Record "Source Code Setup";
    begin
        InsertTempNameValueBuffer(TempNameValueBuffer, SourceCodeSetup.FieldNo("General Journal"), GetGenLedgerSourceCodeSAFT());
        InsertTempNameValueBuffer(TempNameValueBuffer, SourceCodeSetup.FieldNo("IC General Journal"), GetGenLedgerSourceCodeSAFT());
        InsertTempNameValueBuffer(TempNameValueBuffer, SourceCodeSetup.FieldNo("Close Income Statement"), GetGenLedgerSourceCodeSAFT());
        InsertTempNameValueBuffer(TempNameValueBuffer, SourceCodeSetup.FieldNo("VAT Settlement"), GetGenLedgerSourceCodeSAFT());
        InsertTempNameValueBuffer(TempNameValueBuffer, SourceCodeSetup.FieldNo("Exchange Rate Adjmt."), GetGenLedgerSourceCodeSAFT());
        InsertTempNameValueBuffer(TempNameValueBuffer, SourceCodeSetup.FieldNo("Deleted Document"), GetGenLedgerSourceCodeSAFT());
        InsertTempNameValueBuffer(TempNameValueBuffer, SourceCodeSetup.FieldNo("Adjust Add. Reporting Currency"), GetGenLedgerSourceCodeSAFT());
        InsertTempNameValueBuffer(TempNameValueBuffer, SourceCodeSetup.FieldNo("Compress G/L"), GetGenLedgerSourceCodeSAFT());
        InsertTempNameValueBuffer(TempNameValueBuffer, SourceCodeSetup.FieldNo("Compress VAT Entries"), GetGenLedgerSourceCodeSAFT());
        InsertTempNameValueBuffer(TempNameValueBuffer, SourceCodeSetup.FieldNo("Compress Bank Acc. Ledger"), GetGenLedgerSourceCodeSAFT());
        InsertTempNameValueBuffer(TempNameValueBuffer, SourceCodeSetup.FieldNo("Compress Check Ledger"), GetGenLedgerSourceCodeSAFT());
        InsertTempNameValueBuffer(TempNameValueBuffer, SourceCodeSetup.FieldNo("Financially Voided Check"), GetGenLedgerSourceCodeSAFT());
        InsertTempNameValueBuffer(TempNameValueBuffer, SourceCodeSetup.FieldNo("Trans. Bank Rec. to Gen. Jnl."), GetGenLedgerSourceCodeSAFT());
        InsertTempNameValueBuffer(TempNameValueBuffer, SourceCodeSetup.FieldNo("Reversal"), GetGenLedgerSourceCodeSAFT());
        InsertTempNameValueBuffer(TempNameValueBuffer, SourceCodeSetup.FieldNo("Cash Flow Worksheet"), GetGenLedgerSourceCodeSAFT());
        InsertTempNameValueBuffer(TempNameValueBuffer, SourceCodeSetup.FieldNo("Payment Reconciliation Journal"), GetGenLedgerSourceCodeSAFT());

        InsertTempNameValueBuffer(TempNameValueBuffer, SourceCodeSetup.FieldNo("Sales"), GetAccReceivableSourceCodeSAFT());
        InsertTempNameValueBuffer(TempNameValueBuffer, SourceCodeSetup.FieldNo("Sales Journal"), GetAccReceivableSourceCodeSAFT());
        InsertTempNameValueBuffer(TempNameValueBuffer, SourceCodeSetup.FieldNo("Cash Receipt Journal"), GetAccReceivableSourceCodeSAFT());
        InsertTempNameValueBuffer(TempNameValueBuffer, SourceCodeSetup.FieldNo("Sales Entry Application"), GetAccReceivableSourceCodeSAFT());
        InsertTempNameValueBuffer(TempNameValueBuffer, SourceCodeSetup.FieldNo("Unapplied Sales Entry Appln."), GetAccReceivableSourceCodeSAFT());
        InsertTempNameValueBuffer(TempNameValueBuffer, SourceCodeSetup.FieldNo("Reminder"), GetAccReceivableSourceCodeSAFT());
        InsertTempNameValueBuffer(TempNameValueBuffer, SourceCodeSetup.FieldNo("Finance Charge Memo"), GetAccReceivableSourceCodeSAFT());
        InsertTempNameValueBuffer(TempNameValueBuffer, SourceCodeSetup.FieldNo("Compress Cust. Ledger"), GetAccReceivableSourceCodeSAFT());
        InsertTempNameValueBuffer(TempNameValueBuffer, SourceCodeSetup.FieldNo("Service Management"), GetAccReceivableSourceCodeSAFT());

        InsertTempNameValueBuffer(TempNameValueBuffer, SourceCodeSetup.FieldNo("Purchases"), GetAssortedSourceCodeSAFT());
        InsertTempNameValueBuffer(TempNameValueBuffer, SourceCodeSetup.FieldNo("Purchase Journal"), GetAssortedSourceCodeSAFT());
        InsertTempNameValueBuffer(TempNameValueBuffer, SourceCodeSetup.FieldNo("Payment Journal"), GetAssortedSourceCodeSAFT());
        InsertTempNameValueBuffer(TempNameValueBuffer, SourceCodeSetup.FieldNo("Purchase Entry Application"), GetAssortedSourceCodeSAFT());
        InsertTempNameValueBuffer(TempNameValueBuffer, SourceCodeSetup.FieldNo("Unapplied Purch. Entry Appln."), GetAssortedSourceCodeSAFT());
        InsertTempNameValueBuffer(TempNameValueBuffer, SourceCodeSetup.FieldNo("Compress Vend. Ledger"), GetAssortedSourceCodeSAFT());
        SetRestFieldsOfSourceCodeSetupToAssortedJournals(TempNameValueBuffer);
        OnCollectSourceCodeFieldsForSAFTMapping(TempNameValueBuffer);
        MapSourceCodeToSAFTSourceCodeFromBuffer(TempNameValueBuffer);
        MapRestSourceCodesToAssortedJournals();
    end;

    procedure InitDimensionFieldsSAFT()
    var
        Dimension: Record Dimension;
    begin
        Dimension.SetRange("Analysis Type SAF-T", '');
        if Dimension.FindSet() then
            repeat
                Dimension.UpdateSAFTAnalysisTypeFromNoSeries();
                Dimension.Validate("SAF-T Export", true);
                Dimension.Modify();
            until Dimension.Next() = 0;
    end;

    procedure InitVATPostingSetupFieldsSAFT()
    var
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        VATPostingSetup.SetRange("Purchase Tax Code SAF-T", '');
        if VATPostingSetup.FindSet() then
            repeat
                VATPostingSetup.InitTaxCodeSAFT();
            until VATPostingSetup.Next() = 0;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCollectSourceCodeFieldsForSAFTMapping(var TempNameValueBuffer: Record "Name/Value Buffer" temporary)
    begin
    end;

    [EventSubscriber(ObjectType::Table, Database::"Dimension", 'OnBeforeInsertEvent', '', false, false)]
    local procedure UpdateSAFAnalysisTypeOnBeforeDimensionInsert(var Rec: Record "Dimension"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() then
            exit;
        Rec.UpdateSAFTAnalysisTypeFromNoSeries();
    end;
}
