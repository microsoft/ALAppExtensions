codeunit 14624 "Create Item IS"
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
                ValidateRecordFields(Rec, 65260, 50900);
            CreateItem.ParisGuestChairBlack():
                ValidateRecordFields(Rec, 12570, 9800);
            CreateItem.AthensMobilePedestal():
                ValidateRecordFields(Rec, 28270, 22050);
            CreateItem.LondonSwivelChairBlue():
                ValidateRecordFields(Rec, 12390, 9660);
            CreateItem.AntwerpConferenceTable():
                ValidateRecordFields(Rec, 42240, 32960);
            CreateItem.ConferenceBundle16():
                ValidateRecordFields(Rec, 12310, 0);
            CreateItem.AmsterdamLamp():
                ValidateRecordFields(Rec, 3580, 2790);
            CreateItem.ConferenceBundle18():
                ValidateRecordFields(Rec, 15250, 0);
            CreateItem.BerlingGuestChairYellow():
                ValidateRecordFields(Rec, 12570, 9800);
            CreateItem.GuestSection1():
                ValidateRecordFields(Rec, 8200, 0);
            CreateItem.RomeGuestChairGreen():
                ValidateRecordFields(Rec, 12570, 9800);
            CreateItem.TokyoGuestChairBlue():
                ValidateRecordFields(Rec, 12570, 9800);
            CreateItem.ConferenceBundle28():
                ValidateRecordFields(Rec, 15250, 0);
            CreateItem.MexicoSwivelChairBlack():
                ValidateRecordFields(Rec, 12390, 9660);
            CreateItem.ConferencePackage1():
                ValidateRecordFields(Rec, 22290, 0);
            CreateItem.MunichSwivelChairYellow():
                ValidateRecordFields(Rec, 12390, 9660);
            CreateItem.MoscowSwivelChairRed():
                ValidateRecordFields(Rec, 12390, 9660);
            CreateItem.SeoulGuestChairRed():
                ValidateRecordFields(Rec, 12570, 9800);
            CreateItem.AtlantaWhiteboardBase():
                ValidateRecordFields(Rec, 91120, 71070);
            CreateItem.SydneySwivelChairGreen():
                ValidateRecordFields(Rec, 12390, 9660);
        end;
    end;

    local procedure ValidateRecordFields(var Item: Record Item; UnitPrice: Decimal; UnitCost: Decimal)
    begin
        Item.Validate("Unit Price", UnitPrice);
        Item.Validate("Unit Cost", UnitCost);
    end;
}