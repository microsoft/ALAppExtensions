// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 144741 "BCPT Setup Card Test"
{
    SingleInstance = true;
    Subtype = Test;
    TestPermissions = NonRestrictive;
    EventSubscriberInstance = Manual;

    var
        Assert: Codeunit "Library Assert";
        BCPTTestLibrary: Codeunit "BCPT Test Library";
        NoOfIterationsToRun: Integer;
        CurrNoOfIterations: Integer;
        CancelRun: Boolean;

    [Test]
    procedure BCPTSetupCardDefaultsOnNew()
    var
        BCPTHeader: Record "BCPT Header";
        BCPTSetupCard: TestPage "BCPT Setup Card";
    begin
        Initialize();
        BCPTSetupCard.OpenNew();
        BCPTSetupCard.Code.Value := CopyStr(CreateGuid(), 1, MaxStrLen(BCPTHeader.Code));
        BCPTSetupCard.Description.Value := CopyStr(CreateGuid(), 1, MaxStrLen(BCPTHeader.Description));

        BCPTSetupCard.Tag.AssertEquals('');
        BCPTSetupCard.DurationMin.AssertEquals(1);
        BCPTSetupCard.MinDelay.AssertEquals(100);
        BCPTSetupCard.MaxDelay.AssertEquals(1000);
        BCPTSetupCard.WorkdateStarts.AssertEquals(WorkDate());
        BCPTSetupCard.OneDayCorrespondsTo.AssertEquals(10);
        BCPTSetupCard.Version.AssertEquals(0);
        BCPTSetupCard.Status.AssertEquals(BCPTHeader.Status::" ");
        BCPTSetupCard.Started.AssertEquals('');
        BCPTSetupCard.TotalNoOfSessions.AssertEquals(0);
    end;

    [Test]
    procedure BCPTSetupLinesDefaultsOnNew()
    var
        BCPTHeader: Record "BCPT Header";
        BCPTLine: Record "BCPT Line";
        BCPTSetupCard: TestPage "BCPT Setup Card";
    begin
        Initialize();
        BCPTSetupCard.OpenNew();
        BCPTSetupCard.Code.Value := CopyStr(CreateGuid(), 1, MaxStrLen(BCPTHeader.Code));
        BCPTSetupCard.Description.Value := CopyStr(CreateGuid(), 1, MaxStrLen(BCPTHeader.Description));

        BCPTSetupCard.BCPTLines.CodeunitID.SetValue(Codeunit::"BCPT Empty Codeunit");
        BCPTSetupCard.BCPTLines.Next();
        BCPTSetupCard.BCPTLines.First();

        BCPTSetupCard.BCPTLines.CodeunitID.AssertEquals(Codeunit::"BCPT Empty Codeunit");
        BCPTSetupCard.BCPTLines.NoOfInstances.AssertEquals(1);
        BCPTSetupCard.BCPTLines.RunInForeground.AssertEquals(false);
        BCPTSetupCard.BCPTLines.Description.AssertEquals('');
        BCPTSetupCard.BCPTLines.Status.AssertEquals(BCPTLine.Status::" ");
        BCPTSetupCard.BCPTLines.MinDelay.AssertEquals(BCPTSetupCard.MinDelay.AsInteger());
        BCPTSetupCard.BCPTLines.MaxDelay.AssertEquals(BCPTSetupCard.MaxDelay.AsInteger());
        BCPTSetupCard.BCPTLines.Frequency.AssertEquals(5);
        BCPTSetupCard.BCPTLines.FreqType.AssertEquals(BCPTLine."Delay Type"::Fixed);
        BCPTSetupCard.BCPTLines.NoOfIterations.AssertEquals(0);
        BCPTSetupCard.BCPTLines.Duration.AssertEquals(0);
        BCPTSetupCard.BCPTLines.AvgDuration.AssertEquals(0);
        BCPTSetupCard.BCPTLines.NoOfSQLStmts.AssertEquals(0);
        BCPTSetupCard.BCPTLines.AvgSQLStmts.AssertEquals(0);
    end;

    [Test]
    procedure LogsAreGeneratedAfterTheExecution()
    var
        BCPTHeader: Record "BCPT Header";
        BCPTLogEntry: Record "BCPT Log Entry";
        BCPTSetupCardTest: Codeunit "BCPT Setup Card Test";
        BCPTSetupCard: TestPage "BCPT Setup Card";
        UnexpectedNoOfSqlStmtsLbl: Label 'Unexpected value in %1. Expected %2, Actual %3';
    begin
        Initialize();
        BCPTSetupCard.OpenNew();
        BCPTSetupCard.Code.Value := CopyStr(CreateGuid(), 1, MaxStrLen(BCPTHeader.Code));
        BCPTSetupCard.Description.Value := CopyStr(CreateGuid(), 1, MaxStrLen(BCPTHeader.Description));

        BCPTSetupCard.BCPTLines.CodeunitID.SetValue(Codeunit::"BCPT Empty Codeunit");
        BCPTSetupCard.BCPTLines.RunInForeground.SetValue(true);
        BCPTSetupCard.BCPTLines.Next();
        BCPTSetupCard.BCPTLines.First();

        BCPTHeader.Get(BCPTSetupCard.Code.Value);

        NoOfIterationsToRun := 1;
        UnbindSubscription(BCPTSetupCardTest);
        BindSubscription(BCPTSetupCardTest);
        BCPTSetupCard.Start.Invoke(); //Warmup to ignore extra SQL called just for the first time
        BCPTSetupCard.Start.Invoke();
        UnbindSubscription(BCPTSetupCardTest);

        BCPTHeader.Find();
        BCPTLogEntry.SetRange("BCPT Code", BCPTHeader.Code);
        BCPTLogEntry.SetRange(Version, BCPTHeader.Version);
        Assert.RecordIsNotEmpty(BCPTLogEntry);

        BCPTLogEntry.FindFirst();
        BCPTLogEntry.TestField("Codeunit ID", Codeunit::"BCPT Empty Codeunit");
        BCPTLogEntry.TestField(Message, '');
        // A first run counts 2 sql statements from system tables. So the expected number is either 0 or 2
        if not (BCPTLogEntry."No. of SQL Statements" in [0, 2]) then
            Assert.Fail(StrSubstNo(UnexpectedNoOfSqlStmtsLbl, BCPTLogEntry.FieldCaption("No. of SQL Statements"), '0 or 2', Format(BCPTLogEntry."No. of SQL Statements")));
        BCPTLogEntry.TestField(Operation, 'Scenario');
        BCPTLogEntry.TestField(Status, BCPTLogEntry.Status::Success);
    end;

    [Test]
    procedure NoOfSqlCallsAreLogged()
    var
        BCPTHeader: Record "BCPT Header";
        BCPTLine: Record "BCPT Line";
        BCPTSetupCardTest: Codeunit "BCPT Setup Card Test";
        BCPTStartTests: Codeunit "BCPT Start Tests";
        BCPTSetupCard: TestPage "BCPT Setup Card";
    begin
        Initialize();

        BCPTTestLibrary.AddBCPTSuite(BCPTHeader);
        BCPTTestLibrary.AddBCPTLineToSuite(BCPTLine, BCPTHeader.Code, Codeunit::"BCPT Codeunit With 1 Sql");

        NoOfIterationsToRun := 5;
        BindSubscription(BCPTSetupCardTest);
        BCPTStartTests.StartBCPTSuite(BCPTHeader);
        UnbindSubscription(BCPTSetupCardTest);

        BCPTSetupCard.OpenView();
        BCPTSetupCard.GoToRecord(BCPTHeader);
        BCPTSetupCard.BCPTLines.Status.AssertEquals(BCPTLine.Status::Completed);
        BCPTSetupCard.BCPTLines.NoOfIterations.AssertEquals(NoOfIterationsToRun);
        BCPTSetupCard.BCPTLines.NoOfSQLStmts.AssertEquals(NoOfIterationsToRun);
        BCPTSetupCard.BCPTLines.AvgSQLStmts.AssertEquals(1);
        BCPTSetupCard.Close();
    end;

    [Test]
    procedure ErrorsAreLogged()
    var
        BCPTHeader: Record "BCPT Header";
        BCPTLine: Record "BCPT Line";
        BCPTLogEntry: Record "BCPT Log Entry";
        BCPTStartTests: Codeunit "BCPT Start Tests";
        BCPTSetupCardTest: Codeunit "BCPT Setup Card Test";
    begin
        Initialize();

        BCPTTestLibrary.AddBCPTSuite(BCPTHeader);
        BCPTTestLibrary.AddBCPTLineToSuite(BCPTLine, BCPTHeader.Code, Codeunit::"BCPT Codeunit With Error");

        NoOfIterationsToRun := 1;
        BindSubscription(BCPTSetupCardTest);
        BCPTStartTests.StartBCPTSuite(BCPTHeader);
        UnbindSubscription(BCPTSetupCardTest);

        BCPTHeader.Find();
        BCPTLogEntry.SetRange("BCPT Code", BCPTHeader.Code);
        BCPTLogEntry.SetRange(Version, BCPTHeader.Version);
        Assert.RecordIsNotEmpty(BCPTLogEntry);

        BCPTLogEntry.FindFirst();
        BCPTLogEntry.TestField("Codeunit ID", Codeunit::"BCPT Codeunit With Error");
        BCPTLogEntry.TestField("No. of SQL Statements", 0);
        BCPTLogEntry.TestField(Operation, 'Scenario');
        BCPTLogEntry.TestField(Status, BCPTLogEntry.Status::Error);
        BCPTLogEntry.TestField(Message, 'Throw Error');
    end;

    [Test]
    procedure ExportImportOneBCPTSuite()
    var
        BCPTHeader: Record "BCPT Header";
        CopyOfBCPTHeader: Record "BCPT Header";
        BCPTLine: Record "BCPT Line";
        CopyOfBCPTLine: Record "BCPT Line";
        OutStr: OutStream;
        InStr: InStream;
        BCPTSuiteFile: File;
    begin
        Initialize();

        BCPTTestLibrary.AddBCPTSuite(BCPTHeader);
        BCPTTestLibrary.AddBCPTLineToSuite(BCPTLine, BCPTHeader.Code, Codeunit::"BCPT Codeunit With Error");

        CopyOfBCPTHeader.Copy(BCPTHeader);
        CopyOfBCPTLine.Copy(BCPTLine);

        BCPTSuiteFile.Create(CreateGuid());
        BCPTSuiteFile.CreateOutStream(OutStr);

        Xmlport.Export(Xmlport::"BCPT Import/Export", OutStr, BCPTHeader);

        BCPTHeader.Delete(true);
        Assert.TableIsEmpty(Database::"BCPT Header");
        Assert.TableIsEmpty(Database::"BCPT Line");

        BCPTSuiteFile.CreateInStream(InStr);
        Xmlport.Import(Xmlport::"BCPT Import/Export", InStr);
        Assert.TableIsNotEmpty(Database::"BCPT Header");
        Assert.TableIsNotEmpty(Database::"BCPT Line");

        BCPTHeader.Get(CopyOfBCPTHeader.Code);
        BCPTHeader.TestField(Description, CopyOfBCPTHeader.Description);
        BCPTHeader.TestField("Duration (minutes)", CopyOfBCPTHeader."Duration (minutes)");
        BCPTHeader.TestField("Default Max. User Delay (ms)", CopyOfBCPTHeader."Default Max. User Delay (ms)");
        BCPTHeader.TestField("Default Min. User Delay (ms)", CopyOfBCPTHeader."Default Min. User Delay (ms)");
        BCPTHeader.TestField("1 Day Corresponds to (minutes)", CopyOfBCPTHeader."1 Day Corresponds to (minutes)");

        BCPTLine.Get(CopyOfBCPTLine."BCPT Code", CopyOfBCPTLine."Line No.");
        BCPTLine.TestField("Codeunit ID", CopyOfBCPTLine."Codeunit ID");
        BCPTLine.TestField("Delay (sec. btwn. iter.)", CopyOfBCPTLine."Delay (sec. btwn. iter.)");
        BCPTLine.TestField("Delay Type", CopyOfBCPTLine."Delay Type");
        BCPTLine.TestField(Description, CopyOfBCPTLine.Description);
        BCPTLine.TestField("Max. User Delay (ms)", CopyOfBCPTLine."Max. User Delay (ms)");
        BCPTLine.TestField("Min. User Delay (ms)", CopyOfBCPTLine."Min. User Delay (ms)");
        BCPTLine.TestField("No. of Sessions", CopyOfBCPTLine."No. of Sessions");
    end;

    [Test]
    procedure ExportImportMultipleBCPTSuite()
    var
        BCPTHeader1: Record "BCPT Header";
        CopyOfBCPTHeader1: Record "BCPT Header";
        BCPTLine1: Record "BCPT Line";
        CopyOfBCPTLine1: Record "BCPT Line";
        BCPTHeader2: Record "BCPT Header";
        CopyOfBCPTHeader2: Record "BCPT Header";
        BCPTLine2: Record "BCPT Line";
        CopyOfBCPTLine2: Record "BCPT Line";
        OutStr: OutStream;
        InStr: InStream;
        BCPTSuiteFile: File;
    begin
        Initialize();

        BCPTTestLibrary.AddBCPTSuite(BCPTHeader1);
        BCPTTestLibrary.AddBCPTLineToSuite(BCPTLine1, BCPTHeader1.Code, Codeunit::"BCPT Codeunit With Error");

        BCPTTestLibrary.AddBCPTSuite(BCPTHeader2);
        BCPTTestLibrary.AddBCPTLineToSuite(BCPTLine2, BCPTHeader2.Code, Codeunit::"BCPT Codeunit With Error");

        CopyOfBCPTHeader1.Copy(BCPTHeader1);
        CopyOfBCPTLine1.Copy(BCPTLine1);
        CopyOfBCPTHeader2.Copy(BCPTHeader2);
        CopyOfBCPTLine2.Copy(BCPTLine2);

        BCPTSuiteFile.Create(CreateGuid());
        BCPTSuiteFile.CreateOutStream(OutStr);
        BCPTHeader1.SetFilter(Code, '%1|%2', BCPTHeader1.Code, BCPTHeader2.Code);
        Xmlport.Export(Xmlport::"BCPT Import/Export", OutStr, BCPTHeader1);

        BCPTHeader1.DeleteAll(true);
        Assert.TableIsEmpty(Database::"BCPT Header");
        Assert.TableIsEmpty(Database::"BCPT Line");

        BCPTSuiteFile.CreateInStream(InStr);
        Xmlport.Import(Xmlport::"BCPT Import/Export", InStr);
        Assert.TableIsNotEmpty(Database::"BCPT Header");
        Assert.TableIsNotEmpty(Database::"BCPT Line");

        BCPTHeader1.Get(CopyOfBCPTHeader1.Code);
        BCPTHeader1.TestField(Description, CopyOfBCPTHeader1.Description);
        BCPTHeader1.TestField("Duration (minutes)", CopyOfBCPTHeader1."Duration (minutes)");
        BCPTHeader1.TestField("Default Max. User Delay (ms)", CopyOfBCPTHeader1."Default Max. User Delay (ms)");
        BCPTHeader1.TestField("Default Min. User Delay (ms)", CopyOfBCPTHeader1."Default Min. User Delay (ms)");
        BCPTHeader1.TestField("1 Day Corresponds to (minutes)", CopyOfBCPTHeader1."1 Day Corresponds to (minutes)");

        BCPTLine1.Get(CopyOfBCPTLine1."BCPT Code", CopyOfBCPTLine1."Line No.");
        BCPTLine1.TestField("Codeunit ID", CopyOfBCPTLine1."Codeunit ID");
        BCPTLine1.TestField("Delay (sec. btwn. iter.)", CopyOfBCPTLine1."Delay (sec. btwn. iter.)");
        BCPTLine1.TestField("Delay Type", CopyOfBCPTLine1."Delay Type");
        BCPTLine1.TestField(Description, CopyOfBCPTLine1.Description);
        BCPTLine1.TestField("Max. User Delay (ms)", CopyOfBCPTLine1."Max. User Delay (ms)");
        BCPTLine1.TestField("Min. User Delay (ms)", CopyOfBCPTLine1."Min. User Delay (ms)");
        BCPTLine1.TestField("No. of Sessions", CopyOfBCPTLine1."No. of Sessions");

        BCPTHeader2.Get(CopyOfBCPTHeader2.Code);
        BCPTHeader2.TestField(Description, CopyOfBCPTHeader2.Description);
        BCPTHeader2.TestField("Duration (minutes)", CopyOfBCPTHeader2."Duration (minutes)");
        BCPTHeader2.TestField("Default Max. User Delay (ms)", CopyOfBCPTHeader2."Default Max. User Delay (ms)");
        BCPTHeader2.TestField("Default Min. User Delay (ms)", CopyOfBCPTHeader2."Default Min. User Delay (ms)");
        BCPTHeader2.TestField("1 Day Corresponds to (minutes)", CopyOfBCPTHeader2."1 Day Corresponds to (minutes)");

        BCPTLine2.Get(CopyOfBCPTLine2."BCPT Code", CopyOfBCPTLine2."Line No.");
        BCPTLine2.TestField("Codeunit ID", CopyOfBCPTLine2."Codeunit ID");
        BCPTLine2.TestField("Delay (sec. btwn. iter.)", CopyOfBCPTLine2."Delay (sec. btwn. iter.)");
        BCPTLine2.TestField("Delay Type", CopyOfBCPTLine2."Delay Type");
        BCPTLine2.TestField(Description, CopyOfBCPTLine2.Description);
        BCPTLine2.TestField("Max. User Delay (ms)", CopyOfBCPTLine2."Max. User Delay (ms)");
        BCPTLine2.TestField("Min. User Delay (ms)", CopyOfBCPTLine2."Min. User Delay (ms)");
        BCPTLine2.TestField("No. of Sessions", CopyOfBCPTLine2."No. of Sessions");
    end;

    [Test]
    procedure SuiteCanBeRunInPRTMode()
    var
        BCPTHeader: Record "BCPT Header";
        BCPTLine: Record "BCPT Line";
        BCPTStartTests: Codeunit "BCPT Start Tests";
        BCPTSetupCard: TestPage "BCPT Setup Card";
    begin
        Initialize();

        BCPTTestLibrary.AddBCPTSuite(BCPTHeader);
        BCPTTestLibrary.AddBCPTLineToSuite(BCPTLine, BCPTHeader.Code, Codeunit::"BCPT Codeunit With 1 Sql");

        NoOfIterationsToRun := 5;
        BCPTHeader.CurrentRunType := BCPTHeader.CurrentRunType::PRT;
        BCPTHeader."Duration (minutes)" := 1;
        BCPTHeader.Modify();
        BCPTStartTests.StartBCPTSuite(BCPTHeader);

        BCPTSetupCard.OpenView();
        BCPTSetupCard.GoToRecord(BCPTHeader);
        BCPTSetupCard.BCPTLines.Status.AssertEquals(BCPTLine.Status::Completed);
        BCPTSetupCard.BCPTLines.NoOfIterations.AssertEquals(1);
        BCPTSetupCard.BCPTLines.NoOfSQLStmts.AssertEquals(1);
        BCPTSetupCard.BCPTLines.AvgSQLStmts.AssertEquals(1);
        BCPTSetupCard.Close();
    end;

    [Test]
    procedure SuiteCanBeRunInPRTModeWithRandomDelay()
    var
        BCPTHeader: Record "BCPT Header";
        BCPTLine: Record "BCPT Line";
        BCPTStartTests: Codeunit "BCPT Start Tests";
        BCPTSetupCard: TestPage "BCPT Setup Card";
    begin
        Initialize();

        BCPTTestLibrary.AddBCPTSuite(BCPTHeader);
        BCPTTestLibrary.AddBCPTLineToSuite(BCPTLine, BCPTHeader.Code, Codeunit::"BCPT Codeunit With 1 Sql");
        BCPTLine."Delay Type" := BCPTLine."Delay Type"::Random;

        NoOfIterationsToRun := 5;
        BCPTHeader.CurrentRunType := BCPTHeader.CurrentRunType::PRT;
        BCPTHeader."Duration (minutes)" := 1;
        BCPTHeader.Modify();
        BCPTStartTests.StartBCPTSuite(BCPTHeader);

        BCPTSetupCard.OpenView();
        BCPTSetupCard.GoToRecord(BCPTHeader);
        BCPTSetupCard.BCPTLines.Status.AssertEquals(BCPTLine.Status::Completed);
        BCPTSetupCard.BCPTLines.NoOfIterations.AssertEquals(1);
        BCPTSetupCard.BCPTLines.NoOfSQLStmts.AssertEquals(1);
        BCPTSetupCard.BCPTLines.AvgSQLStmts.AssertEquals(1);
        BCPTSetupCard.Close();
    end;

    [Test]
    procedure PerfRunCanBeCancelled()
    var
        BCPTHeader: Record "BCPT Header";
        BCPTLine: Record "BCPT Line";
        BCPTSetupCardTest: Codeunit "BCPT Setup Card Test";
        BCPTStartTests: Codeunit "BCPT Start Tests";
        BCPTSetupCard: TestPage "BCPT Setup Card";
    begin
        Initialize();

        BCPTTestLibrary.AddBCPTSuite(BCPTHeader);
        BCPTTestLibrary.AddBCPTLineToSuite(BCPTLine, BCPTHeader.Code, Codeunit::"BCPT Codeunit With 1 Sql");

        NoOfIterationsToRun := 5;
        CancelRun := true;
        BindSubscription(BCPTSetupCardTest);
        BCPTStartTests.StartBCPTSuite(BCPTHeader);
        UnbindSubscription(BCPTSetupCardTest);

        BCPTSetupCard.OpenView();
        BCPTSetupCard.GoToRecord(BCPTHeader);
        BCPTSetupCard.BCPTLines.Status.AssertEquals(BCPTLine.Status::Cancelled);
        BCPTSetupCard.BCPTLines.NoOfIterations.AssertEquals(NoOfIterationsToRun);
        BCPTSetupCard.Close();
    end;

    [Test]
    procedure BCPTSetupMaxConcurrentUsers()
    var
        BCPTHeader: Record "BCPT Header";
        BCPTLine: Record "BCPT Line";
        BCPTSetupCard: TestPage "BCPT Setup Card";
        LineCount: Integer;
    begin
        Initialize();
        BCPTSetupCard.OpenNew();
        BCPTSetupCard.Code.Value := CopyStr(CreateGuid(), 1, MaxStrLen(BCPTHeader.Code));
        BCPTSetupCard.Description.Value := CopyStr(CreateGuid(), 1, MaxStrLen(BCPTHeader.Description));
        for LineCount := 1 to 5 do begin
            BCPTSetupCard.BCPTLines.New();
            BCPTSetupCard.BCPTLines.CodeunitID.SetValue(Codeunit::"BCPT Empty Codeunit");
            BCPTSetupCard.BCPTLines.CodeunitID.AssertEquals(Codeunit::"BCPT Empty Codeunit");
            BCPTSetupCard.BCPTLines.NoOfInstances.SetValue(100);
            BCPTSetupCard.BCPTLines.NoOfInstances.AssertEquals(100);
            BCPTSetupCard.BCPTLines.RunInForeground.AssertEquals(false);
            BCPTSetupCard.BCPTLines.Description.AssertEquals('');
            BCPTSetupCard.BCPTLines.Status.AssertEquals(BCPTLine.Status::" ");
            BCPTSetupCard.BCPTLines.MinDelay.AssertEquals(BCPTSetupCard.MinDelay.AsInteger());
            BCPTSetupCard.BCPTLines.MaxDelay.AssertEquals(BCPTSetupCard.MaxDelay.AsInteger());
            BCPTSetupCard.BCPTLines.Frequency.AssertEquals(5);
            BCPTSetupCard.BCPTLines.FreqType.AssertEquals(BCPTLine."Delay Type"::Fixed);
            BCPTSetupCard.BCPTLines.NoOfIterations.AssertEquals(0);
            BCPTSetupCard.BCPTLines.Duration.AssertEquals(0);
            BCPTSetupCard.BCPTLines.AvgDuration.AssertEquals(0);
            BCPTSetupCard.BCPTLines.NoOfSQLStmts.AssertEquals(0);
            BCPTSetupCard.BCPTLines.AvgSQLStmts.AssertEquals(0);
            BCPTSetupCard.RefreshStatus.Invoke();
            BCPTSetupCard.TotalNoOfSessions.AssertEquals(LineCount * 100);
        end;
        BCPTSetupCard.BCPTLines.New();
        BCPTSetupCard.BCPTLines.CodeunitID.SetValue(Codeunit::"BCPT Empty Codeunit");
        BCPTSetupCard.BCPTLines.CodeunitID.AssertEquals(Codeunit::"BCPT Empty Codeunit");
        BCPTSetupCard.BCPTLines.NoOfInstances.SetValue(100);
        BCPTSetupCard.BCPTLines.NoOfInstances.AssertEquals(100);
        BCPTSetupCard.BCPTLines.RunInForeground.AssertEquals(false);
        BCPTSetupCard.BCPTLines.Description.AssertEquals('');
        BCPTSetupCard.BCPTLines.Status.AssertEquals(BCPTLine.Status::" ");
        BCPTSetupCard.BCPTLines.MinDelay.AssertEquals(BCPTSetupCard.MinDelay.AsInteger());
        BCPTSetupCard.BCPTLines.MaxDelay.AssertEquals(BCPTSetupCard.MaxDelay.AsInteger());
        BCPTSetupCard.BCPTLines.Frequency.AssertEquals(5);
        BCPTSetupCard.BCPTLines.FreqType.AssertEquals(BCPTLine."Delay Type"::Fixed);
        BCPTSetupCard.BCPTLines.NoOfIterations.AssertEquals(0);
        BCPTSetupCard.BCPTLines.Duration.AssertEquals(0);
        BCPTSetupCard.BCPTLines.AvgDuration.AssertEquals(0);
        BCPTSetupCard.BCPTLines.NoOfSQLStmts.AssertEquals(0);
        BCPTSetupCard.BCPTLines.AvgSQLStmts.AssertEquals(0);
        BCPTSetupCard.RefreshStatus.Invoke();
        Assert.ExpectedError('The total number of sessions must be at most 500. Current attempted value is 600.');
    end;

    local procedure Initialize()
    var
        BCPTHeader: Record "BCPT Header";
        BCPTLine: Record "BCPT Line";
        BCPTLogEntry: Record "BCPT Log Entry";
        BCPTSetupCardTest: Codeunit "BCPT Setup Card Test";
    begin
        NoOfIterationsToRun := 0;
        CurrNoOfIterations := 0;
        CancelRun := false;
        BCPTLogEntry.DeleteAll();
        BCPTLine.DeleteAll();
        BCPTHeader.DeleteAll();
        UnbindSubscription(BCPTSetupCardTest);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"BCPT Role Wrapper", 'OnBeforeExecuteIteration', '', false, false)]
    local procedure SetExitExecutionOnBeforeExecuteIteration(var BCPTHeader: Record "BCPT Header"; var BCPTLine: Record "BCPT Line"; var SkipDelay: Boolean)
    var
        BCPTHeaderCU: Codeunit "BCPT Header";
    begin
        SkipDelay := true;

        if CurrNoOfIterations >= (NoOfIterationsToRun - 1) then
            if CancelRun then begin
                //BCPTHeader.Status := BCPTHeader.Status::Cancelled;
                BCPTHeaderCU.SetRunStatus(BCPTHeader, BCPTHeader.Status::Cancelled);
                //BCPTHeader.
                //BCPTHeader.Modify();
                Commit();
            end else
                BCPTHeader."Started at" := BCPTHeader."Started at" - 60000 * BCPTHeader."Duration (minutes)";
        CurrNoOfIterations += 1;
    end;
}