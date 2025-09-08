// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Test.Bank.StatementImport;

using Microsoft.Bank.BankAccount;
using Microsoft.Bank.Setup;
using Microsoft.Bank.StatementImport;
using System.IO;
using System.TestLibraries.Utilities;
using System.Utilities;

codeunit 148130 "Bank Stmt File Wizard Tests"
{
    Subtype = Test;
    TestType = IntegrationTest;
    TestPermissions = Disabled;
    EventSubscriberInstance = Manual;

    trigger OnRun()
    begin
        // [FEATURE] [Bank Statement File Wizard] [UI]
    end;

    var
        LibraryUtility: Codeunit "Library - Utility";
        LibraryERM: Codeunit "Library - ERM";
        LibraryRandom: Codeunit "Library - Random";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        TempBlobGlobal: Codeunit "Temp Blob";
        Assert: Codeunit Assert;
        ColumnSeparator: Option " ",Comma,Semicolon;
        DecimalSeparator: Option " ","Dot","Comma";
        DateHeaderTxt: Label 'Date';
        DescriptionHeaderTxt: Label 'Description';
        AmountHeaderTxt: Label 'Amount';

    [Test]
    procedure WizardAllStepsCsvSeparatorSemicolonAndDecimalSeparatorComma()
    var
        BankAccount: Record "Bank Account";
        DataExchDef: Record "Data Exch. Def";
        DataExchLineDef: Record "Data Exch. Line Def";
        DataExchColumnDef: Record "Data Exch. Column Def";
        BankExportImportSetup: Record "Bank Export/Import Setup";
        BankStmtFileWizardTests: Codeunit "Bank Stmt File Wizard Tests";
        TempBlob: Codeunit "Temp Blob";
        BankStatementFileWizard: TestPage "Bank Statement File Wizard";
        DataExchDefinitionType: Enum "Data Exchange Definition Type";
        FileName: Code[20];
        CsvFileName: Text;
    begin
        // [SCENARIO 397260] Load CSV file with semicolon csv separator and comma decimal separator to Bank Statement File Wizard. Run wizard through all steps.

        // [GIVEN] Bank Account "BA".
        LibraryERM.CreateBankAccount(BankAccount);

        // [GIVEN] Text in CSV format with one header line and multiple data lines. Format is Date;Description;Amount. CSV separator is semicolon.
        // [GIVEN] Date has format dd.MM.yyyy, like 27.08.2021.
        // [GIVEN] Amount has decimal separator comma.
        WriteCsvTextWithSemicolonSeparatorToBlob(TempBlob);
        FileName := LibraryUtility.GenerateGUID();
        CsvFileName := GenerateCsvFileName(FileName);
        BankStmtFileWizardTests.CopyBlobToGlobalBlob(TempBlob);
        BankStmtFileWizardTests.EnqueueFileName(CsvFileName);

        // [GIVEN] Bank Statement File Wizard opened on step Upload bank statement file.
        BankStatementFileWizard.OpenEdit();
        BankStatementFileWizard.ActionNext.Invoke();

        // [WHEN] Emulate loading CSV file with name "FN01.csv" and with content from CSV text to wizard, press Next.
        BindSubscription(BankStmtFileWizardTests);
        BankStatementFileWizard.UploadFile.Drilldown();
        BankStatementFileWizard.ActionNext.Invoke();

        // [THEN] Step "Specify number of header lines" is opened. Header Lines to Skip = 1.
        Assert.AreEqual(1, BankStatementFileWizard.HeaderLines.AsInteger(), '');

        // [WHEN] Press Next.
        BankStatementFileWizard.ActionNext.Invoke();

        // [THEN] Step "Specify the column separator and column count" is opened. Column Separator = Semicolon. Column Count = 3.
        Assert.AreEqual(Format(ColumnSeparator::Semicolon), BankStatementFileWizard.ColumnSeparator.Value, '');
        Assert.AreEqual(3, BankStatementFileWizard.ColumnCount.AsInteger(), '');

        // [WHEN] Press Next.
        BankStatementFileWizard.ActionNext.Invoke();

        // [THEN] Step "Review and define the column definitions" is opened. Date Column No. = 1. Amount Column No. = 3. Description Column No. = 2.
        Assert.AreEqual(1, BankStatementFileWizard.TransactionDate.AsInteger(), '');
        Assert.AreEqual(3, BankStatementFileWizard.TransactionAmount.AsInteger(), '');
        Assert.AreEqual(2, BankStatementFileWizard.Description.AsInteger(), '');

        // [WHEN] Press Next.
        BankStatementFileWizard.ActionNext.Invoke();

        // [THEN] Step "Review and define the local formats" is opened. Date Format = dd.MM.yyyy. Decimal Separator = Comma.
        Assert.AreEqual('dd.MM.yyyy', BankStatementFileWizard.DateFormat.Value, '');
        Assert.AreEqual(Format(DecimalSeparator::Comma), BankStatementFileWizard.DecimalSeperator.Value, '');

        // [WHEN] Press Next, then Next.
        BankStatementFileWizard.ActionNext.Invoke();
        BankStatementFileWizard.ActionNext.Invoke();

        // [THEN] Step "You are all set" is opened. Format Code is "FN01".
        Assert.AreEqual(FileName, BankStatementFileWizard.DataExchangeCode.Value, '');

        // [WHEN] Set Bank Account = "BA", press Finish.
        BankStatementFileWizard.SelectBankAccount.SetValue(BankAccount."No.");
        BankStatementFileWizard.ActionFinish.Invoke();

        // [THEN] Data Exchange Definition with Code "FN01" is created. File Type is "Fixed Text", Type is "Bank Statement Import", Header Lines = 1.
        // [THEN] Data Exchange Line Definition with Code "FN01" is created. Line Type is "Detail", Column Count = 3.
        // [THEN] Three Data Exchange Column Definitions for Date, Description, Amount columns are created.
        VerifyDataExchDef(FileName, DataExchDef."File Type"::"Fixed Text", DataExchDefinitionType::"Bank Statement Import", 1);
        VerifyDataExchLineDef(FileName, FileName, DataExchLineDef."Line Type"::Detail, 3);
        VerifyDataExchColumnDef(FileName, FileName, 1, DateHeaderTxt, DataExchColumnDef."Data Type"::Date, 'dd.MM.yyyy', 'es-ES');
        VerifyDataExchColumnDef(FileName, FileName, 2, DescriptionHeaderTxt, DataExchColumnDef."Data Type"::Text, '', '');
        VerifyDataExchColumnDef(FileName, FileName, 3, AmountHeaderTxt, DataExchColumnDef."Data Type"::Decimal, '', 'es-ES');

        // [THEN] Bank Export/Import Setup with Code "FN01" and Data Exch. Def. Code "FN01" is created.
        BankExportImportSetup.Get(FileName);
        Assert.RecordIsNotEmpty(BankExportImportSetup);
        BankExportImportSetup.TestField("Data Exch. Def. Code", FileName);

        // [THEN] Bank Statement Import Format for Bank Account "BA" is set to "FN01".
        BankAccount.Get(BankAccount."No.");
        BankAccount.TestField("Bank Statement Import Format", FileName);

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]

    procedure LoadCsvWithCsvSeparatorCommaAndDecimalSeparatorDot()
    var
        BankStmtFileWizardTests: Codeunit "Bank Stmt File Wizard Tests";
        TempBlob: Codeunit "Temp Blob";
        BankStatementFileWizard: TestPage "Bank Statement File Wizard";
        CsvFileName: Text;
    begin
        // [SCENARIO 397260] Load CSV file with comma csv separator and dot decimal separator to Bank Statement File Wizard.

        // [GIVEN] Text in CSV format with one header line and multiple data lines. Format is Date,Description,Amount. CSV separator is comma.
        // [GIVEN] Date has format MM/dd/yyyy, like 08/27/2021.
        // [GIVEN] Amount has decimal separator dot.
        WriteCsvTextWithCommaSeparatorToBlob(TempBlob);
        CsvFileName := GenerateCsvFileName(LibraryUtility.GenerateGUID());
        BankStmtFileWizardTests.CopyBlobToGlobalBlob(TempBlob);
        BankStmtFileWizardTests.EnqueueFileName(CsvFileName);

        // [WHEN] Open Bank Statement File Wizard and emulate loading CSV file with name "FN01" and with content from CSV text to wizard, press Next, Next.
        BankStatementFileWizard.OpenEdit();
        BankStatementFileWizard.ActionNext.Invoke();
        BindSubscription(BankStmtFileWizardTests);
        BankStatementFileWizard.UploadFile.Drilldown();
        BankStatementFileWizard.ActionNext.Invoke();
        BankStatementFileWizard.ActionNext.Invoke();

        // [THEN] Step "Specify the column separator and column count" is opened. Column Separator = Comma. Column Count = 3.
        Assert.AreEqual(Format(ColumnSeparator::Comma), BankStatementFileWizard.ColumnSeparator.Value, '');
        Assert.AreEqual(3, BankStatementFileWizard.ColumnCount.AsInteger(), '');

        // [WHEN] Press Next, Next
        BankStatementFileWizard.ActionNext.Invoke();
        BankStatementFileWizard.ActionNext.Invoke();

        // [THEN] Step "Review and define the local formats" is opened. Date Format = MM/dd/yyyy. Decimal Separator = Dot.
        Assert.AreEqual('MM/dd/yyyy', BankStatementFileWizard.DateFormat.Value, '');
        Assert.AreEqual(Format(DecimalSeparator::Dot), BankStatementFileWizard.DecimalSeperator.Value, '');

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    procedure LoadCsvWithAmountWithSingleQuoteThousandsSeparator()
    var
        BankStmtFileWizardTests: Codeunit "Bank Stmt File Wizard Tests";
        TempBlob: Codeunit "Temp Blob";
        BankStatementFileWizard: TestPage "Bank Statement File Wizard";
        CsvFileName: Text;
    begin
        // [SCENARIO 397260] Load CSV file with Amounts that have dot decimal separator and single quote thousands separator to Bank Statement File Wizard.

        // [GIVEN] Text in CSV format with one header line and multiple data lines. Format is Date,Description,Amount. CSV separator is semicolon.
        // [GIVEN] Amount has decimal separator dot and thousands separator single quote, like 1'234'567.89.
        WriteCsvTextWithSingleQuoteThousandsSeparatorToBlob(TempBlob);
        CsvFileName := GenerateCsvFileName(LibraryUtility.GenerateGUID());
        BankStmtFileWizardTests.CopyBlobToGlobalBlob(TempBlob);
        BankStmtFileWizardTests.EnqueueFileName(CsvFileName);

        // [WHEN] Open Bank Statement File Wizard and emulate loading CSV file with name "FN01" and with content from CSV text to wizard, press Next, Next.
        BankStatementFileWizard.OpenEdit();
        BankStatementFileWizard.ActionNext.Invoke();
        BindSubscription(BankStmtFileWizardTests);
        BankStatementFileWizard.UploadFile.Drilldown();
        BankStatementFileWizard.ActionNext.Invoke();
        BankStatementFileWizard.ActionNext.Invoke();

        // [THEN] Step "Specify the column separator and column count" is opened. Column Separator = Semicolon. Column Count = 3.
        Assert.AreEqual(Format(ColumnSeparator::Semicolon), BankStatementFileWizard.ColumnSeparator.Value, '');
        Assert.AreEqual(3, BankStatementFileWizard.ColumnCount.AsInteger(), '');

        // [WHEN] Press Next, Next
        BankStatementFileWizard.ActionNext.Invoke();
        BankStatementFileWizard.ActionNext.Invoke();

        // [THEN] Step "Review and define the local formats" is opened. Decimal Separator = Dot.
        Assert.AreEqual(Format(DecimalSeparator::Dot), BankStatementFileWizard.DecimalSeperator.Value, '');

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    procedure LoadCsvWithAmountWithCommaThousandsSeparator()
    var
        BankStmtFileWizardTests: Codeunit "Bank Stmt File Wizard Tests";
        TempBlob: Codeunit "Temp Blob";
        BankStatementFileWizard: TestPage "Bank Statement File Wizard";
        CsvFileName: Text;
    begin
        // [SCENARIO 397260] Load CSV file with Amounts that have dot decimal separator and comma thousands separator to Bank Statement File Wizard.

        // [GIVEN] Text in CSV format with one header line and multiple data lines. Format is Date,Description,Amount. CSV separator is semicolon.
        // [GIVEN] Amount has decimal separator dot and thousands separator comma, like 1,234,567.89.
        WriteCsvTextWithCommaThousandsSeparatorToBlob(TempBlob);
        CsvFileName := GenerateCsvFileName(LibraryUtility.GenerateGUID());
        BankStmtFileWizardTests.CopyBlobToGlobalBlob(TempBlob);
        BankStmtFileWizardTests.EnqueueFileName(CsvFileName);

        // [WHEN] Open Bank Statement File Wizard and emulate loading CSV file with name "FN01" and with content from CSV text to wizard, press Next, Next.
        BankStatementFileWizard.OpenEdit();
        BankStatementFileWizard.ActionNext.Invoke();
        BindSubscription(BankStmtFileWizardTests);
        BankStatementFileWizard.UploadFile.Drilldown();
        BankStatementFileWizard.ActionNext.Invoke();
        BankStatementFileWizard.ActionNext.Invoke();

        // [THEN] Step "Specify the column separator and column count" is opened. Column Separator = Semicolon. Column Count = 3.
        Assert.AreEqual(Format(ColumnSeparator::Semicolon), BankStatementFileWizard.ColumnSeparator.Value, '');
        Assert.AreEqual(3, BankStatementFileWizard.ColumnCount.AsInteger(), '');

        // [WHEN] Press Next, Next
        BankStatementFileWizard.ActionNext.Invoke();
        BankStatementFileWizard.ActionNext.Invoke();

        // [THEN] Step "Review and define the local formats" is opened. Decimal Separator = Dot.
        Assert.AreEqual(Format(DecimalSeparator::Dot), BankStatementFileWizard.DecimalSeperator.Value, '');

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    procedure LoadCsvWithLongFileName()
    var
        BankAccount: Record "Bank Account";
        DataExchDef: Record "Data Exch. Def";
        DataExchLineDef: Record "Data Exch. Line Def";
        BankExportImportSetup: Record "Bank Export/Import Setup";
        BankStmtFileWizardTests: Codeunit "Bank Stmt File Wizard Tests";
        TempBlob: Codeunit "Temp Blob";
        BankStatementFileWizard: TestPage "Bank Statement File Wizard";
        FileName: Text;
        CsvFileName: Text;
        ShortFileName: Text;
    begin
        // [SCENARIO 397260] Load CSV file with name length more than 20 chars to Bank Statement File Wizard.

        // [GIVEN] Bank Account "BA".
        LibraryERM.CreateBankAccount(BankAccount);

        // [GIVEN] Text in CSV format with one header line and multiple data lines.
        // [GIVEN] Generate file name "FN00001.csv" with length more than 20 chars; first 20 chars are "FN00".
        WriteCsvTextWithCommaThousandsSeparatorToBlob(TempBlob);
        FileName := LibraryUtility.GenerateRandomXMLText(100);
        CsvFileName := GenerateCsvFileName(FileName);
        BankStmtFileWizardTests.CopyBlobToGlobalBlob(TempBlob);
        BankStmtFileWizardTests.EnqueueFileName(CsvFileName);

        // [WHEN] Open Bank Statement File Wizard and emulate loading CSV file with long name "FN00001.csv" and with content from CSV text to wizard, press Next until the last step.
        BankStatementFileWizard.OpenEdit();
        BankStatementFileWizard.ActionNext.Invoke();
        BindSubscription(BankStmtFileWizardTests);
        BankStatementFileWizard.UploadFile.Drilldown();
        BankStatementFileWizard.ActionNext.Invoke();
        BankStatementFileWizard.ActionNext.Invoke();
        BankStatementFileWizard.ActionNext.Invoke();
        BankStatementFileWizard.ActionNext.Invoke();
        BankStatementFileWizard.ActionNext.Invoke();
        BankStatementFileWizard.ActionNext.Invoke();

        // [THEN] Step "You are all set" is opened. Format Code is equal to "FN00", i.e. to the first 20 chars of "FN00001".
        ShortFileName := CopyStr(FileName, 1, MaxStrLen(DataExchDef.Code));
        Assert.AreEqual(ShortFileName.ToUpper(), BankStatementFileWizard.DataExchangeCode.Value, '');

        // [WHEN] Set Bank Account = "BA", press Finish.
        BankStatementFileWizard.SelectBankAccount.SetValue(BankAccount."No.");
        BankStatementFileWizard.ActionFinish.Invoke();

        // [THEN] Data Exchange Definition with Code "FN00" is created.
        // [THEN] Data Exchange Line Definition with Code "FN00" is created.
        DataExchDef.Get(ShortFileName);
        Assert.RecordIsNotEmpty(DataExchDef);
        DataExchLineDef.Get(ShortFileName, ShortFileName);
        Assert.RecordIsNotEmpty(DataExchLineDef);

        // [THEN] Bank Export/Import Setup with Code "FN00" and Data Exch. Def. Code "FN00" is created.
        BankExportImportSetup.Get(ShortFileName);
        Assert.RecordIsNotEmpty(BankExportImportSetup);
        BankExportImportSetup.TestField("Data Exch. Def. Code", ShortFileName);

        // [THEN] Bank Statement Import Format for Bank Account "BA" is set to "FN00".
        BankAccount.Get(BankAccount."No.");
        BankAccount.TestField("Bank Statement Import Format", ShortFileName);

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('BankStatementImportPreviewEnqueueAmountsModalPageHandler,ConfirmHandler')]

    procedure BankStatementImportPreviewWhenAmountWithSingleQuoteThousandsSeparator()
    var
        BankStmtFileWizardTests: Codeunit "Bank Stmt File Wizard Tests";
        TempBlob: Codeunit "Temp Blob";
        BankStatementFileWizard: TestPage "Bank Statement File Wizard";
        AmountsText: List of [Text];
        CsvFileName: Text;
        ExpectedAmount: Decimal;
        i: Integer;
    begin
        // [SCENARIO 397260] Open Bank Statement Import Preview page when CSV file with Amounts with dot decimal separator and single quote thousands separator loaded to Bank Statement File Wizard.

        // [GIVEN] Text in CSV format with one header line and three data lines. Format is Date,Description,Amount. CSV separator is semicolon.
        // [GIVEN] Amount has decimal separator dot and thousands separator single quote, like 1'234'567.89.
        WriteCsvTextWithSingleQuoteThousandsSeparatorToBlob(TempBlob, AmountsText);
        CsvFileName := GenerateCsvFileName(LibraryUtility.GenerateGUID());
        BankStmtFileWizardTests.CopyBlobToGlobalBlob(TempBlob);
        BankStmtFileWizardTests.EnqueueFileName(CsvFileName);

        // [GIVEN] Opened Bank Statement File Wizard. CSV file with name "FN01" and with content from CSV text is loaded to wizard. Step "Try it out" is opened.
        BankStatementFileWizard.OpenEdit();
        BankStatementFileWizard.ActionNext.Invoke();
        BindSubscription(BankStmtFileWizardTests);
        BankStatementFileWizard.UploadFile.Drilldown();
        BankStatementFileWizard.ActionNext.Invoke();
        BankStatementFileWizard.ActionNext.Invoke();
        BankStatementFileWizard.ActionNext.Invoke();
        BankStatementFileWizard.ActionNext.Invoke();
        BankStatementFileWizard.ActionNext.Invoke();

        // [WHEN] Drill down for "Test the bank statement file format" field.
        BankStatementFileWizard.TestFormat.Drilldown();

        // [THEN] Bank Statement Import Preview modal page with three lines is opened. Amount for each line is a valid decimal and has format "123,456.78".
        for i := 1 to 3 do begin
            Evaluate(ExpectedAmount, DelChr(AmountsText.Get(i), '=', ''''));
            Assert.AreEqual(ExpectedAmount, LibraryVariableStorage.DequeueDecimal(), '');
        end;

        LibraryVariableStorage.AssertEmpty();
    end;

    procedure CopyBlobToGlobalBlob(TempBlob: Codeunit "Temp Blob")
    begin
        TempBlobGlobal := TempBlob;
    end;

    procedure EnqueueFileName(FileName: Text)
    begin
        LibraryVariableStorage.Enqueue(FileName);
    end;

    local procedure GenerateCsvFileName(FileName: Text): Text
    var
        CsvFileNamePatternLbl: Label '%1.csv', Locked = true;
    begin
        exit(StrSubstNo(CsvFileNamePatternLbl, FileName));
    end;

    local procedure VerifyDataExchDef(DataExchDefCode: Code[20]; FileType: Option; DataExchDefinitionType: Enum "Data Exchange Definition Type"; HeaderLines: Integer)
    var
        DataExchDef: Record "Data Exch. Def";
    begin
        DataExchDef.Get(DataExchDefCode);
        Assert.RecordIsNotEmpty(DataExchDef);
        DataExchDef.TestField("File Type", FileType);
        DataExchDef.TestField(Type, DataExchDefinitionType);
        DataExchDef.TestField("Header Lines", HeaderLines);
    end;

    local procedure VerifyDataExchLineDef(DataExchDefCode: Code[20]; CodeValue: Code[20]; LineType: Option; ColumnCount: Integer)
    var
        DataExchLineDef: Record "Data Exch. Line Def";
    begin
        DataExchLineDef.Get(DataExchDefCode, CodeValue);
        Assert.RecordIsNotEmpty(DataExchLineDef);
        DataExchLineDef.TestField("Line Type", LineType);
        DataExchLineDef.TestField("Column Count", ColumnCount);
    end;

    local procedure VerifyDataExchColumnDef(DataExchDefCode: Code[20]; DataExchLineDefCode: Code[20]; ColumnNo: Integer; NameValue: Text[250]; DataType: Option; DataFormat: Text[100]; DataFormatingCulture: Text[10])
    var
        DataExchColumnDef: Record "Data Exch. Column Def";
    begin
        DataExchColumnDef.Get(DataExchDefCode, DataExchLineDefCode, ColumnNo);
        Assert.RecordIsNotEmpty(DataExchColumnDef);
        DataExchColumnDef.TestField(Name, NameValue);
        DataExchColumnDef.TestField("Data Type", DataType);
        DataExchColumnDef.TestField("Data Format", DataFormat);
        DataExchColumnDef.TestField("Data Formatting Culture", DataFormatingCulture);
    end;

    local procedure WriteCsvTextWithSemicolonSeparatorToBlob(var TempBlob: Codeunit "Temp Blob")
    begin
        WriteCsvTextToBlob(TempBlob, ';', '<Sign><Integer><Decimals><Comma,,>', '<Day,2>.<Month,2>.<Year4>');
    end;

    local procedure WriteCsvTextWithCommaSeparatorToBlob(var TempBlob: Codeunit "Temp Blob")
    begin
        WriteCsvTextToBlob(TempBlob, ',', '<Sign><Integer><Decimals><Comma,.>', '<Month,2>/<Day,2>/<Year4>');
    end;

    local procedure WriteCsvTextWithSingleQuoteThousandsSeparatorToBlob(var TempBlob: Codeunit "Temp Blob")
    var
        OutStream: OutStream;
        DateText: Text;
    begin
        Clear(TempBlob);
        TempBlob.CreateOutStream(OutStream);
        WriteLine(OutStream, StrSubstNo('%1;%2;%3', DateHeaderTxt, DescriptionHeaderTxt, AmountHeaderTxt));
        DateText := Format(GetDate(), 0, '<Day,2>.<Month,2>.<Year4>');
        WriteLine(OutStream, StrSubstNo('%1;%2;%3', DateText, LibraryUtility.GenerateGUID(), '123''456.78'));
        WriteLine(OutStream, StrSubstNo('%1;%2;%3', DateText, LibraryUtility.GenerateGUID(), '23''456'));
        WriteLine(OutStream, StrSubstNo('%1;%2;%3', DateText, LibraryUtility.GenerateGUID(), '3''456''789.10'));
    end;

    local procedure WriteCsvTextWithSingleQuoteThousandsSeparatorToBlob(var TempBlob: Codeunit "Temp Blob"; var AmountsText: List of [Text])
    var
        OutStream: OutStream;
        DateText: Text;
    begin
        Clear(TempBlob);
        TempBlob.CreateOutStream(OutStream);
        WriteLine(OutStream, StrSubstNo('%1;%2;%3', DateHeaderTxt, DescriptionHeaderTxt, AmountHeaderTxt));
        DateText := Format(GetDate(), 0, '<Day,2>.<Month,2>.<Year4>');
        AmountsText.AddRange('123''456.78', '23''456', '3''456''789.10');
        WriteLine(OutStream, StrSubstNo('%1;%2;%3', DateText, LibraryUtility.GenerateGUID(), AmountsText.Get(1)));
        WriteLine(OutStream, StrSubstNo('%1;%2;%3', DateText, LibraryUtility.GenerateGUID(), AmountsText.Get(2)));
        WriteLine(OutStream, StrSubstNo('%1;%2;%3', DateText, LibraryUtility.GenerateGUID(), AmountsText.Get(3)));
    end;

    local procedure WriteCsvTextWithCommaThousandsSeparatorToBlob(var TempBlob: Codeunit "Temp Blob")
    var
        OutStream: OutStream;
        DateText: Text;
    begin
        Clear(TempBlob);
        TempBlob.CreateOutStream(OutStream);
        WriteLine(OutStream, StrSubstNo('%1;%2;%3', DateHeaderTxt, DescriptionHeaderTxt, AmountHeaderTxt));
        DateText := Format(GetDate(), 0, '<Day,2>.<Month,2>.<Year4>');
        WriteLine(OutStream, StrSubstNo('%1;%2;%3', DateText, LibraryUtility.GenerateGUID(), '123,456.78'));
        WriteLine(OutStream, StrSubstNo('%1;%2;%3', DateText, LibraryUtility.GenerateGUID(), '23,456'));
        WriteLine(OutStream, StrSubstNo('%1;%2;%3', DateText, LibraryUtility.GenerateGUID(), '3,456,789.10'));
    end;

    local procedure WriteCsvTextToBlob(var TempBlob: Codeunit "Temp Blob"; CsvSeparator: Char; AmountFormat: Text; DateFormat: Text)
    var
        OutStream: OutStream;
        DateText: Text;
        AmountText: Text;
        i: Integer;
    begin
        Clear(TempBlob);
        TempBlob.CreateOutStream(OutStream);
        WriteLine(OutStream, StrSubstNo('%1%4%2%4%3', DateHeaderTxt, DescriptionHeaderTxt, AmountHeaderTxt, CsvSeparator)); // header: Date;Description;Amount
        DateText := Format(GetDate(), 0, DateFormat);
        for i := 1 to 3 do begin
            AmountText := Format(LibraryRandom.RandDecInRange(-999999, 999999, 2), 0, AmountFormat);
            WriteLine(OutStream, StrSubstNo('%1%4%2%4%3', DateText, LibraryUtility.GenerateGUID(), AmountText, CsvSeparator));  // line: 21.12.2021;abcd;123456.78
        end;
    end;

    local procedure WriteLine(OutStream: OutStream; LineText: Text)
    begin
        OutStream.WriteText(LineText);
        OutStream.WriteText();
    end;

    local procedure GetDate(): Date
    var
        Date: Date;
        Day: Integer;
        Month: Integer;
        Year: Integer;
    begin
        Date := WorkDate();
        Day := Date2DMY(Date, 1);
        Month := Date2DMY(Date, 2);
        Year := Date2DMY(Date, 3);
        if Day <= 12 then
            Day += 12;
        exit(DMY2Date(Day, Month, Year));
    end;

    [ModalPageHandler]
    procedure BankStatementImportPreviewEnqueueAmountsModalPageHandler(var BankStatementImportPreview: TestPage "Bank Statement Import Preview")
    begin
        BankStatementImportPreview.First();
        LibraryVariableStorage.Enqueue(BankStatementImportPreview.Amount.AsDecimal());
        BankStatementImportPreview.Next();
        LibraryVariableStorage.Enqueue(BankStatementImportPreview.Amount.AsDecimal());
        BankStatementImportPreview.Next();
        LibraryVariableStorage.Enqueue(BankStatementImportPreview.Amount.AsDecimal());
    end;

    [ConfirmHandler]
    procedure ConfirmHandler(Question: Text[1024]; var Reply: Boolean);
    begin
        Reply := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Bank Statement File Wizard", 'OnBeforeUploadBankFile', '', false, false)]
    local procedure LoadBankFileFromServerFileOnBeforeUploadBankFile(var FileName: Text; var TempBlob: Codeunit "Temp Blob"; var IsHandled: Boolean)
    begin
        FileName := LibraryVariableStorage.DequeueText();
        TempBlob := TempBlobGlobal;
        IsHandled := true;
    end;
}
