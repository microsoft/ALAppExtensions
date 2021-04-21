// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 148045 "Test Payroll Imp. Gen. Jnl. Ln"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;
        LibraryERM: Codeunit "Library - ERM";
        AssertMsg: Label '%1 Field: "%2" different from expected.';
        IsInitialized: Boolean;

    trigger OnRun();
    begin
        // [FEATURE] [Payroll] [Import]
    end;

    [Test]
    procedure TestDataExchDefImportedAtSetupPageOpen();
    var
        DataExchDef: record "Data Exch. Def";
        SetupDKPayrollService: TestPage "Setup DK Payroll Service";
    begin
        // [GIVEN] Empty Data Exchange Def
        DataExchDef.DeleteAll(true);

        // [WHEN] Setup DK Payroll Service Setup Page is open
        SetupDKPayrollService.OpenView();

        // [THEN] Payroll Data Exchnage Def imported
        AssertDataExchDefImported();
    end;

    [Test]
    procedure TestDataExchDefImportedAtGenLedgerSetupPageOpen();
    var
        DataExchDef: record "Data Exch. Def";
        GeneralLedgerSetup: TestPage "General Ledger Setup";
    begin
        // [GIVEN] Empty Data Exchange Def
        DataExchDef.DeleteAll(true);

        // [WHEN] General Ledger Setup Page is open
        GeneralLedgerSetup.OpenView();

        // [THEN] Payroll Data Exchnage Def imported
        AssertDataExchDefImported();
    end;

    [Test]
    procedure TestProlonSampleImport();
    var
        GenJnlLineTemplate: Record "Gen. Journal Line";
        TempExpdGenJnlLine: Record "Gen. Journal Line" temporary;
        GLAccount1: Record "G/L Account";
        GLAccount2: Record "G/L Account";
        GLAccount3: Record "G/L Account";
        TempBlobOEM: Codeunit "Temp Blob";
        TempBlobANSI: Codeunit "Temp Blob";
        ImportPayrollTransaction: Codeunit "Import Payroll Transaction";
        OutStream: OutStream;
        LineNo: Integer;
        EntryNo: Integer;
        DocNo: Code[20];
    begin
        Initialize();
        // Setup
        TempBlobOEM.CreateOutStream(OutStream);
        LibraryERM.CreateGLAccount(GLAccount1);
        LibraryERM.CreateGLAccount(GLAccount2);
        LibraryERM.CreateGLAccount(GLAccount3);
        // Sample lines
        WriteLine(OutStream, 'LINJENR-1;LINJENR-2;AFDELING;LØNART;BELØB;D/K;PERIODE;LINJETEKST;AFDELINGSSTEKST;LØNARTSTEKST;');
        WriteLine(OutStream, '4117000;' + GLAccount1."No." + ';0;0;28290,42;D;PERIODE 0513;BRUTTOSKATTEGRUNDLAG;;;');
        WriteLine(OutStream, '4117000;' + GLAccount2."No." + ';0;0;2130,36;D;PERIODE 0513;AM-PENSION;;;');
        WriteLine(OutStream, '4124100;' + GLAccount3."No." + ';0;0;5626;K;PERIODE 0513;HENSAT_A-SKAT;;;');
        ConvertOEMToANSI(TempBlobOEM, TempBlobANSI);

        // Exercise
        CreateGenJnlLineTemplateWithFilter(GenJnlLineTemplate);
        ImportPayrollTransaction.ImportPayrollDataToGL(GenJnlLineTemplate, '', TempBlobANSI, 'PROLOEN');
        EntryNo := FindDataExch('PROLOEN');

        // Verify
        LineNo := GenJnlLineTemplate."Line No.";
        DocNo := GenJnlLineTemplate."Document No.";
        CreateTempGenJnlLine(TempExpdGenJnlLine, GenJnlLineTemplate, LineNo * 1, DocNo, GLAccount1."No.", WORKDATE(),
            GLAccount1.Name + ' BRUTTOSKATTEGRUNDLAG', 'PERIODE 0513', 28290.42, EntryNo, 1);
        CreateTempGenJnlLine(TempExpdGenJnlLine, GenJnlLineTemplate, LineNo * 2, DocNo, GLAccount2."No.", WORKDATE(),
            GLAccount2.Name + ' AM-PENSION', 'PERIODE 0513', 2130.36, EntryNo, 2);
        CreateTempGenJnlLine(TempExpdGenJnlLine, GenJnlLineTemplate, LineNo * 3, DocNo, GLAccount3."No.", WORKDATE(),
            GLAccount3.Name + ' HENSAT_A-SKAT', 'PERIODE 0513', -5626, EntryNo, 3);

        AssertDataInTable(TempExpdGenJnlLine, GenJnlLineTemplate, '');
    end;

    [Test]
    procedure TestLonServiceSampleImport();
    VAR
        GenJnlLineTemplate: Record "Gen. Journal Line";
        TempExpdGenJnlLine: Record "Gen. Journal Line" temporary;
        GLAccount1: Record "G/L Account";
        ImportPayrollTransaction: Codeunit "Import Payroll Transaction";
        TempBlobOEM: Codeunit "Temp Blob";
        TempBlobANSI: Codeunit "Temp Blob";
        OutStream: OutStream;
        LineNo: Integer;
        EntryNo: Integer;
        DocNo: Code[20];
    BEGIN
        Initialize();
        // Setup
        TempBlobOEM.CreateOutStream(OutStream);
        LibraryERM.CreateGLAccount(GLAccount1);

        // Sample lines
        WriteLine(OutStream, '30.01.2012;' + GLAccount1."No." + ';-26780,45;ATP, Lønmodtager');
        WriteLine(OutStream, '29.01.2012;' + GLAccount1."No." + ';50000,45;Lønmodtager SSID');
        ConvertOEMToANSI(TempBlobOEM, TempBlobANSI);

        // Exercise
        CreateGenJnlLineTemplateWithFilter(GenJnlLineTemplate);
        ImportPayrollTransaction.ImportPayrollDataToGL(GenJnlLineTemplate, '', TempBlobANSI, 'LOENSERVICE');
        EntryNo := FindDataExch('LOENSERVICE');

        // Verify
        LineNo := GenJnlLineTemplate."Line No.";
        DocNo := GenJnlLineTemplate."Document No.";
        CreateTempGenJnlLine(TempExpdGenJnlLine, GenJnlLineTemplate, LineNo * 1, DocNo, GLAccount1."No.", DMY2DATE(30, 1, 2012),
            GLAccount1.Name + ' ATP, Lønmodtager', '', -26780.45, EntryNo, 1);
        CreateTempGenJnlLine(TempExpdGenJnlLine, GenJnlLineTemplate, LineNo * 2, DocNo, GLAccount1."No.", DMY2DATE(29, 1, 2012),
            GLAccount1.Name + ' Lønmodtager SSID', '', 50000.45, EntryNo, 2);

        AssertDataInTable(TempExpdGenJnlLine, GenJnlLineTemplate, '');
    END;

    [Test]
    PROCEDURE TestDanlonSampleImport();
    VAR
        GenJnlLineTemplate: Record "Gen. Journal Line";
        TempExpdGenJnlLine: Record "Gen. Journal Line" temporary;
        GLAccount1: Record "G/L Account";
        GLAccount2: Record "G/L Account";
        ImportPayrollTransaction: Codeunit "Import Payroll Transaction";
        TempBlobOEM: Codeunit "Temp Blob";
        TempBlobANSI: Codeunit "Temp Blob";
        OutStream: OutStream;
        LineNo: Integer;
        EntryNo: Integer;
        DocNo: Code[20];
    BEGIN
        Initialize();
        // Setup
        TempBlobOEM.CreateOutStream(OutStream);
        LibraryERM.CreateGLAccount(GLAccount1);
        LibraryERM.CreateGLAccount(GLAccount2);
        // Sample lines
        WriteLine(OutStream, 'CVR;Transaktions Dato;UKENDT;Konto Nr.;CPR-NR;Beløb;Lønart;Periode');
        WriteLine(OutStream, 'XXXXXXXX;2013-03-27;Standard;' + GLAccount1."No." + ';123456-7890;1.193.925,23;AM-indkomst, løn;');
        WriteLine(OutStream, 'XXXXXXXX;2013-03-27;Standard;' + GLAccount2."No." + ';;-8.956,93;Personalegoder;20130301-20130331');
        ConvertOEMToANSI(TempBlobOEM, TempBlobANSI);

        // Exercise
        CreateGenJnlLineTemplateWithFilter(GenJnlLineTemplate);
        ImportPayrollTransaction.ImportPayrollDataToGL(GenJnlLineTemplate, '', TempBlobANSI, 'DANLOEN');
        EntryNo := FindDataExch('DANLOEN');

        // Verify
        LineNo := GenJnlLineTemplate."Line No.";
        DocNo := GenJnlLineTemplate."Document No.";
        CreateTempGenJnlLine(TempExpdGenJnlLine, GenJnlLineTemplate, LineNo * 1, DocNo, GLAccount1."No.", DMY2DATE(27, 3, 2013),
            GLAccount1.Name + ' AM-indkomst, løn', '123456-7890', 1193925.23, EntryNo, 1);
        CreateTempGenJnlLine(TempExpdGenJnlLine, GenJnlLineTemplate, LineNo * 2, DocNo, GLAccount2."No.", DMY2DATE(27, 3, 2013),
            GLAccount2.Name + ' Personalegoder', '20130301-20130331', -8956.93, EntryNo, 2);

        AssertDataInTable(TempExpdGenJnlLine, GenJnlLineTemplate, '');
    END;

    [Test]
    PROCEDURE TestMultilonSampleImport();
    VAR
        GenJnlLineTemplate: Record "Gen. Journal Line";
        TempExpdGenJnlLine: Record "Gen. Journal Line" temporary;
        ImportPayrollTransaction: Codeunit "Import Payroll Transaction";
        TempBlobOEM: Codeunit "Temp Blob";
        TempBlobANSI: Codeunit "Temp Blob";
        OutStream: OutStream;
        LineNo: Integer;
        EntryNo: Integer;
        DocNo: Code[20];
    BEGIN
        Initialize();
        // Setup
        TempBlobOEM.CreateOutStream(OutStream);
        // Sample lines
        WriteLine(OutStream, 'ARBEJDSGIVER;KØRSELSNUMMER;KØRSELSTEKST;KONTOTEKST;Afdeling;Kontonr;DEBET;KREDIT');
        WriteLine(OutStream, '9;11303;Bagud/marts - Forud/april 2013;OVERFØRT NETTOLØN;100;2330;;123.728,99');
        WriteLine(OutStream, '9;11303;Bagud/marts - Forud/june 2013;MÅNEDSLØN;100;2910;225.589,25;');
        WriteLine(OutStream, '9;11304;Bagud/marts - Forud/april 2013;OVERFØRT NETTOLØN D-C;100;2330;782,36;3.456,15');
        WriteLine(OutStream, '9;11305;Bagud/marts - Forud/june 2013;MÅNEDSLØN NULL;100;2910;;');

        ConvertOEMToANSI(TempBlobOEM, TempBlobANSI);

        // Exercise
        CreateGenJnlLineTemplateWithFilter(GenJnlLineTemplate);
        ImportPayrollTransaction.ImportPayrollDataToGL(GenJnlLineTemplate, '', TempBlobANSI, 'MULTILOEN');
        EntryNo := FindDataExch('MULTILOEN');

        // Verify
        LineNo := GenJnlLineTemplate."Line No.";
        DocNo := GenJnlLineTemplate."Document No.";
        CreateTempGenJnlLine(TempExpdGenJnlLine, GenJnlLineTemplate, LineNo * 1, DocNo, '2330', WORKDATE(),
            'OVERFØRT NETTOLØN', '11303 Bagud/marts - Forud/april 2013', -123728.99, EntryNo, 1);
        CreateTempGenJnlLine(TempExpdGenJnlLine, GenJnlLineTemplate, LineNo * 2, DocNo, '2910', WORKDATE(),
            'MÅNEDSLØN', '11303 Bagud/marts - Forud/june 2013', 225589.25, EntryNo, 2);
        CreateTempGenJnlLine(TempExpdGenJnlLine, GenJnlLineTemplate, LineNo * 3, DocNo, '2330', WORKDATE(),
            'OVERFØRT NETTOLØN D-C', '11304 Bagud/marts - Forud/april 2013', -3456.15, EntryNo, 3);
        CreateTempGenJnlLine(TempExpdGenJnlLine, GenJnlLineTemplate, LineNo * 4, DocNo, '2910', WORKDATE(),
            'MÅNEDSLØN NULL', '11305 Bagud/marts - Forud/june 2013', 0, EntryNo, 4);

        AssertDataInTable(TempExpdGenJnlLine, GenJnlLineTemplate, '');
    END;

    [Test]
    PROCEDURE TestCombinePayrollFormats();
    VAR
        GenJnlLineTemplate: Record "Gen. Journal Line";
        TempExpdGenJnlLine: Record "Gen. Journal Line" temporary;
        GLAccount1: Record "G/L Account";
        GLAccount2: Record "G/L Account";
        ImportPayrollTransaction: Codeunit "Import Payroll Transaction";
        TempBlobOEM: Codeunit "Temp Blob";
        TempBlobOEM1: Codeunit "Temp Blob";
        TempBlobANSI: Codeunit "Temp Blob";
        TempBlobANSI1: Codeunit "Temp Blob";
        OutStream: OutStream;
        LineNo: Integer;
        EntryNo1: Integer;
        EntryNo2: Integer;
        DocNo: Code[20];
    BEGIN
        Initialize();
        // Setup
        TempBlobOEM.CreateOutStream(OutStream);
        LibraryERM.CreateGLAccount(GLAccount1);
        LibraryERM.CreateGLAccount(GLAccount2);
        WriteLine(OutStream, 'LINJENR-1;LINJENR-2;AFDELING;LØNART;BELØB;D/K;PERIODE;LINJETEKST;AFDELINGSSTEKST;LØNARTSTEKST;');
        WriteLine(OutStream, '4117000;' + GLAccount1."No." + ';0;0;28290,42;D;PERIODE 0513;BRUTTOSKATTEGRUNDLAG;;;');
        ConvertOEMToANSI(TempBlobOEM, TempBlobANSI);

        CreateGenJnlLineTemplateWithFilter(GenJnlLineTemplate);
        ImportPayrollTransaction.ImportPayrollDataToGL(GenJnlLineTemplate, '', TempBlobANSI, 'PROLOEN');
        EntryNo1 := FindDataExch('PROLOEN');

        TempBlobOEM1.CreateOutStream(OutStream);
        WriteLine(OutStream, '30.01.2012;' + GLAccount2."No." + ';-26780,45;ATP, Lønmodtager');
        ConvertOEMToANSI(TempBlobOEM1, TempBlobANSI1);

        // Exercise
        ImportPayrollTransaction.ImportPayrollDataToGL(GenJnlLineTemplate, '', TempBlobANSI1, 'LOENSERVICE');
        EntryNo2 := FindDataExch('LOENSERVICE');

        // Verify
        LineNo := GenJnlLineTemplate."Line No.";
        DocNo := GenJnlLineTemplate."Document No.";
        CreateTempGenJnlLine(TempExpdGenJnlLine, GenJnlLineTemplate, LineNo * 1, DocNo, GLAccount1."No.", WORKDATE(),
            GLAccount1.Name + ' BRUTTOSKATTEGRUNDLAG', 'PERIODE 0513', 28290.42, EntryNo1, 1);
        CreateTempGenJnlLine(TempExpdGenJnlLine, GenJnlLineTemplate, LineNo * 2, IncCode(1, DocNo), GLAccount2."No.", DMY2DATE(30, 1, 2012),
            GLAccount2.Name + ' ATP, Lønmodtager', '', -26780.45, EntryNo2, 1);

        AssertDataInTable(TempExpdGenJnlLine, GenJnlLineTemplate, '');
    END;

    [Test]
    PROCEDURE TestDatalonSampleImport();
    VAR
        GenJnlLineTemplate: Record "Gen. Journal Line";
        TempExpdGenJnlLine: Record "Gen. Journal Line" temporary;
        GLAccount1: Record "G/L Account";
        GLAccount2: Record "G/L Account";
        ImportPayrollTransaction: Codeunit "Import Payroll Transaction";
        TempBlobOEM: Codeunit "Temp Blob";
        TempBlobANSI: Codeunit "Temp Blob";
        OutStream: OutStream;
        LineNo: Integer;
        EntryNo: Integer;
        DocNo: Code[20];
        Tab: Text[1];
        FileLine: Text;
    BEGIN
        Initialize();
        // Setup
        TempBlobOEM.CreateOutStream(OutStream);
        // Sample lines
        Tab[1] := 9;
        FileLine := PADSTR('30.01.2012', 11, Tab) + PADSTR('2910', 5, Tab) + PADSTR('-26780,45', 10, Tab) + 'ATP, Lønmodtager';
        WriteLine(OutStream, FileLine);
        FileLine := PADSTR('29.01.2012', 11, Tab) + PADSTR('8710', 5, Tab) + PADSTR('50000,45', 9, Tab) + 'Lønmodtager SSID';
        WriteLine(OutStream, FileLine);
        ConvertOEMToANSI(TempBlobOEM, TempBlobANSI);

        // Exercise
        CreateGenJnlLineTemplateWithFilter(GenJnlLineTemplate);
        ImportPayrollTransaction.ImportPayrollDataToGL(GenJnlLineTemplate, '', TempBlobANSI, 'DATALOEN');
        EntryNo := FindDataExch('DATALOEN');

        // Verify
        LineNo := GenJnlLineTemplate."Line No.";
        DocNo := GenJnlLineTemplate."Document No.";
        GLAccount1.GET(2910);
        GLAccount2.GET(8710);
        CreateTempGenJnlLine(TempExpdGenJnlLine, GenJnlLineTemplate, LineNo * 1, DocNo, GLAccount1."No.", DMY2DATE(30, 1, 2012),
            GLAccount1.Name + ' ATP, Lønmodtager', '', -26780.45, EntryNo, 1);
        CreateTempGenJnlLine(TempExpdGenJnlLine, GenJnlLineTemplate, LineNo * 2, DocNo, GLAccount2."No.", DMY2DATE(29, 1, 2012),
            GLAccount2.Name + ' Lønmodtager SSID', '', 50000.45, EntryNo, 2);

        AssertDataInTable(TempExpdGenJnlLine, GenJnlLineTemplate, '');
    END;

    procedure Initialize();
    begin
        if IsInitialized then
            exit;

        Codeunit.Run(Codeunit::"ImportPayrollDataExchDef");
        IsInitialized := true;
    end;

    local procedure AssertDataExchDefImported();
    var
        DataExchDef: Record "Data Exch. Def";
    begin
        DataExchDef.SetFilter(Code, 'DANLOEN');
        Assert.RecordCount(DataExchDef, 1);
        DataExchDef.Reset();
        DataExchDef.SetFilter(Code, 'DATALOEN');
        Assert.RecordCount(DataExchDef, 1);
        DataExchDef.Reset();
        DataExchDef.SetFilter(Code, 'LOENSERVICE');
        Assert.RecordCount(DataExchDef, 1);
        DataExchDef.Reset();
        DataExchDef.SetFilter(Code, 'MULTILOEN');
        Assert.RecordCount(DataExchDef, 1);
        DataExchDef.Reset();
        DataExchDef.SetFilter(Code, 'PROLOEN');
        Assert.RecordCount(DataExchDef, 1);
    end;

    local procedure WriteLine(OutStream: OutStream; Text: Text)
    begin
        OutStream.WriteText(Text);
        OutStream.WriteText();
    end;

    local procedure CreateGenJnlLineTemplateWithFilter(var GenJnlLineTemplate: Record "Gen. Journal Line");
    var
        GenJnlTemplate: Record "Gen. Journal Template";
        GenJnlBatch: Record "Gen. Journal Batch";
    begin
        LibraryERM.CreateGenJournalTemplate(GenJnlTemplate);
        LibraryERM.CreateGenJournalBatch(GenJnlBatch, GenJnlTemplate.Name);

        LibraryERM.CreateGeneralJnlLine(GenJnlLineTemplate, GenJnlTemplate.Name, GenJnlBatch.Name, GenJnlLineTemplate."Document Type"::" ",
            GenJnlLineTemplate."Account Type"::"G/L Account", '', 0);
        GenJnlLineTemplate.VALIDATE("External Document No.", '');
        GenJnlLineTemplate.MODIFY(TRUE);
        GenJnlLineTemplate.DELETE(TRUE); // The template needs to removed to not skew when comparing testresults.

        GenJnlLineTemplate.SETRANGE("Journal Template Name", GenJnlTemplate.Name);
        GenJnlLineTemplate.SETRANGE("Journal Batch Name", GenJnlBatch.Name);
    end;

    local procedure CreateTempGenJnlLine(var TempGenJnlLine: Record "Gen. Journal Line" temporary; GenJnlLineTemplate: Record "Gen. Journal Line"; LineNo: Integer; DocumentNo: Code[20]; AccountNo: Code[20]; PostingDate: Date; Description: Text; TransactionInfo: Text[100]; Amount: Decimal; EntryNo: Integer; ExchLineNo: Integer);
    BEGIN
        TempGenJnlLine.COPY(GenJnlLineTemplate);
        TempGenJnlLine.VALIDATE("Line No.", LineNo);
        TempGenJnlLine.VALIDATE("Document No.", DocumentNo);
        TempGenJnlLine.VALIDATE("Account No.", AccountNo);
        TempGenJnlLine.VALIDATE("Posting Date", PostingDate);
        TempGenJnlLine.VALIDATE(Description, Description);
        TempGenJnlLine.VALIDATE("Transaction Information", TransactionInfo);
        TempGenJnlLine.VALIDATE(Amount, Amount);
        TempGenJnlLine.VALIDATE("Data Exch. Entry No.", EntryNo);
        TempGenJnlLine.VALIDATE("Data Exch. Line No.", ExchLineNo);
        TempGenJnlLine.INSERT();
    END;

    local procedure AssertDataInTable(var Expected: Record "Gen. Journal Line" temporary; var Actual: Record "Gen. Journal Line"; Msg: Text);
    VAR
        LineNo: Integer;
    BEGIN
        Expected.FINDFIRST();
        Actual.FINDFIRST();
        REPEAT
            LineNo += 1;
            AreEqualRecords(Expected, Actual, Msg + 'Line:' + FORMAT(LineNo) + ' ');
        UNTIL (Expected.NEXT() = 0) OR (Actual.NEXT() = 0);
        Assert.AreEqual(Expected.COUNT(), Actual.COUNT(), 'Row count does not match');
    end;

    local procedure IncCode(IncrementCount: Integer; TextToIncrement: Code[20]): Code[20];
    VAR
        i: Integer;
    BEGIN
        FOR i := 1 TO IncrementCount DO
            TextToIncrement := INCSTR(TextToIncrement);

        EXIT(TextToIncrement);
    END;

    local procedure AreEqualRecords(ExpectedRecord: Variant; ActualRecord: Variant; Msg: Text);
    VAR
        ExpectedRecRef: RecordRef;
        ActualRecRef: RecordRef;
        i: Integer;
    BEGIN
        ExpectedRecRef.GETTABLE(ExpectedRecord);
        ActualRecRef.GETTABLE(ActualRecord);

        Assert.AreEqual(ExpectedRecRef.NUMBER(), ActualRecRef.NUMBER(), 'Tables are not the same');

        FOR i := 1 TO ExpectedRecRef.FIELDCOUNT() DO
            IF IsSupportedType(ExpectedRecRef.FIELDINDEX(i).VALUE()) THEN
                Assert.AreEqual(ExpectedRecRef.FIELDINDEX(i).VALUE(), ActualRecRef.FIELDINDEX(i).VALUE(),
                    STRSUBSTNO(AssertMsg, Msg, ExpectedRecRef.FIELDINDEX(i).NAME()));
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

    local procedure ConvertOEMToANSI(SourceTempBlob: Codeunit "Temp Blob"; VAR DestinationTempBlob: Codeunit "Temp Blob");
    VAR
        InStream: InStream;
        OutStream: OutStream;
        EncodedText: Text;
    BEGIN
        SourceTempBlob.CreateInStream(InStream);
        DestinationTempBlob.CreateOutStream(OutStream, TextEncoding::Windows);

        while 0 <> InStream.READTEXT(EncodedText) do begin
            OutStream.WriteText(EncodedText);
            OutStream.WriteText();
        end;
    END;

    LOCAL PROCEDURE FindDataExch(DataExchDefCode: Text): Integer;
    VAR
        DataExch: Record "Data Exch.";
    BEGIN
        DataExch.SETRANGE("Data Exch. Def Code", DataExchDefCode);
        DataExch.FINDLAST();
        EXIT(DataExch."Entry No.");
    END;

}