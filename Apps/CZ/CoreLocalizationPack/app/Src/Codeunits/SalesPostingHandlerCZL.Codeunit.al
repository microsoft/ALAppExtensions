﻿// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Posting;

using Microsoft.Bank;
using Microsoft.Finance.Currency;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.Finance.ReceivablesPayables;
using Microsoft.Finance.VAT.Calculation;
using Microsoft.Finance.VAT.Reporting;
using Microsoft.Finance.VAT.Setup;
using Microsoft.Foundation.AuditCodes;
#if not CLEAN22
using Microsoft.Foundation.BatchProcessing;
using Microsoft.Foundation.Company;
#endif
using Microsoft.Inventory.Counting.Journal;
using Microsoft.Inventory.Intrastat;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Journal;
#if not CLEAN22
using Microsoft.Purchases.Document;
#endif
using Microsoft.Sales.Document;
using Microsoft.Sales.History;
#if not CLEAN22
using Microsoft.Sales.Reports;
using System.Environment.Configuration;
#endif
using System.Utilities;

codeunit 31038 "Sales Posting Handler CZL"
{
    var
        Currency: Record Currency;
        GLEntry: Record "G/L Entry";
        SourceCodeSetup: Record "Source Code Setup";
        VATPostingSetup: Record "VAT Posting Setup";
        BankOperationsFunctionsCZL: Codeunit "Bank Operations Functions CZL";
        ReverseChargeCheckCZL: Enum "Reverse Charge Check CZL";
        GlobalAmountType: Option Base,VAT;

#if not CLEAN23
#pragma warning disable AL0432
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterPostInvPostBuffer', '', false, false)]
    local procedure SalesPostVATDelayOnAfterPostInvPostBuffer(var GenJnlLine: Record "Gen. Journal Line"; var InvoicePostBuffer: Record "Invoice Post. Buffer"; var SalesHeader: Record "Sales Header"; GLEntryNo: Integer; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    var
        VATCurrFactor: Decimal;
    begin
        if (SalesHeader."Currency Code" <> '') and (SalesHeader."Currency Factor" <> SalesHeader."VAT Currency Factor CZL") and
           ((InvoicePostBuffer."VAT Calculation Type" = InvoicePostBuffer."VAT Calculation Type"::"Reverse Charge VAT") or
            (InvoicePostBuffer."VAT Calculation Type" = InvoicePostBuffer."VAT Calculation Type"::"Normal VAT"))
        then begin
            VATPostingSetup.Get(GenJnlLine."VAT Bus. Posting Group", GenJnlLine."VAT Prod. Posting Group");
            VATPostingSetup.TestField("Sales VAT Curr. Exch. Acc CZL");
            SourceCodeSetup.Get();
            SourceCodeSetup.TestField("Sales VAT Delay CZL");
            GLEntry.Get(GLEntryNo);

            VATCurrFactor := 1;
            if SalesHeader."VAT Currency Factor CZL" <> 0 then
                VATCurrFactor := SalesHeader."Currency Factor" / SalesHeader."VAT Currency Factor CZL";

            PostVATDelay(SalesHeader, InvoicePostBuffer, -1, 1, true, GenJnlPostLine);
            PostVATDelay(SalesHeader, InvoicePostBuffer, 1, VATCurrFactor, false, GenJnlPostLine);
            if InvoicePostBuffer."VAT Calculation Type" = InvoicePostBuffer."VAT Calculation Type"::"Normal VAT" then begin
                PostVATDelayDifference(SalesHeader, InvoicePostBuffer, GlobalAmountType::Base, VATCurrFactor, GenJnlPostLine);
                PostVATDelayDifference(SalesHeader, InvoicePostBuffer, GlobalAmountType::VAT, VATCurrFactor, GenJnlPostLine);
            end;
        end;
    end;

    local procedure PostVATDelay(SalesHeader: Record "Sales Header"; InvoicePostBuffer: Record "Invoice Post. Buffer"; Sign: Integer; CurrFactor: Decimal; IsCorrection: Boolean; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        GetCurrency(SalesHeader."Currency Code");
        if CurrFactor = 0 then
            CurrFactor := 1;

        InitGenJournalLine(SalesHeader, InvoicePostBuffer, GenJournalLine);

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

        GenJnlPostLine.RunWithCheck(GenJournalLine);
    end;

    local procedure PostVATDelayDifference(SalesHeader: Record "Sales Header"; InvoicePostBuffer: Record "Invoice Post. Buffer"; AmountType: Option Base,VAT; CurrFactor: Decimal; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    var
        GenJournalLine: Record "Gen. Journal Line";
        Amount: Decimal;
        AccountNo: Code[20];
    begin
        GetCurrency(SalesHeader."Currency Code");
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

        InitGenJournalLine(SalesHeader, InvoicePostBuffer, GenJournalLine);
        GenJournalLine."Gen. Posting Type" := GenJournalLine."Gen. Posting Type"::" ";
        if AccountNo <> '' then
            GenJournalLine."Account No." := AccountNo;
        GenJournalLine.Amount := Amount;

        GenJnlPostLine.RunWithCheck(GenJournalLine);
    end;

    local procedure InitGenJournalLine(SalesHeader: Record "Sales Header"; InvoicePostBuffer: Record "Invoice Post. Buffer"; var GenJournalLine: Record "Gen. Journal Line")
    begin
        GenJournalLine.Init();
        GenJournalLine."Document Type" := GLEntry."Document Type";
        GenJournalLine."Document No." := GLEntry."Document No.";
        GenJournalLine."External Document No." := GLEntry."External Document No.";
        GenJournalLine."Account No." := VATPostingSetup."Sales VAT Curr. Exch. Acc CZL";
        if InvoicePostBuffer."VAT Calculation Type" = InvoicePostBuffer."VAT Calculation Type"::"Reverse Charge VAT" then
            GenJournalLine."Bal. Account No." := VATPostingSetup."Sales VAT Curr. Exch. Acc CZL";
        GenJournalLine."Posting Date" := SalesHeader."Posting Date";
        GenJournalLine."Document Date" := SalesHeader."Document Date";
#if not CLEAN22
        GenJournalLine."VAT Date CZL" := SalesHeader."VAT Date CZL";
#endif
        GenJournalLine."VAT Reporting Date" := SalesHeader."VAT Reporting Date";
        GenJournalLine."Original Doc. VAT Date CZL" := SalesHeader."Original Doc. VAT Date CZL";
        GenJournalLine.Description := SalesHeader."Posting Description";
        GenJournalLine."Reason Code" := SalesHeader."Reason Code";
        GenJournalLine."System-Created Entry" := InvoicePostBuffer."System-Created Entry";
        GenJournalLine."Source Currency Code" := SalesHeader."Currency Code";
        GenJournalLine.Correction := InvoicePostBuffer."Correction CZL";
        GenJournalLine."Gen. Posting Type" := GenJournalLine."Gen. Posting Type"::Sale;
        GenJournalLine."Tax Area Code" := InvoicePostBuffer."Tax Area Code";
        GenJournalLine."Tax Liable" := InvoicePostBuffer."Tax Liable";
        GenJournalLine."Tax Group Code" := InvoicePostBuffer."Tax Group Code";
        GenJournalLine."Use Tax" := InvoicePostBuffer."Use Tax";
        GenJournalLine."VAT Calculation Type" := InvoicePostBuffer."VAT Calculation Type";
        GenJournalLine."VAT Base Discount %" := SalesHeader."VAT Base Discount %";
        GenJournalLine."VAT Posting" := GenJournalLine."VAT Posting"::"Manual VAT Entry";
        GenJournalLine."Shortcut Dimension 1 Code" := InvoicePostBuffer."Global Dimension 1 Code";
        GenJournalLine."Shortcut Dimension 2 Code" := InvoicePostBuffer."Global Dimension 2 Code";
        GenJournalLine."Dimension Set ID" := InvoicePostBuffer."Dimension Set ID";
        GenJournalLine."Job No." := InvoicePostBuffer."Job No.";
        GenJournalLine."Source Code" := SourceCodeSetup."Sales VAT Delay CZL";
        GenJournalLine."Bill-to/Pay-to No." := SalesHeader."Bill-to Customer No.";
        GenJournalLine."Source Type" := GenJournalLine."Source Type"::Customer;
        GenJournalLine."Source No." := SalesHeader."Bill-to Customer No.";
        GenJournalLine."Posting No. Series" := SalesHeader."Posting No. Series";
        GenJournalLine."Country/Region Code" := SalesHeader."VAT Country/Region Code";
        GenJournalLine."VAT Registration No." := SalesHeader."VAT Registration No.";
        GenJournalLine."Registration No. CZL" := SalesHeader."Registration No. CZL";
        GenJournalLine.Quantity := InvoicePostBuffer.Quantity;
        GenJournalLine."VAT Delay CZL" := true;
    end;

#pragma warning restore AL0432
#endif
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales Post Invoice Events", 'OnPostLinesOnAfterGenJnlLinePost', '', false, false)]
    local procedure SalesPostVATDelayOnPostLinesOnAfterGenJnlLinePost(var GenJnlLine: Record "Gen. Journal Line"; TempInvoicePostingBuffer: Record "Invoice Posting Buffer"; SalesHeader: Record "Sales Header"; GLEntryNo: Integer; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    var
        VATCurrFactor: Decimal;
    begin
        if (SalesHeader."Currency Code" <> '') and (SalesHeader."Currency Factor" <> SalesHeader."VAT Currency Factor CZL") and
           ((TempInvoicePostingBuffer."VAT Calculation Type" = TempInvoicePostingBuffer."VAT Calculation Type"::"Reverse Charge VAT") or
            (TempInvoicePostingBuffer."VAT Calculation Type" = TempInvoicePostingBuffer."VAT Calculation Type"::"Normal VAT"))
        then begin
            VATPostingSetup.Get(GenJnlLine."VAT Bus. Posting Group", GenJnlLine."VAT Prod. Posting Group");
            VATPostingSetup.TestField("Sales VAT Curr. Exch. Acc CZL");
            SourceCodeSetup.Get();
            SourceCodeSetup.TestField("Sales VAT Delay CZL");
            GLEntry.Get(GLEntryNo);

            VATCurrFactor := 1;
            if SalesHeader."VAT Currency Factor CZL" <> 0 then
                VATCurrFactor := SalesHeader."Currency Factor" / SalesHeader."VAT Currency Factor CZL";

            PostVATDelay(SalesHeader, TempInvoicePostingBuffer, -1, 1, true, GenJnlPostLine);
            PostVATDelay(SalesHeader, TempInvoicePostingBuffer, 1, VATCurrFactor, false, GenJnlPostLine);
            if TempInvoicePostingBuffer."VAT Calculation Type" = TempInvoicePostingBuffer."VAT Calculation Type"::"Normal VAT" then begin
                PostVATDelayDifference(SalesHeader, TempInvoicePostingBuffer, GlobalAmountType::Base, VATCurrFactor, GenJnlPostLine);
                PostVATDelayDifference(SalesHeader, TempInvoicePostingBuffer, GlobalAmountType::VAT, VATCurrFactor, GenJnlPostLine);
            end;
        end;
    end;

    local procedure PostVATDelay(SalesHeader: Record "Sales Header"; TempInvoicePostingBuffer: Record "Invoice Posting Buffer"; Sign: Integer; CurrFactor: Decimal; IsCorrection: Boolean; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        GetCurrency(SalesHeader."Currency Code");
        if CurrFactor = 0 then
            CurrFactor := 1;

        InitGenJournalLine(SalesHeader, TempInvoicePostingBuffer, GenJournalLine);

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

        GenJnlPostLine.RunWithCheck(GenJournalLine);
    end;

    local procedure PostVATDelayDifference(SalesHeader: Record "Sales Header"; TempInvoicePostingBuffer: Record "Invoice Posting Buffer"; AmountType: Option Base,VAT; CurrFactor: Decimal; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    var
        GenJournalLine: Record "Gen. Journal Line";
        Amount: Decimal;
        AccountNo: Code[20];
    begin
        GetCurrency(SalesHeader."Currency Code");
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

        InitGenJournalLine(SalesHeader, TempInvoicePostingBuffer, GenJournalLine);
        GenJournalLine."Gen. Posting Type" := GenJournalLine."Gen. Posting Type"::" ";
        if AccountNo <> '' then
            GenJournalLine."Account No." := AccountNo;
        GenJournalLine.Amount := Amount;

        GenJnlPostLine.RunWithCheck(GenJournalLine);
    end;

    local procedure InitGenJournalLine(SalesHeader: Record "Sales Header"; TempInvoicePostingBuffer: Record "Invoice Posting Buffer"; var GenJournalLine: Record "Gen. Journal Line")
    begin
        GenJournalLine.Init();
        GenJournalLine."Document Type" := GLEntry."Document Type";
        GenJournalLine."Document No." := GLEntry."Document No.";
        GenJournalLine."External Document No." := GLEntry."External Document No.";
        GenJournalLine."Account No." := VATPostingSetup."Sales VAT Curr. Exch. Acc CZL";
        if TempInvoicePostingBuffer."VAT Calculation Type" = TempInvoicePostingBuffer."VAT Calculation Type"::"Reverse Charge VAT" then
            GenJournalLine."Bal. Account No." := VATPostingSetup."Sales VAT Curr. Exch. Acc CZL";
        GenJournalLine."Posting Date" := SalesHeader."Posting Date";
        GenJournalLine."Document Date" := SalesHeader."Document Date";
#if not CLEAN22
#pragma warning disable AL0432
        GenJournalLine."VAT Date CZL" := SalesHeader."VAT Date CZL";
#pragma warning restore AL0432
#endif
        GenJournalLine."VAT Reporting Date" := SalesHeader."VAT Reporting Date";
        GenJournalLine."Original Doc. VAT Date CZL" := SalesHeader."Original Doc. VAT Date CZL";
        GenJournalLine.Description := SalesHeader."Posting Description";
        GenJournalLine."Reason Code" := SalesHeader."Reason Code";
        GenJournalLine."System-Created Entry" := TempInvoicePostingBuffer."System-Created Entry";
        GenJournalLine."Source Currency Code" := SalesHeader."Currency Code";
        GenJournalLine.Correction := TempInvoicePostingBuffer."Correction CZL";
        GenJournalLine."Gen. Posting Type" := GenJournalLine."Gen. Posting Type"::Sale;
        GenJournalLine."Tax Area Code" := TempInvoicePostingBuffer."Tax Area Code";
        GenJournalLine."Tax Liable" := TempInvoicePostingBuffer."Tax Liable";
        GenJournalLine."Tax Group Code" := TempInvoicePostingBuffer."Tax Group Code";
        GenJournalLine."Use Tax" := TempInvoicePostingBuffer."Use Tax";
        GenJournalLine."VAT Calculation Type" := TempInvoicePostingBuffer."VAT Calculation Type";
        GenJournalLine."VAT Base Discount %" := SalesHeader."VAT Base Discount %";
        GenJournalLine."VAT Posting" := GenJournalLine."VAT Posting"::"Manual VAT Entry";
        GenJournalLine."Shortcut Dimension 1 Code" := TempInvoicePostingBuffer."Global Dimension 1 Code";
        GenJournalLine."Shortcut Dimension 2 Code" := TempInvoicePostingBuffer."Global Dimension 2 Code";
        GenJournalLine."Dimension Set ID" := TempInvoicePostingBuffer."Dimension Set ID";
        GenJournalLine."Job No." := TempInvoicePostingBuffer."Job No.";
        GenJournalLine."Source Code" := SourceCodeSetup."Sales VAT Delay CZL";
        GenJournalLine."Bill-to/Pay-to No." := SalesHeader."Bill-to Customer No.";
        GenJournalLine."Source Type" := GenJournalLine."Source Type"::Customer;
        GenJournalLine."Source No." := SalesHeader."Bill-to Customer No.";
        GenJournalLine."Posting No. Series" := SalesHeader."Posting No. Series";
        GenJournalLine."Country/Region Code" := SalesHeader."VAT Country/Region Code";
        GenJournalLine."VAT Registration No." := SalesHeader."VAT Registration No.";
        GenJournalLine."Registration No. CZL" := SalesHeader."Registration No. CZL";
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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterCheckSalesDoc', '', false, false)]
    local procedure CheckVatDateOnAfterCheckSalesDoc(var SalesHeader: Record "Sales Header")
    var
        VATDateHandlerCZL: Codeunit "VAT Date Handler CZL";
    begin
#if not CLEAN22
#pragma warning disable AL0432
        SalesHeader.CheckIntrastatMandatoryFieldsCZL();
#pragma warning restore AL0432
#endif
        VATDateHandlerCZL.CheckVATDateCZL(SalesHeader);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnCheckAndUpdateOnAfterSetPostingFlags', '', false, false)]
    local procedure CheckTariffNoOnCheckAndUpdateOnAfterSetPostingFlags(var SalesHeader: Record "Sales Header");
    begin
        CheckTariffNo(SalesHeader);
    end;

    local procedure CheckTariffNo(SalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
        TariffNumber: Record "Tariff Number";
        CommodityCZL: Record "Commodity CZL";
        CommoditySetupCZL: Record "Commodity Setup CZL";
        ItemUnitofMeasure: Record "Item Unit of Measure";
        TempInventoryBuffer: Record "Inventory Buffer" temporary;
        Temp1InventoryBuffer: Record "Inventory Buffer" temporary;
        Temp2InventoryBuffer: Record "Inventory Buffer" temporary;
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        ConfirmManagement: Codeunit "Confirm Management";
        AmountToCheckLimit: Decimal;
        LineAmount: Decimal;
        QtyToInvoice: Decimal;
        ItemNoText: Text;
        IsHandled: Boolean;
        ItemUnitOfMeasureForVATNotExistErr: Label 'Unit of Measure %1 not exist for Item No. %2.', Comment = '%1 = Unit of Measure Code, %2 = Item No.';
        CommoditySetupForVATNotExistErr: Label 'Commodity Setup %1 for date %2 not exist.', Comment = '%1 = Commodity Code, %2 = Date';
        VATPostingSetupPostMismashErr: Label 'For commodity %1 and limit %2 not allowed VAT type %3 posting.\\Item List:\%4.', Comment = '%1 = Commodity Code, %2 = Commodity Limit Amount LCY, %3 = VAT Calculation Type, %4 = Item No.';
        VATPostingSetupPostMismashQst: Label 'The amount of the invoice is below the limit for Reverse VAT (%5).\\Item List:\%4\\Really post VAT type %3 for Deliverable Code %1 and limit %2?', Comment = '%1 = Commodity Code, %2 = Commodity Limit Amount LCY, %3 = VAT Calculation Type, %4 = List of Item No., %5 = AmountToCheckLimit';
    begin
        OnBeforeCheckTariffNo(SalesHeader, IsHandled);
        if IsHandled then
            exit;
#if not CLEAN22
#pragma warning disable AL0432
        if not SalesHeader.IsReplaceVATDateEnabled() then
            SalesHeader."VAT Reporting Date" := SalesHeader."VAT Date CZL";
#pragma warning restore AL0432
#endif

        CommoditySetupCZL.SetFilter("Valid From", '..%1', SalesHeader."VAT Reporting Date");
        CommoditySetupCZL.SetFilter("Valid To", '%1|%2..', 0D, SalesHeader."VAT Reporting Date");

        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        if SalesLine.FindSet(false) then
            repeat
                QtyToInvoice := GetQtyToInvoice(SalesLine, SalesHeader.Ship);

                if VATPostingSetup.Get(SalesLine."VAT Bus. Posting Group", SalesLine."VAT Prod. Posting Group") and
                   (QtyToInvoice <> 0)
                then
                    if VATPostingSetup."Reverse Charge Check CZL" = ReverseChargeCheckCZL::"Limit Check" then begin
                        SalesLine.TestField("Tariff No. CZL");
                        TariffNumber.Get(SalesLine."Tariff No. CZL");

                        if not TariffNumber."Allow Empty UoM Code CZL" then
                            if SalesLine.Type = SalesLine.Type::Item then begin
                                ItemUnitofMeasure.SetRange("Item No.", SalesLine."No.");
                                ItemUnitofMeasure.SetRange(Code, TariffNumber."VAT Stat. UoM Code CZL");
                                if ItemUnitofMeasure.IsEmpty() then
                                    Error(ItemUnitOfMeasureForVATNotExistErr, TariffNumber."VAT Stat. UoM Code CZL", SalesLine."No.");
                            end else
                                if TariffNumber."VAT Stat. UoM Code CZL" <> '' then
                                    SalesLine.TestField("Unit of Measure Code", TariffNumber."VAT Stat. UoM Code CZL");

                        if (TariffNumber."Statement Code CZL" <> '') and SalesHeader.Invoice then begin
                            TariffNumber.TestField("Statement Limit Code CZL");
                            CommodityCZL.Get(TariffNumber."Statement Limit Code CZL");
                        end else
                            Clear(CommodityCZL);

                        if CommodityCZL.Code <> '' then begin
                            CommoditySetupCZL.SetRange("Commodity Code", CommodityCZL.Code);
                            if not CommoditySetupCZL.FindLast() then
                                Error(CommoditySetupForVATNotExistErr, CommodityCZL.Code, SalesHeader."VAT Reporting Date");

                            if not TempInventoryBuffer.Get(CommodityCZL.Code, Format(SalesLine."VAT Calculation Type", 0, '<Number>')) then begin
                                TempInventoryBuffer.Init();
                                TempInventoryBuffer."Item No." := CommodityCZL.Code;
                                TempInventoryBuffer."Variant Code" := Format(SalesLine."VAT Calculation Type", 0, '<Number>');
                                TempInventoryBuffer.Insert();
                                Temp1InventoryBuffer.Init();
                                Temp1InventoryBuffer."Item No." := CommodityCZL.Code;
                                Temp1InventoryBuffer."Variant Code" := Format(SalesLine."VAT Calculation Type", 0, '<Number>');
                                Temp1InventoryBuffer.Insert();
                            end;

                            LineAmount := SalesLine."Unit Price" * QtyToInvoice;
                            if SalesHeader."Currency Code" <> '' then
                                LineAmount :=
                                  CurrencyExchangeRate.ExchangeAmtFCYToLCY(
                                    SalesHeader."Posting Date", SalesHeader."Currency Code",
                                    LineAmount, SalesHeader."Currency Factor");

                            TempInventoryBuffer.Quantity += LineAmount;
                            TempInventoryBuffer.Modify();
                            Temp1InventoryBuffer.Get(CommodityCZL.Code, Format(SalesLine."VAT Calculation Type", 0, '<Number>'));
                            Temp1InventoryBuffer.Quantity += LineAmount;
                            Temp1InventoryBuffer.Modify();

                            if not Temp2InventoryBuffer.Get(CommodityCZL.Code, Format(SalesLine."VAT Calculation Type", 0, '<Number>'), 0, '', '', SalesLine."No.") then begin
                                Temp2InventoryBuffer.Init();
                                Temp2InventoryBuffer."Item No." := CommodityCZL.Code;
                                Temp2InventoryBuffer."Variant Code" := Format(SalesLine."VAT Calculation Type", 0, '<Number>');
                                Temp2InventoryBuffer."Lot No." := SalesLine."No.";
                                Temp2InventoryBuffer.Insert();
                            end;
                        end;
                    end;
            until SalesLine.Next() = 0;

        if not SalesHeader.Invoice then
            exit;

        if TempInventoryBuffer.FindSet() then
            repeat
                CommoditySetupCZL.SetRange("Commodity Code", TempInventoryBuffer."Item No.");
                CommoditySetupCZL.FindLast();

                TempInventoryBuffer.SetRange("Item No.", TempInventoryBuffer."Item No.");
                Clear(AmountToCheckLimit);
                Clear(ItemNoText);
                if TempInventoryBuffer.Count > 1 then
                    repeat
                        AmountToCheckLimit += TempInventoryBuffer.Quantity;
                        ItemNoText := GetListItemNo(Temp2InventoryBuffer, TempInventoryBuffer);
                    until TempInventoryBuffer.Next() = 0
                else begin
                    AmountToCheckLimit := TempInventoryBuffer.Quantity;
                    ItemNoText := GetListItemNo(Temp2InventoryBuffer, TempInventoryBuffer);
                end;

                TempInventoryBuffer.SetRange("Item No.");

                if AmountToCheckLimit < CommoditySetupCZL."Commodity Limit Amount LCY" then begin
                    // Normal
                    if Temp1InventoryBuffer.Get(TempInventoryBuffer."Item No.", Format(SalesLine."VAT Calculation Type"::"Reverse Charge VAT", 0, '<Number>')) then
                        if not ConfirmManagement.GetResponseOrDefault(StrSubStno(VATPostingSetupPostMismashQst,
                            CommoditySetupCZL."Commodity Code", CommoditySetupCZL."Commodity Limit Amount LCY",
                            SalesLine."VAT Calculation Type"::"Reverse Charge VAT", ItemNoText, AmountToCheckLimit), false)
                        then
                            Error('');
                end else
                    // Reverse
                    if Temp1InventoryBuffer.Get(TempInventoryBuffer."Item No.", Format(SalesLine."VAT Calculation Type"::"Normal VAT", 0, '<Number>')) then
                        Error(VATPostingSetupPostMismashErr, CommoditySetupCZL."Commodity Code", CommoditySetupCZL."Commodity Limit Amount LCY",
                          SalesLine."VAT Calculation Type"::"Normal VAT", ItemNoText);

            until TempInventoryBuffer.Next() = 0;
    end;

    local procedure GetQtyToInvoice(SalesLine: Record "Sales Line"; Ship: Boolean): Decimal
    var
        AllowedQtyToInvoice: Decimal;
    begin
        AllowedQtyToInvoice := SalesLine."Qty. Shipped Not Invoiced";
        if Ship then
            AllowedQtyToInvoice := AllowedQtyToInvoice + SalesLine."Qty. to Ship";
        if SalesLine."Qty. to Invoice" > AllowedQtyToInvoice then
            exit(AllowedQtyToInvoice);
        exit(SalesLine."Qty. to Invoice");
    end;

    local procedure GetListItemNo(var Temp2InventoryBuffer: Record "Inventory Buffer" temporary; TempInventoryBuffer: Record "Inventory Buffer" temporary): Text
    var
        ItemNoText: Text;
    begin
        Temp2InventoryBuffer.SetRange("Item No.", TempInventoryBuffer."Item No.");
        Temp2InventoryBuffer.SetRange("Variant Code", TempInventoryBuffer."Variant Code");
        if Temp2InventoryBuffer.FindSet() then
            repeat
                if (StrLen(ItemNoText) + StrLen(Temp2InventoryBuffer."Lot No.") + 2) < MaxStrLen(ItemNoText) then
                    if ItemNoText <> '' then
                        ItemNoText := ItemNoText + ', ' + Temp2InventoryBuffer."Lot No."
                    else
                        ItemNoText := Temp2InventoryBuffer."Lot No.";
            until Temp2InventoryBuffer.Next() = 0;
        exit(ItemNoText);
    end;

#if not CLEAN23
#pragma warning disable AL0432
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforePostCustomerEntry', '', false, false)]
    local procedure UpdateSymbolsAndBankAccountOnBeforePostCustomerEntry(var GenJnlLine: Record "Gen. Journal Line"; var SalesHeader: Record "Sales Header")
    begin
        GenJnlLine."Specific Symbol CZL" := SalesHeader."Specific Symbol CZL";
        if SalesHeader."Variable Symbol CZL" <> '' then
            GenJnlLine."Variable Symbol CZL" := SalesHeader."Variable Symbol CZL"
        else
            GenJnlLine."Variable Symbol CZL" := BankOperationsFunctionsCZL.CreateVariableSymbol(GenJnlLine."Document No.");
        GenJnlLine."Constant Symbol CZL" := SalesHeader."Constant Symbol CZL";
        GenJnlLine."Bank Account Code CZL" := SalesHeader."Bank Account Code CZL";
        GenJnlLine."Bank Account No. CZL" := SalesHeader."Bank Account No. CZL";
        GenJnlLine."IBAN CZL" := SalesHeader."IBAN CZL";
        GenJnlLine."SWIFT Code CZL" := SalesHeader."SWIFT Code CZL";
        GenJnlLine."Transit No. CZL" := SalesHeader."Transit No. CZL";
    end;

#pragma warning restore AL0432
#endif
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales Post Invoice Events", 'OnPostLedgerEntryOnBeforeGenJnlPostLine', '', false, false)]
    local procedure UpdateSymbolsAndBankAccountOnPostLedgerEntryOnBeforeGenJnlPostLine(var GenJnlLine: Record "Gen. Journal Line"; var SalesHeader: Record "Sales Header")
    begin
        GenJnlLine."Specific Symbol CZL" := SalesHeader."Specific Symbol CZL";
        if SalesHeader."Variable Symbol CZL" <> '' then
            GenJnlLine."Variable Symbol CZL" := SalesHeader."Variable Symbol CZL"
        else
            GenJnlLine."Variable Symbol CZL" := BankOperationsFunctionsCZL.CreateVariableSymbol(GenJnlLine."Document No.");
        GenJnlLine."Constant Symbol CZL" := SalesHeader."Constant Symbol CZL";
        GenJnlLine."Bank Account Code CZL" := SalesHeader."Bank Account Code CZL";
        GenJnlLine."Bank Account No. CZL" := SalesHeader."Bank Account No. CZL";
        GenJnlLine."IBAN CZL" := SalesHeader."IBAN CZL";
        GenJnlLine."SWIFT Code CZL" := SalesHeader."SWIFT Code CZL";
        GenJnlLine."Transit No. CZL" := SalesHeader."Transit No. CZL";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforeSalesInvHeaderInsert', '', false, false)]
    local procedure FillVariableSymbolOnBeforeSalesInvHeaderInsert(var SalesInvHeader: Record "Sales Invoice Header")
    begin
        if SalesInvHeader."Variable Symbol CZL" = '' then
            SalesInvHeader."Variable Symbol CZL" := BankOperationsFunctionsCZL.CreateVariableSymbol(SalesInvHeader."No.");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforeSalesCrMemoHeaderInsert', '', false, false)]
    local procedure FillVariableSymbolOnBeforeSalesCrMemoHeaderInsert(var SalesCrMemoHeader: Record "Sales Cr.Memo Header")
    begin
        if SalesCrMemoHeader."Variable Symbol CZL" = '' then
            SalesCrMemoHeader."Variable Symbol CZL" := BankOperationsFunctionsCZL.CreateVariableSymbol(SalesCrMemoHeader."No.");
    end;
#if not CLEAN22
#pragma warning disable AL0432

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterTestSalesLine', '', false, false)]
    local procedure CheckIntrastatOnAfterTestSalesLine(SalesHeader: Record "Sales Header"; SalesLine: Record "Sales Line")
    begin
        SalesLine.CheckIntrastatMandatoryFieldsCZL(SalesHeader);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterInitAssocItemJnlLine', '', false, false)]
    local procedure CopyFieldsOnAfterInitAssocItemJnlLine(var ItemJournalLine: Record "Item Journal Line"; PurchaseHeader: Record "Purchase Header"; PurchaseLine: Record "Purchase Line")
    begin
        ItemJournalLine."Intrastat Transaction CZL" := PurchaseHeader.IsIntrastatTransactionCZL();
        // recalc to base UOM
        if ItemJournalLine."Net Weight CZL" <> 0 then
            if PurchaseLine."Qty. per Unit of Measure" <> 0 then
                ItemJournalLine."Net Weight CZL" := Round(ItemJournalLine."Net Weight CZL" / PurchaseLine."Qty. per Unit of Measure", 0.00001);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnPostItemJnlLineOnAfterCopyItemCharge', '', false, false)]
    local procedure CopyFieldsOnPostItemJnlLineOnAfterCopyItemCharge(var ItemJournalLine: Record "Item Journal Line"; var TempItemChargeAssgntSales: Record "Item Charge Assignment (Sales)")
    begin
        ItemJournalLine."Incl. in Intrastat Amount CZL" := TempItemChargeAssgntSales."Incl. in Intrastat Amount CZL";
        ItemJournalLine."Incl. in Intrastat S.Value CZL" := TempItemChargeAssgntSales."Incl. in Intrastat S.Value CZL";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnPostItemChargePerOrderOnAfterCopyToItemJnlLine', '', false, false)]
    local procedure CopyFieldsOnPostItemChargePerOrderOnAfterCopyToItemJnlLine(var ItemJournalLine: Record "Item Journal Line"; var TempItemChargeAssignmentSales: Record "Item Charge Assignment (Sales)")
    begin
        ItemJournalLine."Incl. in Intrastat Amount CZL" := TempItemChargeAssignmentSales."Incl. in Intrastat Amount CZL";
        ItemJournalLine."Incl. in Intrastat S.Value CZL" := TempItemChargeAssignmentSales."Incl. in Intrastat S.Value CZL";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterValidatePostingAndDocumentDate', '', false, false)]
    local procedure ValidateVATDateOnAfterValidatePostingAndDocumentDate(var SalesHeader: Record "Sales Header")
    var
        BatchProcessingMgt: Codeunit "Batch Processing Mgt.";
        VATReportingDateMgt: Codeunit "VAT Reporting Date Mgt";
        VATDate: Date;
        VATDateExists: Boolean;
        ReplaceVATDate: Boolean;
        PostingDate: Date;
    begin
        if SalesHeader.IsReplaceVATDateEnabled() then
            exit;
        if VATReportingDateMgt.IsVATDateEnabled() then begin
            VATDateExists :=
                BatchProcessingMgt.GetBooleanParameter(SalesHeader.RecordId, Enum::"Batch Posting Parameter Type"::"Replace VAT Date", ReplaceVATDate) and
                BatchProcessingMgt.GetDateParameter(SalesHeader.RecordId, Enum::"Batch Posting Parameter Type"::"VAT Date", VATDate);
            if not VATDateExists then
                VATDateExists :=
                    BatchProcessingMgt.GetBooleanParameter(SalesHeader.RecordId, Enum::"Batch Posting Parameter Type"::"Replace VAT Date CZL", ReplaceVATDate) and
                    BatchProcessingMgt.GetDateParameter(SalesHeader.RecordId, Enum::"Batch Posting Parameter Type"::"VAT Date CZL", VATDate);
            if VATDateExists and (ReplaceVATDate or (SalesHeader."VAT Date CZL" = 0D)) then begin
                SalesHeader.Validate("VAT Date CZL", VATDate);
                SalesHeader.Modify();
            end;
        end else
            if BatchProcessingMgt.GetDateParameter(SalesHeader.RecordId, Enum::"Batch Posting Parameter Type"::"Posting Date", PostingDate) and
               (SalesHeader."Posting Date" <> SalesHeader."VAT Date CZL")
            then begin
                SalesHeader.Validate("VAT Date CZL", PostingDate);
                SalesHeader.Modify();
            end;
    end;
#pragma warning restore AL0432
#endif

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforeTestSalesLineItemCharge', '', false, false)]
    local procedure SkipCheckOnBeforeTestSalesLineItemCharge(SalesLine: Record "Sales Line"; var IsHandled: Boolean)
    var
        SalesHeader: Record "Sales Header";
    begin
        if SalesHeader.Get(SalesLine."Document Type", SalesLine."Document No.") then
            if not SalesHeader.Invoice then
                IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnPostItemJnlLineOnAfterPrepareItemJnlLine', '', false, false)]
    local procedure SetGLCorrectionOnPostItemJnlLineOnBeforeInitAmount(var ItemJournalLine: Record "Item Journal Line"; SalesHeader: Record "Sales Header"; SalesLine: Record "Sales Line")
    begin
        ItemJournalLine."G/L Correction CZL" := SalesHeader.Correction xor SalesLine."Negative CZL";
    end;
#if not CLEAN22

    [EventSubscriber(ObjectType::Report, Report::"Sales Document - Test", 'OnAfterCheckSalesDoc', '', false, false)]
    local procedure CheckIntrastatMandatoryFieldsOnAfterCheckSalesDoc(SalesHeader: Record "Sales Header"; var ErrorCounter: Integer; var ErrorText: array[99] of Text[250])
    var
        StatutoryReportingSetupCZL: Record "Statutory Reporting Setup CZL";
        FeatureMgtFacade: Codeunit "Feature Management Facade";
        MustBeSpecifiedLbl: Label '%1 must be specified.', Comment = '%1 = FieldCaption';
        IntrastatFeatureKeyIdTok: Label 'ReplaceIntrastat', Locked = true;
    begin
        if FeatureMgtFacade.IsEnabled(IntrastatFeatureKeyIdTok) then
            exit;
        if not (SalesHeader.Ship or SalesHeader.Receive) then
            exit;
        if SalesHeader.IsIntrastatTransactionCZL() and SalesHeader.ShipOrReceiveInventoriableTypeItemsCZL() then begin
            StatutoryReportingSetupCZL.Get();
#pragma warning disable AL0432
            if StatutoryReportingSetupCZL."Transaction Type Mandatory" then
                if SalesHeader."Transaction Type" = '' then
                    AddError(StrSubstNo(MustBeSpecifiedLbl, SalesHeader.FieldCaption("Transaction Type")), ErrorCounter, ErrorText);
            if StatutoryReportingSetupCZL."Transaction Spec. Mandatory" then
                if SalesHeader."Transaction Specification" = '' then
                    AddError(StrSubstNo(MustBeSpecifiedLbl, SalesHeader.FieldCaption("Transaction Specification")), ErrorCounter, ErrorText);
            if StatutoryReportingSetupCZL."Transport Method Mandatory" then
                if SalesHeader."Transport Method" = '' then
                    AddError(StrSubstNo(MustBeSpecifiedLbl, SalesHeader.FieldCaption("Transport Method")), ErrorCounter, ErrorText);
            if StatutoryReportingSetupCZL."Shipment Method Mandatory" then
                if SalesHeader."Shipment Method Code" = '' then
                    AddError(StrSubstNo(MustBeSpecifiedLbl, SalesHeader.FieldCaption("Shipment Method Code")), ErrorCounter, ErrorText);
#pragma warning restore AL0432
        end;
    end;

    local procedure AddError(Text: Text[250]; var ErrorCounter: Integer; var ErrorText: array[99] of Text[250])
    begin
        ErrorCounter += 1;
        ErrorText[ErrorCounter] := Text;
    end;
#endif

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckTariffNo(SalesHeader: Record "Sales Header"; var IsHandled: Boolean);
    begin
    end;
}
