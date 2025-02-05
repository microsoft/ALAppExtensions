codeunit 17144 "Create AU Vendor"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::Vendor, 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnInsertRecords(var Rec: Record Vendor; RunTrigger: Boolean)
    var
        CreateVendor: Codeunit "Create Vendor";
        CreateTerritory: Codeunit "Create Territory";
        CreateCountryRegion: Codeunit "Create Country/Region";
        CreateVendorPostingGroup: Codeunit "Create Vendor Posting Group";
        CreatePaymentTerms: Codeunit "Create Payment Terms";
        CreatePostingGroups: Codeunit "Create Posting Groups";
    begin
        case Rec."No." of
            CreateVendor.ExportFabrikam():
                begin
                    ValidateRecordFields(Rec, ExportFabrikamVATLbl, AtlantaCityLbl, 'US-GA 31772', '', CreateTerritory.Foreign(), CreateVendorPostingGroup.Foreign(), CreateCountryRegion.US(), CreatePaymentTerms.PaymentTermsDAYS30(), CreatePostingGroups.ExportPostingGroup(), '');
                    InsertAddressID(Rec, ExportFabrikamAddressIDLbl);
                end;
            CreateVendor.DomesticFirstUp():
                ValidateRecordFields(Rec, DomesticFirstUpVATLbl, AlbertonCityLbl, '4207', QueenslandCountyLbl, CreateTerritory.Foreign(), CreateVendorPostingGroup.Domestic(), CreateCountryRegion.AU(), CreatePaymentTerms.PaymentTermsDAYS30(), CreatePostingGroups.DomesticPostingGroup(), '');
            CreateVendor.EUGraphicDesign():
                ValidateRecordFields(Rec, EUGraphicDesignVATLbl, EningenCityLbl, 'DE-72800', '', CreateTerritory.Foreign(), CreateVendorPostingGroup.Foreign(), CreateCountryRegion.DE(), CreatePaymentTerms.PaymentTermsDAYS30(), CreatePostingGroups.ExportPostingGroup(), '');
            CreateVendor.DomesticWorldImporter():
                ValidateRecordFields(Rec, DomesticWorldImporterVATLbl, CoorparooCityLbl, '4151', QueenslandCountyLbl, CreateTerritory.Foreign(), CreateVendorPostingGroup.Domestic(), CreateCountryRegion.AU(), CreatePaymentTerms.PaymentTermsDAYS30(), CreatePostingGroups.DomesticPostingGroup(), '');
            CreateVendor.DomesticNodPublisher():
                begin
                    ValidateRecordFields(Rec, DomesticNodPublisherVATLbl, EastMelbourneCityLbl, '3002', VictoriaCountyLbl, CreateTerritory.Foreign(), CreateVendorPostingGroup.Domestic(), CreateCountryRegion.AU(), CreatePaymentTerms.PaymentTermsDAYS30(), CreatePostingGroups.DomesticPostingGroup(), '');
                    InsertAddressID(Rec, DomesticNodPublisherAddressIDLbl);
                end;
        end;
    end;

    local procedure ValidateRecordFields(var Vendor: Record Vendor; VATRegistrationNo: Code[20]; City: Text[30]; PostCode: Code[20]; County: Code[10]; TerritoryCode: Code[10]; VendorPostingGroup: Code[20]; CountryRegionCode: Code[10]; PaymentTermsCode: Code[10]; GenBusPostingGroup: Code[20]; VATBusPostingGroup: Code[20])
    begin
        Vendor.Validate(City, City);
        Vendor.Validate("Post Code", PostCode);
        Vendor.Validate(County, County);
        Vendor.Validate("Territory Code", TerritoryCode);
        Vendor.Validate("Vendor Posting Group", VendorPostingGroup);
        Vendor.Validate("Country/Region Code", CountryRegionCode);
        Vendor.Validate("Payment Terms Code", PaymentTermsCode);
        Vendor.Validate("Gen. Bus. Posting Group", GenBusPostingGroup);
        Vendor.Validate("VAT Bus. Posting Group", VATBusPostingGroup);
        Vendor."VAT Registration No." := VATRegistrationNo;
    end;

    local procedure InsertAddressID(Vendor: Record Vendor; AddressIDField: Text[10])
    var
        AddressID: Record "Address ID";
    begin
        AddressID.Init();
        AddressID.Validate("Table No.", Database::Vendor);
        AddressID.Validate("Table Key", Vendor.GetPosition());
        AddressID.Validate("Address Type", AddressID."Address Type"::Main);
        AddressID.Validate("Address ID", AddressIDField);
        AddressID.Validate("Bar Code System", AddressID."Bar Code System"::"4-State Bar Code");
        AddressID.Insert();
    end;


    var
        AtlantaCityLbl: Label 'Atlanta', MaxLength = 30;
        AlbertonCityLbl: Label 'ALBERTON', MaxLength = 30;
        EningenCityLbl: Label 'Eningen', MaxLength = 30;
        CoorparooCityLbl: Label 'COORPAROO', MaxLength = 30;
        EastMelbourneCityLbl: Label 'EAST MELBOURNE', MaxLength = 30;
        ExportFabrikamVATLbl: Label '503912693', MaxLength = 20;
        DomesticFirstUpVATLbl: Label '274863274B01', MaxLength = 20;
        EUGraphicDesignVATLbl: Label '521478963', MaxLength = 20;
        DomesticWorldImporterVATLbl: Label '197548769B01', MaxLength = 20;
        DomesticNodPublisherVATLbl: Label '295267495B01', MaxLength = 20;
        QueenslandCountyLbl: Label 'QLD', MaxLength = 10;
        VictoriaCountyLbl: Label 'VIC', MaxLength = 10;
        ExportFabrikamAddressIDLbl: Label '20077917', MaxLength = 10;
        DomesticNodPublisherAddressIDLbl: Label '20030073', MaxLength = 10;
}