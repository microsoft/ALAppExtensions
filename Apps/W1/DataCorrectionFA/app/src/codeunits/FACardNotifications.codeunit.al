Codeunit 6091 "FA Card Notifications"
{
    var
        NotificationForFAEntriesThatCouldByCorrectedMsg: Label 'There are Fixed Asset Entries with potential rounding issues.';
        SeeMoreMsg: Label 'See more';

    [EventSubscriber(ObjectType::Page, Page::"Fixed Asset Card", 'OnAfterGetCurrRecordEvent', '', false, false)]
    Local Procedure IsDataCorrupted(var Rec: Record "Fixed Asset")
    var
        FALedgEntrywIssue: Record "FA Ledg. Entry w. Issue";
    begin
        ScheduleScanJob();
        if not FALedgEntrywIssue.IsEmpty then
            RaiseNotificationForFAEntriesThatCouldByCorrected();
    end;

    procedure RaiseNotificationForFAEntriesThatCouldByCorrected()
    var
        Notification: Notification;
    begin
        Notification.Id(GetNotificationForFAEntriesThatCouldByCorrected());
        Notification.Message(NotificationForFAEntriesThatCouldByCorrectedMsg);
        Notification.Scope(NOTIFICATIONSCOPE::LocalScope);
        Notification.AddAction(SeeMoreMsg, Codeunit::"FA Card Notifications",
          'ShowEntriesThatCouldBeRounded');
        Notification.Send();
    end;

    procedure ShowEntriesThatCouldBeRounded(FAEntriesThatCouldBeRounded: Notification)
    var
        FALedgEntrywIssue: Record "FA Ledg. Entry w. Issue";
    begin
        if not FALedgEntrywIssue.ReadPermission THEN
            exit;
        if FALedgEntrywIssue.IsEmpty then begin
            ScheduleScanJob();
            exit;
        end;
        Page.RunModal(Page::"FA Ledger Entries Issues", FALedgEntrywIssue);
    end;

    local procedure ScheduleScanJob()
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        if not CanScheduleJob() then
            exit;
        JobQueueEntry.SETRANGE("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SETRANGE("Object ID to Run", CODEUNIT::"FA Ledger Entries Scan");
        JobQueueEntry.SETRANGE(Status, JobQueueEntry.Status::Ready);
        IF JobQueueEntry.FINDFIRST() THEN
            EXIT;

        JobQueueEntry.SETFILTER(Status, '%1|%2', JobQueueEntry.Status::"On Hold", JobQueueEntry.Status::Finished);
        IF JobQueueEntry.FINDFIRST() THEN BEGIN
            JobQueueEntry.Restart();
            EXIT;
        END;
        JobQueueEntry.LOCKTABLE();
        JobQueueEntry.INIT();
        JobQueueEntry."Run on Sundays" := true;
        JobQueueEntry."Recurring Job" := true;
        JobQueueEntry."Object Type to Run" := JobQueueEntry."Object Type to Run"::Codeunit;
        JobQueueEntry."Object ID to Run" := CODEUNIT::"FA Ledger Entries Scan";
        JobQueueEntry."Earliest Start Date/Time" := CREATEDATETIME(Today, 220000T);
        JobQueueEntry."Maximum No. of Attempts to Run" := 3;
        CODEUNIT.RUN(CODEUNIT::"Job Queue - Enqueue", JobQueueEntry);
    end;

    procedure GetNotificationForFAEntriesThatCouldByCorrected(): Guid
    begin
        exit('732367dd-4f13-4cf0-a0d9-8e380a4b920c');
    end;

    internal procedure CanScheduleJob(): Boolean
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        if not (JobQueueEntry.WritePermission() and JobQueueEntry.ReadPermission()) then
            exit(false);
        if not TASKSCHEDULER.CanCreateTask() then
            exit(false);
        exit(true);
    end;

}
