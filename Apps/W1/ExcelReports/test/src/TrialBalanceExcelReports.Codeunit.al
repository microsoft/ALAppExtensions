namespace Microsoft.Finance.ExcelReports.Test;

using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Finance.ExcelReports;
using Microsoft.Finance.Dimension;
using Microsoft.Finance.Consolidation;

codeunit 139544 "Trial Balance Excel Reports"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        LibraryERM: Codeunit "Library - ERM";
        LibraryReportDataset: Codeunit "Library - Report Dataset";
        Assert: Codeunit Assert;

    [Test]
    [HandlerFunctions('EXRTrialBalanceExcelHandler')]
    procedure TrialBalanceExportsAsManyItemsAsGLAccounts()
    var
        Variant: Variant;
        RequestPageXml: Text;
    begin
        // [SCENARIO] An empty report should export all GL Accounts regardless
        // [GIVEN] An empty trial balance
        CleanUpTrialBalanceData();
        // [GIVEN] 5 G/L Accounts
        CreateSampleGLAccounts(5);
        Commit();
        // [WHEN] Running the report
        RequestPageXml := Report.RunRequestPage(Report::"EXR Trial Balance Excel", RequestPageXml);
        LibraryReportDataset.RunReportAndLoad(Report::"EXR Trial Balance Excel", Variant, RequestPageXml);
        // [THEN] 5 rows of type GLAccount should be exported
        Assert.AreEqual(5, LibraryReportDataset.RowCount(), 'Only the GLAccounts should be exported');
        LibraryReportDataset.SetXmlNodeList('DataItem[@name="GLAccounts"]');
        Assert.AreEqual(5, LibraryReportDataset.RowCount(), 'The exported items should be GLAccounts');
    end;

    [Test]
    [HandlerFunctions('EXRTrialBalanceBudgetExcelHandler')]
    procedure TrialBalanceBudgetExportsAsManyItemsAsGLAccounts()
    var
        Variant: Variant;
        RequestPageXml: Text;
    begin
        // [SCENARIO] An empty report should export all GL Accounts regardless
        // [GIVEN] An empty trial balance
        CleanUpTrialBalanceData();
        // [GIVEN] 7 G/L Accounts
        CreateSampleGLAccounts(7);
        Commit();
        // [WHEN] Running the report
        RequestPageXml := Report.RunRequestPage(Report::"EXR Trial BalanceBudgetExcel", RequestPageXml);
        LibraryReportDataset.RunReportAndLoad(Report::"EXR Trial BalanceBudgetExcel", Variant, RequestPageXml);
        // [THEN] 7 rows of type GLAccount should be exported
        Assert.AreEqual(7, LibraryReportDataset.RowCount(), 'Only the GLAccounts should be exported');
        LibraryReportDataset.SetXmlNodeList('DataItem[@name="GLAccounts"]');
        Assert.AreEqual(7, LibraryReportDataset.RowCount(), 'The exported items should be GLAccounts');
    end;


    [Test]
    [HandlerFunctions('EXRConsolidatedTrialBalanceHandler')]
    procedure ConsolidatedTrialBalanceExportsAsManyItemsAsGLAccountsAndBusinessUnits()
    var
        Variant: Variant;
        RequestPageXml: Text;
    begin
        // [SCENARIO] An empty Consolidation report should export all GL Accounts regardless and all Business Units
        // [GIVEN] An empty trial balance
        CleanUpTrialBalanceData();
        // [GIVEN] 9 G/L Accounts
        CreateSampleGLAccounts(9);
        // [GIVEN] 3 Business units
        CreateSampleBusinessUnits(3);
        Commit();
        // [WHEN] Running the report
        RequestPageXml := Report.RunRequestPage(Report::"EXR Consolidated Trial Balance", RequestPageXml);
        LibraryReportDataset.RunReportAndLoad(Report::"EXR Consolidated Trial Balance", Variant, RequestPageXml);
        // [THEN] The 9 GLAccount rows and 3 Business Unit rows should be exported
        Assert.AreEqual(9 + 3, LibraryReportDataset.RowCount(), 'Only GL Accounts and Business Units should be exported');
        LibraryReportDataset.SetXmlNodeList('DataItem[@name="GLAccounts"]');
        Assert.AreEqual(9, LibraryReportDataset.RowCount(), 'Created GL Accounts should be exported');
        LibraryReportDataset.SetXmlNodeList('DataItem[@name="BusinessUnits"]');
        Assert.AreEqual(3, LibraryReportDataset.RowCount(), 'Created BusinessUnits should be exported');
    end;

    [Test]
    [HandlerFunctions('EXRTrialBalanceExcelHandler')]
    procedure TrialBalanceDoesntExportDimensionValuesIfUnused()
    var
        Variant: Variant;
        RequestPageXml: Text;
    begin
        // [SCENARIO] An empty report should only export GL Accounts, even if there are dimensions
        // [GIVEN] An empty trial balance
        CleanUpTrialBalanceData();
        // [GIVEN] 3 GL Accounts
        CreateSampleGLAccounts(3);
        // [GIVEN] 2 Global Dimensions, with Dimension Values
        CreateSampleGlobalDimensionAndDimensionValues();
        Commit();
        // [WHEN] Running the report
        RequestPageXml := Report.RunRequestPage(Report::"EXR Trial Balance Excel", RequestPageXml);
        LibraryReportDataset.RunReportAndLoad(Report::"EXR Trial Balance Excel", Variant, RequestPageXml);
        // [THEN] Only the GL Accounts should be exported
        Assert.AreEqual(3, LibraryReportDataset.RowCount(), 'Only the GLAccounts should be exported');
        LibraryReportDataset.SetXmlNodeList('DataItem[@name="GLAccounts"]');
        Assert.AreEqual(3, LibraryReportDataset.RowCount(), 'The exported items should be GLAccounts');
    end;

    [Test]
    [HandlerFunctions('EXRTrialBalanceBudgetExcelHandler')]
    procedure TrialBalanceBudgetDoesntExportDimensionValuesIfUnused()
    var
        Variant: Variant;
        RequestPageXml: Text;
    begin
        // [SCENARIO] An empty report should only export GL Accounts, even if there are dimensions
        // [GIVEN] An empty trial balance
        CleanUpTrialBalanceData();
        // [GIVEN] 6 GL Accounts
        CreateSampleGLAccounts(6);
        // [GIVEN] 2 Global Dimensions, with Dimension Values
        CreateSampleGlobalDimensionAndDimensionValues();
        Commit();
        // [WHEN] Running the report
        RequestPageXml := Report.RunRequestPage(Report::"EXR Trial BalanceBudgetExcel", RequestPageXml);
        LibraryReportDataset.RunReportAndLoad(Report::"EXR Trial BalanceBudgetExcel", Variant, RequestPageXml);
        // [THEN] Only the GL Accounts should be exported
        Assert.AreEqual(6, LibraryReportDataset.RowCount(), 'Only the GLAccounts should be exported');
        LibraryReportDataset.SetXmlNodeList('DataItem[@name="GLAccounts"]');
        Assert.AreEqual(6, LibraryReportDataset.RowCount(), 'The exported items should be GLAccounts');
    end;

    [Test]
    [HandlerFunctions('EXRConsolidatedTrialBalanceHandler')]
    procedure ConsolidatedTrialBalanceDoesntExportDimensionValuesIfUnused()
    var
        Variant: Variant;
        RequestPageXml: Text;
    begin
        // [SCENARIO] An empty report should only export GL Accounts, even if there are dimensions
        // [GIVEN] An empty trial balance
        CleanUpTrialBalanceData();
        // [GIVEN] 2 Business Units
        CreateSampleBusinessUnits(2);
        // [GIVEN] 6 GL Accounts
        CreateSampleGLAccounts(6);
        // [GIVEN] 2 Global Dimensions, with Dimension Values
        CreateSampleGlobalDimensionAndDimensionValues();
        Commit();
        // [WHEN] Running the report
        RequestPageXml := Report.RunRequestPage(Report::"EXR Consolidated Trial Balance", RequestPageXml);
        LibraryReportDataset.RunReportAndLoad(Report::"EXR Consolidated Trial Balance", Variant, RequestPageXml);
        // [THEN] Only the GL Accounts should be exported
        Assert.AreEqual(6 + 2, LibraryReportDataset.RowCount(), 'Only GL Accounts and Business Units should be exported');
        LibraryReportDataset.SetXmlNodeList('DataItem[@name="GLAccounts"]');
        Assert.AreEqual(6, LibraryReportDataset.RowCount(), 'Created GL Accounts should be exported');
    end;

    [Test]
    [HandlerFunctions('EXRTrialBalanceExcelHandler')]
    procedure TrialBalanceExportsOnlyTheUsedDimensionValues()
    var
        GLAccount: Record "G/L Account";
        Dimension: Record Dimension;
        DimensionValue: Record "Dimension Value";
        Variant: Variant;
        ReportValue, RequestPageXml : Text;
    begin
        // [SCENARIO] The report should only export the Dimension Values for which it has a total
        // [GIVEN] A trial balance for an entry with Global Dimension 2 value defined
        CleanUpTrialBalanceData();
        CreateSampleGLAccounts(10, GLAccount);
        CreateSampleGlobalDimensionAndDimensionValues(Dimension, DimensionValue);
        CreateGLEntry(GLAccount."No.", DimensionValue.Code);
        Commit();
        // [WHEN] Running the report
        RequestPageXml := Report.RunRequestPage(Report::"EXR Trial Balance Excel", RequestPageXml);
        LibraryReportDataset.RunReportAndLoad(Report::"EXR Trial Balance Excel", Variant, RequestPageXml);
        // [THEN] All the GLAccounts should be exported
        LibraryReportDataset.SetXmlNodeList('DataItem[@name="GLAccounts"]');
        Assert.AreEqual(10, LibraryReportDataset.RowCount(), 'Created GL Accounts should be exported');
        // [THEN] The only Dimension1 exported is the one of the entry (blank)
        LibraryReportDataset.SetXmlNodeList('DataItem[@name="Dimension1"]');
        Assert.AreEqual(1, LibraryReportDataset.RowCount(), 'There should be 1 "Global dimension 1" exported, the blank dimension');
        LibraryReportDataset.GetNextRow();
        LibraryReportDataset.FindCurrentRowValue('Dim1Code', Variant);
        ReportValue := Variant;
        Assert.AreEqual('', ReportValue, 'The exported dimension should be the blank dimension');
        // [THEN] The only Dimension2 exported is the one defined on the entry
        LibraryReportDataset.SetXmlNodeList('DataItem[@name="Dimension2"]');
        Assert.AreEqual(1, LibraryReportDataset.RowCount(), 'There should be 1 "Global dimension 2" exported');
        LibraryReportDataset.GetNextRow();
        LibraryReportDataset.FindCurrentRowValue('Dim2Code', Variant);
        ReportValue := Variant;
        Assert.AreEqual(DimensionValue.Code, ReportValue, 'The exported dimension should be the dimension in the GLEntry');
    end;

    [Test]
    [HandlerFunctions('EXRTrialBalanceBudgetExcelHandler')]
    procedure TrialBalanceBudgetExportsOnlyTheUsedDimensionValues()
    var
        GLAccount: Record "G/L Account";
        Dimension: Record Dimension;
        DimensionValue: Record "Dimension Value";
        Variant: Variant;
        ReportValue, RequestPageXml : Text;
    begin
        // [SCENARIO] The report should only export the Dimension Values for which it has a total
        // [GIVEN] A trial balance for an entry with Global Dimension 2 value defined
        CleanUpTrialBalanceData();
        CreateSampleGLAccounts(10, GLAccount);
        CreateSampleGlobalDimensionAndDimensionValues(Dimension, DimensionValue);
        CreateGLEntry(GLAccount."No.", DimensionValue.Code);
        Commit();
        // [WHEN] Running the report
        RequestPageXml := Report.RunRequestPage(Report::"EXR Trial BalanceBudgetExcel", RequestPageXml);
        LibraryReportDataset.RunReportAndLoad(Report::"EXR Trial BalanceBudgetExcel", Variant, RequestPageXml);
        // [THEN] All the GLAccounts should be exported
        LibraryReportDataset.SetXmlNodeList('DataItem[@name="GLAccounts"]');
        Assert.AreEqual(10, LibraryReportDataset.RowCount(), 'Created GL Accounts should be exported');
        // [THEN] The only Dimension1 exported is the one of the entry (blank)
        LibraryReportDataset.SetXmlNodeList('DataItem[@name="Dimension1"]');
        Assert.AreEqual(1, LibraryReportDataset.RowCount(), 'There should be 1 "Global dimension 1" exported, the blank dimension');
        LibraryReportDataset.GetNextRow();
        LibraryReportDataset.FindCurrentRowValue('Dim1Code', Variant);
        ReportValue := Variant;
        Assert.AreEqual('', ReportValue, 'The exported dimension should be the blank dimension');
        // [THEN] The only Dimension2 exported is the one defined on the entry
        LibraryReportDataset.SetXmlNodeList('DataItem[@name="Dimension2"]');
        Assert.AreEqual(1, LibraryReportDataset.RowCount(), 'There should be 1 "Global dimension 2" exported');
        LibraryReportDataset.GetNextRow();
        LibraryReportDataset.FindCurrentRowValue('Dim2Code', Variant);
        ReportValue := Variant;
        Assert.AreEqual(DimensionValue.Code, ReportValue, 'The exported dimension should be the dimension in the GLEntry');
    end;

    [Test]
    [HandlerFunctions('EXRConsolidatedTrialBalanceHandler')]
    procedure ConsolidatedTrialBalanceExportsOnlyTheUsedDimensionValues()
    var
        GLAccount: Record "G/L Account";
        Dimension: Record Dimension;
        DimensionValue: Record "Dimension Value";
        Variant: Variant;
        ReportValue, RequestPageXml : Text;
    begin
        // [SCENARIO] The report should only export the Dimension Values for which it has a total
        // [GIVEN] A trial balance for an entry with Global Dimension 2 value defined
        CleanUpTrialBalanceData();
        CreateSampleGLAccounts(10, GLAccount);
        CreateSampleBusinessUnits(1);
        CreateSampleGlobalDimensionAndDimensionValues(Dimension, DimensionValue);
        CreateGLEntry(GLAccount."No.", DimensionValue.Code);
        Commit();
        // [WHEN] Running the report
        RequestPageXml := Report.RunRequestPage(Report::"EXR Consolidated Trial Balance", RequestPageXml);
        LibraryReportDataset.RunReportAndLoad(Report::"EXR Consolidated Trial Balance", Variant, RequestPageXml);
        // [THEN] All the GLAccounts should be exported
        LibraryReportDataset.SetXmlNodeList('DataItem[@name="GLAccounts"]');
        Assert.AreEqual(10, LibraryReportDataset.RowCount(), 'Created GL Accounts should be exported');
        // [THEN] The only Dimension1 exported is the one of the entry (blank)
        LibraryReportDataset.SetXmlNodeList('DataItem[@name="Dimension1"]');
        Assert.AreEqual(1, LibraryReportDataset.RowCount(), 'There should be 1 "Global dimension 1" exported, the blank dimension');
        LibraryReportDataset.GetNextRow();
        LibraryReportDataset.FindCurrentRowValue('Dim1Code', Variant);
        ReportValue := Variant;
        Assert.AreEqual('', ReportValue, 'The exported dimension should be the blank dimension');
        // [THEN] The only Dimension2 exported is the one defined on the entry
        LibraryReportDataset.SetXmlNodeList('DataItem[@name="Dimension2"]');
        Assert.AreEqual(1, LibraryReportDataset.RowCount(), 'There should be 1 "Global dimension 2" exported');
        LibraryReportDataset.GetNextRow();
        LibraryReportDataset.FindCurrentRowValue('Dim2Code', Variant);
        ReportValue := Variant;
        Assert.AreEqual(DimensionValue.Code, ReportValue, 'The exported dimension should be the dimension in the GLEntry');
    end;

    [Test]
    [HandlerFunctions('EXRConsolidatedTrialBalanceHandler')]
    procedure ConsolidatedTrialBalanceShouldErrorWithNoBusinessUnits()
    var
        GLAccount: Record "G/L Account";
        Variant: Variant;
        RequestPageXml: Text;
    begin
        // [SCENARIO 544098] Running Consolidation Trial Balance should fail when there are no business units configured.
        // [GIVEN] A company without business units
        CleanUpTrialBalanceData();
        CreateSampleGLAccounts(10, GLAccount);
        Commit();
        // [WHEN] Running the Consolidation Trial Balance report
        RequestPageXml := Report.RunRequestPage(Report::"EXR Consolidated Trial Balance", RequestPageXml);
        // [THEN] It should fail and not produce a corrupt Excel file.
        asserterror LibraryReportDataset.RunReportAndLoad(Report::"EXR Consolidated Trial Balance", Variant, RequestPageXml);
    end;

    [Test]
    procedure TrialBalanceBufferNetChangeSplitsIntoDebitAndCreditWhenCalledSeveralTimes()
    var
        EXRTrialBalanceBuffer: Record "EXR Trial Balance Buffer";
        ValuesToSplitInCreditAndDebit: array[3] of Decimal;
    begin
        // [SCENARIO 547558] Trial Balance Buffer data split into Debit and Credit correctly, even if called multiple times.
        // [GIVEN] Trial Balance Buffer filled with positive Balance/Net Change
        ValuesToSplitInCreditAndDebit[1] := 837;
        // [GIVEN] Trial Balance Buffer filled with negative Balance/Net Change
        ValuesToSplitInCreditAndDebit[2] := -110;
        // [GIVEN] Trial Balance Buffer filled with positive Balance/Net Change
        ValuesToSplitInCreditAndDebit[3] := 998;
        // [WHEN] Trial Balance Buffer entries are inserted
        EXRTrialBalanceBuffer."G/L Account No." := 'A';
        EXRTrialBalanceBuffer.Validate("Net Change", ValuesToSplitInCreditAndDebit[1]);
        EXRTrialBalanceBuffer.Validate(Balance, ValuesToSplitInCreditAndDebit[1]);
        EXRTrialBalanceBuffer.Validate("Net Change (ACY)", ValuesToSplitInCreditAndDebit[1]);
        EXRTrialBalanceBuffer.Validate("Balance (ACY)", ValuesToSplitInCreditAndDebit[1]);
        EXRTrialBalanceBuffer.Insert();
        EXRTrialBalanceBuffer."G/L Account No." := 'B';
        EXRTrialBalanceBuffer.Validate("Net Change", ValuesToSplitInCreditAndDebit[2]);
        EXRTrialBalanceBuffer.Validate(Balance, ValuesToSplitInCreditAndDebit[2]);
        EXRTrialBalanceBuffer.Validate("Net Change (ACY)", ValuesToSplitInCreditAndDebit[2]);
        EXRTrialBalanceBuffer.Validate("Balance (ACY)", ValuesToSplitInCreditAndDebit[2]);
        EXRTrialBalanceBuffer.Insert();
        EXRTrialBalanceBuffer."G/L Account No." := 'C';
        EXRTrialBalanceBuffer.Validate("Net Change", ValuesToSplitInCreditAndDebit[3]);
        EXRTrialBalanceBuffer.Validate(Balance, ValuesToSplitInCreditAndDebit[3]);
        EXRTrialBalanceBuffer.Validate("Net Change (ACY)", ValuesToSplitInCreditAndDebit[3]);
        EXRTrialBalanceBuffer.Validate("Balance (ACY)", ValuesToSplitInCreditAndDebit[3]);
        EXRTrialBalanceBuffer.Insert();
        // [THEN] All Entries have the right split in Credit and Debit
        EXRTrialBalanceBuffer.FindSet();
        Assert.AreEqual(ValuesToSplitInCreditAndDebit[1], Abs(EXRTrialBalanceBuffer."Net Change (Debit)" + EXRTrialBalanceBuffer."Net Change (Credit)"), 'Split in line in credit and debit should be the same as the inserted value.');
        Assert.AreEqual(ValuesToSplitInCreditAndDebit[1], Abs(EXRTrialBalanceBuffer."Balance (Debit)" + EXRTrialBalanceBuffer."Balance (Credit)"), 'Split in line in credit and debit should be the same as the inserted value.');
        Assert.AreEqual(ValuesToSplitInCreditAndDebit[1], Abs(EXRTrialBalanceBuffer."Net Change (Debit) (ACY)" + EXRTrialBalanceBuffer."Net Change (Credit) (ACY)"), 'Split in line in credit and debit should be the same as the inserted value.');
        Assert.AreEqual(ValuesToSplitInCreditAndDebit[1], Abs(EXRTrialBalanceBuffer."Balance (Debit) (ACY)" + EXRTrialBalanceBuffer."Balance (Credit) (ACY)"), 'Split in line in credit and debit should be the same as the inserted value.');
        EXRTrialBalanceBuffer.Next();
        Assert.AreEqual(-ValuesToSplitInCreditAndDebit[2], Abs(EXRTrialBalanceBuffer."Net Change (Debit)" + EXRTrialBalanceBuffer."Net Change (Credit)"), 'Split in line in credit and debit should be the same as the inserted value.');
        Assert.AreEqual(-ValuesToSplitInCreditAndDebit[2], Abs(EXRTrialBalanceBuffer."Balance (Debit)" + EXRTrialBalanceBuffer."Balance (Credit)"), 'Split in line in credit and debit should be the same as the inserted value.');
        Assert.AreEqual(-ValuesToSplitInCreditAndDebit[2], Abs(EXRTrialBalanceBuffer."Net Change (Debit) (ACY)" + EXRTrialBalanceBuffer."Net Change (Credit) (ACY)"), 'Split in line in credit and debit should be the same as the inserted value.');
        Assert.AreEqual(-ValuesToSplitInCreditAndDebit[2], Abs(EXRTrialBalanceBuffer."Balance (Debit) (ACY)" + EXRTrialBalanceBuffer."Balance (Credit) (ACY)"), 'Split in line in credit and debit should be the same as the inserted value.');
        EXRTrialBalanceBuffer.Next();
        Assert.AreEqual(ValuesToSplitInCreditAndDebit[3], Abs(EXRTrialBalanceBuffer."Net Change (Debit)" + EXRTrialBalanceBuffer."Net Change (Credit)"), 'Split in line in credit and debit should be the same as the inserted value.');
        Assert.AreEqual(ValuesToSplitInCreditAndDebit[3], Abs(EXRTrialBalanceBuffer."Balance (Debit)" + EXRTrialBalanceBuffer."Balance (Credit)"), 'Split in line in credit and debit should be the same as the inserted value.');
        Assert.AreEqual(ValuesToSplitInCreditAndDebit[3], Abs(EXRTrialBalanceBuffer."Net Change (Debit) (ACY)" + EXRTrialBalanceBuffer."Net Change (Credit) (ACY)"), 'Split in line in credit and debit should be the same as the inserted value.');
        Assert.AreEqual(ValuesToSplitInCreditAndDebit[3], Abs(EXRTrialBalanceBuffer."Balance (Debit) (ACY)" + EXRTrialBalanceBuffer."Balance (Credit) (ACY)"), 'Split in line in credit and debit should be the same as the inserted value.');
    end;

    local procedure CreateSampleBusinessUnits(HowMany: Integer)
    var
        BusinessUnit: Record "Business Unit";
    begin
        CreateSampleBusinessUnits(HowMany, BusinessUnit);
    end;

    local procedure CreateSampleBusinessUnits(HowMany: Integer; var BusinessUnit: Record "Business Unit")
    var
        i: Integer;
    begin
        for i := 1 to HowMany do
            LibraryERM.CreateBusinessUnit(BusinessUnit);
    end;

    local procedure CreateSampleGLAccounts(HowMany: Integer)
    var
        GLAccount: Record "G/L Account";
    begin
        CreateSampleGLAccounts(HowMany, GLAccount);
    end;

    local procedure CreateSampleGLAccounts(HowMany: Integer; var GLAccount: Record "G/L Account")
    var
        i: Integer;
    begin
        for i := 1 to HowMany do
            LibraryERM.CreateGLAccount(GLAccount);
    end;

    local procedure CleanUpTrialBalanceData()
    var
        GLAccount: Record "G/L Account";
        GLEntry: Record "G/L Entry";
        Dimension: Record Dimension;
        DimensionValue: Record "Dimension Value";
        BusinessUnit: Record "Business Unit";
    begin
        DimensionValue.DeleteAll();
        Dimension.DeleteAll();
        GLAccount.DeleteAll();
        BusinessUnit.DeleteAll();
        GLEntry.DeleteAll();
    end;

    local procedure CreateSampleGlobalDimensionAndDimensionValues()
    var
        Dimension: Record Dimension;
        DimensionValue: Record "Dimension Value";
    begin
        CreateSampleGlobalDimensionAndDimensionValues(Dimension, DimensionValue);
    end;

    local procedure CreateSampleGlobalDimensionAndDimensionValues(var Dimension: Record Dimension; var DimensionValue: Record "Dimension Value")
    begin
        LibraryERM.CreateDimension(Dimension);
        LibraryERM.CreateDimensionValue(DimensionValue, Dimension.Code);
        DimensionValue."Global Dimension No." := 1;
        DimensionValue.Modify();
        LibraryERM.CreateDimensionValue(DimensionValue, Dimension.Code);
        DimensionValue."Global Dimension No." := 1;
        DimensionValue.Modify();
        LibraryERM.CreateDimension(Dimension);
        LibraryERM.CreateDimensionValue(DimensionValue, Dimension.Code);
        DimensionValue."Global Dimension No." := 2;
        DimensionValue.Modify();
        LibraryERM.CreateDimensionValue(DimensionValue, Dimension.Code);
        DimensionValue."Global Dimension No." := 2;
        DimensionValue.Modify();
        LibraryERM.CreateDimensionValue(DimensionValue, Dimension.Code);
        DimensionValue."Global Dimension No." := 2;
        DimensionValue.Modify();
    end;

    local procedure CreateGLEntry(GLAccountNo: Code[20]; DimensionValue2Code: Code[20])
    var
        GLEntry: Record "G/L Entry";
        EntryNo: Integer;
    begin
        if GLEntry.FindLast() then;
        EntryNo := GLEntry."Entry No." + 1;
        Clear(GLEntry);
        GLEntry."Entry No." := EntryNo;
        GLEntry."G/L Account No." := GLAccountNo;
        GLEntry."Global Dimension 2 Code" := DimensionValue2Code;
        GLEntry.Amount := 1337;
        GLEntry."Debit Amount" := GLEntry.Amount;
        GLEntry."Posting Date" := WorkDate();
        GLEntry.Insert();
    end;

    [RequestPageHandler]
    procedure EXRTrialBalanceExcelHandler(var EXRTrialBalanceExcel: TestRequestPage "EXR Trial Balance Excel")
    begin
        EXRTrialBalanceExcel.OK().Invoke();
    end;

    [RequestPageHandler]
    procedure EXRTrialBalanceBudgetExcelHandler(var EXRTrialBalanceBudgetExcel: TestRequestPage "EXR Trial BalanceBudgetExcel")
    begin
        EXRTrialBalanceBudgetExcel.OK().Invoke();
    end;

    [RequestPageHandler]
    procedure EXRConsolidatedTrialBalanceHandler(var EXRConsolidatedTrialBalance: TestRequestPage "EXR Consolidated Trial Balance")
    begin
        EXRConsolidatedTrialBalance.EndingDateField.Value := Format(20261231D);
        EXRConsolidatedTrialBalance.OK().Invoke();
    end;

}