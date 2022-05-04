// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
codeunit 149002 "BCPT Role Wrapper"
{
    TableNo = "BCPT Line";
    SingleInstance = true;
    Access = Internal;

    var
        GlobalBCPTLine: Record "BCPT Line";
        GlobalBCPTHeader: Record "BCPT Header";
        BCPTHeader: Record "BCPT Header";
        NoOfInsertedLogEntries: Integer;
        AccumulatedWaitTimeMs: Integer;
        WasSuccess: Boolean;
        ScenarioLbl: Label 'Scenario';

    trigger OnRun();
    var
        PoissonLimit: Integer;
        StartTime: DateTime;
        CurrentWorkDate: Date;
    begin
        if Rec."Codeunit ID" = 0 then
            exit;
        SetBCPTLine(Rec);

        NoOfInsertedLogEntries := 0;
        AccumulatedWaitTimeMs := 0;
        PoissonLimit := 0;
        InitializeBCPTLineForRun(Rec, BCPTHeader, PoissonLimit);
        SetBCPTHeader(BCPTHeader);

        StartTime := BCPTHeader."Started at";
        CurrentWorkDate := BCPTHeader."Work date starts at";

        ExecuteBCPTLine(Rec, BCPTHeader, StartTime, CurrentWorkDate, PoissonLimit);
    end;

    local procedure InitializeBCPTLineForRun(var BCPTLine: Record "BCPT Line"; var BCPTHeader: Record "BCPT Header"; PoissonLimit: Integer)
    begin
        BCPTHeader.Get(BCPTLine."BCPT Code");
        if BCPTHeader."Started at" < CurrentDateTime() then
            BCPTHeader."Started at" := CurrentDateTime();
        if BCPTHeader."Work date starts at" = 0D then
            BCPTHeader."Work date starts at" := Today;

        if BCPTLine."Delay Type" = BCPTLine."Delay Type"::Random then
            if BCPTLine."Delay (sec. btwn. iter.)" = 0 then
                PoissonLimit := 0
            else // This was based on heuristics and does not behave as a true Poisson process, but only a rough approximation.
                PoissonLimit := 1000000 - 1000000 div BCPTLine."Delay (sec. btwn. iter.)";
    end;

    local procedure ExecuteBCPTLine(var BCPTLine: Record "BCPT Line"; var BCPTHeader: Record "BCPT Header"; StartTime: DateTime; CurrentWorkDate: Date; PoissonLimit: Integer)
    var
        BCPTLineCU: Codeunit "BCPT Line";
        BCPTHeaderCU: Codeunit "BCPT Header";
        BCPTRunType: Enum "BCPT Run Type";
        DoRun: Boolean;
        ExecutionSuccess: Boolean;
        ExecuteNextIteration: Boolean;
        SkipDelay: Boolean;
    begin
        DoRun := (BCPTLine."Delay Type" = BCPTLine."Delay Type"::Fixed) or (BCPTHeader.CurrentRunType = BCPTHeader.CurrentRunType::PRT);
        Randomize();
        ExecuteNextIteration := true;

        repeat
            if DoRun then begin
                // set workdate
                if BCPTHeader."1 Day Corresponds to (minutes)" > 0 then
                    if CurrentDateTime() > StartTime + 60000 * BCPTHeader."1 Day Corresponds to (minutes)" then begin
                        CurrentWorkDate += 1;
                        StartTime := CurrentDateTime();
                    end;
                WorkDate(CurrentWorkDate);

                GetAndClearAccumulatedWaitTimeMs();
                GetAndClearNoOfLogEntriesInserted();

                BCPTLineCU.StartScenario(ScenarioLbl);
                OnBeforeExecuteIteration(BCPTHeader, BCPTLine, SkipDelay);
                ExecutionSuccess := ExecuteIteration(BCPTLine);
                Commit();
                BCPTLineCU.EndScenario(BCPTLine, ScenarioLbl, ExecutionSuccess);
                Commit();
            end;

            ExecuteNextIteration := (CurrentDateTime() <= BCPTHeader."Started at" + (60000 * BCPTHeader."Duration (minutes)")) and (BCPTHeader.CurrentRunType = BCPTRunType::BCPT);
            if ExecuteNextIteration then begin
                BCPTHeader.Find();
                if BCPTHeader.Status = BCPTHeader.Status::Cancelled then
                    ExecuteNextIteration := false;
            end;

            if ExecuteNextIteration and (not SkipDelay) then begin
                if BCPTLine."Run in Foreground" then // rotate between foreground scenarios in this thread
                    if BCPTLine.Next() = 0 then
                        if BCPTLine.FindSet() then;
                // Wait for next run
                case BCPTLine."Delay Type" of
                    BCPTLine."Delay Type"::Fixed:
                        Sleep(1000 * BCPTLine."Delay (sec. btwn. iter.)");
                    BCPTLine."Delay Type"::Random:
                        begin
                            Sleep(1000);
                            DoRun := Random(1050000) > PoissonLimit;
                        end;
                end;
            end else
                if BCPTLine."Run in Foreground" and (BCPTHeader.CurrentRunType = BCPTRunType::PRT) then
                    ExecuteNextIteration := BCPTLine.Next() <> 0;
        until (ExecuteNextIteration = false);
        BCPTHeaderCU.DecreaseNoOfTestsRunningNow(BCPTHeader);
    end;

    local procedure ExecuteIteration(var BCPTLine: Record "BCPT Line"): boolean
    var
        TestMethodLine: Record "Test Method Line";
        TestRunnerIsolDisabled: Codeunit "Test Runner - Isol. Disabled";
    begin
        SetBCPTLine(BCPTLine);
        TestMethodLine."Line Type" := TestMethodLine."Line Type"::Codeunit;
        TestMethodLine."Skip Logging Results" := true;
        TestMethodLine."Test Codeunit" := BCPTLine."Codeunit ID";
        WasSuccess := true; // init in case the event subscriber is not called
        exit(TestRunnerIsolDisabled.Run(TestMethodLine) and WasSuccess);  // WasSuccess is set in an eventsubscriber
    end;

    internal procedure GetScenarioLbl(): Text[100]
    begin
        exit(ScenarioLbl);
    end;

    internal procedure GetBCPTHeaderTag(): Text[20]
    begin
        exit(BCPTHeader.Tag);
    end;

    /// <summary>
    /// Sets the BCPT Line so that the test codeunits can retrieve.
    /// </summary>
    local procedure SetBCPTLine(var BCPTLine: Record "BCPT Line")
    begin
        GlobalBCPTLine := BCPTLine;
    end;

    /// <summary>
    /// Gets the BCPT Line stored through the SetBCPTLine method.
    /// </summary>
    internal procedure GetBCPTLine(var BCPTLine: Record "BCPT Line")
    begin
        BCPTLine := GlobalBCPTLine;
    end;

    local procedure SetBCPTHeader(var CurrBCPTHeader: Record "BCPT Header")
    begin
        GlobalBCPTHeader := CurrBCPTHeader;
    end;

    internal procedure GetBCPTHeader(var CurrBCPTHeader: Record "BCPT Header")
    begin
        CurrBCPTHeader := GlobalBCPTHeader;
    end;

    internal procedure AddToNoOfLogEntriesInserted()
    begin
        NoOfInsertedLogEntries += 1;
    end;

    internal procedure GetNoOfLogEntriesInserted(): Integer
    var
        ReturnValue: Integer;
    begin
        ReturnValue := NoOfInsertedLogEntries;
        exit(ReturnValue);
    end;

    internal procedure GetAndClearNoOfLogEntriesInserted(): Integer
    var
        ReturnValue: Integer;
    begin
        ReturnValue := NoOfInsertedLogEntries;
        NoOfInsertedLogEntries := 0;
        exit(ReturnValue);
    end;

    internal procedure AddToAccumulatedWaitTimeMs(ms: Integer)
    begin
        AccumulatedWaitTimeMs += ms;
    end;

    internal procedure GetAndClearAccumulatedWaitTimeMs(): Integer
    var
        ReturnValue: Integer;
    begin
        ReturnValue := AccumulatedWaitTimeMs;
        AccumulatedWaitTimeMs := 0;
        exit(ReturnValue);
    end;

    [InternalEvent(false)]
    procedure OnBeforeExecuteIteration(var BCPTHeader: Record "BCPT Header"; var BCPTLine: Record "BCPT Line"; var SkipDelay: Boolean)
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Test Runner - Mgt", 'OnAfterTestMethodRun', '', false, false)]
    local procedure OnAfterTestMethodRun(var CurrentTestMethodLine: Record "Test Method Line"; CodeunitID: Integer; CodeunitName: Text[30]; FunctionName: Text[128]; FunctionTestPermissions: TestPermissions; IsSuccess: Boolean)
    begin
        WasSuccess := IsSuccess;
    end;
}