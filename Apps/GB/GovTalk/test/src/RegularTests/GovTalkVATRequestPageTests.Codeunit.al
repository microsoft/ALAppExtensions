// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.GovTalk;

using Microsoft.Finance.VAT.Reporting;
using System.TestLibraries.Utilities;

codeunit 148001 "GovTalk VAT Request Page Tests"
{
    Subtype = Test;
    TestType = IntegrationTest;
    TestPermissions = Disabled;
#if not CLEAN27
    EventSubscriberInstance = Manual;
#endif

    var
        LibraryERM: Codeunit "Library - ERM";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        LibraryVATReport: Codeunit "Library - VAT Report";
        Assert: Codeunit Assert;
        Selection: Enum "VAT Statement Report Selection";
        PeriodSelection: Enum "VAT Statement Report Period Selection";
        IsInitialized: Boolean;
        WrongVATStatementSetupErr: Label 'VAT statement template %1 name %2 has a wrong setup. There must be nine rows, each with a value between 1 and 9 for the Box No. field.', Comment = '%1 = statement template name, %2 = statement name';

    [Test]
    [HandlerFunctions('SuggestLinesRPH')]
    procedure VATStatementLineCountEqualsNine()
    var
        VATReportHeader: Record "VAT Report Header";
        VATStatementName: Record "VAT Statement Name";
        VATStatementReportLine: Record "VAT Statement Report Line";
    begin
        // [SCENARIO 614191] VAT Report Request Page successfully processes VAT statement with exactly 9 lines
        Initialize();

#if not CLEAN27
        Bindsubscription(this);
#endif
        // [GIVEN] VAT statement template "T" and name "N" with 9 VAT statement lines with Box No. 1-9 and 5 VAT statement lines without Box No.
        CreateVATStatementWithLines(VATStatementName, 9);
        CreateVATReturn(VATReportHeader);
        EnqueueVATStatementValues(VATStatementName);

        // [WHEN] VAT Report Request Page is run for VAT return "R"
        SuggestLines(VATReportHeader);

        // [THEN] VAT return "R" is generated without errors
        VATStatementReportLine.SetRange("VAT Report No.", VATReportHeader."No.");
        VATStatementReportLine.SetRange("VAT Report Config. Code", VATReportHeader."VAT Report Config. Code");
        Assert.RecordCount(VATStatementReportLine, 9);

#if not CLEAN27
        Unbindsubscription(this);
#endif
        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('SuggestLinesRPH')]
    procedure VATStatementLineCountLessThanNine()
    var
        VATReportHeader: Record "VAT Report Header";
        VATStatementName: Record "VAT Statement Name";
    begin
        // [SCENARIO 614191] VAT Report Request Page fails when VAT statement has less than 9 lines and 5 VAT statement lines without Box No.
        Initialize();
#if not CLEAN27
        Bindsubscription(this);
#endif
        // [GIVEN] VAT statement template "T" and name "N" with 8 VAT statement lines with Box No. 1-8
        CreateVATStatementWithLines(VATStatementName, 8);
        CreateVATReturn(VATReportHeader);
        EnqueueVATStatementValues(VATStatementName);

        // [WHEN] VAT Report Request Page is run for VAT return "R"
        asserterror SuggestLines(VATReportHeader);

        // [THEN] Error is thrown indicating wrong VAT statement setup
        Assert.ExpectedError(StrSubstNo(WrongVATStatementSetupErr, VATStatementName."Statement Template Name", VATStatementName.Name));

#if not CLEAN27
        Unbindsubscription(this);
#endif
        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('SuggestLinesRPH')]
    procedure VATStatementLineCountMoreThanNine()
    var
        VATReportHeader: Record "VAT Report Header";
        VATStatementName: Record "VAT Statement Name";
    begin
        // [SCENARIO 614191] VAT Report Request Page fails when VAT statement has more than 9 lines and 5 VAT statement lines without Box No.
        Initialize();
#if not CLEAN27
        Bindsubscription(this);
#endif
        // [GIVEN] VAT statement template "T" and name "N" with 10 VAT statement lines with Box No. 1-10
        CreateVATStatementWithLines(VATStatementName, 10);
        CreateVATReturn(VATReportHeader);
        EnqueueVATStatementValues(VATStatementName);

        // [WHEN] VAT Report Request Page is run for VAT return "R"
        asserterror SuggestLines(VATReportHeader);

        // [THEN] Error is thrown indicating wrong VAT statement setup
        Assert.ExpectedError(StrSubstNo(WrongVATStatementSetupErr, VATStatementName."Statement Template Name", VATStatementName.Name));

#if not CLEAN27
        Unbindsubscription(this);
#endif
        LibraryVariableStorage.AssertEmpty();
    end;

#if not CLEAN27
#pragma warning disable AS0018
    [Test]
    [HandlerFunctions('SuggestLinesRPH')]
    [Obsolete('These tests are not required anymore', '27.0')]
    procedure VATStatementLineCountEqualsNineViaObsoleteEvent()
    var
        VATReportHeader: Record "VAT Report Header";
        VATStatementName: Record "VAT Statement Name";
        VATStatementReportLine: Record "VAT Statement Report Line";
    begin
        // [SCENARIO 614191] VAT Report Request Page successfully processes VAT statement with exactly 9 lines via obsolete event
        Initialize();

        // [GIVEN] VAT statement template "T" and name "N" with 9 VAT statement lines with Box No. 1-9 and 5 VAT statement lines without Box No., GovTalk feature is disabled
        CreateVATStatementWithLines(VATStatementName, 9);
        CreateVATReturn(VATReportHeader);
        EnqueueVATStatementValues(VATStatementName);

        // [WHEN] VAT Report Request Page is run for VAT return "R"
        SuggestLines(VATReportHeader);

        // [THEN] VAT return "R" is generated without errors
        VATStatementReportLine.SetRange("VAT Report No.", VATReportHeader."No.");
        VATStatementReportLine.SetRange("VAT Report Config. Code", VATReportHeader."VAT Report Config. Code");
        Assert.RecordCount(VATStatementReportLine, 9);

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('SuggestLinesRPH')]
    [Obsolete('These tests are not required anymore', '27.0')]
    procedure VATStatementLineCountLessThanNineViaObsoleteEvent()
    var
        VATReportHeader: Record "VAT Report Header";
        VATStatementName: Record "VAT Statement Name";
    begin
        // [SCENARIO 614191] VAT Report Request Page fails when VAT statement has less than 9 lines via obsolete event
        Initialize();

        // [GIVEN] VAT statement template "T" and name "N" with 8 VAT statement lines with Box No. 1-8 and 5 VAT statement lines without Box No., GovTalk feature is disabled
        CreateVATStatementWithLines(VATStatementName, 8);
        CreateVATReturn(VATReportHeader);
        EnqueueVATStatementValues(VATStatementName);

        // [WHEN] VAT Report Request Page is run for VAT return "R"
        asserterror SuggestLines(VATReportHeader);

        // [THEN] Error is thrown indicating wrong VAT statement setup
        Assert.ExpectedError(StrSubstNo(WrongVATStatementSetupErr, VATStatementName."Statement Template Name", VATStatementName.Name));

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('SuggestLinesRPH')]
    [Obsolete('These tests are not required anymore', '27.0')]
    procedure VATStatementLineCountMoreThanNineViaObsoleteEvent()
    var
        VATReportHeader: Record "VAT Report Header";
        VATStatementName: Record "VAT Statement Name";
    begin
        // [SCENARIO 614191] VAT Report Request Page fails when VAT statement has more than 9 lines via obsolete event
        Initialize();

        // [GIVEN] VAT statement template "T" and name "N" with 10 VAT statement lines with Box No. 1-10 and 5 VAT statement lines without Box No., GovTalk feature is disabled
        CreateVATStatementWithLines(VATStatementName, 10);
        CreateVATReturn(VATReportHeader);
        EnqueueVATStatementValues(VATStatementName);

        // [WHEN] VAT Report Request Page is run for VAT return "R"
        asserterror SuggestLines(VATReportHeader);

        // [THEN] Error is thrown indicating wrong VAT statement setup
        Assert.ExpectedError(StrSubstNo(WrongVATStatementSetupErr, VATStatementName."Statement Template Name", VATStatementName.Name));

        LibraryVariableStorage.AssertEmpty();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::GovTalk, OnAfterCheckFeatureEnabled, '', false, false)]
    local procedure OnAfterCheckFeatureEnabled(var IsEnabled: Boolean)
    begin
        IsEnabled := true;
    end;
#pragma warning restore AS0018
#endif

    local procedure Initialize()
    var
        VATStatementTemplate: Record "VAT Statement Template";
        VATStatementLine: Record "VAT Statement Line";
    begin
        VATStatementTemplate.DeleteAll();
        VATStatementLine.DeleteAll();
        if IsInitialized then
            exit;

        SetupVATReportsConfiguration();
        IsInitialized := true;
        Commit();
    end;

    local procedure SetupVATReportsConfiguration()
    var
        VATReportsConfiguration: Record "VAT Reports Configuration";
    begin
        VATReportsConfiguration.SetRange("VAT Report Type", VATReportsConfiguration."VAT Report Type"::"VAT Return");
        VATReportsConfiguration.DeleteAll();
        LibraryVATReport.CreateVATReportConfigurationNo(Codeunit::"VAT Report Suggest Lines", 0, 0, 0, 0);
    end;

    local procedure CreateVATReturn(var VATReportHeader: Record "VAT Report Header")
    begin
        LibraryVATReport.CreateVATReturn(VATReportHeader, Date2DMY(WorkDate(), 3));
    end;

    local procedure CreateVATStatementWithLines(var VATStatementName: Record "VAT Statement Name"; LineCount: Integer)
    var
        VATStatementTemplate: Record "VAT Statement Template";
        VATStatementLine: Record "VAT Statement Line";
        i: Integer;
    begin
        LibraryERM.CreateVATStatementTemplate(VATStatementTemplate);
        LibraryERM.CreateVATStatementName(VATStatementName, VATStatementTemplate.Name);

        for i := 1 to LineCount do begin
            LibraryERM.CreateVATStatementLine(VATStatementLine, VATStatementName."Statement Template Name", VATStatementName.Name);
            VATStatementLine.Validate("Row No.", Format(i));
            VATStatementLine.Validate("Box No.", Format(i));
            VATStatementLine.Modify(true);
        end;
        LineCount += 1;
        for i := LineCount to (LineCount + 5) do begin
            LibraryERM.CreateVATStatementLine(VATStatementLine, VATStatementName."Statement Template Name", VATStatementName.Name);
            VATStatementLine.Validate("Row No.", Format(i));
            VATStatementLine.Validate("Box No.", '');
            VATStatementLine.Modify(true);
        end;
    end;

    local procedure EnqueueVATStatementValues(VATStatementName: Record "VAT Statement Name")
    begin
        LibraryVariableStorage.Enqueue(VATStatementName."Statement Template Name");
        LibraryVariableStorage.Enqueue(VATStatementName.Name);
        LibraryVariableStorage.Enqueue(Selection::Open);
        LibraryVariableStorage.Enqueue(PeriodSelection::"Within Period");
        LibraryVariableStorage.Enqueue(Date2DMY(WorkDate(), 3));
        LibraryVariableStorage.Enqueue(false);
    end;

    local procedure SuggestLines(VATReportHeader: Record "VAT Report Header")
    var
        VATReportMediator: Codeunit "VAT Report Mediator";
    begin
        Commit();
        VATReportMediator.GetLines(VATReportHeader);
    end;

    [RequestPageHandler]
    procedure SuggestLinesRPH(var VATReportRequestPage: TestRequestPage "VAT Report Request Page")
    begin
        VATReportRequestPage.VATStatementTemplate.SetValue(LibraryVariableStorage.DequeueText());
        VATReportRequestPage.VATStatementName.SetValue(LibraryVariableStorage.DequeueText());

        Selection := "VAT Statement Report Selection".FromInteger(LibraryVariableStorage.DequeueInteger());
        VATReportRequestPage.Selection.SetValue(Format(Selection));

        PeriodSelection := "VAT Statement Report Period Selection".FromInteger(LibraryVariableStorage.DequeueInteger());
        VATReportRequestPage.PeriodSelection.SetValue(Format(PeriodSelection));

        VATReportRequestPage."Period Year".SetValue(LibraryVariableStorage.DequeueInteger());
        VATReportRequestPage."Amounts in ACY".SetValue(LibraryVariableStorage.DequeueBoolean());
        VATReportRequestPage.OK().Invoke();
    end;
}
