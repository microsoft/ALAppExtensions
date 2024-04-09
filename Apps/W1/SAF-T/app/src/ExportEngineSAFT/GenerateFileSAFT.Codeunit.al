// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

using Microsoft.Bank.BankAccount;
using Microsoft.Finance.Dimension;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.VAT.Ledger;
using Microsoft.Finance.VAT.Setup;
using Microsoft.FixedAssets.Depreciation;
using Microsoft.FixedAssets.FixedAsset;
using Microsoft.FixedAssets.Ledger;
using Microsoft.Foundation.AuditCodes;
using Microsoft.Foundation.Company;
using Microsoft.Foundation.Enums;
using Microsoft.Foundation.UOM;
using Microsoft.HumanResources.Employee;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Item.Attribute;
using Microsoft.Inventory.Item.Catalog;
using Microsoft.Inventory.Ledger;
using Microsoft.Inventory.Location;
using Microsoft.Projects.Resources.Resource;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Purchases.Payables;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using Microsoft.Sales.Receivables;
using System.Environment;
using System.Telemetry;
using System.Utilities;

codeunit 5289 "Generate File SAF-T"
{
    Access = Internal;

    var
        GlobalAuditFileExportSetup: Record "Audit File Export Setup";
        GlobalCustomer: Record Customer;
        GlobalVendor: Record Vendor;
        SAFTDataMgt: Codeunit "SAF-T Data Mgt.";
        XmlHelper: Codeunit "Xml Helper SAF-T";
        PayablesAccounts: Dictionary of [Code[20], Code[20]];
        ReceivablesAccounts: Dictionary of [Code[20], Code[20]];
        ProgressDialog: Dialog;
        IsSAFTSetupLoaded: Boolean;
        GeneratingHeaderTxt: label 'Generating header...';
        ExportingGLAccountsTxt: label 'Exporting G/L accounts:';
        ExportingCustomersTxt: label 'Exporting customers:';
        ExportingVendorsTxt: label 'Exporting vendors:';
        ExportingVATPostingSetupTxt: label 'Exporting VAT Posting Setup...';
        ExportingDimensionsTxt: label 'Exporting Dimensions...';
        ExportingGLEntriesTxt: label 'Exporting G/L entries:';
        ExportingUOMTxt: label 'Exporting Unit of Measures...';
        ExportingMovementTypesTxt: label 'Exporting Item Ledger Entry Types...';
        ExportingProductsTxt: label 'Exporting Items and Resources...';
        ExportingPhysicalStockTxt: label 'Exporting Warehouse Entries...';
        ExportingAssetsTxt: label 'Exporting Fixed Assets...';
        ExportingSalesInvoicesTxt: label 'Exporting Sales Invoices:';
        ExportingPurchaseInvoicesTxt: label 'Exporting Purchase Invoices:';
        ExportingPaymentsTxt: label 'Exporting Payments...';
        ExportingMovementOfGoodsTxt: label 'Exporting Movement of Goods...';
        ExportingAssetTransactionsTxt: label 'Exporting Asset Transactions...';
        TaxInformationTxt: label 'TaxInformation', Locked = true;
        TaxInformationTotalsTxt: label 'TaxInformationTotals', Locked = true;
        TaxTypeVATTxt: label 'VAT', Locked = true;
        BlankTxt: label 'Blank';
        AddressTxt: label 'Address', Locked = true;
        StreetAddressTxt: label 'StreetAddress', Locked = true;
        PostalAddressTxt: label 'PostalAddress', Locked = true;
        BillingAddressTxt: label 'BillingAddress', Locked = true;
        ShipToAddressTxt: label 'ShipToAddress', Locked = true;
        ShipFromAddressTxt: label 'ShipFromAddress', Locked = true;
        InvoiceTypeTxt: label 'Invoice', Locked = true;
        CreditMemoTypeTxt: label 'CrMemo', Locked = true;
        SAFTExportTok: label 'Audit File Export SAFT', Locked = true;

    procedure GenerateFileContent(var AuditFileExportLine: Record "Audit File Export Line"; var TempBlob: Codeunit "Temp Blob")
    var
        AuditFileExportHeader: Record "Audit File Export Header";
        FeatureTelemetry: Codeunit "Feature Telemetry";
    begin
        if GuiAllowed() then
            ProgressDialog.Open('#1#################### #2###');
        AuditFileExportHeader.Get(AuditFileExportLine.ID);
        ExportHeader(AuditFileExportHeader);

        case AuditFileExportLine."Data Class" of
            Enum::"Audit File Export Data Class"::MasterData:
                begin
                    ExportMasterFiles(AuditFileExportHeader);
                    XmlHelper.AfterAppendXmlNode('MasterFiles');
                end;
            Enum::"Audit File Export Data Class"::GeneralLedgerEntries:
                begin
                    ExportGeneralLedgerEntries(AuditFileExportHeader, AuditFileExportLine);
                    XmlHelper.AfterAppendXmlNode('GeneralLedgerEntries');
                end;
            Enum::"Audit File Export Data Class"::SourceDocuments:
                begin
                    ExportSourceDocuments(AuditFileExportHeader);
                    XmlHelper.AfterAppendXmlNode('SourceDocuments');
                end;
        end;

        if GuiAllowed() then
            ProgressDialog.Close();

        XmlHelper.WriteXMLDocToTempBlob(TempBlob);

        FeatureTelemetry.LogUptake('0000KTB', SAFTExportTok, Enum::"Feature Uptake Status"::"Used");
    end;

    local procedure ExportMasterFiles(AuditFileExportHeader: Record "Audit File Export Header")
    var
        AuditExportDataTypeSetup: Record "Audit Export Data Type Setup";
    begin
        AuditExportDataTypeSetup.SetRange("Audit File Export Format", Enum::"Audit File Export Format"::SAFT);
        AuditExportDataTypeSetup.SetRange("Export Enabled", true);
        if AuditExportDataTypeSetup.IsEmpty() then
            exit;

        XmlHelper.AddNewXmlNode('MasterFiles', '');

        AuditExportDataTypeSetup.FindSet();
        repeat
            XmlHelper.SetNodeModificationAllowed(AuditExportDataTypeSetup."Export Data Type");
            case AuditExportDataTypeSetup."Export Data Type" of
                Enum::"Audit File Export Data Type"::GeneralLedgerAccounts:
                    ExportGeneralLedgerAccounts(AuditFileExportHeader);
                Enum::"Audit File Export Data Type"::Customers:
                    ExportCustomers(AuditFileExportHeader);
                Enum::"Audit File Export Data Type"::Suppliers:
                    ExportVendors(AuditFileExportHeader);
                Enum::"Audit File Export Data Type"::TaxTable:
                    ExportTaxTable();
                Enum::"Audit File Export Data Type"::UOMTable:
                    ExportUOMTable();
                Enum::"Audit File Export Data Type"::AnalysisTypeTable:
                    ExportAnalysisTypeTable();
                Enum::"Audit File Export Data Type"::MovementTypeTable:
                    ExportMovementTypeTable();
                Enum::"Audit File Export Data Type"::Products:
                    ExportProducts();
                Enum::"Audit File Export Data Type"::PhysicalStock:
                    ExportPhysicalStock(AuditFileExportHeader);
                Enum::"Audit File Export Data Type"::Assets:
                    ExportAssets(AuditFileExportHeader);
            end;
            XmlHelper.AfterAppendXmlNode(Format(AuditExportDataTypeSetup."Export Data Type"));
        until AuditExportDataTypeSetup.Next() = 0;

        XmlHelper.FinalizeXmlNode();
    end;

    local procedure ExportSourceDocuments(AuditFileExportHeader: Record "Audit File Export Header")
    var
        AuditExportDataTypeSetup: Record "Audit Export Data Type Setup";
    begin
        AuditExportDataTypeSetup.SetRange("Audit File Export Format", Enum::"Audit File Export Format"::SAFT);
        AuditExportDataTypeSetup.SetRange("Export Enabled", true);
        if AuditExportDataTypeSetup.IsEmpty() then
            exit;

        XmlHelper.AddNewXmlNode('SourceDocuments', '');

        AuditExportDataTypeSetup.FindSet();
        repeat
            XmlHelper.SetNodeModificationAllowed(AuditExportDataTypeSetup."Export Data Type");
            case AuditExportDataTypeSetup."Export Data Type" of
                Enum::"Audit File Export Data Type"::SalesInvoices:
                    ExportSalesInvoicesAndCreditMemos(AuditFileExportHeader);
                Enum::"Audit File Export Data Type"::PurchaseInvoices:
                    ExportPurchaseInvoicesAndCreditMemos(AuditFileExportHeader);
                Enum::"Audit File Export Data Type"::Payments:
                    ExportPayments(AuditFileExportHeader);
                Enum::"Audit File Export Data Type"::MovementOfGoods:
                    ExportMovementOfGoods(AuditFileExportHeader);
                Enum::"Audit File Export Data Type"::AssetTransactions:
                    ExportAssetTransactions(AuditFileExportHeader);
            end;
            XmlHelper.AfterAppendXmlNode(Format(AuditExportDataTypeSetup."Export Data Type"));
        until AuditExportDataTypeSetup.Next() = 0;

        XmlHelper.FinalizeXmlNode();
    end;

    local procedure ExportHeader(AuditFileExportHeader: Record "Audit File Export Header")
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        CompanyInformation: Record "Company Information";
        ApplicationSystemConstants: Codeunit "Application System Constants";
    begin
        XmlHelper.Initialize();
        XmlHelper.SetHeaderModificationAllowed();
        UpdateDataSourceInProgressDialog(GeneratingHeaderTxt);

        CompanyInformation.Get();
        XmlHelper.SetCurrentRec(CompanyInformation);
        XmlHelper.AddNewXmlNode('Header', '');
        XmlHelper.AppendXmlNode('AuditFileVersion', '1.0');
        XmlHelper.AppendXmlNode('AuditFileCountry', SAFTDataMgt.GetISOCountryCode(CompanyInformation."Country/Region Code"));
        XmlHelper.AppendXmlNode('AuditFileDateCreated', FormatDate(Today()));
        XmlHelper.AppendXmlNode('SoftwareCompanyName', 'Microsoft');
        XmlHelper.AppendXmlNode('SoftwareID', 'Microsoft Dynamics 365 Business Central');
        XmlHelper.AppendXmlNode('SoftwareVersion', ApplicationSystemConstants.ApplicationVersion());

        ExportCompanyInfo();

        GeneralLedgerSetup.Get();
        XmlHelper.AppendXmlNode('DefaultCurrencyCode', GeneralLedgerSetup."LCY Code");

        XmlHelper.AddNewXmlNode('SelectionCriteria', '');
        XmlHelper.AppendXmlNode('PeriodStart', Format(Date2DMY(AuditFileExportHeader."Starting Date", 2)));
        XmlHelper.AppendXmlNode('PeriodStartYear', Format(Date2DMY(AuditFileExportHeader."Starting Date", 3)));
        XmlHelper.AppendXmlNode('PeriodEnd', Format(Date2DMY(AuditFileExportHeader."Ending Date", 2)));
        XmlHelper.AppendXmlNode('PeriodEndYear', Format(Date2DMY(AuditFileExportHeader."Ending Date", 3)));
        XmlHelper.FinalizeXmlNode();

        XmlHelper.AppendXmlNode('HeaderComment', AuditFileExportHeader."Header Comment");
        XmlHelper.AppendXmlNode('TaxAccountingBasis', '');
        XmlHelper.AppendXmlNode('TaxEntity', 'Company');
        XmlHelper.AppendXmlNode('UserID', SAFTDataMgt.GetSAFTMiddle1Text(UserId()));
        XmlHelper.FinalizeXmlNode();
    end;

    local procedure ExportCompanyInfo()
    var
        CompanyInformation: Record "Company Information";
        Employee: Record Employee;
    begin
        CompanyInformation.Get();

        XmlHelper.SetCurrentRec(CompanyInformation);
        XmlHelper.AddNewXmlNode('Company', '');
        XmlHelper.AppendXmlNode('RegistrationNumber', CompanyInformation."VAT Registration No.");
        XmlHelper.AppendXmlNode('Name', SAFTDataMgt.GetSAFTMiddle2Text(CompanyInformation.Name));
        ExportAddress(
            AddressTxt, CombineWithSpace(CompanyInformation.Address, CompanyInformation."Address 2"), CompanyInformation.City, CompanyInformation."Post Code",
            CompanyInformation."Country/Region Code", StreetAddressTxt);

        Employee.Get(CompanyInformation."Contact No. SAF-T");
        ExportContact(
            Employee."First Name", Employee."Last Name", Employee."Phone No.", Employee."Fax No.", Employee."E-Mail", '', Employee."Mobile Phone No.");

        ExportTaxRegistration(CompanyInformation."VAT Registration No.");
        ExportBankAccount(
            CompanyInformation."Bank Name", CompanyInformation."Bank Account No.", CompanyInformation.IBAN,
            CompanyInformation."Bank Branch No.", '');
        ExportBankAccounts();
        XmlHelper.SetCurrentRec(CompanyInformation);
        XmlHelper.AfterAppendXmlNode('BankAccount');

        XmlHelper.FinalizeXmlNode();
    end;

    local procedure ExportAddress(AddressTagName: Text; StreetName: Text; City: Text; PostalCode: Text; Country: Text; AddressType: Text)
    begin
        XmlHelper.AddNewXmlNode(AddressTagName, '');
        XmlHelper.AppendXmlNode('StreetName', SAFTDataMgt.GetSAFTMiddle2Text(StreetName));
        XmlHelper.AppendXmlNode('City', SAFTDataMgt.GetSAFTMiddle1Text(City));
        if PostalCode = '' then begin
            GetSAFTSetup();
            PostalCode := GlobalAuditFileExportSetup."Default Post Code";
        end;
        XmlHelper.AppendXmlNode('PostalCode', SAFTDataMgt.GetSAFTShortText(PostalCode));
        XmlHelper.AppendXmlNode('Country', SAFTDataMgt.GetISOCountryCode(Country));
        XmlHelper.AppendXmlNode('AddressType', AddressType);
        XmlHelper.FinalizeXmlNode();
    end;

    local procedure ExportContact(FirstName: Text; LastName: Text; Telephone: Text; Fax: Text; Email: Text; Website: Text; MobilePhone: Text)
    begin
        if (FirstName.Trim() = '') or (LastName.Trim() = '') then
            exit;

        XmlHelper.AddNewXmlNode('Contact', '');
        XmlHelper.AddNewXmlNode('ContactPerson', '');
        XmlHelper.AppendXmlNode('FirstName', SAFTDataMgt.GetSAFTMiddle1Text(FirstName));
        XmlHelper.AppendXmlNode('LastName', SAFTDataMgt.GetSAFTMiddle2Text(LastName));
        XmlHelper.FinalizeXmlNode();

        XmlHelper.AppendXmlNode('Telephone', SAFTDataMgt.GetSAFTShortText(Telephone));
        XmlHelper.AppendXmlNode('Fax', SAFTDataMgt.GetSAFTShortText(Fax));
        XmlHelper.AppendXmlNode('Email', SAFTDataMgt.GetSAFTMiddle2Text(Email));
        XmlHelper.AppendXmlNode('Website', Website);
        XmlHelper.AppendXmlNode('MobilePhone', SAFTDataMgt.GetSAFTShortText(MobilePhone));
        XmlHelper.FinalizeXmlNode();
    end;

    local procedure ExportTaxRegistration(VATRegistrationNo: Text[20])
    begin
        if VATRegistrationNo = '' then
            exit;
        XmlHelper.AddNewXmlNode('TaxRegistration', '');
        XmlHelper.AppendXmlNode('TaxRegistrationNumber', VATRegistrationNo);
        XmlHelper.AppendXmlNode('TaxAuthority', '');
        XmlHelper.FinalizeXmlNode();
    end;

    local procedure ExportBankAccounts()
    var
        BankAccount: Record "Bank Account";
    begin
        BankAccount.SetLoadFields(
            Name, "Name 2", "Bank Account No.", IBAN, "Bank Branch No.", "Bank Clearing Code", "SWIFT Code", "Currency Code", "Bank Acc. Posting Group");
        if not BankAccount.FindSet() then
            exit;

        repeat
            XmlHelper.SetCurrentRec(BankAccount);
            ExportBankAccount(
                CombineWithSpace(BankAccount.Name, BankAccount."Name 2"),
                BankAccount."Bank Account No.", BankAccount.IBAN,
                BankAccount."Bank Branch No.", BankAccount."Bank Clearing Code");
        until BankAccount.Next() = 0;
    end;

    local procedure ExportBankAccount(BankName: Text; BankNumber: Text; IBAN: Text; BranchNo: Text; ClearingCode: Text)
    var
        SortCode: Text;
    begin
        XmlHelper.AddNewXmlNode('BankAccount', '');
        if IBAN <> '' then
            XmlHelper.AppendXmlNode('IBANNumber', IBAN)
        else begin
            XmlHelper.AppendXmlNode('BankAccountNumber', BankNumber);
            XmlHelper.AppendXmlNode('BankAccountName', SAFTDataMgt.GetSAFTMiddle2Text(BankName));
            if ClearingCode = '' then
                SortCode := BranchNo
            else
                SortCode := ClearingCode;
            XmlHelper.AppendXmlNode('SortCode', SortCode);
        end;

        XmlHelper.FinalizeXmlNode();
    end;

    local procedure ExportGeneralLedgerAccounts(AuditFileExportHeader: Record "Audit File Export Header")
    var
        GLAccountMappingHeader: Record "G/L Account Mapping Header";
        GLAccountMappingLine: Record "G/L Account Mapping Line";
        TotalNumberOfAccounts: Integer;
        CountOfAccounts: Integer;
        GLAccountsHaveGroupingCategory: Boolean;
    begin
        GLAccountMappingHeader.Get(AuditFileExportHeader."G/L Account Mapping Code");
        GLAccountMappingLine.SetRange("G/L Account Mapping Code", AuditFileExportHeader."G/L Account Mapping Code");
        GLAccountMappingLine.SetFilter("Standard Account No.", '<>%1', '');
        if not GLAccountMappingLine.FindSet() then
            exit;

        GLAccountMappingLine.SetFilter("Standard Account Category No.", '<>%1', '');
        GLAccountsHaveGroupingCategory := not GLAccountMappingLine.IsEmpty();
        GLAccountMappingLine.SetRange("Standard Account Category No.");

        XmlHelper.AddNewXmlNode('GeneralLedgerAccounts', '');
        UpdateDataSourceInProgressDialog(ExportingGLAccountsTxt);
        TotalNumberOfAccounts := GLAccountMappingLine.Count();
        repeat
            CountOfAccounts += 1;
            UpdateCountInProgressDialog(CountOfAccounts, TotalNumberOfAccounts);

            if GLAccountsHaveGroupingCategory then
                ExportGLAccount(
                    GLAccountMappingLine."G/L Account No.", '',
                    GLAccountMappingLine."Standard Account Category No.", GLAccountMappingLine."Standard Account No.",
                    AuditFileExportHeader."Starting Date", AuditFileExportHeader."Ending Date")
            else
                ExportGLAccount(
                    GLAccountMappingLine."G/L Account No.", GLAccountMappingLine."Standard Account No.",
                    '', '', AuditFileExportHeader."Starting Date", AuditFileExportHeader."Ending Date");
        until GLAccountMappingLine.Next() = 0;
        XmlHelper.FinalizeXmlNode();
    end;

    local procedure ExportGLAccount(GLAccNo: Code[20]; StandardAccNo: Text; GroupingCategory: Code[20]; GroupingNo: Code[20]; StartingDate: Date; EndingDate: Date)
    var
        GLAccount: Record "G/L Account";
        OpeningDebitBalance: Decimal;
        OpeningCreditBalance: Decimal;
        ClosingDebitBalance: Decimal;
        ClosingCreditBalance: Decimal;
    begin
        GLAccount.Get(GLAccNo);

        // Opening balance always zero for income statement
        if GLAccount."Income/Balance" <> GLAccount."Income/Balance"::"Income Statement" then begin
            GLAccount.SetRange("Date Filter", 0D, ClosingDate(StartingDate - 1));
            GLAccount.CalcFields("Net Change");
            if GLAccount."Net Change" > 0 then
                OpeningDebitBalance := GLAccount."Net Change"
            else
                OpeningCreditBalance := -GLAccount."Net Change";
        end;

        if GLAccount."Income/Balance" = GLAccount."Income/Balance"::"Income Statement" then
            GLAccount.SetRange("Date Filter", StartingDate, EndingDate)
        else
            GLAccount.SetRange("Date Filter", 0D, ClosingDate(EndingDate));
        GLAccount.CalcFields("Net Change");
        if GLAccount."Net Change" > 0 then
            ClosingDebitBalance := GLAccount."Net Change"
        else
            ClosingCreditBalance := -GLAccount."Net Change";

        XmlHelper.SetCurrentRec(GLAccount);
        XmlHelper.AddNewXmlNode('Account', '');
        XmlHelper.AppendXmlNode('AccountID', GLAccount."No.");
        XmlHelper.AppendXmlNode('AccountDescription', GLAccount.Name);

        if StandardAccNo <> '' then
            XmlHelper.AppendXmlNode('StandardAccountID', StandardAccNo)
        else begin
            XmlHelper.AppendXmlNode('GroupingCategory', GroupingCategory);
            XmlHelper.AppendXmlNode('GroupingCode', GroupingNo);
        end;

        XmlHelper.AppendXmlNode('AccountType', '');
        if GLAccount."Income/Balance" = GLAccount."Income/Balance"::"Income Statement" then begin
            // For income statement the opening balance is always zero but it's more preferred to have same type of balance (Debit or Credit) to match opening and closing XML nodes.
            if ClosingDebitBalance = 0 then
                XmlHelper.AppendXmlNode('OpeningCreditBalance', FormatAmount(0))
            else
                XmlHelper.AppendXmlNode('OpeningDebitBalance', FormatAmount(0))
        end else
            if OpeningDebitBalance = 0 then
                XmlHelper.AppendXmlNode('OpeningCreditBalance', SAFTDataMgt.GetSAFTMonetaryDecimal(OpeningCreditBalance))
            else
                XmlHelper.AppendXmlNode('OpeningDebitBalance', SAFTDataMgt.GetSAFTMonetaryDecimal(OpeningDebitBalance));
        if ClosingDebitBalance = 0 then
            XmlHelper.AppendXmlNode('ClosingCreditBalance', SAFTDataMgt.GetSAFTMonetaryDecimal(ClosingCreditBalance))
        else
            XmlHelper.AppendXmlNode('ClosingDebitBalance', SAFTDataMgt.GetSAFTMonetaryDecimal(ClosingDebitBalance));
        XmlHelper.FinalizeXmlNode();
    end;

    local procedure ExportCustomers(AuditFileExportHeader: Record "Audit File Export Header")
    var
        Customer: Record Customer;
        TotalNumberOfCustomers: Integer;
        CountOfCustomers: Integer;
    begin
        Customer.SetLoadFields(
            "No.", Name, "Name 2", "VAT Registration No.", Address, "Address 2", City, "Post Code", "Country/Region Code", Contact,
            "Phone No.", "Fax No.", "E-Mail", "Home Page", "Customer Posting Group", "Currency Code", "Payment Terms Code");
        if not Customer.FindSet() then
            exit;

        XmlHelper.AddNewXmlNode('Customers', '');
        UpdateDataSourceInProgressDialog(ExportingCustomersTxt);
        TotalNumberOfCustomers := Customer.Count();
        repeat
            CountOfCustomers += 1;
            UpdateCountInProgressDialog(CountOfCustomers, TotalNumberOfCustomers);

            ExportCustomer(Customer, AuditFileExportHeader);
        until Customer.Next() = 0;
        XmlHelper.FinalizeXmlNode();
    end;

    local procedure ExportCustomer(Customer: Record Customer; AuditFileExportHeader: Record "Audit File Export Header")
    var
        CustomerBankAccount: Record "Customer Bank Account";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        OpeningDebitBalance: Decimal;
        ClosingDebitBalance: Decimal;
        OpeningCreditBalance: Decimal;
        ClosingCreditBalance: Decimal;
        Handled: Boolean;
        FirstName: Text;
        LastName: Text;
    begin
        CustLedgerEntry.SetCurrentKey("Customer No.", "Posting Date");
        CustLedgerEntry.SetRange("Customer No.", Customer."No.");
        CustLedgerEntry.SetRange("Posting Date", AuditFileExportHeader."Starting Date", ClosingDate(AuditFileExportHeader."Ending Date"));
        if CustLedgerEntry.IsEmpty() then
            exit;

        Customer.SetRange("Date Filter", 0D, ClosingDate(AuditFileExportHeader."Starting Date" - 1));
        Customer.CalcFields("Net Change (LCY)");
        if Customer."Net Change (LCY)" > 0 then
            OpeningDebitBalance := Customer."Net Change (LCY)"
        else
            OpeningCreditBalance := -Customer."Net Change (LCY)";
        Customer.SetRange("Date Filter", 0D, ClosingDate(AuditFileExportHeader."Ending Date"));
        Customer.CalcFields("Net Change (LCY)");
        if Customer."Net Change (LCY)" > 0 then
            ClosingDebitBalance := Customer."Net Change (LCY)"
        else
            ClosingCreditBalance := -Customer."Net Change (LCY)";

        XmlHelper.SetCurrentRec(Customer);
        XmlHelper.AddNewXmlNode('Customer', '');
        XmlHelper.AppendXmlNode('RegistrationNumber', Customer."VAT Registration No.");
        XmlHelper.AppendXmlNode('Name', SAFTDataMgt.GetSAFTMiddle2Text(CombineWithSpace(Customer.Name, Customer."Name 2")));
        ExportAddress(
            AddressTxt, CombineWithSpace(Customer.Address, Customer."Address 2"), Customer.City, Customer."Post Code", Customer."Country/Region Code", StreetAddressTxt);
        OnBeforeGetFirstAndLastNameFromCustomer(Handled, FirstName, LastName, Customer);
        if not Handled then
            SAFTDataMgt.GetFirstAndLastNameFromContactName(FirstName, LastName, Customer.Contact);
        ExportContact(FirstName, LastName, Customer."Phone No.", Customer."Fax No.", Customer."E-Mail", Customer."Home Page", Customer."Mobile Phone No.");
        XmlHelper.AfterAppendXmlNode('Contact');

        CustomerBankAccount.SetLoadFields(Name, "Name 2", "Bank Account No.", IBAN, "Bank Branch No.", "Bank Clearing Code", "SWIFT Code", "Currency Code");
        CustomerBankAccount.SetRange("Customer No.", Customer."No.");
        if CustomerBankAccount.FindSet() then
            repeat
                XmlHelper.SetCurrentRec(CustomerBankAccount);
                ExportBankAccount(
                    CombineWithSpace(CustomerBankAccount.Name, CustomerBankAccount."Name 2"),
                    CustomerBankAccount."Bank Account No.", CustomerBankAccount.IBAN,
                    CustomerBankAccount."Bank Branch No.", CustomerBankAccount."Bank Clearing Code");
            until CustomerBankAccount.Next() = 0;
        XmlHelper.SetCurrentRec(Customer);
        XmlHelper.AfterAppendXmlNode('BankAccount');

        XmlHelper.AppendXmlNode('CustomerID', Customer."No.");
        XmlHelper.AppendXmlNode('AccountID', GetReceivablesAccount(Customer."Customer Posting Group"));

        if OpeningDebitBalance = 0 then
            XmlHelper.AppendXmlNode('OpeningCreditBalance', SAFTDataMgt.GetSAFTMonetaryDecimal(OpeningCreditBalance))
        else
            XmlHelper.AppendXmlNode('OpeningDebitBalance', SAFTDataMgt.GetSAFTMonetaryDecimal(OpeningDebitBalance));
        if ClosingDebitBalance = 0 then
            XmlHelper.AppendXmlNode('ClosingCreditBalance', SAFTDataMgt.GetSAFTMonetaryDecimal(ClosingCreditBalance))
        else
            XmlHelper.AppendXmlNode('ClosingDebitBalance', SAFTDataMgt.GetSAFTMonetaryDecimal(ClosingDebitBalance));

        XmlHelper.FinalizeXmlNode();
    end;

    local procedure ExportVendors(AuditFileExportHeader: Record "Audit File Export Header")
    var
        Vendor: Record Vendor;
        TotalNumberOfVendors: Integer;
        CountOfVendors: Integer;
    begin
        Vendor.SetLoadFields(
            "No.", Name, "Name 2", "VAT Registration No.", Address, "Address 2", City, "Post Code", "Country/Region Code", Contact,
            "Phone No.", "Fax No.", "E-Mail", "Home Page", "Vendor Posting Group", "Currency Code", "Payment Terms Code");
        if not Vendor.FindSet() then
            exit;

        XmlHelper.AddNewXmlNode('Suppliers', '');
        UpdateDataSourceInProgressDialog(ExportingVendorsTxt);
        TotalNumberOfVendors := Vendor.Count();
        repeat
            CountOfVendors += 1;
            UpdateCountInProgressDialog(CountOfVendors, TotalNumberOfVendors);

            ExportVendor(Vendor, AuditFileExportHeader);
        until Vendor.Next() = 0;
        XmlHelper.FinalizeXmlNode();
    end;

    local procedure ExportVendor(Vendor: Record Vendor; AuditFileExportHeader: Record "Audit File Export Header")
    var
        VendorBankAccount: Record "Vendor Bank Account";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        OpeningDebitBalance: Decimal;
        ClosingDebitBalance: Decimal;
        OpeningCreditBalance: Decimal;
        ClosingCreditBalance: Decimal;
        Handled: Boolean;
        FirstName: Text;
        LastName: Text;
    begin
        VendorLedgerEntry.SetCurrentKey("Vendor No.", "Posting Date");
        VendorLedgerEntry.SetRange("Vendor No.", Vendor."No.");
        VendorLedgerEntry.SetRange("Posting Date", AuditFileExportHeader."Starting Date", ClosingDate(AuditFileExportHeader."Ending Date"));
        if VendorLedgerEntry.IsEmpty() then
            exit;

        Vendor.SetRange("Date Filter", 0D, ClosingDate(AuditFileExportHeader."Starting Date" - 1));
        Vendor.CalcFields("Net Change (LCY)");
        if Vendor."Net Change (LCY)" > 0 then
            OpeningCreditBalance := Vendor."Net Change (LCY)"
        else
            OpeningDebitBalance := -Vendor."Net Change (LCY)";
        Vendor.SetRange("Date Filter", 0D, ClosingDate(AuditFileExportHeader."Ending Date"));
        Vendor.CalcFields("Net Change (LCY)");
        if Vendor."Net Change (LCY)" > 0 then
            ClosingCreditBalance := Vendor."Net Change (LCY)"
        else
            ClosingDebitBalance := -Vendor."Net Change (LCY)";

        XmlHelper.SetCurrentRec(Vendor);
        XmlHelper.AddNewXmlNode('Supplier', '');
        XmlHelper.AppendXmlNode('RegistrationNumber', Vendor."VAT Registration No.");
        XmlHelper.AppendXmlNode('Name', SAFTDataMgt.GetSAFTMiddle2Text(CombineWithSpace(Vendor.Name, Vendor."Name 2")));
        ExportAddress(
            AddressTxt, CombineWithSpace(Vendor.Address, Vendor."Address 2"), Vendor.City, Vendor."Post Code", Vendor."Country/Region Code", StreetAddressTxt);
        OnBeforeGetFirstAndLastNameFromVendor(Handled, FirstName, LastName, Vendor);
        if not Handled then
            SAFTDataMgt.GetFirstAndLastNameFromContactName(FirstName, LastName, Vendor.Contact);
        ExportContact(FirstName, LastName, Vendor."Phone No.", Vendor."Fax No.", Vendor."E-Mail", Vendor."Home Page", Vendor."Mobile Phone No.");
        XmlHelper.AfterAppendXmlNode('Contact');

        VendorBankAccount.SetLoadFields(Name, "Name 2", "Bank Account No.", IBAN, "Bank Branch No.", "Bank Clearing Code", "SWIFT Code", "Currency Code");
        VendorBankAccount.SetRange("Vendor No.", Vendor."No.");
        if VendorBankAccount.FindSet() then
            repeat
                XmlHelper.SetCurrentRec(VendorBankAccount);
                ExportBankAccount(
                    CombineWithSpace(VendorBankAccount.Name, VendorBankAccount."Name 2"),
                    VendorBankAccount."Bank Account No.", VendorBankAccount.IBAN,
                    VendorBankAccount."Bank Branch No.", VendorBankAccount."Bank Clearing Code");
            until VendorBankAccount.Next() = 0;
        XmlHelper.SetCurrentRec(Vendor);
        XmlHelper.AfterAppendXmlNode('BankAccount');

        XmlHelper.AppendXmlNode('SupplierID', Vendor."No.");
        XmlHelper.AppendXmlNode('AccountID', GetPayablesAccount(Vendor."Vendor Posting Group"));

        if OpeningDebitBalance = 0 then
            XmlHelper.AppendXmlNode('OpeningCreditBalance', SAFTDataMgt.GetSAFTMonetaryDecimal(OpeningCreditBalance))
        else
            XmlHelper.AppendXmlNode('OpeningDebitBalance', SAFTDataMgt.GetSAFTMonetaryDecimal(OpeningDebitBalance));
        if ClosingDebitBalance = 0 then
            XmlHelper.AppendXmlNode('ClosingCreditBalance', SAFTDataMgt.GetSAFTMonetaryDecimal(ClosingCreditBalance))
        else
            XmlHelper.AppendXmlNode('ClosingDebitBalance', SAFTDataMgt.GetSAFTMonetaryDecimal(ClosingDebitBalance));

        XmlHelper.FinalizeXmlNode();
    end;

    local procedure ExportTaxTable()
    var
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        if not VATPostingSetup.FindSet() then
            exit;

        UpdateDataSourceInProgressDialog(ExportingVATPostingSetupTxt);
        UpdateProgressDialog(2, '');

        XmlHelper.AddNewXmlNode('TaxTable', '');
        XmlHelper.AddNewXmlNode('TaxTableEntry', '');
        XmlHelper.AppendXmlNode('TaxType', TaxTypeVATTxt);
        XmlHelper.AppendXmlNode('Description', '');

        repeat
            ExportTaxCodeDetails(VATPostingSetup);
        until VATPostingSetup.Next() = 0;

        XmlHelper.FinalizeXmlNode();
        XmlHelper.FinalizeXmlNode();
    end;

    local procedure ExportTaxCodeDetails(var VATPostingSetup: Record "VAT Posting Setup")
    var
        VATAccountType: Option Sales,Purchase;
    begin
        if VATPostingSetup."Sales VAT Account" <> '' then
            ExportTaxCodeDetail(VATPostingSetup, VATAccountType::Sales);
        if VATPostingSetup."Purchase VAT Account" <> '' then
            ExportTaxCodeDetail(VATPostingSetup, VATAccountType::Purchase);
    end;

    local procedure ExportTaxCodeDetail(var VATPostingSetup: Record "VAT Posting Setup"; VATAccountType: Option Sales,Purchase)
    var
        CompanyInformation: Record "Company Information";
        TaxCode: Code[9];
        StandardTaxCode: Text;
        Params: Dictionary of [Text, Text];
    begin
        case VATAccountType of
            VATAccountType::Sales:
                begin
                    TaxCode := VATPostingSetup."Sales Tax Code SAF-T";
                    StandardTaxCode := SAFTDataMgt.GetSAFTCodeText(VATPostingSetup."Sale VAT Reporting Code");
                end;
            VATAccountType::Purchase:
                begin
                    TaxCode := VATPostingSetup."Purchase Tax Code SAF-T";
                    StandardTaxCode := SAFTDataMgt.GetSAFTCodeText(VATPostingSetup."Purch. VAT Reporting Code");
                end;
        end;

        CompanyInformation.SetLoadFields("Country/Region Code");
        CompanyInformation.Get();

        Params.Add('StandardTaxCode', StandardTaxCode);
        XmlHelper.SetAdditionalParams(Params);

        XmlHelper.SetCurrentRec(VATPostingSetup);
        XmlHelper.AddNewXmlNode('TaxCodeDetails', '');
        XmlHelper.AppendXmlNode('TaxCode', TaxCode);
        XmlHelper.AppendXmlNode('EffectiveDate', FormatDate(VATPostingSetup."Starting Date"));
        XmlHelper.AppendXmlNode('Description', VATPostingSetup.Description);
        XmlHelper.AppendXmlNode('TaxPercentage', FormatAmount(VATPostingSetup."VAT %"));
        XmlHelper.AppendXmlNode('Country', SAFTDataMgt.GetISOCountryCode(CompanyInformation."Country/Region Code"));

        XmlHelper.FinalizeXmlNode();
    end;

    local procedure ExportAnalysisTypeTable()
    var
        Dimension: Record Dimension;
        DimensionValue: Record "Dimension Value";
        PrevDimensionCode: Code[20];
    begin
        if not DimensionValue.FindSet() then
            exit;
        UpdateDataSourceInProgressDialog(ExportingDimensionsTxt);
        UpdateProgressDialog(2, '');

        PrevDimensionCode := '';
        XmlHelper.AddNewXmlNode('AnalysisTypeTable', '');
        repeat
            if DimensionValue."Dimension Code" <> PrevDimensionCode then begin
                Dimension.Get(DimensionValue."Dimension Code");
                PrevDimensionCode := Dimension.Code;
            end;
            if Dimension."SAF-T Export" then begin
                XmlHelper.SetCurrentRec(DimensionValue);
                XmlHelper.AddNewXmlNode('AnalysisTypeTableEntry', '');
                XmlHelper.AppendXmlNode('AnalysisType', Dimension."Analysis Type SAF-T");
                XmlHelper.AppendXmlNode('AnalysisTypeDescription', Dimension.Name);
                XmlHelper.AppendXmlNode('AnalysisID', DimensionValue.Code);
                XmlHelper.AppendXmlNode('AnalysisIDDescription', DimensionValue.Name);
                XmlHelper.FinalizeXmlNode();
            end;
        until DimensionValue.Next() = 0;
        XmlHelper.FinalizeXmlNode();
    end;

    local procedure ExportMovementTypeTable()
    var
        CurrItemLedgerEntryType: Enum "Item Ledger Entry Type";
    begin
        if Enum::"Item Ledger Entry Type".Ordinals().Count = 0 then
            exit;
        UpdateDataSourceInProgressDialog(ExportingMovementTypesTxt);
        UpdateProgressDialog(2, '');

        XmlHelper.AddNewXmlNode('MovementTypeTable', '');
        foreach CurrItemLedgerEntryType in Enum::"Item Ledger Entry Type".Ordinals() do begin
            XmlHelper.AddNewXmlNode('MovementTypeTableEntry', '');
            XmlHelper.AppendXmlNode('MovementType', Format(CurrItemLedgerEntryType.AsInteger()));
            XmlHelper.AppendXmlNode('Description', Format(CurrItemLedgerEntryType));
            XmlHelper.FinalizeXmlNode();
        end;
        XmlHelper.FinalizeXmlNode();
    end;

    local procedure ExportProducts()
    var
        Item: Record Item;
        ItemReference: Record "Item Reference";
        Resource: Record Resource;
        Params: Dictionary of [Text, Text];
        ProductNumberCode: Text;
        ValuationMethod: Text;
        IsService: Boolean;
    begin
        if not Item.FindSet() and not Resource.FindSet() then
            exit;
        UpdateDataSourceInProgressDialog(ExportingProductsTxt);
        UpdateProgressDialog(2, '');

        XmlHelper.AddNewXmlNode('Products', '');

        Item.SetLoadFields(Type, "Item Category Code", Description, "Tariff No.", "Base Unit of Measure", "Costing Method", "VAT Prod. Posting Group");
        repeat
            IsService := (Item.Type = "Item Type"::Service) or (Item.Type = "Item Type"::"Non-Inventory");
            if not IsService then
                ValuationMethod := Format(Item."Costing Method");
            Clear(Params);
            Params.Add('IsService', Format(IsService));
            XmlHelper.SetAdditionalParams(Params);

            ItemReference.SetRange("Item No.", Item."No.");
            ItemReference.SetRange("Reference Type", ItemReference."Reference Type"::"Bar Code");
            ItemReference.SetFilter("Reference No.", '<>%1', '');
            if ItemReference.FindFirst() then;
            ProductNumberCode := ItemReference."Reference No.";

            XmlHelper.SetCurrentRec(Item);
            XmlHelper.AddNewXmlNode('Product', '');
            XmlHelper.AppendXmlNode('ProductCode', Item."No.");
            XmlHelper.AppendXmlNode('GoodsServicesID', SAFTDataMgt.GetGoodsServicesID(IsService));
            XmlHelper.AppendXmlNode('ProductGroup', Item."Item Category Code");
            XmlHelper.AppendXmlNode('Description', Item.Description);
            XmlHelper.AppendXmlNode('ProductCommodityCode', Item."Tariff No.");
            XmlHelper.AppendXmlNode('ProductNumberCode', ProductNumberCode);
            XmlHelper.AppendXmlNode('ValuationMethod', SAFTDataMgt.GetSAFTCodeText(ValuationMethod));
            XmlHelper.AppendXmlNode('UOMBase', SAFTDataMgt.GetSAFTCodeText(Item."Base Unit of Measure"));
            XmlHelper.AddNewXmlNode('Tax', '');
            XmlHelper.AppendXmlNode('TaxType', 'VAT');
            XmlHelper.AppendXmlNode('TaxCode', SAFTDataMgt.GetSAFTCodeText(Item."VAT Prod. Posting Group"));
            XmlHelper.FinalizeXmlNode();
            XmlHelper.FinalizeXmlNode();
        until Item.Next() = 0;

        Resource.SetLoadFields("Resource Group No.", Name, "Base Unit of Measure", "VAT Prod. Posting Group");
        repeat
            IsService := true;
            Clear(Params);
            Params.Add('IsService', Format(IsService));
            XmlHelper.SetAdditionalParams(Params);

            XmlHelper.SetCurrentRec(Resource);
            XmlHelper.AddNewXmlNode('Product', '');
            XmlHelper.AppendXmlNode('ProductCode', Resource."No.");
            XmlHelper.AppendXmlNode('GoodsServicesID', SAFTDataMgt.GetGoodsServicesID(IsService));
            XmlHelper.AppendXmlNode('ProductGroup', Resource."Resource Group No.");
            XmlHelper.AppendXmlNode('Description', Resource.Name);
            XmlHelper.AppendXmlNode('UOMBase', SAFTDataMgt.GetSAFTCodeText(Resource."Base Unit of Measure"));
            XmlHelper.AddNewXmlNode('Tax', '');
            XmlHelper.AppendXmlNode('TaxType', 'VAT');
            XmlHelper.AppendXmlNode('TaxCode', SAFTDataMgt.GetSAFTCodeText(Resource."VAT Prod. Posting Group"));
            XmlHelper.FinalizeXmlNode();
            XmlHelper.FinalizeXmlNode();
        until Resource.Next() = 0;

        XmlHelper.FinalizeXmlNode();
    end;

    local procedure ExportUOMTable()
    var
        UnitOfMeasure: Record "Unit of Measure";
    begin
        if not UnitOfMeasure.FindSet() then
            exit;
        UpdateDataSourceInProgressDialog(ExportingUOMTxt);
        UpdateProgressDialog(2, '');

        XmlHelper.AddNewXmlNode('UOMTable', '');
        repeat
            XmlHelper.SetCurrentRec(UnitOfMeasure);
            XmlHelper.AddNewXmlNode('UOMTableEntry', '');
            XmlHelper.AppendXmlNode('UnitOfMeasure', SAFTDataMgt.GetSAFTCodeText(UnitOfMeasure.Code));
            XmlHelper.AppendXmlNode('Description', UnitOfMeasure.Description);
            XmlHelper.FinalizeXmlNode();
        until UnitOfMeasure.Next() = 0;
        XmlHelper.FinalizeXmlNode();
    end;

    local procedure ExportPhysicalStock(AuditFileExportHeader: Record "Audit File Export Header")
    var
        Item: Record Item;
        TempItemLedgerEntryStart: Record "Item Ledger Entry" temporary;
        TempItemLedgerEntryEnd: Record "Item Ledger Entry" temporary;
        QtyItemLedgerEntrySAFT: Query "Qty. Item Ledger Entry SAF-T";
        StockAccountNo: Text;
        ProductStatus: Text;
        OpeningStockQuantity: Decimal;
        ClosingStockQuantity: Decimal;
    begin
        // Quantity in the beginning of the period
        QtyItemLedgerEntrySAFT.SetFilter(Posting_Date_Filter, '<%1', AuditFileExportHeader."Starting Date");
        QtyItemLedgerEntrySAFT.Open();
        while QtyItemLedgerEntrySAFT.Read() do
            if QtyItemLedgerEntrySAFT.Quantity > 0 then begin
                TempItemLedgerEntryStart."Entry No." := QtyItemLedgerEntrySAFT.Entry_No_;
                TempItemLedgerEntryStart.Quantity := QtyItemLedgerEntrySAFT.Quantity;
                TempItemLedgerEntryStart.Insert();
            end;

        // Quantity in the end of the period
        Clear(QtyItemLedgerEntrySAFT);
        QtyItemLedgerEntrySAFT.SetFilter(Posting_Date_Filter, '<=%1', AuditFileExportHeader."Ending Date");
        QtyItemLedgerEntrySAFT.Open();
        while QtyItemLedgerEntrySAFT.Read() do begin
            TempItemLedgerEntryEnd."Entry No." := QtyItemLedgerEntrySAFT.Entry_No_;
            TempItemLedgerEntryEnd."Location Code" := QtyItemLedgerEntrySAFT.Location_Code;
            TempItemLedgerEntryEnd."Item No." := QtyItemLedgerEntrySAFT.Item_No_;
            TempItemLedgerEntryEnd."Lot No." := QtyItemLedgerEntrySAFT.Lot_No_;
            TempItemLedgerEntryEnd."Serial No." := QtyItemLedgerEntrySAFT.Serial_No_;
            TempItemLedgerEntryEnd.Quantity := QtyItemLedgerEntrySAFT.Quantity;
            TempItemLedgerEntryEnd.Insert();
        end;

        TempItemLedgerEntryEnd.SetFilter(Quantity, '<>%1', 0);
        if TempItemLedgerEntryStart.IsEmpty() and TempItemLedgerEntryEnd.IsEmpty() then
            exit;

        UpdateDataSourceInProgressDialog(ExportingPhysicalStockTxt);
        UpdateProgressDialog(2, '');

        XmlHelper.AddNewXmlNode('PhysicalStock', '');

        TempItemLedgerEntryEnd.Reset();
        TempItemLedgerEntryEnd.FindSet();
        repeat
            OpeningStockQuantity := 0;
            if TempItemLedgerEntryStart.Get(TempItemLedgerEntryEnd."Entry No.") then
                OpeningStockQuantity := TempItemLedgerEntryStart.Quantity;

            ClosingStockQuantity := 0;
            if TempItemLedgerEntryEnd.Quantity > 0 then
                ClosingStockQuantity := TempItemLedgerEntryEnd.Quantity;

            if (OpeningStockQuantity > 0) or (ClosingStockQuantity > 0) then begin
                Item.SetLoadFields(Blocked, "Inventory Posting Group", "Base Unit of Measure", "Unit Price");
                Item.Get(TempItemLedgerEntryEnd."Item No.");
                if Item.Blocked then
                    ProductStatus := 'Discontinued'
                else
                    ProductStatus := 'Normal';

                StockAccountNo := TempItemLedgerEntryEnd."Serial No.";
                if StockAccountNo = '' then
                    StockAccountNo := TempItemLedgerEntryEnd."Lot No.";
                if StockAccountNo = '' then
                    StockAccountNo := TempItemLedgerEntryEnd."Item No.";

                XmlHelper.SetCurrentRec(TempItemLedgerEntryEnd);
                XmlHelper.AddNewXmlNode('PhysicalStockEntry', '');
                XmlHelper.AppendXmlNode('WarehouseID', TempItemLedgerEntryEnd."Location Code");
                XmlHelper.AppendXmlNode('ProductCode', TempItemLedgerEntryEnd."Item No.");
                XmlHelper.AppendXmlNode('StockAccountNo', StockAccountNo);
                XmlHelper.AppendXmlNode('ProductType', SAFTDataMgt.GetSAFTShortText(Item."Inventory Posting Group"));
                XmlHelper.AppendXmlNode('ProductStatus', SAFTDataMgt.GetSAFTShortText(ProductStatus));
                XmlHelper.AppendXmlNode('UOMPhysicalStock', SAFTDataMgt.GetSAFTCodeText(Item."Base Unit of Measure"));
                XmlHelper.AppendXmlNode('UOMToUOMBaseConversionFactor', FormatAmount(1));       // Quantity in Item Ledger Entry is always in Base Unit of Measure
                XmlHelper.AppendXmlNode('UnitPrice', SAFTDataMgt.GetSAFTMonetaryDecimal(Item."Unit Price"));
                XmlHelper.AppendXmlNode('OpeningStockQuantity', FormatAmount(OpeningStockQuantity));
                XmlHelper.AppendXmlNode('ClosingStockQuantity', FormatAmount(ClosingStockQuantity));

                ExportStockCharacteristics(TempItemLedgerEntryEnd."Item No.");

                XmlHelper.FinalizeXmlNode();
            end;
        until TempItemLedgerEntryEnd.Next() = 0;

        XmlHelper.FinalizeXmlNode();
    end;

    local procedure ExportStockCharacteristics(ItemNo: Code[20])
    var
        ItemAttribute: Record "Item Attribute";
        ItemAttributeValueMapping: Record "Item Attribute Value Mapping";
        ItemAttributeValue: Record "Item Attribute Value";
    begin
        ItemAttributeValueMapping.SetRange("Table ID", DATABASE::Item);
        ItemAttributeValueMapping.SetRange("No.", ItemNo);
        if not ItemAttributeValueMapping.FindSet() then
            exit;

        XmlHelper.AddNewXmlNode('StockCharacteristics', '');
        repeat
            ItemAttribute.Get(ItemAttributeValueMapping."Item Attribute ID");
            ItemAttributeValue.Get(ItemAttributeValueMapping."Item Attribute ID", ItemAttributeValueMapping."Item Attribute Value ID");
            XmlHelper.AppendXmlNode('StockCharacteristic', SAFTDataMgt.GetSAFTShortText(ItemAttribute.Name));
            XmlHelper.AppendXmlNode('StockCharacteristicValue', SAFTDataMgt.GetSAFTMiddle1Text(ItemAttributeValue.Value));
        until ItemAttributeValueMapping.Next() = 0;
        XmlHelper.FinalizeXmlNode();
    end;

    local procedure ExportAssets(AuditFileExportHeader: Record "Audit File Export Header")
    var
        FixedAsset: Record "Fixed Asset";
        FAPostingGroup: Record "FA Posting Group";
        FALedgerEntry: Record "FA Ledger Entry";
        VendorNo: Code[20];
    begin
        if not FixedAsset.FindSet() then
            exit;
        UpdateDataSourceInProgressDialog(ExportingAssetsTxt);
        UpdateProgressDialog(2, '');

        XmlHelper.AddNewXmlNode('Assets', '');

        repeat
            FAPostingGroup.SetLoadFields("Acquisition Cost Account");
            FAPostingGroup.Get(FixedAsset."FA Posting Group");

            SAFTDataMgt.GetFixedAssetAcquisitionLedgerEntry(FALedgerEntry, FixedAsset."No.");
            VendorNo := SAFTDataMgt.GetFixedAssetAcquisitionVendorNo(FALedgerEntry);

            XmlHelper.SetCurrentRec(FixedAsset);
            XmlHelper.AddNewXmlNode('Asset', '');
            XmlHelper.AppendXmlNode('AssetID', FixedAsset."No.");
            XmlHelper.AppendXmlNode('AccountID', FAPostingGroup."Acquisition Cost Account");
            XmlHelper.AppendXmlNode('Description', FixedAsset.Description);

            ExportAssetSupplier(VendorNo);

            XmlHelper.SetCurrentRec(FALedgerEntry);
            XmlHelper.AppendXmlNode('PurchaseOrderDate', FormatDate(FALedgerEntry."Document Date"));
            XmlHelper.AppendXmlNode('DateOfAcquisition', FormatDate(FALedgerEntry."Posting Date"));
            XmlHelper.AppendXmlNode('StartUpDate', FormatDate(FALedgerEntry."Depreciation Starting Date"));

            ExportAssetValuations(FixedAsset, AuditFileExportHeader);

            XmlHelper.FinalizeXmlNode();
        until FixedAsset.Next() = 0;
        XmlHelper.FinalizeXmlNode();
    end;

    local procedure ExportAssetSupplier(VendorNo: Code[20])
    var
        Vendor: Record Vendor;
    begin
        Vendor.SetLoadFields(Name, "Name 2", Address, "Address 2", City, "Post Code", "Country/Region Code");
        if not Vendor.Get(VendorNo) then
            exit;

        XmlHelper.SetCurrentRec(Vendor);
        XmlHelper.AddNewXmlNode('Supplier', '');
        XmlHelper.AppendXmlNode('SupplierName', SAFTDataMgt.GetSAFTMiddle2Text(CombineWithSpace(Vendor.Name, Vendor."Name 2")));
        XmlHelper.AppendXmlNode('SupplierID', Vendor."No.");
        ExportAddress(
            PostalAddressTxt, CombineWithSpace(Vendor.Address, Vendor."Address 2"), Vendor.City, Vendor."Post Code", Vendor."Country/Region Code", PostalAddressTxt);
        XmlHelper.FinalizeXmlNode();
    end;

    local procedure ExportAssetValuations(var FixedAsset: Record "Fixed Asset"; var AuditFileExportHeader: Record "Audit File Export Header")
    var
        FADepreciationBook: Record "FA Depreciation Book";
        FALedgerEntry: Record "FA Ledger Entry";
        AcquisitionCostBegin: Decimal;
        AcquisitionCostEnd: Decimal;
        InvestmentSupport: Decimal;
        AssetDisposal: Decimal;
        BookValueBegin: Decimal;
        DepreciationPercentage: Decimal;
        DepreciationForPeriod: Decimal;
        AppreciationForPeriod: Decimal;
        AccumulatedDepreciation: Decimal;
        BookValueEnd: Decimal;
    begin
        FADepreciationBook.SetRange("FA No.", FixedAsset."No.");
        if not FADepreciationBook.FindSet() then
            exit;

        XmlHelper.AddNewXmlNode('Valuations', '');
        repeat
            FALedgerEntry.SetRange("FA No.", FADepreciationBook."FA No.");

            FALedgerEntry.SetRange("FA Posting Type", "FA Ledger Entry FA Posting Type"::"Acquisition Cost");
            FALedgerEntry.SetRange("Gen. Posting Type", "General Posting Type"::Purchase);
            FALedgerEntry.SetFilter("Posting Date", '<%1', AuditFileExportHeader."Starting Date");
            FALedgerEntry.CalcSums("Amount (LCY)");
            AcquisitionCostBegin := FALedgerEntry."Amount (LCY)";

            FALedgerEntry.SetRange("FA Posting Type", "FA Ledger Entry FA Posting Type"::"Acquisition Cost");
            FALedgerEntry.SetFilter("Posting Date", '<=%1', AuditFileExportHeader."Ending Date");
            FALedgerEntry.CalcSums("Amount (LCY)");
            AcquisitionCostEnd := FALedgerEntry."Amount (LCY)";

            FALedgerEntry.SetRange("FA Posting Type", "FA Ledger Entry FA Posting Type"::"Proceeds on Disposal");
            FALedgerEntry.SetRange("Posting Date", AuditFileExportHeader."Starting Date", AuditFileExportHeader."Ending Date");
            FALedgerEntry.CalcSums("Amount (LCY)");
            AssetDisposal := FALedgerEntry."Amount (LCY)";

            FALedgerEntry.SetRange("FA Posting Type", "FA Ledger Entry FA Posting Type"::Depreciation);
            FALedgerEntry.SetRange("Posting Date", AuditFileExportHeader."Starting Date", AuditFileExportHeader."Ending Date");
            FALedgerEntry.CalcSums("Amount (LCY)");
            DepreciationForPeriod := FALedgerEntry."Amount (LCY)";

            FALedgerEntry.SetRange("FA Posting Type", "FA Ledger Entry FA Posting Type"::Depreciation);
            FALedgerEntry.SetRange("Posting Date");
            FALedgerEntry.CalcSums("Amount (LCY)");
            AccumulatedDepreciation := FALedgerEntry."Amount (LCY)";

            FALedgerEntry.SetRange("FA Posting Type", "FA Ledger Entry FA Posting Type"::Appreciation);
            FALedgerEntry.SetRange("Posting Date", AuditFileExportHeader."Starting Date", AuditFileExportHeader."Ending Date");
            FALedgerEntry.CalcSums("Amount (LCY)");
            AppreciationForPeriod := FALedgerEntry."Amount (LCY)";

            FALedgerEntry.SetRange("FA Posting Type");
            FALedgerEntry.SetFilter("Posting Date", '<%1', AuditFileExportHeader."Starting Date");
            FALedgerEntry.CalcSums("Amount (LCY)");
            BookValueBegin := FALedgerEntry."Amount (LCY)";

            FALedgerEntry.SetRange("FA Posting Type");
            FALedgerEntry.SetFilter("Posting Date", '<=%1', AuditFileExportHeader."Ending Date");
            FALedgerEntry.CalcSums("Amount (LCY)");
            BookValueEnd := FALedgerEntry."Amount (LCY)";

            FALedgerEntry.SetRange("FA Posting Type");
            FALedgerEntry.SetRange("Posting Date");
            FALedgerEntry.SetFilter("Amount (LCY)", '>%1', 0);
            FALedgerEntry.CalcSums("Amount (LCY)");
            InvestmentSupport := FALedgerEntry."Amount (LCY)";

            DepreciationPercentage := 0;
            if (FADepreciationBook."Depreciation Method" = "FA Depreciation Method"::"Straight-Line") and
                not FADepreciationBook."Use Half-Year Convention"
            then
                if FADepreciationBook."No. of Depreciation Years" <> 0 then
                    DepreciationPercentage := 100 / FADepreciationBook."No. of Depreciation Years";

            XmlHelper.SetCurrentRec(FADepreciationBook);
            XmlHelper.AddNewXmlNode('Valuation', '');
            XmlHelper.AppendXmlNode('AssetValuationType', FADepreciationBook."Depreciation Book Code");
            XmlHelper.AppendXmlNode('ValuationClass', FixedAsset."FA Class Code");
            XmlHelper.AppendXmlNode('AcquisitionAndProductionCostsBegin', SAFTDataMgt.GetSAFTMonetaryDecimal(AcquisitionCostBegin));
            XmlHelper.AppendXmlNode('AcquisitionAndProductionCostsEnd', SAFTDataMgt.GetSAFTMonetaryDecimal(AcquisitionCostEnd));
            XmlHelper.AppendXmlNode('InvestmentSupport', SAFTDataMgt.GetSAFTMonetaryDecimal(InvestmentSupport));
            XmlHelper.AppendXmlNode('AssetLifeYear', FormatAmount(FADepreciationBook."No. of Depreciation Years"));
            XmlHelper.AppendXmlNode('AssetAddition', SAFTDataMgt.GetSAFTMonetaryDecimal(AcquisitionCostEnd - AcquisitionCostBegin));
            XmlHelper.AppendXmlNode('AssetDisposal', SAFTDataMgt.GetSAFTMonetaryDecimal(AssetDisposal));
            XmlHelper.AppendXmlNode('BookValueBegin', SAFTDataMgt.GetSAFTMonetaryDecimal(BookValueBegin));
            XmlHelper.AppendXmlNode('DepreciationMethod', SAFTDataMgt.GetSAFTMiddle1Text(Format(FADepreciationBook."Depreciation Method")));
            XmlHelper.AppendXMLNodeIfNotZero('DepreciationPercentage', DepreciationPercentage);
            XmlHelper.AppendXmlNode('DepreciationForPeriod', SAFTDataMgt.GetSAFTMonetaryDecimal(DepreciationForPeriod));
            XmlHelper.AppendXmlNode('AppreciationForPeriod', SAFTDataMgt.GetSAFTMonetaryDecimal(AppreciationForPeriod));
            XmlHelper.AppendXmlNode('AccumulatedDepreciation', SAFTDataMgt.GetSAFTMonetaryDecimal(AccumulatedDepreciation));
            XmlHelper.AppendXmlNode('BookValueEnd', SAFTDataMgt.GetSAFTMonetaryDecimal(BookValueEnd));
            XmlHelper.FinalizeXmlNode();
        until FADepreciationBook.Next() = 0;
        XmlHelper.FinalizeXmlNode();
    end;

    local procedure ExportGeneralLedgerEntries(var AuditFileExportHeader: Record "Audit File Export Header"; AuditFileExportLine: Record "Audit File Export Line")
    var
        GLEntry: Record "G/L Entry";
        SourceCodeSAFT: Record "Source Code SAF-T";
        SourceCode: Record "Source Code";
        MappingHelperSAFT: Codeunit "Mapping Helper SAF-T";
        SourceCodeFilter: Text;
        TotalCount: Integer;
        NumberOfEntries: Integer;
    begin
        GLEntry.SetRange("Posting Date", AuditFileExportLine."Starting Date", AuditFileExportLine."Ending Date");
        if GLEntry.IsEmpty() then
            exit;

        UpdateDataSourceInProgressDialog(ExportingGLEntriesTxt);
        TotalCount := GLEntry.Count();

        XmlHelper.AddNewXmlNode('GeneralLedgerEntries', '');
        XmlHelper.AppendXMLNode('NumberOfEntries', FormatAmount(AuditFileExportHeader."Number of G/L Entries"));
        XmlHelper.AppendXMLNode('TotalDebit', FormatAmount(AuditFileExportHeader."Total G/L Entry Debit"));
        XmlHelper.AppendXMLNode('TotalCredit', FormatAmount(AuditFileExportHeader."Total G/L Entry Credit"));

        if SourceCodeSAFT.FindSet() then
            repeat
                SourceCodeFilter := '';

                SourceCode.SetRange("Source Code SAF-T", SourceCodeSAFT.Code);
                if SourceCode.FindSet() then
                    repeat
                        SourceCodeFilter += (SourceCode.Code + '|');
                    until SourceCode.Next() = 0;
                if SourceCodeSAFT."Includes No Source Code" then
                    SourceCodeFilter += ''' ''';
                SourceCodeFilter := SourceCodeFilter.TrimEnd('|');

                if SourceCodeSAFT.Code = '' then begin
                    SourceCodeSAFT.Code := MappingHelperSAFT.GetAssortedSourceCodeSAFT();
                    SourceCodeSAFT.Description := MappingHelperSAFT.GetAssortedSourceCodeSAFTDescr();
                end;

                ExportGLEntriesBySourceCode(SourceCodeSAFT, SourceCodeFilter, AuditFileExportHeader, AuditFileExportLine, NumberOfEntries, TotalCount);
            until SourceCodeSAFT.Next() = 0;

        XmlHelper.FinalizeXmlNode();
    end;

    local procedure ExportGLEntriesBySourceCode(SourceCodeSAFT: Record "Source Code SAF-T"; SourceCodeFilter: Text; var AuditFileExportHeader: Record "Audit File Export Header"; AuditFileExportLine: Record "Audit File Export Line"; var NumberOfEntries: Integer; TotalCount: Integer)
    var
        GLEntry: Record "G/L Entry";
        GLEntrySAFT: Query "G/L Entry SAF-T";
        CurrencyCode: Code[10];
        ExchangeRate: Decimal;
        PrevTransactionID: Text;
        CurrentTransactionID: Text;
        GLEntriesExist: Boolean;
    begin
        if SourceCodeFilter = '' then
            exit;

        GLEntrySAFT.SetFilter(Posting_Date_Filter, '%1..%2', AuditFileExportLine."Starting Date", AuditFileExportLine."Ending Date");
        GLEntrySAFT.SetFilter(Source_Code, SourceCodeFilter);
        GLEntrySAFT.Open();
        GLEntriesExist := GLEntrySAFT.Read();       // read the first row
        if not GLEntriesExist then
            exit;

        XmlHelper.AddNewXmlNode('Journal', '');
        XmlHelper.AppendXmlNode('JournalID', SourceCodeSAFT.Code);
        XmlHelper.AppendXmlNode('Description', SourceCodeSAFT.Description);
        XmlHelper.AppendXmlNode('Type', SourceCodeSAFT.Code);

        repeat
            NumberOfEntries += 1;
            UpdateCountInProgressDialog(NumberOfEntries, TotalCount);
            CopyQueryFieldsToGLEntry(GLEntrySAFT, GLentry);

            CurrentTransactionID := GetSAFTTransactionID(GLEntry);
            if CurrentTransactionID <> PrevTransactionID then begin
                if PrevTransactionID <> '' then
                    XmlHelper.FinalizeXmlNode();        // close previous Transaction node
                ExportGLEntryTransactionInfo(GLEntry, CurrentTransactionID);
                PrevTransactionID := GetSAFTTransactionID(GLEntry);
                SAFTDataMgt.GetFCYData(CurrencyCode, ExchangeRate, GLEntry, AuditFileExportHeader."Export Currency Information");
            end;

            ExportGLEntryLine(GLEntry, CurrencyCode, ExchangeRate);
        until not GLEntrySAFT.Read();

        if PrevTransactionID <> '' then
            XmlHelper.FinalizeXmlNode();        // close last Transaction node

        if SourceCodeSAFT.Code <> '' then
            XmlHelper.FinalizeXmlNode();                // close Journal node
    end;

    local procedure ExportGLEntryTransactionInfo(GLEntry: Record "G/L Entry"; TransactionID: Text)
    var
        SystemEntryDate: Date;
        TransactionTypeValue: Text;
    begin
        XmlHelper.SetCurrentRec(GLEntry);
        XmlHelper.AddNewXmlNode('Transaction', '');
        XmlHelper.AppendXmlNode('TransactionID', TransactionID);
        XmlHelper.AppendXmlNode('Period', Format(Date2DMY(GLEntry."Posting Date", 2)));
        XmlHelper.AppendXmlNode('PeriodYear', Format(Date2DMY(GLEntry."Posting Date", 3)));
        XmlHelper.AppendXmlNode('TransactionDate', FormatDate(GLEntry."Document Date"));
        XmlHelper.AppendXmlNode('SourceID', SAFTDataMgt.GetSAFTMiddle1Text(GLEntry."User ID"));
        if GLEntry."Document Type" = "Gen. Journal Document Type"::" " then
            TransactionTypeValue := BlankTxt
        else
            TransactionTypeValue := Format(GLEntry."Document Type");
        XmlHelper.AppendXmlNode('TransactionType', SAFTDataMgt.GetSAFTShortText(TransactionTypeValue));
        XmlHelper.AppendXmlNode('Description', GLEntry.Description);
        XmlHelper.AppendXmlNode('BatchID', Format(GLEntry."Transaction No."));
        if GLEntry."Last Modified DateTime" = 0DT then
            SystemEntryDate := GLEntry."Posting Date"
        else
            SystemEntryDate := DT2Date(GLEntry."Last Modified DateTime");
        XmlHelper.AppendXmlNode('SystemEntryDate', FormatDate(SystemEntryDate));
        XmlHelper.AppendXmlNode('GLPostingDate', FormatDate(GLEntry."Posting Date"));
    end;

    local procedure ExportGLEntryLine(var GLEntry: Record "G/L Entry"; CurrencyCode: Code[10]; ExchangeRate: Decimal)
    var
        TempDimIDBuffer: Record "Dimension ID Buffer" temporary;
        VATEntry: Record "VAT Entry";
        GLEntryVATEntryLink: Record "G/L Entry - VAT Entry Link";
        ReceivablesAccount: Code[20];
        PayablesAccount: Code[20];
        AmountXMLNode: Text;
        Amount: Decimal;
    begin
        XmlHelper.SetCurrentRec(GLEntry);
        XmlHelper.AddNewXmlNode('Line', '');
        XmlHelper.AppendXmlNode('RecordID', Format(GLEntry."Entry No."));
        XmlHelper.AppendXmlNode('AccountID', GLEntry."G/L Account No.");
        CopyDimeSetIDToDimIDBuffer(TempDimIDBuffer, GLEntry."Dimension Set ID");
        ExportAnalysisInfo(TempDimIDBuffer);
        if GLEntry."VAT Reporting Date" <> GLEntry."Document Date" then
            XmlHelper.AppendXmlNode('ValueDate', FormatDate(GLEntry."VAT Reporting Date"));
        XmlHelper.AppendXmlNode('SourceDocumentID', GLEntry."Document No.");
        case GLEntry."Source Type" of
            GLEntry."Source Type"::Customer:
                begin
                    if GLEntry."Source No." <> GlobalCustomer."No." then
                        if GlobalCustomer.Get(GLEntry."Source No.") then
                            ReceivablesAccount := GetReceivablesAccount(GlobalCustomer."Customer Posting Group");
                    if GLEntry."G/L Account No." = ReceivablesAccount then
                        XmlHelper.AppendXmlNode('CustomerID', GLEntry."Source No.");
                end;
            GLEntry."Source Type"::Vendor:
                begin
                    if GLEntry."Source No." <> GlobalVendor."No." then
                        if GlobalVendor.Get(GLEntry."Source No.") then
                            PayablesAccount := GetPayablesAccount(GlobalVendor."Vendor Posting Group");
                    if GLEntry."G/L Account No." = PayablesAccount then
                        XmlHelper.AppendXmlNode('SupplierID', GLEntry."Source No.");
                end;
        end;
        if GLEntry.Description = '' then
            GLEntry.Description := GLEntry."G/L Account No.";
        XmlHelper.AppendXmlNode('Description', GLEntry.Description);
        SAFTDataMgt.GetAmountInfoFromGLEntry(AmountXMLNode, Amount, GLEntry);
        ExportAmountWithCurrencyInfo(AmountXMLNode, GLEntry."G/L Account No.", CurrencyCode, ExchangeRate, Amount);
        if (GLEntry."VAT Bus. Posting Group" <> '') or (GLEntry."VAT Prod. Posting Group" <> '') then begin
            GLEntryVATEntryLink.SetRange("G/L Entry No.", GLEntry."Entry No.");
            if GLEntryVATEntryLink.FindFirst() then begin
                VATEntry.SetLoadFields(Type, "VAT Bus. Posting Group", "VAT Prod. Posting Group", Base, Amount);
                VATEntry.Get(GLEntryVATEntryLink."VAT Entry No.");
                ExportTaxInformation(VATEntry, TaxInformationTxt);
            end;
        end;
        XmlHelper.AfterAppendXmlNode('TaxInformation');
        XmlHelper.FinalizeXmlNode();
    end;

    local procedure ExportTaxInformation(var VATEntry: Record "VAT Entry"; TaxInformationTagName: Text)
    var
        VATPostingSetup: Record "VAT Posting Setup";
        Params: Dictionary of [Text, Text];
        TaxCode: Code[9];
        StandardTaxCode: Text;
        IsHandled: Boolean;
    begin
        if not (VATEntry.Type in [VATEntry.Type::Sale, VATEntry.Type::Purchase]) then
            exit;

        VATPostingSetup.SetLoadFields(
            "Sales Tax Code SAF-T", "Sale VAT Reporting Code", "Purchase Tax Code SAF-T", "Purch. VAT Reporting Code", "VAT %");
        VATPostingSetup.Get(VATEntry."VAT Bus. Posting Group", VATEntry."VAT Prod. Posting Group");
        case VATEntry.Type of
            "General Posting Type"::Sale:
                begin
                    TaxCode := VATPostingSetup."Sales Tax Code SAF-T";
                    StandardTaxCode := SAFTDataMgt.GetSAFTCodeText(VATPostingSetup."Sale VAT Reporting Code");
                end;
            "General Posting Type"::Purchase:
                begin
                    TaxCode := VATPostingSetup."Purchase Tax Code SAF-T";
                    StandardTaxCode := SAFTDataMgt.GetSAFTCodeText(VATPostingSetup."Purch. VAT Reporting Code");
                end;
        end;

        Params.Add('StandardTaxCode', StandardTaxCode);
        XmlHelper.SetAdditionalParams(Params);

        XmlHelper.SetCurrentRec(VATEntry);
        XmlHelper.AddNewXmlNode(TaxInformationTagName, '');
        XmlHelper.AppendXmlNode('TaxType', TaxTypeVATTxt);
        XmlHelper.AppendXmlNode('TaxCode', Format(TaxCode));
        XmlHelper.AppendXmlNode('TaxPercentage', FormatAmount(VATPostingSetup."VAT %"));
        XmlHelper.AppendXmlNode('TaxBase', FormatAmount(Abs(VATEntry.Base)));
        IsHandled := false;
        OnBeforeExportVATEntryAmountInfo(XmlHelper, VATEntry, IsHandled);
        if not IsHandled then
            ExportAmountInfo('TaxAmount', Abs(VATEntry.Amount));
        XmlHelper.FinalizeXmlNode();
    end;

    local procedure ExportTaxInformation(TaxCode: Code[9]; StandardTaxCode: Code[20]; VATPercentage: Decimal; TaxBase: Decimal; TaxAmount: Decimal)
    var
        Params: Dictionary of [Text, Text];
    begin
        Params.Add('StandardTaxCode', StandardTaxCode);
        XmlHelper.SetAdditionalParams(Params);

        XmlHelper.AddNewXmlNode(TaxInformationTxt, '');
        XmlHelper.AppendXmlNode('TaxType', TaxTypeVATTxt);
        XmlHelper.AppendXmlNode('TaxCode', Format(TaxCode));
        XmlHelper.AppendXmlNode('TaxPercentage', FormatAmount(VATPercentage));
        XmlHelper.AppendXmlNode('TaxBase', FormatAmount(Abs(TaxBase)));
        ExportAmountInfo('TaxAmount', Abs(TaxAmount));
        XmlHelper.FinalizeXmlNode();
    end;

    local procedure ExportAmountInfo(ParentNodeName: Text; Amount: Decimal)
    begin
        XmlHelper.AddNewXmlNode(ParentNodeName, '');
        XmlHelper.AppendXmlNode('Amount', SAFTDataMgt.GetSAFTMonetaryDecimal(Amount));
        XmlHelper.FinalizeXmlNode();
    end;

    local procedure ExportAmountWithCurrencyInfo(ParentNodeName: Text; GLAccNo: Code[20]; CurrencyCode: Code[10]; ExchangeRate: Decimal; Amount: Decimal)
    var
        ExportAmountWithNoCurrency: Boolean;
    begin
        if CurrencyCode = '' then
            ExportAmountWithNoCurrency := true
        else
            ExportAmountWithNoCurrency := SAFTDataMgt.IsGLAccInCurrencyGainLossAcc(GLAccNo, CurrencyCode);

        if ExportAmountWithNoCurrency then begin
            ExportAmountInfo(ParentNodeName, Amount);
            exit;
        end;

        XmlHelper.AddNewXmlNode(ParentNodeName, '');
        XmlHelper.AppendXmlNode('Amount', SAFTDataMgt.GetSAFTMonetaryDecimal(Amount));
        XmlHelper.AppendXmlNode('CurrencyCode', CurrencyCode);
        XmlHelper.AppendXmlNode('CurrencyAmount', SAFTDataMgt.GetSAFTMonetaryDecimal(Amount / ExchangeRate));
        XmlHelper.AppendXmlNode('ExchangeRate', SAFTDataMgt.GetSAFTExchangeRateDecimal(ExchangeRate));
        XmlHelper.FinalizeXmlNode();
    end;

    local procedure ExportAnalysisInfo(var TempDimIDBuffer: Record "Dimension ID Buffer" temporary)
    begin
        if TempDimIDBuffer.FindSet() then
            repeat
                XmlHelper.AddNewXmlNode('Analysis', '');
                XmlHelper.AppendXmlNode('AnalysisType', TempDimIDBuffer."Dimension Code");
                XmlHelper.AppendXmlNode('AnalysisID', TempDimIDBuffer."Dimension Value");
                XmlHelper.FinalizeXmlNode();
            until TempDimIDBuffer.Next() = 0;
    end;

    local procedure CopyDimeSetIDToDimIDBuffer(var TempDimIDBuffer: Record "Dimension ID Buffer" temporary; DimSetID: Integer)
    var
        TempDimSetEntry: Record "Dimension Set Entry" temporary;
        Dimension: Record Dimension;
        DimensionManagement: Codeunit DimensionManagement;
    begin
        TempDimIDBuffer.Reset();
        TempDimIDBuffer.DeleteAll();
        if DimSetID = 0 then
            exit;

        DimensionManagement.GetDimensionSet(TempDimSetEntry, DimSetID);
        if not TempDimSetEntry.FindSet() then
            exit;

        repeat
            Dimension.Get(TempDimSetEntry."Dimension Code");
            if Dimension."SAF-T Export" then begin
                TempDimIDBuffer."Parent ID" += 1;
                TempDimIDBuffer."Dimension Code" := Dimension."Analysis Type SAF-T";
                TempDimIDBuffer."Dimension Value" := TempDimSetEntry."Dimension Value Code";
                TempDimIDBuffer.Insert();
            end;
        until TempDimSetEntry.Next() = 0;
    end;

    local procedure ExportSalesInvoicesAndCreditMemos(AuditFileExportHeader: Record "Audit File Export Header")
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        TotalNumberOfEntries: Integer;
        Counter: Integer;
        TotalDebit: Decimal;
        TotalCredit: Decimal;
    begin
        SalesInvoiceHeader.SetLoadFields(
            "Posting Date", "Document Date", "Customer Posting Group", "Payment Terms Code", "User ID", "Order No.", "Order Date", "Currency Code",
            "Bill-to Customer No.", "Bill-to Address", "Bill-to Address 2", "Bill-to City", "Bill-to Post Code", "Bill-to Country/Region Code",
            "Ship-to Address", "Ship-to Address 2", "Ship-to City", "Ship-to Post Code", "Ship-to Country/Region Code",
            "Package Tracking No.", "Location Code");
        SalesCrMemoHeader.SetLoadFields(
            "Posting Date", "Document Date", "Customer Posting Group", "Payment Terms Code", "User ID", "Return Order No.", "Currency Code",
            "Bill-to Customer No.", "Bill-to Address", "Bill-to Address 2", "Bill-to City", "Bill-to Post Code", "Bill-to Country/Region Code",
            "Ship-to Address", "Ship-to Address 2", "Ship-to City", "Ship-to Post Code", "Ship-to Country/Region Code",
            "Package Tracking No.", "Location Code");
        SalesInvoiceHeader.SetRange("Posting Date", AuditFileExportHeader."Starting Date", AuditFileExportHeader."Ending Date");
        SalesCrMemoHeader.SetRange("Posting Date", AuditFileExportHeader."Starting Date", AuditFileExportHeader."Ending Date");
        if SalesInvoiceHeader.IsEmpty() and SalesCrMemoHeader.IsEmpty() then
            exit;

        UpdateDataSourceInProgressDialog(ExportingSalesInvoicesTxt);
        UpdateProgressDialog(2, '');

        TotalNumberOfEntries := SalesInvoiceHeader.Count() + SalesCrMemoHeader.Count();

        XmlHelper.AddNewXmlNode('SalesInvoices', '');
        XmlHelper.AppendXmlNode('NumberOfEntries', Format(TotalNumberOfEntries));

        TotalDebit := SAFTDataMgt.GetTotalAmountCustomerDocuments(AuditFileExportHeader."Starting Date", AuditFileExportHeader."Ending Date", "Gen. Journal Document Type"::Invoice);
        TotalCredit := SAFTDataMgt.GetTotalAmountCustomerDocuments(AuditFileExportHeader."Starting Date", AuditFileExportHeader."Ending Date", "Gen. Journal Document Type"::"Credit Memo");
        XmlHelper.AppendXmlNode('TotalDebit', SAFTDataMgt.GetSAFTMonetaryDecimal(TotalDebit));
        XmlHelper.AppendXmlNode('TotalCredit', SAFTDataMgt.GetSAFTMonetaryDecimal(TotalCredit));

        if SalesInvoiceHeader.FindSet() then
            repeat
                ExportSalesInvoice(SalesInvoiceHeader);

                Counter += 1;
                UpdateCountInProgressDialog(Counter, TotalNumberOfEntries);
            until SalesInvoiceHeader.Next() = 0;

        if SalesCrMemoHeader.FindSet() then
            repeat
                ExportSalesCreditMemo(SalesCrMemoHeader);

                Counter += 1;
                UpdateCountInProgressDialog(Counter, TotalNumberOfEntries);
            until SalesCrMemoHeader.Next() = 0;

        XmlHelper.FinalizeXmlNode();
    end;

    local procedure ExportSalesInvoice(var SalesInvoiceHeader: Record "Sales Invoice Header")
    var
        Location: Record Location;
        CustLedgerEntry: Record "Cust. Ledger Entry";
        SalesInvoiceLine: Record "Sales Invoice Line";
        VATEntry: Record "VAT Entry";
        AppliedCreditMemoNos: List of [Code[20]];
        ExchangeRate: Decimal;
        ShipFromInfoEmpty: Boolean;
        ShipFromAddressEmpty: Boolean;
        ShipToAddressEmpty: Boolean;
    begin
        if SalesInvoiceHeader."No." = '' then
            exit;

        XmlHelper.SetCurrentRec(SalesInvoiceHeader);
        XmlHelper.AddNewXmlNode('Invoice', '');
        XmlHelper.AppendXmlNode('InvoiceNo', SalesInvoiceHeader."No.");
        XmlHelper.AddNewXmlNode('CustomerInfo', '');
        XmlHelper.AppendXmlNode('CustomerID', SalesInvoiceHeader."Bill-to Customer No.");
        ExportAddress(
            BillingAddressTxt, CombineWithSpace(SalesInvoiceHeader."Bill-to Address", SalesInvoiceHeader."Bill-to Address 2"),
            SalesInvoiceHeader."Bill-to City", SalesInvoiceHeader."Bill-to Post Code", SalesInvoiceHeader."Bill-to Country/Region Code", BillingAddressTxt);
        XmlHelper.FinalizeXmlNode();

        XmlHelper.AppendXmlNode('AccountID', GetReceivablesAccount(SalesInvoiceHeader."Customer Posting Group"));
        XmlHelper.AppendXmlNode('Period', Format(Date2DMY(SalesInvoiceHeader."Posting Date", 2)));
        XmlHelper.AppendXmlNode('PeriodYear', Format(Date2DMY(SalesInvoiceHeader."Posting Date", 3)));
        XmlHelper.AppendXmlNode('InvoiceDate', FormatDate(SalesInvoiceHeader."Document Date"));
        XmlHelper.AppendXmlNode('InvoiceType', SAFTDataMgt.GetSAFTCodeText(InvoiceTypeTxt));

        ShipToAddressEmpty :=
            (SalesInvoiceHeader."Ship-to Address" = '') and (SalesInvoiceHeader."Ship-to Address 2" = '') and (SalesInvoiceHeader."Ship-to City" = '') and
            (SalesInvoiceHeader."Ship-to Post Code" = '') and (SalesInvoiceHeader."Ship-to Country/Region Code" = '');
        if not ShipToAddressEmpty then begin
            XmlHelper.AddNewXmlNode('ShipTo', '');
            ExportAddress(
                AddressTxt, CombineWithSpace(SalesInvoiceHeader."Ship-to Address", SalesInvoiceHeader."Ship-to Address 2"),
                SalesInvoiceHeader."Ship-to City", SalesInvoiceHeader."Ship-to Post Code", SalesInvoiceHeader."Ship-to Country/Region Code", ShipToAddressTxt);
            XmlHelper.FinalizeXmlNode();
        end;

        Location.SetLoadFields(Address, "Address 2", City, "Post Code", "Country/Region Code");
        if Location.Get(SalesInvoiceHeader."Location Code") then;
        ShipFromInfoEmpty := (SalesInvoiceHeader."Package Tracking No." = '') and (SalesInvoiceHeader."Location Code" = '');
        ShipFromAddressEmpty :=
            (Location.Address = '') and (Location."Address 2" = '') and (Location.City = '') and (Location."Post Code" = '') and (Location."Country/Region Code" = '');
        if not ShipFromInfoEmpty or not ShipFromAddressEmpty then begin
            XmlHelper.AddNewXmlNode('ShipFrom', '');
            XmlHelper.AppendXmlNode('DeliveryID', SalesInvoiceHeader."Package Tracking No.");
            XmlHelper.AppendXmlNode('WarehouseID', SalesInvoiceHeader."Location Code");
            if not ShipFromAddressEmpty then
                ExportAddress(
                    AddressTxt, CombineWithSpace(Location.Address, Location."Address 2"), Location.City,
                    Location."Post Code", Location."Country/Region Code", ShipFromAddressTxt);
            XmlHelper.FinalizeXmlNode();
        end;

        XmlHelper.AppendXmlNode('PaymentTerms', SalesInvoiceHeader."Payment Terms Code");
        XmlHelper.AppendXmlNode('SourceID', SAFTDataMgt.GetSAFTMiddle1Text(SalesInvoiceHeader."User ID"));
        XmlHelper.AppendXmlNode('GLPostingDate', FormatDate(SalesInvoiceHeader."Posting Date"));

        CustLedgerEntry.SetLoadFields("Document Type", "Document No.", "Posting Date", "Transaction No.", Amount, "Amount (LCY)");
        CustLedgerEntry.SetRange("Document Type", "Gen. Journal Document Type"::Invoice);
        CustLedgerEntry.SetRange("Document No.", SalesInvoiceHeader."No.");
        CustLedgerEntry.SetRange("Posting Date", SalesInvoiceHeader."Posting Date");
        if CustLedgerEntry.FindFirst() then;
        CustLedgerEntry.CalcFields(Amount, "Amount (LCY)");
        if CustLedgerEntry.Amount <> 0 then
            ExchangeRate := CustLedgerEntry."Amount (LCY)" / CustLedgerEntry.Amount
        else
            ExchangeRate := 1;

        XmlHelper.AppendXmlNode('BatchID', Format(CustLedgerEntry."Transaction No."));
        XmlHelper.AppendXmlNode('TransactionID', GetSAFTTransactionID(CustLedgerEntry));

        AppliedCreditMemoNos := SAFTDataMgt.GetAppliedSalesDocuments(CustLedgerEntry."Entry No.", "Gen. Journal Document Type"::"Credit Memo");

        SalesInvoiceLine.SetLoadFields(
            Type, "Dimension Set ID", "No.", Description, Quantity, "Unit of Measure Code", "Qty. per Unit of Measure", "Unit Price",
            "VAT Bus. Posting Group", "VAT Prod. Posting Group", "VAT %", "VAT Base Amount", Amount, "Amount Including VAT");
        SalesInvoiceLine.SetRange("Document No.", SalesInvoiceHeader."No.");
        if SalesInvoiceLine.FindSet() then
            repeat
                ExportSalesInvoiceLine(SalesInvoiceLine, SalesInvoiceHeader, AppliedCreditMemoNos, ExchangeRate);
            until SalesInvoiceLine.Next() = 0;

        XmlHelper.SetCurrentRec(SalesInvoiceHeader);
        XmlHelper.AddNewXmlNode('DocumentTotals', '');
        VATEntry.SetLoadFields("Document Type", "Document No.", "Posting Date", Type, "VAT Bus. Posting Group", "VAT Prod. Posting Group", Base, Amount);
        VATEntry.SetRange("Document Type", "Gen. Journal Document Type"::Invoice);
        VATEntry.SetRange("Document No.", SalesInvoiceHeader."No.");
        VATEntry.SetRange("Posting Date", SalesInvoiceHeader."Posting Date");
        if VATEntry.FindSet() then
            repeat
                ExportTaxInformation(VATEntry, TaxInformationTotalsTxt);
            until VATEntry.Next() = 0;

        SalesInvoiceHeader.CalcFields(Amount, "Amount Including VAT");
        XmlHelper.AppendXmlNode('NetTotal', SAFTDataMgt.GetSAFTMonetaryDecimal(SalesInvoiceHeader.Amount));
        XmlHelper.AppendXmlNode('GrossTotal', SAFTDataMgt.GetSAFTMonetaryDecimal(SalesInvoiceHeader."Amount Including VAT"));
        XmlHelper.FinalizeXmlNode();

        XmlHelper.FinalizeXmlNode();
    end;

    local procedure ExportSalesInvoiceLine(var SalesInvoiceLine: Record "Sales Invoice Line"; var SalesInvoiceHeader: Record "Sales Invoice Header"; AppliedCreditMemoNos: List of [Code[20]]; ExchangeRate: Decimal)
    var
        TempDimIDBuffer: Record "Dimension ID Buffer" temporary;
        VATPostingSetup: Record "VAT Posting Setup";
        Params: Dictionary of [Text, Text];
        CreditMemoNo: Code[20];
        IsService: Boolean;
    begin
        if SalesInvoiceLine.Type = "Sales Line Type"::" " then      // skip comment lines
            exit;

        XmlHelper.SetCurrentRec(SalesInvoiceLine);
        XmlHelper.AddNewXmlNode('Line', '');
        XmlHelper.AppendXmlNode('LineNumber', Format(SalesInvoiceLine."Line No."));
        CopyDimeSetIDToDimIDBuffer(TempDimIDBuffer, SalesInvoiceLine."Dimension Set ID");
        ExportAnalysisInfo(TempDimIDBuffer);

        if SalesInvoiceHeader."Order No." <> '' then begin
            XmlHelper.AddNewXmlNode('OrderReferences', '');
            XmlHelper.AppendXmlNode('OriginatingON', SalesInvoiceHeader."Order No.");
            XmlHelper.AppendXmlNode('OrderDate', FormatDate(SalesInvoiceHeader."Order Date"));
            XmlHelper.FinalizeXmlNode();
        end;

        IsService := SAFTDataMgt.IsSalesLineService(SalesInvoiceLine.Type, SalesInvoiceLine."No.");
        Params.Add('IsService', Format(IsService));
        XmlHelper.SetAdditionalParams(Params);
        XmlHelper.AppendXmlNode('GoodsServicesID', SAFTDataMgt.GetGoodsServicesID(IsService));
        XmlHelper.AppendXmlNode('ProductCode', SalesInvoiceLine."No.");
        XmlHelper.AppendXmlNode('ProductDescription', SalesInvoiceLine.Description);
        XmlHelper.AppendXmlNode('Quantity', FormatAmount(SalesInvoiceLine.Quantity));
        XmlHelper.AppendXmlNode('InvoiceUOM', SAFTDataMgt.GetSAFTCodeText(SalesInvoiceLine."Unit of Measure Code"));
        if (SalesInvoiceLine."Unit of Measure Code" <> '') and (SalesInvoiceLine."Qty. per Unit of Measure" <> 1) then
            XmlHelper.AppendXmlNode('UOMToUOMBaseConversionFactor', FormatAmount(SalesInvoiceLine."Qty. per Unit of Measure"));
        XmlHelper.AppendXmlNode('UnitPrice', SAFTDataMgt.GetSAFTMonetaryDecimal(SalesInvoiceLine."Unit Price"));
        XmlHelper.AppendXmlNode('InvoiceDate', FormatDate(SalesInvoiceHeader."Document Date"));

        if AppliedCreditMemoNos.Count > 0 then begin
            XmlHelper.AddNewXmlNode('References', '');
            foreach CreditMemoNo in AppliedCreditMemoNos do begin
                XmlHelper.AddNewXmlNode('CreditNote', '');
                XmlHelper.AppendXmlNode('Reference', CreditMemoNo);
                XmlHelper.FinalizeXmlNode();
            end;
            XmlHelper.FinalizeXmlNode();
        end;

        XmlHelper.AppendXmlNode('Description', SalesInvoiceLine.Description);

        XmlHelper.AddNewXmlNode('InvoiceLineAmount', '');
        XmlHelper.AppendXmlNode('Amount', SAFTDataMgt.GetSAFTMonetaryDecimal(SalesInvoiceLine.Amount * ExchangeRate));
        if SalesInvoiceHeader."Currency Code" <> '' then begin
            XmlHelper.AppendXmlNode('CurrencyCode', SAFTDataMgt.GetISOCurrencyCode(SalesInvoiceHeader."Currency Code"));
            XmlHelper.AppendXmlNode('CurrencyAmount', SAFTDataMgt.GetSAFTMonetaryDecimal(SalesInvoiceLine.Amount));
            XmlHelper.AppendXmlNode('ExchangeRate', SAFTDataMgt.GetSAFTExchangeRateDecimal(ExchangeRate));
        end;
        XmlHelper.FinalizeXmlNode();

        XmlHelper.AppendXmlNode('DebitCreditIndicator', SAFTDataMgt.GetDebitCreditIndicator(SalesInvoiceLine.Amount));

        VATPostingSetup.SetLoadFields("Sales Tax Code SAF-T", "Sale VAT Reporting Code");
        if VATPostingSetup.Get(SalesInvoiceLine."VAT Bus. Posting Group", SalesInvoiceLine."VAT Prod. Posting Group") then
            ExportTaxInformation(
                VATPostingSetup."Sales Tax Code SAF-T", VATPostingSetup."Sale VAT Reporting Code", SalesInvoiceLine."VAT %",
                SalesInvoiceLine."VAT Base Amount", SalesInvoiceLine."Amount Including VAT" - SalesInvoiceLine.Amount);

        XmlHelper.FinalizeXmlNode();
    end;

    local procedure ExportSalesCreditMemo(var SalesCrMemoHeader: Record "Sales Cr.Memo Header")
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        VATEntry: Record "VAT Entry";
        ExchangeRate: Decimal;
        ShipToAddressEmpty: Boolean;
    begin
        if SalesCrMemoHeader."No." = '' then
            exit;

        XmlHelper.SetCurrentRec(SalesCrMemoHeader);
        XmlHelper.AddNewXmlNode('Invoice', '');
        XmlHelper.AppendXmlNode('InvoiceNo', SalesCrMemoHeader."No.");
        XmlHelper.AddNewXmlNode('CustomerInfo', '');
        XmlHelper.AppendXmlNode('CustomerID', SalesCrMemoHeader."Bill-to Customer No.");
        ExportAddress(
            BillingAddressTxt, CombineWithSpace(SalesCrMemoHeader."Bill-to Address", SalesCrMemoHeader."Bill-to Address 2"),
            SalesCrMemoHeader."Bill-to City", SalesCrMemoHeader."Bill-to Post Code", SalesCrMemoHeader."Bill-to Country/Region Code", BillingAddressTxt);
        XmlHelper.FinalizeXmlNode();

        XmlHelper.AppendXmlNode('AccountID', GetReceivablesAccount(SalesCrMemoHeader."Customer Posting Group"));
        XmlHelper.AppendXmlNode('Period', Format(Date2DMY(SalesCrMemoHeader."Posting Date", 2)));
        XmlHelper.AppendXmlNode('PeriodYear', Format(Date2DMY(SalesCrMemoHeader."Posting Date", 3)));
        XmlHelper.AppendXmlNode('InvoiceDate', FormatDate(SalesCrMemoHeader."Document Date"));
        XmlHelper.AppendXmlNode('InvoiceType', SAFTDataMgt.GetSAFTCodeText(CreditMemoTypeTxt));

        ShipToAddressEmpty :=
            (SalesCrMemoHeader."Ship-to Address" = '') and (SalesCrMemoHeader."Ship-to Address 2" = '') and (SalesCrMemoHeader."Ship-to City" = '') and
            (SalesCrMemoHeader."Ship-to Post Code" = '') and (SalesCrMemoHeader."Ship-to Country/Region Code" = '');
        if not ShipToAddressEmpty then begin
            XmlHelper.AddNewXmlNode('ShipTo', '');
            ExportAddress(
                AddressTxt, CombineWithSpace(SalesCrMemoHeader."Ship-to Address", SalesCrMemoHeader."Ship-to Address 2"),
                SalesCrMemoHeader."Ship-to City", SalesCrMemoHeader."Ship-to Post Code", SalesCrMemoHeader."Ship-to Country/Region Code", ShipToAddressTxt);
            XmlHelper.FinalizeXmlNode();
        end;

        if SalesCrMemoHeader."Package Tracking No." <> '' then begin
            XmlHelper.AddNewXmlNode('ShipFrom', '');
            XmlHelper.AppendXmlNode('DeliveryID', SalesCrMemoHeader."Package Tracking No.");
            XmlHelper.FinalizeXmlNode();
        end;

        XmlHelper.AppendXmlNode('PaymentTerms', SalesCrMemoHeader."Payment Terms Code");
        XmlHelper.AppendXmlNode('SourceID', SAFTDataMgt.GetSAFTMiddle1Text(SalesCrMemoHeader."User ID"));
        XmlHelper.AppendXmlNode('GLPostingDate', FormatDate(SalesCrMemoHeader."Posting Date"));

        CustLedgerEntry.SetLoadFields("Document Type", "Document No.", "Posting Date", "Transaction No.", Amount, "Amount (LCY)");
        CustLedgerEntry.SetRange("Document Type", "Gen. Journal Document Type"::"Credit Memo");
        CustLedgerEntry.SetRange("Document No.", SalesCrMemoHeader."No.");
        CustLedgerEntry.SetRange("Posting Date", SalesCrMemoHeader."Posting Date");
        if CustLedgerEntry.FindFirst() then;
        CustLedgerEntry.CalcFields(Amount, "Amount (LCY)");
        if CustLedgerEntry.Amount <> 0 then
            ExchangeRate := CustLedgerEntry."Amount (LCY)" / CustLedgerEntry.Amount
        else
            ExchangeRate := 1;

        XmlHelper.AppendXmlNode('BatchID', Format(CustLedgerEntry."Transaction No."));
        XmlHelper.AppendXmlNode('TransactionID', GetSAFTTransactionID(CustLedgerEntry));

        SalesCrMemoLine.SetLoadFields(
            Type, "Dimension Set ID", "No.", Description, Quantity, "Unit of Measure Code", "Qty. per Unit of Measure", "Unit Price",
            "VAT Bus. Posting Group", "VAT Prod. Posting Group", "VAT %", "VAT Base Amount", Amount, "Amount Including VAT");
        SalesCrMemoLine.SetRange("Document No.", SalesCrMemoHeader."No.");
        if SalesCrMemoLine.FindSet() then
            repeat
                ExportSalesCrMemoLine(SalesCrMemoLine, SalesCrMemoHeader, ExchangeRate);
            until SalesCrMemoLine.Next() = 0;

        XmlHelper.SetCurrentRec(SalesCrMemoHeader);
        XmlHelper.AddNewXmlNode('DocumentTotals', '');
        VATEntry.SetLoadFields("Document Type", "Document No.", "Posting Date", Type, "VAT Bus. Posting Group", "VAT Prod. Posting Group", Base, Amount);
        VATEntry.SetRange("Document Type", "Gen. Journal Document Type"::"Credit Memo");
        VATEntry.SetRange("Document No.", SalesCrMemoHeader."No.");
        VATEntry.SetRange("Posting Date", SalesCrMemoHeader."Posting Date");
        if VATEntry.FindSet() then
            repeat
                ExportTaxInformation(VATEntry, TaxInformationTotalsTxt);
            until VATEntry.Next() = 0;

        SalesCrMemoHeader.CalcFields(Amount, "Amount Including VAT");
        XmlHelper.AppendXmlNode('NetTotal', SAFTDataMgt.GetSAFTMonetaryDecimal(SalesCrMemoHeader.Amount));
        XmlHelper.AppendXmlNode('GrossTotal', SAFTDataMgt.GetSAFTMonetaryDecimal(SalesCrMemoHeader."Amount Including VAT"));
        XmlHelper.FinalizeXmlNode();

        XmlHelper.FinalizeXmlNode();
    end;

    local procedure ExportSalesCrMemoLine(var SalesCrMemoLine: Record "Sales Cr.Memo Line"; var SalesCrMemoHeader: Record "Sales Cr.Memo Header"; ExchangeRate: Decimal)
    var
        TempDimIDBuffer: Record "Dimension ID Buffer" temporary;
        VATPostingSetup: Record "VAT Posting Setup";
        Params: Dictionary of [Text, Text];
        IsService: Boolean;
    begin
        if SalesCrMemoLine.Type = "Sales Line Type"::" " then       // skip comment lines
            exit;

        XmlHelper.SetCurrentRec(SalesCrMemoLine);
        XmlHelper.AddNewXmlNode('Line', '');
        XmlHelper.AppendXmlNode('LineNumber', Format(SalesCrMemoLine."Line No."));
        CopyDimeSetIDToDimIDBuffer(TempDimIDBuffer, SalesCrMemoLine."Dimension Set ID");
        ExportAnalysisInfo(TempDimIDBuffer);

        if SalesCrMemoHeader."Return Order No." <> '' then begin
            XmlHelper.AddNewXmlNode('OrderReferences', '');
            XmlHelper.AppendXmlNode('OriginatingON', SalesCrMemoHeader."Return Order No.");
            XmlHelper.FinalizeXmlNode();
        end;

        IsService := SAFTDataMgt.IsSalesLineService(SalesCrMemoLine.Type, SalesCrMemoLine."No.");
        Params.Add('IsService', Format(IsService));
        XmlHelper.SetAdditionalParams(Params);
        XmlHelper.AppendXmlNode('GoodsServicesID', SAFTDataMgt.GetGoodsServicesID(IsService));
        XmlHelper.AppendXmlNode('ProductCode', SalesCrMemoLine."No.");
        XmlHelper.AppendXmlNode('ProductDescription', SalesCrMemoLine.Description);
        XmlHelper.AppendXmlNode('Quantity', FormatAmount(SalesCrMemoLine.Quantity));
        XmlHelper.AppendXmlNode('InvoiceUOM', SAFTDataMgt.GetSAFTCodeText(SalesCrMemoLine."Unit of Measure Code"));
        if (SalesCrMemoLine."Unit of Measure Code" <> '') and (SalesCrMemoLine."Qty. per Unit of Measure" <> 1) then
            XmlHelper.AppendXmlNode('UOMToUOMBaseConversionFactor', FormatAmount(SalesCrMemoLine."Qty. per Unit of Measure"));
        XmlHelper.AppendXmlNode('UnitPrice', SAFTDataMgt.GetSAFTMonetaryDecimal(SalesCrMemoLine."Unit Price"));
        XmlHelper.AppendXmlNode('InvoiceDate', FormatDate(SalesCrMemoHeader."Document Date"));

        XmlHelper.AppendXmlNode('Description', SalesCrMemoLine.Description);

        XmlHelper.AddNewXmlNode('InvoiceLineAmount', '');
        XmlHelper.AppendXmlNode('Amount', SAFTDataMgt.GetSAFTMonetaryDecimal(SalesCrMemoLine.Amount * ExchangeRate));
        if SalesCrMemoHeader."Currency Code" <> '' then begin
            XmlHelper.AppendXmlNode('CurrencyCode', SAFTDataMgt.GetISOCurrencyCode(SalesCrMemoHeader."Currency Code"));
            XmlHelper.AppendXmlNode('CurrencyAmount', SAFTDataMgt.GetSAFTMonetaryDecimal(SalesCrMemoLine.Amount));
            XmlHelper.AppendXmlNode('ExchangeRate', SAFTDataMgt.GetSAFTExchangeRateDecimal(ExchangeRate));
        end;
        XmlHelper.FinalizeXmlNode();

        XmlHelper.AppendXmlNode('DebitCreditIndicator', SAFTDataMgt.GetDebitCreditIndicator(SalesCrMemoLine.Amount));

        VATPostingSetup.SetLoadFields("Sales Tax Code SAF-T", "Sale VAT Reporting Code");
        if VATPostingSetup.Get(SalesCrMemoLine."VAT Bus. Posting Group", SalesCrMemoLine."VAT Prod. Posting Group") then
            ExportTaxInformation(
                VATPostingSetup."Sales Tax Code SAF-T", VATPostingSetup."Sale VAT Reporting Code", SalesCrMemoLine."VAT %",
                SalesCrMemoLine."VAT Base Amount", SalesCrMemoLine."Amount Including VAT" - SalesCrMemoLine.Amount);

        XmlHelper.FinalizeXmlNode();
    end;

    local procedure ExportPurchaseInvoicesAndCreditMemos(AuditFileExportHeader: Record "Audit File Export Header")
    var
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        DetailedVEndorLedgEntry: Record "Detailed Vendor Ledg. Entry";
        TotalNumberOfEntries: Integer;
        Counter: Integer;
    begin
        PurchInvHeader.SetLoadFields(
            "Posting Date", "Document Date", "Vendor Posting Group", "Payment Terms Code", "User ID", "Order No.", "Order Date", "Currency Code",
            "Pay-to Vendor No.", "Pay-to Address", "Pay-to Address 2", "Pay-to City", "Pay-to Post Code", "Pay-to Country/Region Code",
            "Ship-to Address", "Ship-to Address 2", "Ship-to City", "Ship-to Post Code", "Ship-to Country/Region Code", "Location Code");
        PurchCrMemoHdr.SetLoadFields(
            "Posting Date", "Document Date", "Vendor Posting Group", "Payment Terms Code", "User ID", "Return Order No.", "Currency Code",
            "Pay-to Vendor No.", "Pay-to Address", "Pay-to Address 2", "Pay-to City", "Pay-to Post Code", "Pay-to Country/Region Code",
            "Ship-to Address", "Ship-to Address 2", "Ship-to City", "Ship-to Post Code", "Ship-to Country/Region Code", "Location Code");
        PurchInvHeader.SetRange("Posting Date", AuditFileExportHeader."Starting Date", AuditFileExportHeader."Ending Date");
        PurchCrMemoHdr.SetRange("Posting Date", AuditFileExportHeader."Starting Date", AuditFileExportHeader."Ending Date");
        if PurchInvHeader.IsEmpty() and PurchCrMemoHdr.IsEmpty() then
            exit;

        UpdateDataSourceInProgressDialog(ExportingPurchaseInvoicesTxt);

        TotalNumberOfEntries := PurchInvHeader.Count() + PurchCrMemoHdr.Count();

        XmlHelper.AddNewXmlNode('PurchaseInvoices', '');
        XmlHelper.AppendXmlNode('NumberOfEntries', Format(TotalNumberOfEntries));

        DetailedVEndorLedgEntry.SetLoadFields("Document Type", "Posting Date", "Amount (LCY)");
        DetailedVEndorLedgEntry.SetRange("Posting Date", AuditFileExportHeader."Starting Date", AuditFileExportHeader."Ending Date");
        DetailedVEndorLedgEntry.SetRange("Ledger Entry Amount", true);

        DetailedVEndorLedgEntry.SetRange("Document Type", "Gen. Journal Document Type"::Invoice);
        DetailedVEndorLedgEntry.CalcSums("Amount (LCY)");
        XmlHelper.AppendXmlNode('TotalDebit', SAFTDataMgt.GetSAFTMonetaryDecimal(DetailedVEndorLedgEntry."Amount (LCY)"));

        DetailedVEndorLedgEntry.SetRange("Document Type", "Gen. Journal Document Type"::"Credit Memo");
        DetailedVEndorLedgEntry.CalcSums("Amount (LCY)");
        XmlHelper.AppendXmlNode('TotalCredit', SAFTDataMgt.GetSAFTMonetaryDecimal(DetailedVEndorLedgEntry."Amount (LCY)"));

        if PurchInvHeader.FindSet() then
            repeat
                ExportPurchaseInvoice(PurchInvHeader);

                Counter += 1;
                UpdateCountInProgressDialog(Counter, TotalNumberOfEntries);
            until PurchInvHeader.Next() = 0;

        if PurchCrMemoHdr.FindSet() then
            repeat
                ExportPurchaseCreditMemo(PurchCrMemoHdr);

                Counter += 1;
                UpdateCountInProgressDialog(Counter, TotalNumberOfEntries);
            until PurchCrMemoHdr.Next() = 0;

        XmlHelper.FinalizeXmlNode();
    end;

    local procedure ExportPurchaseInvoice(var PurchInvHeader: Record "Purch. Inv. Header")
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        PurchInvLine: Record "Purch. Inv. Line";
        VATEntry: Record "VAT Entry";
        AppliedCreditMemoNos: List of [Code[20]];
        ExchangeRate: Decimal;
        ShipToAddressEmpty: Boolean;
    begin
        if PurchInvHeader."No." = '' then
            exit;

        XmlHelper.SetCurrentRec(PurchInvHeader);
        XmlHelper.AddNewXmlNode('Invoice', '');
        XmlHelper.AppendXmlNode('InvoiceNo', PurchInvHeader."No.");
        XmlHelper.AddNewXmlNode('SupplierInfo', '');
        XmlHelper.AppendXmlNode('SupplierID', PurchInvHeader."Pay-to Vendor No.");
        ExportAddress(
            BillingAddressTxt, CombineWithSpace(PurchInvHeader."Pay-to Address", PurchInvHeader."Pay-to Address 2"),
            PurchInvHeader."Pay-to City", PurchInvHeader."Pay-to Post Code", PurchInvHeader."Pay-to Country/Region Code", BillingAddressTxt);
        XmlHelper.FinalizeXmlNode();

        XmlHelper.AppendXmlNode('AccountID', GetPayablesAccount(PurchInvHeader."Vendor Posting Group"));
        XmlHelper.AppendXmlNode('Period', Format(Date2DMY(PurchInvHeader."Posting Date", 2)));
        XmlHelper.AppendXmlNode('PeriodYear', Format(Date2DMY(PurchInvHeader."Posting Date", 3)));
        XmlHelper.AppendXmlNode('InvoiceDate', FormatDate(PurchInvHeader."Document Date"));
        XmlHelper.AppendXmlNode('InvoiceType', SAFTDataMgt.GetSAFTCodeText(InvoiceTypeTxt));

        ShipToAddressEmpty :=
            (PurchInvHeader."Ship-to Address" = '') and (PurchInvHeader."Ship-to Address 2" = '') and (PurchInvHeader."Ship-to City" = '') and
            (PurchInvHeader."Ship-to Post Code" = '') and (PurchInvHeader."Ship-to Country/Region Code" = '');
        if not ShipToAddressEmpty then begin
            XmlHelper.AddNewXmlNode('ShipTo', '');
            ExportAddress(
                AddressTxt, CombineWithSpace(PurchInvHeader."Ship-to Address", PurchInvHeader."Ship-to Address 2"),
                PurchInvHeader."Ship-to City", PurchInvHeader."Ship-to Post Code", PurchInvHeader."Ship-to Country/Region Code", ShipToAddressTxt);
            XmlHelper.FinalizeXmlNode();
        end;

        XmlHelper.AppendXmlNode('PaymentTerms', PurchInvHeader."Payment Terms Code");
        XmlHelper.AppendXmlNode('SourceID', SAFTDataMgt.GetSAFTMiddle1Text(PurchInvHeader."User ID"));
        XmlHelper.AppendXmlNode('GLPostingDate', FormatDate(PurchInvHeader."Posting Date"));

        VendorLedgerEntry.SetLoadFields("Document Type", "Document No.", "Posting Date", "Transaction No.", Amount, "Amount (LCY)");
        VendorLedgerEntry.SetRange("Document Type", "Gen. Journal Document Type"::Invoice);
        VendorLedgerEntry.SetRange("Document No.", PurchInvHeader."No.");
        VendorLedgerEntry.SetRange("Posting Date", PurchInvHeader."Posting Date");
        if VendorLedgerEntry.FindFirst() then;
        VendorLedgerEntry.CalcFields(Amount, "Amount (LCY)");
        if VendorLedgerEntry.Amount <> 0 then
            ExchangeRate := VendorLedgerEntry."Amount (LCY)" / VendorLedgerEntry.Amount
        else
            ExchangeRate := 1;

        XmlHelper.AppendXmlNode('BatchID', Format(VendorLedgerEntry."Transaction No."));
        XmlHelper.AppendXmlNode('TransactionID', GetSAFTTransactionID(VendorLedgerEntry));

        AppliedCreditMemoNos := SAFTDataMgt.GetAppliedPurchaseCreditMemos(VendorLedgerEntry."Entry No.", "Gen. Journal Document Type"::"Credit Memo");

        PurchInvLine.SetLoadFields(
            Type, "Dimension Set ID", "No.", Description, Quantity, "Unit of Measure Code", "Qty. per Unit of Measure", "Direct Unit Cost",
            "VAT Bus. Posting Group", "VAT Prod. Posting Group", "VAT %", "VAT Base Amount", Amount, "Amount Including VAT");
        PurchInvLine.SetRange("Document No.", PurchInvHeader."No.");
        if PurchInvLine.FindSet() then
            repeat
                ExportPurchaseInvoiceLine(PurchInvLine, PurchInvHeader, AppliedCreditMemoNos, ExchangeRate);
            until PurchInvLine.Next() = 0;

        XmlHelper.SetCurrentRec(PurchInvHeader);
        XmlHelper.AddNewXmlNode('DocumentTotals', '');
        VATEntry.SetLoadFields("Document Type", "Document No.", "Posting Date", Type, "VAT Bus. Posting Group", "VAT Prod. Posting Group", Base, Amount);
        VATEntry.SetRange("Document Type", "Gen. Journal Document Type"::Invoice);
        VATEntry.SetRange("Document No.", PurchInvHeader."No.");
        VATEntry.SetRange("Posting Date", PurchInvHeader."Posting Date");
        if VATEntry.FindSet() then
            repeat
                ExportTaxInformation(VATEntry, TaxInformationTotalsTxt);
            until VATEntry.Next() = 0;

        PurchInvHeader.CalcFields(Amount, "Amount Including VAT");
        XmlHelper.AppendXmlNode('NetTotal', SAFTDataMgt.GetSAFTMonetaryDecimal(PurchInvHeader.Amount));
        XmlHelper.AppendXmlNode('GrossTotal', SAFTDataMgt.GetSAFTMonetaryDecimal(PurchInvHeader."Amount Including VAT"));
        XmlHelper.FinalizeXmlNode();

        XmlHelper.FinalizeXmlNode();
    end;

    local procedure ExportPurchaseInvoiceLine(var PurchInvLine: Record "Purch. Inv. Line"; var PurchInvHeader: Record "Purch. Inv. Header"; AppliedCreditMemoNos: List of [Code[20]]; ExchangeRate: Decimal)
    var
        TempDimIDBuffer: Record "Dimension ID Buffer" temporary;
        VATPostingSetup: Record "VAT Posting Setup";
        Params: Dictionary of [Text, Text];
        CreditMemoNo: Code[20];
        IsService: Boolean;
    begin
        if PurchInvLine.Type = "Purchase Line Type"::" " then       // skip comment lines
            exit;

        XmlHelper.SetCurrentRec(PurchInvLine);
        XmlHelper.AddNewXmlNode('Line', '');
        XmlHelper.AppendXmlNode('LineNumber', Format(PurchInvLine."Line No."));
        CopyDimeSetIDToDimIDBuffer(TempDimIDBuffer, PurchInvLine."Dimension Set ID");
        ExportAnalysisInfo(TempDimIDBuffer);

        if PurchInvHeader."Order No." <> '' then begin
            XmlHelper.AddNewXmlNode('OrderReferences', '');
            XmlHelper.AppendXmlNode('OriginatingON', PurchInvHeader."Order No.");
            XmlHelper.AppendXmlNode('OrderDate', FormatDate(PurchInvHeader."Order Date"));
            XmlHelper.FinalizeXmlNode();
        end;

        IsService := SAFTDataMgt.IsPurchaseLineService(PurchInvLine.Type, PurchInvLine."No.");
        Params.Add('IsService', Format(IsService));
        XmlHelper.SetAdditionalParams(Params);
        XmlHelper.AppendXmlNode('GoodsServicesID', SAFTDataMgt.GetGoodsServicesID(IsService));
        XmlHelper.AppendXmlNode('ProductCode', PurchInvLine."No.");
        XmlHelper.AppendXmlNode('ProductDescription', PurchInvLine.Description);
        XmlHelper.AppendXmlNode('Quantity', FormatAmount(PurchInvLine.Quantity));
        XmlHelper.AppendXmlNode('InvoiceUOM', SAFTDataMgt.GetSAFTCodeText(PurchInvLine."Unit of Measure Code"));
        if (PurchInvLine."Unit of Measure Code" <> '') and (PurchInvLine."Qty. per Unit of Measure" <> 1) then
            XmlHelper.AppendXmlNode('UOMToUOMBaseConversionFactor', FormatAmount(PurchInvLine."Qty. per Unit of Measure"));
        XmlHelper.AppendXmlNode('UnitPrice', SAFTDataMgt.GetSAFTMonetaryDecimal(PurchInvLine."Direct Unit Cost"));
        XmlHelper.AppendXmlNode('InvoiceDate', FormatDate(PurchInvHeader."Document Date"));

        if AppliedCreditMemoNos.Count > 0 then begin
            XmlHelper.AddNewXmlNode('References', '');
            foreach CreditMemoNo in AppliedCreditMemoNos do begin
                XmlHelper.AddNewXmlNode('CreditNote', '');
                XmlHelper.AppendXmlNode('Reference', CreditMemoNo);
                XmlHelper.FinalizeXmlNode();
            end;
            XmlHelper.FinalizeXmlNode();
        end;

        XmlHelper.AppendXmlNode('Description', PurchInvLine.Description);

        XmlHelper.AddNewXmlNode('InvoiceLineAmount', '');
        XmlHelper.AppendXmlNode('Amount', SAFTDataMgt.GetSAFTMonetaryDecimal(PurchInvLine.Amount * ExchangeRate));
        if PurchInvHeader."Currency Code" <> '' then begin
            XmlHelper.AppendXmlNode('CurrencyCode', SAFTDataMgt.GetISOCurrencyCode(PurchInvHeader."Currency Code"));
            XmlHelper.AppendXmlNode('CurrencyAmount', SAFTDataMgt.GetSAFTMonetaryDecimal(PurchInvLine.Amount));
            XmlHelper.AppendXmlNode('ExchangeRate', SAFTDataMgt.GetSAFTExchangeRateDecimal(ExchangeRate));
        end;
        XmlHelper.FinalizeXmlNode();

        XmlHelper.AppendXmlNode('DebitCreditIndicator', SAFTDataMgt.GetDebitCreditIndicator(PurchInvLine.Amount));

        VATPostingSetup.SetLoadFields("Purchase Tax Code SAF-T", "Purch. VAT Reporting Code");
        if VATPostingSetup.Get(PurchInvLine."VAT Bus. Posting Group", PurchInvLine."VAT Prod. Posting Group") then
            ExportTaxInformation(
                VATPostingSetup."Purchase Tax Code SAF-T", VATPostingSetup."Purch. VAT Reporting Code", PurchInvLine."VAT %",
                PurchInvLine."VAT Base Amount", PurchInvLine."Amount Including VAT" - PurchInvLine.Amount);

        XmlHelper.FinalizeXmlNode();
    end;

    local procedure ExportPurchaseCreditMemo(var PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.")
    var
        Location: Record Location;
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        PurchCrMemoLine: Record "Purch. Cr. Memo Line";
        VATEntry: Record "VAT Entry";
        ExchangeRate: Decimal;
        ShipFromAddressEmpty: Boolean;
        ShipToAddressEmpty: Boolean;
    begin
        if PurchCrMemoHdr."No." = '' then
            exit;

        XmlHelper.SetCurrentRec(PurchCrMemoHdr);
        XmlHelper.AddNewXmlNode('Invoice', '');
        XmlHelper.AppendXmlNode('InvoiceNo', PurchCrMemoHdr."No.");
        XmlHelper.AddNewXmlNode('SupplierInfo', '');
        XmlHelper.AppendXmlNode('SupplierID', PurchCrMemoHdr."Pay-to Vendor No.");
        ExportAddress(
            BillingAddressTxt, CombineWithSpace(PurchCrMemoHdr."Pay-to Address", PurchCrMemoHdr."Pay-to Address 2"),
            PurchCrMemoHdr."Pay-to City", PurchCrMemoHdr."Pay-to Post Code", PurchCrMemoHdr."Pay-to Country/Region Code", BillingAddressTxt);
        XmlHelper.FinalizeXmlNode();

        XmlHelper.AppendXmlNode('AccountID', GetPayablesAccount(PurchCrMemoHdr."Vendor Posting Group"));
        XmlHelper.AppendXmlNode('Period', Format(Date2DMY(PurchCrMemoHdr."Posting Date", 2)));
        XmlHelper.AppendXmlNode('PeriodYear', Format(Date2DMY(PurchCrMemoHdr."Posting Date", 3)));
        XmlHelper.AppendXmlNode('InvoiceDate', FormatDate(PurchCrMemoHdr."Document Date"));
        XmlHelper.AppendXmlNode('InvoiceType', SAFTDataMgt.GetSAFTCodeText(CreditMemoTypeTxt));

        ShipToAddressEmpty :=
            (PurchCrMemoHdr."Ship-to Address" = '') and (PurchCrMemoHdr."Ship-to Address 2" = '') and (PurchCrMemoHdr."Ship-to City" = '') and
            (PurchCrMemoHdr."Ship-to Post Code" = '') and (PurchCrMemoHdr."Ship-to Country/Region Code" = '');
        if not ShipToAddressEmpty then begin
            XmlHelper.AddNewXmlNode('ShipTo', '');
            ExportAddress(
                AddressTxt, CombineWithSpace(PurchCrMemoHdr."Ship-to Address", PurchCrMemoHdr."Ship-to Address 2"),
                PurchCrMemoHdr."Ship-to City", PurchCrMemoHdr."Ship-to Post Code", PurchCrMemoHdr."Ship-to Country/Region Code", ShipToAddressTxt);
            XmlHelper.FinalizeXmlNode();
        end;

        Location.SetLoadFields(Address, "Address 2", City, "Post Code", "Country/Region Code");
        if Location.Get(PurchCrMemoHdr."Location Code") then;
        ShipFromAddressEmpty :=
            (Location.Address = '') and (Location."Address 2" = '') and (Location.City = '') and (Location."Post Code" = '') and (Location."Country/Region Code" = '');
        if not ShipFromAddressEmpty then begin
            XmlHelper.AddNewXmlNode('ShipFrom', '');
            ExportAddress(
                AddressTxt, CombineWithSpace(Location.Address, Location."Address 2"), Location.City,
                Location."Post Code", Location."Country/Region Code", ShipFromAddressTxt);
            XmlHelper.FinalizeXmlNode();
        end;

        XmlHelper.AppendXmlNode('PaymentTerms', PurchCrMemoHdr."Payment Terms Code");
        XmlHelper.AppendXmlNode('SourceID', SAFTDataMgt.GetSAFTMiddle1Text(PurchCrMemoHdr."User ID"));
        XmlHelper.AppendXmlNode('GLPostingDate', FormatDate(PurchCrMemoHdr."Posting Date"));

        VendorLedgerEntry.SetLoadFields("Document Type", "Document No.", "Posting Date", "Transaction No.", Amount, "Amount (LCY)");
        VendorLedgerEntry.SetRange("Document Type", "Gen. Journal Document Type"::"Credit Memo");
        VendorLedgerEntry.SetRange("Document No.", PurchCrMemoHdr."No.");
        VendorLedgerEntry.SetRange("Posting Date", PurchCrMemoHdr."Posting Date");
        if VendorLedgerEntry.FindFirst() then;
        VendorLedgerEntry.CalcFields(Amount, "Amount (LCY)");
        if VendorLedgerEntry.Amount <> 0 then
            ExchangeRate := VendorLedgerEntry."Amount (LCY)" / VendorLedgerEntry.Amount
        else
            ExchangeRate := 1;

        XmlHelper.AppendXmlNode('BatchID', Format(VendorLedgerEntry."Transaction No."));
        XmlHelper.AppendXmlNode('TransactionID', GetSAFTTransactionID(VendorLedgerEntry));

        PurchCrMemoLine.SetLoadFields(
            Type, "Dimension Set ID", "No.", Description, Quantity, "Unit of Measure Code", "Qty. per Unit of Measure", "Direct Unit Cost",
            "VAT Bus. Posting Group", "VAT Prod. Posting Group", "VAT %", "VAT Base Amount", Amount, "Amount Including VAT");
        PurchCrMemoLine.SetRange("Document No.", PurchCrMemoHdr."No.");
        if PurchCrMemoLine.FindSet() then
            repeat
                ExportPurchaseCrMemoLine(PurchCrMemoLine, PurchCrMemoHdr, ExchangeRate);
            until PurchCrMemoLine.Next() = 0;

        XmlHelper.SetCurrentRec(PurchCrMemoHdr);
        XmlHelper.AddNewXmlNode('DocumentTotals', '');
        VATEntry.SetLoadFields("Document Type", "Document No.", "Posting Date", Type, "VAT Bus. Posting Group", "VAT Prod. Posting Group", Base, Amount);
        VATEntry.SetRange("Document Type", "Gen. Journal Document Type"::"Credit Memo");
        VATEntry.SetRange("Document No.", PurchCrMemoHdr."No.");
        VATEntry.SetRange("Posting Date", PurchCrMemoHdr."Posting Date");
        if VATEntry.FindSet() then
            repeat
                ExportTaxInformation(VATEntry, TaxInformationTotalsTxt);
            until VATEntry.Next() = 0;

        PurchCrMemoHdr.CalcFields(Amount, "Amount Including VAT");
        XmlHelper.AppendXmlNode('NetTotal', SAFTDataMgt.GetSAFTMonetaryDecimal(PurchCrMemoHdr.Amount));
        XmlHelper.AppendXmlNode('GrossTotal', SAFTDataMgt.GetSAFTMonetaryDecimal(PurchCrMemoHdr."Amount Including VAT"));
        XmlHelper.FinalizeXmlNode();

        XmlHelper.FinalizeXmlNode();
    end;

    local procedure ExportPurchaseCrMemoLine(var PurchCrMemoLine: Record "Purch. Cr. Memo Line"; var PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr."; ExchangeRate: Decimal)
    var
        TempDimIDBuffer: Record "Dimension ID Buffer" temporary;
        VATPostingSetup: Record "VAT Posting Setup";
        Params: Dictionary of [Text, Text];
        IsService: Boolean;
    begin
        if PurchCrMemoLine.Type = "Purchase Line Type"::" " then       // skip comment lines
            exit;

        XmlHelper.SetCurrentRec(PurchCrMemoLine);
        XmlHelper.AddNewXmlNode('Line', '');
        XmlHelper.AppendXmlNode('LineNumber', Format(PurchCrMemoLine."Line No."));
        CopyDimeSetIDToDimIDBuffer(TempDimIDBuffer, PurchCrMemoLine."Dimension Set ID");
        ExportAnalysisInfo(TempDimIDBuffer);

        if PurchCrMemoHdr."Return Order No." <> '' then begin
            XmlHelper.AddNewXmlNode('OrderReferences', '');
            XmlHelper.AppendXmlNode('OriginatingON', PurchCrMemoHdr."Return Order No.");
            XmlHelper.FinalizeXmlNode();
        end;

        IsService := SAFTDataMgt.IsPurchaseLineService(PurchCrMemoLine.Type, PurchCrMemoLine."No.");
        Params.Add('IsService', Format(IsService));
        XmlHelper.SetAdditionalParams(Params);
        XmlHelper.AppendXmlNode('GoodsServicesID', SAFTDataMgt.GetGoodsServicesID(IsService));
        XmlHelper.AppendXmlNode('ProductCode', PurchCrMemoLine."No.");
        XmlHelper.AppendXmlNode('ProductDescription', PurchCrMemoLine.Description);
        XmlHelper.AppendXmlNode('Quantity', FormatAmount(PurchCrMemoLine.Quantity));
        XmlHelper.AppendXmlNode('InvoiceUOM', SAFTDataMgt.GetSAFTCodeText(PurchCrMemoLine."Unit of Measure Code"));
        if (PurchCrMemoLine."Unit of Measure Code" <> '') and (PurchCrMemoLine."Qty. per Unit of Measure" <> 1) then
            XmlHelper.AppendXmlNode('UOMToUOMBaseConversionFactor', FormatAmount(PurchCrMemoLine."Qty. per Unit of Measure"));
        XmlHelper.AppendXmlNode('UnitPrice', SAFTDataMgt.GetSAFTMonetaryDecimal(PurchCrMemoLine."Direct Unit Cost"));
        XmlHelper.AppendXmlNode('InvoiceDate', FormatDate(PurchCrMemoHdr."Document Date"));

        XmlHelper.AppendXmlNode('Description', PurchCrMemoLine.Description);

        XmlHelper.AddNewXmlNode('InvoiceLineAmount', '');
        XmlHelper.AppendXmlNode('Amount', SAFTDataMgt.GetSAFTMonetaryDecimal(PurchCrMemoLine.Amount * ExchangeRate));
        if PurchCrMemoHdr."Currency Code" <> '' then begin
            XmlHelper.AppendXmlNode('CurrencyCode', SAFTDataMgt.GetISOCurrencyCode(PurchCrMemoHdr."Currency Code"));
            XmlHelper.AppendXmlNode('CurrencyAmount', SAFTDataMgt.GetSAFTMonetaryDecimal(PurchCrMemoLine.Amount));
            XmlHelper.AppendXmlNode('ExchangeRate', SAFTDataMgt.GetSAFTExchangeRateDecimal(ExchangeRate));
        end;
        XmlHelper.FinalizeXmlNode();

        XmlHelper.AppendXmlNode('DebitCreditIndicator', SAFTDataMgt.GetDebitCreditIndicator(PurchCrMemoLine.Amount));

        VATPostingSetup.SetLoadFields("Purchase Tax Code SAF-T", "Purch. VAT Reporting Code");
        if VATPostingSetup.Get(PurchCrMemoLine."VAT Bus. Posting Group", PurchCrMemoLine."VAT Prod. Posting Group") then
            ExportTaxInformation(
                VATPostingSetup."Purchase Tax Code SAF-T", VATPostingSetup."Purch. VAT Reporting Code", PurchCrMemoLine."VAT %",
                PurchCrMemoLine."VAT Base Amount", PurchCrMemoLine."Amount Including VAT" - PurchCrMemoLine.Amount);

        XmlHelper.FinalizeXmlNode();
    end;

    local procedure ExportPayments(AuditFileExportHeader: Record "Audit File Export Header")
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        CustLedgerEntrySAFT: Query "Cust. Ledger Entry SAF-T";
        VendorLedgerEntrySAFT: Query "Vendor Ledger Entry SAF-T";
        NumberOfEntries: Integer;
        TotalDebit: Decimal;
        TotalCredit: Decimal;
        GrossAmount: Decimal;
        PrevDocumentNo: Code[20];
        CustomerPaymentsExist: Boolean;
        VendorPaymentsExist: Boolean;
    begin
        CustLedgerEntrySAFT.SetFilter(Document_Type_Filter, '%1|%2', "Gen. Journal Document Type"::Payment, "Gen. Journal Document Type"::Refund);
        CustLedgerEntrySAFT.SetFilter(Posting_Date_Filter, '%1..%2', AuditFileExportHeader."Starting Date", AuditFileExportHeader."Ending Date");
        CustLedgerEntrySAFT.Open();
        CustomerPaymentsExist := CustLedgerEntrySAFT.Read();        // read the first row of customer payments

        VendorLedgerEntrySAFT.SetFilter(Document_Type_Filter, '%1|%2', "Gen. Journal Document Type"::Payment, "Gen. Journal Document Type"::Refund);
        VendorLedgerEntrySAFT.SetFilter(Posting_Date_Filter, '%1..%2', AuditFileExportHeader."Starting Date", AuditFileExportHeader."Ending Date");
        VendorLedgerEntrySAFT.Open();
        VendorPaymentsExist := VendorLedgerEntrySAFT.Read();        // read the first row of vendor payments

        if not CustomerPaymentsExist and not VendorPaymentsExist then
            exit;

        UpdateDataSourceInProgressDialog(ExportingPaymentsTxt);
        UpdateProgressDialog(2, '');

        XmlHelper.AddNewXmlNode('Payments', '');
        XmlHelper.SaveCurrXmlElement();             // NumberOfEntries

        TotalDebit += SAFTDataMgt.GetTotalAmountCustomerDocuments(AuditFileExportHeader."Starting Date", AuditFileExportHeader."Ending Date", "Gen. Journal Document Type"::Refund);
        TotalCredit += SAFTDataMgt.GetTotalAmountCustomerDocuments(AuditFileExportHeader."Starting Date", AuditFileExportHeader."Ending Date", "Gen. Journal Document Type"::Payment);

        TotalDebit += SAFTDataMgt.GetTotalAmountVendorDocuments(AuditFileExportHeader."Starting Date", AuditFileExportHeader."Ending Date", "Gen. Journal Document Type"::Payment);
        TotalCredit += SAFTDataMgt.GetTotalAmountVendorDocuments(AuditFileExportHeader."Starting Date", AuditFileExportHeader."Ending Date", "Gen. Journal Document Type"::Refund);

        XmlHelper.AppendXmlNode('TotalDebit', SAFTDataMgt.GetSAFTMonetaryDecimal(TotalDebit));
        XmlHelper.AppendXmlNode('TotalCredit', SAFTDataMgt.GetSAFTMonetaryDecimal(TotalCredit));

        // Customer payments
        if CustomerPaymentsExist then begin
            PrevDocumentNo := '';
            GrossAmount := 0;
            repeat
                NumberOfEntries += 1;
                CopyQueryFieldsToCustLedgerEntry(CustLedgerEntrySAFT, CustLedgerEntry);

                if CustLedgerEntry."Document No." <> PrevDocumentNo then begin
                    if PrevDocumentNo <> '' then begin
                        ExportCustPaymentGroupTotals(CustLedgerEntry, GrossAmount);
                        XmlHelper.FinalizeXmlNode();     // close previous Payment group
                    end;
                    ExportCustPaymentGroupHeader(CustLedgerEntry);
                    PrevDocumentNo := CustLedgerEntry."Document No.";
                    GrossAmount := 0;
                end;

                ExportCustomerPaymentLine(CustLedgerEntry);
                GrossAmount += CustLedgerEntry."Amount (LCY)";
            until not CustLedgerEntrySAFT.Read();

            if PrevDocumentNo <> '' then begin
                ExportCustPaymentGroupTotals(CustLedgerEntry, GrossAmount);
                XmlHelper.FinalizeXmlNode();     // close last Payment group
            end;
        end;

        // Vendor payments
        if VendorPaymentsExist then begin
            PrevDocumentNo := '';
            GrossAmount := 0;
            repeat
                NumberOfEntries += 1;
                CopyQueryFieldsToVendorLedgerEntry(VendorLedgerEntrySAFT, VendorLedgerEntry);

                if VendorLedgerEntry."Document No." <> PrevDocumentNo then begin
                    if PrevDocumentNo <> '' then begin
                        ExportVendorPaymentGroupTotals(VendorLedgerEntry, GrossAmount);
                        XmlHelper.FinalizeXmlNode();     // close previous Payment group
                    end;
                    ExportVendorPaymentGroupHeader(VendorLedgerEntry);
                    PrevDocumentNo := VendorLedgerEntry."Document No.";
                    GrossAmount := 0;
                end;

                ExportVendorPaymentLine(VendorLedgerEntry);
                GrossAmount += VendorLedgerEntry."Amount (LCY)";
            until not VendorLedgerEntrySAFT.Read();

            if PrevDocumentNo <> '' then begin
                ExportVendorPaymentGroupTotals(VendorLedgerEntry, GrossAmount);
                XmlHelper.FinalizeXmlNode();     // close last Payment group
            end;
        end;

        XmlHelper.AppendToSavedXMLNode('NumberOfEntries', Format(NumberOfEntries));
        XmlHelper.FinalizeXmlNode();
    end;

    local procedure ExportCustPaymentGroupHeader(var CustLedgerEntry: Record "Cust. Ledger Entry")
    var
        PaymentMethodCode: Code[10];
    begin
        PaymentMethodCode := CustLedgerEntry."Payment Method Code";
        if PaymentMethodCode = '' then begin
            GetSAFTSetup();
            PaymentMethodCode := GlobalAuditFileExportSetup."Default Payment Method Code";
        end;

        XmlHelper.SetCurrentRec(CustLedgerEntry);
        XmlHelper.AddNewXmlNode('Payment', '');
        XmlHelper.AppendXmlNode('PaymentRefNo', CustLedgerEntry."Document No.");

        XmlHelper.AppendXmlNode('Period', Format(Date2DMY(CustLedgerEntry."Posting Date", 2)));
        XmlHelper.AppendXmlNode('PeriodYear', Format(Date2DMY(CustLedgerEntry."Posting Date", 3)));
        XmlHelper.AppendXmlNode('TransactionID', GetSAFTTransactionID(CustLedgerEntry));
        XmlHelper.AppendXmlNode('TransactionDate', FormatDate(CustLedgerEntry."Document Date"));
        XmlHelper.AppendXmlNode('PaymentMethod', SAFTDataMgt.GetSAFTCodeText(PaymentMethodCode));
        XmlHelper.AppendXmlNode('Description', CustLedgerEntry.Description);
        XmlHelper.AppendXmlNode('BatchID', Format(CustLedgerEntry."Transaction No."));
        XmlHelper.AppendXmlNode('SourceID', SAFTDataMgt.GetSAFTMiddle1Text(CustLedgerEntry."User ID"));
    end;

    local procedure ExportCustPaymentGroupTotals(var CustLedgerEntry: Record "Cust. Ledger Entry"; GrossTotalAmount: Decimal)
    var
        VATEntry: Record "VAT Entry";
    begin
        XmlHelper.SetCurrentRec(CustLedgerEntry);
        XmlHelper.AddNewXmlNode('DocumentTotals', '');
        VATEntry.SetLoadFields(
            "Document Type", "Document No.", "Posting Date", Type, "VAT Bus. Posting Group", "VAT Prod. Posting Group", Base, Amount);
        VATEntry.SetRange("Document Type", CustLedgerEntry."Document Type");
        VATEntry.SetRange("Document No.", CustLedgerEntry."Document No.");
        VATEntry.SetRange("Posting Date", CustLedgerEntry."Posting Date");
        if VATEntry.FindSet() then
            repeat
                ExportTaxInformation(VATEntry, TaxInformationTotalsTxt);
            until VATEntry.Next() = 0;
        XmlHelper.AppendXmlNode('GrossTotal', SAFTDataMgt.GetSAFTMonetaryDecimal(GrossTotalAmount));
        XmlHelper.FinalizeXmlNode();
    end;

    local procedure ExportCustomerPaymentLine(var CustLedgerEntry: Record "Cust. Ledger Entry")
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        TempDimIDBuffer: Record "Dimension ID Buffer" temporary;
        AppliedDocumentNos: List of [Code[20]];
        TaxPointDate: Date;
    begin
        XmlHelper.SetCurrentRec(CustLedgerEntry);
        XmlHelper.AddNewXmlNode('Line', '');
        XmlHelper.AppendXmlNode('LineNumber', Format(CustLedgerEntry."Entry No."));
        XmlHelper.AppendXmlNode('SourceDocumentID', CustLedgerEntry."Document No.");
        XmlHelper.AppendXmlNode('AccountID', GetReceivablesAccount(CustLedgerEntry."Customer Posting Group"));

        CopyDimeSetIDToDimIDBuffer(TempDimIDBuffer, CustLedgerEntry."Dimension Set ID");
        ExportAnalysisInfo(TempDimIDBuffer);

        XmlHelper.AppendXmlNode('CustomerID', CustLedgerEntry."Customer No.");

        if CustLedgerEntry."Document Type" = "Gen. Journal Document Type"::Payment then begin
            AppliedDocumentNos := SAFTDataMgt.GetAppliedSalesDocuments(CustLedgerEntry."Entry No.", "Gen. Journal Document Type"::Invoice);
            if AppliedDocumentNos.Count > 0 then
                if SalesInvoiceHeader.Get(AppliedDocumentNos.Get(1)) then
                    TaxPointDate := SalesInvoiceHeader."Document Date";
        end else
            if CustLedgerEntry."Document Type" = "Gen. Journal Document Type"::Refund then begin
                AppliedDocumentNos := SAFTDataMgt.GetAppliedSalesDocuments(CustLedgerEntry."Entry No.", "Gen. Journal Document Type"::"Credit Memo");
                if AppliedDocumentNos.Count > 0 then
                    if SalesCrMemoHeader.Get(AppliedDocumentNos.Get(1)) then
                        TaxPointDate := SalesCrMemoHeader."Document Date";
            end;
        XmlHelper.AppendXmlNode('TaxPointDate', FormatDate(TaxPointDate));

        XmlHelper.AppendXmlNode('Description', CustLedgerEntry.Description);
        XmlHelper.AppendXmlNode('DebitCreditIndicator', SAFTDataMgt.GetDebitCreditIndicator(CustLedgerEntry.Amount));

        XmlHelper.AddNewXmlNode('PaymentLineAmount', '');
        XmlHelper.AppendXmlNode('Amount', SAFTDataMgt.GetSAFTMonetaryDecimal(CustLedgerEntry."Amount (LCY)"));
        if CustLedgerEntry."Currency Code" <> '' then begin
            XmlHelper.AppendXmlNode('CurrencyCode', SAFTDataMgt.GetISOCurrencyCode(CustLedgerEntry."Currency Code"));
            XmlHelper.AppendXmlNode('CurrencyAmount', SAFTDataMgt.GetSAFTMonetaryDecimal(CustLedgerEntry.Amount));
            XmlHelper.AppendXmlNode('ExchangeRate', SAFTDataMgt.GetSAFTExchangeRateDecimal(CustLedgerEntry."Amount (LCY)" / CustLedgerEntry.Amount));
        end;
        XmlHelper.FinalizeXmlNode();

        XmlHelper.FinalizeXmlNode();
    end;

    local procedure ExportVendorPaymentGroupHeader(var VendorLedgerEntry: Record "Vendor Ledger Entry")
    var
        PaymentMethodCode: Code[10];
    begin
        PaymentMethodCode := VendorLedgerEntry."Payment Method Code";
        if PaymentMethodCode = '' then begin
            GetSAFTSetup();
            PaymentMethodCode := GlobalAuditFileExportSetup."Default Payment Method Code";
        end;

        XmlHelper.SetCurrentRec(VendorLedgerEntry);
        XmlHelper.AddNewXmlNode('Payment', '');
        XmlHelper.AppendXmlNode('PaymentRefNo', VendorLedgerEntry."Document No.");

        XmlHelper.AppendXmlNode('Period', Format(Date2DMY(VendorLedgerEntry."Posting Date", 2)));
        XmlHelper.AppendXmlNode('PeriodYear', Format(Date2DMY(VendorLedgerEntry."Posting Date", 3)));
        XmlHelper.AppendXmlNode('TransactionID', GetSAFTTransactionID(VendorLedgerEntry));
        XmlHelper.AppendXmlNode('TransactionDate', FormatDate(VendorLedgerEntry."Document Date"));
        XmlHelper.AppendXmlNode('PaymentMethod', SAFTDataMgt.GetSAFTCodeText(PaymentMethodCode));
        XmlHelper.AppendXmlNode('Description', VendorLedgerEntry.Description);
        XmlHelper.AppendXmlNode('BatchID', Format(VendorLedgerEntry."Transaction No."));
        XmlHelper.AppendXmlNode('SourceID', SAFTDataMgt.GetSAFTMiddle1Text(VendorLedgerEntry."User ID"));
    end;

    local procedure ExportVendorPaymentGroupTotals(var VendorLedgerEntry: Record "Vendor Ledger Entry"; GrossTotalAmount: Decimal)
    var
        VATEntry: Record "VAT Entry";
    begin
        XmlHelper.SetCurrentRec(VendorLedgerEntry);
        XmlHelper.AddNewXmlNode('DocumentTotals', '');
        VATEntry.SetLoadFields(
            "Document Type", "Document No.", "Posting Date", Type, "VAT Bus. Posting Group", "VAT Prod. Posting Group", Base, Amount);
        VATEntry.SetRange("Document Type", VendorLedgerEntry."Document Type");
        VATEntry.SetRange("Document No.", VendorLedgerEntry."Document No.");
        VATEntry.SetRange("Posting Date", VendorLedgerEntry."Posting Date");
        if VATEntry.FindSet() then
            repeat
                ExportTaxInformation(VATEntry, TaxInformationTotalsTxt);
            until VATEntry.Next() = 0;
        XmlHelper.AppendXmlNode('GrossTotal', SAFTDataMgt.GetSAFTMonetaryDecimal(GrossTotalAmount));
        XmlHelper.FinalizeXmlNode();
    end;

    local procedure ExportVendorPaymentLine(var VendorLedgerEntry: Record "Vendor Ledger Entry")
    var
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        TempDimIDBuffer: Record "Dimension ID Buffer" temporary;
        AppliedDocumentNos: List of [Code[20]];
        TaxPointDate: Date;
    begin
        if VendorLedgerEntry.Amount = 0 then
            exit;

        XmlHelper.SetCurrentRec(VendorLedgerEntry);
        XmlHelper.AddNewXmlNode('Line', '');
        XmlHelper.AppendXmlNode('LineNumber', Format(VendorLedgerEntry."Entry No."));
        XmlHelper.AppendXmlNode('SourceDocumentID', VendorLedgerEntry."Document No.");
        XmlHelper.AppendXmlNode('AccountID', GetPayablesAccount(VendorLedgerEntry."Vendor Posting Group"));

        CopyDimeSetIDToDimIDBuffer(TempDimIDBuffer, VendorLedgerEntry."Dimension Set ID");
        ExportAnalysisInfo(TempDimIDBuffer);

        XmlHelper.AppendXmlNode('SupplierID', VendorLedgerEntry."Vendor No.");

        if VendorLedgerEntry."Document Type" = "Gen. Journal Document Type"::Payment then begin
            AppliedDocumentNos := SAFTDataMgt.GetAppliedSalesDocuments(VendorLedgerEntry."Entry No.", "Gen. Journal Document Type"::Invoice);
            if AppliedDocumentNos.Count > 0 then
                if PurchInvHeader.Get(AppliedDocumentNos.Get(1)) then
                    TaxPointDate := PurchInvHeader."Document Date";
        end else
            if VendorLedgerEntry."Document Type" = "Gen. Journal Document Type"::Refund then begin
                AppliedDocumentNos := SAFTDataMgt.GetAppliedSalesDocuments(VendorLedgerEntry."Entry No.", "Gen. Journal Document Type"::"Credit Memo");
                if AppliedDocumentNos.Count > 0 then
                    if PurchCrMemoHdr.Get(AppliedDocumentNos.Get(1)) then
                        TaxPointDate := PurchCrMemoHdr."Document Date";
            end;
        XmlHelper.AppendXmlNode('TaxPointDate', FormatDate(TaxPointDate));

        XmlHelper.AppendXmlNode('Description', VendorLedgerEntry.Description);
        XmlHelper.AppendXmlNode('DebitCreditIndicator', SAFTDataMgt.GetDebitCreditIndicator(VendorLedgerEntry.Amount));

        XmlHelper.AddNewXmlNode('PaymentLineAmount', '');
        XmlHelper.AppendXmlNode('Amount', SAFTDataMgt.GetSAFTMonetaryDecimal(VendorLedgerEntry."Amount (LCY)"));
        if VendorLedgerEntry."Currency Code" <> '' then begin
            XmlHelper.AppendXmlNode('CurrencyCode', SAFTDataMgt.GetISOCurrencyCode(VendorLedgerEntry."Currency Code"));
            XmlHelper.AppendXmlNode('CurrencyAmount', SAFTDataMgt.GetSAFTMonetaryDecimal(VendorLedgerEntry.Amount));
            XmlHelper.AppendXmlNode('ExchangeRate', SAFTDataMgt.GetSAFTExchangeRateDecimal(VendorLedgerEntry."Amount (LCY)" / VendorLedgerEntry.Amount));
        end;
        XmlHelper.FinalizeXmlNode();

        XmlHelper.FinalizeXmlNode();
    end;

    local procedure ExportMovementOfGoods(AuditFileExportHeader: Record "Audit File Export Header")
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        ItemLedgerEntrySAFT: Query "Item Ledger Entry SAF-T";
        NumberOfMovements: Integer;
        TotalQtyReceived: Decimal;
        TotalQtyIssued: Decimal;
        PrevDocumentNo: Code[20];
        PrevDocumentType: Enum "Item Ledger Document Type";
        PrevEntryType: Enum "Item Ledger Entry Type";
    begin
        ItemLedgerEntry.SetRange("Posting Date", AuditFileExportHeader."Starting Date", AuditFileExportHeader."Ending Date");
        ItemLedgerEntry.SetRange(Positive, true);
        ItemLedgerEntry.CalcSums(Quantity);
        TotalQtyReceived := ItemLedgerEntry.Quantity;

        ItemLedgerEntry.SetRange(Positive, false);
        ItemLedgerEntry.CalcSums(Quantity);
        TotalQtyIssued := Abs(ItemLedgerEntry.Quantity);

        if (TotalQtyReceived = 0) and (TotalQtyIssued = 0) then
            exit;

        UpdateDataSourceInProgressDialog(ExportingMovementOfGoodsTxt);
        UpdateProgressDialog(2, '');

        XmlHelper.AddNewXmlNode('MovementOfGoods', '');
        XmlHelper.SaveCurrXmlElement();             // NumberOfEntries

        XmlHelper.AppendXmlNode('TotalQuantityReceived', SAFTDataMgt.GetSAFTMonetaryDecimal(TotalQtyReceived));
        XmlHelper.AppendXmlNode('TotalQuantityIssued', SAFTDataMgt.GetSAFTMonetaryDecimal(TotalQtyIssued));

        PrevDocumentNo := '';
        PrevEntryType := "Item Ledger Entry Type"::" ";
        PrevDocumentType := "Item Ledger Document Type"::" ";
        ItemLedgerEntrySAFT.SetFilter(Posting_Date_Filter, '%1..%2', AuditFileExportHeader."Starting Date", AuditFileExportHeader."Ending Date");
        ItemLedgerEntrySAFT.Open();
        while ItemLedgerEntrySAFT.Read() do begin
            NumberOfMovements += 1;
            CopyQueryFieldsToItemLedgerEntry(ItemLedgerEntrySAFT, ItemLedgerEntry);
            if (ItemLedgerEntry."Document Type" <> PrevDocumentType) or
               (ItemLedgerEntry."Entry Type" <> PrevEntryType) or
               (ItemLedgerEntry."Document No." <> PrevDocumentNo)
            then begin
                if PrevDocumentNo <> '' then
                    XmlHelper.FinalizeXmlNode();     // close previous StockMovement group
                ExportMovementGroupHeader(ItemLedgerEntry);

                PrevDocumentType := ItemLedgerEntry."Document Type";
                PrevEntryType := ItemLedgerEntry."Entry Type";
                PrevDocumentNo := ItemLedgerEntry."Document No.";
            end;

            ExportMovementLine(ItemLedgerEntry);
        end;

        if PrevDocumentNo <> '' then
            XmlHelper.FinalizeXmlNode();     // close last StockMovement group

        XmlHelper.AppendToSavedXMLNode('NumberOfMovementLines', Format(NumberOfMovements));
        XmlHelper.FinalizeXmlNode();
    end;

    local procedure ExportMovementGroupHeader(var ItemLedgerEntry: Record "Item Ledger Entry")
    begin
        XmlHelper.SetCurrentRec(ItemLedgerEntry);
        XmlHelper.AddNewXmlNode('StockMovement', '');
        XmlHelper.AppendXmlNode('MovementReference', ItemLedgerEntry."Document No.");
        XmlHelper.AppendXmlNode('MovementDate', FormatDate(ItemLedgerEntry."Document Date"));
        XmlHelper.AppendXmlNode('MovementPostingDate', FormatDate(ItemLedgerEntry."Posting Date"));
        XmlHelper.AppendXmlNode('MovementType', SAFTDataMgt.GetMovementEntryType(ItemLedgerEntry."Entry Type"));

        XmlHelper.AddNewXmlNode('DocumentReference', '');
        XmlHelper.AppendXmlNode('DocumentType', SAFTDataMgt.GetMovementDocType(ItemLedgerEntry."Document Type"));
        XmlHelper.AppendXmlNode('DocumentNumber', ItemLedgerEntry."Document No.");
        XmlHelper.FinalizeXmlNode();
    end;

    local procedure ExportMovementLine(var ItemLedgerEntry: Record "Item Ledger Entry")
    var
        ShipToAddress: Record "Ship-to Address";
        ShipFromAddress: Record "Ship-to Address";
        Item: Record Item;
        PackageTrackingNo: Text;
        StockAccountNo: Text;
        BookValue: Decimal;
        ShipToAddressEmpty: Boolean;
        ShipFromAddressEmpty: Boolean;
    begin
        if ItemLedgerEntry.Quantity = 0 then
            exit;

        XmlHelper.SetCurrentRec(ItemLedgerEntry);
        XmlHelper.AddNewXmlNode('Line', '');
        XmlHelper.AppendXmlNode('LineNumber', Format(ItemLedgerEntry."Entry No."));

        if ItemLedgerEntry."Source Type" = "Analysis Source Type"::Customer then
            XmlHelper.AppendXmlNode('CustomerID', ItemLedgerEntry."Source No.")
        else
            if ItemLedgerEntry."Source Type" = "Analysis Source Type"::Vendor then
                XmlHelper.AppendXmlNode('SupplierID', ItemLedgerEntry."Source No.");

        SAFTDataMgt.GetShipToAddressFromItemLedgerEntry(ItemLedgerEntry, ShipToAddress);
        ShipToAddressEmpty :=
            (ShipToAddress.Address = '') and (ShipToAddress."Address 2" = '') and (ShipToAddress.City = '') and
            (ShipToAddress."Post Code" = '') and (ShipToAddress."Country/Region Code" = '');
        if not ShipToAddressEmpty then begin
            XmlHelper.AddNewXmlNode('ShipTo', '');
            ExportAddress(
                AddressTxt, CombineWithSpace(ShipToAddress.Address, ShipToAddress."Address 2"),
                ShipToAddress.City, ShipToAddress."Post Code", ShipToAddress."Country/Region Code", ShipToAddressTxt);
            XmlHelper.FinalizeXmlNode();
        end;

        SAFTDataMgt.GetShipFromAddressFromItemLedgerEntry(ItemLedgerEntry, ShipFromAddress, PackageTrackingNo);
        ShipFromAddressEmpty :=
            (ShipFromAddress.Address = '') and (ShipFromAddress."Address 2" = '') and (ShipFromAddress.City = '') and
            (ShipFromAddress."Post Code" = '') and (ShipFromAddress."Country/Region Code" = '');
        if not ShipFromAddressEmpty or (PackageTrackingNo <> '') then begin
            XmlHelper.AddNewXmlNode('ShipFrom', '');
            XmlHelper.AppendXmlNode('DeliveryID', PackageTrackingNo);
            if not ShipFromAddressEmpty then
                ExportAddress(
                    AddressTxt, CombineWithSpace(ShipFromAddress.Address, ShipFromAddress."Address 2"),
                    ShipFromAddress.City, ShipFromAddress."Post Code", ShipFromAddress."Country/Region Code", ShipFromAddressTxt);
            XmlHelper.FinalizeXmlNode();
        end;

        XmlHelper.AppendXmlNode('ProductCode', ItemLedgerEntry."Item No.");

        StockAccountNo := ItemLedgerEntry."Serial No.";
        if StockAccountNo = '' then
            StockAccountNo := ItemLedgerEntry."Lot No.";
        XmlHelper.AppendXmlNode('StockAccountNo', StockAccountNo);

        XmlHelper.AppendXmlNode('Quantity', FormatAmount(ItemLedgerEntry.Quantity));

        Item.SetLoadFields("Base Unit of Measure");
        Item.Get(ItemLedgerEntry."Item No.");
        XmlHelper.AppendXmlNode('UnitOfMeasure', Item."Base Unit of Measure");
        XmlHelper.AppendXmlNode('UOMToUOMPhysicalStockConversionFactor', Format(1));    // Quantity in Item Ledger Entry is always in base UOM

        if ItemLedgerEntry."Entry Type" = "Item Ledger Entry Type"::Sale then
            BookValue := ItemLedgerEntry."Sales Amount (Actual)"
        else
            if ItemLedgerEntry."Entry Type" = "Item Ledger Entry Type"::Purchase then
                BookValue := ItemLedgerEntry."Cost Amount (Actual)";
        XmlHelper.AppendXMLNodeIfNotZero('BookValue', Round(BookValue, 0.01));

        XmlHelper.AppendXmlNode('MovementSubType', SAFTDataMgt.GetMovementEntryType(ItemLedgerEntry."Entry Type"));
        XmlHelper.FinalizeXmlNode();
    end;

    local procedure ExportAssetTransactions(AuditFileExportHeader: Record "Audit File Export Header")
    var
        FALedgerEntry: Record "FA Ledger Entry";
        FALedgerEntrySAFT: Query "FA Ledger Entry SAF-T";
        NumberOfAssetTransactions: Integer;
        FALedgerEntriesExist: Boolean;
    begin
        FALedgerEntrySAFT.SetFilter(Posting_Date_Filter, '%1..%2', AuditFileExportHeader."Starting Date", AuditFileExportHeader."Ending Date");
        FALedgerEntrySAFT.Open();
        FALedgerEntriesExist := FALedgerEntrySAFT.Read();        // read the first row
        if not FALedgerEntriesExist then
            exit;

        UpdateDataSourceInProgressDialog(ExportingAssetTransactionsTxt);
        UpdateProgressDialog(2, '');

        XmlHelper.AddNewXmlNode('AssetTransactions', '');
        XmlHelper.SaveCurrXmlElement();         // NumberOfAssetTransactions

        repeat
            NumberOfAssetTransactions += 1;
            CopyQueryFieldsToFALedgerEntry(FALedgerEntrySAFT, FALedgerEntry);
            ExportAssetTransaction(FALedgerEntry);
        until not FALedgerEntrySAFT.Read();

        XmlHelper.AppendToSavedXMLNode('NumberOfAssetTransactions', Format(NumberOfAssetTransactions));
        XmlHelper.FinalizeXmlNode();
    end;

    local procedure ExportAssetTransaction(var FALedgerEntry: Record "FA Ledger Entry")
    var
        AcquisitionFALedgerEntry: Record "FA Ledger Entry";
        VendorNo: Code[20];
    begin
        XmlHelper.SetCurrentRec(FALedgerEntry);
        XmlHelper.AddNewXmlNode('AssetTransaction', '');
        XmlHelper.AppendXmlNode('AssetTransactionID', Format(FALedgerEntry."Entry No."));
        XmlHelper.AppendXmlNode('AssetID', FALedgerEntry."FA No.");
        XmlHelper.AppendXmlNode('AssetTransactionType', SAFTDataMgt.GetAssetTransactionType(FALedgerEntry."FA Posting Type"));
        XmlHelper.AppendXmlNode('Description', FALedgerEntry.Description);
        XmlHelper.AppendXmlNode('AssetTransactionDate', FormatDate(FALedgerEntry."FA Posting Date"));

        SAFTDataMgt.GetFixedAssetAcquisitionLedgerEntry(AcquisitionFALedgerEntry, FALedgerEntry."FA No.");
        VendorNo := SAFTDataMgt.GetFixedAssetAcquisitionVendorNo(FALedgerEntry);
        ExportAssetSupplier(VendorNo);

        XmlHelper.SetCurrentRec(FALedgerEntry);
        XmlHelper.AppendXmlNode('TransactionID', Format(FALedgerEntry."G/L Entry No."));
        XmlHelper.AddNewXmlNode('AssetTransactionValuations', '');
        XmlHelper.AddNewXmlNode('AssetTransactionValuation', '');
        XmlHelper.AppendXmlNode('AssetValuationType', FALedgerEntry."Depreciation Book Code");
        XmlHelper.AppendXmlNode('AcquisitionAndProductionCostsOnTransaction', SAFTDataMgt.GetSAFTMonetaryDecimal(AcquisitionFALedgerEntry."Amount (LCY)"));
        XmlHelper.AppendXmlNode('BookValueOnTransaction', SAFTDataMgt.GetSAFTMonetaryDecimal(SAFTDataMgt.GetFixedAssetBookValueOnTransactionDate(FALedgerEntry)));
        XmlHelper.AppendXmlNode('AssetTransactionAmount', SAFTDataMgt.GetSAFTMonetaryDecimal(AcquisitionFALedgerEntry."Amount (LCY)"));
        XmlHelper.FinalizeXmlNode();
        XmlHelper.FinalizeXmlNode();

        XmlHelper.FinalizeXmlNode();
    end;

    local procedure CopyQueryFieldsToCustLedgerEntry(var CustLedgerEntrySAFT: Query "Cust. Ledger Entry SAF-T"; var CustLedgerEntry: Record "Cust. Ledger Entry")
    begin
        CustLedgerEntry.Init();
        CustLedgerEntry."Entry No." := CustLedgerEntrySAFT.Entry_No_;
        CustLedgerEntry."Document Type" := CustLedgerEntrySAFT.Document_Type;
        CustLedgerEntry."Document No." := CustLedgerEntrySAFT.Document_No_;
        CustLedgerEntry."Posting Date" := CustLedgerEntrySAFT.Posting_Date;
        CustLedgerEntry."Document Date" := CustLedgerEntrySAFT.Document_Date;
        CustLedgerEntry."Customer No." := CustLedgerEntrySAFT.Customer_No_;
        CustLedgerEntry."Payment Method Code" := CustLedgerEntrySAFT.Payment_Method_Code;
        CustLedgerEntry.Description := CustLedgerEntrySAFT.Description;
        CustLedgerEntry."Transaction No." := CustLedgerEntrySAFT.Transaction_No_;
        CustLedgerEntry."User ID" := CustLedgerEntrySAFT.User_ID;
        CustLedgerEntry."Dimension Set ID" := CustLedgerEntrySAFT.Dimension_Set_ID;
        CustLedgerEntry."Currency Code" := CustLedgerEntrySAFT.Currency_Code;
        CustLedgerEntry."Customer Posting Group" := CustLedgerEntrySAFT.Customer_Posting_Group;
        CustLedgerEntry.Amount := CustLedgerEntrySAFT.Amount;
        CustLedgerEntry."Amount (LCY)" := CustLedgerEntrySAFT.Amount__LCY_;
    end;

    local procedure CopyQueryFieldsToVendorLedgerEntry(var VendorLedgerEntrySAFT: Query "Vendor Ledger Entry SAF-T"; var VendorLedgerEntry: Record "Vendor Ledger Entry")
    begin
        VendorLedgerEntry.Init();
        VendorLedgerEntry."Entry No." := VendorLedgerEntrySAFT.Entry_No_;
        VendorLedgerEntry."Document Type" := VendorLedgerEntrySAFT.Document_Type;
        VendorLedgerEntry."Document No." := VendorLedgerEntrySAFT.Document_No_;
        VendorLedgerEntry."Posting Date" := VendorLedgerEntrySAFT.Posting_Date;
        VendorLedgerEntry."Document Date" := VendorLedgerEntrySAFT.Document_Date;
        VendorLedgerEntry."Vendor No." := VendorLedgerEntrySAFT.Vendor_No_;
        VendorLedgerEntry."Payment Method Code" := VendorLedgerEntrySAFT.Payment_Method_Code;
        VendorLedgerEntry.Description := VendorLedgerEntrySAFT.Description;
        VendorLedgerEntry."Transaction No." := VendorLedgerEntrySAFT.Transaction_No_;
        VendorLedgerEntry."User ID" := VendorLedgerEntrySAFT.User_ID;
        VendorLedgerEntry."Dimension Set ID" := VendorLedgerEntrySAFT.Dimension_Set_ID;
        VendorLedgerEntry."Currency Code" := VendorLedgerEntrySAFT.Currency_Code;
        VendorLedgerEntry."Vendor Posting Group" := VendorLedgerEntrySAFT.Vendor_Posting_Group;
        VendorLedgerEntry.Amount := VendorLedgerEntrySAFT.Amount;
        VendorLedgerEntry."Amount (LCY)" := VendorLedgerEntrySAFT.Amount__LCY_;
    end;

    local procedure CopyQueryFieldsToItemLedgerEntry(var ItemLedgerEntrySAFT: Query "Item Ledger Entry SAF-T"; var ItemLedgerEntry: Record "Item Ledger Entry")
    begin
        ItemLedgerEntry.Init();
        ItemLedgerEntry."Entry Type" := ItemLedgerEntrySAFT.Entry_Type;
        ItemLedgerEntry."Entry No." := ItemLedgerEntrySAFT.Entry_No_;
        ItemLedgerEntry."Document Type" := ItemLedgerEntrySAFT.Document_Type;
        ItemLedgerEntry."Document No." := ItemLedgerEntrySAFT.Document_No_;
        ItemLedgerEntry."Source Type" := ItemLedgerEntrySAFT.Source_Type;
        ItemLedgerEntry."Source No." := ItemLedgerEntrySAFT.Source_No_;
        ItemLedgerEntry."Posting Date" := ItemLedgerEntrySAFT.Posting_Date;
        ItemLedgerEntry."Document Date" := ItemLedgerEntrySAFT.Document_Date;
        ItemLedgerEntry."Location Code" := ItemLedgerEntrySAFT.Location_Code;
        ItemLedgerEntry."Item No." := ItemLedgerEntrySAFT.Item_No_;
        ItemLedgerEntry."Serial No." := ItemLedgerEntrySAFT.Serial_No_;
        ItemLedgerEntry."Lot No." := ItemLedgerEntrySAFT.Lot_No_;
        ItemLedgerEntry."Unit of Measure Code" := ItemLedgerEntrySAFT.Unit_of_Measure_Code;
        ItemLedgerEntry."Qty. per Unit of Measure" := ItemLedgerEntrySAFT.Qty__per_Unit_of_Measure;
        ItemLedgerEntry.Quantity := ItemLedgerEntrySAFT.Quantity;
        ItemLedgerEntry."Sales Amount (Actual)" := ItemLedgerEntrySAFT.Sales_Amount__Actual_;
        ItemLedgerEntry."Purchase Amount (Actual)" := ItemLedgerEntrySAFT.Purchase_Amount__Actual_;
    end;

    local procedure CopyQueryFieldsToGLEntry(var GLEntrySAFT: Query "G/L Entry SAF-T"; var GLEntry: Record "G/L Entry")
    begin
        GLEntry.Init();
        GLEntry."Entry No." := GLEntrySAFT.Entry_No_;
        GLEntry."Document Type" := GLEntrySAFT.Document_Type;
        GLEntry."Document No." := GLEntrySAFT.Document_No_;
        GLEntry."External Document No." := GLEntrySAFT.External_Document_No_;
        GLEntry."Posting Date" := GLEntrySAFT.Posting_Date;
        GLEntry."Document Date" := GLEntrySAFT.Document_Date;
        GLEntry."VAT Reporting Date" := GLEntrySAFT.VAT_Reporting_Date;
        GLEntry."G/L Account No." := GLEntrySAFT.G_L_Account_No_;
        GLEntry."Source Code" := GLEntrySAFT.Source_Code;
        GLEntry."Source Type" := GLEntrySAFT.Source_Type;
        GLEntry."Source No." := GLEntrySAFT.Source_No_;
        GLEntry.Description := GLEntrySAFT.Description;
        GLEntry."Transaction No." := GLEntrySAFT.Transaction_No_;
        GLEntry."User ID" := GLEntrySAFT.User_ID;
        GLEntry."Dimension Set ID" := GLEntrySAFT.Dimension_Set_ID;
        GLEntry."VAT Bus. Posting Group" := GLEntrySAFT.VAT_Bus__Posting_Group;
        GLEntry."VAT Prod. Posting Group" := GLEntrySAFT.VAT_Prod__Posting_Group;
        GLEntry."Last Modified DateTime" := GLEntrySAFT.Last_Modified_DateTime;
        GLEntry."Debit Amount" := GLEntrySAFT.Debit_Amount;
        GLEntry."Credit Amount" := GLEntrySAFT.Credit_Amount;
    end;

    local procedure CopyQueryFieldsToFALedgerEntry(var FALedgerEntrySAFT: Query "FA Ledger Entry SAF-T"; var FALedgerEntry: Record "FA Ledger Entry")
    begin
        FALedgerEntry.Init();
        FALedgerEntry."Entry No." := FALedgerEntrySAFT.Entry_No_;
        FALedgerEntry."FA Posting Type" := FALedgerEntrySAFT.FA_Posting_Type;
        FALedgerEntry."FA Posting Date" := FALedgerEntrySAFT.FA_Posting_Date;
        FALedgerEntry."FA No." := FALedgerEntrySAFT.FA_No_;
        FALedgerEntry.Description := FALedgerEntrySAFT.Description;
        FALedgerEntry."G/L Entry No." := FALedgerEntrySAFT.G_L_Entry_No_;
        FALedgerEntry."Amount (LCY)" := FALedgerEntrySAFT.Amount__LCY_;
    end;

    local procedure CombineWithSpace(FirstString: Text; SecondString: Text) Result: Text
    begin
        Result := FirstString;
        if (Result <> '') and (SecondString <> '') then
            Result += ' ';
        exit(Result + SecondString);
    end;

    local procedure FormatDate(DateToFormat: Date): Text
    begin
        exit(Format(DateToFormat, 0, 9));
    end;

    local procedure FormatAmount(AmountToFormat: Decimal): Text
    begin
        exit(Format(AmountToFormat, 0, 9))
    end;

    local procedure GetSAFTSetup()
    begin
        if IsSAFTSetupLoaded then
            exit;
        GlobalAuditFileExportSetup.Get();
        IsSAFTSetupLoaded := true;
    end;

    local procedure GetPayablesAccount(VendorPostingGroupCode: Code[20]) PayablesAcc: Code[20]
    var
        VendorPostingGroup: Record "Vendor Posting Group";
    begin
        if PayablesAccounts.Get(VendorPostingGroupCode, PayablesAcc) then
            exit;

        VendorPostingGroup.SetLoadFields("Payables Account");
        if VendorPostingGroup.Get(VendorPostingGroupCode) then begin
            PayablesAccounts.Add(VendorPostingGroup.Code, VendorPostingGroup."Payables Account");
            PayablesAcc := VendorPostingGroup."Payables Account";
        end;
    end;

    local procedure GetReceivablesAccount(CustomerPostingGroupCode: Code[20]) ReceivablesAcc: Code[20]
    var
        CustomerPostingGroup: Record "Customer Posting Group";
    begin
        if ReceivablesAccounts.Get(CustomerPostingGroupCode, ReceivablesAcc) then
            exit;

        CustomerPostingGroup.SetLoadFields("Receivables Account");
        if CustomerPostingGroup.Get(CustomerPostingGroupCode) then begin
            ReceivablesAccounts.Add(CustomerPostingGroup.Code, CustomerPostingGroup."Receivables Account");
            ReceivablesAcc := CustomerPostingGroup."Receivables Account";
        end;
    end;

    local procedure UpdateDataSourceInProgressDialog(DataSourceCaption: Text)
    begin
        if GuiAllowed() then
            ProgressDialog.Update(1, DataSourceCaption);
    end;

    local procedure UpdateCountInProgressDialog(CurrentNumber: Integer; TotalNumber: Integer)
    begin
        if GuiAllowed() then
            ProgressDialog.Update(2, Format(Round(100 * (CurrentNumber / TotalNumber), 1)) + '%');
    end;

    local procedure UpdateProgressDialog(Number: Integer; NewText: Text)
    begin
        if GuiAllowed() then
            ProgressDialog.Update(Number, NewText);
    end;

    local procedure GetSAFTTransactionID(var GLEntry: Record "G/L Entry"): Text
    begin
        exit(GetSAFTTransactionID(GLEntry."Document No.", GLEntry."Posting Date"));
    end;

    local procedure GetSAFTTransactionID(var CustomerLedgerEntry: Record "Cust. Ledger Entry"): Text
    begin
        exit(GetSAFTTransactionID(CustomerLedgerEntry."Document No.", CustomerLedgerEntry."Posting Date"));
    end;

    local procedure GetSAFTTransactionID(var VendorLedgerEntry: Record "Vendor Ledger Entry"): Text
    begin
        exit(GetSAFTTransactionID(VendorLedgerEntry."Document No.", VendorLedgerEntry."Posting Date"));
    end;

    local procedure GetSAFTTransactionID(DocNo: Code[20]; PostingDate: Date): Text
    begin
        exit(DocNo + Format(PostingDate, 0, '<Day,2><Month,2><Year,2>'));
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetFirstAndLastNameFromCustomer(var Handled: Boolean; var FirstName: Text; var LastName: Text; Customer: Record Customer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetFirstAndLastNameFromVendor(var Handled: Boolean; var FirstName: Text; var LastName: Text; Vendor: Record Vendor)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeExportVATEntryAmountInfo(var XMLHelperSAFT: Codeunit "Xml Helper SAF-T"; VATEntry: Record "VAT Entry"; var IsHandled: Boolean)
    begin
    end;
}
