codeunit 135080 "AMC Bank Stmt E2E Web Serv"
{
    Subtype = Test;
    TestPermissions = NonRestrictive;

    trigger OnRun()
    begin
        // [FEATURE] [AMC Banking Fundamentals] [Web Service]
    end;

    var
        LibraryAMCWebService: Codeunit "Library - Amc Web Service";
        LibraryXPathXMLReader: Codeunit "Library - XPath XML Reader";
        IsInitialized: Boolean;
        CremulPathTxt: Label '/ns:reportExportResponse/return/cremul', Locked = true;
        EndBalanceNodePathTxt: Label '/ns:reportExportResponse/return/finsta/statement/', Locked = true;
        NordeaCorporate_EnCodWinTxt: Label '"NDEADKKKXXX","2999","9999940560","DKK","Demo User","","20030221","20030221","15757.25","+","15757.25","","68","","Order 12345","4","500","MEDDELNR 2001219","0","99999999999903","501","","502","KON konto 0979999035","0","","0","","0","","","","","","","266787.12","+","266787.12","","","Driftskonto","DK3420009999940560","N","Test Testsen","Testvej 10","9999 Testrup","","","","Ordrenr. 65656","99999999999903","1170200109040120000018","7","Betaling af f¹lgende fakturaer:","Fakturanr. Bel¹b:","12345 2500,35","22345 1265,66","32345 5825,00","42345 3635,88","52345 2530,36","","","","","","","","","","","","","","","","","","","","","","","",""', Locked = true;

    local procedure Initialize()
    begin
        if IsInitialized then
            exit;

        LibraryAMCWebService.SetupDefaultService();
        LibraryAMCWebService.SetServiceUrlToTest();
        LibraryAMCWebService.SetServiceCredentialsToTest();

        IsInitialized := true;
    end;

    [Test]
    [Scope('OnPrem')]
    procedure SendBankStmtToWebService()
    var
        DataExch: Record "Data Exch.";
        BankStmtTempBlob: Codeunit "Temp Blob";
        ResponseBodyTempBlob: Codeunit "Temp Blob";
        AMCBankImpSTMTHndl: Codeunit "AMC Bank Imp.STMT. Hndl";
        AMCBankingMgt: Codeunit "AMC Banking Mgt.";
        BankStmtOutStream: OutStream;
    begin
        // [SCENARIO 1] Send a bank statement File to AMC web service, and get AMC-formatted XML file
        // [GIVEN] Bank statement file on disk.
        // [WHEN] Run the ConvertBankStatementToAMCFormat function.
        // [THEN] XML file in AMC format is returned as a BLOB, containing the expected data.

        Initialize();

        // Pre-Setup
        BankStmtTempBlob.CreateOutStream(BankStmtOutStream, TEXTENCODING::Windows);
        BankStmtOutStream.Write(NordeaCorporate_EnCodWinTxt);

        // Exercise
        AMCBankImpSTMTHndl.ConvertBankStatementToFormat(BankStmtTempBlob, DataExch);

        // Pre-Verify
        ResponseBodyTempBlob.FromRecord(DataExch, DataExch.FieldNo("File Content"));
        LibraryXPathXMLReader.InitializeWithBlob(ResponseBodyTempBlob, AMCBankingMgt.GetNamespace());
        LibraryXPathXMLReader.SetDefaultNamespaceUsage(false);

        // Verify
        LibraryXPathXMLReader.VerifyNodeValueByXPath(EndBalanceNodePathTxt + '/balanceend', '266787.1200');
        LibraryXPathXMLReader.VerifyNodeAbsence(CremulPathTxt);
    end;

    /*
    [Test]
    [Scope('OnPrem')]
    procedure SendEmptyBankStmtToWebService()
    var
        DataExch: Record "Data Exch.";
        BankStmtTempBlob: Codeunit "Temp Blob";
        AMCBankImpSTMTHndl: Codeunit "AMC Bank Imp.STMT. Hndl";
        BankStmtOutStream: OutStream;
    begin
        // [SCENARIO 2] Send an empty file to AMC web service
        // [GIVEN] Empty file on disk.
        // [WHEN] Run the ConvertBankStatementToAMCFormat function.
        // [THEN] Error message is displayed that no content is available to send.

        Initialize();

        // Setup
        BankStmtTempBlob.CreateOutStream(BankStmtOutStream, TEXTENCODING::MSDos);
        BankStmtOutStream.Write('');

        // Exercise
        asserterror AMCBankImpSTMTHndl.ConvertBankStatementToFormat(BankStmtTempBlob, DataExch);

        // Verify
        Assert.ExpectedError(SyslogErrorsErr);
        Assert.ExpectedError(SupportURLErr);
        Assert.ExpectedError(FileNotRecognizedErr);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure SendNonSupportedBankStmtToWebService()
    var
        DataExch: Record "Data Exch.";
        BankStmtTempBlob: Codeunit "Temp Blob";
        AMCBankImpSTMTHndl: Codeunit "AMC Bank Imp.STMT. Hndl";
        BankStmtOutStream: OutStream;
    begin        
        // [SCENARIO 4] Send a non-supported bank statement file to AMC web service.
        // [GIVEN] Bank statement file on disk.
        // [WHEN] Run the ConvertBankStatementToAMCFormat function.
        // [THEN] Error message is displayed to indicate inability to recognize the bank statement format.

        Initialize();

        // Setup
        BankStmtTempBlob.CreateOutStream(BankStmtOutStream, TEXTENCODING::UTF8);
        BankStmtOutStream.Write('RandomText');

        // Exercise
        asserterror AMCBankImpSTMTHndl.ConvertBankStatementToFormat(BankStmtTempBlob, DataExch);

        // Verify
        Assert.ExpectedError(SyslogErrorsErr);
        Assert.ExpectedError(SupportURLErr);
        Assert.ExpectedError(FileNotRecognizedErr);        
    end;
    */
}

