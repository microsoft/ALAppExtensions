// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Tracking;

using Microsoft.Inventory.Item;
using Microsoft.Inventory.Ledger;
using Microsoft.Inventory.Transfer;

codeunit 31430 "Item Tracking Line Handler CZA"
{
    [EventSubscriber(ObjectType::Page, Page::"Item Tracking Lines", 'OnBeforeCollectTempTrackingSpecificationInsert', '', false, false)]
    local procedure UndoItemEntryRelationOnBeforeCollectTempTrackingSpecificationInsert(var TempTrackingSpecification: Record "Tracking Specification"; ItemLedgerEntry: Record "Item Ledger Entry"; var TrackingSpecification: Record "Tracking Specification")
    var
        ItemEntryRelation: Record "Item Entry Relation";
    begin
        if TrackingSpecification."Source Type" <> Database::"Transfer Line" then
            exit;

        if ItemEntryRelation.Get(ItemLedgerEntry."Entry No.") then
            if ItemEntryRelation."Undo CZA" then begin
                TempTrackingSpecification."Quantity (Base)" := 0;
                TempTrackingSpecification."Quantity Handled (Base)" := 0;
                TempTrackingSpecification."Quantity Invoiced (Base)" := 0;
                TempTrackingSpecification.InitQtyToShip();
            end;
    end;
}
