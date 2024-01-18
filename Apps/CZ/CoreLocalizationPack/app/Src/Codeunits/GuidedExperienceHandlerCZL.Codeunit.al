// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.Environment.Configuration;

using Microsoft.Bank.Setup;
using Microsoft.Finance;
using Microsoft.Finance.Registration;
using Microsoft.Finance.VAT.Reporting;
using Microsoft.Foundation.Company;
#if not CLEAN22
using Microsoft.Inventory.Intrastat;
#endif
using Microsoft.Inventory.Journal;
using Microsoft.Inventory.Location;
using Microsoft.Purchases.Vendor;
using Microsoft.Utilities;
using System.IO;

codeunit 11747 "Guided Experience Handler CZL"
{
    Access = Internal;

    var
        GuidedExperience: Codeunit "Guided Experience";
        ManualSetupCategory: Enum "Manual Setup Category";

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Guided Experience", 'OnRegisterManualSetup', '', false, false)]
    local procedure OnRegisterManualSetup()
    begin
        RegisterInventoryMovementTemplates();
        RegisterRegNoServiceConfig();
        RegisterUnrelPayerServiceSetup();
        RegisterVATCtrlReportSection();
        RegisterVATPeriods();
        RegisterStatutoryReportingSetup();
        RegisterCompanyOfficials();
        RegisterDocumentFooter();
        RegisterExcelTemplates();
        RegisterCommodities();
        RegisterVATAttribudeCode();
        RegisterStockkeepingUnitTemplates();
        RegisterConstantSymbols();
        RegisterEETServiceSetup();
        RegisterEETBusinessPremises();
        RegisterEETCashRegisters();
#if not CLEAN22
        RegisterStatisticIndications();
        RegisterSpecificMovements();
        RegisterIntrastatDeliveryGroups();
#endif
    end;

    local procedure RegisterInventoryMovementTemplates()
    var
        InventoryMovementTemplateNameTxt: Label 'Inventory Movement Templates';
        InventoryMovementTemplateDescriptionTxt: Label 'Set up the templates for item movements, that you can select from in the Item Journal, Job Journal and Physical Inventory.';
        InventoryMovementTemplateKeywordsTxt: Label 'Inventory, Template, Item Journal, Job Journal,  Physical Inventory';
    begin
        GuidedExperience.InsertManualSetup(InventoryMovementTemplateNameTxt, InventoryMovementTemplateNameTxt, InventoryMovementTemplateDescriptionTxt,
          5, ObjectType::Page, Page::"Invt. Movement Templates CZL", ManualSetupCategory::Inventory, InventoryMovementTemplateKeywordsTxt);
    end;

    local procedure RegisterRegNoServiceConfig()
    var
        RegNoServiceConfigNameTxt: Label 'Registration No. Service Config';
        RegNoServiceConfigDescriptionTxt: Label 'Set up and enable the Registration No. service.';
        RegNoServiceConfigKeywordsTxt: Label 'ARES, Registration No., Customer, Vendor, Contact';
    begin
        GuidedExperience.InsertManualSetup(RegNoServiceConfigNameTxt, RegNoServiceConfigNameTxt, RegNoServiceConfigDescriptionTxt,
          1, ObjectType::Page, Page::"Reg. No. Service Config CZL", ManualSetupCategory::General, RegNoServiceConfigKeywordsTxt);
    end;

    local procedure RegisterUnrelPayerServiceSetup()
    var
        UnrelPayerServiceSetupNameTxt: Label 'Unreliable Payer Service Setup';
        UnrelPayerServiceSetupDescriptionTxt: Label 'Set up and enable the Check of Unreliable Payers service.';
        UnrelPayerServiceSetupKeywordsTxt: Label 'Payer, Unreliable Payer, Vendor, Bank Account';
    begin
        GuidedExperience.InsertManualSetup(UnrelPayerServiceSetupNameTxt, UnrelPayerServiceSetupNameTxt, UnrelPayerServiceSetupDescriptionTxt,
          1, ObjectType::Page, Page::"Unrel. Payer Service Setup CZL", ManualSetupCategory::Purchasing, UnrelPayerServiceSetupKeywordsTxt);
    end;

    local procedure RegisterVATCtrlReportSection()
    var
        VATCtrlReportSectionNameTxt: Label 'VAT Control Report Sections';
        VATCtrlReportSectionDescriptionTxt: Label 'Set the codes for each reporting portion of the VAT Control Report.';
        VATCtrlReportSectionKeywordsTxt: Label 'VAT, VAT Control Report, Sections';
    begin
        GuidedExperience.InsertManualSetup(VATCtrlReportSectionNameTxt, VATCtrlReportSectionNameTxt, VATCtrlReportSectionDescriptionTxt,
          30, ObjectType::Page, Page::"VAT Ctrl. Report Sections CZL", ManualSetupCategory::Finance, VATCtrlReportSectionKeywordsTxt);
    end;

    local procedure RegisterVATPeriods()
    var
        VATPeriodsNameTxt: Label 'VAT Periods';
        VATPeriodsDescriptionTxt: Label 'Set up the number of VAT periods, such as 12 monthly periods, within the fiscal year. VAT periods can be set separately from accounting periods (eg if you are a quarterly VAT payer).';
        VATPeriodsKeywordsTxt: Label 'VAT, Period';
    begin
        GuidedExperience.InsertManualSetup(VATPeriodsNameTxt, VATPeriodsNameTxt, VATPeriodsDescriptionTxt,
          2, ObjectType::Page, Page::"VAT Periods CZL", ManualSetupCategory::Finance, VATPeriodsKeywordsTxt);
    end;

    local procedure RegisterStatutoryReportingSetup()
    var
        StatutoryReportingSetupNameTxt: Label 'Statutory Reporting Setup';
        StatutoryReportingSetupDescriptionTxt: Label 'Set up information used in statutory reporting.';
        StatutoryReportingSetupKeywordsTxt: Label 'VIES, VAT Control Report, VAT Statement, Official, Intrastat';
    begin
        GuidedExperience.InsertManualSetup(StatutoryReportingSetupNameTxt, StatutoryReportingSetupNameTxt, StatutoryReportingSetupDescriptionTxt,
          5, ObjectType::Page, Page::"Statutory Reporting Setup CZL", ManualSetupCategory::General, StatutoryReportingSetupKeywordsTxt);
    end;

    local procedure RegisterCompanyOfficials()
    var
        CompanyOfficialsNameTxt: Label 'Company Officials';
        CompanyOfficialsDescriptionTxt: Label 'Set up a list of people who represent your company officials for authorities.';
        CompanyOfficialsKeywordsTxt: Label 'Company, Official, Representative';
    begin
        GuidedExperience.InsertManualSetup(CompanyOfficialsNameTxt, CompanyOfficialsNameTxt, CompanyOfficialsDescriptionTxt,
          2, ObjectType::Page, Page::"Company Official List CZL", ManualSetupCategory::General, CompanyOfficialsKeywordsTxt);
    end;

    local procedure RegisterDocumentFooter()
    var
        DocumentFootersNameTxt: Label 'Document Footers';
        DocumentFootersDescriptionTxt: Label 'Set up a document footer texts for printouts.';
        DocumentFootersKeywordsTxt: Label 'Company, Document, Footer, Text';
    begin
        GuidedExperience.InsertManualSetup(DocumentFootersNameTxt, DocumentFootersNameTxt, DocumentFootersDescriptionTxt,
          2, ObjectType::Page, Page::"Document Footers CZL", ManualSetupCategory::General, DocumentFootersKeywordsTxt);
    end;

    local procedure RegisterExcelTemplates()
    var
        ExcelTemplateNameTxt: Label 'Excel Templates';
        ExcelTemplateDescriptionTxt: Label 'Set up a Excel templates into which you can export Account Schedules.';
        ExcelTemplateKeywordsTxt: Label 'Excel, Template, Account Schedule';
    begin
        GuidedExperience.InsertManualSetup(ExcelTemplateNameTxt, ExcelTemplateNameTxt, ExcelTemplateDescriptionTxt,
          2, ObjectType::Page, Page::"Excel Templates CZL", ManualSetupCategory::General, ExcelTemplateKeywordsTxt);
    end;

    local procedure RegisterCommodities()
    var
        CommoditiesNameTxt: Label 'Commodities';
        CommoditiesDescriptionTxt: Label 'Set up a list of commodities that you will use when processing VAT reverse charge and their detailed settings.';
        CommoditiesKeywordsTxt: Label 'Commodity, VAT, Posting, Sales, Purchase';
    begin
        GuidedExperience.InsertManualSetup(CommoditiesNameTxt, CommoditiesNameTxt, CommoditiesDescriptionTxt,
          1, ObjectType::Page, Page::"Commodities CZL", ManualSetupCategory::General, CommoditiesKeywordsTxt);
    end;

    local procedure RegisterVATAttribudeCode()
    var
        VATAttributeCodesNameTxt: Label 'VAT Attribute Codes';
        VATAttributeCodesDescriptionTxt: Label 'Set up XML codes for VAT statement export to XML file.';
        VATAttributeCodesKeywordsTxt: Label 'VAT, Statement, XML';
    begin
        GuidedExperience.InsertManualSetup(VATAttributeCodesNameTxt, VATAttributeCodesNameTxt, VATAttributeCodesDescriptionTxt,
          10, ObjectType::Page, Page::"VAT Attribute Codes CZL", ManualSetupCategory::Finance, VATAttributeCodesKeywordsTxt);
    end;

    local procedure RegisterStockkeepingUnitTemplates()
    var
        StockkeepingUnitTemplateNameTxt: Label 'Stockkeeping Unit Templates';
        StockkeepingUnitTemplateDescriptionTxt: Label 'Set up templates that is being used as part of the stockkeeping unit creation process.';
        StockkeepingUnitTemplateKeywordsTxt: Label 'Stockkeeping Unit, Item, Location, Item Category';
    begin
        GuidedExperience.InsertManualSetup(StockkeepingUnitTemplateNameTxt, StockkeepingUnitTemplateNameTxt, StockkeepingUnitTemplateDescriptionTxt,
          2, ObjectType::Page, Page::"Stockkeeping Unit Templ. CZL", ManualSetupCategory::Inventory, StockkeepingUnitTemplateKeywordsTxt);
    end;

    local procedure RegisterConstantSymbols()
    var
        ConstantSymbolNameTxt: Label 'Constant Symbols';
        ConstantSymbolDescriptionTxt: Label 'Set up the constant symbols for bank payments.';
        ConstantSymbolKeywordsTxt: Label 'Banking, Payments';
    begin
        GuidedExperience.InsertManualSetup(ConstantSymbolNameTxt, ConstantSymbolNameTxt, ConstantSymbolDescriptionTxt,
          5, ObjectType::Page, Page::"Constant Symbols CZL", ManualSetupCategory::Finance, ConstantSymbolKeywordsTxt);
    end;

    local procedure RegisterEETServiceSetup()
    var
        EETServiceSetupNameTxt: Label 'EET Service Setup';
        EETServiceSetupDescriptionTxt: Label 'Set up and enable the Electronic registration of sales (EET) service.';
        EETServiceSetupKeywordsTxt: Label 'EET';
    begin
        GuidedExperience.InsertManualSetup(EETServiceSetupNameTxt, EETServiceSetupNameTxt, EETServiceSetupDescriptionTxt,
          2, ObjectType::Page, Page::"EET Service Setup CZL", ManualSetupCategory::"EET CZL", EETServiceSetupKeywordsTxt);
    end;

    local procedure RegisterEETBusinessPremises()
    var
        EETBusinessPremisesNameTxt: Label 'EET Business Premises';
        EETBusinessPremisesDescriptionTxt: Label 'Set up the Business Premises of Electronic registration of sales (EET).';
        EETBusinessPremisesKeywordsTxt: Label 'EET';
    begin
        GuidedExperience.InsertManualSetup(EETBusinessPremisesNameTxt, EETBusinessPremisesNameTxt, EETBusinessPremisesDescriptionTxt,
          1, ObjectType::Page, Page::"EET Business Premises CZL", ManualSetupCategory::"EET CZL", EETBusinessPremisesKeywordsTxt);
    end;

    local procedure RegisterEETCashRegisters()
    var
        EETCashRegisterNameTxt: Label 'EET Cash Registers';
        EETCashRegisterDescriptionTxt: Label 'Set up the Cash Registers of Electronic registration of sales (EET).';
        EETCashRegisterKeywordsTxt: Label 'EET';
    begin
        GuidedExperience.InsertManualSetup(EETCashRegisterNameTxt, EETCashRegisterNameTxt, EETCashRegisterDescriptionTxt,
          2, ObjectType::Page, Page::"EET Cash Registers CZL", ManualSetupCategory::"EET CZL", EETCashRegisterKeywordsTxt);
    end;
#if not CLEAN22
#pragma warning disable AL0432
    local procedure RegisterStatisticIndications()
    var
        StatisticIndicationsNameTxt: Label 'Statistic Indications (Obsolete)';
        StatisticIndicationsDescriptionTxt: Label 'Set up or update Statistic Indications.';
        StatisticIndicationsKeywordsTxt: Label 'Intrastat';
    begin
        GuidedExperience.InsertManualSetup(StatisticIndicationsNameTxt, StatisticIndicationsNameTxt, StatisticIndicationsDescriptionTxt,
          2, ObjectType::Page, Page::"Statistic Indications CZL", ManualSetupCategory::"Intrastat CZL", StatisticIndicationsKeywordsTxt);
    end;

    local procedure RegisterSpecificMovements()
    var
        SpecificMovementsNameTxt: Label 'Specific Movements (Obsolete)';
        SpecificMovementsDescriptionTxt: Label 'Set up or update Specific Movements.';
        SpecificMovementsKeywordsTxt: Label 'Intrastat';
    begin
        GuidedExperience.InsertManualSetup(SpecificMovementsNameTxt, SpecificMovementsNameTxt, SpecificMovementsDescriptionTxt,
          2, ObjectType::Page, Page::"Specific Movements CZL", ManualSetupCategory::"Intrastat CZL", SpecificMovementsKeywordsTxt);
    end;

    local procedure RegisterIntrastatDeliveryGroups()
    var
        IntrastatDeliveryGroupsNameTxt: Label 'Intrastat Delivery Groups (Obsolete)';
        IntrastatDeliveryGroupsDescriptionTxt: Label 'Set up or update Intrastat Delivery Groups.';
        IntrastatDeliveryGroupsKeywordsTxt: Label 'Intrastat';
    begin
        GuidedExperience.InsertManualSetup(IntrastatDeliveryGroupsNameTxt, IntrastatDeliveryGroupsNameTxt, IntrastatDeliveryGroupsDescriptionTxt,
          1, ObjectType::Page, Page::"Intrastat Delivery Groups CZL", ManualSetupCategory::"Intrastat CZL", IntrastatDeliveryGroupsKeywordsTxt);
    end;
#pragma warning restore AL0432
#endif
}
