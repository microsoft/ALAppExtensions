// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Inventory;

using Microsoft.Inventory.Intrastat;
using Microsoft.DemoData.Foundation;
using Microsoft.DemoData.Intrastat;
using Microsoft.Inventory.Item;

codeunit 11708 "Create Intrastat Item CZ"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::Item, 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertItem(var Rec: Record Item)
    var
        CreateItem: Codeunit "Create Item";
        CreateCountryRegion: Codeunit "Create Country/Region";
        CreateTariffNumberCZ: Codeunit "Create Tariff Number CZ";
    begin
        if Rec."No." <> CreateItem.AthensDesk() then
            exit;

        ValidateItem(Rec, CreateTariffNumberCZ.No94031098(), CreateCountryRegion.SK());
    end;

    local procedure ValidateItem(var Item: Record Item; TariffNo: Code[10]; CountryOfOriginCode: Code[10])
    var
        TariffNumber: Record "Tariff Number";
    begin
        if not TariffNumber.Get(TariffNo) then
            exit;

        Item.Validate("Tariff No.", TariffNo);
        Item.Validate("Country/Region of Origin Code", CountryOfOriginCode);
    end;
}
