// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Purchases;

using Microsoft.DemoTool.Helpers;
using Microsoft.DemoData.Finance;
using Microsoft.Purchases.Vendor;
using Microsoft.DemoTool;
using Microsoft.DemoData.Inventory;
using Microsoft.DemoData.Foundation;
using Microsoft.Finance.TaxBase;
using Microsoft.Finance.GST.Base;

codeunit 19036 "Create IN Vendor"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoINTaxSetup: Codeunit "Contoso IN Tax Setup";
        CreatVendor: Codeunit "Create Vendor";
        CreateINTDSSection: Codeunit "Create IN TDS Section";
        CreateINTDSNatureofRem: Codeunit "Create IN TDS Nature of Rem.";
        CreateINActApplicable: Codeunit "Create IN Act Applicable";
    begin
        ContosoINTaxSetup.CreateVendorAllowedSection(CreatVendor.EUGraphicDesign(), CreateINTDSSection.Section194ILB(), true, true, false, '', '');
        ContosoINTaxSetup.CreateVendorAllowedSection(CreatVendor.EUGraphicDesign(), CreateINTDSSection.Section194JPF(), true, true, false, '', '');
        ContosoINTaxSetup.CreateVendorAllowedSection(CreatVendor.EUGraphicDesign(), CreateINTDSSection.SectionS(), true, true, false, '', '');
        ContosoINTaxSetup.CreateVendorAllowedSection(CreatVendor.DomesticWorldImporter(), CreateINTDSSection.Section195(), true, true, true, CreateINActApplicable.IncomeTaxAct(), CreateINTDSNatureofRem.NatureofRemittance16());
    end;

    [EventSubscriber(ObjectType::Table, Database::Vendor, 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertVendor(var Rec: Record Vendor)
    var
        ContosoCoffeeDemoDataSetup: Record "Contoso Coffee Demo Data Setup";
        CreateVendor: Codeunit "Create Vendor";
        CreateTerritory: Codeunit "Create Territory";
        CreatePostingGroups: Codeunit "Create Posting Groups";
        CreateVATPostingGroups: Codeunit "Create VAT Posting Groups";
        CreateCountryRegion: Codeunit "Create Country/Region";
        CreateINLocation: Codeunit "Create IN Location";
        CreateVendorPostingGroup: Codeunit "Create Vendor Posting Group";
        CreateINAssesseeCode: Codeunit "Create IN Assessee Code";
        CreateINState: Codeunit "Create IN State";
        CreateCurrency: Codeunit "Create Currency";
    begin
        ContosoCoffeeDemoDataSetup.Get();
        case Rec."No." of
            CreateVendor.ExportFabrikam():
                ValidateRecordFields(Rec, LondonPostmasterLbl, NorthLakeAvenueAddressLbl, '', NewDelhiCityLbl, CreateTerritory.London(), CreateVendorPostingGroup.Domestic(), ContosoCoffeeDemoDataSetup."Country/Region Code", CreateINLocation.BlueLocation(), ExportFabrikamVatRegNoLbl, CreatePostingGroups.DomesticPostingGroup(), '', PostCode110001Lbl, 'mrs.carol.philips@contoso.com', CreateVATPostingGroups.Domestic(), '', 'CONQB0007I', Enum::"P.A.N.Status"::" ", '', CreateINState.Delhi(), '07CONQB0007I1Z3', Enum::"GST Vendor Type"::Registered, '');
            CreateVendor.DomesticFirstUp():
                ValidateRecordFields(Rec, ARDayPropertyManagementLbl, DayDriveAddressLbl, '', ChicagoCityLbl, CreateTerritory.Foreign(), CreateVendorPostingGroup.Foreign(), CreateCountryRegion.US(), CreateINLocation.BlueLocation(), DomesticFirstUpVatRgeNoLbl, CreatePostingGroups.ExportPostingGroup(), '', USIL61236PostCodeLbl, 'mr.frank.lee@contoso.com', CreateVATPostingGroups.Export(), '', '', Enum::"P.A.N.Status"::" ", '', '', '', Enum::"GST Vendor Type"::" ", CreateCurrency.USD());
            CreateVendor.EUGraphicDesign():
                ValidateRecordFields(Rec, CoolWoodTechnologiesLbl, HitechDriveAddressLbl, '', NewDelhiCityLbl, CreateTerritory.South(), CreateVendorPostingGroup.Domestic(), ContosoCoffeeDemoDataSetup."Country/Region Code", CreateINLocation.BlueLocation(), EUGraphicDesignVatRegNoLbl, CreatePostingGroups.DomesticPostingGroup(), '', PostCode110001Lbl, 'mr.richard.bready@contoso.com', CreateVATPostingGroups.Domestic(), CreateINAssesseeCode.Company(), 'LOCAT7888A', Enum::"P.A.N.Status"::" ", '', CreateINState.Delhi(), '', Enum::"GST Vendor Type"::" ", '');
            CreateVendor.DomesticWorldImporter():
                ValidateRecordFields(Rec, LewisHomeFurnitureLbl, RadcroftRoadAddressLbl, '', AtlantaCityLbl, CreateTerritory.Foreign(), CreateVendorPostingGroup.Foreign(), CreateCountryRegion.US(), CreateINLocation.RedLocation(), DomesticWorldImporterVatRegNoLbl, CreatePostingGroups.ExportPostingGroup(), 'GA', USGA31772PostCodeLbl, 'mrs.julia.collins@contoso.com', CreateVATPostingGroups.Export(), CreateINAssesseeCode.NonResidentIndian(), 'PANNOTAVBL', Enum::"P.A.N.Status"::PANNOTAVBL, 'PANNOTAVBL', '', '', Enum::"GST Vendor Type"::" ", CreateCurrency.USD());
            CreateVendor.DomesticNodPublisher():
                ValidateRecordFields(Rec, ServiceElectronicsLtdLbl, FieldGreenAddressLbl, '', NewDelhiCityLbl, CreateTerritory.London(), CreateVendorPostingGroup.Domestic(), ContosoCoffeeDemoDataSetup."Country/Region Code", CreateINLocation.BlueLocation(), DomesticNodPublisherVatRegNoLbl, CreatePostingGroups.DomesticPostingGroup(), '', PostCode110001Lbl, 'mr.marc.zimmerman@contoso.com', CreateVATPostingGroups.Domestic(), '', '', Enum::"P.A.N.Status"::" ", '', CreateINState.Delhi(), '', Enum::"GST Vendor Type"::Unregistered, '');
        end;
    end;

    local procedure ValidateRecordFields(var Vendor: Record Vendor; Name: Text[100]; Address: Text[100]; Address2: Text[50]; City: Text[30]; TerritoryCode: Code[10]; VendorPostingGroup: Code[20]; CountryRegionCode: Code[10]; LocationCode: Code[10]; VatRegNo: Text[20]; GenBusPostingGroup: Code[20]; County: Text[30]; PostCode: Code[20]; Email: Text[80]; VATBusPostingGroup: Code[20]; AssesseeCode: Code[10]; PANNo: Code[20]; PANStatus: Enum "P.A.N.Status"; PANReferenceNo: Code[20]; StateCode: Code[10]; GSTRegistrationNo: Code[20]; GSTVendorType: Enum "GST Vendor Type"; CurrencyCode: COde[10])
    begin
        Vendor.Validate(Name, Name);
        Vendor.Validate(Address, Address);
        Vendor.Validate("Address 2", Address2);
        Vendor.Validate(City, City);
        Vendor.Validate("Territory Code", TerritoryCode);
        Vendor.Validate("Vendor Posting Group", VendorPostingGroup);
        Vendor.Validate("VAT Registration No.", VatRegNo);
        Vendor.Validate("Post Code", PostCode);
        Vendor.Validate(County, County);
        Vendor.Validate("Country/Region Code", CountryRegionCode);
        Vendor.Validate("Location Code", LocationCode);
        Vendor.Validate("Gen. Bus. Posting Group", GenBusPostingGroup);
        Vendor.Validate("Currency Code", CurrencyCode);
        Vendor.Validate("E-Mail", Email);
        Vendor.Validate("VAT Bus. Posting Group", VATBusPostingGroup);
        Vendor.Validate("Assessee Code", AssesseeCode);
        Vendor.Validate("P.A.N. Status", PANStatus);
        Vendor.Validate("P.A.N. No.", PANNo);
        Vendor.Validate("P.A.N. Reference No.", PANReferenceNo);
        Vendor.Validate("State Code", StateCode);
        Vendor."GST Registration No." := GSTRegistrationNo;
        Vendor."GST Vendor Type" := GSTVendorType;
    end;

    var
        LondonPostmasterLbl: Label 'London Postmaster', MaxLength = 100;
        ARDayPropertyManagementLbl: Label 'AR Day Property Management', MaxLength = 100;
        CoolWoodTechnologiesLbl: Label 'CoolWood Technologies', MaxLength = 100;
        LewisHomeFurnitureLbl: Label 'Lewis Home Furniture', MaxLength = 100;
        ServiceElectronicsLtdLbl: Label 'Service Electronics Ltd.', MaxLength = 100;
        NorthLakeAvenueAddressLbl: Label '10 North Lake Avenue', MaxLength = 100, Locked = true;
        DayDriveAddressLbl: Label '100 Day Drive', MaxLength = 100, Locked = true;
        HitechDriveAddressLbl: Label '33 Hitech Drive', MaxLength = 100, Locked = true;
        RadcroftRoadAddressLbl: Label '51 Radcroft Road', MaxLength = 100, Locked = true;
        FieldGreenAddressLbl: Label '172 Field Green', MaxLength = 100, Locked = true;
        NewDelhiCityLbl: Label 'New Delhi', MaxLength = 30, Locked = true;
        AtlantaCityLbl: Label 'Atlanta', MaxLength = 30, Locked = true;
        ChicagoCityLbl: Label 'Chicago', MaxLength = 30, Locked = true;
        ExportFabrikamVatRegNoLbl: Label '895741963', MaxLength = 20;
        DomesticFirstUpVatRgeNoLbl: Label '274863274', MaxLength = 20;
        EUGraphicDesignVatRegNoLbl: Label '697528465', MaxLength = 20;
        DomesticWorldImporterVatRegNoLbl: Label '197548769', MaxLength = 20;
        DomesticNodPublisherVatRegNoLbl: Label '295267495', MaxLength = 20;
        USGA31772PostCodeLbl: Label 'US-GA 31772', MaxLength = 20;
        USIL61236PostCodeLbl: Label 'US-IL 61236', MaxLength = 20;
        PostCode110001Lbl: Label '110001', MaxLength = 20;
}
