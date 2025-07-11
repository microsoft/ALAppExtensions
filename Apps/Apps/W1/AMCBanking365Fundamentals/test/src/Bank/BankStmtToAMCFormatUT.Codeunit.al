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
        AMCBankImpSTMTHndl: Codeunit "AMC Bank Imp.STMT. Hndl";
    begin
        // [SCENARIO 1] Send an empty file to AMC web service
        // [GIVEN] Empty file on disk.
        // [WHEN] Run the ConvertBankStatementToAMCFormat function.
        // [THEN] Error message is displayed that no content is available to send.

        // Setup
        LibraryLowerPermissions.SetOutsideO365Scope();

        // Exercise
        asserterror AMCBankImpSTMTHndl.ConvertBankStatementToFormat(BankStmtTempBlob, DataExch);

        // Verify
        Assert.ExpectedError(NoRequestBodyErr);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure DetectEncodingOEM()
    var
        InputTempBlob: Codeunit "Temp Blob";
        OutputTempBlob: Codeunit "Temp Blob";
        FileManagement: Codeunit "File Management";
        InStream: InStream;
        OutStream: OutStream;
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
        OutputTempBlob.CreateOutStream(OutStream, TEXTENCODING::MSDos);
        OutStream.Write(String);

        // Exercise
        LibraryLowerPermissions.SetBanking();
        FileName := FileManagement.ServerTempFileName('MSDos.txt');
        FileManagement.BLOBExportToServerFile(OutputTempBlob, FileName);
        FileManagement.BLOBImportFromServerFile(InputTempBlob, FileName);

        // Pre-Verify
        InputTempBlob.CreateInStream(InStream, TEXTENCODING::UTF16);
        InStream.Read(ContentWrongEncoding);

        InputTempBlob.CreateInStream(InStream, TEXTENCODING::MSDos);
        InStream.Read(ContentProperEncoding);

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
        FileManagement: Codeunit "File Management";
        InStream: InStream;
        OutStream: OutStream;
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
        OutputTempBlob.CreateOutStream(OutStream, TEXTENCODING::Windows);
        OutStream.Write(String);

        // Exercise
        LibraryLowerPermissions.SetBanking();
        FileName := FileManagement.ServerTempFileName('Windows.txt');
        FileManagement.BLOBExportToServerFile(OutputTempBlob, FileName);
        FileManagement.BLOBImportFromServerFile(InputTempBlob, FileName);

        // Pre-Verify
        InputTempBlob.CreateInStream(InStream, TEXTENCODING::UTF16);
        InStream.Read(ContentWrongEncoding);

        InputTempBlob.CreateInStream(InStream, TEXTENCODING::Windows);
        InStream.Read(ContentProperEncoding);

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
        FileManagement: Codeunit "File Management";
        InStream: InStream;
        OutStream: OutStream;
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
        OutputTempBlob.CreateOutStream(OutStream, TEXTENCODING::UTF8);
        OutStream.Write(String);

        // Exercise
        LibraryLowerPermissions.SetBanking();
        FileName := FileManagement.ServerTempFileName('UTF8.txt');
        FileManagement.BLOBExportToServerFile(OutputTempBlob, FileName);
        FileManagement.BLOBImportFromServerFile(InputTempBlob, FileName);

        // Pre-Verify
        InputTempBlob.CreateInStream(InStream, TEXTENCODING::UTF16);
        InStream.Read(ContentWrongEncoding);

        // TEXTENCODING::UTF8 did not work!
        InputTempBlob.CreateInStream(InStream, TEXTENCODING::Windows);
        InStream.Read(ContentProperEncoding);

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
        FileManagement: Codeunit "File Management";
        InStream: InStream;
        OutStream: OutStream;
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
        OutputTempBlob.CreateOutStream(OutStream, TEXTENCODING::UTF16);
        OutStream.Write(String);

        // Exercise
        LibraryLowerPermissions.SetBanking();
        FileName := FileManagement.ServerTempFileName('UTF16.txt');
        FileManagement.BLOBExportToServerFile(OutputTempBlob, FileName);
        FileManagement.BLOBImportFromServerFile(InputTempBlob, FileName);

        // Pre-Verify
        InputTempBlob.CreateInStream(InStream, TEXTENCODING::MSDos);
        InStream.Read(ContentWrongEncoding);

        InputTempBlob.CreateInStream(InStream, TEXTENCODING::UTF16);
        InStream.Read(ContentProperEncoding);

        // Verify
        Assert.AreNotEqual(String, ContentWrongEncoding, '');
        Assert.AreEqual(String, ContentProperEncoding, '');
    end;
}
