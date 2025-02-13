codeunit 10812 "Create ES Vendor"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    //Todo - Hard Coded Post Code to be replace with Post Code Codeuint.

    [EventSubscriber(ObjectType::Table, Database::Vendor, 'OnBeforeOnInsert', '', false, false)]
    local procedure OnInsertRecord(var Vendor: Record Vendor; var IsHandled: Boolean)
    var
        CreateVendor: Codeunit "Create Vendor";
        CreateTerritory: Codeunit "Create Territory";
        CreateCountryRegion: Codeunit "Create Country/Region";
        CreatePaymentTerms: Codeunit "Create Payment Terms";
        CreateESPaymentTerms: Codeunit "Create ES Payment Terms";
        CreatePaymentMethod: Codeunit "Create Payment Method";
        CreateESPaymentMethod: Codeunit "Create ES Payment Method";
    begin
        case Vendor."No." of
            CreateVendor.ExportFabrikam():
                ValidateRecordFields(Vendor, ExportFabrikamVATLbl, AtlantaCityLbl, 'US-GA 31772', CreateTerritory.Foreign(), CreateCountryRegion.US(), CreatePaymentTerms.PaymentTermsCM(), CreatePaymentMethod.Bank(), 'GA');
            CreateVendor.DomesticFirstUp():
                ValidateRecordFields(Vendor, DomesticFirstUpVATLbl, ValenciaCityLbl, '46022', CreateTerritory.Foreign(), CreateCountryRegion.ES(), CreatePaymentTerms.PaymentTermsCM(), CreatePaymentMethod.Bank(), ValenciaCountyLbl);
            CreateVendor.EUGraphicDesign():
                ValidateRecordFields(Vendor, EUGraphicDesignVATLbl, EningenCityLbl, 'DE-72800', CreateTerritory.Foreign(), CreateCountryRegion.DE(), CreatePaymentTerms.PaymentTermsCM(), CreatePaymentMethod.Bank(), '');
            CreateVendor.DomesticWorldImporter():
                ValidateRecordFields(Vendor, DomesticWorldImporterVATLbl, SanSebastianCityLbl, '20001', CreateTerritory.Foreign(), CreateCountryRegion.ES(), CreateESPaymentTerms.PaymentTermsDays3x30(), CreateESPaymentMethod.Pagare(), '');
            CreateVendor.DomesticNodPublisher():
                ValidateRecordFields(Vendor, DomesticNodPublisherVATLbl, AlicanteCityLbl, '03003', CreateTerritory.Foreign(), CreateCountryRegion.ES(), CreatePaymentTerms.PaymentTermsCM(), CreatePaymentMethod.Bank(), AlicanteCountyLbl);
        end;
    end;

    local procedure ValidateRecordFields(var Vendor: Record Vendor; VATRegistrationNo: Code[20]; City: Text[30]; PostCode: Code[20]; TerritoryCode: Code[10]; CountryRegionCode: Code[10]; PaymentTermsCode: Code[10]; PaymentMethodCode: Code[10]; VendorCounty: Text[30])
    begin
        Vendor.Validate(City, City);
        Vendor.Validate("Post Code", PostCode);
        Vendor.Validate("Territory Code", TerritoryCode);
        Vendor."VAT Registration No." := VATRegistrationNo;
        if CountryRegionCode <> '' then
            Vendor.Validate("Country/Region Code", CountryRegionCode);
        Vendor.Validate("Payment Terms Code", PaymentTermsCode);
        Vendor.Validate("Payment Method Code", PaymentMethodCode);
        Vendor.Validate(County, VendorCounty);
    end;

    var
        AtlantaCityLbl: Label 'Atlanta', MaxLength = 30;
        ValenciaCityLbl: Label 'Valencia', MaxLength = 30;
        ValenciaCountyLbl: Label 'VALENCIA', MaxLength = 30;
        EningenCityLbl: Label 'Eningen', MaxLength = 30;
        SanSebastianCityLbl: Label 'San Sebastian', MaxLength = 30;
        AlicanteCityLbl: Label 'Alicante', MaxLength = 30;
        AlicanteCountyLbl: Label 'ALICANTE/ALACANT', MaxLength = 30;
        ExportFabrikamVATLbl: Label '503912693', MaxLength = 20;
        DomesticFirstUpVATLbl: Label '274863274A', MaxLength = 20;
        EUGraphicDesignVATLbl: Label '521478963', MaxLength = 20;
        DomesticWorldImporterVATLbl: Label '197548769A', MaxLength = 20;
        DomesticNodPublisherVATLbl: Label '295267495A', MaxLength = 20;
}