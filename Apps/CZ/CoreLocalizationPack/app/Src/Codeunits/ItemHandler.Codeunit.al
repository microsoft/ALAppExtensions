codeunit 11777 "Item Handler CZL"
{
    [EventSubscriber(ObjectType::Table, Database::Item, 'OnAfterValidateEvent', 'Inventory Posting Group', false, false)]
    local procedure CheckChangeInventoryPostingGroupOnAfterInventoryPostingGroupValidate(Rec: Record Item)
    begin
        Rec.CheckOpenItemLedgerEntriesCZL();
    end;
}