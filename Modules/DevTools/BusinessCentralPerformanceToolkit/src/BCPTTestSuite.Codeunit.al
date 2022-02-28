// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 149006 "BCPT Test Suite"
{
    var
        TestSuiteAlreadyExistsErr: Label 'Test suite with %1 %2 already exists.', Comment = '%1 - field caption, %2 - field value';
        TestSuiteNotFoundErr: Label 'Test suite with %1 %2 does not exist.', Comment = '%1 - field caption, %2 - field value';
        TestSuiteLineNotFoundErr: Label 'Test suite line with %1 %2 and %3 %4 does not exist.', Comment = '%1 - field caption, %2 - field value, %3 - field caption, %4 - field value';

    procedure CreateTestSuiteHeader(SuiteCode: Code[10]; SuiteDescription: Text[50]; DurationInMinutes: Integer;
                              DefaultMinUserDelayInMs: Integer; DefaultMaxUserDelayInMs: Integer;
                              OneDayCorrespondsToMinutes: Integer; Tag: Text[20])
    var
        BCPTHeader: Record "BCPT Header";
    begin
        if BCPTHeader.Get(SuiteCode) then
            Error(TestSuiteAlreadyExistsErr, BCPTHeader.FieldCaption(Code), SuiteCode);

        Clear(BCPTHeader);
        BCPTHeader.Code := SuiteCode;
        BCPTHeader.Description := SuiteDescription;

        if DurationInMinutes <> 0 then
            BCPTHeader."Duration (minutes)" := DurationInMinutes;

        if DefaultMinUserDelayInMs <> 0 then
            BCPTHeader."Default Min. User Delay (ms)" := DefaultMinUserDelayInMs;

        if DefaultMaxUserDelayInMs <> 0 then
            BCPTHeader."Default Max. User Delay (ms)" := DefaultMaxUserDelayInMs;

        if OneDayCorrespondsToMinutes <> 0 then
            BCPTHeader."1 Day Corresponds to (minutes)" := OneDayCorrespondsToMinutes;

        BCPTHeader.Tag := Tag;
        BCPTHeader.Insert(true);
    end;

    procedure CreateTestSuiteHeader(SuiteCode: Code[10]; SuiteDescription: Text[50])
    var
        BCPTHeader: Record "BCPT Header";
    begin
        if BCPTHeader.Get(SuiteCode) then
            Error(TestSuiteAlreadyExistsErr, BCPTHeader.FieldCaption(Code), SuiteCode);

        Clear(BCPTHeader);
        BCPTHeader.Code := SuiteCode;
        BCPTHeader.Description := SuiteDescription;
        BCPTHeader.Insert(true);
    end;

    procedure SetTestSuiteDuration(SuiteCode: Code[10]; DurationInMinutes: Integer)
    var
        BCPTHeader: Record "BCPT Header";
    begin
        if BCPTHeader.Get(SuiteCode) then
            Error(TestSuiteNotFoundErr, BCPTHeader.FieldCaption(Code), SuiteCode);

        BCPTHeader."Duration (minutes)" := DurationInMinutes;
        BCPTHeader.Modify(true);
    end;

    procedure SetTestSuiteDefaultMinUserDelay(SuiteCode: Code[10]; DelayInMs: Integer)
    var
        BCPTHeader: Record "BCPT Header";
    begin
        if BCPTHeader.Get(SuiteCode) then
            Error(TestSuiteNotFoundErr, BCPTHeader.FieldCaption(Code), SuiteCode);

        BCPTHeader."Default Min. User Delay (ms)" := DelayInMs;
        BCPTHeader.Modify(true);
    end;

    procedure SetTestSuiteDefaultMaxUserDelay(SuiteCode: Code[10]; DelayInMs: Integer)
    var
        BCPTHeader: Record "BCPT Header";
    begin
        if BCPTHeader.Get(SuiteCode) then
            Error(TestSuiteNotFoundErr, BCPTHeader.FieldCaption(Code), SuiteCode);

        BCPTHeader."Default Max. User Delay (ms)" := DelayInMs;
        BCPTHeader.Modify(true);
    end;

    procedure SetTestSuite1DayCorresponds(SuiteCode: Code[10]; DurationInMinutes: Integer)
    var
        BCPTHeader: Record "BCPT Header";
    begin
        if BCPTHeader.Get(SuiteCode) then
            Error(TestSuiteNotFoundErr, BCPTHeader.FieldCaption(Code), SuiteCode);

        BCPTHeader."1 Day Corresponds to (minutes)" := DurationInMinutes;
        BCPTHeader.Modify(true);
    end;

    procedure SetTestSuiteTag(SuiteCode: Code[10]; Tag: Text[20])
    var
        BCPTHeader: Record "BCPT Header";
    begin
        if BCPTHeader.Get(SuiteCode) then
            Error(TestSuiteNotFoundErr, BCPTHeader.FieldCaption(Code), SuiteCode);

        BCPTHeader.Tag := Tag;
        BCPTHeader.Modify(true);
    end;

    procedure AddLineToTestSuiteHeader(SuiteCode: Code[10]; CodeunitId: Integer; NoOfSessions: Integer; Description: Text[50];
                                   MinUserDelayInMs: Integer; MaxUserDelayInMs: Integer; DelayBtwnIterInSecs: Integer; RunInForeground: Boolean;
                                   Parameters: Text[1000]): Integer
    var
        DelayType: Enum "BCPT Line Delay Type";
    begin
        exit(AddLineToTestSuiteHeader(SuiteCode, CodeunitId, NoOfSessions, Description, MinUserDelayInMs, MaxUserDelayInMs, DelayBtwnIterInSecs, RunInForeground, Parameters, DelayType::Fixed));
    end;

    procedure AddLineToTestSuiteHeader(SuiteCode: Code[10]; CodeunitId: Integer): Integer
    var
        BCPTHeader: Record "BCPT Header";
        BCPTLine: Record "BCPT Line";
        LastBCPTLine: Record "BCPT Line";

    begin
        if not BCPTHeader.Get(SuiteCode) then
            Error(TestSuiteNotFoundErr, BCPTHeader.FieldCaption(Code), SuiteCode);

        LastBCPTLine.SetRange("BCPT Code", SuiteCode);
        if LastBCPTLine.FindLast() then;
        Clear(BCPTLine);
        BCPTLine."BCPT Code" := SuiteCode;
        BCPTLine."Line No." := LastBCPTLine."Line No." + 1000;
        BCPTLine."Codeunit ID" := CodeunitId;
        BCPTLine.Insert(true);

        exit(BCPTLine."Line No.");
    end;

    procedure AddLineToTestSuiteHeader(SuiteCode: Code[10]; CodeunitId: Integer; NoOfSessions: Integer; Description: Text[50];
                               MinUserDelayInMs: Integer; MaxUserDelayInMs: Integer; DelayBtwnIterInSecs: Integer; RunInForeground: Boolean;
                               Parameters: Text[1000]; DelayType: Enum "BCPT Line Delay Type"): Integer
    var
        BCPTHeader: Record "BCPT Header";
        BCPTLine: Record "BCPT Line";
        LastBCPTLine: Record "BCPT Line";
    begin
        if not BCPTHeader.Get(SuiteCode) then
            Error(TestSuiteNotFoundErr, BCPTHeader.FieldCaption(Code), SuiteCode);


        LastBCPTLine.SetRange("BCPT Code", SuiteCode);
        if LastBCPTLine.FindLast() then;
        Clear(BCPTLine);
        BCPTLine."BCPT Code" := SuiteCode;
        BCPTLine."Line No." := LastBCPTLine."Line No." + 1000;
        BCPTLine."Codeunit ID" := CodeunitId;

        if NoOfSessions <> 0 then
            BCPTLine."No. of Sessions" := NoOfSessions;

        BCPTLine.Description := Description;

        if MinUserDelayInMs <> 0 then
            BCPTLine."Min. User Delay (ms)" := MinUserDelayInMs
        else
            BCPTLine."Min. User Delay (ms)" := BCPTHeader."Default Min. User Delay (ms)";

        if MaxUserDelayInMs <> 0 then
            BCPTLine."Max. User Delay (ms)" := MaxUserDelayInMs
        else
            BCPTLine."Max. User Delay (ms)" := BCPTHeader."Default Max. User Delay (ms)";

        if DelayBtwnIterInSecs <> 0 then
            BCPTLine."Delay (sec. btwn. iter.)" := DelayBtwnIterInSecs;

        BCPTLine."Run in Foreground" := RunInForeground;

        BCPTLine.Parameters := Parameters;

        BCPTLine."Delay Type" := DelayType;

        BCPTLine.Insert(true);

        exit(BCPTLine."Line No.");
    end;

    procedure SetTestSuiteLineNoOfSessions(SuiteCode: Code[10]; LineNo: Integer; NoOfSessions: Integer)
    var
        BCPTLine: Record "BCPT Line";
    begin
        if not BCPTLine.Get(SuiteCode, LineNo) then
            Error(TestSuiteLineNotFoundErr, BCPTLine.FieldCaption("BCPT Code"), SuiteCode, BCPTLine.FieldCaption("Line No."), LineNo);

        BCPTLine."No. of Sessions" := NoOfSessions;
        BCPTLine.Modify(true);
    end;

    procedure SetTestSuiteLineDescription(SuiteCode: Code[10]; LineNo: Integer; Description: Text[50])
    var
        BCPTLine: Record "BCPT Line";
    begin
        if not BCPTLine.Get(SuiteCode, LineNo) then
            Error(TestSuiteLineNotFoundErr, BCPTLine.FieldCaption("BCPT Code"), SuiteCode, BCPTLine.FieldCaption("Line No."), LineNo);

        BCPTLine.Description := Description;
        BCPTLine.Modify(true);
    end;

    procedure SetTestSuiteLineMinUserDelay(SuiteCode: Code[10]; LineNo: Integer; DelayInMs: Integer)
    var
        BCPTLine: Record "BCPT Line";
    begin
        if not BCPTLine.Get(SuiteCode, LineNo) then
            Error(TestSuiteLineNotFoundErr, BCPTLine.FieldCaption("BCPT Code"), SuiteCode, BCPTLine.FieldCaption("Line No."), LineNo);

        BCPTLine."Min. User Delay (ms)" := DelayInMs;
        BCPTLine.Modify(true);
    end;

    procedure SetTestSuiteLineMaxUserDelay(SuiteCode: Code[10]; LineNo: Integer; DelayInMs: Integer)
    var
        BCPTLine: Record "BCPT Line";
    begin
        if not BCPTLine.Get(SuiteCode, LineNo) then
            Error(TestSuiteLineNotFoundErr, BCPTLine.FieldCaption("BCPT Code"), SuiteCode, BCPTLine.FieldCaption("Line No."), LineNo);

        BCPTLine."Max. User Delay (ms)" := DelayInMs;
        BCPTLine.Modify(true);
    end;

    procedure SetTestSuiteLineDelayBtwnIter(SuiteCode: Code[10]; LineNo: Integer; DelayInSecs: Integer)
    var
        BCPTLine: Record "BCPT Line";
    begin
        if not BCPTLine.Get(SuiteCode, LineNo) then
            Error(TestSuiteLineNotFoundErr, BCPTLine.FieldCaption("BCPT Code"), SuiteCode, BCPTLine.FieldCaption("Line No."), LineNo);

        BCPTLine."Delay (sec. btwn. iter.)" := DelayInSecs;
        BCPTLine.Modify(true);
    end;

    procedure SetTestSuiteLineRunInForeground(SuiteCode: Code[10]; LineNo: Integer; RunInForeground: Boolean)
    var
        BCPTLine: Record "BCPT Line";
    begin
        if not BCPTLine.Get(SuiteCode, LineNo) then
            Error(TestSuiteLineNotFoundErr, BCPTLine.FieldCaption("BCPT Code"), SuiteCode, BCPTLine.FieldCaption("Line No."), LineNo);

        BCPTLine."Run in Foreground" := RunInForeground;
        BCPTLine.Modify(true);
    end;

    procedure SetTestSuiteLineParameters(SuiteCode: Code[10]; LineNo: Integer; Parameters: Text[1000])
    var
        BCPTLine: Record "BCPT Line";
    begin
        if not BCPTLine.Get(SuiteCode, LineNo) then
            Error(TestSuiteLineNotFoundErr, BCPTLine.FieldCaption("BCPT Code"), SuiteCode, BCPTLine.FieldCaption("Line No."), LineNo);

        BCPTLine.Parameters := Parameters;
        BCPTLine.Modify(true);
    end;

    procedure IsAnyTestRunInProgress(): Boolean
    var
        BCPTHeader2: Record "BCPT Header";
    begin
        BCPTHeader2.SetRange(Status, BCPTHeader2.Status::Running);
        exit(not BCPTHeader2.IsEmpty());
    end;

    procedure IsTestRunInProgress(SuiteCode: Code[10]): Boolean
    var
        BCPTHeader2: Record "BCPT Header";
    begin
        BCPTHeader2.SetRange(Code, SuiteCode);
        BCPTHeader2.SetRange(Status, BCPTHeader2.Status::Running);
        exit(not BCPTHeader2.IsEmpty());
    end;

}