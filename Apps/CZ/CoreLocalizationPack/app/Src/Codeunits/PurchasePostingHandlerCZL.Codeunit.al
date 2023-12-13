﻿// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.Posting;

using Microsoft.Bank;
using Microsoft.Finance.Currency;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.Finance.ReceivablesPayables;
using Microsoft.Finance.VAT.Calculation;
using Microsoft.Finance.VAT.Setup;
using Microsoft.Foundation.AuditCodes;
#if not CLEAN22
using Microsoft.Foundation.BatchProcessing;
using Microsoft.Foundation.Company;
#endif
using Microsoft.Inventory.Intrastat;
using Microsoft.Inventory.Journal;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Purchases.Payables;
using Microsoft.Purchases.Reports;
using Microsoft.Purchases.Setup;
using Microsoft.Purchases.Vendor;
#if not CLEAN22
using Microsoft.Sales.Document;
using System.Environment.Configuration;
#endif
using System.Utilities;

codeunit 31039 "Purchase Posting Handler CZL"
{
    var
        Currency: Record Currency;
        GLEntry: Record "G/L Entry";
        SourceCodeSetup: Record "Source Code Setup";
        VATPostingSetup: Record "VAT Posting Setup";
        BankOperationsFunctionsCZL: Codeunit "Bank Operations Functions CZL";
        GlobalAmountType: Option Base,VAT;
        PurchaseAlreadyExistsQst: Label 'Purchase %1 %2 already exists for this vendor.\Do you want to continue?',
            Comment = '%1 = Document Type; %2 = External Document No.; e.g. Purchase Invoice 123 already exists...';

#if not CLEAN23
#pragma warning disable AL0432
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnAfterPostInvPostBuffer', '', false, false)]
    local procedure PurchasePostVATDelayOnAfterPostInvPostBuffer(var InvoicePostBuffer: Record "Invoice Post. Buffer"; PurchHeader: Record "Purchase Header"; GLEntryNo: Integer; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    var
        VATCurrFactor: Decimal;
    begin
        if (PurchHeader."Currency Code" <> '') and (PurchHeader."Currency Factor" <> PurchHeader."VAT Currency Factor CZL") and
           ((InvoicePostBuffer."VAT Calculation Type" = InvoicePostBuffer."VAT Calculation Type"::"Reverse Charge VAT") or
            (InvoicePostBuffer."VAT Calculation Type" = InvoicePostBuffer."VAT Calculation Type"::"Normal VAT"))
        then begin
            VATPostingSetup.Get(InvoicePostBuffer."VAT Bus. Posting Group", InvoicePostBuffer."VAT Prod. Posting Group");
            VATPostingSetup.TestField("Purch. VAT Curr. Exch. Acc CZL");
            SourceCodeSetup.Get();
            SourceCodeSetup.TestField("Purchase VAT Delay CZL");
            GLEntry.Get(GLEntryNo);

            VATCurrFactor := 1;
            if PurchHeader."VAT Currency Factor CZL" <> 0 then
                VATCurrFactor := PurchHeader."Currency Factor" / PurchHeader."VAT Currency Factor CZL";

            PostVATDelay(PurchHeader, InvoicePostBuffer, -1, 1, true, GenJnlPostLine);
            PostVATDelay(PurchHeader, InvoicePostBuffer, 1, VATCurrFactor, false, GenJnlPostLine);
            if InvoicePostBuffer."VAT Calculation Type" = InvoicePostBuffer."VAT Calculation Type"::"Normal VAT" then begin
                PostVATDelayDifference(PurchHeader, InvoicePostBuffer, GlobalAmountType::Base, VATCurrFactor, GenJnlPostLine);
                PostVATDelayDifference(PurchHeader, InvoicePostBuffer, GlobalAmountType::VAT, VATCurrFactor, GenJnlPostLine);
            end;
        end;
    end;

    local procedure PostVATDelay(PurchaseHeader: Record "Purchase Header"; InvoicePostBuffer: Record "Invoice Post. Buffer"; Sign: Integer; CurrFactor: Decimal; IsCorrection: Boolean; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        GetCurrency(PurchaseHeader."Currency Code");
        if CurrFactor = 0 then
            CurrFactor := 1;

        InitGenJournalLine(PurchaseHeader, InvoicePostBuffer, GenJournalLine);

        GenJournalLine.Quantity := Sign * GenJournalLine.Quantity;
        GenJournalLine.Amount :=
            Sign * Round(InvoicePostBuffer.Amount * CurrFactor, Currency."Amount Rounding Precision");
        GenJournalLine."VAT Amount" :=
            Sign * Round(InvoicePostBuffer."VAT Amount" * CurrFactor, Currency."Amount Rounding Precision");
        GenJournalLine."VAT Base Amount" := GenJournalLine.Amount;
        GenJournalLine."Source Currency Amount" :=
            Sign * Round(InvoicePostBuffer."Amount (ACY)" * CurrFactor, Currency."Amount Rounding Precision");
        GenJournalLine."Source Curr. VAT Amount" :=
            Sign * Round(InvoicePostBuffer."VAT Amount (ACY)" * CurrFactor, Currency."Amount Rounding Precision");
        GenJournalLine."Source Curr. VAT Base Amount" := GenJournalLine."Source Currency Amount";
        GenJournalLine."VAT Difference" :=
            Sign * Round(InvoicePostBuffer."VAT Difference" * CurrFactor, Currency."Amount Rounding Precision");

        GenJournalLine.Correction := InvoicePostBuffer."Correction CZL" xor IsCorrection;
        GenJournalLine."VAT Bus. Posting Group" := InvoicePostBuffer."VAT Bus. Posting Group";
        GenJournalLine."VAT Prod. Posting Group" := InvoicePostBuffer."VAT Prod. Posting Group";
        GenJournalLine."Gen. Bus. Posting Group" := InvoicePostBuffer."Gen. Bus. Posting Group";
        GenJournalLine."Gen. Prod. Posting Group" := InvoicePostBuffer."Gen. Prod. Posting Group";
        if not PurchaseHeader.IsEU3PartyTradeFeatureEnabled() then
            PurchaseHeader."EU 3 Party Trade" := PurchaseHeader."EU 3-Party Trade CZL";
        GenJournalLine."EU 3-Party Trade" := PurchaseHeader."EU 3 Party Trade";
        GenJournalLine."EU 3-Party Intermed. Role CZL" := PurchaseHeader."EU 3-Party Intermed. Role CZL";

        GenJnlPostLine.RunWithCheck(GenJournalLine);
    end;

    local procedure PostVATDelayDifference(PurchaseHeader: Record "Purchase Header"; InvoicePostBuffer: Record "Invoice Post. Buffer"; AmountType: Option Base,VAT; CurrFactor: Decimal; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    var
        GenJournalLine: Record "Gen. Journal Line";
        Amount: Decimal;
        AccountNo: Code[20];
    begin
        GetCurrency(PurchaseHeader."Currency Code");
        if CurrFactor = 0 then
            CurrFactor := 1;

        case AmountType of
            AmountType::Base:
                Amount :=
                    InvoicePostBuffer.Amount -
                    Round(InvoicePostBuffer.Amount * CurrFactor, Currency."Amount Rounding Precision");
            AmountType::VAT:
                begin
                    Amount :=
                        InvoicePostBuffer."VAT Amount" -
                        Round(InvoicePostBuffer."VAT Amount" * CurrFactor, Currency."Amount Rounding Precision");
                    if Amount < 0 then
                        AccountNo := Currency."Realized Gains Acc."
                    else
                        AccountNo := Currency."Realized Losses Acc.";
                end;
        end;

        InitGenJournalLine(PurchaseHeader, InvoicePostBuffer, GenJournalLine);
        GenJournalLine."Gen. Posting Type" := GenJournalLine."Gen. Posting Type"::" ";
        if AccountNo <> '' then
            GenJournalLine."Account No." := AccountNo;
        GenJournalLine.Amount := Amount;

        GenJnlPostLine.RunWithCheck(GenJournalLine);
    end;

    local procedure InitGenJournalLine(PurchaseHeader: Record "Purchase Header"; InvoicePostBuffer: Record "Invoice Post. Buffer"; var GenJournalLine: Record "Gen. Journal Line")
    begin
        GenJournalLine.Init();
        GenJournalLine."Document Type" := GLEntry."Document Type";
        GenJournalLine."Document No." := GLEntry."Document No.";
        GenJournalLine."External Document No." := GLEntry."External Document No.";
        GenJournalLine."Account No." := VATPostingSetup."Purch. VAT Curr. Exch. Acc CZL";
        if InvoicePostBuffer."VAT Calculation Type" = InvoicePostBuffer."VAT Calculation Type"::"Reverse Charge VAT" then
            GenJournalLine."Bal. Account No." := VATPostingSetup."Purch. VAT Curr. Exch. Acc CZL";
        GenJournalLine."Posting Date" := PurchaseHeader."Posting Date";
        GenJournalLine."Document Date" := PurchaseHeader."Document Date";
#if not CLEAN22
        GenJournalLine."VAT Date CZL" := PurchaseHeader."VAT Date CZL";
#endif
        GenJournalLine."VAT Reporting Date" := PurchaseHeader."VAT Reporting Date";
        GenJournalLine."Original Doc. VAT Date CZL" := PurchaseHeader."Original Doc. VAT Date CZL";
        GenJournalLine.Description := PurchaseHeader."Posting Description";
        GenJournalLine."Reason Code" := PurchaseHeader."Reason Code";
        GenJournalLine."System-Created Entry" := InvoicePostBuffer."System-Created Entry";
        GenJournalLine."Source Currency Code" := PurchaseHeader."Currency Code";
        GenJournalLine.Correction := InvoicePostBuffer."Correction CZL";
        GenJournalLine."Gen. Posting Type" := GenJournalLine."Gen. Posting Type"::Purchase;
        GenJournalLine."Tax Area Code" := InvoicePostBuffer."Tax Area Code";
        GenJournalLine."Tax Liable" := InvoicePostBuffer."Tax Liable";
        GenJournalLine."Tax Group Code" := InvoicePostBuffer."Tax Group Code";
        GenJournalLine."Use Tax" := InvoicePostBuffer."Use Tax";
        GenJournalLine."VAT Calculation Type" := InvoicePostBuffer."VAT Calculation Type";
        GenJournalLine."VAT Base Discount %" := PurchaseHeader."VAT Base Discount %";
        GenJournalLine."VAT Posting" := GenJournalLine."VAT Posting"::"Manual VAT Entry";
        GenJournalLine."Shortcut Dimension 1 Code" := InvoicePostBuffer."Global Dimension 1 Code";
        GenJournalLine."Shortcut Dimension 2 Code" := InvoicePostBuffer."Global Dimension 2 Code";
        GenJournalLine."Dimension Set ID" := InvoicePostBuffer."Dimension Set ID";
        GenJournalLine."Job No." := InvoicePostBuffer."Job No.";
        GenJournalLine."Source Code" := SourceCodeSetup."Purchase VAT Delay CZL";
        GenJournalLine."Bill-to/Pay-to No." := PurchaseHeader."Pay-to Vendor No.";
        GenJournalLine."Source Type" := GenJournalLine."Source Type"::Vendor;
        GenJournalLine."Source No." := PurchaseHeader."Pay-to Vendor No.";
        GenJournalLine."Posting No. Series" := PurchaseHeader."Posting No. Series";
        GenJournalLine."Country/Region Code" := PurchaseHeader."VAT Country/Region Code";
        GenJournalLine."VAT Registration No." := PurchaseHeader."VAT Registration No.";
        GenJournalLine."Registration No. CZL" := PurchaseHeader."Registration No. CZL";
        GenJournalLine.Quantity := InvoicePostBuffer.Quantity;
        GenJournalLine."VAT Delay CZL" := true;
    end;

#pragma warning restore AL0432
#endif
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch. Post Invoice Events", 'OnPostLinesOnAfterGenJnlLinePost', '', false, false)]
    local procedure PurchasePostVATCurrencyFactorOnPostLinesOnAfterGenJnlLinePost(TempInvoicePostingBuffer: Record "Invoice Posting Buffer"; PurchHeader: Record "Purchase Header"; GLEntryNo: Integer; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    var
        VATCurrFactor: Decimal;
    begin
        if (PurchHeader."Currency Code" <> '') and (PurchHeader."Currency Factor" <> PurchHeader."VAT Currency Factor CZL") and
           ((TempInvoicePostingBuffer."VAT Calculation Type" = TempInvoicePostingBuffer."VAT Calculation Type"::"Reverse Charge VAT") or
            (TempInvoicePostingBuffer."VAT Calculation Type" = TempInvoicePostingBuffer."VAT Calculation Type"::"Normal VAT"))
        then begin
            VATPostingSetup.Get(TempInvoicePostingBuffer."VAT Bus. Posting Group", TempInvoicePostingBuffer."VAT Prod. Posting Group");
            VATPostingSetup.TestField("Purch. VAT Curr. Exch. Acc CZL");
            SourceCodeSetup.Get();
            SourceCodeSetup.TestField("Purchase VAT Delay CZL");
            GLEntry.Get(GLEntryNo);

            VATCurrFactor := 1;
            if PurchHeader."VAT Currency Factor CZL" <> 0 then
                VATCurrFactor := PurchHeader."Currency Factor" / PurchHeader."VAT Currency Factor CZL";

            PostVATDelay(PurchHeader, TempInvoicePostingBuffer, -1, 1, true, GenJnlPostLine);
            PostVATDelay(PurchHeader, TempInvoicePostingBuffer, 1, VATCurrFactor, false, GenJnlPostLine);
            if TempInvoicePostingBuffer."VAT Calculation Type" = TempInvoicePostingBuffer."VAT Calculation Type"::"Normal VAT" then begin
                PostVATDelayDifference(PurchHeader, TempInvoicePostingBuffer, GlobalAmountType::Base, VATCurrFactor, GenJnlPostLine);
                PostVATDelayDifference(PurchHeader, TempInvoicePostingBuffer, GlobalAmountType::VAT, VATCurrFactor, GenJnlPostLine);
            end;
        end;
    end;

    local procedure PostVATDelay(PurchaseHeader: Record "Purchase Header"; TempInvoicePostingBuffer: Record "Invoice Posting Buffer"; Sign: Integer; CurrFactor: Decimal; IsCorrection: Boolean; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        GetCurrency(PurchaseHeader."Currency Code");
        if CurrFactor = 0 then
            CurrFactor := 1;

        InitGenJournalLine(PurchaseHeader, TempInvoicePostingBuffer, GenJournalLine);

        GenJournalLine.Quantity := Sign * GenJournalLine.Quantity;
        GenJournalLine.Amount :=
            Sign * Round(TempInvoicePostingBuffer.Amount * CurrFactor, Currency."Amount Rounding Precision");
        GenJournalLine."VAT Amount" :=
            Sign * Round(TempInvoicePostingBuffer."VAT Amount" * CurrFactor, Currency."Amount Rounding Precision");
        GenJournalLine."VAT Base Amount" := GenJournalLine.Amount;
        GenJournalLine."Source Currency Amount" :=
            Sign * Round(TempInvoicePostingBuffer."Amount (ACY)" * CurrFactor, Currency."Amount Rounding Precision");
        GenJournalLine."Source Curr. VAT Amount" :=
            Sign * Round(TempInvoicePostingBuffer."VAT Amount (ACY)" * CurrFactor, Currency."Amount Rounding Precision");
        GenJournalLine."Source Curr. VAT Base Amount" := GenJournalLine."Source Currency Amount";
        GenJournalLine."VAT Difference" :=
            Sign * Round(TempInvoicePostingBuffer."VAT Difference" * CurrFactor, Currency."Amount Rounding Precision");

        GenJournalLine.Correction := TempInvoicePostingBuffer."Correction CZL" xor IsCorrection;
        GenJournalLine."VAT Bus. Posting Group" := TempInvoicePostingBuffer."VAT Bus. Posting Group";
        GenJournalLine."VAT Prod. Posting Group" := TempInvoicePostingBuffer."VAT Prod. Posting Group";
        GenJournalLine."Gen. Bus. Posting Group" := TempInvoicePostingBuffer."Gen. Bus. Posting Group";
        GenJournalLine."Gen. Prod. Posting Group" := TempInvoicePostingBuffer."Gen. Prod. Posting Group";
#if not CLEAN24
#pragma warning disable AL0432
        if not PurchaseHeader.IsEU3PartyTradeFeatureEnabled() then
            PurchaseHeader."EU 3 Party Trade" := PurchaseHeader."EU 3-Party Trade CZL";
#pragma warning restore AL0432
#endif
        GenJournalLine."EU 3-Party Trade" := PurchaseHeader."EU 3 Party Trade";
        GenJournalLine."EU 3-Party Intermed. Role CZL" := PurchaseHeader."EU 3-Party Intermed. Role CZL";

        GenJnlPostLine.RunWithCheck(GenJournalLine);
    end;

    local procedure PostVATDelayDifference(PurchaseHeader: Record "Purchase Header"; TempInvoicePostingBuffer: Record "Invoice Posting Buffer"; AmountType: Option Base,VAT; CurrFactor: Decimal; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    var
        GenJournalLine: Record "Gen. Journal Line";
        Amount: Decimal;
        AccountNo: Code[20];
    begin
        GetCurrency(PurchaseHeader."Currency Code");
        if CurrFactor = 0 then
            CurrFactor := 1;

        case AmountType of
            AmountType::Base:
                Amount :=
                    TempInvoicePostingBuffer.Amount -
                    Round(TempInvoicePostingBuffer.Amount * CurrFactor, Currency."Amount Rounding Precision");
            AmountType::VAT:
                begin
                    Amount :=
                        TempInvoicePostingBuffer."VAT Amount" -
                        Round(TempInvoicePostingBuffer."VAT Amount" * CurrFactor, Currency."Amount Rounding Precision");
                    if Amount < 0 then
                        AccountNo := Currency."Realized Gains Acc."
                    else
                        AccountNo := Currency."Realized Losses Acc.";
                end;
        end;

        InitGenJournalLine(PurchaseHeader, TempInvoicePostingBuffer, GenJournalLine);
        GenJournalLine."Gen. Posting Type" := GenJournalLine."Gen. Posting Type"::" ";
        if AccountNo <> '' then
            GenJournalLine."Account No." := AccountNo;
        GenJournalLine.Amount := Amount;

        GenJnlPostLine.RunWithCheck(GenJournalLine);
    end;

    local procedure InitGenJournalLine(PurchaseHeader: Record "Purchase Header"; TempInvoicePostingBuffer: Record "Invoice Posting Buffer"; var GenJournalLine: Record "Gen. Journal Line")
    begin
        GenJournalLine.Init();
        GenJournalLine."Document Type" := GLEntry."Document Type";
        GenJournalLine."Document No." := GLEntry."Document No.";
        GenJournalLine."External Document No." := GLEntry."External Document No.";
        GenJournalLine."Account No." := VATPostingSetup."Purch. VAT Curr. Exch. Acc CZL";
        if TempInvoicePostingBuffer."VAT Calculation Type" = TempInvoicePostingBuffer."VAT Calculation Type"::"Reverse Charge VAT" then
            GenJournalLine."Bal. Account No." := VATPostingSetup."Purch. VAT Curr. Exch. Acc CZL";
        GenJournalLine."Posting Date" := PurchaseHeader."Posting Date";
        GenJournalLine."Document Date" := PurchaseHeader."Document Date";
#if not CLEAN22
#pragma warning disable AL0432
        GenJournalLine."VAT Date CZL" := PurchaseHeader."VAT Date CZL";
#pragma warning restore AL0432
#endif
        GenJournalLine."VAT Reporting Date" := PurchaseHeader."VAT Reporting Date";
        GenJournalLine."Original Doc. VAT Date CZL" := PurchaseHeader."Original Doc. VAT Date CZL";
        GenJournalLine.Description := PurchaseHeader."Posting Description";
        GenJournalLine."Reason Code" := PurchaseHeader."Reason Code";
        GenJournalLine."System-Created Entry" := TempInvoicePostingBuffer."System-Created Entry";
        GenJournalLine."Source Currency Code" := PurchaseHeader."Currency Code";
        GenJournalLine.Correction := TempInvoicePostingBuffer."Correction CZL";
        GenJournalLine."Gen. Posting Type" := GenJournalLine."Gen. Posting Type"::Purchase;
        GenJournalLine."Tax Area Code" := TempInvoicePostingBuffer."Tax Area Code";
        GenJournalLine."Tax Liable" := TempInvoicePostingBuffer."Tax Liable";
        GenJournalLine."Tax Group Code" := TempInvoicePostingBuffer."Tax Group Code";
        GenJournalLine."Use Tax" := TempInvoicePostingBuffer."Use Tax";
        GenJournalLine."VAT Calculation Type" := TempInvoicePostingBuffer."VAT Calculation Type";
        GenJournalLine."VAT Base Discount %" := PurchaseHeader."VAT Base Discount %";
        GenJournalLine."VAT Posting" := GenJournalLine."VAT Posting"::"Manual VAT Entry";
        GenJournalLine."Shortcut Dimension 1 Code" := TempInvoicePostingBuffer."Global Dimension 1 Code";
        GenJournalLine."Shortcut Dimension 2 Code" := TempInvoicePostingBuffer."Global Dimension 2 Code";
        GenJournalLine."Dimension Set ID" := TempInvoicePostingBuffer."Dimension Set ID";
        GenJournalLine."Job No." := TempInvoicePostingBuffer."Job No.";
        GenJournalLine."Source Code" := SourceCodeSetup."Purchase VAT Delay CZL";
        GenJournalLine."Bill-to/Pay-to No." := PurchaseHeader."Pay-to Vendor No.";
        GenJournalLine."Source Type" := GenJournalLine."Source Type"::Vendor;
        GenJournalLine."Source No." := PurchaseHeader."Pay-to Vendor No.";
        GenJournalLine."Posting No. Series" := PurchaseHeader."Posting No. Series";
        GenJournalLine."Country/Region Code" := PurchaseHeader."VAT Country/Region Code";
        GenJournalLine."VAT Registration No." := PurchaseHeader."VAT Registration No.";
        GenJournalLine."Registration No. CZL" := PurchaseHeader."Registration No. CZL";
        GenJournalLine.Quantity := TempInvoicePostingBuffer.Quantity;
        GenJournalLine."VAT Delay CZL" := true;
    end;

    local procedure GetCurrency(CurrencyCode: Code[10])
    begin
        if CurrencyCode = '' then
            Currency.InitRoundingPrecision()
        else begin
            Currency.Get(CurrencyCode);
            Currency.TestField("Amount Rounding Precision");
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnAfterCheckPurchDoc', '', false, false)]
    local procedure CheckVatDateOnAfterCheckPurchDoc(var PurchHeader: Record "Purchase Header")
    var
        VATDateHandlerCZL: Codeunit "VAT Date Handler CZL";
    begin
#if not CLEAN22
#pragma warning disable AL0432
        PurchHeader.CheckIntrastatMandatoryFieldsCZL();
#pragma warning restore AL0432
#endif
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

#if not CLEAN23
#pragma warning disable AL0432
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnBeforePostVendorEntry', '', false, false)]
    local procedure UpdateSymbolsAndBankAccountOnBeforePostVendorEntry(var GenJnlLine: Record "Gen. Journal Line"; var PurchHeader: Record "Purchase Header")
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

#pragma warning restore AL0432
#endif
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
#if not CLEAN22
#pragma warning disable AL0432

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnAfterTestPurchLine', '', false, false)]
    local procedure CheckIntrastatOnAfterTestPurchLine(PurchHeader: Record "Purchase Header"; PurchLine: Record "Purchase Line")
    begin
        PurchLine.CheckIntrastatMandatoryFieldsCZL(PurchHeader);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnAfterInitAssocItemJnlLine', '', false, false)]
    local procedure CopyFieldsOnAfterInitAssocItemJnlLine(var ItemJournalLine: Record "Item Journal Line"; SalesHeader: Record "Sales Header"; SalesLine: Record "Sales Line")
    begin
        ItemJournalLine."Intrastat Transaction CZL" := SalesHeader.IsIntrastatTransactionCZL();
        // recalc to base UOM
        if ItemJournalLine."Net Weight CZL" <> 0 then
            if SalesLine."Qty. per Unit of Measure" <> 0 then
                ItemJournalLine."Net Weight CZL" := Round(ItemJournalLine."Net Weight CZL" / SalesLine."Qty. per Unit of Measure", 0.00001);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnPostItemJnlLineOnAfterCopyItemCharge', '', false, false)]
    local procedure CopyFieldsOnPostItemJnlLineOnAfterCopyItemCharge(var ItemJournalLine: Record "Item Journal Line"; var TempItemChargeAssgntPurch: Record "Item Charge Assignment (Purch)")
    begin
        ItemJournalLine."Incl. in Intrastat Amount CZL" := TempItemChargeAssgntPurch."Incl. in Intrastat Amount CZL";
        ItemJournalLine."Incl. in Intrastat S.Value CZL" := TempItemChargeAssgntPurch."Incl. in Intrastat S.Value CZL";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnPostItemChargePerOrderOnAfterCopyToItemJnlLine', '', false, false)]
    local procedure CopyFieldsOnPostItemChargePerOrderOnAfterCopyToItemJnlLine(var ItemJournalLine: Record "Item Journal Line"; var TempItemChargeAssignmentPurch: Record "Item Charge Assignment (Purch)")
    begin
        ItemJournalLine."Incl. in Intrastat Amount CZL" := TempItemChargeAssignmentPurch."Incl. in Intrastat Amount CZL";
        ItemJournalLine."Incl. in Intrastat S.Value CZL" := TempItemChargeAssignmentPurch."Incl. in Intrastat S.Value CZL";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnAfterValidatePostingAndDocumentDate', '', false, false)]
    local procedure ValidateVATDateOnAfterValidatePostingAndDocumentDate(var PurchaseHeader: Record "Purchase Header"; CommitIsSuppressed: Boolean; PreviewMode: Boolean)
    var
        BatchProcessingMgt: Codeunit "Batch Processing Mgt.";
        VATReportingDateMgt: Codeunit "VAT Reporting Date Mgt";
        VATDate: Date;
        VATDateExists: Boolean;
        ReplaceVATDate: Boolean;
        PostingDate: Date;
    begin
        if PurchaseHeader.IsReplaceVATDateEnabled() then
            exit;
        if VATReportingDateMgt.IsVATDateEnabled() then begin
            VATDateExists :=
                BatchProcessingMgt.GetBooleanParameter(PurchaseHeader.RecordId, Enum::"Batch Posting Parameter Type"::"Replace VAT Date", ReplaceVATDate) and
                BatchProcessingMgt.GetDateParameter(PurchaseHeader.RecordId, Enum::"Batch Posting Parameter Type"::"VAT Date", VATDate);
            if not VATDateExists then
                VATDateExists :=
                    BatchProcessingMgt.GetBooleanParameter(PurchaseHeader.RecordId, Enum::"Batch Posting Parameter Type"::"Replace VAT Date CZL", ReplaceVATDate) and
                    BatchProcessingMgt.GetDateParameter(PurchaseHeader.RecordId, Enum::"Batch Posting Parameter Type"::"VAT Date CZL", VATDate);
            if VATDateExists and (ReplaceVATDate or (PurchaseHeader."VAT Date CZL" = 0D)) then begin
                PurchaseHeader.Validate("VAT Date CZL", VATDate);
                PurchaseHeader.Modify();
            end;
        end else
            if BatchProcessingMgt.GetDateParameter(PurchaseHeader.RecordId, Enum::"Batch Posting Parameter Type"::"Posting Date", PostingDate) and
               (PurchaseHeader."Posting Date" <> PurchaseHeader."VAT Date CZL")
            then begin
                PurchaseHeader.Validate("VAT Date CZL", PurchaseHeader."Posting Date");
                PurchaseHeader.Modify();
            end;
    end;

    [EventSubscriber(ObjectType::Report, Report::"Purchase Document - Test", 'OnAfterCheckPurchaseDoc', '', false, false)]
    local procedure CheckIntrastatMandatoryFieldsOnAfterCheckPurchaseDoc(PurchaseHeader: Record "Purchase Header"; var ErrorCounter: Integer; var ErrorText: array[99] of Text[250])
    var
        StatutoryReportingSetupCZL: Record "Statutory Reporting Setup CZL";
        FeatureMgtFacade: Codeunit "Feature Management Facade";
        MustBeSpecifiedLbl: Label '%1 must be specified.', Comment = '%1 = FieldCaption';
        IntrastatFeatureKeyIdTok: Label 'ReplaceIntrastat', Locked = true;
    begin
        if FeatureMgtFacade.IsEnabled(IntrastatFeatureKeyIdTok) then
            exit;
        if not (PurchaseHeader.Ship or PurchaseHeader.Receive) then
            exit;
        if PurchaseHeader.IsIntrastatTransactionCZL() and PurchaseHeader.ShipOrReceiveInventoriableTypeItemsCZL() then begin
            StatutoryReportingSetupCZL.Get();
            if StatutoryReportingSetupCZL."Transaction Type Mandatory" then
                if PurchaseHeader."Transaction Type" = '' then
                    AddError(StrSubstNo(MustBeSpecifiedLbl, PurchaseHeader.FieldCaption("Transaction Type")), ErrorCounter, ErrorText);
            if StatutoryReportingSetupCZL."Transaction Spec. Mandatory" then
                if PurchaseHeader."Transaction Specification" = '' then
                    AddError(StrSubstNo(MustBeSpecifiedLbl, PurchaseHeader.FieldCaption("Transaction Specification")), ErrorCounter, ErrorText);
            if StatutoryReportingSetupCZL."Transport Method Mandatory" then
                if PurchaseHeader."Transport Method" = '' then
                    AddError(StrSubstNo(MustBeSpecifiedLbl, PurchaseHeader.FieldCaption("Transport Method")), ErrorCounter, ErrorText);
            if StatutoryReportingSetupCZL."Shipment Method Mandatory" then
                if PurchaseHeader."Shipment Method Code" = '' then
                    AddError(StrSubstNo(MustBeSpecifiedLbl, PurchaseHeader.FieldCaption("Shipment Method Code")), ErrorCounter, ErrorText);
        end;
    end;
#pragma warning restore AL0432 
#endif

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

#if not CLEAN23
#pragma warning disable AL0432
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnAfterFillInvoicePostBuffer', '', false, false)]
    local procedure SetExtendedAmountsOnAfterFillInvoicePostBuffer(var InvoicePostBuffer: Record "Invoice Post. Buffer"; PurchLine: Record "Purchase Line")
    begin
        InvoicePostBuffer."Ext. Amount CZL" := PurchLine."Ext. Amount CZL";
        InvoicePostBuffer."Ext. Amount Incl. VAT CZL" := PurchLine."Ext. Amount Incl. VAT CZL";
    end;

#pragma warning restore AL0432
#endif
#if not CLEAN24
#pragma warning disable AL0432
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch. Post Invoice Events", 'OnPrepareLineOnAfterFillInvoicePostingBuffer', '', false, false)]
    local procedure SetExtendedAmountsOnPrepareLineOnAfterFillInvoicePostingBuffer(var InvoicePostingBuffer: Record "Invoice Posting Buffer"; PurchLine: Record "Purchase Line")
    begin
        InvoicePostingBuffer."Ext. Amount CZL" := PurchLine."Ext. Amount CZL";
        InvoicePostingBuffer."Ext. Amount Incl. VAT CZL" := PurchLine."Ext. Amount Incl. VAT CZL";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnRoundAmountOnBeforeIncrAmount', '', false, false)]
    local procedure RoundExtendedAmountsOnRoundAmountOnBeforeIncrAmount(PurchaseHeader: Record "Purchase Header"; var PurchaseLine: Record "Purchase Line"; var TotalPurchLine: Record "Purchase Line"; var TotalPurchLineLCY: Record "Purchase Line"; var CurrExchRate: Record "Currency Exchange Rate"; var NoVAT: Boolean)
    begin
        if PurchaseHeader."Currency Code" = '' then
            exit;

        PurchaseLine."Ext. Amount Incl. VAT CZL" :=
            Round(
                CurrExchRate.ExchangeAmtFCYToLCY(
                    PurchaseHeader.GetUseDate(), PurchaseHeader."Currency Code",
                    TotalPurchLine."Amount Including VAT", PurchaseHeader."VAT Currency Factor CZL")) -
            TotalPurchLineLCY."Ext. Amount Incl. VAT CZL";

        if NoVAT then
            PurchaseLine."Ext. Amount CZL" := PurchaseLine."Ext. Amount Incl. VAT CZL"
        else
            PurchaseLine."Ext. Amount CZL" :=
                Round(
                    CurrExchRate.ExchangeAmtFCYToLCY(
                        PurchaseHeader.GetUseDate(), PurchaseHeader."Currency Code",
                        TotalPurchLine.Amount, PurchaseHeader."VAT Currency Factor CZL")) -
                TotalPurchLineLCY."Ext. Amount CZL";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnAfterIncrAmount', '', false, false)]
    local procedure IncrementExtendedAmountsOnAfterIncrAmount(var TotalPurchLine: Record "Purchase Line"; PurchLine: Record "Purchase Line")
    begin
        Increment(TotalPurchLine."Ext. Amount Incl. VAT CZL", PurchLine."Ext. Amount Incl. VAT CZL");
        Increment(TotalPurchLine."Ext. Amount CZL", PurchLine."Ext. Amount CZL");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnAfterReverseAmount', '', false, false)]
    local procedure ReverseExtendedAmountsOnAfterReverseAmount(var PurchLine: Record "Purchase Line")
    begin
        PurchLine."Ext. Amount CZL" := -PurchLine."Ext. Amount CZL";
        PurchLine."Ext. Amount Incl. VAT CZL" := -PurchLine."Ext. Amount Incl. VAT CZL";
    end;

#pragma warning restore AL0432
#endif
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
    end;

    local procedure Increment(var Number: Decimal; Number2: Decimal)
    begin
        Number := Number + Number2;
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
