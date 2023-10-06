// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Test.DataAdministration;

using System.DataAdministration;
using System.TestLibraries.DataAdministration;
using System.TestLibraries.Utilities;
using System.TestLibraries.Security.AccessControl;

codeunit 138700 "Retention Period Test"
{
    Subtype = Test;

    var
        Assert: Codeunit "Library Assert";
        PermissionsMock: Codeunit "Permissions Mock";

    trigger OnRun()
    begin

    end;

    [Test]
    procedure TestOneWeekRetentionPeriod()
    begin
        TestRetentionPeriod(Enum::"Retention Period Enum"::"1 Week", '<-1W>');
    end;

    [Test]
    procedure TestTwentyEightDaysRetentionPeriod()
    begin
        TestRetentionPeriod(Enum::"Retention Period Enum"::"28 Days", '<-28D>');
    end;

    [Test]
    procedure TestOneMonthRetentionPeriod()
    begin
        TestRetentionPeriod(Enum::"Retention Period Enum"::"1 Month", '<-1M>');
    end;

    [Test]
    procedure TestThreeMonthsRetentionPeriod()
    begin
        TestRetentionPeriod(Enum::"Retention Period Enum"::"3 Months", '<-3M>');
    end;

    [Test]
    procedure TestSixMonthsRetentionPeriod()
    begin
        TestRetentionPeriod(Enum::"Retention Period Enum"::"6 Months", '<-6M>');
    end;

    [Test]
    procedure TestOneYearRetentionPeriod()
    begin
        TestRetentionPeriod(Enum::"Retention Period Enum"::"1 Year", '<-1Y>');
    end;

    [Test]
    procedure TestThreeYearsRetentionPeriod()
    begin
        TestRetentionPeriod(Enum::"Retention Period Enum"::"3 Years", '<-3Y>');
    end;

    [Test]
    procedure TestFiveYearsRetentionPeriod()
    begin
        TestRetentionPeriod(Enum::"Retention Period Enum"::"5 Years", '<-5Y>');
    end;

    [Test]
    procedure TestNeverDeleteRetentionPeriod()
    var
        RetentionPeriod: Record "Retention Period";
        ExpirationDate: Date;
        CurrDateTime: DateTime;
        ExpirationDateTime: DateTime;
        RetentionPeriodInterface: Interface "Retention Period";
    begin
        PermissionsMock.Set('Retention Pol. Admin');
        // Setup
        RetentionPeriod."Retention Period" := RetentionPeriod."Retention Period"::"Never Delete";
        RetentionPeriodInterface := RetentionPeriod."Retention Period";

        // Exercise
        ExpirationDate := RetentionPeriodInterface.CalculateExpirationDate(RetentionPeriod, Today);
        CurrDateTime := CurrentDateTime();
        ExpirationDateTime := RetentionPeriodInterface.CalculateExpirationDate(RetentionPeriod, CurrDateTime);

        // Verify
        Assert.AreEqual(DMY2DATE(31, 12, 9999), ExpirationDate, 'Incorrect expiration date for Retention Period ''Never Delete''');
        Assert.AreEqual(CreateDateTime(DMY2DATE(31, 12, 9999), 235959.999T), ExpirationDateTime, 'Incorrect expiration datetime for Retention Period ''Never Delete''');
    end;

    local procedure TestRetentionPeriod(RetentionPeriodEnum: Enum "Retention Period Enum"; DateExpression: Text)
    var
        RetentionPeriod: Record "Retention Period";
        ExpirationDate: Date;
        CurrDateTime: DateTime;
        ExpirationDateTime: DateTime;
        RetentionPeriodInterface: Interface "Retention Period";
        IncorrectExpirationDatetimeTxt: Label 'Incorrect expiration datetime for Retention Period ''%1''', Comment = '%1 = Retetion Period (e.g. 3 years)';
        IncorrectExpirationDateTxt: Label 'Incorrect expiration date for Retention Period ''%1''', Comment = '%1 = Retetion Period (e.g. 3 years)';
    begin
        PermissionsMock.Set('Retention Pol. Admin');
        // Setup
        RetentionPeriod."Retention Period" := RetentionPeriodEnum;
        RetentionPeriodInterface := RetentionPeriod."Retention Period";
        // Exercise
        ExpirationDate := RetentionPeriodInterface.CalculateExpirationDate(RetentionPeriod, Today);
        CurrDateTime := CurrentDateTime();
        ExpirationDateTime := RetentionPeriodInterface.CalculateExpirationDate(RetentionPeriod, CurrDateTime);

        // Verify
        Assert.AreEqual(CalcDate(DateExpression, Today()), ExpirationDate, StrSubstNo(IncorrectExpirationDateTxt, RetentionPeriodEnum));
        Assert.AreEqual(CreateDateTime(CalcDate(DateExpression, DT2Date(CurrDateTime)), DT2Time(CurrDateTime)), ExpirationDateTime, StrSubstNo(IncorrectExpirationDatetimeTxt, RetentionPeriodEnum));
    end;

    [Test]
    procedure TestRollingMonthCustomRetentionPeriod()
    var
        RetentionPeriod: Record "Retention Period";
        ExpirationDate: Date;
        CurrDateTime: DateTime;
        ExpirationDateTime: DateTime;
        RetentionPeriodInterface: Interface "Retention Period";
    begin
        PermissionsMock.Set('Retention Pol. Admin');
        // Setup
        RetentionPeriod."Retention Period" := RetentionPeriod."Retention Period"::Custom;
        Evaluate(RetentionPeriod."Ret. Period Calculation", '<+CM-2M>');
        RetentionPeriodInterface := RetentionPeriod."Retention Period";

        // Exercise
        ExpirationDate := RetentionPeriodInterface.CalculateExpirationDate(RetentionPeriod, Today);
        CurrDateTime := CurrentDateTime();
        ExpirationDateTime := RetentionPeriodInterface.CalculateExpirationDate(RetentionPeriod, CurrDateTime);

        // Verify
        Assert.AreEqual(CalcDate('<+CM-2M>', Today()), ExpirationDate, 'Incorrect expiration date for Retention Period ''Custom''');
        Assert.AreEqual(CreateDateTime(CalcDate('<+CM-2M>', DT2Date(CurrDateTime)), DT2Time(CurrDateTime)), ExpirationDateTime, 'Incorrect expiration datetime for Retention Period ''Custom''');
    end;

    [Test]
    procedure Test1WeekRetentionPeriodDateFormulaTranslation()
    var
        RetentionPeriod: Record "Retention Period";
        RetentionPeriodInterface: Interface "Retention Period";
    begin
        PermissionsMock.Set('Retention Pol. Admin');
        // Setup
        GlobalLanguage(1030);
        RetentionPeriod."Retention Period" := RetentionPeriod."Retention Period"::"1 Week";
        RetentionPeriodInterface := RetentionPeriod."Retention Period";

        // Exercise
        // Verify
        Assert.AreEqual('<-1W>', RetentionPeriodInterface.RetentionPeriodDateFormula(RetentionPeriod), 'Incorrect DateFormula for Retention Period ''1 Week''');
        Assert.AreEqual('<-1W>', RetentionPeriodInterface.RetentionPeriodDateFormula(RetentionPeriod, false), 'Incorrect DateFormula for Retention Period ''1 Week''');
        Assert.AreEqual('-1U', RetentionPeriodInterface.RetentionPeriodDateFormula(RetentionPeriod, true), 'Incorrect DateFormula for Retention Period ''1 Week''');

        GlobalLanguage(1033);
    end;

    [Test]
    procedure Test1MonthRetentionPeriodDateFormulaTranslation()
    var
        RetentionPeriod: Record "Retention Period";
        RetentionPeriodInterface: Interface "Retention Period";
    begin
        PermissionsMock.Set('Retention Pol. Admin');
        // Setup
        GlobalLanguage(1030);
        RetentionPeriod."Retention Period" := RetentionPeriod."Retention Period"::"1 Month";
        RetentionPeriodInterface := RetentionPeriod."Retention Period";

        // Exercise
        // Verify
        Assert.AreEqual('<-1M>', RetentionPeriodInterface.RetentionPeriodDateFormula(RetentionPeriod), 'Incorrect DateFormula for Retention Period ''1 Month''');
        Assert.AreEqual('<-1M>', RetentionPeriodInterface.RetentionPeriodDateFormula(RetentionPeriod, false), 'Incorrect DateFormula for Retention Period ''1 Month''');
        Assert.AreEqual('-1M', RetentionPeriodInterface.RetentionPeriodDateFormula(RetentionPeriod, true), 'Incorrect DateFormula for Retention Period ''1 Month''');

        GlobalLanguage(1033);
    end;

    [Test]
    procedure Test3MonthsRetentionPeriodDateFormulaTranslation()
    var
        RetentionPeriod: Record "Retention Period";
        RetentionPeriodInterface: Interface "Retention Period";
    begin
        PermissionsMock.Set('Retention Pol. Admin');
        // Setup
        GlobalLanguage(1030);
        RetentionPeriod."Retention Period" := RetentionPeriod."Retention Period"::"3 Months";
        RetentionPeriodInterface := RetentionPeriod."Retention Period";

        // Exercise
        // Verify
        Assert.AreEqual('<-3M>', RetentionPeriodInterface.RetentionPeriodDateFormula(RetentionPeriod), 'Incorrect DateFormula for Retention Period ''3 Months''');
        Assert.AreEqual('<-3M>', RetentionPeriodInterface.RetentionPeriodDateFormula(RetentionPeriod, false), 'Incorrect DateFormula for Retention Period ''3 Months''');
        Assert.AreEqual('-3M', RetentionPeriodInterface.RetentionPeriodDateFormula(RetentionPeriod, true), 'Incorrect DateFormula for Retention Period ''3 Months''');

        GlobalLanguage(1033);
    end;

    [Test]
    procedure Test6MonthsRetentionPeriodDateFormulaTranslation()
    var
        RetentionPeriod: Record "Retention Period";
        RetentionPeriodInterface: Interface "Retention Period";
    begin
        PermissionsMock.Set('Retention Pol. Admin');
        // Setup
        GlobalLanguage(1030);
        RetentionPeriod."Retention Period" := RetentionPeriod."Retention Period"::"6 Months";
        RetentionPeriodInterface := RetentionPeriod."Retention Period";

        // Exercise
        // Verify
        Assert.AreEqual('<-6M>', RetentionPeriodInterface.RetentionPeriodDateFormula(RetentionPeriod), 'Incorrect DateFormula for Retention Period ''6 Months''');
        Assert.AreEqual('<-6M>', RetentionPeriodInterface.RetentionPeriodDateFormula(RetentionPeriod, false), 'Incorrect DateFormula for Retention Period ''6 Months''');
        Assert.AreEqual('-6M', RetentionPeriodInterface.RetentionPeriodDateFormula(RetentionPeriod, true), 'Incorrect DateFormula for Retention Period ''6 Months''');

        GlobalLanguage(1033);
    end;

    [Test]
    procedure Test1YearRetentionPeriodDateFormulaTranslation()
    var
        RetentionPeriod: Record "Retention Period";
        RetentionPeriodInterface: Interface "Retention Period";
    begin
        PermissionsMock.Set('Retention Pol. Admin');
        // Setup
        GlobalLanguage(1030);
        RetentionPeriod."Retention Period" := RetentionPeriod."Retention Period"::"1 Year";
        RetentionPeriodInterface := RetentionPeriod."Retention Period";

        // Exercise
        // Verify
        Assert.AreEqual('<-1Y>', RetentionPeriodInterface.RetentionPeriodDateFormula(RetentionPeriod), 'Incorrect DateFormula for Retention Period ''1 Year''');
        Assert.AreEqual('<-1Y>', RetentionPeriodInterface.RetentionPeriodDateFormula(RetentionPeriod, false), 'Incorrect DateFormula for Retention Period ''1 Year''');
        Assert.AreEqual('-1Å', RetentionPeriodInterface.RetentionPeriodDateFormula(RetentionPeriod, true), 'Incorrect DateFormula for Retention Period ''1 Year''');

        GlobalLanguage(1033);
    end;

    [Test]
    procedure Test5YearsRetentionPeriodDateFormulaTranslation()
    var
        RetentionPeriod: Record "Retention Period";
        RetentionPeriodInterface: Interface "Retention Period";
    begin
        PermissionsMock.Set('Retention Pol. Admin');
        // Setup
        GlobalLanguage(1030);
        RetentionPeriod."Retention Period" := RetentionPeriod."Retention Period"::"5 Years";
        RetentionPeriodInterface := RetentionPeriod."Retention Period";

        // Exercise
        // Verify
        Assert.AreEqual('<-5Y>', RetentionPeriodInterface.RetentionPeriodDateFormula(RetentionPeriod), 'Incorrect DateFormula for Retention Period ''5 Years''');
        Assert.AreEqual('<-5Y>', RetentionPeriodInterface.RetentionPeriodDateFormula(RetentionPeriod, false), 'Incorrect DateFormula for Retention Period ''5 Years''');
        Assert.AreEqual('-5Å', RetentionPeriodInterface.RetentionPeriodDateFormula(RetentionPeriod, true), 'Incorrect DateFormula for Retention Period ''5 Years''');

        GlobalLanguage(1033);
    end;

    [Test]
    procedure TestNeverDeleteRetentionPeriodDateFormulaTranslation()
    var
        RetentionPeriod: Record "Retention Period";
        RetentionPeriodInterface: Interface "Retention Period";
        UnltdRetenPolCalcFormDKTxt: Label '+LÅ+%1Å', Locked = true;
        UnltdRetenPolCalcFormTxt: Label '<+CY+%1Y>', Locked = true;
    begin
        PermissionsMock.Set('Retention Pol. Admin');
        // Setup
        GlobalLanguage(1030);
        RetentionPeriod."Retention Period" := RetentionPeriod."Retention Period"::"Never Delete";
        RetentionPeriodInterface := RetentionPeriod."Retention Period";

        // Exercise
        // Verify
        Assert.AreEqual(StrSubstNo(UnltdRetenPolCalcFormTxt, 9999 - Date2DMY(Today(), 3)), RetentionPeriodInterface.RetentionPeriodDateFormula(RetentionPeriod), 'Incorrect DateFormula for Retention Period ''Never Delete''');
        Assert.AreEqual(StrSubstNo(UnltdRetenPolCalcFormTxt, 9999 - Date2DMY(Today(), 3)), RetentionPeriodInterface.RetentionPeriodDateFormula(RetentionPeriod, false), 'Incorrect DateFormula for Retention Period ''Never Delete''');
        Assert.AreEqual(StrSubstNo(UnltdRetenPolCalcFormDKTxt, 9999 - Date2DMY(Today(), 3)), RetentionPeriodInterface.RetentionPeriodDateFormula(RetentionPeriod, true), 'Incorrect DateFormula for Retention Period ''Never Delete''');

        GlobalLanguage(1033);
    end;

    [Test]
    procedure TestCustomRetentionPeriodDateFormulaTranslation()
    var
        RetentionPeriod: Record "Retention Period";
        RetentionPeriodInterface: Interface "Retention Period";
    begin
        PermissionsMock.Set('Retention Pol. Admin');
        // Setup
        GlobalLanguage(1030);
        RetentionPeriod."Retention Period" := RetentionPeriod."Retention Period"::Custom;
        Evaluate(RetentionPeriod."Ret. Period Calculation", '<+CY-24M>');
        RetentionPeriodInterface := RetentionPeriod."Retention Period";

        // Exercise
        // Verify
        Assert.AreEqual('<+CY-24M>', RetentionPeriodInterface.RetentionPeriodDateFormula(RetentionPeriod), 'Incorrect DateFormula for Retention Period ''Custom''');
        Assert.AreEqual('<+CY-24M>', RetentionPeriodInterface.RetentionPeriodDateFormula(RetentionPeriod, false), 'Incorrect DateFormula for Retention Period ''Custom''');
        Assert.AreEqual('+LÅ-24M', RetentionPeriodInterface.RetentionPeriodDateFormula(RetentionPeriod, true), 'Incorrect DateFormula for Retention Period ''Custom''');

        GlobalLanguage(1033);
    end;

    [Test]
    procedure TestCustomRetentionPeriodInterfaceInitializationError()
    var
        RetentionPeriod: Record "Retention Period";
        RetentionPeriodInterface: Interface "Retention Period";
        DateFormulaText: Text;
    begin
        PermissionsMock.Set('Retention Pol. Admin');
        // Setup - initialize with one implementation
        RetentionPeriod."Retention Period" := RetentionPeriod."Retention Period"::"Never Delete";
        RetentionPeriodInterface := RetentionPeriod."Retention Period";

        // Exercise - change enum value (to force another implementation)
        RetentionPeriod."Retention Period" := RetentionPeriod."Retention Period"::Custom;
        asserterror
            DateFormulaText := RetentionPeriodInterface.RetentionPeriodDateFormula(RetentionPeriod);

        // Verify - the correct error is thrown due to interface implementation mismatch.
        Assert.ExpectedError('This implementation of the interface does not support the enum value selected');
    end;

    [Test]
    procedure TestOnValidateRetentionPeriod()
    var
        RetentionPeriod: Record "Retention Period";
        RetentionPeriods: TestPage "Retention Periods";
    begin
        PermissionsMock.Set('Retention Pol. Admin');
        // Setup
        ClearTestData();
        RetentionPeriod.Code := Format(RetentionPeriod."Retention Period"::"1 Month");
        RetentionPeriod."Retention Period" := RetentionPeriod."Retention Period"::"1 Month";
        RetentionPeriod.Insert();

        RetentionPeriods.OpenEdit();
        RetentionPeriods.First();
        RetentionPeriods."Expiration Date".AssertEquals(CalcDate('<-1M>', Today()));

        // Exercise
        RetentionPeriods."Retention Period".SetValue(RetentionPeriod."Retention Period"::"3 Months");

        // Verify
        RetentionPeriods."Expiration Date".AssertEquals(CalcDate('<-3M>', Today()));
    end;

    [Test]
    procedure TestOnValidateRetentionPeriodCustom()
    var
        RetentionPeriod: Record "Retention Period";
        RetentionPeriods: TestPage "Retention Periods";
    begin
        PermissionsMock.Set('Retention Pol. Admin');
        // Setup
        ClearTestData();
        RetentionPeriod.Code := Format(RetentionPeriod."Retention Period"::"1 Month");
        RetentionPeriod."Retention Period" := RetentionPeriod."Retention Period"::"1 Month";
        RetentionPeriod.Insert();

        RetentionPeriods.OpenEdit();
        RetentionPeriods.First();
        RetentionPeriods."Expiration Date".AssertEquals(CalcDate('<-1M>', Today()));

        // Exercise
        RetentionPeriods."Retention Period".SetValue(RetentionPeriod."Retention Period"::"Custom");
        RetentionPeriods."Expiration Date".AssertEquals(0D);
        RetentionPeriods."Ret. Period Calculation".SetValue('-3M');

        // Verify
        RetentionPeriods."Expiration Date".AssertEquals(CalcDate('<-3M>', Today()));
    end;

    [Test]
    procedure TestOnValidateRetPeriodCustomCalculationFail()
    var
        RetentionPeriod: Record "Retention Period";
        RetentionPeriods: TestPage "Retention Periods";
    begin
        PermissionsMock.Set('Retention Pol. Admin');
        // Setup
        ClearTestData();
        RetentionPeriod.Code := Format(RetentionPeriod."Retention Period"::"1 Month");
        RetentionPeriod."Retention Period" := RetentionPeriod."Retention Period"::"1 Month";
        RetentionPeriod.Insert();

        RetentionPeriods.OpenEdit();
        RetentionPeriods.First();
        RetentionPeriods."Expiration Date".AssertEquals(CalcDate('<-1M>', Today()));

        // Exercise
        RetentionPeriods."Retention Period".SetValue(RetentionPeriod."Retention Period"::"Custom");
        RetentionPeriods."Expiration Date".AssertEquals(0D);
        asserterror
            RetentionPeriods."Ret. Period Calculation".SetValue('3M');

        // Verify
        Assert.ExpectedError('The date formula (3M) must result in a date that is at least two days before the current date');
    end;

    [Test]
    procedure TestCalcExpirationDateOnNewRecordOnListPage()
    var
        RetentionPeriod: Record "Retention Period";
        RetentionPeriods: TestPage "Retention Periods";
    begin
        PermissionsMock.Set('Retention Pol. Admin');
        // Setup
        ClearTestData();
        RetentionPeriod.Code := Format(RetentionPeriod."Retention Period"::"1 Month");
        RetentionPeriod."Retention Period" := RetentionPeriod."Retention Period"::"1 Month";
        RetentionPeriod.Insert();

        RetentionPeriods.OpenEdit();
        RetentionPeriods.First();
        RetentionPeriods."Expiration Date".AssertEquals(CalcDate('<-1M>', Today()));

        // Exercise
        RetentionPeriods.New();

        // Verify
        RetentionPeriods."Expiration Date".AssertEquals(0D);
    end;

    local procedure ClearTestData()
    var
        RetentionPeriod: Record "Retention Period";
        RetentionPolicySetup: Record "Retention Policy Setup";
        RetentionPolicySetupLine: Record "Retention Policy Setup Line";
        RetentionPolicyTestData: Record "Retention Policy Test Data";
    begin
        RetentionPolicyTestData.DeleteAll(true);
        RetentionPolicySetup.DeleteAll(true);
        RetentionPolicySetupLine.DeleteAll(true);
        RetentionPeriod.DeleteAll(true);
    end;

}
