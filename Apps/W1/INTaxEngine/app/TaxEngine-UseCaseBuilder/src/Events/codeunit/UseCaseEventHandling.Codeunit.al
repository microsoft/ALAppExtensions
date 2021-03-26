codeunit 20286 "Use Case Event Handling"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Use Case Event Library", 'OnAfterHandleBusinessUseCaseEvent', '', false, false)]
    procedure OnAfterHandleBusinessUseCaseEvent(EventName: Text[150]; Record: Variant; CurrencyCode: Code[20]; CurrencyFactor: Decimal);
    begin
        UseCaseExecution.HandleEvent(EventName, Record, CurrencyCode, CurrencyFactor);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnAfterUpdateAmountsDone', '', false, false)]
    procedure BusinessRuleOnAfterUpdateSalesLineAmountsDone(var SalesLine: Record "Sales Line"; var xSalesLine: Record "Sales Line")
    var
        SalesHeader: Record "Sales Header";
    begin
        if (SalesLine.Quantity = 0) and (xSalesLine.Quantity = 0) then
            exit;
        if not SalesHeader.Get(SalesLine."Document Type", SalesLine."Document No.") then
            exit;
        UseCaseExecution.HandleEvent('OnAfterUpdateSalesUnitPrice', SalesLine, SalesHeader."Currency Code", SalesHeader."Currency Factor");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnAfterUpdateAmountsDone', '', false, false)]
    procedure BusinessRuleOnAfterUpdatePurchUnitPrice(var PurchLine: Record "Purchase Line"; var xPurchLine: Record "Purchase Line");
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        if (PurchLine.Quantity = 0) and (xPurchLine.Quantity = 0) then
            exit;
        if not PurchaseHeader.Get(PurchLine."Document Type", PurchLine."Document No.") then
            exit;
        UseCaseExecution.HandleEvent('OnAfterUpdatePurchUnitPrice', PurchLine, PurchaseHeader."Currency Code", PurchaseHeader."Currency Factor");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::GlobalTriggerManagement, 'OnAfterOnDatabaseRename', '', false, false)]
    local procedure BusinessRuleOnAfterRename(RecRef: RecordRef; xRecRef: RecordRef);
    begin
        RenameTaxTransactionValue(RecRef, xRecRef);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::GlobalTriggerManagement, 'OnAfterOnDatabaseDelete', '', false, false)]
    local procedure BusinessRuleOnAfterDelete(RecRef: RecordRef);
    begin
        DeleteTaxTransactionValue(RecRef);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::GlobalTriggerManagement, 'OnAfterGetDatabaseTableTriggerSetup', '', false, false)]
    local procedure OnAfterGetDatabaseTableTriggerSetup(TableId: Integer; var OnDatabaseInsert: Boolean; var OnDatabaseModify: Boolean; var OnDatabaseDelete: Boolean; var OnDatabaseRename: Boolean);
    var
        TaxEntity: Record "Tax Entity";
    begin
        TaxEntity.SetRange("Table ID", TableId);
        if not TaxEntity.IsEmpty() then
            OnDatabaseDelete := true;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterValidateEvent', 'Amount', false, false)]
    procedure OnAfterPostGenJnlLine(var Rec: Record "Gen. Journal Line"; var xRec: Record "Gen. Journal Line");
    begin
        if rec."System-Created Entry" then
            exit;

        if (Rec.Amount = 0) and (xRec.Amount = 0) then
            exit;
        UseCaseExecution.HandleEvent('OnGenJnlPost', Rec, Rec."Currency Code", Rec."Currency Factor");
    end;

    local procedure DeleteTaxTransactionValue(RecRef: RecordRef);
    var
        TaxTransactionValue: Record "Tax Transaction Value";
    begin
        if RecRef.IsTemporary() then
            exit;

        TaxTransactionValue.SetRange("Tax Record ID", RecRef.RecordId());
        if not TaxTransactionValue.IsEmpty() then
            TaxTransactionValue.DeleteAll(true);
    end;

    local procedure RenameTaxTransactionValue(RecRef: RecordRef; xRecRef: RecordRef);
    var
        TaxTransactionValue: Record "Tax Transaction Value";
    begin
        if RecRef.IsTemporary() then
            exit;

        TaxTransactionValue.SetRange("Tax Record ID", xRecRef.RecordId());
        if not TaxTransactionValue.IsEmpty() then
            TaxTransactionValue.ModifyAll("Tax Record ID", RecRef.RecordId());
    end;

    var
        UseCaseExecution: Codeunit "Use Case Execution";
}