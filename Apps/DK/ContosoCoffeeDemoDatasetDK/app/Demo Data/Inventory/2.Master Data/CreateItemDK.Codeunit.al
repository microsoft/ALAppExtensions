codeunit 13729 "Create Item DK"
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
                ValidateRecordFields(Rec, 5560, 4337);
            CreateItem.ParisGuestChairBlack():
                ValidateRecordFields(Rec, 1071, 835);
            CreateItem.AthensMobilePedestal():
                ValidateRecordFields(Rec, 2409, 1879);
            CreateItem.LondonSwivelChairBlue():
                ValidateRecordFields(Rec, 1056, 823);
            CreateItem.AntwerpConferenceTable():
                ValidateRecordFields(Rec, 3599, 2808);
            CreateItem.ConferenceBundle16():
                ValidateRecordFields(Rec, 1049, 0);
            CreateItem.AmsterdamLamp():
                ValidateRecordFields(Rec, 305, 238);
            CreateItem.ConferenceBundle18():
                ValidateRecordFields(Rec, 1299, 0);
            CreateItem.BerlingGuestChairYellow():
                ValidateRecordFields(Rec, 1071, 835);
            CreateItem.GuestSection1():
                ValidateRecordFields(Rec, 699, 0);
            CreateItem.RomeGuestChairGreen():
                ValidateRecordFields(Rec, 1071, 835);
            CreateItem.TokyoGuestChairBlue():
                ValidateRecordFields(Rec, 1071, 835);
            CreateItem.ConferenceBundle28():
                ValidateRecordFields(Rec, 1299, 0);
            CreateItem.MexicoSwivelChairBlack():
                ValidateRecordFields(Rec, 1056, 823);
            CreateItem.ConferencePackage1():
                ValidateRecordFields(Rec, 1899, 0);
            CreateItem.MunichSwivelChairYellow():
                ValidateRecordFields(Rec, 1056, 823);
            CreateItem.MoscowSwivelChairRed():
                ValidateRecordFields(Rec, 1056, 823);
            CreateItem.SeoulGuestChairRed():
                ValidateRecordFields(Rec, 1071, 835);
            CreateItem.AtlantaWhiteboardBase():
                ValidateRecordFields(Rec, 7763, 6055);
            CreateItem.SydneySwivelChairGreen():
                ValidateRecordFields(Rec, 1056, 823);
        end;
    end;

    local procedure ValidateRecordFields(var Item: Record Item; UnitPrice: Decimal; UnitCost: Decimal)
    begin
        Item.Validate("Unit Price", UnitPrice);
        Item.Validate("Unit Cost", UnitCost);
    end;
}