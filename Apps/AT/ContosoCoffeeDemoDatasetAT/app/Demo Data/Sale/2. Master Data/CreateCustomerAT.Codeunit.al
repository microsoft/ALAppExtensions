codeunit 11175 "Create Customer AT"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    //TODO -Hard coded values pending to replace - Post Code,Vat Registration No

    [EventSubscriber(ObjectType::Table, Database::Customer, 'OnBeforeInsert', '', false, false)]
    local procedure OnBeforeInsertCustomer(var Customer: Record Customer)
    var
        CreateLanguage: Codeunit "Create Language";
        CreateCustomer: Codeunit "Create Customer";
    begin
        case Customer."No." of
            CreateCustomer.DomesticAdatumCorporation():
                ValidateCustomer(Customer, CreateLanguage.DEA(), '', PostCode1230Lbl, DomesticAdatumCorporationVatRegLbl, DomesticAdatumCorporationCityLbl);
            CreateCustomer.DomesticTreyResearch():
                ValidateCustomer(Customer, CreateLanguage.DEA(), '', PostCode3601Lbl, DomesticTreyResearchVatRegLbl, DomesticTreyResearchCityLbl);
            CreateCustomer.DomesticRelecloud():
                ValidateCustomer(Customer, CreateLanguage.DEA(), '', PostCode5020Lbl, DomesticRelecloudVatRegLbl, DomesticRelecloudCityLbl);

            CreateCustomer.ExportSchoolofArt():
                ValidateCustomerFields(Customer, CreateLanguage.ENU(), PostCodeFL37125Lbl, ExportSchoolofArtVatRegLbl, ExportSchoolofArtCityLbl, 'FL');
            CreateCustomer.EUAlpineSkiHouse():
                begin
                    ValidateCustomerFields(Customer, CreateLanguage.DEU(), PostCode80807Lbl, EUAlpineSkiHouseVatRegLbl, EUAlpineSkiHouseCityLbl, '');
                    Customer.Validate("Territory Code", '');
                end;
        end;
    end;

    local procedure ValidateCustomer(var Customer: Record Customer; LanguageCode: Code[10]; CountryRegionCode: Code[10]; PostCode: Code[20]; VatRegistraionNo: Text[20]; City: Text[30])
    begin
        Customer.Validate("Post Code", PostCode);
        Customer.Validate("Language Code", LanguageCode);
        Customer.Validate(City, City);
        Customer."Country/Region Code" := CountryRegionCode;

        if CountryRegionCode <> '' then
            Customer.Validate("VAT Registration No.", VatRegistraionNo)
        else
            Customer."VAT Registration No." := VatRegistraionNo;
    end;

    local procedure ValidateCustomerFields(var Customer: Record Customer; LanguageCode: Code[10]; PostCode: Code[20]; VatRegistraionNo: Text[20]; City: Text[30]; CustomerCounty: Text[30])
    begin
        Customer.Validate("Post Code", PostCode);
        Customer.Validate("Language Code", LanguageCode);
        Customer."VAT Registration No." := VatRegistraionNo;
        Customer.Validate(City, City);
        Customer.Validate(County, CustomerCounty);
    end;

    var
        DomesticAdatumCorporationCityLbl: Label 'Wien', MaxLength = 30;
        DomesticTreyResearchCityLbl: Label 'Dürnstein', MaxLength = 30;
        ExportSchoolofArtCityLbl: Label 'Miami', MaxLength = 30;
        EUAlpineSkiHouseCityLbl: Label 'Munchen', MaxLength = 30;
        DomesticRelecloudCityLbl: Label 'Salzburg', MaxLength = 30;
        DomesticAdatumCorporationVatRegLbl: Label 'XATU78945627', MaxLength = 20;
        DomesticTreyResearchVatRegLbl: Label 'XATU25468745', MaxLength = 20;
        ExportSchoolofArtVatRegLbl: Label '733495789', MaxLength = 20;
        EUAlpineSkiHouseVatRegLbl: Label '533435789', MaxLength = 20;
        DomesticRelecloudVatRegLbl: Label 'XATU58204893', MaxLength = 20;
        PostCode1230Lbl: Label '1230', MaxLength = 20;
        PostCode3601Lbl: Label '3601', MaxLength = 20;
        PostCodeFL37125Lbl: Label 'FL 37125', MaxLength = 20;
        PostCode80807Lbl: Label '80807', MaxLength = 20;
        PostCode5020Lbl: Label '5020', MaxLength = 20;

}