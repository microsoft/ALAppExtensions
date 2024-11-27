// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft;

using Microsoft.Bank.BankAccount;
using Microsoft.Bank.Setup;
using Microsoft.CRM.Contact;
using Microsoft.Finance;
using Microsoft.Finance.FinancialReports;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Finance.GeneralLedger.Reports;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.Registration;
using Microsoft.Finance.VAT.Ledger;
using Microsoft.Finance.VAT.Reporting;
using Microsoft.Finance.VAT.Setup;
using Microsoft.FixedAssets.Depreciation;
using Microsoft.Foundation.AuditCodes;
using Microsoft.Foundation.Company;
using Microsoft.Foundation.Reporting;
using Microsoft.Foundation.Shipping;
using Microsoft.Foundation.UOM;
using Microsoft.Inventory.Counting.Document;
using Microsoft.Inventory.History;
using Microsoft.Inventory.Intrastat;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Journal;
using Microsoft.Inventory.Ledger;
using Microsoft.Inventory.Location;
using Microsoft.Inventory.Setup;
using Microsoft.Inventory.Transfer;
using Microsoft.Projects.Project.Journal;
using Microsoft.Projects.Project.Ledger;
using Microsoft.Projects.Resources.Resource;
using Microsoft.Purchases.Archive;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Purchases.Payables;
using Microsoft.Purchases.Setup;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Archive;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Document;
using Microsoft.Sales.FinanceCharge;
using Microsoft.Sales.History;
using Microsoft.Sales.Receivables;
using Microsoft.Sales.Reminder;
using Microsoft.Sales.Setup;
using Microsoft.Service.Document;
using Microsoft.Service.History;
using Microsoft.Service.Reports;
using Microsoft.Service.Setup;
using Microsoft.Utilities;
using System.IO;
using System.Security.Encryption;
using System.Security.User;
using System.Upgrade;

#pragma warning disable AL0432,AL0603
codeunit 11748 "Install Application CZL"
{
    Subtype = Install;
    Permissions = tabledata "Statutory Reporting Setup CZL" = im,
                  tabledata "Unreliable Payer Entry CZL" = im,
                  tabledata "Registration Log CZL" = im,
                  tabledata "Invt. Movement Template CZL" = im,
                  tabledata "VAT Period CZL" = im,
                  tabledata "VAT Ctrl. Report Section CZL" = im,
                  tabledata "VAT Ctrl. Report Header CZL" = im,
                  tabledata "VAT Ctrl. Report Line CZL" = im,
                  tabledata "VAT Ctrl. Report Ent. Link CZL" = i,
                  tabledata "VIES Declaration Header CZL" = im,
                  tabledata "VIES Declaration Line CZL" = im,
                  tabledata "Company Official CZL" = im,
                  tabledata "Document Footer CZL" = im,
                  tabledata "VAT Attribute Code CZL" = im,
                  tabledata "VAT Statement Comment Line CZL" = im,
                  tabledata "VAT Statement Attachment CZL" = im,
                  tabledata "Excel Template CZL" = im,
                  tabledata "Acc. Schedule File Mapping CZL" = im,
                  tabledata "Commodity CZL" = im,
                  tabledata "Commodity Setup CZL" = im,
                  tabledata "Statistic Indication CZL" = im,
                  tabledata "Stockkeeping Unit Template CZL" = im,
                  tabledata "Config. Template Header" = i,
                  tabledata "Config. Template Line" = i,
                  tabledata "Certificate Code CZL" = im,
                  tabledata "EET Service Setup CZL" = im,
                  tabledata "EET Business Premises CZL" = im,
                  tabledata "EET Cash Register CZL" = im,
                  tabledata "EET Entry CZL" = im,
                  tabledata "EET Entry Status Log CZL" = im,
                  tabledata "Constant Symbol CZL" = im,
                  tabledata "Specific Movement CZL" = im,
                  tabledata "Intrastat Delivery Group CZL" = im,
                  tabledata "User Setup Line CZL" = im,
                  tabledata "Acc. Schedule Extension CZL" = im,
                  tabledata "Acc. Schedule Result Line CZL" = im,
                  tabledata "Acc. Schedule Result Col. CZL" = im,
                  tabledata "Acc. Schedule Result Value CZL" = im,
                  tabledata "Acc. Schedule Result Hdr. CZL" = im,
                  tabledata "Acc. Schedule Result Hist. CZL" = im,
                  tabledata "Unrel. Payer Service Setup CZL" = im,
                  tabledata "SWIFT Code" = i,
                  tabledata "Source Code" = i,
                  tabledata "Company Information" = m,
                  tabledata "Responsibility Center" = m,
                  tabledata Customer = m,
                  tabledata Vendor = m,
                  tabledata "Vendor Bank Account" = m,
                  tabledata Contact = m,
                  tabledata "Item Journal Line" = m,
                  tabledata "Job Journal Line" = m,
                  tabledata "Phys. Invt. Order Line" = m,
                  tabledata "Inventory Setup" = m,
                  tabledata "General Ledger Setup" = m,
                  tabledata "Sales & Receivables Setup" = m,
                  tabledata "Purchases & Payables Setup" = m,
                  tabledata "Service Mgt. Setup" = m,
                  tabledata "User Setup" = m,
                  tabledata "G/L Entry" = m,
                  tabledata "Cust. Ledger Entry" = m,
                  tabledata "Detailed Cust. Ledg. Entry" = m,
                  tabledata "Vendor Ledger Entry" = m,
                  tabledata "Detailed Vendor Ledg. Entry" = m,
                  tabledata "VAT Entry" = m,
                  tabledata "Gen. Journal Line" = m,
                  tabledata "Sales Header" = m,
                  tabledata "Sales Shipment Header" = m,
                  tabledata "Sales Invoice Header" = m,
                  tabledata "Sales Cr.Memo Header" = m,
                  tabledata "Return Receipt Header" = m,
                  tabledata "Sales Header Archive" = m,
                  tabledata "Purchase Header" = m,
                  tabledata "Purch. Rcpt. Header" = m,
                  tabledata "Purch. Inv. Header" = m,
                  tabledata "Purch. Cr. Memo Hdr." = m,
                  tabledata "Return Shipment Header" = m,
                  tabledata "Purchase Header Archive" = m,
                  tabledata "Service Header" = m,
                  tabledata "Service Shipment Header" = m,
                  tabledata "Service Invoice Header" = m,
                  tabledata "Service Cr.Memo Header" = m,
                  tabledata "Reminder Header" = m,
                  tabledata "Issued Reminder Header" = m,
                  tabledata "Finance Charge Memo Header" = m,
                  tabledata "Issued Fin. Charge Memo Header" = m,
                  tabledata "VAT Posting Setup" = m,
                  tabledata "VAT Statement Template" = m,
                  tabledata "VAT Statement Line" = m,
                  tabledata "G/L Account" = m,
                  tabledata "Acc. Schedule Name" = m,
                  tabledata "Acc. Schedule Line" = m,
                  tabledata "Purchase Line" = m,
                  tabledata "Purch. Cr. Memo Line" = m,
                  tabledata "Purch. Inv. Line" = m,
                  tabledata "Purch. Rcpt. Line" = m,
                  tabledata "Sales Line" = m,
                  tabledata "Sales Cr.Memo Line" = m,
                  tabledata "Sales Invoice Line" = m,
                  tabledata "Sales Shipment Line" = m,
                  tabledata "Tariff Number" = m,
                  tabledata "Source Code Setup" = m,
                  tabledata "Stockkeeping Unit" = m,
                  tabledata Item = m,
                  tabledata Resource = m,
                  tabledata "Service Line" = m,
                  tabledata "Service Invoice Line" = m,
                  tabledata "Service Cr.Memo Line" = m,
                  tabledata "Service Shipment Line" = m,
                  tabledata "Isolated Certificate" = m,
                  tabledata "Bank Account" = m,
                  tabledata "Depreciation Book" = m,
                  tabledata "Value Entry" = m,
                  tabledata "Shipment Method" = m,
                  tabledata "Unit of Measure" = m,
                  tabledata "Sales Line Archive" = m,
                  tabledata "Purchase Line Archive" = m,
                  tabledata "Transfer Header" = m,
                  tabledata "Transfer Line" = m,
                  tabledata "Transfer Receipt Header" = m,
                  tabledata "Transfer Shipment Header" = m,
                  tabledata "Item Ledger Entry" = m,
                  tabledata "Job Ledger Entry" = m,
                  tabledata "Item Charge" = m,
                  tabledata "Item Charge Assignment (Purch)" = m,
                  tabledata "Item Charge Assignment (Sales)" = m,
                  tabledata "Posted Gen. Journal Line" = m,
                  tabledata "Intrastat Jnl. Batch" = m,
                  tabledata "Intrastat Jnl. Line" = m,
                  tabledata "Inventory Posting Setup" = m,
                  tabledata "General Posting Setup" = m,
                  tabledata "Gen. Journal Template" = m,
                  tabledata "Report Selections" = m,
                  tabledata "Item Journal Template" = m;

    var
        InstallApplicationsMgtCZL: Codeunit "Install Applications Mgt. CZL";
        AppInfo: ModuleInfo;

    trigger OnInstallAppPerCompany()
    begin
        if not InitializeDone() then begin
            BindSubscription(InstallApplicationsMgtCZL);
            CopyData();
            ModifyData();
            UnbindSubscription(InstallApplicationsMgtCZL);
        end;
        CompanyInitialize();
    end;

    local procedure InitializeDone(): Boolean
    begin
        NavApp.GetCurrentModuleInfo(AppInfo);
        exit(AppInfo.DataVersion() <> Version.Create('0.0.0.0'));
    end;

    local procedure CopyData()
    begin
        CopyCompanyInformation();
        CopyCustomer();
        CopyVendor();
        CopyGLSetup();
        CopySalesHeader();
        CopySalesInvoiceHeader();
        CopySalesCrMemoHeader();
        CopySalesHeaderArchive();
        CopyPurchaseHeader();
        CopyPurchaseInvoiceHeader();
        CopyPurchaseCrMemoHeader();
        CopyPurchaseHeaderArchive();
        CopyServiceHeader();
        CopyServiceInvoiceHeader();
        CopyServiceCrMemoHeader();
        CopyIssuedReminderHeader();
        CopyVATStatementTemplate();
        CopyVATStatementLine();
        CopyAccScheduleLine();
        CopySourceCodeSetup();
        InitUnreliablePayerServiceSetup();
        InitVATCtrlReportSections();
        InitStatutoryReportingSetup();
        InitSourceCodeSetup();
    end;

    local procedure ModifyData()
    begin
        ModifyGenJournalTemplate();
        ModifyReportSelections();
        ModifyItemJournalTemplate();
    end;

    local procedure CopyCompanyInformation();
    var
        StatutoryReportingSetupCZL: Record "Statutory Reporting Setup CZL";
    begin
        if not StatutoryReportingSetupCZL.Get() then begin
            StatutoryReportingSetupCZL.Init();
            StatutoryReportingSetupCZL.Insert();
        end;
    end;

    local procedure CopyCustomer();
    var
        Customer: Record Customer;
        CustomerDataTransfer: DataTransfer;
    begin
        CustomerDataTransfer.SetTables(Database::Customer, Database::Customer);
        CustomerDataTransfer.AddConstantValue(true, Customer.FieldNo("Allow Multiple Posting Groups"));
        CustomerDataTransfer.CopyFields();
    end;

    local procedure CopyVendor();
    var
        Vendor: Record Vendor;
        VendorDataTransfer: DataTransfer;
    begin
        VendorDataTransfer.SetTables(Database::Vendor, Database::Vendor);
        VendorDataTransfer.AddConstantValue(true, Vendor.FieldNo("Allow Multiple Posting Groups"));
        VendorDataTransfer.CopyFields();
    end;

    local procedure CopyGLSetup();
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        StatutoryReportingSetupCZL: Record "Statutory Reporting Setup CZL";
        VATSetup: Record "VAT Setup";
    begin
        if GeneralLedgerSetup.Get() then begin
            GeneralLedgerSetup."VAT Reporting Date Usage" := GeneralLedgerSetup."VAT Reporting Date Usage"::Disabled;
            GeneralLedgerSetup.Modify(false);
            if not StatutoryReportingSetupCZL.Get() then begin
                StatutoryReportingSetupCZL.Init();
                StatutoryReportingSetupCZL.Insert();
            end;
            if not VATSetup.Get() then begin
                VATSetup.Init();
                VATSetup.Insert();
            end;
        end;
    end;



    local procedure CopySalesHeader();
    var
        SalesHeader: Record "Sales Header";
        SalesHeaderDataTransfer: DataTransfer;
    begin
        SalesHeaderDataTransfer.SetTables(Database::"Sales Header", Database::"Sales Header");
        SalesHeaderDataTransfer.AddFieldValue(SalesHeader.FieldNo("Currency Code"), SalesHeader.FieldNo("VAT Currency Code CZL"));
        SalesHeaderDataTransfer.CopyFields();
    end;

    local procedure CopySalesInvoiceHeader();
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesInvoiceHeaderDataTransfer: DataTransfer;
    begin
        SalesInvoiceHeaderDataTransfer.SetTables(Database::"Sales Invoice Header", Database::"Sales Invoice Header");
        SalesInvoiceHeaderDataTransfer.AddFieldValue(SalesInvoiceHeader.FieldNo("Currency Code"), SalesInvoiceHeader.FieldNo("VAT Currency Code CZL"));
        SalesInvoiceHeaderDataTransfer.CopyFields();
    end;

    local procedure CopySalesCrMemoHeader();
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesCrMemoHeaderDataTransfer: DataTransfer;
    begin
        SalesCrMemoHeaderDataTransfer.SetTables(Database::"Sales Cr.Memo Header", Database::"Sales Cr.Memo Header");
        SalesCrMemoHeaderDataTransfer.AddFieldValue(SalesCrMemoHeader.FieldNo("Currency Code"), SalesCrMemoHeader.FieldNo("VAT Currency Code CZL"));
        SalesCrMemoHeaderDataTransfer.CopyFields();
    end;


    local procedure CopySalesHeaderArchive();
    var
        SalesHeaderArchive: Record "Sales Header Archive";
        SalesHeaderArchiveDataTransfer: DataTransfer;
    begin
        SalesHeaderArchiveDataTransfer.SetTables(Database::"Sales Header Archive", Database::"Sales Header Archive");
        SalesHeaderArchiveDataTransfer.AddFieldValue(SalesHeaderArchive.FieldNo("Currency Code"), SalesHeaderArchive.FieldNo("VAT Currency Code CZL"));
        SalesHeaderArchiveDataTransfer.CopyFields();
    end;

    local procedure CopyPurchaseHeader();
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseHeaderDataTransfer: DataTransfer;
    begin
        PurchaseHeaderDataTransfer.SetTables(Database::"Purchase Header", Database::"Purchase Header");
        PurchaseHeaderDataTransfer.AddFieldValue(PurchaseHeader.FieldNo("Currency Code"), PurchaseHeader.FieldNo("VAT Currency Code CZL"));
        PurchaseHeaderDataTransfer.CopyFields();
    end;

    local procedure CopyPurchaseInvoiceHeader();
    var
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchInvHeaderDataTransfer: DataTransfer;
    begin
        PurchInvHeaderDataTransfer.SetTables(Database::"Purch. Inv. Header", Database::"Purch. Inv. Header");
        PurchInvHeaderDataTransfer.AddFieldValue(PurchInvHeader.FieldNo("Currency Code"), PurchInvHeader.FieldNo("VAT Currency Code CZL"));
        PurchInvHeaderDataTransfer.CopyFields();
    end;

    local procedure CopyPurchaseCrMemoHeader();
    var
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        PurchCrMemoHdrDataTransfer: DataTransfer;
    begin
        PurchCrMemoHdrDataTransfer.SetTables(Database::"Purch. Cr. Memo Hdr.", Database::"Purch. Cr. Memo Hdr.");
        PurchCrMemoHdrDataTransfer.AddFieldValue(PurchCrMemoHdr.FieldNo("Currency Code"), PurchCrMemoHdr.FieldNo("VAT Currency Code CZL"));
        PurchCrMemoHdrDataTransfer.CopyFields();
    end;

    local procedure CopyPurchaseHeaderArchive();
    var
        PurchaseHeaderArchive: Record "Purchase Header Archive";
        PurchaseHeaderArchiveDataTransfer: DataTransfer;
    begin
        PurchaseHeaderArchiveDataTransfer.SetTables(Database::"Purchase Header Archive", Database::"Purchase Header Archive");
        PurchaseHeaderArchiveDataTransfer.AddFieldValue(PurchaseHeaderArchive.FieldNo("Currency Code"), PurchaseHeaderArchive.FieldNo("VAT Currency Code CZL"));
        PurchaseHeaderArchiveDataTransfer.CopyFields();
    end;

    local procedure CopyServiceHeader();
    var
        ServiceHeader: Record "Service Header";
        ServiceHeaderDataTransfer: DataTransfer;
    begin
        ServiceHeaderDataTransfer.SetTables(Database::"Service Header", Database::"Service Header");
        ServiceHeaderDataTransfer.AddFieldValue(ServiceHeader.FieldNo("Currency Code"), ServiceHeader.FieldNo("VAT Currency Code CZL"));
        ServiceHeaderDataTransfer.CopyFields();
    end;

    local procedure CopyServiceInvoiceHeader();
    var
        ServiceInvoiceHeader: Record "Service Invoice Header";
        ServiceInvoiceHeaderDataTransfer: DataTransfer;
    begin
        ServiceInvoiceHeaderDataTransfer.SetTables(Database::"Service Invoice Header", Database::"Service Invoice Header");
        ServiceInvoiceHeaderDataTransfer.AddFieldValue(ServiceInvoiceHeader.FieldNo("Currency Code"), ServiceInvoiceHeader.FieldNo("VAT Currency Code CZL"));
        ServiceInvoiceHeaderDataTransfer.CopyFields();
    end;

    local procedure CopyServiceCrMemoHeader();
    var
        ServiceCrMemoHeader: Record "Service Cr.Memo Header";
        ServiceCrMemoHeaderDataTransfer: DataTransfer;
    begin
        ServiceCrMemoHeaderDataTransfer.SetTables(Database::"Service Cr.Memo Header", Database::"Service Cr.Memo Header");
        ServiceCrMemoHeaderDataTransfer.AddFieldValue(ServiceCrMemoHeader.FieldNo("Currency Code"), ServiceCrMemoHeader.FieldNo("VAT Currency Code CZL"));
        ServiceCrMemoHeaderDataTransfer.CopyFields();
    end;

    local procedure CopyIssuedReminderHeader();
    var
        IssuedReminderHeader: Record "Issued Reminder Header";
        IssuedReminderHeaderDataTransfer: DataTransfer;
    begin
        IssuedReminderHeaderDataTransfer.SetTables(Database::"Issued Reminder Header", Database::"Issued Reminder Header");
        IssuedReminderHeaderDataTransfer.AddFieldValue(IssuedReminderHeader.FieldNo("Specific Symbol"), IssuedReminderHeader.FieldNo("Specific Symbol CZL"));
        IssuedReminderHeaderDataTransfer.AddFieldValue(IssuedReminderHeader.FieldNo("Variable Symbol"), IssuedReminderHeader.FieldNo("Variable Symbol CZL"));
        IssuedReminderHeaderDataTransfer.AddFieldValue(IssuedReminderHeader.FieldNo("Constant Symbol"), IssuedReminderHeader.FieldNo("Constant Symbol CZL"));
        IssuedReminderHeaderDataTransfer.AddFieldValue(IssuedReminderHeader.FieldNo("Bank No."), IssuedReminderHeader.FieldNo("Bank Account Code CZL"));
        IssuedReminderHeaderDataTransfer.AddFieldValue(IssuedReminderHeader.FieldNo("Bank Account No."), IssuedReminderHeader.FieldNo("Bank Account No. CZL"));
        IssuedReminderHeaderDataTransfer.AddFieldValue(IssuedReminderHeader.FieldNo("Bank Branch No."), IssuedReminderHeader.FieldNo("Bank Branch No. CZL"));
        IssuedReminderHeaderDataTransfer.AddFieldValue(IssuedReminderHeader.FieldNo("Bank Name"), IssuedReminderHeader.FieldNo("Bank Name CZL"));
        IssuedReminderHeaderDataTransfer.AddFieldValue(IssuedReminderHeader.FieldNo("Transit No."), IssuedReminderHeader.FieldNo("Transit No. CZL"));
        IssuedReminderHeaderDataTransfer.AddFieldValue(IssuedReminderHeader.FieldNo(IBAN), IssuedReminderHeader.FieldNo("IBAN CZL"));
        IssuedReminderHeaderDataTransfer.AddFieldValue(IssuedReminderHeader.FieldNo("SWIFT Code"), IssuedReminderHeader.FieldNo("SWIFT Code CZL"));
        IssuedReminderHeaderDataTransfer.CopyFields();
    end;

    local procedure CopyVATStatementTemplate();
    var
        VATStatementTemplate: Record "VAT Statement Template";
    begin
        VATStatementTemplate.SetLoadFields("XML Format CZL");
        if VATStatementTemplate.FindSet() then
            repeat
                VATStatementTemplate."XML Format CZL" := VATStatementTemplate."XML Format CZL"::DPHDP3;
                VATStatementTemplate.Modify(false);
            until VATStatementTemplate.Next() = 0;
    end;

    local procedure CopyVATStatementLine();
    var
        VATStatementLine: Record "VAT Statement Line";
    begin
        VATStatementLine.SetLoadFields(Type);
        if VATStatementLine.FindSet() then
            repeat
                ConvertVATStatementLineDeprEnumValues(VATStatementLine);
                VATStatementLine.Modify(false);
            until VATStatementLine.Next() = 0;
    end;

    local procedure ConvertVATStatementLineDeprEnumValues(var VATStatementLine: Record "VAT Statement Line");
    begin
        if VATStatementLine.Type = 4 then //4 = VATStatementLine.Type::Formula
            VATStatementLine.Type := VATStatementLine.Type::"Formula CZL";
    end;


    local procedure CopyAccScheduleLine();
    var
        AccScheduleLine: Record "Acc. Schedule Line";
    begin
        AccScheduleLine.SetLoadFields("Totaling Type");
        if AccScheduleLine.FindSet() then
            repeat
                ConvertAccScheduleLineTotalingTypeEnumValues(AccScheduleLine);
                AccScheduleLine.Modify(false);
            until AccScheduleLine.Next() = 0;
    end;

    local procedure ConvertAccScheduleLineTotalingTypeEnumValues(var AccScheduleLine: Record "Acc. Schedule Line");
    begin
        if AccScheduleLine."Totaling Type" = 14 then //14 = AccScheduleLine.Type::Custom
            AccScheduleLine."Totaling Type" := AccScheduleLine."Totaling Type"::"Custom CZL";
        if AccScheduleLine."Totaling Type" = 15 then //15 = AccScheduleLine.Type::Constant
            AccScheduleLine."Totaling Type" := AccScheduleLine."Totaling Type"::"Constant CZL";
    end;

    local procedure CopySourceCodeSetup();
    var
        SourceCodeSetup: Record "Source Code Setup";
    begin
        SourceCodeSetup.SetLoadFields("Sales VAT Delay", "Purchase VAT Delay");
        if SourceCodeSetup.Get() then begin
            SourceCodeSetup."Sales VAT Delay CZL" := SourceCodeSetup."Sales VAT Delay";
            SourceCodeSetup."Purchase VAT Delay CZL" := SourceCodeSetup."Purchase VAT Delay";
            SourceCodeSetup.Modify(false);
        end;

    end;

    local procedure CreateTemplateHeader(var ConfigTemplateHeader: Record "Config. Template Header"; "Code": Code[10]; Description: Text[100]; TableID: Integer)
    begin
        ConfigTemplateHeader.Init();
        ConfigTemplateHeader.Code := Code;
        ConfigTemplateHeader.Description := Description;
        ConfigTemplateHeader."Table ID" := TableID;
        ConfigTemplateHeader.Enabled := true;
        ConfigTemplateHeader.Insert();
    end;

    local procedure CreateTemplateLine(var ConfigTemplateHeader: Record "Config. Template Header"; FieldID: Integer; Value: Text[50])
    var
        ConfigTemplateLine: Record "Config. Template Line";
        NextLineNo: Integer;
    begin
        NextLineNo := 10000;
        ConfigTemplateLine.SetRange("Data Template Code", ConfigTemplateHeader.Code);
        if ConfigTemplateLine.FindLast() then
            NextLineNo := ConfigTemplateLine."Line No." + 10000;

        ConfigTemplateLine.Init();
        ConfigTemplateLine.Validate("Data Template Code", ConfigTemplateHeader.Code);
        ConfigTemplateLine.Validate("Line No.", NextLineNo);
        ConfigTemplateLine.Validate(Type, ConfigTemplateLine.Type::Field);
        ConfigTemplateLine.Validate("Table ID", ConfigTemplateHeader."Table ID");
        ConfigTemplateLine.Validate("Field ID", FieldID);
        ConfigTemplateLine."Default Value" := Value;
        ConfigTemplateLine.Insert(true);
    end;

    local procedure GetNextDataTemplateAvailableCode(): Code[10]
    var
        ConfigTemplateHeader: Record "Config. Template Header";
        StockkeepingUnitConfigTemplCode: Code[10];
        StockkeepingUnitConfigTemplCodeTxt: Label 'SKU0000000', MaxLength = 10;
    begin
        StockkeepingUnitConfigTemplCode := StockkeepingUnitConfigTemplCodeTxt;
        repeat
            StockkeepingUnitConfigTemplCode := CopyStr(IncStr(StockkeepingUnitConfigTemplCode), 1, MaxStrLen(ConfigTemplateHeader.Code));
        until not ConfigTemplateHeader.Get(StockkeepingUnitConfigTemplCode);
        exit(StockkeepingUnitConfigTemplCode);
    end;

    local procedure ModifyGenJournalTemplate()
    var
        GenJournalTemplate: Record "Gen. Journal Template";
        PrevGenJournalTemplate: Record "Gen. Journal Template";
    begin
        if GenJournalTemplate.FindSet(true) then
            repeat
                PrevGenJournalTemplate := GenJournalTemplate;
                GenJournalTemplate."Test Report ID" := Report::"General Journal - Test CZL";
                if GenJournalTemplate."Posting Report ID" = 11763 then
                    GenJournalTemplate."Posting Report ID" := Report::"General Ledger Document CZL";
                if (GenJournalTemplate."Test Report ID" <> PrevGenJournalTemplate."Test Report ID") or (GenJournalTemplate."Posting Report ID" <> PrevGenJournalTemplate."Posting Report ID") then
                    GenJournalTemplate.Modify(false);
            until GenJournalTemplate.Next() = 0;
    end;

    local procedure ModifyReportSelections()
    var
        ReportSelections: Record "Report Selections";
        PrevReportSelections: Record "Report Selections";
    begin
        if ReportSelections.FindSet(true) then
            repeat
                PrevReportSelections := ReportSelections;
                case ReportSelections."Report ID" of
                    31094,
                    Report::"Standard Sales - Quote":
                        ReportSelections."Report ID" := Report::"Sales Quote CZL";
                    31095,
                    Report::"Standard Sales - Order Conf.":
                        ReportSelections."Report ID" := Report::"Sales Order Confirmation CZL";
                    31096,
                    Report::"Standard Sales - Invoice":
                        ReportSelections."Report ID" := Report::"Sales Invoice CZL";
                    31093,
                    Report::"Return Order Confirmation":
                        ReportSelections."Report ID" := Report::"Sales Return Order Confirm CZL";
                    31097,
                    Report::"Standard Sales - Credit Memo":
                        ReportSelections."Report ID" := Report::"Sales Credit Memo CZL";
                    31098,
                    Report::"Sales - Shipment":
                        ReportSelections."Report ID" := Report::"Sales Shipment CZL";
                    31099,
                    Report::"Sales - Return Receipt":
                        ReportSelections."Report ID" := Report::"Sales Return Reciept CZL";
                    31091,
                    Report::"Purchase - Quote":
                        ReportSelections."Report ID" := Report::"Purchase Quote CZL";
                    31092,
                    Report::Order,
                    Report::"Standard Purchase - Order":
                        ReportSelections."Report ID" := Report::"Purchase Order CZL";
                    31110,
                    Report::"Service Quote":
                        ReportSelections."Report ID" := Report::"Service Quote CZL";
                    31111,
                    Report::"Service Order":
                        ReportSelections."Report ID" := Report::"Service Order CZL";
                    31088,
                    Report::"Service - Invoice":
                        ReportSelections."Report ID" := Report::"Service Invoice CZL";
                    31089,
                    Report::"Service - Credit Memo":
                        ReportSelections."Report ID" := Report::"Service Credit Memo CZL";
                    31090,
                    Report::"Service - Shipment":
                        ReportSelections."Report ID" := Report::"Service Shipment CZL";
                    31112,
                    Report::"Service Contract Quote":
                        ReportSelections."Report ID" := Report::"Service Contract Quote CZL";
                    31113,
                    Report::"Service Contract":
                        ReportSelections."Report ID" := Report::"Service Contract CZL";
                    31086,
                    Report::Reminder:
                        ReportSelections."Report ID" := Report::"Reminder CZL";
                    31087,
                    Report::"Finance Charge Memo":
                        ReportSelections."Report ID" := Report::"Finance Charge Memo CZL";
                    Report::"Blanket Purchase Order":
                        ReportSelections."Report ID" := Report::"Blanket Purchase Order CZL";
                end;
                if ReportSelections."Report ID" <> PrevReportSelections."Report ID" then
                    ReportSelections.Modify();
            until ReportSelections.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Company-Initialize", 'OnCompanyInitialize', '', false, false)]
    local procedure CompanyInitialize()
    var
        DataClassEvalHandlerCZL: Codeunit "Data Class. Eval. Handler CZL";
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        InitRegistrationNoServiceConfig();
        CreateUnreliablePayerSrviceSetup();
        CreatetVATCtrlReportSections();
        CreateStatutoryReportingSetup();
        InitSWIFTCodes();
        InitEETServiceSetup();
        CreateSourceCodeSetup();
        ModifyReportSelections();

        DataClassEvalHandlerCZL.ApplyEvaluationClassificationsForPrivacy();
        UpgradeTag.SetAllUpgradeTags();
    end;

    local procedure InitRegistrationNoServiceConfig()
    var
        RegistrationLogMgtCZL: Codeunit "Registration Log Mgt. CZL";
    begin
        RegistrationLogMgtCZL.SetupService();
    end;

    local procedure CreateUnreliablePayerSrviceSetup()
    var
        UnrelPayerServiceSetupCZL: Record "Unrel. Payer Service Setup CZL";
    begin
        if not UnrelPayerServiceSetupCZL.Get() then
            InitUnreliablePayerServiceSetup();
    end;

    local procedure InitUnreliablePayerServiceSetup()
    var
        UnrelPayerServiceSetupCZL: Record "Unrel. Payer Service Setup CZL";
        PrevUnrelPayerServiceSetupCZL: Record "Unrel. Payer Service Setup CZL";
        UnreliablePayerMgtCZL: Codeunit "Unreliable Payer Mgt. CZL";
        UnreliablePayerWSCZL: Codeunit "Unreliable Payer WS CZL";
    begin
        if not UnrelPayerServiceSetupCZL.Get() then begin
            UnrelPayerServiceSetupCZL.Init();
            UnrelPayerServiceSetupCZL.Insert();
        end;

        PrevUnrelPayerServiceSetupCZL := UnrelPayerServiceSetupCZL;
        UnreliablePayerMgtCZL.SetDefaultUnreliablePayerServiceURL(UnrelPayerServiceSetupCZL);
        UnrelPayerServiceSetupCZL.Enabled := false;
        UnrelPayerServiceSetupCZL."Public Bank Acc.Chck.Star.Date" := 20140101D;
        UnrelPayerServiceSetupCZL."Public Bank Acc.Check Limit" := 700000;
        UnrelPayerServiceSetupCZL."Unr.Payer Request Record Limit" := UnreliablePayerWSCZL.GetDefaultInputRecordLimit();

        if (UnrelPayerServiceSetupCZL."Unreliable Payer Web Service" <> PrevUnrelPayerServiceSetupCZL."Unreliable Payer Web Service") or
           (UnrelPayerServiceSetupCZL.Enabled <> PrevUnrelPayerServiceSetupCZL.Enabled) or
           (UnrelPayerServiceSetupCZL."Public Bank Acc.Chck.Star.Date" <> PrevUnrelPayerServiceSetupCZL."Public Bank Acc.Chck.Star.Date") or
           (UnrelPayerServiceSetupCZL."Public Bank Acc.Check Limit" <> PrevUnrelPayerServiceSetupCZL."Public Bank Acc.Check Limit") or
           (UnrelPayerServiceSetupCZL."Unr.Payer Request Record Limit" <> PrevUnrelPayerServiceSetupCZL."Unr.Payer Request Record Limit")
        then
            UnrelPayerServiceSetupCZL.Modify();
    end;

    local procedure CreatetVATCtrlReportSections()
    var
        VATCtrlReportSectionCZL: Record "VAT Ctrl. Report Section CZL";
    begin
        if not VATCtrlReportSectionCZL.IsEmpty() then
            exit;

        InitVATCtrlReportSections();
    end;

    local procedure InitVATCtrlReportSections()
    var
        XA1Tok: Label 'A1', Locked = true;
        XA2Tok: Label 'A2', Locked = true;
        XA3Tok: Label 'A3', Locked = true;
        XA4Tok: Label 'A4', Locked = true;
        XA5Tok: Label 'A5', Locked = true;
        XB1Tok: Label 'B1', Locked = true;
        XB2Tok: Label 'B2', Locked = true;
        XB3Tok: Label 'B3', Locked = true;
        XReverseChargeSalesTxt: Label 'Reverse charge sales';
        XReverseChargePurchaseTxt: Label 'Reverse charge purchase';
        XEUPurchaseTxt: Label 'EU purchase';
        XSalesOfInvestmentGoldTxt: Label 'Sales of investment gold';
        XDomesticSalesAbove10ThousandTxt: Label 'Domestic sales above 10 thousand';
        XDomesticSalesBelow10ThousandTxt: Label 'Domestic sales below 10 thousand';
        XDomesticPurchaseAbove10ThousandTxt: Label 'Domestic purchase above 10 thousand';
        XDomesticPurchaseBelow10ThousandTxt: Label 'Domestic purchase below 10 thousand';
    begin
        InsertVATCtrlReportSection(XA1Tok, XReverseChargeSalesTxt, 0, '');
        InsertVATCtrlReportSection(XA2Tok, XEUPurchaseTxt, 1, '');
        InsertVATCtrlReportSection(XA3Tok, XSalesOfInvestmentGoldTxt, 0, '');
        InsertVATCtrlReportSection(XA4Tok, XDomesticSalesAbove10ThousandTxt, 0, XA5Tok);
        InsertVATCtrlReportSection(XA5Tok, XDomesticSalesBelow10ThousandTxt, 2, '');
        InsertVATCtrlReportSection(XB1Tok, XReverseChargePurchaseTxt, 1, '');
        InsertVATCtrlReportSection(XB2Tok, XDomesticPurchaseAbove10ThousandTxt, 1, XB3Tok);
        InsertVATCtrlReportSection(XB3Tok, XDomesticPurchaseBelow10ThousandTxt, 2, '');
    end;

    local procedure InsertVATCtrlReportSection(VATCtrlReportCode: Code[20]; VATCtrlReportDescription: Text[50]; GroupBy: Option; SimplifiedTaxDocSectCode: Code[20])
    var
        VATCtrlReportSectionCZL: Record "VAT Ctrl. Report Section CZL";
    begin
        if VATCtrlReportSectionCZL.Get(VATCtrlReportCode) then
            exit;
        VATCtrlReportSectionCZL.Init();
        VATCtrlReportSectionCZL.Code := VATCtrlReportCode;
        VATCtrlReportSectionCZL.Description := VATCtrlReportDescription;
        VATCtrlReportSectionCZL."Group By" := GroupBy;
        VATCtrlReportSectionCZL."Simplified Tax Doc. Sect. Code" := SimplifiedTaxDocSectCode;
        VATCtrlReportSectionCZL.Insert();
    end;

    local procedure CreateStatutoryReportingSetup()
    var
        StatutoryReportingSetupCZL: Record "Statutory Reporting Setup CZL";
    begin
        if not StatutoryReportingSetupCZL.Get() then
            InitStatutoryReportingSetup();
    end;

    local procedure InitStatutoryReportingSetup()
    var
        StatutoryReportingSetupCZL: Record "Statutory Reporting Setup CZL";
        PrevStatutoryReportingSetupCZL: Record "Statutory Reporting Setup CZL";
    begin
        if not StatutoryReportingSetupCZL.Get() then begin
            StatutoryReportingSetupCZL.Init();
            StatutoryReportingSetupCZL.Insert();
        end;

        PrevStatutoryReportingSetupCZL := StatutoryReportingSetupCZL;
        StatutoryReportingSetupCZL."VAT Control Report XML Format" := StatutoryReportingSetupCZL."VAT Control Report XML Format"::"03_01_03";
        StatutoryReportingSetupCZL."Simplified Tax Document Limit" := 10000;
        StatutoryReportingSetupCZL."VIES Declaration Report No." := Report::"VIES Declaration CZL";
        StatutoryReportingSetupCZL."VIES Declaration Export No." := Xmlport::"VIES Declaration CZL";

        if (StatutoryReportingSetupCZL."VAT Control Report XML Format" <> PrevStatutoryReportingSetupCZL."VAT Control Report XML Format") or
           (StatutoryReportingSetupCZL."Simplified Tax Document Limit" <> PrevStatutoryReportingSetupCZL."Simplified Tax Document Limit") or
           (StatutoryReportingSetupCZL."VIES Declaration Report No." <> PrevStatutoryReportingSetupCZL."VIES Declaration Report No.") or
           (StatutoryReportingSetupCZL."VIES Declaration Export No." <> PrevStatutoryReportingSetupCZL."VIES Declaration Export No.")
        then
            StatutoryReportingSetupCZL.Modify();
    end;

    local procedure InitSWIFTCodes()
    var
        KOMBCZPPTok: Label 'KOMBCZPP', Locked = true;
        KOMBCZPPTxt: Label 'Komerční banka, a.s.';
        CEKOCZPPTok: Label 'CEKOCZPP', Locked = true;
        CEKOCZPPTxt: Label 'Československá obchodní banka, a.s.';
        CNBACZPPTok: Label 'CNBACZPP', Locked = true;
        CNBACZPPTxt: Label 'Česká národní banka';
        GIBACZPXTok: Label 'GIBACZPX', Locked = true;
        GIBACZPXTxt: Label 'Česká spořitelna, a.s.';
        AGBACZPPTok: Label 'AGBACZPP', Locked = true;
        AGBACZPPTxt: Label 'MONETA Money Bank, a.s.';
        FIOBCZPPTok: Label 'FIOBCZPP', Locked = true;
        FIOBCZPPTxt: Label 'Fio banka, a.s.';
        BACXCZPPTok: Label 'BACXCZPP', Locked = true;
        BACXCZPPTxt: Label 'UniCredit Bank Czech Republic and Slovakia, a.s.';
        AIRACZPPTok: Label 'AIRACZPP', Locked = true;
        AIRACZPPTxt: Label 'Air Bank a.s.';
        INGBCZPPTok: Label 'INGBCZPP', Locked = true;
        INGBCZPPTxt: Label 'ING Bank N.V.';
        RZBCCZPPTok: Label 'RZBCCZPP', Locked = true;
        RZBCCZPPTxt: Label 'Raiffeisenbank a.s.';
        JTBPCZPPTok: Label 'JTBPCZPP', Locked = true;
        JTBPCZPPTxt: Label 'J & T Banka, a.s.';
        PMBPCZPPTok: Label 'PMBPCZPP', Locked = true;
        PMBPCZPPTxt: Label 'PPF banka a.s.';
        EQBKCZPPTok: Label 'EQBKCZPP', Locked = true;
        EQBKCZPPTxt: Label 'Equa bank a.s.';
    begin
        InsertSWIFTCode(KOMBCZPPTok, KOMBCZPPTxt);
        InsertSWIFTCode(CEKOCZPPTok, CEKOCZPPTxt);
        InsertSWIFTCode(CNBACZPPTok, CNBACZPPTxt);
        InsertSWIFTCode(GIBACZPXTok, GIBACZPXTxt);
        InsertSWIFTCode(AGBACZPPTok, AGBACZPPTxt);
        InsertSWIFTCode(FIOBCZPPTok, FIOBCZPPTxt);
        InsertSWIFTCode(BACXCZPPTok, BACXCZPPTxt);
        InsertSWIFTCode(AIRACZPPTok, AIRACZPPTxt);
        InsertSWIFTCode(INGBCZPPTok, INGBCZPPTxt);
        InsertSWIFTCode(RZBCCZPPTok, RZBCCZPPTxt);
        InsertSWIFTCode(JTBPCZPPTok, JTBPCZPPTxt);
        InsertSWIFTCode(PMBPCZPPTok, PMBPCZPPTxt);
        InsertSWIFTCode(EQBKCZPPTok, EQBKCZPPTxt);
    end;

    local procedure InsertSWIFTCode(SWIFTCodeCode: Code[20]; SWIFTCodeName: Text[100])
    var
        SWIFTCode: Record "SWIFT Code";
    begin
        if SWIFTCode.Get(SWIFTCodeCode) then
            exit;
        SWIFTCode.Init();
        SWIFTCode.Code := SWIFTCodeCode;
        SWIFTCode.Name := SWIFTCodeName;
        SWIFTCode.Insert();
    end;

    local procedure InitEETServiceSetup()
    var
        EETServiceSetupCZL: Record "EET Service Setup CZL";
    begin
        if EETServiceSetupCZL.Get() then
            exit;

        EETServiceSetupCZL.Init();
        EETServiceSetupCZL.SetURLToDefault(false);
        EETServiceSetupCZL.Insert(true);
    end;

    local procedure CreateSourceCodeSetup()
    var
        SourceCodeSetup: Record "Source Code Setup";
        PrevSourceCodeSetup: Record "Source Code Setup";
        PurchaseVATDelaySourceCodeTxt: Label 'VATPD', MaxLength = 10;
        PurchaseVATDelaySourceCodeDescriptionTxt: Label 'Purchase VAT Delay', MaxLength = 100;
        SalesVATDelaySourceCodeTxt: Label 'VATSD', MaxLength = 10;
        SalesVATDelaySourceCodeDescriptionTxt: Label 'Sales VAT Delay', MaxLength = 100;
        VATLCYCorrectionSourceCodeTxt: Label 'VATCORR', MaxLength = 10;
        VATLCYCorrectionSourceCodeDescriptionTxt: Label 'VAT Correction in LCY', MaxLength = 100;
        OpenBalanceSheetSourceCodeTxt: Label 'OPBALANCE', MaxLength = 10;
        OpenBalanceSheetSourceCodeDescriptionTxt: Label 'Open Balance Sheet', MaxLength = 100;
        CloseBalanceSheetSourceCodeTxt: Label 'CLBALANCE', MaxLength = 10;
        CloseBalanceSheetSourceCodeDescriptionTxt: Label 'Close Balance Sheet', MaxLength = 100;
    begin
        if not SourceCodeSetup.Get() then
            exit;
        PrevSourceCodeSetup := SourceCodeSetup;
        if SourceCodeSetup."Purchase VAT Delay CZL" = '' then
            InsertSourceCode(SourceCodeSetup."Purchase VAT Delay CZL", PurchaseVATDelaySourceCodeTxt, PurchaseVATDelaySourceCodeDescriptionTxt);
        if SourceCodeSetup."Sales VAT Delay CZL" = '' then
            InsertSourceCode(SourceCodeSetup."Sales VAT Delay CZL", SalesVATDelaySourceCodeTxt, SalesVATDelaySourceCodeDescriptionTxt);
        if SourceCodeSetup."VAT LCY Correction CZL" = '' then
            InsertSourceCode(SourceCodeSetup."VAT LCY Correction CZL", VATLCYCorrectionSourceCodeTxt, VATLCYCorrectionSourceCodeDescriptionTxt);
        if SourceCodeSetup."Open Balance Sheet CZL" = '' then
            InsertSourceCode(SourceCodeSetup."Open Balance Sheet CZL", OpenBalanceSheetSourceCodeTxt, OpenBalanceSheetSourceCodeDescriptionTxt);
        if SourceCodeSetup."Close Balance Sheet CZL" = '' then
            InsertSourceCode(SourceCodeSetup."Close Balance Sheet CZL", CloseBalanceSheetSourceCodeTxt, CloseBalanceSheetSourceCodeDescriptionTxt);

        if (SourceCodeSetup."Purchase VAT Delay CZL" <> PrevSourceCodeSetup."Purchase VAT Delay CZL") or
           (SourceCodeSetup."Sales VAT Delay CZL" <> PrevSourceCodeSetup."Sales VAT Delay CZL") or
           (SourceCodeSetup."VAT LCY Correction CZL" <> PrevSourceCodeSetup."VAT LCY Correction CZL") or
           (SourceCodeSetup."Open Balance Sheet CZL" <> PrevSourceCodeSetup."Open Balance Sheet CZL") or
           (SourceCodeSetup."Close Balance Sheet CZL" <> PrevSourceCodeSetup."Close Balance Sheet CZL")
        then
            SourceCodeSetup.Modify();
    end;

    local procedure InitSourceCodeSetup()
    var
        SourceCodeSetup: Record "Source Code Setup";
        PrevSourceCodeSetup: Record "Source Code Setup";
        PurchaseVATDelaySourceCodeTxt: Label 'VATPD', MaxLength = 10;
        PurchaseVATDelaySourceCodeDescriptionTxt: Label 'Purchase VAT Delay', MaxLength = 100;
        SalesVATDelaySourceCodeTxt: Label 'VATSD', MaxLength = 10;
        SalesVATDelaySourceCodeDescriptionTxt: Label 'Sales VAT Delay', MaxLength = 100;
        VATLCYCorrectionSourceCodeTxt: Label 'VATCORR', MaxLength = 10;
        VATLCYCorrectionSourceCodeDescriptionTxt: Label 'VAT Correction in LCY', MaxLength = 100;
        OpenBalanceSheetSourceCodeTxt: Label 'OPBALANCE', MaxLength = 10;
        OpenBalanceSheetSourceCodeDescriptionTxt: Label 'Open Balance Sheet', MaxLength = 100;
        CloseBalanceSheetSourceCodeTxt: Label 'CLBALANCE', MaxLength = 10;
        CloseBalanceSheetSourceCodeDescriptionTxt: Label 'Close Balance Sheet', MaxLength = 100;
    begin
        if not SourceCodeSetup.Get() then
            SourceCodeSetup.Init();
        PrevSourceCodeSetup := SourceCodeSetup;
        InsertSourceCode(SourceCodeSetup."Purchase VAT Delay CZL", PurchaseVATDelaySourceCodeTxt, PurchaseVATDelaySourceCodeDescriptionTxt);
        InsertSourceCode(SourceCodeSetup."Sales VAT Delay CZL", SalesVATDelaySourceCodeTxt, SalesVATDelaySourceCodeDescriptionTxt);
        InsertSourceCode(SourceCodeSetup."VAT LCY Correction CZL", VATLCYCorrectionSourceCodeTxt, VATLCYCorrectionSourceCodeDescriptionTxt);
        InsertSourceCode(SourceCodeSetup."Open Balance Sheet CZL", OpenBalanceSheetSourceCodeTxt, OpenBalanceSheetSourceCodeDescriptionTxt);
        InsertSourceCode(SourceCodeSetup."Close Balance Sheet CZL", CloseBalanceSheetSourceCodeTxt, CloseBalanceSheetSourceCodeDescriptionTxt);

        if (SourceCodeSetup."Purchase VAT Delay CZL" <> PrevSourceCodeSetup."Purchase VAT Delay CZL") or
           (SourceCodeSetup."Sales VAT Delay CZL" <> PrevSourceCodeSetup."Sales VAT Delay CZL") or
           (SourceCodeSetup."VAT LCY Correction CZL" <> PrevSourceCodeSetup."VAT LCY Correction CZL") or
           (SourceCodeSetup."Open Balance Sheet CZL" <> PrevSourceCodeSetup."Open Balance Sheet CZL") or
           (SourceCodeSetup."Close Balance Sheet CZL" <> PrevSourceCodeSetup."Close Balance Sheet CZL")
        then
            SourceCodeSetup.Modify();
    end;

    local procedure InsertSourceCode(var SourceCodeDefCode: Code[10]; "Code": Code[10]; Description: Text[100])
    var
        SourceCode: Record "Source Code";
    begin
        SourceCodeDefCode := Code;
        if SourceCode.Get(Code) then
            exit;
        SourceCode.Init();
        SourceCode.Code := Code;
        SourceCode.Description := Description;
        SourceCode.Insert();
    end;

    local procedure ModifyItemJournalTemplate()
    var
        ItemJournalTemplate: Record "Item Journal Template";
        PrevItemJournalTemplate: Record "Item Journal Template";
    begin
        if ItemJournalTemplate.FindSet(true) then
            repeat
                PrevItemJournalTemplate := ItemJournalTemplate;
                if ItemJournalTemplate."Posting Report ID" = 31078 then
                    ItemJournalTemplate."Posting Report ID" := Report::"Posted Inventory Document CZL";
                if (ItemJournalTemplate."Posting Report ID" <> PrevItemJournalTemplate."Posting Report ID") then
                    ItemJournalTemplate.Modify();
            until ItemJournalTemplate.Next() = 0;
    end;
}