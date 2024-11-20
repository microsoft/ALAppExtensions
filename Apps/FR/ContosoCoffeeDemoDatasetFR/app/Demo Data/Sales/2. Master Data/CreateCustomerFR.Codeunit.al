codeunit 10886 "Create Customer FR"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::Customer, 'OnBeforeInsert', '', false, false)]
    local procedure OnBeforeInsertCustomer(var Customer: Record Customer)
    var
        ContosoCoffeeDemoDataSetup: Record "Contoso Coffee Demo Data Setup";
        CreateLanguage: Codeunit "Create Language";
        CreateCustomer: Codeunit "Create Customer";
        CreateVendorPostingGroup: codeunit "Create Vendor Posting Group";
    begin
        ContosoCoffeeDemoDataSetup.Get();
        case Customer."No." of
            CreateCustomer.DomesticAdatumCorporation():
                ValidateCustomer(Customer, CreateLanguage.FRA(), ContosoCoffeeDemoDataSetup."Country/Region Code", CreateVendorPostingGroup.Foreign(), PostCode69001Lbl, 'FR78945627890', LyonCityLbl);
            CreateCustomer.DomesticTreyResearch():
                ValidateCustomer(Customer, CreateLanguage.FRA(), ContosoCoffeeDemoDataSetup."Country/Region Code", CreateVendorPostingGroup.Foreign(), PostCode37000Lbl, 'FR25468745678', ToursCityLbl);
            CreateCustomer.DomesticRelecloud():
                ValidateCustomer(Customer, CreateLanguage.FRA(), ContosoCoffeeDemoDataSetup."Country/Region Code", CreateVendorPostingGroup.Foreign(), PostCode75008Lbl, 'FR58204893678', ParisCityLbl);

            CreateCustomer.ExportSchoolofArt():
                Customer.Validate("VAT Registration No.", ExportSchoolofArtVatRegLbl);
            CreateCustomer.EUAlpineSkiHouse():
                Customer.Validate("VAT Registration No.", EUAlpineSkiHouseVatRegLbl);
        end;
    end;

    local procedure ValidateCustomer(var Customer: Record Customer; LanguageCode: Code[10]; CountryRegionCode: Code[10]; TerritoryCode: Code[20]; PostCode: Code[20]; VatRegistraionNo: Text[20]; City: Text[30])
    begin
        Customer.Validate("Language Code", LanguageCode);
        Customer."VAT Registration No." := VatRegistraionNo;
        if CountryRegionCode <> '' then
            Customer.Validate("Country/Region Code", CountryRegionCode);
        Customer.Validate(City, City);
        Customer.Validate("Post Code", PostCode);
        Customer.Validate("Territory Code", TerritoryCode);
    end;

    var
        LyonCityLbl: Label 'Lyon', MaxLength = 30;
        ToursCityLbl: Label 'Tours', MaxLength = 30;
        ParisCityLbl: Label 'Paris', MaxLength = 30;
        ExportSchoolofArtVatRegLbl: Label '733495789', MaxLength = 20;
        EUAlpineSkiHouseVatRegLbl: Label '533435789', MaxLength = 20;
        PostCode69001Lbl: Label '69001', MaxLength = 20;
        PostCode37000Lbl: Label '37000', MaxLength = 20;
        PostCode75008Lbl: Label '75008', MaxLength = 20;
}