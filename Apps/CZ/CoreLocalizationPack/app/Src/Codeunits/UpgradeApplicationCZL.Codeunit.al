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
using Microsoft.Finance.VAT.Calculation;
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
using Microsoft.Sales.History;
using Microsoft.Sales.Receivables;
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
        UpgradeVATReport();
        UpgradeSetEnableNonDeductibleVATCZ();
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

        UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZL.GetEU3PartyTradePurchaseUpgradeTag());
    end;

    local procedure UpgradePermission()
    begin
        UpgradePermissionReplaceAllowAlterPostingGroups();
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

    local procedure UpgradeVATReport()
    var
        VATAttributeCodeCZL: Record "VAT Attribute Code CZL";
        VATReportsConfiguration: Record "VAT Reports Configuration";
        VATReportSetup: Record "VAT Report Setup";
        VATReportVersionTok: Label 'CZ', Locked = true;
        IsModified: Boolean;
        Code: Text;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetVATReportUpgradeTag()) then
            exit;

        if not VATReportsConfiguration.Get(VATReportsConfiguration."VAT Report Type"::"VAT Return", VATReportVersionTok) then begin
            VATReportsConfiguration.Init();
            VATReportsConfiguration.Validate("VAT Report Type", VATReportsConfiguration."VAT Report Type"::"VAT Return");
            VATReportsConfiguration.Validate("VAT Report Version", VATReportVersionTok);
            VATReportsConfiguration.Validate("Suggest Lines Codeunit ID", Codeunit::"VAT Report Suggest Lines CZL");
            VATReportsConfiguration.Validate("Validate Codeunit ID", Codeunit::"VAT Report Validate CZL");
            VATReportsConfiguration.Validate("Content Codeunit ID", Codeunit::"VAT Report Export CZL");
            VATReportsConfiguration.Validate("Submission Codeunit ID", Codeunit::"VAT Report Submit CZL");
            if VATReportsConfiguration.Insert(true) then;
        end;

        if not VATReportSetup.Get() then begin
            VATReportSetup.Init();
            if VATReportSetup.Insert() then;
        end;

        VATReportSetup."Report Version" := VATReportVersionTok;
        if VATReportSetup.Modify() then;

        if VATAttributeCodeCZL.FindSet() then
            repeat
                IsModified := true;
                Code := VATAttributeCodeCZL.Code;
                case true of
                    Code.EndsWith('Z'):
                        VATAttributeCodeCZL."VAT Report Amount Type" := VATAttributeCodeCZL."VAT Report Amount Type"::Base;
                    Code.EndsWith('D'):
                        VATAttributeCodeCZL."VAT Report Amount Type" := VATAttributeCodeCZL."VAT Report Amount Type"::Amount;
                    Code.EndsWith('K'):
                        VATAttributeCodeCZL."VAT Report Amount Type" := VATAttributeCodeCZL."VAT Report Amount Type"::"Reduced Amount";
                    else
                        IsModified := false;
                end;

                if IsModified then
                    if VATAttributeCodeCZL.Modify() then;
            until VATAttributeCodeCZL.Next() = 0;

        UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZL.GetVATReportUpgradeTag());
    end;

    local procedure UpgradeSetEnableNonDeductibleVATCZ()
    var
        NonDeductibleVATSetupCZL: Record "Non-Deductible VAT Setup CZL";
        VATSetup: Record "VAT Setup";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.SetEnableNonDeductibleVATCZUpgradeTag()) then
            exit;

        if not NonDeductibleVATSetupCZL.IsEmpty() then
            if VATSetup.Get() then
                if VATSetup."Enable Non-Deductible VAT" then begin
                    VATSetup."Enable Non-Deductible VAT CZL" := true;
                    VATSetup.Modify();
                end;

        UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZL.SetEnableNonDeductibleVATCZUpgradeTag());
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
