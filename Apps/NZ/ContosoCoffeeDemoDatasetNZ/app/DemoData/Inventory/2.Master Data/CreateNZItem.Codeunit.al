// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Inventory;

using Microsoft.Inventory.Item;

codeunit 17126 "Create NZ Item"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::Item, 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertItem(var Rec: Record Item)
    var
        CreateItem: Codeunit "Create Item";
    begin
        case Rec."No." of
            CreateItem.AthensDesk():
                ValidateRecordFields(Rec, 2237, 1745);
            CreateItem.ParisGuestChairBlack():
                ValidateRecordFields(Rec, 431, 336);
            CreateItem.AthensMobilePedestal():
                ValidateRecordFields(Rec, 969, 756);
            CreateItem.LondonSwivelChairBlue():
                ValidateRecordFields(Rec, 425, 331);
            CreateItem.AntwerpConferenceTable():
                ValidateRecordFields(Rec, 1448, 1130);
            CreateItem.ConferenceBundle16():
                ValidateRecordFields(Rec, 422, 0);
            CreateItem.AmsterdamLamp():
                ValidateRecordFields(Rec, 123, 96);
            CreateItem.ConferenceBundle18():
                ValidateRecordFields(Rec, 523, 0);
            CreateItem.BerlingGuestChairYellow():
                ValidateRecordFields(Rec, 431, 336);
            CreateItem.GuestSection1():
                ValidateRecordFields(Rec, 281, 0);
            CreateItem.RomeGuestChairGreen():
                ValidateRecordFields(Rec, 431, 336);
            CreateItem.TokyoGuestChairBlue():
                ValidateRecordFields(Rec, 431, 336);
            CreateItem.ConferenceBundle28():
                ValidateRecordFields(Rec, 523, 0);
            CreateItem.MexicoSwivelChairBlack():
                ValidateRecordFields(Rec, 425, 331);
            CreateItem.ConferencePackage1():
                ValidateRecordFields(Rec, 764, 0);
            CreateItem.MunichSwivelChairYellow():
                ValidateRecordFields(Rec, 425, 331);
            CreateItem.MoscowSwivelChairRed():
                ValidateRecordFields(Rec, 425, 331);
            CreateItem.SeoulGuestChairRed():
                ValidateRecordFields(Rec, 431, 336);
            CreateItem.AtlantaWhiteboardBase():
                ValidateRecordFields(Rec, 3123, 2436);
            CreateItem.SydneySwivelChairGreen():
                ValidateRecordFields(Rec, 425, 331);
        end;
    end;

    local procedure ValidateRecordFields(var Item: Record Item; UnitPrice: Decimal; UnitCost: Decimal)
    begin
        Item.Validate("Unit Price", UnitPrice);
        Item.Validate("Unit Cost", UnitCost);
    end;
}
