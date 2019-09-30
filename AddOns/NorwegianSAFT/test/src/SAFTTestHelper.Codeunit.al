codeunit 148099 "SAF-T Test Helper"
{
    trigger OnRun()
    begin

    end;

    var
        Assert: Codeunit Assert;
        LibraryHumanResource: Codeunit "Library - Human Resource";
        LibraryERM: Codeunit "Library - ERM";
        LibrarySales: Codeunit "Library - Sales";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryRandom: Codeunit "Library - Random";
        LibraryDimension: Codeunit "Library - Dimension";
        UnexpectedElementNameErr: Label 'Unexpected element name. Expected element name: %1. Actual element name: %2.', Comment = '%1=Expetced XML Element Name;%2=Actual XML Element Name';
        UnexpectedElementValueErr: Label 'Unexpected element value for element %1. Expected element value: %2. Actual element value: %3.', Comment = '%1=XML Element Name;%2=Expected XML Element Value;%3=Actual XML element Value';

    procedure SetupMasterData()
    var
        TempGLAccount: Record "G/L Account" temporary;
    begin
        SetupCompanyInformation();
        SetupGLAccounts(TempGLAccount);
        // Use same G/L accounts for customer and vendor posting to avoid creation of new accounts
        SetupVATPostingSetupMapping();
        SetupCompanyBankAccount();
        TempGLAccount.FindSet();
        SetupCustomers(TempGLAccount);
        SetupVendors(TempGLAccount);
        SetupDimensions();
    end;

    procedure InsertSAFTMappingRangeFullySetup(var SAFTMappingRange: Record "SAF-T Mapping Range"; MappingType: Enum "SAF-T Mapping Type"; StartingDate: Date; EndingDate: Date)
    var
        SAFTMappingHelper: Codeunit "SAF-T Mapping Helper";
    begin
        InsertSAFTMappingRangeWithSource(SAFTMappingRange, MappingType, StartingDate, EndingDate);
        SAFTMappingHelper.Run(SAFTMappingRange);
    end;

    procedure InsertSAFTMappingRangeWithSource(var SAFTMappingRange: Record "SAF-T Mapping Range"; MappingType: Enum "SAF-T Mapping Type"; StartingDate: Date; EndingDate: Date)
    var
        SAFTXMLImport: Codeunit "SAF-T XML Import";
    begin
        InsertSAFTMappingRange(SAFTMappingRange, MappingType, StartingDate, EndingDate);
        SAFTXMLImport.Run(SAFTMappingRange);
    end;

    procedure InsertSAFTMappingRange(var SAFTMappingRange: Record "SAF-T Mapping Range"; MappingType: Enum "SAF-T Mapping Type"; StartingDate: Date; EndingDate: Date)
    begin
        SAFTMappingRange.Init();
        SAFTMappingRange.Code := LibraryUtility.GenerateGUID();
        SAFTMappingRange.Validate("Mapping Type", MappingType);
        SAFTMappingRange.Validate("Starting Date", StartingDate);
        SAFTMappingRange.Validate("Ending Date", EndingDate);
        SAFTMappingRange.Insert(true);
    end;

    procedure CreateSAFTExportHeader(var SAFTExportHeader: Record "SAF-T Export Header"; MappingRangeCode: Code[20])
    begin
        SAFTExportHeader.Init();
        SAFTExportHeader.Validate("Mapping Range Code", MappingRangeCode);
        SAFTExportHeader.Insert(true);
    end;

    procedure RunSAFTExport(var SAFTExportHeader: Record "SAF-T Export Header")
    begin
        Codeunit.Run(Codeunit::"SAF-T Export Mgt.", SAFTExportHeader);
    end;

    procedure PostRandomAmountForNumberOfMasterDataRecords(PostingDate: Date; NumberOfMasterDataRecords: Integer)
    var
        GLAccount: Record "G/L Account";
        Customer: Record Customer;
        Vendor: Record Vendor;
        i: Integer;
        Amount: Decimal;
    begin
        GLAccount.SetRange("Income/Balance", GLAccount."Income/Balance"::"Balance Sheet");
        GLAccount.FindSet();
        Customer.FindSet();
        Vendor.FindSet();
        // Make debit amount more than credit amount to make sure we have positive closing balance for all G/L accounts
        Amount := LibraryRandom.RandDec(100, 2);
        for i := 1 to NumberOfMasterDataRecords do begin
            MockCustLedgEntry(PostingDate, Customer."No.", Amount);
            MockVendLedgEntry(PostingDate, Vendor."No.", -Amount);
            MockGLEntry(PostingDate, LibraryUtility.GenerateGUID(), GLAccount."No.", i, 0, '', '', 0, '', GetGLSourceCode(), Amount, 0);
            GLAccount.Next();
            Customer.Next();
            Vendor.Next();
        end;
    end;

    procedure MockEntriesForFirstRecordOfMasterData(IncomeBalance: Integer; PostingDate: Date; GLAccAmount: Decimal; CustAmount: Decimal; VendAmount: Decimal)
    var
        GLAccount: Record "G/L Account";
        Customer: Record Customer;
        Vendor: Record Vendor;
    begin
        GLAccount.SetRange("Income/Balance", GLAccount."Income/Balance"::"Balance Sheet");
        GLAccount.FindFirst();
        Customer.FindFirst();
        Vendor.FindFirst();
        MockGLEntry(PostingDate, LibraryUtility.GenerateGUID(), GLAccount."No.", 1, 0, '', '', 0, '', GetGLSourceCode(), GLAccAmount, 0);
        MockCustLedgEntry(PostingDate, Customer."No.", CustAmount);
        MockCustLedgEntry(PostingDate, Vendor."No.", VendAmount);
    end;

    procedure MockGLEntryNoVAT(PostingDate: Date; GLAccNo: Code[20]; TransactionNo: Integer; DimSetID: Integer; SourceType: Integer; SourceNo: Code[20]; SourceCode: Code[10]; DebitAmount: Decimal; CreditAmount: Decimal)
    begin
        MockGLEntry(PostingDate, LibraryUtility.GenerateGUID(), GLAccNo, TransactionNo, DimSetID, '', '', SourceType, SourceNo, SourceCode, DebitAmount, CreditAmount);
    end;

    procedure MockGLEntry(PostingDate: Date; DocNo: Code[20]; GLAccNo: Code[20]; TransactionNo: Integer; DimSetID: Integer; VATBusPostingGroupCode: Code[20]; VATProdPostingGroupCode: Code[20]; SourceType: Integer; SourceNo: Code[20]; SourceCode: Code[10]; DebitAmount: Decimal; CreditAmount: Decimal)
    var
        GLEntry: Record "G/L Entry";
    begin
        GLEntry.Init();
        GLEntry."Entry No." := LibraryUtility.GetNewRecNo(GLEntry, GLEntry.FieldNo("Entry No."));
        GLEntry."Posting Date" := PostingDate;
        GLEntry."Document Date" := PostingDate;
        GLEntry."Document No." := DocNo;
        GLEntry."G/L Account No." := GLAccNo;
        GLEntry."Transaction No." := TransactionNo;
        GLEntry."Dimension Set ID" := DimSetID;
        GLEntry.Description := LibraryUtility.GenerateGUID();
        GLEntry."External Document No." := LibraryUtility.GenerateGUID();
        GLEntry."User ID" := copystr(UserId(), 1, MaxStrLen(GLEntry."User ID"));
        GLEntry."Source Code" := SourceCode;
        GLEntry."VAT Bus. Posting Group" := VATBusPostingGroupCode;
        GLEntry."VAT Prod. Posting Group" := VATProdPostingGroupCode;
        GLEntry."Debit Amount" := DebitAmount;
        GLEntry."Credit Amount" := CreditAmount;
        GLEntry.Amount := DebitAmount + CreditAmount;
        GLEntry.Insert()
    end;

    procedure MockVATEntry(var VATEntry: Record "VAT Entry"; PostingDate: Date; Type: Integer; TransactionNo: Integer)
    var
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        VATEntry.init();
        VATEntry."Entry No." := LibraryUtility.GetNewRecNo(VATEntry, VATEntry.FieldNo("Entry No."));
        VATEntry."Posting Date" := PostingDate;
        VATEntry."Transaction No." := TransactionNo;
        VATEntry."Document No." := LibraryUtility.GenerateGUID();
        VATEntry.Type := Type;
        LibraryERM.FindVATPostingSetup(VATPostingSetup, VATPostingSetup."VAT Calculation Type"::"Normal VAT");
        VATEntry."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
        VATEntry."VAT Prod. Posting Group" := VATPostingSetup."VAT Prod. Posting Group";
        VATEntry.Base := LibraryRandom.RandDec(100, 2);
        VATEntry.Amount := LibraryRandom.RandDec(100, 2);
        VATEntry.Insert();
    end;

    local procedure MockCustLedgEntry(PostingDate: Date; CustNo: Code[20]; Amount: Decimal)
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        DetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry";
    begin
        CustLedgerEntry.Init();
        CustLedgerEntry."Entry No." := LibraryUtility.GetNewRecNo(CustLedgerEntry, CustLedgerEntry.FieldNo("Entry No."));
        CustLedgerEntry."Posting Date" := PostingDate;
        CustLedgerEntry."Customer No." := CustNo;
        CustLedgerEntry.Insert();
        DetailedCustLedgEntry.Init();
        DetailedCustLedgEntry."Entry No." :=
            LibraryUtility.GetNewRecNo(DetailedCustLedgEntry, DetailedCustLedgEntry.FieldNo("Entry No."));
        DetailedCustLedgEntry."Cust. Ledger Entry No." := CustLedgerEntry."Entry No.";
        DetailedCustLedgEntry."Posting Date" := CustLedgerEntry."Posting Date";
        DetailedCustLedgEntry."Customer No." := CustLedgerEntry."Customer No.";
        DetailedCustLedgEntry."Amount (LCY)" := Amount;
        DetailedCustLedgEntry.Insert();
    end;

    local procedure MockVendLedgEntry(PostingDate: Date; VendNo: Code[20]; Amount: Decimal)
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        DetailedVendorLedgEntry: Record "Detailed Vendor Ledg. Entry";
    begin
        VendorLedgerEntry.Init();
        VendorLedgerEntry."Entry No." := LibraryUtility.GetNewRecNo(VendorLedgerEntry, VendorLedgerEntry.FieldNo("Entry No."));
        VendorLedgerEntry."Posting Date" := PostingDate;
        VendorLedgerEntry."Vendor No." := VendNo;
        VendorLedgerEntry.Insert();
        DetailedVendorLedgEntry.Init();
        DetailedVendorLedgEntry."Entry No." :=
            LibraryUtility.GetNewRecNo(DetailedVendorLedgEntry, DetailedVendorLedgEntry.FieldNo("Entry No."));
        DetailedVendorLedgEntry."Vendor Ledger Entry No." := VendorLedgerEntry."Entry No.";
        DetailedVendorLedgEntry."Posting Date" := VendorLedgerEntry."Posting Date";
        DetailedVendorLedgEntry."Vendor No." := VendorLedgerEntry."Vendor No.";
        DetailedVendorLedgEntry."Amount (LCY)" := Amount;
        DetailedVendorLedgEntry.Insert();
    end;

    procedure GetGLSourceCode(): Code[10]
    var
        SourceCodeSetup: Record "Source Code Setup";
    begin
        SourceCodeSetup.Get();
        exit(SourceCodeSetup."General Journal");
    end;

    procedure SetDimensionForGLAccount(GLAccNo: Code[20]; var SAFTAnalysisType: Code[9]; var DimValueCode: Code[20]; var DimSetID: Integer)
    var
        Dimension: Record Dimension;
        DimValue: Record "Dimension Value";
        DefaultDimension: Record "Default Dimension";
    begin
        LibraryDimension.CreateDimension(Dimension);
        LibraryDimension.CreateDimensionValue(DimValue, Dimension.Code);
        LibraryDimension.CreateDefaultDimensionGLAcc(
            DefaultDimension, GLAccNo, DimValue."Dimension Code", DimValue.Code);
        SAFTAnalysisType := Dimension."SAF-T Analysis Type";
        DimValueCode := DimValue.Code;
        DimSetID := LibraryDimension.CreateDimSet(0, DimValue."Dimension Code", DimValue.Code);
    end;

    local procedure SetupCompanyInformation()
    var
        Employee: Record Employee;
        CompanyInformation: Record "Company Information";
        GeneralLedgerSetup: Record "General Ledger Setup";
        PostCode: Record "Post Code";
    begin
        LibraryHumanResource.CreateEmployee(Employee);
        Employee.Validate("First Name", LibraryUtility.GenerateGUID());
        Employee.Validate("Last Name", LibraryUtility.GenerateGUID());
        Employee.Validate("Phone No.", LibraryUtility.GenerateGUID());
        Employee.Validate("Fax No.", LibraryUtility.GenerateGUID());
        Employee."E-Mail" := LibraryUtility.GenerateGUID();
        Employee.Validate("Mobile Phone No.", LibraryUtility.GenerateGUID());
        Employee.Modify(true);

        CompanyInformation.Get();
        CompanyInformation.Validate(Name, LibraryUtility.GenerateGUID());
        CompanyInformation.Validate("Name 2", LibraryUtility.GenerateGUID());
        CompanyInformation.Validate(Address, LibraryUtility.GenerateGUID());
        CompanyInformation.Validate("Address 2", LibraryUtility.GenerateGUID());
        CompanyInformation.Validate("SAF-T Contact No.", Employee."No.");
        CompanyInformation."VAT Registration No." := LibraryUtility.GenerateGUID();
        CompanyInformation.Modify(true);

        LibraryERM.CreatePostCode(PostCode);
        CompanyInformation.Validate("Country/Region Code", PostCode."Country/Region Code");
        CompanyInformation.Validate("Post Code", PostCode.Code);
        CompanyInformation.Validate(City, PostCode.City);
        CompanyInformation.Modify(true);
        GeneralLedgerSetup.Get();
        GeneralLedgerSetup.Validate("LCY Code", LibraryUtility.GenerateGUID());
        GeneralLedgerSetup.Modify();
    end;

    local procedure SetupVATPostingSetupMapping()
    var
        VATPostingSetup: Record "VAT Posting Setup";
        VATCode: Record "VAT Code";
    begin
        VATPostingSetup.FindSet();
        VATPostingSetup.Next(); // do not specify any value for Standard Tax Code in order to verify that NA value will be exported in the XML file
        VATCode.FindSet();
        repeat
            VATPostingSetup.Validate("Sales SAF-T Standard Tax Code", VATCode.Code);
            VATPostingSetup.Validate("Purch. SAF-T Standard Tax Code", VATCode.Code);
            VATPostingSetup.Validate("Calc. Prop. Deduction VAT", false);
            VATPostingSetup.Modify(true);
            VATCode.Next();
        until VATPostingSetup.Next() = 0;
        VATCode.ModifyAll(Compensation, false);
    end;

    local procedure SetupCompanyBankAccount()
    var
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.Get();
        CompanyInformation."Bank Account No." := LibraryUtility.GenerateGUID();
        CompanyInformation.Modify();
    end;

    local procedure SetupGLAccounts(var TempGLAccount: Record "G/L Account" temporary)
    var
        GLAccount: Record "G/L Account";
        SAFTGLAccountMapping: Record "SAF-T G/L Account Mapping";
        i: integer;
        IncomeBalance: Integer;
    begin
        GLAccount.DeleteAll();
        SAFTGLAccountMapping.DeleteAll();
        TempGLAccount.Reset();
        TempGLAccount.DeleteAll();
        for IncomeBalance := GLAccount."Income/Balance"::"Income Statement" to GLAccount."Income/Balance"::"Balance Sheet" do
            for i := 1 to LibraryRandom.RandIntInRange(5, 10) do begin
                LibraryERM.CreateGLAccount(GLAccount);
                GLAccount.Validate("Account Type", GLAccount."Account Type"::Posting);
                GLAccount.Validate("Income/Balance", IncomeBalance);
                GLAccount.Validate("Direct Posting", true);
                GLAccount.Modify(true);
                TempGLAccount := GLAccount;
                TempGLAccount.Insert();
            end;
    end;

    local procedure SetupCustomers(var TempGLAccount: Record "G/L Account" temporary)
    var
        Customer: Record Customer;
        CustomerBankAccount: Record "Customer Bank Account";
        CustomerPostingGroup: Record "Customer Posting Group";
        PostCode: Record "Post Code";
        CompanyInformation: Record "Company Information";
        i: Integer;
        j: Integer;
    begin
        Customer.DeleteAll();
        for i := 1 to LibraryRandom.RandInt(5) do begin
            LibrarySales.CreateCustomer(Customer);
            Customer."VAT Registration No." := LibraryUtility.GenerateGUID();
            Customer.Validate(Address, LibraryUtility.GenerateGUID());
            Customer.Validate("Address 2", LibraryUtility.GenerateGUID());
            LibraryERM.CreatePostCode(PostCode);
            CompanyInformation.Get();
            Customer."Country/Region Code" := CompanyInformation."Country/Region Code";
            Customer.Validate("Post Code", PostCode.Code);
            Customer.Validate(City, PostCode.City);
            Customer.Validate(Contact, LibraryUtility.GenerateGUID());
            Customer."Phone No." := LibraryUtility.GenerateGUID();
            Customer.Validate("Fax No.", LibraryUtility.GenerateGUID());
            Customer."E-Mail" := LibraryUtility.GenerateGUID();
            Customer.Validate("Home Page", LibraryUtility.GenerateGUID());
            Customer.Validate("Payment Terms Code", CreatePaymentTerms());
            Customer.Modify(true);
            CustomerPostingGroup.Get(Customer."Customer Posting Group");
            CustomerPostingGroup.Validate("Receivables Account", TempGLAccount."No.");
            CustomerPostingGroup.Modify(true);
            LibrarySales.CreateCustomerBankAccount(CustomerBankAccount, Customer."No.");
            CustomerBankAccount."Bank Account No." := LibraryUtility.GenerateGUID();
            CustomerBankAccount.Modify(true);
            for j := 1 to LibraryRandom.RandInt(3) do
                CreateDefaultDimensions(Database::Customer, Customer."No.");
        end;
    end;

    local procedure SetupVendors(var TempGLAccount: Record "G/L Account" temporary)
    var
        Vendor: Record Vendor;
        VendorPostingGroup: Record "Vendor Posting Group";
        VendorBankAccount: Record "Vendor Bank Account";
        PostCode: Record "Post Code";
        CompanyInformation: Record "Company Information";
        i: integer;
        j: Integer;
    begin
        Vendor.DeleteAll();
        for i := 1 to LibraryRandom.RandInt(5) do begin
            LibraryPurchase.CreateVendor(Vendor);
            Vendor."VAT Registration No." := LibraryUtility.GenerateGUID();
            Vendor.Validate(Address, LibraryUtility.GenerateGUID());
            Vendor.Validate("Address 2", LibraryUtility.GenerateGUID());
            LibraryERM.CreatePostCode(PostCode);
            CompanyInformation.Get();
            Vendor."Country/Region Code" := CompanyInformation."Country/Region Code";
            Vendor.Validate("Post Code", PostCode.Code);
            Vendor.Validate(City, PostCode.City);
            Vendor.Validate(Contact, LibraryUtility.GenerateGUID());
            Vendor."Phone No." := LibraryUtility.GenerateGUID();
            Vendor.Validate("Fax No.", LibraryUtility.GenerateGUID());
            Vendor."E-Mail" := LibraryUtility.GenerateGUID();
            Vendor.Validate("Home Page", LibraryUtility.GenerateGUID());
            Vendor.Validate("Payment Terms Code", CreatePaymentTerms());
            Vendor.Modify(true);
            VendorPostingGroup.Get(Vendor."Vendor Posting Group");
            VendorPostingGroup.Validate("Payables Account", TempGLAccount."No.");
            VendorPostingGroup.Modify(true);
            LibraryPurchase.CreateVendorBankAccount(VendorBankAccount, Vendor."No.");
            VendorBankAccount."Bank Account No." := LibraryUtility.GenerateGUID();
            VendorBankAccount.Modify(true);
            for j := 1 to LibraryRandom.RandInt(3) do
                CreateDefaultDimensions(Database::Vendor, Vendor."No.");
        end;
        TempGLAccount.Next();
    end;

    local procedure SetupDimensions()
    var
        DimensionValue: Record "Dimension Value";
    begin
        DimensionValue.SetFilter(Name, ' ');
        if DimensionValue.FindSet() then
            repeat
                DimensionValue.Name := LibraryUtility.GenerateGUID();
                DimensionValue.Modify();
            until DimensionValue.Next() = 0;
    end;

    local procedure CreateDefaultDimensions(TableID: Integer; SourceNo: Code[20])
    var
        Dimension: Record Dimension;
        DimensionValue: Record "Dimension Value";
        DefaultDimension: Record "Default Dimension";
    begin
        LibraryDimension.CreateDimension(Dimension);
        LibraryDimension.CreateDimensionValue(DimensionValue, Dimension.Code);
        LibraryDimension.CreateDefaultDimension(
            DefaultDimension, TableID, SourceNo, DimensionValue."Dimension Code", DimensionValue.Code);
    end;

    local procedure CreateCurrencyWithISOCode(): Code[10]
    var
        Currency: Record Currency;
    begin
        LibraryERM.CreateCurrency(Currency);
        Currency."ISO Code" :=
            copystr(LibraryUtility.GenerateRandomCodeWithLength(
                Currency.FieldNo("ISO Code"), Database::Currency, MaxStrLen(Currency."ISO Code")), 1, MaxStrLen(Currency."ISO Code"));
        Currency.Modify(true);
        exit(Currency.Code);
    end;

    local procedure CreatePaymentTerms(): Code[10]
    var
        PaymentTerms: Record "Payment Terms";
    begin
        LibraryERM.CreatePaymentTermsDiscount(PaymentTerms, false);
        exit(PaymentTerms.Code)
    end;

    procedure FindSAFTHeaderElement(var TempXMLBuffer: Record "XML Buffer" temporary)
    begin
        TempXMLBuffer.FindNodesByXPath(TempXMLBuffer, '/nl:AuditFile/nl:Header');
    end;

    procedure AssertElementValue(var TempXMLBuffer: Record "XML Buffer" temporary; ElementName: Text; ElementValue: Text)
    begin
        FindNextElement(TempXMLBuffer);
        AssertCurrentElementValue(TempXMLBuffer, ElementName, ElementValue);
    end;

    procedure AssertElementName(var TempXMLBuffer: Record "XML Buffer" temporary; ElementName: Text)
    begin
        FindNextElement(TempXMLBuffer);
        Assert.AreEqual(ElementName, TempXMLBuffer.GetElementName(),
            StrSubstNo(UnexpectedElementNameErr, ElementName, TempXMLBuffer.GetElementName()));
    end;

    procedure AssertCurrentElementValue(var TempXMLBuffer: Record "XML Buffer" temporary; ElementName: Text; ElementValue: Text)
    begin
        Assert.AreEqual(ElementName, TempXMLBuffer.GetElementName(),
            StrSubstNo(UnexpectedElementNameErr, ElementName, TempXMLBuffer.GetElementName()));
        Assert.AreEqual(ElementValue, TempXMLBuffer.Value,
            StrSubstNo(UnexpectedElementValueErr, ElementName, ElementValue, TempXMLBuffer.Value));
    end;

    procedure AssertCurrentValue(var TempXMLBuffer: Record "XML Buffer" temporary; XPath: Text; ExpectedValue: Text)
    begin
        TempXMLBuffer.Reset();
        TempXMLBuffer.FindNodesByXPath(TempXMLBuffer, XPath);
        Assert.AreEqual(ExpectedValue, TempXMLBuffer.Value,
            StrSubstNo(UnexpectedElementValueErr, TempXMLBuffer.GetElementName(), ExpectedValue, TempXMLBuffer.Value));
    end;

    procedure FindNextElement(var TempXMLBuffer: Record "XML Buffer" temporary)
    begin
        if TempXMLBuffer.HasChildNodes() then
            TempXMLBuffer.FindChildElements(TempXMLBuffer)
        else
            if not (TempXMLBuffer.Next() > 0) then begin
                TempXMLBuffer.GetParent();
                TempXMLBuffer.SetRange("Parent Entry No.", TempXMLBuffer."Parent Entry No.");
                if not (TempXMLBuffer.Next() > 0) then
                    repeat
                        TempXMLBuffer.GetParent();
                        TempXMLBuffer.SetRange("Parent Entry No.", TempXMLBuffer."Parent Entry No.");
                    until TempXMLBuffer.Next() > 0;
            end;
    end;

    procedure FormatDate(DateToFormat: Date): Text
    begin
        exit(format(DateToFormat, 0, 9));
    end;

    procedure FormatAmount(AmountToFormat: Decimal): Text
    begin
        exit(format(AmountToFormat, 0, 9))
    end;

    procedure CombineWithSpace(FirstString: Text; SecondString: Text) Result: Text
    begin
        Result := FirstString;
        If (Result <> '') and (SecondString <> '') then
            Result += ' ';
        exit(Result + SecondString);
    end;

    procedure GetFirstAndLastNameFromContactName(var FirstName: Text; var LastName: Text; ContactName: Text)
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


}