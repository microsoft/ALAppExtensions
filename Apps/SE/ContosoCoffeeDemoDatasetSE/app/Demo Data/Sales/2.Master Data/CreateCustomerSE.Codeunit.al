codeunit 11234 "Create Customer SE"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::Customer, 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertCustomer(var Rec: Record Customer)
    var
        CreateCustomer: Codeunit "Create Customer";
        CreateLanguage: Codeunit "Create Language";
    begin
        case Rec."No." of
            CreateCustomer.DomesticAdatumCorporation():
                ValidateRecordFields(Rec, MALMOCityLbl, 'SE789456278901', PostCode21215Lbl, CreateLanguage.SVE());
            CreateCustomer.DomesticTreyResearch():
                ValidateRecordFields(Rec, StockholmCityLbl, 'SE254687456701', PostCode11432Lbl, CreateLanguage.SVE());
            CreateCustomer.ExportSchoolofArt():
                ValidateRecordFields(Rec, MiamiCityLbl, ExportSchoolofArtVatRegNoLbl, USFL37125PostCodeLbl, CreateLanguage.ENU());
            CreateCustomer.EUAlpineSkiHouse():
                ValidateRecordFields(Rec, MunchenCityLbl, EUAlpineSkiHouseVatRegNoLbl, DE80807PostCodeLbl, CreateLanguage.DEU());
            CreateCustomer.DomesticRelecloud():
                ValidateRecordFields(Rec, StockholmCityLbl, 'SE582048936701', PostCode11432Lbl, CreateLanguage.SVE());
        end;
    end;

    local procedure ValidateRecordFields(var Customer: Record Customer; City: Text[30]; VatRegNo: Text[20]; PostCode: Code[20]; LanguageCode: Code[10])
    begin
        Customer.Validate(City, City);
        Customer.Validate("Post Code", PostCode);
        Customer."VAT Registration No." := VatRegNo;
        Customer.Validate("Language Code", LanguageCode);
    end;

    var
        MALMOCityLbl: Label 'MALMÖ', MaxLength = 30, Locked = true;
        StockholmCityLbl: Label 'STOCKHOLM', MaxLength = 30, Locked = true;
        MiamiCityLbl: Label 'Miami', MaxLength = 30, Locked = true;
        MunchenCityLbl: Label 'Munchen', MaxLength = 30, Locked = true;
        ExportSchoolofArtVatRegNoLbl: Label '733495789', MaxLength = 20;
        EUAlpineSkiHouseVatRegNoLbl: Label '533435789', MaxLength = 20;
        PostCode21215Lbl: Label '212 15', MaxLength = 20;
        PostCode11432Lbl: Label '114 32', MaxLength = 20;
        USFL37125PostCodeLbl: Label 'US-FL 37125', MaxLength = 20;
        DE80807PostCodeLbl: Label 'DE-80807', MaxLength = 20;
}