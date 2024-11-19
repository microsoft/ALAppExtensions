codeunit 17118 "Create AU Item"
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
                ValidateRecordFields(Rec, 1893, 1477, '');
            CreateItem.ParisGuestChairBlack():
                ValidateRecordFields(Rec, 365, 284, '');
            CreateItem.AthensMobilePedestal():
                ValidateRecordFields(Rec, 820, 640, '');
            CreateItem.LondonSwivelChairBlue():
                ValidateRecordFields(Rec, 360, 280, '');
            CreateItem.AntwerpConferenceTable():
                ValidateRecordFields(Rec, 1225, 956, '');
            CreateItem.ConferenceBundle16():
                ValidateRecordFields(Rec, 357, 0, '');
            CreateItem.AmsterdamLamp():
                ValidateRecordFields(Rec, 104, 81, '');
            CreateItem.ConferenceBundle18():
                ValidateRecordFields(Rec, 442, 0, '');
            CreateItem.BerlingGuestChairYellow():
                ValidateRecordFields(Rec, 365, 284, '');
            CreateItem.GuestSection1():
                ValidateRecordFields(Rec, 238, 0, '');
            CreateItem.RomeGuestChairGreen():
                ValidateRecordFields(Rec, 365, 284, '');
            CreateItem.TokyoGuestChairBlue():
                ValidateRecordFields(Rec, 365, 284, '');
            CreateItem.ConferenceBundle28():
                ValidateRecordFields(Rec, 442, 0, '');
            CreateItem.MexicoSwivelChairBlack():
                ValidateRecordFields(Rec, 360, 280, '');
            CreateItem.ConferencePackage1():
                ValidateRecordFields(Rec, 647, 0, '');
            CreateItem.MunichSwivelChairYellow():
                ValidateRecordFields(Rec, 360, 280, '');
            CreateItem.MoscowSwivelChairRed():
                ValidateRecordFields(Rec, 360, 280, '');
            CreateItem.SeoulGuestChairRed():
                ValidateRecordFields(Rec, 365, 284, '');
            CreateItem.AtlantaWhiteboardBase():
                ValidateRecordFields(Rec, 2643, 2062, '');
            CreateItem.SydneySwivelChairGreen():
                ValidateRecordFields(Rec, 360, 280, '');
        end;
    end;

    local procedure ValidateRecordFields(var Item: Record Item; UnitPrice: Decimal; UnitCost: Decimal; VATProdPostingGroup: Code[20])
    begin
        Item.Validate("Unit Price", UnitPrice);
        Item.Validate("Unit Cost", UnitCost);
        Item.Validate("VAT Prod. Posting Group", VATProdPostingGroup);
    end;
}