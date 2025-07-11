// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Ledger;

codeunit 31125 "Item Ledger Entry-Edit CZL"
{
    Permissions = TableData "Item Ledger Entry" = m;
    TableNo = "Item Ledger Entry";

    trigger OnRun()
    begin
        ItemLedgerEntry := Rec;
        ItemLedgerEntry.LockTable();
        ItemLedgerEntry.Find();
        OnRunOnBeforeItemLedgEntryModify(ItemLedgerEntry, Rec);
        ItemLedgerEntry.TestField("Entry No.", Rec."Entry No.");
        ItemLedgerEntry.Modify();
        OnRunOnAfterItemLedgEntryModify(ItemLedgerEntry);
        Rec := ItemLedgerEntry;
    end;

    var
        ItemLedgerEntry: Record "Item Ledger Entry";

    [IntegrationEvent(false, false)]
    local procedure OnRunOnBeforeItemLedgEntryModify(var ItemLedgerEntry: Record "Item Ledger Entry"; FromItemLedgerEntry: Record "Item Ledger Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnRunOnAfterItemLedgEntryModify(var ItemLedgerEntry: Record "Item Ledger Entry")
    begin
    end;
}

