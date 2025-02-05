codeunit 17126 "Create NZ Item"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::Item, 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertItem(var Rec: Record Item)
    var
        CreateItem: Codeunit "Create Item";
        CreateNZVATPostingGroup: Codeunit "Create NZ VAT Posting Group";
    begin
        case Rec."No." of
            CreateItem.AthensDesk():
                ValidateRecordFields(Rec, 2237, 1745, CreateNZVATPostingGroup.VAT15());
            CreateItem.ParisGuestChairBlack():
                ValidateRecordFields(Rec, 431, 336, CreateNZVATPostingGroup.VAT15());
            CreateItem.AthensMobilePedestal():
                ValidateRecordFields(Rec, 969, 756, CreateNZVATPostingGroup.VAT15());
            CreateItem.LondonSwivelChairBlue():
                ValidateRecordFields(Rec, 425, 331, CreateNZVATPostingGroup.VAT15());
            CreateItem.AntwerpConferenceTable():
                ValidateRecordFields(Rec, 1448, 1130, CreateNZVATPostingGroup.VAT15());
            CreateItem.ConferenceBundle16():
                ValidateRecordFields(Rec, 422, 0, CreateNZVATPostingGroup.VAT15());
            CreateItem.AmsterdamLamp():
                ValidateRecordFields(Rec, 123, 96, CreateNZVATPostingGroup.VAT15());
            CreateItem.ConferenceBundle18():
                ValidateRecordFields(Rec, 523, 0, CreateNZVATPostingGroup.VAT15());
            CreateItem.BerlingGuestChairYellow():
                ValidateRecordFields(Rec, 431, 336, CreateNZVATPostingGroup.VAT15());
            CreateItem.GuestSection1():
                ValidateRecordFields(Rec, 281, 0, CreateNZVATPostingGroup.VAT15());
            CreateItem.RomeGuestChairGreen():
                ValidateRecordFields(Rec, 431, 336, CreateNZVATPostingGroup.VAT15());
            CreateItem.TokyoGuestChairBlue():
                ValidateRecordFields(Rec, 431, 336, CreateNZVATPostingGroup.VAT15());
            CreateItem.ConferenceBundle28():
                ValidateRecordFields(Rec, 523, 0, CreateNZVATPostingGroup.VAT15());
            CreateItem.MexicoSwivelChairBlack():
                ValidateRecordFields(Rec, 425, 331, CreateNZVATPostingGroup.VAT15());
            CreateItem.ConferencePackage1():
                ValidateRecordFields(Rec, 764, 0, CreateNZVATPostingGroup.VAT15());
            CreateItem.MunichSwivelChairYellow():
                ValidateRecordFields(Rec, 425, 331, CreateNZVATPostingGroup.VAT15());
            CreateItem.MoscowSwivelChairRed():
                ValidateRecordFields(Rec, 425, 331, CreateNZVATPostingGroup.VAT15());
            CreateItem.SeoulGuestChairRed():
                ValidateRecordFields(Rec, 431, 336, CreateNZVATPostingGroup.VAT15());
            CreateItem.AtlantaWhiteboardBase():
                ValidateRecordFields(Rec, 3123, 2436, CreateNZVATPostingGroup.VAT15());
            CreateItem.SydneySwivelChairGreen():
                ValidateRecordFields(Rec, 425, 331, CreateNZVATPostingGroup.VAT15());
        end;
    end;

    local procedure ValidateRecordFields(var Item: Record Item; UnitPrice: Decimal; UnitCost: Decimal; VATProdPostingGroup: Code[20])
    begin
        Item.Validate("Unit Price", UnitPrice);
        Item.Validate("Unit Cost", UnitCost);
        Item.Validate("VAT Prod. Posting Group", VATProdPostingGroup);
    end;
}