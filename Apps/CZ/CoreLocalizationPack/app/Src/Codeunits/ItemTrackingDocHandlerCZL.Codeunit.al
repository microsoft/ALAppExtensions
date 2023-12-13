// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Tracking;

using Microsoft.Inventory.Ledger;

codeunit 31475 "Item Tracking Doc. Handler CZL"
{
    EventSubscriberInstance = Manual;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Tracking Doc. Management", 'OnAfterFillTrackingSpecBufferFromItemLedgEntry', '', false, false)]
    local procedure FillExpirationDateOnAfterFillTrackingSpecBufferFromItemLedgEntry(var TempTrackingSpecification: Record "Tracking Specification" temporary; var TempItemLedgerEntry: Record "Item Ledger Entry" temporary)
    var
        ItemTrackingSetup: Record "Item Tracking Setup";
        ItemTrackingManagement: Codeunit "Item Tracking Management";
        EntriesExist: Boolean;
    begin
        ItemTrackingSetup.CopyTrackingFromItemLedgerEntry(TempItemLedgerEntry);
        TempTrackingSpecification."Expiration Date" := ItemTrackingManagement.ExistingExpirationDate(TempItemLedgerEntry."Item No.", TempItemLedgerEntry."Variant Code", ItemTrackingSetup, false, EntriesExist);
        TempTrackingSpecification.Modify();
    end;
}
