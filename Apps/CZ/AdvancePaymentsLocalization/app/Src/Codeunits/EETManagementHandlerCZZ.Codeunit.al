// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Finance;
using Microsoft.Finance.CashDesk;
using Microsoft.Finance.VAT.Ledger;

codeunit 31090 "EET Management Handler CZZ"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EET Management CZP", 'OnBeforeCheckLineWithAppliedDocument', '', false, false)]
    local procedure EETManagementOnBeforeCheckLineWithAppliedDocument(CashDocumentLineCZP: Record "Cash Document Line CZP"; var IsHandled: Boolean)
    var
        SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ";
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        AppliedDocumentAmount: Decimal;
        EntryCount: Integer;
    begin
        if not CashDocumentLineCZP.IsAdvancePaymentCZZ() and not CashDocumentLineCZP.IsAdvanceRefundCZZ() then
            exit;

        IsHandled := true;

        if CashDocumentLineCZP.IsAdvancePaymentCZZ() then begin
            SalesAdvLetterHeaderCZZ.Get(CashDocumentLineCZP."Advance Letter No. CZZ");
            SalesAdvLetterHeaderCZZ.TestField("Bill-to Customer No.", CashDocumentLineCZP."Account No.");
            SalesAdvLetterHeaderCZZ.TestField("Currency Code", CashDocumentLineCZP."Currency Code");
            SalesAdvLetterHeaderCZZ.CalcFields("To Pay");
            AppliedDocumentAmount := SalesAdvLetterHeaderCZZ."To Pay";
        end else begin
            SalesAdvLetterEntryCZZ.Reset();
            SalesAdvLetterEntryCZZ.SetRange("Document No.", CashDocumentLineCZP."Applies-To Doc. No.");
            SalesAdvLetterEntryCZZ.SetRange("Entry Type", SalesAdvLetterEntryCZZ."Entry Type"::Close);
            EntryCount := SalesAdvLetterEntryCZZ.Count();
            if EntryCount = 1 then begin
                SalesAdvLetterEntryCZZ.CalcSums(Amount);
                AppliedDocumentAmount := SalesAdvLetterEntryCZZ.Amount;
            end else
                if EntryCount > 1 then
                    exit;

            if EntryCount = 0 then begin
                SalesAdvLetterEntryCZZ.Reset();
                SalesAdvLetterEntryCZZ.SetRange("Document No.", CashDocumentLineCZP."Applies-To Doc. No.");
                SalesAdvLetterEntryCZZ.SetRange("Entry Type", SalesAdvLetterEntryCZZ."Entry Type"::Payment);
                SalesAdvLetterEntryCZZ.SetFilter(Amount, '>0');
                SalesAdvLetterEntryCZZ.CalcSums(Amount);
                AppliedDocumentAmount := SalesAdvLetterEntryCZZ.Amount;
            end;
        end;

        if CashDocumentLineCZP."Amount Including VAT" > AppliedDocumentAmount then
            CashDocumentLineCZP.TestField("Amount Including VAT", AppliedDocumentAmount);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EET Management CZP", 'OnGetAppliedDocumentType', '', false, false)]
    local procedure SetAdvanceDocumentTypeOnGetAppliedDocumentType(CashDocumentLineCZP: Record "Cash Document Line CZP"; var EETAppliedDocumentTypeCZL: Enum "EET Applied Document Type CZL")
    begin
        if CashDocumentLineCZP.IsAdvancePaymentCZZ() then
            EETAppliedDocumentTypeCZL := EETAppliedDocumentTypeCZL::"Advance CZZ";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EET Management CZP", 'OnGetAppliedDocumentNo', '', false, false)]
    local procedure SetAdvanceLetterNoOnGetAppliedDocumentNo(CashDocumentLineCZP: Record "Cash Document Line CZP"; var AppliedDocumentNo: Code[20])
    begin
        if CashDocumentLineCZP.IsAdvancePaymentCZZ() then
            AppliedDocumentNo := CashDocumentLineCZP."Advance Letter No. CZZ";
        if CashDocumentLineCZP.IsAdvanceRefundCZZ() then
            AppliedDocumentNo := '';
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EET Management CZP", 'OnAfterCollectVATEntries', '', false, false)]
    local procedure CollectVATEntriesOfAdvanceLetterOnAfterCollectVATEntries(EETEntryCZL: Record "EET Entry CZL"; CashDocumentLineCZP: Record "Cash Document Line CZP"; var TempVATEntry: Record "VAT Entry" temporary)
    var
        SalesAdvLetterEntryCZZClose: Record "Sales Adv. Letter Entry CZZ";
        SalesAdvLetterEntryCZZPayment: Record "Sales Adv. Letter Entry CZZ";
        SalesAdvLetterEntryCZZVATClose: Record "Sales Adv. Letter Entry CZZ";
        SalesAdvLetterEntryCZZVATPayment: Record "Sales Adv. Letter Entry CZZ";
    begin
        if not CashDocumentLineCZP.IsAdvancePaymentCZZ() and not CashDocumentLineCZP.IsAdvanceRefundCZZ() then
            exit;

        // Collect vat entries of advance payment
        if CashDocumentLineCZP.IsAdvancePaymentCZZ() then begin
            SalesAdvLetterEntryCZZPayment.SetLoadFields("Entry No.");
            SalesAdvLetterEntryCZZPayment.SetRange("Sales Adv. Letter No.", CashDocumentLineCZP."Advance Letter No. CZZ");
            SalesAdvLetterEntryCZZPayment.SetRange("Document No.", EETEntryCZL."Document No.");
            SalesAdvLetterEntryCZZPayment.SetRange("Entry Type", SalesAdvLetterEntryCZZPayment."Entry Type"::Payment);
            SalesAdvLetterEntryCZZPayment.SetRange(Cancelled, false);
            if SalesAdvLetterEntryCZZPayment.FindSet() then
                repeat
                    SalesAdvLetterEntryCZZVATPayment.SetLoadFields("VAT Entry No.");
                    SalesAdvLetterEntryCZZVATPayment.SetRange("Sales Adv. Letter No.", CashDocumentLineCZP."Advance Letter No. CZZ");
                    SalesAdvLetterEntryCZZVATPayment.SetRange("Related Entry", SalesAdvLetterEntryCZZPayment."Entry No.");
                    SalesAdvLetterEntryCZZVATPayment.SetRange("Entry Type", SalesAdvLetterEntryCZZVATPayment."Entry Type"::"VAT Payment");
                    SalesAdvLetterEntryCZZVATPayment.SetRange(Cancelled, false);
                    if SalesAdvLetterEntryCZZVATPayment.FindSet() then
                        repeat
                            AddVATEntryToBuffer(SalesAdvLetterEntryCZZVATPayment."VAT Entry No.", TempVATEntry);
                        until SalesAdvLetterEntryCZZVATPayment.Next() = 0;
                until SalesAdvLetterEntryCZZPayment.Next() = 0;
        end else begin
            // Collect vat entries of closed advance letter
            SalesAdvLetterEntryCZZClose.SetLoadFields("Entry No.", Amount);
            SalesAdvLetterEntryCZZClose.Reset();
            SalesAdvLetterEntryCZZClose.SetRange("Document No.", CashDocumentLineCZP."Applies-To Doc. No.");
            SalesAdvLetterEntryCZZClose.SetRange("Entry Type", SalesAdvLetterEntryCZZClose."Entry Type"::Close);
            if SalesAdvLetterEntryCZZClose.Count() > 1 then
                exit;
            if SalesAdvLetterEntryCZZClose.FindFirst() then begin
                SalesAdvLetterEntryCZZVATClose.SetLoadFields("VAT Entry No.");
                SalesAdvLetterEntryCZZVATClose.Reset();
                SalesAdvLetterEntryCZZVATClose.SetRange("Related Entry", SalesAdvLetterEntryCZZClose."Entry No.");
                SalesAdvLetterEntryCZZVATClose.SetRange("Entry Type", SalesAdvLetterEntryCZZVATClose."Entry Type"::"VAT Close");
                if SalesAdvLetterEntryCZZClose.Amount > 0 then
                    SalesAdvLetterEntryCZZVATClose.SetFilter(Amount, '>0')
                else
                    SalesAdvLetterEntryCZZVATClose.SetFilter(Amount, '<0');
                if SalesAdvLetterEntryCZZVATClose.FindSet() then
                    repeat
                        AddVATEntryToBuffer(SalesAdvLetterEntryCZZVATClose."VAT Entry No.", TempVATEntry);
                    until SalesAdvLetterEntryCZZVATClose.Next() = 0;
                exit;
            end;

            // Collect vat entries of unlink advance payment
            SalesAdvLetterEntryCZZPayment.SetLoadFields("Related Entry", Amount);
            SalesAdvLetterEntryCZZPayment.Reset();
            SalesAdvLetterEntryCZZPayment.SetRange("Document No.", CashDocumentLineCZP."Applies-To Doc. No.");
            SalesAdvLetterEntryCZZPayment.SetRange("Entry Type", SalesAdvLetterEntryCZZPayment."Entry Type"::Payment);
            if SalesAdvLetterEntryCZZPayment.FindLast() then begin
                SalesAdvLetterEntryCZZVATPayment.SetLoadFields("VAT Entry No.");
                SalesAdvLetterEntryCZZVATPayment.Reset();
                SalesAdvLetterEntryCZZVATPayment.SetRange("Related Entry", SalesAdvLetterEntryCZZPayment."Related Entry");
                SalesAdvLetterEntryCZZVATPayment.SetRange("Entry Type", SalesAdvLetterEntryCZZVATPayment."Entry Type"::"VAT Payment");
                if SalesAdvLetterEntryCZZPayment.Amount > 0 then
                    SalesAdvLetterEntryCZZVATPayment.SetFilter(Amount, '>0')
                else
                    SalesAdvLetterEntryCZZVATPayment.SetFilter(Amount, '<0');
                if SalesAdvLetterEntryCZZVATPayment.FindSet() then
                    repeat
                        AddVATEntryToBuffer(SalesAdvLetterEntryCZZVATPayment."VAT Entry No.", TempVATEntry);
                    until SalesAdvLetterEntryCZZVATPayment.Next() = 0;
            end;
        end;
    end;

    local procedure AddVATEntryToBuffer(VATEntryNo: Integer; var TempVATEntry: Record "VAT Entry" temporary): Boolean
    var
        VATEntry: Record "VAT Entry";
    begin
        VATEntry.Get(VATEntryNo);
        TempVATEntry.Init();
        TempVATEntry := VATEntry;
        exit(TempVATEntry.Insert());
    end;
}
