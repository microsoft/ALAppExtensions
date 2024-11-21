// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Posting;

using Microsoft.Inventory.Item;
using Microsoft.Inventory.Journal;
using Microsoft.Inventory.Ledger;
using Microsoft.Inventory.Setup;
using Microsoft.Manufacturing.Capacity;

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
    begin
        if CalledFromAdjustment then
            exit;
        ItemJnlLine.CheckInventoryPostingGroupCZA();
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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", 'OnInsertCapValueEntryOnAfterUpdateCostAmounts', '', false, false)]
    local procedure AddFieldsOnInsertCapValueEntryOnAfterUpdateCostAmounts(var ValueEntry: Record "Value Entry"; var ItemJournalLine: Record "Item Journal Line")
    begin
        ValueEntry."Source No." := ItemJournalLine."Source No.";
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
        ValueEntry."Source No." := ItemJnlLine."Source No.";
        ValueEntry."Location Code" := ItemJnlLine."Location Code";
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
    local procedure AddFieldsOnInitValueEntryOnAfterAssignFields(var ValueEntry: Record "Value Entry"; ItemJnlLine: Record "Item Journal Line")
    begin
        ValueEntry."Source No." := ItemJnlLine."Source No.";
        ValueEntry."Invoice-to Source No. CZA" := ItemJnlLine."Invoice-to Source No.";
        ValueEntry."Delivery-to Source No. CZA" := ItemJnlLine."Delivery-to Source No. CZA";
        ValueEntry."Currency Code CZA" := ItemJnlLine."Currency Code CZA";
        ValueEntry."Currency Factor CZA" := ItemJnlLine."Currency Factor CZA";
    end;
}
