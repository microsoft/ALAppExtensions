// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Upgrade;

using Microsoft;
using Microsoft.Bank.Setup;
using Microsoft.CRM.Contact;
using Microsoft.Finance;
using Microsoft.Finance.FinancialReports;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.VAT.Ledger;
using Microsoft.Finance.VAT.Reporting;
using Microsoft.Finance.VAT.Setup;
using Microsoft.FixedAssets.Depreciation;
using Microsoft.Foundation.Company;
using Microsoft.Foundation.Reporting;
using Microsoft.Foundation.Shipping;
using Microsoft.Foundation.UOM;
using Microsoft.Inventory.History;
using Microsoft.Inventory.Intrastat;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Journal;
using Microsoft.Inventory.Ledger;
using Microsoft.Inventory.Setup;
using Microsoft.Inventory.Transfer;
using Microsoft.Projects.Project.Journal;
using Microsoft.Projects.Project.Ledger;
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
using Microsoft.Service.Setup;
using System.Environment.Configuration;
using System.Security.AccessControl;
using System.Security.Encryption;
using System.Security.User;
using System.Upgrade;

#pragma warning disable AL0432,AL0603
codeunit 31017 "Upgrade Application CZL"
{
    Subtype = Upgrade;
    Permissions = tabledata Permission = i,
                  tabledata "Subst. Cust. Posting Group CZL" = i,
                  tabledata "Subst. Vend. Posting Group CZL" = i,
                  tabledata "Certificate Code CZL" = im,
                  tabledata "EET Service Setup CZL" = im,
                  tabledata "EET Business Premises CZL" = im,
                  tabledata "EET Cash Register CZL" = im,
                  tabledata "EET Entry CZL" = im,
                  tabledata "EET Entry Status Log CZL" = im,
                  tabledata "Constant Symbol CZL" = i,
                  tabledata "Specific Movement CZL" = im,
                  tabledata "Intrastat Delivery Group CZL" = im,
                  tabledata "User Setup Line CZL" = im,
                  tabledata "Acc. Schedule Extension CZL" = im,
                  tabledata "Acc. Schedule Result Line CZL" = im,
                  tabledata "Acc. Schedule Result Col. CZL" = im,
                  tabledata "Acc. Schedule Result Value CZL" = im,
                  tabledata "Acc. Schedule Result Hdr. CZL" = im,
                  tabledata "Acc. Schedule Result Hist. CZL" = im,
                  tabledata "General Ledger Setup" = m,
                  tabledata "Sales & Receivables Setup" = m,
                  tabledata "Purchases & Payables Setup" = m,
                  tabledata "Service Mgt. Setup" = m,
                  tabledata "Inventory Setup" = m,
                  tabledata "Depreciation Book" = m,
                  tabledata "Item Journal Line" = m,
                  tabledata "Job Journal Line" = m,
                  tabledata "Sales Line" = m,
                  tabledata "Purchase Line" = m,
                  tabledata "Service Line" = m,
                  tabledata "Value Entry" = m,
                  tabledata "Detailed Cust. Ledg. Entry" = m,
                  tabledata "Detailed Vendor Ledg. Entry" = m,
                  tabledata "Isolated Certificate" = m,
                  tabledata "EET Service Setup" = m,
                  tabledata "Shipment Method" = m,
                  tabledata "Tariff Number" = m,
                  tabledata "Statistic Indication CZL" = m,
                  tabledata "Statutory Reporting Setup CZL" = m,
                  tabledata Customer = m,
                  tabledata Vendor = m,
                  tabledata Item = m,
                  tabledata "Unit of Measure" = m,
                  tabledata "VAT Posting Setup" = m,
                  tabledata "Sales Header" = m,
                  tabledata "Sales Shipment Header" = m,
                  tabledata "Sales Invoice Header" = m,
                  tabledata "Sales Invoice Line" = m,
                  tabledata "Sales Cr.Memo Header" = m,
                  tabledata "Sales Cr.Memo Line" = m,
                  tabledata "Sales Header Archive" = m,
                  tabledata "Sales Line Archive" = m,
                  tabledata "Purchase Header" = m,
                  tabledata "Purch. Rcpt. Header" = m,
                  tabledata "Purch. Rcpt. Line" = m,
                  tabledata "Purch. Inv. Header" = m,
                  tabledata "Purch. Inv. Line" = m,
                  tabledata "Purch. Cr. Memo Hdr." = m,
                  tabledata "Purch. Cr. Memo Line" = m,
                  tabledata "Purchase Header Archive" = m,
                  tabledata "Purchase Line Archive" = m,
                  tabledata "Service Header" = m,
                  tabledata "Service Shipment Header" = m,
                  tabledata "Service Invoice Header" = m,
                  tabledata "Service Invoice Line" = m,
                  tabledata "Service Cr.Memo Header" = m,
                  tabledata "Service Cr.Memo Line" = m,
                  tabledata "Return Shipment Header" = m,
                  tabledata "Return Receipt Header" = m,
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
                  tabledata "User Setup" = m,
                  tabledata "Gen. Journal Template" = m,
                  tabledata "VAT Entry" = m,
                  tabledata "Report Selections" = m,
                  tabledata "G/L Entry" = m;

    var
        DataUpgradeMgt: Codeunit "Data Upgrade Mgt.";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeTagDefinitionsCZL: Codeunit "Upgrade Tag Definitions CZL";
        InstallApplicationsMgtCZL: Codeunit "Install Applications Mgt. CZL";
        InstallApplicationCZL: Codeunit "Install Application CZL";
        AppInfo: ModuleInfo;

    trigger OnUpgradePerDatabase()
    begin
        DataUpgradeMgt.SetUpgradeInProgress();
        UpgradePermission();
        SetDatabaseUpgradeTags();
    end;

    trigger OnUpgradePerCompany()
    begin
        DataUpgradeMgt.SetUpgradeInProgress();
        BindSubscription(InstallApplicationsMgtCZL);
        UpgradeData();
        UnbindSubscription(InstallApplicationsMgtCZL);
        SetCompanyUpgradeTags();
    end;

    local procedure UpgradeData()
    begin
        UpgradeGeneralLedgerSetup();
        UpgradeSalesSetup();
        UpgradePurchaseSetup();
        UpgradeServiceSetup();
        UpgradeInventorySetup();
        UpgradeDepreciationBook();
        UpgradeItemJournalLine();
        UpgradeJobJournalLine();
        UpgradeSalesLine();
        UpgradePurchaseLine();
        UpgradeServiceLine();
        UpgradeValueEntry();
        UpgradeDetailedCustLedgEntry();
        UpgradeDetailedVendorLedgEntry();
        UpgradeSubstCustomerPostingGroup();
        UpgradeSubstVendorPostingGroup();
        UpgradeCertificateCZCode();
        UpgradeIsolatedCertificate();
        UpgradeEETServiceSetup();
        UpgradeEETBusinessPremises();
        UpgradeEETCashRegister();
        UpgradeEETEntry();
        UpgradeEETEntryStatus();
        UpgradeConstantSymbol();
        UpgradeShipmentMethod();
        UpgradeTariffNumber();
        UpgradeStatisticIndication();
        UpgradeSpecificMovement();
        UpgradeIntrastatDeliveryGroup();
        UpgradeStatutoryReportingSetup();
        UpgradeCustomer();
        UpgradeVendor();
        UpgradeItem();
        UpgradeUnitofMeasure();
        UpgradeVATPostingSetup();
        UpgradeSalesHeader();
        UpgradeSalesShipmentHeader();
        UpgradeSalesInvoiceHeader();
        UpgradeSalesInvoiceLine();
        UpgradeSalesCrMemoLine();
        UpgradeSalesCrMemoLine();
        UpgradeSalesCrMemoHeader();
        UpgradeSalesHeaderArchive();
        UpgradeSalesLineArchive();
        UpgradePurchaseHeader();
        UpgradePurchRcptHeader();
        UpgradePurchRcptLine();
        UpgradePurchInvHeader();
        UpgradePurchInvLine();
        UpgradePurchCrMemoHdr();
        UpgradePurchCrMemoLine();
        UpgradePurchaseHeaderArchive();
        UpgradePurchaseLineArchive();
        UpgradeServiceHeader();
        UpgradeServiceShipmentHeader();
        UpgradeServiceInvoiceHeader();
        UpgradeServiceInvoiceLine();
        UpgradeServiceCrMemoHeader();
        UpgradeServiceCrMemoLine();
        UpgradeReturnShipmentHeader();
        UpgradeReturnReceiptHeader();
        UpgradeTransferHeader();
        UpgradeTransferLine();
        UpgradeTransferReceiptHeader();
        UpgradeTransferShipmentHeader();
        UpgradeItemLedgerEntry();
        UpgradeJobLedgerEntry();
        UpgradeItemCharge();
        UpgradeItemChargeAssignmentPurch();
        UpgradeItemChargeAssignmentSales();
        UpgradePostedGenJournalLine();
        UpgradeIntrastatJournalBatch();
        UpgradeIntrastatJournalLine();
        UpgradeGeneralPostingSetup();
        UpgradeInventoryPostingSetup();
        UpgradeUserSetup();
        UpgradeUserSetupLine();
        UpgradeAccScheduleLine();
        UpgradeAccScheduleExtension();
        UpgradeAccScheduleResultLine();
        UpgradeAccScheduleResultColumn();
        UpgradeAccScheduleResultValue();
        UpgradeAccScheduleResultHeader();
        UpgradeAccScheduleResultHistory();
        UpgradeGenJournalTemplate();
        UpgradeVATEntry();
        UpgradeCustLedgerEntry();
        UpgradeVendLedgerEntry();
        UpgradeGenJournalLine();
        UpgradeReminderHeader();
        UpgradeIssuedReminderHeader();
        UpgradeFinanceChargeMemoHeader();
        UpgradeIssuedFinanceChargeMemoHeader();
        UpgradeReportSelections();
        UpgradeReplaceVATDateCZL();
        UpgradeReplaceAllowAlterPostingGroups();
        UpgradeUseW1RegistrationNumber();
        UpgradeReportSelectionDirectTransfer();
        UpgradeEU3PartyTradePurchase();
        UpgradeStatutoryReportingSetupCity();
        UpgradeSubstCustVendPostingGroup();
        UpgradeVATStatementTemplate();
        UpgradeAllowVATPosting();
        UpgradeOriginalVATAmountsInVATEntries();
        UpgradeFunctionalCurrency();
        UpgradeEnableNonDeductibleVATCZ();
    end;

    local procedure UpgradeGeneralLedgerSetup();
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion183PerCompanyUpgradeTag()) and
           UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag())
        then
            exit;

        if GeneralLedgerSetup.Get() then begin
            if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion183PerCompanyUpgradeTag()) then begin
                GeneralLedgerSetup."Shared Account Schedule CZL" := GeneralLedgerSetup."Shared Account Schedule";
                GeneralLedgerSetup."Acc. Schedule Results Nos. CZL" := GeneralLedgerSetup."Acc. Schedule Results Nos.";
            end;
            if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then begin
                GeneralLedgerSetup."Check Posting Debit/Credit CZL" := GeneralLedgerSetup."Check Posting Debit/Credit";
                GeneralLedgerSetup."Mark Neg. Qty as Correct. CZL" := GeneralLedgerSetup."Mark Neg. Qty as Correction";
                GeneralLedgerSetup."Rounding Date CZL" := GeneralLedgerSetup."Rounding Date";
                GeneralLedgerSetup."Closed Per. Entry Pos.Date CZL" := GeneralLedgerSetup."Closed Period Entry Pos.Date";
                GeneralLedgerSetup."User Checks Allowed CZL" := GeneralLedgerSetup."User Checks Allowed";
            end;
            GeneralLedgerSetup.Modify(false);
        end;
    end;

    local procedure UpgradeSalesSetup();
    var
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            if SalesReceivablesSetup.Get() then begin
                SalesReceivablesSetup."Allow Alter Posting Groups CZL" := SalesReceivablesSetup."Allow Alter Posting Groups";
                SalesReceivablesSetup.Modify(false);
            end;
    end;

    local procedure UpgradePurchaseSetup();
    var
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        if PurchasesPayablesSetup.Get() then begin
            PurchasesPayablesSetup."Allow Alter Posting Groups CZL" := PurchasesPayablesSetup."Allow Alter Posting Groups";
            PurchasesPayablesSetup.Modify(false);
        end;
    end;

    local procedure UpgradeServiceSetup();
    var
        ServiceMgtSetup: Record "Service Mgt. Setup";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        if ServiceMgtSetup.Get() then begin
            ServiceMgtSetup."Allow Alter Posting Groups CZL" := ServiceMgtSetup."Allow Alter Cust. Post. Groups";
            ServiceMgtSetup.Modify(false);
        end;
    end;

    local procedure UpgradeInventorySetup();
    var
        InventorySetup: Record "Inventory Setup";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        InventorySetup.SetLoadFields("Date Order Inventory Change", "Post Neg. Transfers as Corr.", "Post Exp. Cost Conv. as Corr.");
        if InventorySetup.Get() then begin
            InventorySetup."Date Order Invt. Change CZL" := InventorySetup."Date Order Inventory Change";
            InventorySetup."Post Neg.Transf. As Corr.CZL" := InventorySetup."Post Neg. Transfers as Corr.";
            InventorySetup."Post Exp.Cost Conv.As Corr.CZL" := InventorySetup."Post Exp. Cost Conv. as Corr.";
            InventorySetup.Modify(false);
        end;
    end;

    local procedure UpgradeDepreciationBook();
    var
        DepreciationBook: Record "Depreciation Book";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        DepreciationBook.SetLoadFields("Mark Reclass. as Corrections");
        if DepreciationBook.FindSet(true) then
            repeat
                DepreciationBook."Mark Reclass. as Correct. CZL" := DepreciationBook."Mark Reclass. as Corrections";
                DepreciationBook.Modify(false);
            until DepreciationBook.Next() = 0;
    end;

    local procedure UpgradeItemJournalLine();
    var
        ItemJournalLine: Record "Item Journal Line";
        ItemJournalLineDataTransfer: DataTransfer;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        ItemJournalLineDataTransfer.SetTables(Database::"Item Journal Line", Database::"Item Journal Line");
        ItemJournalLineDataTransfer.AddFieldValue(ItemJournalLine.FieldNo("Tariff No."), ItemJournalLine.FieldNo("Tariff No. CZL"));
        ItemJournalLineDataTransfer.AddFieldValue(ItemJournalLine.FieldNo("Physical Transfer"), ItemJournalLine.FieldNo("Physical Transfer CZL"));
        ItemJournalLineDataTransfer.AddFieldValue(ItemJournalLine.FieldNo("Incl. in Intrastat Amount"), ItemJournalLine.FieldNo("Incl. in Intrastat Amount CZL"));
        ItemJournalLineDataTransfer.AddFieldValue(ItemJournalLine.FieldNo("Incl. in Intrastat Stat. Value"), ItemJournalLine.FieldNo("Incl. in Intrastat S.Value CZL"));
        ItemJournalLineDataTransfer.AddFieldValue(ItemJournalLine.FieldNo("Net Weight"), ItemJournalLine.FieldNo("Net Weight CZL"));
        ItemJournalLineDataTransfer.AddFieldValue(ItemJournalLine.FieldNo("Country/Region of Origin Code"), ItemJournalLine.FieldNo("Country/Reg. of Orig. Code CZL"));
        ItemJournalLineDataTransfer.AddFieldValue(ItemJournalLine.FieldNo("Statistic Indication"), ItemJournalLine.FieldNo("Statistic Indication CZL"));
        ItemJournalLineDataTransfer.AddFieldValue(ItemJournalLine.FieldNo("Intrastat Transaction"), ItemJournalLine.FieldNo("Intrastat Transaction CZL"));
        ItemJournalLineDataTransfer.AddFieldValue(ItemJournalLine.FieldNo("G/L Correction"), ItemJournalLine.FieldNo("G/L Correction CZL"));
        ItemJournalLineDataTransfer.CopyFields();
    end;

    local procedure UpgradeJobJournalLine();
    var
        JobJournalLine: Record "Job Journal Line";
        JobJournalLineDataTransfer: DataTransfer;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        JobJournalLineDataTransfer.SetTables(Database::"Job Journal Line", Database::"Job Journal Line");
        JobJournalLineDataTransfer.AddFieldValue(JobJournalLine.FieldNo("Correction"), JobJournalLine.FieldNo("Correction CZL"));
        JobJournalLineDataTransfer.AddFieldValue(JobJournalLine.FieldNo("Tariff No."), JobJournalLine.FieldNo("Tariff No. CZL"));
        JobJournalLineDataTransfer.AddFieldValue(JobJournalLine.FieldNo("Net Weight"), JobJournalLine.FieldNo("Net Weight CZL"));
        JobJournalLineDataTransfer.AddFieldValue(JobJournalLine.FieldNo("Country/Region of Origin Code"), JobJournalLine.FieldNo("Country/Reg. of Orig. Code CZL"));
        JobJournalLineDataTransfer.AddFieldValue(JobJournalLine.FieldNo("Statistic Indication"), JobJournalLine.FieldNo("Statistic Indication CZL"));
        JobJournalLineDataTransfer.AddFieldValue(JobJournalLine.FieldNo("Intrastat Transaction"), JobJournalLine.FieldNo("Intrastat Transaction CZL"));
        JobJournalLineDataTransfer.CopyFields();
    end;

    local procedure UpgradeSalesLine();
    var
        SalesLine: Record "Sales Line";
        SalesLineDataTransfer: DataTransfer;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        SalesLineDataTransfer.SetTables(Database::"Sales Line", Database::"Sales Line");
        SalesLineDataTransfer.AddFieldValue(SalesLine.FieldNo("Negative"), SalesLine.FieldNo("Negative CZL"));
        SalesLineDataTransfer.AddFieldValue(SalesLine.FieldNo("Physical Transfer"), SalesLine.FieldNo("Physical Transfer CZL"));
        SalesLineDataTransfer.AddFieldValue(SalesLine.FieldNo("Country/Region of Origin Code"), SalesLine.FieldNo("Country/Reg. of Orig. Code CZL"));
        SalesLineDataTransfer.CopyFields();
    end;

    local procedure UpgradePurchaseLine();
    var
        PurchaseLine: Record "Purchase Line";
        PurchaseLineDataTransfer: DataTransfer;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) and
           UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion200PerCompanyUpgradeTag())
        then
            exit;

        PurchaseLineDataTransfer.SetTables(Database::"Purchase Line", Database::"Purchase Line");
        if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then begin
            PurchaseLineDataTransfer.AddFieldValue(PurchaseLine.FieldNo("Negative"), PurchaseLine.FieldNo("Negative CZL"));
            PurchaseLineDataTransfer.AddFieldValue(PurchaseLine.FieldNo("Physical Transfer"), PurchaseLine.FieldNo("Physical Transfer CZL"));
            PurchaseLineDataTransfer.AddFieldValue(PurchaseLine.FieldNo("Country/Region of Origin Code"), PurchaseLine.FieldNo("Country/Reg. of Orig. Code CZL"));
        end;
        if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion200PerCompanyUpgradeTag()) then begin
            PurchaseLineDataTransfer.AddFieldValue(PurchaseLine.FieldNo("Ext. Amount (LCY)"), PurchaseLine.FieldNo("Ext. Amount CZL"));
            PurchaseLineDataTransfer.AddFieldValue(PurchaseLine.FieldNo("Ext.Amount Including VAT (LCY)"), PurchaseLine.FieldNo("Ext. Amount Incl. VAT CZL"));
        end;
        PurchaseLineDataTransfer.CopyFields();
    end;

    local procedure UpgradeServiceLine();
    var
        ServiceLine: Record "Service Line";
        ServiceLineDataTransfer: DataTransfer;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        ServiceLineDataTransfer.SetTables(Database::"Service Line", Database::"Service Line");
        ServiceLineDataTransfer.AddFieldValue(ServiceLine.FieldNo("Negative"), ServiceLine.FieldNo("Negative CZL"));
        ServiceLineDataTransfer.AddFieldValue(ServiceLine.FieldNo("Physical Transfer"), ServiceLine.FieldNo("Physical Transfer CZL"));
        ServiceLineDataTransfer.AddFieldValue(ServiceLine.FieldNo("Country/Region of Origin Code"), ServiceLine.FieldNo("Country/Reg. of Orig. Code CZL"));
        ServiceLineDataTransfer.CopyFields();
    end;

    local procedure UpgradeValueEntry();
    var
        ValueEntry: Record "Value Entry";
        ValueEntryDataTransfer: DataTransfer;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        ValueEntryDataTransfer.SetTables(Database::"Value Entry", Database::"Value Entry");
        ValueEntryDataTransfer.AddFieldValue(ValueEntry.FieldNo("G/L Correction"), ValueEntry.FieldNo("G/L Correction CZL"));
        ValueEntryDataTransfer.AddFieldValue(ValueEntry.FieldNo("Incl. in Intrastat Amount"), ValueEntry.FieldNo("Incl. in Intrastat Amount CZL"));
        ValueEntryDataTransfer.AddFieldValue(ValueEntry.FieldNo("Incl. in Intrastat Stat. Value"), ValueEntry.FieldNo("Incl. in Intrastat S.Value CZL"));
        ValueEntryDataTransfer.CopyFields();
    end;

    local procedure UpgradeDetailedCustLedgEntry()
    var
        DetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry";
        ApplTransactionDictionary: Dictionary of [Integer, Boolean];
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        DetailedCustLedgEntry.SetLoadFields("Entry No.", "Customer Posting Group", "Entry Type", "Transaction No.");
        if DetailedCustLedgEntry.FindSet(true) then
            repeat
                DetailedCustLedgEntry."Customer Posting Group CZL" := DetailedCustLedgEntry."Customer Posting Group";
                if DetailedCustLedgEntry."Entry Type" = DetailedCustLedgEntry."Entry Type"::Application then
                    DetailedCustLedgEntry."Appl. Across Post. Groups CZL" :=
                        InstallApplicationCZL.IsCustomerApplAcrossPostGrpTransaction(DetailedCustLedgEntry."Transaction No.", ApplTransactionDictionary);
                DetailedCustLedgEntry.Modify(false);
            until DetailedCustLedgEntry.Next() = 0;
    end;

    local procedure UpgradeDetailedVendorLedgEntry()
    var
        DetailedVendorLedgEntry: Record "Detailed Vendor Ledg. Entry";
        ApplTransactionDictionary: Dictionary of [Integer, Boolean];
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        if DetailedVendorLedgEntry.FindSet(true) then
            repeat
                DetailedVendorLedgEntry."Vendor Posting Group CZL" := DetailedVendorLedgEntry."Vendor Posting Group";
                if DetailedVendorLedgEntry."Entry Type" = DetailedVendorLedgEntry."Entry Type"::Application then
                    DetailedVendorLedgEntry."Appl. Across Post. Groups CZL" :=
                        InstallApplicationCZL.IsVendorApplAcrossPostGrpTransaction(DetailedVendorLedgEntry."Transaction No.", ApplTransactionDictionary);
                DetailedVendorLedgEntry.Modify(false);
            until DetailedVendorLedgEntry.Next() = 0;
    end;

    local procedure UpgradeSubstCustomerPostingGroup();
    var
        SubstCustomerPostingGroup: Record "Subst. Customer Posting Group";
        SubstCustPostingGroupCZL: Record "Subst. Cust. Posting Group CZL";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        if SubstCustomerPostingGroup.FindSet() then
            repeat
                if not SubstCustPostingGroupCZL.Get(SubstCustomerPostingGroup."Parent Cust. Posting Group", SubstCustomerPostingGroup."Customer Posting Group") then begin
                    SubstCustPostingGroupCZL.Init();
                    SubstCustPostingGroupCZL."Parent Customer Posting Group" := SubstCustomerPostingGroup."Parent Cust. Posting Group";
                    SubstCustPostingGroupCZL."Customer Posting Group" := SubstCustomerPostingGroup."Customer Posting Group";
                    SubstCustPostingGroupCZL.SystemId := SubstCustomerPostingGroup.SystemId;
                    SubstCustPostingGroupCZL.Insert(false, true);
                end;
            until SubstCustomerPostingGroup.Next() = 0;
    end;

    local procedure UpgradeSubstVendorPostingGroup();
    var
        SubstVendorPostingGroup: Record "Subst. Vendor Posting Group";
        SubstVendPostingGroupCZL: Record "Subst. Vend. Posting Group CZL";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        if SubstVendorPostingGroup.FindSet() then
            repeat
                if not SubstVendPostingGroupCZL.Get(SubstVendorPostingGroup."Parent Vend. Posting Group", SubstVendorPostingGroup."Vendor Posting Group") then begin
                    SubstVendPostingGroupCZL.Init();
                    SubstVendPostingGroupCZL."Parent Vendor Posting Group" := SubstVendorPostingGroup."Parent Vend. Posting Group";
                    SubstVendPostingGroupCZL."Vendor Posting Group" := SubstVendorPostingGroup."Vendor Posting Group";
                    SubstVendPostingGroupCZL.SystemId := SubstVendorPostingGroup.SystemId;
                    SubstVendPostingGroupCZL.Insert(false, true);
                end;
            until SubstVendorPostingGroup.Next() = 0;
    end;

    local procedure UpgradeCertificateCZCode()
    var
        CertificateCZCode: Record "Certificate CZ Code";
        CertificateCodeCZL: Record "Certificate Code CZL";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion174PerCompanyUpgradeTag()) then
            exit;

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

    local procedure UpgradeIsolatedCertificate()
    var
        IsolatedCertificate: Record "Isolated Certificate";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion174PerCompanyUpgradeTag()) then
            exit;

        IsolatedCertificate.SetLoadFields("Certificate Code");
        if IsolatedCertificate.FindSet() then
            repeat
                IsolatedCertificate."Certificate Code CZL" := IsolatedCertificate."Certificate Code";
                IsolatedCertificate.Modify(false);
            until IsolatedCertificate.Next() = 0;
    end;

    local procedure UpgradeEETServiceSetup()
    var
        EETServiceSetup: Record "EET Service Setup";
        EETServiceSetupCZL: Record "EET Service Setup CZL";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion174PerCompanyUpgradeTag()) then
            exit;

        if EETServiceSetup.Get() then begin
            if not EETServiceSetupCZL.Get() then begin
                EETServiceSetupCZL.Init();
                EETServiceSetupCZL.SystemId := EETServiceSetup.SystemId;
                EETServiceSetupCZL.Insert(false, true);
            end;
            EETServiceSetupCZL."Service URL" := EETServiceSetup."Service URL";
            EETServiceSetupCZL."Sales Regime" := "EET Sales Regime CZL".FromInteger(EETServiceSetup."Sales Regime");
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

    local procedure UpgradeEETBusinessPremises()
    var
        EETBusinessPremises: Record "EET Business Premises";
        EETBusinessPremisesCZL: Record "EET Business Premises CZL";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion174PerCompanyUpgradeTag()) then
            exit;

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

    local procedure UpgradeEETCashRegister()
    var
        EETCashRegister: Record "EET Cash Register";
        EETCashRegisterCZL: Record "EET Cash Register CZL";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion174PerCompanyUpgradeTag()) then
            exit;

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

    local procedure UpgradeEETEntry()
    var
        EETEntry: Record "EET Entry";
        EETEntryCZL: Record "EET Entry CZL";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion174PerCompanyUpgradeTag()) then
            exit;

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
                EETEntryCZL."Applied Document Type" := "EET Applied Document Type CZL".FromInteger(EETEntry."Applied Document Type");
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

    local procedure UpgradeEETEntryStatus()
    var
        EETEntryStatus: Record "EET Entry Status";
        EETEntryStatusLogCZL: Record "EET Entry Status Log CZL";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion174PerCompanyUpgradeTag()) then
            exit;

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

    local procedure UpgradeConstantSymbol();
    var
        ConstantSymbol: Record "Constant Symbol";
        ConstantSymbolCZL: Record "Constant Symbol CZL";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        if ConstantSymbol.FindSet() then
            repeat
                if not ConstantSymbolCZL.Get(ConstantSymbol.Code) then begin
                    ConstantSymbolCZL.Init();
                    ConstantSymbolCZL.Code := ConstantSymbol.Code;
                    ConstantSymbolCZL.Description := ConstantSymbol.Description;
                    ConstantSymbolCZL.SystemId := ConstantSymbol.SystemId;
                    ConstantSymbolCZL.Insert(false, true);
                end;
            until ConstantSymbol.Next() = 0;
    end;

    local procedure UpgradeShipmentMethod()
    var
        ShipmentMethod: Record "Shipment Method";
        ShipmentMethodDataTransfer: DataTransfer;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        ShipmentMethodDataTransfer.SetTables(Database::"Shipment Method", Database::"Shipment Method");
        ShipmentMethodDataTransfer.AddFieldValue(ShipmentMethod.FieldNo("Include Item Charges (Amount)"), ShipmentMethod.FieldNo("Incl. Item Charges (Amt.) CZL"));
        ShipmentMethodDataTransfer.AddFieldValue(ShipmentMethod.FieldNo("Intrastat Delivery Group Code"), ShipmentMethod.FieldNo("Intrastat Deliv. Grp. Code CZL"));
        ShipmentMethodDataTransfer.AddFieldValue(ShipmentMethod.FieldNo("Incl. Item Charges (Stat.Val.)"), ShipmentMethod.FieldNo("Incl. Item Charges (S.Val) CZL"));
        ShipmentMethodDataTransfer.AddFieldValue(ShipmentMethod.FieldNo("Adjustment %"), ShipmentMethod.FieldNo("Adjustment % CZL"));
        ShipmentMethodDataTransfer.CopyFields();
    end;

    local procedure UpgradeTariffNumber()
    var
        UnitOfMeasure: Record "Unit of Measure";
        TariffNumber: Record "Tariff Number";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        TariffNumber.SetLoadFields("Full Name ENG", "Description EN CZL", "Supplem. Unit of Measure Code", "Supplem. Unit of Measure Code");
        if TariffNumber.FindSet() then
            repeat
                TariffNumber."Description EN CZL" := CopyStr(TariffNumber."Full Name ENG", 1, MaxStrLen(TariffNumber."Description EN CZL"));
                TariffNumber."Suppl. Unit of Meas. Code CZL" := TariffNumber."Supplem. Unit of Measure Code";
                TariffNumber."Supplementary Units" := UnitOfMeasure.Get(TariffNumber."Supplem. Unit of Measure Code");
                TariffNumber.Modify(false);
            until TariffNumber.Next() = 0;
    end;

    local procedure UpgradeStatisticIndication()
    var
        StatisticIndication: Record "Statistic Indication";
        StatisticIndicationCZL: Record "Statistic Indication CZL";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        StatisticIndication.SetLoadFields(Code, "Full Name ENG");
        if StatisticIndication.FindSet() then
            repeat
                if StatisticIndicationCZL.Get(StatisticIndication.Code) then begin
                    StatisticIndicationCZL."Description EN" := CopyStr(StatisticIndication."Full Name ENG", 1, MaxStrLen(StatisticIndicationCZL."Description EN"));
                    StatisticIndicationCZL.Modify(false);
                end;
            until StatisticIndication.Next() = 0;
    end;

    local procedure UpgradeSpecificMovement()
    var
        SpecificMovement: Record "Specific Movement";
        SpecificMovementCZL: Record "Specific Movement CZL";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        if SpecificMovement.FindSet() then
            repeat
                if not SpecificMovementCZL.Get(SpecificMovement.Code) then begin
                    SpecificMovementCZL.Init();
                    SpecificMovementCZL.Code := SpecificMovement.Code;
                    SpecificMOvementCZL.SystemId := SpecificMovement.SystemId;
                    SpecificMovementCZL.Insert(false, true);
                end;
                SpecificMovementCZL.Description := SpecificMovement.Description;
                SpecificMovementCZL.Modify(false);
            until SpecificMovement.Next() = 0;
    end;

    local procedure UpgradeIntrastatDeliveryGroup()
    var
        IntrastatDeliveryGroup: Record "Intrastat Delivery Group";
        IntrastatDeliveryGroupCZL: Record "Intrastat Delivery Group CZL";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

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

    local procedure UpgradeStatutoryReportingSetup();
    var
        StatReportingSetup: Record "Stat. Reporting Setup";
        StatutoryReportingSetupCZL: Record "Statutory Reporting Setup CZL";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;
        if not StatReportingSetup.Get() then
            exit;
        if not StatutoryReportingSetupCZL.Get() then
            exit;
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

    local procedure UpgradeCustomer();
    var
        Customer: Record Customer;
        CustomerDataTransfer: DataTransfer;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        CustomerDataTransfer.SetTables(Database::Customer, Database::Customer);
        CustomerDataTransfer.AddFieldValue(Customer.FieldNo("Transaction Type"), Customer.FieldNo("Transaction Type CZL"));
        CustomerDataTransfer.AddFieldValue(Customer.FieldNo("Transaction Specification"), Customer.FieldNo("Transaction Specification CZL"));
        CustomerDataTransfer.AddFieldValue(Customer.FieldNo("Transport Method"), Customer.FieldNo("Transport Method CZL"));
        CustomerDataTransfer.CopyFields();
    end;

    local procedure UpgradeVendor();
    var
        Vendor: Record Vendor;
        VendorDataTransfer: DataTransfer;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        VendorDataTransfer.SetTables(Database::Vendor, Database::Vendor);
        VendorDataTransfer.AddFieldValue(Vendor.FieldNo("Transaction Type"), Vendor.FieldNo("Transaction Type CZL"));
        VendorDataTransfer.AddFieldValue(Vendor.FieldNo("Transaction Specification"), Vendor.FieldNo("Transaction Specification CZL"));
        VendorDataTransfer.AddFieldValue(Vendor.FieldNo("Transport Method"), Vendor.FieldNo("Transport Method CZL"));
        VendorDataTransfer.CopyFields();
    end;

    local procedure UpgradeItem();
    var
        Item: Record Item;
        ItemDataTransfer: DataTransfer;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        ItemDataTransfer.SetTables(Database::Item, Database::Item);
        ItemDataTransfer.AddFieldValue(Item.FieldNo("Specific Movement"), Item.FieldNo("Specific Movement CZL"));
        ItemDataTransfer.CopyFields();
    end;

    local procedure UpgradeUnitofMeasure();
    var
        UnitofMeasure: Record "Unit of Measure";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        UnitofMeasure.SetLoadFields("Tariff Number UOM Code");
        if UnitofMeasure.FindSet(true) then
            repeat
                UnitofMeasure."Tariff Number UOM Code CZL" := CopyStr(UnitofMeasure."Tariff Number UOM Code", 1, 10);
                UnitofMeasure.Modify(false);
            until UnitofMeasure.Next() = 0;
    end;

    local procedure UpgradeVATPostingSetup();
    var
        VATPostingSetup: Record "VAT Posting Setup";
        VATPostingSetupDataTransfer: DataTransfer;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        VATPostingSetupDataTransfer.SetTables(Database::"VAT Posting Setup", Database::"VAT Posting Setup");
        VATPostingSetupDataTransfer.AddFieldValue(VATPostingSetup.FieldNo("Intrastat Service"), VATPostingSetup.FieldNo("Intrastat Service CZL"));
        VATPostingSetupDataTransfer.CopyFields();
    end;

    local procedure UpgradeSalesHeader();
    var
        SalesHeader: Record "Sales Header";
        SalesHeaderDataTransfer: DataTransfer;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) and
           UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion189PerCompanyUpgradeTag())
        then
            exit;

        SalesHeaderDataTransfer.SetTables(Database::"Sales Header", Database::"Sales Header");
        if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion189PerCompanyUpgradeTag()) then begin
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
        end;
        if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then begin
            SalesHeaderDataTransfer.AddFieldValue(SalesHeader.FieldNo("Physical Transfer"), SalesHeader.FieldNo("Physical Transfer CZL"));
            SalesHeaderDataTransfer.AddFieldValue(SalesHeader.FieldNo("Intrastat Exclude"), SalesHeader.FieldNo("Intrastat Exclude CZL"));
        end;
        SalesHeaderDataTransfer.CopyFields();
    end;

    local procedure UpgradeSalesShipmentHeader();
    var
        SalesShipmentHeader: Record "Sales Shipment Header";
        SalesShipmentHeaderDataTransfer: DataTransfer;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        SalesShipmentHeaderDataTransfer.SetTables(Database::"Sales Shipment Header", Database::"Sales Shipment Header");
        SalesShipmentHeaderDataTransfer.AddFieldValue(SalesShipmentHeader.FieldNo("Physical Transfer"), SalesShipmentHeader.FieldNo("Physical Transfer CZL"));
        SalesShipmentHeaderDataTransfer.AddFieldValue(SalesShipmentHeader.FieldNo("Intrastat Exclude"), SalesShipmentHeader.FieldNo("Intrastat Exclude CZL"));
        SalesShipmentHeaderDataTransfer.CopyFields();
    end;

    local procedure UpgradeSalesInvoiceHeader();
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesInvoiceHeaderDataTransfer: DataTransfer;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) and
           UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion189PerCompanyUpgradeTag())
        then
            exit;

        SalesInvoiceHeaderDataTransfer.SetTables(Database::"Sales Invoice Header", Database::"Sales Invoice Header");
        if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion189PerCompanyUpgradeTag()) then begin
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
        end;
        if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then begin
            SalesInvoiceHeaderDataTransfer.AddFieldValue(SalesInvoiceHeader.FieldNo("Physical Transfer"), SalesInvoiceHeader.FieldNo("Physical Transfer CZL"));
            SalesInvoiceHeaderDataTransfer.AddFieldValue(SalesInvoiceHeader.FieldNo("Intrastat Exclude"), SalesInvoiceHeader.FieldNo("Intrastat Exclude CZL"));
        end;
        SalesInvoiceHeaderDataTransfer.CopyFields();
    end;

    local procedure UpgradeSalesInvoiceLine();
    var
        SalesInvoiceLine: Record "Sales Invoice Line";
        SalesInvoicelineDataTransfer: DataTransfer;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        SalesInvoicelineDataTransfer.SetTables(Database::"Sales Invoice Line", Database::"Sales Invoice Line");
        SalesInvoicelineDataTransfer.AddFieldValue(SalesInvoiceLine.FieldNo("Country/Region of Origin Code"), SalesInvoiceLine.FieldNo("Country/Reg. of Orig. Code CZL"));
        SalesInvoicelineDataTransfer.CopyFields();
    end;

    local procedure UpgradeSalesCrMemoHeader();
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesCrMemoHeaderDataTransfer: DataTransfer;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) and
           UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion189PerCompanyUpgradeTag())
        then
            exit;

        SalesCrMemoHeaderDataTransfer.SetTables(Database::"Sales Cr.Memo Header", Database::"Sales Cr.Memo Header");
        if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion189PerCompanyUpgradeTag()) then begin
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
        end;
        if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then begin
            SalesCrMemoHeaderDataTransfer.AddFieldValue(SalesCrMemoHeader.FieldNo("Physical Transfer"), SalesCrMemoHeader.FieldNo("Physical Transfer CZL"));
            SalesCrMemoHeaderDataTransfer.AddFieldValue(SalesCrMemoHeader.FieldNo("Intrastat Exclude"), SalesCrMemoHeader.FieldNo("Intrastat Exclude CZL"));
        end;
        SalesCrMemoHeaderDataTransfer.CopyFields();
    end;

    local procedure UpgradeSalesCrMemoLine();
    var
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        SalesCrMemoLineDataTransfer: DataTransfer;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        SalesCrMemoLineDataTransfer.SetTables(Database::"Sales Cr.Memo Line", Database::"Sales Cr.Memo Line");
        SalesCrMemoLineDataTransfer.AddFieldValue(SalesCrMemoLine.FieldNo("Country/Region of Origin Code"), SalesCrMemoLine.FieldNo("Country/Reg. of Orig. Code CZL"));
        SalesCrMemoLineDataTransfer.CopyFields();
    end;

    local procedure UpgradeSalesHeaderArchive();
    var
        SalesHeaderArchive: Record "Sales Header Archive";
        SalesHeaderArchiveDataTransfer: DataTransfer;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) and
           UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion189PerCompanyUpgradeTag())
        then
            exit;

        SalesHeaderArchiveDataTransfer.SetTables(Database::"Sales Header Archive", Database::"Sales Header Archive");
        if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion189PerCompanyUpgradeTag()) then begin
            SalesHeaderArchiveDataTransfer.AddFieldValue(SalesHeaderArchive.FieldNo("Specific Symbol"), SalesHeaderArchive.FieldNo("Specific Symbol CZL"));
            SalesHeaderArchiveDataTransfer.AddFieldValue(SalesHeaderArchive.FieldNo("Variable Symbol"), SalesHeaderArchive.FieldNo("Variable Symbol CZL"));
            SalesHeaderArchiveDataTransfer.AddFieldValue(SalesHeaderArchive.FieldNo("Constant Symbol"), SalesHeaderArchive.FieldNo("Constant Symbol CZL"));
            SalesHeaderArchiveDataTransfer.AddFieldValue(SalesHeaderArchive.FieldNo("Bank Account Code"), SalesHeaderArchive.FieldNo("Bank Account Code CZL"));
            SalesHeaderArchiveDataTransfer.AddFieldValue(SalesHeaderArchive.FieldNo("Bank Account No."), SalesHeaderArchive.FieldNo("Bank Account No. CZL"));
            SalesHeaderArchiveDataTransfer.AddFieldValue(SalesHeaderArchive.FieldNo("Transit No."), SalesHeaderArchive.FieldNo("Transit No. CZL"));
            SalesHeaderArchiveDataTransfer.AddFieldValue(SalesHeaderArchive.FieldNo(IBAN), SalesHeaderArchive.FieldNo("IBAN CZL"));
            SalesHeaderArchiveDataTransfer.AddFieldValue(SalesHeaderArchive.FieldNo("SWIFT Code"), SalesHeaderArchive.FieldNo("SWIFT Code CZL"));
        end;
        if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then begin
            SalesHeaderArchiveDataTransfer.AddFieldValue(SalesHeaderArchive.FieldNo("Physical Transfer"), SalesHeaderArchive.FieldNo("Physical Transfer CZL"));
            SalesHeaderArchiveDataTransfer.AddFieldValue(SalesHeaderArchive.FieldNo("Intrastat Exclude"), SalesHeaderArchive.FieldNo("Intrastat Exclude CZL"));
        end;
        SalesHeaderArchiveDataTransfer.CopyFields();
    end;

    local procedure UpgradeSalesLineArchive();
    var
        SalesLineArchive: Record "Sales Line Archive";
        SalesLineArchiveDataTransfer: DataTransfer;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        SalesLineArchiveDataTransfer.SetTables(Database::"Sales Line Archive", Database::"Sales Line Archive");
        SalesLineArchiveDataTransfer.AddFieldValue(SalesLineArchive.FieldNo("Physical Transfer"), SalesLineArchive.FieldNo("Physical Transfer CZL"));
        SalesLineArchiveDataTransfer.CopyFields();
    end;

    local procedure UpgradePurchaseHeader();
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseHeaderDataTransfer: DataTransfer;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) and
           UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion189PerCompanyUpgradeTag())
        then
            exit;

        PurchaseHeaderDataTransfer.SetTables(Database::"Purchase Header", Database::"Purchase Header");
        if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion189PerCompanyUpgradeTag()) then begin
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
        end;
        if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then begin
            PurchaseHeaderDataTransfer.AddFieldValue(PurchaseHeader.FieldNo("Physical Transfer"), PurchaseHeader.FieldNo("Physical Transfer CZL"));
            PurchaseHeaderDataTransfer.AddFieldValue(PurchaseHeader.FieldNo("Intrastat Exclude"), PurchaseHeader.FieldNo("Intrastat Exclude CZL"));
        end;
        PurchaseHeaderDataTransfer.CopyFields();
    end;

    local procedure UpgradePurchRcptHeader();
    var
        PurchRcptHeader: Record "Purch. Rcpt. Header";
        PurchRcptHeaderDataTransfer: DataTransfer;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        PurchRcptHeaderDataTransfer.SetTables(Database::"Purch. Rcpt. Header", Database::"Purch. Rcpt. Header");
        PurchRcptHeaderDataTransfer.AddFieldValue(PurchRcptHeader.FieldNo("Physical Transfer"), PurchRcptHeader.FieldNo("Physical Transfer CZL"));
        PurchRcptHeaderDataTransfer.AddFieldValue(PurchRcptHeader.FieldNo("Intrastat Exclude"), PurchRcptHeader.FieldNo("Intrastat Exclude CZL"));
        PurchRcptHeaderDataTransfer.CopyFields();
    end;

    local procedure UpgradePurchRcptLine();
    var
        PurchRcptLine: Record "Purch. Rcpt. Line";
        PurchRcptLineDataTransfer: DataTransfer;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        PurchRcptLineDataTransfer.SetTables(Database::"Purch. Rcpt. Line", Database::"Purch. Rcpt. Line");
        PurchRcptLineDataTransfer.AddFieldValue(PurchRcptLine.FieldNo("Country/Region of Origin Code"), PurchRcptLine.FieldNo("Country/Reg. of Orig. Code CZL"));
        PurchRcptLineDataTransfer.CopyFields();
    end;

    local procedure UpgradePurchInvHeader();
    var
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchInvHeaderDataTransfer: DataTransfer;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) and
           UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion189PerCompanyUpgradeTag())
        then
            exit;

        PurchInvHeaderDataTransfer.SetTables(Database::"Purch. Inv. Header", Database::"Purch. Inv. Header");
        if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion189PerCompanyUpgradeTag()) then begin
            PurchInvHeaderDataTransfer.AddFieldValue(PurchInvHeader.FieldNo("Specific Symbol"), PurchInvHeader.FieldNo("Specific Symbol CZL"));
            PurchInvHeaderDataTransfer.AddFieldValue(PurchInvHeader.FieldNo("Variable Symbol"), PurchInvHeader.FieldNo("Variable Symbol CZL"));
            PurchInvHeaderDataTransfer.AddFieldValue(PurchInvHeader.FieldNo("Constant Symbol"), PurchInvHeader.FieldNo("Constant Symbol CZL"));
            PurchInvHeaderDataTransfer.AddFieldValue(PurchInvHeader.FieldNo("Bank Account Code"), PurchInvHeader.FieldNo("Bank Account Code CZL"));
            PurchInvHeaderDataTransfer.AddFieldValue(PurchInvHeader.FieldNo("Bank Account No."), PurchInvHeader.FieldNo("Bank Account No. CZL"));
            PurchInvHeaderDataTransfer.AddFieldValue(PurchInvHeader.FieldNo("Transit No."), PurchInvHeader.FieldNo("Transit No. CZL"));
            PurchInvHeaderDataTransfer.AddFieldValue(PurchInvHeader.FieldNo(IBAN), PurchInvHeader.FieldNo("IBAN CZL"));
            PurchInvHeaderDataTransfer.AddFieldValue(PurchInvHeader.FieldNo("SWIFT Code"), PurchInvHeader.FieldNo("SWIFT Code CZL"));
            PurchInvHeaderDataTransfer.AddFieldValue(PurchInvHeader.FieldNo("VAT Date"), PurchInvHeader.FieldNo("VAT Date CZL"));
        end;
        if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then begin
            PurchInvHeaderDataTransfer.AddFieldValue(PurchInvHeader.FieldNo("Physical Transfer"), PurchInvHeader.FieldNo("Physical Transfer CZL"));
            PurchInvHeaderDataTransfer.AddFieldValue(PurchInvHeader.FieldNo("Intrastat Exclude"), PurchInvHeader.FieldNo("Intrastat Exclude CZL"));
        end;
        PurchInvHeaderDataTransfer.CopyFields();
    end;

    local procedure UpgradePurchInvLine();
    var
        PurchInvLine: Record "Purch. Inv. Line";
        PurchInvLineDataTransfer: DataTransfer;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        PurchInvLineDataTransfer.SetTables(Database::"Purch. Inv. Line", Database::"Purch. Inv. Line");
        PurchInvLineDataTransfer.AddFieldValue(PurchInvLine.FieldNo("Country/Region of Origin Code"), PurchInvLine.FieldNo("Country/Reg. of Orig. Code CZL"));
        PurchInvLineDataTransfer.CopyFields();
    end;

    local procedure UpgradePurchCrMemoHdr();
    var
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        PurchCrMemoHdrDataTransfer: DataTransfer;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) and
           UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion189PerCompanyUpgradeTag())
        then
            exit;

        PurchCrMemoHdrDataTransfer.SetTables(Database::"Purch. Cr. Memo Hdr.", Database::"Purch. Cr. Memo Hdr.");
        if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion189PerCompanyUpgradeTag()) then begin
            PurchCrMemoHdrDataTransfer.AddFieldValue(PurchCrMemoHdr.FieldNo("Specific Symbol"), PurchCrMemoHdr.FieldNo("Specific Symbol CZL"));
            PurchCrMemoHdrDataTransfer.AddFieldValue(PurchCrMemoHdr.FieldNo("Variable Symbol"), PurchCrMemoHdr.FieldNo("Variable Symbol CZL"));
            PurchCrMemoHdrDataTransfer.AddFieldValue(PurchCrMemoHdr.FieldNo("Constant Symbol"), PurchCrMemoHdr.FieldNo("Constant Symbol CZL"));
            PurchCrMemoHdrDataTransfer.AddFieldValue(PurchCrMemoHdr.FieldNo("Bank Account Code"), PurchCrMemoHdr.FieldNo("Bank Account Code CZL"));
            PurchCrMemoHdrDataTransfer.AddFieldValue(PurchCrMemoHdr.FieldNo("Bank Account No."), PurchCrMemoHdr.FieldNo("Bank Account No. CZL"));
            PurchCrMemoHdrDataTransfer.AddFieldValue(PurchCrMemoHdr.FieldNo("Transit No."), PurchCrMemoHdr.FieldNo("Transit No. CZL"));
            PurchCrMemoHdrDataTransfer.AddFieldValue(PurchCrMemoHdr.FieldNo(IBAN), PurchCrMemoHdr.FieldNo("IBAN CZL"));
            PurchCrMemoHdrDataTransfer.AddFieldValue(PurchCrMemoHdr.FieldNo("SWIFT Code"), PurchCrMemoHdr.FieldNo("SWIFT Code CZL"));
        end;
        if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then begin
            PurchCrMemoHdrDataTransfer.AddFieldValue(PurchCrMemoHdr.FieldNo("Physical Transfer"), PurchCrMemoHdr.FieldNo("Physical Transfer CZL"));
            PurchCrMemoHdrDataTransfer.AddFieldValue(PurchCrMemoHdr.FieldNo("Intrastat Exclude"), PurchCrMemoHdr.FieldNo("Intrastat Exclude CZL"));
        end;
        PurchCrMemoHdrDataTransfer.CopyFields();
    end;

    local procedure UpgradePurchCrMemoLine();
    var
        PurchCrMemoLine: Record "Purch. Cr. Memo Line";
        PurchCrMemoLineDataTransfer: DataTransfer;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        PurchCrMemoLineDataTransfer.SetTables(Database::"Purch. Cr. Memo Line", Database::"Purch. Cr. Memo Line");
        PurchCrMemoLineDataTransfer.AddFieldValue(PurchCrMemoLine.FieldNo("Country/Region of Origin Code"), PurchCrMemoLine.FieldNo("Country/Reg. of Orig. Code CZL"));
        PurchCrMemoLineDataTransfer.CopyFields();
    end;

    local procedure UpgradePurchaseHeaderArchive();
    var
        PurchaseHeaderArchive: Record "Purchase Header Archive";
        PurchaseHeaderArchiveDataTransfer: DataTransfer;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) and
           UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion189PerCompanyUpgradeTag())
        then
            exit;

        PurchaseHeaderArchiveDataTransfer.SetTables(Database::"Purchase Header Archive", Database::"Purchase Header Archive");
        if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion189PerCompanyUpgradeTag()) then begin
            PurchaseHeaderArchiveDataTransfer.AddFieldValue(PurchaseHeaderArchive.FieldNo("Specific Symbol"), PurchaseHeaderArchive.FieldNo("Specific Symbol CZL"));
            PurchaseHeaderArchiveDataTransfer.AddFieldValue(PurchaseHeaderArchive.FieldNo("Variable Symbol"), PurchaseHeaderArchive.FieldNo("Variable Symbol CZL"));
            PurchaseHeaderArchiveDataTransfer.AddFieldValue(PurchaseHeaderArchive.FieldNo("Constant Symbol"), PurchaseHeaderArchive.FieldNo("Constant Symbol CZL"));
            PurchaseHeaderArchiveDataTransfer.AddFieldValue(PurchaseHeaderArchive.FieldNo("Bank Account Code"), PurchaseHeaderArchive.FieldNo("Bank Account Code CZL"));
            PurchaseHeaderArchiveDataTransfer.AddFieldValue(PurchaseHeaderArchive.FieldNo("Bank Account No."), PurchaseHeaderArchive.FieldNo("Bank Account No. CZL"));
            PurchaseHeaderArchiveDataTransfer.AddFieldValue(PurchaseHeaderArchive.FieldNo("Transit No."), PurchaseHeaderArchive.FieldNo("Transit No. CZL"));
            PurchaseHeaderArchiveDataTransfer.AddFieldValue(PurchaseHeaderArchive.FieldNo(IBAN), PurchaseHeaderArchive.FieldNo("IBAN CZL"));
            PurchaseHeaderArchiveDataTransfer.AddFieldValue(PurchaseHeaderArchive.FieldNo("SWIFT Code"), PurchaseHeaderArchive.FieldNo("SWIFT Code CZL"));
        end;
        if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then begin
            PurchaseHeaderArchiveDataTransfer.AddFieldValue(PurchaseHeaderArchive.FieldNo("Physical Transfer"), PurchaseHeaderArchive.FieldNo("Physical Transfer CZL"));
            PurchaseHeaderArchiveDataTransfer.AddFieldValue(PurchaseHeaderArchive.FieldNo("Intrastat Exclude"), PurchaseHeaderArchive.FieldNo("Intrastat Exclude CZL"));
        end;
        PurchaseHeaderArchiveDataTransfer.CopyFields();
    end;

    local procedure UpgradePurchaseLineArchive();
    var
        PurchaseLineArchive: Record "Purchase Line Archive";
        PurchaseLineArchiveDataTransfer: DataTransfer;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        PurchaseLineArchiveDataTransfer.SetTables(Database::"Purchase Line Archive", Database::"Purchase Line Archive");
        PurchaseLineArchiveDataTransfer.AddFieldValue(PurchaseLineArchive.FieldNo("Physical Transfer"), PurchaseLineArchive.FieldNo("Physical Transfer CZL"));
        PurchaseLineArchiveDataTransfer.CopyFields();
    end;

    local procedure UpgradeServiceHeader();
    var
        ServiceHeader: Record "Service Header";
        ServiceHeaderDataTransfer: DataTransfer;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) and
           UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion189PerCompanyUpgradeTag())
        then
            exit;

        ServiceHeaderDataTransfer.SetTables(Database::"Service Header", Database::"Service Header");
        if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion189PerCompanyUpgradeTag()) then begin
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
        end;
        if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then begin
            ServiceHeaderDataTransfer.AddFieldValue(ServiceHeader.FieldNo("Physical Transfer"), ServiceHeader.FieldNo("Physical Transfer CZL"));
            ServiceHeaderDataTransfer.AddFieldValue(ServiceHeader.FieldNo("Intrastat Exclude"), ServiceHeader.FieldNo("Intrastat Exclude CZL"));
        end;
        ServiceHeaderDataTransfer.CopyFields();
    end;

    local procedure UpgradeServiceShipmentHeader();
    var
        ServiceShipmentHeader: Record "Service Shipment Header";
        ServiceShipmentHeaderDataTransfer: DataTransfer;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        ServiceShipmentHeaderDataTransfer.SetTables(Database::"Service Shipment Header", Database::"Service Shipment Header");
        ServiceShipmentHeaderDataTransfer.AddFieldValue(ServiceShipmentHeader.FieldNo("Physical Transfer"), ServiceShipmentHeader.FieldNo("Physical Transfer CZL"));
        ServiceShipmentHeaderDataTransfer.AddFieldValue(ServiceShipmentHeader.FieldNo("Intrastat Exclude"), ServiceShipmentHeader.FieldNo("Intrastat Exclude CZL"));
        ServiceShipmentHeaderDataTransfer.CopyFields();
    end;

    local procedure UpgradeServiceInvoiceHeader();
    var
        ServiceInvoiceHeader: Record "Service Invoice Header";
        ServiceInvoiceHeaderDataTransfer: DataTransfer;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) and
           UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion189PerCompanyUpgradeTag())
        then
            exit;

        ServiceInvoiceHeaderDataTransfer.SetTables(Database::"Service Invoice Header", Database::"Service Invoice Header");
        if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion189PerCompanyUpgradeTag()) then begin
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
        end;
        if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then begin
            ServiceInvoiceHeaderDataTransfer.AddFieldValue(ServiceInvoiceHeader.FieldNo("Physical Transfer"), ServiceInvoiceHeader.FieldNo("Physical Transfer CZL"));
            ServiceInvoiceHeaderDataTransfer.AddFieldValue(ServiceInvoiceHeader.FieldNo("Intrastat Exclude"), ServiceInvoiceHeader.FieldNo("Intrastat Exclude CZL"));
        end;
        ServiceInvoiceHeaderDataTransfer.CopyFields();
    end;

    local procedure UpgradeServiceInvoiceLine();
    var
        ServiceInvoiceLine: Record "Service Invoice Line";
        ServiceInvoiceLineDataTransfer: DataTransfer;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        ServiceInvoiceLineDataTransfer.SetTables(Database::"Service Invoice Line", Database::"Service Invoice Line");
        ServiceInvoiceLineDataTransfer.AddFieldValue(ServiceInvoiceLine.FieldNo("Country/Region of Origin Code"), ServiceInvoiceLine.FieldNo("Country/Reg. of Orig. Code CZL"));
        ServiceInvoiceLineDataTransfer.CopyFields();
    end;

    local procedure UpgradeServiceCrMemoHeader();
    var
        ServiceCrMemoHeader: Record "Service Cr.Memo Header";
        ServiceCrMemoHeaderDataTransfer: DataTransfer;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) and
           UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion189PerCompanyUpgradeTag())
        then
            exit;

        ServiceCrMemoHeaderDataTransfer.SetTables(Database::"Service Cr.Memo Header", Database::"Service Cr.Memo Header");
        if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion189PerCompanyUpgradeTag()) then begin
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
        end;
        if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then begin
            ServiceCrMemoHeaderDataTransfer.AddFieldValue(ServiceCrMemoHeader.FieldNo("Physical Transfer"), ServiceCrMemoHeader.FieldNo("Physical Transfer CZL"));
            ServiceCrMemoHeaderDataTransfer.AddFieldValue(ServiceCrMemoHeader.FieldNo("Intrastat Exclude"), ServiceCrMemoHeader.FieldNo("Intrastat Exclude CZL"));
        end;
        ServiceCrMemoHeaderDataTransfer.CopyFields();
    end;

    local procedure UpgradeServiceCrMemoLine();
    var
        ServiceCrMemoLine: Record "Service Cr.Memo Line";
        ServiceCrMemoLineDataTransfer: DataTransfer;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        ServiceCrMemoLineDataTransfer.SetTables(Database::"Service Cr.Memo Line", Database::"Service Cr.Memo Line");
        ServiceCrMemoLineDataTransfer.AddFieldValue(ServiceCrMemoLine.FieldNo("Country/Region of Origin Code"), ServiceCrMemoLine.FieldNo("Country/Reg. of Orig. Code CZL"));
        ServiceCrMemoLineDataTransfer.CopyFields();
    end;

    local procedure UpgradeReturnShipmentHeader();
    var
        ReturnShipmentHeader: Record "Return Shipment Header";
        ReturnShipmentHeaderDataTransfer: DataTransfer;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        ReturnShipmentHeaderDataTransfer.SetTables(Database::"Return Shipment Header", Database::"Return Shipment Header");
        ReturnShipmentHeaderDataTransfer.AddFieldValue(ReturnShipmentHeader.FieldNo("Physical Transfer"), ReturnShipmentHeader.FieldNo("Physical Transfer CZL"));
        ReturnShipmentHeaderDataTransfer.AddFieldValue(ReturnShipmentHeader.FieldNo("Intrastat Exclude"), ReturnShipmentHeader.FieldNo("Intrastat Exclude CZL"));
        ReturnShipmentHeaderDataTransfer.CopyFields();
    end;

    local procedure UpgradeReturnReceiptHeader();
    var
        ReturnReceiptHeader: Record "Return Receipt Header";
        ReturnReceiptHeaderDataTransfer: DataTransfer;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        ReturnReceiptHeaderDataTransfer.SetTables(Database::"Return Receipt Header", Database::"Return Receipt Header");
        ReturnReceiptHeaderDataTransfer.AddFieldValue(ReturnReceiptHeader.FieldNo("Physical Transfer"), ReturnReceiptHeader.FieldNo("Physical Transfer CZL"));
        ReturnReceiptHeaderDataTransfer.AddFieldValue(ReturnReceiptHeader.FieldNo("Intrastat Exclude"), ReturnReceiptHeader.FieldNo("Intrastat Exclude CZL"));
        ReturnReceiptHeaderDataTransfer.CopyFields();
    end;

    local procedure UpgradeTransferHeader();
    var
        TransferHeader: Record "Transfer Header";
        TransferHeaderDataTransfer: DataTransfer;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        TransferHeaderDataTransfer.SetTables(Database::"Transfer Header", Database::"Transfer Header");
        TransferHeaderDataTransfer.AddFieldValue(TransferHeader.FieldNo("Intrastat Exclude"), TransferHeader.FieldNo("Intrastat Exclude CZL"));
        TransferHeaderDataTransfer.CopyFields();
    end;

    local procedure UpgradeTransferLine();
    var
        TransferLine: Record "Transfer Line";
        TransferLineDataTransfer: DataTransfer;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        TransferLineDataTransfer.SetTables(Database::"Transfer Line", Database::"Transfer Line");
        TransferLineDataTransfer.AddFieldValue(TransferLine.FieldNo("Tariff No."), TransferLine.FieldNo("Tariff No. CZL"));
        TransferLineDataTransfer.AddFieldValue(TransferLine.FieldNo("Statistic Indication"), TransferLine.FieldNo("Statistic Indication CZL"));
        TransferLineDataTransfer.AddFieldValue(TransferLine.FieldNo("Country/Region of Origin Code"), TransferLine.FieldNo("Country/Reg. of Orig. Code CZL"));
        TransferLineDataTransfer.CopyFields();
    end;

    local procedure UpgradeTransferReceiptHeader();
    var
        TransferReceiptHeader: Record "Transfer Receipt Header";
        TransferReceiptHeaderDataTransfer: DataTransfer;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        TransferReceiptHeaderDataTransfer.SetTables(Database::"Transfer Receipt Header", Database::"Transfer Receipt Header");
        TransferReceiptHeaderDataTransfer.AddFieldValue(TransferReceiptHeader.FieldNo("Intrastat Exclude"), TransferReceiptHeader.FieldNo("Intrastat Exclude CZL"));
        TransferReceiptHeaderDataTransfer.CopyFields();
    end;

    local procedure UpgradeTransferShipmentHeader();
    var
        TransferShipmentHeader: Record "Transfer Shipment Header";
        TransferShipmentHeaderDataTransfer: DataTransfer;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        TransferShipmentHeaderDataTransfer.SetTables(Database::"Transfer Shipment Header", Database::"Transfer Shipment Header");
        TransferShipmentHeaderDataTransfer.AddFieldValue(TransferShipmentHeader.FieldNo("Intrastat Exclude"), TransferShipmentHeader.FieldNo("Intrastat Exclude CZL"));
        TransferShipmentHeaderDataTransfer.CopyFields();
    end;

    local procedure UpgradeItemLedgerEntry();
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        ItemLedgerEntryDataTransfer: DataTransfer;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        ItemLedgerEntryDataTransfer.SetTables(Database::"Item Ledger Entry", Database::"Item Ledger Entry");
        ItemLedgerEntryDataTransfer.AddFieldValue(ItemLedgerEntry.FieldNo("Tariff No."), ItemLedgerEntry.FieldNo("Tariff No. CZL"));
        ItemLedgerEntryDataTransfer.AddFieldValue(ItemLedgerEntry.FieldNo("Physical Transfer"), ItemLedgerEntry.FieldNo("Physical Transfer CZL"));
        ItemLedgerEntryDataTransfer.AddFieldValue(ItemLedgerEntry.FieldNo("Net Weight"), ItemLedgerEntry.FieldNo("Net Weight CZL"));
        ItemLedgerEntryDataTransfer.AddFieldValue(ItemLedgerEntry.FieldNo("Country/Region of Origin Code"), ItemLedgerEntry.FieldNo("Country/Reg. of Orig. Code CZL"));
        ItemLedgerEntryDataTransfer.AddFieldValue(ItemLedgerEntry.FieldNo("Statistic Indication"), ItemLedgerEntry.FieldNo("Statistic Indication CZL"));
        ItemLedgerEntryDataTransfer.AddFieldValue(ItemLedgerEntry.FieldNo("Intrastat Transaction"), ItemLedgerEntry.FieldNo("Intrastat Transaction CZL"));
        ItemLedgerEntryDataTransfer.CopyFields();
    end;

    local procedure UpgradeJobLedgerEntry();
    var
        JobLedgerEntry: Record "Job Ledger Entry";
        JobLedgerEntryDataTransfer: DataTransfer;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        JobLedgerEntryDataTransfer.SetTables(Database::"Job Ledger Entry", Database::"Job Ledger Entry");
        JobLedgerEntryDataTransfer.AddFieldValue(JobLedgerEntry.FieldNo("Tariff No."), JobLedgerEntry.FieldNo("Tariff No. CZL"));
        JobLedgerEntryDataTransfer.AddFieldValue(JobLedgerEntry.FieldNo("Net Weight"), JobLedgerEntry.FieldNo("Net Weight CZL"));
        JobLedgerEntryDataTransfer.AddFieldValue(JobLedgerEntry.FieldNo("Country/Region of Origin Code"), JobLedgerEntry.FieldNo("Country/Reg. of Orig. Code CZL"));
        JobLedgerEntryDataTransfer.AddFieldValue(JobLedgerEntry.FieldNo("Statistic Indication"), JobLedgerEntry.FieldNo("Statistic Indication CZL"));
        JobLedgerEntryDataTransfer.AddFieldValue(JobLedgerEntry.FieldNo("Intrastat Transaction"), JobLedgerEntry.FieldNo("Intrastat Transaction CZL"));
        JobLedgerEntryDataTransfer.CopyFields();
    end;

    local procedure UpgradeItemCharge();
    var
        ItemCharge: Record "Item Charge";
        ItemChargeDataTransfer: DataTransfer;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        ItemChargeDataTransfer.SetTables(Database::"Item Charge", Database::"Item Charge");
        ItemChargeDataTransfer.AddFieldValue(ItemCharge.FieldNo("Incl. in Intrastat Amount"), ItemCharge.FieldNo("Incl. in Intrastat Amount CZL"));
        ItemChargeDataTransfer.AddFieldValue(ItemCharge.FieldNo("Incl. in Intrastat Stat. Value"), ItemCharge.FieldNo("Incl. in Intrastat S.Value CZL"));
        ItemChargeDataTransfer.CopyFields();
    end;

    local procedure UpgradeItemChargeAssignmentPurch();
    var
        ItemChargeAssignmentPurch: Record "Item Charge Assignment (Purch)";
        ItemChargeAssignmentPurchDataTransfer: DataTransfer;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        ItemChargeAssignmentPurchDataTransfer.SetTables(Database::"Item Charge Assignment (Purch)", Database::"Item Charge Assignment (Purch)");
        ItemChargeAssignmentPurchDataTransfer.AddFieldValue(ItemChargeAssignmentPurch.FieldNo("Incl. in Intrastat Amount"), ItemChargeAssignmentPurch.FieldNo("Incl. in Intrastat Amount CZL"));
        ItemChargeAssignmentPurchDataTransfer.AddFieldValue(ItemChargeAssignmentPurch.FieldNo("Incl. in Intrastat Stat. Value"), ItemChargeAssignmentPurch.FieldNo("Incl. in Intrastat S.Value CZL"));
        ItemChargeAssignmentPurchDataTransfer.CopyFields();
    end;

    local procedure UpgradeItemChargeAssignmentSales();
    var
        ItemChargeAssignmentSales: Record "Item Charge Assignment (Sales)";
        ItemChargeAssignmentSalesDataTransfer: DataTransfer;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        ItemChargeAssignmentSalesDataTransfer.SetTables(Database::"Item Charge Assignment (Sales)", Database::"Item Charge Assignment (Sales)");
        ItemChargeAssignmentSalesDataTransfer.AddFieldValue(ItemChargeAssignmentSales.FieldNo("Incl. in Intrastat Amount"), ItemChargeAssignmentSales.FieldNo("Incl. in Intrastat Amount CZL"));
        ItemChargeAssignmentSalesDataTransfer.AddFieldValue(ItemChargeAssignmentSales.FieldNo("Incl. in Intrastat Stat. Value"), ItemChargeAssignmentSales.FieldNo("Incl. in Intrastat S.Value CZL"));
        ItemChargeAssignmentSalesDataTransfer.CopyFields();
    end;

    local procedure UpgradePostedGenJournalLine();
    var
        PostedGenJournalLine: Record "Posted Gen. Journal Line";
        PostedGenJournalLineDataTransfer: DataTransfer;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

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

    local procedure UpgradeIntrastatJournalBatch();
    var
        IntrastatJnlBatch: Record "Intrastat Jnl. Batch";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        IntrastatJnlBatch.SetLoadFields("Declaration No.", "Statement Type");
        if IntrastatJnlBatch.FindSet(true) then
            repeat
                IntrastatJnlBatch."Declaration No. CZL" := IntrastatJnlBatch."Declaration No.";
                IntrastatJnlBatch."Statement Type CZL" := "Intrastat Statement Type CZL".FromInteger(IntrastatJnlBatch."Statement Type");
                IntrastatJnlBatch.Modify(false);
            until IntrastatJnlBatch.Next() = 0;
    end;

    local procedure UpgradeIntrastatJournalLine();
    var
        IntrastatJnlLine: Record "Intrastat Jnl. Line";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        IntrastatJnlLine.SetLoadFields("Additional Costs", "Source Entry Date", "Statistic Indication", "Statistics Period", "Declaration No.", "Statement Type",
                                       "Prev. Declaration No.", "Prev. Declaration Line No.", "Specific Movement", "Supplem. UoM Code", "Supplem. UoM Quantity",
                                       "Supplem. UoM Net Weight", "Base Unit of Measure");
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

    local procedure UpgradeInventoryPostingSetup();
    var
        InventoryPostingSetup: Record "Inventory Posting Setup";
        InventoryPostingSetupDataTransfer: DataTransfer;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        InventoryPostingSetupDataTransfer.SetTables(Database::"Inventory Posting Setup", Database::"Inventory Posting Setup");
        InventoryPostingSetupDataTransfer.AddFieldValue(InventoryPostingSetup.FieldNo("Change In Inv.Of Product Acc."), InventoryPostingSetup.FieldNo("Change In Inv.OfProd. Acc. CZL"));
        InventoryPostingSetupDataTransfer.AddFieldValue(InventoryPostingSetup.FieldNo("Change In Inv.Of WIP Acc."), InventoryPostingSetup.FieldNo("Change In Inv.Of WIP Acc. CZL"));
        InventoryPostingSetupDataTransfer.AddFieldValue(InventoryPostingSetup.FieldNo("Consumption Account"), InventoryPostingSetup.FieldNo("Consumption Account CZL"));
        InventoryPostingSetupDataTransfer.CopyFields();
    end;

    local procedure UpgradeGeneralPostingSetup();
    var
        GeneralPostingSetup: Record "General Posting Setup";
        GeneralPostingSetupDataTransfer: DataTransfer;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        GeneralPostingSetupDataTransfer.SetTables(Database::"General Posting Setup", Database::"General Posting Setup");
        GeneralPostingSetupDataTransfer.AddFieldValue(GeneralPostingSetup.FieldNo("Invt. Rounding Adj. Account"), GeneralPostingSetup.FieldNo("Invt. Rounding Adj. Acc. CZL"));
        GeneralPostingSetupDataTransfer.CopyFields();
    end;

    local procedure UpgradeUserSetup();
    var
        UserSetup: Record "User Setup";
        UserSetupDataTransfer: DataTransfer;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        UserSetupDataTransfer.SetTables(Database::"User Setup", Database::"User Setup");
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

    local procedure UpgradeUserSetupLine();
    var
        UserSetupLine: Record "User Setup Line";
        UserSetupLineCZL: Record "User Setup Line CZL";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

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

    local procedure UpgradeAccScheduleLine();
    var
        AccScheduleLine: Record "Acc. Schedule Line";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion183PerCompanyUpgradeTag()) then
            exit;

        AccScheduleLine.SetLoadFields("Source Table", "Totaling Type");
        if AccScheduleLine.FindSet(true) then
            repeat
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

    local procedure UpgradeAccScheduleExtension();
    var
        AccScheduleExtension: Record "Acc. Schedule Extension";
        AccScheduleExtensionCZL: Record "Acc. Schedule Extension CZL";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion183PerCompanyUpgradeTag()) then
            exit;

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

    local procedure UpgradeAccScheduleResultLine();
    var
        AccScheduleResultLine: Record "Acc. Schedule Result Line";
        AccScheduleResultLineCZL: Record "Acc. Schedule Result Line CZL";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion183PerCompanyUpgradeTag()) then
            exit;

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

    local procedure UpgradeAccScheduleResultColumn();
    var
        AccScheduleResultColumn: Record "Acc. Schedule Result Column";
        AccScheduleResultColCZL: Record "Acc. Schedule Result Col. CZL";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion183PerCompanyUpgradeTag()) then
            exit;

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

    local procedure UpgradeAccScheduleResultValue();
    var
        AccScheduleResultValue: Record "Acc. Schedule Result Value";
        AccScheduleResultValueCZL: Record "Acc. Schedule Result Value CZL";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion183PerCompanyUpgradeTag()) then
            exit;

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

    local procedure UpgradeAccScheduleResultHeader();
    var
        AccScheduleResultHeader: Record "Acc. Schedule Result Header";
        AccScheduleResultHdrCZL: Record "Acc. Schedule Result Hdr. CZL";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion183PerCompanyUpgradeTag()) then
            exit;

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

    local procedure UpgradeAccScheduleResultHistory();
    var
        AccScheduleResultHistory: Record "Acc. Schedule Result History";
        AccScheduleResultHistCZL: Record "Acc. Schedule Result Hist. CZL";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion183PerCompanyUpgradeTag()) then
            exit;

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

    local procedure UpgradeGenJournalTemplate();
    var
        GenJournalTemplate: Record "Gen. Journal Template";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        GenJournalTemplate.SetLoadFields("Not Check Doc. Type");
        GenJournalTemplate.SetRange("Not Check Doc. Type", true);
        if GenJournalTemplate.FindSet() then
            repeat
                GenJournalTemplate."Not Check Doc. Type CZL" := GenJournalTemplate."Not Check Doc. Type";
                GenJournalTemplate.Modify(false);
            until GenJournalTemplate.Next() = 0;
    end;

    local procedure UpgradeVATEntry();
    var
        VATEntry: Record "VAT Entry";
        VATEntryDataTransfer: DataTransfer;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        VATEntryDataTransfer.SetTables(Database::"VAT Entry", Database::"VAT Entry");
        VATEntryDataTransfer.AddSourceFilter(VATEntry.FieldNo("VAT Identifier"), '<>%1', '');
        VATEntryDataTransfer.AddFieldValue(VATEntry.FieldNo("VAT Identifier"), VATEntry.FieldNo("VAT Identifier CZL"));
        VATEntryDataTransfer.CopyFields();
    end;

    local procedure UpgradeCustLedgerEntry();
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        CustLedgerEntryDataTransfer: DataTransfer;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion189PerCompanyUpgradeTag()) then
            exit;

        CustLedgerEntryDataTransfer.SetTables(Database::"Cust. Ledger Entry", Database::"Cust. Ledger Entry");
        CustLedgerEntryDataTransfer.AddFieldValue(CustLedgerEntry.FieldNo("Specific Symbol"), CustLedgerEntry.FieldNo("Specific Symbol CZL"));
        CustLedgerEntryDataTransfer.AddFieldValue(CustLedgerEntry.FieldNo("Variable Symbol"), CustLedgerEntry.FieldNo("Variable Symbol CZL"));
        CustLedgerEntryDataTransfer.AddFieldValue(CustLedgerEntry.FieldNo("Constant Symbol"), CustLedgerEntry.FieldNo("Constant Symbol CZL"));
        CustLedgerEntryDataTransfer.AddFieldValue(CustLedgerEntry.FieldNo("Bank Account Code"), CustLedgerEntry.FieldNo("Bank Account Code CZL"));
        CustLedgerEntryDataTransfer.AddFieldValue(CustLedgerEntry.FieldNo("Bank Account No."), CustLedgerEntry.FieldNo("Bank Account No. CZL"));
        CustLedgerEntryDataTransfer.AddFieldValue(CustLedgerEntry.FieldNo("Transit No."), CustLedgerEntry.FieldNo("Transit No. CZL"));
        CustLedgerEntryDataTransfer.AddFieldValue(CustLedgerEntry.FieldNo(IBAN), CustLedgerEntry.FieldNo("IBAN CZL"));
        CustLedgerEntryDataTransfer.AddFieldValue(CustLedgerEntry.FieldNo("SWIFT Code"), CustLedgerEntry.FieldNo("SWIFT Code CZL"));
        CustLedgerEntryDataTransfer.CopyFields();
    end;

    local procedure UpgradeVendLedgerEntry();
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        VendorLedgerEntryDataTransfer: DataTransfer;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion189PerCompanyUpgradeTag()) then
            exit;

        VendorLedgerEntryDataTransfer.SetTables(Database::"Vendor Ledger Entry", Database::"Vendor Ledger Entry");
        VendorLedgerEntryDataTransfer.AddFieldValue(VendorLedgerEntry.FieldNo("Specific Symbol"), VendorLedgerEntry.FieldNo("Specific Symbol CZL"));
        VendorLedgerEntryDataTransfer.AddFieldValue(VendorLedgerEntry.FieldNo("Variable Symbol"), VendorLedgerEntry.FieldNo("Variable Symbol CZL"));
        VendorLedgerEntryDataTransfer.AddFieldValue(VendorLedgerEntry.FieldNo("Constant Symbol"), VendorLedgerEntry.FieldNo("Constant Symbol CZL"));
        VendorLedgerEntryDataTransfer.AddFieldValue(VendorLedgerEntry.FieldNo("Bank Account Code"), VendorLedgerEntry.FieldNo("Bank Account Code CZL"));
        VendorLedgerEntryDataTransfer.AddFieldValue(VendorLedgerEntry.FieldNo("Bank Account No."), VendorLedgerEntry.FieldNo("Bank Account No. CZL"));
        VendorLedgerEntryDataTransfer.AddFieldValue(VendorLedgerEntry.FieldNo("Transit No."), VendorLedgerEntry.FieldNo("Transit No. CZL"));
        VendorLedgerEntryDataTransfer.AddFieldValue(VendorLedgerEntry.FieldNo(IBAN), VendorLedgerEntry.FieldNo("IBAN CZL"));
        VendorLedgerEntryDataTransfer.AddFieldValue(VendorLedgerEntry.FieldNo("SWIFT Code"), VendorLedgerEntry.FieldNo("SWIFT Code CZL"));
        VendorLedgerEntryDataTransfer.CopyFields();
    end;

    local procedure UpgradeGenJournalLine();
    var
        GenJournalLine: Record "Gen. Journal Line";
        GenJournalLineDataTransfer: DataTransfer;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion189PerCompanyUpgradeTag()) then
            exit;

        GenJournalLineDataTransfer.SetTables(Database::"Gen. Journal Line", Database::"Gen. Journal Line");
        GenJournalLineDataTransfer.AddFieldValue(GenJournalLine.FieldNo("Specific Symbol"), GenJournalLine.FieldNo("Specific Symbol CZL"));
        GenJournalLineDataTransfer.AddFieldValue(GenJournalLine.FieldNo("Variable Symbol"), GenJournalLine.FieldNo("Variable Symbol CZL"));
        GenJournalLineDataTransfer.AddFieldValue(GenJournalLine.FieldNo("Constant Symbol"), GenJournalLine.FieldNo("Constant Symbol CZL"));
        GenJournalLineDataTransfer.AddFieldValue(GenJournalLine.FieldNo("Bank Account Code"), GenJournalLine.FieldNo("Bank Account Code CZL"));
        GenJournalLineDataTransfer.AddFieldValue(GenJournalLine.FieldNo("Bank Account No."), GenJournalLine.FieldNo("Bank Account No. CZL"));
        GenJournalLineDataTransfer.AddFieldValue(GenJournalLine.FieldNo("Transit No."), GenJournalLine.FieldNo("Transit No. CZL"));
        GenJournalLineDataTransfer.AddFieldValue(GenJournalLine.FieldNo(IBAN), GenJournalLine.FieldNo("IBAN CZL"));
        GenJournalLineDataTransfer.AddFieldValue(GenJournalLine.FieldNo("SWIFT Code"), GenJournalLine.FieldNo("SWIFT Code CZL"));
        GenJournalLineDataTransfer.CopyFields();
    end;

    local procedure UpgradeReminderHeader();
    var
        ReminderHeader: Record "Reminder Header";
        ReminderHeaderDataTransfer: DataTransfer;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion189PerCompanyUpgradeTag()) then
            exit;

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
        ReminderHeaderDataTransfer.CopyFields();
    end;

    local procedure UpgradeIssuedReminderHeader();
    var
        IssuedReminderHeader: Record "Issued Reminder Header";
        IssuedReminderHeaderDataTransfer: DataTransfer;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion189PerCompanyUpgradeTag()) then
            exit;

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

    local procedure UpgradeFinanceChargeMemoHeader();
    var
        FinanceChargeMemoHeader: Record "Finance Charge Memo Header";
        FinanceChargeMemoHeaderDataTransfer: DataTransfer;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion189PerCompanyUpgradeTag()) then
            exit;

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
        FinanceChargeMemoHeaderDataTransfer.CopyFields();
    end;

    local procedure UpgradeIssuedFinanceChargeMemoHeader();
    var
        IssuedFinChargeMemoHeader: Record "Issued Fin. Charge Memo Header";
        IssuedFinChargeMemoHeaderDataTransfer: DataTransfer;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion189PerCompanyUpgradeTag()) then
            exit;

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
        IssuedFinChargeMemoHeaderDataTransfer.CopyFields();
    end;

    local procedure UpgradeReplaceVATDateCZL()
    begin
        UpgradeReplaceVATDateCZLVATEntries();
        UpgradeReplaceVATDateCZLGLEntries();
        UpgradeReplaceVATDateCZLSales();
        UpgradeReplaceVATDateCZLPurchase();
        UpgradeReplaceVATDateCZLService();
        UpgradeReplaceVATDateCZLSetup();
    end;

    local procedure UpgradeReplaceVATDateCZLVATEntries()
    var
        VATEntry: Record "VAT Entry";
        ReplaceVATDateCZLDataTransfer: DataTransfer;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetReplaceVATDateCZLVATEntriesUpgradeTag()) then
            exit;

        ReplaceVATDateCZLDataTransfer.SetTables(Database::"VAT Entry", Database::"VAT Entry");
        ReplaceVATDateCZLDataTransfer.AddSourceFilter(VATEntry.FieldNo("VAT Date CZL"), '<>%1', 0D);
        ReplaceVATDateCZLDataTransfer.AddFieldValue(VATEntry.FieldNo("VAT Date CZL"), VATEntry.FieldNo("VAT Reporting Date"));
        ReplaceVATDateCZLDataTransfer.CopyFields();
        Clear(ReplaceVATDateCZLDataTransfer);

        UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZL.GetReplaceVATDateCZLVATEntriesUpgradeTag());
    end;

    local procedure UpgradeReplaceVATDateCZLGLEntries()
    var
        GLEntry: Record "G/L Entry";
        TotalRows: Integer;
        FromNo, ToNo : Integer;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetReplaceVATDateCZLGLEntriesUpgradeTag()) then
            exit;

        GLEntry.Reset();
        TotalRows := GLEntry.Count();
        ToNo := 0;

        while ToNo < TotalRows do begin
            // Batch size 5 million
            FromNo := ToNo + 1;
            ToNo := FromNo + 5000000;

            if ToNo > TotalRows then
                ToNo := TotalRows;

            DataTransferGLEntries(FromNo, ToNo);
        end;

        UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZL.GetReplaceVATDateCZLGLEntriesUpgradeTag());
    end;

    local procedure DataTransferGLEntries(FromEntryNo: Integer; ToEntryNo: Integer)
    var
        GLEntry: Record "G/L Entry";
        ReplaceVATDateCZLDataTransfer: DataTransfer;
    begin
        ReplaceVATDateCZLDataTransfer.SetTables(Database::"G/L Entry", Database::"G/L Entry");
        ReplaceVATDateCZLDataTransfer.AddSourceFilter(GLEntry.FieldNo("Entry No."), '%1..%2', FromEntryNo, ToEntryNo);
        ReplaceVATDateCZLDataTransfer.AddSourceFilter(GLEntry.FieldNo("VAT Date CZL"), '<>%1', 0D);
        ReplaceVATDateCZLDataTransfer.AddFieldValue(GLEntry.FieldNo("VAT Date CZL"), GLEntry.FieldNo("VAT Reporting Date"));
        ReplaceVATDateCZLDataTransfer.CopyFields();
        Clear(ReplaceVATDateCZLDataTransfer);
    end;

    local procedure UpgradeReplaceVATDateCZLSales()
    var
        GenJournalLine: Record "Gen. Journal Line";
        SalesHeader: Record "Sales Header";
        SalesHeaderArchive: Record "Sales Header Archive";
        SalesInvHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        ReplaceVATDateCZLDataTransfer: DataTransfer;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetReplaceVATDateCZLSalesUpgradeTag()) then
            exit;

        ReplaceVATDateCZLDataTransfer.SetTables(Database::"Sales Header", Database::"Sales Header");
        ReplaceVATDateCZLDataTransfer.AddSourceFilter(SalesHeader.FieldNo("VAT Date CZL"), '<>%1', 0D);
        ReplaceVATDateCZLDataTransfer.AddFieldValue(SalesHeader.FieldNo("VAT Date CZL"), SalesHeader.FieldNo("VAT Reporting Date"));
        ReplaceVATDateCZLDataTransfer.CopyFields();
        Clear(ReplaceVATDateCZLDataTransfer);

        ReplaceVATDateCZLDataTransfer.SetTables(Database::"Sales Header Archive", Database::"Sales Header Archive");
        ReplaceVATDateCZLDataTransfer.AddSourceFilter(SalesHeaderArchive.FieldNo("VAT Date CZL"), '<>%1', 0D);
        ReplaceVATDateCZLDataTransfer.AddFieldValue(SalesHeaderArchive.FieldNo("VAT Date CZL"), SalesHeaderArchive.FieldNo("VAT Reporting Date"));
        ReplaceVATDateCZLDataTransfer.CopyFields();
        Clear(ReplaceVATDateCZLDataTransfer);

        ReplaceVATDateCZLDataTransfer.SetTables(Database::"Sales Invoice Header", Database::"Sales Invoice Header");
        ReplaceVATDateCZLDataTransfer.AddSourceFilter(SalesInvHeader.FieldNo("VAT Date CZL"), '<>%1', 0D);
        ReplaceVATDateCZLDataTransfer.AddFieldValue(SalesInvHeader.FieldNo("VAT Date CZL"), SalesInvHeader.FieldNo("VAT Reporting Date"));
        ReplaceVATDateCZLDataTransfer.CopyFields();
        Clear(ReplaceVATDateCZLDataTransfer);

        ReplaceVATDateCZLDataTransfer.SetTables(Database::"Sales Cr.Memo Header", Database::"Sales Cr.Memo Header");
        ReplaceVATDateCZLDataTransfer.AddSourceFilter(SalesCrMemoHeader.FieldNo("VAT Date CZL"), '<>%1', 0D);
        ReplaceVATDateCZLDataTransfer.AddFieldValue(SalesCrMemoHeader.FieldNo("VAT Date CZL"), SalesCrMemoHeader.FieldNo("VAT Reporting Date"));
        ReplaceVATDateCZLDataTransfer.CopyFields();
        Clear(ReplaceVATDateCZLDataTransfer);

        ReplaceVATDateCZLDataTransfer.SetTables(Database::"Gen. Journal Line", Database::"Gen. Journal Line");
        ReplaceVATDateCZLDataTransfer.AddSourceFilter(GenJournalLine.FieldNo("VAT Date CZL"), '<>%1', 0D);
        ReplaceVATDateCZLDataTransfer.AddFieldValue(GenJournalLine.FieldNo("VAT Date CZL"), GenJournalLine.FieldNo("VAT Reporting Date"));
        ReplaceVATDateCZLDataTransfer.CopyFields();
        Clear(ReplaceVATDateCZLDataTransfer);

        UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZL.GetReplaceVATDateCZLSalesUpgradeTag());
    end;

    local procedure UpgradeReplaceVATDateCZLPurchase()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseHeaderArchive: Record "Purchase Header Archive";
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        ReplaceVATDateCZLDataTransfer: DataTransfer;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetReplaceVATDateCZLPurchaseUpgradeTag()) then
            exit;

        ReplaceVATDateCZLDataTransfer.SetTables(Database::"Purchase Header", Database::"Purchase Header");
        ReplaceVATDateCZLDataTransfer.AddSourceFilter(PurchaseHeader.FieldNo("VAT Date CZL"), '<>%1', 0D);
        ReplaceVATDateCZLDataTransfer.AddFieldValue(PurchaseHeader.FieldNo("VAT Date CZL"), PurchaseHeader.FieldNo("VAT Reporting Date"));
        ReplaceVATDateCZLDataTransfer.CopyFields();
        Clear(ReplaceVATDateCZLDataTransfer);

        ReplaceVATDateCZLDataTransfer.SetTables(Database::"Purchase Header Archive", Database::"Purchase Header Archive");
        ReplaceVATDateCZLDataTransfer.AddSourceFilter(PurchaseHeaderArchive.FieldNo("VAT Date CZL"), '<>%1', 0D);
        ReplaceVATDateCZLDataTransfer.AddFieldValue(PurchaseHeaderArchive.FieldNo("VAT Date CZL"), PurchaseHeaderArchive.FieldNo("VAT Reporting Date"));
        ReplaceVATDateCZLDataTransfer.CopyFields();
        Clear(ReplaceVATDateCZLDataTransfer);

        ReplaceVATDateCZLDataTransfer.SetTables(Database::"Purch. Inv. Header", Database::"Purch. Inv. Header");
        ReplaceVATDateCZLDataTransfer.AddSourceFilter(PurchInvHeader.FieldNo("VAT Date CZL"), '<>%1', 0D);
        ReplaceVATDateCZLDataTransfer.AddFieldValue(PurchInvHeader.FieldNo("VAT Date CZL"), PurchInvHeader.FieldNo("VAT Reporting Date"));
        ReplaceVATDateCZLDataTransfer.CopyFields();
        Clear(ReplaceVATDateCZLDataTransfer);

        ReplaceVATDateCZLDataTransfer.SetTables(Database::"Purch. Cr. Memo Hdr.", Database::"Purch. Cr. Memo Hdr.");
        ReplaceVATDateCZLDataTransfer.AddSourceFilter(PurchCrMemoHdr.FieldNo("VAT Date CZL"), '<>%1', 0D);
        ReplaceVATDateCZLDataTransfer.AddFieldValue(PurchCrMemoHdr.FieldNo("VAT Date CZL"), PurchCrMemoHdr.FieldNo("VAT Reporting Date"));
        ReplaceVATDateCZLDataTransfer.CopyFields();
        Clear(ReplaceVATDateCZLDataTransfer);

        UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZL.GetReplaceVATDateCZLPurchaseUpgradeTag());
    end;

    local procedure UpgradeReplaceVATDateCZLService()
    var
        ServiceHeader: Record "Service Header";
        ServiceInvoiceHeader: Record "Service Invoice Header";
        ServiceCrMemoHeader: Record "Service Cr.Memo Header";
        ReplaceVATDateCZLDataTransfer: DataTransfer;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetReplaceVATDateCZLServiceUpgradeTag()) then
            exit;

        if not (ServiceHeader.WritePermission() and ServiceInvoiceHeader.WritePermission() and ServiceCrMemoHeader.WritePermission()) then
            exit;

        ReplaceVATDateCZLDataTransfer.SetTables(Database::"Service Header", Database::"Service Header");
        ReplaceVATDateCZLDataTransfer.AddSourceFilter(ServiceHeader.FieldNo("VAT Date CZL"), '<>%1', 0D);
        ReplaceVATDateCZLDataTransfer.AddFieldValue(ServiceHeader.FieldNo("VAT Date CZL"), ServiceHeader.FieldNo("VAT Reporting Date"));
        ReplaceVATDateCZLDataTransfer.CopyFields();
        Clear(ReplaceVATDateCZLDataTransfer);

        ReplaceVATDateCZLDataTransfer.SetTables(Database::"Service Invoice Header", Database::"Service Invoice Header");
        ReplaceVATDateCZLDataTransfer.AddSourceFilter(ServiceInvoiceHeader.FieldNo("VAT Date CZL"), '<>%1', 0D);
        ReplaceVATDateCZLDataTransfer.AddFieldValue(ServiceInvoiceHeader.FieldNo("VAT Date CZL"), ServiceInvoiceHeader.FieldNo("VAT Reporting Date"));
        ReplaceVATDateCZLDataTransfer.CopyFields();
        Clear(ReplaceVATDateCZLDataTransfer);

        ReplaceVATDateCZLDataTransfer.SetTables(Database::"Service Cr.Memo Header", Database::"Service Cr.Memo Header");
        ReplaceVATDateCZLDataTransfer.AddSourceFilter(ServiceCrMemoHeader.FieldNo("VAT Date CZL"), '<>%1', 0D);
        ReplaceVATDateCZLDataTransfer.AddFieldValue(ServiceCrMemoHeader.FieldNo("VAT Date CZL"), ServiceCrMemoHeader.FieldNo("VAT Reporting Date"));
        ReplaceVATDateCZLDataTransfer.CopyFields();
        Clear(ReplaceVATDateCZLDataTransfer);

        UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZL.GetReplaceVATDateCZLServiceUpgradeTag());
    end;

    local procedure UpgradeReplaceVATDateCZLSetup()
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetReplaceVATDateCZLSetupUpgradeTag()) then
            exit;

        if GeneralLedgerSetup.Get() then begin
            if GeneralLedgerSetup."Use VAT Date CZL" then
                GeneralLedgerSetup."VAT Reporting Date Usage" := GeneralLedgerSetup."VAT Reporting Date Usage"::"Enabled (Prevent modification)"
            else
                GeneralLedgerSetup."VAT Reporting Date Usage" := GeneralLedgerSetup."VAT Reporting Date Usage"::Disabled;

            if PurchasesPayablesSetup.Get() then
                case PurchasesPayablesSetup."Def. Orig. Doc. VAT Date CZL" of
                    PurchasesPayablesSetup."Def. Orig. Doc. VAT Date CZL"::Blank:
                        GeneralLedgerSetup."Def. Orig. Doc. VAT Date CZL" := Enum::"Default Orig.Doc. VAT Date CZL"::Blank;
                    PurchasesPayablesSetup."Def. Orig. Doc. VAT Date CZL"::"Posting Date":
                        GeneralLedgerSetup."Def. Orig. Doc. VAT Date CZL" := Enum::"Default Orig.Doc. VAT Date CZL"::"Posting Date";
                    PurchasesPayablesSetup."Def. Orig. Doc. VAT Date CZL"::"VAT Date":
                        GeneralLedgerSetup."Def. Orig. Doc. VAT Date CZL" := Enum::"Default Orig.Doc. VAT Date CZL"::"VAT Date";
                    PurchasesPayablesSetup."Def. Orig. Doc. VAT Date CZL"::"Document Date":
                        GeneralLedgerSetup."Def. Orig. Doc. VAT Date CZL" := Enum::"Default Orig.Doc. VAT Date CZL"::"Document Date";
                end;

            GeneralLedgerSetup.Modify();
        end;

        UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZL.GetReplaceVATDateCZLSetupUpgradeTag());
    end;

    local procedure UpgradeReplaceAllowAlterPostingGroups()
    var
        Customer: Record Customer;
        DetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry";
        DetailedVendorLedgEntry: Record "Detailed Vendor Ledg. Entry";
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
        ServiceMgtSetup: Record "Service Mgt. Setup";
        Vendor: Record Vendor;
        CustomerDataTransfer: DataTransfer;
        DetCustLedgEntryDataTransfer: DataTransfer;
        DetVendLedgEntryDataTransfer: DataTransfer;
        VendorDataTransfer: DataTransfer;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetReplaceAllowAlterPostingGroupsUpgradeTag()) then
            exit;

        if PurchasesPayablesSetup.Get() then begin
            PurchasesPayablesSetup."Allow Multiple Posting Groups" := PurchasesPayablesSetup."Allow Alter Posting Groups CZL";
            PurchasesPayablesSetup.Modify();
        end;

        if SalesReceivablesSetup.Get() then begin
            SalesReceivablesSetup."Allow Multiple Posting Groups" := SalesReceivablesSetup."Allow Alter Posting Groups CZL";
            SalesReceivablesSetup.Modify();
        end;

        if ServiceMgtSetup.Get() then begin
            ServiceMgtSetup."Allow Multiple Posting Groups" := ServiceMgtSetup."Allow Alter Posting Groups CZL";
            ServiceMgtSetup.Modify();
        end;

        VendorDataTransfer.SetTables(Database::"Vendor", Database::"Vendor");
        VendorDataTransfer.AddConstantValue(true, Vendor.FieldNo("Allow Multiple Posting Groups"));
        VendorDataTransfer.CopyFields();

        CustomerDataTransfer.SetTables(Database::"Customer", Database::"Customer");
        CustomerDataTransfer.AddConstantValue(true, Customer.FieldNo("Allow Multiple Posting Groups"));
        CustomerDataTransfer.CopyFields();

        DetCustLedgEntryDataTransfer.SetTables(Database::"Detailed Cust. Ledg. Entry", Database::"Detailed Cust. Ledg. Entry");
        DetCustLedgEntryDataTransfer.AddSourceFilter(DetailedCustLedgEntry.FieldNo("Customer Posting Group CZL"), '<>%1', '');
        DetCustLedgEntryDataTransfer.AddFieldValue(DetailedCustLedgEntry.FieldNo("Customer Posting Group CZL"), DetailedCustLedgEntry.FieldNo("Posting Group"));
        DetCustLedgEntryDataTransfer.CopyFields();

        DetVendLedgEntryDataTransfer.SetTables(Database::"Detailed Vendor Ledg. Entry", Database::"Detailed Vendor Ledg. Entry");
        DetVendLedgEntryDataTransfer.AddSourceFilter(DetailedVendorLedgEntry.FieldNo("Vendor Posting Group CZL"), '<>%1', '');
        DetVendLedgEntryDataTransfer.AddFieldValue(DetailedVendorLedgEntry.FieldNo("Vendor Posting Group CZL"), DetailedVendorLedgEntry.FieldNo("Posting Group"));
        DetVendLedgEntryDataTransfer.CopyFields();

        UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZL.GetReplaceAllowAlterPostingGroupsUpgradeTag());
    end;

    local procedure UpgradeUseW1RegistrationNumber()
    var
        Contact: Record Contact;
        Customer: Record Customer;
        Vendor: Record Vendor;
        ContactDataTransfer: DataTransfer;
        CustomerDataTransfer: DataTransfer;
        VendorDataTransfer: DataTransfer;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetUseW1RegistrationNumberUpgradeTag()) then
            exit;

        CustomerDataTransfer.SetTables(Database::"Customer", Database::"Customer");
        CustomerDataTransfer.AddSourceFilter(Customer.FieldNo("Registration No. CZL"), '<>%1', '');
        CustomerDataTransfer.AddFieldValue(Customer.FieldNo("Registration No. CZL"), Customer.FieldNo("Registration Number"));
        CustomerDataTransfer.CopyFields();

        VendorDataTransfer.SetTables(Database::"Vendor", Database::"Vendor");
        VendorDataTransfer.AddSourceFilter(Vendor.FieldNo("Registration No. CZL"), '<>%1', '');
        VendorDataTransfer.AddFieldValue(Vendor.FieldNo("Registration No. CZL"), Vendor.FieldNo("Registration Number"));
        VendorDataTransfer.CopyFields();

        ContactDataTransfer.SetTables(Database::"Contact", Database::"Contact");
        ContactDataTransfer.AddSourceFilter(Contact.FieldNo("Registration No. CZL"), '<>%1', '');
        ContactDataTransfer.AddFieldValue(Contact.FieldNo("Registration No. CZL"), Contact.FieldNo("Registration Number"));
        ContactDataTransfer.CopyFields();

        UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZL.GetUseW1RegistrationNumberUpgradeTag());
    end;

    local procedure UpgradeEU3PartyTradePurchase()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        PurchInvHeader: Record "Purch. Inv. Header";
        VATStatementLine: Record "VAT Statement Line";
        PurchCrMemoHdrDataTransfer: DataTransfer;
        PurchInvHeaderDataTransfer: DataTransfer;
        PurchHeaderDataTransfer: DataTransfer;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetEU3PartyTradePurchaseUpgradeTag()) then
            exit;

        PurchHeaderDataTransfer.SetTables(Database::"Purchase Header", Database::"Purchase Header");
        PurchHeaderDataTransfer.AddFieldValue(PurchaseHeader.FieldNo("EU 3-Party Trade CZL"), PurchaseHeader.FieldNo("EU 3 Party Trade"));
        PurchHeaderDataTransfer.CopyFields();

        PurchCrMemoHdrDataTransfer.SetTables(Database::"Purch. Cr. Memo Hdr.", Database::"Purch. Cr. Memo Hdr.");
        PurchCrMemoHdrDataTransfer.AddFieldValue(PurchCrMemoHdr.FieldNo("EU 3-Party Trade CZL"), PurchCrMemoHdr.FieldNo("EU 3 Party Trade"));
        PurchCrMemoHdrDataTransfer.CopyFields();

        PurchInvHeaderDataTransfer.SetTables(Database::"Purch. Inv. Header", Database::"Purch. Inv. Header");
        PurchInvHeaderDataTransfer.AddFieldValue(PurchInvHeader.FieldNo("EU 3-Party Trade CZL"), PurchInvHeader.FieldNo("EU 3 Party Trade"));
        PurchInvHeaderDataTransfer.CopyFields();

        if VATStatementLine.FindSet() then
            repeat
                case VATStatementLine."EU-3 Party Trade" of
                    VATStatementLine."EU-3 Party Trade"::" ":
                        VATStatementLine."EU 3 Party Trade" := VATStatementLine."EU 3 Party Trade"::All;
                    VATStatementLine."EU-3 Party Trade"::Yes:
                        VATStatementLine."EU 3 Party Trade" := VATStatementLine."EU 3 Party Trade"::EU3;
                    VATStatementLine."EU-3 Party Trade"::No:
                        VATStatementLine."EU 3 Party Trade" := VATStatementLine."EU 3 Party Trade"::"non-EU3";
                end;
                VATStatementLine.Modify(false);
            until VATStatementLine.Next() = 0;

        UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZL.GetEU3PartyTradePurchaseUpgradeTag());
    end;

    local procedure UpgradePermission()
    begin
        UpgradePermissionVersion174();
        UpgradePermissionVersion180();
        UpgradePermissionVersion190();
        UpgradePermissionReplaceAllowAlterPostingGroups();
    end;

    local procedure UpgradePermissionVersion174()
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion174PerDatabaseUpgradeTag()) then
            exit;

        NavApp.GetCurrentModuleInfo(AppInfo);
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Certificate CZ Code", Database::"Certificate Code CZL");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"EET Business Premises", Database::"EET Business Premises CZL");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"EET Cash Register", Database::"EET Cash Register CZL");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"EET Entry", Database::"EET Entry CZL");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"EET Entry Status", Database::"EET Entry Status Log CZL");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"EET Service Setup", Database::"EET Service Setup CZL");

        UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion174PerDatabaseUpgradeTag());
    end;

    local procedure UpgradePermissionVersion180()
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerDatabaseUpgradeTag()) then
            exit;

        NavApp.GetCurrentModuleInfo(AppInfo);
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Subst. Customer Posting Group", Database::"Subst. Cust. Posting Group CZL");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Subst. Vendor Posting Group", Database::"Subst. Vend. Posting Group CZL");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Constant Symbol", Database::"Constant Symbol CZL");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Specific Movement", Database::"Specific Movement CZL");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Intrastat Delivery Group", Database::"Intrastat Delivery Group CZL");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"User Setup Line", Database::"User Setup Line CZL");

        UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerDatabaseUpgradeTag());
    end;

    local procedure UpgradePermissionVersion190()
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion183PerDatabaseUpgradeTag()) then
            exit;

        NavApp.GetCurrentModuleInfo(AppInfo);
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Acc. Schedule Extension", Database::"Acc. Schedule Extension CZL");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Acc. Schedule Result Line", Database::"Acc. Schedule Result Line CZL");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Acc. Schedule Result Column", Database::"Acc. Schedule Result Col. CZL");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Acc. Schedule Result Value", Database::"Acc. Schedule Result Value CZL");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Acc. Schedule Result Header", Database::"Acc. Schedule Result Hdr. CZL");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Acc. Schedule Result History", Database::"Acc. Schedule Result Hist. CZL");

        UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion183PerDatabaseUpgradeTag());
    end;

    local procedure UpgradePermissionReplaceAllowAlterPostingGroups()
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetReplaceAllowAlterPostingGroupsPermissionUpgradeTag()) then
            exit;

        NavApp.GetCurrentModuleInfo(AppInfo);
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Subst. Cust. Posting Group CZL", Database::"Alt. Customer Posting Group");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Subst. Vend. Posting Group CZL", Database::"Alt. Vendor Posting Group");

        UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZL.GetReplaceAllowAlterPostingGroupsPermissionUpgradeTag());
    end;

    local procedure UpgradeReportSelections()
    var
        ReportSelections: Record "Report Selections";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetReportBlanketPurchaseOrderCZUpgradeTag()) then
            exit;
        ReportSelections.SetRange("Report ID", Report::"Blanket Purchase Order");
        ReportSelections.ModifyAll("Report ID", Report::"Blanket Purchase Order CZL");
        UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZL.GetReportBlanketPurchaseOrderCZUpgradeTag());
    end;

    local procedure UpgradeReportSelectionDirectTransfer()
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetReportPostedDirectTransferCZUpgradeTag()) then
            exit;

        InsertRepSelection(Enum::"Report Selection Usage"::"P.Direct Transfer", '1', Report::"Posted Direct Transfer CZL");
        UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZL.GetReportPostedDirectTransferCZUpgradeTag());
    end;

    local procedure UpgradeStatutoryReportingSetupCity()
    var
        CompanyInformation: Record "Company Information";
        StatutoryReportingSetupCZL: Record "Statutory Reporting Setup CZL";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetStatutoryReportingSetupCityUpgradeTag()) then
            exit;

        if not CompanyInformation.Get() then
            exit;
        if not StatutoryReportingSetupCZL.Get() then
            exit;

        StatutoryReportingSetupCZL.City := CompanyInformation.City;
        StatutoryReportingSetupCZL.Modify();

        UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZL.GetStatutoryReportingSetupCityUpgradeTag());
    end;

    local procedure UpgradeSubstCustVendPostingGroup()
    var
        AltCustomerPostingGroup: Record "Alt. Customer Posting Group";
        AltVendorPostingGroup: Record "Alt. Vendor Posting Group";
        SubstCustPostingGroupCZL: Record "Subst. Cust. Posting Group CZL";
        SubstVendPostingGroupCZL: Record "Subst. Vend. Posting Group CZL";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetSubstCustVendPostingGroupUpgradeTag()) then
            exit;

        if SubstCustPostingGroupCZL.FindSet() then
            repeat
                if not AltCustomerPostingGroup.Get(SubstCustPostingGroupCZL."Parent Customer Posting Group", SubstCustPostingGroupCZL."Customer Posting Group") then begin
                    AltCustomerPostingGroup.Init();
                    AltCustomerPostingGroup."Customer Posting Group" := SubstCustPostingGroupCZL."Parent Customer Posting Group";
                    AltCustomerPostingGroup."Alt. Customer Posting Group" := SubstCustPostingGroupCZL."Customer Posting Group";
                    AltCustomerPostingGroup.SystemId := SubstCustPostingGroupCZL.SystemId;
                    AltCustomerPostingGroup.Insert(false, true);
                end;
            until SubstCustPostingGroupCZL.Next() = 0;

        if SubstVendPostingGroupCZL.FindSet() then
            repeat
                if not AltVendorPostingGroup.Get(SubstVendPostingGroupCZL."Parent Vendor Posting Group", SubstVendPostingGroupCZL."Vendor Posting Group") then begin
                    AltVendorPostingGroup.Init();
                    AltVendorPostingGroup."Vendor Posting Group" := SubstVendPostingGroupCZL."Parent Vendor Posting Group";
                    AltVendorPostingGroup."Alt. Vendor Posting Group" := SubstVendPostingGroupCZL."Vendor Posting Group";
                    AltVendorPostingGroup.SystemId := SubstVendPostingGroupCZL.SystemId;
                    AltVendorPostingGroup.Insert(false, true);
                end;
            until SubstVendPostingGroupCZL.Next() = 0;

        UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZL.GetSubstCustVendPostingGroupUpgradeTag());
    end;

    local procedure UpgradeVATStatementTemplate()
    var
        VATStatementTemplate: Record "VAT Statement Template";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetVATStatementReportExtensionUpgradeTag()) then
            exit;

#if not CLEAN24
        VATStatementTemplate.SetRange("VAT Statement Report ID", Report::"VAT Statement CZL");
#else
        VATStatementTemplate.SetRange("VAT Statement Report ID", 11769); // VAT Statement CZL
#endif
        VATStatementTemplate.ModifyAll("VAT Statement Report ID", Report::"VAT Statement");

        UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZL.GetVATStatementReportExtensionUpgradeTag());
    end;

    local procedure UpgradeAllowVATPosting()
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        UserSetup: Record "User Setup";
        VATSetup: Record "VAT Setup";
        UserSetupDataTransfer: DataTransfer;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetAllowVATPostingUpgradeTag()) then
            exit;

        if GeneralLedgerSetup.Get() then begin
            if not VATSetup.Get() then begin
                VATSetup.Init();
                VATSetup.Insert();
            end;
            VATSetup."Allow VAT Date From" := GeneralLedgerSetup."Allow VAT Posting From CZL";
            VATSetup."Allow VAT Date To" := GeneralLedgerSetup."Allow VAT Posting To CZL";
            VATSetup.Modify();
        end;

        UserSetupDataTransfer.SetTables(Database::"User Setup", Database::"User Setup");
        UserSetupDataTransfer.AddFieldValue(UserSetup.FieldNo("Allow VAT Posting From CZL"), UserSetup.FieldNo("Allow VAT Date From"));
        UserSetupDataTransfer.AddFieldValue(UserSetup.FieldNo("Allow VAT Posting To CZL"), UserSetup.FieldNo("Allow VAT Date To"));
        UserSetupDataTransfer.CopyFields();

        UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZL.GetAllowVATPostingUpgradeTag());
    end;

    local procedure UpgradeOriginalVATAmountsInVATEntries()
    var
        VATEntry: Record "VAT Entry";
        VATEntryDataTransfer: DataTransfer;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetOriginalVATAmountsInVATEntriesUpgradeTag()) then
            exit;

        VATEntryDataTransfer.SetTables(Database::"VAT Entry", Database::"VAT Entry");
        VATEntryDataTransfer.AddFieldValue(VATEntry.FieldNo(Base), VATEntry.FieldNo("Original VAT Base CZL"));
        VATEntryDataTransfer.AddFieldValue(VATEntry.FieldNo(Amount), VATEntry.FieldNo("Original VAT Amount CZL"));
        VATEntryDataTransfer.CopyFields();

        UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZL.GetOriginalVATAmountsInVATEntriesUpgradeTag());
    end;

    local procedure UpgradeFunctionalCurrency()
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        PurchaseHeader: Record "Purchase Header";
        SalesHeader: Record "Sales Header";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetFunctionalCurrencyUpgradeTag()) then
            exit;

        if GeneralLedgerSetup.IsAdditionalCurrencyEnabled() then begin
            SalesHeader.SetLoadFields("Additional Currency Factor CZL", "Posting Date");
            SalesHeader.SetRange("Additional Currency Factor CZL", 0);
            if SalesHeader.FindSet(true) then
                repeat
                    SalesHeader.UpdateAddCurrencyFactorCZL();
#pragma warning disable AA0214
                    if SalesHeader.Modify() then;
#pragma warning restore AA0214
                until SalesHeader.Next() = 0;

            PurchaseHeader.SetLoadFields("Additional Currency Factor CZL", "Posting Date");
            PurchaseHeader.SetRange("Additional Currency Factor CZL", 0);
            if PurchaseHeader.FindSet(true) then
                repeat
                    PurchaseHeader.UpdateAddCurrencyFactorCZL();
#pragma warning disable AA0214
                    if PurchaseHeader.Modify() then;
#pragma warning restore AA0214
                until PurchaseHeader.Next() = 0;
        end;

        UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZL.GetFunctionalCurrencyUpgradeTag());
    end;

    local procedure UpgradeEnableNonDeductibleVATCZ()
    var
        VATEntry: Record "VAT Entry";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetEnableNonDeductibleVATCZUpgradeTag()) then
            exit;

        VATEntry.SetFilter("Non-Deductible VAT %", '<>%1', 0);
        VATEntry.SetLoadFields("Entry No.", Base, Amount, "Non-Deductible VAT Base", "Non-Deductible VAT Amount");
        if VATEntry.FindSet() then
            repeat
                VATEntry."Original VAT Base CZL" := VATEntry.CalcOriginalVATBaseCZL();
                VATEntry."Original VAT Amount CZL" := VATEntry.CalcOriginalVATAmountCZL();
                VATEntry."Original VAT Entry No. CZL" := VATEntry."Entry No.";
                if VATEntry.Modify() then;
            until VATEntry.Next() = 0;

        UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZL.GetEnableNonDeductibleVATCZUpgradeTag());
    end;

    local procedure InsertRepSelection(ReportUsage: Enum "Report Selection Usage"; Sequence: Code[10]; ReportID: Integer)
    var
        ReportSelections: Record "Report Selections";
    begin
        if not ReportSelections.Get(ReportUsage, Sequence) then begin
            ReportSelections.Init();
            ReportSelections.Usage := ReportUsage;
            ReportSelections.Sequence := Sequence;
            ReportSelections."Report ID" := ReportID;
            ReportSelections.Insert();
        end;
    end;

    local procedure SetDatabaseUpgradeTags();
    begin
        if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion174PerDatabaseUpgradeTag()) then
            UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion174PerDatabaseUpgradeTag());
        if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion189PerDatabaseUpgradeTag()) then
            UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion189PerDatabaseUpgradeTag());
        if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerDatabaseUpgradeTag()) then
            UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerDatabaseUpgradeTag());
        if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion183PerDatabaseUpgradeTag()) then
            UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion183PerDatabaseUpgradeTag());
        if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion200PerDatabaseUpgradeTag()) then
            UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion200PerDatabaseUpgradeTag());
    end;

    local procedure SetCompanyUpgradeTags();
    begin
        if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion174PerCompanyUpgradeTag()) then
            UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion174PerCompanyUpgradeTag());
        if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion189PerCompanyUpgradeTag()) then
            UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion189PerCompanyUpgradeTag());
        if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag());
        if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion183PerCompanyUpgradeTag()) then
            UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion183PerCompanyUpgradeTag());
        if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion200PerCompanyUpgradeTag()) then
            UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion200PerCompanyUpgradeTag());
    end;
}
