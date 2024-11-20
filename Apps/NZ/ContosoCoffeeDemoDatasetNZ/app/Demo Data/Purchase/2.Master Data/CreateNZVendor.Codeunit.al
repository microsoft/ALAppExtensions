codeunit 17133 "Create NZ Vendor"
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
        CreateVendorPostingGroup: codeunit "Create Vendor Posting Group";
        CreatePaymentTerms: Codeunit "Create Payment Terms";
        CreateCountryRegion: Codeunit "Create Country/Region";
        CreatePostingGroup: Codeunit "Create Posting Groups";
        CreateVatPostingGroups: Codeunit "Create VAT Posting Groups";
    begin
        case Rec."No." of
            CreateVendor.ExportFabrikam():
                ValidateRecordFields(Rec, AtlantaCityLbl, ExportFabrikamVatRegNoLbl, ExportFabrikamPostCodeLbl, CreateTerritory.Foreign(), CreateVendorPostingGroup.Foreign(), CreatePaymentTerms.PaymentTermsDAYS30(), CreateCountryRegion.US(), CreatePostingGroup.ExportPostingGroup(), CreateVatPostingGroups.Export(), '');
            CreateVendor.DomesticFirstUp():
                ValidateRecordFields(Rec, AnnesBrookCityLbl, DomesticFirstUpVatRegNoLbl, DomesticFirstUpPostCodeLbl, CreateTerritory.Foreign(), CreateVendorPostingGroup.Domestic(), CreatePaymentTerms.PaymentTermsDAYS30(), CreateCountryRegion.NZ(), CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroups.Domestic(), '');
            CreateVendor.EUGraphicDesign():
                ValidateRecordFields(Rec, EningenCityLbl, EUGraphicDesignVatRegNoLbl, EUGraphicDesignPostCodeLbl, CreateTerritory.Foreign(), CreateVendorPostingGroup.Foreign(), CreatePaymentTerms.PaymentTermsDAYS30(), CreateCountryRegion.DE(), CreatePostingGroup.ExportPostingGroup(), CreateVatPostingGroups.Export(), '');
            CreateVendor.DomesticWorldImporter():
                ValidateRecordFields(Rec, AlicetownCityLbl, DomesticWorldImporterVatRegNoLbl, DomesticWorldImporterPostCodeLbl, CreateTerritory.Foreign(), CreateVendorPostingGroup.Domestic(), CreatePaymentTerms.PaymentTermsDAYS30(), CreateCountryRegion.NZ(), CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroups.Domestic(), '');
            CreateVendor.DomesticNodPublisher():
                ValidateRecordFields(Rec, AnnesBrookCityLbl, DomesticNodPublisherVatRegNoLbl, DomesticNodPublisherPostCodeLbl, CreateTerritory.Foreign(), CreateVendorPostingGroup.Domestic(), CreatePaymentTerms.PaymentTermsDAYS30(), CreateCountryRegion.NZ(), CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroups.Domestic(), '');
        end;
    end;

    local procedure ValidateRecordFields(var Vendor: Record Vendor; City: Text[30]; VatRegNo: Text[20]; PostCode: Code[20]; TerritoryCode: Code[10]; VendorPostingGroup: Code[20]; PaymentTermsCode: Code[10]; CountryRegionCode: Code[10]; GenBusPostingGroup: Code[20]; VATBusPostingGroup: Code[20]; County: Text[30])
    begin
        Vendor.Validate(City, City);
        Vendor.Validate("Post Code", PostCode);
        Vendor.Validate("VAT Registration No.", VatRegNo);
        Vendor.Validate("Territory Code", TerritoryCode);
        Vendor.Validate("Vendor Posting Group", VendorPostingGroup);
        Vendor.Validate("Payment Terms Code", PaymentTermsCode);
        Vendor.Validate("Country/Region Code", CountryRegionCode);
        Vendor.Validate("Gen. Bus. Posting Group", GenBusPostingGroup);
        Vendor.Validate("VAT Bus. Posting Group", VATBusPostingGroup);
        Vendor.Validate(County, County);
    end;

    var
        AtlantaCityLbl: Label 'Atlanta', MaxLength = 30, Locked = true;
        AnnesBrookCityLbl: Label 'Annes Brook', MaxLength = 30, Locked = true;
        EningenCityLbl: Label 'Eningen', MaxLength = 30, Locked = true;
        AlicetownCityLbl: Label 'Alicetown', MaxLength = 30, Locked = true;
        ExportFabrikamVatRegNoLbl: Label '503912693', MaxLength = 20;
        DomesticFirstUpVatRegNoLbl: Label '274863274', MaxLength = 20;
        EUGraphicDesignVatRegNoLbl: Label '521478963', MaxLength = 20;
        DomesticWorldImporterVatRegNoLbl: Label '197548769', MaxLength = 20;
        DomesticNodPublisherVatRegNoLbl: Label '295267495', MaxLength = 20;
        ExportFabrikamPostCodeLbl: Label 'US-GA 31772', MaxLength = 20;
        DomesticFirstUpPostCodeLbl: Label '7001', MaxLength = 20;
        EUGraphicDesignPostCodeLbl: Label 'DE-72800', MaxLength = 20;
        DomesticWorldImporterPostCodeLbl: Label '6008', MaxLength = 20;
        DomesticNodPublisherPostCodeLbl: Label '7001', MaxLength = 20;
}