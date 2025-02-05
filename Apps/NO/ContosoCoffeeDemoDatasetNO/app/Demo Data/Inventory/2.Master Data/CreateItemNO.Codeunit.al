codeunit 10665 "Create Item NO"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::Item, 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertItem(var Rec: Record Item)
    var
        CreateItem: Codeunit "Create Item";
        CreateVatPostingGroupsNO: Codeunit "Create Vat Posting Groups NO";
    begin
        case Rec."No." of
            CreateItem.AthensDesk():
                ValidateRecordFields(Rec, 6329, 4937, CreateVatPostingGroupsNO.High());
            CreateItem.ParisGuestChairBlack():
                ValidateRecordFields(Rec, 1219, 950, CreateVatPostingGroupsNO.High());
            CreateItem.AthensMobilePedestal():
                ValidateRecordFields(Rec, 2742, 2139, CreateVatPostingGroupsNO.High());
            CreateItem.LondonSwivelChairBlue():
                ValidateRecordFields(Rec, 1202, 937, CreateVatPostingGroupsNO.High());
            CreateItem.AntwerpConferenceTable():
                ValidateRecordFields(Rec, 4097, 3196, CreateVatPostingGroupsNO.High());
            CreateItem.ConferenceBundle16():
                ValidateRecordFields(Rec, 1194, 0, CreateVatPostingGroupsNO.High());
            CreateItem.AmsterdamLamp():
                ValidateRecordFields(Rec, 347, 271, CreateVatPostingGroupsNO.High());
            CreateItem.ConferenceBundle18():
                ValidateRecordFields(Rec, 1479, 0, CreateVatPostingGroupsNO.High());
            CreateItem.BerlingGuestChairYellow():
                ValidateRecordFields(Rec, 1219, 950, CreateVatPostingGroupsNO.High());
            CreateItem.GuestSection1():
                ValidateRecordFields(Rec, 796, 0, CreateVatPostingGroupsNO.High());
            CreateItem.RomeGuestChairGreen():
                ValidateRecordFields(Rec, 1219, 950, CreateVatPostingGroupsNO.High());
            CreateItem.TokyoGuestChairBlue():
                ValidateRecordFields(Rec, 1219, 950, CreateVatPostingGroupsNO.High());
            CreateItem.ConferenceBundle28():
                ValidateRecordFields(Rec, 1479, 0, CreateVatPostingGroupsNO.High());
            CreateItem.MexicoSwivelChairBlack():
                ValidateRecordFields(Rec, 1202, 937, CreateVatPostingGroupsNO.High());
            CreateItem.ConferencePackage1():
                ValidateRecordFields(Rec, 2162, 0, CreateVatPostingGroupsNO.High());
            CreateItem.MunichSwivelChairYellow():
                ValidateRecordFields(Rec, 1202, 937, CreateVatPostingGroupsNO.High());
            CreateItem.MoscowSwivelChairRed():
                ValidateRecordFields(Rec, 1202, 937, CreateVatPostingGroupsNO.High());
            CreateItem.SeoulGuestChairRed():
                ValidateRecordFields(Rec, 1219, 950, CreateVatPostingGroupsNO.High());
            CreateItem.AtlantaWhiteboardBase():
                ValidateRecordFields(Rec, 8837, 6892, CreateVatPostingGroupsNO.High());
            CreateItem.SydneySwivelChairGreen():
                ValidateRecordFields(Rec, 1202, 937, CreateVatPostingGroupsNO.High());
        end;
    end;

    local procedure ValidateRecordFields(var Item: Record Item; UnitPrice: Decimal; UnitCost: Decimal; VATProdPostingGroupCode: Code[20])
    begin
        Item.Validate("Unit Price", UnitPrice);
        Item.Validate("Unit Cost", UnitCost);
        Item.Validate("VAT Prod. Posting Group", VATProdPostingGroupCode);
    end;
}