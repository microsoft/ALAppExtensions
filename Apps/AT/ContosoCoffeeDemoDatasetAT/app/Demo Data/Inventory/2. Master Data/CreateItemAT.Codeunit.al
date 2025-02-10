codeunit 11164 "Create Item AT"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::Item, 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertItem(var Rec: Record Item)
    var
        CreateItem: Codeunit "Create Item";
        CreateVatPostingGrpAT: Codeunit "Create VAT Posting Group AT";
    begin

        case Rec."No." of
            CreateItem.AthensDesk():
                ValidateRecordFields(Rec, 1005.8, 784.6, CreateVatPostingGrpAT.VAT20());
            CreateItem.ParisGuestChairBlack():
                ValidateRecordFields(Rec, 193.7, 151.1, CreateVatPostingGrpAT.VAT20());
            CreateItem.AthensMobilePedestal():
                ValidateRecordFields(Rec, 435.8, 339.9, CreateVatPostingGrpAT.VAT20());
            CreateItem.LondonSwivelChairBlue():
                ValidateRecordFields(Rec, 191, 148.9, CreateVatPostingGrpAT.VAT20());
            CreateItem.AntwerpConferenceTable():
                ValidateRecordFields(Rec, 651.1, 508, CreateVatPostingGrpAT.VAT20());
            CreateItem.ConferenceBundle16():
                ValidateRecordFields(Rec, 189.8, 0, CreateVatPostingGrpAT.VAT20());
            CreateItem.AmsterdamLamp():
                ValidateRecordFields(Rec, 55.2, 43.1, CreateVatPostingGrpAT.VAT20());
            CreateItem.ConferenceBundle18():
                ValidateRecordFields(Rec, 235, 0, CreateVatPostingGrpAT.VAT20());
            CreateItem.BerlingGuestChairYellow():
                ValidateRecordFields(Rec, 193.7, 151.1, CreateVatPostingGrpAT.VAT20());
            CreateItem.GuestSection1():
                ValidateRecordFields(Rec, 126.4, 0, CreateVatPostingGrpAT.VAT20());
            CreateItem.RomeGuestChairGreen():
                ValidateRecordFields(Rec, 193.7, 151.1, CreateVatPostingGrpAT.VAT20());
            CreateItem.TokyoGuestChairBlue():
                ValidateRecordFields(Rec, 193.7, 151.1, CreateVatPostingGrpAT.VAT20());
            CreateItem.ConferenceBundle28():
                ValidateRecordFields(Rec, 235, 0, CreateVatPostingGrpAT.VAT20());
            CreateItem.MexicoSwivelChairBlack():
                ValidateRecordFields(Rec, 191, 148.9, CreateVatPostingGrpAT.VAT20());
            CreateItem.ConferencePackage1():
                ValidateRecordFields(Rec, 343.5, 0, CreateVatPostingGrpAT.VAT20());
            CreateItem.MunichSwivelChairYellow():
                ValidateRecordFields(Rec, 191, 148.9, CreateVatPostingGrpAT.VAT20());
            CreateItem.MoscowSwivelChairRed():
                ValidateRecordFields(Rec, 191, 148.9, CreateVatPostingGrpAT.VAT20());
            CreateItem.SeoulGuestChairRed():
                ValidateRecordFields(Rec, 193.7, 151.1, CreateVatPostingGrpAT.VAT20());
            CreateItem.AtlantaWhiteboardBase():
                ValidateRecordFields(Rec, 1404.3, 1095.3, CreateVatPostingGrpAT.VAT20());
            CreateItem.SydneySwivelChairGreen():
                ValidateRecordFields(Rec, 191, 148.9, CreateVatPostingGrpAT.VAT20());
        end;
    end;

    local procedure ValidateRecordFields(var Item: Record Item; UnitPrice: Decimal; UnitCost: Decimal; VatProdPostingGrp: Code[20])
    begin
        Item.Validate("Unit Price", UnitPrice);
        Item.Validate("Unit Cost", UnitCost);
        Item.Validate("VAT Prod. Posting Group", VatProdPostingGrp);
    end;
}