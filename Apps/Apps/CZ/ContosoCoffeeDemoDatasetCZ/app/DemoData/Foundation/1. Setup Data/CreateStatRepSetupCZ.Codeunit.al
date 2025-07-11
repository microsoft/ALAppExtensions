// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Foundation;

using Microsoft.Foundation.Company;
using Microsoft.DemoData.Finance;
using Microsoft.DemoData.HumanResources;
using Microsoft.Finance.VAT.Reporting;

codeunit 31280 "Create Stat. Rep. Setup CZ"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions =
        tabledata "Statutory Reporting Setup CZL" = rim;

    trigger OnRun()
    var
        StatutoryReportingSetupCZL: Record "Statutory Reporting Setup CZL";
        CreateCompanyInformation: Codeunit "Create Company Information";
    begin
        if not StatutoryReportingSetupCZL.Get() then
            CreateSetupStatutoryReportingSetup();

        StatutoryReportingSetupCZL.Validate("Company Type", StatutoryReportingSetupCZL."Company Type"::Corporate);
        StatutoryReportingSetupCZL.Validate("Company Trade Name", CreateCompanyInformation.DefaultCronusCompanyName());
        StatutoryReportingSetupCZL.Validate("Company Trade Name Appendix", CompanyTradeNameAppendixTok);
        StatutoryReportingSetupCZL.Validate("VAT Control Report E-mail", 'info@contoso.cz');
        StatutoryReportingSetupCZL.Validate("Data Box ID", DataBoxIDTok);
        StatutoryReportingSetupCZL.Validate("Tax Payer Status", StatutoryReportingSetupCZL."Tax Payer Status"::Payer);
        StatutoryReportingSetupCZL.Validate("Company Type", StatutoryReportingSetupCZL."Company Type"::Corporate);
        StatutoryReportingSetupCZL.Validate(City, CityTok);
        StatutoryReportingSetupCZL.Validate(Street, StreetTok);
        StatutoryReportingSetupCZL.Validate("House No.", HouseNoTok);
        StatutoryReportingSetupCZL.Validate("Tax Office Number", TaxOfficeNumberTok);
        StatutoryReportingSetupCZL.Validate("Tax Office Region Number", TaxOfficeRegionNumberTok);
        StatutoryReportingSetupCZL.Validate("Primary Business Activity Code", PrimaryBusinessActivityCodeTok);
        StatutoryReportingSetupCZL.Modify(true);
    end;

    procedure CreateSetupStatutoryReportingSetup()
    var
        StatutoryReportingSetupCZL: Record "Statutory Reporting Setup CZL";
        CreateNoSeriesCZ: Codeunit "Create No. Series CZ";
    begin
        if not StatutoryReportingSetupCZL.Get() then
            StatutoryReportingSetupCZL.Insert();

        StatutoryReportingSetupCZL.Validate("Simplified Tax Document Limit", 10000);
        StatutoryReportingSetupCZL.Validate("VAT Statement Country Name", CzechRepublicLbl);
        StatutoryReportingSetupCZL.Validate("VIES Number of Lines", 20);
        StatutoryReportingSetupCZL.Validate("VIES Declaration Export No.", Xmlport::"VIES Declaration CZL");
        StatutoryReportingSetupCZL.Validate("VIES Declaration Report No.", Report::"VIES Declaration CZL");
        StatutoryReportingSetupCZL.Validate("VAT Control Report Xml Format", StatutoryReportingSetupCZL."VAT Control Report Xml Format"::"03_01_03");
        StatutoryReportingSetupCZL.Validate("Company Official Nos.", CreateNoSeriesCZ.CompanyOfficial());
        StatutoryReportingSetupCZL.Validate("VAT Control Report Nos.", CreateNoSeriesCZ.VATControlReport());
        StatutoryReportingSetupCZL.Validate("VIES Declaration Nos.", CreateNoSeriesCZ.VIESDeclaration());
        StatutoryReportingSetupCZL.Modify(true);
    end;

    internal procedure CreateFinanceStatutoryReportingSetup()
    var
        StatutoryReportingSetupCZL: Record "Statutory Reporting Setup CZL";
        CreateVATStatement: Codeunit "Create VAT Statement";
    begin
        if not StatutoryReportingSetupCZL.Get() then
            Run();

        StatutoryReportingSetupCZL.Validate("VAT Statement Template Name", CreateVATStatement.VATTemplateName());
        StatutoryReportingSetupCZL.Validate("VAT Statement Name", CreateVATStatement.VATStatementName());
        StatutoryReportingSetupCZL.Modify(true);
    end;

    internal procedure CreateHRStatutoryReportingSetup()
    var
        StatutoryReportingSetupCZL: Record "Statutory Reporting Setup CZL";
        CreateCompanyOfficialCZ: Codeunit "Create Company Official CZ";
    begin
        if not StatutoryReportingSetupCZL.Get() then
            Run();

        StatutoryReportingSetupCZL.Validate("VIES Decl. Auth. Employee No.", CreateCompanyOfficialCZ.ProductionManager());
        StatutoryReportingSetupCZL.Validate("VIES Decl. Filled Employee No.", CreateCompanyOfficialCZ.ManagingDirector());
        StatutoryReportingSetupCZL.Validate("VAT Stat. Auth. Employee No.", CreateCompanyOfficialCZ.ProductionManager());
        StatutoryReportingSetupCZL.Validate("VAT Stat. Filled Employee No.", CreateCompanyOfficialCZ.ManagingDirector());
        StatutoryReportingSetupCZL.Modify(true);
    end;

    var
        CzechRepublicLbl: Label 'Czech Republic', MaxLength = 25;
        CompanyTradeNameAppendixTok: Label 'a.s.', MaxLength = 10, Locked = true;
        DataBoxIDTok: Label 'ABC123', MaxLength = 20, Locked = true;
        CityTok: Label 'Vracov', MaxLength = 30, Locked = true;
        StreetTok: Label 'The Ring', MaxLength = 50, Locked = true;
        HouseNoTok: Label '5', MaxLength = 30, Locked = true;
        TaxOfficeNumberTok: Label '461', MaxLength = 20, Locked = true;
        TaxOfficeRegionNumberTok: Label '3003', MaxLength = 20, Locked = true;
        PrimaryBusinessActivityCodeTok: Label '620200', MaxLength = 10, Locked = true;
}
