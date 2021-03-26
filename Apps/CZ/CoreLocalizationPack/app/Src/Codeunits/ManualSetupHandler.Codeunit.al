codeunit 11747 "Manual Setup Handler CZL"
{
    var
        Info: ModuleInfo;
        ManualSetupCategory: Enum "Manual Setup Category";

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Manual Setup", 'OnRegisterManualSetup', '', false, false)]
    local procedure OnRegisterManualSetup(var Sender: Codeunit "Manual Setup")
    begin
        RegisterInventoryMovementTemplate(Sender);
        RegisterRegNoServiceConfig(Sender);
        RegisterUnrelPayerServiceSetup(Sender);
        RegisterVATCtrlReportSection(Sender);
        RegisterVATPeriods(Sender);
        RegisterStatutoryReportingSetup(Sender);
        RegisterCompanyOfficial(Sender);
        RegisterDocumentFooter(Sender);
        RegisterExcelTemplate(Sender);
        RegisterCommodities(Sender);
        RegisterVATAttribudeCode(Sender);
        RegisterStockkeepingUnitTemplate(Sender);
        RegisterConstantSymbol(Sender);
        RegisterEETServiceSetup(Sender);
        RegisterEETBusinessPremises(Sender);
        RegisterEETCashRegisters(Sender);
        RegisterStatisticIndications(Sender);
        RegisterSpecificMovements(Sender);
        RegisterIntrastatDeliveryGroups(Sender);
    end;

    local procedure RegisterInventoryMovementTemplate(var ManualSetup: Codeunit "Manual Setup")
    var
        InventoryMovementTemplateNameTxt: Label 'Inventory Movement Templates';
        InventoryMovementTemplateDescriptionTxt: Label 'Set up the templates for item movements, that you can select from in the Item Journal, Job Journal and Physical Inventory.';
        InventoryMovementTemplateKeywordsTxt: Label 'Inventory, Template, Item Journal, Job Journal,  Physical Inventory';
    begin
        NavApp.GetCurrentModuleInfo(Info);
        ManualSetup.Insert(InventoryMovementTemplateNameTxt, InventoryMovementTemplateDescriptionTxt,
          InventoryMovementTemplateKeywordsTxt, Page::"Invt. Movement Templates CZL",
          Info.Id(), ManualSetupCategory::Inventory);
    end;

    local procedure RegisterRegNoServiceConfig(var ManualSetup: Codeunit "Manual Setup")
    var
        RegNoServiceConfigNameTxt: Label 'Registration No. Service Config';
        RegNoServiceConfigDescriptionTxt: Label 'Set up and enable the Registration No. service.';
        RegNoServiceConfigKeywordsTxt: Label 'ARES, Registration No., Customer, Vendor, Contact';
    begin
        NavApp.GetCurrentModuleInfo(Info);
        ManualSetup.Insert(RegNoServiceConfigNameTxt, RegNoServiceConfigDescriptionTxt,
          RegNoServiceConfigKeywordsTxt, Page::"Reg. No. Service Config CZL",
          Info.Id(), ManualSetupCategory::Service);
    end;

    local procedure RegisterUnrelPayerServiceSetup(var ManualSetup: Codeunit "Manual Setup")
    var
        UnrelPayerServiceSetupNameTxt: Label 'Unreliable Payer Service Setup';
        UnrelPayerServiceSetupDescriptionTxt: Label 'Set up and enable the Check of Unreliable Payers service.';
        UnrelPayerServiceSetupKeywordsTxt: Label 'Payer, Unreliable Payer, Vendor, Bank Account';
    begin
        NavApp.GetCurrentModuleInfo(Info);
        ManualSetup.Insert(UnrelPayerServiceSetupNameTxt, UnrelPayerServiceSetupDescriptionTxt,
          UnrelPayerServiceSetupKeywordsTxt, Page::"Unrel. Payer Service Setup CZL",
          Info.Id(), ManualSetupCategory::Service);
    end;

    local procedure RegisterVATCtrlReportSection(var ManualSetup: Codeunit "Manual Setup")
    var
        VATCtrlReportSectionNameTxt: Label 'VAT Control Report Sections';
        VATCtrlReportSectionDescriptionTxt: Label 'Set the codes for each reporting portion of the VAT Control Report.';
        VATCtrlReportSectionKeywordsTxt: Label 'VAT, VAT Control Report, Sections';
    begin
        NavApp.GetCurrentModuleInfo(Info);
        ManualSetup.Insert(VATCtrlReportSectionNameTxt, VATCtrlReportSectionDescriptionTxt,
          VATCtrlReportSectionKeywordsTxt, Page::"VAT Ctrl. Report Sections CZL",
          Info.Id(), ManualSetupCategory::Finance);
    end;

    local procedure RegisterVATPeriods(var ManualSetup: Codeunit "Manual Setup")
    var
        VATPeriodsNameTxt: Label 'VAT Periods';
        VATPeriodsDescriptionTxt: Label 'Set up the number of VAT periods, such as 12 monthly periods, within the fiscal year. VAT periods can be set separately from accounting periods (eg if you are a quarterly VAT payer).';
        VATPeriodsKeywordsTxt: Label 'VAT, Period';
    begin
        NavApp.GetCurrentModuleInfo(Info);
        ManualSetup.Insert(VATPeriodsNameTxt, VATPeriodsDescriptionTxt,
          VATPeriodsKeywordsTxt, Page::"VAT Periods CZL",
          Info.Id(), ManualSetupCategory::Finance);
    end;

    local procedure RegisterStatutoryReportingSetup(var ManualSetup: Codeunit "Manual Setup")
    var
        StatutoryReportingSetupNameTxt: Label 'Statutory Reporting Setup';
        StatutoryReportingSetupDescriptionTxt: Label 'Set up information used in statutory reporting.';
        StatutoryReportingSetupKeywordsTxt: Label 'VIES, VAT Control Report, VAT Statement, Official, Intrastat';
    begin
        NavApp.GetCurrentModuleInfo(Info);
        ManualSetup.Insert(StatutoryReportingSetupNameTxt, StatutoryReportingSetupDescriptionTxt,
          StatutoryReportingSetupKeywordsTxt, Page::"Statutory Reporting Setup CZL",
          Info.Id(), ManualSetupCategory::General);
    end;

    local procedure RegisterCompanyOfficial(var ManualSetup: Codeunit "Manual Setup")
    var
        CompanyOfficialsNameTxt: Label 'Company Officials';
        CompanyOfficialsDescriptionTxt: Label 'Set up a list of people who represent your company officials for authorities.';
        CompanyOfficialsKeywordsTxt: Label 'Company, Official, Representative';
    begin
        NavApp.GetCurrentModuleInfo(Info);
        ManualSetup.Insert(CompanyOfficialsNameTxt, CompanyOfficialsDescriptionTxt,
          CompanyOfficialsKeywordsTxt, Page::"Company Official List CZL",
          Info.Id(), ManualSetupCategory::General);
    end;

    local procedure RegisterDocumentFooter(var ManualSetup: Codeunit "Manual Setup")
    var
        DocumentFootersNameTxt: Label 'Document Footers';
        DocumentFootersDescriptionTxt: Label 'Set up a document footer texts for printouts.';
        DocumentFootersKeywordsTxt: Label 'Company, Document, Footer, Text';
    begin
        NavApp.GetCurrentModuleInfo(Info);
        ManualSetup.Insert(DocumentFootersNameTxt, DocumentFootersDescriptionTxt,
          DocumentFootersKeywordsTxt, Page::"Document Footers CZL",
          Info.Id(), ManualSetupCategory::General);
    end;

    local procedure RegisterExcelTemplate(var ManualSetup: Codeunit "Manual Setup")
    var
        ExcelTemplateNameTxt: Label 'Excel Templates';
        ExcelTemplateDescriptionTxt: Label 'Set up a Excel templates into which you can export Account Schedules.';
        ExcelTemplateKeywordsTxt: Label 'Excel, Template, Account Schedule';
    begin
        NavApp.GetCurrentModuleInfo(Info);
        ManualSetup.Insert(ExcelTemplateNameTxt, ExcelTemplateDescriptionTxt,
          ExcelTemplateKeywordsTxt, Page::"Excel Templates CZL",
          Info.Id(), ManualSetupCategory::General);
    end;

    local procedure RegisterCommodities(var ManualSetup: Codeunit "Manual Setup")
    var
        CommoditiesNameTxt: Label 'Commodities';
        CommoditiesDescriptionTxt: Label 'Set up a list of commodities that you will use when processing VAT reverse charge and their detailed settings.';
        CommoditiesKeywordsTxt: Label 'Commodity, VAT, Posting, Sales, Purchase';
    begin
        NavApp.GetCurrentModuleInfo(Info);
        ManualSetup.Insert(CommoditiesNameTxt, CommoditiesDescriptionTxt,
          CommoditiesKeywordsTxt, Page::"Commodities CZL",
          Info.Id(), ManualSetupCategory::General);
    end;

    local procedure RegisterVATAttribudeCode(var ManualSetup: Codeunit "Manual Setup")
    var
        VATAttributeCodesNameTxt: Label 'VAT Attribute Codes';
        VATAttributeCodesDescriptionTxt: Label 'Set up XML codes for VAT statement export to XML file.';
        VATAttributeCodesKeywordsTxt: Label 'VAT, Statement, XML';
    begin
        NavApp.GetCurrentModuleInfo(Info);
        ManualSetup.Insert(VATAttributeCodesNameTxt, VATAttributeCodesDescriptionTxt,
          VATAttributeCodesKeywordsTxt, Page::"VAT Attribute Codes CZL",
          Info.Id(), ManualSetupCategory::General);
    end;

    local procedure RegisterStockkeepingUnitTemplate(var ManualSetup: Codeunit "Manual Setup")
    var
        StockkeepingUnitTemplateNameTxt: Label 'Stockkeeping Unit Templates';
        StockkeepingUnitTemplateDescriptionTxt: Label 'Set up templates that is being used as part of the stockkeeping unit creation process.';
        StockkeepingUnitTemplateKeywordsTxt: Label 'Stockkeeping Unit, Item, Location, Item Category';
    begin
        NavApp.GetCurrentModuleInfo(Info);
        ManualSetup.Insert(StockkeepingUnitTemplateNameTxt, StockkeepingUnitTemplateDescriptionTxt,
          StockkeepingUnitTemplateKeywordsTxt, Page::"Stockkeeping Unit Templ. CZL",
          Info.Id(), ManualSetupCategory::Inventory);
    end;

    local procedure RegisterConstantSymbol(var ManualSetup: Codeunit "Manual Setup")
    var
        ConstantSymbolNameTxt: Label 'Constant Symbols';
        ConstantSymbolDescriptionTxt: Label 'Set up the constant symbols for bank payments.';
        ConstantSymbolKeywordsTxt: Label 'Banking, Payments';
    begin
        NavApp.GetCurrentModuleInfo(Info);
        ManualSetup.Insert(ConstantSymbolNameTxt, ConstantSymbolDescriptionTxt,
          ConstantSymbolKeywordsTxt, Page::"Constant Symbols CZL",
          Info.Id(), ManualSetupCategory::Finance);
    end;

    local procedure RegisterEETServiceSetup(var ManualSetup: Codeunit "Manual Setup")
    var
        EETServiceSetupNameTxt: Label 'EET Service Setup';
        EETServiceSetupDescriptionTxt: Label 'Set up and enable the Electronic registration of sales (EET) service.';
        EETServiceSetupKeywordsTxt: Label 'EET';
    begin
        NavApp.GetCurrentModuleInfo(Info);
        ManualSetup.Insert(EETServiceSetupNameTxt, EETServiceSetupDescriptionTxt,
          EETServiceSetupKeywordsTxt, Page::"EET Service Setup CZL",
          Info.Id(), ManualSetupCategory::Finance);
    end;

    local procedure RegisterEETBusinessPremises(var ManualSetup: Codeunit "Manual Setup")
    var
        EETBusinessPremisesNameTxt: Label 'EET Business Premises';
        EETBusinessPremisesDescriptionTxt: Label 'Set up the Business Premises of Electronic registration of sales (EET).';
        EETBusinessPremisesKeywordsTxt: Label 'EET';
    begin
        NavApp.GetCurrentModuleInfo(Info);
        ManualSetup.Insert(EETBusinessPremisesNameTxt, EETBusinessPremisesDescriptionTxt,
          EETBusinessPremisesKeywordsTxt, Page::"EET Business Premises CZL",
          Info.Id(), ManualSetupCategory::Finance);
    end;

    local procedure RegisterEETCashRegisters(var ManualSetup: Codeunit "Manual Setup")
    var
        EETCashRegisterNameTxt: Label 'EET Cash Registers';
        EETCashRegisterDescriptionTxt: Label 'Set up the Cash Registers of Electronic registration of sales (EET).';
        EETCashRegisterKeywordsTxt: Label 'EET';
    begin
        NavApp.GetCurrentModuleInfo(Info);
        ManualSetup.Insert(EETCashRegisterNameTxt, EETCashRegisterDescriptionTxt,
          EETCashRegisterKeywordsTxt, Page::"EET Cash Registers CZL",
          Info.Id(), ManualSetupCategory::Finance);
    end;

    local procedure RegisterStatisticIndications(var ManualSetup: Codeunit "Manual Setup")
    var
        StatisticIndicationsNameTxt: Label 'Statistic Indications';
        StatisticIndicationsDescriptionTxt: Label 'Set up or update Statistic Indications.';
        StatisticIndicationsKeywordsTxt: Label 'Intrastat';
    begin
        NavApp.GetCurrentModuleInfo(Info);
        ManualSetup.Insert(StatisticIndicationsNameTxt, StatisticIndicationsDescriptionTxt,
          StatisticIndicationsKeywordsTxt, Page::"Statistic Indications CZL",
          Info.Id(), ManualSetupCategory::Finance);
    end;

    local procedure RegisterSpecificMovements(var ManualSetup: Codeunit "Manual Setup")
    var
        SpecificMovementsNameTxt: Label 'Specific Movements';
        SpecificMovementsDescriptionTxt: Label 'Set up or update Specific Movements.';
        SpecificMovementsKeywordsTxt: Label 'Intrastat';
    begin
        NavApp.GetCurrentModuleInfo(Info);
        ManualSetup.Insert(SpecificMovementsNameTxt, SpecificMovementsDescriptionTxt,
          SpecificMovementsKeywordsTxt, Page::"Specific Movements CZL",
          Info.Id(), ManualSetupCategory::Finance);
    end;

    local procedure RegisterIntrastatDeliveryGroups(var ManualSetup: Codeunit "Manual Setup")
    var
        IntrastatDeliveryGroupsNameTxt: Label 'Intrastat Delivery Groups';
        IntrastatDeliveryGroupsDescriptionTxt: Label 'Set up or update Intrastat Delivery Groups.';
        IntrastatDeliveryGroupsKeywordsTxt: Label 'Intrastat';
    begin
        NavApp.GetCurrentModuleInfo(Info);
        ManualSetup.Insert(IntrastatDeliveryGroupsNameTxt, IntrastatDeliveryGroupsDescriptionTxt,
          IntrastatDeliveryGroupsKeywordsTxt, Page::"Intrastat Delivery Groups CZL",
          Info.Id(), ManualSetupCategory::Finance);
    end;
}
