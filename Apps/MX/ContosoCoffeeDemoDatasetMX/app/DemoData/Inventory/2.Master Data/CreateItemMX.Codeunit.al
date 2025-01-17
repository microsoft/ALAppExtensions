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
        CreateVatPostingGroupsMX: Codeunit "Create Vat Posting Groups MX";
    begin
        case Rec."No." of
            CreateItem.AthensDesk():
                ValidateRecordFields(Rec, 9007, 7026, CreateVatPostingGroupsMX.VAT16());
            CreateItem.ParisGuestChairBlack():
                ValidateRecordFields(Rec, 1735, 1353, CreateVatPostingGroupsMX.VAT16());
            CreateItem.AthensMobilePedestal():
                ValidateRecordFields(Rec, 3903, 3044, CreateVatPostingGroupsMX.VAT16());
            CreateItem.LondonSwivelChairBlue():
                ValidateRecordFields(Rec, 1711, 1333, CreateVatPostingGroupsMX.VAT16());
            CreateItem.AntwerpConferenceTable():
                ValidateRecordFields(Rec, 5830, 4549, CreateVatPostingGroupsMX.VAT16());
            CreateItem.ConferenceBundle16():
                ValidateRecordFields(Rec, 1699, 0, CreateVatPostingGroupsMX.VAT16());
            CreateItem.AmsterdamLamp():
                ValidateRecordFields(Rec, 494, 386, CreateVatPostingGroupsMX.VAT16());
            CreateItem.ConferenceBundle18():
                ValidateRecordFields(Rec, 2104, 0, CreateVatPostingGroupsMX.VAT16());
            CreateItem.BerlingGuestChairYellow():
                ValidateRecordFields(Rec, 1735, 1353, CreateVatPostingGroupsMX.VAT16());
            CreateItem.GuestSection1():
                ValidateRecordFields(Rec, 1132, 0, CreateVatPostingGroupsMX.VAT16());
            CreateItem.RomeGuestChairGreen():
                ValidateRecordFields(Rec, 1735, 1353, CreateVatPostingGroupsMX.VAT16());
            CreateItem.TokyoGuestChairBlue():
                ValidateRecordFields(Rec, 1735, 1353, CreateVatPostingGroupsMX.VAT16());
            CreateItem.ConferenceBundle28():
                ValidateRecordFields(Rec, 2104, 0, CreateVatPostingGroupsMX.VAT16());
            CreateItem.MexicoSwivelChairBlack():
                ValidateRecordFields(Rec, 1711, 1333, CreateVatPostingGroupsMX.VAT16());
            CreateItem.ConferencePackage1():
                ValidateRecordFields(Rec, 3076, 0, CreateVatPostingGroupsMX.VAT16());
            CreateItem.MunichSwivelChairYellow():
                ValidateRecordFields(Rec, 1711, 1333, CreateVatPostingGroupsMX.VAT16());
            CreateItem.MoscowSwivelChairRed():
                ValidateRecordFields(Rec, 1711, 1333, CreateVatPostingGroupsMX.VAT16());
            CreateItem.SeoulGuestChairRed():
                ValidateRecordFields(Rec, 1735, 1353, CreateVatPostingGroupsMX.VAT16());
            CreateItem.AtlantaWhiteboardBase():
                ValidateRecordFields(Rec, 12576, 9809, CreateVatPostingGroupsMX.VAT16());
            CreateItem.SydneySwivelChairGreen():
                ValidateRecordFields(Rec, 1711, 1333, CreateVatPostingGroupsMX.VAT16());
        end;
    end;

    local procedure ValidateRecordFields(var Item: Record Item; UnitPrice: Decimal; UnitCost: Decimal; VATProdPostingGroupCode: Code[20])
    begin
        Item.Validate("Unit Price", UnitPrice);
        Item.Validate("Unit Cost", UnitCost);
        Item.Validate("VAT Prod. Posting Group", VATProdPostingGroupCode);
    end;
}