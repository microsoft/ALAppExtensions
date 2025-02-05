codeunit 10498 "Create Item US"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::Item, 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnInsertRecord(var Rec: Record Item)
    var
        CreateItem: Codeunit "Create Item";
        CreateTaxGroupUS: Codeunit "Create Tax Group US";
    begin
        case Rec."No." of
            CreateItem.AthensDesk():
                ValidateRecordFields(Rec, 1000.8, 780.7, CreateTaxGroupUS.Furniture(), '');
            CreateItem.ParisGuestChairBlack():
                ValidateRecordFields(Rec, 192.8, 150.3, CreateTaxGroupUS.Furniture(), '');
            CreateItem.AthensMobilePedestal():
                ValidateRecordFields(Rec, 433.6, 338.2, CreateTaxGroupUS.Furniture(), '');
            CreateItem.LondonSwivelChairBlue():
                ValidateRecordFields(Rec, 190.1, 148.1, CreateTaxGroupUS.Furniture(), '');
            CreateItem.AntwerpConferenceTable():
                ValidateRecordFields(Rec, 647.8, 505.4, CreateTaxGroupUS.Furniture(), '');
            CreateItem.ConferenceBundle16():
                ValidateRecordFields(Rec, 188.8, 0, CreateTaxGroupUS.Furniture(), '');
            CreateItem.AmsterdamLamp():
                ValidateRecordFields(Rec, 54.9, 42.8, CreateTaxGroupUS.Furniture(), '');
            CreateItem.ConferenceBundle18():
                ValidateRecordFields(Rec, 233.8, 0, CreateTaxGroupUS.Furniture(), '');
            CreateItem.BerlingGuestChairYellow():
                ValidateRecordFields(Rec, 192.8, 150.3, CreateTaxGroupUS.Furniture(), '');
            CreateItem.GuestSection1():
                ValidateRecordFields(Rec, 125.8, 0, CreateTaxGroupUS.Furniture(), '');
            CreateItem.RomeGuestChairGreen():
                ValidateRecordFields(Rec, 192.8, 150.3, CreateTaxGroupUS.Furniture(), '');
            CreateItem.TokyoGuestChairBlue():
                ValidateRecordFields(Rec, 192.8, 150.3, CreateTaxGroupUS.Furniture(), '');
            CreateItem.ConferenceBundle28():
                ValidateRecordFields(Rec, 233.8, 0, CreateTaxGroupUS.Furniture(), '');
            CreateItem.MexicoSwivelChairBlack():
                ValidateRecordFields(Rec, 190.1, 148.1, CreateTaxGroupUS.Furniture(), '');
            CreateItem.ConferencePackage1():
                ValidateRecordFields(Rec, 341.8, 0, CreateTaxGroupUS.Furniture(), '');
            CreateItem.MunichSwivelChairYellow():
                ValidateRecordFields(Rec, 190.1, 148.1, CreateTaxGroupUS.Furniture(), '');
            CreateItem.MoscowSwivelChairRed():
                ValidateRecordFields(Rec, 190.1, 148.1, CreateTaxGroupUS.Furniture(), '');
            CreateItem.SeoulGuestChairRed():
                ValidateRecordFields(Rec, 192.8, 150.3, CreateTaxGroupUS.Furniture(), '');
            CreateItem.AtlantaWhiteboardBase():
                ValidateRecordFields(Rec, 1397.3, 1089.9, CreateTaxGroupUS.Furniture(), '');
            CreateItem.SydneySwivelChairGreen():
                ValidateRecordFields(Rec, 190.1, 148.1, CreateTaxGroupUS.Furniture(), '');
        end;
    end;

    local procedure ValidateRecordFields(var Item: Record Item; UnitPrice: Decimal; UnitCost: Decimal; TaxGroupCode: Code[20]; VATProdPostingGroup: Code[20])
    begin
        Item.Validate("Unit Cost", UnitCost);
        Item.Validate("Unit Price", UnitPrice);
        Item.Validate("Tax Group Code", TaxGroupCode);
        Item.Validate("VAT Prod. Posting Group", VATProdPostingGroup);
    end;
}