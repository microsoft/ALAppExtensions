// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.Posting;

using Microsoft.Bank;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.Finance.ReceivablesPayables;
using Microsoft.Finance.VAT.Calculation;
using Microsoft.Finance.VAT.Setup;
using Microsoft.Inventory.Intrastat;
using Microsoft.Inventory.Journal;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Purchases.Payables;
using Microsoft.Purchases.Reports;
using Microsoft.Purchases.Setup;
using Microsoft.Purchases.Vendor;
using System.Utilities;

codeunit 31039 "Purchase Posting Handler CZL"
{
    var
        VATPostingSetup: Record "VAT Posting Setup";
        BankOperationsFunctionsCZL: Codeunit "Bank Operations Functions CZL";
        PurchaseVATDelayPostingCZL: Codeunit "Purchase VAT Delay Posting CZL";
        PurchaseAlreadyExistsQst: Label 'Purchase %1 %2 already exists for this vendor.\Do you want to continue?',
            Comment = '%1 = Document Type; %2 = External Document No.; e.g. Purchase Invoice 123 already exists...';

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch. Post Invoice Events", 'OnPostLinesOnAfterGenJnlLinePost', '', false, false)]
    local procedure PurchasePostVATCurrencyFactorOnPostLinesOnAfterGenJnlLinePost(var GenJnlLine: Record "Gen. Journal Line"; TempInvoicePostingBuffer: Record "Invoice Posting Buffer"; PurchHeader: Record "Purchase Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    begin
        PurchaseVATDelayPostingCZL.PostPurchaseVATDelay(GenJnlLine, TempInvoicePostingBuffer, PurchHeader, GenJnlPostLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnAfterCheckPurchDoc', '', false, false)]
    local procedure CheckVatDateOnAfterCheckPurchDoc(var PurchHeader: Record "Purchase Header")
    var
        VATDateHandlerCZL: Codeunit "VAT Date Handler CZL";
    begin
        VATDateHandlerCZL.CheckVATDateCZL(PurchHeader);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnCheckAndUpdateOnAfterSetPostingFlags', '', false, false)]
    local procedure CheckPurchDocumentOnCheckAndUpdateOnAfterSetPostingFlags(var PurchHeader: Record "Purchase Header");
    begin
        CheckTariffNo(PurchHeader);
        CheckAndConfirmExternalDocumentNumber(PurchHeader);
    end;

    local procedure CheckTariffNo(PurchaseHeader: Record "Purchase Header")
    var
        PurchaseLine: Record "Purchase Line";
        TariffNumber: Record "Tariff Number";
        IsHandled: Boolean;
    begin
        OnBeforeCheckTariffNo(PurchaseHeader, IsHandled);
        if IsHandled then
            exit;

        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        if PurchaseLine.FindSet(false) then
            repeat
                if VATPostingSetup.Get(PurchaseLine."VAT Bus. Posting Group", PurchaseLine."VAT Prod. Posting Group") then
                    if VATPostingSetup."Reverse Charge Check CZL" = Enum::"Reverse Charge Check CZL"::"Limit Check" then begin
                        PurchaseLine.TestField("Tariff No. CZL");
                        if TariffNumber.Get(PurchaseLine."Tariff No. CZL") then
                            if TariffNumber."VAT Stat. UoM Code CZL" <> '' then
                                PurchaseLine.TestField("Unit of Measure Code", TariffNumber."VAT Stat. UoM Code CZL");
                    end;
            until PurchaseLine.Next() = 0;
    end;

    local procedure CheckAndConfirmExternalDocumentNumber(PurchaseHeader: Record "Purchase Header")
    var
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
        PersistConfirmResponseCZL: Codeunit "Persist. Confirm Response CZL";
        DocumentType: Enum "Gen. Journal Document Type";
        ExternalDocumentNo: Code[35];
        ConfirmQuestion: Text;
    begin
        if not GuiAllowed() or not PurchaseHeader.Invoice then
            exit;

        if PurchaseHeader."Document Type" in [PurchaseHeader."Document Type"::Order,
                                              PurchaseHeader."Document Type"::Invoice]
        then begin
            DocumentType := DocumentType::Invoice;
            ExternalDocumentNo := PurchaseHeader."Vendor Invoice No.";
        end else begin
            DocumentType := DocumentType::"Credit Memo";
            ExternalDocumentNo := PurchaseHeader."Vendor Cr. Memo No.";
        end;

        PurchasesPayablesSetup.Get();
        if not PurchasesPayablesSetup."Ext. Doc. No. Mandatory" and (ExternalDocumentNo = '') then
            exit;

        if CheckExternalDocumentNumber(PurchaseHeader, ExternalDocumentNo) then
            exit;

        ConfirmQuestion := StrSubstNo(PurchaseAlreadyExistsQst, DocumentType, ExternalDocumentNo);
        PersistConfirmResponseCZL.Init();
        if not PersistConfirmResponseCZL.GetResponseOrDefault(ConfirmQuestion, false) then
            Error('');
    end;

    local procedure CheckExternalDocumentNumber(PurchaseHeader: Record "Purchase Header"; ExternalDocumentNo: Code[35]): Boolean
    var
        VendLedgEntry: Record "Vendor Ledger Entry";
    begin
        exit(not PurchaseHeader.FindPostedDocumentWithSameExternalDocNo(VendLedgEntry, ExternalDocumentNo));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnBeforeCheckExternalDocumentNumber', '', false, false)]
    local procedure SkipCheckExternalDocumentNoOnBeforeCheckExternalDocumentNumber(var Handled: Boolean)
    var
        PersistConfirmResponseCZL: Codeunit "Persist. Confirm Response CZL";
    begin
        if Handled then
            exit;

        Handled := PersistConfirmResponseCZL.GetPersistentResponse();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch. Post Invoice Events", 'OnPostLedgerEntryOnBeforeGenJnlPostLine', '', false, false)]
    local procedure UpdateSymbolsAndBankAccountOnPostLedgerEntryOnBeforeGenJnlPostLine(var GenJnlLine: Record "Gen. Journal Line"; var PurchHeader: Record "Purchase Header")
    begin
        GenJnlLine."Specific Symbol CZL" := PurchHeader."Specific Symbol CZL";
        if PurchHeader."Variable Symbol CZL" <> '' then
            GenJnlLine."Variable Symbol CZL" := PurchHeader."Variable Symbol CZL"
        else
            GenJnlLine."Variable Symbol CZL" := BankOperationsFunctionsCZL.CreateVariableSymbol(GenJnlLine."External Document No.");
        GenJnlLine."Constant Symbol CZL" := PurchHeader."Constant Symbol CZL";
        GenJnlLine."Bank Account Code CZL" := PurchHeader."Bank Account Code CZL";
        GenJnlLine."Bank Account No. CZL" := PurchHeader."Bank Account No. CZL";
        GenJnlLine."IBAN CZL" := PurchHeader."IBAN CZL";
        GenJnlLine."SWIFT Code CZL" := PurchHeader."SWIFT Code CZL";
        GenJnlLine."Transit No. CZL" := PurchHeader."Transit No. CZL";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnBeforePurchInvHeaderInsert', '', false, false)]
    local procedure FillVariableSymbolOnBeforePurchInvHeaderInsert(var PurchInvHeader: Record "Purch. Inv. Header")
    begin
        if PurchInvHeader."Variable Symbol CZL" = '' then
            PurchInvHeader."Variable Symbol CZL" := BankOperationsFunctionsCZL.CreateVariableSymbol(PurchInvHeader."Vendor Invoice No.");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnBeforePurchCrMemoHeaderInsert', '', false, false)]
    local procedure FillVariableSymbolOnBeforePurchCrMemoHeaderInsert(var PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.")
    begin
        if PurchCrMemoHdr."Variable Symbol CZL" = '' then
            PurchCrMemoHdr."Variable Symbol CZL" := BankOperationsFunctionsCZL.CreateVariableSymbol(PurchCrMemoHdr."Vendor Cr. Memo No.");
    end;

    [EventSubscriber(ObjectType::Report, Report::"Purchase Document - Test", 'OnAfterCheckPurchaseDoc', '', false, false)]
    local procedure CheckExternalDocumentNoOnAfterCheckPurchaseDoc(PurchaseHeader: Record "Purchase Header"; var ErrorCounter: Integer; var ErrorText: array[99] of Text[250])
    var
        VendLedgEntry: Record "Vendor Ledger Entry";
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        VendorMgt: Codeunit "Vendor Mgt.";
        ExternalDocumentNoAlreadyExistsLbl: Label 'Purchase %1 %2 already exists for this vendor.', Comment = '%1 = Document Type, %2 = Document No.';
    begin
        if PurchaseHeader."Vendor Invoice No." <> '' then begin
            VendLedgEntry.SetCurrentKey("External Document No.");
            VendorMgt.SetFilterForExternalDocNo(VendLedgEntry, PurchaseHeader."Document Type", PurchaseHeader."Vendor Invoice No.", PurchaseHeader."Pay-to Vendor No.", PurchaseHeader."Document Date");
            if VendLedgEntry.IsEmpty() then begin
                PurchInvHeader.SetCurrentKey("Vendor Invoice No.");
                PurchInvHeader.SetRange("Vendor Invoice No.", PurchaseHeader."Vendor Invoice No.");
                PurchInvHeader.SetRange("Pay-to Vendor No.", PurchaseHeader."Pay-to Vendor No.");
                if not PurchInvHeader.IsEmpty() then
                    AddError(StrSubstNo(ExternalDocumentNoAlreadyExistsLbl, PurchaseHeader."Document Type", PurchaseHeader."Vendor Invoice No."), ErrorCounter, ErrorText);
            end;
        end;

        if PurchaseHeader."Vendor Cr. Memo No." <> '' then begin
            VendLedgEntry.SetCurrentKey("External Document No.");
            VendorMgt.SetFilterForExternalDocNo(VendLedgEntry, PurchaseHeader."Document Type", PurchaseHeader."Vendor Cr. Memo No.", PurchaseHeader."Pay-to Vendor No.", PurchaseHeader."Document Date");
            if not VendLedgEntry.IsEmpty() then
                AddError(StrSubstNo(ExternalDocumentNoAlreadyExistsLbl, PurchaseHeader."Document Type", PurchaseHeader."Vendor Cr. Memo No."), ErrorCounter, ErrorText)
            else begin
                PurchCrMemoHdr.SetCurrentKey("Vendor Cr. Memo No.");
                PurchCrMemoHdr.SetRange("Vendor Cr. Memo No.", PurchaseHeader."Vendor Cr. Memo No.");
                PurchCrMemoHdr.SetRange("Pay-to Vendor No.", PurchaseHeader."Pay-to Vendor No.");
                if not PurchCrMemoHdr.IsEmpty() then
                    AddError(StrSubstNo(ExternalDocumentNoAlreadyExistsLbl, PurchaseHeader."Document Type", PurchaseHeader."Vendor Cr. Memo No."), ErrorCounter, ErrorText);

            end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnBeforeTestPurchLineItemCharge', '', false, false)]
    local procedure SkipCheckOnBeforeTestPurchLineItemCharge(PurchaseLine: Record "Purchase Line"; var IsHandled: Boolean)
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        if PurchaseHeader.Get(PurchaseLine."Document Type", PurchaseLine."Document No.") then
            if not PurchaseHeader.Invoice then
                IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnPostItemJnlLineOnBeforeInitAmount', '', false, false)]
    local procedure SetGLCorrectionOnPostItemJnlLineOnBeforeInitAmount(var ItemJnlLine: Record "Item Journal Line"; PurchHeader: Record "Purchase Header"; var PurchLine: Record "Purchase Line")
    begin
        ItemJnlLine."G/L Correction CZL" := PurchHeader.Correction xor PurchLine."Negative CZL";
        ItemJnlLine."Additional Currency Factor CZL" := PurchHeader."Additional Currency Factor CZL";
    end;

    local procedure AddError(Text: Text[250]; var ErrorCounter: Integer; var ErrorText: array[99] of Text[250])
    begin
        ErrorCounter += 1;
        ErrorText[ErrorCounter] := Text;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckTariffNo(PurchaseHeader: Record "Purchase Header"; var IsHandled: Boolean);
    begin
    end;
}