codeunit 11606 "Create CH Item"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::Item, 'OnBeforeOnInsert', '', false, false)]
    local procedure OnBeforeOnInsertItem(var Item: Record Item)
    var
        CreateCHVatPostingGroups: Codeunit "Create CH VAT Posting Groups";
        CreateItem: Codeunit "Create Item";
    begin
        case Item."No." of
            CreateItem.AthensDesk():
                ValidateRecordFields(Item, 1190, 932, CreateCHVatPostingGroups.Normal());
            CreateItem.ParisGuestChairBlack():
                ValidateRecordFields(Item, 230, 179.5, CreateCHVatPostingGroups.Normal());
            CreateItem.AthensMobilePedestal():
                ValidateRecordFields(Item, 520, 404, CreateCHVatPostingGroups.Normal());
            CreateItem.LondonSwivelChairBlue():
                ValidateRecordFields(Item, 230, 177, CreateCHVatPostingGroups.Normal());
            CreateItem.AntwerpConferenceTable():
                ValidateRecordFields(Item, 770, 603.5, CreateCHVatPostingGroups.Normal());
            CreateItem.ConferenceBundle16():
                ValidateRecordFields(Item, 230, 0, CreateCHVatPostingGroups.Normal());
            CreateItem.AmsterdamLamp():
                ValidateRecordFields(Item, 66, 51, CreateCHVatPostingGroups.Normal());
            CreateItem.ConferenceBundle18():
                ValidateRecordFields(Item, 280, 0, CreateCHVatPostingGroups.Normal());
            CreateItem.BerlingGuestChairYellow():
                ValidateRecordFields(Item, 230, 179.5, CreateCHVatPostingGroups.Normal());
            CreateItem.GuestSection1():
                ValidateRecordFields(Item, 150, 0, CreateCHVatPostingGroups.Normal());
            CreateItem.RomeGuestChairGreen():
                ValidateRecordFields(Item, 230, 179.5, CreateCHVatPostingGroups.Normal());
            CreateItem.TokyoGuestChairBlue():
                ValidateRecordFields(Item, 230, 179.5, CreateCHVatPostingGroups.Normal());
            CreateItem.ConferenceBundle28():
                ValidateRecordFields(Item, 280, 0, CreateCHVatPostingGroups.Normal());
            CreateItem.MexicoSwivelChairBlack():
                ValidateRecordFields(Item, 230, 177, CreateCHVatPostingGroups.Normal());
            CreateItem.ConferencePackage1():
                ValidateRecordFields(Item, 410, 0, CreateCHVatPostingGroups.Normal());
            CreateItem.MunichSwivelChairYellow():
                ValidateRecordFields(Item, 230, 177, CreateCHVatPostingGroups.Normal());
            CreateItem.MoscowSwivelChairRed():
                ValidateRecordFields(Item, 230, 177, CreateCHVatPostingGroups.Normal());
            CreateItem.SeoulGuestChairRed():
                ValidateRecordFields(Item, 230, 179.5, CreateCHVatPostingGroups.Normal());
            CreateItem.AtlantaWhiteboardBase():
                ValidateRecordFields(Item, 1670, 1301, CreateCHVatPostingGroups.Normal());
            CreateItem.SydneySwivelChairGreen():
                ValidateRecordFields(Item, 230, 177, CreateCHVatPostingGroups.Normal());
        end;
    end;

    local procedure ValidateRecordFields(var Item: Record Item; UnitPrice: Decimal; UnitCost: Decimal; VatProdPostingGroup: Code[20])
    begin
        Item.Validate("Unit Price", UnitPrice);
        Item.Validate("Unit Cost", UnitCost);
        Item.Validate("VAT Prod. Posting Group", VatProdPostingGroup);
    end;
}