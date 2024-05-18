// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Posting;

using Microsoft.Inventory.Ledger;
using Microsoft.Inventory.Setup;

#pragma warning disable AL0432
codeunit 31047 "Item Jnl-Post Line Handler CZL"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", 'OnBeforeInsertApplEntry', '', false, false)]
    local procedure DateOrderInvtCZLChangeOnBeforeInsertApplEntry(Quantity: Decimal; InboundItemEntry: Integer; OutboundItemEntry: Integer; PostingDate: Date);
    var
        InventorySetup: Record "Inventory Setup";
        DateOrderItemLedgerEntry: Record "Item Ledger Entry";
        WrongItemEntryApplicationErr: Label 'Wrong Item Ledger Entry Application (Date Order)\\%1 %2 in %3 %7 %4\must not be less then\%1 %5 in %3 %7 %6.', Comment = '%1 = Posting Date FieldCaption, %2 = Outbound Entry Posting Date, %3 = TabeCaption, %4 = Outbound Entry No., %5 = Inbound Entry Posting Date, %6 = Inbound Entry No., %7 = Entry No FieldCaption';
    begin
        if Quantity >= 0 then
            exit;
        InventorySetup.Get();
        if not InventorySetup."Date Order Invt. Change CZL" then
            exit;

        if DateOrderItemLedgerEntry.Get(InboundItemEntry) then begin
            if DateOrderItemLedgerEntry."Posting Date" > PostingDate then
                Error(WrongItemEntryApplicationErr, DateOrderItemLedgerEntry.FieldCaption("Posting Date"), PostingDate, DateOrderItemLedgerEntry.TableCaption,
                  OutboundItemEntry, DateOrderItemLedgerEntry."Posting Date", InboundItemEntry, DateOrderItemLedgerEntry.FieldCaption("Entry No."));
        end else begin
            DateOrderItemLedgerEntry.Get(OutboundItemEntry);
            if DateOrderItemLedgerEntry."Posting Date" < PostingDate then
                Error(WrongItemEntryApplicationErr, DateOrderItemLedgerEntry.FieldCaption("Posting Date"), DateOrderItemLedgerEntry."Posting Date", DateOrderItemLedgerEntry.TableCaption,
                  OutboundItemEntry, PostingDate, InboundItemEntry, DateOrderItemLedgerEntry.FieldCaption("Entry No."));
        end;

    end;
}
