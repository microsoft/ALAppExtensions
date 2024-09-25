// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

using Microsoft.Bank.BankAccount;
using Microsoft.Bank.Ledger;
using Microsoft.Finance.Currency;
using Microsoft.Finance.Dimension;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.VAT.Ledger;
using Microsoft.Finance.VAT.Reporting;
using Microsoft.Finance.VAT.Setup;
using Microsoft.Foundation.Address;
using Microsoft.Foundation.AuditCodes;
using Microsoft.Foundation.Company;
using Microsoft.Foundation.PaymentTerms;
using Microsoft.HumanResources.Employee;
using Microsoft.Purchases.Payables;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Receivables;
using System.Reflection;

codeunit 10673 "Generate SAF-T File"
{
    TableNo = "SAF-T Export Line";
    trigger OnRun()
    var
        SAFTExportHeader: Record "SAF-T Export Header";
        GLEntry: Record "G/L Entry";
    begin
        LockTable();
        Validate("Server Instance ID", ServiceInstanceId());
        Validate("Session ID", SessionId());
        Validate("Created Date/Time", 0DT);
        Validate("No. Of Retries", 3);
        Modify();
        Commit();

        if GuiAllowed() then
            Window.Open(
                '#1#################################\\' +
                '@2@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@');
        SAFTExportHeader.Get(ID);
        if "Master Data" then begin
            ExportHeaderWithMasterFiles(SAFTExportHeader);
            if GuiAllowed() then
                Window.Close();
            FinalizeExport(Rec, SAFTExportHeader);
            exit;
        end;
        ExportHeader(SAFTExportHeader);
        GLEntry.SetCurrentKey("Document No.", "Posting Date");
        GLEntry.SetRange("Posting Date", "Starting Date", "Ending Date");
        ExportGeneralLedgerEntries(GLEntry, Rec);
        if GuiAllowed() then
            Window.Close();
        FinalizeExport(Rec, SAFTExportHeader);
    end;

    var
        GlobalSAFTSetup: Record "SAF-T Setup";
        GlobalCustomer: Record Customer;
        GlobalVendor: Record Vendor;
        GlobalCustomerPostingGroup: Record "Customer Posting Group";
        GlobalVendorPostingGroup: Record "Vendor Posting Group";
        GlobalCurrency: Record Currency;
        SAFTXMLHelper: Codeunit "SAF-T XML Helper";
        Window: Dialog;
        SAFTSetupGot: Boolean;
        GeneratingHeaderTxt: Label 'Generating header...';
        ExportingGLAccountsTxt: Label 'Exporting g/l Accounts...';
        ExportingCustomersTxt: Label 'Exporting customers...';
        ExportingVendorsTxt: Label 'Exporting vendors...';
        ExportingVATPostingSetupTxt: Label 'Exporting VAT Posting Setup...';
        ExportingDimensionsTxt: Label 'Exporting Dimensions...';
        ExportingGLEntriesTxt: Label 'Exporting G/L entries...';
        SkatteetatenMsg: Label 'Skatteetaten', Locked = true;
        BlankTxt: Label 'Blank';
        NATxt: Label 'NA', Comment = 'Stands for Not Applicable';

    local procedure ExportHeaderWithMasterFiles(SAFTExportHeader: Record "SAF-T Export Header")
    begin
        ExportHeader(SAFTExportHeader);
        ExportMasterFiles(SAFTExportHeader);
    end;

    local procedure ExportHeader(SAFTExportHeader: Record "SAF-T Export Header")
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        CompanyInformation: Record "Company Information";
        CountryRegion: Record "Country/Region";
    begin
        SAFTXMLHelper.Initialize();
        if GuiAllowed() then
            Window.Update(1, GeneratingHeaderTxt);
        CompanyInformation.get();
        SAFTXMLHelper.AddNewXMLNode('Header', '');
        SAFTXMLHelper.AppendXMLNode('AuditFileVersion', '1.0');
        if CompanyInformation."Country/Region Code" <> '' then begin
            CountryRegion.Get(CompanyInformation."Country/Region Code");
            if CountryRegion."ISO Code" = '' then
                SAFTXMLHelper.AppendXMLNode('AuditFileCountry', CompanyInformation."Country/Region Code")
            else
                SAFTXMLHelper.AppendXMLNode('AuditFileCountry', CountryRegion."ISO Code");
        end;
        SAFTXMLHelper.AppendXMLNode('AuditFileDateCreated', FormatDate(today()));
        SAFTXMLHelper.AppendXMLNode('SoftwareCompanyName', 'Microsoft');
        SAFTXMLHelper.AppendXMLNode('SoftwareID', 'Microsoft Dynamics 365 Business Central');
        SAFTXMLHelper.AppendXMLNode('SoftwareVersion', '14.0');
        ExportCompanyInfo('Company');
        GeneralLedgerSetup.get();
        SAFTXMLHelper.AppendXMLNode('DefaultCurrencyCode', GeneralLedgerSetup."LCY Code");

        SAFTXMLHelper.AddNewXMLNode('SelectionCriteria', '');
        SAFTXMLHelper.AppendXMLNode('PeriodStart', format(Date2DMY(SAFTExportHeader."Starting Date", 2)));
        SAFTXMLHelper.AppendXMLNode('PeriodStartYear', format(Date2DMY(SAFTExportHeader."Starting Date", 3)));
        SAFTXMLHelper.AppendXMLNode('PeriodEnd', format(Date2DMY(SAFTExportHeader."Ending Date", 2)));
        SAFTXMLHelper.AppendXMLNode('PeriodEndYear', format(Date2DMY(SAFTExportHeader."Ending Date", 3)));
        SAFTXMLHelper.FinalizeXMLNode();

        SAFTXMLHelper.AppendXMLNode('HeaderComment', SAFTExportHeader."Header Comment");
        SAFTXMLHelper.AppendXMLNode('TaxAccountingBasis', 'A');
        SAFTXMLHelper.AppendXMLNode('UserID', GetSAFTMiddle1Text(UserId()));
        SAFTXMLHelper.FinalizeXMLNode();
    end;

    local procedure ExportCompanyInfo(ParentNodeName: Text)
    var
        CompanyInformation: Record "Company Information";
        Employee: Record Employee;
    begin
        SAFTXMLHelper.AddNewXMLNode(ParentNodeName, '');
        CompanyInformation.get();
        SAFTXMLHelper.AppendXMLNode('RegistrationNumber', CompanyInformation."VAT Registration No.");
        SAFTXMLHelper.AppendXMLNode('Name', CombineWithSpace(CompanyInformation.Name, CompanyInformation."Name 2"));
        ExportAddress(
            CombineWithSpace(CompanyInformation.Address, CompanyInformation."Address 2"), CompanyInformation.City, CompanyInformation."Post Code",
            CompanyInformation."Country/Region Code", 'StreetAddress');
        Employee.Get(CompanyInformation."SAF-T Contact No.");
        ExportContact(
            Employee."First Name", Employee."Last Name", GetSAFTShortText(Employee."Phone No."),
            GetSAFTShortText(Employee."Fax No."), GetSAFTMiddle2Text(Employee."E-Mail"),
            '', GetSAFTShortText(Employee."Mobile Phone No."));
        ExportTaxRegistration(CompanyInformation."VAT Registration No.");
        ExportBankAccount(
            CompanyInformation."Bank Name", CompanyInformation."Bank Account No.", CompanyInformation.IBAN,
            CompanyInformation."Bank Branch No.", '', CompanyInformation."SWIFT Code", '', '');
        ExportBankAccounts();
        SAFTXMLHelper.FinalizeXMLNode();
    end;

    local procedure ExportAddress(StreetName: Text; City: Text; PostalCode: Text; Country: Text; AddressType: Text)
    begin
        SAFTXMLHelper.AddNewXMLNode('Address', '');
        SAFTXMLHelper.AppendXMLNode('StreetName', StreetName);
        SAFTXMLHelper.AppendXMLNode('City', City);
        If PostalCode = '' then begin
            GetSAFTSetup();
            PostalCode := GlobalSAFTSetup."Default Post Code";
        end;
        SAFTXMLHelper.AppendXMLNode('PostalCode', GetSAFTShortText(PostalCode));
        SAFTXMLHelper.AppendXMLNode('Country', Country);
        SAFTXMLHelper.AppendXMLNode('AddressType', AddressType);
        SAFTXMLHelper.FinalizeXMLNode();
    end;

    local procedure ExportContact(FirstName: Text; LastName: Text; Telephone: Text; Fax: Text; Email: Text; Website: Text; MobilePhone: Text)
    begin
        if (FirstName.Trim() = '') or (LastName.Trim() = '') then
            exit;

        SAFTXMLHelper.AddNewXMLNode('Contact', '');
        SAFTXMLHelper.AddNewXMLNode('ContactPerson', '');
        SAFTXMLHelper.AppendXMLNode('FirstName', FirstName);
        SAFTXMLHelper.AppendXMLNode('LastName', LastName);
        SAFTXMLHelper.FinalizeXMLNode();

        SAFTXMLHelper.AppendXMLNode('Telephone', GetSAFTShortText(Telephone));
        SAFTXMLHelper.AppendXMLNode('Fax', GetSAFTShortText(Fax));
        SAFTXMLHelper.AppendXMLNode('Email', GetSAFTMiddle2Text(Email));
        SAFTXMLHelper.AppendXMLNode('Website', Website);
        SAFTXMLHelper.AppendXMLNode('MobilePhone', GetSAFTShortText(MobilePhone));
        SAFTXMLHelper.FinalizeXMLNode();
    end;

    local procedure ExportTaxRegistration(VATRegistrationNo: Text[20])
    begin
        SAFTXMLHelper.AddNewXMLNode('TaxRegistration', '');
        SAFTXMLHelper.AppendXMLNode('TaxRegistrationNumber', VATRegistrationNo);
        SAFTXMLHelper.AppendXMLNode('TaxAuthority', SkatteetatenMsg);
        SAFTXMLHelper.FinalizeXMLNode();
    end;

    local procedure ExportMasterFiles(SAFTExportHeader: Record "SAF-T Export Header")
    begin
        SAFTXMLHelper.AddNewXMLNode('MasterFiles', '');
        if GuiAllowed() then
            Window.Update(1, ExportingGLAccountsTxt);
        ExportGeneralLedgerAccounts(SAFTExportHeader);
        ExportCustomers(SAFTExportHeader);
        ExportVendors(SAFTExportHeader);
        ExportTaxTable();
        ExportAnalysisTypeTable();
        SAFTXMLHelper.FinalizeXMLNode();
    end;

    local procedure ExportGeneralLedgerAccounts(SAFTExportHeader: Record "SAF-T Export Header")
    var
        SAFTMappingRange: Record "SAF-T Mapping Range";
        SAFTGLAccountMapping: Record "SAF-T G/L Account Mapping";
        TotalNumberOfAccounts: Integer;
        CountOfAccounts: Integer;
    begin
        SAFTMappingRange.Get(SAFTExportHeader."Mapping Range Code");
        SAFTGLAccountMapping.SetRange("Mapping Range Code", SAFTExportHeader."Mapping Range Code");
        SAFTGLAccountMapping.SetFilter("No.", '<>%1', '');
        if not SAFTGLAccountMapping.FindSet() then
            exit;

        SAFTXMLHelper.AddNewXMLNode('GeneralLedgerAccounts', '');
        if GuiAllowed() then
            TotalNumberOfAccounts := SAFTGLAccountMapping.Count();
        repeat
            if GuiAllowed() then begin
                CountOfAccounts += 1;
                Window.Update(2, ROUND(100 * (CountOfAccounts / TotalNumberOfAccounts * 100), 1));
            end;
            ExportGLAccount(
                SAFTMappingRange."Mapping Type", SAFTGLAccountMapping."G/L Account No.", SAFTGLAccountMapping."No.",
                SAFTGLAccountMapping."Category No.", SAFTGLAccountMapping."No.",
                SAFTExportHeader."Starting Date", SAFTExportHeader."Ending Date");
        until SAFTGLAccountMapping.Next() = 0;
        SAFTXMLHelper.FinalizeXMLNode();
    end;

    local procedure ExportGLAccount(MappingType: Enum "SAF-T Mapping Type"; GLAccNo: Code[20]; StandardAccNo: Text; GroupingCategory: Code[20]; GroupingNo: Code[20]; StartingDate: Date; EndingDate: Date)
    var
        GLAccount: Record "G/L Account";
        OpeningDebitBalance: Decimal;
        OpeningCreditBalance: Decimal;
        ClosingDebitBalance: Decimal;
        ClosingCreditBalance: Decimal;
    begin
        GLAccount.get(GLAccNo);
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

        SAFTXMLHelper.AddNewXMLNode('Account', '');
        SAFTXMLHelper.AppendXMLNode('AccountID', GLAccount."No.");
        SAFTXMLHelper.AppendXMLNode('AccountDescription', GLAccount.Name);
        if MappingType in [MappingType::"Two Digit Standard Account", MappingType::"Four Digit Standard Account"] then
            SAFTXMLHelper.AppendXMLNode('StandardAccountID', StandardAccNo)
        else begin
            SAFTXMLHelper.AppendXMLNode('GroupingCategory', GroupingCategory);
            SAFTXMLHelper.AppendXMLNode('GroupingCode', GroupingNo);
        end;
        SAFTXMLHelper.AppendXMLNode('AccountType', 'GL');
        if GLAccount."Income/Balance" = GLAccount."Income/Balance"::"Income Statement" then begin
            // For income statement the opening balance is always zero but it's more preferred to have same type of balance (Debit or Credit) to match opening and closing XML nodes.
            if ClosingDebitBalance = 0 then
                SAFTXMLHelper.AppendXMLNode('OpeningCreditBalance', FormatAmount(0))
            else
                SAFTXMLHelper.AppendXMLNode('OpeningDebitBalance', FormatAmount(0))
        end else
            if OpeningDebitBalance = 0 then
                SAFTXMLHelper.AppendXMLNode('OpeningCreditBalance', FormatAmount(OpeningCreditBalance))
            else
                SAFTXMLHelper.AppendXMLNode('OpeningDebitBalance', FormatAmount(OpeningDebitBalance));
        if ClosingDebitBalance = 0 then
            SAFTXMLHelper.AppendXMLNode('ClosingCreditBalance', FormatAmount(ClosingCreditBalance))
        else
            SAFTXMLHelper.AppendXMLNode('ClosingDebitBalance', FormatAmount(ClosingDebitBalance));
        SAFTXMLHelper.FinalizeXMLNode();
    end;

    local procedure ExportCustomers(SAFTExportHeader: Record "SAF-T Export Header")
    var
        Customer: Record Customer;
        TotalNumberOfCustomers: Integer;
        CountOfCustomers: Integer;
    begin
        if not Customer.FindSet() then
            exit;

        SAFTXMLHelper.AddNewXMLNode('Customers', '');
        if GuiAllowed() then begin
            Window.Update(1, ExportingCustomersTxt);
            TotalNumberOfCustomers := Customer.Count();
        end;
        repeat
            if GuiAllowed() then begin
                CountOfCustomers += 1;
                Window.Update(2, ROUND(100 * (CountOfCustomers / TotalNumberOfCustomers * 100), 1));
            end;
            ExportCustomer(Customer, SAFTExportHeader);
        until Customer.Next() = 0;
        SAFTXMLHelper.FinalizeXMLNode();
    end;

    local procedure ExportCustomer(Customer: Record Customer; SAFTExportHeader: Record "SAF-T Export Header")
    var
        CustomerPostingGroup: Record "Customer Posting Group";
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
        CustLedgerEntry.SetRange("Posting Date", SAFTExportHeader."Starting Date", closingdate(SAFTExportHeader."Ending Date"));
        if CustLedgerEntry.IsEmpty() then
            exit;
        Customer.SetRange("Date Filter", 0D, closingdate(SAFTExportHeader."Starting Date" - 1));
        Customer.CalcFields("Net Change (LCY)");
        if Customer."Net Change (LCY)" > 0 then
            OpeningDebitBalance := Customer."Net Change (LCY)"
        else
            OpeningCreditBalance := -Customer."Net Change (LCY)";
        Customer.SetRange("Date Filter", 0D, closingdate(SAFTExportHeader."Ending Date"));
        Customer.CalcFields("Net Change (LCY)");
        if Customer."Net Change (LCY)" > 0 then
            ClosingDebitBalance := Customer."Net Change (LCY)"
        else
            ClosingCreditBalance := -Customer."Net Change (LCY)";

        SAFTXMLHelper.AddNewXMLNode('Customer', '');
        SAFTXMLHelper.AppendXMLNode('RegistrationNumber', Customer."VAT Registration No.");
        SAFTXMLHelper.AppendXMLNode('Name', CombineWithSpace(Customer.Name, Customer."Name 2"));
        ExportAddress(CombineWithSpace(Customer.Address, Customer."Address 2"), Customer.City, Customer."Post Code", Customer."Country/Region Code", 'StreetAddress');
        OnBeforeGetFirstAndLastNameFromCustomer(Handled, FirstName, LastName, Customer);
        if not Handled then
            GetFirstAndLastNameFromContactName(FirstName, LastName, Customer.Contact);
        ExportContact(FirstName, LastName, Customer."Phone No.", Customer."Fax No.", Customer."E-Mail", Customer."Home Page", '');
        CustomerBankAccount.SetRange("Customer No.", Customer."No.");
        if CustomerBankAccount.FindSet() then
            repeat
                ExportBankAccount(
                    CombineWithSpace(CustomerBankAccount.Name, CustomerBankAccount."Name 2"),
                    CustomerBankAccount."Bank Account No.", CustomerBankAccount.IBAN,
                    CustomerBankAccount."Bank Branch No.", CustomerBankAccount."Bank Clearing Code",
                    CustomerBankAccount."SWIFT Code", CustomerBankAccount."Currency Code", '');
            until CustomerBankAccount.Next() = 0;
        SAFTXMLHelper.AppendXMLNode('CustomerID', Customer."No.");
        CustomerPostingGroup.get(customer."Customer Posting Group");
        SAFTXMLHelper.AppendXMLNode('AccountID', CustomerPostingGroup."Receivables Account");
        if OpeningDebitBalance = 0 then
            SAFTXMLHelper.AppendXMLNode('OpeningCreditBalance', FormatAmount(OpeningCreditBalance))
        else
            SAFTXMLHelper.AppendXMLNode('OpeningDebitBalance', FormatAmount(OpeningDebitBalance));
        if ClosingDebitBalance = 0 then
            SAFTXMLHelper.AppendXMLNode('ClosingCreditBalance', FormatAmount(ClosingCreditBalance))
        else
            SAFTXMLHelper.AppendXMLNode('ClosingDebitBalance', FormatAmount(ClosingDebitBalance));
        ExportPartyInfo(Database::Customer, Customer."No.", Customer."Currency Code", Customer."Payment Terms Code");
        SAFTXMLHelper.FinalizeXMLNode();
    end;

    local procedure ExportVendors(SAFTExportHeader: Record "SAF-T Export Header")
    var
        Vendor: Record Vendor;
        TotalNumberOfVendors: Integer;
        CountOfVendors: Integer;
    begin
        if not Vendor.FindSet() then
            exit;

        SAFTXMLHelper.AddNewXMLNode('Suppliers', '');
        if GuiAllowed() then begin
            Window.Update(1, ExportingVendorsTxt);
            TotalNumberOfVendors := Vendor.Count();
        end;
        repeat
            if GuiAllowed() then begin
                CountOfVendors += 1;
                Window.Update(2, ROUND(100 * (CountOfVendors / TotalNumberOfVendors * 100), 1));
            end;
            ExportVendor(Vendor, SAFTExportHeader);
        until Vendor.Next() = 0;
        SAFTXMLHelper.FinalizeXMLNode();
    end;

    local procedure ExportVendor(Vendor: Record Vendor; SAFTExportHeader: Record "SAF-T Export Header")
    var
        VendorPostingGroup: Record "Vendor Posting Group";
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
        VendorLedgerEntry.SetRange("Posting Date", SAFTExportHeader."Starting Date", closingdate(SAFTExportHeader."Ending Date"));
        if VendorLedgerEntry.IsEmpty() then
            exit;
        Vendor.SetRange("Date Filter", 0D, closingdate(SAFTExportHeader."Starting Date" - 1));
        Vendor.CalcFields("Net Change (LCY)");
        if Vendor."Net Change (LCY)" > 0 then
            OpeningCreditBalance := Vendor."Net Change (LCY)"
        else
            OpeningDebitBalance := -Vendor."Net Change (LCY)";
        Vendor.SetRange("Date Filter", 0D, closingdate(SAFTExportHeader."Ending Date"));
        Vendor.CalcFields("Net Change (LCY)");
        if Vendor."Net Change (LCY)" > 0 then
            ClosingCreditBalance := Vendor."Net Change (LCY)"
        else
            ClosingDebitBalance := -Vendor."Net Change (LCY)";

        SAFTXMLHelper.AddNewXMLNode('Supplier', '');
        SAFTXMLHelper.AppendXMLNode('RegistrationNumber', Vendor."VAT Registration No.");
        SAFTXMLHelper.AppendXMLNode('Name', CombineWithSpace(Vendor.Name, Vendor."Name 2"));
        ExportAddress(CombineWithSpace(Vendor.Address, Vendor."Address 2"), Vendor.City, Vendor."Post Code", Vendor."Country/Region Code", 'StreetAddress');
        OnBeforeGetFirstAndLastNameFromVendor(Handled, FirstName, LastName, Vendor);
        if not Handled then
            GetFirstAndLastNameFromContactName(FirstName, LastName, Vendor.Contact);
        ExportContact(FirstName, LastName, Vendor."Phone No.", Vendor."Fax No.", Vendor."E-Mail", Vendor."Home Page", '');
        VendorBankAccount.SetRange("Vendor No.", Vendor."No.");
        If VendorBankAccount.FindSet() then
            repeat
                ExportBankAccount(
                    CombineWithSpace(VendorBankAccount.Name, VendorBankAccount."Name 2"),
                    VendorBankAccount."Bank Account No.", VendorBankAccount.IBAN,
                    VendorBankAccount."Bank Branch No.", VendorBankAccount."Bank Clearing Code",
                    VendorBankAccount."SWIFT Code", VendorBankAccount."Currency Code", '');
            until VendorBankAccount.Next() = 0;
        If Vendor."Recipient Bank Account No." <> '' then
            ExportBankAccount(Vendor."Bank Name", Vendor."Recipient Bank Account No.", '', '', '', Vendor.SWIFT, '', '');
        SAFTXMLHelper.AppendXMLNode('SupplierID', Vendor."No.");
        VendorPostingGroup.Get(Vendor."Vendor Posting Group");
        SAFTXMLHelper.AppendXMLNode('AccountID', VendorPostingGroup."Payables Account");
        if OpeningDebitBalance = 0 then
            SAFTXMLHelper.AppendXMLNode('OpeningCreditBalance', FormatAmount(OpeningCreditBalance))
        else
            SAFTXMLHelper.AppendXMLNode('OpeningDebitBalance', FormatAmount(OpeningDebitBalance));
        if ClosingDebitBalance = 0 then
            SAFTXMLHelper.AppendXMLNode('ClosingCreditBalance', FormatAmount(ClosingCreditBalance))
        else
            SAFTXMLHelper.AppendXMLNode('ClosingDebitBalance', FormatAmount(ClosingDebitBalance));
        ExportPartyInfo(Database::Vendor, Vendor."No.", Vendor."Currency Code", Vendor."Payment Terms Code");
        SAFTXMLHelper.FinalizeXMLNode();
    end;

    local procedure ExportTaxTable()
    begin
        if GuiAllowed() then
            Window.Update(1, ExportingVATPostingSetupTxt);
        SAFTXMLHelper.AddNewXMLNode('TaxTable', '');
        SAFTXMLHelper.AddNewXMLNode('TaxTableEntry', '');
        SAFTXMLHelper.AppendXMLNode('TaxType', 'MVA');
        SAFTXMLHelper.AppendXMLNode('Description', 'Merverdiavgift');
        ExportTaxCodeDetails();
        SAFTXMLHelper.FinalizeXMLNode();
        SAFTXMLHelper.FinalizeXMLNode();
    end;

    local procedure ExportTaxCodeDetails()
    var
        VATPostingSetup: Record "VAT Posting Setup";
        VATReportingCode: Record "VAT Reporting Code";
        SAFTExportMgt: Codeunit "SAF-T Export Mgt.";
        NotApplicableVATCode: Code[20];
        SalesCompensation: Boolean;
        PurchaseCompensation: Boolean;
    begin
        if not VATPostingSetup.FindSet() then
            exit;

        NotApplicableVATCode := SAFTExportMgt.GetNotApplicableVATCode();
        repeat
            if not VATPostingSetup."Calc. Prop. Deduction VAT" then
                VATPostingSetup."Proportional Deduction VAT %" := 0;
            if VATPostingSetup."Sale VAT Reporting Code" = '' then
                VATPostingSetup."Sale VAT Reporting Code" := NotApplicableVATCode
            else begin
                VATReportingCode.Get(VATPostingSetup."Sale VAT Reporting Code");
                SalesCompensation := VATReportingCode.Compensation;
            end;
            if VATPostingSetup."Purch. VAT Reporting Code" = '' then
                VATPostingSetup."Purch. VAT Reporting Code" := NotApplicableVATCode
            else begin
                VATReportingCode.Get(VATPostingSetup."Purch. VAT Reporting Code");
                PurchaseCompensation := VATReportingCode.Compensation;
            end;

            if VATPostingSetup."Sales VAT Account" <> '' then
                ExportTaxCodeDetail(
                    VATPostingSetup."Sales SAF-T Tax Code", CopyStr(VATPostingSetup."Sale VAT Reporting Code", 1, 9),
                    VATPostingSetup.Description, VATPostingSetup."VAT %",
                    SalesCompensation, VATPostingSetup."Proportional Deduction VAT %");
            If VATPostingSetup."Purchase VAT Account" <> '' then
                ExportTaxCodeDetail(
                    VATPostingSetup."Purchase SAF-T Tax Code", CopyStr(VATPostingSetup."Purch. VAT Reporting Code", 1, 9),
                    VATPostingSetup.Description, VATPostingSetup."VAT %",
                    PurchaseCompensation, VATPostingSetup."Proportional Deduction VAT %");
        until VATPostingSetup.Next() = 0;
    end;

    local procedure ExportTaxCodeDetail(SAFTTaxCode: Integer; StandardTaxCode: Code[10]; Description: Text; VATRate: Decimal; Compensation: Boolean; VATDeductionRate: Decimal)
    var
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.Get();
        SAFTXMLHelper.AddNewXMLNode('TaxCodeDetails', '');
        SAFTXMLHelper.AppendXMLNode('TaxCode', Format(SAFTTaxCode));
        SAFTXMLHelper.AppendXMLNode('Description', Description);
        SAFTXMLHelper.AppendXMLNode('TaxPercentage', FormatAmount(VATRate));
        SAFTXMLHelper.AppendXMLNode('Country', CompanyInformation."Country/Region Code");
        SAFTXMLHelper.AppendXMLNode('StandardTaxCode', StandardTaxCode);
        SAFTXMLHelper.AppendXMLNode('Compensation', Format(Compensation, 0, 9));
        if VATDeductionRate = 0 then
            VATDeductionRate := 100;
        SAFTXMLHelper.AppendXMLNode('BaseRate', FormatAmount(VATDeductionRate));
        SAFTXMLHelper.FinalizeXMLNode();
    end;

    local procedure ExportAnalysisTypeTable()
    var
        Dimension: Record Dimension;
        DimensionValue: Record "Dimension Value";
        LastDimensionCode: Code[20];
    begin
        If not DimensionValue.FindSet() then
            exit;

        if GuiAllowed() then
            Window.Update(1, ExportingDimensionsTxt);
        SAFTXMLHelper.AddNewXMLNode('AnalysisTypeTable', '');
        repeat
            if LastDimensionCode <> DimensionValue."Dimension Code" then begin
                Dimension.Get(DimensionValue."Dimension Code");
                LastDimensionCode := Dimension.Code;
            end;
            if Dimension."Export to SAF-T" then begin
                SAFTXMLHelper.AddNewXMLNode('AnalysisTypeTableEntry', '');
                SAFTXMLHelper.AppendXMLNode('AnalysisType', Dimension."SAF-T Analysis Type");
                SAFTXMLHelper.AppendXMLNode('AnalysisTypeDescription', Dimension.Name);
                SAFTXMLHelper.AppendXMLNode('AnalysisID', DimensionValue.Code);
                SAFTXMLHelper.AppendXMLNode('AnalysisIDDescription', DimensionValue.Name);
                SAFTXMLHelper.FinalizeXMLNode();
            end;
        until DimensionValue.Next() = 0;
        SAFTXMLHelper.FinalizeXMLNode();
    end;

    local procedure ExportGeneralLedgerEntries(var GLEntry: Record "G/L Entry"; var SAFTExportLine: Record "SAF-T Export Line")
    var
        SAFTSourceCode: Record "SAF-T Source Code";
        TempSourceCode: Record "Source Code" temporary;
        SourceCode: Record "Source Code";
        SAFTExportHeader: Record "SAF-T Export Header";
        SAFTMappingHelper: Codeunit "SAF-T Mapping Helper";
        GLEntryProgressStep: Decimal;
        GLEntryProgress: Decimal;
    begin
        SAFTXMLHelper.AddNewXMLNode('GeneralLedgerEntries', '');
        SAFTExportHeader.Get(SAFTExportLine.ID);
        SAFTXMLHelper.AppendXMLNode('NumberOfEntries', FormatAmount(SAFTExportHeader."Number of G/L Entries"));
        SAFTXMLHelper.AppendXMLNode('TotalDebit', FormatAmount(SAFTExportHeader."Total G/L Entry Debit"));
        SAFTXMLHelper.AppendXMLNode('TotalCredit', FormatAmount(SAFTExportHeader."Total G/L Entry Credit"));
        if GLEntry.IsEmpty() then begin
            SAFTXMLHelper.FinalizeXMLNode();
            exit;
        end;

        if GuiAllowed() then
            Window.Update(1, ExportingGLEntriesTxt);
        if SAFTSourceCode.FindSet() then
            GLEntryProgressStep := Round(10000 / SAFTSourceCode.Count(), 1, '<')
        else
            GLEntryProgressStep := 10000;
        repeat
            TempSourceCode.Reset();
            TempSourceCode.DeleteAll();
            if SAFTSourceCode.Code = '' then begin
                SAFTSourceCode.Init();
                SAFTSourceCode.Code := SAFTMappingHelper.GetARSAFTSourceCode();
                SAFTSourceCode.Description := SAFTMappingHelper.GetASAFTSourceCodeDescription();
            end else
                SourceCode.SetRange("SAF-T Source Code", SAFTSourceCode.Code);
            if SourceCode.FindSet() then
                repeat
                    TempSourceCode := SourceCode;
                    TempSourceCode.Insert();
                until SourceCode.Next() = 0;
            if SAFTSourceCode."Includes No Source Code" then begin
                TempSourceCode.Init();
                TempSourceCode.Code := '';
                TempSourceCode.Insert();
            end;
            GLEntryProgress += GLEntryProgressStep;
            if GuiAllowed() then
                Window.Update(2, GLEntryProgress);
            if ExportGLEntriesBySourceCodeBuffer(TempSourceCode, GLEntry, SAFTSourceCode, SAFTExportHeader) then begin
                SAFTExportLine.Get(SAFTExportLine.ID, SAFTExportLine."Line No.");
                SAFTExportLine.LockTable();
                SAFTExportLine.Validate(Progress, GLEntryProgress);
                SAFTExportLine.Modify(true);
                Commit();
            end;
        until SAFTSourceCode.Next() = 0;
        SAFTXMLHelper.FinalizeXMLNode();
    end;

    local procedure ExportGLEntriesBySourceCodeBuffer(var TempSourceCode: Record "Source Code" temporary; var GLEntry: Record "G/L Entry"; SAFTSourceCode: Record "SAF-T Source Code"; SAFTExportHeader: Record "SAF-T Export Header"): Boolean
    var
        SourceCodeFilter: Text;
        GLEntriesExists: Boolean;
    begin
        If not TempSourceCode.FindSet() then
            exit(false);

        repeat
            if SourceCodeFilter <> '' then
                SourceCodeFilter += '|';
            if TempSourceCode.Code = '' then
                SourceCodeFilter += ''' '''
            else
                SourceCodeFilter += TempSourceCode.Code;
        until TempSourceCode.Next() = 0;
        GLEntry.SetFilter("Source Code", SourceCodeFilter);
        GLEntriesExists := GLEntry.FindSet();
        if not GLEntriesExists then
            exit(false);

        SAFTXMLHelper.AddNewXMLNode('Journal', '');
        SAFTXMLHelper.AppendXMLNode('JournalID', SAFTSourceCode.Code);
        SAFTXMLHelper.AppendXMLNode('Description', SAFTSourceCode.Description);
        SAFTXMLHelper.AppendXMLNode('Type', SAFTSourceCode.Code);
        ExportGLEntriesByTransaction(GLEntry, SAFTExportHeader);
        if SAFTSourceCode.Code <> '' then
            SAFTXMLHelper.FinalizeXMLNode();
        exit(true);
    end;

    local procedure ExportGLEntriesByTransaction(var GLEntry: Record "G/L Entry"; SAFTExportHeader: Record "SAF-T Export Header")
    var
        TempDimIDBuffer: Record "Dimension ID Buffer" temporary;
        VATEntry: Record "VAT Entry";
        GLEntryVATEntryLink: Record "G/L Entry - VAT Entry Link";
        SAFTExportMgt: Codeunit "SAF-T Export Mgt.";
        AmountXMLNode: Text;
        Amount: Decimal;
        CurrencyCode: Code[10];
        ExchangeRate: Decimal;
        EntryAmount: Decimal;
        EntryAmountLCY: Decimal;
        CurrentTransactionID: Text;
        PrevTransactionID: Text;
        IsHandled: Boolean;
    begin
        repeat
            CurrentTransactionID := GetSAFTTransactionIDFromGLEntry(GLEntry);
            if CurrentTransactionID <> PrevTransactionID then begin
                if PrevTransactionID <> '' then
                    SAFTXMLHelper.FinalizeXMLNode();
                ExportGLEntryTransactionInfo(GLEntry, CurrentTransactionID);
                PrevTransactionID := GetSAFTTransactionIDFromGLEntry(GLEntry);
                GetFCYData(CurrencyCode, ExchangeRate, EntryAmount, EntryAmountLCY, SAFTExportHeader, GLEntry);
            end;
            SAFTXMLHelper.AddNewXMLNode('Line', '');
            SAFTXMLHelper.AppendXMLNode('RecordID', format(GLEntry."Entry No."));
            SAFTXMLHelper.AppendXMLNode('AccountID', GLEntry."G/L Account No.");
            CopyDimeSetIDToDimIDBuffer(TempDimIDBuffer, GLEntry."Dimension Set ID");
            ExportAnalysisInfo(TempDimIDBuffer);
            SAFTXMLHelper.AppendXMLNode('SourceDocumentID', GLEntry."Document No.");
            case GLEntry."Source Type" of
                GLEntry."Source Type"::Customer:
                    begin
                        if GLEntry."Source No." <> GlobalCustomer."No." then begin
                            GlobalCustomerPostingGroup.Init();
                            if GlobalCustomer.Get(GLEntry."Source No.") then
                                if GlobalCustomerPostingGroup.Get(GlobalCustomer."Customer Posting Group") then;
                        end;
                        if GLEntry."G/L Account No." = GlobalCustomerPostingGroup."Receivables Account" then
                            SAFTXMLHelper.AppendXMLNode('CustomerID', GLEntry."Source No.");
                    end;
                GLEntry."Source Type"::Vendor:
                    begin
                        if GLEntry."Source No." <> GlobalVendor."No." then begin
                            GlobalVendorPostingGroup.init();
                            if GlobalVendor.Get(GLEntry."Source No.") then
                                if GlobalVendorPostingGroup.Get(GlobalVendor."Vendor Posting Group") then;
                        end;
                        if GLEntry."G/L Account No." = GlobalVendorPostingGroup."Payables Account" then
                            SAFTXMLHelper.AppendXMLNode('SupplierID', GLEntry."Source No.");
                    end;
            end;
            SAFTXMLHelper.AppendXMLNode('Description', GetGLEntryDescription(GLEntry));
            SAFTExportMgt.GetAmountInfoFromGLEntry(AmountXMLNode, Amount, GLEntry);
            IsHandled := false;
            OnBeforeExportGLEntryAmountInfo(SAFTXMLHelper, AmountXMLNode, GLEntry, IsHandled);
            If not IsHandled then
                ExportAmountWithCurrencyInfo(AmountXMLNode, GLEntry."G/L Account No.", CurrencyCode, ExchangeRate, Amount, EntryAmount, EntryAmountLCY);
            if (GLEntry."VAT Bus. Posting Group" <> '') or (GLEntry."VAT Prod. Posting Group" <> '') then begin
                GLEntryVATEntryLink.SetRange("G/L Entry No.", GLEntry."Entry No.");
                if GLEntryVATEntryLink.FindFirst() then begin
                    VATEntry.Get(GLEntryVATEntryLink."VAT Entry No.");
                    ExportTaxInformation(VATEntry);
                end;
            end;
            SAFTXMLHelper.AppendXMLNode('ReferenceNumber', GLEntry."External Document No.");
            SAFTXMLHelper.FinalizeXMLNode();
        until GLEntry.Next() = 0;
        SAFTXMLHelper.FinalizeXMLNode();
    end;

    local procedure ExportGLEntryTransactionInfo(GLEntry: Record "G/L Entry"; TransactionID: Text)
    var
        SystemEntryDate: Date;
        TransactionTypeValue: Text;
    begin
        SAFTXMLHelper.AddNewXMLNode('Transaction', '');
        SAFTXMLHelper.AppendXMLNode('TransactionID', TransactionID);
        SAFTXMLHelper.AppendXMLNode('Period', format(Date2DMY(GLEntry."Posting Date", 2)));
        SAFTXMLHelper.AppendXMLNode('PeriodYear', format(Date2DMY(GLEntry."Posting Date", 3)));
        SAFTXMLHelper.AppendXMLNode('TransactionDate', FormatDate(GLEntry."Document Date"));
        SAFTXMLHelper.AppendXMLNode('SourceID', GetSAFTMiddle1Text(GLEntry."User ID"));
        if GLEntry."Document Type" = 0 then
            TransactionTypeValue := BlankTxt
        else
            TransactionTypeValue := Format(GLEntry."Document Type");
        SAFTXMLHelper.AppendXMLNode('TransactionType', TransactionTypeValue);
        SAFTXMLHelper.AppendXMLNode('Description', GetGLEntryDescription(GLEntry));
        SAFTXMLHelper.AppendXMLNode('BatchID', Format(GLEntry."Transaction No."));
        if GLEntry."Last Modified DateTime" = 0DT then
            SystemEntryDate := GLEntry."Posting Date"
        else
            SystemEntryDate := DT2Date(GLEntry."Last Modified DateTime");
        SAFTXMLHelper.AppendXMLNode('SystemEntryDate', FormatDate(SystemEntryDate));
        SAFTXMLHelper.AppendXMLNode('GLPostingDate', FormatDate(GLEntry."Posting Date"));
    end;

    local procedure ExportTaxInformation(VATEntry: Record 254)
    var
        VATPostingSetup: Record "VAT Posting Setup";
        IsHandled: Boolean;
    begin
        if not (VATEntry.Type in [VATEntry.Type::Sale, VATEntry.Type::Purchase]) then
            exit;

        VATPostingSetup.get(VATEntry."VAT Bus. Posting Group", VATEntry."VAT Prod. Posting Group");
        SAFTXMLHelper.AddNewXMLNode('TaxInformation', '');
        SAFTXMLHelper.AppendXMLNode('TaxType', 'MVA');
        if VATEntry.Type = VATEntry.Type::Sale then
            SAFTXMLHelper.AppendXMLNode('TaxCode', Format(VATPostingSetup."Sales SAF-T Tax Code"))
        else
            SAFTXMLHelper.AppendXMLNode('TaxCode', Format(VATPostingSetup."Purchase SAF-T Tax Code"));
        SAFTXMLHelper.AppendXMLNode('TaxPercentage', FormatAmount(VATPostingSetup."VAT %"));
        SAFTXMLHelper.AppendXMLNode('TaxBase', FormatAmount(abs(VATEntry.Base)));
        IsHandled := false;
        OnBeforeExportVATEntryAmountInfo(SAFTXMLHelper, VATEntry, IsHandled);
        if not IsHandled then
            ExportAmountInfo('TaxAmount', abs(VATEntry.Amount));
        SAFTXMLHelper.FinalizeXMLNode();
    end;

    local procedure ExportAmountInfo(ParentNodeName: Text; Amount: Decimal)
    begin
        SAFTXMLHelper.AddNewXMLNode(ParentNodeName, '');
        SAFTXMLHelper.AppendXMLNode('Amount', FormatAmount(Amount));
        SAFTXMLHelper.FinalizeXMLNode();
    end;

    local procedure ExportAmountWithCurrencyInfo(ParentNodeName: Text; GLAccNo: Code[20]; CurrencyCode: Code[10]; ExchangeRate: Decimal; Amount: Decimal; EntryAmount: Decimal; EntryAmountLCY: Decimal)
    var
        ExportAmountWithNoCurrency: Boolean;
        CurrentAmount: Decimal;
        CurrentAmountLCY: Decimal;
    begin
        if CurrencyCode = '' then
            ExportAmountWithNoCurrency := true
        else
            ExportAmountWithNoCurrency := GLAccInCurrencyGainLossAcc(GLAccNo, CurrencyCode);
        if ExportAmountWithNoCurrency then begin
            ExportAmountInfo(ParentNodeName, Amount);
            exit;
        end;

        SAFTXMLHelper.AddNewXMLNode(ParentNodeName, '');
        GetCurrencyAmounts(CurrentAmount, CurrentAmountLCY, CurrencyCode, ExchangeRate, Amount, EntryAmount, EntryAmountLCY);
        SAFTXMLHelper.AppendXMLNode('Amount', FormatAmount(CurrentAmountLCY));
        SAFTXMLHelper.AppendXMLNode('CurrencyCode', CurrencyCode);
        SAFTXMLHelper.AppendXMLNode('CurrencyAmount', FormatAmount(CurrentAmount));
        SAFTXMLHelper.AppendXMLNode('ExchangeRate', FormatAmount(Round(ExchangeRate, 0.00001)));
        SAFTXMLHelper.FinalizeXMLNode();
    end;

    local procedure ExportBankAccounts()
    var
        BankAccount: Record "Bank Account";
    begin
        if not BankAccount.FindSet() then
            exit;

        repeat
            ExportBankAccount(
                CombineWithSpace(BankAccount.Name, BankAccount."Name 2"),
                BankAccount."Bank Account No.", BankAccount.IBAN,
                BankAccount."Bank Branch No.", BankAccount."Bank Clearing Code",
                BankAccount."SWIFT Code", BankAccount."Currency Code", GetGLAccFromBankAccPostingGroup(BankAccount."Bank Acc. Posting Group"));
        until BankAccount.Next() = 0;
    end;

    local procedure ExportBankAccount(BankName: Text; BankNumber: Text; IBAN: Text; BranchNo: Text; ClearingCode: Text; SWIFT: Text; CurrencyCode: Code[10]; AccNo: Code[20])
    var
        SAFTExportMgt: Codeunit "SAF-T Export Mgt.";
        SortCode: Text;
    begin
        if (IBAN = '') and (BankNumber = '') and (BankName = '') and (BranchNo = '') then
            exit;

        SAFTXMLHelper.AddNewXMLNode('BankAccount', '');
        SAFTXMLHelper.AppendXMLNode('IBANNumber', IBAN);
        if IBAN = '' then begin
            SAFTXMLHelper.AppendXMLNode('BankAccountNumber', BankNumber);
            SAFTXMLHelper.AppendXMLNode('BankAccountName', BankName);
            if ClearingCode = '' then
                SortCode := BranchNo
            else
                SortCode := ClearingCode;
            SAFTXMLHelper.AppendXMLNode('SortCode', SortCode);
        end;
        SAFTXMLHelper.AppendXMLNode('BIC', SWIFT);

        SAFTXMLHelper.AppendXMLNode('CurrencyCode', SAFTExportMgt.GetISOCurrencyCode(CurrencyCode));
        SAFTXMLHelper.AppendXMLNode('GeneralLedgerAccountID', AccNo);
        SAFTXMLHelper.FinalizeXMLNode();
    end;

    local procedure ExportPaymentTerms(PaymentTermsCode: Code[10])
    var
        PaymentTerms: Record "Payment Terms";
    begin
        if PaymentTermsCode = '' then
            exit;

        PaymentTerms.get(PaymentTermsCode);
        SAFTXMLHelper.AddNewXMLNode('PaymentTerms', '');
        SAFTXMLHelper.AppendXMLNode('Days', format(CalcDate(PaymentTerms."Due Date Calculation", WorkDate()) - WorkDate()));
        if format(PaymentTerms."Discount Date Calculation") <> '' then
            SAFTXMLHelper.AppendXMLNode('CashDiscountDays', format(CalcDate(PaymentTerms."Discount Date Calculation", WorkDate()) - WorkDate()));
        SAFTXMLHelper.AppendXMLNode('CashDiscountRate', FormatAmount(PaymentTerms."Discount %"));
        SAFTXMLHelper.FinalizeXMLNode();
    end;

    local procedure ExportPartyInfo(SourceID: Integer; SourceNo: Code[20]; CurrencyCode: Code[10]; PaymentTermsCode: Code[10])
    var
        DefaultDimension: Record "Default Dimension";
        TempDimIDBuffer: Record "Dimension ID Buffer" temporary;
        SAFTExportMgt: Codeunit "SAF-T Export Mgt.";
    begin
        SAFTXMLHelper.AddNewXMLNode('PartyInfo', '');
        ExportPaymentTerms(PaymentTermsCode);
        SAFTXMLHelper.AppendXMLNode('CurrencyCode', SAFTExportMgt.GetISOCurrencyCode(CurrencyCode));
        DefaultDimension.SetRange("Table ID", SourceID);
        DefaultDimension.SetRange("No.", SourceNo);
        CopyDefaultDimToDimBuffer(TempDimIDBuffer, DefaultDimension);
        ExportAnalysisInfo(TempDimIDBuffer);
        SAFTXMLHelper.FinalizeXMLNode();
    end;

    local procedure ExportAnalysisInfo(var TempDimIDBuffer: Record "Dimension ID Buffer" temporary)
    begin
        TempDimIDBuffer.SetFilter("Dimension Value", '<>%1', '');
        if TempDimIDBuffer.FindSet() then
            repeat
                SAFTXMLHelper.AddNewXMLNode('Analysis', '');
                SAFTXMLHelper.AppendXMLNode('AnalysisType', TempDimIDBuffer."Dimension Code");
                SAFTXMLHelper.AppendXMLNode('AnalysisID', TempDimIDBuffer."Dimension Value");
                SAFTXMLHelper.FinalizeXMLNode();
            until TempDimIDBuffer.Next() = 0;
        TempDimIDBuffer.SetRange("Dimension Value");
    end;

    local procedure CopyDefaultDimToDimBuffer(var TempDimIDBuffer: Record "Dimension ID Buffer" temporary; var DefaultDimension: Record "Default Dimension")
    var
        Dimension: Record Dimension;
    begin
        TempDimIDBuffer.Reset();
        TempDimIDBuffer.DeleteAll();
        if DefaultDimension.FindSet() then
            repeat
                Dimension.get(DefaultDimension."Dimension Code");
                TempDimIDBuffer."Parent ID" += 1;
                TempDimIDBuffer."Dimension Code" := Dimension."SAF-T Analysis Type";
                TempDimIDBuffer."Dimension Value" := DefaultDimension."Dimension Value Code";
                TempDimIDBuffer.Insert();
            until DefaultDimension.next() = 0;
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
            if Dimension."Export to SAF-T" then begin
                TempDimIDBuffer."Parent ID" += 1;
                TempDimIDBuffer."Dimension Code" := Dimension."SAF-T Analysis Type";
                TempDimIDBuffer."Dimension Value" := TempDimSetEntry."Dimension Value Code";
                TempDimIDBuffer.Insert();
            end;
        until TempDimSetEntry.Next() = 0;

    end;

    local procedure GetFirstAndLastNameFromContactName(var FirstName: Text; var LastName: Text; ContactName: Text)
    var
        SpacePos: Integer;
    begin
        SpacePos := StrPos(ContactName, ' ');
        if SpacePos = 0 then begin
            FirstName := ContactName;
            LastName := '-';
        end else begin
            FirstName := copystr(ContactName, 1, SpacePos - 1);
            LastName := copystr(ContactName, SpacePos + 1, StrLen(ContactName) - SpacePos);
        end;
    end;

    local procedure GetGLAccFromBankAccPostingGroup(BankAccPostGroupCode: Code[20]): Code[20]
    var
        BankAccPostingGroup: Record "Bank Account Posting Group";
    begin
        if BankAccPostGroupCode = '' then
            exit('');
        if not BankAccPostingGroup.Get(BankAccPostGroupCode) then
            exit('');
        exit(BankAccPostingGroup."G/L Account No.");
    end;

    local procedure GetCurrencyAmounts(var Amount: Decimal; var AmountLCY: Decimal; CurrencyCode: Code[10]; ExchangeRate: Decimal; OriginalLCYAmount: Decimal; EntryAmount: Decimal; EntryAmountLCY: Decimal)
    begin
        AmountLCY := EntryAmountLCY;
        Amount := EntryAmount;
        if Amount <> 0 then
            exit;
        if CurrencyCode <> GlobalCurrency.Code then begin
            GlobalCurrency.Get(CurrencyCode);
            GlobalCurrency.InitRoundingPrecision();
        end;
        AmountLCY := OriginalLCYAmount;
        if ExchangeRate = 0 then
            Amount := 0
        else
            Amount := Round(OriginalLCYAmount / ExchangeRate, GlobalCurrency."Amount Rounding Precision");
        exit;
    end;

    local procedure FinalizeExport(var SAFTExportLine: Record "SAF-T Export Line"; SAFTExportHeader: Record "SAF-T Export Header")
    var
        SAFTExportMgt: Codeunit "SAF-T Export Mgt.";
        TypeHelper: Codeunit "Type Helper";
    begin
        SAFTExportLine.Get(SAFTExportLine.ID, SAFTExportLine."Line No.");
        SAFTExportLine.LockTable();
        SAFTXMLHelper.ExportXMLDocument(SAFTExportLine, SAFTExportHeader);
        SAFTExportLine.Validate(Status, SAFTExportLine.Status::Completed);
        SAFTExportLine.Validate(Progress, 10000);
        SAFTExportLine.Validate("Created Date/Time", TypeHelper.GetCurrentDateTimeInUserTimeZone());
        SAFTExportLine.Modify(true);
        Commit();
        SAFTExportMgt.UpdateExportStatus(SAFTExportHeader);
        SAFTExportMgt.LogSuccess(SAFTExportLine);
        SAFTExportMgt.StartExportLinesNotStartedYet(SAFTExportHeader);
        SAFTExportHeader.Get(SAFTExportHeader.Id);
        SAFTExportMgt.GenerateZipFile(SAFTExportHeader);
    end;

    local procedure CombineWithSpace(FirstString: Text; SecondString: Text) Result: Text
    begin
        Result := FirstString;
        If (Result <> '') and (SecondString <> '') then
            Result += ' ';
        exit(GetSAFTMiddle2Text(Result + SecondString));
    end;

    local procedure FormatDate(DateToFormat: Date): Text
    begin
        exit(format(DateToFormat, 0, 9));
    end;

    local procedure FormatAmount(AmountToFormat: Decimal): Text
    begin
        exit(format(AmountToFormat, 0, 9))
    end;

    local procedure GetSAFTShortText(InputText: Text): Text
    begin
        // SAF-T definition. Simple type. Type SAFshorttextType
        exit(CopyStr(InputText, 1, 18));
    end;

    local procedure GetSAFTMiddle1Text(InputText: Text): Text
    begin
        // SAF-T definition. Simple type. Type SAFmiddle1textType
        exit(CopyStr(InputText, 1, 35));
    end;

    local procedure GetSAFTMiddle2Text(InputText: Text): Text
    begin
        // SAF-T definition. Simple type. Type SAFmiddle2textType
        exit(CopyStr(InputText, 1, 70));
    end;

    local procedure GetSAFTSetup()
    begin
        if SAFTSetupGot then
            exit;
        GlobalSAFTSetup.Get();
        SAFTSetupGot := true;
    end;

    local procedure GetFCYData(var CurrencyCode: Code[10]; var ExchangeRate: Decimal; var EntryAmount: Decimal; var EntryAmountLCY: Decimal; SAFTExportHeader: Record "SAF-T Export Header"; GLEntry: Record "G/L Entry")
    var
        CustLedgEntry: Record "Cust. Ledger Entry";
        VendLedgEntry: Record "Vendor Ledger Entry";
        BankAccLedgEntry: Record "Bank Account Ledger Entry";
    begin
        CurrencyCode := '';
        ExchangeRate := 0;
        EntryAmount := 0;
        EntryAmountLCY := 0;
        if not SAFTExportHeader."Export Currency Information" then
            exit;

        if GLEntry."Source Type" in [GLEntry."Source Type"::Customer, GLEntry."Source Type"::" "] then begin
            CustLedgEntry.SetRange("Transaction No.", GLEntry."Transaction No.");
            if not CustLedgEntry.FindFirst() then
                exit;
            if CustLedgEntry."Currency Code" = '' then
                exit;
            CustLedgEntry.CalcFields(Amount, "Amount (LCY)");
            if CustLedgEntry.Amount = 0 then
                exit;
            CurrencyCode := CustLedgEntry."Currency Code";
            ExchangeRate := GetCurrencyFactor(CustLedgEntry."Original Currency Factor", CustLedgEntry.Amount, CustLedgEntry."Amount (LCY)");
            if CustLedgEntry."Entry No." = GLEntry."Entry No." then begin
                EntryAmount := CustLedgEntry.Amount;
                EntryAmountLCY := CustLedgEntry."Amount (LCY)";
            end;
            exit;
        end;
        if GLEntry."Source Type" in [GLEntry."Source Type"::Vendor, GLEntry."Source Type"::" "] then begin
            VendLedgEntry.SetRange("Transaction No.", GLEntry."Transaction No.");
            if not VendLedgEntry.FindFirst() then
                exit;
            if VendLedgEntry."Currency Code" = '' then
                exit;
            VendLedgEntry.CalcFields(Amount, "Amount (LCY)");
            if VendLedgEntry.Amount = 0 then
                exit;
            CurrencyCode := VendLedgEntry."Currency Code";
            ExchangeRate := GetCurrencyFactor(VendLedgEntry."Original Currency Factor", VendLedgEntry.Amount, VendLedgEntry."Amount (LCY)");
            if VendLedgEntry."Entry No." = GLEntry."Entry No." then begin
                EntryAmount := VendLedgEntry.Amount;
                EntryAmountLCY := VendLedgEntry."Amount (LCY)";
            end;
            exit;
        end;
        if GLEntry."Source Type" in [GLEntry."Source Type"::"Bank Account", GLEntry."Source Type"::" "] then begin
            BankAccLedgEntry.SetRange("Transaction No.", GLEntry."Transaction No.");
            if not BankAccLedgEntry.FindFirst() then
                exit;
            if BankAccLedgEntry."Currency Code" = '' then
                exit;
            if BankAccLedgEntry.Amount = 0 then
                exit;
            CurrencyCode := BankAccLedgEntry."Currency Code";
            ExchangeRate := GetCurrencyFactor(0, BankAccLedgEntry.Amount, BankAccLedgEntry."Amount (LCY)");
            if BankAccLedgEntry."Entry No." = GLEntry."Entry No." then begin
                EntryAmount := BankAccLedgEntry.Amount;
                EntryAmountLCY := BankAccLedgEntry."Amount (LCY)";
            end;
            exit;
        end;
    end;

    local procedure GetCurrencyFactor(OriginalCurrencyFactor: Decimal; Amount: Decimal; AmountLCY: Decimal): Decimal
    begin
        if OriginalCurrencyFactor <> 0 then
            exit(OriginalCurrencyFactor);
        exit(AmountLCY / Amount);
    end;

    local procedure GLAccInCurrencyGainLossAcc(GLAccNo: Code[20]; CurrencyCode: Code[10]): Boolean
    var
        Currency: Record Currency;
    begin
        Currency.Get(CurrencyCode);
        exit(GLAccNo in [Currency."Unrealized Gains Acc.", Currency."Unrealized Losses Acc.", Currency."Realized Gains Acc.", Currency."Realized Losses Acc."]);
    end;

    local procedure GetSAFTTransactionIDFromGLEntry(GLEntry: Record "G/L Entry"): Text
    begin
        exit(GLEntry."Document No." + Format(GLEntry."Posting Date", 0, '<Day,2><Month,2><Year,2>'));
    end;

    local procedure GetGLEntryDescription(var GLEntry: Record "G/L Entry") Description: Text
    begin
        Description := GLEntry.Description;
        if Description = '' then
            Description := GLEntry."G/L Account No.";
        if Description = '' then
            Description := NATxt;
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
    local procedure OnBeforeExportGLEntryAmountInfo(var SAFTXMLHelper: Codeunit "SAF-T XML Helper"; AmountXMLNode: Text; GLEntry: Record "G/L Entry"; var IsHandled: Boolean)
    begin

    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeExportVATEntryAmountInfo(var SAFTXMLHelper: Codeunit "SAF-T XML Helper"; VATEntry: Record "VAT Entry"; var IsHandled: Boolean)
    begin

    end;

}
