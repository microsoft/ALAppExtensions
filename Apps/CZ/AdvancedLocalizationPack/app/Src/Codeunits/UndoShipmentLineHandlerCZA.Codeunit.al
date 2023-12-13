﻿// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.History;

using Microsoft.Inventory.Item;
using Microsoft.Inventory.Journal;

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
}
