codeunit 11375 "Create Item BE"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::Item, 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertItem(var Rec: Record Item)
    var
        CreateItem: Codeunit "Create Item";
        CreateVatPostingGrpBE: Codeunit "Create VAT Posting Group BE";
    begin
        case Rec."No." of
            CreateItem.AthensDesk():
                ValidateRecordFields(Rec, 1005.8, 784.6, CreateVatPostingGrpBE.G3());
            CreateItem.ParisGuestChairBlack():
                ValidateRecordFields(Rec, 193.7, 151.1, CreateVatPostingGrpBE.G3());
            CreateItem.AthensMobilePedestal():
                ValidateRecordFields(Rec, 435.8, 339.9, CreateVatPostingGrpBE.G3());
            CreateItem.LondonSwivelChairBlue():
                ValidateRecordFields(Rec, 191, 148.9, CreateVatPostingGrpBE.G3());
            CreateItem.AntwerpConferenceTable():
                ValidateRecordFields(Rec, 651.1, 508, CreateVatPostingGrpBE.G3());
            CreateItem.ConferenceBundle16():
                ValidateRecordFields(Rec, 189.8, 0, CreateVatPostingGrpBE.G3());
            CreateItem.AmsterdamLamp():
                ValidateRecordFields(Rec, 55.2, 43.1, CreateVatPostingGrpBE.G3());
            CreateItem.ConferenceBundle18():
                ValidateRecordFields(Rec, 235, 0, CreateVatPostingGrpBE.G3());
            CreateItem.BerlingGuestChairYellow():
                ValidateRecordFields(Rec, 193.7, 151.1, CreateVatPostingGrpBE.G3());
            CreateItem.GuestSection1():
                ValidateRecordFields(Rec, 126.4, 0, CreateVatPostingGrpBE.G3());
            CreateItem.RomeGuestChairGreen():
                ValidateRecordFields(Rec, 193.7, 151.1, CreateVatPostingGrpBE.G3());
            CreateItem.TokyoGuestChairBlue():
                ValidateRecordFields(Rec, 193.7, 151.1, CreateVatPostingGrpBE.G3());
            CreateItem.ConferenceBundle28():
                ValidateRecordFields(Rec, 235, 0, CreateVatPostingGrpBE.G3());
            CreateItem.MexicoSwivelChairBlack():
                ValidateRecordFields(Rec, 191, 148.9, CreateVatPostingGrpBE.G3());
            CreateItem.ConferencePackage1():
                ValidateRecordFields(Rec, 343.5, 0, CreateVatPostingGrpBE.G3());
            CreateItem.MunichSwivelChairYellow():
                ValidateRecordFields(Rec, 191, 148.9, CreateVatPostingGrpBE.G3());
            CreateItem.MoscowSwivelChairRed():
                ValidateRecordFields(Rec, 191, 148.9, CreateVatPostingGrpBE.G3());
            CreateItem.SeoulGuestChairRed():
                ValidateRecordFields(Rec, 193.7, 151.1, CreateVatPostingGrpBE.G3());
            CreateItem.AtlantaWhiteboardBase():
                ValidateRecordFields(Rec, 1404.3, 1095.3, CreateVatPostingGrpBE.G3());
            CreateItem.SydneySwivelChairGreen():
                ValidateRecordFields(Rec, 191, 148.9, CreateVatPostingGrpBE.G3());
        end;
    end;

    local procedure ValidateRecordFields(var Item: Record Item; UnitPrice: Decimal; UnitCost: Decimal; VatProdPostingGrp: Code[20])
    begin
        Item.Validate("Unit Price", UnitPrice);
        Item.Validate("Unit Cost", UnitCost);
        Item.Validate("VAT Prod. Posting Group", VatProdPostingGrp);
    end;
}