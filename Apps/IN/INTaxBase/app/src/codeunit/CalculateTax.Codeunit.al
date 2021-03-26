codeunit 18543 "Calculate Tax"
{
    procedure CallTaxEngineOnGenJnlLine(
        var GenJournalLine: Record "Gen. Journal Line";
        var xGenJournalLine: Record "Gen. Journal Line")
    begin
        if GenJournalLine."System-Created Entry" then
            exit;

        if (GenJournalLine.Amount = 0) and (xGenJournalLine.Amount = 0) then
            exit;

        OnAfterValidateGenJnlLineFields(GenJournalLine);
    end;

    procedure CallTaxEngineOnSalesLine(
        var SalesLine: Record "Sales Line";
        var xSalesLine: Record "Sales Line")
    begin
        if (SalesLine.Quantity = 0) and (xSalesLine.Quantity = 0) then
            exit;

        OnAfterValidateSalesLineFields(SalesLine);
    end;

    procedure CallTaxEngineOnPurchaseLine(
        var PurchaseLine: Record "Purchase Line";
        var xPurchaseLine: Record "Purchase Line")
    begin
        if (PurchaseLine.Quantity = 0) and (xPurchaseLine.Quantity = 0) then
            exit;

        OnAfterValidatePurchaseLineFields(PurchaseLine);
    end;

    procedure CallTaxEngineOnServiceLine(
            var ServiceLine: Record "Service Line";
            var xServiceLine: Record "Service Line")
    begin
        if (ServiceLine.Quantity = 0) and (xServiceLine.Quantity = 0) then
            exit;

        OnAfterValidateServiceLineFields(ServiceLine);
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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnBeforePostVAT', '', false, false)]
    local procedure OnBeforePostVAT(VATPostingSetup: Record "VAT Posting Setup"; var IsHandled: Boolean)
    begin
        if (VATPostingSetup."VAT Bus. Posting Group" = '') and (VATPostingSetup."VAT Prod. Posting Group" = '') then
            IsHandled := true;
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
}