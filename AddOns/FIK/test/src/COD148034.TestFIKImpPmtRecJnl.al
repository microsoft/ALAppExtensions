// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

Codeunit 148034 "TestFIKImp.Pmt. Rec. Jnl."
{
    Subtype = Test;
    TestPermissions = Disabled;

    VAR
        LibraryERM: Codeunit "Library - ERM";
        Assert: Codeunit Assert;
        AssertMsg: Label '%1 Field:"%2" different from expected.', Locked = true;
        FIKFileNotValidErr: Label 'The selected file is not a FIK file.', Locked = true;
        WrongBankAccountErr: Label 'You cannot use bank account', Locked = true;

    trigger OnRun();
    begin
        // [FEATURE] [FIK]
    end;

    [Test]
    PROCEDURE TestFIKImport();
    VAR
        DataExch: Record "Data Exch.";
        TempBankAccReconLineExpected: Record "Bank Acc. Reconciliation Line" temporary;
        BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line";
        BankAccReconciliation: Record "Bank Acc. Reconciliation";
        TempBlobOEM: Codeunit "Temp Blob";
        TempBlobANSI: Codeunit "Temp Blob";
        FIKManagement: Codeunit FIKManagement;
        OutStream: OutStream;
        LineNo: Integer;
    BEGIN
        // Setup
        TempBlobOEM.CreateOutStream(OutStream);

        // Sample lines
        WriteLine(OutStream, 'FI0101308881000253547880000000000000000000020140205143901P');
        WriteLine(OutStream, 'FI020889580397500000121499000000000000000000000000020140205143901');
        WriteLine(OutStream, 'FI03020120928710000000000001030105301520120928018224613720141001000000002880813' +
          '                      CC000000000N');
        WriteLine(OutStream, 'FI03020140114710000000000000030154193820140114458161702320140115000000000131250' +
          '                      CC000000000N');
        WriteLine(OutStream, 'FI0808895803900000000108000000059457029000000000000000');
        WriteLine(OutStream, 'FI09013088810002535478800000000000000000000100000000108');
        ConvertOEMToANSI(TempBlobOEM, TempBlobANSI);
        SetupSourceMock('FIK71', TempBlobANSI);

        // Exercise
        CreateBankAccReconTemplate(BankAccReconciliation, '');
        FIKManagement.ImportFIKToBankAccRecLine(BankAccReconciliation);

        DataExch.SETRANGE("Data Exch. Def Code", 'FIK71');
        DataExch.FINDLAST();

        BankAccReconciliationLine.SETRANGE("Statement Type", BankAccReconciliation."Statement Type");
        BankAccReconciliationLine.SETRANGE("Bank Account No.", BankAccReconciliation."Bank Account No.");
        BankAccReconciliationLine.SETRANGE("Statement No.", BankAccReconciliation."Statement No.");
        BankAccReconciliationLine.FINDSET();

        // Verify
        Assert.IsTrue(BankAccReconciliation.FIKPaymentReconciliation, 'FIK Payment Reconciliation was not set to true');
        LineNo := BankAccReconciliationLine."Statement Line No.";
        CreateLine(TempBankAccReconLineExpected,
          BankAccReconciliationLine,
          DataExch."Entry No.",
          1,
          LineNo * 1,
          DMY2DATE(1, 10, 2014),
          'FIK 000000001030105',
          28808.13);

        TempBankAccReconLineExpected.PaymentReference := '103010';
        TempBankAccReconLineExpected.MODIFY();

        BankAccReconciliationLine.NEXT();
        CreateLine(TempBankAccReconLineExpected,
          BankAccReconciliationLine,
          DataExch."Entry No.",
          2,
          LineNo * 2,
          DMY2DATE(15, 1, 2014),
          'FIK 000000000030154',
          1312.5);

        TempBankAccReconLineExpected.PaymentReference := '3015';
        TempBankAccReconLineExpected.MODIFY();

        AssertDataInTable(TempBankAccReconLineExpected, BankAccReconciliationLine, '');
    END;

    [Test]
    PROCEDURE TestFIKImportWrongFileFormat();
    VAR
        BankAccReconciliation: Record "Bank Acc. Reconciliation";
        TempBlobOEM: Codeunit "Temp Blob";
        TempBlobANSI: Codeunit "Temp Blob";
        FIKManagement: Codeunit FIKManagement;
        OutStream: OutStream;
    BEGIN
        // Setup
        TempBlobOEM.CreateOutStream(OutStream);

        // Sample lines
        WriteLine(OutStream, 'FI0101308881000253547880000000000000000000020140205143901P');
        WriteLine(OutStream, 'FI020889580397500000121499000000000000000000000000020140205143901');
        WriteLine(OutStream, 'Not Valid FIK line');
        WriteLine(OutStream, 'FI03020140114710000868040331198157193820140114458161702320140115000000000131250' +
          '                      CC000000000N');
        WriteLine(OutStream, 'FI0808895803900000000108000000059457029000000000000000');
        WriteLine(OutStream, 'FI09013088810002535478800000000000000000000100000000108');
        ConvertOEMToANSI(TempBlobOEM, TempBlobANSI);
        SetupSourceMock('FIK71', TempBlobANSI);

        // Exercise
        CreateBankAccReconTemplate(BankAccReconciliation, '');
        ASSERTERROR FIKManagement.ImportFIKToBankAccRecLine(BankAccReconciliation);

        // Verify
        Assert.ExpectedError(FIKFileNotValidErr);
        Assert.IsFalse(BankAccReconciliation.FIKPaymentReconciliation, 'FIK Payment Reconciliation should not be updated');
    END;

    [Test]
    PROCEDURE TestFIKImportWrongBankAccNotDKK();
    VAR
        BankAccReconciliation: Record "Bank Acc. Reconciliation";
        Currency: Record Currency;
        TempBlobOEM: Codeunit "Temp Blob";
        TempBlobANSI: Codeunit "Temp Blob";
        FIKManagement: Codeunit FIKManagement;
        OutStream: OutStream;
    BEGIN
        // Setup
        TempBlobOEM.CreateOutStream(OutStream);

        // Sample lines
        WriteLine(OutStream, 'FI0101308881000253547880000000000000000000020140205143901P');
        WriteLine(OutStream, 'FI020889580397500000121499000000000000000000000000020140205143901');
        WriteLine(OutStream, 'FI03020120928710000000000001030105301520120928018224613720141001000000002880813' +
          '                      CC000000000N');
        WriteLine(OutStream, 'FI03020140114710000000000000030154193820140114458161702320140115000000000131250' +
          '                      CC000000000N');
        WriteLine(OutStream, 'FI0808895803900000000108000000059457029000000000000000');
        WriteLine(OutStream, 'FI09013088810002535478800000000000000000000100000000108');
        ConvertOEMToANSI(TempBlobOEM, TempBlobANSI);
        SetupSourceMock('FIK71', TempBlobANSI);

        // Exercise
        LibraryERM.CreateCurrency(Currency);

        // Create Bank Account with currency different from LCY
        CreateBankAccReconTemplate(BankAccReconciliation, Currency.Code);

        ASSERTERROR FIKManagement.ImportFIKToBankAccRecLine(BankAccReconciliation);

        // Verify
        Assert.ExpectedError(WrongBankAccountErr);
        Assert.IsFalse(BankAccReconciliation.FIKPaymentReconciliation, 'FIK Payment Reconciliation should not be updated');
    END;

    LOCAL PROCEDURE CreateBankAccReconTemplate(VAR BankAccReconciliation: Record "Bank Acc. Reconciliation"; CurrencyCode: Code[10]);
    VAR
        BankAccount: Record "Bank Account";
    BEGIN
        CreateBankAccount(BankAccount);
        IF CurrencyCode <> '' THEN BEGIN
            BankAccount.VALIDATE("Currency Code", CurrencyCode);
            BankAccount.MODIFY();
        END;
        LibraryERM.CreateBankAccReconciliation(BankAccReconciliation, BankAccount."No.",
          BankAccReconciliation."Statement Type"::"Payment Application");
    END;

    LOCAL PROCEDURE CreateBankAccount(VAR BankAccount: Record "Bank Account");
    BEGIN
        LibraryERM.CreateBankAccount(BankAccount);
    END;

    LOCAL PROCEDURE WriteLine(OutStream: OutStream; Text: Text);
    BEGIN
        OutStream.WRITETEXT(Text);
        OutStream.WRITETEXT();
    END;

    LOCAL PROCEDURE ConvertOEMToANSI(SourceTempBlob: Codeunit "Temp Blob"; VAR DestinationTempBlob: Codeunit "Temp Blob");
    VAR
        InStreamObj: InStream;
        OutStreamObj: OutStream;
        ParsedText: Text;
    BEGIN
        SourceTempBlob.CreateInStream(InStreamObj);
        DestinationTempBlob.CreateOutStream(OutStreamObj, TextEncoding::Windows);

        WHILE NOT InStreamObj.EOS() DO begin
            InStreamObj.ReadText(ParsedText);
            OutStreamObj.WriteText(ParsedText);
            OutStreamObj.WriteText();
        END;

    END;

    LOCAL PROCEDURE SetupSourceMock(DataExchDefCode: Code[20]; TempBlob: Codeunit "Temp Blob");
    VAR
        DataExchDef: Record "Data Exch. Def";
        TempBLobList: Codeunit "Temp Blob List";
        ERMPESourceTestMock: Codeunit "ERM PE Source Test Mock";
    begin
        TempBLobList.Add(TempBlob);
        ERMPESourceTestMock.SetTempBlobList(TempBlobList);

        DataExchDef.GET(DataExchDefCode);
        DataExchDef."Ext. Data Handling Codeunit" := CODEUNIT::"ERM PE Source test mock";
        DataExchDef.MODIFY();
    END;

    LOCAL PROCEDURE CreateLine(VAR TempBankAccReconciliationLine: Record "Bank Acc. Reconciliation Line" temporary; BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line"; DataExchEntryNo: Integer; DataExchLineNo: Integer; LineNo: Integer; PostingDate: Date; Description: Text[50]; Amount: Decimal);
    BEGIN
        TempBankAccReconciliationLine.COPY(BankAccReconciliationLine);
        TempBankAccReconciliationLine.VALIDATE("Data Exch. Entry No.", DataExchEntryNo);
        TempBankAccReconciliationLine.VALIDATE("Data Exch. Line No.", DataExchLineNo);
        TempBankAccReconciliationLine.VALIDATE("Statement Line No.", LineNo);
        TempBankAccReconciliationLine.VALIDATE("Transaction Date", PostingDate);
        TempBankAccReconciliationLine.VALIDATE(Description, Description);
        TempBankAccReconciliationLine.VALIDATE("Statement Amount", Amount);
        TempBankAccReconciliationLine.INSERT();
    END;

    LOCAL PROCEDURE AssertDataInTable(VAR TempBankAccReconciliationLineExp: Record "Bank Acc. Reconciliation Line" temporary; VAR BankAccReconciliationLineActual: Record "Bank Acc. Reconciliation Line"; Msg: Text);
    VAR
        LineNo: Integer;
    BEGIN
        TempBankAccReconciliationLineExp.FINDFIRST();
        BankAccReconciliationLineActual.FINDFIRST();
        REPEAT
            LineNo += 1;
            AreEqualRecords(TempBankAccReconciliationLineExp, BankAccReconciliationLineActual, Msg + 'Line:' + FORMAT(LineNo) + ' ');
        UNTIL (TempBankAccReconciliationLineExp.NEXT() = 0) OR (BankAccReconciliationLineActual.NEXT() = 0);
        Assert.AreEqual(TempBankAccReconciliationLineExp.COUNT(), BankAccReconciliationLineActual.COUNT(), 'Row count does not match');
    END;

    LOCAL PROCEDURE AreEqualRecords(ExpectedRecord: Variant; ActualRecord: Variant; Msg: Text);
    VAR
        ExpectedRecRef: RecordRef;
        ActualRecRef: RecordRef;
        i: Integer;
    BEGIN
        ExpectedRecRef.GETTABLE(ExpectedRecord);
        ActualRecRef.GETTABLE(ActualRecord);

        Assert.AreEqual(ExpectedRecRef.NUMBER(), ActualRecRef.NUMBER(), 'Tables are not the same');

        FOR i := 1 TO ExpectedRecRef.FIELDCOUNT() DO
            IF IsSupportedType(FORMAT(ExpectedRecRef.FIELDINDEX(i).VALUE())) THEN
                Assert.AreEqual(FORMAT(ExpectedRecRef.FIELDINDEX(i).VALUE()), FORMAT(ActualRecRef.FIELDINDEX(i).VALUE()),
                  STRSUBSTNO(AssertMsg, Msg, FORMAT(ExpectedRecRef.FIELDINDEX(i).NAME())));
    END;

    LOCAL PROCEDURE IsSupportedType(Value: Variant): Boolean;
    BEGIN
        EXIT(Value.ISBOOLEAN() OR
          Value.ISOPTION() OR
          Value.ISINTEGER() OR
          Value.ISDECIMAL() OR
          Value.ISTEXT() OR
          Value.ISCODE() OR
          Value.ISDATE() OR
          Value.ISTIME());
    END;

}

