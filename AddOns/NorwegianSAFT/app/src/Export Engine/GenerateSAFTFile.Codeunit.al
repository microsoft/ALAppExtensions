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
        GLEntry.SetRange("Posting Date", "Starting Date", "Ending Date");
        ExportGeneralLedgerEntries(GLEntry, Rec);
        if GuiAllowed() then
            Window.Close();
        FinalizeExport(Rec, SAFTExportHeader);
    end;

    var
        CompanyInformation: Record "Company Information";
        SAFTXMLHelper: Codeunit "SAF-T XML Helper";
        Window: Dialog;
        GeneratingHeaderTxt: Label 'Generating header...';
        ExportingGLAccountsTxt: Label 'Exporting g/l Accounts...';
        ExportingCustomersTxt: Label 'Exporting customers...';
        ExportingVendorsTxt: Label 'Exporting vendors...';
        ExportingVATPostingSetupTxt: Label 'Exporting VAT Posting Setup...';
        ExportingDimensionsTxt: Label 'Exporting Dimensions...';
        ExportingGLEntriesTxt: Label 'Exporting G/L entries...';
        SkatteetatenMsg: Label 'Skatteetaten', Locked = true;

    local procedure ExportHeaderWithMasterFiles(SAFTExportHeader: Record "SAF-T Export Header")
    begin
        ExportHeader(SAFTExportHeader);
        ExportMasterFiles(SAFTExportHeader);
    end;

    local procedure ExportHeader(SAFTExportHeader: Record "SAF-T Export Header")
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        SAFTXMLHelper.Initialize();
        if GuiAllowed() then
            Window.Update(1, GeneratingHeaderTxt);
        CompanyInformation.get();
        SAFTXMLHelper.AddNewXMLNode('Header', '');
        SAFTXMLHelper.AppendXMLNode('AuditFileVersion', '1.0');
        SAFTXMLHelper.AppendXMLNode('AuditFileCountry', CompanyInformation."Country/Region Code");
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
        SAFTXMLHelper.AppendXMLNode('UserID', UserId());
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
            Employee."First Name", Employee."Last Name", Employee."Phone No.", Employee."Fax No.", Employee."E-Mail",
            '', Employee."Mobile Phone No.");
        ExportTaxRegistration(CompanyInformation."VAT Registration No.");
        ExportBankAccount(
            CompanyInformation."Country/Region Code", CompanyInformation."Bank Name", CompanyInformation."Bank Account No.", CompanyInformation.IBAN,
            CompanyInformation."Bank Branch No.", '');
        SAFTXMLHelper.FinalizeXMLNode();
    end;

    local procedure ExportAddress(StreetName: Text; City: Text; PostalCode: Text; Country: Text; AddressType: Text)
    begin
        SAFTXMLHelper.AddNewXMLNode('Address', '');
        SAFTXMLHelper.AppendXMLNode('StreetName', StreetName);
        SAFTXMLHelper.AppendXMLNode('City', City);
        SAFTXMLHelper.AppendXMLNode('PostalCode', PostalCode);
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

        SAFTXMLHelper.AppendXMLNode('Telephone', Telephone);
        SAFTXMLHelper.AppendXMLNode('Fax', Fax);
        SAFTXMLHelper.AppendXMLNode('Email', Email);
        SAFTXMLHelper.AppendXMLNode('Website', Website);
        SAFTXMLHelper.AppendXMLNode('MobilePhone', MobilePhone);
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
        // It's up to date by VerifyMappingIsDone function called from SAFTExportCheck.Codeunit.al right before the actual export
        SAFTGLAccountMapping.SetRange("G/L Entries Exists", true);
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
                SAFTGLAccountMapping."G/L Account No.", SAFTGLAccountMapping."No.", '', '',
                SAFTExportHeader."Starting Date", SAFTExportHeader."Ending Date");
        until SAFTGLAccountMapping.Next() = 0;
        SAFTXMLHelper.FinalizeXMLNode();
    end;

    local procedure ExportGLAccount(GLAccNo: Code[20]; StandardAccNo: Text[4]; GroupingCategory: Code[20]; GroupingNo: Code[20]; StartingDate: Date; EndingDate: Date)
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
        if (ClosingDebitBalance = 0) and (ClosingCreditBalance = 0) then
            exit;

        SAFTXMLHelper.AddNewXMLNode('Account', '');
        SAFTXMLHelper.AppendXMLNode('AccountID', GLAccount."No.");
        SAFTXMLHelper.AppendXMLNode('AccountDescription', GLAccount.Name);
        SAFTXMLHelper.AppendXMLNode('StandardAccountID', StandardAccNo);
        SAFTXMLHelper.AppendXMLNode('GroupingCategory', GroupingCategory);
        SAFTXMLHelper.AppendXMLNode('GroupingCode', GroupingNo);
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
        OpeningDebitBalance: Decimal;
        ClosingDebitBalance: Decimal;
        OpeningCreditBalance: Decimal;
        ClosingCreditBalance: Decimal;
        Handled: Boolean;
        FirstName: Text;
        LastName: Text;
    begin
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
        If (ClosingDebitBalance = 0) and (ClosingCreditBalance = 0) then
            exit;

        SAFTXMLHelper.AddNewXMLNode('Customer', '');
        SAFTXMLHelper.AppendXMLNode('RegistrationNumber', Customer."VAT Registration No.");
        SAFTXMLHelper.AppendXMLNode('Name', CombineWithSpace(Customer.Name, Customer."Name 2"));
        ExportAddress(CombineWithSpace(Customer.Address, Customer."Address 2"), Customer.City, Customer."Post Code", Customer."Country/Region Code", 'StreetAddress');
        OnBeforeGetFirstAndLastNameFromCustomer(Handled, FirstName, LastName, Customer);
        if not Handled then
            GetFirstAndLastNameFromContactName(FirstName, LastName, Customer.Contact);
        ExportContact(FirstName, LastName, Customer."Phone No.", Customer."Fax No.", Customer."E-Mail", Customer."Home Page", '');
        if Customer."Preferred Bank Account Code" = '' then begin
            CustomerBankAccount.SetRange("Customer No.", Customer."No.");
            if not CustomerBankAccount.FindFirst() then
                clear(CustomerBankAccount);
        end else
            CustomerBankAccount.Get(Customer."No.", Customer."Preferred Bank Account Code");
        ExportBankAccount(
            Customer."Country/Region Code", CombineWithSpace(CustomerBankAccount.Name, CustomerBankAccount."Name 2"),
            CustomerBankAccount."Bank Account No.", CustomerBankAccount.IBAN,
            CustomerBankAccount."Bank Branch No.", CustomerBankAccount."Currency Code");
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
        OpeningDebitBalance: Decimal;
        ClosingDebitBalance: Decimal;
        OpeningCreditBalance: Decimal;
        ClosingCreditBalance: Decimal;
        Handled: Boolean;
        FirstName: Text;
        LastName: Text;
    begin
        Vendor.SetRange("Date Filter", 0D, closingdate(SAFTExportHeader."Starting Date" - 1));
        Vendor.CalcFields("Net Change (LCY)");
        if Vendor."Net Change (LCY)" > 0 then
            OpeningDebitBalance := Vendor."Net Change (LCY)"
        else
            OpeningCreditBalance := -Vendor."Net Change (LCY)";
        Vendor.SetRange("Date Filter", 0D, closingdate(SAFTExportHeader."Ending Date"));
        Vendor.CalcFields("Net Change (LCY)");
        if Vendor."Net Change (LCY)" > 0 then
            ClosingDebitBalance := Vendor."Net Change (LCY)"
        else
            ClosingCreditBalance := -Vendor."Net Change (LCY)";
        If (ClosingDebitBalance = 0) and (ClosingCreditBalance = 0) then
            exit;

        SAFTXMLHelper.AddNewXMLNode('Supplier', '');
        SAFTXMLHelper.AppendXMLNode('RegistrationNumber', Vendor."VAT Registration No.");
        SAFTXMLHelper.AppendXMLNode('Name', CombineWithSpace(Vendor.Name, Vendor."Name 2"));
        ExportAddress(CombineWithSpace(Vendor.Address, Vendor."Address 2"), Vendor.City, Vendor."Post Code", Vendor."Country/Region Code", 'StreetAddress');
        OnBeforeGetFirstAndLastNameFromVendor(Handled, FirstName, LastName, Vendor);
        if not Handled then
            GetFirstAndLastNameFromContactName(FirstName, LastName, Vendor.Contact);
        ExportContact(FirstName, LastName, Vendor."Phone No.", Vendor."Fax No.", Vendor."E-Mail", Vendor."Home Page", '');
        if Vendor."Preferred Bank Account Code" = '' then begin
            VendorBankAccount.SetRange("Vendor No.", Vendor."No.");
            if not VendorBankAccount.FindFirst() then
                clear(VendorBankAccount);
        end else
            VendorBankAccount.Get(Vendor."No.", Vendor."Preferred Bank Account Code");
        ExportBankAccount(
            Vendor."Country/Region Code", CombineWithSpace(VendorBankAccount.Name, VendorBankAccount."Name 2"),
            VendorBankAccount."Bank Account No.", VendorBankAccount.IBAN,
            VendorBankAccount."Bank Branch No.", VendorBankAccount."Currency Code");
        SAFTXMLHelper.AppendXMLNode('SupplierID', Vendor."No.");
        VendorPostingGroup.get(Vendor."Vendor Posting Group");
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
        VATCode: Record "VAT Code";
        SAFTExportMgt: Codeunit "SAF-T Export Mgt.";
        NotApplicableVATCode: Code[10];
        SalesCompensation: Boolean;
        PurchaseCompensation: Boolean;
    begin
        if not VATPostingSetup.FindSet() then
            exit;

        NotApplicableVATCode := SAFTExportMgt.GetNotApplicationVATCode();
        repeat
            If not VATPostingSetup."Calc. Prop. Deduction VAT" then
                VATPostingSetup."Proportional Deduction VAT %" := 0;
            if VATPostingSetup."Sales SAF-T Standard Tax Code" = '' then
                VATPostingSetup."Sales SAF-T Standard Tax Code" := NotApplicableVATCode
            else begin
                VATCode.Get(VATPostingSetup."Sales SAF-T Standard Tax Code");
                SalesCompensation := VATCode.Compensation;
            end;
            if VATPostingSetup."Purch. SAF-T Standard Tax Code" = '' then
                VATPostingSetup."Purch. SAF-T Standard Tax Code" := NotApplicableVATCode
            else begin
                VATCode.Get(VATPostingSetup."Purch. SAF-T Standard Tax Code");
                PurchaseCompensation := VATCode.Compensation;
            end;

            If VATPostingSetup."Sales VAT Account" <> '' then
                ExportTaxCodeDetail(
                    VATPostingSetup."Sales SAF-T Tax Code", VATPostingSetup."Sales SAF-T Standard Tax Code",
                    VATPostingSetup.Description, VATPostingSetup."VAT %",
                    SalesCompensation, VATPostingSetup."Proportional Deduction VAT %");
            If VATPostingSetup."Purchase VAT Account" <> '' then
                ExportTaxCodeDetail(
                    VATPostingSetup."Purchase SAF-T Tax Code", VATPostingSetup."Purch. SAF-T Standard Tax Code",
                    VATPostingSetup.Description, VATPostingSetup."VAT %",
                    PurchaseCompensation, VATPostingSetup."Proportional Deduction VAT %");
        until VATPostingSetup.Next() = 0;
    end;

    local procedure ExportTaxCodeDetail(SAFTTaxCode: Integer; StandardTaxCode: Code[10]; Description: Text; VATRate: Decimal; Compensation: Boolean; VATDeductionRate: Decimal)
    begin
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
        SAFTMappingHelper: Codeunit "SAF-T Mapping Helper";
        GLEntryProgressStep: Decimal;
        GLEntryProgress: Decimal;
    begin
        GLEntry.CalcSums("Debit Amount", "Credit Amount");
        SAFTXMLHelper.AddNewXMLNode('GeneralLedgerEntries', '');
        SAFTXMLHelper.AppendXMLNode('NumberOfEntries', format(GLEntry.Count()));
        SAFTXMLHelper.AppendXMLNode('TotalDebit', FormatAmount(GLEntry."Debit Amount"));
        SAFTXMLHelper.AppendXMLNode('TotalCredit', FormatAmount(GLEntry."Credit Amount"));
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
            if ExportGLEntriesBySourceCodeBuffer(TempSourceCode, GLEntry, SAFTSourceCode) then begin
                SAFTExportLine.Find();
                SAFTExportLine.LockTable();
                SAFTExportLine.Validate(Progress, GLEntryProgress);
                SAFTExportLine.Modify(true);
                Commit();
            end;
        until SAFTSourceCode.Next() = 0;

        SAFTXMLHelper.FinalizeXMLNode();
    end;

    local procedure ExportGLEntriesBySourceCodeBuffer(var TempSourceCode: Record "Source Code" temporary; var GLEntry: Record "G/L Entry"; SAFTSourceCode: Record "SAF-T Source Code"): Boolean
    var
        SourceCodeFilter: Text;
        GLEntriesExists: Boolean;
    begin
        If not TempSourceCode.FindSet() then
            exit(false);

        repeat
            if SourceCodeFilter <> '' then
                SourceCodeFilter += '|';
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
        ExportGLEntriesByTransaction(GLEntry);
        if SAFTSourceCode.Code <> '' then
            SAFTXMLHelper.FinalizeXMLNode();
        exit(true);
    end;

    local procedure ExportGLEntriesByTransaction(var GLEntry: Record "G/L Entry")
    var
        TempDimCodeAmountBuffer: Record "Dimension Code Amount Buffer" temporary;
        VATEntry: Record "VAT Entry";
        SAFTExportMgt: Codeunit "SAF-T Export Mgt.";
        AmountXMLNode: Text;
        Amount: Decimal;
        LastTransactionNo: Integer;
    begin
        repeat
            if LastTransactionNo <> GLEntry."Transaction No." then begin
                if LastTransactionNo <> 0 then
                    SAFTXMLHelper.FinalizeXMLNode();
                ExportGLEntryTransactionInfo(GLEntry);
                LastTransactionNo := GLEntry."Transaction No.";
            end;
            SAFTXMLHelper.AddNewXMLNode('Line', '');
            SAFTXMLHelper.AppendXMLNode('RecordID', format(GLEntry."Entry No."));
            SAFTXMLHelper.AppendXMLNode('AccountID', GLEntry."G/L Account No.");
            CopyDimeSetIDToDimCodeAmountBuffer(TempDimCodeAmountBuffer, GLEntry."Dimension Set ID");
            ExportAnalysisInfo(TempDimCodeAmountBuffer);
            SAFTXMLHelper.AppendXMLNode('SourceDocumentID', GLEntry."Document No.");
            case GLEntry."Source Type" of
                GLEntry."Source Type"::Customer:
                    SAFTXMLHelper.AppendXMLNode('CustomerID', GLEntry."Source No.");
                GLEntry."Source Type"::Vendor:
                    SAFTXMLHelper.AppendXMLNode('SupplierID', GLEntry."Source No.");
            end;
            SAFTXMLHelper.AppendXMLNode('Description', GLEntry.Description);
            SAFTExportMgt.GetAmountInfoFromGLEntry(AmountXMLNode, Amount, GLEntry);
            ExportAmountInfo(AmountXMLNode, Amount);
            SAFTXMLHelper.AppendXMLNode('ReferenceNumber', GLEntry."External Document No.");
            if (GLEntry."VAT Bus. Posting Group" <> '') or (GLEntry."VAT Prod. Posting Group" <> '') then begin
                VATEntry.SetCurrentKey("Document No.", "Posting Date");
                VATEntry.SetRange("Document No.", GLEntry."Document No.");
                VATEntry.SetRange("Posting Date", GLEntry."Posting Date");
                VATEntry.SetRange("Transaction No.", GLEntry."Transaction No.");
                if VATEntry.FindFirst() then
                    ExportTaxInformation(VATEntry);
            end;
            SAFTXMLHelper.FinalizeXMLNode();
        until GLEntry.Next() = 0;
        SAFTXMLHelper.FinalizeXMLNode();
    end;

    local procedure ExportGLEntryTransactionInfo(GLEntry: Record "G/L Entry")
    begin
        SAFTXMLHelper.AddNewXMLNode('Transaction', '');
        SAFTXMLHelper.AppendXMLNode('TransactionID', format(GLEntry."Transaction No."));
        SAFTXMLHelper.AppendXMLNode('Period', format(Date2DMY(GLEntry."Posting Date", 2)));
        SAFTXMLHelper.AppendXMLNode('PeriodYear', format(Date2DMY(GLEntry."Posting Date", 3)));
        SAFTXMLHelper.AppendXMLNode('TransactionDate', FormatDate(GLEntry."Document Date"));
        SAFTXMLHelper.AppendXMLNode('SourceID', GLEntry."User ID");
        SAFTXMLHelper.AppendXMLNode('Description', GLEntry.Description);
        SAFTXMLHelper.AppendXMLNode('SystemEntryDate', FormatDate(GLEntry."Document Date"));
        SAFTXMLHelper.AppendXMLNode('GLPostingDate', FormatDate(GLEntry."Posting Date"));
    end;

    local procedure ExportTaxInformation(VATEntry: Record 254)
    var
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        if not (VATEntry.Type in [VATEntry.Type::Sale, VATEntry.Type::Sale]) then
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
        ExportAmountInfo('TaxAmount', abs(VATEntry.Amount));
        SAFTXMLHelper.FinalizeXMLNode();
    end;

    local procedure ExportAmountInfo(ParentNodeName: Text; Amount: Decimal)
    begin
        SAFTXMLHelper.AddNewXMLNode(ParentNodeName, '');
        SAFTXMLHelper.AppendXMLNode('Amount', FormatAmount(Amount));
        SAFTXMLHelper.FinalizeXMLNode();
    end;

    local procedure ExportBankAccount(CountryCode: Code[10]; BankName: Text; BankNumber: Text; IBAN: Text; BranchNo: Text; CurrencyCode: Code[10])
    var
        TempNameValueBuffer: Record "Name/Value Buffer" temporary;
        SAFTExportMgt: Codeunit "SAF-T Export Mgt.";
        Exported: Boolean;
    begin
        if (IBAN = '') and (BankNumber = '') and (BankName = '') and (BranchNo = '') then
            exit;


        GetBankAccInfo(TempNameValueBuffer, CountryCode, BankName, BankNumber, IBAN, BranchNo);
        Exported := false;
        if not TempNameValueBuffer.FindSet() then
            exit;

        SAFTXMLHelper.AddNewXMLNode('BankAccount', '');
        repeat
            If TempNameValueBuffer.Value <> '' then begin
                SAFTXMLHelper.AppendXMLNode(TempNameValueBuffer.Name, TempNameValueBuffer.Value);
                Exported := true;
            end;
        until (TempNameValueBuffer.next() = 0) or Exported;
        SAFTXMLHelper.AppendXMLNode('CurrencyCode', SAFTExportMgt.GetISOCurrencyCode(CurrencyCode));
        SAFTXMLHelper.FinalizeXMLNode();
    end;

    local procedure GetBankAccInfo(var TempNameValueBuffer: Record "Name/Value Buffer" temporary; CountryCode: Code[10]; BankName: Text; BankNumber: Text; IBAN: Text; BranchNo: Text)
    var
        CompanyInformation: Record "Company Information";
    begin
        TempNameValueBuffer.Reset();
        TempNameValueBuffer.DeleteAll();
        CompanyInformation.Get();
        if CountryCode = CompanyInformation."Country/Region Code" then begin
            InsertTempNameValueBuffer(TempNameValueBuffer, 'BankAccountNumber', BankNumber);
            InsertTempNameValueBuffer(TempNameValueBuffer, 'IBANNumber', IBAN);
        end else begin
            InsertTempNameValueBuffer(TempNameValueBuffer, 'IBANNumber', IBAN);
            InsertTempNameValueBuffer(TempNameValueBuffer, 'BankAccountNumber', BankNumber);
        end;
        InsertTempNameValueBuffer(TempNameValueBuffer, 'BankAccountName', BankName);
        InsertTempNameValueBuffer(TempNameValueBuffer, 'SortCode', BranchNo);
    end;

    local procedure InsertTempNameValueBuffer(var TempNameValueBuffer: Record "Name/Value Buffer" temporary; Name: Text; Value: Text)
    begin
        TempNameValueBuffer.Id += 1;
        TempNameValueBuffer.Name := copystr(Name, 1, MaxStrLen(TempNameValueBuffer.Name));
        TempNameValueBuffer.Value := copystr(Value, 1, MaxStrLen(TempNameValueBuffer.Value));
        if not TempNameValueBuffer.Insert() then
            TempNameValueBuffer.Modify();
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
        TempDimCodeAmountBuffer: Record "Dimension Code Amount Buffer" temporary;
        SAFTExportMgt: Codeunit "SAF-T Export Mgt.";
    begin
        SAFTXMLHelper.AddNewXMLNode('PartyInfo', '');
        ExportPaymentTerms(PaymentTermsCode);
        SAFTXMLHelper.AppendXMLNode('CurrencyCode', SAFTExportMgt.GetISOCurrencyCode(CurrencyCode));
        DefaultDimension.SetRange("Table ID", SourceID);
        DefaultDimension.SetRange("No.", SourceNo);
        CopyDefaultDimToDimCodeAmountBuffer(TempDimCodeAmountBuffer, DefaultDimension);
        ExportAnalysisInfo(TempDimCodeAmountBuffer);
        SAFTXMLHelper.FinalizeXMLNode();
    end;

    local procedure ExportAnalysisInfo(var TempDimCodeAmountBuffer: Record "Dimension Code Amount Buffer" temporary)
    begin
        if TempDimCodeAmountBuffer.FindSet() then
            repeat
                SAFTXMLHelper.AddNewXMLNode('Analysis', '');
                SAFTXMLHelper.AppendXMLNode('AnalysisType', TempDimCodeAmountBuffer."Line Code");
                SAFTXMLHelper.AppendXMLNode('AnalysisID', TempDimCodeAmountBuffer."Column Code");
                SAFTXMLHelper.FinalizeXMLNode();
            until TempDimCodeAmountBuffer.Next() = 0;
    end;

    local procedure CopyDefaultDimToDimCodeAmountBuffer(var TempDimCodeAmountBuffer: Record "Dimension Code Amount Buffer" temporary; var DefaultDimension: Record "Default Dimension")
    var
        Dimension: Record Dimension;
    begin
        TempDimCodeAmountBuffer.reset();
        TempDimCodeAmountBuffer.DeleteAll();
        if DefaultDimension.FindSet() then
            repeat
                Dimension.get(DefaultDimension."Dimension Code");
                TempDimCodeAmountBuffer."Line Code" := Dimension."SAF-T Analysis Type";
                TempDimCodeAmountBuffer."Column Code" := DefaultDimension."Dimension Value Code";
                TempDimCodeAmountBuffer.Insert();
            until DefaultDimension.next() = 0;
    end;

    local procedure CopyDimeSetIDToDimCodeAmountBuffer(var TempDimCodeAmountBuffer: Record "Dimension Code Amount Buffer" temporary; DimSetID: Integer)
    var
        TempDimSetEntry: Record "Dimension Set Entry" temporary;
        Dimension: Record Dimension;
        DimensionManagement: Codeunit DimensionManagement;
    begin
        TempDimCodeAmountBuffer.Reset();
        TempDimCodeAmountBuffer.DeleteAll();
        if DimSetID = 0 then
            exit;

        DimensionManagement.GetDimensionSet(TempDimSetEntry, DimSetID);
        if not TempDimSetEntry.FindSet() then
            exit;

        repeat
            Dimension.Get(TempDimSetEntry."Dimension Code");
            TempDimCodeAmountBuffer."Line Code" := Dimension."SAF-T Analysis Type";
            TempDimCodeAmountBuffer."Column Code" := TempDimSetEntry."Dimension Value Code";
            TempDimCodeAmountBuffer.Insert();
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

    local procedure FinalizeExport(var SAFTExportLine: Record "SAF-T Export Line"; SAFTExportHeader: Record "SAF-T Export Header")
    var
        SAFTExportMgt: Codeunit "SAF-T Export Mgt.";
        TypeHelper: Codeunit "Type Helper";
    begin
        SAFTExportLine.Find();
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
        SAFTExportHeader.find();
        if SAFTExportHeader.Status = SAFTExportHeader.Status::Completed then
            if SAFTExportHeader.AllowedToExportIntoFolder() then
                SAFTExportMgt.GenerateZipFileFromSavedFiles(SAFTExportHeader)
            else
                SAFTExportMgt.BuildZipFilesWithAllRelatedXmlFiles(SAFTExportHeader);
    end;

    local procedure CombineWithSpace(FirstString: Text; SecondString: Text) Result: Text
    begin
        Result := FirstString;
        If (Result <> '') and (SecondString <> '') then
            Result += ' ';
        exit(Result + SecondString);
    end;

    local procedure FormatDate(DateToFormat: Date): Text
    begin
        exit(format(DateToFormat, 0, 9));
    end;

    local procedure FormatAmount(AmountToFormat: Decimal): Text
    begin
        exit(format(AmountToFormat, 0, 9))
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetFirstAndLastNameFromCustomer(var Handled: Boolean; var FirstName: Text; var LastName: Text; Customer: Record Customer)
    begin

    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetFirstAndLastNameFromVendor(var Handled: Boolean; var FirstName: Text; var LastName: Text; Vendor: Record Vendor)
    begin

    end;
}
