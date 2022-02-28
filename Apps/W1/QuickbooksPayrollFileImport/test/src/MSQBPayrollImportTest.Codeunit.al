codeunit 139676 "MS - QB Payroll Import Test"
{
    // version Test,W1

    Subtype = Test;
    TestPermissions = Disabled;

    var
        FileManagement: Codeunit "File Management";
        MSQuickbooksPayrollImport: Codeunit "MS - Quickbooks Payroll Import";
        Assert: Codeunit "Assert";
        InvalidIIFTransFileErr: Label 'This is not a valid IIF transaction file. Required token %1 could not be found in the file.', Comment = '%1 - arbitrary text';
        NoGenJnlTransactionsMsg: Label 'No transactions with supported type were found in the imported file. Supported transaction types are: General Journal, Check, and Transfer.';
        NonGJTransactionsDetectedMsg: Label 'One or more transactions in the imported file were not imported because they are not of supported type. Supported transaction types are: General Journal, Check, and Transfer.';
        TransactionHeaderTok: Label '!TRNS', Locked = true;
        TransactionTypeTok: Label 'TRNSTYPE', Locked = true;
        AccountNameTok: Label 'ACCNT', Locked = true;
        AmountTok: Label 'AMOUNT', Locked = true;

    [Test]
    procedure TestImportValidIIFTransactionFile();
    var
        TempImportGLTransaction: Record 1661 temporary;
        ServerFilePath: Text[250];
    begin
        GenerateValidIIFTransactionFile(ServerFilePath);
        MSQuickbooksPayrollImport.ImportGLTransactionsByIIFFileName(ServerFilePath, TempImportGLTransaction);

        Assert.AreEqual(3, TempImportGLTransaction.COUNT(), 'Unexpected number of transactions imported');
        TempImportGLTransaction.SETRANGE("App ID", FORMAT(MSQuickbooksPayrollImport.GetAppID()));
        TempImportGLTransaction.SETRANGE("Transaction Date", DMY2DATE(1, 7, 2016));
        TempImportGLTransaction.SETRANGE("External Account", 'Savings');
        TempImportGLTransaction.SETRANGE(Amount, 650);
        Assert.IsFalse(TempImportGLTransaction.ISEMPTY(), 'Expected transaction not imported.');
        TempImportGLTransaction.SETRANGE("External Account", 'Construction:Labor');
        TempImportGLTransaction.SETRANGE(Amount, -349.5);
        Assert.IsFalse(TempImportGLTransaction.ISEMPTY(), 'Expected transaction not imported.');
        TempImportGLTransaction.SETRANGE("External Account", 'Construction:Materials');
        TempImportGLTransaction.SETRANGE(Amount, -350.5);
        Assert.IsFalse(TempImportGLTransaction.ISEMPTY(), 'Expected transaction not imported.');
    end;

    [Test]
    [HandlerFunctions('UnsupportedTransactionsMessageHandler')]
    procedure TestImportValidIIFTransactionFileMixedTransactionTypes();
    var
        TempImportGLTransaction: Record 1661 temporary;
        ServerFilePath: Text[250];
    begin
        GenerateValidIIFTransactionFileMixed(ServerFilePath);
        MSQuickbooksPayrollImport.ImportGLTransactionsByIIFFileName(ServerFilePath, TempImportGLTransaction);

        Assert.AreEqual(3, TempImportGLTransaction.COUNT(), 'Unexpected number of transactions imported');
        TempImportGLTransaction.SETRANGE("App ID", FORMAT(MSQuickbooksPayrollImport.GetAppID()));
        TempImportGLTransaction.SETRANGE("Transaction Date", DMY2DATE(1, 7, 2016));
        TempImportGLTransaction.SETRANGE(Amount, 650);
        TempImportGLTransaction.SETRANGE("External Account", 'Savings');
        Assert.IsFalse(TempImportGLTransaction.ISEMPTY(), 'Expected transaction not imported.');
        TempImportGLTransaction.SETRANGE("External Account", 'Construction:Labor');
        TempImportGLTransaction.SETRANGE(Amount, -349.5);
        Assert.IsFalse(TempImportGLTransaction.ISEMPTY(), 'Expected transaction not imported.');
        TempImportGLTransaction.SETRANGE("External Account", 'Construction:Materials');
        TempImportGLTransaction.SETRANGE(Amount, -250.5);
        Assert.IsFalse(TempImportGLTransaction.ISEMPTY(), 'Expected transaction not imported.');
    end;

    [Test]
    [HandlerFunctions('NoGenJnlTransactionsMessageHandler')]
    procedure TestImportValidIIFTransactionFileNoGenJnlTransactions();
    var
        TempImportGLTransaction: Record 1661 temporary;
        ServerFilePath: Text[250];
    begin
        GenerateValidIIFTransactionFileNoGenJnl(ServerFilePath);
        MSQuickbooksPayrollImport.ImportGLTransactionsByIIFFileName(ServerFilePath, TempImportGLTransaction);

        Assert.AreEqual(0, TempImportGLTransaction.COUNT(), 'Unexpected number of transactions imported');
    end;

    [Test]
    procedure TestImportValidIIFTransactionFileLastCenturyDates();
    var
        TempImportGLTransaction: Record 1661 temporary;
        ServerFilePath: Text[250];
    begin
        GenerateValidIIFTransactionFileLastCenturyDates(ServerFilePath);
        MSQuickbooksPayrollImport.ImportGLTransactionsByIIFFileName(ServerFilePath, TempImportGLTransaction);

        Assert.AreEqual(3, TempImportGLTransaction.COUNT(), 'Unexpected number of transactions imported');
        TempImportGLTransaction.SETRANGE("App ID", FORMAT(MSQuickbooksPayrollImport.GetAppID()));
        TempImportGLTransaction.SETRANGE("Transaction Date", DMY2DATE(1, 10, 1998));
        TempImportGLTransaction.SETRANGE("External Account", 'Savings');
        TempImportGLTransaction.SETRANGE(Amount, 650);
        Assert.IsFalse(TempImportGLTransaction.ISEMPTY(), 'Expected transaction not imported.');
        TempImportGLTransaction.SETRANGE("Transaction Date", DMY2DATE(23, 7, 1998));
        TempImportGLTransaction.SETRANGE("External Account", 'Construction:Labor');
        TempImportGLTransaction.SETRANGE(Amount, -349.5);
        Assert.IsFalse(TempImportGLTransaction.ISEMPTY(), 'Expected transaction not imported.');
        TempImportGLTransaction.SETRANGE("Transaction Date", DMY2DATE(11, 10, 1998));
        TempImportGLTransaction.SETRANGE("External Account", 'Construction:Materials');
        TempImportGLTransaction.SETRANGE(Amount, -350.5);
        Assert.IsFalse(TempImportGLTransaction.ISEMPTY(), 'Expected transaction not imported.');
    end;

    [Test]
    procedure TestImportIIFTransactionFileMissingHeader();
    var
        TempImportGLTransaction: Record 1661 temporary;
        ServerFilePath: Text[250];
    begin
        GenerateIIFTransactionFileNoHeader(ServerFilePath);
        ASSERTERROR MSQuickbooksPayrollImport.ImportGLTransactionsByIIFFileName(ServerFilePath, TempImportGLTransaction);
        Assert.ExpectedError(STRSUBSTNO(InvalidIIFTransFileErr, TransactionHeaderTok));
    end;

    [Test]
    procedure TestImportIIFTransactionFileMissingTransactionTypeField();
    var
        TempImportGLTransaction: Record 1661 temporary;
        ServerFilePath: Text[250];
    begin
        GenerateIIFFileMissingTransactionTypeField(ServerFilePath);
        ASSERTERROR MSQuickbooksPayrollImport.ImportGLTransactionsByIIFFileName(ServerFilePath, TempImportGLTransaction);
        Assert.ExpectedError(STRSUBSTNO(InvalidIIFTransFileErr, TransactionTypeTok));
    end;

    [Test]
    procedure TestImportIIFTransactionFileMissingAccountNameField();
    var
        TempImportGLTransaction: Record 1661 temporary;
        ServerFilePath: Text[250];
    begin
        GenerateIIFFileMissingAccountField(ServerFilePath);
        ASSERTERROR MSQuickbooksPayrollImport.ImportGLTransactionsByIIFFileName(ServerFilePath, TempImportGLTransaction);
        Assert.ExpectedError(STRSUBSTNO(InvalidIIFTransFileErr, AccountNameTok));
    end;

    [Test]
    procedure TestImportIIFTransactionFileMissingAmountField();
    var
        TempImportGLTransaction: Record 1661 temporary;
        ServerFilePath: Text[250];
    begin
        GenerateIIFFileMissingAmountField(ServerFilePath);
        ASSERTERROR MSQuickbooksPayrollImport.ImportGLTransactionsByIIFFileName(ServerFilePath, TempImportGLTransaction);
        Assert.ExpectedError(STRSUBSTNO(InvalidIIFTransFileErr, AmountTok));
    end;

    [Test]
    procedure TestImportEmptyFile();
    var
        TempImportGLTransaction: Record 1661 temporary;
        ServerFilePath: Text[250];
    begin
        GenerateEmptyFile(ServerFilePath);
        ASSERTERROR MSQuickbooksPayrollImport.ImportGLTransactionsByIIFFileName(ServerFilePath, TempImportGLTransaction);
        Assert.ExpectedError(STRSUBSTNO(InvalidIIFTransFileErr, TransactionHeaderTok));
    end;

    local procedure GenerateValidIIFTransactionFile(var ServerFilePath: Text[250]);
    var
        TempBlob: Codeunit "Temp Blob";
        TempOutStream: OutStream;
        Tab: Char;
        CR: Char;
    begin
        Tab := 9;
        CR := 13;

        TempBlob.CreateOutStream(TempOutStream, TEXTENCODING::UTF8);
        TempOutStream.WRITE(STRSUBSTNO('!TRNS%1TRNSID%1TRNSTYPE%1DATE%1ACCNT%1CLASS%1AMOUNT%1DOCNUM%1MEMO', Tab));
        TempOutStream.WRITE(FORMAT(CR));
        TempOutStream.WRITE(STRSUBSTNO('!SPL%1SPLID%1TRNSTYPE%1DATE%1ACCNT%1CLASS%1AMOUNT%1DOCNUM%1MEMO', Tab));
        TempOutStream.WRITE(FORMAT(CR));
        TempOutStream.WRITE('!ENDTRNS');
        TempOutStream.WRITE(FORMAT(CR));
        TempOutStream.WRITE(STRSUBSTNO('TRNS%1%1GENERAL JOURNAL%1 7/1/16%1Savings%1%1 650%1%1', Tab));
        TempOutStream.WRITE(FORMAT(CR));
        TempOutStream.WRITE(STRSUBSTNO('SPL%1%1GENERAL JOURNAL%1 7/1/16%1Construction:Labor%1%1 -349.5%1%1', Tab));
        TempOutStream.WRITE(FORMAT(CR));
        TempOutStream.WRITE(STRSUBSTNO('SPL%1%1GENERAL JOURNAL%1 7/1/16%1Construction:Materials%1%1 -350.5%1%1', Tab));
        TempOutStream.WRITE(FORMAT(CR));
        TempOutStream.WRITE('ENDTRNS');

        ServerFilePath := CopyStr(FileManagement.ServerTempFileName('.iif'), 1, MaxStrLen(ServerFilePath));
        FileManagement.BLOBExportToServerFile(TempBlob, ServerFilePath);
    end;

    local procedure GenerateValidIIFTransactionFileMixed(var ServerFilePath: Text[250]);
    var
        TempBlob: Codeunit "Temp Blob";
        TempOutStream: OutStream;
        Tab: Char;
        CR: Char;
    begin
        Tab := 9;
        CR := 13;

        TempBlob.CreateOutStream(TempOutStream, TEXTENCODING::UTF8);
        TempOutStream.WRITE(STRSUBSTNO('!TRNS%1TRNSID%1TRNSTYPE%1DATE%1ACCNT%1CLASS%1AMOUNT%1DOCNUM%1MEMO', Tab));
        TempOutStream.WRITE(FORMAT(CR));
        TempOutStream.WRITE(STRSUBSTNO('!SPL%1SPLID%1TRNSTYPE%1DATE%1ACCNT%1CLASS%1AMOUNT%1DOCNUM%1MEMO', Tab));
        TempOutStream.WRITE(FORMAT(CR));
        TempOutStream.WRITE('!ENDTRNS');
        TempOutStream.WRITE(FORMAT(CR));
        TempOutStream.WRITE(STRSUBSTNO('TRNS%1%1GENERAL JOURNAL%1 7/1/16%1Savings%1%1 650%1%1', Tab));
        TempOutStream.WRITE(FORMAT(CR));
        TempOutStream.WRITE(STRSUBSTNO('SPL%1%1GENERAL JOURNAL%1 7/1/16%1Construction:Labor%1%1 -349.5%1%1', Tab));
        TempOutStream.WRITE(FORMAT(CR));
        TempOutStream.WRITE(STRSUBSTNO('SPL%1%1GENERAL JOURNAL%1 7/1/16%1Construction:Materials%1%1 -250.5%1%1', Tab));
        TempOutStream.WRITE(FORMAT(CR));
        TempOutStream.WRITE(STRSUBSTNO('SPL%1%1DEPOSIT%1 7/1/16%1Fees%1%1 -100%1%1', Tab));
        TempOutStream.WRITE(FORMAT(CR));
        TempOutStream.WRITE('ENDTRNS');

        ServerFilePath := CopyStr(FileManagement.ServerTempFileName('.iif'), 1, MaxStrLen(ServerFilePath));
        FileManagement.BLOBExportToServerFile(TempBlob, ServerFilePath);
    end;

    local procedure GenerateValidIIFTransactionFileNoGenJnl(var ServerFilePath: Text[250]);
    var
        TempBlob: Codeunit "Temp Blob";
        TempOutStream: OutStream;
        Tab: Char;
        CR: Char;
    begin
        Tab := 9;
        CR := 13;

        TempBlob.CreateOutStream(TempOutStream, TEXTENCODING::UTF8);
        TempOutStream.WRITE(STRSUBSTNO('!TRNS%1TRNSID%1TRNSTYPE%1DATE%1ACCNT%1CLASS%1AMOUNT%1DOCNUM%1MEMO', Tab));
        TempOutStream.WRITE(FORMAT(CR));
        TempOutStream.WRITE(STRSUBSTNO('!SPL%1SPLID%1TRNSTYPE%1DATE%1ACCNT%1CLASS%1AMOUNT%1DOCNUM%1MEMO', Tab));
        TempOutStream.WRITE(FORMAT(CR));
        TempOutStream.WRITE('!ENDTRNS');
        TempOutStream.WRITE(FORMAT(CR));
        TempOutStream.WRITE(STRSUBSTNO('TRNS%1%1DEPOSIT%1 7/1/16%1Savings%1%1 650%1%1', Tab));
        TempOutStream.WRITE(FORMAT(CR));
        TempOutStream.WRITE(STRSUBSTNO('SPL%1%1DEPOSIT%1 7/1/16%1Construction:Labor%1%1 -349.5%1%1', Tab));
        TempOutStream.WRITE(FORMAT(CR));
        TempOutStream.WRITE(STRSUBSTNO('SPL%1%1DEPOSIT%1 7/1/16%1Construction:Materials%1%1 -250.5%1%1', Tab));
        TempOutStream.WRITE(FORMAT(CR));
        TempOutStream.WRITE(STRSUBSTNO('SPL%1%1DEPOSIT%1 7/1/16%1Fees%1%1 -100%1%1', Tab));
        TempOutStream.WRITE(FORMAT(CR));
        TempOutStream.WRITE('ENDTRNS');

        ServerFilePath := CopyStr(FileManagement.ServerTempFileName('.iif'), 1, MaxStrLen(ServerFilePath));
        FileManagement.BLOBExportToServerFile(TempBlob, ServerFilePath);
    end;

    local procedure GenerateValidIIFTransactionFileLastCenturyDates(var ServerFilePath: Text[250]);
    var
        TempBlob: Codeunit "Temp Blob";
        TempOutStream: OutStream;
        Tab: Char;
        CR: Char;
    begin
        Tab := 9;
        CR := 13;

        TempBlob.CreateOutStream(TempOutStream, TEXTENCODING::UTF8);
        TempOutStream.WRITE(STRSUBSTNO('!TRNS%1TRNSID%1TRNSTYPE%1DATE%1ACCNT%1CLASS%1AMOUNT%1DOCNUM%1MEMO', Tab));
        TempOutStream.WRITE(FORMAT(CR));
        TempOutStream.WRITE(STRSUBSTNO('!SPL%1SPLID%1TRNSTYPE%1DATE%1ACCNT%1CLASS%1AMOUNT%1DOCNUM%1MEMO', Tab));
        TempOutStream.WRITE(FORMAT(CR));
        TempOutStream.WRITE('!ENDTRNS');
        TempOutStream.WRITE(FORMAT(CR));
        TempOutStream.WRITE(STRSUBSTNO('TRNS%1%1GENERAL JOURNAL%1 10/1/98%1Savings%1%1 650%1%1', Tab));
        TempOutStream.WRITE(FORMAT(CR));
        TempOutStream.WRITE(STRSUBSTNO('SPL%1%1GENERAL JOURNAL%1 7/23/98%1Construction:Labor%1%1 -349.5%1%1', Tab));
        TempOutStream.WRITE(FORMAT(CR));
        TempOutStream.WRITE(STRSUBSTNO('SPL%1%1GENERAL JOURNAL%1 10/11/98%1Construction:Materials%1%1 -350.5%1%1', Tab));
        TempOutStream.WRITE(FORMAT(CR));
        TempOutStream.WRITE('ENDTRNS');

        ServerFilePath := CopyStr(FileManagement.ServerTempFileName('.iif'), 1, MaxStrLen(ServerFilePath));
        FileManagement.BLOBExportToServerFile(TempBlob, ServerFilePath);
    end;

    local procedure GenerateIIFTransactionFileNoHeader(var ServerFilePath: Text[250]);
    var
        TempBlob: Codeunit "Temp Blob";
        TempOutStream: OutStream;
        Tab: Char;
        CR: Char;
    begin
        Tab := 9;
        CR := 13;

        TempBlob.CreateOutStream(TempOutStream, TEXTENCODING::UTF8);
        TempOutStream.WRITE(STRSUBSTNO('TRNS%1%1GENERAL JOURNAL%1 7/1/16%1Savings%1%1 650%1%1', Tab));
        TempOutStream.WRITE(FORMAT(CR));
        TempOutStream.WRITE(STRSUBSTNO('SPL%1%1GENERAL JOURNAL%1 7/1/16%1Construction:Labor%1%1 -349.5%1%1', Tab));
        TempOutStream.WRITE(FORMAT(CR));
        TempOutStream.WRITE(STRSUBSTNO('SPL%1%1GENERAL JOURNAL%1 7/1/16%1Construction:Materials%1%1 -350.5%1%1', Tab));
        TempOutStream.WRITE(FORMAT(CR));
        TempOutStream.WRITE('ENDTRNS');

        ServerFilePath := CopyStr(FileManagement.ServerTempFileName('.iif'), 1, MaxStrLen(ServerFilePath));
        FileManagement.BLOBExportToServerFile(TempBlob, ServerFilePath);
    end;

    local procedure GenerateEmptyFile(var ServerFilePath: Text[250]);
    var
        TempBlob: Codeunit "Temp Blob";
        TempOutStream: OutStream;
    begin
        TempBlob.CreateOutStream(TempOutStream, TEXTENCODING::UTF8);

        ServerFilePath := CopyStr(FileManagement.ServerTempFileName('.iif'), 1, MaxStrLen(ServerFilePath));
        FileManagement.BLOBExportToServerFile(TempBlob, ServerFilePath);
    end;

    local procedure GenerateIIFFileMissingTransactionTypeField(var ServerFilePath: Text[250]);
    var
        TempBlob: Codeunit "Temp Blob";
        TempOutStream: OutStream;
        Tab: Char;
        CR: Char;
    begin
        Tab := 9;
        CR := 13;

        TempBlob.CreateOutStream(TempOutStream, TEXTENCODING::UTF8);
        TempOutStream.WRITE(STRSUBSTNO('!TRNS%1TRNSID%1ABCD%1DATE%1ACCNT%1CLASS%1AMOUNT%1DOCNUM%1MEMO', Tab));
        TempOutStream.WRITE(FORMAT(CR));
        TempOutStream.WRITE(STRSUBSTNO('!SPL%1SPLID%1ABCD%1DATE%1ACCNT%1CLASS%1AMOUNT%1DOCNUM%1MEMO', Tab));
        TempOutStream.WRITE(FORMAT(CR));
        TempOutStream.WRITE('!ENDTRNS');
        TempOutStream.WRITE(FORMAT(CR));
        TempOutStream.WRITE(STRSUBSTNO('TRNS%1%1GENERAL JOURNAL%1 7/1/16%1Savings%1%1 650%1%1', Tab));
        TempOutStream.WRITE(FORMAT(CR));
        TempOutStream.WRITE('ENDTRNS');

        ServerFilePath := CopyStr(FileManagement.ServerTempFileName('.iif'), 1, MaxStrLen(ServerFilePath));
        FileManagement.BLOBExportToServerFile(TempBlob, ServerFilePath);
    end;

    local procedure GenerateIIFFileMissingAccountField(var ServerFilePath: Text[250]);
    var
        TempBlob: Codeunit "Temp Blob";
        TempOutStream: OutStream;
        Tab: Char;
        CR: Char;
    begin
        Tab := 9;
        CR := 13;

        TempBlob.CreateOutStream(TempOutStream, TEXTENCODING::UTF8);
        TempOutStream.WRITE(STRSUBSTNO('!TRNS%1TRNSID%1TRNSTYPE%1DATE%1ABCD%1CLASS%1AMOUNT%1DOCNUM%1MEMO', Tab));
        TempOutStream.WRITE(FORMAT(CR));
        TempOutStream.WRITE(STRSUBSTNO('!SPL%1SPLID%1TRNSTYPE%1DATE%1ABCD%1CLASS%1AMOUNT%1DOCNUM%1MEMO', Tab));
        TempOutStream.WRITE(FORMAT(CR));
        TempOutStream.WRITE('!ENDTRNS');
        TempOutStream.WRITE(FORMAT(CR));
        TempOutStream.WRITE(STRSUBSTNO('TRNS%1%1GENERAL JOURNAL%1 7/1/16%1Savings%1%1 650%1%1', Tab));
        TempOutStream.WRITE(FORMAT(CR));
        TempOutStream.WRITE('ENDTRNS');

        ServerFilePath := CopyStr(FileManagement.ServerTempFileName('.iif'), 1, MaxStrLen(ServerFilePath));
        FileManagement.BLOBExportToServerFile(TempBlob, ServerFilePath);
    end;

    local procedure GenerateIIFFileMissingAmountField(var ServerFilePath: Text[250]);
    var
        TempBlob: Codeunit "Temp Blob";
        TempOutStream: OutStream;
        Tab: Char;
        CR: Char;
    begin
        Tab := 9;
        CR := 13;

        TempBlob.CreateOutStream(TempOutStream, TEXTENCODING::UTF8);
        TempOutStream.WRITE(STRSUBSTNO('!TRNS%1TRNSID%1TRNSTYPE%1DATE%1ACCNT%1CLASS%1ABCD%1DOCNUM%1MEMO', Tab));
        TempOutStream.WRITE(FORMAT(CR));
        TempOutStream.WRITE(STRSUBSTNO('!SPL%1SPLID%1TRNSTYPE%1DATE%1ACCNT%1CLASS%1ABCD%1DOCNUM%1MEMO', Tab));
        TempOutStream.WRITE(FORMAT(CR));
        TempOutStream.WRITE('!ENDTRNS');
        TempOutStream.WRITE(FORMAT(CR));
        TempOutStream.WRITE(STRSUBSTNO('TRNS%1%1GENERAL JOURNAL%1 7/1/16%1Savings%1%1 650%1%1', Tab));
        TempOutStream.WRITE(FORMAT(CR));
        TempOutStream.WRITE('ENDTRNS');

        ServerFilePath := CopyStr(FileManagement.ServerTempFileName('.iif'), 1, MaxStrLen(ServerFilePath));
        FileManagement.BLOBExportToServerFile(TempBlob, ServerFilePath);
    end;

    [MessageHandler]
    procedure NoGenJnlTransactionsMessageHandler(Message: Text[1024]);
    begin
        Assert.AreEqual(NoGenJnlTransactionsMsg, Message, '');
    end;

    [MessageHandler]
    procedure UnsupportedTransactionsMessageHandler(Message: Text[1024]);
    begin
        Assert.AreEqual(NonGJTransactionsDetectedMsg, Message, '');
    end;
}

