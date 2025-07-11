// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Item;

codeunit 11777 "Item Handler CZL"
{
    [EventSubscriber(ObjectType::Table, Database::Item, 'OnAfterValidateEvent', 'Inventory Posting Group', false, false)]
    local procedure CheckChangeInventoryPostingGroupOnAfterInventoryPostingGroupValidate(Rec: Record Item)
    begin
        Rec.CheckOpenItemLedgerEntriesCZL();
    end;
}
