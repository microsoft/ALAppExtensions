codeunit 31253 "Item Journal Line Handler CZA"
{
    [EventSubscriber(ObjectType::Table, Database::"Item Journal Line", 'OnAfterValidateEvent', 'Variant Code', false, false)]
    local procedure SetGPPGfromSKUOnAfterValidateVariantCode(var Rec: Record "Item Journal Line")
    begin
        Rec.SetGPPGfromSKUCZA();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Journal Line", 'OnAfterValidateEvent', 'Location Code', false, false)]
    local procedure SetGPPGfromSKUOnAfterValidateEventLocationCode(var Rec: Record "Item Journal Line")
    begin
        Rec.SetGPPGfromSKUCZA();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Journal Line", 'OnValidateItemNoOnAfterGetItem', '', false, false)]
    local procedure SetGPPGfromSKUOnValidateItemNoOnAfterGetItem(var ItemJournalLine: Record "Item Journal Line")
    begin
        ItemJournalLine.SetGPPGfromSKUCZA();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Journal Line", 'OnAfterCopyItemJnlLineFromSalesHeader', '', false, false)]
    local procedure AddFieldsOnAfterCopyItemJnlLineFromSalesHeader(var ItemJnlLine: Record "Item Journal Line"; SalesHeader: Record "Sales Header")
    begin
        ItemJnlLine."Delivery-to Source No. CZA" := SalesHeader."Ship-to Code";
        ItemJnlLine."Currency Code CZA" := SalesHeader."Currency Code";
        ItemJnlLine."Currency Factor CZA" := SalesHeader."Currency Factor";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Journal Line", 'OnAfterCopyItemJnlLineFromPurchHeader', '', false, false)]
    local procedure AddFieldsOnAfterCopyItemJnlLineFromPurchHeader(var ItemJnlLine: Record "Item Journal Line"; PurchHeader: Record "Purchase Header")
    begin
        ItemJnlLine."Delivery-to Source No. CZA" := PurchHeader."Ship-to Code";
        ItemJnlLine."Currency Code CZA" := PurchHeader."Currency Code";
        ItemJnlLine."Currency Factor CZA" := PurchHeader."Currency Factor";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Journal Line", 'OnAfterCopyItemJnlLineFromServHeader', '', false, false)]
    local procedure AddFieldsOnAfterCopyItemJnlLineFromServHeader(var ItemJnlLine: Record "Item Journal Line"; ServHeader: Record "Service Header")
    begin
        ItemJnlLine."Delivery-to Source No. CZA" := ServHeader."Ship-to Code";
        ItemJnlLine."Currency Code CZA" := ServHeader."Currency Code";
        ItemJnlLine."Currency Factor CZA" := ServHeader."Currency Factor";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Journal Line", 'OnAfterCopyItemJnlLineFromServShptHeader', '', false, false)]
    local procedure AddFieldsOnAfterCopyItemJnlLineFromServShptHeader(var ItemJnlLine: Record "Item Journal Line"; ServShptHeader: Record "Service Shipment Header")
    begin
        ItemJnlLine."Currency Code CZA" := ServShptHeader."Currency Code";
        ItemJnlLine."Currency Factor CZA" := ServShptHeader."Currency Factor";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", 'OnInsertCapValueEntryOnAfterUpdateCostAmounts', '', false, false)]
    local procedure AddFieldsOnInsertCapValueEntryOnAfterUpdateCostAmounts(var ValueEntry: Record "Value Entry"; var ItemJournalLine: Record "Item Journal Line")
    begin
        ValueEntry."Invoice-to Source No. CZA" := ItemJournalLine."Invoice-to Source No.";
        ValueEntry."Delivery-to Source No. CZA" := ItemJournalLine."Delivery-to Source No. CZA";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", 'OnBeforeInsertCapLedgEntry', '', false, false)]
    local procedure AddFieldsOnBeforeInsertCapLedgEntry(var CapLedgEntry: Record "Capacity Ledger Entry")
    begin
        CapLedgEntry."User ID CZA" := CopyStr(UserId(), 1, MaxStrLen(CapLedgEntry."User ID CZA"));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", 'OnBeforeInsertCapValueEntry', '', false, false)]
    local procedure AddFieldsOnBeforeInsertCapValueEntry(var ValueEntry: Record "Value Entry"; ItemJnlLine: Record "Item Journal Line")
    begin
        ValueEntry."Invoice-to Source No. CZA" := ItemJnlLine."Invoice-to Source No.";
        ValueEntry."Delivery-to Source No. CZA" := ItemJnlLine."Delivery-to Source No. CZA";
        ValueEntry."Currency Code CZA" := ItemJnlLine."Currency Code CZA";
        ValueEntry."Currency Factor CZA" := ItemJnlLine."Currency Factor CZA";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", 'OnAfterInitItemLedgEntry', '', false, false)]
    local procedure AddFieldsOnAfterInitItemLedgEntry(var NewItemLedgEntry: Record "Item Ledger Entry"; ItemJournalLine: Record "Item Journal Line")
    begin
        NewItemLedgEntry."Invoice-to Source No. CZA" := ItemJournalLine."Invoice-to Source No.";
        NewItemLedgEntry."Delivery-to Source No. CZA" := ItemJournalLine."Delivery-to Source No. CZA";
        NewItemLedgEntry."Currency Code CZA" := ItemJournalLine."Currency Code CZA";
        NewItemLedgEntry."Currency Factor CZA" := ItemJournalLine."Currency Factor CZA";
        NewItemLedgEntry."Source Code CZA" := ItemJournalLine."Source Code";
        NewItemLedgEntry."Reason Code CZA" := ItemJournalLine."Reason Code";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", 'OnInitValueEntryOnAfterAssignFields', '', false, false)]
    local procedure AddFieldsOnInitValueEntryOnAfterAssignFields(var ValueEntry: Record "Value Entry"; ItemLedgEntry: Record "Item Ledger Entry")
    begin
        ValueEntry."Invoice-to Source No. CZA" := ItemLedgEntry."Invoice-to Source No. CZA";
        ValueEntry."Delivery-to Source No. CZA" := ItemLedgEntry."Delivery-to Source No. CZA";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", 'OnAfterInitValueEntry', '', false, false)]
    local procedure AddFieldsOnAfterInitValueEntry(var ValueEntry: Record "Value Entry"; ItemJournalLine: Record "Item Journal Line")
    begin
        if ItemJournalLine."Item Charge No." <> '' then begin
            ValueEntry."Invoice-to Source No. CZA" := ItemJournalLine."Invoice-to Source No.";
            ValueEntry."Delivery-to Source No. CZA" := ItemJournalLine."Delivery-to Source No. CZA";
        end;
        ValueEntry."Currency Code CZA" := ItemJournalLine."Currency Code CZA";
        ValueEntry."Currency Factor CZA" := ItemJournalLine."Currency Factor CZA";
    end;
}
