codeunit 31444 "Undo Shipment Line Handler CZA"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Undo Sales Shipment Line", 'OnAfterCopyItemJnlLineFromSalesShpt', '', false, false)]
    local procedure ItemBaseUnitOfMeasureOnAfterCopyItemJnlLineFromSalesShpt(var ItemJournalLine: Record "Item Journal Line")
    var
        Item: Record Item;
    begin
        if ItemJournalLine."Item No." = '' then
            exit;
        Item.Get(ItemJournalLine."Item No.");
        ItemJournalLine."Unit of Measure Code" := Item."Base Unit of Measure";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Undo Return Shipment Line", 'OnAfterCopyItemJnlLineFromReturnShpt', '', false, false)]
    local procedure ItemBaseUnitOfMeasureOnAfterCopyItemJnlLineFromReturnShpt(var ItemJournalLine: Record "Item Journal Line")
    var
        Item: Record Item;
    begin
        if ItemJournalLine."Item No." = '' then
            exit;
        Item.Get(ItemJournalLine."Item No.");
        ItemJournalLine."Unit of Measure Code" := Item."Base Unit of Measure";
    end;
}
