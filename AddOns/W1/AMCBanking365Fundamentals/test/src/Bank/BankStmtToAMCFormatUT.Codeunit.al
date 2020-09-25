codeunit 132562 "Bank Stmt. to AMC Format UT"
{
    Subtype = Test;
    TestPermissions = NonRestrictive;

    trigger OnRun()
    begin
        // [FEATURE] [AMC Banking Fundamentals] [UT]
    end;

    var
        Assert: Codeunit Assert;
        LibraryUtility: Codeunit "Library - Utility";
        LibraryLowerPermissions: Codeunit "Library - Lower Permissions";
        NoRequestBodyErr: Label 'The request body is not set.';


    [Test]
    [Scope('OnPrem')]
    procedure SendEmptyBlobToWebService()
    var
        DataExch: Record "Data Exch.";
        BankStmtTempBlob: Codeunit "Temp Blob";
        ImpBankConvExtDataHndl: Codeunit "AMC Bank Imp.STMT. Hndl";
    begin
        // [SCENARIO 1] Send an empty file to AMC web service
        // [GIVEN] Empty file on disk.
        // [WHEN] Run the ConvertBankStatementToAMCFormat function.
        // [THEN] Error message is displayed that no content is available to send.

        // Setup
        LibraryLowerPermissions.SetOutsideO365Scope();

        // Exercise
        asserterror ImpBankConvExtDataHndl.ConvertBankStatementToFormat(BankStmtTempBlob, DataExch);

        // Verify
        Assert.ExpectedError(NoRequestBodyErr);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure DetectEncodingOEM()
    var
        InputTempBlob: Codeunit "Temp Blob";
        OutputTempBlob: Codeunit "Temp Blob";
        FileMgt: Codeunit "File Management";
        InputStream: InStream;
        OutputStream: OutStream;
        ContentProperEncoding: Text;
        ContentWrongEncoding: Text;
        FileName: Text;
        String: Text;
    begin
        // [SCENARIO 2] Save content in OEM encoding to a file and read it properly.
        // [GIVEN] Content written in OEM encoding.
        // [WHEN] Import the file.
        // [THEN] Content is improperly read when Unicode encoding is used.
        // [THEN] Content is properly read when OEM encoding is used.

        // Pre-Seutp
        String := LibraryUtility.GenerateRandomText(1024);

        // Setup
        OutputTempBlob.CreateOutStream(OutputStream, TEXTENCODING::MSDos);
        OutputStream.Write(String);

        // Exercise
        LibraryLowerPermissions.SetBanking();
        FileName := FileMgt.ServerTempFileName('MSDos.txt');
        FileMgt.BLOBExportToServerFile(OutputTempBlob, FileName);
        FileMgt.BLOBImportFromServerFile(InputTempBlob, FileName);

        // Pre-Verify
        InputTempBlob.CreateInStream(InputStream, TEXTENCODING::UTF16);
        InputStream.Read(ContentWrongEncoding);

        InputTempBlob.CreateInStream(InputStream, TEXTENCODING::MSDos);
        InputStream.Read(ContentProperEncoding);

        // Verify
        Assert.AreNotEqual(String, ContentWrongEncoding, '');
        Assert.AreEqual(String, ContentProperEncoding, '');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure DetectEncodingASCII()
    var
        InputTempBlob: Codeunit "Temp Blob";
        OutputTempBlob: Codeunit "Temp Blob";
        FileMgt: Codeunit "File Management";
        InputStream: InStream;
        OutputStream: OutStream;
        ContentProperEncoding: Text;
        ContentWrongEncoding: Text;
        FileName: Text;
        String: Text;
    begin
        // [SCENARIO 3] Save content in ASCII encoding to a file and read it properly.
        // [GIVEN] Content written in ASCII encoding.
        // [WHEN] Import the file.
        // [THEN] Content is improperly read when Unicode encoding is used.
        // [THEN] Content is properly read when ASCII encoding is used.

        // Pre-Seutp
        String := LibraryUtility.GenerateRandomText(1024);

        // Setup
        OutputTempBlob.CreateOutStream(OutputStream, TEXTENCODING::Windows);
        OutputStream.Write(String);

        // Exercise
        LibraryLowerPermissions.SetBanking();
        FileName := FileMgt.ServerTempFileName('Windows.txt');
        FileMgt.BLOBExportToServerFile(OutputTempBlob, FileName);
        FileMgt.BLOBImportFromServerFile(InputTempBlob, FileName);

        // Pre-Verify
        InputTempBlob.CreateInStream(InputStream, TEXTENCODING::UTF16);
        InputStream.Read(ContentWrongEncoding);

        InputTempBlob.CreateInStream(InputStream, TEXTENCODING::Windows);
        InputStream.Read(ContentProperEncoding);

        // Verify
        Assert.AreNotEqual(String, ContentWrongEncoding, '');
        Assert.AreEqual(String, ContentProperEncoding, '');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure DetectEncodingUTF8()
    var
        InputTempBlob: Codeunit "Temp Blob";
        OutputTempBlob: Codeunit "Temp Blob";
        FileMgt: Codeunit "File Management";
        InputStream: InStream;
        OutputStream: OutStream;
        ContentProperEncoding: Text;
        ContentWrongEncoding: Text;
        FileName: Text;
        String: Text;
    begin
        // [SCENARIO 4] Save content in UTF-8 encoding to a file and read it properly.
        // [GIVEN] Content written in UTF-8 encoding.
        // [WHEN] Import the file.
        // [THEN] Content is improperly read when Unicode encoding is used.
        // [THEN] Content is properly read when UTF-8 encoding is used.

        // Pre-Seutp
        String := LibraryUtility.GenerateRandomText(1024);

        // Setup
        OutputTempBlob.CreateOutStream(OutputStream, TEXTENCODING::UTF8);
        OutputStream.Write(String);

        // Exercise
        LibraryLowerPermissions.SetBanking();
        FileName := FileMgt.ServerTempFileName('UTF8.txt');
        FileMgt.BLOBExportToServerFile(OutputTempBlob, FileName);
        FileMgt.BLOBImportFromServerFile(InputTempBlob, FileName);

        // Pre-Verify
        InputTempBlob.CreateInStream(InputStream, TEXTENCODING::UTF16);
        InputStream.Read(ContentWrongEncoding);

        // TEXTENCODING::UTF8 did not work!
        InputTempBlob.CreateInStream(InputStream, TEXTENCODING::Windows);
        InputStream.Read(ContentProperEncoding);

        // Verify
        Assert.AreNotEqual(String, ContentWrongEncoding, '');
        Assert.AreEqual(String, ContentProperEncoding, '');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure DetectEncodingUnicode()
    var
        InputTempBlob: Codeunit "Temp Blob";
        OutputTempBlob: Codeunit "Temp Blob";
        FileMgt: Codeunit "File Management";
        InputStream: InStream;
        OutputStream: OutStream;
        ContentProperEncoding: Text;
        ContentWrongEncoding: Text;
        FileName: Text;
        String: Text;
    begin
        // [SCENARIO 5] Save content in Unicode encoding to a file and read it properly.
        // [GIVEN] Content written in Unicode encoding.
        // [WHEN] Import the file.
        // [THEN] Content is improperly read when OEM encoding is used.
        // [THEN] Content is properly read when Unicode encoding is used.

        // Pre-Seutp
        String := LibraryUtility.GenerateRandomText(1024);

        // Setup
        OutputTempBlob.CreateOutStream(OutputStream, TEXTENCODING::UTF16);
        OutputStream.Write(String);

        // Exercise
        LibraryLowerPermissions.SetBanking();
        FileName := FileMgt.ServerTempFileName('UTF16.txt');
        FileMgt.BLOBExportToServerFile(OutputTempBlob, FileName);
        FileMgt.BLOBImportFromServerFile(InputTempBlob, FileName);

        // Pre-Verify
        InputTempBlob.CreateInStream(InputStream, TEXTENCODING::MSDos);
        InputStream.Read(ContentWrongEncoding);

        InputTempBlob.CreateInStream(InputStream, TEXTENCODING::UTF16);
        InputStream.Read(ContentProperEncoding);

        // Verify
        Assert.AreNotEqual(String, ContentWrongEncoding, '');
        Assert.AreEqual(String, ContentProperEncoding, '');
    end;
}
