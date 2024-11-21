codeunit 11222 "Create Item SE"
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
                ValidateRecordFields(Rec, 6562, 5119);
            CreateItem.ParisGuestChairBlack():
                ValidateRecordFields(Rec, 1264, 985);
            CreateItem.AthensMobilePedestal():
                ValidateRecordFields(Rec, 2843, 2218);
            CreateItem.LondonSwivelChairBlue():
                ValidateRecordFields(Rec, 1246, 971);
            CreateItem.AntwerpConferenceTable():
                ValidateRecordFields(Rec, 4248, 3314);
            CreateItem.ConferenceBundle16():
                ValidateRecordFields(Rec, 1238, 0);
            CreateItem.AmsterdamLamp():
                ValidateRecordFields(Rec, 360, 281);
            CreateItem.ConferenceBundle18():
                ValidateRecordFields(Rec, 1533, 0);
            CreateItem.BerlingGuestChairYellow():
                ValidateRecordFields(Rec, 1264, 985);
            CreateItem.GuestSection1():
                ValidateRecordFields(Rec, 825, 0);
            CreateItem.RomeGuestChairGreen():
                ValidateRecordFields(Rec, 1264, 985);
            CreateItem.TokyoGuestChairBlue():
                ValidateRecordFields(Rec, 1264, 985);
            CreateItem.ConferenceBundle28():
                ValidateRecordFields(Rec, 1533, 0);
            CreateItem.MexicoSwivelChairBlack():
                ValidateRecordFields(Rec, 1246, 971);
            CreateItem.ConferencePackage1():
                ValidateRecordFields(Rec, 2241, 0);
            CreateItem.MunichSwivelChairYellow():
                ValidateRecordFields(Rec, 1246, 971);
            CreateItem.MoscowSwivelChairRed():
                ValidateRecordFields(Rec, 1246, 971);
            CreateItem.SeoulGuestChairRed():
                ValidateRecordFields(Rec, 1264, 985);
            CreateItem.AtlantaWhiteboardBase():
                ValidateRecordFields(Rec, 9162, 7146);
            CreateItem.SydneySwivelChairGreen():
                ValidateRecordFields(Rec, 1246, 971);
        end;
    end;

    local procedure ValidateRecordFields(var Item: Record Item; UnitPrice: Decimal; UnitCost: Decimal)
    begin
        Item.Validate("Unit Price", UnitPrice);
        Item.Validate("Unit Cost", UnitCost);
    end;
}