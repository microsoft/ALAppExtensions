codeunit 10512 "Create Vendor US"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    //Todo - Hard Coded Post Code to be replace with Post Code Codeuint.

    [EventSubscriber(ObjectType::Table, Database::Vendor, 'OnBeforeOnInsert', '', false, false)]
    local procedure OnInsertRecord(var Vendor: Record Vendor; var IsHandled: Boolean)
    var
        CreateCountryRegion: Codeunit "Create Country/Region";
        CreateVendor: Codeunit "Create Vendor";
        CreateVendorPostingGroup: codeunit "Create Vendor Posting Group";
        CreatePostingGroup: Codeunit "Create Posting Groups";
        CreateTaxAreaUS: Codeunit "Create Tax Area US";
    begin
        case Vendor."No." of
            CreateVendor.ExportFabrikam():
                ValidateRecordFields(Vendor, NorthLakeAvenueLbl, AtlantaCityLbl, '4255550101', CreateVendorPostingGroup.Domestic(), CreateCountryRegion.US(), CreatePostingGroup.DomesticPostingGroup(), '31772', GaLbl, CreateTaxAreaUS.AtlantaGa(), true, '', '', '');
            CreateVendor.DomesticFirstUp():
                ValidateRecordFields(Vendor, DayDrive100Lbl, ChicagoCityLbl, '', CreateVendorPostingGroup.Domestic(), CreateCountryRegion.US(), CreatePostingGroup.DomesticPostingGroup(), '61236', IlLbl, CreateTaxAreaUS.ChicagoIl(), true, '', '', '');
            CreateVendor.EUGraphicDesign():
                ValidateRecordFields(Vendor, HitechDrive33Lbl, MiamiCityLbl, '', CreateVendorPostingGroup.Domestic(), CreateCountryRegion.US(), CreatePostingGroup.DomesticPostingGroup(), '37125', FlLbl, CreateTaxAreaUS.MiamiFl(), true, '', '', '');
            CreateVendor.DomesticWorldImporter():
                ValidateRecordFields(Vendor, RadcroftRoad51Lbl, AtlantaCityLbl, '', CreateVendorPostingGroup.Domestic(), CreateCountryRegion.US(), CreatePostingGroup.DomesticPostingGroup(), '31772', GaLbl, CreateTaxAreaUS.NAtlGa(), true, '', '', '');
            CreateVendor.DomesticNodPublisher():
                ValidateRecordFields(Vendor, FieldGreen172Lbl, AtlantaCityLbl, '', CreateVendorPostingGroup.Domestic(), CreateCountryRegion.US(), CreatePostingGroup.DomesticPostingGroup(), '31772', GaLbl, CreateTaxAreaUS.AtlantaGa(), true, '', '', '');
        end;
    end;

    local procedure ValidateRecordFields(var Vendor: Record Vendor; Address: Text[100]; City: Text[30]; PhoneNo: Text[30]; VendorPostingGroup: Code[20]; CountryOrRegionCode: Code[10]; GenBusPostingGroup: Code[20]; PostCode: Code[20]; County: Code[20]; TaxAreaCode: Code[20]; TaxLiable: Boolean; Address2: Text[50]; TerritoryCode: Code[10]; VATBusPostingGroup: Code[20])
    begin
        Vendor.Validate(Address, Address);
        Vendor.Validate("Address 2", Address2);
        Vendor.Validate(City, City);
        Vendor.Validate("Phone No.", PhoneNo);
        Vendor.Validate("Vendor Posting Group", VendorPostingGroup);
        Vendor.Validate("Territory Code", TerritoryCode);
        Vendor.Validate("Gen. Bus. Posting Group", GenBusPostingGroup);
        Vendor.Validate("VAT Bus. Posting Group", VATBusPostingGroup);
        Vendor.Validate("Tax Area Code", TaxAreaCode);
        Vendor.Validate("Tax Liable", TaxLiable);
        Vendor.Validate("Country/Region Code", CountryOrRegionCode);
        Vendor.Validate("Post Code", PostCode);
        Vendor.Validate(County, County);
    end;

    var
        NorthLakeAvenueLbl: Label '10 North Lake Avenue', MaxLength = 100;
        DayDrive100Lbl: Label '100 Day Drive', MaxLength = 100;
        HitechDrive33Lbl: Label '33 Hitech Drive', MaxLength = 100;
        RadcroftRoad51Lbl: Label '51 Radcroft Road', MaxLength = 100;
        FieldGreen172Lbl: Label '172 Field Green', MaxLength = 100;
        AtlantaCityLbl: Label 'Atlanta', MaxLength = 30;
        ChicagoCityLbl: Label 'Chicago', MaxLength = 30;
        MiamiCityLbl: Label 'Miami', MaxLength = 30;
        GaLbl: Label 'GA', MaxLength = 20;
        IlLbl: Label 'IL', MaxLength = 20;
        FlLbl: Label 'FL', MaxLength = 20;
}