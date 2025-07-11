// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Sales;

using Microsoft.DemoTool.Helpers;
using Microsoft.DemoData.Finance;
using Microsoft.Sales.Customer;
using Microsoft.DemoTool;
using Microsoft.DemoData.Foundation;
using Microsoft.DemoData.Inventory;
using Microsoft.DemoData.CRM;
using Microsoft.Finance.GST.Base;

codeunit 19015 "Create IN Customer"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoINTaxSetup: Codeunit "Contoso IN Tax Setup";
        CreateCustomer: Codeunit "Create Customer";
        CreateINTDSSection: Codeunit "Create IN TDS Section";
        CreateINTCSNatureofColl: Codeunit "Create IN TCS Nature of Coll.";
    begin
        UpdateContactOnCustomer(CreateCustomer.DomesticAdatumCorporation(), RobertTownesLbl);
        UpdateContactOnCustomer(CreateCustomer.DomesticTreyResearch(), HelenRayLbl);
        UpdateContactOnCustomer(CreateCustomer.ExportSchoolofArt(), MeaganBondLbl);
        UpdateContactOnCustomer(CreateCustomer.EUAlpineSkiHouse(), IanDeberryLbl);
        UpdateContactOnCustomer(CreateCustomer.DomesticRelecloud(), JimStewartLbl);
        ContosoINTaxSetup.CreateCustomerAllowedSection(CreateCustomer.EUAlpineSkiHouse(), CreateINTDSSection.Section194ILB(), true, true);
        ContosoINTaxSetup.CreateCustomerAllowedSection(CreateCustomer.EUAlpineSkiHouse(), CreateINTDSSection.SectionS(), true, true);
        ContosoINTaxSetup.CreateCustomerAllowedNOC(CreateCustomer.DomesticRelecloud(), CreateINTCSNatureofColl.NatureofCollectionA(), true, true);
    end;

    local procedure UpdateContactOnCustomer(CustomerNo: Code[20]; ContactName: Text[100])
    var
        Customer: Record Customer;
    begin
        if Customer.Get(CustomerNo) then begin
            Customer.Validate(Contact, ContactName);
            Customer.Modify(true);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::Customer, 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertCustomer(var Rec: Record Customer)
    var
        ContosoCoffeeDemoDataSetup: Record "Contoso Coffee Demo Data Setup";
        CreateCustomer: Codeunit "Create Customer";
        CreateLanguage: Codeunit "Create Language";
        CreateTerritory: Codeunit "Create Territory";
        CreatePostingGroups: Codeunit "Create Posting Groups";
        CreateVATPostingGroups: Codeunit "Create VAT Posting Groups";
        CreateCountryRegion: Codeunit "Create Country/Region";
        CreateINLocation: Codeunit "Create IN Location";
        CreateCustomerPostingGroup: Codeunit "Create Customer Posting Group";
        CreatePaymentTerms: Codeunit "Create Payment Terms";
        CreateSalespersonPurchaser: Codeunit "Create Salesperson/Purchaser";
        CreateReminderTerms: Codeunit "Create Reminder Terms";
        CreateINAssesseeCode: Codeunit "Create IN Assessee Code";
        CreateINState: Codeunit "Create IN State";
    begin
        ContosoCoffeeDemoDataSetup.Get();
        case Rec."No." of
            CreateCustomer.DomesticAdatumCorporation():
                ValidateRecordFields(Rec, TheCannonGroupPLCLbl, StationRoadAddressLbl, '', NewDelhiCityLbl, CreateTerritory.Midlands(), CreateCustomerPostingGroup.Domestic(), CreatePaymentTerms.PaymentTermsM8D(), CreateSalespersonPurchaser.JimOlive(), ContosoCoffeeDemoDataSetup."Country/Region Code", CreateINLocation.BlueLocation(), DomesticAdatumCorporationVatRegNoLbl, CreatePostingGroups.DomesticPostingGroup(), '', PostCode110002Lbl, CreateLanguage.ENG(), 'mr.andy.teal@contoso.com', CreateReminderTerms.Domestic(), CreateVATPostingGroups.Domestic(), '', 'ABCDE0123F', CreateINState.Delhi(), '07ABCDE0123F1Z1', Enum::"GST Customer Type"::Registered);
            CreateCustomer.DomesticTreyResearch():
                ValidateRecordFields(Rec, SelangorianLtdLbl, SouthwarkBridgeRdAddressLbl, '', GurugramCityLbl, CreateTerritory.Midlands(), CreateCustomerPostingGroup.Domestic(), CreatePaymentTerms.PaymentTermsDAYS14(), CreateSalespersonPurchaser.JimOlive(), ContosoCoffeeDemoDataSetup."Country/Region Code", CreateINLocation.BlueLocation(), DomesticTreyResearchVatRgeNoLbl, CreatePostingGroups.DomesticPostingGroup(), '', PostCode122002Lbl, CreateLanguage.ENG(), 'mr.mark.mcarthur@contoso.com', CreateReminderTerms.Domestic(), CreateVATPostingGroups.Domestic(), '', '', CreateINState.Haryana(), '', Enum::"GST Customer Type"::Unregistered);
            CreateCustomer.ExportSchoolofArt():
                ValidateRecordFields(Rec, JohnHaddockInsuranceCoLbl, HighTowerGreenAddressLbl, '', ChicagoCityLbl, CreateTerritory.Foreign(), CreateCustomerPostingGroup.Foreign(), CreatePaymentTerms.PaymentTermsM8D(), CreateSalespersonPurchaser.OtisFalls(), CreateCountryRegion.US(), CreateINLocation.BlueLocation(), EUAlpineSkiHouseVatRegNoLbl, CreatePostingGroups.ExportPostingGroup(), '', USIL61236PostCodeLbl, CreateLanguage.ENU(), 'miss.patricia.doyle@contoso.com', CreateReminderTerms.Foreign(), CreateVATPostingGroups.Export(), '', '', '', '', Enum::"GST Customer Type"::Export);
            CreateCustomer.EUAlpineSkiHouse():
                ValidateRecordFields(Rec, DeerfieldGraphicsCompanyLbl, DeerfieldRoadAddressLbl, '', NewDelhiCityLbl, CreateTerritory.West(), CreateCustomerPostingGroup.Domestic(), CreatePaymentTerms.PaymentTermsM8D(), CreateSalespersonPurchaser.JimOlive(), ContosoCoffeeDemoDataSetup."Country/Region Code", CreateINLocation.BlueLocation(), ExportSchoolofArtVatRegNoLbl, CreatePostingGroups.DomesticPostingGroup(), '', PostCode110001Lbl, CreateLanguage.ENG(), 'mr.kevin.wright@contoso.com', CreateReminderTerms.Domestic(), CreateVATPostingGroups.Domestic(), CreateINAssesseeCode.Company(), 'LOCAT2887A', CreateINState.Delhi(), '', Enum::"GST Customer Type"::Registered);
            CreateCustomer.DomesticRelecloud():
                ValidateRecordFields(Rec, GuildfordWaterDepartmentLbl, WaterWayAddressLbl, '', NewDelhiCityLbl, CreateTerritory.South(), CreateCustomerPostingGroup.Domestic(), CreatePaymentTerms.PaymentTermsDAYS14(), CreateSalespersonPurchaser.JimOlive(), ContosoCoffeeDemoDataSetup."Country/Region Code", CreateINLocation.BlueLocation(), DomesticRelecloudVatRegNoLbl, CreatePostingGroups.DomesticPostingGroup(), '', PostCode110001Lbl, CreateLanguage.ENG(), 'mr.jim.stewart@contoso.com', CreateReminderTerms.Domestic(), CreateVATPostingGroups.Domestic(), CreateINAssesseeCode.Company(), 'LOCAT8898A', CreateINState.Delhi(), '', Enum::"GST Customer Type"::Registered);
        end;
    end;

    local procedure ValidateRecordFields(var Customer: Record Customer; Name: Text[100]; Address: Text[100]; Address2: Text[50]; City: Text[30]; TerritoryCode: Code[10]; CustomerPostingGroup: Code[20]; PaymentTermsCode: Code[10]; SalespersonCode: Code[20]; CountryRegionCode: Code[10]; LocationCode: Code[10]; VatRegNo: Text[20]; GenBusPostingGroup: Code[20]; County: Text[30]; PostCode: Code[20]; LanguageCode: Code[10]; Email: Text[80]; ReminderTermsCode: Code[10]; VATBusPostingGroup: Code[20]; AssesseeCode: Code[10]; PANNo: Code[20]; StateCode: Code[10]; GSTRegistrationNo: Code[20]; GSTCustomerType: Enum "GST Customer Type")
    begin
        Customer.Validate(Name, Name);
        Customer.Validate(Address, Address);
        Customer.Validate("Address 2", Address2);
        Customer.Validate(City, City);
        Customer.Validate("Territory Code", TerritoryCode);
        Customer.Validate("Customer Posting Group", CustomerPostingGroup);
        Customer.Validate("Payment Terms Code", PaymentTermsCode);
        Customer.Validate("Salesperson Code", SalespersonCode);
        Customer.Validate("VAT Registration No.", VatRegNo);
        Customer.Validate("Post Code", PostCode);
        Customer.Validate(County, County);
        Customer.Validate("Country/Region Code", CountryRegionCode);
        Customer.Validate("Location Code", LocationCode);
        Customer.Validate("Gen. Bus. Posting Group", GenBusPostingGroup);
        Customer.Validate("Language Code", LanguageCode);
        Customer.Validate("E-Mail", Email);
        Customer.Validate("Reminder Terms Code", ReminderTermsCode);
        Customer.Validate("VAT Bus. Posting Group", VATBusPostingGroup);
        Customer.Validate("Assessee Code", AssesseeCode);
        Customer.Validate("P.A.N. No.", PANNo);
        Customer.Validate("State Code", StateCode);
        Customer."GST Registration No." := GSTRegistrationNo;
        Customer."GST Customer Type" := GSTCustomerType;
        Customer.Contact := '';
    end;

    var
        TheCannonGroupPLCLbl: Label 'The Cannon Group PLC', MaxLength = 100;
        SelangorianLtdLbl: Label 'Selangorian Ltd.', MaxLength = 100;
        JohnHaddockInsuranceCoLbl: Label 'John Haddock Insurance Co.', MaxLength = 100;
        DeerfieldGraphicsCompanyLbl: Label 'Deerfield Graphics Company', MaxLength = 100;
        GuildfordWaterDepartmentLbl: Label 'Guildford Water Department', MaxLength = 100;
        StationRoadAddressLbl: Label 'Station Road, 21', MaxLength = 100, Locked = true;
        SouthwarkBridgeRdAddressLbl: Label 'Southwark Bridge Rd, 91-95', MaxLength = 100, Locked = true;
        HighTowerGreenAddressLbl: Label '10 High Tower Green', MaxLength = 100, Locked = true;
        DeerfieldRoadAddressLbl: Label '10 Deerfield Road', MaxLength = 100, Locked = true;
        WaterWayAddressLbl: Label '25 Water Way', MaxLength = 100, Locked = true;
        NewDelhiCityLbl: Label 'New Delhi', MaxLength = 30, Locked = true;
        GurugramCityLbl: Label 'Gurugram', MaxLength = 30, Locked = true;
        ChicagoCityLbl: Label 'Chicago', MaxLength = 30, Locked = true;
        RobertTownesLbl: Label 'Robert Townes', MaxLength = 100;
        HelenRayLbl: Label 'Helen Ray', MaxLength = 100;
        MeaganBondLbl: Label 'Meagan Bond', MaxLength = 100;
        IanDeberryLbl: Label 'Ian Deberry', MaxLength = 100;
        JimStewartLbl: Label 'Mr. Jim Stewart', MaxLength = 100;
        DomesticAdatumCorporationVatRegNoLbl: Label '789456278', MaxLength = 20;
        DomesticTreyResearchVatRgeNoLbl: Label '254687456', MaxLength = 20;
        DomesticRelecloudVatRegNoLbl: Label '582048936', MaxLength = 20;
        ExportSchoolofArtVatRegNoLbl: Label '733495789', MaxLength = 20;
        EUAlpineSkiHouseVatRegNoLbl: Label '533435789', MaxLength = 20;
        PostCode110002Lbl: Label '110002', MaxLength = 20;
        PostCode122002Lbl: Label '122002', MaxLength = 20;
        USIL61236PostCodeLbl: Label 'US-IL 61236', MaxLength = 20;
        PostCode110001Lbl: Label '110001', MaxLength = 20;
}
