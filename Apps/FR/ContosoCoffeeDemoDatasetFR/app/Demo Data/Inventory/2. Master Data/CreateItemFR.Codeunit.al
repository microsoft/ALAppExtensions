codeunit 10879 "Create Item FR"
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
                ValidateRecordFields(Rec, 1005.8, 784.6);
            CreateItem.ParisGuestChairBlack():
                ValidateRecordFields(Rec, 193.7, 151.1);
            CreateItem.AthensMobilePedestal():
                ValidateRecordFields(Rec, 435.8, 339.9);
            CreateItem.LondonSwivelChairBlue():
                ValidateRecordFields(Rec, 191, 148.9);
            CreateItem.AntwerpConferenceTable():
                ValidateRecordFields(Rec, 651.1, 508);
            CreateItem.ConferenceBundle16():
                ValidateRecordFields(Rec, 189.8, 0);
            CreateItem.AmsterdamLamp():
                ValidateRecordFields(Rec, 55.2, 43.1);
            CreateItem.ConferenceBundle18():
                ValidateRecordFields(Rec, 235, 0);
            CreateItem.BerlingGuestChairYellow():
                ValidateRecordFields(Rec, 193.7, 151.1);
            CreateItem.GuestSection1():
                ValidateRecordFields(Rec, 126.4, 0);
            CreateItem.RomeGuestChairGreen():
                ValidateRecordFields(Rec, 193.7, 151.1);
            CreateItem.TokyoGuestChairBlue():
                ValidateRecordFields(Rec, 193.7, 151.1);
            CreateItem.ConferenceBundle28():
                ValidateRecordFields(Rec, 235, 0);
            CreateItem.MexicoSwivelChairBlack():
                ValidateRecordFields(Rec, 191, 148.9);
            CreateItem.ConferencePackage1():
                ValidateRecordFields(Rec, 343.5, 0);
            CreateItem.MunichSwivelChairYellow():
                ValidateRecordFields(Rec, 191, 148.9);
            CreateItem.MoscowSwivelChairRed():
                ValidateRecordFields(Rec, 191, 148.9);
            CreateItem.SeoulGuestChairRed():
                ValidateRecordFields(Rec, 193.7, 151.1);
            CreateItem.AtlantaWhiteboardBase():
                ValidateRecordFields(Rec, 1404.3, 1095.3);
            CreateItem.SydneySwivelChairGreen():
                ValidateRecordFields(Rec, 191, 148.9);
        end;
    end;

    local procedure ValidateRecordFields(var Item: Record Item; UnitPrice: Decimal; UnitCost: Decimal)
    begin
        Item.Validate("Unit Price", UnitPrice);
        Item.Validate("Unit Cost", UnitCost);
    end;
}