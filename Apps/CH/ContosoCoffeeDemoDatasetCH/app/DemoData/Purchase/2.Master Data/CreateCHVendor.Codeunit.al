codeunit 11619 "Create CH Vendor"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    //TODO -Hard coded values pending to replace - Post Code

    [EventSubscriber(ObjectType::Table, Database::Vendor, 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertVendor(var Rec: Record Vendor)
    var
        ContosoCoffeeDemoDataSetup: Record "Contoso Coffee Demo Data Setup";
        CreateCountryRegion: Codeunit "Create Country/Region";
        CreateTerritory: Codeunit "Create Territory";
        CreateVendor: Codeunit "Create Vendor";
    begin
        ContosoCoffeeDemoDataSetup.Get();

        case Rec."No." of
            CreateVendor.ExportFabrikam():
                ValidateRecordFields(Rec, AtlantaCityLbl, CreateTerritory.Foreign(), CreateCountryRegion.US(), 'US-GA 31772', GACountyLbl, FabrikamVATRegNoLbl, '');
            CreateVendor.DomesticFirstUp():
                ValidateRecordFields(Rec, FontannenbWolhusenCityLbl, CreateTerritory.Foreign(), ContosoCoffeeDemoDataSetup."Country/Region Code", '6110', LUCountyLbl, FirstUpVATRegNoLbl, '');
            CreateVendor.EUGraphicDesign():
                ValidateRecordFields(Rec, EningenCityLbl, CreateTerritory.Foreign(), CreateCountryRegion.DE(), 'DE-72800', '', GraphicDesignVATRegNoLbl, '');
            CreateVendor.DomesticWorldImporter():
                ValidateRecordFields(Rec, BallwilCityLbl, CreateTerritory.Foreign(), ContosoCoffeeDemoDataSetup."Country/Region Code", '6275', LUCountyLbl, WorldImporterVATRegNoLbl, '');
            CreateVendor.DomesticNodPublisher():
                ValidateRecordFields(Rec, BuchrainCityLbl, CreateTerritory.Foreign(), ContosoCoffeeDemoDataSetup."Country/Region Code", '6033', LUCountyLbl, NodPublisherVATRegNoLbl, '');
        end;
    end;

    local procedure ValidateRecordFields(var Vendor: Record Vendor; City: Text[30]; TerritoryCode: Code[10]; CountryRegionCode: Code[10]; PostCode: Code[20]; County: Text[30]; VatRegistraionNo: Text[20]; Email: Text[80])
    begin
        Vendor.Validate("Post Code", PostCode);
        Vendor.Validate(City, City);
        Vendor.Validate("Country/Region Code", CountryRegionCode);
        Vendor.Validate(County, County);
        Vendor.Validate("Territory Code", TerritoryCode);
        Vendor.Validate("VAT Registration No.", VatRegistraionNo);
        Vendor.Validate("E-Mail", Email);
    end;

    var
        AtlantaCityLbl: Label 'Atlanta', MaxLength = 30;
        FontannenbWolhusenCityLbl: Label 'Fontannen b. Wolhusen', MaxLength = 30;
        EningenCityLbl: Label 'Eningen', MaxLength = 30;
        BallwilCityLbl: Label 'Ballwil', MaxLength = 30;
        BuchrainCityLbl: Label 'Buchrain', MaxLength = 30;
        FabrikamVATRegNoLbl: Label '503912693', MaxLength = 20;
        FirstUpVATRegNoLbl: Label 'CHE-274.863.274MWST', MaxLength = 20;
        GraphicDesignVATRegNoLbl: Label '521478963', MaxLength = 20;
        WorldImporterVATRegNoLbl: Label 'CHE-197.548.769MWST', MaxLength = 20;
        NodPublisherVATRegNoLbl: Label 'CHE-295.267.495MWST', MaxLength = 20;
        LUCountyLbl: Label 'LU', MaxLength = 30;
        GACountyLbl: Label 'GA', MaxLength = 30;
}