// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Inventory;

using Microsoft.Inventory.Item;

codeunit 11094 "Create DE Item"
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
                ValidateItem(Item, 1005.8, 784.6);
            CreateItem.ParisGuestChairBlack():
                ValidateItem(Item, 193.7, 151.1);
            CreateItem.AthensMobilePedestal():
                ValidateItem(Item, 435.8, 339.9);
            CreateItem.LondonSwivelChairBlue():
                ValidateItem(Item, 191, 148.9);
            CreateItem.AntwerpConferenceTable():
                ValidateItem(Item, 651.1, 508);
            CreateItem.ConferenceBundle16():
                ValidateItem(Item, 189.8, 0);
            CreateItem.AmsterdamLamp():
                ValidateItem(Item, 55.2, 43.1);
            CreateItem.ConferenceBundle18():
                ValidateItem(Item, 235, 0);
            CreateItem.BerlingGuestChairYellow():
                ValidateItem(Item, 193.7, 151.1);
            CreateItem.GuestSection1():
                ValidateItem(Item, 126.4, 0);
            CreateItem.RomeGuestChairGreen():
                ValidateItem(Item, 193.7, 151.1);
            CreateItem.TokyoGuestChairBlue():
                ValidateItem(Item, 193.7, 151.1);
            CreateItem.ConferenceBundle28():
                ValidateItem(Item, 235, 0);
            CreateItem.MexicoSwivelChairBlack():
                ValidateItem(Item, 191, 148.9);
            CreateItem.ConferencePackage1():
                ValidateItem(Item, 343.5, 0);
            CreateItem.MunichSwivelChairYellow():
                ValidateItem(Item, 191, 148.9);
            CreateItem.MoscowSwivelChairRed():
                ValidateItem(Item, 191, 148.9);
            CreateItem.SeoulGuestChairRed():
                ValidateItem(Item, 193.7, 151.1);
            CreateItem.AtlantaWhiteboardBase():
                ValidateItem(Item, 1404.3, 1095.3);
            CreateItem.SydneySwivelChairGreen():
                ValidateItem(Item, 191, 148.9);
        end;
    end;

    local procedure ValidateItem(var Item: Record Item; UnitPrice: Decimal; UnitCost: Decimal)
    begin
        Item.Validate("Unit Price", UnitPrice);
        Item.Validate("Unit Cost", UnitCost);
    end;
}
