codeunit 27067 "Create CA Vendor"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    //Todo - Hard Coded Post Code to be replace with Post Code Codeuint.

    [EventSubscriber(ObjectType::Table, Database::Vendor, 'OnBeforeOnInsert', '', false, false)]
    local procedure OnInsertRecord(var Vendor: Record Vendor; var IsHandled: Boolean)
    var
        ContosoCoffeeDemoDataSetup: Record "Contoso Coffee Demo Data Setup";
        CreateVendor: Codeunit "Create Vendor";
        CreateVendorPostingGroup: codeunit "Create Vendor Posting Group";
        CreatePostingGroup: Codeunit "Create Posting Groups";
        CreateCATaxArea: Codeunit "Create CA Tax Area";
    begin
        ContosoCoffeeDemoDataSetup.Get();

        case Vendor."No." of
            CreateVendor.ExportFabrikam():
                ValidateRecordFields(Vendor, BayStreetSuiteLbl, '', TorontoCityLbl, '', CreateVendorPostingGroup.Domestic(), ContosoCoffeeDemoDataSetup."Country/Region Code", CreatePostingGroup.DomesticPostingGroup(), 'M5K 1E7', ONLbl, CreateCATaxArea.Ontario(), true, '123456789');
            CreateVendor.DomesticFirstUp():
                ValidateRecordFields(Vendor, StreetSuiteLbl, '', EdmontonCityLbl, '', CreateVendorPostingGroup.Domestic(), ContosoCoffeeDemoDataSetup."Country/Region Code", CreatePostingGroup.DomesticPostingGroup(), 'T5J 4G8', ABLbl, CreateCATaxArea.Alberta(), true, '');
            CreateVendor.EUGraphicDesign():
                ValidateRecordFields(Vendor, WGeorgiaStSuiteLbl, '', VancouverCityLbl, '', CreateVendorPostingGroup.Domestic(), ContosoCoffeeDemoDataSetup."Country/Region Code", CreatePostingGroup.DomesticPostingGroup(), 'V6E 4M3', BCLbl, CreateCATaxArea.BritishColumbia(), true, '');
            CreateVendor.DomesticWorldImporter():
                ValidateRecordFields(Vendor, GranvilleStSuiteLbl, '', VancouverCityLbl, '', CreateVendorPostingGroup.Domestic(), ContosoCoffeeDemoDataSetup."Country/Region Code", CreatePostingGroup.DomesticPostingGroup(), 'V7Y 1L1', BCLbl, CreateCATaxArea.BritishColumbia(), true, '');
            CreateVendor.DomesticNodPublisher():
                ValidateRecordFields(Vendor, McGillCollAvSuiteLbl, '', MontrealCityLbl, '', CreateVendorPostingGroup.Domestic(), ContosoCoffeeDemoDataSetup."Country/Region Code", CreatePostingGroup.DomesticPostingGroup(), 'H3A 3H3', QCLbl, CreateCATaxArea.Quebec(), true, '');
        end;
    end;

    local procedure ValidateRecordFields(var Vendor: Record Vendor; Address: Text[100]; Address2: Text[50]; City: Text[30]; TerritoryCode: Code[10]; VendorPostingGroup: Code[20]; CountryOrRegionCode: Code[10]; GenBusPostingGroup: Code[20]; PostCode: Code[20]; County: Code[20]; TaxAreaCode: Code[20]; TaxLiable: Boolean; VATRegistrationNo: Code[20])
    begin
        Vendor.Validate(Address, Address);
        Vendor.Validate("Address 2", Address2);
        Vendor.Validate(City, City);
        Vendor.Validate("Vendor Posting Group", VendorPostingGroup);
        Vendor.Validate("Territory Code", TerritoryCode);
        Vendor.Validate("Gen. Bus. Posting Group", GenBusPostingGroup);
        Vendor.Validate("VAT Registration No.", VATRegistrationNo);
        Vendor.Validate("Tax Area Code", TaxAreaCode);
        Vendor.Validate("Tax Liable", TaxLiable);
        Vendor.Validate("Country/Region Code", CountryOrRegionCode);
        Vendor.Validate("Post Code", PostCode);
        Vendor.Validate(County, County);
    end;

    var
        BayStreetSuiteLbl: Label '222 Bay Street, Suite 1201', MaxLength = 100;
        StreetSuiteLbl: Label '10155 - 102 Street, Suite 2100', MaxLength = 100;
        WGeorgiaStSuiteLbl: Label '1111 W Georgia St., Suite 1100', MaxLength = 100;
        GranvilleStSuiteLbl: Label '725 Granville St., Suite 700', MaxLength = 100;
        McGillCollAvSuiteLbl: Label '2000 McGill Coll Av, Suite 450', MaxLength = 100;
        TorontoCityLbl: Label 'Toronto', MaxLength = 30;
        EdmontonCityLbl: Label 'Edmonton', MaxLength = 30;
        VancouverCityLbl: Label 'Vancouver', MaxLength = 30;
        MontrealCityLbl: Label 'Montreal', MaxLength = 30;
        ONLbl: Label 'ON', MaxLength = 20;
        ABLbl: Label 'AB', MaxLength = 20;
        BCLbl: Label ' BC', MaxLength = 20;
        QCLbl: Label 'QC', MaxLength = 20;
}