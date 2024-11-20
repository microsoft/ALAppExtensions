codeunit 11094 "Create DE Item"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::Item, 'OnBeforeOnInsert', '', false, false)]
    local procedure OnBeforeOnInsertItem(var Item: Record Item)
    var
        CreateVatPostingGrp: Codeunit "Create DE VAT Posting Groups";
        CreateItem: Codeunit "Create Item";
    begin
        case Item."No." of
            CreateItem.AthensDesk():
                ValidateItem(Item, 1005.8, 784.6, CreateVatPostingGrp.VAT19());
            CreateItem.ParisGuestChairBlack():
                ValidateItem(Item, 193.7, 151.1, CreateVatPostingGrp.VAT19());
            CreateItem.AthensMobilePedestal():
                ValidateItem(Item, 435.8, 339.9, CreateVatPostingGrp.VAT19());
            CreateItem.LondonSwivelChairBlue():
                ValidateItem(Item, 191, 148.9, CreateVatPostingGrp.VAT19());
            CreateItem.AntwerpConferenceTable():
                ValidateItem(Item, 651.1, 508, CreateVatPostingGrp.VAT19());
            CreateItem.ConferenceBundle16():
                ValidateItem(Item, 189.8, 0, CreateVatPostingGrp.VAT19());
            CreateItem.AmsterdamLamp():
                ValidateItem(Item, 55.2, 43.1, CreateVatPostingGrp.VAT19());
            CreateItem.ConferenceBundle18():
                ValidateItem(Item, 235, 0, CreateVatPostingGrp.VAT19());
            CreateItem.BerlingGuestChairYellow():
                ValidateItem(Item, 193.7, 151.1, CreateVatPostingGrp.VAT19());
            CreateItem.GuestSection1():
                ValidateItem(Item, 126.4, 0, CreateVatPostingGrp.VAT19());
            CreateItem.RomeGuestChairGreen():
                ValidateItem(Item, 193.7, 151.1, CreateVatPostingGrp.VAT19());
            CreateItem.TokyoGuestChairBlue():
                ValidateItem(Item, 193.7, 151.1, CreateVatPostingGrp.VAT19());
            CreateItem.ConferenceBundle28():
                ValidateItem(Item, 235, 0, CreateVatPostingGrp.VAT19());
            CreateItem.MexicoSwivelChairBlack():
                ValidateItem(Item, 191, 148.9, CreateVatPostingGrp.VAT19());
            CreateItem.ConferencePackage1():
                ValidateItem(Item, 343.5, 0, CreateVatPostingGrp.VAT19());
            CreateItem.MunichSwivelChairYellow():
                ValidateItem(Item, 191, 148.9, CreateVatPostingGrp.VAT19());
            CreateItem.MoscowSwivelChairRed():
                ValidateItem(Item, 191, 148.9, CreateVatPostingGrp.VAT19());
            CreateItem.SeoulGuestChairRed():
                ValidateItem(Item, 193.7, 151.1, CreateVatPostingGrp.VAT19());
            CreateItem.AtlantaWhiteboardBase():
                ValidateItem(Item, 1404.3, 1095.3, CreateVatPostingGrp.VAT19());
            CreateItem.SydneySwivelChairGreen():
                ValidateItem(Item, 191, 148.9, CreateVatPostingGrp.VAT19());
        end;
    end;

    local procedure ValidateItem(var Item: Record Item; UnitPrice: Decimal; UnitCost: Decimal; VatProdPostingGrp: Code[20])
    begin
        Item.Validate("Unit Price", UnitPrice);
        Item.Validate("Unit Cost", UnitCost);
        Item.Validate("VAT Prod. Posting Group", VatProdPostingGrp);
    end;
}