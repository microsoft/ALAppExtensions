// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Inventory;

using Microsoft.Inventory.Item;

codeunit 14124 "Create Item MX"
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
                ValidateRecordFields(Rec, 9007, 7026);
            CreateItem.ParisGuestChairBlack():
                ValidateRecordFields(Rec, 1735, 1353);
            CreateItem.AthensMobilePedestal():
                ValidateRecordFields(Rec, 3903, 3044);
            CreateItem.LondonSwivelChairBlue():
                ValidateRecordFields(Rec, 1711, 1333);
            CreateItem.AntwerpConferenceTable():
                ValidateRecordFields(Rec, 5830, 4549);
            CreateItem.ConferenceBundle16():
                ValidateRecordFields(Rec, 1699, 0);
            CreateItem.AmsterdamLamp():
                ValidateRecordFields(Rec, 494, 386);
            CreateItem.ConferenceBundle18():
                ValidateRecordFields(Rec, 2104, 0);
            CreateItem.BerlingGuestChairYellow():
                ValidateRecordFields(Rec, 1735, 1353);
            CreateItem.GuestSection1():
                ValidateRecordFields(Rec, 1132, 0);
            CreateItem.RomeGuestChairGreen():
                ValidateRecordFields(Rec, 1735, 1353);
            CreateItem.TokyoGuestChairBlue():
                ValidateRecordFields(Rec, 1735, 1353);
            CreateItem.ConferenceBundle28():
                ValidateRecordFields(Rec, 2104, 0);
            CreateItem.MexicoSwivelChairBlack():
                ValidateRecordFields(Rec, 1711, 1333);
            CreateItem.ConferencePackage1():
                ValidateRecordFields(Rec, 3076, 0);
            CreateItem.MunichSwivelChairYellow():
                ValidateRecordFields(Rec, 1711, 1333);
            CreateItem.MoscowSwivelChairRed():
                ValidateRecordFields(Rec, 1711, 1333);
            CreateItem.SeoulGuestChairRed():
                ValidateRecordFields(Rec, 1735, 1353);
            CreateItem.AtlantaWhiteboardBase():
                ValidateRecordFields(Rec, 12576, 9809);
            CreateItem.SydneySwivelChairGreen():
                ValidateRecordFields(Rec, 1711, 1333);
        end;
    end;

    local procedure ValidateRecordFields(var Item: Record Item; UnitPrice: Decimal; UnitCost: Decimal)
    begin
        Item.Validate("Unit Price", UnitPrice);
        Item.Validate("Unit Cost", UnitCost);
    end;
}
