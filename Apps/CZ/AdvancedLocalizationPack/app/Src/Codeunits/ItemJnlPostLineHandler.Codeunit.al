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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", 'OnPostItemOnBeforeSetAverageTransfer', '', false, false)]
    local procedure CheckInventoryPostingGroupOnPostItemOnBeforeSetAverageTransfer(var ItemJnlLine: Record "Item Journal Line"; CalledFromAdjustment: Boolean)
    var
        Item: Record Item;
    begin
        if ItemJnlLine."Item No." = '' then
            exit;

        Item.Get(ItemJnlLine."Item No.");
        if not (ItemJnlLine."Inventory Posting Group" = '') and (Item.Type = Item.Type::Inventory) then
            if not CalledFromAdjustment and (Item.Type = Item.Type::Inventory) then
                ItemJnlLine.TestField("Inventory Posting Group", Item."Inventory Posting Group");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", 'OnPostFlushedConsumpOnAfterCopyProdOrderFieldsToItemJnlLine', '', false, false)]
    local procedure UpdateGenBusPostingGroupOnPostFlushedConsumpOnAfterCopyProdOrderFieldsToItemJnlLine(var ItemJournalLine: Record "Item Journal Line"; var OldItemJournalLine: Record "Item Journal Line")
    begin
        ItemJournalLine."Gen. Bus. Posting Group" := OldItemJournalLine."Gen. Bus. Posting Group";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", 'OnAfterSetupSplitJnlLine', '', false, false)]
    local procedure PostItemJnlLineOnAfterSetupSplitJnlLine(var PostItemJnlLine: Boolean; var ItemJnlLineOrigin: Record "Item Journal Line")
    begin
        if (ItemJnlLineOrigin."Entry Type" = ItemJnlLineOrigin."Entry Type"::Transfer) and (ItemJnlLineOrigin."Invoice No." = 'xSetExtLotSN') then begin
            ItemJnlLineOrigin."Invoice No." := '';
            PostItemJnlLine := true;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", 'OnBeforeTrackingSpecificationMissingErr', '', false, false)]
    local procedure OnBeforeTrackingSpecificationMissingErr(var IsHandled: Boolean; ItemJournalLine: Record "Item Journal Line")
    begin
        if (ItemJournalLine."Entry Type" = ItemJournalLine."Entry Type"::Transfer) and (ItemJournalLine."Invoice No." = 'xSetExtLotSN') then begin
            ItemJournalLine."Invoice No." := '';
            IsHandled := true;
        end;
    end;
}
