codeunit 148103 "SAF-T XML Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [SAF-T] [XML]
    end;

    var
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        LibraryRandom: Codeunit "Library - Random";
        LibraryUtility: Codeunit "Library - Utility";
        SAFTTestHelper: Codeunit "SAF-T Test Helper";
        Assert: Codeunit Assert;
        SAFTMappingType: Enum "SAF-T Mapping Type";
        IsInitialized: Boolean;
        GenerateSAFTFileImmediatelyQst: Label 'Since you did not schedule the SAF-T file generation, it will be generated immediately which can take a while. Do you want to continue?';

    [Test]
    [HandlerFunctions('ConfirmYesHandler')]
    procedure MasterFile()
    var
        SAFTExportHeader: Record "SAF-T Export Header";
        SAFTExportLine: Record "SAF-T Export Line";
        SAFTMappingRange: Record "SAF-T Mapping Range";
        TempXMLBuffer: Record "XML Buffer" temporary;
        NumberOfMasterDataRecords: Integer;
    begin
        // [SCENARIO 309923] The first XML file generates by SAF-T Export functionality has master data

        Initialize();
        NumberOfMasterDataRecords := LibraryRandom.RandInt(5);
        SetupSAFT(SAFTMappingRange, SAFTMappingType::"Four Digit Standard Account", NumberOfMasterDataRecords);
        SAFTTestHelper.PostRandomAmountForNumberOfMasterDataRecords(SAFTMappingRange."Ending Date", NumberOfMasterDataRecords);
        MatchGLAccountsFourDigit(SAFTMappingRange.Code);
        SAFTTestHelper.CreateSAFTExportHeader(SAFTExportHeader, SAFTMappingRange.Code);
        LibraryVariableStorage.Enqueue(GenerateSAFTFileImmediatelyQst);
        SAFTTestHelper.RunSAFTExport(SAFTExportHeader);
        SAFTExportLine.SetRange(Status, SAFTExportLine.Status::Completed);
        FindSAFTExportLine(SAFTExportLine, SAFTExportHeader.ID);
        Assert.RecordCount(SAFTExportLine, 2);
        SAFTExportLine.TestField("Master Data", true);
        SAFTExportHeader.Find();
        SAFTExportHeader.TestField(Status, SAFTExportHeader.Status::Completed);
        SAFTExportHeader.TestField("Execution Start Date/Time");
        SAFTExportHeader.TestField("Execution End Date/Time");

        LoadXMLBufferFromSAFTExportLine(TempXMLBuffer, SAFTExportLine);
        VerifyHeaderStructure(TempXMLBuffer, SAFTExportLine);
        VerifyMasterDataStructureWithStdAccMapping(TempXMLBuffer, SAFTExportHeader."Mapping Range Code", NumberOfMasterDataRecords);
        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('ConfirmYesHandler')]
    procedure OpeningDebitBalanceOnMasterData()
    var
        GLAccount: Record "G/L Account";
        SAFTExportHeader: Record "SAF-T Export Header";
        SAFTExportLine: Record "SAF-T Export Line";
        SAFTMappingRange: Record "SAF-T Mapping Range";
        TempXMLBuffer: Record "XML Buffer" temporary;
        BalanceAmount: Decimal;
        ClosingAmount: Decimal;
    begin
        // [SCENARIO 309923] The master data information in the first XML file has OpeningDebitBalance

        Initialize();
        SetupSAFT(SAFTMappingRange, SAFTMappingType::"Four Digit Standard Account", LibraryRandom.RandInt(5));
        MatchGLAccountsFourDigit(SAFTMappingRange.Code);
        SAFTTestHelper.CreateSAFTExportHeader(SAFTExportHeader, SAFTMappingRange.Code);
        BalanceAmount := LibraryRandom.RandDec(100, 2);
        ClosingAmount := LibraryRandom.RandDec(100, 2);
        SAFTTestHelper.MockEntriesForFirstRecordOfMasterData(
            GLAccount."Income/Balance"::"Balance Sheet", SAFTExportHeader."Starting Date" - 1,
            BalanceAmount, BalanceAmount, -BalanceAmount);
        SAFTTestHelper.MockEntriesForFirstRecordOfMasterData(
            GLAccount."Income/Balance"::"Balance Sheet", SAFTExportHeader."Starting Date",
            ClosingAmount, ClosingAmount, ClosingAmount);
        LibraryVariableStorage.Enqueue(GenerateSAFTFileImmediatelyQst);
        SAFTTestHelper.RunSAFTExport(SAFTExportHeader);
        FindSAFTExportLine(SAFTExportLine, SAFTExportHeader.ID);
        LoadXMLBufferFromSAFTExportLine(TempXMLBuffer, SAFTExportLine);
        VerifyMasterDataBalance(TempXMLBuffer, 'OpeningDebitBalance', BalanceAmount);
    end;

    [Test]
    [HandlerFunctions('ConfirmYesHandler')]
    procedure OpeningCreditBalanceOnMasterData()
    var
        GLAccount: Record "G/L Account";
        SAFTExportHeader: Record "SAF-T Export Header";
        SAFTExportLine: Record "SAF-T Export Line";
        SAFTMappingRange: Record "SAF-T Mapping Range";
        TempXMLBuffer: Record "XML Buffer" temporary;
        BalanceAmount: Decimal;
        ClosingAmount: Decimal;
    begin
        // [SCENARIO 309923] The master data information in the first XML file has OpeningCreditBalance

        Initialize();
        SetupSAFT(SAFTMappingRange, SAFTMappingType::"Four Digit Standard Account", LibraryRandom.RandInt(5));
        MatchGLAccountsFourDigit(SAFTMappingRange.Code);
        SAFTTestHelper.CreateSAFTExportHeader(SAFTExportHeader, SAFTMappingRange.Code);
        BalanceAmount := LibraryRandom.RandDec(100, 2);
        ClosingAmount := LibraryRandom.RandDec(100, 2);
        SAFTTestHelper.MockEntriesForFirstRecordOfMasterData(
            GLAccount."Income/Balance"::"Balance Sheet", SAFTExportHeader."Starting Date" - 1,
            -BalanceAmount, -BalanceAmount, BalanceAmount);
        SAFTTestHelper.MockEntriesForFirstRecordOfMasterData(
            GLAccount."Income/Balance"::"Balance Sheet", SAFTExportHeader."Starting Date",
            ClosingAmount, ClosingAmount, ClosingAmount);
        LibraryVariableStorage.Enqueue(GenerateSAFTFileImmediatelyQst);
        SAFTTestHelper.RunSAFTExport(SAFTExportHeader);
        FindSAFTExportLine(SAFTExportLine, SAFTExportHeader.ID);
        LoadXMLBufferFromSAFTExportLine(TempXMLBuffer, SAFTExportLine);
        VerifyMasterDataBalance(TempXMLBuffer, 'OpeningCreditBalance', BalanceAmount);
    end;

    [Test]
    [HandlerFunctions('ConfirmYesHandler')]
    procedure ClosingDebitBalanceOnMasterData()
    var
        GLAccount: Record "G/L Account";
        SAFTExportHeader: Record "SAF-T Export Header";
        SAFTExportLine: Record "SAF-T Export Line";
        SAFTMappingRange: Record "SAF-T Mapping Range";
        TempXMLBuffer: Record "XML Buffer" temporary;
        BalanceAmount: Decimal;
    begin
        // [SCENARIO 309923] The master data information in the first XML file has ClosingDebitBalance

        Initialize();
        SetupSAFT(SAFTMappingRange, SAFTMappingType::"Four Digit Standard Account", LibraryRandom.RandInt(5));
        MatchGLAccountsFourDigit(SAFTMappingRange.Code);
        SAFTTestHelper.CreateSAFTExportHeader(SAFTExportHeader, SAFTMappingRange.Code);
        BalanceAmount := LibraryRandom.RandDec(100, 2);
        SAFTTestHelper.MockEntriesForFirstRecordOfMasterData(
            GLAccount."Income/Balance"::"Balance Sheet", SAFTExportHeader."Ending Date",
            BalanceAmount, BalanceAmount, -BalanceAmount);
        LibraryVariableStorage.Enqueue(GenerateSAFTFileImmediatelyQst);
        SAFTTestHelper.RunSAFTExport(SAFTExportHeader);
        FindSAFTExportLine(SAFTExportLine, SAFTExportHeader.ID);
        LoadXMLBufferFromSAFTExportLine(TempXMLBuffer, SAFTExportLine);
        VerifyMasterDataBalance(TempXMLBuffer, 'ClosingDebitBalance', BalanceAmount);
    end;

    [Test]
    [HandlerFunctions('ConfirmYesHandler')]
    procedure ClosingCreditBalanceOnMasterData()
    var
        GLAccount: Record "G/L Account";
        SAFTExportHeader: Record "SAF-T Export Header";
        SAFTExportLine: Record "SAF-T Export Line";
        SAFTMappingRange: Record "SAF-T Mapping Range";
        TempXMLBuffer: Record "XML Buffer" temporary;
        BalanceAmount: Decimal;
    begin
        // [SCENARIO 309923] The master data information in the first XML file has ClosingCreditBalance

        Initialize();
        SetupSAFT(SAFTMappingRange, SAFTMappingType::"Four Digit Standard Account", LibraryRandom.RandInt(5));
        MatchGLAccountsFourDigit(SAFTMappingRange.Code);
        SAFTTestHelper.CreateSAFTExportHeader(SAFTExportHeader, SAFTMappingRange.Code);
        BalanceAmount := LibraryRandom.RandDec(100, 2);
        SAFTTestHelper.MockEntriesForFirstRecordOfMasterData(
            GLAccount."Income/Balance"::"Balance Sheet", SAFTExportHeader."Ending Date",
            -BalanceAmount, -BalanceAmount, BalanceAmount);
        LibraryVariableStorage.Enqueue(GenerateSAFTFileImmediatelyQst);
        SAFTTestHelper.RunSAFTExport(SAFTExportHeader);
        FindSAFTExportLine(SAFTExportLine, SAFTExportHeader.ID);
        LoadXMLBufferFromSAFTExportLine(TempXMLBuffer, SAFTExportLine);
        VerifyMasterDataBalance(TempXMLBuffer, 'ClosingCreditBalance', BalanceAmount);
    end;

    [Test]
    [HandlerFunctions('ConfirmYesHandler')]
    procedure GeneralLedgerEntryFile()
    var
        GLAccount: Record "G/L Account";
        SAFTExportHeader: Record "SAF-T Export Header";
        SAFTExportLine: Record "SAF-T Export Line";
        SAFTMappingRange: Record "SAF-T Mapping Range";
        TempXMLBuffer: Record "XML Buffer" temporary;
        TempSAFTSourceCode: Record "SAF-T Source Code" temporary;
        SAFTSourceCode: Record "SAF-T Source Code";
        SourceCode: Record "Source Code";
        VATEntry: Record "VAT Entry";
        SAFTAnalysisType: Code[9];
        DimValueCode: Code[20];
        DimSetID: Integer;
        JournalsNumber: Integer;
        EntriesInTransactionNumber: Integer;
        i: Integer;
        j: Integer;
    begin
        // [SCENARIO 309923] The structure of the XML file with General Ledger Entries is correct
        // [SCENARIO 331600] "NumberOfEntries" contains the number of transactions
        // [SCENARIO 334997] "ReferenceNumber" xml node exports after "TaxInformation" section

        Initialize();
        SetupSAFT(SAFTMappingRange, SAFTMappingType::"Four Digit Standard Account", LibraryRandom.RandInt(5));
        MatchGLAccountsFourDigit(SAFTMappingRange.Code);
        SAFTTestHelper.CreateSAFTExportHeader(SAFTExportHeader, SAFTMappingRange.Code);
        EntriesInTransactionNumber := LibraryRandom.RandInt(5);
        JournalsNumber := LibraryRandom.RandInt(5);
        GLAccount.SetRange("Income/Balance", GLAccount."Income/Balance"::"Balance Sheet");
        GLAccount.FindFirst();
        SAFTTestHelper.SetDimensionForGLAccount(GLAccount."No.", SAFTAnalysisType, DimValueCode, DimSetID);
        SAFTSourceCode.FindSet();
        for i := 1 to JournalsNumber do begin
            SourceCode.SetRange("SAF-T Source Code", SAFTSourceCode.Code);
            SourceCode.FindFirst();
            for j := 1 to EntriesInTransactionNumber do begin
                SAFTTestHelper.MockVATEntry(VATEntry, SAFTExportHeader."Ending Date", VATEntry.Type::Sale, i);
                SAFTTestHelper.MockGLEntry(
                    SAFTExportHeader."Ending Date", VATEntry."Document No.", GLAccount."No.",
                    VATEntry."Transaction No.", DimSetID, VATEntry."VAT Bus. Posting Group",
                    VATEntry."VAT Prod. Posting Group", 0, '', SourceCode.Code, LibraryRandom.RandDec(100, 2), 0);
            end;
            TempSAFTSourceCode := SAFTSourceCode;
            TempSAFTSourceCode.Insert();
            SAFTSourceCode.Next();
        end;
        LibraryVariableStorage.Enqueue(GenerateSAFTFileImmediatelyQst);
        SAFTTestHelper.RunSAFTExport(SAFTExportHeader);
        SAFTExportLine.SetRange(Status, SAFTExportLine.Status::Completed);
        FindSAFTExportLine(SAFTExportLine, SAFTExportHeader.ID);
        Assert.RecordCount(SAFTExportLine, 2);
        SAFTExportLine.Next();
        SAFTExportLine.TestField("Master Data", false);
        LoadXMLBufferFromSAFTExportLine(TempXMLBuffer, SAFTExportLine);
        VerifyXMLFileHasHeader(TempXMLBuffer);
        VerifyGLEntriesGroupedBySAFTSourceCode(
            TempXMLBuffer, TempSAFTSourceCode, EntriesInTransactionNumber, SAFTExportLine."Starting Date", SAFTExportLine."Ending Date",
            SAFTAnalysisType, DimValueCode);
    end;

    [Test]
    [HandlerFunctions('ConfirmYesHandler')]
    procedure CustomerIDExportsOncePerLine()
    var
        SAFTMappingRange: Record "SAF-T Mapping Range";
        SAFTExportHeader: Record "SAF-T Export Header";
        SAFTExportLine: Record "SAF-T Export Line";
        TempXMLBuffer: Record "XML Buffer" temporary;
        GLAccount: Record "G/L Account";
        Customer: Record Customer;
        GLEntry: Record "G/L Entry";
        DocNo: Code[20];
    begin
        // [SCENARIO 331600] "CustomerID" xml node exports only once per document

        Initialize();

        SetupSAFT(SAFTMappingRange, SAFTMappingType::"Four Digit Standard Account", LibraryRandom.RandInt(5));
        MatchGLAccountsFourDigit(SAFTMappingRange.Code);
        SAFTTestHelper.CreateSAFTExportHeader(SAFTExportHeader, SAFTMappingRange.Code);

        DocNo := LibraryUtility.GenerateGUID();
        GLAccount.SetRange("Income/Balance", GLAccount."Income/Balance"::"Balance Sheet");
        GLAccount.FindFirst();
        Customer.FindFirst();
        SAFTTestHelper.IncludesNoSourceCodeToTheFirstSAFTSourceCode();

        // [GIVEN] Two G/L Entries with the same document/transaction, one  with "Gen. Posting Type" = Sales, one with blank value
        SAFTTestHelper.MockGLEntry(
            SAFTExportHeader."Ending Date", DocNo, GLAccount."No.",
            1, 0, GLEntry."Gen. Posting Type"::Sale, '',
            '', GLEntry."Source Type"::Customer, Customer."No.", '', LibraryRandom.RandDec(100, 2), 0);
        SAFTTestHelper.MockGLEntry(
            SAFTExportHeader."Ending Date", DocNo, GLAccount."No.",
            1, 0, 0, '',
            '', GLEntry."Source Type"::Customer, Customer."No.", '', LibraryRandom.RandDec(100, 2), 0);

        // [WHEN] Export G/L Entries to the XML file
        LibraryVariableStorage.Enqueue(GenerateSAFTFileImmediatelyQst);
        SAFTTestHelper.RunSAFTExport(SAFTExportHeader);
        SAFTExportLine.SetRange("Master Data", false);
        FindSAFTExportLine(SAFTExportLine, SAFTExportHeader.ID);
        LoadXMLBufferFromSAFTExportLine(TempXMLBuffer, SAFTExportLine);

        // [THEN] CustomerID xml node exists just once in the XML file
        Assert.IsTrue(
            TempXMLBuffer.FindNodesByXPath(TempXMLBuffer,
                '/nl:AuditFile/nl:GeneralLedgerEntries/nl:Journal/nl:Transaction/nl:Line/nl:CustomerID'),
                'No G/L entries with CustomerID exported.');
        Assert.RecordCount(TempXMLBuffer, 1);
    end;

    [Test]
    [HandlerFunctions('ConfirmYesHandler')]
    procedure SupplierIDExportsOncePerLine()
    var
        SAFTMappingRange: Record "SAF-T Mapping Range";
        SAFTExportHeader: Record "SAF-T Export Header";
        SAFTExportLine: Record "SAF-T Export Line";
        TempXMLBuffer: Record "XML Buffer" temporary;
        GLAccount: Record "G/L Account";
        Vendor: Record Customer;
        GLEntry: Record "G/L Entry";
        DocNo: Code[20];
    begin
        // [SCENARIO 331600] "SupplierID" xml node exports only once per document

        Initialize();

        SetupSAFT(SAFTMappingRange, SAFTMappingType::"Four Digit Standard Account", LibraryRandom.RandInt(5));
        MatchGLAccountsFourDigit(SAFTMappingRange.Code);
        SAFTTestHelper.CreateSAFTExportHeader(SAFTExportHeader, SAFTMappingRange.Code);

        DocNo := LibraryUtility.GenerateGUID();
        GLAccount.SetRange("Income/Balance", GLAccount."Income/Balance"::"Balance Sheet");
        GLAccount.FindFirst();
        Vendor.FindFirst();
        SAFTTestHelper.IncludesNoSourceCodeToTheFirstSAFTSourceCode();

        // [GIVEN] Two G/L Entries with the same document/transaction, one  with "Gen. Posting Type" = Sales, one with blank value
        SAFTTestHelper.MockGLEntry(
            SAFTExportHeader."Ending Date", DocNo, GLAccount."No.",
            1, 0, GLEntry."Gen. Posting Type"::Sale, '',
            '', GLEntry."Source Type"::Vendor, Vendor."No.", '', LibraryRandom.RandDec(100, 2), 0);
        SAFTTestHelper.MockGLEntry(
            SAFTExportHeader."Ending Date", DocNo, GLAccount."No.",
            1, 0, 0, '',
            '', GLEntry."Source Type"::Vendor, Vendor."No.", '', LibraryRandom.RandDec(100, 2), 0);

        // [WHEN] Export G/L Entries to the XML file
        LibraryVariableStorage.Enqueue(GenerateSAFTFileImmediatelyQst);
        SAFTTestHelper.RunSAFTExport(SAFTExportHeader);
        SAFTExportLine.SetRange("Master Data", false);
        FindSAFTExportLine(SAFTExportLine, SAFTExportHeader.ID);
        LoadXMLBufferFromSAFTExportLine(TempXMLBuffer, SAFTExportLine);

        // [THEN] SupplierID xml node exists just once in the XML file
        Assert.IsTrue(
            TempXMLBuffer.FindNodesByXPath(TempXMLBuffer,
                '/nl:AuditFile/nl:GeneralLedgerEntries/nl:Journal/nl:Transaction/nl:Line/nl:SupplierID'),
                'No G/L entries with CustomerID exported.');
        Assert.RecordCount(TempXMLBuffer, 1);
    end;

    local procedure Initialize()
    begin
        LibraryTestInitialize.OnTestInitialize(CODEUNIT::"SAF-T XML Tests");
        if IsInitialized then
            exit;

        LibraryTestInitialize.OnBeforeTestSuiteInitialize(CODEUNIT::"SAF-T XML Tests");

        IsInitialized := true;
        LibraryTestInitialize.OnAfterTestSuiteInitialize(CODEUNIT::"SAF-T XML Tests");
    end;

    local procedure SetupSAFT(var SAFTMappingRange: Record "SAF-T Mapping Range"; MappingType: Enum "SAF-T Mapping Type"; NumberOfMasterDataRecords: Integer): Code[20]
    var
        SAFTMappingHelper: Codeunit "SAF-T Mapping Helper";
    begin
        SAFTTestHelper.SetupMasterData(NumberOfMasterDataRecords);
        SAFTTestHelper.InsertSAFTMappingRangeFullySetup(
            SAFTMappingRange, MappingType, GetWorkDateInYearWithNoGLEntries(),
            CalcDate('<CY>', GetWorkDateInYearWithNoGLEntries()));
        SAFTMappingHelper.MapRestSourceCodesToAssortedJournals();
        exit(SAFTMappingRange.Code);
    end;

    local procedure MatchGLAccountsFourDigit(MappingRangeCode: Code[20])
    var
        SAFTMapping: Record "SAF-T Mapping";
        SAFTGLAccountMapping: Record "SAF-T G/L Account Mapping";
    begin
        SAFTGLAccountMapping.SetRange("Mapping Range Code", MappingRangeCode);
        SAFTGLAccountMapping.FindSet();
        SAFTMapping.FindSet();
        repeat
            SAFTGLAccountMapping.Validate("Category No.", SAFTMapping."Category No.");
            SAFTGLAccountMapping.Validate("No.", SAFTMapping."No.");
            SAFTGLAccountMapping.Modify(true);
            SAFTMapping.Next();
        until SAFTGLAccountMapping.Next() = 0;
    end;

    local procedure GetWorkDateInYearWithNoGLEntries(): Date
    var
        GLEntry: Record "G/L Entry";
    begin
        GLEntry.SetCurrentKey("Posting Date");
        GLEntry.FindLast();
        exit(CalcDate('<CY+1D>', GLEntry."Posting Date"));
    end;

    local procedure CalcNumberOfTransactions(var GLEntry: Record "G/L Entry") NumberOfTransactions: Integer
    begin
        GLEntry.SetCurrentKey("Transaction No.");
        GLEntry.FindSet();
        repeat
            GLEntry.SetRange("Transaction No.", GLEntry."Transaction No.");
            GLEntry.FindLast();
            NumberOfTransactions += 1;
            GLEntry.SetRange("Transaction No.");
        until GLEntry.Next() = 0;
    end;

    local procedure FindSAFTExportLine(var SAFTExportLine: Record "SAF-T Export Line"; ExportID: Integer)
    begin
        SAFTExportLine.SetRange(ID, ExportID);
        SAFTExportLine.FindSet();
    end;

    local procedure FindGLEntryWithGenPostingType(var GLEntry: Record "G/L Entry"; DocType: Integer; PostingDate: Date; DocNo: Code[20])
    begin
        GLEntry.SetRange("Document Type", DocType);
        GLEntry.SetRange("Posting Date", PostingDate);
        GLEntry.SetRange("Document No.", DocNo);
        GLEntry.SetFilter("Gen. Posting Type", '<>%1', 0);
        GLEntry.FindFirst();
    end;

    local procedure LoadXMLBufferFromSAFTExportLine(var TempXMLBuffer: Record "XML Buffer" temporary; SAFTExportLine: Record "SAF-T Export Line")
    var
        Stream: InStream;
    begin
        SAFTExportLine.CalcFields("SAF-T File");
        SAFTExportLine."SAF-T File".CreateInStream(Stream);
        TempXMLBuffer.Reset();
        TempXMLBuffer.DeleteAll();
        TempXMLBuffer.LoadFromStream(Stream);
    end;

    local procedure VerifyHeaderStructure(var TempXMLBuffer: Record "XML Buffer" temporary; SAFTExportLine: Record "SAF-T Export Line")
    var
        CompanyInformation: Record "Company Information";
        GeneralLedgerSetup: Record "General Ledger Setup";
        SAFTExportHeader: Record "SAF-T Export Header";

    begin
        SAFTTestHelper.FindSAFTHeaderElement(TempXMLBuffer);
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'nl:AuditFileVersion', '1.0');
        CompanyInformation.Get();
        GeneralLedgerSetup.Get();
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'nl:AuditFileCountry', CompanyInformation."Country/Region Code");
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'nl:AuditFileDateCreated', SAFTTestHelper.FormatDate(Today()));
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'nl:SoftwareCompanyName', 'Microsoft');
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'nl:SoftwareID', 'Microsoft Dynamics 365 Business Central');
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'nl:SoftwareVersion', '14.0');
        SAFTTestHelper.AssertElementName(TempXMLBuffer, 'nl:Company');
        VerifyCompanyStructure(TempXMLBuffer, CompanyInformation);
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'nl:DefaultCurrencyCode', GeneralLedgerSetup."LCY Code");
        SAFTExportHeader.Get(SAFTExportLine.ID);
        SAFTTestHelper.AssertElementName(TempXMLBuffer, 'nl:SelectionCriteria');
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'nl:PeriodStart', format(Date2DMY(SAFTExportHeader."Starting Date", 2)));
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'nl:PeriodStartYear', format(Date2DMY(SAFTExportHeader."Starting Date", 3)));
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'nl:PeriodEnd', format(Date2DMY(SAFTExportHeader."Ending Date", 2)));
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'nl:PeriodEndYear', format(Date2DMY(SAFTExportHeader."Ending Date", 3)));
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'nl:TaxAccountingBasis', 'A');
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'nl:UserID', UserId());
    end;

    local procedure VerifyMasterDataStructureWithStdAccMapping(var TempXMLBuffer: Record "XML Buffer" temporary; MappingRangeCode: Code[20]; NumberOfMasterDataRecords: Integer)
    begin
        VerifyGeneralLedgerAccountsWithStdAccMapping(TempXMLBuffer, MappingRangeCode, NumberOfMasterDataRecords);
        VerifyCustomers(TempXMLBuffer, MappingRangeCode, NumberOfMasterDataRecords);
        VerifyVendors(TempXMLBuffer, MappingRangeCode, NumberOfMasterDataRecords);
        VerifyVATPostingSetup(TempXMLBuffer);
        VerifyDimensions(TempXMLBuffer);
    end;

    local procedure VerifyMasterDataBalance(var TempXMLBuffer: Record "XML Buffer" temporary; BalanceXMLNodeName: Text; ExpectedAmount: Decimal)
    var
        AmountText: Text;
    begin
        AmountText := SAFTTestHelper.FormatAmount(ExpectedAmount);
        SAFTTestHelper.AssertCurrentValue(
            TempXMLBuffer, StrSubstNo('/nl:AuditFile/nl:MasterFiles/nl:GeneralLedgerAccounts/nl:Account/nl:%1', BalanceXMLNodeName), AmountText);
        SAFTTestHelper.AssertCurrentValue(
            TempXMLBuffer, StrSubstNo('/nl:AuditFile/nl:MasterFiles/nl:Customers/nl:Customer/nl:%1', BalanceXMLNodeName), AmountText);
        SAFTTestHelper.AssertCurrentValue(
            TempXMLBuffer, StrSubstNo('/nl:AuditFile/nl:MasterFiles/nl:Suppliers/nl:Supplier/nl:%1', BalanceXMLNodeName), AmountText);
    end;

    local procedure VerifyGeneralLedgerAccountsWithStdAccMapping(var TempXMLBuffer: Record "XML Buffer" temporary; MappingRangeCode: Code[20]; NumberOfMasterDataRecords: Integer)
    var
        GLAccount: Record "G/L Account";
        SAFTGLAccountMapping: Record "SAF-T G/L Account Mapping";
        SAFTMappingRange: Record "SAF-T Mapping Range";
        i: Integer;
    begin
        SAFTTestHelper.AssertElementName(TempXMLBuffer, 'nl:MasterFiles');
        SAFTTestHelper.AssertElementName(TempXMLBuffer, 'nl:GeneralLedgerAccounts');
        GLAccount.SetRange("Income/Balance", GLAccount."Income/Balance"::"Balance Sheet");
        GLAccount.FindSet();
        SAFTMappingRange.Get(MappingRangeCode);
        for i := 1 to NumberOfMasterDataRecords do begin
            SAFTTestHelper.AssertElementName(TempXMLBuffer, 'nl:Account');
            SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'nl:AccountID', GLAccount."No.");
            SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'nl:AccountDescription', GLAccount.Name);
            SAFTGLAccountMapping.Get(MappingRangeCode, GLAccount."No.");
            SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'nl:StandardAccountID', SAFTGLAccountMapping."No.");
            SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'nl:AccountType', 'GL');
            GLAccount.SetRange("Date Filter", 0D, ClosingDate(SAFTMappingRange."Starting Date" - 1));
            GLAccount.CalcFields("Net Change");
            SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'nl:OpeningCreditBalance', SAFTTestHelper.FormatAmount(-GLAccount."Net Change"));
            GLAccount.SetRange("Date Filter", 0D, ClosingDate(SAFTMappingRange."Ending Date"));
            GLAccount.CalcFields("Net Change");
            SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'nl:ClosingDebitBalance', SAFTTestHelper.FormatAmount(GLAccount."Net Change"));
            GLAccount.Next();
        end;
    end;

    local procedure VerifyCustomers(var TempXMLBuffer: Record "XML Buffer" temporary; MappingRangeCode: Code[20]; NumberOfMasterDataRecords: Integer)
    var
        Customer: Record Customer;
        CustomerPostingGroup: Record "Customer Posting Group";
        CustomerBankAccount: Record "Customer Bank Account";
        SAFTMappingRange: Record "SAF-T Mapping Range";
        i: Integer;
    begin
        Customer.FindSet();
        SAFTMappingRange.Get(MappingRangeCode);
        SAFTTestHelper.AssertElementName(TempXMLBuffer, 'nl:Customers');
        for i := 1 to NumberOfMasterDataRecords do begin
            SAFTTestHelper.AssertElementName(TempXMLBuffer, 'nl:Customer');
            SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'nl:RegistrationNumber', Customer."VAT Registration No.");
            SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'nl:Name', SAFTTestHelper.CombineWithSpace(Customer.Name, Customer."Name 2"));
            VerifyAddress(
                TempXMLBuffer, SAFTTestHelper.CombineWithSpace(Customer.Address, Customer."Address 2"),
                Customer.City, Customer."Post Code", Customer."Country/Region Code");
            VerifyContactSimple(
                TempXMLBuffer, Customer.Contact, Customer."Phone No.", Customer."Fax No.", Customer."E-Mail", Customer."Home Page");
            CustomerBankAccount.SetRange("Customer No.", Customer."No.");
            CustomerBankAccount.FindFirst();
            VerifyCompanyBankAccount(TempXMLBuffer, CustomerBankAccount."Bank Account No.");
            SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'nl:CustomerID', Customer."No.");
            CustomerPostingGroup.Get(Customer."Customer Posting Group");
            SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'nl:AccountID', CustomerPostingGroup."Receivables Account");
            Customer.SetRange("Date Filter", 0D, closingdate(SAFTMappingRange."Starting Date" - 1));
            Customer.CalcFields("Net Change (LCY)");
            SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'nl:OpeningCreditBalance', SAFTTestHelper.FormatAmount(Customer."Net Change (LCY)"));
            Customer.SetRange("Date Filter", 0D, closingdate(SAFTMappingRange."Ending Date"));
            Customer.CalcFields("Net Change (LCY)");
            SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'nl:ClosingDebitBalance', SAFTTestHelper.FormatAmount(Customer."Net Change (LCY)"));
            VerifyPartyInfo(TempXMLBuffer, Customer."Payment Terms Code", database::Customer, Customer."No.");
            Customer.Next();
        end;
    end;

    local procedure VerifyVendors(var TempXMLBuffer: Record "XML Buffer" temporary; MappingRangeCode: Code[20]; NumberOfMasterDataRecords: Integer)
    var
        Vendor: Record Vendor;
        VendorPostingGroup: Record "Vendor Posting Group";
        VendorBankAccount: Record "Vendor Bank Account";
        SAFTMappingRange: Record "SAF-T Mapping Range";
        i: Integer;
    begin
        Vendor.FindSet();
        SAFTMappingRange.Get(MappingRangeCode);
        SAFTTestHelper.AssertElementName(TempXMLBuffer, 'nl:Suppliers');
        for i := 1 to NumberOfMasterDataRecords do begin
            SAFTTestHelper.AssertElementName(TempXMLBuffer, 'nl:Supplier');
            SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'nl:RegistrationNumber', Vendor."VAT Registration No.");
            SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'nl:Name', SAFTTestHelper.CombineWithSpace(Vendor.Name, Vendor."Name 2"));
            VerifyAddress(
                TempXMLBuffer, SAFTTestHelper.CombineWithSpace(Vendor.Address, Vendor."Address 2"),
                Vendor.City, Vendor."Post Code", Vendor."Country/Region Code");
            VerifyContactSimple(
                TempXMLBuffer, Vendor.Contact, Vendor."Phone No.", Vendor."Fax No.", Vendor."E-Mail", Vendor."Home Page");
            VendorBankAccount.SetRange("Vendor No.", Vendor."No.");
            VendorBankAccount.FindFirst();
            VerifyCompanyBankAccount(TempXMLBuffer, VendorBankAccount."Bank Account No.");
            SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'nl:SupplierID', Vendor."No.");
            VendorPostingGroup.Get(Vendor."Vendor Posting Group");
            SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'nl:AccountID', VendorPostingGroup."Payables Account");
            Vendor.SetRange("Date Filter", 0D, closingdate(SAFTMappingRange."Starting Date" - 1));
            Vendor.CalcFields("Net Change (LCY)");
            SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'nl:OpeningCreditBalance', SAFTTestHelper.FormatAmount(Vendor."Net Change (LCY)"));
            Vendor.SetRange("Date Filter", 0D, closingdate(SAFTMappingRange."Ending Date"));
            Vendor.CalcFields("Net Change (LCY)");
            SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'nl:ClosingDebitBalance', SAFTTestHelper.FormatAmount(Vendor."Net Change (LCY)"));
            VerifyPartyInfo(TempXMLBuffer, Vendor."Payment Terms Code", database::Vendor, Vendor."No.");
            Vendor.Next();
        end;
    end;

    local procedure VerifyVATPostingSetup(var TempXMLBuffer: Record "XML Buffer" temporary)
    var
        VATPostingSetup: Record "VAT Posting Setup";
        SAFTExportMgt: Codeunit "SAF-T Export Mgt.";
        NotApplicationVATCode: Code[10];
    begin
        VATPostingSetup.FindSet();
        SAFTTestHelper.AssertElementName(TempXMLBuffer, 'nl:TaxTable');
        SAFTTestHelper.AssertElementName(TempXMLBuffer, 'nl:TaxTableEntry');
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'nl:TaxType', 'MVA');
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'nl:Description', 'Merverdiavgift');
        NotApplicationVATCode := SAFTExportMgt.GetNotApplicationVATCode();
        // Verify first VAT Posting Setup with no standard tax codes
        VerifySingleVATPostingSetup(
            TempXMLBuffer, VATPostingSetup."Sales SAF-T Tax Code", VATPostingSetup.Description,
            VATPostingSetup."VAT %", NotApplicationVATCode, false, 100);
        VerifySingleVATPostingSetup(
            TempXMLBuffer, VATPostingSetup."Purchase SAF-T Tax Code", VATPostingSetup.Description,
            VATPostingSetup."VAT %", NotApplicationVATCode, false, 100);
        VATPostingSetup.Next();
        repeat
            VerifySingleVATPostingSetup(
                TempXMLBuffer, VATPostingSetup."Sales SAF-T Tax Code", VATPostingSetup.Description,
                VATPostingSetup."VAT %", VATPostingSetup."Sales SAF-T Standard Tax Code", false, 100);
            VerifySingleVATPostingSetup(
                TempXMLBuffer, VATPostingSetup."Purchase SAF-T Tax Code", VATPostingSetup.Description,
                VATPostingSetup."VAT %", VATPostingSetup."Purch. SAF-T Standard Tax Code", false, 100);
        until VATPostingSetup.Next() = 0;
    end;

    local procedure VerifyDimensions(var TempXMLBuffer: Record "XML Buffer" temporary)
    var
        Dimension: Record Dimension;
        DimensionValue: Record "Dimension Value";
    begin
        DimensionValue.FindSet();
        SAFTTestHelper.AssertElementName(TempXMLBuffer, 'nl:AnalysisTypeTable');
        repeat
            SAFTTestHelper.AssertElementName(TempXMLBuffer, 'nl:AnalysisTypeTableEntry');
            Dimension.Get(DimensionValue."Dimension Code");
            SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'nl:AnalysisType', Dimension."SAF-T Analysis Type");
            SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'nl:AnalysisTypeDescription', Dimension.Name);
            SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'nl:AnalysisID', DimensionValue.Code);
            SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'nl:AnalysisIDDescription', DimensionValue.Name);
        until DimensionValue.Next() = 0;
    end;

    local procedure VerifySingleVATPostingSetup(var TempXMLBuffer: Record "XML Buffer" temporary; TaxCode: Integer; Description: Text; VATRate: Decimal; StandardTaxCode: Code[10]; Compensation: Boolean; DeductionRate: Decimal)
    var
        CompanyInformation: record "Company Information";
    begin
        CompanyInformation.Get();
        SAFTTestHelper.AssertElementName(TempXMLBuffer, 'nl:TaxCodeDetails');
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'nl:TaxCode', Format(TaxCode));
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'nl:Description', Description);
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'nl:TaxPercentage', SAFTTestHelper.FormatAmount(VATRate));
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'nl:Country', CompanyInformation."Country/Region Code");
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'nl:StandardTaxCode', StandardTaxCode);
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'nl:Compensation', Format(Compensation, 0, 9));
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'nl:BaseRate', SAFTTestHelper.FormatAmount(DeductionRate));
    end;

    local procedure VerifyCompanyStructure(var TempXMLBuffer: Record "XML Buffer" temporary; CompanyInformation: Record "Company Information")
    var
        Employee: Record Employee;
    begin
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'nl:RegistrationNumber', CompanyInformation."VAT Registration No.");
        SAFTTestHelper.AssertElementValue(
            TempXMLBuffer, 'nl:Name', SAFTTestHelper.CombineWithSpace(CompanyInformation.Name, CompanyInformation."Name 2"));
        VerifyAddress(
            TempXMLBuffer, SAFTTestHelper.CombineWithSpace(CompanyInformation.Address, CompanyInformation."Address 2"),
            CompanyInformation.City, CompanyInformation."Post Code", CompanyInformation."Country/Region Code");
        Employee.Get(CompanyInformation."SAF-T Contact No.");
        VerifyEmployee(
            TempXMLBuffer, Employee."First Name", Employee."Last Name", Employee."Phone No.",
             Employee."Fax No.", Employee."E-Mail", Employee."Mobile Phone No.");
        VerifyTaxRegistration(TempXMLBuffer, CompanyInformation);
        VerifyCompanyBankAccount(TempXMLBuffer, CompanyInformation."Bank Account No.");
    end;

    local procedure VerifyAddress(var TempXMLBuffer: Record "XML Buffer" temporary; StreetName: Text; City: Text; PostCode: Code[20]; CountryRegionCode: Code[20])
    begin
        SAFTTestHelper.AssertElementName(TempXMLBuffer, 'nl:Address');
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'nl:StreetName', StreetName);
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'nl:City', City);
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'nl:PostalCode', PostCode);
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'nl:Country', CountryRegionCode);
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'nl:AddressType', 'StreetAddress');
    end;

    local procedure VerifyContactSimple(var TempXMLBuffer: Record "XML Buffer" temporary; Name: Text; PhoneNo: Text; FaxNo: Text; Email: Text; HomePage: Text)
    var
        FirstName: Text;
        LastName: Text;
    begin
        SAFTTestHelper.GetFirstAndLastNameFromContactName(FirstName, LastName, Name);
        SAFTTestHelper.AssertElementName(TempXMLBuffer, 'nl:Contact');
        SAFTTestHelper.AssertElementName(TempXMLBuffer, 'nl:ContactPerson');
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'nl:FirstName', FirstName);
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'nl:LastName', LastName);
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'nl:Telephone', PhoneNo);
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'nl:Fax', FaxNo);
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'nl:Email', Email);
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'nl:Website', HomePage);
    end;

    local procedure VerifyEmployee(var TempXMLBuffer: Record "XML Buffer" temporary; FirstName: Text; LastName: Text; PhoneNo: Text; FaxNo: Text; Email: Text; MobilePhoneNo: Text)

    begin
        SAFTTestHelper.AssertElementName(TempXMLBuffer, 'nl:Contact');
        SAFTTestHelper.AssertElementName(TempXMLBuffer, 'nl:ContactPerson');
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'nl:FirstName', FirstName);
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'nl:LastName', LastName);
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'nl:Telephone', PhoneNo);
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'nl:Fax', FaxNo);
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'nl:Email', Email);
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'nl:MobilePhone', MobilePhoneNo);
    end;

    local procedure VerifyPartyInfo(var TempXMLBuffer: Record "XML Buffer" temporary; PaymentTermsCode: Code[10]; TableID: Integer; SourceNo: Code[20]);
    var
        PaymentTerms: Record "Payment Terms";
        DefaultDimension: Record "Default Dimension";
        Dimension: Record Dimension;
        SAFTExportMgt: Codeunit "SAF-T Export Mgt.";
    begin
        PaymentTerms.Get(PaymentTermsCode);
        SAFTTestHelper.AssertElementName(TempXMLBuffer, 'nl:PartyInfo');
        SAFTTestHelper.AssertElementName(TempXMLBuffer, 'nl:PaymentTerms');
        SAFTTestHelper.AssertElementValue(
            TempXMLBuffer, 'nl:Days', format(CalcDate(PaymentTerms."Due Date Calculation", WorkDate()) - WorkDate()));
        SAFTTestHelper.AssertElementValue(
            TempXMLBuffer, 'nl:CashDiscountDays', format(CalcDate(PaymentTerms."Discount Date Calculation", WorkDate()) - WorkDate()));
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'nl:CashDiscountRate', SAFTTestHelper.FormatAmount(PaymentTerms."Discount %"));
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'nl:CurrencyCode', SAFTExportMgt.GetISOCurrencyCode(''));
        DefaultDimension.SetRange("Table ID", TableID);
        DefaultDimension.SetRange("No.", SourceNo);
        DefaultDimension.FindSet();
        repeat
            SAFTTestHelper.AssertElementName(TempXMLBuffer, 'nl:Analysis');
            Dimension.get(DefaultDimension."Dimension Code");
            SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'nl:AnalysisType', Dimension."SAF-T Analysis Type");
            SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'nl:AnalysisID', DefaultDimension."Dimension Value Code");
        until DefaultDimension.Next() = 0;
    end;

    local procedure VerifyTaxRegistration(var TempXMLBuffer: Record "XML Buffer" temporary; CompanyInformation: Record "Company Information")
    begin
        SAFTTestHelper.AssertElementName(TempXMLBuffer, 'nl:TaxRegistration');
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'nl:TaxRegistrationNumber', CompanyInformation."VAT Registration No.");
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'nl:TaxAuthority', 'Skatteetaten');
    end;

    local procedure VerifyCompanyBankAccount(var TempXMLBuffer: Record "XML Buffer" temporary; BankAccountNumber: Text[30])
    var
        SAFTExportMgt: Codeunit "SAF-T Export Mgt.";
    begin
        SAFTTestHelper.AssertElementName(TempXMLBuffer, 'nl:BankAccount');
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'nl:BankAccountNumber', BankAccountNumber);
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'nl:CurrencyCode', SAFTExportMgt.GetISOCurrencyCode(''));
    end;

    local procedure VerifyXMLFileHasHeader(var TempXMLBuffer: Record "XML Buffer" temporary)
    begin
        SAFTTestHelper.FindSAFTHeaderElement(TempXMLBuffer);
        Assert.RecordCount(TempXMLBuffer, 1);
    end;

    local procedure VerifyGLEntriesGroupedBySAFTSourceCode(var TempXMLBuffer: Record "XML Buffer" temporary; var TempSAFTSourceCode: Record "SAF-T Source Code" temporary; ExpectedEntriesInTransactionNumber: Integer; StartingDate: Date; EndingDate: Date; SAFTAnalysisType: Code[9]; DimValueCode: Code[20])
    var
        GLEntry: Record "G/L Entry";
        SourceCode: Record "Source Code";
    begin
        GLEntry.SetRange("Posting Date", StartingDate, EndingDate);
        TempXMLBuffer.Reset();
        Assert.IsTrue(TempXMLBuffer.FindNodesByXPath(TempXMLBuffer, '/nl:AuditFile/nl:GeneralLedgerEntries'), 'No G/L entries exported.');
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'nl:NumberOfEntries', format(CalcNumberOfTransactions(GLEntry)));
        GLEntry.CalcSums("Debit Amount", "Credit Amount");
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'nl:TotalDebit', SAFTTestHelper.FormatAmount(GLEntry."Debit Amount"));
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'nl:TotalCredit', SAFTTestHelper.FormatAmount(GLEntry."Credit Amount"));
        TempSAFTSourceCode.FindSet();
        repeat
            SAFTTestHelper.AssertElementName(TempXMLBuffer, 'nl:Journal');
            SourceCode.SetRange("SAF-T Source Code", TempSAFTSourceCode.Code);
            SourceCode.FindFirst();
            SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'nl:JournalID', TempSAFTSourceCode.Code);
            SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'nl:Description', TempSAFTSourceCode.Description);
            SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'nl:Type', TempSAFTSourceCode.Code);
            GLEntry.SetRange("Source Code", SourceCode.Code);
            GLEntry.FindSet();
            VerifyGLEntriesGroupedByTransactionNos(TempXMLBuffer, GLEntry, ExpectedEntriesInTransactionNumber, SAFTAnalysisType, DimValueCode);
            GLEntry.SetRange("Source Code");
        until TempSAFTSourceCode.Next() = 0;
    end;

    local procedure VerifyGLEntriesGroupedByTransactionNos(var TempXMLBuffer: Record "XML Buffer" temporary; var GLEntry: Record "G/L Entry"; ExpectedEntriesInTransactionNumber: Integer; SAFTAnalysisType: Code[9]; DimValueCode: Code[20])
    var
        ActualEntriesInTransactionNumber: Integer;
        Step: Integer;
    begin
        repeat
            SAFTTestHelper.AssertElementName(TempXMLBuffer, 'nl:Transaction');
            GLEntry.SetRange("Transaction No.", GLEntry."Transaction No.");
            SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'nl:TransactionID', format(GLEntry."Transaction No."));
            SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'nl:Period', format(Date2DMY(GLEntry."Posting Date", 2)));
            SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'nl:PeriodYear', format(Date2DMY(GLEntry."Posting Date", 3)));
            SAFTTestHelper.AssertElementValue(
                TempXMLBuffer, 'nl:TransactionDate', SAFTTestHelper.FormatDate(GLEntry."Document Date"));
            SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'nl:SourceID', GLEntry."User ID");
            SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'nl:Description', GLEntry.Description);
            SAFTTestHelper.AssertElementValue(
                TempXMLBuffer, 'nl:SystemEntryDate', SAFTTestHelper.FormatDate(GLEntry."Document Date"));
            SAFTTestHelper.AssertElementValue(
                TempXMLBuffer, 'nl:GLPostingDate', SAFTTestHelper.FormatDate(GLEntry."Posting Date"));
            Step := 1;
            ActualEntriesInTransactionNumber := 0;
            while Step = 1 do begin
                VerifySingleGLEntry(TempXMLBuffer, GLEntry, SAFTAnalysisType, DimValueCode);
                Step := GLEntry.Next();
                ActualEntriesInTransactionNumber += 1;
            end;
            GLEntry.SetRange("Transaction No.");
            Assert.AreEqual(
                ExpectedEntriesInTransactionNumber, ActualEntriesInTransactionNumber, 'Number of transactions not expected');
        until GLEntry.Next() = 0;
    end;

    local procedure VerifySingleGLEntry(var TempXMLBuffer: Record "XML Buffer" temporary; var GLEntry: Record "G/L Entry"; SAFTAnalysisType: Code[9]; DimValueCode: Code[20])
    var
        SAFTExportMgt: Codeunit "SAF-T Export Mgt.";
        AmountXMLNode: Text;
        Amount: Decimal;
    begin
        SAFTTestHelper.AssertElementName(TempXMLBuffer, 'nl:Line');
        SAFTTestHelper.AssertElementName(TempXMLBuffer, 'nl:RecordID');
        SAFTTestHelper.AssertCurrentElementValue(TempXMLBuffer, 'nl:RecordID', Format(GLEntry."Entry No."));
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'nl:AccountID', GLEntry."G/L Account No.");
        VerifyDimensions(TempXMLBuffer, SAFTAnalysisType, DimValueCode);
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'nl:SourceDocumentID', GLEntry."Document No.");
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'nl:Description', GLEntry.Description);
        SAFTExportMgt.GetAmountInfoFromGLEntry(AmountXMLNode, Amount, GLEntry);
        VerifyAmountInfo(TempXMLBuffer, AmountXMLNode, Amount);
        VerifySalesVATEntry(TempXMLBuffer, GLEntry);
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'nl:ReferenceNumber', GLEntry."External Document No.");
    end;

    local procedure VerifySalesVATEntry(var TempXMLBuffer: Record "XML Buffer" temporary; GLEntry: Record "G/L Entry")
    var
        VATPostingSetup: Record "VAT Posting Setup";
        VATEntry: Record "VAT Entry";
    begin
        GLEntry.TestField("VAT Bus. Posting Group");
        GLEntry.TestField("VAT Prod. Posting Group");
        VATPostingSetup.Get(GLEntry."VAT Bus. Posting Group", GLEntry."VAT Prod. Posting Group");
        VATEntry.SetCurrentKey("Document No.", "Posting Date");
        VATEntry.SetRange("Document No.", GLEntry."Document No.");
        VATEntry.SetRange("Posting Date", GLEntry."Posting Date");
        VATEntry.SetRange("Transaction No.", GLEntry."Transaction No.");
        VATEntry.FindFirst();

        SAFTTestHelper.AssertElementName(TempXMLBuffer, 'nl:TaxInformation');
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'nl:TaxType', 'MVA');
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'nl:TaxCode', Format(VATPostingSetup."Sales SAF-T Tax Code"));
        SAFTTestHelper.AssertElementValue(
            TempXMLBuffer, 'nl:TaxPercentage', SAFTTestHelper.FormatAmount(VATPostingSetup."VAT %"));
        SAFTTestHelper.AssertElementValue(
            TempXMLBuffer, 'nl:TaxBase', SAFTTestHelper.FormatAmount(abs(VATEntry.Base)));
        VerifyAmountInfo(TempXMLBuffer, 'TaxAmount', abs(VATEntry.Amount));
    end;

    local procedure VerifyDimensions(var TempXMLBuffer: Record "XML Buffer" temporary; SAFTAnalysisType: Code[9]; DimValueCode: Code[20])
    begin
        SAFTTestHelper.AssertElementName(TempXMLBuffer, 'nl:Analysis');
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'nl:AnalysisType', SAFTAnalysisType);
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'nl:AnalysisID', DimValueCode);
    end;

    local procedure VerifyAmountInfo(var TempXMLBuffer: Record "XML Buffer" temporary; AmountXMLNode: Text; Amount: Decimal)
    begin
        SAFTTestHelper.AssertElementName(TempXMLBuffer, 'nl:' + AmountXMLNode);
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'nl:Amount', SAFTTestHelper.FormatAmount(Amount));
    end;

    [ConfirmHandler]
    procedure ConfirmYesHandler(Question: Text; var Reply: Boolean)
    begin
        Assert.ExpectedMessage(LibraryVariableStorage.DequeueText(), Question);
        Reply := true;
    end;
}
