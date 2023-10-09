codeunit 148015 "SIE Import Export Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [SIE]
    end;

    var
        Assert: Codeunit Assert;
        SIETestHelper: Codeunit "SIE Test Helper";
        LibraryERM: Codeunit "Library - ERM";
        LibraryJournals: Codeunit "Library - Journals";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        LibraryTextFileValidation: Codeunit "Library - Text File Validation";
        LibraryDimension: Codeunit "Library - Dimension";
        LibraryRandom: Codeunit "Library - Random";
        LibraryUtility: Codeunit "Library - Utility";
        IncorrectPeriodStartDateErr: Label 'Incorrect period start date';
        IncorrectPeriodEndDateErr: Label 'Incorrect period end date';
        IsInitialized: Boolean;
        GLAccountNoFilterTxt: label 'No.: %1', Comment = '%1 - G/L Account No.';
        TransactionLineTxt: label '  #TRANS  %1  {}  %2  %3', Comment = '%1 - G/L Account No.; %2 - Amount; %3 - transaction date';

    [Test]
    [HandlerFunctions('ConfirmHandlerYes')]
    procedure SIE_Export_TRANS_Format()
    var
        GLAccountMappingLine: Record "G/L Account Mapping Line";
        GenJournalLine: Record "Gen. Journal Line";
        AuditFile: Record "Audit File";
        ExpectedLine: Text;
        FileInStream: InStream;
    begin
        // [FEATURE] [Export]
        // [SCENARIO 363105] SIE Export writes GLEntry's posting date to #TRANS section
        Initialize();
        SIETestHelper.CreateGLAccMappingWithLine(GLAccountMappingLine);

        // [GIVEN] Post General Journal Line with Date = "D", GLAccount "ACC", Amount = "AMT"
        CreatePostGenJnlLineWithBalAcc(GenJournalLine, GLAccountMappingLine."G/L Account No.");
        Commit();

        // [WHEN] Run SIE Export report
        RunSIEExport(AuditFile, GenJournalLine."Account No.", WorkDate(), WorkDate());

        // [THEN] Exported file containes #TRANS line with Date = "D", GLAccount = "ACC", Amount = "AMT"
        ExpectedLine :=
            StrSubstNo(TransactionLineTxt,
                GenJournalLine."Account No.", FormatAmount(GenJournalLine.Amount), FormatDate(WorkDate()));
        AuditFile.CalcFields("File Content");
        AuditFile."File Content".CreateInStream(FileInStream);
        Assert.ExpectedMessage(
            ExpectedLine,
            LibraryTextFileValidation.FindLineWithValue(FileInStream, 1, StrLen(ExpectedLine), ExpectedLine));
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerYes')]
    procedure SIEExportAccPeriodLessThanYear()
    var
        GLAccountMappingLine: Record "G/L Account Mapping Line";
        AuditFile: Record "Audit File";
        StartDate: Date;
        EndDate: Date;
        FileInStream: InStream;
    begin
        // [FEATURE] [Export]
        // [SCENARIO 378125] SIE Export writes accounting period ending date to #RAR section
        Initialize();
        SIETestHelper.CreateGLAccMappingWithLine(GLAccountMappingLine);

        // [GIVEN] Create fiscal year with period less than calendar year
        CreateNextFiscalYear(LibraryRandom.RandIntInRange(5, 10), StartDate, EndDate);
        Commit();

        // [WHEN] Run SIE Export report
        RunSIEExport(AuditFile, '', StartDate, EndDate);

        // [THEN] Exported file containes #RAR line for current fiscal year (#RAR  0) with proper starting and ending dates
        AuditFile.CalcFields("File Content");
        AuditFile."File Content".CreateInStream(FileInStream);
        VerifyLinePeriod(FileInStream, '#RAR  0', StartDate, EndDate);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerYes')]
    procedure SIEExportPrevAccPeriodLessThanYear()
    var
        GLAccountMappingLine: Record "G/L Account Mapping Line";
        AuditFile: Record "Audit File";
        PrevFYStartDate: Date;
        PrevFYEndDate: Date;
        LastFYStartDate: Date;
        LastFYEndDate: Date;
        FileInStream: InStream;
    begin
        // [FEATURE] [Export]
        // [SCENARIO 378125] SIE Export writes previous accounting period ending date to #RAR section
        Initialize();
        SIETestHelper.CreateGLAccMappingWithLine(GLAccountMappingLine);

        // [GIVEN] Create 2 fiscal years with period less than calendar year
        CreateNextFiscalYear(LibraryRandom.RandIntInRange(5, 10), PrevFYStartDate, PrevFYEndDate);
        CreateNextFiscalYear(LibraryRandom.RandIntInRange(5, 10), LastFYStartDate, LastFYEndDate);
        Commit();

        // [WHEN] Run SIE Export report
        RunSIEExport(AuditFile, '', LastFYStartDate, LastFYEndDate);

        // [THEN] Exported file containes #RAR line for previous fiscal year (#RAR  -1) with proper starting and ending dates
        AuditFile.CalcFields("File Content");
        AuditFile."File Content".CreateInStream(FileInStream);
        VerifyLinePeriod(FileInStream, '#RAR  -1', PrevFYStartDate, PrevFYEndDate);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerYes,SIEImportRPH,GeneralJournalPageHandler')]
    procedure SIEImportGLAccountFieldsValidateInGJLine()
    var
        GLAccountMappingLine: Record "G/L Account Mapping Line";
        GenJournalLine: Record "Gen. Journal Line";
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
        AuditFile: Record "Audit File";
        TempBlob: Codeunit "Temp Blob";
    begin
        // [FEATURE] [Export] [Import]
        // [SCENARIO 309471] SIE Import validates VAT and Posting fields from GLAccount posted in documents having spaces in No.
        Initialize();
        SIETestHelper.CreateGLAccMappingWithLine(GLAccountMappingLine);

        // [GIVEN] Post General Journal Line with GLAccount "Acc"
        CreatePostGenJnlLineWithBalAcc(GenJournalLine, GLAccountMappingLine."G/L Account No.");
        Commit();

        // [GIVEN] Exported file saved on the server
        RunSIEExport(AuditFile, GenJournalLine."Account No.", WorkDate(), WorkDate());
        CopyAuditFileToTempBlob(AuditFile, TempBlob);

        // [GIVEN] Add VAT and Posting setup to the 'Acc'
        ModifyGLAccountWithVatSetup(GenJournalLine."Account No.");

        // [GIVEN] Gen. Journal Template "GJT" and Gen. Journal Batch "GJB"
        LibraryERM.CreateGenJournalTemplate(GenJournalTemplate);
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);

        // [WHEN] Run SIE Import with "GJT" and "GJB"
        LibraryVariableStorage.Enqueue(GenJournalTemplate.Name);
        LibraryVariableStorage.Enqueue(GenJournalBatch.Name);
        Commit();
        RunSIEImport(TempBlob);

        // [THEN] VAT and Posting fields on imported Gen. Journal Line are the same as on GLAccount
        VerifyImportedGenJnlLine(GenJournalTemplate.Name, GenJournalBatch.Name, GenJournalLine."Account No.");
    end;

    [Test]
    [HandlerFunctions('SIEImportInsertGLAccountRequestPageHandler,ConfirmHandlerYes,GeneralJournalPageHandler')]
    procedure SIEImportEmptyGLAccountNo()
    var
        GLAccountMappingLine: Record "G/L Account Mapping Line";
        GLAccount: Record "G/L Account";
        GenJournalBatch: Record "Gen. Journal Batch";
        AuditFile: Record "Audit File";
        TempBlob: Codeunit "Temp Blob";
        GLAccountNo: Code[20];
    begin
        // [FEATURE] [Import]
        // [SCENARIO 372202] Run SIE Import on file that contains #KONTO line with empty No and Name.
        Initialize();
        CreateGenJournalBatch(GenJournalBatch);
        SIETestHelper.CreateGLAccMappingWithLine(GLAccountMappingLine);

        // [GIVEN] SIE file, that contains two #KONTO lines.
        // [GIVEN] First #KONTO line is with alphanumeric No = "GLNO" and Name = "GLNAME": #KONTO  1GU00000000000000000  "1GU00000000000000000".
        // [GIVEN] Second #KONTO line is with spaces in place of No and Name: #KONTO        .
        GLAccountNo := GLAccountMappingLine."G/L Account No.";
        Commit();
        RunSIEExport(AuditFile, GLAccountNo, WorkDate(), WorkDate());
        CopyAuditFileToTempBlob(AuditFile, TempBlob);
        AddLineWithEmptyKONTONoAndName(TempBlob);

        // [GIVEN] G/L Account with No "GLNO" does not exist.
        GLAccount.Get(GLAccountNo);
        GLAccount.Delete();

        // [WHEN] Run SIE Import report on this SIE file with option Insert G/L Account set.
        LibraryVariableStorage.Enqueue(GenJournalBatch."Journal Template Name");
        LibraryVariableStorage.Enqueue(GenJournalBatch.Name);
        Commit();
        RunSIEImport(TempBlob);

        // [THEN] G/L Account "GLNO" is created. G/L Account with empty No is not created.
        GLAccount.Get(GLAccountNo);
        asserterror GLAccount.Get();
        Assert.ExpectedError('The G/L Account does not exist.');
        Assert.ExpectedErrorCode('DB:RecordNotFound');

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    procedure SIEUpdateShortcutDimensionForNotLinkedSIEDimension()
    var
        Dimension: Record Dimension;
        GeneralLedgerSetup: Record "General Ledger Setup";
        DimensionSIE: Record "Dimension SIE";
    begin
        // [FEATURE] [Dimensions]
        // [SCENARIO 381234] Changing of Shortcut dimension updates ShortCutDimNo in SIE Dimension
        Initialize();

        // [GIVEN] SIE Dimension "D" not linked to any Shortcut Dimension
        LibraryDimension.CreateDimension(Dimension);
        DimensionSIE.Validate("Dimension Code", Dimension.Code);
        DimensionSIE.Insert(true);
        DimensionSIE.TestField(ShortCutDimNo, 0);

        // [WHEN] Set dimension "D" as Shortcut Dimension 3 in G/L Setup
        GeneralLedgerSetup.Get();
        GeneralLedgerSetup.Validate("Shortcut Dimension 3 Code", Dimension.Code);
        GeneralLedgerSetup.Modify(true);

        // [THEN] SIE Dimension "D" linked with ShortCutDimNo = 3
        DimensionSIE.Find();
        DimensionSIE.TestField(ShortCutDimNo, 3);
    end;

    [Test]
    procedure SIEClearShortcutDimensionForLinkedSIEDimension()
    var
        Dimension: Record Dimension;
        GeneralLedgerSetup: Record "General Ledger Setup";
        DimensionSIE: Record "Dimension SIE";
    begin
        // [FEATURE] [Dimensions]
        // [SCENARIO 381234] Deleting of Shortcut dimension clears ShortCutDimNo in SIE Dimension to 0
        Initialize();

        // [GIVEN] Shortcut Dimension 4 has value dimension "D"
        LibraryDimension.CreateDimension(Dimension);
        GeneralLedgerSetup.Get();
        GeneralLedgerSetup.Validate("Shortcut Dimension 4 Code", Dimension.Code);
        GeneralLedgerSetup.Modify();

        // [GIVEN] SIE Dimension "D" linked to Shortcut Dimension 4
        DimensionSIE.Validate("Dimension Code", Dimension.Code);
        DimensionSIE.Insert(true);
        DimensionSIE.TestField(ShortCutDimNo, 4);

        // [WHEN] Clear Shortcut Dimension 4 in G/L Setup
        GeneralLedgerSetup.Validate("Shortcut Dimension 4 Code", '');
        GeneralLedgerSetup.Modify(true);

        // [THEN] SIE Dimension "D" has ShortCutDimNo = 0
        DimensionSIE.Find();
        DimensionSIE.TestField(ShortCutDimNo, 0);
    end;

    [Test]
    procedure SIEReplaceShortcutDimensionForTwoSIEDimensions()
    var
        Dimension1: Record Dimension;
        Dimension2: Record Dimension;
        GeneralLedgerSetup: Record "General Ledger Setup";
        DimensionSIE1: Record "Dimension SIE";
        DimensionSIE2: Record "Dimension SIE";
    begin
        // [FEATURE] [Dimensions]
        // [SCENARIO 381234] Replacing of Shortcut dimension updates ShortCutDimNo in SIE Dimension
        Initialize();

        // [GIVEN] Shortcut Dimension 5 has dimension "D1"
        LibraryDimension.CreateDimension(Dimension1);
        LibraryDimension.CreateDimension(Dimension2);

        GeneralLedgerSetup.Get();
        GeneralLedgerSetup.Validate("Shortcut Dimension 5 Code", Dimension1.Code);
        GeneralLedgerSetup.Modify(true);

        // SIE Dimension "D1" is linked to Shortcut Dimension 5
        DimensionSIE1.Validate("Dimension Code", Dimension1.Code);
        DimensionSIE1.Insert(true);
        DimensionSIE1.TestField(ShortCutDimNo, 5);
        // SIE Dimension "D2" is not linked to any Shortcut Dimension
        DimensionSIE2.Validate("Dimension Code", Dimension2.Code);
        DimensionSIE2.Insert(true);
        DimensionSIE2.TestField(ShortCutDimNo, 0);

        // [WHEN] Replace Shortcut Dimension 5 with dimension "D2"
        GeneralLedgerSetup.Validate("Shortcut Dimension 5 Code", Dimension2.Code);
        GeneralLedgerSetup.Modify(true);

        // [THEN] SIE Dimension "D1" has ShortCutDimNo = 0
        // [THEN] SIE Dimension "D2" has ShortCutDimNo = 5
        DimensionSIE1.Find();
        DimensionSIE1.TestField(ShortCutDimNo, 0);
        DimensionSIE2.Find();
        DimensionSIE2.TestField(ShortCutDimNo, 5);
    end;

    [Test]
    [HandlerFunctions('SIEImportInsertGLAccountRequestPageHandler,ConfirmHandlerYes,GeneralJournalPageHandler')]
    procedure VATDateWhenRunSIEImport()
    var
        GLAccountMappingLine: Record "G/L Account Mapping Line";
        GenJournalLine: Record "Gen. Journal Line";
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
        AuditFile: Record "Audit File";
        TempBlob: Codeunit "Temp Blob";
        PostingDate: Date;
    begin
        // [FEATURE] [Import]
        // [SCENARIO 463175] VAT Reporting Date in General Journal when run SIE Import.
        Initialize();
        SIETestHelper.CreateGLAccMappingWithLine(GLAccountMappingLine);

        // [GIVEN] Posted General Journal Line with Posting Date "D1".
        PostingDate := LibraryRandom.RandDateFromInRange(WorkDate(), 1, 5);
        LibraryJournals.CreateGenJournalLineWithBatch(
            GenJournalLine, GenJournalLine."Document Type"::Payment, GenJournalLine."Account Type"::"G/L Account",
            GLAccountMappingLine."G/L Account No.", LibraryRandom.RandDecInRange(1000, 2000, 2));
        GenJournalLine.Validate("Posting Date", PostingDate);
        GenJournalLine.Modify(true);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
        Commit();

        // [GIVEN] Exported SIE file.
        RunSIEExport(AuditFile, GenJournalLine."Account No.", PostingDate, PostingDate);
        CopyAuditFileToTempBlob(AuditFile, TempBlob);

        // [GIVEN] General Journal Template "T" and General Journal Batch "B".
        LibraryERM.CreateGenJournalTemplate(GenJournalTemplate);
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);

        // [WHEN] Run SIE Import to General Journal with template "T" and batch "B".
        LibraryVariableStorage.Enqueue(GenJournalTemplate.Name);
        LibraryVariableStorage.Enqueue(GenJournalBatch.Name);
        Commit();
        RunSIEImport(TempBlob);

        // [THEN] General Journal Line is created. Posting Date, Document Date, VAT Registration Date are equal to "D1".
        VerifyDatesOnGenJournalLine(
            GenJournalTemplate.Name, GenJournalBatch.Name, GenJournalLine."Account No.", PostingDate, PostingDate, PostingDate);
    end;

    [Test]
    procedure SIEExportStartingDateBeforeAccountingPeriod()
    var
        GLAccountMappingLine: Record "G/L Account Mapping Line";
        AuditFileExportHeader: Record "Audit File Export Header";
        GenJournalLine: Record "Gen. Journal Line";
        AccountingPeriod: Record "Accounting Period";
        AuditFileExportMgt: Codeunit "Audit File Export Mgt.";
        StartingDate: Date;
    begin
        // [FEATURE] [Export]
        // [SCENARIO 463103] Start export when Starting Date is less than the starting date of the first accounting period.
        Initialize();
        SIETestHelper.CreateGLAccMappingWithLine(GLAccountMappingLine);

        // [GIVEN] Audit File Export Document with Starting Date 01.01.2010, which is less than the starting date of the first accounting period.
        AccountingPeriod.SetRange("New Fiscal Year", true);
        AccountingPeriod.FindFirst();
        StartingDate := CalcDate('<-1Y>', AccountingPeriod."Starting Date");
        SIETestHelper.CreateAuditFileExportDoc(
            AuditFileExportHeader, StartingDate, WorkDate(), "File Type SIE"::"4. Transactions",
            StrSubstNo(GLAccountNoFilterTxt, GenJournalLine."Account No."));

        // [WHEN] Run SIE Export report
        asserterror AuditFileExportMgt.StartExport(AuditFileExportHeader);

        // [THEN] Error message is shown.
        Assert.ExpectedError(StrSubstNo('The starting date %1 must be within the existing accounting period.', StartingDate));
        Assert.ExpectedErrorCode('Dialog');
    end;

    [Test]
    procedure SIEExportStartingDateAfterAccountingPeriod()
    var
        GLAccountMappingLine: Record "G/L Account Mapping Line";
        AuditFileExportHeader: Record "Audit File Export Header";
        GenJournalLine: Record "Gen. Journal Line";
        AccountingPeriod: Record "Accounting Period";
        AuditFileExportMgt: Codeunit "Audit File Export Mgt.";
        StartingDate: Date;
    begin
        // [FEATURE] [Export]
        // [SCENARIO 463103] Start export when Starting Date is greater than the starting date of the last accounting period.
        Initialize();
        SIETestHelper.CreateGLAccMappingWithLine(GLAccountMappingLine);

        // [GIVEN] Audit File Export Document with Starting Date 01.01.2030, which is greater than the starting date of the last accounting period.
        AccountingPeriod.SetRange("New Fiscal Year", true);
        AccountingPeriod.FindLast();
        StartingDate := CalcDate('<1Y>', AccountingPeriod."Starting Date");
        SIETestHelper.CreateAuditFileExportDoc(
            AuditFileExportHeader, StartingDate, WorkDate(), "File Type SIE"::"4. Transactions",
            StrSubstNo(GLAccountNoFilterTxt, GenJournalLine."Account No."));

        // [WHEN] Run SIE Export report.
        asserterror AuditFileExportMgt.StartExport(AuditFileExportHeader);

        // [THEN] Error message is shown.
        Assert.ExpectedError(StrSubstNo('There must be the accounting period next to the accounting period %1.', AccountingPeriod."Starting Date"));
        Assert.ExpectedErrorCode('Dialog');
    end;

    [Test]
    procedure SetSIEFormatToDocumentWhenSetupNotExist()
    var
        AuditFileExportHeader: Record "Audit File Export Header";
        AuditFileExportFormatSetup: Record "Audit File Export Format Setup";
        SIEManagement: Codeunit "SIE Management";
    begin
        // [FEATURE] [Export]
        // [SCENARIO 463103] Set export format to SIE for Audit Document when Export Format Setup for SIE does not exist.
        Initialize();

        // [GIVEN] There is no Audit File Export Setup for SIE format.
        AuditFileExportFormatSetup.SetRange("Audit File Export Format", "Audit File Export Format"::SIE);
        AuditFileExportFormatSetup.DeleteAll();

        // [WHEN] Set Export Format SIE to Audit File Export Document.
        asserterror AuditFileExportHeader.Validate("Audit File Export Format", "Audit File Export Format"::SIE);

        // [THEN] Error message is shown.
        Assert.ExpectedError('Audit File Export Format Setup does not exist for the SIE export format.');
        Assert.ExpectedErrorCode('Dialog');

        // restore setup
        AuditFileExportFormatSetup.InitSetup("Audit File Export Format"::SIE, SIEManagement.GetAuditFileName(), false);
    end;

    [Test]
    procedure DefaultMappingSIEWhenOpenWizard()
    var
        GLAccountMappingHeader: Record "G/L Account Mapping Header";
        SIESetupWizard: TestPage "SIE Setup Wizard";
    begin
        // [FEATURE] [Export]
        // [SCENARIO 463103] Code for default Mapping SIE when SIE wizard page is opened.
        Initialize();

        // [WHEN] Open SIE wizard page.
        SIESetupWizard.OpenEdit();

        // [THEN] Mapping Header with code "DEFAULT SIE" is created.
        GLAccountMappingHeader.SetRange("Audit File Export Format", "Audit File Export Format"::SIE);
        GLAccountMappingHeader.FindFirst();
        Assert.AreEqual('DEFAULT SIE', GLAccountMappingHeader.Code, '');
    end;

    local procedure Initialize()
    begin
        LibraryVariableStorage.Clear();
        DeleteDocumentsAndMapping();

        if IsInitialized then
            exit;

        BindSubscription(SIETestHelper);    // IsSIEFeatureEnabled returns true, see EnableSIEFeatureOnInitializeFeatureDataUpdateStatus
        SIETestHelper.SetupSIE();
        Commit();

        IsInitialized := true;
    end;

    local procedure AddLineWithEmptyKONTONoAndName(var TempBlob: Codeunit "Temp Blob")
    var
        TypeHelper: Codeunit "Type Helper";
        CRLF: Text[2];
        FileOutStream: OutStream;
    begin
        CRLF := TypeHelper.CRLFSeparator();
        TempBlob.CreateOutStream(FileOutStream);
        FileOutStream.WriteText('#KONTO        ' + CRLF);
    end;

    local procedure CreatePostGenJnlLineWithBalAcc(var GenJournalLine: Record "Gen. Journal Line"; GLAccountNo: Code[20])
    begin
        LibraryJournals.CreateGenJournalLineWithBatch(
            GenJournalLine, GenJournalLine."Document Type"::Payment, GenJournalLine."Account Type"::"G/L Account",
            GLAccountNo, LibraryRandom.RandDecInRange(1000, 2000, 2));

        // TFS334845: The SIE export file cannot be used if the customer has a space character in a document number.
        GenJournalLine."Document No." := CopyStr(LibraryUtility.GenerateGUID() + ' A A', 1, MaxStrLen(GenJournalLine."Document No."));
        GenJournalLine.Modify(true);

        LibraryERM.PostGeneralJnlLine(GenJournalLine);
    end;

    local procedure CreateGenJournalBatch(var GenJournalBatch: Record "Gen. Journal Batch")
    var
        GenJournalTemplate: Record "Gen. Journal Template";
    begin
        LibraryERM.CreateGenJournalTemplate(GenJournalTemplate);
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);
    end;

    local procedure CreateNextFiscalYear(NumberOfMonth: Integer; var StartDate: Date; var EndDate: Date)
    var
        AccountingPeriod: Record "Accounting Period";
        CreateFiscalYear: Report "Create Fiscal Year";
        PeriodLength: DateFormula;
    begin
        StartDate := GetNextFiscalYearStartDate();
        Evaluate(PeriodLength, '<1M>');
        CreateFiscalYear.InitializeRequest(NumberOfMonth, PeriodLength, StartDate);
        CreateFiscalYear.UseRequestPage(false);
        CreateFiscalYear.Run();

        EndDate := AccountingPeriod.GetFiscalYearEndDate(StartDate);
    end;

    local procedure CopyAuditFileToTempBlob(var AuditFile: Record "Audit File"; var TempBlob: Codeunit "Temp Blob")
    var
        FileInStream: InStream;
        FileOutStream: OutStream;
    begin
        TempBlob.CreateOutStream(FileOutStream);
        AuditFile.CalcFields("File Content");
        AuditFile."File Content".CreateInStream(FileInStream);
        CopyStream(FileOutStream, FileInStream);
    end;

    local procedure ModifyGLAccountWithVatSetup(GLAccountNo: Code[20])
    var
        VATPostingSetup: Record "VAT Posting Setup";
        GeneralPostingSetup: Record "General Posting Setup";
        GLAccount: Record "G/L Account";
    begin
        LibraryERM.FindGeneralPostingSetup(GeneralPostingSetup);
        LibraryERM.FindVATPostingSetup(VATPostingSetup, "General Posting Type"::" ");
        GLAccount.Get(GLAccountNo);
        GLAccount.Validate("Account Type", GLAccount."Account Type"::Posting);
        LibraryERM.UpdateGLAccountWithPostingSetup(GLAccount, "General Posting Type"::Purchase, GeneralPostingSetup, VATPostingSetup);
    end;

    local procedure GetNextFiscalYearStartDate(): Date
    var
        AccountingPeriod: Record "Accounting Period";
    begin
        AccountingPeriod.SetRange("New Fiscal Year", true);
        if AccountingPeriod.FindLast() then
            exit(AccountingPeriod."Starting Date");

        exit(CalcDate('<-CY>', WorkDate()));
    end;

    local procedure DeleteDocumentsAndMapping()
    var
        AuditFileExportHeader: Record "Audit File Export Header";
        AuditFileExportLine: Record "Audit File Export Line";
        AuditFile: Record "Audit File";
        GLAccountMappingHeader: Record "G/L Account Mapping Header";
        GLAccountMappingLine: Record "G/L Account Mapping Line";
    begin
        AuditFile.DeleteAll();
        AuditFileExportLine.DeleteAll(true);
        AuditFileExportHeader.DeleteAll();

        GLAccountMappingLine.DeleteAll();
        GLAccountMappingHeader.DeleteAll();
    end;

    local procedure RunSIEExport(var AuditFile: Record "Audit File"; GLAccountNo: Code[20]; StartDate: Date; EndDate: Date)
    var
        AuditFileExportHeader: Record "Audit File Export Header";
        AuditFileExportMgt: Codeunit "Audit File Export Mgt.";
    begin
        SIETestHelper.CreateAuditFileExportDoc(
            AuditFileExportHeader, StartDate, EndDate, "File Type SIE"::"4. Transactions", StrSubstNo(GLAccountNoFilterTxt, GLAccountNo));
        AuditFileExportMgt.StartExport(AuditFileExportHeader);
        AuditFile.SetRange("Export ID", AuditFileExportHeader.ID);
        AuditFile.FindFirst();
    end;

    local procedure RunSIEImport(var TempBlob: Codeunit "Temp Blob")
    var
        ImportSIE: Report "Import SIE";
    begin
        ImportSIE.UseRequestPage(true);
        ImportSIE.InitializeRequest(TempBlob);
        ImportSIE.RunModal();
    end;

    local procedure FormatAmount(Amount: Decimal) ReturnText: Text[30]
    begin
        exit(CopyStr(ConvertStr(Format(Amount, 0, '<Sign><Integer><decimal>'), ',', '.'), 1, MaxStrLen(ReturnText)));
    end;

    local procedure FormatDate(Date: Date): Text[30]
    begin
        exit(Format(Date, 8, '<Year4><month,2><day,2>'));
    end;

    local procedure VerifyLinePeriod(FileInStream: InStream; PeriodSubstring: Code[10]; ExpectedStartDate: Date; ExpectedEndDate: Date)
    var
        LineText: Text;
        ExpectedStartDateAsText: Text;
        ExpectedEndDateAsText: Text;
    begin
        ExpectedStartDateAsText := FormatDate(ExpectedStartDate);
        ExpectedEndDateAsText := FormatDate(ExpectedEndDate);
        LineText := LibraryTextFileValidation.FindLineContainingValue(FileInStream, 1, 1000, PeriodSubstring);
        Assert.AreEqual(ExpectedStartDateAsText, CopyStr(LineText, StrLen(PeriodSubstring) + 3, 8), IncorrectPeriodStartDateErr);
        Assert.AreEqual(ExpectedEndDateAsText, CopyStr(LineText, StrLen(PeriodSubstring) + 15, 8), IncorrectPeriodEndDateErr);
    end;

    local procedure VerifyImportedGenJnlLine(GenJournalTemplateName: Code[10]; GenJournalBatchName: Code[10]; GLAccountNo: Code[20])
    var
        GenJournalLine: Record "Gen. Journal Line";
        GLAccount: Record "G/L Account";
    begin
        GLAccount.Get(GLAccountNo);
        GenJournalLine.SetRange("Journal Template Name", GenJournalTemplateName);
        GenJournalLine.SetRange("Journal Batch Name", GenJournalBatchName);
        GenJournalLine.SetRange("Account No.", GLAccount."No.");
        GenJournalLine.FindFirst();
        GenJournalLine.TestField("Gen. Posting Type", GLAccount."Gen. Posting Type");
        GenJournalLine.TestField("Gen. Bus. Posting Group", GLAccount."Gen. Bus. Posting Group");
        GenJournalLine.TestField("Gen. Prod. Posting Group", GLAccount."Gen. Prod. Posting Group");
        GenJournalLine.TestField("VAT Prod. Posting Group", GLAccount."VAT Prod. Posting Group");
        GenJournalLine.TestField("VAT Bus. Posting Group", GLAccount."VAT Bus. Posting Group");
    end;

    local procedure VerifyDatesOnGenJournalLine(GenJournalTemplateName: Code[10]; GenJournalBatchName: Code[10]; GLAccountNo: Code[20]; PostingDate: Date; DocumentDate: Date; VATDate: Date)
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        GenJournalLine.SetRange("Journal Template Name", GenJournalTemplateName);
        GenJournalLine.SetRange("Journal Batch Name", GenJournalBatchName);
        GenJournalLine.SetRange("Account No.", GLAccountNo);
        GenJournalLine.FindFirst();
        GenJournalLine.TestField("Posting Date", PostingDate);
        GenJournalLine.TestField("Document Date", DocumentDate);
        GenJournalLine.TestField("VAT Reporting Date", VATDate);
    end;

    [RequestPageHandler]
    procedure SIEImportRPH(var ImportSIE: TestRequestPage "Import SIE")
    begin
        ImportSIE.JournalTemplateName.SetValue(LibraryVariableStorage.DequeueText());
        ImportSIE.JournalBatchName.SetValue(LibraryVariableStorage.DequeueText());
        ImportSIE.OK().Invoke();
    end;

    [RequestPageHandler]
    procedure SIEImportInsertGLAccountRequestPageHandler(var SIEImport: TestRequestPage "Import SIE")
    begin
        SIEImport.JournalTemplateName.SetValue(LibraryVariableStorage.DequeueText());  // Gen. Journal Template
        SIEImport.JournalBatchName.SetValue(LibraryVariableStorage.DequeueText());  // Gen. Journal Batch
        SIEImport.InsertNewAccField.SetValue(true);  // Insert G/L Account
        SIEImport.OK().Invoke();
    end;

    [PageHandler]
    procedure GeneralJournalPageHandler(var GeneralJournal: TestPage "General Journal")
    begin
        GeneralJournal.Close();
    end;

    [ConfirmHandler]
    procedure ConfirmHandlerYes(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := true;
    end;
}

