codeunit 11521 "Create Customer NL"
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
                ValidateRecordFields(Rec, ArnhemCityLbl, DomesticAdatumCorporationVatRegNoLbl, PostCode1705RELbl, CreateLanguage.NLD());
            CreateCustomer.DomesticTreyResearch():
                ValidateRecordFields(Rec, ZaandamCityLbl, DomesticTreyResearchVatRgeNoLbl, PostCode1324JWLbl, CreateLanguage.NLD());
            CreateCustomer.ExportSchoolofArt():
                Rec.Validate("VAT Registration No.", ExportSchoolofArtVatRegNoLbl);
            CreateCustomer.EUAlpineSkiHouse():
                Rec.Validate("VAT Registration No.", EUAlpineSkiHouseVatRegNoLbl);
            CreateCustomer.DomesticRelecloud():
                ValidateRecordFields(Rec, AmsterdamCityLbl, DomesticRelecloudVatRegNoLbl, PostCode7201HWLbl, CreateLanguage.NLD());
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
        ArnhemCityLbl: Label 'Arnhem', MaxLength = 30;
        ZaandamCityLbl: Label 'Zaandam', MaxLength = 30;
        AmsterdamCityLbl: Label 'Amsterdam', MaxLength = 30;
        DomesticAdatumCorporationVatRegNoLbl: Label '789456278', MaxLength = 20;
        DomesticTreyResearchVatRgeNoLbl: Label '254687456', MaxLength = 20;
        DomesticRelecloudVatRegNoLbl: Label '582048936', MaxLength = 20;
        ExportSchoolofArtVatRegNoLbl: Label '733495789', MaxLength = 20;
        EUAlpineSkiHouseVatRegNoLbl: Label '533435789', MaxLength = 20;
        PostCode1705RELbl: Label '1705 RE', MaxLength = 20;
        PostCode1324JWLbl: Label '1324 JW', MaxLength = 20;
        PostCode7201HWLbl: Label '7201 HW', MaxLength = 20;
}