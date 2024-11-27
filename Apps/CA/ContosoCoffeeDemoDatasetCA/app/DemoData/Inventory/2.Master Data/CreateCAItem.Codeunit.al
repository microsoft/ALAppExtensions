codeunit 27057 "Create CA Item"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::Item, 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnInsertRecord(var Rec: Record Item)
    var
        CreateItem: Codeunit "Create Item";
        CreateCATaxGroup: Codeunit "Create CA Tax Group";
    begin
        case Rec."No." of
            CreateItem.AthensDesk():
                ValidateRecordFields(Rec, 1503.4, 1172.7, CreateCATaxGroup.Taxable());
            CreateItem.ParisGuestChairBlack():
                ValidateRecordFields(Rec, 289.6, 225.8, CreateCATaxGroup.Taxable());
            CreateItem.AthensMobilePedestal():
                ValidateRecordFields(Rec, 651.4, 508.1, CreateCATaxGroup.Taxable());
            CreateItem.LondonSwivelChairBlue():
                ValidateRecordFields(Rec, 285.5, 222.5, CreateCATaxGroup.Taxable());
            CreateItem.AntwerpConferenceTable():
                ValidateRecordFields(Rec, 973.2, 759.3, CreateCATaxGroup.Taxable());
            CreateItem.ConferenceBundle16():
                ValidateRecordFields(Rec, 283.6, 0, CreateCATaxGroup.Taxable());
            CreateItem.AmsterdamLamp():
                ValidateRecordFields(Rec, 82.5, 64.4, CreateCATaxGroup.Taxable());
            CreateItem.ConferenceBundle18():
                ValidateRecordFields(Rec, 351.2, 0, CreateCATaxGroup.Taxable());
            CreateItem.BerlingGuestChairYellow():
                ValidateRecordFields(Rec, 289.6, 225.8, CreateCATaxGroup.Taxable());
            CreateItem.GuestSection1():
                ValidateRecordFields(Rec, 189, 0, CreateCATaxGroup.Taxable());
            CreateItem.RomeGuestChairGreen():
                ValidateRecordFields(Rec, 289.6, 225.8, CreateCATaxGroup.Taxable());
            CreateItem.TokyoGuestChairBlue():
                ValidateRecordFields(Rec, 289.6, 225.8, CreateCATaxGroup.Taxable());
            CreateItem.ConferenceBundle28():
                ValidateRecordFields(Rec, 351.2, 0, CreateCATaxGroup.Taxable());
            CreateItem.MexicoSwivelChairBlack():
                ValidateRecordFields(Rec, 285.5, 222.5, CreateCATaxGroup.Taxable());
            CreateItem.ConferencePackage1():
                ValidateRecordFields(Rec, 513.5, 0, CreateCATaxGroup.Taxable());
            CreateItem.MunichSwivelChairYellow():
                ValidateRecordFields(Rec, 285.5, 222.5, CreateCATaxGroup.Taxable());
            CreateItem.MoscowSwivelChairRed():
                ValidateRecordFields(Rec, 285.5, 222.5, CreateCATaxGroup.Taxable());
            CreateItem.SeoulGuestChairRed():
                ValidateRecordFields(Rec, 289.6, 225.8, CreateCATaxGroup.Taxable());
            CreateItem.AtlantaWhiteboardBase():
                ValidateRecordFields(Rec, 2099.1, 1637.3, CreateCATaxGroup.Taxable());
            CreateItem.SydneySwivelChairGreen():
                ValidateRecordFields(Rec, 285.5, 222.5, CreateCATaxGroup.Taxable());
        end;
    end;

    local procedure ValidateRecordFields(var Item: Record Item; UnitPrice: Decimal; UnitCost: Decimal; TaxGroupCode: Code[20])
    begin
        Item.Validate("Unit Price", UnitPrice);
        Item.Validate("Unit Cost", UnitCost);
        Item.Validate("Tax Group Code", TaxGroupCode);
    end;
}