codeunit 2400 "Sync Job"
{
    trigger OnRun()
    var
        JobQueueEntry: Record "Job Queue Entry";
        JobQueueManagement: Codeunit "Job Queue Management";
        UserLoginTimeTracker: Codeunit "User Login Time Tracker";
        FromDate: Date;
    begin
        FromDate := CalcDate('<-2W>');

        if not UserLoginTimeTracker.AnyUserLoggedInSinceDate(FromDate) then begin
            JobQueueManagement.DeleteJobQueueEntries(JobQueueEntry."Object Type to Run"::Codeunit, Codeunit::"Sync Job");
            exit;
        end;

        RunSync();
    end;

    var
        SyncJobInProgressErr: Label 'Sync job is already in progress.';

    procedure RunSyncForeground()
    var
        JobQueueEntry: Record "Job Queue Entry";
        JobQueueManagement: Codeunit "Job Queue Management";
    begin
        if IsSyncJobInProgress() then
            Error(SyncJobInProgressErr);
        JobQueueManagement.DeleteJobQueueEntries(JobQueueEntry."Object Type to Run"::Codeunit, Codeunit::"Sync Job");
        RunSync();
        CreateJobQueueEntry();
    end;

    local procedure CreateJobQueueEntry()
    var
        JobQueueEntry: Record "Job Queue Entry";
        DummyRecordId: RecordId;
    begin
        JobQueueEntry.ScheduleJobQueueEntry(Codeunit::"Sync Job", DummyRecordId);
        JobQueueEntry.Validate("No. of Minutes between Runs", 5);
        JobQueueEntry.Validate("Run on Mondays", true);
        JobQueueEntry.Validate("Run on Tuesdays", true);
        JobQueueEntry.Validate("Run on Wednesdays", true);
        JobQueueEntry.Validate("Run on Thursdays", true);
        JobQueueEntry.Validate("Run on Fridays", true);
        JobQueueEntry.Validate("Run on Saturdays", true);
        JobQueueEntry.Validate("Run on Sundays", true);
        JobQueueEntry.Modify(true);
    end;

    local procedure IsSyncJobInProgress(): Boolean
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"Sync Job");
        JobQueueEntry.SetRange(Status, JobQueueEntry.Status::"In Process");
        exit(not JobQueueEntry.IsEmpty());
    end;

    local procedure RunSync()
    var
        SyncSetup: Record "Sync Setup";
        SyncChange: Record "Sync Change";
        JobQueueEntry: Record "Job Queue Entry";
        SyncManagement: Codeunit "Sync Management";
        Success: Boolean;
    begin
        SyncSetup.GetSingleInstance();

        OnStartSync(SyncSetup);

        if SyncSetup."Last Sync Time" = 0DT then
            OnInitialSync()
        else begin
            OnDiscoverDeletions();
            OnGetChanges(SyncChange, SyncSetup);
            SyncManagement.MergeSyncChanges();
        end;

        if SyncChange.FindSet() then
            repeat
                if SyncChange."Current No. of sync attempts" = SyncSetup."Max No. of sync attempts" then begin
                    JobQueueEntry.SetRange("Object ID to Run", Codeunit::"Sync Job");
                    if JobQueueEntry.FindFirst() then begin
                        OnCreateJobQueueEntryLogForUnsuccessfulSync(JobQueueEntry, SyncChange."Error message");
                        SyncChange.Delete();
                    end;
                end else begin
                    OnProcessChange(SyncChange, SyncSetup, Success);
                    if Success then begin
                        SyncChange.Delete();
                        Commit();
                    end else begin
                        SyncChange."Current No. of sync attempts" := SyncChange."Current No. of sync attempts" + 1;
                        SyncChange.Modify();
                    end;
                end;
            until SyncChange.Next() = 0;
        OnEndSync(SyncSetup);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnStartSync(var SyncSetup: Record "Sync Setup")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetChanges(var SyncChange: Record "Sync Change"; SyncSetup: Record "Sync Setup")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnProcessChange(var SyncChange: Record "Sync Change"; SyncSetup: Record "Sync Setup"; var Success: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnDiscoverDeletions()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnEndSync(var SyncSetup: Record "Sync Setup")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCreateJobQueueEntryLogForUnsuccessfulSync(var JobQueueEntry: Record "Job Queue Entry"; ErrorMessage: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInitialSync();
    begin
    end;
}

