codeunit 11594 "Create CH Customer"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    //TODO -Hard coded values pending to replace - Post Code

    [EventSubscriber(ObjectType::Table, Database::Customer, 'OnBeforeInsert', '', false, false)]
    local procedure OnBeforeInsertCustomer(var Customer: Record Customer)
    var
        ContosoCoffeeDemoDataSetup: Record "Contoso Coffee Demo Data Setup";
        CreateLanguage: Codeunit "Create Language";
        CreateCountryRegion: Codeunit "Create Country/Region";
        CreateTerritory: Codeunit "Create Territory";
        CreateCustomer: Codeunit "Create Customer";
    begin
        ContosoCoffeeDemoDataSetup.Get();

        case Customer."No." of
            CreateCustomer.DomesticAdatumCorporation():
                ValidateRecordFields(Customer, LuzernCityLbl, CreateTerritory.Foreign(), CreateLanguage.DES(), ContosoCoffeeDemoDataSetup."Country/Region Code", '6000', LUCountyLbl, AdatumCorporationVATRegNoLbl, '');
            CreateCustomer.DomesticTreyResearch():
                ValidateRecordFields(Customer, MeggenCityLbl, CreateTerritory.Foreign(), CreateLanguage.DES(), ContosoCoffeeDemoDataSetup."Country/Region Code", '6045', LUCountyLbl, TreyResearchVATRegNoLbl, '');
            CreateCustomer.ExportSchoolofArt():
                ValidateRecordFields(Customer, MiamiCityLbl, CreateTerritory.Foreign(), CreateLanguage.ENU(), CreateCountryRegion.US(), 'US-FL 37125', FLCountyLbl, SchoolofFineArtVATRegNoLbl, '');
            CreateCustomer.EUAlpineSkiHouse():
                ValidateRecordFields(Customer, MunchenCityLbl, CreateTerritory.Foreign(), CreateLanguage.DEU(), CreateCountryRegion.DE(), 'DE-80807', '', AlpineSkiHouseVATRegNoLbl, '');
            CreateCustomer.DomesticRelecloud():
                ValidateRecordFields(Customer, RamersbergCityLbl, CreateTerritory.Foreign(), CreateLanguage.DES(), ContosoCoffeeDemoDataSetup."Country/Region Code", '6060', OWCountyLbl, RelecloudVATRegNoLbl, '');
        end;
    end;

    local procedure ValidateRecordFields(var Customer: Record Customer; City: Text[30]; TerritoryCode: Code[10]; LanguageCode: Code[10]; CountryRegionCode: Code[10]; PostCode: Code[20]; County: Text[30]; VatRegistraionNo: Text[20]; Email: Text[80])
    begin
        Customer.Validate("Post Code", PostCode);
        Customer.Validate(City, City);
        Customer.Validate("Country/Region Code", CountryRegionCode);
        Customer.Validate(County, County);
        Customer.Validate("Territory Code", TerritoryCode);
        Customer.Validate("Language Code", LanguageCode);
        Customer.Validate("VAT Registration No.", VatRegistraionNo);
        Customer.Validate("E-Mail", Email);
    end;

    var
        LuzernCityLbl: Label 'Luzern', MaxLength = 30;
        MeggenCityLbl: Label 'Meggen', MaxLength = 30;
        MiamiCityLbl: Label 'Miami', MaxLength = 30;
        MunchenCityLbl: Label 'Munchen', MaxLength = 30;
        RamersbergCityLbl: Label 'Ramersberg', MaxLength = 30;
        AdatumCorporationVATRegNoLbl: Label 'CHE-789.456.278MWST', MaxLength = 20;
        TreyResearchVATRegNoLbl: Label 'CHE-254.687.456MWST', MaxLength = 20;
        SchoolofFineArtVATRegNoLbl: Label '733495789', MaxLength = 20;
        AlpineSkiHouseVATRegNoLbl: Label '533435789', MaxLength = 20;
        RelecloudVATRegNoLbl: Label 'CHE-582.048.936MWST', MaxLength = 20;
        LUCountyLbl: Label 'LU', MaxLength = 30;
        OWCountyLbl: Label 'OW', MaxLength = 30;
        FLCountyLbl: Label 'FL', MaxLength = 30;
}