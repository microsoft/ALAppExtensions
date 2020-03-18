codeunit 148000 "Payroll Integration Test"
{
    EventSubscriberInstance = Manual;
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Payroll] [Import] [Huldt And Lillevik]
    end;

    var
        Assert: Codeunit Assert;
        LibraryApplicationArea: Codeunit "Library - Application Area";
        LibraryDimension: Codeunit "Library - Dimension";
        LibraryERM: Codeunit "Library - ERM";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        IsInitialized: Boolean;
        DataExchNameTok: Label 'HULDT-LILLEVIK', locked = true;
        AmountInCentsTok: Label 'AMOUNT_IN_CENTS', locked = true;
        BlankDimCodeTok: Label 'BLANK_DIM_CODE', locked = true;
        EvaluateTextToIntegerTok: Label 'EVAL_TXT_TO_INT', locked = true;
        AssertMsg: Label '%1 Field: "%2" different from expected.';
        DimCodeDoesNotExistErr: Label 'contains a value (%1) that cannot be found in the related table (Dimension Value)';

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TransformAmountInCentsWithLeadingZeroes()
    var
        TransformationRule: record "Transformation Rule";
    begin
        // [SCENARIO] 'AMOUNT_IN_CENTS' rule uses nb-NO culture for decimals
        Initialize();
        TransformationRule.Code := CopyStr(AmountInCentsTok, 1, MaxStrLen(TransformationRule.Code));
        TransformationRule."Transformation Type" := TransformationRule."Transformation Type"::Custom;
        Assert.AreEqual('12340,05', TransformationRule.TransformText('000001234005'), '00001234005');
        Assert.AreEqual('-12340,5', TransformationRule.TransformText('-00001234050'), '-0001234050');
        Assert.AreEqual('0', TransformationRule.TransformText('000000000000'), '00000000000');
        Assert.AreEqual('0', TransformationRule.TransformText('-00000000000'), '-0000000000');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TransformCodeWithLeadingZeroes()
    var
        TransformationRule: record "Transformation Rule";
    begin
        // [SCENARIO] 'EVAL_TXT_TO_INT' rule removes leading zeroes in numeric string
        Initialize();
        TransformationRule.Code := CopyStr(EvaluateTextToIntegerTok, 1, MaxStrLen(TransformationRule.Code));
        TransformationRule."Transformation Type" := TransformationRule."Transformation Type"::Custom;
        Assert.AreEqual('5020', TransformationRule.TransformText('00005020'), '00005020');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure BlankDimCodeIfImportDisabled()
    var
        TransformationRule: record "Transformation Rule";
        GLSetup: Record "General Ledger Setup";
    begin
        // [FEATURE] [Dimension]
        // [SCENARIO] 'BLANK_DIM_CODE' rule returns blank string if "Import Dimension Codes" is 'No'
        Initialize();
        GLSetup.Get();
        GLSetup."Import Dimension Codes" := false;
        GLSetup.Modify();

        TransformationRule.Code := CopyStr(BlankDimCodeTok, 1, MaxStrLen(TransformationRule.Code));
        TransformationRule."Transformation Type" := TransformationRule."Transformation Type"::Custom;
        Assert.AreEqual('', TransformationRule.TransformText('X'), 'Should be blank.');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure KeepDimCodeIfImportEnabled()
    var
        TransformationRule: record "Transformation Rule";
        GLSetup: Record "General Ledger Setup";
    begin
        // [FEATURE] [Dimension]
        // [SCENARIO] 'BLANK_DIM_CODE' rule returns the same string if "Import Dimension Codes" is 'Yes'
        Initialize();
        GLSetup.Get();
        GLSetup."Import Dimension Codes" := true;
        GLSetup.Modify();

        TransformationRule.Code := CopyStr(BlankDimCodeTok, 1, MaxStrLen(TransformationRule.Code));
        TransformationRule."Transformation Type" := TransformationRule."Transformation Type"::Custom;
        Assert.AreEqual('X', TransformationRule.TransformText('X'), 'Should be the same.');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure SampleImportWithDimensions();
    var
        GenJnlLineTemplate: Record "Gen. Journal Line";
        TempExpdGenJnlLine: Record "Gen. Journal Line" temporary;
        GLAccount: array[3] of Record "G/L Account";
        DimValue: array[2] of Record "Dimension Value";
        TempBlobOEM: Codeunit "Temp Blob";
        TempBlobANSI: Codeunit "Temp Blob";
        ImportPayrollTransaction: Codeunit "Import Payroll Transaction";
        GeneralLedgerSetupPage: TestPage "General Ledger Setup";
        OutStream: OutStream;
        LineNo: Integer;
        DocNo: Code[20];
        PostingDate: date;
    begin
        // [SCENARIO] Import the 3-line sample file leads to creation of 3 journal lines with amounts.
        Initialize();
        // [GIVEN] 'HULDT-LILLEVIK' data exchange definition is created and set in GLSetup."Payroll Trans. Import Format"
        GeneralLedgerSetupPage.OpenView();
        GeneralLedgerSetupPage."Payroll Trans. Import Format".SetValue(DataExchNameTok);
        // [GIVEN] "Import Dimension Codes" is Yes
        GeneralLedgerSetupPage."Import Dimension Codes".SetValue(Format(true));
        GeneralLedgerSetupPage.Close();

        // [GIVEN] the sample file with 3 lines
        TempBlobOEM.CreateOutStream(OutStream);
        LibraryERM.CreateGLAccount(GLAccount[1]);
        LibraryERM.CreateGLAccount(GLAccount[2]);
        LibraryERM.CreateGLAccount(GLAccount[3]);
        LibraryDimension.GetGlobalDimCodeValue(1, DimValue[1]);
        LibraryDimension.GetGlobalDimCodeValue(2, DimValue[2]);
        PostingDate := DMY2Date(20, 1, 2017);
        // Sample lines
        WriteLine(OutStream, GLAccount[1]."No." + '; 0;;' + DimValue[2].Code + ';00000000;00000000;00000000;00000000;00000000;        ;;20012017;   ;20012017;0000000000;0000000000;-000058570');
        WriteLine(OutStream, GLAccount[2]."No." + '; 0;' + DimValue[1].Code + ';' + DimValue[2].Code + ';00000000;00000000;00000000;00000000;00000000;        ;;20012017;   ;20012017;0000066000;0000000000;0031182900');
        WriteLine(OutStream, GLAccount[3]."No." + '; 0;' + DimValue[1].Code + ';;00000000;00000000;00000000;00000000;00000000;        ;;20012017;   ;20012017;0000104050;0000000000;0005902502');
        ConvertOEMToANSI(TempBlobOEM, TempBlobANSI);
        // [WHEN] run ImportPayrollDataToGL
        CreateGenJnlLineTemplateWithFilter(GenJnlLineTemplate);
        ImportPayrollTransaction.ImportPayrollDataToGL(GenJnlLineTemplate, '', TempBlobANSI, copystr(DataExchNameTok, 1, 20));

        // [THEN] 3 journal lines are created
        LineNo := GenJnlLineTemplate."Line No.";
        DocNo := GenJnlLineTemplate."Document No.";
        CreateTempGenJnlLine(TempExpdGenJnlLine, GenJnlLineTemplate, LineNo * 1, DocNo, GLAccount[1]."No.", PostingDate, GLAccount[1].Name, 0, -585.70, '', DimValue[2].Code);
        CreateTempGenJnlLine(TempExpdGenJnlLine, GenJnlLineTemplate, LineNo * 2, DocNo, GLAccount[2]."No.", PostingDate, GLAccount[2].Name, 660, 311829.00, DimValue[1].Code, DimValue[2].Code);
        CreateTempGenJnlLine(TempExpdGenJnlLine, GenJnlLineTemplate, LineNo * 3, DocNo, GLAccount[3]."No.", PostingDate, GLAccount[3].Name, 1040.5, 59025.02, DimValue[1].Code, '');

        AssertDataInTable(TempExpdGenJnlLine, GenJnlLineTemplate, '');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure SampleImportWithoutDimensions();
    var
        GenJnlLineTemplate: Record "Gen. Journal Line";
        TempExpdGenJnlLine: Record "Gen. Journal Line" temporary;
        GLAccount: Record "G/L Account";
        DimValue: array[2] of Record "Dimension Value";
        ImportPayrollTransaction: Codeunit "Import Payroll Transaction";
        TempBlobOEM: Codeunit "Temp Blob";
        TempBlobANSI: Codeunit "Temp Blob";
        GeneralLedgerSetupPage: TestPage "General Ledger Setup";
        OutStream: OutStream;
        LineNo: Integer;
        DocNo: Code[20];
        PostingDate: date;
    begin
        // [FEATURE] [Dimension]
        // [SCENARIO] Dimension data is not imported if "Import Dimension Codes" is 'No'.
        Initialize();
        // [GIVEN] 'HULDT-LILLEVIK' data exchange definition is created
        GeneralLedgerSetupPage.OpenView();
        // [GIVEN] "Import Dimension Codes" is 'No'
        GeneralLedgerSetupPage."Import Dimension Codes".SetValue(Format(false));
        GeneralLedgerSetupPage.Close();
        // [GIVEN] the sample file with 1 line
        TempBlobOEM.CreateOutStream(OutStream);
        LibraryERM.CreateGLAccount(GLAccount);
        LibraryDimension.GetGlobalDimCodeValue(1, DimValue[1]);
        LibraryDimension.GetGlobalDimCodeValue(2, DimValue[2]);
        PostingDate := DMY2Date(20, 1, 2017);
        // [GIVEN] The line contains dimension codes: 'A' and 'B'
        WriteLine(OutStream, GLAccount."No." + '; 0;' + DimValue[1].Code + ';' + DimValue[2].Code + ';00000000;00000000;00000000;00000000;00000000;        ;;20012017;   ;20012017;0000000000;0000000000;0000000001');
        ConvertOEMToANSI(TempBlobOEM, TempBlobANSI);
        // [WHEN] run ImportPayrollDataToGL
        CreateGenJnlLineTemplateWithFilter(GenJnlLineTemplate);
        ImportPayrollTransaction.ImportPayrollDataToGL(GenJnlLineTemplate, '', TempBlobANSI, copystr(DataExchNameTok, 1, 20));

        // [THEN] 3 journal lines are created
        LineNo := GenJnlLineTemplate."Line No.";
        DocNo := GenJnlLineTemplate."Document No.";
        CreateTempGenJnlLine(TempExpdGenJnlLine, GenJnlLineTemplate, LineNo * 1, DocNo, GLAccount."No.", PostingDate, GLAccount.Name, 0, 0.01, '', '');
        AssertDataInTable(TempExpdGenJnlLine, GenJnlLineTemplate, '');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure PayrollTransImportFormatIsOnPageGLSetup()
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        DataExchDef: Record "Data Exch. Def";
        GeneralLedgerSetupPage: TestPage "General Ledger Setup";
    begin
        // [SCENARIO] 'HULDT-LILLEVIK' data exchange definition is created on open of G/L Setup page and can be set as "Payroll Trans. Import Format"
        // [GIVEN] 'HULDT-LILLEVIK' data exchnage definition does not exist 
        Initialize();
        // [GIVEN] "Payroll Trans. Import Format" is <blank> in GLSetup table
        GeneralLedgerSetup.Get();
        GeneralLedgerSetup."Payroll Trans. Import Format" := '';
        GeneralLedgerSetup.Modify();

        // [WHEN] Open "General Ledger Setup" page under Suite application area
        GeneralLedgerSetupPage.OpenEdit();

        // [THEN] 'HULDT-LILLEVIK' data exchange definition is created, where "Type" is 'Payroll Import', "File Type" is 'Variable Text'
        DataExchDef.get(DataExchNameTok);
        DataExchDef.TestField(Type, DataExchDef.Type::"Payroll Import");
        DataExchDef.TestField("File Type", DataExchDef."File Type"::"Variable Text");
        DataExchDef.TestField("File Encoding", DataExchDef."File Encoding"::WINDOWS);
        DataExchDef.TestField("Column Separator", DataExchDef."Column Separator"::Semicolon);
        DataExchDef.TestField("Reading/Writing XMLport", XMLPort::"Data Exch. Import - CSV");
        DataExchDef.TestField("Ext. Data Handling Codeunit", Codeunit::"Read Data Exch. from File");

        // [THEN] "Payroll Trans. Import Format" is <blank>, visible and editable on the page.
        Assert.IsTrue(GeneralLedgerSetupPage."Payroll Trans. Import Format".Visible(), '"Import Dimension Codes".Visible');
        Assert.IsTrue(GeneralLedgerSetupPage."Payroll Trans. Import Format".Editable(), '"Import Dimension Codes".Editable');
        GeneralLedgerSetupPage."Payroll Trans. Import Format".AssertEquals('');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure ImportDimCodesIsOnPageGLSetup()
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        GeneralLedgerSetupPage: TestPage "General Ledger Setup";
    begin
        // [SCENARIO] "Import Dimension Codes" checkbox is editable on "General Ledger Setup" page.
        // [GIVEN] "Import Dimension Codes" is 'No' in GLSetup table
        Initialize();

        // [GIVEN] Open "General Ledger Setup" page under Suite application area
        GeneralLedgerSetupPage.OpenEdit();
        // [GIVEN] "Import Dimension Codes" is 'No', visible and editable on the page.
        Assert.IsTrue(GeneralLedgerSetupPage."Import Dimension Codes".Visible(), '"Import Dimension Codes".Visible');
        Assert.IsTrue(GeneralLedgerSetupPage."Import Dimension Codes".Editable(), '"Import Dimension Codes".Editable');
        GeneralLedgerSetupPage."Import Dimension Codes".AssertEquals(Format(false));

        // [WHEN] Set "Import Dimension Codes" to 'Yes'
        GeneralLedgerSetupPage."Import Dimension Codes".SetValue(Format(true));
        GeneralLedgerSetupPage.Close();

        // [THEN] "Import Dimension Codes" is 'Yes' in GLSetup table
        GeneralLedgerSetup.Get();
        GeneralLedgerSetup.testfield("Import Dimension Codes");
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure IgnoreZeroOnlyValuesIsOnPageGLSetup()
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        GeneralLedgerSetupPage: TestPage "General Ledger Setup";
    begin
        // [SCENARIO 341476] "Ignore Zeros-Only Values" checkbox is editable on "General Ledger Setup" page.

        // [GIVEN] "Ignore Zeros-Only Values" is 'No' in GLSetup table
        Initialize();

        // [GIVEN] Open "General Ledger Setup" page under Suite application area
        GeneralLedgerSetupPage.OpenEdit();
        // [GIVEN] "Ignore Zeros-Only Values" is 'No', visible and editable on the page.
        Assert.IsTrue(GeneralLedgerSetupPage."Ignore Zeros-Only Values".Visible(), '"Ignore Zeros-Only Values".Visible');
        Assert.IsTrue(GeneralLedgerSetupPage."Ignore Zeros-Only Values".Editable(), '"Ignore Zeros-Only Values".Editable');
        GeneralLedgerSetupPage."Ignore Zeros-Only Values".AssertEquals(Format(false));

        // [WHEN] Set "Ignore Zeros-Only Values" to 'Yes'
        GeneralLedgerSetupPage."Ignore Zeros-Only Values".SetValue(Format(true));
        GeneralLedgerSetupPage.Close();

        // [THEN] "Ignore Zeros-Only Values" is 'Yes' in GLSetup table
        GeneralLedgerSetup.Get();
        GeneralLedgerSetup.TestField("Ignore Zeros-Only Values");
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure ImportPassesWhenIgnoreZerosOnlyValuesEnabled();
    var
        GenJnlLineTemplate: Record "Gen. Journal Line";
        TempExpdGenJnlLine: Record "Gen. Journal Line" temporary;
        GLAccount: Record "G/L Account";
        ImportPayrollTransaction: Codeunit "Import Payroll Transaction";
        TempBlobOEM: Codeunit "Temp Blob";
        TempBlobANSI: Codeunit "Temp Blob";
        GeneralLedgerSetupPage: Testpage "General Ledger Setup";
        OutStream: OutStream;
        LineNo: Integer;
        DocNo: Code[20];
        PostingDate: date;
        Amount: Decimal;
    begin
        // [FEATURE] [Dimension]
        // [SCENARIO 341476] An import process not fails when zero values exists for dimensions and "Ignore Zeros-Only Values" enabled in General Ledger Setup

        Initialize();
        // [GIVEN] "Ignore Zeros-Only Values" is "Yes" in General Ledger Setup
        GeneralLedgerSetupPage.OpenView();
        GeneralLedgerSetupPage."Payroll Trans. Import Format".SetValue(DataExchNameTok);
        GeneralLedgerSetupPage."Import Dimension Codes".SetValue(Format(true));
        GeneralLedgerSetupPage."Ignore Zeros-Only Values".SetValue(Format(true));
        GeneralLedgerSetupPage.Close();

        // [GIVEN] A sample file with 1 line and 00000000 value for dimension
        TempBlobOEM.CREATEOUTSTREAM(OutStream);
        LibraryERM.CreateGLAccount(GLAccount);
        PostingDate := DMY2Date(20, 1, 2017);
        Amount := 585.70;
        WriteLine(OutStream, GLAccount."No." + '; 0;;00000000;00000000;00000000;00000000;00000000;00000000;        ;;20012017;   ;20012017;0000000000;0000000000;-000058570');
        ConvertOEMToANSI(TempBlobOEM, TempBlobANSI);
        // [WHEN] Run ImportPayrollDataToGL
        CreateGenJnlLineTemplateWithFilter(GenJnlLineTemplate);
        ImportPayrollTransaction.ImportPayrollDataToGL(GenJnlLineTemplate, '', TempBlobANSI, copystr(DataExchNameTok, 1, 20));

        // [THEN] 3 journal lines are created
        LineNo := GenJnlLineTemplate."Line No.";
        DocNo := GenJnlLineTemplate."Document No.";
        CreateTempGenJnlLine(TempExpdGenJnlLine, GenJnlLineTemplate, LineNo * 1, DocNo, GLAccount."No.", PostingDate, GLAccount.Name, 0, -Amount, '', '');

        AssertDataInTable(TempExpdGenJnlLine, GenJnlLineTemplate, '');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure ImportFailsWhenIgnoreZerosOnlyValuesDisabled();
    var
        GenJnlLineTemplate: Record "Gen. Journal Line";
        GLAccount: Record "G/L Account";
        ImportPayrollTransaction: Codeunit "Import Payroll Transaction";
        TempBlobOEM: Codeunit "Temp Blob";
        TempBlobANSI: Codeunit "Temp Blob";
        GeneralLedgerSetupPage: Testpage "General Ledger Setup";
        OutStream: OutStream;
        ZeroValue: Text;
    begin
        // [FEATURE] [Dimension]
        // [SCENARIO 341476] An import process fails when zero values exists for dimensions and "Ignore Zeros-Only Values" disabled in General Ledger Setup

        Initialize();
        // [GIVEN] "Ignore Zeros-Only Values" is "No" in General Ledger Setup
        GeneralLedgerSetupPage.OpenView();
        GeneralLedgerSetupPage."Payroll Trans. Import Format".SetValue(DataExchNameTok);
        GeneralLedgerSetupPage."Import Dimension Codes".SetValue(Format(true));
        GeneralLedgerSetupPage."Ignore Zeros-Only Values".SetValue(Format(false));
        GeneralLedgerSetupPage.Close();

        // [GIVEN] A sample file with 1 line and 00000000 value for dimension
        TempBlobOEM.CREATEOUTSTREAM(OutStream);
        LibraryERM.CreateGLAccount(GLAccount);
        ZeroValue := '00000000';
        WriteLine(OutStream, GLAccount."No." + '; 0;;' + ZeroValue + ';00000000;00000000;00000000;00000000;00000000;        ;;20012017;   ;20012017;0000000000;0000000000;-000058570');
        ConvertOEMToANSI(TempBlobOEM, TempBlobANSI);
        // [WHEN] Run ImportPayrollDataToGL
        CreateGenJnlLineTemplateWithFilter(GenJnlLineTemplate);
        asserterror ImportPayrollTransaction.ImportPayrollDataToGL(GenJnlLineTemplate, '', TempBlobANSI, copystr(DataExchNameTok, 1, 20));

        // [THEN] Import fails on error "The project code field contains a value (00000000) that does not exist in table Dimension Value."
        Assert.ExpectedError(StrSubstNo(DimCodeDoesNotExistErr, ZeroValue));
    end;

    local procedure Initialize()
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        TransformationRule: Record "Transformation Rule";
        DataExchDef: Record "Data Exch. Def";
    begin
        LibraryVariableStorage.Clear();

        GeneralLedgerSetup.Get();
        GeneralLedgerSetup."Payroll Trans. Import Format" := '';
        GeneralLedgerSetup."Import Dimension Codes" := false;
        GeneralLedgerSetup."Ignore Zeros-Only Values" := false;
        GeneralLedgerSetup.Modify();

        TransformationRule.SetFilter(Code, '%1|%2|%3', AmountInCentsTok, EvaluateTextToIntegerTok, BlankDimCodeTok);
        TransformationRule.DeleteAll(true);

        DataExchDef.SetRange(Code, DataExchNameTok);
        DataExchDef.DeleteAll(true);

        if IsInitialized then
            exit;

        LibraryApplicationArea.EnableFoundationSetup();
        IsInitialized := true;
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

    local procedure CreateTempGenJnlLine(var TempGenJnlLine: Record "Gen. Journal Line" temporary; GenJnlLineTemplate: Record "Gen. Journal Line"; LineNo: Integer; DocumentNo: Code[20]; AccountNo: Code[20]; PostingDate: Date; Description: Text[100]; Quantity: Decimal; Amount: Decimal; DimCode1: code[20]; DimCode2: code[20]);
    BEGIN
        TempGenJnlLine.COPY(GenJnlLineTemplate);
        TempGenJnlLine.VALIDATE("Line No.", LineNo);
        TempGenJnlLine.VALIDATE("Document No.", DocumentNo);
        TempGenJnlLine.VALIDATE("Account No.", AccountNo);
        TempGenJnlLine.VALIDATE("Posting Date", PostingDate);
        TempGenJnlLine.VALIDATE(Description, Description);
        TempGenJnlLine.VALIDATE(Quantity, Quantity);
        TempGenJnlLine.VALIDATE(Amount, Amount);
        TempGenJnlLine.VALIDATE("Shortcut Dimension 1 Code", DimCode1);
        TempGenJnlLine.VALIDATE("Shortcut Dimension 2 Code", DimCode2);
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
}

