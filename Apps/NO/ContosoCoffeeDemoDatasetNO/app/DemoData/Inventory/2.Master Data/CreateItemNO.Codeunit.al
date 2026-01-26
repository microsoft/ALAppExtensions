// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Inventory;

using Microsoft.Inventory.Item;

codeunit 10665 "Create Item NO"
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
                ValidateRecordFields(Rec, 6329, 4937);
            CreateItem.ParisGuestChairBlack():
                ValidateRecordFields(Rec, 1219, 950);
            CreateItem.AthensMobilePedestal():
                ValidateRecordFields(Rec, 2742, 2139);
            CreateItem.LondonSwivelChairBlue():
                ValidateRecordFields(Rec, 1202, 937);
            CreateItem.AntwerpConferenceTable():
                ValidateRecordFields(Rec, 4097, 3196);
            CreateItem.ConferenceBundle16():
                ValidateRecordFields(Rec, 1194, 0);
            CreateItem.AmsterdamLamp():
                ValidateRecordFields(Rec, 347, 271);
            CreateItem.ConferenceBundle18():
                ValidateRecordFields(Rec, 1479, 0);
            CreateItem.BerlingGuestChairYellow():
                ValidateRecordFields(Rec, 1219, 950);
            CreateItem.GuestSection1():
                ValidateRecordFields(Rec, 796, 0);
            CreateItem.RomeGuestChairGreen():
                ValidateRecordFields(Rec, 1219, 950);
            CreateItem.TokyoGuestChairBlue():
                ValidateRecordFields(Rec, 1219, 950);
            CreateItem.ConferenceBundle28():
                ValidateRecordFields(Rec, 1479, 0);
            CreateItem.MexicoSwivelChairBlack():
                ValidateRecordFields(Rec, 1202, 937);
            CreateItem.ConferencePackage1():
                ValidateRecordFields(Rec, 2162, 0);
            CreateItem.MunichSwivelChairYellow():
                ValidateRecordFields(Rec, 1202, 937);
            CreateItem.MoscowSwivelChairRed():
                ValidateRecordFields(Rec, 1202, 937);
            CreateItem.SeoulGuestChairRed():
                ValidateRecordFields(Rec, 1219, 950);
            CreateItem.AtlantaWhiteboardBase():
                ValidateRecordFields(Rec, 8837, 6892);
            CreateItem.SydneySwivelChairGreen():
                ValidateRecordFields(Rec, 1202, 937);
        end;
    end;

    local procedure ValidateRecordFields(var Item: Record Item; UnitPrice: Decimal; UnitCost: Decimal)
    begin
        Item.Validate("Unit Price", UnitPrice);
        Item.Validate("Unit Cost", UnitCost);
    end;
}
