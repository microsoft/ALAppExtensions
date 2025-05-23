// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Inventory;

using Microsoft.Inventory.Item;
using Microsoft.DemoData.Finance;

codeunit 19030 "Create IN Item"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::Item, 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertItem(var Rec: Record Item)
    var
        CreateItem: Codeunit "Create Item";
        CreateVATPostingGroups: Codeunit "Create VAT Posting Groups";
        CreateINGSTGroup: Codeunit "Create IN GST Group";
        CreateINHSNSAC: Codeunit "Create IN HSN/SAC";
    begin
        case Rec."No." of
            CreateItem.AthensDesk():
                ValidateRecordFields(Rec, 45090, 35170, CreateVATPostingGroups.Standard(), '', '');
            CreateItem.ParisGuestChairBlack():
                ValidateRecordFields(Rec, 8690, 6770, CreateVATPostingGroups.Standard(), '', '');
            CreateItem.AthensMobilePedestal():
                ValidateRecordFields(Rec, 19540, 15240, CreateVATPostingGroups.Standard(), '', '');
            CreateItem.LondonSwivelChairBlue():
                ValidateRecordFields(Rec, 8560, 6669.99, CreateVATPostingGroups.Standard(), '', '');
            CreateItem.AntwerpConferenceTable():
                ValidateRecordFields(Rec, 29190, 22770.011, CreateVATPostingGroups.Standard(), '', '');
            CreateItem.ConferenceBundle16():
                ValidateRecordFields(Rec, 8510, 0, CreateVATPostingGroups.Standard(), '', '');
            CreateItem.AmsterdamLamp():
                ValidateRecordFields(Rec, 2470, 1930.003, CreateVATPostingGroups.Standard(), '', '');
            CreateItem.ConferenceBundle18():
                ValidateRecordFields(Rec, 10540, 0, CreateVATPostingGroups.Standard(), '', '');
            CreateItem.BerlingGuestChairYellow():
                ValidateRecordFields(Rec, 8690, 6769.984, CreateVATPostingGroups.Zero(), CreateINGSTGroup.GSTGroup0989(), CreateINHSNSAC.HSNSACCode0989001());
            CreateItem.GuestSection1():
                ValidateRecordFields(Rec, 5670, 0, CreateVATPostingGroups.Standard(), '', '');
            CreateItem.RomeGuestChairGreen():
                ValidateRecordFields(Rec, 8690, 6770.07, CreateVATPostingGroups.Zero(), '', '');
            CreateItem.TokyoGuestChairBlue():
                ValidateRecordFields(Rec, 8690, 6769.987, CreateVATPostingGroups.Zero(), '', '');
            CreateItem.ConferenceBundle28():
                ValidateRecordFields(Rec, 10540, 0, CreateVATPostingGroups.Standard(), '', '');
            CreateItem.MexicoSwivelChairBlack():
                ValidateRecordFields(Rec, 8560, 6670.026, CreateVATPostingGroups.Zero(), CreateINGSTGroup.GSTGroup0988(), CreateINHSNSAC.HSNSACCode0988001());
            CreateItem.ConferencePackage1():
                ValidateRecordFields(Rec, 15400, 0, CreateVATPostingGroups.Standard(), '', '');
            CreateItem.MunichSwivelChairYellow():
                ValidateRecordFields(Rec, 8560, 6670, CreateVATPostingGroups.Standard(), '', '');
            CreateItem.MoscowSwivelChairRed():
                ValidateRecordFields(Rec, 8560, 6670, CreateVATPostingGroups.Standard(), '', '');
            CreateItem.SeoulGuestChairRed():
                ValidateRecordFields(Rec, 8690, 6769.954, CreateVATPostingGroups.Zero(), CreateINGSTGroup.GSTGroup0989(), CreateINHSNSAC.HSNSACCode0989001());
            CreateItem.AtlantaWhiteboardBase():
                ValidateRecordFields(Rec, 62960, 49109.978, CreateVATPostingGroups.Standard(), '', '');
            CreateItem.SydneySwivelChairGreen():
                ValidateRecordFields(Rec, 8560, 6670.005, CreateVATPostingGroups.Standard(), '', '');
        end;
    end;

    local procedure ValidateRecordFields(var Item: Record Item; UnitPrice: Decimal; UnitCost: Decimal; VATProdPostingGroup: Code[20]; GSTGroupCode: Code[10]; HSNSACCode: Code[10])
    begin
        Item.Validate("Unit Price", UnitPrice);
        Item.Validate("Unit Cost", UnitCost);
        Item.Validate("VAT Prod. Posting Group", VATProdPostingGroup);
        Item.Validate("GST Group Code", GSTGroupCode);
        Item.Validate("HSN/SAC Code", HSNSACCode);
    end;
}
