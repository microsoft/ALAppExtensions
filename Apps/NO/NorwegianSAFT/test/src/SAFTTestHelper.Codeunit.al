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

    procedure SetupSAFT(var SAFTMappingRange: Record "SAF-T Mapping Range"; MappingType: Enum "SAF-T Mapping Type"; NumberOfMasterDataRecords: Integer): Code[20]
    var
        SAFTMappingHelper: Codeunit "SAF-T Mapping Helper";
    begin
        SetupMasterData(NumberOfMasterDataRecords);
        InsertSAFTMappingRangeFullySetup(
            SAFTMappingRange, MappingType, GetWorkDateInYearWithNoGLEntries(),
            CalcDate('<CY>', GetWorkDateInYearWithNoGLEntries()));
        SAFTMappingHelper.MapRestSourceCodesToAssortedJournals();
        exit(SAFTMappingRange.Code);
    end;

    procedure SetupMasterData(NumberOfMasterDataRecords: Integer)
    var
        TempGLAccount: Record "G/L Account" temporary;
    begin
        SetupCompanyInformation();
        RemoveGLAccData();
        SetupGLAccounts(TempGLAccount, TempGLAccount."Income/Balance"::"Income Statement", NumberOfMasterDataRecords);
        SetupGLAccounts(TempGLAccount, TempGLAccount."Income/Balance"::"Balance Sheet", NumberOfMasterDataRecords);
        // Use same G/L accounts for customer and vendor posting to avoid creation of new accounts
        SetupMasterDataBasedOnGLAccounts(TempGLAccount, NumberOfMasterDataRecords);
    end;

    procedure SetupMasterDataSingleAcc(IncomeBalance: Integer)
    var
        TempGLAccount: Record "G/L Account" temporary;
    begin
        SetupCompanyInformation();
        RemoveGLAccData();
        SetupGLAccounts(TempGLAccount, TempGLAccount."Income/Balance"::"Balance Sheet", 1);
        // Use same G/L accounts for customer and vendor posting to avoid creation of new accounts
        SetupMasterDataBasedOnGLAccounts(TempGLAccount, 1);
    end;

    procedure MatchGLAccountsFourDigit(MappingRangeCode: Code[20])
    var
        SAFTMappinRange: Record "SAF-T Mapping Range";
        SAFTMapping: Record "SAF-T Mapping";
        SAFTGLAccountMapping: Record "SAF-T G/L Account Mapping";
    begin
        SAFTGLAccountMapping.SetRange("Mapping Range Code", MappingRangeCode);
        SAFTGLAccountMapping.FindSet();
        SAFTMappinRange.Get(MappingRangeCode);
        SAFTMapping.SetRange("Mapping Type", SAFTMappinRange."Mapping Type");
        SAFTMapping.FindSet();
        repeat
            SAFTGLAccountMapping.Validate("Category No.", SAFTMapping."Category No.");
            SAFTGLAccountMapping.Validate("No.", SAFTMapping."No.");
            SAFTGLAccountMapping.Modify(true);
            SAFTMapping.Next();
        until SAFTGLAccountMapping.Next() = 0;
    end;

    procedure GetWorkDateInYearWithNoGLEntries(): Date
    var
        GLEntry: Record "G/L Entry";
    begin
        GLEntry.SetCurrentKey("Posting Date");
        GLEntry.FindLast();
        exit(CalcDate('<CY+1D>', GLEntry."Posting Date"));
    end;

    local procedure SetupMasterDataBasedOnGLAccounts(var TempGLAccount: Record "G/L Account" temporary; NumberOfMasterDataRecords: Integer)
    begin
        SetupVATPostingSetupMapping();
        SetupCompanyBankAccounts();
        TempGLAccount.FindSet();
        SetupCustomers(TempGLAccount, NumberOfMasterDataRecords);
        SetupVendors(TempGLAccount, NumberOfMasterDataRecords);
        SetupDimensions();
    end;

    procedure InsertSAFTMappingRangeFullySetup(var SAFTMappingRange: Record "SAF-T Mapping Range"; MappingType: Enum "SAF-T Mapping Type"; StartingDate: Date;
                                                                                                                    EndingDate: Date)
    var
        SAFTMappingHelper: Codeunit "SAF-T Mapping Helper";
    begin
        InsertSAFTMappingRangeWithSource(SAFTMappingRange, MappingType, StartingDate, EndingDate);
        SAFTMappingHelper.Run(SAFTMappingRange);
    end;

    procedure InsertSAFTMappingRangeWithSource(var SAFTMappingRange: Record "SAF-T Mapping Range"; MappingType: Enum "SAF-T Mapping Type"; StartingDate: Date;
                                                                                                                    EndingDate: Date)
    var
        SAFTXMLImport: Codeunit "SAF-T XML Import";
    begin
        InsertSAFTMappingRange(SAFTMappingRange, MappingType, StartingDate, EndingDate);
        SAFTXMLImport.Run(SAFTMappingRange);
    end;

    procedure InsertSAFTMappingRange(var SAFTMappingRange: Record "SAF-T Mapping Range"; MappingType: Enum "SAF-T Mapping Type"; StartingDate: Date;
                                                                                                          EndingDate: Date)
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

    procedure IncludesNoSourceCodeToTheFirstSAFTSourceCode()
    var
        SAFTSourceCode: Record "SAF-T Source Code";
    begin
        SAFTSourceCode.FindFirst();
        SAFTSourceCode.Validate("Includes No Source Code", true);
        SAFTSourceCode.Modify(true);
    end;

    procedure PostRandomAmountForNumberOfMasterDataRecords(PostingDate: Date; NumberOfMasterDataRecords: Integer)
    var
        GLAccount: Record "G/L Account";
        Customer: Record Customer;
        Vendor: Record Vendor;
        i: Integer;
        Amount: Decimal;
    begin
        GLAccount.FindSet();
        Customer.FindSet();
        Vendor.FindSet();
        // Make debit amount more than credit amount to make sure we have positive closing balance for all G/L accounts
        Amount := LibraryRandom.RandDec(100, 2);
        for i := 1 to NumberOfMasterDataRecords do begin
            MockCustLedgEntrySimple(PostingDate, Customer."No.", Amount);
            MockVendLedgEntrySimple(PostingDate, Vendor."No.", -Amount);
            MockGLEntry(PostingDate, LibraryUtility.GenerateGUID(), GLAccount."No.", i, 0, '', '', 0, '', GetGLSourceCode(), Amount, 0);
            GLAccount.Next();
            Customer.Next();
            Vendor.Next();
        end;
        // Create entries for all master data records except one G/L Account. In test it verifies that all G/L accounts exports anyway
        for i := 1 to (NumberOfMasterDataRecords - 1) do begin
            MockGLEntry(PostingDate, LibraryUtility.GenerateGUID(), GLAccount."No.", i, 0, '', '', 0, '', GetGLSourceCode(), Amount, 0);
            GLAccount.Next();
        end;
    end;

    procedure MockEntriesForFirstRecordOfMasterData(IncomeBalance: Integer; PostingDate: Date; GLAccAmount: Decimal; CustAmount: Decimal; VendAmount: Decimal)
    var
        GLAccount: Record "G/L Account";
        Customer: Record Customer;
        Vendor: Record Vendor;
    begin
        GLAccount.SetRange("Income/Balance", IncomeBalance);
        GLAccount.FindFirst();
        Customer.FindFirst();
        Vendor.FindFirst();
        MockGLEntry(PostingDate, LibraryUtility.GenerateGUID(), GLAccount."No.", 1, 0, '', '', 0, '', GetGLSourceCode(), GLAccAmount, 0);
        MockCustLedgEntrySimple(PostingDate, Customer."No.", CustAmount);
        MockCustLedgEntrySimple(PostingDate, Vendor."No.", VendAmount);
    end;

    procedure MockGLEntryNoVAT(PostingDate: Date; GLAccNo: Code[20]; TransactionNo: Integer; DimSetID: Integer; SourceType: Integer; SourceNo: Code[20]; SourceCode: Code[10]; DebitAmount: Decimal; CreditAmount: Decimal): Integer
    begin
        exit(MockGLEntry(PostingDate, LibraryUtility.GenerateGUID(), GLAccNo, TransactionNo, DimSetID, '', '', SourceType, SourceNo, SourceCode, DebitAmount, CreditAmount));
    end;

    procedure MockGLEntry(PostingDate: Date; DocNo: Code[20]; GLAccNo: Code[20]; TransactionNo: Integer; DimSetID: Integer; VATBusPostingGroupCode: Code[20]; VATProdPostingGroupCode: Code[20]; SourceType: Integer; SourceNo: Code[20]; SourceCode: Code[10]; DebitAmount: Decimal; CreditAmount: Decimal): Integer
    begin
        exit(MockGLEntryLocal(PostingDate, DocNo, GLAccNo, TransactionNo, DimSetID, 0, VATBusPostingGroupCode, VATProdPostingGroupCode, SourceType, SourceNo, SourceCode, DebitAmount, CreditAmount));
    end;

    procedure MockGLEntry(PostingDate: Date; DocNo: Code[20]; GLAccNo: Code[20]; TransactionNo: Integer; DimSetID: Integer; GenPostingType: Integer; VATBusPostingGroupCode: Code[20]; VATProdPostingGroupCode: Code[20]; SourceType: Integer; SourceNo: Code[20]; SourceCode: Code[10]; DebitAmount: Decimal; CreditAmount: Decimal): Integer
    begin
        exit(MockGLEntryLocal(PostingDate, DocNo, GLAccNo, TransactionNo, DimSetID, GenPostingType, VATBusPostingGroupCode, VATProdPostingGroupCode, SourceType, SourceNo, SourceCode, DebitAmount, CreditAmount));
    end;

    local procedure MockGLEntryLocal(PostingDate: Date; DocNo: Code[20]; GLAccNo: Code[20]; TransactionNo: Integer; DimSetID: Integer; GenPostingType: Integer; VATBusPostingGroupCode: Code[20]; VATProdPostingGroupCode: Code[20]; SourceType: Integer; SourceNo: Code[20]; SourceCode: Code[10]; DebitAmount: Decimal; CreditAmount: Decimal): Integer
    var
        GLEntry: Record "G/L Entry";
    begin
        GLEntry.Init();
        GLEntry."Entry No." := LibraryUtility.GetNewRecNo(GLEntry, GLEntry.FieldNo("Entry No."));
        GLEntry."Posting Date" := PostingDate;
        GLEntry."Document Date" := PostingDate;
        GLEntry."Document Type" := GLEntry."Document Type"::Invoice;
        GLEntry."Document No." := DocNo;
        GLEntry."G/L Account No." := GLAccNo;
        GLEntry."Transaction No." := TransactionNo;
        GLEntry."Dimension Set ID" := DimSetID;
        GLEntry.Description := LibraryUtility.GenerateGUID();
        GLEntry."External Document No." := LibraryUtility.GenerateGUID();
        GLEntry."User ID" := copystr(UserId(), 1, MaxStrLen(GLEntry."User ID"));
        GLEntry."Source Type" := SourceType;
        GLEntry."Source No." := SourceNo;
        GLEntry."Source Code" := SourceCode;
        GLEntry."Gen. Posting Type" := GenPostingType;
        GLEntry."VAT Bus. Posting Group" := VATBusPostingGroupCode;
        GLEntry."VAT Prod. Posting Group" := VATProdPostingGroupCode;
        GLEntry."Debit Amount" := DebitAmount;
        GLEntry."Credit Amount" := CreditAmount;
        GLEntry.Amount := DebitAmount + CreditAmount;
        GLEntry.Insert(true);
        exit(GLEntry."Entry No.");
    end;

    procedure MockVATEntry(var VATEntry: Record "VAT Entry"; PostingDate: Date; Type: Integer; TransactionNo: Integer)
    begin
        MockVATEntryCustom(VATEntry, PostingDate, LibraryUtility.GenerateGUID(), Type, TransactionNo);
    end;

    procedure MockVATEntry(var VATEntry: Record "VAT Entry"; PostingDate: Date; DocumentNo: Code[20]; Type: Integer; TransactionNo: Integer)
    begin
        MockVATEntryCustom(VATEntry, PostingDate, DocumentNo, Type, TransactionNo);
    end;

    local procedure MockVATEntryCustom(var VATEntry: Record "VAT Entry"; PostingDate: Date; DocumentNo: Code[20]; Type: Integer; TransactionNo: Integer)
    var
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        VATEntry.init();
        VATEntry."Entry No." := LibraryUtility.GetNewRecNo(VATEntry, VATEntry.FieldNo("Entry No."));
        VATEntry."Posting Date" := PostingDate;
        VATEntry."VAT Reporting Date" := PostingDate;
        VATEntry."Transaction No." := TransactionNo;
        VATEntry."Document No." := DocumentNo;
        VATEntry.Type := Type;
        LibraryERM.FindVATPostingSetup(VATPostingSetup, VATPostingSetup."VAT Calculation Type"::"Normal VAT");
        VATEntry."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
        VATEntry."VAT Prod. Posting Group" := VATPostingSetup."VAT Prod. Posting Group";
        VATEntry.Base := LibraryRandom.RandDec(100, 2);
        VATEntry.Amount := LibraryRandom.RandDec(100, 2);
        VATEntry.Insert();
    end;

    procedure MockGLEntryVATEntryLink(GLEntryNo: Integer; VATEntryNo: Integer)
    var
        GLEntryVATEntryLink: Record "G/L Entry - VAT Entry Link";
    begin
        GLEntryVATEntryLink.InsertLink(GLEntryNo, VATEntryNo);
    end;

    local procedure MockCustLedgEntrySimple(PostingDate: Date; CustNo: Code[20]; Amount: Decimal)
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        MockCustLedgEntryCustom(LibraryUtility.GetNewRecNo(CustLedgerEntry, CustLedgerEntry.FieldNo("Entry No.")), PostingDate, CustNo, 0, '', Amount, Amount, Amount, 0, "Gen. Journal Document Type"::" ");
    end;

    procedure MockCustLedgEntry(PostingDate: Date; CustNo: Code[20]; Amount: Decimal; AmountDtldCustLedgEntry: Decimal; DocumentType: Enum "Gen. Journal Document Type")
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        MockCustLedgEntryCustom(LibraryUtility.GetNewRecNo(CustLedgerEntry, CustLedgerEntry.FieldNo("Entry No.")), PostingDate, CustNo, 0, '', Amount, Amount, AmountDtldCustLedgEntry, 0, DocumentType);
    end;

    procedure MockCustLedgEntry(EntryNo: Integer; PostingDate: Date; CustNo: Code[20]; TransactionNo: Integer; CurrencyCode: Code[10]; SalesAmount: Decimal; Amount: Decimal; AmountDtldVendLedgEntry: Decimal; CurrencyFactor: Decimal; DocumentType: Enum "Gen. Journal Document Type")
    begin
        MockCustLedgEntryCustom(EntryNo, PostingDate, CustNo, TransactionNo, CurrencyCode, SalesAmount, Amount, AmountDtldVendLedgEntry, CurrencyFactor, DocumentType);
    end;

    procedure MockCustLedgEntryCustom(EntryNo: Integer; PostingDate: Date; CustNo: Code[20]; TransactionNo: Integer; CurrencyCode: Code[10]; SalesAmount: Decimal; Amount: Decimal; AmountLCY: Decimal; CurrencyFactor: Decimal; DocumentType: Enum "Gen. Journal Document Type")
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        DetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry";
    begin
        CustLedgerEntry.Init();
        CustLedgerEntry."Entry No." := EntryNo;
        CustLedgerEntry."Posting Date" := PostingDate;
        CustLedgerEntry."Customer No." := CustNo;
        if not (DocumentType in ["Gen. Journal Document Type"::Payment, "Gen. Journal Document Type"::Refund]) then
            CustLedgerEntry."Sales (LCY)" := SalesAmount;
        CustLedgerEntry."Document Type" := DocumentType;
        CustLedgerEntry."Transaction No." := TransactionNo;
        CustLedgerEntry."Currency Code" := CurrencyCode;
        CustLedgerEntry."Original Currency Factor" := CurrencyFactor;
        CustLedgerEntry.Insert();
        DetailedCustLedgEntry.Init();
        DetailedCustLedgEntry."Entry No." :=
            LibraryUtility.GetNewRecNo(DetailedCustLedgEntry, DetailedCustLedgEntry.FieldNo("Entry No."));
        DetailedCustLedgEntry."Cust. Ledger Entry No." := CustLedgerEntry."Entry No.";
        DetailedCustLedgEntry."Posting Date" := CustLedgerEntry."Posting Date";
        DetailedCustLedgEntry."Customer No." := CustLedgerEntry."Customer No.";
        DetailedCustLedgEntry.Amount := Amount;
        DetailedCustLedgEntry."Ledger Entry Amount" := true;
        DetailedCustLedgEntry."Amount (LCY)" := AmountLCY;
        DetailedCustLedgEntry.Insert();
    end;

    local procedure MockVendLedgEntrySimple(PostingDate: Date; VendNo: Code[20]; Amount: Decimal)
    begin
        MockVendLedgEntry(PostingDate, VendNo, Amount, Amount, "Gen. Journal Document Type"::" ");
    end;

    procedure MockVendLedgEntry(PostingDate: Date; VendNo: Code[20]; Amount: Decimal; AmountDtldVendLedgEntry: Decimal; DocumentType: Enum "Gen. Journal Document Type")
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
    begin
        MockVendLedgEntryCustom(LibraryUtility.GetNewRecNo(VendorLedgerEntry, VendorLedgerEntry.FieldNo("Entry No.")), PostingDate, VendNo, 0, '', Amount, AmountDtldVendLedgEntry, AmountDtldVendLedgEntry, 0, DocumentType);
    end;

    procedure MockVendLedgEntry(EntryNo: Integer; PostingDate: Date; VendNo: Code[20]; TransactionNo: Integer; CurrencyCode: Code[10]; PurchAmount: Decimal; Amount: Decimal; AmountDtldVendLedgEntry: Decimal; CurrencyFactor: Decimal; DocumentType: Enum "Gen. Journal Document Type")
    begin
        MockVendLedgEntryCustom(EntryNo, PostingDate, VendNo, TransactionNo, CurrencyCode, PurchAmount, Amount, AmountDtldVendLedgEntry, CurrencyFactor, DocumentType);
    end;

    local procedure MockVendLedgEntryCustom(EntryNo: Integer; PostingDate: Date; VendNo: Code[20]; TransactionNo: Integer; CurrencyCode: Code[10]; PurchAmount: Decimal; Amount: Decimal; AmountLCY: Decimal; CurrencyFactor: Decimal; DocumentType: Enum "Gen. Journal Document Type")
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        DetailedVendorLedgEntry: Record "Detailed Vendor Ledg. Entry";
    begin
        VendorLedgerEntry.Init();
        VendorLedgerEntry."Entry No." := EntryNo;
        VendorLedgerEntry."Posting Date" := PostingDate;
        VendorLedgerEntry."Vendor No." := VendNo;
        if not (DocumentType in ["Gen. Journal Document Type"::Payment, "Gen. Journal Document Type"::Refund]) then
            VendorLedgerEntry."Purchase (LCY)" := PurchAmount;
        VendorLedgerEntry."Document Type" := DocumentType;
        VendorLedgerEntry."Transaction No." := TransactionNo;
        VendorLedgerEntry."Currency Code" := CurrencyCode;
        VendorLedgerEntry."Original Currency Factor" := CurrencyFactor;
        VendorLedgerEntry.Insert();
        DetailedVendorLedgEntry.Init();
        DetailedVendorLedgEntry."Entry No." :=
            LibraryUtility.GetNewRecNo(DetailedVendorLedgEntry, DetailedVendorLedgEntry.FieldNo("Entry No."));
        DetailedVendorLedgEntry."Vendor Ledger Entry No." := VendorLedgerEntry."Entry No.";
        DetailedVendorLedgEntry."Posting Date" := VendorLedgerEntry."Posting Date";
        DetailedVendorLedgEntry."Vendor No." := VendorLedgerEntry."Vendor No.";
        DetailedVendorLedgEntry.Amount := Amount;
        DetailedVendorLedgEntry."Ledger Entry Amount" := true;
        DetailedVendorLedgEntry."Amount (LCY)" := AmountLCY;
        DetailedVendorLedgEntry.Insert();
    end;

    procedure MockBankLedgEntry(EntryNo: Integer; PostingDate: Date; BankAccNo: Code[20]; TransactionNo: Integer; CurrencyCode: Code[10]; Amount: Decimal; AmountLCY: Decimal; DocumentType: Enum "Gen. Journal Document Type")
    var
        BankAccLedgerEntry: Record "Bank Account Ledger Entry";
    begin
        BankAccLedgerEntry.Init();
        BankAccLedgerEntry."Entry No." := EntryNo;
        BankAccLedgerEntry."Posting Date" := PostingDate;
        BankAccLedgerEntry."Bank Account No." := BankAccNo;
        BankAccLedgerEntry."Document Type" := DocumentType;
        BankAccLedgerEntry."Transaction No." := TransactionNo;
        BankAccLedgerEntry."Currency Code" := CurrencyCode;
        BankAccLedgerEntry.Amount := Amount;
        BankAccLedgerEntry."Amount (LCY)" := AmountLCY;
        BankAccLedgerEntry.Insert();
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
        CompanyInformation."Registration No." := LibraryUtility.GenerateGUID();
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
        VATReportingCode: Record "VAT Reporting Code";
    begin
        VATPostingSetup.FindSet();
        VATPostingSetup.Next(); // do not specify any value for Standard Tax Code in order to verify that NA value will be exported in the XML file
        VATReportingCode.FindSet();
        repeat
            VATPostingSetup.Validate("Sale VAT Reporting Code", VATReportingCode.Code);
            VATPostingSetup.Validate("Purch. VAT Reporting Code", VATReportingCode.Code);
            VATPostingSetup.Validate("Calc. Prop. Deduction VAT", false);
            VATPostingSetup.Modify(true);
            VATReportingCode.Next();
        until VATPostingSetup.Next() = 0;
        VATReportingCode.ModifyAll(Compensation, false);
    end;

    local procedure SetupCompanyBankAccounts()
    var
        CompanyInformation: Record "Company Information";
        BankAccount: Record "Bank Account";
    begin
        CompanyInformation.Get();
        CompanyInformation.IBAN := LibraryUtility.GenerateGUID();
        CompanyInformation."Bank Account No." := LibraryUtility.GenerateGUID();
        CompanyInformation.Modify();
        BankAccount.DeleteAll();
        LibraryERM.CreateBankAccount(BankAccount);
        BankAccount.IBAN := LibraryUtility.GenerateGUID();
        BankAccount."Bank Clearing Code" := LibraryUtility.GenerateGUID();
        BankAccount."SWIFT Code" := LibraryUtility.GenerateGUID();
        BankAccount.Validate("Bank Account No.", LibraryUtility.GenerateGUID());
        BankAccount."Bank Acc. Posting Group" := '';
        BankAccount.Modify(true);
    end;

    local procedure SetupGLAccounts(var TempGLAccount: Record "G/L Account" temporary; IncomeBalance: Integer; NumberOfMasterDataRecords: Integer)
    var
        GLAccount: Record "G/L Account";
        i: integer;
    begin
        for i := 1 to NumberOfMasterDataRecords do begin
            LibraryERM.CreateGLAccount(GLAccount);
            GLAccount.Validate("Account Type", GLAccount."Account Type"::Posting);
            GLAccount.Validate("Account Category", GetCategoryByIncomeBalance(IncomeBalance));
            GLAccount.Validate("Income/Balance", IncomeBalance);
            GLAccount.Validate("Direct Posting", true);
            GLAccount.Modify(true);
            TempGLAccount := GLAccount;
            TempGLAccount.Insert();
        end;
    end;

    local procedure RemoveGLAccData()
    var
        GLAccount: Record "G/L Account";
        SAFTGLAccountMapping: Record "SAF-T G/L Account Mapping";
    begin
        GLAccount.DeleteAll();
        SAFTGLAccountMapping.DeleteAll();
    end;

    local procedure GetCategoryByIncomeBalance(IncomeBalance: Integer): Integer
    var
        GLAccount: Record "G/L Account";
    begin
        case IncomeBalance of
            GLAccount."Income/Balance"::"Income Statement":
                exit(GLAccount."Account Category"::Income);
            GLAccount."Income/Balance"::"Balance Sheet":
                exit(GLAccount."Account Category"::Liabilities);
        end;
    end;

    local procedure SetupCustomers(var TempGLAccount: Record "G/L Account" temporary; NumberOfMasterDataRecords: Integer)
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
        for i := 1 to NumberOfMasterDataRecords do begin
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
            CustomerBankAccount.Name := LibraryUtility.GenerateGUID();
            CustomerBankAccount."Bank Account No." := LibraryUtility.GenerateGUID();
            CustomerBankAccount."Bank Clearing Code" := LibraryUtility.GenerateGUID();
            CustomerBankAccount."SWIFT Code" := LibraryUtility.GenerateGUID();
            CustomerBankAccount.Modify(true);
            for j := 1 to LibraryRandom.RandInt(3) do
                CreateDefaultDimensions(Database::Customer, Customer."No.");
        end;
    end;

    local procedure SetupVendors(var TempGLAccount: Record "G/L Account" temporary; NumberOfMasterDataRecords: Integer)
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
        for i := 1 to NumberOfMasterDataRecords do begin
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
            VendorBankAccount.Name := LibraryUtility.GenerateGUID();
            VendorBankAccount."Bank Account No." := LibraryUtility.GenerateGUID();
            VendorBankAccount."Bank Clearing Code" := LibraryUtility.GenerateGUID();
            VendorBankAccount."SWIFT Code" := LibraryUtility.GenerateGUID();
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
                DimensionValue.Name := '<&';
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

    local procedure CreatePaymentTerms(): Code[10]
    var
        PaymentTerms: Record "Payment Terms";
    begin
        LibraryERM.CreatePaymentTermsDiscount(PaymentTerms, false);
        exit(PaymentTerms.Code)
    end;

    procedure LoadXMLBufferFromSAFTExportLine(var TempXMLBuffer: Record "XML Buffer" temporary; SAFTExportLine: Record "SAF-T Export Line")
    var
        Stream: InStream;
    begin
        SAFTExportLine.CalcFields("SAF-T File");
        SAFTExportLine."SAF-T File".CreateInStream(Stream);
        TempXMLBuffer.Reset();
        TempXMLBuffer.DeleteAll();
        TempXMLBuffer.LoadFromStream(Stream);
    end;

    procedure FindSAFTHeaderElement(var TempXMLBuffer: Record "XML Buffer" temporary)
    begin
        TempXMLBuffer.FindNodesByXPath(TempXMLBuffer, '/n1:AuditFile/n1:Header');
    end;

    procedure FindSAFTExportLine(var SAFTExportLine: Record "SAF-T Export Line"; ExportID: Integer)
    begin
        SAFTExportLine.SetRange(ID, ExportID);
        SAFTExportLine.FindSet();
    end;

    procedure AssertElementValue(var TempXMLBuffer: Record "XML Buffer" temporary; ElementName: Text; ElementValue: Text)
    begin
        FindNextElement(TempXMLBuffer);
        AssertCurrentElementValue(TempXMLBuffer, ElementName, ElementValue);
    end;

    procedure AssertElementName(var TempXMLBuffer: Record "XML Buffer" temporary; ElementName: Text)
    begin
        FindNextElement(TempXMLBuffer);
        AssertCurrentElementName(TempXMLBuffer, ElementName);
    end;

    procedure AssertCurrentElementName(var TempXMLBuffer: Record "XML Buffer" temporary; ElementName: Text)
    begin
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

    procedure FilterChildElementsByName(var TempResultElementXMLBuffer: Record "XML Buffer" temporary; var TempXMLBuffer: Record "XML Buffer" temporary; Name: Text[250])
    begin
        TempXMLBuffer.FindChildElements(TempResultElementXMLBuffer);
        TempResultElementXMLBuffer.SETRANGE(Name, Name);
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
