// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Inventory;

using Microsoft.Inventory.Item;

codeunit 31338 "Create Item CZ"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::Item, 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertGenJournalLine(var Rec: Record Item)
    var
        CreateCurrencyExRateCZ: Codeunit "Create Currency Ex. Rate CZ";
    begin
        ValidateRecordFields(Rec,
            Round(Rec."Unit Cost" / CreateCurrencyExRateCZ.GetLocalCurrencyFactor(), 1),
            Round(Rec."Unit Price" / CreateCurrencyExRateCZ.GetLocalCurrencyFactor(), 1));
    end;

    local procedure ValidateRecordFields(var Item: Record Item; UnitCost: Decimal; UnitPrice: Decimal)
    begin
        Item.Validate("Unit Cost", UnitCost);
        Item.Validate("Unit Price", UnitPrice);
    end;
}