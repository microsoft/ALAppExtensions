// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
codeunit 149005 "BCPT Line"
{
    Access = Internal;

    var
        BCPTHeader: Record "BCPT Header";
        ScenarioStarted: Dictionary of [Text, DateTime];
        NoOfSQLStatements: Dictionary of [Text, Integer];
        ScenarioNotStartedErr: Label 'Scenario %1 was not started.', Comment = '%1 = codeunit name';
        MaxNoOfSessionsErr: Label 'The total number of sessions must be at most %1. Current attempted value is %2.', Comment = '%1 = Max number of sessions allowed %2 = codeunit name';

    [EventSubscriber(ObjectType::Table, Database::"BCPT Line", 'OnBeforeInsertEvent', '', false, false)]
    local procedure SetNoOfSessionsOnBeforeInsertBCPTLine(var Rec: Record "BCPT Line"; RunTrigger: Boolean)
    var
        BCPTLine: Record "BCPT Line";
    begin
        if Rec.IsTemporary() then
            exit;

        if Rec."Line No." = 0 then begin
            BCPTLine.SetAscending("Line No.", true);
            BCPTLine.SetRange("BCPT Code", Rec."BCPT Code");
            if BCPTLine.FindLast() then;
            Rec."Line No." := BCPTLine."Line No." + 1000;
        end;

        if GetCurrentTotalNoOfSessions(Rec) >= MaxNoOfSessions() then
            Rec."No. of sessions" := 0;
    end;

    [EventSubscriber(ObjectType::Table, Database::"BCPT Line", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure DeleteLogEntriesOnDeleteBCPTLine(var Rec: Record "BCPT Line"; RunTrigger: Boolean)
    var
        BCPTLogEntry: Record "BCPT Log Entry";
    begin
        if Rec.IsTemporary() then
            exit;

        BCPTLogEntry.SetRange("BCPT Code", Rec."BCPT Code");
        BCPTLogEntry.SetRange("BCPT Line No.", Rec."Line No.");
        BCPTLogEntry.DeleteAll(true);
    end;

    [EventSubscriber(ObjectType::Table, Database::"BCPT Line", 'OnBeforeModifyEvent', '', false, false)]
    local procedure CheckNoOfSessionsOnModifyBCPTLine(var Rec: Record "BCPT Line"; var xRec: Record "BCPT Line"; RunTrigger: Boolean)
    var
        NewNoOfSessions: Integer;
    begin
        if Rec.IsTemporary() then
            exit;

        if Rec."No. of Sessions" = xRec."No. of Sessions" then
            exit;

        NewNoOfSessions := GetCurrentTotalNoOfSessions(Rec) + Rec."No. of Sessions" - xRec."No. of Sessions";
        if NewNoOfSessions > MaxNoOfSessions() then
            error(MaxNoOfSessionsErr, MaxNoOfSessions(), NewNoOfSessions);
    end;

    [EventSubscriber(ObjectType::Page, Page::"BCPT Lines", 'OnInsertRecordEvent', '', false, false)]
    local procedure OnInsertRecordEvent(var Rec: Record "BCPT Line"; BelowxRec: Boolean; var xRec: Record "BCPT Line"; var AllowInsert: Boolean)
    begin
        if Rec."BCPT Code" = '' then begin
            AllowInsert := false;
            exit;
        end;

        if Rec."BCPT Code" <> BCPTHeader.Code then
            if BCPTHeader.Get(Rec."BCPT Code") then;
        if Rec."Min. User Delay (ms)" = 0 then
            Rec."Min. User Delay (ms)" := BCPTHeader."Default Min. User Delay (ms)";
        if Rec."Max. User Delay (ms)" = 0 then
            Rec."Max. User Delay (ms)" := BCPTHeader."Default Max. User Delay (ms)";
        if Rec."Delay Type".AsInteger() = 0 then
            Rec."Delay Type" := Rec."Delay Type"::Fixed;
    end;

    local procedure GetCurrentTotalNoOfSessions(var BCPTLine: Record "BCPT Line"): Integer
    var
        BCPTLine2: Record "BCPT Line";
    begin
        BCPTLine2.SetRange("BCPT Code", BCPTLine."BCPT Code");
        BCPTLine2.CalcSums("No. of Sessions");
        exit(BCPTLine2."No. of Sessions");
    end;

    local procedure MaxNoOfSessions(): Integer
    begin
        exit(500);
    end;

    procedure Indent(var BCPTLine: Record "BCPT Line")
    var
        ParentBCPTLine: Record "BCPT Line";
    begin
        if BCPTLine.Indentation > 0 then
            exit;
        ParentBCPTLine := BCPTLine;
        ParentBCPTLine.SetRange(Sequence, BCPTLine.Sequence);
        ParentBCPTLine.SetRange(Indentation, 0);
        if ParentBCPTLine.IsEmpty() then
            exit;
        BCPTLine.Indentation := 1;
        BCPTLine.Modify(true);
    end;

    procedure Outdent(var BCPTLine: Record "BCPT Line")
    begin
        if BCPTLine.Indentation = 0 then
            exit;
        BCPTLine.Indentation := 0;
        BCPTLine.Modify(true);
    end;

    procedure StartScenario(ScenarioOperation: Text)
    var
        OldStartTime: DateTime;
        OldSQLCount: Integer;
    begin
        if ScenarioStarted.Get(ScenarioOperation, OldStartTime) then
            ScenarioStarted.Set(ScenarioOperation, CurrentDateTime())
        else
            ScenarioStarted.Add(ScenarioOperation, CurrentDateTime());
        if NoOfSQLStatements.Get(ScenarioOperation, OldSQLCount) then
            NoOfSQLStatements.Set(ScenarioOperation, SessionInformation.SqlStatementsExecuted)
        else
            NoOfSQLStatements.Add(ScenarioOperation, SessionInformation.SqlStatementsExecuted);
    end;

    procedure EndScenario(BCPTLine: Record "BCPT Line"; ScenarioOperation: Text)
    begin
        EndScenario(BCPTLine, ScenarioOperation, true);
    end;

    procedure EndScenario(BCPTLine: Record "BCPT Line"; ScenarioOperation: Text; ExecutionSuccess: Boolean)
    var
        ErrorMessage: Text;
        NoOfSQL: Integer;
        StartTime: DateTime;
        EndTime: DateTime;
    begin
        EndTime := CurrentDateTime();
        if NoOfSQLStatements.Get(ScenarioOperation, NoOfSQL) then
            NoOfSQL := SessionInformation.SqlStatementsExecuted - NoOfSQL
        else
            ErrorMessage := strsubstno(ScenarioNotStartedErr, ScenarioOperation);
        if not ExecutionSuccess then
            ErrorMessage := CopyStr(GetLastErrorText(), 1, MaxStrLen(ErrorMessage));
        if ScenarioStarted.Get(ScenarioOperation, StartTime) then
            if ScenarioStarted.Remove(ScenarioOperation) then;
        AddLogEntry(BCPTLine, ScenarioOperation, ExecutionSuccess, ErrorMessage, NoOfSQL, StartTime, EndTime);
    end;

    internal procedure AddLogEntry(var BCPTLine: Record "BCPT Line"; Operation: Text; ExecutionSuccess: Boolean; Message: Text; NoOfSQLStatements: Integer; StartTime: DateTime; EndTime: Datetime)
    var
        BCPTLogEntry: Record "BCPT Log Entry";
        BCPTRoleWrapperImpl: Codeunit "BCPT Role Wrapper"; // single instance
    begin
        BCPTLine.Testfield("BCPT Code");
        BCPTRoleWrapperImpl.GetBCPTHeader(BCPTHeader);
        Clear(BCPTLogEntry);
        BCPTLogEntry."BCPT Code" := BCPTLine."BCPT Code";
        BCPTLogEntry."BCPT Line No." := BCPTLine."Line No.";
        BCPTLogEntry.Version := BCPTHeader.Version;
        BCPTLogEntry."Codeunit ID" := BCPTLine."Codeunit ID";
        BCPTLogEntry.Operation := copystr(Operation, 1, MaxStrLen(BCPTLogEntry.Operation));
        BCPTLogEntry.Tag := BCPTRoleWrapperImpl.GetBCPTHeaderTag();
        BCPTLogEntry."Entry No." := 0;
        if ExecutionSuccess then
            BCPTLogEntry.Status := BCPTLogEntry.Status::Success
        else
            BCPTLogEntry.Status := BCPTLogEntry.Status::Error;
        BCPTLogEntry."No. of SQL Statements" := NoOfSQLStatements;
        BCPTLogEntry.Message := copystr(Message, 1, MaxStrLen(BCPTLogEntry.Message));
        BCPTLogEntry."End Time" := EndTime;
        BCPTLogEntry."Start Time" := StartTime;
        BCPTLogEntry."Duration (ms)" := BCPTLogEntry."End Time" - BCPTLogEntry."Start Time";
        if Operation = BCPTRoleWrapperImpl.GetScenarioLbl() then begin
            BCPTLogEntry."Duration (ms)" -= BCPTRoleWrapperImpl.GetAndClearAccumulatedWaitTimeMs();
            BCPTLogEntry."No. of SQL Statements" -= BCPTRoleWrapperImpl.GetAndClearNoOfLogEntriesInserted();
        end;
        BCPTLogEntry.Insert(true);
        Commit();
        AddLogAppInsights(BCPTLogEntry);
        BCPTRoleWrapperImpl.AddToNoOfLogEntriesInserted();
    end;

    local procedure AddLogAppInsights(var BCPTLogEntry: Record "BCPT Log Entry")
    var
        BCPTRoleWrapperImpl: Codeunit "BCPT Role Wrapper"; // single instance
        Dimensions: Dictionary of [Text, Text];
        TelemetryLogLbl: Label 'Performance Toolkit - %1 - %2 - %3', Locked = true;
    begin
        Dimensions.Add('Code', BCPTLogEntry."BCPT Code");
        Dimensions.Add('LineNo', Format(BCPTLogEntry."BCPT Line No."));
        Dimensions.Add('Version', Format(BCPTLogEntry.Version));
        Dimensions.Add('CodeunitId', Format(BCPTLogEntry."Codeunit ID"));
        BCPTLogEntry.CalcFields("Codeunit Name");
        Dimensions.Add('CodeunitName', BCPTLogEntry."Codeunit Name");
        Dimensions.Add('Operation', BCPTLogEntry.Operation);
        Dimensions.Add('Tag', BCPTLogEntry.Tag);
        Dimensions.Add('Status', Format(BCPTLogEntry.Status));
        Dimensions.Add('NoOfSqlStatements', Format(BCPTLogEntry."No. of SQL Statements"));
        Dimensions.Add('StartTime', Format(BCPTLogEntry."Start Time"));
        Dimensions.Add('EndTime', Format(BCPTLogEntry."End Time"));
        Dimensions.Add('Duration', Format(BCPTLogEntry."Duration (ms)"));
        Dimensions.Add('SessionNo', Format(BCPTLogEntry."Session No."));
        Session.LogMessage(
            '0000DGF',
            StrSubstNo(TelemetryLogLbl, BCPTLogEntry."BCPT Code", BCPTRoleWrapperImpl.GetScenarioLbl(), BCPTLogEntry.Status),
            Verbosity::Normal,
            DataClassification::SystemMetadata,
            TelemetryScope::All,
            Dimensions)
    end;

    procedure UserWait(var BCPTLine: Record "BCPT Line")
    var
        BCPTRoleWrapperImpl: Codeunit "BCPT Role Wrapper"; // single instance
        NapTime: Integer;
    begin
        Commit();
        NapTime := BCPTLine."Min. User Delay (ms)" + Random(BCPTLine."Max. User Delay (ms)" - BCPTLine."Min. User Delay (ms)");
        BCPTRoleWrapperImpl.AddToAccumulatedWaitTimeMs(NapTime);
        Sleep(NapTime);
    end;

    procedure GetAvgDuration(BCPTLine: Record "BCPT Line"): Integer
    begin
        if BCPTLine."No. of Iterations" = 0 then
            exit(0);
        exit(BCPTLine."Total Duration (ms)" div BCPTLine."No. of Iterations");
    end;

    procedure GetAvgSQLStmts(BCPTLine: Record "BCPT Line"): Integer
    begin
        if BCPTLine."No. of Iterations" = 0 then
            exit(0);
        exit(BCPTLine."No. of SQL Statements" div BCPTLine."No. of Iterations");
    end;

    Procedure GetParam(var BCPTLine: Record "BCPT Line"; ParamName: Text): Text
    var
        dict: Dictionary of [Text, Text];
    begin
        if ParamName = '' then
            exit('');
        if BCPTLine.Parameters = '' then
            exit('');
        ParameterStringToDictionary(BCPTLine.Parameters, dict);
        if dict.Count = 0 then
            exit('');
        exit(dict.Get(ParamName));
    end;

    procedure ParameterStringToDictionary(Params: Text; var dict: Dictionary of [Text, Text])
    var
        i: Integer;
        p: Integer;
        KeyVal: Text;
        NoOfParams: Integer;
    begin
        clear(dict);
        if Params = '' then
            exit;

        NoOfParams := StrLen(Params) - strlen(DelChr(Params, '=', ',')) + 1;

        for i := 1 to NoOfParams do begin
            if NoOfParams = 1 then
                KeyVal := Params
            else
                KeyVal := SelectStr(i, Params);
            p := StrPos(KeyVal, '=');
            if p > 0 then
                dict.Add(DelChr(CopyStr(KeyVal, 1, p - 1), '<>', ' '), DelChr(CopyStr(KeyVal, p + 1), '<>', ' '))
            else
                dict.Add(DelChr(KeyVal, '<>', ' '), '');
        end;
    end;

    procedure EvaluateParameter(var Parm: Text; var ParmVal: Integer): Boolean
    var
        x: Integer;
    begin
        if not Evaluate(x, Parm) then
            exit(false);
        ParmVal := x;
        Parm := format(ParmVal, 0, 9);
        exit(true);
    end;

    procedure EvaluateDecimal(var Parm: Text; var ParmVal: Decimal): Boolean
    var
        x: Decimal;
    begin
        if not Evaluate(x, Parm) then
            exit(false);
        ParmVal := x;
        Parm := format(ParmVal, 0, 9);
        exit(true);
    end;

    procedure EvaluateDate(var Parm: Text; var ParmVal: Date): Boolean
    var
        x: Date;
    begin
        if not Evaluate(x, Parm) then
            exit(false);
        ParmVal := x;
        Parm := format(ParmVal, 0, 9);
        exit(true);
    end;

    procedure EvaluateFieldValue(var Parm: Text; TableNo: Integer; FieldNo: Integer): Boolean
    var
        Field: Record Field;
        RecRef: RecordRef;
        FldRef: FieldRef;
    begin
        if not Field.Get(TableNo, FieldNo) then
            exit(false);
        if Field.Type <> Field.Type::Option then
            exit(false);
        RecRef.Open(TableNo);
        FldRef := RecRef.Field(FieldNo);
        if not Evaluate(FldRef, Parm) then
            exit(false);
        Parm := format(FldRef.Value, 0, 9);
        exit(true);
    end;
}