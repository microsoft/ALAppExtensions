// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Inventory;

using Microsoft.Inventory.Item;

codeunit 11606 "Create CH Item"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::Item, 'OnBeforeOnInsert', '', false, false)]
    local procedure OnBeforeOnInsertItem(var Item: Record Item)
    var
        CreateItem: Codeunit "Create Item";
    begin
        case Item."No." of
            CreateItem.AthensDesk():
                ValidateRecordFields(Item, 1190, 932);
            CreateItem.ParisGuestChairBlack():
                ValidateRecordFields(Item, 230, 179.5);
            CreateItem.AthensMobilePedestal():
                ValidateRecordFields(Item, 520, 404);
            CreateItem.LondonSwivelChairBlue():
                ValidateRecordFields(Item, 230, 177);
            CreateItem.AntwerpConferenceTable():
                ValidateRecordFields(Item, 770, 603.5);
            CreateItem.ConferenceBundle16():
                ValidateRecordFields(Item, 230, 0);
            CreateItem.AmsterdamLamp():
                ValidateRecordFields(Item, 66, 51);
            CreateItem.ConferenceBundle18():
                ValidateRecordFields(Item, 280, 0);
            CreateItem.BerlingGuestChairYellow():
                ValidateRecordFields(Item, 230, 179.5);
            CreateItem.GuestSection1():
                ValidateRecordFields(Item, 150, 0);
            CreateItem.RomeGuestChairGreen():
                ValidateRecordFields(Item, 230, 179.5);
            CreateItem.TokyoGuestChairBlue():
                ValidateRecordFields(Item, 230, 179.5);
            CreateItem.ConferenceBundle28():
                ValidateRecordFields(Item, 280, 0);
            CreateItem.MexicoSwivelChairBlack():
                ValidateRecordFields(Item, 230, 177);
            CreateItem.ConferencePackage1():
                ValidateRecordFields(Item, 410, 0);
            CreateItem.MunichSwivelChairYellow():
                ValidateRecordFields(Item, 230, 177);
            CreateItem.MoscowSwivelChairRed():
                ValidateRecordFields(Item, 230, 177);
            CreateItem.SeoulGuestChairRed():
                ValidateRecordFields(Item, 230, 179.5);
            CreateItem.AtlantaWhiteboardBase():
                ValidateRecordFields(Item, 1670, 1301);
            CreateItem.SydneySwivelChairGreen():
                ValidateRecordFields(Item, 230, 177);
        end;
    end;

    local procedure ValidateRecordFields(var Item: Record Item; UnitPrice: Decimal; UnitCost: Decimal)
    begin
        Item.Validate("Unit Price", UnitPrice);
        Item.Validate("Unit Cost", UnitCost);
    end;
}
