codeunit 2413 "XS Job Queue Management"
{
    procedure CheckifJobQueueEntryExists(): Boolean;
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"Sync Job");
        JobQueueEntry.SetFilter(Status, '%1|%2|%3', JobQueueEntry.Status::Ready, JobQueueEntry.Status::"In Process", JobQueueEntry.Status::Error);
        exit(JobQueueEntry.FindFirst());
    end;

    procedure RestartJobQueueIfStatusError() // TODO: temporary - because access key can't be renewed automatically
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"Sync Job");
        JobQueueEntry.SetFilter(Status, '%1', JobQueueEntry.Status::Error);
        if JobQueueEntry.FindFirst() then
            JobQueueEntry.Restart();
    end;

    procedure CreateJobQueueEntry()
    var
        JobQueueEntry: Record "Job Queue Entry";
        SyncSetup: Record "Sync Setup";
        DummyRecordId: RecordId;
        StartNewSession: Boolean;
    begin
        StartNewSession := true;
        OnBeforeStartNewSession(StartNewSession);
        SyncSetup.GetSingleInstance();
        if SyncSetup."XS In Test Mode" then
            exit;
        if StartNewSession then begin
            JobQueueEntry.ScheduleJobQueueEntry(Codeunit::"Sync Job", DummyRecordId);
            JobQueueEntry.Validate("No. of Minutes between Runs", 5);
            SetJobQueueEntryToBeRecurring(JobQueueEntry);
            JobQueueEntry.Modify(true);
            OnScheduledJobQueueEntry();
        end else
            Codeunit.Run(Codeunit::"Sync Job");
    end;

    local procedure SetJobQueueEntryToBeRecurring(var JobQueueEntry: Record "Job Queue Entry")
    begin
        JobQueueEntry.Validate("Run on Mondays", true);
        JobQueueEntry.Validate("Run on Tuesdays", true);
        JobQueueEntry.Validate("Run on Wednesdays", true);
        JobQueueEntry.Validate("Run on Thursdays", true);
        JobQueueEntry.Validate("Run on Fridays", true);
        JobQueueEntry.Validate("Run on Saturdays", true);
        JobQueueEntry.Validate("Run on Sundays", true);
    end;

    procedure CreateJobQueueEntryLogForUnsuccessfulSync(var JobQueueEntry: Record "Job Queue Entry"; ErrorMessage: Text)
    var
        JobQueueLogEntry: Record "Job Queue Log Entry";
    begin
        JobQueueLogEntry.Insert(true);
        JobQueueEntry.InsertLogEntry(JobQueueLogEntry);
        JobQueueLogEntry.Validate("Start Date/Time", CurrentDateTime());
        JobQueueLogEntry.Validate("Error Message", ErrorMessage);
        JobQueueLogEntry.Validate(Status, JobQueueLogEntry.Status::Error);
        JobQueueLogEntry.Modify(true);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeStartNewSession(var StartNewSession: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnScheduledJobQueueEntry()
    begin
    end;

    procedure RemoveScheduledJobTask()
    var
        JobQueueEntry: Record "Job Queue Entry";
        JobQueueManagement: Codeunit "Job Queue Management";
    begin
        JobQueueManagement.DeleteJobQueueEntries(JobQueueEntry."Object Type to Run"::Codeunit, Codeunit::"Sync Job");
    end;

    procedure GetJobQueueStatus(): Text
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"Sync Job");
        if JobQueueEntry.FindFirst() then
            exit(Format(JobQueueEntry.Status));
    end;

    procedure SetFiltersOnJobQueueLogEntry(var JobQueueLogEntry: Record "Job Queue Log Entry")
    begin
        JobQueueLogEntry.SetRange("Object Type to Run", JobQueueLogEntry."Object Type to Run"::Codeunit);
        JobQueueLogEntry.SetRange("Object ID to Run", Codeunit::"Sync Job");
    end;

    procedure RemoveScheduledJobTaskIfUserInactive() JobDeleted: Boolean
    var
        JobQueueEntry: Record "Job Queue Entry";
        JobQueueManagement: Codeunit "Job Queue Management";
        UserLoginTimeTracker : Codeunit "User Login Time Tracker";
        FromDate : Date;
    begin
        FromDate := CalcDate('<-2W>');

        if not UserLoginTimeTracker.AnyUserLoggedInSinceDate(FromDate) then begin
            JobQueueManagement.DeleteJobQueueEntries(JobQueueEntry."Object Type to Run"::Codeunit, Codeunit::"Sync Job");
            JobDeleted := true;
        end;
    end;
}