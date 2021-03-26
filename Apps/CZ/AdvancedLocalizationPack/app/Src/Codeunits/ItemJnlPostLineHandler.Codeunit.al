codeunit 31305 "Item Jnl-Post Line Handler CZA"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", 'OnUpdateUnitCostOnBeforeUpdateUnitCost', '', false, false)]
    local procedure SetUpdateSKUOnUpdateUnitCostOnBeforeUpdateUnitCost(ItemJournalLine: Record "Item Journal Line"; ValueEntry: Record "Value Entry"; Item: Record Item; var UpdateSKU: Boolean)
    var
        InventorySetup: Record "Inventory Setup";
    begin
        InventorySetup.Get();
        UpdateSKU := not InventorySetup."Skip Update SKU on Posting CZA";
    end;
}
