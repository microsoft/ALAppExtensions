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
        LibrarySales: Codeunit "Library - Sales";
        LibraryPurchase: Codeunit "Library - Purchase";
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
        NumberOfMasterDataRecords := LibraryRandom.RandIntInRange(3, 5);
        SAFTTestHelper.SetupSAFT(SAFTMappingRange, SAFTMappingType::"Four Digit Standard Account", NumberOfMasterDataRecords);
        SAFTTestHelper.PostRandomAmountForNumberOfMasterDataRecords(SAFTMappingRange."Ending Date", NumberOfMasterDataRecords);
        SAFTTestHelper.MatchGLAccountsFourDigit(SAFTMappingRange.Code);
        SAFTTestHelper.CreateSAFTExportHeader(SAFTExportHeader, SAFTMappingRange.Code);
        LibraryVariableStorage.Enqueue(GenerateSAFTFileImmediatelyQst);
        SAFTTestHelper.RunSAFTExport(SAFTExportHeader);
        SAFTExportLine.SetRange(Status, SAFTExportLine.Status::Completed);
        SAFTTestHelper.FindSAFTExportLine(SAFTExportLine, SAFTExportHeader.ID);
        Assert.RecordCount(SAFTExportLine, 2);
        SAFTExportLine.TestField("Master Data", true);
        SAFTExportHeader.Find();
        SAFTExportHeader.TestField(Status, SAFTExportHeader.Status::Completed);
        SAFTExportHeader.TestField("Execution Start Date/Time");
        SAFTExportHeader.TestField("Execution End Date/Time");

        SAFTTestHelper.LoadXMLBufferFromSAFTExportLine(TempXMLBuffer, SAFTExportLine);
        VerifyHeaderStructure(TempXMLBuffer, SAFTExportLine);
        // TFS 348392: All G/L accounts are exports
        // TFS 349472: Both Company Information's bank account and all records from Bank Acount table exports
        // TFS 349472: All customer and vendor bank accounts exports
        // TFS 350284: All xnl nodes predefined with 'n1:'
        // TFS 350284: Both sales and purchase VAT Entry information exports 
        // TFS 372962: Customer and vendor with zero balance should be presented
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
        SetupSAFTSingleAcc(
            SAFTMappingRange, SAFTMappingType::"Four Digit Standard Account", GLAccount."Income/Balance"::"Balance Sheet");
        SAFTTestHelper.MatchGLAccountsFourDigit(SAFTMappingRange.Code);
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
        SAFTTestHelper.FindSAFTExportLine(SAFTExportLine, SAFTExportHeader.ID);
        SAFTTestHelper.LoadXMLBufferFromSAFTExportLine(TempXMLBuffer, SAFTExportLine);
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
        SetupSAFTSingleAcc(
            SAFTMappingRange, SAFTMappingType::"Four Digit Standard Account", GLAccount."Income/Balance"::"Balance Sheet");
        SAFTTestHelper.MatchGLAccountsFourDigit(SAFTMappingRange.Code);
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
        SAFTTestHelper.FindSAFTExportLine(SAFTExportLine, SAFTExportHeader.ID);
        SAFTTestHelper.LoadXMLBufferFromSAFTExportLine(TempXMLBuffer, SAFTExportLine);
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
        SetupSAFTSingleAcc(
            SAFTMappingRange, SAFTMappingType::"Four Digit Standard Account", GLAccount."Income/Balance"::"Balance Sheet");
        SAFTTestHelper.MatchGLAccountsFourDigit(SAFTMappingRange.Code);
        SAFTTestHelper.CreateSAFTExportHeader(SAFTExportHeader, SAFTMappingRange.Code);
        BalanceAmount := LibraryRandom.RandDec(100, 2);
        SAFTTestHelper.MockEntriesForFirstRecordOfMasterData(
            GLAccount."Income/Balance"::"Balance Sheet", SAFTExportHeader."Ending Date",
            BalanceAmount, BalanceAmount, -BalanceAmount);
        LibraryVariableStorage.Enqueue(GenerateSAFTFileImmediatelyQst);
        SAFTTestHelper.RunSAFTExport(SAFTExportHeader);
        SAFTTestHelper.FindSAFTExportLine(SAFTExportLine, SAFTExportHeader.ID);
        SAFTTestHelper.LoadXMLBufferFromSAFTExportLine(TempXMLBuffer, SAFTExportLine);
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
        SetupSAFTSingleAcc(
            SAFTMappingRange, SAFTMappingType::"Four Digit Standard Account", GLAccount."Income/Balance"::"Balance Sheet");
        SAFTTestHelper.MatchGLAccountsFourDigit(SAFTMappingRange.Code);
        SAFTTestHelper.CreateSAFTExportHeader(SAFTExportHeader, SAFTMappingRange.Code);
        BalanceAmount := LibraryRandom.RandDec(100, 2);
        SAFTTestHelper.MockEntriesForFirstRecordOfMasterData(
            GLAccount."Income/Balance"::"Balance Sheet", SAFTExportHeader."Ending Date",
            -BalanceAmount, -BalanceAmount, BalanceAmount);
        LibraryVariableStorage.Enqueue(GenerateSAFTFileImmediatelyQst);
        SAFTTestHelper.RunSAFTExport(SAFTExportHeader);
        SAFTTestHelper.FindSAFTExportLine(SAFTExportLine, SAFTExportHeader.ID);
        SAFTTestHelper.LoadXMLBufferFromSAFTExportLine(TempXMLBuffer, SAFTExportLine);
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
        EntryType: Integer;
    begin
        // [SCENARIO 309923] The structure of the XML file with General Ledger Entries is correct
        // [SCENARIO 331600] "NumberOfEntries" contains the number of transactions
        // [SCENARIO 334997] "ReferenceNumber" xml node exports after "TaxInformation" section

        Initialize();
        SAFTTestHelper.SetupSAFT(SAFTMappingRange, SAFTMappingType::"Four Digit Standard Account", LibraryRandom.RandInt(5));
        SAFTTestHelper.MatchGLAccountsFourDigit(SAFTMappingRange.Code);
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
            for j := 1 to EntriesInTransactionNumber do
                for EntryType := VATEntry.Type::Purchase to VATEntry.Type::Sale do begin
                    SAFTTestHelper.MockVATEntry(VATEntry, SAFTExportHeader."Ending Date", EntryType, i);
                    SAFTTestHelper.MockGLEntryVATEntryLink(
                        SAFTTestHelper.MockGLEntry(
                            SAFTExportHeader."Ending Date", VATEntry."Document No.", GLAccount."No.",
                            VATEntry."Transaction No.", DimSetID, VATEntry."VAT Bus. Posting Group",
                            VATEntry."VAT Prod. Posting Group", 0, '', SourceCode.Code, LibraryRandom.RandDec(100, 2), 0),
                        VATEntry."Entry No.");
                end;
            TempSAFTSourceCode := SAFTSourceCode;
            TempSAFTSourceCode.Insert();
            SAFTSourceCode.Next();
        end;
        LibraryVariableStorage.Enqueue(GenerateSAFTFileImmediatelyQst);
        SAFTTestHelper.RunSAFTExport(SAFTExportHeader);
        SAFTExportLine.SetRange(Status, SAFTExportLine.Status::Completed);
        SAFTTestHelper.FindSAFTExportLine(SAFTExportLine, SAFTExportHeader.ID);
        Assert.RecordCount(SAFTExportLine, 2);
        SAFTExportLine.Next();
        SAFTExportLine.TestField("Master Data", false);
        SAFTTestHelper.LoadXMLBufferFromSAFTExportLine(TempXMLBuffer, SAFTExportLine);
        VerifyXMLFileHasHeader(TempXMLBuffer);
        VerifyGLEntriesGroupedBySAFTSourceCode(
            TempXMLBuffer, TempSAFTSourceCode, EntriesInTransactionNumber * 2, SAFTExportLine."Starting Date", SAFTExportLine."Ending Date",
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

        SAFTTestHelper.SetupSAFT(SAFTMappingRange, SAFTMappingType::"Four Digit Standard Account", LibraryRandom.RandInt(5));
        SAFTTestHelper.MatchGLAccountsFourDigit(SAFTMappingRange.Code);
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
        SAFTTestHelper.FindSAFTExportLine(SAFTExportLine, SAFTExportHeader.ID);
        SAFTTestHelper.LoadXMLBufferFromSAFTExportLine(TempXMLBuffer, SAFTExportLine);

        // [THEN] CustomerID xml node exists just once in the XML file
        Assert.IsTrue(
            TempXMLBuffer.FindNodesByXPath(TempXMLBuffer,
                '/n1:AuditFile/n1:GeneralLedgerEntries/n1:Journal/n1:Transaction/n1:Line/n1:CustomerID'),
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

        SAFTTestHelper.SetupSAFT(SAFTMappingRange, SAFTMappingType::"Four Digit Standard Account", LibraryRandom.RandInt(5));
        SAFTTestHelper.MatchGLAccountsFourDigit(SAFTMappingRange.Code);
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
        SAFTTestHelper.FindSAFTExportLine(SAFTExportLine, SAFTExportHeader.ID);
        SAFTTestHelper.LoadXMLBufferFromSAFTExportLine(TempXMLBuffer, SAFTExportLine);

        // [THEN] SupplierID xml node exists just once in the XML file
        Assert.IsTrue(
            TempXMLBuffer.FindNodesByXPath(TempXMLBuffer,
                '/n1:AuditFile/n1:GeneralLedgerEntries/n1:Journal/n1:Transaction/n1:Line/n1:SupplierID'),
                'No G/L entries with CustomerID exported.');
        Assert.RecordCount(TempXMLBuffer, 1);
    end;

    [Test]
    [HandlerFunctions('ConfirmYesHandler')]
    procedure GLAccountExportWithIncomeStatementMappingType()
    var
        SAFTExportHeader: Record "SAF-T Export Header";
        SAFTExportLine: Record "SAF-T Export Line";
        SAFTMappingRange: Record "SAF-T Mapping Range";
        TempXMLBuffer: Record "XML Buffer" temporary;
        NumberOfMasterDataRecords: Integer;
    begin
        // [SCENARIO 352458] The xml file of master data contains G/L account with income statement mapping if "Mapping Type" is "Income Statement"  

        Initialize();
        NumberOfMasterDataRecords := LibraryRandom.RandIntInRange(3, 5);
        SAFTTestHelper.SetupSAFT(SAFTMappingRange, SAFTMappingType::"Income Statement", NumberOfMasterDataRecords);
        SAFTTestHelper.PostRandomAmountForNumberOfMasterDataRecords(SAFTMappingRange."Ending Date", NumberOfMasterDataRecords);
        SAFTTestHelper.MatchGLAccountsFourDigit(SAFTMappingRange.Code);
        SAFTTestHelper.CreateSAFTExportHeader(SAFTExportHeader, SAFTMappingRange.Code);
        LibraryVariableStorage.Enqueue(GenerateSAFTFileImmediatelyQst);
        SAFTTestHelper.RunSAFTExport(SAFTExportHeader);
        SAFTTestHelper.FindSAFTExportLine(SAFTExportLine, SAFTExportHeader.ID);

        SAFTTestHelper.LoadXMLBufferFromSAFTExportLine(TempXMLBuffer, SAFTExportLine);
        VerifyGeneralLedgerAccountsWithIncomeStatementMapping(TempXMLBuffer, SAFTExportHeader."Mapping Range Code");
        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('ConfirmYesHandler')]
    procedure GLEntryVATEntryLink()
    var
        SAFTMappingRange: Record "SAF-T Mapping Range";
        SAFTExportHeader: Record "SAF-T Export Header";
        SAFTExportLine: Record "SAF-T Export Line";
        TempXMLBuffer: Record "XML Buffer" temporary;
        GLAccount: Record "G/L Account";
        Vendor: Record Customer;
        GLEntry: Record "G/L Entry";
        VATEntry: array[2] of Record "VAT Entry";
        DocNo: Code[20];
        i: Integer;
    begin
        // [FEATURE] [VAT]
        // [SCENARIO 359996] Each G/L Entry under the "Line" xml node has the correct VAT Entry under the "TaxInformation" node 

        Initialize();

        SAFTTestHelper.SetupSAFT(SAFTMappingRange, SAFTMappingType::"Four Digit Standard Account", LibraryRandom.RandInt(5));
        SAFTTestHelper.MatchGLAccountsFourDigit(SAFTMappingRange.Code);
        SAFTTestHelper.CreateSAFTExportHeader(SAFTExportHeader, SAFTMappingRange.Code);

        DocNo := LibraryUtility.GenerateGUID();
        GLAccount.SetRange("Income/Balance", GLAccount."Income/Balance"::"Balance Sheet");
        GLAccount.FindFirst();
        Vendor.FindFirst();
        SAFTTestHelper.IncludesNoSourceCodeToTheFirstSAFTSourceCode();

        // [GIVEN] Two G/L Entries with the same document/transaction, each related to its own VAT Entry
        // [GIVEN] VAT Entry 1: Base = 100, Amount = 21
        // [GIVEN] VAT Entry 2. Base = 200, Amount = 36
        SAFTTestHelper.MockVATEntry(VATEntry[2], SAFTExportHeader."Ending Date", VATEntry[1].Type::Purchase, 1);
        for i := 1 to ArrayLen(VATEntry) do begin
            SAFTTestHelper.MockVATEntry(VATEntry[i], SAFTExportHeader."Ending Date", VATEntry[i].Type::Purchase, 1);
            SAFTTestHelper.MockGLEntryVATEntryLink(
                SAFTTestHelper.MockGLEntry(
                    SAFTExportHeader."Ending Date", DocNo, GLAccount."No.",
                    1, 0, GLEntry."Gen. Posting Type"::Purchase, VATEntry[i]."VAT Bus. Posting Group",
                    VATEntry[i]."VAT Prod. Posting Group", GLEntry."Source Type"::Vendor, Vendor."No.", '', LibraryRandom.RandDec(100, 2), 0),
                VATEntry[i]."Entry No.");
        end;

        // [WHEN] Export G/L Entries to the XML file
        LibraryVariableStorage.Enqueue(GenerateSAFTFileImmediatelyQst);
        SAFTTestHelper.RunSAFTExport(SAFTExportHeader);
        SAFTExportLine.SetRange("Master Data", false);
        SAFTTestHelper.FindSAFTExportLine(SAFTExportLine, SAFTExportHeader.ID);
        SAFTTestHelper.LoadXMLBufferFromSAFTExportLine(TempXMLBuffer, SAFTExportLine);

        // [THEN] The following nodes have exported:
        // [THEN] n1:Line/n1:TaxInformation/n1:TaxBase. Value: 100
        // [THEN] n1:Line/n1:TaxInformation/n1:TaxAmount/n1:Amount. Value: 21
        // [THEN] n1:Line/n1:TaxInformation/n1:TaxBase. Value: 200
        // [THEN] n1:Line/n1:TaxInformation/n1:TaxAmount/n1:Amount. Value: 36
        Assert.IsTrue(
            TempXMLBuffer.FindNodesByXPath(TempXMLBuffer,
                '/n1:AuditFile/n1:GeneralLedgerEntries/n1:Journal/n1:Transaction/n1:Line/n1:TaxInformation/n1:TaxBase'),
                'A TaxBase xml node hasn''t found');
        Assert.RecordCount(TempXMLBuffer, 2);
        SAFTTestHelper.AssertCurrentElementValue(TempXMLBuffer, 'n1:TaxBase', SAFTTestHelper.FormatAmount(VATEntry[1].Base));
        TempXMLBuffer.Next();
        SAFTTestHelper.AssertCurrentElementValue(TempXMLBuffer, 'n1:TaxBase', SAFTTestHelper.FormatAmount(VATEntry[2].Base));
        Assert.IsTrue(
            TempXMLBuffer.FindNodesByXPath(TempXMLBuffer,
                '/n1:AuditFile/n1:GeneralLedgerEntries/n1:Journal/n1:Transaction/n1:Line/n1:TaxInformation/n1:TaxAmount/n1:Amount'),
                'A TaxAmount xml node hasn''t found');
        Assert.RecordCount(TempXMLBuffer, 2);
        SAFTTestHelper.AssertCurrentElementValue(TempXMLBuffer, 'n1:Amount', SAFTTestHelper.FormatAmount(VATEntry[1].Amount));
        TempXMLBuffer.Next();
        SAFTTestHelper.AssertCurrentElementValue(TempXMLBuffer, 'n1:Amount', SAFTTestHelper.FormatAmount(VATEntry[2].Amount));
    end;

    [Test]
    [HandlerFunctions('ConfirmYesHandler')]
    procedure LastModifiedDateTimeExportsToSystemEntryDateXMLNode()
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
        // [SCENARIO 360658] A value of "Last Modified DateTime" exports to the SystemEntryDate xml node

        Initialize();

        SAFTTestHelper.SetupSAFT(SAFTMappingRange, SAFTMappingType::"Four Digit Standard Account", LibraryRandom.RandInt(5));
        SAFTTestHelper.MatchGLAccountsFourDigit(SAFTMappingRange.Code);
        SAFTTestHelper.CreateSAFTExportHeader(SAFTExportHeader, SAFTMappingRange.Code);

        DocNo := LibraryUtility.GenerateGUID();
        GLAccount.SetRange("Income/Balance", GLAccount."Income/Balance"::"Balance Sheet");
        GLAccount.FindFirst();
        Customer.FindFirst();
        SAFTTestHelper.IncludesNoSourceCodeToTheFirstSAFTSourceCode();

        // [GIVEN] A G/L Entry with "Last Modified DateTime" = "X" and "Posting Date" = "Y"
        GLEntry.Get(
            SAFTTestHelper.MockGLEntry(
                SAFTExportHeader."Ending Date", DocNo, GLAccount."No.",
                1, 0, GLEntry."Gen. Posting Type"::Sale, '',
                '', GLEntry."Source Type"::Customer, Customer."No.", '', LibraryRandom.RandDec(100, 2), 0));

        // [WHEN] Export G/L Entries to the XML file
        LibraryVariableStorage.Enqueue(GenerateSAFTFileImmediatelyQst);
        SAFTTestHelper.RunSAFTExport(SAFTExportHeader);
        SAFTExportLine.SetRange("Master Data", false);
        SAFTTestHelper.FindSAFTExportLine(SAFTExportLine, SAFTExportHeader.ID);
        SAFTTestHelper.LoadXMLBufferFromSAFTExportLine(TempXMLBuffer, SAFTExportLine);

        // [THEN] SystemEntryDate xml node has value "X"
        Assert.IsTrue(
            TempXMLBuffer.FindNodesByXPath(TempXMLBuffer,
                '/n1:AuditFile/n1:GeneralLedgerEntries/n1:Journal/n1:Transaction/n1:SystemEntryDate'),
                'No G/L entries with SystemEntryDate exported.');
        Assert.RecordCount(TempXMLBuffer, 1);
        SAFTTestHelper.AssertCurrentElementValue(
            TempXMLBuffer, 'n1:SystemEntryDate',
            SAFTTestHelper.FormatDate(DT2Date(GLEntry."Last Modified DateTime")));
    end;

    [Test]
    [HandlerFunctions('ConfirmYesHandler')]
    procedure PostingDateExportsToSystemEntryDateXMLNode()
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
        // [SCENARIO 360658] A value of "Posting Date" exports to the SystemEntryDate xml node when "Last Modified DateTime" is blank

        Initialize();

        SAFTTestHelper.SetupSAFT(SAFTMappingRange, SAFTMappingType::"Four Digit Standard Account", LibraryRandom.RandInt(5));
        SAFTTestHelper.MatchGLAccountsFourDigit(SAFTMappingRange.Code);
        SAFTTestHelper.CreateSAFTExportHeader(SAFTExportHeader, SAFTMappingRange.Code);

        DocNo := LibraryUtility.GenerateGUID();
        GLAccount.SetRange("Income/Balance", GLAccount."Income/Balance"::"Balance Sheet");
        GLAccount.FindFirst();
        Customer.FindFirst();
        SAFTTestHelper.IncludesNoSourceCodeToTheFirstSAFTSourceCode();

        // [GIVEN] A G/L Entry with blank "Last Modified DateTime" and "Posting Date" = "Y"
        GLEntry.Get(
            SAFTTestHelper.MockGLEntry(
                SAFTExportHeader."Ending Date", DocNo, GLAccount."No.",
                1, 0, GLEntry."Gen. Posting Type"::Sale, '',
                '', GLEntry."Source Type"::Customer, Customer."No.", '', LibraryRandom.RandDec(100, 2), 0));
        GLEntry.Validate("Last Modified DateTime", 0DT);
        GLEntry.Modify();

        // [WHEN] Export G/L Entries to the XML file
        LibraryVariableStorage.Enqueue(GenerateSAFTFileImmediatelyQst);
        SAFTTestHelper.RunSAFTExport(SAFTExportHeader);
        SAFTExportLine.SetRange("Master Data", false);
        SAFTTestHelper.FindSAFTExportLine(SAFTExportLine, SAFTExportHeader.ID);
        SAFTTestHelper.LoadXMLBufferFromSAFTExportLine(TempXMLBuffer, SAFTExportLine);

        // [THEN] SystemEntryDate xml node has value "Y"
        Assert.IsTrue(
            TempXMLBuffer.FindNodesByXPath(TempXMLBuffer,
                '/n1:AuditFile/n1:GeneralLedgerEntries/n1:Journal/n1:Transaction/n1:SystemEntryDate'),
                'No G/L entries with SystemEntryDate exported.');
        Assert.RecordCount(TempXMLBuffer, 1);
        SAFTTestHelper.AssertCurrentElementValue(
            TempXMLBuffer, 'n1:SystemEntryDate',
            SAFTTestHelper.FormatDate(GLEntry."Posting Date"));
    end;

    [Test]
    [HandlerFunctions('ConfirmYesHandler')]
    procedure CustomerIDWithZeroBalanceInvoiceAndPayment();
    var
        SAFTExportHeader: Record "SAF-T Export Header";
        Customer: Record Customer;
        CustNo: Code[20];
        Cust2No: Code[20];
        Amount: Decimal;
    begin
        // [SCENARIO 372962] CustomerID of Customer with zero balance and non-zero sales must be presented in XML
        Initialize();

        // [GIVEN] SAF-T Setup
        BasicSAFTSetup(SAFTExportHeader);

        // [GIVEN] Customer with 2 Customer Ledger Entries - Invoice and Payment
        Customer.FindFirst();
        CustNo := Customer."No.";
        Amount := LibraryRandom.RandIntInRange(100, 1000);
        SAFTTestHelper.MockCustLedgEntry(
            SAFTExportHeader."Starting Date", CustNo, Amount, Amount, "Gen. Journal Document Type"::Invoice);
        SAFTTestHelper.MockCustLedgEntry(
            SAFTExportHeader."Starting Date", CustNo, 0, -Amount, "Gen. Journal Document Type"::Payment);

        // [GIVEN] Customer2 without any ledger entries
        Cust2No := LibrarySales.CreateCustomerNo();

        // [WHEN] Export SAF-T
        LibraryVariableStorage.Enqueue(GenerateSAFTFileImmediatelyQst);
        SAFTTestHelper.RunSAFTExport(SAFTExportHeader);

        // [THEN] Master file contains the 'n1:CustomerID' for Customer with zero balance
        VerifyXMLNodeOfMasterFile(SAFTExportHeader, 'CustomerID', CustNo);

        // [THEN] Master file does not contain the 'n1:CustomerID' for Customer2
        VerifyNonExistingXMLNodeOfMasterFile(SAFTExportHeader, 'CustomerID', Cust2No);
        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('ConfirmYesHandler')]
    procedure VendorIDWithZeroBalanceInvoiceAndPayment();
    var
        SAFTExportHeader: Record "SAF-T Export Header";
        Vendor: Record Vendor;
        VendNo: Code[20];
        Vend2No: Code[20];
        Amount: Decimal;
    begin
        // [SCENARIO 372962] SupplierID of Vendor with zero balance and non-zero sales must be presented in XML
        Initialize();

        // [GIVEN] SAF-T Setup
        BasicSAFTSetup(SAFTExportHeader);

        // [GIVEN] Vendor with 2 Vendor Ledger Entries - Invoice and Payment
        Vendor.FindFirst();
        VendNo := Vendor."No.";
        Amount := LibraryRandom.RandIntInRange(100, 1000);
        SAFTTestHelper.MockVendLedgEntry(
            SAFTExportHeader."Starting Date", VendNo, Amount, Amount, "Gen. Journal Document Type"::Invoice);
        SAFTTestHelper.MockVendLedgEntry(
            SAFTExportHeader."Starting Date", VendNo, 0, -Amount, "Gen. Journal Document Type"::Payment);

        // [GIVEN] Vendor2 without any ledger entries
        Vend2No := LibraryPurchase.CreateVendorNo();

        // [WHEN] Export SAF-T
        LibraryVariableStorage.Enqueue(GenerateSAFTFileImmediatelyQst);
        SAFTTestHelper.RunSAFTExport(SAFTExportHeader);

        // [THEN] Master file contains the 'n1:SupplierID' for Vendor with zero balance
        VerifyXMLNodeOfMasterFile(SAFTExportHeader, 'SupplierID', VendNo);

        // [THEN] Master file does not contain the 'n1:SupplierID' for Vendor2
        VerifyNonExistingXMLNodeOfMasterFile(SAFTExportHeader, 'SupplierID', Vend2No);
        LibraryVariableStorage.AssertEmpty();
    END;

    [Test]
    [HandlerFunctions('ConfirmYesHandler')]
    procedure CustomerIDWithZeroBalanceInvoiceAndCreditMemo();
    var
        SAFTExportHeader: Record "SAF-T Export Header";
        Customer: Record Customer;
        CustNo: Code[20];
        Amount: Decimal;
    begin
        // [SCENARIO 372962] CustomerID of Customer with zero balance and non-zero sales must be presented in XML
        Initialize();

        // [GIVEN] SAF-T Setup
        BasicSAFTSetup(SAFTExportHeader);

        // [GIVEN] Customer with 2 Customer Ledger Entries - Invoice and Credit Memo
        Customer.FindFirst();
        CustNo := Customer."No.";
        Amount := LibraryRandom.RandIntInRange(100, 1000);
        SAFTTestHelper.MockCustLedgEntry(
            SAFTExportHeader."Starting Date", CustNo, Amount, Amount, "Gen. Journal Document Type"::Invoice);
        SAFTTestHelper.MockCustLedgEntry(
            SAFTExportHeader."Starting Date", CustNo, -Amount, -Amount, "Gen. Journal Document Type"::"Credit Memo");

        // [WHEN] Export SAF-T
        LibraryVariableStorage.Enqueue(GenerateSAFTFileImmediatelyQst);
        SAFTTestHelper.RunSAFTExport(SAFTExportHeader);

        // [THEN] Master file contains the 'n1:CustomerID' for Customer with zero balance
        VerifyXMLNodeOfMasterFile(SAFTExportHeader, 'CustomerID', CustNo);
        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('ConfirmYesHandler')]
    procedure VendorIDWithZeroBalanceInvoiceAndCreditMemo();
    var
        SAFTExportHeader: Record "SAF-T Export Header";
        Vendor: Record Vendor;
        VendNo: Code[20];
        Amount: Decimal;
    begin
        // [SCENARIO 372962] SupplierID of Vendor with zero balance and non-zero sales must be presented in XML
        Initialize();

        // [GIVEN] SAF-T Setup
        BasicSAFTSetup(SAFTExportHeader);

        // [GIVEN] Vendor with 2 Vendor Ledger Entries - Invoice and Credit Memo
        Vendor.FindFirst();
        VendNo := Vendor."No.";
        Amount := LibraryRandom.RandIntInRange(100, 1000);
        SAFTTestHelper.MockVendLedgEntry(
            SAFTExportHeader."Starting Date", VendNo, Amount, Amount, "Gen. Journal Document Type"::Invoice);
        SAFTTestHelper.MockVendLedgEntry(
            SAFTExportHeader."Starting Date", VendNo, -Amount, -Amount, "Gen. Journal Document Type"::"Credit Memo");

        // [WHEN] Export SAF-T
        LibraryVariableStorage.Enqueue(GenerateSAFTFileImmediatelyQst);
        SAFTTestHelper.RunSAFTExport(SAFTExportHeader);

        // [THEN] Master file contains the 'n1:SupplierID' for Vendor with zero balance
        VerifyXMLNodeOfMasterFile(SAFTExportHeader, 'SupplierID', VendNo);
        LibraryVariableStorage.AssertEmpty();
    END;

    local procedure Initialize()
    begin
        LibraryTestInitialize.OnTestInitialize(CODEUNIT::"SAF-T XML Tests");
        if IsInitialized then
            exit;

        LibraryTestInitialize.OnBeforeTestSuiteInitialize(CODEUNIT::"SAF-T XML Tests");

        IsInitialized := true;
        LibraryTestInitialize.OnAfterTestSuiteInitialize(CODEUNIT::"SAF-T XML Tests");
    end;

    local procedure SetupSAFTSingleAcc(var SAFTMappingRange: Record "SAF-T Mapping Range"; MappingType: Enum "SAF-T Mapping Type"; IncomeBalance: Integer): Code[20]
    var
        SAFTMappingHelper: Codeunit "SAF-T Mapping Helper";
    begin
        SAFTTestHelper.SetupMasterDataSingleAcc(IncomeBalance);
        SAFTTestHelper.InsertSAFTMappingRangeFullySetup(
            SAFTMappingRange, MappingType, SAFTTestHelper.GetWorkDateInYearWithNoGLEntries(),
            CalcDate('<CY>', SAFTTestHelper.GetWorkDateInYearWithNoGLEntries()));
        SAFTMappingHelper.MapRestSourceCodesToAssortedJournals();
        exit(SAFTMappingRange.Code);
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

    local procedure BasicSAFTSetup(var SAFTExportHeader: Record "SAF-T Export Header");
    var
        SAFTMappingRange: Record "SAF-T Mapping Range";
    begin
        SAFTTestHelper.SetupSAFT(
          SAFTMappingRange, "SAF-T Mapping Type"::"Four Digit Standard Account", LibraryRandom.RandIntInRange(3, 5));
        SAFTTestHelper.MatchGLAccountsFourDigit(SAFTMappingRange.Code);
        SAFTTestHelper.CreateSAFTExportHeader(SAFTExportHeader, SAFTMappingRange.Code);
    end;

    local procedure VerifyHeaderStructure(var TempXMLBuffer: Record "XML Buffer" temporary; SAFTExportLine: Record "SAF-T Export Line")
    var
        CompanyInformation: Record "Company Information";
        GeneralLedgerSetup: Record "General Ledger Setup";
        SAFTExportHeader: Record "SAF-T Export Header";

    begin
        SAFTTestHelper.FindSAFTHeaderElement(TempXMLBuffer);
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'n1:AuditFileVersion', '1.0');
        CompanyInformation.Get();
        GeneralLedgerSetup.Get();
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'n1:AuditFileCountry', CompanyInformation."Country/Region Code");
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'n1:AuditFileDateCreated', SAFTTestHelper.FormatDate(Today()));
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'n1:SoftwareCompanyName', 'Microsoft');
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'n1:SoftwareID', 'Microsoft Dynamics 365 Business Central');
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'n1:SoftwareVersion', '14.0');
        SAFTTestHelper.AssertElementName(TempXMLBuffer, 'n1:Company');
        VerifyCompanyStructure(TempXMLBuffer, CompanyInformation);
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'n1:DefaultCurrencyCode', GeneralLedgerSetup."LCY Code");
        SAFTExportHeader.Get(SAFTExportLine.ID);
        SAFTTestHelper.AssertElementName(TempXMLBuffer, 'n1:SelectionCriteria');
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'n1:PeriodStart', format(Date2DMY(SAFTExportHeader."Starting Date", 2)));
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'n1:PeriodStartYear', format(Date2DMY(SAFTExportHeader."Starting Date", 3)));
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'n1:PeriodEnd', format(Date2DMY(SAFTExportHeader."Ending Date", 2)));
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'n1:PeriodEndYear', format(Date2DMY(SAFTExportHeader."Ending Date", 3)));
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'n1:TaxAccountingBasis', 'A');
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'n1:UserID', UserId());
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
            TempXMLBuffer, StrSubstNo('/n1:AuditFile/n1:MasterFiles/n1:GeneralLedgerAccounts/n1:Account/n1:%1', BalanceXMLNodeName), AmountText);
        SAFTTestHelper.AssertCurrentValue(
            TempXMLBuffer, StrSubstNo('/n1:AuditFile/n1:MasterFiles/n1:Customers/n1:Customer/n1:%1', BalanceXMLNodeName), AmountText);
        SAFTTestHelper.AssertCurrentValue(
            TempXMLBuffer, StrSubstNo('/n1:AuditFile/n1:MasterFiles/n1:Suppliers/n1:Supplier/n1:%1', BalanceXMLNodeName), AmountText);
    end;

    local procedure VerifyGeneralLedgerAccountsWithStdAccMapping(var TempXMLBuffer: Record "XML Buffer" temporary; MappingRangeCode: Code[20]; NumberOfMasterDataRecords: Integer)
    var
        GLAccount: Record "G/L Account";
        SAFTGLAccountMapping: Record "SAF-T G/L Account Mapping";
        SAFTMappingRange: Record "SAF-T Mapping Range";
        i: Integer;
    begin
        SAFTTestHelper.AssertElementName(TempXMLBuffer, 'n1:MasterFiles');
        SAFTTestHelper.AssertElementName(TempXMLBuffer, 'n1:GeneralLedgerAccounts');
        GLAccount.FindSet();
        SAFTMappingRange.Get(MappingRangeCode);
        // Income statement accounts
        for i := 1 to NumberOfMasterDataRecords do begin
            SAFTGLAccountMapping.Get(MappingRangeCode, GLAccount."No.");
            VerifyAccountHeader(TempXMLBuffer, GLAccount, SAFTGLAccountMapping);
            VerifyAccountAmounts(TempXMLBuffer, GLAccount, SAFTMappingRange, 'n1:OpeningDebitBalance', 'n1:ClosingDebitBalance');
            GLAccount.Next();
        end;
        // Balance sheet accounts (all but last)
        for i := 1 to (NumberOfMasterDataRecords - 1) do begin
            SAFTGLAccountMapping.Get(MappingRangeCode, GLAccount."No.");
            VerifyAccountHeader(TempXMLBuffer, GLAccount, SAFTGLAccountMapping);
            VerifyAccountAmounts(TempXMLBuffer, GLAccount, SAFTMappingRange, 'n1:OpeningCreditBalance', 'n1:ClosingDebitBalance');
            GLAccount.Next();
        end;
        // The last account has no entries but still exports.
        SAFTGLAccountMapping.Get(MappingRangeCode, GLAccount."No.");
        VerifyAccountHeader(TempXMLBuffer, GLAccount, SAFTGLAccountMapping);
        VerifyAccountAmounts(TempXMLBuffer, GLAccount, SAFTMappingRange, 'n1:OpeningCreditBalance', 'n1:ClosingCreditBalance');
    end;

    local procedure VerifyGeneralLedgerAccountsWithIncomeStatementMapping(var TempXMLBuffer: Record "XML Buffer" temporary; MappingRangeCode: Code[20])
    var
        GLAccount: Record "G/L Account";
        SAFTGLAccountMapping: Record "SAF-T G/L Account Mapping";
    begin
        Assert.IsTrue(TempXMLBuffer.FindNodesByXPath(TempXMLBuffer, '/n1:AuditFile/n1:MasterFiles/n1:GeneralLedgerAccounts/n1:Account'), 'No G/L accounts exported.');
        GLAccount.FindSet();
        repeat
            SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'n1:AccountID', GLAccount."No.");
            SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'n1:AccountDescription', GLAccount.Name);
            SAFTGLAccountMapping.Get(MappingRangeCode, GLAccount."No.");
            SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'n1:GroupingCategory', SAFTGLAccountMapping."Category No.");
            SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'n1:GroupingCode', SAFTGLAccountMapping."No.");
            SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'n1:AccountType', 'GL');
            SAFTTestHelper.FindNextElement(TempXMLBuffer); // skip opening balance check
            SAFTTestHelper.FindNextElement(TempXMLBuffer); // skip closing balance check
            SAFTTestHelper.FindNextElement(TempXMLBuffer); // skip n1:Account
        until GLAccount.Next() = 0;
    end;

    local procedure VerifyAccountHeader(var TempXMLBuffer: Record "XML Buffer" temporary; GLAccount: Record "G/L Account"; SAFTGLAccountMapping: Record "SAF-T G/L Account Mapping")
    begin
        SAFTTestHelper.AssertElementName(TempXMLBuffer, 'n1:Account');
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'n1:AccountID', GLAccount."No.");
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'n1:AccountDescription', GLAccount.Name);
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'n1:StandardAccountID', SAFTGLAccountMapping."No.");
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'n1:AccountType', 'GL');
    end;

    local procedure VerifyAccountAmounts(var TempXMLBuffer: Record "XML Buffer" temporary; GLAccount: Record "G/L Account"; SAFTMappingRange: Record "SAF-T Mapping Range"; OpeningBalanceNodeText: Text; ClosingBalanceNodeText: Text)
    begin
        GLAccount.SetRange("Date Filter", 0D, ClosingDate(SAFTMappingRange."Starting Date" - 1));
        GLAccount.CalcFields("Net Change");
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, OpeningBalanceNodeText, SAFTTestHelper.FormatAmount(GLAccount."Net Change"));
        GLAccount.SetRange("Date Filter", 0D, ClosingDate(SAFTMappingRange."Ending Date"));
        GLAccount.CalcFields("Net Change");
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, ClosingBalanceNodeText, SAFTTestHelper.FormatAmount(GLAccount."Net Change"));
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
        SAFTTestHelper.AssertElementName(TempXMLBuffer, 'n1:Customers');
        for i := 1 to NumberOfMasterDataRecords do begin
            SAFTTestHelper.AssertElementName(TempXMLBuffer, 'n1:Customer');
            SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'n1:RegistrationNumber', Customer."VAT Registration No.");
            SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'n1:Name', SAFTTestHelper.CombineWithSpace(Customer.Name, Customer."Name 2"));
            VerifyAddress(
                TempXMLBuffer, SAFTTestHelper.CombineWithSpace(Customer.Address, Customer."Address 2"),
                Customer.City, Customer."Post Code", Customer."Country/Region Code");
            VerifyContactSimple(
                TempXMLBuffer, Customer.Contact, Customer."Phone No.", Customer."Fax No.", Customer."E-Mail", Customer."Home Page");
            CustomerBankAccount.SetRange("Customer No.", Customer."No.");
            CustomerBankAccount.FindFirst();
            VerifyCompanyBankAccount(TempXMLBuffer, CustomerBankAccount."Bank Account No.");
            SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'n1:CustomerID', Customer."No.");
            CustomerPostingGroup.Get(Customer."Customer Posting Group");
            SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'n1:AccountID', CustomerPostingGroup."Receivables Account");
            Customer.SetRange("Date Filter", 0D, closingdate(SAFTMappingRange."Starting Date" - 1));
            Customer.CalcFields("Net Change (LCY)");
            SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'n1:OpeningCreditBalance', SAFTTestHelper.FormatAmount(Customer."Net Change (LCY)"));
            Customer.SetRange("Date Filter", 0D, closingdate(SAFTMappingRange."Ending Date"));
            Customer.CalcFields("Net Change (LCY)");
            SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'n1:ClosingDebitBalance', SAFTTestHelper.FormatAmount(Customer."Net Change (LCY)"));
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
        SAFTTestHelper.AssertElementName(TempXMLBuffer, 'n1:Suppliers');
        for i := 1 to NumberOfMasterDataRecords do begin
            SAFTTestHelper.AssertElementName(TempXMLBuffer, 'n1:Supplier');
            SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'n1:RegistrationNumber', Vendor."VAT Registration No.");
            SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'n1:Name', SAFTTestHelper.CombineWithSpace(Vendor.Name, Vendor."Name 2"));
            VerifyAddress(
                TempXMLBuffer, SAFTTestHelper.CombineWithSpace(Vendor.Address, Vendor."Address 2"),
                Vendor.City, Vendor."Post Code", Vendor."Country/Region Code");
            VerifyContactSimple(
                TempXMLBuffer, Vendor.Contact, Vendor."Phone No.", Vendor."Fax No.", Vendor."E-Mail", Vendor."Home Page");
            VendorBankAccount.SetRange("Vendor No.", Vendor."No.");
            VendorBankAccount.FindFirst();
            VerifyCompanyBankAccount(TempXMLBuffer, VendorBankAccount."Bank Account No.");
            SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'n1:SupplierID', Vendor."No.");
            VendorPostingGroup.Get(Vendor."Vendor Posting Group");
            SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'n1:AccountID', VendorPostingGroup."Payables Account");
            Vendor.SetRange("Date Filter", 0D, closingdate(SAFTMappingRange."Starting Date" - 1));
            Vendor.CalcFields("Net Change (LCY)");
            SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'n1:OpeningCreditBalance', SAFTTestHelper.FormatAmount(Vendor."Net Change (LCY)"));
            Vendor.SetRange("Date Filter", 0D, closingdate(SAFTMappingRange."Ending Date"));
            Vendor.CalcFields("Net Change (LCY)");
            SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'n1:ClosingDebitBalance', SAFTTestHelper.FormatAmount(Vendor."Net Change (LCY)"));
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
        SAFTTestHelper.AssertElementName(TempXMLBuffer, 'n1:TaxTable');
        SAFTTestHelper.AssertElementName(TempXMLBuffer, 'n1:TaxTableEntry');
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'n1:TaxType', 'MVA');
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'n1:Description', 'Merverdiavgift');
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
        SAFTTestHelper.AssertElementName(TempXMLBuffer, 'n1:AnalysisTypeTable');
        repeat
            SAFTTestHelper.AssertElementName(TempXMLBuffer, 'n1:AnalysisTypeTableEntry');
            Dimension.Get(DimensionValue."Dimension Code");
            SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'n1:AnalysisType', Dimension."SAF-T Analysis Type");
            SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'n1:AnalysisTypeDescription', Dimension.Name);
            SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'n1:AnalysisID', DimensionValue.Code);
            SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'n1:AnalysisIDDescription', DimensionValue.Name);
        until DimensionValue.Next() = 0;
    end;

    local procedure VerifySingleVATPostingSetup(var TempXMLBuffer: Record "XML Buffer" temporary; TaxCode: Integer; Description: Text; VATRate: Decimal; StandardTaxCode: Code[10]; Compensation: Boolean; DeductionRate: Decimal)
    var
        CompanyInformation: record "Company Information";
    begin
        CompanyInformation.Get();
        SAFTTestHelper.AssertElementName(TempXMLBuffer, 'n1:TaxCodeDetails');
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'n1:TaxCode', Format(TaxCode));
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'n1:Description', Description);
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'n1:TaxPercentage', SAFTTestHelper.FormatAmount(VATRate));
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'n1:Country', CompanyInformation."Country/Region Code");
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'n1:StandardTaxCode', StandardTaxCode);
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'n1:Compensation', Format(Compensation, 0, 9));
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'n1:BaseRate', SAFTTestHelper.FormatAmount(DeductionRate));
    end;

    local procedure VerifyCompanyStructure(var TempXMLBuffer: Record "XML Buffer" temporary; CompanyInformation: Record "Company Information")
    var
        Employee: Record Employee;
        BankAccount: Record "Bank Account";
    begin
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'n1:RegistrationNumber', CompanyInformation."Registration No.");
        SAFTTestHelper.AssertElementValue(
            TempXMLBuffer, 'n1:Name', SAFTTestHelper.CombineWithSpace(CompanyInformation.Name, CompanyInformation."Name 2"));
        VerifyAddress(
            TempXMLBuffer, SAFTTestHelper.CombineWithSpace(CompanyInformation.Address, CompanyInformation."Address 2"),
            CompanyInformation.City, CompanyInformation."Post Code", CompanyInformation."Country/Region Code");
        Employee.Get(CompanyInformation."SAF-T Contact No.");
        VerifyEmployee(
            TempXMLBuffer, Employee."First Name", Employee."Last Name", Employee."Phone No.",
             Employee."Fax No.", Employee."E-Mail", Employee."Mobile Phone No.");
        VerifyTaxRegistration(TempXMLBuffer, CompanyInformation);
        VerifyCompanyBankAccount(TempXMLBuffer, CompanyInformation."Bank Account No.");
        BankAccount.FindFirst();
        VerifyCompanyBankAccount(TempXMLBuffer, BankAccount."Bank Account No.");
    end;

    local procedure VerifyAddress(var TempXMLBuffer: Record "XML Buffer" temporary; StreetName: Text; City: Text; PostCode: Code[20]; CountryRegionCode: Code[20])
    begin
        SAFTTestHelper.AssertElementName(TempXMLBuffer, 'n1:Address');
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'n1:StreetName', StreetName);
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'n1:City', City);
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'n1:PostalCode', PostCode);
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'n1:Country', CountryRegionCode);
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'n1:AddressType', 'StreetAddress');
    end;

    local procedure VerifyContactSimple(var TempXMLBuffer: Record "XML Buffer" temporary; Name: Text; PhoneNo: Text; FaxNo: Text; Email: Text; HomePage: Text)
    var
        FirstName: Text;
        LastName: Text;
    begin
        SAFTTestHelper.GetFirstAndLastNameFromContactName(FirstName, LastName, Name);
        SAFTTestHelper.AssertElementName(TempXMLBuffer, 'n1:Contact');
        SAFTTestHelper.AssertElementName(TempXMLBuffer, 'n1:ContactPerson');
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'n1:FirstName', FirstName);
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'n1:LastName', LastName);
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'n1:Telephone', PhoneNo);
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'n1:Fax', FaxNo);
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'n1:Email', Email);
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'n1:Website', HomePage);
    end;

    local procedure VerifyEmployee(var TempXMLBuffer: Record "XML Buffer" temporary; FirstName: Text; LastName: Text; PhoneNo: Text; FaxNo: Text; Email: Text; MobilePhoneNo: Text)

    begin
        SAFTTestHelper.AssertElementName(TempXMLBuffer, 'n1:Contact');
        SAFTTestHelper.AssertElementName(TempXMLBuffer, 'n1:ContactPerson');
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'n1:FirstName', FirstName);
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'n1:LastName', LastName);
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'n1:Telephone', PhoneNo);
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'n1:Fax', FaxNo);
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'n1:Email', Email);
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'n1:MobilePhone', MobilePhoneNo);
    end;

    local procedure VerifyPartyInfo(var TempXMLBuffer: Record "XML Buffer" temporary; PaymentTermsCode: Code[10]; TableID: Integer; SourceNo: Code[20]);
    var
        PaymentTerms: Record "Payment Terms";
        DefaultDimension: Record "Default Dimension";
        Dimension: Record Dimension;
        SAFTExportMgt: Codeunit "SAF-T Export Mgt.";
    begin
        PaymentTerms.Get(PaymentTermsCode);
        SAFTTestHelper.AssertElementName(TempXMLBuffer, 'n1:PartyInfo');
        SAFTTestHelper.AssertElementName(TempXMLBuffer, 'n1:PaymentTerms');
        SAFTTestHelper.AssertElementValue(
            TempXMLBuffer, 'n1:Days', format(CalcDate(PaymentTerms."Due Date Calculation", WorkDate()) - WorkDate()));
        SAFTTestHelper.AssertElementValue(
            TempXMLBuffer, 'n1:CashDiscountDays', format(CalcDate(PaymentTerms."Discount Date Calculation", WorkDate()) - WorkDate()));
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'n1:CashDiscountRate', SAFTTestHelper.FormatAmount(PaymentTerms."Discount %"));
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'n1:CurrencyCode', SAFTExportMgt.GetISOCurrencyCode(''));
        DefaultDimension.SetRange("Table ID", TableID);
        DefaultDimension.SetRange("No.", SourceNo);
        DefaultDimension.FindSet();
        repeat
            SAFTTestHelper.AssertElementName(TempXMLBuffer, 'n1:Analysis');
            Dimension.get(DefaultDimension."Dimension Code");
            SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'n1:AnalysisType', Dimension."SAF-T Analysis Type");
            SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'n1:AnalysisID', DefaultDimension."Dimension Value Code");
        until DefaultDimension.Next() = 0;
    end;

    local procedure VerifyTaxRegistration(var TempXMLBuffer: Record "XML Buffer" temporary; CompanyInformation: Record "Company Information")
    begin
        SAFTTestHelper.AssertElementName(TempXMLBuffer, 'n1:TaxRegistration');
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'n1:TaxRegistrationNumber', CompanyInformation."VAT Registration No.");
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'n1:TaxAuthority', 'Skatteetaten');
    end;

    local procedure VerifyCompanyBankAccount(var TempXMLBuffer: Record "XML Buffer" temporary; BankAccountNumber: Text[30])
    var
        SAFTExportMgt: Codeunit "SAF-T Export Mgt.";
    begin
        SAFTTestHelper.AssertElementName(TempXMLBuffer, 'n1:BankAccount');
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'n1:BankAccountNumber', BankAccountNumber);
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'n1:CurrencyCode', SAFTExportMgt.GetISOCurrencyCode(''));
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
        Assert.IsTrue(TempXMLBuffer.FindNodesByXPath(TempXMLBuffer, '/n1:AuditFile/n1:GeneralLedgerEntries'), 'No G/L entries exported.');
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'n1:NumberOfEntries', format(CalcNumberOfTransactions(GLEntry)));
        GLEntry.CalcSums("Debit Amount", "Credit Amount");
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'n1:TotalDebit', SAFTTestHelper.FormatAmount(GLEntry."Debit Amount"));
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'n1:TotalCredit', SAFTTestHelper.FormatAmount(GLEntry."Credit Amount"));
        TempSAFTSourceCode.FindSet();
        repeat
            SAFTTestHelper.AssertElementName(TempXMLBuffer, 'n1:Journal');
            SourceCode.SetRange("SAF-T Source Code", TempSAFTSourceCode.Code);
            SourceCode.FindFirst();
            SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'n1:JournalID', TempSAFTSourceCode.Code);
            SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'n1:Description', TempSAFTSourceCode.Description);
            SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'n1:Type', TempSAFTSourceCode.Code);
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
            SAFTTestHelper.AssertElementName(TempXMLBuffer, 'n1:Transaction');
            GLEntry.SetRange("Transaction No.", GLEntry."Transaction No.");
            SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'n1:TransactionID', format(GLEntry."Document No."));
            SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'n1:Period', format(Date2DMY(GLEntry."Posting Date", 2)));
            SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'n1:PeriodYear', format(Date2DMY(GLEntry."Posting Date", 3)));
            SAFTTestHelper.AssertElementValue(
                TempXMLBuffer, 'n1:TransactionDate', SAFTTestHelper.FormatDate(GLEntry."Document Date"));
            SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'n1:SourceID', GLEntry."User ID");
            SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'n1:TransactionType', Format(GLEntry."Document Type"));
            SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'n1:Description', GLEntry.Description);
            SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'n1:BatchID', Format(GLEntry."Transaction No."));
            SAFTTestHelper.AssertElementValue(
                TempXMLBuffer, 'n1:SystemEntryDate', SAFTTestHelper.FormatDate(DT2Date(GLEntry."Last Modified DateTime")));
            SAFTTestHelper.AssertElementValue(
                TempXMLBuffer, 'n1:GLPostingDate', SAFTTestHelper.FormatDate(GLEntry."Posting Date"));
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
        SAFTTestHelper.AssertElementName(TempXMLBuffer, 'n1:Line');
        SAFTTestHelper.AssertElementName(TempXMLBuffer, 'n1:RecordID');
        SAFTTestHelper.AssertCurrentElementValue(TempXMLBuffer, 'n1:RecordID', Format(GLEntry."Entry No."));
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'n1:AccountID', GLEntry."G/L Account No.");
        VerifyDimensions(TempXMLBuffer, SAFTAnalysisType, DimValueCode);
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'n1:SourceDocumentID', GLEntry."Document No.");
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'n1:Description', GLEntry.Description);
        SAFTExportMgt.GetAmountInfoFromGLEntry(AmountXMLNode, Amount, GLEntry);
        VerifyAmountInfo(TempXMLBuffer, AmountXMLNode, Amount);
        VerifySalesVATEntry(TempXMLBuffer, GLEntry);
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'n1:ReferenceNumber', GLEntry."External Document No.");
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

        SAFTTestHelper.AssertElementName(TempXMLBuffer, 'n1:TaxInformation');
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'n1:TaxType', 'MVA');
        SAFTTestHelper.AssertElementValue(
            TempXMLBuffer, 'n1:TaxCode',
            Format(GetSAFTTaxCodeFromVATPostinSetup(VATPostingSetup, VATEntry.Type)));
        SAFTTestHelper.AssertElementValue(
            TempXMLBuffer, 'n1:TaxPercentage', SAFTTestHelper.FormatAmount(VATPostingSetup."VAT %"));
        SAFTTestHelper.AssertElementValue(
            TempXMLBuffer, 'n1:TaxBase', SAFTTestHelper.FormatAmount(abs(VATEntry.Base)));
        VerifyAmountInfo(TempXMLBuffer, 'TaxAmount', abs(VATEntry.Amount));
    end;

    local procedure VerifyXMLNodeOfMasterFile(SAFTExportHeader: Record "SAF-T Export Header"; XmlName: Text[250]; XmlValue: Text[250]);
    var
        SAFTExportLine: Record "SAF-T Export Line";
        TempXMLBuffer: Record "XML Buffer" temporary;
    begin
        SAFTExportLine.SetRange(Status, SAFTExportLine.Status::Completed);
        SAFTTestHelper.FindSAFTExportLine(SAFTExportLine, SAFTExportHeader.ID);
        SAFTTestHelper.LoadXMLBufferFromSAFTExportLine(TempXMLBuffer, SAFTExportLine);
        TempXMLBuffer.SetFilter(Name, XmlName);
        TempXMLBuffer.FindFirst();
        TempXMLBuffer.TestField(Value, XmlValue);
    END;

    local procedure VerifyNonExistingXMLNodeOfMasterFile(SAFTExportHeader: Record "SAF-T Export Header"; XmlName: Text[250]; XmlValue: Text[250]);
    var
        SAFTExportLine: Record "SAF-T Export Line";
        TempXMLBuffer: Record "XML Buffer" temporary;
    begin
        SAFTExportLine.SetRange(Status, SAFTExportLine.Status::Completed);
        SAFTTestHelper.FindSAFTExportLine(SAFTExportLine, SAFTExportHeader.ID);
        SAFTTestHelper.LoadXMLBufferFromSAFTExportLine(TempXMLBuffer, SAFTExportLine);
        TempXMLBuffer.SetRange(Name, XmlName);
        TempXMLBuffer.SetRange(Value, XmlValue);
        Assert.RecordIsEmpty(TempXMLBuffer);
    END;

    local procedure GetSAFTTaxCodeFromVATPostinSetup(VATPostingSetup: Record "VAT Posting Setup"; EntryType: Integer): Integer
    var
        VATEntry: Record "VAT Entry";
    begin
        case EntryType of
            VATEntry.Type::Purchase:
                exit(VATPostingSetup."Purchase SAF-T Tax Code");
            VATEntry.Type::Sale:
                exit(VATPostingSetup."Sales SAF-T Tax Code");
        end;
    end;

    local procedure VerifyDimensions(var TempXMLBuffer: Record "XML Buffer" temporary; SAFTAnalysisType: Code[9]; DimValueCode: Code[20])
    begin
        SAFTTestHelper.AssertElementName(TempXMLBuffer, 'n1:Analysis');
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'n1:AnalysisType', SAFTAnalysisType);
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'n1:AnalysisID', DimValueCode);
    end;

    local procedure VerifyAmountInfo(var TempXMLBuffer: Record "XML Buffer" temporary; AmountXMLNode: Text; Amount: Decimal)
    begin
        SAFTTestHelper.AssertElementName(TempXMLBuffer, 'n1:' + AmountXMLNode);
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'n1:Amount', SAFTTestHelper.FormatAmount(Amount));
    end;

    [ConfirmHandler]
    procedure ConfirmYesHandler(Question: Text; var Reply: Boolean)
    begin
        Assert.ExpectedMessage(LibraryVariableStorage.DequeueText(), Question);
        Reply := true;
    end;
}
