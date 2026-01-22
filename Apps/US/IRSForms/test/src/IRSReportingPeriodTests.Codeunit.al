// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

codeunit 148016 "IRS Reporting Period Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        LibraryUtility: Codeunit "Library - Utility";
        Assert: Codeunit Assert;
        IsInitialized: Boolean;
        StartingEndingDateOverlapErr: Label 'The starting date and ending date overlap with an existing reporting period.';

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure ReportingPeriodOverlapWithStartingDate()
    var
        IRSReportingPeriod: Record "IRS Reporting Period";
    begin
        // [SCENARIO 495389] Stan cannot create reporting periods where starting date and ending date overlap with existing reporting periods

        Initialize();
        IRSReportingPeriod."No." := LibraryUtility.GenerateGUID();
        IRSReportingPeriod.Validate("Starting Date", 20240101D);
        IRSReportingPeriod.Validate("Ending Date", 20241231D);
        IRSReportingPeriod.Insert();

        IRSReportingPeriod.Init();
        IRSReportingPeriod."No." := LibraryUtility.GenerateGUID();
        IRSReportingPeriod.Validate("Starting Date", 20230101D);
        asserterror IRSReportingPeriod.Validate("Ending Date", 20240101D);

        Assert.ExpectedError(StartingEndingDateOverlapErr);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure ReportingPeriodOverlapWithEndingDate()
    var
        IRSReportingPeriod: Record "IRS Reporting Period";
    begin
        // [SCENARIO 495389] Stan cannot create reporting periods where starting date and ending date overlap with existing reporting periods

        Initialize();
        IRSReportingPeriod."No." := LibraryUtility.GenerateGUID();
        IRSReportingPeriod.Validate("Starting Date", 20240101D);
        IRSReportingPeriod.Validate("Ending Date", 20241231D);
        IRSReportingPeriod.Insert();

        IRSReportingPeriod.Init();
        IRSReportingPeriod."No." := LibraryUtility.GenerateGUID();
        IRSReportingPeriod.Validate("Starting Date", 20241231D);
        asserterror IRSReportingPeriod.Validate("Ending Date", 20250101D);

        Assert.ExpectedError(StartingEndingDateOverlapErr);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure ReportingPeriodOverlapStartingInTheMiddle()
    var
        IRSReportingPeriod: Record "IRS Reporting Period";
    begin
        // [SCENARIO 495389] Stan cannot create reporting periods where starting date and ending date overlap with existing reporting periods

        Initialize();
        IRSReportingPeriod."No." := LibraryUtility.GenerateGUID();
        IRSReportingPeriod.Validate("Starting Date", 20240101D);
        IRSReportingPeriod.Validate("Ending Date", 20241231D);
        IRSReportingPeriod.Insert();

        IRSReportingPeriod.Init();
        IRSReportingPeriod."No." := LibraryUtility.GenerateGUID();
        IRSReportingPeriod.Validate("Starting Date", 20240501D);
        asserterror IRSReportingPeriod.Validate("Ending Date", 20250101D);

        Assert.ExpectedError(StartingEndingDateOverlapErr);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure ReportingPeriodOverlapEndinggInTheMiddle()
    var
        IRSReportingPeriod: Record "IRS Reporting Period";
    begin
        // [SCENARIO 495389] Stan cannot create reporting periods where starting date and ending date overlap with existing reporting periods

        Initialize();
        IRSReportingPeriod."No." := LibraryUtility.GenerateGUID();
        IRSReportingPeriod.Validate("Starting Date", 20240101D);
        IRSReportingPeriod.Validate("Ending Date", 20241231D);
        IRSReportingPeriod.Insert();

        IRSReportingPeriod.Init();
        IRSReportingPeriod."No." := LibraryUtility.GenerateGUID();
        IRSReportingPeriod.Validate("Starting Date", 20230101D);
        asserterror IRSReportingPeriod.Validate("Ending Date", 20240501D);

        Assert.ExpectedError(StartingEndingDateOverlapErr);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure ReportingPeriodBeforeExisting()
    var
        IRSReportingPeriod: Record "IRS Reporting Period";
    begin
        // [SCENARIO 495389] Stan can create a new reporting period before the existing one

        Initialize();
        IRSReportingPeriod."No." := LibraryUtility.GenerateGUID();
        IRSReportingPeriod.Validate("Starting Date", 20240101D);
        IRSReportingPeriod.Validate("Ending Date", 20241231D);
        IRSReportingPeriod.Insert();

        IRSReportingPeriod.Init();
        IRSReportingPeriod."No." := LibraryUtility.GenerateGUID();
        IRSReportingPeriod.Validate("Starting Date", 20230101D);
        IRSReportingPeriod.Validate("Ending Date", 20231231D);
        IRSReportingPeriod.Insert();

        Assert.RecordCount(IRSReportingPeriod, 2);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure ReportingPeriodAfterExisting()
    var
        IRSReportingPeriod: Record "IRS Reporting Period";
    begin
        // [SCENARIO 495389] Stan can create a new reporting period after the existing one

        Initialize();
        IRSReportingPeriod."No." := LibraryUtility.GenerateGUID();
        IRSReportingPeriod.Validate("Starting Date", 20240101D);
        IRSReportingPeriod.Validate("Ending Date", 20241231D);
        IRSReportingPeriod.Insert();

        IRSReportingPeriod.Init();
        IRSReportingPeriod."No." := LibraryUtility.GenerateGUID();
        IRSReportingPeriod.Validate("Starting Date", 20250101D);
        IRSReportingPeriod.Validate("Ending Date", 20251231D);
        IRSReportingPeriod.Insert();

        Assert.RecordCount(IRSReportingPeriod, 2);
    end;

    [Test]
    procedure IRSFormsGuideCreatesReportingPeriodOnFinish()
    var
        IRSReportingPeriod: Record "IRS Reporting Period";
        IRS1099Form: Record "IRS 1099 Form";
        IRSFormsGuidePage: TestPage "IRS Forms Guide";
        ReportingYear: Integer;
    begin
        // [SCENARIO 615776] When user specifies the "Init Reporting Year" and finishes the IRS Forms Guide, a reporting period with forms is created

        Initialize();
        ReportingYear := Date2DMY(WorkDate(), 3) + 10;
        // [GIVEN] No reporting period exists for the year
        IRSReportingPeriod.SetRange("No.", Format(ReportingYear));
        IRSReportingPeriod.DeleteAll();

        // [GIVEN] IRS Forms Guide page is opened
        IRSFormsGuidePage.OpenEdit();
        // [GIVEN] User navigates to the Data step
        IRSFormsGuidePage.ActionNext.Invoke();
        // [GIVEN] User sets the Reporting Year to the specified year
        IRSFormsGuidePage.ReportingYearControl.SetValue(ReportingYear);
        // [GIVEN] User navigates to the Features step
        IRSFormsGuidePage.ActionNext.Invoke();
        // [GIVEN] User navigates to the Finish step
        IRSFormsGuidePage.ActionNext.Invoke();
        // [WHEN] User clicks Finish
        IRSFormsGuidePage.ActionFinish.Invoke();

        // [THEN] IRS Reporting Period is created for the specified year
        IRSReportingPeriod.SetRange("No.", Format(ReportingYear));
        Assert.RecordIsNotEmpty(IRSReportingPeriod);
        IRSReportingPeriod.FindFirst();
        Assert.AreEqual(DMY2Date(1, 1, ReportingYear), IRSReportingPeriod."Starting Date", 'Starting Date should be Jan 1');
        Assert.AreEqual(DMY2Date(31, 12, ReportingYear), IRSReportingPeriod."Ending Date", 'Ending Date should be Dec 31');
        // [THEN] IRS 1099 Forms are created for the reporting period
        IRS1099Form.SetRange("Period No.", IRSReportingPeriod."No.");
        Assert.RecordIsNotEmpty(IRS1099Form);
    end;

    trigger OnRun()
    begin
        // [FEATURE] [1099]
    end;

    local procedure Initialize()
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"IRS Reporting Period Tests");
        if IsInitialized then
            exit;
        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"IRS Reporting Period Tests");

        IsInitialized := true;
        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"IRS Reporting Period Tests");
    end;

}
