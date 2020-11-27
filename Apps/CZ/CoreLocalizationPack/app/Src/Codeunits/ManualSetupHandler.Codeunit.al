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
    end;

    local procedure RegisterInventoryMovementTemplate(var Sender: Codeunit "Manual Setup")
    var
        InventoryMovementTemplateNameTxt: Label 'Inventory Movement Template';
        InventoryMovementTemplateDescriptionTxt: Label 'Set up the templates for item movements, that you can select from in the Item Journal, Job Journal and Physical Inventory.';
        InventoryMovementTemplateKeywordsTxt: Label 'Inventory, Template, Item Journal, Job Journal,  Physical Inventory';
    begin
        NavApp.GetCurrentModuleInfo(Info);
        Sender.Insert(InventoryMovementTemplateNameTxt, InventoryMovementTemplateDescriptionTxt,
          InventoryMovementTemplateKeywordsTxt, Page::"Invt. Movement Templates CZL",
          Info.Id(), ManualSetupCategory::Inventory);
    end;

    local procedure RegisterRegNoServiceConfig(var Sender: Codeunit "Manual Setup")
    var
        RegNoServiceConfigNameTxt: Label 'Registration No. Service Config';
        RegNoServiceConfigDescriptionTxt: Label 'Set up and enable the Registration No. service.';
        RegNoServiceConfigKeywordsTxt: Label 'ARES, Registration No., Customer, Vendor, Contact';
    begin
        NavApp.GetCurrentModuleInfo(Info);
        Sender.Insert(RegNoServiceConfigNameTxt, RegNoServiceConfigDescriptionTxt,
          RegNoServiceConfigKeywordsTxt, Page::"Reg. No. Service Config CZL",
          Info.Id(), ManualSetupCategory::Service);
    end;

    local procedure RegisterUnrelPayerServiceSetup(var Sender: Codeunit "Manual Setup")
    var
        UnrelPayerServiceSetupNameTxt: Label 'Unreliable Payer Service Setup';
        UnrelPayerServiceSetupDescriptionTxt: Label 'Set up and enable the Check of Unreliable Payers service.';
        UnrelPayerServiceSetupKeywordsTxt: Label 'Payer, Unreliable Payer, Vendor, Bank Account';
    begin
        NavApp.GetCurrentModuleInfo(Info);
        Sender.Insert(UnrelPayerServiceSetupNameTxt, UnrelPayerServiceSetupDescriptionTxt,
          UnrelPayerServiceSetupKeywordsTxt, Page::"Unrel. Payer Service Setup CZL",
          Info.Id(), ManualSetupCategory::Service);
    end;

    local procedure RegisterVATCtrlReportSection(var Sender: Codeunit "Manual Setup")
    var
        VATCtrlReportSectionNameTxt: Label 'VAT Control Report Sections';
        VATCtrlReportSectionDescriptionTxt: Label 'Set the codes for each reporting portion of the VAT Control Report.';
        VATCtrlReportSectionKeywordsTxt: Label 'VAT, VAT Control Report, Sections';
    begin
        NavApp.GetCurrentModuleInfo(Info);
        Sender.Insert(VATCtrlReportSectionNameTxt, VATCtrlReportSectionDescriptionTxt,
          VATCtrlReportSectionKeywordsTxt, Page::"VAT Ctrl. Report Sections CZL",
          Info.Id(), ManualSetupCategory::Finance);
    end;

    local procedure RegisterVATPeriods(var Sender: Codeunit "Manual Setup")
    var
        VATPeriodsNameTxt: Label 'VAT Periods';
        VATPeriodsDescriptionTxt: Label 'Set up the number of VAT periods, such as 12 monthly periods, within the fiscal year. VAT periods can be set separately from accounting periods (eg if you are a quarterly VAT payer).';
        VATPeriodsKeywordsTxt: Label 'VAT, Period';
    begin
        NavApp.GetCurrentModuleInfo(Info);
        Sender.Insert(VATPeriodsNameTxt, VATPeriodsDescriptionTxt,
          VATPeriodsKeywordsTxt, Page::"VAT Periods CZL",
          Info.Id(), ManualSetupCategory::Finance);
    end;

    local procedure RegisterStatutoryReportingSetup(var Sender: Codeunit "Manual Setup")
    var
        StatutoryReportingSetupNameTxt: Label 'Statutory Reporting Setup';
        StatutoryReportingSetupDescriptionTxt: Label 'Set up information used in statutory reporting.';
        StatutoryReportingSetupKeywordsTxt: Label 'VIES, VAT Control Report, VAT Statement, Official';
    begin
        NavApp.GetCurrentModuleInfo(Info);
        Sender.Insert(StatutoryReportingSetupNameTxt, StatutoryReportingSetupDescriptionTxt,
          StatutoryReportingSetupKeywordsTxt, Page::"Statutory Reporting Setup CZL",
          Info.Id(), ManualSetupCategory::General);
    end;

    local procedure RegisterCompanyOfficial(var Sender: Codeunit "Manual Setup")
    var
        CompanyOfficialsNameTxt: Label 'Company Officials';
        CompanyOfficialsDescriptionTxt: Label 'Set up a list of people who represent your company officials for authorities.';
        CompanyOfficialsKeywordsTxt: Label 'Company, Official, Representative';
    begin
        NavApp.GetCurrentModuleInfo(Info);
        Sender.Insert(CompanyOfficialsNameTxt, CompanyOfficialsDescriptionTxt,
          CompanyOfficialsKeywordsTxt, Page::"Company Official List CZL",
          Info.Id(), ManualSetupCategory::General);
    end;

    local procedure RegisterDocumentFooter(var Sender: Codeunit "Manual Setup")
    var
        DocumentFootersNameTxt: Label 'Document Footers';
        DocumentFootersDescriptionTxt: Label 'Set up a document footer texts for printouts.';
        DocumentFootersKeywordsTxt: Label 'Company, Document, Footer, Text';
    begin
        NavApp.GetCurrentModuleInfo(Info);
        Sender.Insert(DocumentFootersNameTxt, DocumentFootersDescriptionTxt,
          DocumentFootersKeywordsTxt, Page::"Document Footers CZL",
          Info.Id(), ManualSetupCategory::General);
    end;

    local procedure RegisterExcelTemplate(var Sender: Codeunit "Manual Setup")
    var
        ExcelTemplateNameTxt: Label 'Excel Templates';
        ExcelTemplateDescriptionTxt: Label 'Set up a Excel templates into which you can export Account Schedules.';
        ExcelTemplateKeywordsTxt: Label 'Excel, Template, Account Schedule';
    begin
        NavApp.GetCurrentModuleInfo(Info);
        Sender.Insert(ExcelTemplateNameTxt, ExcelTemplateDescriptionTxt,
          ExcelTemplateKeywordsTxt, Page::"Excel Templates CZL",
          Info.Id(), ManualSetupCategory::General);
    end;

    local procedure RegisterCommodities(var Sender: Codeunit "Manual Setup")
    var
        CommoditiesNameTxt: Label 'Commodities';
        CommoditiesDescriptionTxt: Label 'Set up a list of commodities that you will use when processing VAT reverse charge and their detailed settings.';
        CommoditiesKeywordsTxt: Label 'Commodity, VAT, Posting, Sales, Purchase';
    begin
        NavApp.GetCurrentModuleInfo(Info);
        Sender.Insert(CommoditiesNameTxt, CommoditiesDescriptionTxt,
          CommoditiesKeywordsTxt, Page::"Commodities CZL",
          Info.Id(), ManualSetupCategory::General);
    end;

    local procedure RegisterVATAttribudeCode(var Sender: Codeunit "Manual Setup")
    var
        VATAttributeCodesNameTxt: Label 'VAT Attribute Codes';
        VATAttributeCodesDescriptionTxt: Label 'Set up XML codes for VAT statement export to XML file.';
        VATAttributeCodesKeywordsTxt: Label 'VAT, Statement, XML';
    begin
        NavApp.GetCurrentModuleInfo(Info);
        Sender.Insert(VATAttributeCodesNameTxt, VATAttributeCodesDescriptionTxt,
          VATAttributeCodesKeywordsTxt, Page::"VAT Attribute Codes CZL",
          Info.Id(), ManualSetupCategory::General);
    end;

    local procedure RegisterStockkeepingUnitTemplate(var Sender: Codeunit "Manual Setup")
    var
        StockkeepingUnitTemplateNameTxt: Label 'Stockkeeping Unit Templates';
        StockkeepingUnitTemplateDescriptionTxt: Label 'Set up templates that is being used as part of the stockkeeping unit creation process.';
        StockkeepingUnitTemplateKeywordsTxt: Label 'Stockkeeping Unit, Item, Location, Item Category';
    begin
        NavApp.GetCurrentModuleInfo(Info);
        Sender.Insert(StockkeepingUnitTemplateNameTxt, StockkeepingUnitTemplateDescriptionTxt,
          StockkeepingUnitTemplateKeywordsTxt, Page::"Stockkeeping Unit Templ. CZL",
          Info.Id(), ManualSetupCategory::Inventory);
    end;
}
