// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Service.Posting;

using Microsoft.Bank;
using Microsoft.Finance.Currency;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.Finance.ReceivablesPayables;
using Microsoft.Finance.VAT.Calculation;
using Microsoft.Finance.VAT.Setup;
using Microsoft.Foundation.AuditCodes;
using Microsoft.Inventory.Intrastat;
using Microsoft.Service.Document;
using Microsoft.Service.History;

codeunit 31040 "Service Posting Handler CZL"
{
    var
        SourceCodeSetup: Record "Source Code Setup";
        GLEntry: Record "G/L Entry";
        Currency: Record Currency;
        BankOperationsFunctionsCZL: Codeunit "Bank Operations Functions CZL";
        ReverseChargeCheckCZL: Enum "Reverse Charge Check CZL";

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Service Post Invoice Events", 'OnPostLinesOnAfterGenJnlLinePost', '', false, false)]
    local procedure ServicePostVATCurrencyFactorOnPostLinesOnAfterGenJnlLinePost(var GenJnlLine: Record "Gen. Journal Line"; TempInvoicePostingBuffer: Record "Invoice Posting Buffer"; ServiceHeader: Record "Service Header"; GLEntryNo: Integer; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    var
        VATPostingSetup: Record "VAT Posting Setup";
        VATCurrFactor: Decimal;
    begin
        if ServiceHeader."Currency Factor" <> ServiceHeader."VAT Currency Factor CZL" then begin
            VATPostingSetup.Get(GenJnlLine."VAT Bus. Posting Group", GenJnlLine."VAT Prod. Posting Group");
            VATPostingSetup.TestField("VAT Calculation Type", VATPostingSetup."VAT Calculation Type"::"Reverse Charge VAT");
            VATPostingSetup.TestField("Sales VAT Curr. Exch. Acc CZL");
            SourceCodeSetup.Get();
            SourceCodeSetup.TestField("Sales VAT Delay CZL");
            GLEntry.Get(GLEntryNo);
            PostServiceVATCurrencyFactor(ServiceHeader, TempInvoicePostingBuffer, false, 1, true, VATPostingSetup, GenJnlPostLine);
            if ServiceHeader."VAT Currency Factor CZL" = 0 then
                VATCurrFactor := 1
            else
                VATCurrFactor := ServiceHeader."Currency Factor" / ServiceHeader."VAT Currency Factor CZL";
            if VATCurrFactor = 0 then
                VATCurrFactor := 1;

            PostServiceVATCurrencyFactor(ServiceHeader, TempInvoicePostingBuffer, true, VATCurrFactor, false, VATPostingSetup, GenJnlPostLine);
        end;
    end;

    local procedure PostServiceVATCurrencyFactor(ServiceHeader: Record "Service Header"; InvoicePostingBuffer: Record "Invoice Posting Buffer"; ToPost: Boolean; CurrFactor: Decimal; IsCorrection: Boolean; VATPostingSetup: Record "VAT Posting Setup"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    var
        GenJournalLine: Record "Gen. Journal Line";
        Sign: Integer;
    begin
        if ToPost then
            Sign := 1
        else
            Sign := -1;

        GenJournalLine.Init();
        GenJournalLine."Posting Date" := ServiceHeader."Posting Date";
        GenJournalLine.Validate("VAT Reporting Date", ServiceHeader."VAT Reporting Date");
        GenJournalLine."Document Date" := ServiceHeader."Document Date";
        GenJournalLine.Description := ServiceHeader."Posting Description";
        GenJournalLine."Reason Code" := ServiceHeader."Reason Code";
        GenJournalLine."Document Type" := GLEntry."Document Type";
        GenJournalLine."Document No." := GLEntry."Document No.";
        GenJournalLine."External Document No." := GLEntry."External Document No.";
        GenJournalLine."Account No." := VATPostingSetup."Sales VAT Curr. Exch. Acc CZL";
        GenJournalLine."System-Created Entry" := InvoicePostingBuffer."System-Created Entry";
        GenJournalLine."Source Currency Code" := ServiceHeader."Currency Code";
        GetCurrency(ServiceHeader."Currency Code");
#pragma warning disable AL0432
        if IsCorrection then
            GenJournalLine.Correction := not InvoicePostingBuffer."Correction CZL"
        else
            GenJournalLine.Correction := InvoicePostingBuffer."Correction CZL";
#pragma warning restore AL0432
        GenJournalLine."Gen. Posting Type" := GenJournalLine."Gen. Posting Type"::Sale;
        GenJournalLine."VAT Bus. Posting Group" := InvoicePostingBuffer."VAT Bus. Posting Group";
        GenJournalLine."VAT Prod. Posting Group" := InvoicePostingBuffer."VAT Prod. Posting Group";
        GenJournalLine."Tax Area Code" := InvoicePostingBuffer."Tax Area Code";
        GenJournalLine."Tax Liable" := InvoicePostingBuffer."Tax Liable";
        GenJournalLine."Tax Group Code" := InvoicePostingBuffer."Tax Group Code";
        GenJournalLine."Use Tax" := InvoicePostingBuffer."Use Tax";
        GenJournalLine."VAT Calculation Type" := InvoicePostingBuffer."VAT Calculation Type";
        GenJournalLine."VAT Base Discount %" := ServiceHeader."VAT Base Discount %";
        GenJournalLine."VAT Posting" := GenJournalLine."VAT Posting"::"Manual VAT Entry";
        GenJournalLine."Shortcut Dimension 1 Code" := InvoicePostingBuffer."Global Dimension 1 Code";
        GenJournalLine."Shortcut Dimension 2 Code" := InvoicePostingBuffer."Global Dimension 2 Code";
        GenJournalLine."Dimension Set ID" := InvoicePostingBuffer."Dimension Set ID";
        GenJournalLine."Job No." := InvoicePostingBuffer."Job No.";
        GenJournalLine."Source Code" := SourceCodeSetup."Sales VAT Delay CZL";
        GenJournalLine."Bill-to/Pay-to No." := ServiceHeader."Bill-to Customer No.";
        GenJournalLine."Source Type" := GenJournalLine."Source Type"::Customer;
        GenJournalLine."Source No." := ServiceHeader."Bill-to Customer No.";
        GenJournalLine."Posting No. Series" := ServiceHeader."Posting No. Series";
        GenJournalLine."Bal. Account No." := VATPostingSetup."Sales VAT Curr. Exch. Acc CZL";
        GenJournalLine.Quantity := Sign * InvoicePostingBuffer.Quantity;
        GenJournalLine.Amount := Round(Sign * InvoicePostingBuffer.Amount * CurrFactor, Currency."Amount Rounding Precision");
        GenJournalLine."VAT Amount" := Round(Sign * InvoicePostingBuffer."VAT Amount" *
            CurrFactor, Currency."Amount Rounding Precision");
        GenJournalLine."VAT Base Amount" := GenJournalLine.Amount;
        GenJournalLine."Source Currency Amount" := Round(Sign * InvoicePostingBuffer."Amount (ACY)" * CurrFactor,
            Currency."Amount Rounding Precision");
        GenJournalLine."Source Curr. VAT Amount" := Round(Sign * InvoicePostingBuffer."VAT Amount (ACY)" * CurrFactor,
            Currency."Amount Rounding Precision");
        GenJournalLine."Source Curr. VAT Base Amount" := GenJournalLine."Source Currency Amount" - GenJournalLine."Source Curr. VAT Amount";
        GenJournalLine."VAT Difference" := Round(Sign * InvoicePostingBuffer."VAT Difference" * CurrFactor,
            Currency."Amount Rounding Precision");
        GenJournalLine."Gen. Bus. Posting Group" := InvoicePostingBuffer."Gen. Bus. Posting Group";
        GenJournalLine."Gen. Prod. Posting Group" := InvoicePostingBuffer."Gen. Prod. Posting Group";
        GenJournalLine.Validate("VAT Delay CZL", true);

        GenJnlPostLine.RunWithCheck(GenJournalLine);
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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Service-Post", 'OnBeforePostWithLines', '', false, false)]
    local procedure CheckVatDateOnBeforePostWithLines(var PassedServHeader: Record "Service Header")
    var
        VATDateHandlerCZL: Codeunit "VAT Date Handler CZL";
    begin
        VATDateHandlerCZL.CheckVATDateCZL(PassedServHeader);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Service-Post", 'OnAfterInitialize', '', false, false)]
    local procedure OnAfterInitialize(var ServiceHeader: Record "Service Header")
    begin
        CheckTariffNo(ServiceHeader);
    end;

    procedure CheckTariffNo(ServiceHeader: Record "Service Header")
    var
        ServiceLine: Record "Service Line";
        TariffNumber: Record "Tariff Number";
        VATPostingSetup: Record "VAT Posting Setup";
        IsHandled: Boolean;
    begin
        OnBeforeCheckTariffNo(ServiceHeader, IsHandled);
        if IsHandled then
            exit;

        ServiceLine.SetRange("Document Type", ServiceHeader."Document Type");
        ServiceLine.SetRange("Document No.", ServiceHeader."No.");
        if ServiceLine.FindSet(false) then
            repeat
                if VATPostingSetup.Get(ServiceLine."VAT Bus. Posting Group", ServiceLine."VAT Prod. Posting Group") then
                    if VATPostingSetup."Reverse Charge Check CZL" = ReverseChargeCheckCZL::"Limit Check" then begin
                        ServiceLine.TestField("Tariff No. CZL");
                        if TariffNumber.Get(ServiceLine."Tariff No. CZL") then
                            if TariffNumber."VAT Stat. UoM Code CZL" <> '' then
                                ServiceLine.TestField("Unit of Measure Code", TariffNumber."VAT Stat. UoM Code CZL");
                    end;
            until ServiceLine.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Service Post Invoice Events", 'OnPostLedgerEntryOnBeforeGenJnlPostLine', '', false, false)]
    local procedure UpdateSymbolsAndBankAccountOnPostLedgerEntryOnBeforeGenJnlPostLine(var GenJournalLine: Record "Gen. Journal Line"; ServiceHeader: Record "Service Header")
    begin
        GenJournalLine."Specific Symbol CZL" := ServiceHeader."Specific Symbol CZL";
        if ServiceHeader."Variable Symbol CZL" <> '' then
            GenJournalLine."Variable Symbol CZL" := ServiceHeader."Variable Symbol CZL"
        else
            GenJournalLine."Variable Symbol CZL" := BankOperationsFunctionsCZL.CreateVariableSymbol(GenJournalLine."Document No.");
        GenJournalLine."Constant Symbol CZL" := ServiceHeader."Constant Symbol CZL";
        GenJournalLine."Bank Account Code CZL" := ServiceHeader."Bank Account Code CZL";
        GenJournalLine."Bank Account No. CZL" := ServiceHeader."Bank Account No. CZL";
        GenJournalLine."IBAN CZL" := ServiceHeader."IBAN CZL";
        GenJournalLine."SWIFT Code CZL" := ServiceHeader."SWIFT Code CZL";
        GenJournalLine."Transit No. CZL" := ServiceHeader."Transit No. CZL";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Serv-Documents Mgt.", 'OnBeforeServInvHeaderInsert', '', false, false)]
    local procedure FillVariableSymbolOnBeforeServInvHeaderInsert(var ServiceInvoiceHeader: Record "Service Invoice Header")
    begin
        if ServiceInvoiceHeader."Variable Symbol CZL" = '' then
            ServiceInvoiceHeader."Variable Symbol CZL" := BankOperationsFunctionsCZL.CreateVariableSymbol(ServiceInvoiceHeader."No.");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Serv-Documents Mgt.", 'OnBeforeServCrMemoHeaderInsert', '', false, false)]
    local procedure FillVariableSymbolOnBeforeServCrMemoHeaderInsert(var ServiceCrMemoHeader: Record "Service Cr.Memo Header")
    begin
        if ServiceCrMemoHeader."Variable Symbol CZL" = '' then
            ServiceCrMemoHeader."Variable Symbol CZL" := BankOperationsFunctionsCZL.CreateVariableSymbol(ServiceCrMemoHeader."No.");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Service-Post (Yes/No)", 'OnBeforeConfirmServPost', '', false, false)]
    local procedure CheckQRPaymentOnBeforeConfirmServPost(var ServiceHeader: Record "Service Header")
    begin
        ServiceHeader.CheckPaymentQRCodePrintIBANCZL();
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckTariffNo(ServiceHeader: Record "Service Header"; var IsHandled: Boolean);
    begin
    end;
}
