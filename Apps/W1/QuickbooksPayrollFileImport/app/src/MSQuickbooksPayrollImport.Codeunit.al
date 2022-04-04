codeunit 1676 "MS - Quickbooks Payroll Import"
{

    trigger OnRun();
    begin
    end;

    var
        QuickbooksPayrollExtensionNameTxt: Label 'Quickbooks Payroll File Import';
        ImportPackageTxt: Label 'Import IIF file';
        FileExtensionTok: Label '*.iif', Locked = true;
        ImportingMsg: Label 'Importing Data...';
        TransactionHeaderTok: Label '!TRNS', Locked = true;
        SplitHeaderTok: Label '!SPL', Locked = true;
        TransactionLineTok: Label 'TRNS', Locked = true;
        SplitLineTok: Label 'SPL', Locked = true;
        TransactionTypeTok: Label 'TRNSTYPE', Locked = true;
        AccountNameTok: Label 'ACCNT', Locked = true;
        DateTok: Label 'DATE', Locked = true;
        AmountTok: Label 'AMOUNT', Locked = true;
        MemoTok: Label 'MEMO', Locked = true;
        GeneralJournalTok: Label 'GENERAL JOURNAL', Locked = true;
        CheckTok: Label 'CHECK', Locked = true;
        TransferTok: Label 'TRANSFER', Locked = true;
        InvalidIIFTransFileErr: Label 'This is not a valid IIF transaction file. Required token %1 could not be found in the file.', Comment = '%1 - arbitrary text';
        NoSupportedTransactionsMsg: Label 'No transactions with supported type were found in the imported file. Supported transaction types are: General Journal, Check, and Transfer.';
        NonSupportedTransactionsDetectedMsg: Label 'One or more transactions in the imported file were not imported because they are not of supported type. Supported transaction types are: General Journal, Check, and Transfer.';
        QBPayrollImportTelemetryTok: Label 'AL Quickbooks Payroll File Import', Locked = true;
        TransactionsImportedTxt: Label '%1 Quickbooks G/L transactions imported.', Locked = true;
        TrnsDateClassTxt: Label '!TRNS%1TRNSID%1TRNSTYPE%1DATE%1ACCNT%1CLASS%1AMOUNT%1DOCNUM%1MEMO', Locked = true;
        SplitDateClassTxt: Label '!SPL%1SPLID%1TRNSTYPE%1DATE%1ACCNT%1CLASS%1AMOUNT%1DOCNUM%1MEMO', Locked = true;
        TrnsGeneralJournalTxt: Label 'TRNS%1%1GENERAL JOURNAL%1 7/1/16%1Savings%1%1 650%1%1Savings', Locked = true;
        SplitGeneralJournalTxt: Label 'SPL%1%1GENERAL JOURNAL%1 7/1/16%1Construction:Labor%1%1 -650%1%1Construction:Labor', Locked = true;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Payroll Management", 'OnRegisterPayrollService', '', false, false)]
    local procedure OnRegisterPayrollService(var TempServiceConnection: Record "Service Connection" temporary);
    begin
        TempServiceConnection.INIT();
        TempServiceConnection."No." := FORMAT(GetAppID());
        TempServiceConnection.Name := QuickbooksPayrollExtensionNameTxt;
        TempServiceConnection.Status := TempServiceConnection.Status::Enabled;
        TempServiceConnection.INSERT();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Payroll Management", 'OnImportPayroll', '', false, false)]
    local procedure OnImportPayroll(var TempServiceConnection: Record "Service Connection" temporary; GenJournalLine: Record 81);
    var
        PayrollImportTransactions: Page "Payroll Import Transactions";
    begin
        IF NOT (TempServiceConnection."No." = FORMAT(GetAppID())) THEN
            EXIT;
        PayrollImportTransactions.Set(TempServiceConnection, GenJournalLine);
        PayrollImportTransactions.RUNMODAL();
    end;

    [EventSubscriber(ObjectType::Page, Page::"Payroll Import Transactions", 'OnImportPayrollTransactions', '', false, false)]
    local procedure OnImportPayrollTransactions(var TempServiceConnection: Record "Service Connection"; var TempImportGLTransaction: Record 1661 temporary);
    begin
        IF NOT (TempServiceConnection."No." = FORMAT(GetAppID())) THEN
            EXIT;
        TempImportGLTransaction.DELETEALL();
        ImportGLTransactionsFromIIFFile(TempImportGLTransaction);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Payroll Import Transactions", 'OnCreateSampleFile', '', false, false)]
    local procedure OnCreateSampleFile(TempServiceConnection: Record "Service Connection");
    var
        TempBlob: Codeunit "Temp Blob";
        FileMgt: Codeunit "File Management";
        OutStream: OutStream;
        Tab: Char;
    begin
        IF NOT (TempServiceConnection."No." = FORMAT(GetAppID())) THEN
            EXIT;
        TempBlob.CreateOutStream(OutStream);

        Tab := 9;

        OutStream.WRITETEXT(STRSUBSTNO(TrnsDateClassTxt, Tab));
        OutStream.WRITETEXT();
        OutStream.WRITETEXT(STRSUBSTNO(SplitDateClassTxt, Tab));
        OutStream.WRITETEXT();
        OutStream.WRITETEXT('!ENDTRNS');
        OutStream.WRITETEXT();
        OutStream.WRITETEXT(STRSUBSTNO(TrnsGeneralJournalTxt, Tab));
        OutStream.WRITETEXT();
        OutStream.WRITETEXT(STRSUBSTNO(SplitGeneralJournalTxt, Tab));
        OutStream.WRITETEXT();
        OutStream.WRITETEXT('ENDTRNS');

        FileMgt.BLOBExport(TempBlob, 'QuickbooksTransactionsSample.iif', TRUE);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUploadFile(var ServerFileName: Text[250]);
    begin
    end;

    local procedure ImportGLTransactionsFromIIFFile(var TempImportGLTransaction: Record 1661 temporary): Boolean;
    var
        FileManagement: Codeunit "File Management";
        ServerFile: Text[250];
    begin
        OnUploadFile(ServerFile);
        IF ServerFile = '' THEN
            ServerFile := COPYSTR(FileManagement.UploadFile(ImportPackageTxt, FileExtensionTok),
                1, MAXSTRLEN(ServerFile));
        IF ServerFile <> '' THEN BEGIN
            ImportGLTransactionsByIIFFileName(ServerFile, TempImportGLTransaction);
            EXIT(TRUE);
        END;
        EXIT(FALSE);
    end;

    procedure ImportGLTransactionsByIIFFileName(FileName: Text[250]; var TempImportGLTransaction: Record 1661 temporary);
    var
        TempCSVBuffer: Record 1234 temporary;
        WindowDialog: Dialog;
        Tab: Text[1];
        NonGJTransactionsDetected: Boolean;
    begin
        WindowDialog.OPEN(ImportingMsg);

        Tab[1] := 9;
        TempCSVBuffer.LoadData(FileName, Tab);
        VerifyIIFTransactionFile(TempCSVBuffer);
        InsertTransactionData(TempCSVBuffer, TempImportGLTransaction, NonGJTransactionsDetected);

        WindowDialog.CLOSE();

        Session.LogMessage('00001SZ', STRSUBSTNO(TransactionsImportedTxt, TempImportGLTransaction.COUNT()), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', QBPayrollImportTelemetryTok);
        IF NOT TempImportGLTransaction.ISEMPTY() AND NonGJTransactionsDetected THEN
            MESSAGE(NonSupportedTransactionsDetectedMsg);
    end;

    local procedure VerifyIIFTransactionFile(var TempCSVBuffer: Record 1234 temporary);
    begin
        TempCSVBuffer.SETRANGE("Field No.", 1);
        TempCSVBuffer.SETRANGE(Value, TransactionHeaderTok);
        IF TempCSVBuffer.ISEMPTY() THEN
            ERROR(InvalidIIFTransFileErr, TransactionHeaderTok);

        TempCSVBuffer.SETRANGE(Value, SplitHeaderTok);
        IF TempCSVBuffer.ISEMPTY() THEN
            ERROR(InvalidIIFTransFileErr, SplitHeaderTok);

        TempCSVBuffer.RESET();

        TempCSVBuffer.SETRANGE(Value, TransactionTypeTok);
        IF TempCSVBuffer.ISEMPTY() THEN
            ERROR(InvalidIIFTransFileErr, TransactionTypeTok);

        TempCSVBuffer.SETRANGE(Value, AmountTok);
        IF TempCSVBuffer.ISEMPTY() THEN
            ERROR(InvalidIIFTransFileErr, AmountTok);

        TempCSVBuffer.SETRANGE(Value, AccountNameTok);
        IF TempCSVBuffer.ISEMPTY() THEN
            ERROR(InvalidIIFTransFileErr, AccountNameTok);
    end;

    local procedure InsertTransactionData(var TempCSVBuffer: Record 1234 temporary; var TempImportGLTransaction: Record 1661 temporary; var NonGJTransactionsDetected: Boolean);
    var
        TransactionTypeFieldNo: Integer;
        TransactionDateFieldNo: Integer;
        TransactionAmountFieldNo: Integer;
        TransactionDescriptionFieldNo: Integer;
        TransactionAccountNameFieldNo: Integer;
        TransactionDate: Text;
        Day: Integer;
        Month: Integer;
        Year: Integer;
        MonthEnd: Integer;
        DayEnd: Integer;
        EntryNo: Integer;
    begin
        TransactionTypeFieldNo := GetIIFTransactionFileHeaderFieldNo(TempCSVBuffer, TransactionTypeTok);
        TransactionAmountFieldNo := GetIIFTransactionFileHeaderFieldNo(TempCSVBuffer, AmountTok);
        TransactionDateFieldNo := GetIIFTransactionFileHeaderFieldNo(TempCSVBuffer, DateTok);
        TransactionAccountNameFieldNo := GetIIFTransactionFileHeaderFieldNo(TempCSVBuffer, AccountNameTok);
        TransactionDescriptionFieldNo := GetIIFTransactionFileHeaderFieldNo(TempCSVBuffer, MemoTok);

        TempCSVBuffer.RESET();
        TempCSVBuffer.SETRANGE("Field No.", 1);
        TempCSVBuffer.SETFILTER(Value, '%1|%2', TransactionLineTok, SplitLineTok);
        IF TempCSVBuffer.FINDSET() THEN
            REPEAT
                IF IsSupportedTransactionType(TempCSVBuffer.GetValueOfLineAt(TransactionTypeFieldNo)) THEN BEGIN
                    TempImportGLTransaction."App ID" := GetAppID();
                    TempImportGLTransaction.VALIDATE("External Account",
                      COPYSTR(TempCSVBuffer.GetValueOfLineAt(TransactionAccountNameFieldNo),
                        1, MAXSTRLEN(TempImportGLTransaction."External Account")));
                    EVALUATE(TempImportGLTransaction.Amount, TempCSVBuffer.GetValueOfLineAt(TransactionAmountFieldNo), 9);
                    IF TransactionDateFieldNo <> -1 THEN BEGIN
                        TransactionDate := TempCSVBuffer.GetValueOfLineAt(TransactionDateFieldNo);
                        MonthEnd := STRPOS(TransactionDate, '/') - 1;
                        EVALUATE(Month, COPYSTR(TransactionDate, 1, MonthEnd));
                        TransactionDate := COPYSTR(TransactionDate, MonthEnd + 2);
                        DayEnd := STRPOS(TransactionDate, '/') - 1;
                        EVALUATE(Day, COPYSTR(TransactionDate, 1, DayEnd));
                        EVALUATE(Year, COPYSTR(TransactionDate, DayEnd + 2));
                        TempImportGLTransaction."Transaction Date" := DMY2DATE(Day, Month, DetermineQuickbooksYear(Year));
                    END;
                    IF TransactionDescriptionFieldNo <> -1 THEN
                        TempImportGLTransaction.Description :=
                          COPYSTR(TempCSVBuffer.GetValueOfLineAt(TransactionDescriptionFieldNo, True),
                            1, MAXSTRLEN(TempImportGLTransaction.Description));
                    EntryNo += 1;
                    TempImportGLTransaction."Entry No." := EntryNo;
                    TempImportGLTransaction.INSERT();
                END ELSE
                    NonGJTransactionsDetected := TRUE;
            UNTIL TempCSVBuffer.NEXT() = 0;

        IF TempImportGLTransaction.ISEMPTY() AND GUIALLOWED() THEN
            MESSAGE(NoSupportedTransactionsMsg);
    end;

    local procedure GetIIFTransactionFileHeaderFieldNo(var TempCSVBuffer: Record 1234 temporary; Token: Text): Integer;
    var
        HeaderLineNo: Integer;
    begin
        TempCSVBuffer.RESET();
        TempCSVBuffer.SETRANGE("Field No.", 1);
        TempCSVBuffer.SETRANGE(Value, TransactionHeaderTok);
        IF NOT TempCSVBuffer.FINDFIRST() THEN
            EXIT(-1);
        HeaderLineNo := TempCSVBuffer."Line No.";

        TempCSVBuffer.RESET();
        TempCSVBuffer.SETRANGE("Line No.", HeaderLineNo);
        TempCSVBuffer.SETRANGE(Value, Token);

        IF NOT TempCSVBuffer.FINDFIRST() THEN
            EXIT(-1);

        EXIT(TempCSVBuffer."Field No.");
    end;

    local procedure IsSupportedTransactionType(TransType: Text): Boolean;
    begin
        EXIT((TransType.ToUpper() = GeneralJournalTok) OR (TransType.ToUpper() = CheckTok) OR (TransType.ToUpper() = TransferTok))
    end;

    procedure GetAppID(): Guid;
    begin
        EXIT('{bc45ae22-3b5b-44b5-beb4-2a42bf79cc34}');
    end;

    local procedure DetermineQuickbooksYear(Year: Integer): Integer;
    var
        CurrentYear: Integer;
    begin
        // Quickbooks stores the date in MM/DD/YY format
        // The year has only two digits - therefore it is necessary to determine which year is it exactly
        IF Year > 100 THEN
            EXIT(Year);

        CurrentYear := DATE2DMY(TODAY(), 3);
        IF 2000 + Year <= CurrentYear THEN
            EXIT(2000 + Year);

        EXIT(1900 + Year);
    end;
}


