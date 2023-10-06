// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.ReturnSettlement;

using Microsoft.Finance.GST.Base;
using Microsoft.Finance.GST.StockTransfer;
using Microsoft.Inventory.Ledger;

codeunit 18321 "GST Adj. Journal Subscribers"
{
    local procedure UpdateGSTTrackingEntryFromPurchase(ValueEntry: Record "Value Entry")
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        GSTTrackingEntry: Record "GST Tracking Entry";
        GSTPostingManagement: Codeunit "GST Posting Management";
        OrignalDocType: Enum "Original Doc Type";
    begin
        if (ValueEntry."Item Ledger Entry Type" <> ValueEntry."Item Ledger Entry Type"::Purchase) or (ValueEntry."Entry Type" <> ValueEntry."Entry Type"::"Direct Cost") then
            exit;

        if not (ValueEntry."Document Type" in [ValueEntry."Document Type"::"Purchase Invoice", ValueEntry."Document Type"::"Purchase Credit Memo"]) then
            exit;

        if (ValueEntry."Item Ledger Entry No." = 0) or (ValueEntry."Item Ledger Entry Quantity" = 0) then
            exit;

        case ValueEntry."Document Type" of
            ValueEntry."Document Type"::"Purchase Invoice":
                OrignalDocType := OrignalDocType::Invoice;
            ValueEntry."Document Type"::"Purchase Credit Memo":
                OrignalDocType := OrignalDocType::"Credit Memo";
        end;

        if not ItemLedgerEntry.Get(ValueEntry."Item Ledger Entry No.") then
            exit;

        GSTTrackingEntry.Init();
        GSTTrackingEntry."Entry No." := 0;
        GSTTrackingEntry."From Entry No." := 0;
        GSTTrackingEntry."From To No." := 0;
        GSTTrackingEntry."Item Ledger Entry No." := ItemLedgerEntry."Entry No.";
        GSTTrackingEntry.Quantity := ItemLedgerEntry.Quantity;
        GSTTrackingEntry."Remaining Quantity" := ItemLedgerEntry."Remaining Quantity";
        GSTTrackingEntry.Insert(true);

        GSTPostingManagement.SetGSTTrackingEntryNo(GSTTrackingEntry."Entry No.");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Value Entry", 'OnAfterInsertEvent', '', false, false)]
    local procedure OnAfterInsertValueEntry(var Rec: Record "Value Entry"; RunTrigger: Boolean)
    begin
        UpdateGSTTrackingEntryFromPurchase(Rec);
    end;
}
