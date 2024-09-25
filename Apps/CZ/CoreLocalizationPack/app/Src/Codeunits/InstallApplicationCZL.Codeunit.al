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
                  tabledata "EET Service Setup" = m,
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

    trigger OnInstallAppPerDatabase()
    begin
        CopyPermission();
    end;

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

    local procedure CopyPermission();
    begin
        NavApp.GetCurrentModuleInfo(AppInfo);
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Constant Symbol", Database::"Constant Symbol CZL");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Excel Template", Database::"Excel Template CZL");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Statement File Mapping", Database::"Acc. Schedule File Mapping CZL");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"VAT Attribute Code", Database::"VAT Attribute Code CZL");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Uncertainty Payer Entry", Database::"Unreliable Payer Entry CZL");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Electronically Govern. Setup", Database::"Unrel. Payer Service Setup CZL");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Reg. No. Srv Config", Database::"Reg. No. Service Config CZL");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Registration Log", Database::"Registration Log CZL");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"VAT Period", Database::"VAT Period CZL");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"VAT Statement Comment Line", Database::"VAT Statement Comment Line CZL");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"VAT Statement Attachment", Database::"VAT Statement Attachment CZL");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Company Officials", Database::"Company Official CZL");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Stockkeeping Unit Template", Database::"Stockkeeping Unit Template CZL");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Whse. Net Change Template", Database::"Invt. Movement Template CZL");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Statistic Indication", Database::"Statistic Indication CZL");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"VIES Declaration Header", Database::"VIES Declaration Header CZL");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"VIES Declaration Line", Database::"VIES Declaration Line CZL");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Commodity", Database::"Commodity CZL");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Commodity Setup", Database::"Commodity Setup CZL");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Stat. Reporting Setup", Database::"Statutory Reporting Setup CZL");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"VAT Control Report Header", Database::"VAT Ctrl. Report Header CZL");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"VAT Control Report Line", Database::"VAT Ctrl. Report Line CZL");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"VAT Control Report Section", Database::"VAT Ctrl. Report Section CZL");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"VAT Control Report Buffer", Database::"VAT Ctrl. Report Buffer CZL");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"VAT Ctrl.Rep. - VAT Entry Link", Database::"VAT Ctrl. Report Ent. Link CZL");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Document Footer", Database::"Document Footer CZL");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Certificate CZ Code", Database::"Certificate Code CZL");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"EET Business Premises", Database::"EET Business Premises CZL");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"EET Cash Register", Database::"EET Cash Register CZL");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"EET Entry", Database::"EET Entry CZL");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"EET Entry Status", Database::"EET Entry Status Log CZL");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"EET Service Setup", Database::"EET Service Setup CZL");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Subst. Customer Posting Group", Database::"Alt. Customer Posting Group");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Subst. Vendor Posting Group", Database::"Alt. Vendor Posting Group");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Specific Movement", Database::"Specific Movement CZL");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Intrastat Delivery Group", Database::"Intrastat Delivery Group CZL");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Acc. Schedule Extension", Database::"Acc. Schedule Extension CZL");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Acc. Schedule Result Line", Database::"Acc. Schedule Result Line CZL");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Acc. Schedule Result Column", Database::"Acc. Schedule Result Col. CZL");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Acc. Schedule Result Value", Database::"Acc. Schedule Result Value CZL");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Acc. Schedule Result Header", Database::"Acc. Schedule Result Hdr. CZL");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Acc. Schedule Result History", Database::"Acc. Schedule Result Hist. CZL");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"User Setup Line", Database::"User Setup Line CZL");
    end;

    local procedure CopyData()
    begin
        CopyCompanyInformation();
        CopyResponsibilityCenter();
        CopyCustomer();
        CopyVendor();
        CopyVendorBankAccount();
        CopyContact();
        CopyUncertaintyPayerEntry();
        CopyRegistrationLog();
        CopyWhseNetChangeTemplate();
        CopyItemJournalLine();
        CopyJobJournalLine();
        CopyPhysInvtOrderLine();
        CopyInventorySetup();
        CopyGLSetup();
        CopySalesSetup();
        CopyPurchaseSetup();
        CopyServiceSetup();
        CopyUserSetup();
        CopyVATPeriod();
        CopyGLEntry();
        CopyCustLedgerEntry();
        CopyDetailedCustLedgEntry();
        CopyVendLedgerEntry();
        CopyDetailedVendorLedgEntry();
        CopyVATEntry();
        CopyGenJournalLine();
        CopySalesHeader();
        CopySalesShipmentHeader();
        CopySalesInvoiceHeader();
        CopySalesCrMemoHeader();
        CopyReturnReceiptHeader();
        CopySalesHeaderArchive();
        CopyPurchaseHeader();
        CopyPurchaseReceiptHeader();
        CopyPurchaseInvoiceHeader();
        CopyPurchaseCrMemoHeader();
        CopyReturnShipmentHeader();
        CopyPurchaseHeaderArchive();
        CopyServiceHeader();
        CopyServiceShipmentHeader();
        CopyServiceInvoiceHeader();
        CopyServiceCrMemoHeader();
        CopyReminderHeader();
        CopyIssuedReminderHeader();
        CopyFinanceChargeMemoHeader();
        CopyIssuedFinanceChargeMemoHeader();
        CopyStatutoryReportingSetup();
        CopyVATControlReportSection();
        CopyVATControlReportHeader();
        CopyVATControlReportLine();
        CopyVATControlReportEntryLink();
        CopyVATPostingSetup();
        CopyVATStatementTemplate();
        CopyVATStatementLine();
        CopyVIESDeclarationHeader();
        CopyVIESDeclarationLine();
        CopyCompanyOfficials();
        CopyDocumentFooter();
        CopyGLAccount();
        CopyVATAttributeCode();
        CopyVATStatementCommentLine();
        CopyVATStatementAttachment();
        CopyAccScheduleName();
        CopyAccScheduleLine();
        CopyExcelTemplate();
        CopyStatementFileMapping();
        CopyPurchaseLine();
        CopyPurchCrMemoLine();
        CopyPurchInvLine();
        CopyPurchRcptLine();
        CopySalesCrMemoLine();
        CopySalesInvoiceLine();
        CopySalesLine();
        CopySalesShipmentLine();
        CopyTariffNumber();
        CopyCommodity();
        CopyCommoditySetup();
        CopyStatisticIndication();
        CopySourceCodeSetup();
        CopyStockkeepingUnitTemplate();
        CopyStockkeepingUnit();
        CopyItem();
        CopyResource();
        CopyServiceLine();
        CopyServiceInvoiceLine();
        CopyServiceCrMemoLine();
        CopyServiceShipmentLine();
        CopyCertificateCZCode();
        CopyIsolatedCertificate();
        CopyEETServiceSetup();
        CopyEETBusinessPremises();
        CopyEETCashRegister();
        CopyEETEntry();
        CopyEETEntryStatus();
        CopyBankAccount();
        CopyConstantSymbol();
        CopyDepreciationBook();
        CopyValueEntry();
        CopySubstCustomerPostingGroup();
        CopySubstVendorPostingGroup();
        CopyShipmentMethod();
        CopySpecificMovement();
        CopyIntrastatDeliveryGroup();
        CopyUnitofMeasure();
        CopySalesLineArchive();
        CopyPurchaseLineArchive();
        CopyTransferHeader();
        CopyTransferLine();
        CopyTransferReceiptHeader();
        CopyTransferShipmentHeader();
        CopyItemLedgerEntry();
        CopyJobLedgerEntry();
        CopyItemCharge();
        CopyItemChargeAssignmentPurch();
        CopyItemChargeAssignmentSales();
        CopyPostedGenJournalLine();
        CopyIntrastatJournalBatch();
        CopyIntrastatJournalLine();
        CopyInventoryPostingSetup();
        CopyGeneralPostingSetup();
        CopyUserSetupLine();
        CopyAccScheduleExtension();
        CopyAccScheduleResultLine();
        CopyAccScheduleResultColumn();
        CopyAccScheduleResultValue();
        CopyAccScheduleResultHeader();
        CopyAccScheduleResultHistory();
        CopyGenJournalTemplate();
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
        CompanyInformation: Record "Company Information";
        StatutoryReportingSetupCZL: Record "Statutory Reporting Setup CZL";
    begin
        CompanyInformation.SetLoadFields("Default Bank Account Code", "Bank Account Format Check", "Tax Registration No.", "Primary Business Activity",
                                         "Court Authority No.", "Tax Authority No.", "Registration Date", "Equity Capital", "Paid Equity Capital",
                                         "General Manager No.", "Accounting Manager No.", "Finance Manager No.");
        if CompanyInformation.Get() then begin
            CompanyInformation."Default Bank Account Code CZL" := CompanyInformation."Default Bank Account Code";
            CompanyInformation."Bank Account Format Check CZL" := CompanyInformation."Bank Account Format Check";
            CompanyInformation."Tax Registration No. CZL" := CompanyInformation."Tax Registration No.";
            CompanyInformation.Modify(false);
        end;

        if not StatutoryReportingSetupCZL.Get() then begin
            StatutoryReportingSetupCZL.Init();
            StatutoryReportingSetupCZL.Insert();
        end;
        StatutoryReportingSetupCZL."Primary Business Activity" := CompanyInformation."Primary Business Activity";
        StatutoryReportingSetupCZL."Court Authority No." := CompanyInformation."Court Authority No.";
        StatutoryReportingSetupCZL."Tax Authority No." := CompanyInformation."Tax Authority No.";
        StatutoryReportingSetupCZL."Registration Date" := CompanyInformation."Registration Date";
        StatutoryReportingSetupCZL."Equity Capital" := CompanyInformation."Equity Capital";
        StatutoryReportingSetupCZL."Paid Equity Capital" := CompanyInformation."Paid Equity Capital";
        StatutoryReportingSetupCZL."General Manager No." := CompanyInformation."General Manager No.";
        StatutoryReportingSetupCZL."Accounting Manager No." := CompanyInformation."Accounting Manager No.";
        StatutoryReportingSetupCZL."Finance Manager No." := CompanyInformation."Finance Manager No.";
        StatutoryReportingSetupCZL.Modify();
    end;

    local procedure CopyResponsibilityCenter();
    var
        ResponsibilityCenter: Record "Responsibility Center";
        ResponsibilityCenterDataTransfer: DataTransfer;
    begin
        ResponsibilityCenterDataTransfer.SetTables(Database::"Responsibility Center", Database::"Responsibility Center");
        ResponsibilityCenterDataTransfer.AddFieldValue(ResponsibilityCenter.FieldNo("Bank Account Code"), ResponsibilityCenter.FieldNo("Default Bank Account Code CZL"));
        ResponsibilityCenterDataTransfer.CopyFields();
    end;

    local procedure CopyCustomer();
    var
        Customer: Record Customer;
        CustomerDataTransfer: DataTransfer;
    begin
        CustomerDataTransfer.SetTables(Database::Customer, Database::Customer);
        CustomerDataTransfer.AddFieldValue(Customer.FieldNo("Registration No."), Customer.FieldNo("Registration Number"));
        CustomerDataTransfer.AddFieldValue(Customer.FieldNo("Tax Registration No."), Customer.FieldNo("Tax Registration No. CZL"));
        CustomerDataTransfer.AddFieldValue(Customer.FieldNo("Transaction Type"), Customer.FieldNo("Transaction Type CZL"));
        CustomerDataTransfer.AddFieldValue(Customer.FieldNo("Transaction Specification"), Customer.FieldNo("Transaction Specification CZL"));
        CustomerDataTransfer.AddFieldValue(Customer.FieldNo("Transport Method"), Customer.FieldNo("Transport Method CZL"));
        CustomerDataTransfer.AddConstantValue(true, Customer.FieldNo("Allow Multiple Posting Groups"));
        CustomerDataTransfer.CopyFields();
    end;

    local procedure CopyVendor();
    var
        Vendor: Record Vendor;
        VendorDataTransfer: DataTransfer;
    begin
        VendorDataTransfer.SetTables(Database::Vendor, Database::Vendor);
        VendorDataTransfer.AddFieldValue(Vendor.FieldNo("Registration No."), Vendor.FieldNo("Registration Number"));
        VendorDataTransfer.AddFieldValue(Vendor.FieldNo("Tax Registration No."), Vendor.FieldNo("Tax Registration No. CZL"));
        VendorDataTransfer.AddFieldValue(Vendor.FieldNo("Disable Uncertainty Check"), Vendor.FieldNo("Disable Unreliab. Check CZL"));
        VendorDataTransfer.AddFieldValue(Vendor.FieldNo("Transaction Type"), Vendor.FieldNo("Transaction Type CZL"));
        VendorDataTransfer.AddFieldValue(Vendor.FieldNo("Transaction Specification"), Vendor.FieldNo("Transaction Specification CZL"));
        VendorDataTransfer.AddFieldValue(Vendor.FieldNo("Transport Method"), Vendor.FieldNo("Transport Method CZL"));
        VendorDataTransfer.AddConstantValue(true, Vendor.FieldNo("Allow Multiple Posting Groups"));
        VendorDataTransfer.CopyFields();
    end;

    local procedure CopyVendorBankAccount();
    var
        VendorBankAccount: Record "Vendor Bank Account";
        VendorBankAccountDataTransfer: DataTransfer;
    begin
        VendorBankAccountDataTransfer.SetTables(Database::"Vendor Bank Account", Database::"Vendor Bank Account");
        VendorBankAccountDataTransfer.AddFieldValue(VendorBankAccount.FieldNo("Third Party Bank Account"), VendorBankAccount.FieldNo("Third Party Bank Account CZL"));
        VendorBankAccountDataTransfer.CopyFields();
    end;

    local procedure CopyContact();
    var
        Contact: Record Contact;
        ContactDataTransfer: DataTransfer;
    begin
        ContactDataTransfer.SetTables(Database::Contact, Database::Contact);
        ContactDataTransfer.AddFieldValue(Contact.FieldNo("Registration No."), Contact.FieldNo("Registration Number"));
        ContactDataTransfer.AddFieldValue(Contact.FieldNo("Tax Registration No."), Contact.FieldNo("Tax Registration No. CZL"));
        ContactDataTransfer.CopyFields();
    end;

    local procedure CopyUncertaintyPayerEntry();
    var
        UncertaintyPayerEntry: Record "Uncertainty Payer Entry";
        UnreliablePayerEntryCZL: Record "Unreliable Payer Entry CZL";
    begin
        if UncertaintyPayerEntry.FindSet() then
            repeat
                if not UnreliablePayerEntryCZL.Get(UncertaintyPayerEntry."Entry No.") then begin
                    UnreliablePayerEntryCZL.Init();
                    UnreliablePayerEntryCZL."Entry No." := UncertaintyPayerEntry."Entry No.";
                    UnreliablePayerEntryCZL.SystemId := UncertaintyPayerEntry.SystemId;
                    UnreliablePayerEntryCZL.Insert(false, true);
                end;
                UnreliablePayerEntryCZL."Vendor No." := UncertaintyPayerEntry."Vendor No.";
                UnreliablePayerEntryCZL."Check Date" := UncertaintyPayerEntry."Check Date";
                UnreliablePayerEntryCZL."Public Date" := UncertaintyPayerEntry."Public Date";
                UnreliablePayerEntryCZL."End Public Date" := UncertaintyPayerEntry."End Public Date";
                UnreliablePayerEntryCZL."Unreliable Payer" := UncertaintyPayerEntry."Uncertainty Payer";
                UnreliablePayerEntryCZL."Entry Type" := UncertaintyPayerEntry."Entry Type";
                UnreliablePayerEntryCZL."VAT Registration No." := UncertaintyPayerEntry."VAT Registration No.";
                UnreliablePayerEntryCZL."Tax Office Number" := UncertaintyPayerEntry."Tax Office Number";
                UnreliablePayerEntryCZL."Full Bank Account No." := UncertaintyPayerEntry."Full Bank Account No.";
                UnreliablePayerEntryCZL."Bank Account No. Type" := UncertaintyPayerEntry."Bank Account No. Type";
                UnreliablePayerEntryCZL.Modify(false);
            until UncertaintyPayerEntry.Next() = 0;
    end;

    local procedure CopyRegistrationLog();
    var
        RegistrationLog: Record "Registration Log";
        RegistrationLogCZL: Record "Registration Log CZL";
    begin
        if RegistrationLog.FindSet() then
            repeat
                if not RegistrationLogCZL.Get(RegistrationLog."Entry No.") then begin
                    RegistrationLogCZL.Init();
                    RegistrationLogCZL."Entry No." := RegistrationLog."Entry No.";
                    RegistrationLogCZL.SystemId := RegistrationLog.SystemId;
                    RegistrationLogCZL.Insert(false, true);
                end;
                RegistrationLogCZL."Registration No." := RegistrationLog."Registration No.";
                RegistrationLogCZL."Account Type" := RegistrationLog."Account Type";
                RegistrationLogCZL."Account No." := RegistrationLog."Account No.";
                RegistrationLogCZL.Status := RegistrationLog.Status;
                RegistrationLogCZL."Verified Name" := RegistrationLog."Verified Name";
                RegistrationLogCZL."Verified Address" := RegistrationLog."Verified Address";
                RegistrationLogCZL."Verified City" := RegistrationLog."Verified City";
                RegistrationLogCZL."Verified Post Code" := RegistrationLog."Verified Post Code";
                RegistrationLogCZL."Verified VAT Registration No." := RegistrationLog."Verified VAT Registration No.";
                RegistrationLogCZL."Verified Date" := RegistrationLog."Verified Date";
                RegistrationLogCZL."Verified Result" := RegistrationLog."Verified Result";
                RegistrationLogCZL."User ID" := RegistrationLog."User ID";
                RegistrationLogCZL.Modify(false);
            until RegistrationLog.Next() = 0;
    end;

    local procedure CopyWhseNetChangeTemplate();
    var
        WhseNetChangeTemplate: Record "Whse. Net Change Template";
        InvtMovementTemplateCZL: Record "Invt. Movement Template CZL";
    begin
        if WhseNetChangeTemplate.FindSet() then
            repeat
                if not InvtMovementTemplateCZL.Get(WhseNetChangeTemplate.Name) then begin
                    InvtMovementTemplateCZL.Init();
                    InvtMovementTemplateCZL.Name := WhseNetChangeTemplate.Name;
                    InvtMovementTemplateCZL.SystemId := WhseNetChangeTemplate.SystemId;
                    InvtMovementTemplateCZL.Insert(false, true);
                end;
                InvtMovementTemplateCZL.Description := WhseNetChangeTemplate.Description;
                InvtMovementTemplateCZL."Entry Type" := WhseNetChangeTemplate."Entry Type";
                InvtMovementTemplateCZL."Gen. Bus. Posting Group" := WhseNetChangeTemplate."Gen. Bus. Posting Group";
                InvtMovementTemplateCZL.Modify(false);
            until WhseNetChangeTemplate.Next() = 0;
    end;

    local procedure CopyItemJournalLine();
    var
        ItemJournalLine: Record "Item Journal Line";
        ItemJournalLineDataTransfer: DataTransfer;
    begin
        ItemJournalLineDataTransfer.SetTables(Database::"Item Journal Line", Database::"Item Journal Line");
        ItemJournalLineDataTransfer.AddFieldValue(ItemJournalLine.FieldNo("Tariff No."), ItemJournalLine.FieldNo("Tariff No. CZL"));
        ItemJournalLineDataTransfer.AddFieldValue(ItemJournalLine.FieldNo("Physical Transfer"), ItemJournalLine.FieldNo("Physical Transfer CZL"));
        ItemJournalLineDataTransfer.AddFieldValue(ItemJournalLine.FieldNo("Incl. in Intrastat Amount"), ItemJournalLine.FieldNo("Incl. in Intrastat Amount CZL"));
        ItemJournalLineDataTransfer.AddFieldValue(ItemJournalLine.FieldNo("Incl. in Intrastat Stat. Value"), ItemJournalLine.FieldNo("Incl. in Intrastat S.Value CZL"));
        ItemJournalLineDataTransfer.AddFieldValue(ItemJournalLine.FieldNo("Net Weight"), ItemJournalLine.FieldNo("Net Weight CZL"));
        ItemJournalLineDataTransfer.AddFieldValue(ItemJournalLine.FieldNo("Country/Region of Origin Code"), ItemJournalLine.FieldNo("Country/Reg. of Orig. Code CZL"));
        ItemJournalLineDataTransfer.AddFieldValue(ItemJournalLine.FieldNo("Statistic Indication"), ItemJournalLine.FieldNo("Statistic Indication CZL"));
        ItemJournalLineDataTransfer.AddFieldValue(ItemJournalLine.FieldNo("Intrastat Transaction"), ItemJournalLine.FieldNo("Intrastat Transaction CZL"));
        ItemJournalLineDataTransfer.AddFieldValue(ItemJournalLine.FieldNo("Whse. Net Change Template"), ItemJournalLine.FieldNo("Invt. Movement Template CZL"));
        ItemJournalLineDataTransfer.AddFieldValue(ItemJournalLine.FieldNo("G/L Correction"), ItemJournalLine.FieldNo("G/L Correction CZL"));
        ItemJournalLineDataTransfer.CopyFields();
    end;

    local procedure CopyJobJournalLine();
    var
        JobJournalLine: Record "Job Journal Line";
        JobJournalLineDataTransfer: DataTransfer;
    begin
        JobJournalLineDataTransfer.SetTables(Database::"Job Journal Line", Database::"Job Journal Line");
        JobJournalLineDataTransfer.AddFieldValue(JobJournalLine.FieldNo("Whse. Net Change Template"), JobJournalLine.FieldNo("Invt. Movement Template CZL"));
        JobJournalLineDataTransfer.AddFieldValue(JobJournalLine.FieldNo("Correction"), JobJournalLine.FieldNo("Correction CZL"));
        JobJournalLineDataTransfer.AddFieldValue(JobJournalLine.FieldNo("Tariff No."), JobJournalLine.FieldNo("Tariff No. CZL"));
        JobJournalLineDataTransfer.AddFieldValue(JobJournalLine.FieldNo("Net Weight"), JobJournalLine.FieldNo("Net Weight CZL"));
        JobJournalLineDataTransfer.AddFieldValue(JobJournalLine.FieldNo("Country/Region of Origin Code"), JobJournalLine.FieldNo("Country/Reg. of Orig. Code CZL"));
        JobJournalLineDataTransfer.AddFieldValue(JobJournalLine.FieldNo("Statistic Indication"), JobJournalLine.FieldNo("Statistic Indication CZL"));
        JobJournalLineDataTransfer.AddFieldValue(JobJournalLine.FieldNo("Intrastat Transaction"), JobJournalLine.FieldNo("Intrastat Transaction CZL"));
        JobJournalLineDataTransfer.CopyFields();
    end;

    local procedure CopyPhysInvtOrderLine();
    var
        PhysInvtOrderLine: Record "Phys. Invt. Order Line";
        PhysInvtOrderLineDataTransfer: DataTransfer;
    begin
        PhysInvtOrderLineDataTransfer.SetTables(Database::"Phys. Invt. Order Line", Database::"Phys. Invt. Order Line");
        PhysInvtOrderLineDataTransfer.AddFieldValue(PhysInvtOrderLine.FieldNo("Whse. Net Change Template"), PhysInvtOrderLine.FieldNo("Invt. Movement Template CZL"));
        PhysInvtOrderLineDataTransfer.CopyFields();
    end;

    local procedure CopyInventorySetup();
    var
        InventorySetup: Record "Inventory Setup";
    begin
        InventorySetup.SetLoadFields("Date Order Inventory Change", "Def.Template for Phys.Pos.Adj", "Def.Template for Phys.Neg.Adj", "Post Exp. Cost Conv. as Corr.", "Post Neg. Transfers as Corr.");
        if InventorySetup.Get() then begin
            InventorySetup."Date Order Invt. Change CZL" := InventorySetup."Date Order Inventory Change";
            InventorySetup."Def.Tmpl. for Phys.Pos.Adj CZL" := InventorySetup."Def.Template for Phys.Pos.Adj";
            InventorySetup."Def.Tmpl. for Phys.Neg.Adj CZL" := InventorySetup."Def.Template for Phys.Neg.Adj";
            InventorySetup."Post Exp.Cost Conv.As Corr.CZL" := InventorySetup."Post Exp. Cost Conv. as Corr.";
            InventorySetup."Post Neg.Transf. As Corr.CZL" := InventorySetup."Post Neg. Transfers as Corr.";
            InventorySetup.Modify(false);
        end;
    end;

    local procedure CopyGLSetup();
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        StatutoryReportingSetupCZL: Record "Statutory Reporting Setup CZL";
        VATSetup: Record "VAT Setup";
    begin
        if GeneralLedgerSetup.Get() then begin
            if GeneralLedgerSetup."Use VAT Date" then
                GeneralLedgerSetup."VAT Reporting Date Usage" := GeneralLedgerSetup."VAT Reporting Date Usage"::"Enabled (Prevent modification)"
            else
                GeneralLedgerSetup."VAT Reporting Date Usage" := GeneralLedgerSetup."VAT Reporting Date Usage"::Disabled;
            GeneralLedgerSetup."Allow VAT Posting From CZL" := GeneralLedgerSetup."Allow VAT Posting From";
            GeneralLedgerSetup."Allow VAT Posting To CZL" := GeneralLedgerSetup."Allow VAT Posting To";
            GeneralLedgerSetup."Do Not Check Dimensions CZL" := GeneralLedgerSetup."Dont Check Dimension";
            GeneralLedgerSetup."Check Posting Debit/Credit CZL" := GeneralLedgerSetup."Check Posting Debit/Credit";
            GeneralLedgerSetup."Mark Neg. Qty as Correct. CZL" := GeneralLedgerSetup."Mark Neg. Qty as Correction";
            GeneralLedgerSetup."Rounding Date CZL" := GeneralLedgerSetup."Rounding Date";
            GeneralLedgerSetup."Closed Per. Entry Pos.Date CZL" := GeneralLedgerSetup."Closed Period Entry Pos.Date";
            GeneralLedgerSetup."User Checks Allowed CZL" := GeneralLedgerSetup."User Checks Allowed";
            GeneralLedgerSetup."Shared Account Schedule CZL" := GeneralLedgerSetup."Shared Account Schedule";
            GeneralLedgerSetup."Acc. Schedule Results Nos. CZL" := GeneralLedgerSetup."Acc. Schedule Results Nos.";
            GeneralLedgerSetup.Modify(false);
            if not StatutoryReportingSetupCZL.Get() then begin
                StatutoryReportingSetupCZL.Init();
                StatutoryReportingSetupCZL.Insert();
            end;
            StatutoryReportingSetupCZL."Company Official Nos." := GeneralLedgerSetup."Company Officials Nos.";
            StatutoryReportingSetupCZL.Modify();
            if not VATSetup.Get() then begin
                VATSetup.Init();
                VATSetup.Insert();
            end;
            VATSetup."Allow VAT Date From" := GeneralLedgerSetup."Allow VAT Posting From";
            VATSetup."Allow VAT Date To" := GeneralLedgerSetup."Allow VAT Posting To";
            VATSetup.Modify();
        end;
    end;

    local procedure CopySalesSetup();
    var
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
    begin
        SalesReceivablesSetup.SetLoadFields("Default VAT Date", "Allow Alter Posting Groups");
        if SalesReceivablesSetup.Get() then begin
            SalesReceivablesSetup."Default VAT Date CZL" := SalesReceivablesSetup."Default VAT Date";
            SalesReceivablesSetup."Allow Multiple Posting Groups" := SalesReceivablesSetup."Allow Alter Posting Groups";
            SalesReceivablesSetup.Modify(false);
        end;
    end;

    local procedure CopyPurchaseSetup();
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
    begin
        PurchasesPayablesSetup.SetLoadFields("Default VAT Date", "Allow Alter Posting Groups", "Default Orig. Doc. VAT Date");
        if PurchasesPayablesSetup.Get() then begin
            PurchasesPayablesSetup."Default VAT Date CZL" := PurchasesPayablesSetup."Default VAT Date";
            PurchasesPayablesSetup."Allow Multiple Posting Groups" := PurchasesPayablesSetup."Allow Alter Posting Groups";
            GeneralLedgerSetup.Get();
            case PurchasesPayablesSetup."Default Orig. Doc. VAT Date" of
                PurchasesPayablesSetup."Default Orig. Doc. VAT Date"::Blank:
                    GeneralLedgerSetup."Def. Orig. Doc. VAT Date CZL" := Enum::"Default Orig.Doc. VAT Date CZL"::Blank;
                PurchasesPayablesSetup."Default Orig. Doc. VAT Date"::"Posting Date":
                    GeneralLedgerSetup."Def. Orig. Doc. VAT Date CZL" := Enum::"Default Orig.Doc. VAT Date CZL"::"Posting Date";
                PurchasesPayablesSetup."Default Orig. Doc. VAT Date"::"VAT Date":
                    GeneralLedgerSetup."Def. Orig. Doc. VAT Date CZL" := Enum::"Default Orig.Doc. VAT Date CZL"::"VAT Date";
                PurchasesPayablesSetup."Default Orig. Doc. VAT Date"::"Document Date":
                    GeneralLedgerSetup."Def. Orig. Doc. VAT Date CZL" := Enum::"Default Orig.Doc. VAT Date CZL"::"Document Date";
            end;

            GeneralLedgerSetup.Modify(false);
            PurchasesPayablesSetup.Modify(false);
        end;
    end;

    local procedure CopyServiceSetup();
    var
        ServiceMgtSetup: Record "Service Mgt. Setup";
    begin
        ServiceMgtSetup.SetLoadFields("Default VAT Date", "Allow Alter Cust. Post. Groups");
        if ServiceMgtSetup.Get() then begin
            ServiceMgtSetup."Default VAT Date CZL" := ServiceMgtSetup."Default VAT Date";
            ServiceMgtSetup."Allow Multiple Posting Groups" := ServiceMgtSetup."Allow Alter Cust. Post. Groups";
            ServiceMgtSetup.Modify(false);
        end;
    end;

    local procedure CopyUserSetup();
    var
        UserSetup: Record "User Setup";
        UserSetupDataTransfer: DataTransfer;
    begin
        UserSetupDataTransfer.SetTables(Database::"User Setup", Database::"User Setup");
        UserSetupDataTransfer.AddFieldValue(UserSetup.FieldNo("Allow VAT Posting From"), UserSetup.FieldNo("Allow VAT Posting From CZL"));
        UserSetupDataTransfer.AddFieldValue(UserSetup.FieldNo("Allow VAT Posting To"), UserSetup.FieldNo("Allow VAT Posting To CZL"));
        UserSetupDataTransfer.AddFieldValue(UserSetup.FieldNo("Allow VAT Posting From"), UserSetup.FieldNo("Allow VAT Date From"));
        UserSetupDataTransfer.AddFieldValue(UserSetup.FieldNo("Allow VAT Posting To"), UserSetup.FieldNo("Allow VAT Date To"));
        UserSetupDataTransfer.AddFieldValue(UserSetup.FieldNo("Check Document Date(work date)"), UserSetup.FieldNo("Check Doc. Date(work date) CZL"));
        UserSetupDataTransfer.AddFieldValue(UserSetup.FieldNo("Check Document Date(sys. date)"), UserSetup.FieldNo("Check Doc. Date(sys. date) CZL"));
        UserSetupDataTransfer.AddFieldValue(UserSetup.FieldNo("Check Posting Date (work date)"), UserSetup.FieldNo("Check Post.Date(work date) CZL"));
        UserSetupDataTransfer.AddFieldValue(UserSetup.FieldNo("Check Posting Date (sys. date)"), UserSetup.FieldNo("Check Post.Date(sys. date) CZL"));
        UserSetupDataTransfer.AddFieldValue(UserSetup.FieldNo("Check Bank Accounts"), UserSetup.FieldNo("Check Bank Accounts CZL"));
        UserSetupDataTransfer.AddFieldValue(UserSetup.FieldNo("Check Journal Templates"), UserSetup.FieldNo("Check Journal Templates CZL"));
        UserSetupDataTransfer.AddFieldValue(UserSetup.FieldNo("Check Dimension Values"), UserSetup.FieldNo("Check Dimension Values CZL"));
        UserSetupDataTransfer.AddFieldValue(UserSetup.FieldNo("Allow Posting to Closed Period"), UserSetup.FieldNo("Allow Post.toClosed Period CZL"));
        UserSetupDataTransfer.AddFieldValue(UserSetup.FieldNo("Allow Complete Job"), UserSetup.FieldNo("Allow Complete Job CZL"));
        UserSetupDataTransfer.AddFieldValue(UserSetup.FieldNo("Employee No."), UserSetup.FieldNo("Employee No. CZL"));
        UserSetupDataTransfer.AddFieldValue(UserSetup.FieldNo("User Name"), UserSetup.FieldNo("User Name CZL"));
        UserSetupDataTransfer.AddFieldValue(UserSetup.FieldNo("Allow Item Unapply"), UserSetup.FieldNo("Allow Item Unapply CZL"));
        UserSetupDataTransfer.AddFieldValue(UserSetup.FieldNo("Check Location Code"), UserSetup.FieldNo("Check Location Code CZL"));
        UserSetupDataTransfer.AddFieldValue(UserSetup.FieldNo("Check Release Location Code"), UserSetup.FieldNo("Check Release LocationCode CZL"));
        UserSetupDataTransfer.AddFieldValue(UserSetup.FieldNo("Check Whse. Net Change Temp."), UserSetup.FieldNo("Check Invt. Movement Temp. CZL"));
        UserSetupDataTransfer.CopyFields();
    end;

    local procedure CopyVATPeriod();
    var
        VATPeriod: Record "VAT Period";
        VATPeriodCZL: Record "VAT Period CZL";
    begin
        if VATPeriod.FindSet(true) then
            repeat
                if not VATPeriodCZL.Get(VATPeriod."Starting Date") then begin
                    VATPeriodCZL.Init();
                    VATPeriodCZL."Starting Date" := VATPeriod."Starting Date";
                    VATPeriodCZL.SystemId := VATPeriod.SystemId;
                    VATPeriodCZL.Insert(false, true);
                end;
                VATPeriodCZL.Name := VATPeriod.Name;
                VATPeriodCZL."New VAT Year" := VATPeriod."New VAT Year";
                VATPeriodCZL.Closed := VATPeriod.Closed;
                VATPeriodCZL.Modify(false);
            until VATPeriod.Next() = 0;
    end;

    local procedure CopyGLEntry();
    var
        GLEntry: Record "G/L Entry";
        GLEntryDataTransfer: DataTransfer;
        TotalRows: Integer;
        FromNo, ToNo : Integer;
    begin

        GLEntry.Reset();
        TotalRows := GLEntry.Count();
        ToNo := 0;

        while ToNo < TotalRows do begin
            // Batch size 5 million
            FromNo := ToNo + 1;
            ToNo := FromNo + 5000000;

            if ToNo > TotalRows then
                ToNo := TotalRows;

            GLEntryDataTransfer.SetTables(Database::"G/L Entry", Database::"G/L Entry");
            GLEntryDataTransfer.AddSourceFilter(GLEntry.FieldNo("Entry No."), '%1..%2', FromNo, ToNo);
            GLEntryDataTransfer.AddSourceFilter(GLEntry.FieldNo("VAT Date"), '<>%1', 0D);
            GLEntryDataTransfer.AddFieldValue(GLEntry.FieldNo("VAT Date"), GLEntry.FieldNo("VAT Reporting Date"));
            GLEntryDataTransfer.CopyFields();
            Clear(GLEntryDataTransfer);
        end;
    end;

    local procedure CopyCustLedgerEntry();
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        CustLedgerEntryDataTransfer: DataTransfer;
    begin
        CustLedgerEntryDataTransfer.SetTables(Database::"Cust. Ledger Entry", Database::"Cust. Ledger Entry");
        CustLedgerEntryDataTransfer.AddFieldValue(CustLedgerEntry.FieldNo("Specific Symbol"), CustLedgerEntry.FieldNo("Specific Symbol CZL"));
        CustLedgerEntryDataTransfer.AddFieldValue(CustLedgerEntry.FieldNo("Variable Symbol"), CustLedgerEntry.FieldNo("Variable Symbol CZL"));
        CustLedgerEntryDataTransfer.AddFieldValue(CustLedgerEntry.FieldNo("Constant Symbol"), CustLedgerEntry.FieldNo("Constant Symbol CZL"));
        CustLedgerEntryDataTransfer.AddFieldValue(CustLedgerEntry.FieldNo("Bank Account Code"), CustLedgerEntry.FieldNo("Bank Account Code CZL"));
        CustLedgerEntryDataTransfer.AddFieldValue(CustLedgerEntry.FieldNo("Bank Account No."), CustLedgerEntry.FieldNo("Bank Account No. CZL"));
        CustLedgerEntryDataTransfer.AddFieldValue(CustLedgerEntry.FieldNo("Transit No."), CustLedgerEntry.FieldNo("Transit No. CZL"));
        CustLedgerEntryDataTransfer.AddFieldValue(CustLedgerEntry.FieldNo(IBAN), CustLedgerEntry.FieldNo("IBAN CZL"));
        CustLedgerEntryDataTransfer.AddFieldValue(CustLedgerEntry.FieldNo("SWIFT Code"), CustLedgerEntry.FieldNo("SWIFT Code CZL"));
        CustLedgerEntryDataTransfer.AddFieldValue(CustLedgerEntry.FieldNo("VAT Date"), CustLedgerEntry.FieldNo("VAT Date CZL"));
        CustLedgerEntryDataTransfer.CopyFields();
    end;

    local procedure CopyDetailedCustLedgEntry();
    var
        DetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry";
    begin
        DetailedCustLedgEntry.SetLoadFields("Entry No.", "Customer Posting Group", "Entry Type", "Transaction No.");
        if DetailedCustLedgEntry.FindSet(true) then
            repeat
                DetailedCustLedgEntry."Posting Group" := DetailedCustLedgEntry."Customer Posting Group";
                DetailedCustLedgEntry.Modify(false);
            until DetailedCustLedgEntry.Next() = 0;
    end;

    internal procedure IsCustomerApplAcrossPostGrpTransaction(TransactionNo: Integer; var ApplTransactionDictionary: Dictionary of [Integer, Boolean]) ApplAcrossPostGroups: Boolean
    var
        DetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry";
        FirstCustomerPostingGroup: Code[20];
    begin
        if not ApplTransactionDictionary.Get(TransactionNo, ApplAcrossPostGroups) then begin
            FirstCustomerPostingGroup := '';
            DetailedCustLedgEntry.SetLoadFields("Customer Posting Group");
            DetailedCustLedgEntry.SetCurrentKey("Transaction No.", "Customer No.", "Entry Type");
            DetailedCustLedgEntry.SetRange("Transaction No.", TransactionNo);
            DetailedCustLedgEntry.SetRange("Entry Type", DetailedCustLedgEntry."Entry Type"::Application);
            if DetailedCustLedgEntry.FindSet() then
                repeat
                    if FirstCustomerPostingGroup = '' then
                        FirstCustomerPostingGroup := DetailedCustLedgEntry."Customer Posting Group";
                    ApplAcrossPostGroups := FirstCustomerPostingGroup <> DetailedCustLedgEntry."Customer Posting Group";
                until ApplAcrossPostGroups or (DetailedCustLedgEntry.Next() = 0);
            ApplTransactionDictionary.Add(TransactionNo, ApplAcrossPostGroups);
        end;
    end;

    local procedure CopyVendLedgerEntry();
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        VendorLedgerEntryDataTransfer: DataTransfer;
    begin
        VendorLedgerEntryDataTransfer.SetTables(Database::"Vendor Ledger Entry", Database::"Vendor Ledger Entry");
        VendorLedgerEntryDataTransfer.AddFieldValue(VendorLedgerEntry.FieldNo("Specific Symbol"), VendorLedgerEntry.FieldNo("Specific Symbol CZL"));
        VendorLedgerEntryDataTransfer.AddFieldValue(VendorLedgerEntry.FieldNo("Variable Symbol"), VendorLedgerEntry.FieldNo("Variable Symbol CZL"));
        VendorLedgerEntryDataTransfer.AddFieldValue(VendorLedgerEntry.FieldNo("Constant Symbol"), VendorLedgerEntry.FieldNo("Constant Symbol CZL"));
        VendorLedgerEntryDataTransfer.AddFieldValue(VendorLedgerEntry.FieldNo("Bank Account Code"), VendorLedgerEntry.FieldNo("Bank Account Code CZL"));
        VendorLedgerEntryDataTransfer.AddFieldValue(VendorLedgerEntry.FieldNo("Bank Account No."), VendorLedgerEntry.FieldNo("Bank Account No. CZL"));
        VendorLedgerEntryDataTransfer.AddFieldValue(VendorLedgerEntry.FieldNo("Transit No."), VendorLedgerEntry.FieldNo("Transit No. CZL"));
        VendorLedgerEntryDataTransfer.AddFieldValue(VendorLedgerEntry.FieldNo(IBAN), VendorLedgerEntry.FieldNo("IBAN CZL"));
        VendorLedgerEntryDataTransfer.AddFieldValue(VendorLedgerEntry.FieldNo("SWIFT Code"), VendorLedgerEntry.FieldNo("SWIFT Code CZL"));
        VendorLedgerEntryDataTransfer.AddFieldValue(VendorLedgerEntry.FieldNo("VAT Date"), VendorLedgerEntry.FieldNo("VAT Date CZL"));
        VendorLedgerEntryDataTransfer.CopyFields();
    end;

    local procedure CopyDetailedVendorLedgEntry();
    var
        DetailedVendorLedgEntry: Record "Detailed Vendor Ledg. Entry";
    begin
        DetailedVendorLedgEntry.SetLoadFields("Entry No.", "Vendor Posting Group", "Entry Type", "Transaction No.");
        if DetailedVendorLedgEntry.FindSet(true) then
            repeat
                DetailedVendorLedgEntry."Posting Group" := DetailedVendorLedgEntry."Vendor Posting Group";
                DetailedVendorLedgEntry.Modify(false);
            until DetailedVendorLedgEntry.Next() = 0;
    end;

    internal procedure IsVendorApplAcrossPostGrpTransaction(TransactionNo: Integer; var ApplTransactionDictionary: Dictionary of [Integer, Boolean]) ApplAcrossPostGroups: Boolean
    var
        DetailedVendorLedgEntry: Record "Detailed Vendor Ledg. Entry";
        FirstVendorPostingGroup: Code[20];
    begin
        if not ApplTransactionDictionary.Get(TransactionNo, ApplAcrossPostGroups) then begin
            FirstVendorPostingGroup := '';
            DetailedVendorLedgEntry.SetCurrentKey("Transaction No.", "Vendor No.", "Entry Type");
            DetailedVendorLedgEntry.SetLoadFields("Vendor Posting Group");
            DetailedVendorLedgEntry.SetRange("Transaction No.", TransactionNo);
            DetailedVendorLedgEntry.SetRange("Entry Type", DetailedVendorLedgEntry."Entry Type"::Application);
            if DetailedVendorLedgEntry.FindSet() then
                repeat
                    if FirstVendorPostingGroup = '' then
                        FirstVendorPostingGroup := DetailedVendorLedgEntry."Vendor Posting Group";
                    ApplAcrossPostGroups := FirstVendorPostingGroup <> DetailedVendorLedgEntry."Vendor Posting Group";
                until ApplAcrossPostGroups or (DetailedVendorLedgEntry.Next() = 0);
            ApplTransactionDictionary.Add(TransactionNo, ApplAcrossPostGroups);
        end;
    end;

    local procedure CopyVATEntry();
    var
        VATEntry: Record "VAT Entry";
        VATEntryDataTransfer: DataTransfer;
    begin
        VATEntryDataTransfer.SetTables(Database::"VAT Entry", Database::"VAT Entry");
        VATEntryDataTransfer.AddFieldValue(VATEntry.FieldNo("VAT Date"), VATEntry.FieldNo("VAT Reporting Date"));
        VATEntryDataTransfer.AddFieldValue(VATEntry.FieldNo("Registration No."), VATEntry.FieldNo("Registration No. CZL"));
        VATEntryDataTransfer.AddFieldValue(VATEntry.FieldNo("VAT Settlement No."), VATEntry.FieldNo("VAT Settlement No. CZL"));
        VATEntryDataTransfer.AddFieldValue(VATEntry.FieldNo("Original Document VAT Date"), VATEntry.FieldNo("Original Doc. VAT Date CZL"));
        VATEntryDataTransfer.AddFieldValue(VATEntry.FieldNo("EU 3-Party Intermediate Role"), VATEntry.FieldNo("EU 3-Party Intermed. Role CZL"));
        VATEntryDataTransfer.AddFieldValue(VATEntry.FieldNo("VAT Delay"), VATEntry.FieldNo("VAT Delay CZL"));
        VATEntryDataTransfer.AddFieldValue(VATEntry.FieldNo("VAT Identifier"), VATEntry.FieldNo("VAT Identifier CZL"));
        VATEntryDataTransfer.CopyFields();
    end;

    local procedure CopyGenJournalLine();
    var
        GenJournalLine: Record "Gen. Journal Line";
        GenJournalLineDataTransfer: DataTransfer;
    begin
        GenJournalLineDataTransfer.SetTables(Database::"Gen. Journal Line", Database::"Gen. Journal Line");
        GenJournalLineDataTransfer.AddFieldValue(GenJournalLine.FieldNo("Specific Symbol"), GenJournalLine.FieldNo("Specific Symbol CZL"));
        GenJournalLineDataTransfer.AddFieldValue(GenJournalLine.FieldNo("Variable Symbol"), GenJournalLine.FieldNo("Variable Symbol CZL"));
        GenJournalLineDataTransfer.AddFieldValue(GenJournalLine.FieldNo("Constant Symbol"), GenJournalLine.FieldNo("Constant Symbol CZL"));
        GenJournalLineDataTransfer.AddFieldValue(GenJournalLine.FieldNo("Bank Account Code"), GenJournalLine.FieldNo("Bank Account Code CZL"));
        GenJournalLineDataTransfer.AddFieldValue(GenJournalLine.FieldNo("Bank Account No."), GenJournalLine.FieldNo("Bank Account No. CZL"));
        GenJournalLineDataTransfer.AddFieldValue(GenJournalLine.FieldNo("Transit No."), GenJournalLine.FieldNo("Transit No. CZL"));
        GenJournalLineDataTransfer.AddFieldValue(GenJournalLine.FieldNo(IBAN), GenJournalLine.FieldNo("IBAN CZL"));
        GenJournalLineDataTransfer.AddFieldValue(GenJournalLine.FieldNo("SWIFT Code"), GenJournalLine.FieldNo("SWIFT Code CZL"));
        GenJournalLineDataTransfer.AddFieldValue(GenJournalLine.FieldNo("VAT Date"), GenJournalLine.FieldNo("VAT Reporting Date"));
        GenJournalLineDataTransfer.AddFieldValue(GenJournalLine.FieldNo("Registration No."), GenJournalLine.FieldNo("Registration No. CZL"));
        GenJournalLineDataTransfer.AddFieldValue(GenJournalLine.FieldNo("Tax Registration No."), GenJournalLine.FieldNo("Tax Registration No. CZL"));
        GenJournalLineDataTransfer.AddFieldValue(GenJournalLine.FieldNo("EU 3-Party Intermediate Role"), GenJournalLine.FieldNo("EU 3-Party Intermed. Role CZL"));
        GenJournalLineDataTransfer.AddFieldValue(GenJournalLine.FieldNo("Original Document VAT Date"), GenJournalLine.FieldNo("Original Doc. VAT Date CZL"));
        GenJournalLineDataTransfer.AddFieldValue(GenJournalLine.FieldNo("Original Document Partner Type"), GenJournalLine.FieldNo("Original Doc. Partner Type CZL"));
        GenJournalLineDataTransfer.AddFieldValue(GenJournalLine.FieldNo("Original Document Partner No."), GenJournalLine.FieldNo("Original Doc. Partner No. CZL"));
        GenJournalLineDataTransfer.AddFieldValue(GenJournalLine.FieldNo("Currency Factor VAT"), GenJournalLine.FieldNo("VAT Currency Factor CZL"));
        GenJournalLineDataTransfer.AddFieldValue(GenJournalLine.FieldNo("Currency Code VAT"), GenJournalLine.FieldNo("VAT Currency Code CZL"));
        GenJournalLineDataTransfer.AddFieldValue(GenJournalLine.FieldNo("VAT Delay"), GenJournalLine.FieldNo("VAT Delay CZL"));
        GenJournalLineDataTransfer.CopyFields();
    end;

    local procedure CopySalesHeader();
    var
        SalesHeader: Record "Sales Header";
        SalesHeaderDataTransfer: DataTransfer;
    begin
        SalesHeaderDataTransfer.SetTables(Database::"Sales Header", Database::"Sales Header");
        SalesHeaderDataTransfer.AddFieldValue(SalesHeader.FieldNo("Specific Symbol"), SalesHeader.FieldNo("Specific Symbol CZL"));
        SalesHeaderDataTransfer.AddFieldValue(SalesHeader.FieldNo("Variable Symbol"), SalesHeader.FieldNo("Variable Symbol CZL"));
        SalesHeaderDataTransfer.AddFieldValue(SalesHeader.FieldNo("Constant Symbol"), SalesHeader.FieldNo("Constant Symbol CZL"));
        SalesHeaderDataTransfer.AddFieldValue(SalesHeader.FieldNo("Bank Account Code"), SalesHeader.FieldNo("Bank Account Code CZL"));
        SalesHeaderDataTransfer.AddFieldValue(SalesHeader.FieldNo("Bank Account No."), SalesHeader.FieldNo("Bank Account No. CZL"));
        SalesHeaderDataTransfer.AddFieldValue(SalesHeader.FieldNo("Bank Branch No."), SalesHeader.FieldNo("Bank Branch No. CZL"));
        SalesHeaderDataTransfer.AddFieldValue(SalesHeader.FieldNo("Bank Name"), SalesHeader.FieldNo("Bank Name CZL"));
        SalesHeaderDataTransfer.AddFieldValue(SalesHeader.FieldNo("Transit No."), SalesHeader.FieldNo("Transit No. CZL"));
        SalesHeaderDataTransfer.AddFieldValue(SalesHeader.FieldNo(IBAN), SalesHeader.FieldNo("IBAN CZL"));
        SalesHeaderDataTransfer.AddFieldValue(SalesHeader.FieldNo("SWIFT Code"), SalesHeader.FieldNo("SWIFT Code CZL"));
        SalesHeaderDataTransfer.AddFieldValue(SalesHeader.FieldNo("VAT Date"), SalesHeader.FieldNo("VAT Reporting Date"));
        SalesHeaderDataTransfer.AddFieldValue(SalesHeader.FieldNo("Registration No."), SalesHeader.FieldNo("Registration No. CZL"));
        SalesHeaderDataTransfer.AddFieldValue(SalesHeader.FieldNo("Tax Registration No."), SalesHeader.FieldNo("Tax Registration No. CZL"));
        SalesHeaderDataTransfer.AddFieldValue(SalesHeader.FieldNo("Credit Memo Type"), SalesHeader.FieldNo("Credit Memo Type CZL"));
        SalesHeaderDataTransfer.AddFieldValue(SalesHeader.FieldNo("Physical Transfer"), SalesHeader.FieldNo("Physical Transfer CZL"));
        SalesHeaderDataTransfer.AddFieldValue(SalesHeader.FieldNo("Intrastat Exclude"), SalesHeader.FieldNo("Intrastat Exclude CZL"));
        SalesHeaderDataTransfer.AddFieldValue(SalesHeader.FieldNo("EU 3-Party Intermediate Role"), SalesHeader.FieldNo("EU 3-Party Intermed. Role CZL"));
        SalesHeaderDataTransfer.AddFieldValue(SalesHeader.FieldNo("Original Document VAT Date"), SalesHeader.FieldNo("Original Doc. VAT Date CZL"));
        SalesHeaderDataTransfer.AddFieldValue(SalesHeader.FieldNo("VAT Currency Factor"), SalesHeader.FieldNo("VAT Currency Factor CZL"));
        SalesHeaderDataTransfer.AddFieldValue(SalesHeader.FieldNo("Currency Code"), SalesHeader.FieldNo("VAT Currency Code CZL"));
        SalesHeaderDataTransfer.CopyFields();
    end;

    local procedure CopySalesShipmentHeader();
    var
        SalesShipmentHeader: Record "Sales Shipment Header";
        SalesShipmentHeaderDataTransfer: DataTransfer;
    begin
        SalesShipmentHeaderDataTransfer.SetTables(Database::"Sales Shipment Header", Database::"Sales Shipment Header");
        SalesShipmentHeaderDataTransfer.AddFieldValue(SalesShipmentHeader.FieldNo("Registration No."), SalesShipmentHeader.FieldNo("Registration No. CZL"));
        SalesShipmentHeaderDataTransfer.AddFieldValue(SalesShipmentHeader.FieldNo("Tax Registration No."), SalesShipmentHeader.FieldNo("Tax Registration No. CZL"));
        SalesShipmentHeaderDataTransfer.AddFieldValue(SalesShipmentHeader.FieldNo("Physical Transfer"), SalesShipmentHeader.FieldNo("Physical Transfer CZL"));
        SalesShipmentHeaderDataTransfer.AddFieldValue(SalesShipmentHeader.FieldNo("Intrastat Exclude"), SalesShipmentHeader.FieldNo("Intrastat Exclude CZL"));
        SalesShipmentHeaderDataTransfer.AddFieldValue(SalesShipmentHeader.FieldNo("EU 3-Party Intermediate Role"), SalesShipmentHeader.FieldNo("EU 3-Party Intermed. Role CZL"));
        SalesShipmentHeaderDataTransfer.CopyFields();
    end;

    local procedure CopySalesInvoiceHeader();
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesInvoiceHeaderDataTransfer: DataTransfer;
    begin
        SalesInvoiceHeaderDataTransfer.SetTables(Database::"Sales Invoice Header", Database::"Sales Invoice Header");
        SalesInvoiceHeaderDataTransfer.AddFieldValue(SalesInvoiceHeader.FieldNo("Specific Symbol"), SalesInvoiceHeader.FieldNo("Specific Symbol CZL"));
        SalesInvoiceHeaderDataTransfer.AddFieldValue(SalesInvoiceHeader.FieldNo("Variable Symbol"), SalesInvoiceHeader.FieldNo("Variable Symbol CZL"));
        SalesInvoiceHeaderDataTransfer.AddFieldValue(SalesInvoiceHeader.FieldNo("Constant Symbol"), SalesInvoiceHeader.FieldNo("Constant Symbol CZL"));
        SalesInvoiceHeaderDataTransfer.AddFieldValue(SalesInvoiceHeader.FieldNo("Bank Account Code"), SalesInvoiceHeader.FieldNo("Bank Account Code CZL"));
        SalesInvoiceHeaderDataTransfer.AddFieldValue(SalesInvoiceHeader.FieldNo("Bank Account No."), SalesInvoiceHeader.FieldNo("Bank Account No. CZL"));
        SalesInvoiceHeaderDataTransfer.AddFieldValue(SalesInvoiceHeader.FieldNo("Bank Branch No."), SalesInvoiceHeader.FieldNo("Bank Branch No. CZL"));
        SalesInvoiceHeaderDataTransfer.AddFieldValue(SalesInvoiceHeader.FieldNo("Bank Name"), SalesInvoiceHeader.FieldNo("Bank Name CZL"));
        SalesInvoiceHeaderDataTransfer.AddFieldValue(SalesInvoiceHeader.FieldNo("Transit No."), SalesInvoiceHeader.FieldNo("Transit No. CZL"));
        SalesInvoiceHeaderDataTransfer.AddFieldValue(SalesInvoiceHeader.FieldNo(IBAN), SalesInvoiceHeader.FieldNo("IBAN CZL"));
        SalesInvoiceHeaderDataTransfer.AddFieldValue(SalesInvoiceHeader.FieldNo("SWIFT Code"), SalesInvoiceHeader.FieldNo("SWIFT Code CZL"));
        SalesInvoiceHeaderDataTransfer.AddFieldValue(SalesInvoiceHeader.FieldNo("VAT Date"), SalesInvoiceHeader.FieldNo("VAT Reporting Date"));
        SalesInvoiceHeaderDataTransfer.AddFieldValue(SalesInvoiceHeader.FieldNo("Registration No."), SalesInvoiceHeader.FieldNo("Registration No. CZL"));
        SalesInvoiceHeaderDataTransfer.AddFieldValue(SalesInvoiceHeader.FieldNo("Tax Registration No."), SalesInvoiceHeader.FieldNo("Tax Registration No. CZL"));
        SalesInvoiceHeaderDataTransfer.AddFieldValue(SalesInvoiceHeader.FieldNo("Physical Transfer"), SalesInvoiceHeader.FieldNo("Physical Transfer CZL"));
        SalesInvoiceHeaderDataTransfer.AddFieldValue(SalesInvoiceHeader.FieldNo("Intrastat Exclude"), SalesInvoiceHeader.FieldNo("Intrastat Exclude CZL"));
        SalesInvoiceHeaderDataTransfer.AddFieldValue(SalesInvoiceHeader.FieldNo("EU 3-Party Intermediate Role"), SalesInvoiceHeader.FieldNo("EU 3-Party Intermed. Role CZL"));
        SalesInvoiceHeaderDataTransfer.AddFieldValue(SalesInvoiceHeader.FieldNo("VAT Currency Factor"), SalesInvoiceHeader.FieldNo("VAT Currency Factor CZL"));
        SalesInvoiceHeaderDataTransfer.AddFieldValue(SalesInvoiceHeader.FieldNo("Currency Code"), SalesInvoiceHeader.FieldNo("VAT Currency Code CZL"));
        SalesInvoiceHeaderDataTransfer.CopyFields();
    end;

    local procedure CopySalesCrMemoHeader();
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesCrMemoHeaderDataTransfer: DataTransfer;
    begin
        SalesCrMemoHeaderDataTransfer.SetTables(Database::"Sales Cr.Memo Header", Database::"Sales Cr.Memo Header");
        SalesCrMemoHeaderDataTransfer.AddFieldValue(SalesCrMemoHeader.FieldNo("Specific Symbol"), SalesCrMemoHeader.FieldNo("Specific Symbol CZL"));
        SalesCrMemoHeaderDataTransfer.AddFieldValue(SalesCrMemoHeader.FieldNo("Variable Symbol"), SalesCrMemoHeader.FieldNo("Variable Symbol CZL"));
        SalesCrMemoHeaderDataTransfer.AddFieldValue(SalesCrMemoHeader.FieldNo("Constant Symbol"), SalesCrMemoHeader.FieldNo("Constant Symbol CZL"));
        SalesCrMemoHeaderDataTransfer.AddFieldValue(SalesCrMemoHeader.FieldNo("Bank Account Code"), SalesCrMemoHeader.FieldNo("Bank Account Code CZL"));
        SalesCrMemoHeaderDataTransfer.AddFieldValue(SalesCrMemoHeader.FieldNo("Bank Account No."), SalesCrMemoHeader.FieldNo("Bank Account No. CZL"));
        SalesCrMemoHeaderDataTransfer.AddFieldValue(SalesCrMemoHeader.FieldNo("Bank Branch No."), SalesCrMemoHeader.FieldNo("Bank Branch No. CZL"));
        SalesCrMemoHeaderDataTransfer.AddFieldValue(SalesCrMemoHeader.FieldNo("Bank Name"), SalesCrMemoHeader.FieldNo("Bank Name CZL"));
        SalesCrMemoHeaderDataTransfer.AddFieldValue(SalesCrMemoHeader.FieldNo("Transit No."), SalesCrMemoHeader.FieldNo("Transit No. CZL"));
        SalesCrMemoHeaderDataTransfer.AddFieldValue(SalesCrMemoHeader.FieldNo(IBAN), SalesCrMemoHeader.FieldNo("IBAN CZL"));
        SalesCrMemoHeaderDataTransfer.AddFieldValue(SalesCrMemoHeader.FieldNo("SWIFT Code"), SalesCrMemoHeader.FieldNo("SWIFT Code CZL"));
        SalesCrMemoHeaderDataTransfer.AddFieldValue(SalesCrMemoHeader.FieldNo("VAT Date"), SalesCrMemoHeader.FieldNo("VAT Reporting Date"));
        SalesCrMemoHeaderDataTransfer.AddFieldValue(SalesCrMemoHeader.FieldNo("Registration No."), SalesCrMemoHeader.FieldNo("Registration No. CZL"));
        SalesCrMemoHeaderDataTransfer.AddFieldValue(SalesCrMemoHeader.FieldNo("Tax Registration No."), SalesCrMemoHeader.FieldNo("Tax Registration No. CZL"));
        SalesCrMemoHeaderDataTransfer.AddFieldValue(SalesCrMemoHeader.FieldNo("Physical Transfer"), SalesCrMemoHeader.FieldNo("Physical Transfer CZL"));
        SalesCrMemoHeaderDataTransfer.AddFieldValue(SalesCrMemoHeader.FieldNo("Intrastat Exclude"), SalesCrMemoHeader.FieldNo("Intrastat Exclude CZL"));
        SalesCrMemoHeaderDataTransfer.AddFieldValue(SalesCrMemoHeader.FieldNo("Credit Memo Type"), SalesCrMemoHeader.FieldNo("Credit Memo Type CZL"));
        SalesCrMemoHeaderDataTransfer.AddFieldValue(SalesCrMemoHeader.FieldNo("EU 3-Party Intermediate Role"), SalesCrMemoHeader.FieldNo("EU 3-Party Intermed. Role CZL"));
        SalesCrMemoHeaderDataTransfer.AddFieldValue(SalesCrMemoHeader.FieldNo("VAT Currency Factor"), SalesCrMemoHeader.FieldNo("VAT Currency Factor CZL"));
        SalesCrMemoHeaderDataTransfer.AddFieldValue(SalesCrMemoHeader.FieldNo("Currency Code"), SalesCrMemoHeader.FieldNo("VAT Currency Code CZL"));
        SalesCrMemoHeaderDataTransfer.CopyFields();
    end;

    local procedure CopyReturnReceiptHeader();
    var
        ReturnReceiptHeader: Record "Return Receipt Header";
        ReturnReceiptHeaderDataTransfer: DataTransfer;
    begin
        ReturnReceiptHeaderDataTransfer.SetTables(Database::"Return Receipt Header", Database::"Return Receipt Header");
        ReturnReceiptHeaderDataTransfer.AddFieldValue(ReturnReceiptHeader.FieldNo("Registration No."), ReturnReceiptHeader.FieldNo("Registration No. CZL"));
        ReturnReceiptHeaderDataTransfer.AddFieldValue(ReturnReceiptHeader.FieldNo("Tax Registration No."), ReturnReceiptHeader.FieldNo("Tax Registration No. CZL"));
        ReturnReceiptHeaderDataTransfer.AddFieldValue(ReturnReceiptHeader.FieldNo("Physical Transfer"), ReturnReceiptHeader.FieldNo("Physical Transfer CZL"));
        ReturnReceiptHeaderDataTransfer.AddFieldValue(ReturnReceiptHeader.FieldNo("Intrastat Exclude"), ReturnReceiptHeader.FieldNo("Intrastat Exclude CZL"));
        ReturnReceiptHeaderDataTransfer.CopyFields();
    end;

    local procedure CopySalesHeaderArchive();
    var
        SalesHeaderArchive: Record "Sales Header Archive";
        SalesHeaderArchiveDataTransfer: DataTransfer;
    begin
        SalesHeaderArchiveDataTransfer.SetTables(Database::"Sales Header Archive", Database::"Sales Header Archive");
        SalesHeaderArchiveDataTransfer.AddFieldValue(SalesHeaderArchive.FieldNo("Specific Symbol"), SalesHeaderArchive.FieldNo("Specific Symbol CZL"));
        SalesHeaderArchiveDataTransfer.AddFieldValue(SalesHeaderArchive.FieldNo("Variable Symbol"), SalesHeaderArchive.FieldNo("Variable Symbol CZL"));
        SalesHeaderArchiveDataTransfer.AddFieldValue(SalesHeaderArchive.FieldNo("Constant Symbol"), SalesHeaderArchive.FieldNo("Constant Symbol CZL"));
        SalesHeaderArchiveDataTransfer.AddFieldValue(SalesHeaderArchive.FieldNo("Bank Account Code"), SalesHeaderArchive.FieldNo("Bank Account Code CZL"));
        SalesHeaderArchiveDataTransfer.AddFieldValue(SalesHeaderArchive.FieldNo("Bank Account No."), SalesHeaderArchive.FieldNo("Bank Account No. CZL"));
        SalesHeaderArchiveDataTransfer.AddFieldValue(SalesHeaderArchive.FieldNo("Transit No."), SalesHeaderArchive.FieldNo("Transit No. CZL"));
        SalesHeaderArchiveDataTransfer.AddFieldValue(SalesHeaderArchive.FieldNo(IBAN), SalesHeaderArchive.FieldNo("IBAN CZL"));
        SalesHeaderArchiveDataTransfer.AddFieldValue(SalesHeaderArchive.FieldNo("SWIFT Code"), SalesHeaderArchive.FieldNo("SWIFT Code CZL"));
        SalesHeaderArchiveDataTransfer.AddFieldValue(SalesHeaderArchive.FieldNo("VAT Date"), SalesHeaderArchive.FieldNo("VAT Reporting Date"));
        SalesHeaderArchiveDataTransfer.AddFieldValue(SalesHeaderArchive.FieldNo("Registration No."), SalesHeaderArchive.FieldNo("Registration No. CZL"));
        SalesHeaderArchiveDataTransfer.AddFieldValue(SalesHeaderArchive.FieldNo("Tax Registration No."), SalesHeaderArchive.FieldNo("Tax Registration No. CZL"));
        SalesHeaderArchiveDataTransfer.AddFieldValue(SalesHeaderArchive.FieldNo("Physical Transfer"), SalesHeaderArchive.FieldNo("Physical Transfer CZL"));
        SalesHeaderArchiveDataTransfer.AddFieldValue(SalesHeaderArchive.FieldNo("Intrastat Exclude"), SalesHeaderArchive.FieldNo("Intrastat Exclude CZL"));
        SalesHeaderArchiveDataTransfer.AddFieldValue(SalesHeaderArchive.FieldNo("EU 3-Party Intermediate Role"), SalesHeaderArchive.FieldNo("EU 3-Party Intermed. Role CZL"));
        SalesHeaderArchiveDataTransfer.AddFieldValue(SalesHeaderArchive.FieldNo("VAT Currency Factor"), SalesHeaderArchive.FieldNo("VAT Currency Factor CZL"));
        SalesHeaderArchiveDataTransfer.AddFieldValue(SalesHeaderArchive.FieldNo("Currency Code"), SalesHeaderArchive.FieldNo("VAT Currency Code CZL"));
        SalesHeaderArchiveDataTransfer.CopyFields();
    end;

    local procedure CopyPurchaseHeader();
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseHeaderDataTransfer: DataTransfer;
    begin
        PurchaseHeaderDataTransfer.SetTables(Database::"Purchase Header", Database::"Purchase Header");
        PurchaseHeaderDataTransfer.AddFieldValue(PurchaseHeader.FieldNo("Specific Symbol"), PurchaseHeader.FieldNo("Specific Symbol CZL"));
        PurchaseHeaderDataTransfer.AddFieldValue(PurchaseHeader.FieldNo("Variable Symbol"), PurchaseHeader.FieldNo("Variable Symbol CZL"));
        PurchaseHeaderDataTransfer.AddFieldValue(PurchaseHeader.FieldNo("Constant Symbol"), PurchaseHeader.FieldNo("Constant Symbol CZL"));
        PurchaseHeaderDataTransfer.AddFieldValue(PurchaseHeader.FieldNo("Bank Account Code"), PurchaseHeader.FieldNo("Bank Account Code CZL"));
        PurchaseHeaderDataTransfer.AddFieldValue(PurchaseHeader.FieldNo("Bank Account No."), PurchaseHeader.FieldNo("Bank Account No. CZL"));
        PurchaseHeaderDataTransfer.AddFieldValue(PurchaseHeader.FieldNo("Bank Branch No."), PurchaseHeader.FieldNo("Bank Branch No. CZL"));
        PurchaseHeaderDataTransfer.AddFieldValue(PurchaseHeader.FieldNo("Bank Name"), PurchaseHeader.FieldNo("Bank Name CZL"));
        PurchaseHeaderDataTransfer.AddFieldValue(PurchaseHeader.FieldNo("Transit No."), PurchaseHeader.FieldNo("Transit No. CZL"));
        PurchaseHeaderDataTransfer.AddFieldValue(PurchaseHeader.FieldNo(IBAN), PurchaseHeader.FieldNo("IBAN CZL"));
        PurchaseHeaderDataTransfer.AddFieldValue(PurchaseHeader.FieldNo("SWIFT Code"), PurchaseHeader.FieldNo("SWIFT Code CZL"));
        PurchaseHeaderDataTransfer.AddFieldValue(PurchaseHeader.FieldNo("VAT Date"), PurchaseHeader.FieldNo("VAT Reporting Date"));
        PurchaseHeaderDataTransfer.AddFieldValue(PurchaseHeader.FieldNo("Registration No."), PurchaseHeader.FieldNo("Registration No. CZL"));
        PurchaseHeaderDataTransfer.AddFieldValue(PurchaseHeader.FieldNo("Tax Registration No."), PurchaseHeader.FieldNo("Tax Registration No. CZL"));
        PurchaseHeaderDataTransfer.AddFieldValue(PurchaseHeader.FieldNo("Physical Transfer"), PurchaseHeader.FieldNo("Physical Transfer CZL"));
        PurchaseHeaderDataTransfer.AddFieldValue(PurchaseHeader.FieldNo("Intrastat Exclude"), PurchaseHeader.FieldNo("Intrastat Exclude CZL"));
        PurchaseHeaderDataTransfer.AddFieldValue(PurchaseHeader.FieldNo("EU 3-Party Intermediate Role"), PurchaseHeader.FieldNo("EU 3-Party Intermed. Role CZL"));
        PurchaseHeaderDataTransfer.AddFieldValue(PurchaseHeader.FieldNo("EU 3-Party Trade"), PurchaseHeader.FieldNo("EU 3 Party Trade"));
        PurchaseHeaderDataTransfer.AddFieldValue(PurchaseHeader.FieldNo("Original Document VAT Date"), PurchaseHeader.FieldNo("Original Doc. VAT Date CZL"));
        PurchaseHeaderDataTransfer.AddFieldValue(PurchaseHeader.FieldNo("VAT Currency Factor"), PurchaseHeader.FieldNo("VAT Currency Factor CZL"));
        PurchaseHeaderDataTransfer.AddFieldValue(PurchaseHeader.FieldNo("Currency Code"), PurchaseHeader.FieldNo("VAT Currency Code CZL"));
        PurchaseHeaderDataTransfer.CopyFields();
    end;

    local procedure CopyPurchaseReceiptHeader();
    var
        PurchRcptHeader: Record "Purch. Rcpt. Header";
        PurchRcptHeaderDataTransfer: DataTransfer;
    begin
        PurchRcptHeaderDataTransfer.SetTables(Database::"Purch. Rcpt. Header", Database::"Purch. Rcpt. Header");
        PurchRcptHeaderDataTransfer.AddFieldValue(PurchRcptHeader.FieldNo("Registration No."), PurchRcptHeader.FieldNo("Registration No. CZL"));
        PurchRcptHeaderDataTransfer.AddFieldValue(PurchRcptHeader.FieldNo("Tax Registration No."), PurchRcptHeader.FieldNo("Tax Registration No. CZL"));
        PurchRcptHeaderDataTransfer.AddFieldValue(PurchRcptHeader.FieldNo("Physical Transfer"), PurchRcptHeader.FieldNo("Physical Transfer CZL"));
        PurchRcptHeaderDataTransfer.AddFieldValue(PurchRcptHeader.FieldNo("Intrastat Exclude"), PurchRcptHeader.FieldNo("Intrastat Exclude CZL"));
        PurchRcptHeaderDataTransfer.AddFieldValue(PurchRcptHeader.FieldNo("EU 3-Party Intermediate Role"), PurchRcptHeader.FieldNo("EU 3-Party Intermed. Role CZL"));
        PurchRcptHeaderDataTransfer.AddFieldValue(PurchRcptHeader.FieldNo("EU 3-Party Trade"), PurchRcptHeader.FieldNo("EU 3-Party Trade CZL"));
        PurchRcptHeaderDataTransfer.CopyFields();
    end;

    local procedure CopyPurchaseInvoiceHeader();
    var
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchInvHeaderDataTransfer: DataTransfer;
    begin
        PurchInvHeaderDataTransfer.SetTables(Database::"Purch. Inv. Header", Database::"Purch. Inv. Header");
        PurchInvHeaderDataTransfer.AddFieldValue(PurchInvHeader.FieldNo("Specific Symbol"), PurchInvHeader.FieldNo("Specific Symbol CZL"));
        PurchInvHeaderDataTransfer.AddFieldValue(PurchInvHeader.FieldNo("Variable Symbol"), PurchInvHeader.FieldNo("Variable Symbol CZL"));
        PurchInvHeaderDataTransfer.AddFieldValue(PurchInvHeader.FieldNo("Constant Symbol"), PurchInvHeader.FieldNo("Constant Symbol CZL"));
        PurchInvHeaderDataTransfer.AddFieldValue(PurchInvHeader.FieldNo("Bank Account Code"), PurchInvHeader.FieldNo("Bank Account Code CZL"));
        PurchInvHeaderDataTransfer.AddFieldValue(PurchInvHeader.FieldNo("Bank Account No."), PurchInvHeader.FieldNo("Bank Account No. CZL"));
        PurchInvHeaderDataTransfer.AddFieldValue(PurchInvHeader.FieldNo("Transit No."), PurchInvHeader.FieldNo("Transit No. CZL"));
        PurchInvHeaderDataTransfer.AddFieldValue(PurchInvHeader.FieldNo(IBAN), PurchInvHeader.FieldNo("IBAN CZL"));
        PurchInvHeaderDataTransfer.AddFieldValue(PurchInvHeader.FieldNo("SWIFT Code"), PurchInvHeader.FieldNo("SWIFT Code CZL"));
        PurchInvHeaderDataTransfer.AddFieldValue(PurchInvHeader.FieldNo("VAT Date"), PurchInvHeader.FieldNo("VAT Reporting Date"));
        PurchInvHeaderDataTransfer.AddFieldValue(PurchInvHeader.FieldNo("Registration No."), PurchInvHeader.FieldNo("Registration No. CZL"));
        PurchInvHeaderDataTransfer.AddFieldValue(PurchInvHeader.FieldNo("Tax Registration No."), PurchInvHeader.FieldNo("Tax Registration No. CZL"));
        PurchInvHeaderDataTransfer.AddFieldValue(PurchInvHeader.FieldNo("Physical Transfer"), PurchInvHeader.FieldNo("Physical Transfer CZL"));
        PurchInvHeaderDataTransfer.AddFieldValue(PurchInvHeader.FieldNo("Intrastat Exclude"), PurchInvHeader.FieldNo("Intrastat Exclude CZL"));
        PurchInvHeaderDataTransfer.AddFieldValue(PurchInvHeader.FieldNo("EU 3-Party Intermediate Role"), PurchInvHeader.FieldNo("EU 3-Party Intermed. Role CZL"));
        PurchInvHeaderDataTransfer.AddFieldValue(PurchInvHeader.FieldNo("EU 3-Party Trade"), PurchInvHeader.FieldNo("EU 3 Party Trade"));
        PurchInvHeaderDataTransfer.AddFieldValue(PurchInvHeader.FieldNo("Original Document VAT Date"), PurchInvHeader.FieldNo("Original Doc. VAT Date CZL"));
        PurchInvHeaderDataTransfer.AddFieldValue(PurchInvHeader.FieldNo("VAT Currency Factor"), PurchInvHeader.FieldNo("VAT Currency Factor CZL"));
        PurchInvHeaderDataTransfer.AddFieldValue(PurchInvHeader.FieldNo("Currency Code"), PurchInvHeader.FieldNo("VAT Currency Code CZL"));
        PurchInvHeaderDataTransfer.CopyFields();
    end;

    local procedure CopyPurchaseCrMemoHeader();
    var
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        PurchCrMemoHdrDataTransfer: DataTransfer;
    begin
        PurchCrMemoHdrDataTransfer.SetTables(Database::"Purch. Cr. Memo Hdr.", Database::"Purch. Cr. Memo Hdr.");
        PurchCrMemoHdrDataTransfer.AddFieldValue(PurchCrMemoHdr.FieldNo("Specific Symbol"), PurchCrMemoHdr.FieldNo("Specific Symbol CZL"));
        PurchCrMemoHdrDataTransfer.AddFieldValue(PurchCrMemoHdr.FieldNo("Variable Symbol"), PurchCrMemoHdr.FieldNo("Variable Symbol CZL"));
        PurchCrMemoHdrDataTransfer.AddFieldValue(PurchCrMemoHdr.FieldNo("Constant Symbol"), PurchCrMemoHdr.FieldNo("Constant Symbol CZL"));
        PurchCrMemoHdrDataTransfer.AddFieldValue(PurchCrMemoHdr.FieldNo("Bank Account Code"), PurchCrMemoHdr.FieldNo("Bank Account Code CZL"));
        PurchCrMemoHdrDataTransfer.AddFieldValue(PurchCrMemoHdr.FieldNo("Bank Account No."), PurchCrMemoHdr.FieldNo("Bank Account No. CZL"));
        PurchCrMemoHdrDataTransfer.AddFieldValue(PurchCrMemoHdr.FieldNo("Transit No."), PurchCrMemoHdr.FieldNo("Transit No. CZL"));
        PurchCrMemoHdrDataTransfer.AddFieldValue(PurchCrMemoHdr.FieldNo(IBAN), PurchCrMemoHdr.FieldNo("IBAN CZL"));
        PurchCrMemoHdrDataTransfer.AddFieldValue(PurchCrMemoHdr.FieldNo("SWIFT Code"), PurchCrMemoHdr.FieldNo("SWIFT Code CZL"));
        PurchCrMemoHdrDataTransfer.AddFieldValue(PurchCrMemoHdr.FieldNo("VAT Date"), PurchCrMemoHdr.FieldNo("VAT Reporting Date"));
        PurchCrMemoHdrDataTransfer.AddFieldValue(PurchCrMemoHdr.FieldNo("Registration No."), PurchCrMemoHdr.FieldNo("Registration No. CZL"));
        PurchCrMemoHdrDataTransfer.AddFieldValue(PurchCrMemoHdr.FieldNo("Tax Registration No."), PurchCrMemoHdr.FieldNo("Tax Registration No. CZL"));
        PurchCrMemoHdrDataTransfer.AddFieldValue(PurchCrMemoHdr.FieldNo("Physical Transfer"), PurchCrMemoHdr.FieldNo("Physical Transfer CZL"));
        PurchCrMemoHdrDataTransfer.AddFieldValue(PurchCrMemoHdr.FieldNo("Intrastat Exclude"), PurchCrMemoHdr.FieldNo("Intrastat Exclude CZL"));
        PurchCrMemoHdrDataTransfer.AddFieldValue(PurchCrMemoHdr.FieldNo("EU 3-Party Intermediate Role"), PurchCrMemoHdr.FieldNo("EU 3-Party Intermed. Role CZL"));
        PurchCrMemoHdrDataTransfer.AddFieldValue(PurchCrMemoHdr.FieldNo("EU 3-Party Trade"), PurchCrMemoHdr.FieldNo("EU 3 Party Trade"));
        PurchCrMemoHdrDataTransfer.AddFieldValue(PurchCrMemoHdr.FieldNo("Original Document VAT Date"), PurchCrMemoHdr.FieldNo("Original Doc. VAT Date CZL"));
        PurchCrMemoHdrDataTransfer.AddFieldValue(PurchCrMemoHdr.FieldNo("VAT Currency Factor"), PurchCrMemoHdr.FieldNo("VAT Currency Factor CZL"));
        PurchCrMemoHdrDataTransfer.AddFieldValue(PurchCrMemoHdr.FieldNo("Currency Code"), PurchCrMemoHdr.FieldNo("VAT Currency Code CZL"));
        PurchCrMemoHdrDataTransfer.CopyFields();
    end;

    local procedure CopyReturnShipmentHeader();
    var
        ReturnShipmentHeader: Record "Return Shipment Header";
        ReturnShipmentHeaderDataTransfer: DataTransfer;
    begin
        ReturnShipmentHeaderDataTransfer.SetTables(Database::"Return Shipment Header", Database::"Return Shipment Header");
        ReturnShipmentHeaderDataTransfer.AddFieldValue(ReturnShipmentHeader.FieldNo("Registration No."), ReturnShipmentHeader.FieldNo("Registration No. CZL"));
        ReturnShipmentHeaderDataTransfer.AddFieldValue(ReturnShipmentHeader.FieldNo("Tax Registration No."), ReturnShipmentHeader.FieldNo("Tax Registration No. CZL"));
        ReturnShipmentHeaderDataTransfer.AddFieldValue(ReturnShipmentHeader.FieldNo("Physical Transfer"), ReturnShipmentHeader.FieldNo("Physical Transfer CZL"));
        ReturnShipmentHeaderDataTransfer.AddFieldValue(ReturnShipmentHeader.FieldNo("Intrastat Exclude"), ReturnShipmentHeader.FieldNo("Intrastat Exclude CZL"));
        ReturnShipmentHeaderDataTransfer.AddFieldValue(ReturnShipmentHeader.FieldNo("EU 3-Party Trade"), ReturnShipmentHeader.FieldNo("EU 3-Party Trade CZL"));
        ReturnShipmentHeaderDataTransfer.CopyFields();
    end;

    local procedure CopyPurchaseHeaderArchive();
    var
        PurchaseHeaderArchive: Record "Purchase Header Archive";
        PurchaseHeaderArchiveDataTransfer: DataTransfer;
    begin
        PurchaseHeaderArchiveDataTransfer.SetTables(Database::"Purchase Header Archive", Database::"Purchase Header Archive");
        PurchaseHeaderArchiveDataTransfer.AddFieldValue(PurchaseHeaderArchive.FieldNo("Specific Symbol"), PurchaseHeaderArchive.FieldNo("Specific Symbol CZL"));
        PurchaseHeaderArchiveDataTransfer.AddFieldValue(PurchaseHeaderArchive.FieldNo("Variable Symbol"), PurchaseHeaderArchive.FieldNo("Variable Symbol CZL"));
        PurchaseHeaderArchiveDataTransfer.AddFieldValue(PurchaseHeaderArchive.FieldNo("Constant Symbol"), PurchaseHeaderArchive.FieldNo("Constant Symbol CZL"));
        PurchaseHeaderArchiveDataTransfer.AddFieldValue(PurchaseHeaderArchive.FieldNo("Bank Account Code"), PurchaseHeaderArchive.FieldNo("Bank Account Code CZL"));
        PurchaseHeaderArchiveDataTransfer.AddFieldValue(PurchaseHeaderArchive.FieldNo("Bank Account No."), PurchaseHeaderArchive.FieldNo("Bank Account No. CZL"));
        PurchaseHeaderArchiveDataTransfer.AddFieldValue(PurchaseHeaderArchive.FieldNo("Transit No."), PurchaseHeaderArchive.FieldNo("Transit No. CZL"));
        PurchaseHeaderArchiveDataTransfer.AddFieldValue(PurchaseHeaderArchive.FieldNo(IBAN), PurchaseHeaderArchive.FieldNo("IBAN CZL"));
        PurchaseHeaderArchiveDataTransfer.AddFieldValue(PurchaseHeaderArchive.FieldNo("SWIFT Code"), PurchaseHeaderArchive.FieldNo("SWIFT Code CZL"));
        PurchaseHeaderArchiveDataTransfer.AddFieldValue(PurchaseHeaderArchive.FieldNo("VAT Date"), PurchaseHeaderArchive.FieldNo("VAT Reporting Date"));
        PurchaseHeaderArchiveDataTransfer.AddFieldValue(PurchaseHeaderArchive.FieldNo("Registration No."), PurchaseHeaderArchive.FieldNo("Registration No. CZL"));
        PurchaseHeaderArchiveDataTransfer.AddFieldValue(PurchaseHeaderArchive.FieldNo("Tax Registration No."), PurchaseHeaderArchive.FieldNo("Tax Registration No. CZL"));
        PurchaseHeaderArchiveDataTransfer.AddFieldValue(PurchaseHeaderArchive.FieldNo("Physical Transfer"), PurchaseHeaderArchive.FieldNo("Physical Transfer CZL"));
        PurchaseHeaderArchiveDataTransfer.AddFieldValue(PurchaseHeaderArchive.FieldNo("Intrastat Exclude"), PurchaseHeaderArchive.FieldNo("Intrastat Exclude CZL"));
        PurchaseHeaderArchiveDataTransfer.AddFieldValue(PurchaseHeaderArchive.FieldNo("EU 3-Party Intermediate Role"), PurchaseHeaderArchive.FieldNo("EU 3-Party Intermed. Role CZL"));
        PurchaseHeaderArchiveDataTransfer.AddFieldValue(PurchaseHeaderArchive.FieldNo("VAT Currency Factor"), PurchaseHeaderArchive.FieldNo("VAT Currency Factor CZL"));
        PurchaseHeaderArchiveDataTransfer.AddFieldValue(PurchaseHeaderArchive.FieldNo("Currency Code"), PurchaseHeaderArchive.FieldNo("VAT Currency Code CZL"));
        PurchaseHeaderArchiveDataTransfer.CopyFields();
    end;

    local procedure CopyServiceHeader();
    var
        ServiceHeader: Record "Service Header";
        ServiceHeaderDataTransfer: DataTransfer;
    begin
        ServiceHeaderDataTransfer.SetTables(Database::"Service Header", Database::"Service Header");
        ServiceHeaderDataTransfer.AddFieldValue(ServiceHeader.FieldNo("Specific Symbol"), ServiceHeader.FieldNo("Specific Symbol CZL"));
        ServiceHeaderDataTransfer.AddFieldValue(ServiceHeader.FieldNo("Variable Symbol"), ServiceHeader.FieldNo("Variable Symbol CZL"));
        ServiceHeaderDataTransfer.AddFieldValue(ServiceHeader.FieldNo("Constant Symbol"), ServiceHeader.FieldNo("Constant Symbol CZL"));
        ServiceHeaderDataTransfer.AddFieldValue(ServiceHeader.FieldNo("Bank Account Code"), ServiceHeader.FieldNo("Bank Account Code CZL"));
        ServiceHeaderDataTransfer.AddFieldValue(ServiceHeader.FieldNo("Bank Account No."), ServiceHeader.FieldNo("Bank Account No. CZL"));
        ServiceHeaderDataTransfer.AddFieldValue(ServiceHeader.FieldNo("Bank Branch No."), ServiceHeader.FieldNo("Bank Branch No. CZL"));
        ServiceHeaderDataTransfer.AddFieldValue(ServiceHeader.FieldNo("Bank Name"), ServiceHeader.FieldNo("Bank Name CZL"));
        ServiceHeaderDataTransfer.AddFieldValue(ServiceHeader.FieldNo("Transit No."), ServiceHeader.FieldNo("Transit No. CZL"));
        ServiceHeaderDataTransfer.AddFieldValue(ServiceHeader.FieldNo(IBAN), ServiceHeader.FieldNo("IBAN CZL"));
        ServiceHeaderDataTransfer.AddFieldValue(ServiceHeader.FieldNo("SWIFT Code"), ServiceHeader.FieldNo("SWIFT Code CZL"));
        ServiceHeaderDataTransfer.AddFieldValue(ServiceHeader.FieldNo("VAT Date"), ServiceHeader.FieldNo("VAT Reporting Date"));
        ServiceHeaderDataTransfer.AddFieldValue(ServiceHeader.FieldNo("Registration No."), ServiceHeader.FieldNo("Registration No. CZL"));
        ServiceHeaderDataTransfer.AddFieldValue(ServiceHeader.FieldNo("Tax Registration No."), ServiceHeader.FieldNo("Tax Registration No. CZL"));
        ServiceHeaderDataTransfer.AddFieldValue(ServiceHeader.FieldNo("Physical Transfer"), ServiceHeader.FieldNo("Physical Transfer CZL"));
        ServiceHeaderDataTransfer.AddFieldValue(ServiceHeader.FieldNo("Intrastat Exclude"), ServiceHeader.FieldNo("Intrastat Exclude CZL"));
        ServiceHeaderDataTransfer.AddFieldValue(ServiceHeader.FieldNo("Credit Memo Type"), ServiceHeader.FieldNo("Credit Memo Type CZL"));
        ServiceHeaderDataTransfer.AddFieldValue(ServiceHeader.FieldNo("EU 3-Party Intermediate Role"), ServiceHeader.FieldNo("EU 3-Party Intermed. Role CZL"));
        ServiceHeaderDataTransfer.AddFieldValue(ServiceHeader.FieldNo("VAT Currency Factor"), ServiceHeader.FieldNo("VAT Currency Factor CZL"));
        ServiceHeaderDataTransfer.AddFieldValue(ServiceHeader.FieldNo("Currency Code"), ServiceHeader.FieldNo("VAT Currency Code CZL"));
        ServiceHeaderDataTransfer.CopyFields();
    end;

    local procedure CopyServiceShipmentHeader();
    var
        ServiceShipmentHeader: Record "Service Shipment Header";
        ServiceShipmentHeaderDataTransfer: DataTransfer;
    begin
        ServiceShipmentHeaderDataTransfer.SetTables(Database::"Service Shipment Header", Database::"Service Shipment Header");
        ServiceShipmentHeaderDataTransfer.AddFieldValue(ServiceShipmentHeader.FieldNo("Registration No."), ServiceShipmentHeader.FieldNo("Registration No. CZL"));
        ServiceShipmentHeaderDataTransfer.AddFieldValue(ServiceShipmentHeader.FieldNo("Tax Registration No."), ServiceShipmentHeader.FieldNo("Tax Registration No. CZL"));
        ServiceShipmentHeaderDataTransfer.AddFieldValue(ServiceShipmentHeader.FieldNo("Physical Transfer"), ServiceShipmentHeader.FieldNo("Physical Transfer CZL"));
        ServiceShipmentHeaderDataTransfer.AddFieldValue(ServiceShipmentHeader.FieldNo("Intrastat Exclude"), ServiceShipmentHeader.FieldNo("Intrastat Exclude CZL"));
        ServiceShipmentHeaderDataTransfer.AddFieldValue(ServiceShipmentHeader.FieldNo("EU 3-Party Intermediate Role"), ServiceShipmentHeader.FieldNo("EU 3-Party Intermed. Role CZL"));
        ServiceShipmentHeaderDataTransfer.CopyFields();
    end;

    local procedure CopyServiceInvoiceHeader();
    var
        ServiceInvoiceHeader: Record "Service Invoice Header";
        ServiceInvoiceHeaderDataTransfer: DataTransfer;
    begin
        ServiceInvoiceHeaderDataTransfer.SetTables(Database::"Service Invoice Header", Database::"Service Invoice Header");
        ServiceInvoiceHeaderDataTransfer.AddFieldValue(ServiceInvoiceHeader.FieldNo("Specific Symbol"), ServiceInvoiceHeader.FieldNo("Specific Symbol CZL"));
        ServiceInvoiceHeaderDataTransfer.AddFieldValue(ServiceInvoiceHeader.FieldNo("Variable Symbol"), ServiceInvoiceHeader.FieldNo("Variable Symbol CZL"));
        ServiceInvoiceHeaderDataTransfer.AddFieldValue(ServiceInvoiceHeader.FieldNo("Constant Symbol"), ServiceInvoiceHeader.FieldNo("Constant Symbol CZL"));
        ServiceInvoiceHeaderDataTransfer.AddFieldValue(ServiceInvoiceHeader.FieldNo("Bank Account Code"), ServiceInvoiceHeader.FieldNo("Bank Account Code CZL"));
        ServiceInvoiceHeaderDataTransfer.AddFieldValue(ServiceInvoiceHeader.FieldNo("Bank Account No."), ServiceInvoiceHeader.FieldNo("Bank Account No. CZL"));
        ServiceInvoiceHeaderDataTransfer.AddFieldValue(ServiceInvoiceHeader.FieldNo("Bank Branch No."), ServiceInvoiceHeader.FieldNo("Bank Branch No. CZL"));
        ServiceInvoiceHeaderDataTransfer.AddFieldValue(ServiceInvoiceHeader.FieldNo("Bank Name"), ServiceInvoiceHeader.FieldNo("Bank Name CZL"));
        ServiceInvoiceHeaderDataTransfer.AddFieldValue(ServiceInvoiceHeader.FieldNo("Transit No."), ServiceInvoiceHeader.FieldNo("Transit No. CZL"));
        ServiceInvoiceHeaderDataTransfer.AddFieldValue(ServiceInvoiceHeader.FieldNo(IBAN), ServiceInvoiceHeader.FieldNo("IBAN CZL"));
        ServiceInvoiceHeaderDataTransfer.AddFieldValue(ServiceInvoiceHeader.FieldNo("SWIFT Code"), ServiceInvoiceHeader.FieldNo("SWIFT Code CZL"));
        ServiceInvoiceHeaderDataTransfer.AddFieldValue(ServiceInvoiceHeader.FieldNo("VAT Date"), ServiceInvoiceHeader.FieldNo("VAT Reporting Date"));
        ServiceInvoiceHeaderDataTransfer.AddFieldValue(ServiceInvoiceHeader.FieldNo("Registration No."), ServiceInvoiceHeader.FieldNo("Registration No. CZL"));
        ServiceInvoiceHeaderDataTransfer.AddFieldValue(ServiceInvoiceHeader.FieldNo("Tax Registration No."), ServiceInvoiceHeader.FieldNo("Tax Registration No. CZL"));
        ServiceInvoiceHeaderDataTransfer.AddFieldValue(ServiceInvoiceHeader.FieldNo("Physical Transfer"), ServiceInvoiceHeader.FieldNo("Physical Transfer CZL"));
        ServiceInvoiceHeaderDataTransfer.AddFieldValue(ServiceInvoiceHeader.FieldNo("Intrastat Exclude"), ServiceInvoiceHeader.FieldNo("Intrastat Exclude CZL"));
        ServiceInvoiceHeaderDataTransfer.AddFieldValue(ServiceInvoiceHeader.FieldNo("EU 3-Party Intermediate Role"), ServiceInvoiceHeader.FieldNo("EU 3-Party Intermed. Role CZL"));
        ServiceInvoiceHeaderDataTransfer.AddFieldValue(ServiceInvoiceHeader.FieldNo("VAT Currency Factor"), ServiceInvoiceHeader.FieldNo("VAT Currency Factor CZL"));
        ServiceInvoiceHeaderDataTransfer.AddFieldValue(ServiceInvoiceHeader.FieldNo("Currency Code"), ServiceInvoiceHeader.FieldNo("VAT Currency Code CZL"));
        ServiceInvoiceHeaderDataTransfer.CopyFields();
    end;

    local procedure CopyServiceCrMemoHeader();
    var
        ServiceCrMemoHeader: Record "Service Cr.Memo Header";
        ServiceCrMemoHeaderDataTransfer: DataTransfer;
    begin
        ServiceCrMemoHeaderDataTransfer.SetTables(Database::"Service Cr.Memo Header", Database::"Service Cr.Memo Header");
        ServiceCrMemoHeaderDataTransfer.AddFieldValue(ServiceCrMemoHeader.FieldNo("Specific Symbol"), ServiceCrMemoHeader.FieldNo("Specific Symbol CZL"));
        ServiceCrMemoHeaderDataTransfer.AddFieldValue(ServiceCrMemoHeader.FieldNo("Variable Symbol"), ServiceCrMemoHeader.FieldNo("Variable Symbol CZL"));
        ServiceCrMemoHeaderDataTransfer.AddFieldValue(ServiceCrMemoHeader.FieldNo("Constant Symbol"), ServiceCrMemoHeader.FieldNo("Constant Symbol CZL"));
        ServiceCrMemoHeaderDataTransfer.AddFieldValue(ServiceCrMemoHeader.FieldNo("Bank Account Code"), ServiceCrMemoHeader.FieldNo("Bank Account Code CZL"));
        ServiceCrMemoHeaderDataTransfer.AddFieldValue(ServiceCrMemoHeader.FieldNo("Bank Account No."), ServiceCrMemoHeader.FieldNo("Bank Account No. CZL"));
        ServiceCrMemoHeaderDataTransfer.AddFieldValue(ServiceCrMemoHeader.FieldNo("Bank Branch No."), ServiceCrMemoHeader.FieldNo("Bank Branch No. CZL"));
        ServiceCrMemoHeaderDataTransfer.AddFieldValue(ServiceCrMemoHeader.FieldNo("Bank Name"), ServiceCrMemoHeader.FieldNo("Bank Name CZL"));
        ServiceCrMemoHeaderDataTransfer.AddFieldValue(ServiceCrMemoHeader.FieldNo("Transit No."), ServiceCrMemoHeader.FieldNo("Transit No. CZL"));
        ServiceCrMemoHeaderDataTransfer.AddFieldValue(ServiceCrMemoHeader.FieldNo(IBAN), ServiceCrMemoHeader.FieldNo("IBAN CZL"));
        ServiceCrMemoHeaderDataTransfer.AddFieldValue(ServiceCrMemoHeader.FieldNo("SWIFT Code"), ServiceCrMemoHeader.FieldNo("SWIFT Code CZL"));
        ServiceCrMemoHeaderDataTransfer.AddFieldValue(ServiceCrMemoHeader.FieldNo("VAT Date"), ServiceCrMemoHeader.FieldNo("VAT Reporting Date"));
        ServiceCrMemoHeaderDataTransfer.AddFieldValue(ServiceCrMemoHeader.FieldNo("Registration No."), ServiceCrMemoHeader.FieldNo("Registration No. CZL"));
        ServiceCrMemoHeaderDataTransfer.AddFieldValue(ServiceCrMemoHeader.FieldNo("Tax Registration No."), ServiceCrMemoHeader.FieldNo("Tax Registration No. CZL"));
        ServiceCrMemoHeaderDataTransfer.AddFieldValue(ServiceCrMemoHeader.FieldNo("Physical Transfer"), ServiceCrMemoHeader.FieldNo("Physical Transfer CZL"));
        ServiceCrMemoHeaderDataTransfer.AddFieldValue(ServiceCrMemoHeader.FieldNo("Intrastat Exclude"), ServiceCrMemoHeader.FieldNo("Intrastat Exclude CZL"));
        ServiceCrMemoHeaderDataTransfer.AddFieldValue(ServiceCrMemoHeader.FieldNo("Credit Memo Type"), ServiceCrMemoHeader.FieldNo("Credit Memo Type CZL"));
        ServiceCrMemoHeaderDataTransfer.AddFieldValue(ServiceCrMemoHeader.FieldNo("EU 3-Party Intermediate Role"), ServiceCrMemoHeader.FieldNo("EU 3-Party Intermed. Role CZL"));
        ServiceCrMemoHeaderDataTransfer.AddFieldValue(ServiceCrMemoHeader.FieldNo("VAT Currency Factor"), ServiceCrMemoHeader.FieldNo("VAT Currency Factor CZL"));
        ServiceCrMemoHeaderDataTransfer.AddFieldValue(ServiceCrMemoHeader.FieldNo("Currency Code"), ServiceCrMemoHeader.FieldNo("VAT Currency Code CZL"));
        ServiceCrMemoHeaderDataTransfer.CopyFields();
    end;

    local procedure CopyReminderHeader();
    var
        ReminderHeader: Record "Reminder Header";
        ReminderHeaderDataTransfer: DataTransfer;
    begin
        ReminderHeaderDataTransfer.SetTables(Database::"Reminder Header", Database::"Reminder Header");
        ReminderHeaderDataTransfer.AddFieldValue(ReminderHeader.FieldNo("Specific Symbol"), ReminderHeader.FieldNo("Specific Symbol CZL"));
        ReminderHeaderDataTransfer.AddFieldValue(ReminderHeader.FieldNo("Variable Symbol"), ReminderHeader.FieldNo("Variable Symbol CZL"));
        ReminderHeaderDataTransfer.AddFieldValue(ReminderHeader.FieldNo("Constant Symbol"), ReminderHeader.FieldNo("Constant Symbol CZL"));
        ReminderHeaderDataTransfer.AddFieldValue(ReminderHeader.FieldNo("Bank No."), ReminderHeader.FieldNo("Bank Account Code CZL"));
        ReminderHeaderDataTransfer.AddFieldValue(ReminderHeader.FieldNo("Bank Account No."), ReminderHeader.FieldNo("Bank Account No. CZL"));
        ReminderHeaderDataTransfer.AddFieldValue(ReminderHeader.FieldNo("Bank Branch No."), ReminderHeader.FieldNo("Bank Branch No. CZL"));
        ReminderHeaderDataTransfer.AddFieldValue(ReminderHeader.FieldNo("Bank Name"), ReminderHeader.FieldNo("Bank Name CZL"));
        ReminderHeaderDataTransfer.AddFieldValue(ReminderHeader.FieldNo("Transit No."), ReminderHeader.FieldNo("Transit No. CZL"));
        ReminderHeaderDataTransfer.AddFieldValue(ReminderHeader.FieldNo(IBAN), ReminderHeader.FieldNo("IBAN CZL"));
        ReminderHeaderDataTransfer.AddFieldValue(ReminderHeader.FieldNo("SWIFT Code"), ReminderHeader.FieldNo("SWIFT Code CZL"));
        ReminderHeaderDataTransfer.AddFieldValue(ReminderHeader.FieldNo("Registration No."), ReminderHeader.FieldNo("Registration No. CZL"));
        ReminderHeaderDataTransfer.AddFieldValue(ReminderHeader.FieldNo("Tax Registration No."), ReminderHeader.FieldNo("Tax Registration No. CZL"));
        ReminderHeaderDataTransfer.CopyFields();
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
        IssuedReminderHeaderDataTransfer.AddFieldValue(IssuedReminderHeader.FieldNo("Registration No."), IssuedReminderHeader.FieldNo("Registration No. CZL"));
        IssuedReminderHeaderDataTransfer.AddFieldValue(IssuedReminderHeader.FieldNo("Tax Registration No."), IssuedReminderHeader.FieldNo("Tax Registration No. CZL"));
        IssuedReminderHeaderDataTransfer.CopyFields();
    end;

    local procedure CopyFinanceChargeMemoHeader();
    var
        FinanceChargeMemoHeader: Record "Finance Charge Memo Header";
        FinanceChargeMemoHeaderDataTransfer: DataTransfer;
    begin
        FinanceChargeMemoHeaderDataTransfer.SetTables(Database::"Finance Charge Memo Header", Database::"Finance Charge Memo Header");
        FinanceChargeMemoHeaderDataTransfer.AddFieldValue(FinanceChargeMemoHeader.FieldNo("Specific Symbol"), FinanceChargeMemoHeader.FieldNo("Specific Symbol CZL"));
        FinanceChargeMemoHeaderDataTransfer.AddFieldValue(FinanceChargeMemoHeader.FieldNo("Variable Symbol"), FinanceChargeMemoHeader.FieldNo("Variable Symbol CZL"));
        FinanceChargeMemoHeaderDataTransfer.AddFieldValue(FinanceChargeMemoHeader.FieldNo("Constant Symbol"), FinanceChargeMemoHeader.FieldNo("Constant Symbol CZL"));
        FinanceChargeMemoHeaderDataTransfer.AddFieldValue(FinanceChargeMemoHeader.FieldNo("Bank No."), FinanceChargeMemoHeader.FieldNo("Bank Account Code CZL"));
        FinanceChargeMemoHeaderDataTransfer.AddFieldValue(FinanceChargeMemoHeader.FieldNo("Bank Account No."), FinanceChargeMemoHeader.FieldNo("Bank Account No. CZL"));
        FinanceChargeMemoHeaderDataTransfer.AddFieldValue(FinanceChargeMemoHeader.FieldNo("Bank Branch No."), FinanceChargeMemoHeader.FieldNo("Bank Branch No. CZL"));
        FinanceChargeMemoHeaderDataTransfer.AddFieldValue(FinanceChargeMemoHeader.FieldNo("Bank Name"), FinanceChargeMemoHeader.FieldNo("Bank Name CZL"));
        FinanceChargeMemoHeaderDataTransfer.AddFieldValue(FinanceChargeMemoHeader.FieldNo("Transit No."), FinanceChargeMemoHeader.FieldNo("Transit No. CZL"));
        FinanceChargeMemoHeaderDataTransfer.AddFieldValue(FinanceChargeMemoHeader.FieldNo(IBAN), FinanceChargeMemoHeader.FieldNo("IBAN CZL"));
        FinanceChargeMemoHeaderDataTransfer.AddFieldValue(FinanceChargeMemoHeader.FieldNo("SWIFT Code"), FinanceChargeMemoHeader.FieldNo("SWIFT Code CZL"));
        FinanceChargeMemoHeaderDataTransfer.AddFieldValue(FinanceChargeMemoHeader.FieldNo("Registration No."), FinanceChargeMemoHeader.FieldNo("Registration No. CZL"));
        FinanceChargeMemoHeaderDataTransfer.AddFieldValue(FinanceChargeMemoHeader.FieldNo("Tax Registration No."), FinanceChargeMemoHeader.FieldNo("Tax Registration No. CZL"));
        FinanceChargeMemoHeaderDataTransfer.CopyFields();
    end;

    local procedure CopyIssuedFinanceChargeMemoHeader();
    var
        IssuedFinChargeMemoHeader: Record "Issued Fin. Charge Memo Header";
        IssuedFinChargeMemoHeaderDataTransfer: DataTransfer;
    begin
        IssuedFinChargeMemoHeaderDataTransfer.SetTables(Database::"Issued Fin. Charge Memo Header", Database::"Issued Fin. Charge Memo Header");
        IssuedFinChargeMemoHeaderDataTransfer.AddFieldValue(IssuedFinChargeMemoHeader.FieldNo("Specific Symbol"), IssuedFinChargeMemoHeader.FieldNo("Specific Symbol CZL"));
        IssuedFinChargeMemoHeaderDataTransfer.AddFieldValue(IssuedFinChargeMemoHeader.FieldNo("Variable Symbol"), IssuedFinChargeMemoHeader.FieldNo("Variable Symbol CZL"));
        IssuedFinChargeMemoHeaderDataTransfer.AddFieldValue(IssuedFinChargeMemoHeader.FieldNo("Constant Symbol"), IssuedFinChargeMemoHeader.FieldNo("Constant Symbol CZL"));
        IssuedFinChargeMemoHeaderDataTransfer.AddFieldValue(IssuedFinChargeMemoHeader.FieldNo("Bank No."), IssuedFinChargeMemoHeader.FieldNo("Bank Account Code CZL"));
        IssuedFinChargeMemoHeaderDataTransfer.AddFieldValue(IssuedFinChargeMemoHeader.FieldNo("Bank Account No."), IssuedFinChargeMemoHeader.FieldNo("Bank Account No. CZL"));
        IssuedFinChargeMemoHeaderDataTransfer.AddFieldValue(IssuedFinChargeMemoHeader.FieldNo("Bank Branch No."), IssuedFinChargeMemoHeader.FieldNo("Bank Branch No. CZL"));
        IssuedFinChargeMemoHeaderDataTransfer.AddFieldValue(IssuedFinChargeMemoHeader.FieldNo("Bank Name"), IssuedFinChargeMemoHeader.FieldNo("Bank Name CZL"));
        IssuedFinChargeMemoHeaderDataTransfer.AddFieldValue(IssuedFinChargeMemoHeader.FieldNo("Transit No."), IssuedFinChargeMemoHeader.FieldNo("Transit No. CZL"));
        IssuedFinChargeMemoHeaderDataTransfer.AddFieldValue(IssuedFinChargeMemoHeader.FieldNo(IBAN), IssuedFinChargeMemoHeader.FieldNo("IBAN CZL"));
        IssuedFinChargeMemoHeaderDataTransfer.AddFieldValue(IssuedFinChargeMemoHeader.FieldNo("SWIFT Code"), IssuedFinChargeMemoHeader.FieldNo("SWIFT Code CZL"));
        IssuedFinChargeMemoHeaderDataTransfer.AddFieldValue(IssuedFinChargeMemoHeader.FieldNo("Registration No."), IssuedFinChargeMemoHeader.FieldNo("Registration No. CZL"));
        IssuedFinChargeMemoHeaderDataTransfer.AddFieldValue(IssuedFinChargeMemoHeader.FieldNo("Tax Registration No."), IssuedFinChargeMemoHeader.FieldNo("Tax Registration No. CZL"));
        IssuedFinChargeMemoHeaderDataTransfer.CopyFields();
    end;

    local procedure CopyStatutoryReportingSetup();
    var
        StatReportingSetup: Record "Stat. Reporting Setup";
        StatutoryReportingSetupCZL: Record "Statutory Reporting Setup CZL";
    begin
        if StatReportingSetup.Get() then begin
            if not StatutoryReportingSetupCZL.Get() then begin
                StatutoryReportingSetupCZL.Init();
                StatutoryReportingSetupCZL.Insert();
            end;
            StatutoryReportingSetupCZL."Primary Key" := StatReportingSetup."Primary Key";
            StatutoryReportingSetupCZL."Company Trade Name" := StatReportingSetup."Company Trade Name";
            StatutoryReportingSetupCZL."Company Trade Name Appendix" := StatReportingSetup."Company Trade Name Appendix";
            StatutoryReportingSetupCZL."Municipality No." := StatReportingSetup."Municipality No.";
            StatutoryReportingSetupCZL.Street := StatReportingSetup.Street;
            StatutoryReportingSetupCZL."House No." := StatReportingSetup."House No.";
            StatutoryReportingSetupCZL."Apartment No." := StatReportingSetup."Apartment No.";
            StatutoryReportingSetupCZL."VAT Control Report Nos." := StatReportingSetup."VAT Control Report Nos.";
            StatutoryReportingSetupCZL."Simplified Tax Document Limit" := StatReportingSetup."Simplified Tax Document Limit";
            StatutoryReportingSetupCZL."Data Box ID" := StatReportingSetup."Data Box ID";
            StatutoryReportingSetupCZL."VAT Control Report E-mail" := StatReportingSetup."VAT Control Report E-mail";
            StatutoryReportingSetupCZL."VAT Control Report XML Format" := StatReportingSetup."VAT Control Report Xml Format";
            StatutoryReportingSetupCZL."Tax Office Number" := StatReportingSetup."Tax Office Number";
            StatutoryReportingSetupCZL."Tax Office Region Number" := StatReportingSetup."Tax Office Region Number";
            case StatReportingSetup."Taxpayer Type" of
                StatReportingSetup."Taxpayer Type"::Corporation:
                    StatutoryReportingSetupCZL."Company Type" := StatutoryReportingSetupCZL."Company Type"::Corporate;
                StatReportingSetup."Taxpayer Type"::Individual:
                    StatutoryReportingSetupCZL."Company Type" := StatutoryReportingSetupCZL."Company Type"::Individual;
            end;
            StatutoryReportingSetupCZL."Individual First Name" := StatReportingSetup."Natural Person First Name";
            StatutoryReportingSetupCZL."Individual Surname" := StatReportingSetup."Natural Person Surname";
            StatutoryReportingSetupCZL."Individual Title" := StatReportingSetup."Natural Person Title";
            StatutoryReportingSetupCZL."Individual Employee No." := StatReportingSetup."Natural Employee No.";
            StatutoryReportingSetupCZL."Official Code" := StatReportingSetup."Official Code";
            StatutoryReportingSetupCZL."Official Name" := StatReportingSetup."Official Name";
            StatutoryReportingSetupCZL."Official First Name" := StatReportingSetup."Official First Name";
            StatutoryReportingSetupCZL."Official Surname" := StatReportingSetup."Official Surname";
            StatutoryReportingSetupCZL."Official Birth Date" := StatReportingSetup."Official Birth Date";
            StatutoryReportingSetupCZL."Official Reg.No.of Tax Adviser" := StatReportingSetup."Official Reg.No.of Tax Adviser";
            StatutoryReportingSetupCZL."Official Registration No." := StatReportingSetup."Official Registration No.";
            StatutoryReportingSetupCZL."Official Type" := StatReportingSetup."Official Type";
            StatutoryReportingSetupCZL."VAT Statement Country Name" := StatReportingSetup."VAT Statement Country Name";
            StatutoryReportingSetupCZL."VAT Stat. Auth. Employee No." := StatReportingSetup."VAT Stat. Auth.Employee No.";
            StatutoryReportingSetupCZL."VAT Stat. Filled Employee No." := StatReportingSetup."VAT Stat. Filled by Empl. No.";
            StatutoryReportingSetupCZL."Tax Payer Status" := StatReportingSetup."Tax Payer Status";
            StatutoryReportingSetupCZL."Primary Business Activity Code" := StatReportingSetup."Main Economic Activity I Code";
            StatutoryReportingSetupCZL."VIES Declaration Nos." := StatReportingSetup."VIES Declaration Nos.";
            StatutoryReportingSetupCZL."VIES Decl. Auth. Employee No." := StatReportingSetup."VIES Decl. Auth. Employee No.";
            StatutoryReportingSetupCZL."VIES Decl. Filled Employee No." := StatReportingSetup."VIES Decl. Filled by Empl. No.";
            StatutoryReportingSetupCZL."VIES Number of Lines" := StatReportingSetup."VIES Number of Lines";
            if StatReportingSetup."VIES Declaration Report No." = 31060 then
                StatutoryReportingSetupCZL."VIES Declaration Report No." := Report::"VIES Declaration CZL";
            if (StatReportingSetup."VIES Decl. Exp. Obj. Type" = StatReportingSetup."VIES Decl. Exp. Obj. Type"::Report) and (StatReportingSetup."VIES Decl. Exp. Obj. No." = 31066) then
                StatutoryReportingSetupCZL."VIES Declaration Export No." := Xmlport::"VIES Declaration CZL";
            StatutoryReportingSetupCZL."Transaction Type Mandatory" := StatReportingSetup."Transaction Type Mandatory";
            StatutoryReportingSetupCZL."Transaction Spec. Mandatory" := StatReportingSetup."Transaction Spec. Mandatory";
            StatutoryReportingSetupCZL."Transport Method Mandatory" := StatReportingSetup."Transport Method Mandatory";
            StatutoryReportingSetupCZL."Shipment Method Mandatory" := StatReportingSetup."Shipment Method Mandatory";
            StatutoryReportingSetupCZL."Tariff No. Mandatory" := StatReportingSetup."Tariff No. Mandatory";
            StatutoryReportingSetupCZL."Net Weight Mandatory" := StatReportingSetup."Net Weight Mandatory";
            StatutoryReportingSetupCZL."Country/Region of Origin Mand." := StatReportingSetup."Country/Region of Origin Mand.";
            StatutoryReportingSetupCZL."Get Tariff No. From" := "Intrastat Detail Source CZL".FromInteger(StatReportingSetup."Get Tariff No. From");
            StatutoryReportingSetupCZL."Get Net Weight From" := "Intrastat Detail Source CZL".FromInteger(StatReportingSetup."Get Net Weight From");
            StatutoryReportingSetupCZL."Get Country/Region of Origin" := "Intrastat Detail Source CZL".FromInteger(StatReportingSetup."Get Country/Region of Origin");
            StatutoryReportingSetupCZL."Intrastat Rounding Type" := StatReportingSetup."Intrastat Rounding Type";
            StatutoryReportingSetupCZL."No Item Charges in Intrastat" := StatReportingSetup."No Item Charges in Intrastat";
            StatutoryReportingSetupCZL."Intrastat Declaration Nos." := StatReportingSetup."Intrastat Declaration Nos.";
            StatutoryReportingSetupCZL."Stat. Value Reporting" := StatReportingSetup."Stat. Value Reporting";
            StatutoryReportingSetupCZL."Cost Regulation %" := StatReportingSetup."Cost Regulation %";
            StatutoryReportingSetupCZL."Include other Period add.Costs" := StatReportingSetup."Include other Period add.Costs";
            StatutoryReportingSetupCZL.Modify(false);
        end;
    end;

    local procedure CopyVATControlReportSection();
    var
        VATControlReportSection: Record "VAT Control Report Section";
        VATCtrlReportSectionCZL: Record "VAT Ctrl. Report Section CZL";
    begin
        if VATControlReportSection.FindSet() then
            repeat
                if not VATCtrlReportSectionCZL.Get(VATControlReportSection.Code) then begin
                    VATCtrlReportSectionCZL.Init();
                    VATCtrlReportSectionCZL.Code := VATControlReportSection.Code;
                    VATCtrlReportSectionCZL.SystemId := VATControlReportSection.SystemId;
                    VATCtrlReportSectionCZL.Insert(false, true);
                end;
                VATCtrlReportSectionCZL.Description := VATControlReportSection.Description;
                VATCtrlReportSectionCZL."Group By" := VATControlReportSection."Group By";
                VATCtrlReportSectionCZL."Simplified Tax Doc. Sect. Code" := VATControlReportSection."Simplified Tax Doc. Sect. Code";
                VATCtrlReportSectionCZL.Modify(false);
            until VATControlReportSection.Next() = 0;
    end;

    local procedure CopyVATControlReportHeader();
    var
        VATControlReportHeader: Record "VAT Control Report Header";
        VATCtrlReportHeaderCZL: Record "VAT Ctrl. Report Header CZL";
    begin
        if VATControlReportHeader.FindSet() then
            repeat
                if not VATCtrlReportHeaderCZL.Get(VATControlReportHeader."No.") then begin
                    VATCtrlReportHeaderCZL.Init();
                    VATCtrlReportHeaderCZL."No." := VATControlReportHeader."No.";
                    VATCtrlReportHeaderCZL.SystemId := VATControlReportHeader.SystemId;
                    VATCtrlReportHeaderCZL.Insert(false, true);
                end;
                VATCtrlReportHeaderCZL.Description := VATControlReportHeader.Description;
                VATCtrlReportHeaderCZL."Report Period" := VATControlReportHeader."Report Period";
                VATCtrlReportHeaderCZL."Period No." := VATControlReportHeader."Period No.";
                VATCtrlReportHeaderCZL.Year := VATControlReportHeader.Year;
                VATCtrlReportHeaderCZL."Start Date" := VATControlReportHeader."Start Date";
                VATCtrlReportHeaderCZL."End Date" := VATControlReportHeader."End Date";
                VATCtrlReportHeaderCZL."Created Date" := VATControlReportHeader."Created Date";
                VATCtrlReportHeaderCZL.Status := VATControlReportHeader.Status;
                VATCtrlReportHeaderCZL."VAT Statement Template Name" := VATControlReportHeader."VAT Statement Template Name";
                VATCtrlReportHeaderCZL."VAT Statement Name" := VATControlReportHeader."VAT Statement Name";
                VATCtrlReportHeaderCZL."No. Series" := VATControlReportHeader."No. Series";
                VATCtrlReportHeaderCZL.Modify(false);
            until VATControlReportHeader.Next() = 0;
    end;

    local procedure CopyVATControlReportLine();
    var
        VATControlReportLine: Record "VAT Control Report Line";
        VATCtrlReportLineCZL: Record "VAT Ctrl. Report Line CZL";
    begin
        if VATControlReportLine.FindSet() then
            repeat
                if not VATCtrlReportLineCZL.Get(VATControlReportLine."Control Report No.", VATControlReportLine."Line No.") then begin
                    VATCtrlReportLineCZL.Init();
                    VATCtrlReportLineCZL."VAT Ctrl. Report No." := VATControlReportLine."Control Report No.";
                    VATCtrlReportLineCZL."Line No." := VATControlReportLine."Line No.";
                    VATCtrlReportLineCZL.SystemId := VATControlReportLine.SystemId;
                    VATCtrlReportLineCZL.Insert(false, true);
                end;
                VATCtrlReportLineCZL."VAT Ctrl. Report Section Code" := VATControlReportLine."VAT Control Rep. Section Code";
                VATCtrlReportLineCZL."Posting Date" := VATControlReportLine."Posting Date";
                VATCtrlReportLineCZL."VAT Date" := VATControlReportLine."VAT Date";
                VATCtrlReportLineCZL."Original Document VAT Date" := VATControlReportLine."Original Document VAT Date";
                VATCtrlReportLineCZL."Bill-to/Pay-to No." := VATControlReportLine."Bill-to/Pay-to No.";
                VATCtrlReportLineCZL."VAT Registration No." := VATControlReportLine."VAT Registration No.";
                VATCtrlReportLineCZL."Registration No." := VATControlReportLine."Registration No.";
                VATCtrlReportLineCZL."Tax Registration No." := VATControlReportLine."Tax Registration No.";
                VATCtrlReportLineCZL."Document No." := VATControlReportLine."Document No.";
                VATCtrlReportLineCZL."External Document No." := VATControlReportLine."External Document No.";
                VATCtrlReportLineCZL.Type := VATControlReportLine.Type;
                VATCtrlReportLineCZL."VAT Bus. Posting Group" := VATControlReportLine."VAT Bus. Posting Group";
                VATCtrlReportLineCZL."VAT Prod. Posting Group" := VATControlReportLine."VAT Prod. Posting Group";
                VATCtrlReportLineCZL.Base := VATControlReportLine.Base;
                VATCtrlReportLineCZL.Amount := VATControlReportLine.Amount;
                VATCtrlReportLineCZL."VAT Rate" := VATControlReportLine."VAT Rate";
                VATCtrlReportLineCZL."Commodity Code" := VATControlReportLine."Commodity Code";
                VATCtrlReportLineCZL."Supplies Mode Code" := VATControlReportLine."Supplies Mode Code";
                VATCtrlReportLineCZL."Corrections for Bad Receivable" := VATControlReportLine."Corrections for Bad Receivable";
                VATCtrlReportLineCZL."Ratio Use" := VATControlReportLine."Ratio Use";
                VATCtrlReportLineCZL.Name := VATControlReportLine.name;
                VATCtrlReportLineCZL."Birth Date" := VATControlReportLine."Birth Date";
                VATCtrlReportLineCZL."Place of Stay" := VATControlReportLine."Place of Stay";
                VATCtrlReportLineCZL."Exclude from Export" := VATControlReportLine."Exclude from Export";
                VATCtrlReportLineCZL."Closed by Document No." := VATControlReportLine."Closed by Document No.";
                VATCtrlReportLineCZL."Closed Date" := VATControlReportLine."Closed Date";
                VATCtrlReportLineCZL.Modify(false);
            until VATControlReportLine.Next() = 0;
    end;

    local procedure CopyVATControlReportEntryLink();
    var
        VATCtrlRepVATEntryLink: Record "VAT Ctrl.Rep. - VAT Entry Link";
        VATCtrlReportEntLinkCZL: Record "VAT Ctrl. Report Ent. Link CZL";
    begin
        if VATCtrlRepVATEntryLink.FindSet() then
            repeat
                if not VATCtrlReportEntLinkCZL.Get(VATCtrlRepVATEntryLink."Control Report No.", VATCtrlRepVATEntryLink."Line No.", VATCtrlRepVATEntryLink."VAT Entry No.") then begin
                    VATCtrlReportEntLinkCZL.Init();
                    VATCtrlReportEntLinkCZL."VAT Ctrl. Report No." := VATCtrlRepVATEntryLink."Control Report No.";
                    VATCtrlReportEntLinkCZL."Line No." := VATCtrlRepVATEntryLink."Line No.";
                    VATCtrlReportEntLinkCZL."VAT Entry No." := VATCtrlRepVATEntryLink."VAT Entry No.";
                    VATCtrlReportEntLinkCZL.SystemId := VATCtrlRepVATEntryLink.SystemId;
                    VATCtrlReportEntLinkCZL.Insert(false, true);
                end;
            until VATCtrlRepVATEntryLink.Next() = 0;
    end;

    local procedure CopyVATPostingSetup();
    var
        VATPostingSetup: Record "VAT Posting Setup";
        VATPostingSetupDataTransfer: DataTransfer;
    begin
        VATPostingSetupDataTransfer.SetTables(Database::"VAT Posting Setup", Database::"VAT Posting Setup");
        VATPostingSetupDataTransfer.AddFieldValue(VATPostingSetup.FieldNo("VAT Rate"), VATPostingSetup.FieldNo("VAT Rate CZL"));
        VATPostingSetupDataTransfer.AddFieldValue(VATPostingSetup.FieldNo("Supplies Mode Code"), VATPostingSetup.FieldNo("Supplies Mode Code CZL"));
        VATPostingSetupDataTransfer.AddFieldValue(VATPostingSetup.FieldNo("Ratio Coefficient"), VATPostingSetup.FieldNo("Ratio Coefficient CZL"));
        VATPostingSetupDataTransfer.AddFieldValue(VATPostingSetup.FieldNo("Corrections for Bad Receivable"), VATPostingSetup.FieldNo("Corrections Bad Receivable CZL"));
        VATPostingSetupDataTransfer.AddFieldValue(VATPostingSetup.FieldNo("Reverse Charge Check"), VATPostingSetup.FieldNo("Reverse Charge Check CZL"));
        VATPostingSetupDataTransfer.AddFieldValue(VATPostingSetup.FieldNo("Sales VAT Delay Account"), VATPostingSetup.FieldNo("Sales VAT Curr. Exch. Acc CZL"));
        VATPostingSetupDataTransfer.AddFieldValue(VATPostingSetup.FieldNo("Purchase VAT Delay Account"), VATPostingSetup.FieldNo("Purch. VAT Curr. Exch. Acc CZL"));
        VATPostingSetupDataTransfer.AddFieldValue(VATPostingSetup.FieldNo("VIES Purchases"), VATPostingSetup.FieldNo("VIES Purchase CZL"));
        VATPostingSetupDataTransfer.AddFieldValue(VATPostingSetup.FieldNo("VIES Sales"), VATPostingSetup.FieldNo("VIES Sales CZL"));
        VATPostingSetupDataTransfer.AddFieldValue(VATPostingSetup.FieldNo("Intrastat Service"), VATPostingSetup.FieldNo("Intrastat Service CZL"));
        VATPostingSetupDataTransfer.CopyFields();
    end;

    local procedure CopyVATStatementTemplate();
    var
        VATStatementTemplate: Record "VAT Statement Template";
    begin
        VATStatementTemplate.SetLoadFields("Allow Comments/Attachments");
        if VATStatementTemplate.FindSet() then
            repeat
                VATStatementTemplate."Allow Comments/Attachments CZL" := VATStatementTemplate."Allow Comments/Attachments";
                VATStatementTemplate."XML Format CZL" := VATStatementTemplate."XML Format CZL"::DPHDP3;
                VATStatementTemplate.Modify(false);
            until VATStatementTemplate.Next() = 0;
    end;

    local procedure CopyVATStatementLine();
    var
        VATStatementLine: Record "VAT Statement Line";
    begin
        VATStatementLine.SetLoadFields("Attribute Code", "G/L Amount Type", "Gen. Bus. Posting Group", "Gen. Prod. Posting Group", Show, "EU 3-Party Intermediate Role",
                                       "EU-3 Party Trade", "VAT Control Rep. Section Code", "Ignore Simpl. Tax Doc. Limit", Type);
        if VATStatementLine.FindSet() then
            repeat
                VATStatementLine."Attribute Code CZL" := VATStatementLine."Attribute Code";
                VATStatementLine."G/L Amount Type CZL" := VATStatementLine."G/L Amount Type";
                VATStatementLine."Gen. Bus. Posting Group CZL" := VATStatementLine."Gen. Bus. Posting Group";
                VATStatementLine."Gen. Prod. Posting Group CZL" := VATStatementLine."Gen. Prod. Posting Group";
                VATStatementLine."Show CZL" := VATStatementLine.Show;
                VATStatementLine."EU 3-Party Intermed. Role CZL" := VATStatementLine."EU 3-Party Intermediate Role";
                case VATStatementLine."EU-3 Party Trade" of
                    VATStatementLine."EU-3 Party Trade"::" ":
                        VATStatementLine."EU 3 Party Trade" := VATStatementLine."EU 3 Party Trade"::All;
                    VATStatementLine."EU-3 Party Trade"::Yes:
                        VATStatementLine."EU 3 Party Trade" := VATStatementLine."EU 3 Party Trade"::EU3;
                    VATStatementLine."EU-3 Party Trade"::No:
                        VATStatementLine."EU 3 Party Trade" := VATStatementLine."EU 3 Party Trade"::"non-EU3";
                end;
                VATStatementLine."VAT Ctrl. Report Section CZL" := VATStatementLine."VAT Control Rep. Section Code";
                VATStatementLine."Ignore Simpl. Doc. Limit CZL" := VATStatementLine."Ignore Simpl. Tax Doc. Limit";
                ConvertVATStatementLineDeprEnumValues(VATStatementLine);
                VATStatementLine.Modify(false);
            until VATStatementLine.Next() = 0;
    end;

    local procedure ConvertVATStatementLineDeprEnumValues(var VATStatementLine: Record "VAT Statement Line");
    begin
        if VATStatementLine.Type = 4 then //4 = VATStatementLine.Type::Formula
            VATStatementLine.Type := VATStatementLine.Type::"Formula CZL";
    end;

    local procedure CopyVIESDeclarationHeader();
    var
        VIESDeclarationHeader: Record "VIES Declaration Header";
        VIESDeclarationHeaderCZL: Record "VIES Declaration Header CZL";
    begin
        if VIESDeclarationHeader.FindSet() then
            repeat
                if not VIESDeclarationHeaderCZL.Get(VIESDeclarationHeader."No.") then begin
                    VIESDeclarationHeaderCZL.Init();
                    VIESDeclarationHeaderCZL."No." := VIESDeclarationHeader."No.";
                    VIESDeclarationHeaderCZL.SystemId := VIESDeclarationHeader.SystemId;
                    VIESDeclarationHeaderCZL.Insert(false, true);
                end;
                VIESDeclarationHeaderCZL."VAT Registration No." := VIESDeclarationHeader."VAT Registration No.";
                VIESDeclarationHeaderCZL."Trade Type" := VIESDeclarationHeader."Trade Type";
                VIESDeclarationHeaderCZL."Period No." := VIESDeclarationHeader."Period No.";
                VIESDeclarationHeaderCZL.Year := VIESDeclarationHeader.Year;
                VIESDeclarationHeaderCZL."Start Date" := VIESDeclarationHeader."Start Date";
                VIESDeclarationHeaderCZL."End Date" := VIESDeclarationHeader."End Date";
                VIESDeclarationHeaderCZL.Name := VIESDeclarationHeader.Name;
                VIESDeclarationHeaderCZL."Name 2" := VIESDeclarationHeader."Name 2";
                VIESDeclarationHeaderCZL."Country/Region Name" := VIESDeclarationHeader."Country/Region Name";
                VIESDeclarationHeaderCZL.County := VIESDeclarationHeader.County;
                VIESDeclarationHeaderCZL."Municipality No." := VIESDeclarationHeader."Municipality No.";
                VIESDeclarationHeaderCZL.Street := VIESDeclarationHeader.Street;
                VIESDeclarationHeaderCZL."House No." := VIESDeclarationHeader."House No.";
                VIESDeclarationHeaderCZL."Apartment No." := VIESDeclarationHeader."Apartment No.";
                VIESDeclarationHeaderCZL.City := VIESDeclarationHeader.City;
                VIESDeclarationHeaderCZL."Post Code" := VIESDeclarationHeader."Post Code";
                VIESDeclarationHeaderCZL."Tax Office Number" := VIESDeclarationHeader."Tax Office Number";
                VIESDeclarationHeaderCZL."Declaration Period" := VIESDeclarationHeader."Declaration Period";
                VIESDeclarationHeaderCZL."Declaration Type" := VIESDeclarationHeader."Declaration Type";
                VIESDeclarationHeaderCZL."Corrected Declaration No." := VIESDeclarationHeader."Corrected Declaration No.";
                VIESDeclarationHeaderCZL."Document Date" := VIESDeclarationHeader."Document Date";
                VIESDeclarationHeaderCZL."Sign-off Date" := VIESDeclarationHeader."Sign-off Date";
                VIESDeclarationHeaderCZL."Sign-off Place" := VIESDeclarationHeader."Sign-off Place";
                VIESDeclarationHeaderCZL."EU Goods/Services" := VIESDeclarationHeader."EU Goods/Services";
                VIESDeclarationHeaderCZL.Status := VIESDeclarationHeader.Status;
                VIESDeclarationHeaderCZL."No. Series" := VIESDeclarationHeader."No. Series";
                VIESDeclarationHeaderCZL."Authorized Employee No." := VIESDeclarationHeader."Authorized Employee No.";
                VIESDeclarationHeaderCZL."Filled by Employee No." := VIESDeclarationHeader."Filled by Employee No.";
                VIESDeclarationHeaderCZL."Individual First Name" := VIESDeclarationHeader."Natural Person First Name";
                VIESDeclarationHeaderCZL."Individual Surname" := VIESDeclarationHeader."Natural Person Surname";
                VIESDeclarationHeaderCZL."Individual Title" := VIESDeclarationHeader."Natural Person Title";
                VIESDeclarationHeaderCZL."Company Type" := VIESDeclarationHeader."Taxpayer Type";
                VIESDeclarationHeaderCZL."Individual Employee No." := VIESDeclarationHeader."Natural Employee No.";
                VIESDeclarationHeaderCZL."Company Trade Name Appendix" := VIESDeclarationHeader."Company Trade Name Appendix";
                VIESDeclarationHeaderCZL."Tax Office Region Number" := VIESDeclarationHeader."Tax Office Region Number";
                VIESDeclarationHeaderCZL.Modify(false);
            until VIESDeclarationHeader.Next() = 0;
    end;

    local procedure CopyVIESDeclarationLine();
    var
        VIESDeclarationLine: Record "VIES Declaration Line";
        VIESDeclarationLineCZL: Record "VIES Declaration Line CZL";
    begin
        if VIESDeclarationLine.FindSet() then
            repeat
                if not VIESDeclarationLineCZL.Get(VIESDeclarationLine."VIES Declaration No.", VIESDeclarationLine."Line No.") then begin
                    VIESDeclarationLineCZL.Init();
                    VIESDeclarationLineCZL."VIES Declaration No." := VIESDeclarationLine."VIES Declaration No.";
                    VIESDeclarationLineCZL."Line No." := VIESDeclarationLine."Line No.";
                    VIESDEclarationLineCZL.SystemId := VIESDeclarationLine.SystemId;
                    VIESDeclarationLineCZL.Insert(false, true);
                end;
                VIESDeclarationLineCZL."Trade Type" := VIESDeclarationLine."Trade Type";
                VIESDeclarationLineCZL."Line Type" := VIESDeclarationLine."Line Type";
                VIESDeclarationLineCZL."Related Line No." := VIESDeclarationLine."Related Line No.";
                VIESDeclarationLineCZL."EU Service" := VIESDeclarationLine."EU Service";
                VIESDeclarationLineCZL."Country/Region Code" := VIESDeclarationLine."Country/Region Code";
                VIESDeclarationLineCZL."VAT Registration No." := VIESDeclarationLine."VAT Registration No.";
                VIESDeclarationLineCZL."Amount (LCY)" := VIESDeclarationLine."Amount (LCY)";
                VIESDeclarationLineCZL."EU 3-Party Trade" := VIESDeclarationLine."EU 3-Party Trade";
                VIESDeclarationLineCZL."Registration No." := VIESDeclarationLine."Registration No.";
                VIESDeclarationLineCZL."EU 3-Party Intermediate Role" := VIESDeclarationLine."EU 3-Party Intermediate Role";
                VIESDeclarationLineCZL."Number of Supplies" := VIESDeclarationLine."Number of Supplies";
                VIESDeclarationLineCZL."Corrected Reg. No." := VIESDeclarationLine."Corrected Reg. No.";
                VIESDeclarationLineCZL."Corrected Amount" := VIESDeclarationLine."Corrected Amount";
                VIESDeclarationLineCZL."Trade Role Type" := VIESDeclarationLine."Trade Role Type";
                VIESDeclarationLineCZL."System-Created" := VIESDeclarationLine."System-Created";
                VIESDeclarationLineCZL."Report Page Number" := VIESDeclarationLine."Report Page Number";
                VIESDeclarationLineCZL."Report Line Number" := VIESDeclarationLine."Report Line Number";
                VIESDeclarationLineCZL."Record Code" := VIESDeclarationLine."Record Code";
                VIESDeclarationLineCZL."VAT Reg. No. of Original Cust." := VIESDeclarationLine."VAT Reg. No. of Original Cust.";
                VIESDeclarationLineCZL.Modify(false);
            until VIESDeclarationLine.Next() = 0;
    end;

    local procedure CopyCompanyOfficials();
    var
        CompanyOfficials: Record "Company Officials";
        CompanyOfficialCZL: Record "Company Official CZL";
    begin
        if CompanyOfficials.FindSet(true) then
            repeat
                if not CompanyOfficialCZL.Get(CompanyOfficials."No.") then begin
                    CompanyOfficialCZL.Init();
                    CompanyOfficialCZL."No." := CompanyOfficials."No.";
                    CompanyOfficialCZL.SystemId := CompanyOfficials.SystemId;
                    CompanyOfficialCZL.Insert(false, true);
                end;
                CompanyOfficialCZL."First Name" := CompanyOfficials."First Name";
                CompanyOfficialCZL."Middle Name" := CompanyOfficials."Middle Name";
                CompanyOfficialCZL."Last Name" := CompanyOfficials."Last Name";
                CompanyOfficialCZL.Initials := CompanyOfficials.Initials;
                CompanyOfficialCZL."Job Title" := CompanyOfficials."Job Title";
                CompanyOfficialCZL."Search Name" := CompanyOfficials."Search Name";
                CompanyOfficialCZL.Address := CompanyOfficials.Address;
                CompanyOfficialCZL."Address 2" := CompanyOfficials."Address 2";
                CompanyOfficialCZL.City := CompanyOfficials.City;
                CompanyOfficialCZL."Post Code" := CompanyOfficials."Post Code";
                CompanyOfficialCZL.County := CompanyOfficials.County;
                CompanyOfficialCZL."Phone No." := CompanyOfficials."Phone No.";
                CompanyOfficialCZL."Mobile Phone No." := CompanyOfficials."Mobile Phone No.";
                CompanyOfficialCZL."E-Mail" := CompanyOfficials."E-Mail";
                CompanyOfficialCZL."Country/Region Code" := CompanyOfficials."Country/Region Code";
                CompanyOfficialCZL."Last Date Modified" := CompanyOfficials."Last Date Modified";
                CompanyOfficialCZL."Fax No." := CompanyOfficials."Fax No.";
                CompanyOfficialCZL."No. Series" := CompanyOfficials."No. Series";
                CompanyOfficialCZL."Employee No." := CompanyOfficials."Employee No.";
                CompanyOfficialCZL.Modify(false);
            until CompanyOfficials.Next() = 0;
    end;

    local procedure CopyDocumentFooter();
    var
        DocumentFooter: Record "Document Footer";
        DocumentFooterCZL: Record "Document Footer CZL";
    begin
        if DocumentFooter.FindSet() then
            repeat
                if not DocumentFooterCZL.Get(DocumentFooter."Language Code") then begin
                    DocumentFooterCZL.Init();
                    DocumentFooterCZL."Language Code" := DocumentFooter."Language Code";
                    DocumentFooterCZL.SystemId := DocumentFooter.SystemId;
                    DocumentFooterCZL.Insert(false, true);
                end;
                DocumentFooterCZL."Footer Text" := DocumentFooter."Footer Text";
                DocumentFooterCZL.Modify(false);
            until DocumentFooter.Next() = 0;
    end;

    local procedure CopyGLAccount();
    var
        GLAccount: Record "G/L Account";
        GLAccountDataTransfer: DataTransfer;
    begin
        GLAccountDataTransfer.SetTables(Database::"G/L Account", Database::"G/L Account");
        GLAccountDataTransfer.AddFieldValue(GLAccount.FieldNo("G/L Account Group"), GLAccount.FieldNo("G/L Account Group CZL"));
        GLAccountDataTransfer.CopyFields();
    end;

    local procedure CopyVATAttributeCode();
    var
        VATAttributeCode: Record "VAT Attribute Code";
        VATAttributeCodeCZL: Record "VAT Attribute Code CZL";
    begin
        if VATAttributeCode.FindSet() then
            repeat
                if not VATAttributeCodeCZL.Get(VATAttributeCode."VAT Statement Template Name", VATAttributeCode."Code") then begin
                    VATAttributeCodeCZL.Init();
                    VATAttributeCodeCZL."VAT Statement Template Name" := VATAttributeCode."VAT Statement Template Name";
                    VATAttributeCodeCZL."Code" := VATAttributeCode."Code";
                    VATAttributeCodeCZL.SystemId := VATAttributeCode.SystemId;
                    VATAttributeCodeCZL.Insert(false, true);
                end;
                VATAttributeCodeCZL.Description := VATAttributeCode.Description;
                VATAttributeCodeCZL."XML Code" := VATAttributeCode."XML Code";
                VATAttributeCodeCZL.Modify(false);
            until VATAttributeCode.Next() = 0;
    end;

    local procedure CopyVATStatementCommentLine();
    var
        VATStatementCommentLine: Record "VAT Statement Comment Line";
        VATStatementCommentLineCZL: Record "VAT Statement Comment Line CZL";
    begin
        if VATStatementCommentLine.FindSet() then
            repeat
                if not VATStatementCommentLineCZL.Get(VATStatementCommentLine."VAT Statement Template Name", VATStatementCommentLine."VAT Statement Name", VATStatementCommentLine."Line No.") then begin
                    VATStatementCommentLineCZL.Init();
                    VATStatementCommentLineCZL."VAT Statement Template Name" := VATStatementCommentLine."VAT Statement Template Name";
                    VATStatementCommentLineCZL."VAT Statement Name" := VATStatementCommentLine."VAT Statement Name";
                    VATStatementCommentLineCZL."Line No." := VATStatementCommentLine."Line No.";
                    VATStatementCommentLineCZL.SystemId := VATStatementCommentLine.SystemId;
                    VATStatementCommentLineCZL.Insert(false, true);
                end;
                VATStatementCommentLineCZL.Date := VATStatementCommentLine.Date;
                VATStatementCommentLineCZL.Comment := VATStatementCommentLine.Comment;
                VATStatementCommentLineCZL.Modify(false);
            until VATStatementCommentLine.Next() = 0;
    end;

    local procedure CopyVATStatementAttachment();
    var
        VATStatementAttachment: Record "VAT Statement Attachment";
        VATStatementAttachmentCZL: Record "VAT Statement Attachment CZL";
    begin
        if VATStatementAttachment.FindSet() then
            repeat
                if not VATStatementAttachmentCZL.Get(VATStatementAttachment."VAT Statement Template Name", VATStatementAttachment."VAT Statement Name", VATStatementAttachment."Line No.") then begin
                    VATStatementAttachmentCZL.Init();
                    VATStatementAttachmentCZL."VAT Statement Template Name" := VATStatementAttachment."VAT Statement Template Name";
                    VATStatementAttachmentCZL."VAT Statement Name" := VATStatementAttachment."VAT Statement Name";
                    VATStatementAttachmentCZL."Line No." := VATStatementAttachment."Line No.";
                    VATStatementAttachmentCZL.SystemId := VATStatementAttachment.SystemId;
                    VATStatementAttachmentCZL.Insert(false, true);
                end;
                VATStatementAttachmentCZL.Date := VATStatementAttachment.Date;
                VATStatementAttachmentCZL.Description := VATStatementAttachment.Description;
                VATStatementAttachment.CalcFields(VATStatementAttachment.Attachment);
                VATStatementAttachmentCZL.Attachment := VATStatementAttachment.Attachment;
                VATStatementAttachmentCZL."File Name" := VATStatementAttachment."File Name";
                VATStatementAttachmentCZL.Modify(false);
            until VATStatementAttachment.Next() = 0;
    end;

    local procedure CopyAccScheduleName();
    var
        AccScheduleName: Record "Acc. Schedule Name";
        AccScheduleNameDataTransfer: DataTransfer;
    begin
        AccScheduleNameDataTransfer.SetTables(Database::"Acc. Schedule Name", Database::"Acc. Schedule Name");
        AccScheduleNameDataTransfer.AddFieldValue(AccScheduleName.FieldNo("Acc. Schedule Type"), AccScheduleName.FieldNo("Acc. Schedule Type CZL"));
        AccScheduleNameDataTransfer.CopyFields();
    end;

    local procedure CopyAccScheduleLine();
    var
        AccScheduleLine: Record "Acc. Schedule Line";
    begin
        AccScheduleLine.SetLoadFields(Calc, "Row Correction", "Assets/Liabilities Type", "Source Table", "Totaling Type");
        if AccScheduleLine.FindSet() then
            repeat
                AccScheduleLine."Calc CZL" := AccScheduleLine.Calc;
                AccScheduleLine."Row Correction CZL" := AccScheduleLine."Row Correction";
                AccScheduleLine."Assets/Liabilities Type CZL" := AccScheduleLine."Assets/Liabilities Type";
                AccScheduleLine."Source Table CZL" := AccScheduleLine."Source Table";
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

    local procedure CopyExcelTemplate();
    var
        ExcelTemplate: Record "Excel Template";
        ExcelTemplateCZL: Record "Excel Template CZL";
        ExcelTemplateOutStream: OutStream;
        ExcelTemplateInStream: InStream;
    begin
        if ExcelTemplate.FindSet() then
            repeat
                if not ExcelTemplateCZL.Get(ExcelTemplate.Code) then begin
                    ExcelTemplateCZL.Init();
                    ExcelTemplateCZL.Code := ExcelTemplate.Code;
                    ExcelTemplateCZL.SystemId := ExcelTemplate.SystemId;
                    ExcelTemplateCZL.Insert(false, true);
                end;
                ExcelTemplateCZL.Description := ExcelTemplate.Description;
                ExcelTemplateCZL.Sheet := ExcelTemplate.Sheet;
                ExcelTemplateCZL.Blocked := ExcelTemplate.Blocked;
                if ExcelTemplate.Template.HasValue() then begin
                    ExcelTemplate.CalcFields(ExcelTemplate.Template);
                    ExcelTemplate.Template.CreateInStream(ExcelTemplateInStream);
                    ExcelTemplateCZL.Template.CreateOutStream(ExcelTemplateOutStream);
                    CopyStream(ExcelTemplateOutStream, ExcelTemplateInStream);
                end;
                ExcelTemplateCZL.Modify(false);
            until ExcelTemplate.Next() = 0;
    end;

    local procedure CopyStatementFileMapping();
    var
        StatementFileMapping: Record "Statement File Mapping";
        AccScheduleFileMappingCZL: Record "Acc. Schedule File Mapping CZL";
    begin
        if StatementFileMapping.FindSet() then
            repeat
                if not AccScheduleFileMappingCZL.Get(StatementFileMapping."Schedule Name", StatementFileMapping."Schedule Line No.", StatementFileMapping."Schedule Column Layout Name", StatementFileMapping."Schedule Column No.", StatementFileMapping."Excel Cell") then begin
                    AccScheduleFileMappingCZL.Init();
                    AccScheduleFileMappingCZL."Schedule Name" := StatementFileMapping."Schedule Name";
                    AccScheduleFileMappingCZL."Schedule Line No." := StatementFileMapping."Schedule Line No.";
                    AccScheduleFileMappingCZL."Schedule Column Layout Name" := StatementFileMapping."Schedule Column Layout Name";
                    AccScheduleFileMappingCZL."Schedule Column No." := StatementFileMapping."Schedule Column No.";
                    AccScheduleFileMappingCZL."Excel Cell" := StatementFileMapping."Excel Cell";
                    AccScheduleFileMappingCZL.SystemId := StatementFileMapping.SystemId;
                    AccScheduleFileMappingCZL.Insert(false, true);
                end;
                AccScheduleFileMappingCZL."Excel Row No." := StatementFileMapping."Excel Row No.";
                AccScheduleFileMappingCZL."Excel Column No." := StatementFileMapping."Excel Column No.";
                AccScheduleFileMappingCZL.Split := StatementFileMapping.Split;
                AccScheduleFileMappingCZL.Offset := StatementFileMapping.Offset;
                AccScheduleFileMappingCZL.Modify(false);
            until StatementFileMapping.Next() = 0;
    end;

    local procedure CopyPurchaseLine();
    var
        PurchaseLine: Record "Purchase Line";
        PurchaseLineDataTransfer: DataTransfer;
    begin
        PurchaseLineDataTransfer.SetTables(Database::"Purchase Line", Database::"Purchase Line");
        PurchaseLineDataTransfer.AddFieldValue(PurchaseLine.FieldNo("Negative"), PurchaseLine.FieldNo("Negative CZL"));
#if not CLEAN24
        PurchaseLineDataTransfer.AddFieldValue(PurchaseLine.FieldNo("Ext. Amount (LCY)"), PurchaseLine.FieldNo("Ext. Amount CZL"));
        PurchaseLineDataTransfer.AddFieldValue(PurchaseLine.FieldNo("Ext.Amount Including VAT (LCY)"), PurchaseLine.FieldNo("Ext. Amount Incl. VAT CZL"));
#endif
        PurchaseLineDataTransfer.AddFieldValue(PurchaseLine.FieldNo("Physical Transfer"), PurchaseLine.FieldNo("Physical Transfer CZL"));
        PurchaseLineDataTransfer.AddFieldValue(PurchaseLine.FieldNo("Tariff No."), PurchaseLine.FieldNo("Tariff No. CZL"));
        PurchaseLineDataTransfer.AddFieldValue(PurchaseLine.FieldNo("Statistic Indication"), PurchaseLine.FieldNo("Statistic Indication CZL"));
        PurchaseLineDataTransfer.AddFieldValue(PurchaseLine.FieldNo("Country/Region of Origin Code"), PurchaseLine.FieldNo("Country/Reg. of Orig. Code CZL"));
        PurchaseLineDataTransfer.CopyFields();
    end;

    local procedure CopyPurchCrMemoLine();
    var
        PurchCrMemoLine: Record "Purch. Cr. Memo Line";
        PurchCrMemoLineDataTransfer: DataTransfer;
    begin
        PurchCrMemoLineDataTransfer.SetTables(Database::"Purch. Cr. Memo Line", Database::"Purch. Cr. Memo Line");
        PurchCrMemoLineDataTransfer.AddFieldValue(PurchCrMemoLine.FieldNo("Tariff No."), PurchCrMemoLine.FieldNo("Tariff No. CZL"));
        PurchCrMemoLineDataTransfer.AddFieldValue(PurchCrMemoLine.FieldNo("Statistic Indication"), PurchCrMemoLine.FieldNo("Statistic Indication CZL"));
        PurchCrMemoLineDataTransfer.AddFieldValue(PurchCrMemoLine.FieldNo("Country/Region of Origin Code"), PurchCrMemoLine.FieldNo("Country/Reg. of Orig. Code CZL"));
        PurchCrMemoLineDataTransfer.CopyFields();
    end;

    local procedure CopyPurchInvLine();
    var
        PurchInvLine: Record "Purch. Inv. Line";
        PurchInvLineDataTransfer: DataTransfer;
    begin
        PurchInvLineDataTransfer.SetTables(Database::"Purch. Inv. Line", Database::"Purch. Inv. Line");
        PurchInvLineDataTransfer.AddFieldValue(PurchInvLine.FieldNo("Tariff No."), PurchInvLine.FieldNo("Tariff No. CZL"));
        PurchInvLineDataTransfer.AddFieldValue(PurchInvLine.FieldNo("Statistic Indication"), PurchInvLine.FieldNo("Statistic Indication CZL"));
        PurchInvLineDataTransfer.AddFieldValue(PurchInvLine.FieldNo("Country/Region of Origin Code"), PurchInvLine.FieldNo("Country/Reg. of Orig. Code CZL"));
        PurchInvLineDataTransfer.CopyFields();
    end;

    local procedure CopyPurchRcptLine();
    var
        PurchRcptLine: Record "Purch. Rcpt. Line";
        PurchRcptLineDataTransfer: DataTransfer;
    begin
        PurchRcptLineDataTransfer.SetTables(Database::"Purch. Rcpt. Line", Database::"Purch. Rcpt. Line");
        PurchRcptLineDataTransfer.AddFieldValue(PurchRcptLine.FieldNo("Tariff No."), PurchRcptLine.FieldNo("Tariff No. CZL"));
        PurchRcptLineDataTransfer.AddFieldValue(PurchRcptLine.FieldNo("Statistic Indication"), PurchRcptLine.FieldNo("Statistic Indication CZL"));
        PurchRcptLineDataTransfer.AddFieldValue(PurchRcptLine.FieldNo("Country/Region of Origin Code"), PurchRcptLine.FieldNo("Country/Reg. of Orig. Code CZL"));
        PurchRcptLineDataTransfer.CopyFields();
    end;

    local procedure CopySalesCrMemoLine();
    var
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        SalesCrMemoLineDataTransfer: DataTransfer;
    begin
        SalesCrMemoLineDataTransfer.SetTables(Database::"Sales Cr.Memo Line", Database::"Sales Cr.Memo Line");
        SalesCrMemoLineDataTransfer.AddFieldValue(SalesCrMemoLine.FieldNo("Tariff No."), SalesCrMemoLine.FieldNo("Tariff No. CZL"));
        SalesCrMemoLineDataTransfer.AddFieldValue(SalesCrMemoLine.FieldNo("Statistic Indication"), SalesCrMemoLine.FieldNo("Statistic Indication CZL"));
        SalesCrMemoLineDataTransfer.AddFieldValue(SalesCrMemoLine.FieldNo("Country/Region of Origin Code"), SalesCrMemoLine.FieldNo("Country/Reg. of Orig. Code CZL"));
        SalesCrMemoLineDataTransfer.CopyFields();
    end;

    local procedure CopySalesInvoiceLine();
    var
        SalesInvoiceLine: Record "Sales Invoice Line";
        SalesInvoicelineDataTransfer: DataTransfer;
    begin
        SalesInvoicelineDataTransfer.SetTables(Database::"Sales Invoice Line", Database::"Sales Invoice Line");
        SalesInvoicelineDataTransfer.AddFieldValue(SalesInvoiceLine.FieldNo("Tariff No."), SalesInvoiceLine.FieldNo("Tariff No. CZL"));
        SalesInvoicelineDataTransfer.AddFieldValue(SalesInvoiceLine.FieldNo("Statistic Indication"), SalesInvoiceLine.FieldNo("Statistic Indication CZL"));
        SalesInvoicelineDataTransfer.AddFieldValue(SalesInvoiceLine.FieldNo("Country/Region of Origin Code"), SalesInvoiceLine.FieldNo("Country/Reg. of Orig. Code CZL"));
        SalesInvoicelineDataTransfer.CopyFields();
    end;

    local procedure CopySalesLine();
    var
        SalesLine: Record "Sales Line";
        SalesLineDataTransfer: DataTransfer;
    begin
        SalesLineDataTransfer.SetTables(Database::"Sales Line", Database::"Sales Line");
        SalesLineDataTransfer.AddFieldValue(SalesLine.FieldNo("Negative"), SalesLine.FieldNo("Negative CZL"));
        SalesLineDataTransfer.AddFieldValue(SalesLine.FieldNo("Physical Transfer"), SalesLine.FieldNo("Physical Transfer CZL"));
        SalesLineDataTransfer.AddFieldValue(SalesLine.FieldNo("Tariff No."), SalesLine.FieldNo("Tariff No. CZL"));
        SalesLineDataTransfer.AddFieldValue(SalesLine.FieldNo("Statistic Indication"), SalesLine.FieldNo("Statistic Indication CZL"));
        SalesLineDataTransfer.AddFieldValue(SalesLine.FieldNo("Country/Region of Origin Code"), SalesLine.FieldNo("Country/Reg. of Orig. Code CZL"));
        SalesLineDataTransfer.CopyFields();
    end;

    local procedure CopySalesShipmentLine();
    var
        SalesShipmentLine: Record "Sales Shipment Line";
        SalesShipmentLineDataTransfer: DataTransfer;
    begin
        SalesShipmentLineDataTransfer.SetTables(Database::"Sales Shipment Line", Database::"Sales Shipment Line");
        SalesShipmentLineDataTransfer.AddFieldValue(SalesShipmentLine.FieldNo("Tariff No."), SalesShipmentLine.FieldNo("Tariff No. CZL"));
        SalesShipmentLineDataTransfer.AddFieldValue(SalesShipmentLine.FieldNo("Statistic Indication"), SalesShipmentLine.FieldNo("Statistic Indication CZL"));
        SalesShipmentLineDataTransfer.CopyFields();
    end;

    local procedure CopyTariffNumber();
    var
        UnitOfMeasure: Record "Unit of Measure";
        TariffNumber: Record "Tariff Number";
    begin
        TariffNumber.SetLoadFields("Statement Code", "Statement Limit Code", "VAT Stat. Unit of Measure Code", "Allow Empty Unit of Meas.Code", "Full Name ENG", "Description EN CZL",
                                   "Supplem. Unit of Measure Code", "Supplem. Unit of Measure Code");
        if TariffNumber.FindSet() then
            repeat
                TariffNumber."Statement Code CZL" := TariffNumber."Statement Code";
                TariffNumber."Statement Limit Code CZL" := TariffNumber."Statement Limit Code";
                TariffNumber."VAT Stat. UoM Code CZL" := TariffNumber."VAT Stat. Unit of Measure Code";
                TariffNumber."Allow Empty UoM Code CZL" := TariffNumber."Allow Empty Unit of Meas.Code";
                TariffNumber."Description EN CZL" := CopyStr(TariffNumber."Full Name ENG", 1, MaxStrLen(TariffNumber."Description EN CZL"));
                TariffNumber."Suppl. Unit of Meas. Code CZL" := TariffNumber."Supplem. Unit of Measure Code";
                TariffNumber."Supplementary Units" := UnitOfMeasure.Get(TariffNumber."Supplem. Unit of Measure Code");
                TariffNumber.Modify(false);
            until TariffNumber.Next() = 0;
    end;

    local procedure CopyCommodity();
    var
        Commodity: Record Commodity;
        CommodityCZL: Record "Commodity CZL";
    begin
        if Commodity.FindSet() then
            repeat
                if not CommodityCZL.Get(Commodity.Code) then begin
                    CommodityCZL.Init();
                    CommodityCZL.Code := Commodity.Code;
                    CommodityCZL.SystemId := Commodity.SystemId;
                    CommodityCZL.Insert(false, true);
                end;
                CommodityCZL.Description := Commodity.Description;
                CommodityCZL.Modify(false);
            until Commodity.Next() = 0;
    end;

    local procedure CopyCommoditySetup();
    var
        CommoditySetup: Record "Commodity Setup";
        CommoditySetupCZL: Record "Commodity Setup CZL";
    begin
        if CommoditySetup.FindSet() then
            repeat
                if not CommoditySetupCZL.Get(CommoditySetup."Commodity Code", CommoditySetup."Valid From") then begin
                    CommoditySetupCZL.Init();
                    CommoditySetupCZL."Commodity Code" := CommoditySetup."Commodity Code";
                    CommoditySetupCZL."Valid From" := CommoditySetup."Valid From";
                    CommoditySetupCZL.SystemId := CommoditySetup.SystemId;
                    CommoditySetupCZL.Insert(false, true);
                end;
                CommoditySetupCZL."Commodity Limit Amount LCY" := CommoditySetup."Commodity Limit Amount LCY";
                CommoditySetupCZL."Valid To" := CommoditySetup."Valid To";
                CommoditySetupCZL.Modify(false);
            until CommoditySetup.Next() = 0;
    end;

    local procedure CopyStatisticIndication();
    var
        StatisticIndication: Record "Statistic Indication";
        StatisticIndicationCZL: Record "Statistic Indication CZL";
    begin
        if StatisticIndication.FindSet() then
            repeat
                if not StatisticIndicationCZL.Get(StatisticIndication."Tariff No.", StatisticIndication.Code) then begin
                    StatisticIndicationCZL.Init();
                    StatisticIndicationCZL."Tariff No." := StatisticIndication."Tariff No.";
                    StatisticIndicationCZL.Code := StatisticIndication.Code;
                    StatisticIndicationCZL.SystemId := StatisticIndication.SystemId;
                    StatisticIndicationCZL.Insert(false, true);
                end;
                StatisticIndicationCZL.Description := StatisticIndication.Description;
                StatisticIndicationCZL."Description EN" := CopyStr(StatisticIndication."Full Name ENG", 1, MaxStrLen(StatisticIndicationCZL."Description EN"));
                StatisticIndication.Modify(false);
            until StatisticIndication.Next() = 0;
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

    local procedure CopyStockkeepingUnitTemplate();
    var
        StockkeepingUnitTemplate: Record "Stockkeeping Unit Template";
        StockkeepingUnitTemplateCZL: Record "Stockkeeping Unit Template CZL";
        StockkeepingUnit: Record "Stockkeeping Unit";
        ConfigTemplateHeader: Record "Config. Template Header";
    begin
        if StockkeepingUnitTemplate.FindSet() then
            repeat
                CreateTemplateHeader(ConfigTemplateHeader, GetNextDataTemplateAvailableCode(),
                                     GetDataTemplateDescription(StockkeepingUnitTemplate),
                                     Database::"Stockkeeping Unit");
                if StockkeepingUnitTemplate."Components at Location" <> '' then
                    CreateTemplateLine(ConfigTemplateHeader, StockkeepingUnit.FieldNo("Components at Location"), StockkeepingUnitTemplate."Components at Location");
                if StockkeepingUnitTemplate."Replenishment System" <> StockkeepingUnitTemplate."Replenishment System"::Purchase then
                    CreateTemplateLine(ConfigTemplateHeader, StockkeepingUnit.FieldNo("Replenishment System"), Format(StockkeepingUnitTemplate."Replenishment System"));
                if StockkeepingUnitTemplate."Reordering Policy" <> StockkeepingUnitTemplate."Reordering Policy"::" " then
                    CreateTemplateLine(ConfigTemplateHeader, StockkeepingUnit.FieldNo("Reordering Policy"), Format(StockkeepingUnitTemplate."Reordering Policy"));
                if StockkeepingUnitTemplate."Include Inventory" then
                    CreateTemplateLine(ConfigTemplateHeader, StockkeepingUnit.FieldNo("Include Inventory"), Format(StockkeepingUnitTemplate."Include Inventory"));
                if StockkeepingUnitTemplate."Transfer-from Code" <> '' then
                    CreateTemplateLine(ConfigTemplateHeader, StockkeepingUnit.FieldNo("Transfer-from Code"), StockkeepingUnitTemplate."Transfer-from Code");
                if StockkeepingUnitTemplate."Gen. Prod. Posting Group" <> '' then
                    CreateTemplateLine(ConfigTemplateHeader, StockkeepingUnit.FieldNo("Gen. Prod. Posting Group"), StockkeepingUnitTemplate."Gen. Prod. Posting Group");

                if not StockkeepingUnitTemplateCZL.Get(StockkeepingUnitTemplate."Item Category Code", StockkeepingUnitTemplate."Location Code") then begin
                    StockkeepingUnitTemplateCZL.Init();
                    StockkeepingUnitTemplateCZL."Item Category Code" := StockkeepingUnitTemplate."Item Category Code";
                    StockkeepingUnitTemplateCZL."Location Code" := StockkeepingUnitTemplate."Location Code";
                    StockkeepingUnitTemplateCZL.SystemId := StockkeepingUnitTemplate.SystemId;
                    StockkeepingUnitTemplateCZL.Insert(false, true);
                end;
                StockkeepingUnitTemplateCZL.Description := StockkeepingUnitTemplateCZL.GetDefaultDescription();
                StockkeepingUnitTemplateCZL."Configuration Template Code" := ConfigTemplateHeader.Code;
                StockkeepingUnitTemplateCZL.Modify(false);
            until StockkeepingUnitTemplate.Next() = 0;
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

    local procedure GetDataTemplateDescription(StockkeepingUnitTemplate1: Record "Stockkeeping Unit Template"): Text[100]
    var
        StockkeepingUnit: Record "Stockkeeping Unit";
        StockkeepingUnitConfigTemplDescTok: Label '%1 %2 %3', Comment = '%1 = Stockkeeping Unit TableCaption, %2 = "Item Category Code", %3 = "Location Code"', Locked = true;
    begin
        exit(CopyStr(StrSubstNo(StockkeepingUnitConfigTemplDescTok,
                                StockkeepingUnit.TableCaption(),
                                StockkeepingUnitTemplate1."Item Category Code",
                                StockkeepingUnitTemplate1."Location Code"), 1, 100));
    end;

    local procedure CopyStockkeepingUnit();
    var
        StockkeepingUnit: Record "Stockkeeping Unit";
        StockkeepingUnitDataTransfer: DataTransfer;
    begin
        StockkeepingUnitDataTransfer.SetTables(Database::"Stockkeeping Unit", Database::"Stockkeeping Unit");
        StockkeepingUnitDataTransfer.AddFieldValue(StockkeepingUnit.FieldNo("Gen. Prod. Posting Group"), StockkeepingUnit.FieldNo("Gen. Prod. Posting Group CZL"));
        StockkeepingUnitDataTransfer.CopyFields();
    end;

    local procedure CopyItem();
    var
        Item: Record Item;
        ItemDataTransfer: DataTransfer;
    begin
        ItemDataTransfer.SetTables(Database::Item, Database::Item);
        ItemDataTransfer.AddFieldValue(Item.FieldNo("Statistic Indication"), Item.FieldNo("Statistic Indication CZL"));
        ItemDataTransfer.AddFieldValue(Item.FieldNo("Specific Movement"), Item.FieldNo("Specific Movement CZL"));
        ItemDataTransfer.CopyFields();
    end;

    local procedure CopyResource();
    var
        Resource: Record Resource;
        ResourceDataTransfer: DataTransfer;
    begin
        ResourceDataTransfer.SetTables(Database::Resource, Database::Resource);
        ResourceDataTransfer.AddFieldValue(Resource.FieldNo("Tariff No."), Resource.FieldNo("Tariff No. CZL"));
        ResourceDataTransfer.CopyFields();
    end;

    local procedure CopyServiceLine();
    var
        ServiceLine: Record "Service Line";
        ServiceLineDataTransfer: DataTransfer;
    begin
        ServiceLineDataTransfer.SetTables(Database::"Service Line", Database::"Service Line");
        ServiceLineDataTransfer.AddFieldValue(ServiceLine.FieldNo("Negative"), ServiceLine.FieldNo("Negative CZL"));
        ServiceLineDataTransfer.AddFieldValue(ServiceLine.FieldNo("Physical Transfer"), ServiceLine.FieldNo("Physical Transfer CZL"));
        ServiceLineDataTransfer.AddFieldValue(ServiceLine.FieldNo("Tariff No."), ServiceLine.FieldNo("Tariff No. CZL"));
        ServiceLineDataTransfer.AddFieldValue(ServiceLine.FieldNo("Statistic Indication"), ServiceLine.FieldNo("Statistic Indication CZL"));
        ServiceLineDataTransfer.AddFieldValue(ServiceLine.FieldNo("Country/Region of Origin Code"), ServiceLine.FieldNo("Country/Reg. of Orig. Code CZL"));
        ServiceLineDataTransfer.CopyFields();
    end;

    local procedure CopyServiceInvoiceLine();
    var
        ServiceInvoiceLine: Record "Service Invoice Line";
        ServiceInvoiceLineDataTransfer: DataTransfer;
    begin
        ServiceInvoiceLineDataTransfer.SetTables(Database::"Service Invoice Line", Database::"Service Invoice Line");
        ServiceInvoiceLineDataTransfer.AddFieldValue(ServiceInvoiceLine.FieldNo("Tariff No."), ServiceInvoiceLine.FieldNo("Tariff No. CZL"));
        ServiceInvoiceLineDataTransfer.AddFieldValue(ServiceInvoiceLine.FieldNo("Statistic Indication"), ServiceInvoiceLine.FieldNo("Statistic Indication CZL"));
        ServiceInvoiceLineDataTransfer.AddFieldValue(ServiceInvoiceLine.FieldNo("Country/Region of Origin Code"), ServiceInvoiceLine.FieldNo("Country/Reg. of Orig. Code CZL"));
        ServiceInvoiceLineDataTransfer.CopyFields();
    end;

    local procedure CopyServiceCrMemoLine();
    var
        ServiceCrMemoLine: Record "Service Cr.Memo Line";
        ServiceCrMemoLineDataTransfer: DataTransfer;
    begin
        ServiceCrMemoLineDataTransfer.SetTables(Database::"Service Cr.Memo Line", Database::"Service Cr.Memo Line");
        ServiceCrMemoLineDataTransfer.AddFieldValue(ServiceCrMemoLine.FieldNo("Tariff No."), ServiceCrMemoLine.FieldNo("Tariff No. CZL"));
        ServiceCrMemoLineDataTransfer.AddFieldValue(ServiceCrMemoLine.FieldNo("Statistic Indication"), ServiceCrMemoLine.FieldNo("Statistic Indication CZL"));
        ServiceCrMemoLineDataTransfer.AddFieldValue(ServiceCrMemoLine.FieldNo("Country/Region of Origin Code"), ServiceCrMemoLine.FieldNo("Country/Reg. of Orig. Code CZL"));
        ServiceCrMemoLineDataTransfer.CopyFields();
    end;

    local procedure CopyServiceShipmentLine();
    var
        ServiceShipmentLine: Record "Service Shipment Line";
        ServiceShipmentLineDataTransfer: DataTransfer;
    begin
        ServiceShipmentLineDataTransfer.SetTables(Database::"Service Shipment Line", Database::"Service Shipment Line");
        ServiceShipmentLineDataTransfer.AddFieldValue(ServiceShipmentLine.FieldNo("Tariff No."), ServiceShipmentLine.FieldNo("Tariff No. CZL"));
        ServiceShipmentLineDataTransfer.AddFieldValue(ServiceShipmentLine.FieldNo("Statistic Indication"), ServiceShipmentLine.FieldNo("Statistic Indication CZL"));
        ServiceShipmentLineDataTransfer.CopyFields();
    end;

    local procedure CopyCertificateCZCode()
    var
        CertificateCZCode: Record "Certificate CZ Code";
        CertificateCodeCZL: Record "Certificate Code CZL";
    begin
        if CertificateCZCode.FindSet() then
            repeat
                if not CertificateCodeCZL.Get(CertificateCZCode.Code) then begin
                    CertificateCodeCZL.Init();
                    CertificateCodeCZL.Code := CertificateCZCode.Code;
                    CertificateCodeCZL.SystemId := CertificateCZCode.SystemId;
                    CertificateCodeCZL.Insert(false, true);
                end;
                CertificateCodeCZL.Description := CertificateCZCode.Description;
                CertificateCodeCZL.Modify(false);
            until CertificateCZCode.Next() = 0;
    end;

    local procedure CopyIsolatedCertificate()
    var
        IsolatedCertificate: Record "Isolated Certificate";
        IsolatedCertificateDataTransfer: DataTransfer;
    begin
        IsolatedCertificateDataTransfer.SetTables(Database::"Isolated Certificate", Database::"Isolated Certificate");
        IsolatedCertificateDataTransfer.AddFieldValue(IsolatedCertificate.FieldNo("Certificate Code"), IsolatedCertificate.FieldNo("Certificate Code CZL"));
        IsolatedCertificateDataTransfer.CopyFields();
    end;

    local procedure CopyEETServiceSetup()
    var
        EETServiceSetup: Record "EET Service Setup";
        EETServiceSetupCZL: Record "EET Service Setup CZL";
    begin
        if EETServiceSetup.Get() then begin
            if not EETServiceSetupCZL.Get() then begin
                EETServiceSetupCZL.Init();
                EETServiceSetupCZL.SystemId := EETServiceSetup.SystemId;
                EETServiceSetupCZL.Insert(false, true);
            end;
            EETServiceSetupCZL."Service URL" := EETServiceSetup."Service URL";
            EETServiceSetupCZL."Sales Regime" := EETServiceSetup."Sales Regime";
            EETServiceSetupCZL."Limit Response Time" := EETServiceSetup."Limit Response Time";
            EETServiceSetupCZL."Appointing VAT Reg. No." := EETServiceSetup."Appointing VAT Reg. No.";
            EETServiceSetupCZL."Certificate Code" := EETServiceSetup."Certificate Code";
            if EETServiceSetup.Enabled then begin
                EETServiceSetupCZL.Enabled := true;
                EETServiceSetup.Validate(Enabled, false);
                EETServiceSetup.Modify(false);
            end;
            EETServiceSetupCZL.Modify(false);
        end;
    end;

    local procedure CopyEETBusinessPremises()
    var
        EETBusinessPremises: Record "EET Business Premises";
        EETBusinessPremisesCZL: Record "EET Business Premises CZL";
    begin
        if EETBusinessPremises.FindSet() then
            repeat
                if not EETBusinessPremisesCZL.Get(EETBusinessPremises.Code) then begin
                    EETBusinessPremisesCZL.Init();
                    EETBusinessPremisesCZL.Code := EETBusinessPremises.Code;
                    EETBusinessPremisesCZL.SystemId := EETBusinessPremises.SystemId;
                    EETBusinessPremisesCZL.Insert(false, true);
                end;
                EETBusinessPremisesCZL.Description := EETBusinessPremises.Description;
                EETBusinessPremisesCZL.Identification := EETBusinessPremises.Identification;
                EETBusinessPremisesCZL."Certificate Code" := EETBusinessPremises."Certificate Code";
                EETBusinessPremisesCZL.Modify(false);
            until EETBusinessPremises.Next() = 0;
    end;

    local procedure CopyEETCashRegister()
    var
        EETCashRegister: Record "EET Cash Register";
        EETCashRegisterCZL: Record "EET Cash Register CZL";
    begin
        if EETCashRegister.FindSet() then
            repeat
                if not EETCashRegisterCZL.Get(EETCashRegister."Business Premises Code", EETCashRegister.Code) then begin
                    EETCashRegisterCZL.Init();
                    EETCashRegisterCZL."Business Premises Code" := EETCashRegister."Business Premises Code";
                    EETCashRegisterCZL.Code := EETCashRegister.Code;
                    EETCashRegisterCZL.SystemId := EETCashRegister.SystemId;
                    EETCashRegisterCZL.Insert(false, true);
                end;
                EETCashRegisterCZL."Cash Register Type" := "EET Cash Register Type CZL".FromInteger(EETCashRegister."Register Type");
                EETCashRegisterCZL."Cash Register No." := EETCashRegister."Register No.";
                EETCashRegisterCZL."Cash Register Name" := EETCashRegister."Register Name";
                EETCashRegisterCZL."Certificate Code" := EETCashRegister."Certificate Code";
                EETCashRegisterCZL."Receipt Serial Nos." := EETCashRegister."Receipt Serial Nos.";
                EETCashRegisterCZL.Modify(false);
            until EETCashRegister.Next() = 0;
    end;

    local procedure CopyEETEntry()
    var
        EETEntry: Record "EET Entry";
        EETEntryCZL: Record "EET Entry CZL";
    begin
        if EETEntry.FindSet() then
            repeat
                if not EETEntryCZL.Get(EETEntry."Entry No.") then begin
                    EETEntryCZL.Init();
                    EETEntryCZL."Entry No." := EETEntry."Entry No.";
                    EETEntryCZL.SystemId := EETEntry.SystemId;
                    EETEntryCZL.Insert(false, true);
                end;
                EETEntryCZL."Cash Register Type" := "EET Cash Register Type CZL".FromInteger(EETEntry."Source Type");
                EETEntryCZL."Cash Register No." := EETEntry."Source No.";
                EETEntryCZL."Business Premises Code" := EETEntry."Business Premises Code";
                EETEntryCZL."Cash Register Code" := EETEntry."Cash Register Code";
                EETEntryCZL."Document No." := EETEntry."Document No.";
                EETEntryCZL.Description := EETEntry.Description;
                EETEntryCZL."Applied Document Type" := EETEntry."Applied Document Type";
                EETEntryCZL."Applied Document No." := EETEntry."Applied Document No.";
                EETEntryCZL."Created By" := EETEntry."User ID";
                EETEntryCZL."Created At" := EETEntry."Creation Datetime";
                EETEntryCZL."Status" := "EET Status CZL".FromInteger(EETEntry."EET Status");
                EETEntryCZL."Status Last Changed At" := EETEntry."EET Status Last Changed";
                EETEntryCZL."Message UUID" := EETEntry."Message UUID";
                EETEntry.CalcFields("Signature Code (PKP)");
                EETEntryCZL."Taxpayer's Signature Code" := EETEntry."Signature Code (PKP)";
                EETEntryCZL."Taxpayer's Security Code" := EETEntry."Security Code (BKP)";
                EETEntryCZL."Fiscal Identification Code" := EETEntry."Fiscal Identification Code";
                EETEntryCZL."Receipt Serial No." := EETEntry."Receipt Serial No.";
                EETEntryCZL."Total Sales Amount" := EETEntry."Total Sales Amount";
                EETEntryCZL."Amount Exempted From VAT" := EETEntry."Amount Exempted From VAT";
                EETEntryCZL."VAT Base (Basic)" := EETEntry."VAT Base (Basic)";
                EETEntryCZL."VAT Amount (Basic)" := EETEntry."VAT Amount (Basic)";
                EETEntryCZL."VAT Base (Reduced)" := EETEntry."VAT Base (Reduced)";
                EETEntryCZL."VAT Amount (Reduced)" := EETEntry."VAT Amount (Reduced)";
                EETEntryCZL."VAT Base (Reduced 2)" := EETEntry."VAT Base (Reduced 2)";
                EETEntryCZL."VAT Amount (Reduced 2)" := EETEntry."VAT Amount (Reduced 2)";
                EETEntryCZL."Amount - Art.89" := EETEntry."Amount - Art.89";
                EETEntryCZL."Amount (Basic) - Art.90" := EETEntry."Amount (Basic) - Art.90";
                EETEntryCZL."Amount (Reduced) - Art.90" := EETEntry."Amount (Reduced) - Art.90";
                EETEntryCZL."Amount (Reduced 2) - Art.90" := EETEntry."Amount (Reduced 2) - Art.90";
                EETEntryCZL."Amt. For Subseq. Draw/Settle" := EETEntry."Amt. For Subseq. Draw/Settle";
                EETEntryCZL."Amt. Subseq. Drawn/Settled" := EETEntry."Amt. Subseq. Drawn/Settled";
                EETEntryCZL."Canceled By Entry No." := EETEntry."Canceled By Entry No.";
                EETEntryCZL."Simple Registration" := EETEntry."Simple Registration";
                EETEntryCZL.Modify(false);
            until EETEntry.Next() = 0;
    end;

    local procedure CopyEETEntryStatus()
    var
        EETEntryStatus: Record "EET Entry Status";
        EETEntryStatusLogCZL: Record "EET Entry Status Log CZL";
    begin
        if EETEntryStatus.FindSet() then
            repeat
                if not EETEntryStatusLogCZL.Get(EETEntryStatus."Entry No.") then begin
                    EETEntryStatusLogCZL.Init();
                    EETEntryStatusLogCZL."Entry No." := EETEntryStatus."Entry No.";
                    EETEntryStatusLogCZL.SystemId := EETEntryStatus.SystemId;
                    EETEntryStatusLogCZL.Insert(false, true);
                end;
                EETEntryStatusLogCZL."EET Entry No." := EETEntryStatus."EET Entry No.";
                EETEntryStatusLogCZL.Description := EETEntryStatus.Description;
                EETEntryStatusLogCZL.Status := "EET Status CZL".FromInteger(EETEntryStatus.Status);
                EETEntryStatusLogCZL."Changed At" := EETEntryStatus."Change Datetime";
                EETEntryStatusLogCZL.Modify(false);
            until EETEntryStatus.Next() = 0;
    end;

    local procedure CopyBankAccount();
    var
        BankAccount: Record "Bank Account";
        BankAccountDataTransfer: DataTransfer;
    begin
        BankAccountDataTransfer.SetTables(Database::"Bank Account", Database::"Bank Account");
        BankAccountDataTransfer.AddFieldValue(BankAccount.FieldNo("Exclude from Exch. Rate Adj."), BankAccount.FieldNo("Excl. from Exch. Rate Adj. CZL"));
        BankAccountDataTransfer.CopyFields();
    end;

    local procedure CopyConstantSymbol();
    var
        ConstantSymbol: Record "Constant Symbol";
        ConstantSymbolCZL: Record "Constant Symbol CZL";
    begin
        if ConstantSymbol.FindSet() then
            repeat
                if not ConstantSymbolCZL.Get(ConstantSymbol.Code) then begin
                    ConstantSymbolCZL.Init();
                    ConstantSymbolCZL.Code := ConstantSymbol.Code;
                    ConstantSymbolCZL.SystemId := ConstantSymbol.SystemId;
                    ConstantSymbolCZL.Insert(false, true);
                end;
                ConstantSymbolCZL.Description := ConstantSymbol.Description;
                ConstantSymbolCZL.Modify(false);
            until ConstantSymbol.Next() = 0;
    end;

    local procedure CopyDepreciationBook();
    var
        DepreciationBook: Record "Depreciation Book";
        DepreciationBookDataTransfer: DataTransfer;
    begin
        DepreciationBookDataTransfer.SetTables(Database::"Depreciation Book", Database::"Depreciation Book");
        DepreciationBookDataTransfer.AddFieldValue(DepreciationBook.FieldNo("Mark Reclass. as Corrections"), DepreciationBook.FieldNo("Mark Reclass. as Correct. CZL"));
        DepreciationBookDataTransfer.CopyFields();
    end;

    local procedure CopyValueEntry();
    var
        ValueEntry: Record "Value Entry";
        ValueEntryDataTransfer: DataTransfer;
    begin
        ValueEntryDataTransfer.SetTables(Database::"Value Entry", Database::"Value Entry");
        ValueEntryDataTransfer.AddFieldValue(ValueEntry.FieldNo("G/L Correction"), ValueEntry.FieldNo("G/L Correction CZL"));
        ValueEntryDataTransfer.AddFieldValue(ValueEntry.FieldNo("Incl. in Intrastat Amount"), ValueEntry.FieldNo("Incl. in Intrastat Amount CZL"));
        ValueEntryDataTransfer.AddFieldValue(ValueEntry.FieldNo("Incl. in Intrastat Stat. Value"), ValueEntry.FieldNo("Incl. in Intrastat S.Value CZL"));
        ValueEntryDataTransfer.CopyFields();
    end;

    local procedure CopySubstCustomerPostingGroup();
    var
        AltCustomerPostingGroup: Record "Alt. Customer Posting Group";
        SubstCustomerPostingGroup: Record "Subst. Customer Posting Group";
    begin
        if SubstCustomerPostingGroup.FindSet() then
            repeat
                if not AltCustomerPostingGroup.Get(SubstCustomerPostingGroup."Parent Cust. Posting Group", SubstCustomerPostingGroup."Customer Posting Group") then begin
                    AltCustomerPostingGroup.Init();
                    AltCustomerPostingGroup."Customer Posting Group" := SubstCustomerPostingGroup."Parent Cust. Posting Group";
                    AltCustomerPostingGroup."Alt. Customer Posting Group" := SubstCustomerPostingGroup."Customer Posting Group";
                    AltCustomerPostingGroup.SystemId := SubstCustomerPostingGroup.SystemId;
                    AltCustomerPostingGroup.Insert(false, true);
                end;
            until SubstCustomerPostingGroup.Next() = 0;
    end;

    local procedure CopySubstVendorPostingGroup();
    var
        AltVendorPostingGroup: Record "Alt. Vendor Posting Group";
        SubstVendorPostingGroup: Record "Subst. Vendor Posting Group";
    begin
        if SubstVendorPostingGroup.FindSet() then
            repeat
                if not AltVendorPostingGroup.Get(SubstVendorPostingGroup."Parent Vend. Posting Group", SubstVendorPostingGroup."Vendor Posting Group") then begin
                    AltVendorPostingGroup.Init();
                    AltVendorPostingGroup."Vendor Posting Group" := SubstVendorPostingGroup."Parent Vend. Posting Group";
                    AltVendorPostingGroup."Alt. Vendor Posting Group" := SubstVendorPostingGroup."Vendor Posting Group";
                    AltVendorPostingGroup.SystemId := SubstVendorPostingGroup.SystemId;
                    AltVendorPostingGroup.Insert(false, true);
                end;
            until SubstVendorPostingGroup.Next() = 0;
    end;

    local procedure CopyShipmentMethod();
    var
        ShipmentMethod: Record "Shipment Method";
        ShipmentMethodDataTransfer: DataTransfer;
    begin
        ShipmentMethodDataTransfer.SetTables(Database::"Shipment Method", Database::"Shipment Method");
        ShipmentMethodDataTransfer.AddFieldValue(ShipmentMethod.FieldNo("Include Item Charges (Amount)"), ShipmentMethod.FieldNo("Incl. Item Charges (Amt.) CZL"));
        ShipmentMethodDataTransfer.AddFieldValue(ShipmentMethod.FieldNo("Intrastat Delivery Group Code"), ShipmentMethod.FieldNo("Intrastat Deliv. Grp. Code CZL"));
        ShipmentMethodDataTransfer.AddFieldValue(ShipmentMethod.FieldNo("Incl. Item Charges (Stat.Val.)"), ShipmentMethod.FieldNo("Incl. Item Charges (S.Val) CZL"));
        ShipmentMethodDataTransfer.AddFieldValue(ShipmentMethod.FieldNo("Adjustment %"), ShipmentMethod.FieldNo("Adjustment % CZL"));
        ShipmentMethodDataTransfer.CopyFields();
    end;

    local procedure CopySpecificMovement()
    var
        SpecificMovement: Record "Specific Movement";
        SpecificMovementCZL: Record "Specific Movement CZL";
    begin
        if SpecificMovement.FindSet() then
            repeat
                if not SpecificMovementCZL.Get(SpecificMovement.Code) then begin
                    SpecificMovementCZL.Init();
                    SpecificMovementCZL.Code := SpecificMovement.Code;
                    SpecificMovementCZL.SystemId := SpecificMovement.SystemId;
                    SpecificMovementCZL.Insert(false, true);
                end;
                SpecificMovementCZL.Description := SpecificMovement.Description;
                SpecificMovementCZL.Modify(false);
            until SpecificMovement.Next() = 0;
    end;

    local procedure CopyIntrastatDeliveryGroup()
    var
        IntrastatDeliveryGroup: Record "Intrastat Delivery Group";
        IntrastatDeliveryGroupCZL: Record "Intrastat Delivery Group CZL";
    begin
        if IntrastatDeliveryGroup.FindSet() then
            repeat
                if not IntrastatDeliveryGroupCZL.Get(IntrastatDeliveryGroup.Code) then begin
                    IntrastatDeliveryGroupCZL.Init();
                    IntrastatDeliveryGroupCZL.Code := IntrastatDeliveryGroup.Code;
                    IntrastatDeliveryGroupCZL.SystemId := IntrastatDeliveryGroup.SystemId;
                    IntrastatDeliveryGroupCZL.Insert(false, true);
                end;
                IntrastatDeliveryGroupCZL.Description := IntrastatDeliveryGroup.Description;
                IntrastatDeliveryGroupCZL.Modify(false);
            until IntrastatDeliveryGroup.Next() = 0;
    end;

    local procedure CopyUnitofMeasure();
    var
        UnitofMeasure: Record "Unit of Measure";
    begin
        UnitofMeasure.SetLoadFields("Tariff Number UOM Code");
        if UnitofMeasure.FindSet() then
            repeat
                UnitofMeasure."Tariff Number UOM Code CZL" := CopyStr(UnitofMeasure."Tariff Number UOM Code", 1, 10);
                UnitofMeasure.Modify(false);
            until UnitofMeasure.Next() = 0;
    end;

    local procedure CopySalesLineArchive();
    var
        SalesLineArchive: Record "Sales Line Archive";
        SalesLineArchiveDataTransfer: DataTransfer;
    begin
        SalesLineArchiveDataTransfer.SetTables(Database::"Sales Line Archive", Database::"Sales Line Archive");
        SalesLineArchiveDataTransfer.AddFieldValue(SalesLineArchive.FieldNo("Physical Transfer"), SalesLineArchive.FieldNo("Physical Transfer CZL"));
        SalesLineArchiveDataTransfer.CopyFields();
    end;

    local procedure CopyPurchaseLineArchive();
    var
        PurchaseLineArchive: Record "Purchase Line Archive";
        PurchaseLineArchiveDataTransfer: DataTransfer;
    begin
        PurchaseLineArchiveDataTransfer.SetTables(Database::"Purchase Line Archive", Database::"Purchase Line Archive");
        PurchaseLineArchiveDataTransfer.AddFieldValue(PurchaseLineArchive.FieldNo("Physical Transfer"), PurchaseLineArchive.FieldNo("Physical Transfer CZL"));
        PurchaseLineArchiveDataTransfer.CopyFields();
    end;

    local procedure CopyTransferHeader();
    var
        TransferHeader: Record "Transfer Header";
        TransferHeaderDataTransfer: DataTransfer;
    begin
        TransferHeaderDataTransfer.SetTables(Database::"Transfer Header", Database::"Transfer Header");
        TransferHeaderDataTransfer.AddFieldValue(TransferHeader.FieldNo("Intrastat Exclude"), TransferHeader.FieldNo("Intrastat Exclude CZL"));
        TransferHeaderDataTransfer.CopyFields();
    end;

    local procedure CopyTransferLine();
    var
        TransferLine: Record "Transfer Line";
        TransferLineDataTransfer: DataTransfer;
    begin
        TransferLineDataTransfer.SetTables(Database::"Transfer Line", Database::"Transfer Line");
        TransferLineDataTransfer.AddFieldValue(TransferLine.FieldNo("Tariff No."), TransferLine.FieldNo("Tariff No. CZL"));
        TransferLineDataTransfer.AddFieldValue(TransferLine.FieldNo("Statistic Indication"), TransferLine.FieldNo("Statistic Indication CZL"));
        TransferLineDataTransfer.AddFieldValue(TransferLine.FieldNo("Country/Region of Origin Code"), TransferLine.FieldNo("Country/Reg. of Orig. Code CZL"));
        TransferLineDataTransfer.CopyFields();
    end;

    local procedure CopyTransferReceiptHeader();
    var
        TransferReceiptHeader: Record "Transfer Receipt Header";
        TransferReceiptHeaderDataTransfer: DataTransfer;
    begin
        TransferReceiptHeaderDataTransfer.SetTables(Database::"Transfer Receipt Header", Database::"Transfer Receipt Header");
        TransferReceiptHeaderDataTransfer.AddFieldValue(TransferReceiptHeader.FieldNo("Intrastat Exclude"), TransferReceiptHeader.FieldNo("Intrastat Exclude CZL"));
        TransferReceiptHeaderDataTransfer.CopyFields();
    end;

    local procedure CopyTransferShipmentHeader();
    var
        TransferShipmentHeader: Record "Transfer Shipment Header";
        TransferShipmentHeaderDataTransfer: DataTransfer;
    begin
        TransferShipmentHeaderDataTransfer.SetTables(Database::"Transfer Shipment Header", Database::"Transfer Shipment Header");
        TransferShipmentHeaderDataTransfer.AddFieldValue(TransferShipmentHeader.FieldNo("Intrastat Exclude"), TransferShipmentHeader.FieldNo("Intrastat Exclude CZL"));
        TransferShipmentHeaderDataTransfer.CopyFields();
    end;

    local procedure CopyItemLedgerEntry();
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        ItemLedgerEntryDataTransfer: DataTransfer;
    begin
        ItemLedgerEntryDataTransfer.SetTables(Database::"Item Ledger Entry", Database::"Item Ledger Entry");
        ItemLedgerEntryDataTransfer.AddFieldValue(ItemLedgerEntry.FieldNo("Tariff No."), ItemLedgerEntry.FieldNo("Tariff No. CZL"));
        ItemLedgerEntryDataTransfer.AddFieldValue(ItemLedgerEntry.FieldNo("Physical Transfer"), ItemLedgerEntry.FieldNo("Physical Transfer CZL"));
        ItemLedgerEntryDataTransfer.AddFieldValue(ItemLedgerEntry.FieldNo("Net Weight"), ItemLedgerEntry.FieldNo("Net Weight CZL"));
        ItemLedgerEntryDataTransfer.AddFieldValue(ItemLedgerEntry.FieldNo("Country/Region of Origin Code"), ItemLedgerEntry.FieldNo("Country/Reg. of Orig. Code CZL"));
        ItemLedgerEntryDataTransfer.AddFieldValue(ItemLedgerEntry.FieldNo("Statistic Indication"), ItemLedgerEntry.FieldNo("Statistic Indication CZL"));
        ItemLedgerEntryDataTransfer.AddFieldValue(ItemLedgerEntry.FieldNo("Intrastat Transaction"), ItemLedgerEntry.FieldNo("Intrastat Transaction CZL"));
        ItemLedgerEntryDataTransfer.CopyFields();
    end;

    local procedure CopyJobLedgerEntry();
    var
        JobLedgerEntry: Record "Job Ledger Entry";
        JobLedgerEntryDataTransfer: DataTransfer;
    begin
        JobLedgerEntryDataTransfer.SetTables(Database::"Job Ledger Entry", Database::"Job Ledger Entry");
        JobLedgerEntryDataTransfer.AddFieldValue(JobLedgerEntry.FieldNo("Tariff No."), JobLedgerEntry.FieldNo("Tariff No. CZL"));
        JobLedgerEntryDataTransfer.AddFieldValue(JobLedgerEntry.FieldNo("Net Weight"), JobLedgerEntry.FieldNo("Net Weight CZL"));
        JobLedgerEntryDataTransfer.AddFieldValue(JobLedgerEntry.FieldNo("Country/Region of Origin Code"), JobLedgerEntry.FieldNo("Country/Reg. of Orig. Code CZL"));
        JobLedgerEntryDataTransfer.AddFieldValue(JobLedgerEntry.FieldNo("Statistic Indication"), JobLedgerEntry.FieldNo("Statistic Indication CZL"));
        JobLedgerEntryDataTransfer.AddFieldValue(JobLedgerEntry.FieldNo("Intrastat Transaction"), JobLedgerEntry.FieldNo("Intrastat Transaction CZL"));
        JobLedgerEntryDataTransfer.CopyFields();
    end;

    local procedure CopyItemCharge();
    var
        ItemCharge: Record "Item Charge";
        ItemChargeDataTransfer: DataTransfer;
    begin
        ItemChargeDataTransfer.SetTables(Database::"Item Charge", Database::"Item Charge");
        ItemChargeDataTransfer.AddFieldValue(ItemCharge.FieldNo("Incl. in Intrastat Amount"), ItemCharge.FieldNo("Incl. in Intrastat Amount CZL"));
        ItemChargeDataTransfer.AddFieldValue(ItemCharge.FieldNo("Incl. in Intrastat Stat. Value"), ItemCharge.FieldNo("Incl. in Intrastat S.Value CZL"));
        ItemChargeDataTransfer.CopyFields();
    end;

    local procedure CopyItemChargeAssignmentPurch();
    var
        ItemChargeAssignmentPurch: Record "Item Charge Assignment (Purch)";
        ItemChargeAssignmentPurchDataTransfer: DataTransfer;
    begin
        ItemChargeAssignmentPurchDataTransfer.SetTables(Database::"Item Charge Assignment (Purch)", Database::"Item Charge Assignment (Purch)");
        ItemChargeAssignmentPurchDataTransfer.AddFieldValue(ItemChargeAssignmentPurch.FieldNo("Incl. in Intrastat Amount"), ItemChargeAssignmentPurch.FieldNo("Incl. in Intrastat Amount CZL"));
        ItemChargeAssignmentPurchDataTransfer.AddFieldValue(ItemChargeAssignmentPurch.FieldNo("Incl. in Intrastat Stat. Value"), ItemChargeAssignmentPurch.FieldNo("Incl. in Intrastat S.Value CZL"));
        ItemChargeAssignmentPurchDataTransfer.CopyFields();
    end;

    local procedure CopyItemChargeAssignmentSales();
    var
        ItemChargeAssignmentSales: Record "Item Charge Assignment (Sales)";
        ItemChargeAssignmentSalesDataTransfer: DataTransfer;
    begin
        ItemChargeAssignmentSalesDataTransfer.SetTables(Database::"Item Charge Assignment (Sales)", Database::"Item Charge Assignment (Sales)");
        ItemChargeAssignmentSalesDataTransfer.AddFieldValue(ItemChargeAssignmentSales.FieldNo("Incl. in Intrastat Amount"), ItemChargeAssignmentSales.FieldNo("Incl. in Intrastat Amount CZL"));
        ItemChargeAssignmentSalesDataTransfer.AddFieldValue(ItemChargeAssignmentSales.FieldNo("Incl. in Intrastat Stat. Value"), ItemChargeAssignmentSales.FieldNo("Incl. in Intrastat S.Value CZL"));
        ItemChargeAssignmentSalesDataTransfer.CopyFields();
    end;

    local procedure CopyPostedGenJournalLine();
    var
        PostedGenJournalLine: Record "Posted Gen. Journal Line";
        PostedGenJournalLineDataTransfer: DataTransfer;
    begin
        PostedGenJournalLineDataTransfer.SetTables(Database::"Posted Gen. Journal Line", Database::"Posted Gen. Journal Line");
        PostedGenJournalLineDataTransfer.AddFieldValue(PostedGenJournalLine.FieldNo("Specific Symbol"), PostedGenJournalLine.FieldNo("Specific Symbol CZL"));
        PostedGenJournalLineDataTransfer.AddFieldValue(PostedGenJournalLine.FieldNo("Variable Symbol"), PostedGenJournalLine.FieldNo("Variable Symbol CZL"));
        PostedGenJournalLineDataTransfer.AddFieldValue(PostedGenJournalLine.FieldNo("Constant Symbol"), PostedGenJournalLine.FieldNo("Constant Symbol CZL"));
        PostedGenJournalLineDataTransfer.AddFieldValue(PostedGenJournalLine.FieldNo("Bank Account Code"), PostedGenJournalLine.FieldNo("Bank Account Code CZL"));
        PostedGenJournalLineDataTransfer.AddFieldValue(PostedGenJournalLine.FieldNo("Bank Account No."), PostedGenJournalLine.FieldNo("Bank Account No. CZL"));
        PostedGenJournalLineDataTransfer.AddFieldValue(PostedGenJournalLine.FieldNo("Transit No."), PostedGenJournalLine.FieldNo("Transit No. CZL"));
        PostedGenJournalLineDataTransfer.AddFieldValue(PostedGenJournalLine.FieldNo(IBAN), PostedGenJournalLine.FieldNo("IBAN CZL"));
        PostedGenJournalLineDataTransfer.AddFieldValue(PostedGenJournalLine.FieldNo("SWIFT Code"), PostedGenJournalLine.FieldNo("SWIFT Code CZL"));
        PostedGenJournalLineDataTransfer.CopyFields();
    end;

    local procedure CopyIntrastatJournalBatch();
    var
        IntrastatJnlBatch: Record "Intrastat Jnl. Batch";
    begin
        IntrastatJnlBatch.SetLoadFields("Declaration No.", "Statement Type");
        if IntrastatJnlBatch.FindSet(true) then
            repeat
                IntrastatJnlBatch."Declaration No. CZL" := IntrastatJnlBatch."Declaration No.";
                IntrastatJnlBatch."Statement Type CZL" := "Intrastat Statement Type CZL".FromInteger(IntrastatJnlBatch."Statement Type");
                IntrastatJnlBatch.Modify(false);
            until IntrastatJnlBatch.Next() = 0;
    end;

    local procedure CopyIntrastatJournalLine();
    var
        IntrastatJnlLine: Record "Intrastat Jnl. Line";
    begin
        IntrastatJnlLine.SetLoadFields("Additional Costs", "Source Entry Date", "Statistic Indication", "Statistics Period", "Declaration No.", "Statement Type", "Prev. Declaration No.",
                                       "Prev. Declaration Line No.", "Specific Movement", "Supplem. UoM Code", "Supplem. UoM Quantity", "Supplem. UoM Net Weight", "Base Unit of Measure");
        if IntrastatJnlLine.FindSet(true) then
            repeat
                IntrastatJnlLine."Additional Costs CZL" := IntrastatJnlLine."Additional Costs";
                IntrastatJnlLine."Source Entry Date CZL" := IntrastatJnlLine."Source Entry Date";
                IntrastatJnlLine."Statistic Indication CZL" := IntrastatJnlLine."Statistic Indication";
                IntrastatJnlLine."Statistics Period CZL" := IntrastatJnlLine."Statistics Period";
                IntrastatJnlLine."Declaration No. CZL" := IntrastatJnlLine."Declaration No.";
                IntrastatJnlLine."Statement Type CZL" := "Intrastat Statement Type CZL".FromInteger(IntrastatJnlLine."Statement Type");
                IntrastatJnlLine."Prev. Declaration No. CZL" := IntrastatJnlLine."Prev. Declaration No.";
                IntrastatJnlLine."Prev. Declaration Line No. CZL" := IntrastatJnlLine."Prev. Declaration Line No.";
                IntrastatJnlLine."Specific Movement CZL" := IntrastatJnlLine."Specific Movement";
                IntrastatJnlLine."Supplem. UoM Code CZL" := IntrastatJnlLine."Supplem. UoM Code";
                IntrastatJnlLine."Supplem. UoM Quantity CZL" := IntrastatJnlLine."Supplem. UoM Quantity";
                IntrastatJnlLine."Supplem. UoM Net Weight CZL" := IntrastatJnlLine."Supplem. UoM Net Weight";
                IntrastatJnlLine."Base Unit of Measure CZL" := IntrastatJnlLine."Base Unit of Measure";
                IntrastatJnlLine.Modify(false);
            until IntrastatJnlLine.Next() = 0;
    end;

    local procedure CopyInventoryPostingSetup();
    var
        InventoryPostingSetup: Record "Inventory Posting Setup";
        InventoryPostingSetupDataTransfer: DataTransfer;
    begin
        InventoryPostingSetupDataTransfer.SetTables(Database::"Inventory Posting Setup", Database::"Inventory Posting Setup");
        InventoryPostingSetupDataTransfer.AddFieldValue(InventoryPostingSetup.FieldNo("Change In Inv.Of Product Acc."), InventoryPostingSetup.FieldNo("Change In Inv.OfProd. Acc. CZL"));
        InventoryPostingSetupDataTransfer.AddFieldValue(InventoryPostingSetup.FieldNo("Change In Inv.Of WIP Acc."), InventoryPostingSetup.FieldNo("Change In Inv.Of WIP Acc. CZL"));
        InventoryPostingSetupDataTransfer.AddFieldValue(InventoryPostingSetup.FieldNo("Consumption Account"), InventoryPostingSetup.FieldNo("Consumption Account CZL"));
        InventoryPostingSetupDataTransfer.CopyFields();
    end;

    local procedure CopyGeneralPostingSetup();
    var
        GeneralPostingSetup: Record "General Posting Setup";
        GeneralPostingSetupDataTransfer: DataTransfer;
    begin
        GeneralPostingSetupDataTransfer.SetTables(Database::"General Posting Setup", Database::"General Posting Setup");
        GeneralPostingSetupDataTransfer.AddFieldValue(GeneralPostingSetup.FieldNo("Invt. Rounding Adj. Account"), GeneralPostingSetup.FieldNo("Invt. Rounding Adj. Acc. CZL"));
        GeneralPostingSetupDataTransfer.CopyFields();
    end;

    local procedure CopyUserSetupLine();
    var
        UserSetupLine: Record "User Setup Line";
        UserSetupLineCZL: Record "User Setup Line CZL";
    begin
        if UserSetupLine.FindSet() then
            repeat
                if not UserSetupLineCZL.Get(UserSetupLine."User ID", UserSetupLine.Type, UserSetupLine."Line No.") then begin
                    UserSetupLineCZL.Init();
                    UserSetupLineCZL."User ID" := UserSetupLine."User ID";
                    UserSetupLineCZL.Type := UserSetupLine.Type;
                    UserSetupLineCZL."Line No." := UserSetupLine."Line No.";
                    UserSetupLineCZL.SystemId := UserSetupLine.SystemId;
                    UserSetupLineCZL.Insert(false, true);
                end;
                UserSetupLineCZL."Code / Name" := UserSetupLine."Code / Name";
                UserSetupLineCZL.Modify(false);
            until UserSetupLine.Next() = 0;
    end;

    local procedure CopyAccScheduleExtension();
    var
        AccScheduleExtension: Record "Acc. Schedule Extension";
        AccScheduleExtensionCZL: Record "Acc. Schedule Extension CZL";
    begin
        if AccScheduleExtension.FindSet() then
            repeat
                if not AccScheduleExtensionCZL.Get(AccScheduleExtension.Code) then begin
                    AccScheduleExtensionCZL.Init();
                    AccScheduleExtensionCZL.Code := AccScheduleExtension.Code;
                    AccScheduleExtensionCZL.SystemId := AccScheduleExtension.SystemId;
                    AccScheduleExtensionCZL.Insert(false, true);
                end;
                AccScheduleExtensionCZL.Description := AccScheduleExtension.Description;
                AccScheduleExtensionCZL."Source Table" := AccScheduleExtension."Source Table";
                AccScheduleExtensionCZL."Source Type" := AccScheduleExtension."Source Type";
                AccScheduleExtensionCZL."Source Filter" := AccScheduleExtension."Source Filter";
                AccScheduleExtensionCZL."G/L Account Filter" := AccScheduleExtension."G/L Account Filter";
                AccScheduleExtensionCZL."G/L Amount Type" := AccScheduleExtension."G/L Amount Type";
                AccScheduleExtensionCZL."Amount Sign" := AccScheduleExtension."Amount Sign";
                AccScheduleExtensionCZL."Entry Type" := AccScheduleExtension."Entry Type";
                AccScheduleExtensionCZL.Prepayment := AccScheduleExtension.Prepayment;
                AccScheduleExtensionCZL."Reverse Sign" := AccScheduleExtension."Reverse Sign";
                AccScheduleExtensionCZL."VAT Amount Type" := AccScheduleExtension."VAT Amount Type";
                AccScheduleExtensionCZL."VAT Bus. Post. Group Filter" := AccScheduleExtension."VAT Bus. Post. Group Filter";
                AccScheduleExtensionCZL."VAT Prod. Post. Group Filter" := AccScheduleExtension."VAT Prod. Post. Group Filter";
                AccScheduleExtensionCZL."Location Filter" := AccScheduleExtension."Location Filter";
                AccScheduleExtensionCZL."Bin Filter" := AccScheduleExtension."Bin Filter";
                AccScheduleExtensionCZL."Posting Group Filter" := AccScheduleExtension."Posting Group Filter";
                AccScheduleExtensionCZL."Posting Date Filter" := AccScheduleExtension."Posting Date Filter";
                AccScheduleExtensionCZL."Due Date Filter" := AccScheduleExtension."Due Date Filter";
                AccScheduleExtensionCZL."Document Type Filter" := AccScheduleExtension."Document Type Filter";
                AccScheduleExtensionCZL.Modify(false);
            until AccScheduleExtension.Next() = 0;
    end;

    local procedure CopyAccScheduleResultLine();
    var
        AccScheduleResultLine: Record "Acc. Schedule Result Line";
        AccScheduleResultLineCZL: Record "Acc. Schedule Result Line CZL";
    begin
        if AccScheduleResultLine.FindSet() then
            repeat
                if not AccScheduleResultLineCZL.Get(AccScheduleResultLine."Result Code", AccScheduleResultLine."Line No.") then begin
                    AccScheduleResultLineCZL.Init();
                    AccScheduleResultLineCZL."Result Code" := AccScheduleResultLine."Result Code";
                    AccScheduleResultLineCZL."Line No." := AccScheduleResultLine."Line No.";
                    AccScheduleResultLineCZL.SystemId := AccScheduleResultLine.SystemId;
                    AccScheduleResultLineCZL.Insert(false, true);
                end;
                AccScheduleResultLineCZL."Row No." := AccScheduleResultLine."Row No.";
                AccScheduleResultLineCZL.Description := AccScheduleResultLine.Description;
                AccScheduleResultLineCZL.Totaling := AccScheduleResultLine.Totaling;
                AccScheduleResultLineCZL."Totaling Type" := AccScheduleResultLine."Totaling Type";
                AccScheduleResultLineCZL."New Page" := AccScheduleResultLine."New Page";
                AccScheduleResultLineCZL.Show := AccScheduleResultLine.Show;
                AccScheduleResultLineCZL.Bold := AccScheduleResultLine.Bold;
                AccScheduleResultLineCZL.Italic := AccScheduleResultLine.Italic;
                AccScheduleResultLineCZL.Underline := AccScheduleResultLine.Underline;
                AccScheduleResultLineCZL."Show Opposite Sign" := AccScheduleResultLine."Show Opposite Sign";
                AccScheduleResultLineCZL."Row Type" := AccScheduleResultLine."Row Type";
                AccScheduleResultLineCZL."Amount Type" := AccScheduleResultLine."Amount Type";
                AccScheduleResultLineCZL.Modify(false);
            until AccScheduleResultLine.Next() = 0;
    end;

    local procedure CopyAccScheduleResultColumn();
    var
        AccScheduleResultColumn: Record "Acc. Schedule Result Column";
        AccScheduleResultColCZL: Record "Acc. Schedule Result Col. CZL";
    begin
        if AccScheduleResultColumn.FindSet() then
            repeat
                if not AccScheduleResultColCZL.Get(AccScheduleResultColumn."Result Code", AccScheduleResultColumn."Line No.") then begin
                    AccScheduleResultColCZL.Init();
                    AccScheduleResultColCZL."Result Code" := AccScheduleResultColumn."Result Code";
                    AccScheduleResultColCZL."Line No." := AccScheduleResultColumn."Line No.";
                    AccScheduleResultColCZL.SystemId := AccScheduleResultColumn.SystemId;
                    AccScheduleResultColCZL.Insert(false, true);
                end;
                AccScheduleResultColCZL."Column No." := AccScheduleResultColumn."Column No.";
                AccScheduleResultColCZL."Column Header" := AccScheduleResultColumn."Column Header";
                AccScheduleResultColCZL."Column Type" := AccScheduleResultColumn."Column Type";
                AccScheduleResultColCZL."Ledger Entry Type" := AccScheduleResultColumn."Ledger Entry Type";
                AccScheduleResultColCZL."Amount Type" := AccScheduleResultColumn."Amount Type";
                AccScheduleResultColCZL.Formula := AccScheduleResultColumn.Formula;
                AccScheduleResultColCZL."Comparison Date Formula" := AccScheduleResultColumn."Comparison Date Formula";
                AccScheduleResultColCZL."Show Opposite Sign" := AccScheduleResultColumn."Show Opposite Sign";
                AccScheduleResultColCZL.Show := AccScheduleResultColumn.Show;
                AccScheduleResultColCZL."Rounding Factor" := AccScheduleResultColumn."Rounding Factor";
                AccScheduleResultColCZL."Comparison Period Formula" := AccScheduleResultColumn."Comparison Period Formula";
                AccScheduleResultColCZL.Modify(false);
            until AccScheduleResultColumn.Next() = 0;
    end;

    local procedure CopyAccScheduleResultValue();
    var
        AccScheduleResultValue: Record "Acc. Schedule Result Value";
        AccScheduleResultValueCZL: Record "Acc. Schedule Result Value CZL";
    begin
        if AccScheduleResultValue.FindSet() then
            repeat
                if not AccScheduleResultValueCZL.Get(AccScheduleResultValue."Result Code", AccScheduleResultValue."Row No.", AccScheduleResultValue."Column No.") then begin
                    AccScheduleResultValueCZL.Init();
                    AccScheduleResultValueCZL."Result Code" := AccScheduleResultValue."Result Code";
                    AccScheduleResultValueCZL."Row No." := AccScheduleResultValue."Row No.";
                    AccScheduleResultValueCZL."Column No." := AccScheduleResultValue."Column No.";
                    AccScheduleResultValueCZL.SystemId := AccScheduleResultValue.SystemId;
                    AccScheduleResultValueCZL.Insert(false, true);
                end;
                AccScheduleResultValueCZL.Value := AccScheduleResultValue.Value;
                AccScheduleResultValueCZL.Modify(false);
            until AccScheduleResultValue.Next() = 0;
    end;

    local procedure CopyAccScheduleResultHeader();
    var
        AccScheduleResultHeader: Record "Acc. Schedule Result Header";
        AccScheduleResultHdrCZL: Record "Acc. Schedule Result Hdr. CZL";
    begin
        if AccScheduleResultHeader.FindSet() then
            repeat
                if not AccScheduleResultHdrCZL.Get(AccScheduleResultHeader."Result Code") then begin
                    AccScheduleResultHdrCZL.Init();
                    AccScheduleResultHdrCZL."Result Code" := AccScheduleResultHeader."Result Code";
                    AccScheduleResultHdrCZL.SystemId := AccScheduleResultHeader.SystemId;
                    AccScheduleResultHdrCZL.Insert(false, true);
                end;
                AccScheduleResultHdrCZL.Description := AccScheduleResultHeader.Description;
                AccScheduleResultHdrCZL."Date Filter" := AccScheduleResultHeader."Date Filter";
                AccScheduleResultHdrCZL."Acc. Schedule Name" := AccScheduleResultHeader."Acc. Schedule Name";
                AccScheduleResultHdrCZL."Column Layout Name" := AccScheduleResultHeader."Column Layout Name";
                AccScheduleResultHdrCZL."Dimension 1 Filter" := AccScheduleResultHeader."Dimension 1 Filter";
                AccScheduleResultHdrCZL."Dimension 2 Filter" := AccScheduleResultHeader."Dimension 2 Filter";
                AccScheduleResultHdrCZL."Dimension 3 Filter" := AccScheduleResultHeader."Dimension 3 Filter";
                AccScheduleResultHdrCZL."Dimension 4 Filter" := AccScheduleResultHeader."Dimension 4 Filter";
                AccScheduleResultHdrCZL."User ID" := AccScheduleResultHeader."User ID";
                AccScheduleResultHdrCZL."Result Date" := AccScheduleResultHeader."Result Date";
                AccScheduleResultHdrCZL."Result Time" := AccScheduleResultHeader."Result Time";
                AccScheduleResultHdrCZL.Modify(false);
            until AccScheduleResultHeader.Next() = 0;
    end;

    local procedure CopyAccScheduleResultHistory();
    var
        AccScheduleResultHistory: Record "Acc. Schedule Result History";
        AccScheduleResultHistCZL: Record "Acc. Schedule Result Hist. CZL";
    begin
        if AccScheduleResultHistory.FindSet() then
            repeat
                if not AccScheduleResultHistCZL.Get(AccScheduleResultHistory."Result Code", AccScheduleResultHistory."Row No.",
                                                    AccScheduleResultHistory."Column No.", AccScheduleResultHistory."Variant No.") then begin
                    AccScheduleResultHistCZL.Init();
                    AccScheduleResultHistCZL."Result Code" := AccScheduleResultHistory."Result Code";
                    AccScheduleResultHistCZL."Row No." := AccScheduleResultHistory."Row No.";
                    AccScheduleResultHistCZL."Column No." := AccScheduleResultHistory."Column No.";
                    AccScheduleResultHistCZL."Variant No." := AccScheduleResultHistory."Variant No.";
                    AccScheduleResultHistCZL.SystemId := AccScheduleResultHistory.SystemId;
                    AccScheduleResultHistCZL.Insert(false, true);
                end;
                AccScheduleResultHistCZL."New Value" := AccScheduleResultHistory."New Value";
                AccScheduleResultHistCZL."Old Value" := AccScheduleResultHistory."Old Value";
                AccScheduleResultHistCZL."User ID" := AccScheduleResultHistory."User ID";
                AccScheduleResultHistCZL."Modified DateTime" := AccScheduleResultHistory."Modified DateTime";
                AccScheduleResultHistCZL.Modify(false);
            until AccScheduleResultHistory.Next() = 0;
    end;

    local procedure CopyGenJournalTemplate();
    var
        GenJournalTemplate: Record "Gen. Journal Template";
    begin
        GenJournalTemplate.SetLoadFields("Not Check Doc. Type");
        GenJournalTemplate.SetRange("Not Check Doc. Type", true);
        if GenJournalTemplate.FindSet() then
            repeat
                GenJournalTemplate."Not Check Doc. Type CZL" := GenJournalTemplate."Not Check Doc. Type";
                GenJournalTemplate.Modify(false);
            until GenJournalTemplate.Next() = 0;
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