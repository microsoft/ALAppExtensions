codeunit 13730 "Create Vendor DK"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::Vendor, 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertVendor(var Rec: Record Vendor)
    var
        CreateVendor: Codeunit "Create Vendor";
        CreateTerritory: Codeunit "Create Territory";
        CreateVendorPostingGroup: Codeunit "Create Vendor Posting Group";
        CreateCountryRegion: Codeunit "Create Country/Region";
        CreatePostingGroups: Codeunit "Create Posting Groups";
        CreateVatPostingGroups: Codeunit "Create Vat Posting Groups";
    begin
        case Rec."No." of
            CreateVendor.ExportFabrikam():
                ValidateRecordFields(Rec, LondonPostmasterLbl, LondonPostmasterAddressLbl, '', CopenhagenKCityLbl, '', CreateVendorPostingGroup.Domestic(), CreateCountryRegion.DK(), '', CreatePostingGroups.DomesticPostingGroup(), PostCode1152Lbl, CreateVatPostingGroups.Domestic());
            CreateVendor.DomesticFirstUp():
                ValidateRecordFields(Rec, ARDayPropertyManagementLbl, ARDayPropertyManagementAddressLbl, '', KogeCityLbl, '', CreateVendorPostingGroup.Domestic(), CreateCountryRegion.DK(), '', CreatePostingGroups.DomesticPostingGroup(), PostCode4600Lbl, CreateVatPostingGroups.Domestic());
            CreateVendor.EUGraphicDesign():
                ValidateRecordFields(Rec, CoolWoodTechnologiesLbl, CoolWoodTechnologiesAddressLbl, '', CopenhagenCityLbl, '', CreateVendorPostingGroup.Domestic(), CreateCountryRegion.DK(), '', CreatePostingGroups.DomesticPostingGroup(), PostCode2100Lbl, CreateVatPostingGroups.Domestic());
            CreateVendor.DomesticWorldImporter():
                ValidateRecordFields(Rec, LewisHomeFurnitureLbl, LewisHomeFurnitureAddressLbl, '', ManchesterCityLbl, CreateTerritory.Foreign(), CreateVendorPostingGroup.EU(), CreateCountryRegion.GB(), GBVatRegNoLbl, CreatePostingGroups.EUPostingGroup(), GBM225TGPostCodeLbl, CreateVatPostingGroups.EU());
            CreateVendor.DomesticNodPublisher():
                ValidateRecordFields(Rec, ServiceElectronicsLbl, ServiceElectronicsAddressLbl, '', AtlantaCityLbl, CreateTerritory.Foreign(), CreateVendorPostingGroup.Foreign(), CreateCountryRegion.US(), '', CreatePostingGroups.ExportPostingGroup(), USGA31772PostCodeLbl, CreateVatPostingGroups.Export());
        end;
    end;

    local procedure ValidateRecordFields(var Vendor: Record Vendor; Name: Text[100]; Address: Text[100]; Address2: Text[50]; City: Text[30]; TerritoryCode: Code[10]; VendorPostingGroupCode: Code[20]; CountryRegionCode: Code[10]; VatRegNo: Text[20]; GenBusPostingGroup: Code[20]; PostCode: Code[20]; VATBusPostingGroupCode: Code[20])
    var
        CreateVendor: Codeunit "Create Vendor";
    begin
        Vendor.Validate(Name, Name);
        Vendor.Validate(Address, Address);
        Vendor.Validate("Address 2", Address2);
        Vendor.Validate(City, City);
        Vendor.Validate("Territory Code", TerritoryCode);
        Vendor.Validate("Vendor Posting Group", VendorPostingGroupCode);
        Vendor.Validate("Country/Region Code", CountryRegionCode);
        Vendor.Validate("VAT Registration No.", VatRegNo);
        Vendor.Validate("Gen. Bus. Posting Group", GenBusPostingGroup);
        Vendor.Validate("Post Code", PostCode);
        Vendor.Validate("VAT Bus. Posting Group", VATBusPostingGroupCode);
        if Vendor."No." = CreateVendor.DomesticNodPublisher() then
            Vendor.Validate(County, '');
    end;

    var
        LondonPostmasterLbl: Label 'London Postmaster', Maxlength = 100;
        ARDayPropertyManagementLbl: Label 'AR Day Property Management', Maxlength = 100;
        CoolWoodTechnologiesLbl: Label 'CoolWood Technologies', Maxlength = 100;
        LewisHomeFurnitureLbl: Label 'Lewis Home Furniture', Maxlength = 100;
        ServiceElectronicsLbl: Label 'Service Electronics Ltd.', Maxlength = 100;
        LondonPostmasterAddressLbl: Label '10 North Lake Avenue', MaxLength = 100, Locked = true;
        ARDayPropertyManagementAddressLbl: Label '100 Day Drive', MaxLength = 100, Locked = true;
        CoolWoodTechnologiesAddressLbl: Label '33 Hitech Drive', MaxLength = 100, Locked = true;
        LewisHomeFurnitureAddressLbl: Label '51 Radcroft Road', MaxLength = 100, Locked = true;
        ServiceElectronicsAddressLbl: Label '172 Field Green', MaxLength = 100, Locked = true;
        CopenhagenKCityLbl: Label 'Copenhagen K', MaxLength = 30, Locked = true;
        KogeCityLbl: Label 'Koge', MaxLength = 30, Locked = true;
        CopenhagenCityLbl: Label 'Copenhagen', MaxLength = 30, Locked = true;
        ManchesterCityLbl: Label 'Manchester', MaxLength = 30, Locked = true;
        AtlantaCityLbl: Label 'Atlanta', MaxLength = 30, Locked = true;
        GBVatRegNoLbl: Label 'GB555555555', MaxLength = 20;
        PostCode1152Lbl: Label '1152', MaxLength = 20;
        PostCode4600Lbl: Label '4600', MaxLength = 20;
        PostCode2100Lbl: Label '2100', MaxLength = 20;
        GBM225TGPostCodeLbl: Label 'GB-M22 5TG', MaxLength = 20;
        USGA31772PostCodeLbl: Label 'US-GA 31772', MaxLength = 20;
}