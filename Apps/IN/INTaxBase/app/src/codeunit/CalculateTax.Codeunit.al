// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TaxBase;

using Microsoft.Finance.Currency;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.Finance.TaxEngine.UseCaseBuilder;
using Microsoft.Finance.VAT.Setup;
using Microsoft.Purchases.Document;
using Microsoft.Sales.Document;
using Microsoft.Sales.FinanceCharge;
using Microsoft.Service.Document;

codeunit 18543 "Calculate Tax"
{
    procedure CallTaxEngineOnGenJnlLine(
        var GenJournalLine: Record "Gen. Journal Line";
        var xGenJournalLine: Record "Gen. Journal Line")
    var
        IsHandled: Boolean;
    begin
        OnBeforeCallTaxEngineForGenJnlLine(GenJournalLine, IsHandled);
        if IsHandled then
            exit;

        if GenJournalLine."System-Created Entry" then
            exit;

        if (GenJournalLine.Amount = 0) and (xGenJournalLine.Amount = 0) then
            exit;

        OnAfterValidateGenJnlLineFields(GenJournalLine);
    end;

    procedure CallTaxEngineOnSalesLine(
        var SalesLine: Record "Sales Line";
        var xSalesLine: Record "Sales Line")
    var
        IsHandled: Boolean;
    begin
        OnBeforeCallTaxEngineForSalesLine(SalesLine, IsHandled);
        if IsHandled then
            exit;

        if (SalesLine.Quantity = 0) and (xSalesLine.Quantity = 0) then
            exit;

        OnAfterValidateSalesLineFields(SalesLine);
    end;

    procedure CallTaxEngineOnPurchaseLine(
        var PurchaseLine: Record "Purchase Line";
        var xPurchaseLine: Record "Purchase Line")
    var
        IsHandled: Boolean;
    begin
        OnBeforeCallTaxEngineForPurchaseLine(PurchaseLine, IsHandled);
        if IsHandled then
            exit;

        if (PurchaseLine.Quantity = 0) and (xPurchaseLine.Quantity = 0) then
            exit;

        OnAfterValidatePurchaseLineFields(PurchaseLine);
    end;

    procedure CallTaxEngineOnServiceLine(
        var ServiceLine: Record "Service Line";
        var xServiceLine: Record "Service Line")
    var
        IsHandled: Boolean;
    begin
        OnBeforeCallTaxEngineForServiceLine(ServiceLine, IsHandled);
        if IsHandled then
            exit;

        if (ServiceLine.Quantity = 0) and (xServiceLine.Quantity = 0) then
            exit;

        OnAfterValidateServiceLineFields(ServiceLine);
    end;

    procedure CallTaxEngineOnFinanceChargeMemoLine(
            var FinanceChargeMemoLine: Record "Finance Charge Memo Line";
            var xFinanceChargeMemoLine: Record "Finance Charge Memo Line")
    begin
        if (FinanceChargeMemoLine.Amount = 0) and (xFinanceChargeMemoLine.Amount = 0) then
            exit;

        OnAfterValidateFinChargeMemoLineFields(FinanceChargeMemoLine);
    end;

    //Call General Journal Line Related Use Cases
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Use Case Event Library", 'OnAddUseCaseEventstoLibrary', '', false, false)]
    local procedure OnAddGenJnlLineUseCaseEventstoLibrary()
    var
        UseCaseEventLibrary: Codeunit "Use Case Event Library";
    begin
        UseCaseEventLibrary.AddUseCaseEventToLibrary('CallTaxEngineOnGenJnlLine', Database::"Gen. Journal Line", 'Calculate Tax on General Journal line');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Calculate Tax", 'OnAfterValidateGenJnlLineFields', '', false, false)]
    local procedure HandleGenJnlLineUseCase(var GenJnlLine: Record "Gen. Journal Line")
    var
        UseCaseExecution: Codeunit "Use Case Execution";
    begin
        UseCaseExecution.HandleEvent(
            'CallTaxEngineOnGenJnlLine',
            GenJnlLine,
            GenJnlLine."Currency Code",
            GenJnlLine."Currency Factor");
    end;

    //Call Sales Line Related Use Cases
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Use Case Event Library", 'OnAddUseCaseEventstoLibrary', '', false, false)]
    local procedure OnAddSalesUseCaseEventstoLibrary()
    var
        UseCaseEventLibrary: Codeunit "Use Case Event Library";
    begin
        UseCaseEventLibrary.AddUseCaseEventToLibrary('CallTaxEngineOnSalesLine', Database::"Sales Line", 'Calculate Tax on Sales line');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Calculate Tax", 'OnAfterValidateSalesLineFields', '', false, false)]
    local procedure HandleSalesUseCase(var SalesLine: Record "Sales Line")
    var
        SalesHeader: Record "Sales Header";
        UseCaseExecution: Codeunit "Use Case Execution";
    begin
        SalesHeader.Get(SalesLine."Document Type", SalesLine."Document No.");
        UseCaseExecution.HandleEvent(
            'CallTaxEngineOnSalesLine',
            SalesLine,
            SalesHeader."Currency Code",
            SalesHeader."Currency Factor");
    end;

    //Call Purchase Line Related Use Cases
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Use Case Event Library", 'OnAddUseCaseEventstoLibrary', '', false, false)]
    local procedure OnAddPurchaseUseCaseEventstoLibrary()
    var
        UseCaseEventLibrary: Codeunit "Use Case Event Library";
    begin
        UseCaseEventLibrary.AddUseCaseEventToLibrary('CallTaxEngineOnPurchaseLine', Database::"Purchase Line", 'Calculate Tax on Purchase Line');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Calculate Tax", 'OnAfterValidatePurchaseLineFields', '', false, false)]
    local procedure HandlePurchaseUseCase(var PurchaseLine: Record "Purchase Line")
    var
        PurchaseHeader: Record "Purchase Header";
        UseCaseExecution: Codeunit "Use Case Execution";
    begin
        PurchaseHeader.Get(PurchaseLine."Document Type", PurchaseLine."Document No.");
        UseCaseExecution.HandleEvent(
            'CallTaxEngineOnPurchaseLine',
            PurchaseLine,
            PurchaseHeader."Currency Code",
            PurchaseHeader."Currency Factor");
    end;

    //Call Service Line Related Use Cases
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Use Case Event Library", 'OnAddUseCaseEventstoLibrary', '', false, false)]
    local procedure OnAddServiceUseCaseEventstoLibrary()
    var
        UseCaseEventLibrary: Codeunit "Use Case Event Library";
    begin
        UseCaseEventLibrary.AddUseCaseEventToLibrary('CallTaxEngineOnServiceLine', Database::"Service Line", 'Calculate Tax on Service line');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Calculate Tax", 'OnAfterValidateServiceLineFields', '', false, false)]
    local procedure HandleServiceUseCase(var ServiceLine: Record "Service Line")
    var
        ServiceHeader: Record "Service Header";
        UseCaseExecution: Codeunit "Use Case Execution";
    begin
        if not ServiceHeader.Get(ServiceLine."Document Type", ServiceLine."Document No.") then
            exit;

        UseCaseExecution.HandleEvent(
            'CallTaxEngineOnServiceLine',
            ServiceLine,
            ServiceHeader."Currency Code",
            ServiceHeader."Currency Factor");
    end;

    //Call GST Finance Charge Memo Line Related Use Cases
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Use Case Event Library", 'OnAddUseCaseEventstoLibrary', '', false, false)]
    local procedure OnAddFinanceUseCaseEventstoLibrary()
    var
        UseCaseEventLibrary: Codeunit "Use Case Event Library";
    begin
        UseCaseEventLibrary.AddUseCaseEventToLibrary('CallTaxEngineOnFinanceChargeMemoLine', Database::"Finance Charge Memo Line", 'Calculate Tax on Finance Charge Memo Line');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Calculate Tax", 'OnAfterValidateFinChargeMemoLineFields', '', false, false)]
    local procedure HandleFinanceChargeMemoUseCase(var FinanceChargeMemoLine: Record "Finance Charge Memo Line")
    var
        FinanceChargeMemoHeader: Record "Finance Charge Memo Header";
        UseCaseExecution: Codeunit "Use Case Execution";
    begin
        if not FinanceChargeMemoHeader.Get(FinanceChargeMemoLine."Finance Charge Memo No.") then
            exit;

        UseCaseExecution.HandleEvent(
            'CallTaxEngineOnFinanceChargeMemoLine',
            FinanceChargeMemoLine,
            FinanceChargeMemoHeader."Currency Code",
            UpdateCurrencyFactor(FinanceChargeMemoHeader));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnBeforePostVAT', '', false, false)]
    local procedure OnBeforePostVAT(VATPostingSetup: Record "VAT Posting Setup"; var IsHandled: Boolean)
    begin
        if (VATPostingSetup."VAT Bus. Posting Group" = '') and (VATPostingSetup."VAT Prod. Posting Group" = '') then
            IsHandled := true;
    end;

    local procedure UpdateCurrencyFactor(FinanceChargeMemoHeader: Record "Finance Charge Memo Header"): Decimal
    var
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        CurrencyDate: Date;
        CurrencyFactor: Decimal;
    begin
        if FinanceChargeMemoHeader."Currency Code" <> '' then begin
            if FinanceChargeMemoHeader."Posting Date" <> 0D then
                CurrencyDate := FinanceChargeMemoHeader."Posting Date"
            else
                CurrencyDate := WorkDate();

            CurrencyFactor := CurrencyExchangeRate.ExchangeRate(CurrencyDate, FinanceChargeMemoHeader."Currency Code");
        end else
            CurrencyFactor := 0;
        exit(CurrencyFactor);
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterValidateGenJnlLineFields(var GenJnlLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterValidateSalesLineFields(var SalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterValidatePurchaseLineFields(var PurchaseLine: Record "Purchase Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterValidateServiceLineFields(var ServiceLine: Record "Service Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterValidateFinChargeMemoLineFields(var FinanceChargeMemoLine: Record "Finance Charge Memo Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnBeforeCallTaxEngineForGenJnlLine(var GenJournalLine: Record "Gen. Journal Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnBeforeCallTaxEngineForSalesLine(var SalesLine: Record "Sales Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnBeforeCallTaxEngineForPurchaseLine(var PurchaseLine: Record "Purchase Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnBeforeCallTaxEngineForServiceLine(var ServiceLine: Record "Service Line"; var IsHandled: Boolean)
    begin
    end;
}
