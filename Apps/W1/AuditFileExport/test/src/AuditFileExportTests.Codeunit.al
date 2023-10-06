codeunit 148035 "Audit File Export Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Audit File Export]
    end;

    var
        AuditFileExportTestHelper: Codeunit "Audit File Export Test Helper";
        LibraryERM: Codeunit "Library - ERM";
        LibraryRandom: Codeunit "Library - Random";
        LibraryMarketing: Codeunit "Library - Marketing";
        Assert: Codeunit Assert;
        IsInitialized: Boolean;
        AddressMustHaveValueErr: label 'Address must have a value in Contact: No.=%1', Comment = '%1 - Contact No.';
        CommentMustHaveValueErr: label 'Header Comment must have a value in Audit File Export Header: ID=%1', Comment = 'Audit File Export Header ID';

    [Test]
    [HandlerFunctions('ConfirmHandlerYes')]
    procedure ExportAuditFiles()
    var
        GLAccountMappingHeader: Record "G/L Account Mapping Header";
        AuditFileExportHeader: Record "Audit File Export Header";
        TempBlob: Codeunit "Temp Blob";
        MappedGLAccountNos: List of [Code[20]];
        DocumentNos: List of [Code[20]];
        Amounts: List of [Decimal];
        AuditFileNames: List of [Text[1024]];
    begin
        // [SCENARIO 452704] Export audit files.
        Initialize();

        // [GIVEN] Audit File Export Format "TEST" set up.
        // [GIVEN] Implemented procedure CreateAuditFileExportLines() which creates three lines - Master Data, G/L Entries, Source Documents.
        // [GIVEN] Implemented procedure GenerateFileContentForAuditDocLine().

        // [GIVEN] G/L Account Mapping with three lines with Standard Account No. "1111", "2222", "3333".
        AuditFileExportTestHelper.CreateGLAccMappingWithLines(GLAccountMappingHeader, MappedGLAccountNos);

        // [GIVEN] Posted payment for each mapped G/L Account.
        CreateAndPostGenJnlLines(DocumentNos, Amounts, MappedGLAccountNos);

        // [GIVEN] Audit File Export document with Archive to Zip not set.
        AuditFileExportTestHelper.CreateAuditFileExportDoc(AuditFileExportHeader, WorkDate(), WorkDate(), false);

        // [WHEN] Start export.
        AuditFileExportTestHelper.StartExport(AuditFileExportHeader);

        // [THEN] Three files were created - MasterData.txt, GLEntry.txt, SourceDocument.txt.
        AuditFileNames.AddRange('MasterData.txt', 'GLEntry.txt', 'SourceDocument.txt');
        VerifyAuditFileCountAndNames(AuditFileExportHeader, AuditFileNames);

        // [THEN] MasterData.txt contains Header Comment, Contact and list of mapped G/L Accounts.
        GetAuditFileContent(AuditFileNames.Get(1), TempBlob);
        VerifyAuditFileWithMasterData(AuditFileExportHeader, TempBlob, MappedGLAccountNos);

        // [THEN] GLEntry.txt contains list of G/L Entries for mapped G/L Accounts.
        GetAuditFileContent(AuditFileNames.Get(2), TempBlob);
        VerifyAuditFileWithGLEntries(TempBlob, MappedGLAccountNos, DocumentNos, Amounts);

        // [THEN] SourceDocument.txt contains one line "Source Document File Content".
        GetAuditFileContent(AuditFileNames.Get(3), TempBlob);
        VerifyAuditFileWithSourceDocs(TempBlob);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerYes')]
    procedure ExportAuditFilesToZip()
    var
        GLAccountMappingHeader: Record "G/L Account Mapping Header";
        AuditFileExportHeader: Record "Audit File Export Header";
        TempBlob: Codeunit "Temp Blob";
        ZipTempBlob: Codeunit "Temp Blob";
        DataCompression: Codeunit "Data Compression";
        MappedGLAccountNos: List of [Code[20]];
        DocumentNos: List of [Code[20]];
        Amounts: List of [Decimal];
        AuditFileNames: List of [Text[1024]];
        ZipEntryList: List of [Text];
        ZipFileName: Text[1024];
    begin
        // [SCENARIO 452704] Export audit files.
        Initialize();

        // [GIVEN] Audit File Export Format "TEST" set up.
        // [GIVEN] Implemented procedure CreateAuditFileExportLines() which creates three lines - Master Data, G/L Entries, Source Documents.
        // [GIVEN] Implemented procedure GenerateFileContentForAuditDocLine().

        // [GIVEN] G/L Account Mapping with three lines with Standard Account No. "1111", "2222", "3333".
        AuditFileExportTestHelper.CreateGLAccMappingWithLines(GLAccountMappingHeader, MappedGLAccountNos);

        // [GIVEN] Posted payment for each mapped G/L Account.
        CreateAndPostGenJnlLines(DocumentNos, Amounts, MappedGLAccountNos);

        // [GIVEN] Audit File Export document with Archive to Zip set and Audit File Name "AuditFiles.zip".
        AuditFileExportTestHelper.CreateAuditFileExportDoc(AuditFileExportHeader, WorkDate(), WorkDate(), true);
        ZipFileName := 'AuditFiles.zip';
        AuditFileExportHeader."Audit File Name" := ZipFileName;
        AuditFileExportHeader.Modify();

        // [WHEN] Start export.
        AuditFileExportTestHelper.StartExport(AuditFileExportHeader);

        // [THEN] One zip file "AuditFiles.zip" was created.
        AuditFileNames.Add(ZipFileName);
        VerifyAuditFileCountAndNames(AuditFileExportHeader, AuditFileNames);

        // [THEN] Zip file contains 3 txt files - MasterData.txt, GLEntry.txt, SourceDocument.txt.
        GetAuditFileContent(ZipFileName, ZipTempBlob);
        DataCompression.OpenZipArchive(ZipTempBlob, false);
        DataCompression.GetEntryList(ZipEntryList);
        Assert.AreEqual(3, ZipEntryList.Count, '');
        DataCompression.CloseZipArchive();

        // [THEN] MasterData.txt contains Header Comment, Contact and list of mapped G/L Accounts.
        GetFileContentFromZip(ZipTempBlob, TempBlob, 'MasterData.txt');
        VerifyAuditFileWithMasterData(AuditFileExportHeader, TempBlob, MappedGLAccountNos);

        // [THEN] GLEntry.txt contains list of G/L Entries for mapped G/L Accounts.
        GetFileContentFromZip(ZipTempBlob, TempBlob, 'GLEntry.txt');
        VerifyAuditFileWithGLEntries(TempBlob, MappedGLAccountNos, DocumentNos, Amounts);

        // [THEN] SourceDocument.txt contains one line "Source Document File Content".
        GetFileContentFromZip(ZipTempBlob, TempBlob, 'SourceDocument.txt');
        VerifyAuditFileWithSourceDocs(TempBlob);
    end;

    [Test]
    procedure CheckAuditFileExportDocumentNegative()
    var
        AuditFileExportHeader: Record "Audit File Export Header";
    begin
        // [SCENARIO 452704] Check Audit File Export document when it does not meet the requirements.
        Initialize();

        // [GIVEN] Audit File Export Format "TEST" set up.
        // [GIVEN] Implemented procedure CheckAuditDocReadyToExport() which tests the field "Header Comment" of Audit File Export Header.

        // [GIVEN] Audit File Export document with blank Header Comment.
        AuditFileExportTestHelper.CreateAuditFileExportDoc(AuditFileExportHeader, WorkDate(), WorkDate(), false);
        AuditFileExportHeader."Header Comment" := '';
        AuditFileExportHeader.Modify();

        // [WHEN] Start export.
        asserterror AuditFileExportTestHelper.StartExport(AuditFileExportHeader);

        // [THEN] Error "Header Comment must have a value" is shown.
        Assert.ExpectedError(StrSubstNo(CommentMustHaveValueErr, AuditFileExportHeader.ID));
        Assert.ExpectedErrorCode('TestField');
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerYes')]
    procedure CheckAuditFileExportDocumentPositive()
    var
        AuditFileExportHeader: Record "Audit File Export Header";
    begin
        // [SCENARIO 452704] Check Audit File Export document when it does not meet the requirements.
        Initialize();

        // [GIVEN] Audit File Export Format "TEST" set up.
        // [GIVEN] Implemented procedure CheckAuditDocReadyToExport() which tests the field "Header Comment" of Audit File Export Header.

        // [GIVEN] Audit File Export document with non-blank Header Comment.
        AuditFileExportTestHelper.CreateAuditFileExportDoc(AuditFileExportHeader, WorkDate(), WorkDate(), false);
        AuditFileExportHeader."Header Comment" := 'comment 1';
        AuditFileExportHeader.Modify();

        // [WHEN] Start export.
        AuditFileExportTestHelper.StartExport(AuditFileExportHeader);

        // [THEN] No error is shown.
    end;

    [Test]
    procedure CheckDataToExportNegative()
    var
        AuditFileExportHeader: Record "Audit File Export Header";
        Contact: Record Contact;
        AuditFileExportDocCard: TestPage "Audit File Export Doc. Card";
    begin
        // [SCENARIO 452704] Check audit data before export when data does not meet the requirements.
        Initialize();

        // [GIVEN] Audit File Export Format "TEST" set up.
        // [GIVEN] Implemented procedure CheckDataToExport() which verifies that the contact specified in Audit File Export Header has non-blank address.

        // [GIVEN] Contact A with a blank address.
        LibraryMarketing.CreatePersonContact(Contact);
        Contact.Address := '';
        Contact.Modify();

        // [GIVEN] Audit File Export document with Contact A.
        AuditFileExportTestHelper.CreateAuditFileExportDoc(AuditFileExportHeader, WorkDate(), WorkDate(), false);
        AuditFileExportHeader.Contact := Contact."No.";
        AuditFileExportHeader.Modify();

        // [WHEN] Open Audit File Export Document Card, select action "Data Check".
        AuditFileExportDocCard.OpenEdit();
        AuditFileExportDocCard.Filter.SetFilter(ID, Format(AuditFileExportHeader.ID));
        asserterror AuditFileExportDocCard.DataCheck.Invoke();

        // [THEN] Error "Address must have a value in Contact: No.=A" is shown.
        Assert.ExpectedError(StrSubstNo(AddressMustHaveValueErr, Contact."No."));
        Assert.ExpectedErrorCode('TestField');
    end;

    [Test]
    procedure CheckDataToExportPositive()
    var
        AuditFileExportHeader: Record "Audit File Export Header";
        Contact: Record Contact;
        AuditFileExportDocCard: TestPage "Audit File Export Doc. Card";
    begin
        // [SCENARIO 452704] Check audit data before export when data meets the requirements.
        Initialize();

        // [GIVEN] Audit File Export Format "TEST" set up.
        // [GIVEN] Implemented procedure CheckDataToExport() which verifies that the contact specified in Audit File Export Header has non-blank address.

        // [GIVEN] Contact A with a non-blank address.
        LibraryMarketing.CreatePersonContact(Contact);
        Contact.Address := 'abc';
        Contact.Modify();

        // [GIVEN] Audit File Export document with Contact A.
        AuditFileExportTestHelper.CreateAuditFileExportDoc(AuditFileExportHeader, WorkDate(), WorkDate(), false);
        AuditFileExportHeader.Contact := Contact."No.";
        AuditFileExportHeader.Modify();

        // [WHEN] Open Audit File Export Document Card, select action "Data Check".
        AuditFileExportDocCard.OpenEdit();
        AuditFileExportDocCard.Filter.SetFilter(ID, Format(AuditFileExportHeader.ID));
        AuditFileExportDocCard.DataCheck.Invoke();

        // [THEN] No error is shown.
    end;

    [Test]
    procedure AuditFileExportFormatNone()
    var
        AuditFileExportSetup: Record "Audit File Export Setup";
        AuditFileExportHeader: Record "Audit File Export Header";
    begin
        // [SCENARIO 465520] Audit File Export Format "None" with 0 value exists.
        AuditFileExportSetup.Validate("Audit File Export Format", "Audit File Export Format"::None);
        Assert.AreEqual("Audit File Export Format"::None, AuditFileExportSetup."Audit File Export Format", '');

        AuditFileExportHeader.Validate("Audit File Export Format", "Audit File Export Format"::None);
        Assert.AreEqual("Audit File Export Format"::None, AuditFileExportHeader."Audit File Export Format", '');

        // restore setup
        AuditFileExportSetup.InitSetup("Audit File Export Format"::TEST);
    end;

    local procedure Initialize()
    begin
        if IsInitialized then
            exit;

        AuditFileExportTestHelper.SetupTestFormat();
        Commit();

        IsInitialized := true;
    end;

    local procedure CreateAndPostGenJnlLines(var DocumentNos: List of [Code[20]]; var Amounts: List of [Decimal]; GLAccountNos: List of [Code[20]])
    var
        GenJournalLine: Record "Gen. Journal Line";
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
        AccountNo: Code[20];
    begin
        LibraryERM.CreateGenJournalTemplate(GenJournalTemplate);
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);
        GenJournalBatch.Validate("Bal. Account Type", "Gen. Journal Account Type"::"G/L Account");
        GenJournalBatch.Validate("Bal. Account No.", LibraryERM.CreateGLAccountNo());
        GenJournalBatch.Modify(true);

        foreach AccountNo in GLAccountNos do begin
            LibraryERM.CreateGeneralJnlLine(
                GenJournalLine, GenJournalBatch."Journal Template Name", GenJournalBatch.Name, "Gen. Journal Document Type"::Payment,
                "Gen. Journal Account Type"::"G/L Account", AccountNo, LibraryRandom.RandDecInRange(100, 200, 2));
            DocumentNos.Add(GenJournalLine."Document No.");
            Amounts.Add(GenJournalLine.Amount);
            LibraryERM.PostGeneralJnlLine(GenJournalLine);
        end;
    end;

    local procedure GetAuditFileContent(AuditFileName: Text[1024]; var TempBlob: Codeunit "Temp Blob")
    var
        AuditFile: Record "Audit File";
        FileInStream: InStream;
        BlobOutStream: OutStream;
    begin
        Clear(TempBlob);
        AuditFile.SetFilter("File Name", AuditFileName);
        AuditFile.FindFirst();
        AuditFile.CalcFields("File Content");
        AuditFile."File Content".CreateInStream(FileInStream);
        TempBlob.CreateOutStream(BlobOutStream);
        CopyStream(BlobOutStream, FileInStream);
    end;

    local procedure GetFileContentFromZip(var ZipTempBlob: Codeunit "Temp Blob"; var TempBlob: Codeunit "Temp Blob"; FileNameInZip: Text)
    var
        DataCompression: Codeunit "Data Compression";
        FileOutStream: OutStream;
    begin
        Clear(TempBlob);
        DataCompression.OpenZipArchive(ZipTempBlob, false);
        TempBlob.CreateOutStream(FileOutStream);
        DataCompression.ExtractEntry(FileNameInZip, FileOutStream);
        DataCompression.CloseZipArchive();
    end;

    local procedure VerifyAuditFileCountAndNames(AuditFileExportHeader: Record "Audit File Export Header"; AuditFileNames: List of [Text[1024]])
    var
        AuditFile: Record "Audit File";
        FileName: Text[1024];
    begin
        AuditFile.SetRange("Export ID", AuditFileExportHeader.ID);
        Assert.RecordCount(AuditFile, AuditFileNames.Count);

        foreach FileName in AuditFileNames do begin
            AuditFile.SetFilter("File Name", FileName);
            Assert.RecordCount(AuditFile, 1);
        end;
    end;

    local procedure VerifyAuditFileWithMasterData(AuditFileExportHeader: Record "Audit File Export Header"; var TempBlob: Codeunit "Temp Blob"; MappedGLAccountNos: List of [Code[20]])
    var
        FileInStream: InStream;
        LineContent: Text;
        ExpectedLinesContent: List of [Text];
        ExpLineContent: Text;
    begin
        TempBlob.CreateInStream(FileInStream);
#pragma warning disable AA0217
        ExpectedLinesContent.Add('Master Data');
        ExpectedLinesContent.Add(StrSubstNo('Header Comment %1', AuditFileExportHeader."Header Comment"));
        ExpectedLinesContent.Add(StrSubstNo('Contact %2', AuditFileExportHeader.Contact));
        ExpectedLinesContent.Add(StrSubstNo('G/L Account %1 %2', MappedGLAccountNos.Get(1), '1111'));
        ExpectedLinesContent.Add(StrSubstNo('G/L Account %1 %2', MappedGLAccountNos.Get(2), '2222'));
        ExpectedLinesContent.Add(StrSubstNo('G/L Account %1 %2', MappedGLAccountNos.Get(3), '3333'));
#pragma warning restore
        foreach ExpLineContent in ExpectedLinesContent do begin
            FileInStream.ReadText(LineContent);
            Assert.ExpectedMessage(ExpLineContent, LineContent);
        end;

        Assert.IsTrue(FileInStream.EOS(), 'Audit File contains more lines than expected');
    end;

    local procedure VerifyAuditFileWithGLEntries(var TempBlob: Codeunit "Temp Blob"; MappedGLAccountNos: List of [Code[20]]; DocumentNos: List of [Code[20]]; Amounts: List of [Decimal])
    var
        FileInStream: InStream;
        LineContent: Text;
        ExpectedLinesContent: List of [Text];
        ExpLineContent: Text;
        i: Integer;
    begin
        TempBlob.CreateInStream(FileInStream);

        ExpectedLinesContent.Add('G/L Entries');
#pragma warning disable AA0217
        for i := 1 to DocumentNos.Count do
            ExpectedLinesContent.Add(StrSubstNo('G/L Entry %1 %2 %3', MappedGLAccountNos.Get(i), DocumentNos.Get(i), Format(Amounts.Get(i), 0, 9)));
#pragma warning restore
        foreach ExpLineContent in ExpectedLinesContent do begin
            FileInStream.ReadText(LineContent);
            Assert.ExpectedMessage(ExpLineContent, LineContent);
        end;

        Assert.IsTrue(FileInStream.EOS(), 'Audit File contains more lines than expected');
    end;

    local procedure VerifyAuditFileWithSourceDocs(var TempBlob: Codeunit "Temp Blob")
    var
        FileInStream: InStream;
        LineContent: Text;
        ExpectedLinesContent: List of [Text];
        ExpLineContent: Text;
    begin
        TempBlob.CreateInStream(FileInStream);

        ExpectedLinesContent.Add('Source Document File Content');

        foreach ExpLineContent in ExpectedLinesContent do begin
            FileInStream.ReadText(LineContent);
            Assert.ExpectedMessage(ExpLineContent, LineContent);
        end;

        Assert.IsTrue(FileInStream.EOS(), 'Audit File contains more lines than expected');
    end;

    [ConfirmHandler]
    procedure ConfirmHandlerYes(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := true;
    end;
}