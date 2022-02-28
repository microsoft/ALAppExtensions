Codeunit 6091 "FA Card Notifications"
{
    var
        NotificationForFAEntriesThatCouldByCorrectedMsg: Label 'There are fixed asset entries with potential rounding issues.';
        SeeMoreMsg: Label 'See more';

    [EventSubscriber(ObjectType::Page, Page::"Fixed Asset Card", 'OnAfterGetCurrRecordEvent', '', false, false)]
    Local Procedure IsDataCorrupted(var Rec: Record "Fixed Asset")
    var
        FALedgEntrywIssue: Record "FA Ledg. Entry w. Issue";
    begin
        ScanEntries();
        FALedgEntrywIssue.SetRange(Corrected, false);
        FALedgEntrywIssue.SetRange("FA No.", Rec."No.");
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
            ScanEntries();
            exit;
        end;
        Page.RunModal(Page::"FA Ledger Entries Issues", FALedgEntrywIssue);
    end;

    local procedure ScanEntries()
    var
        FASetup: Record "FA Setup";
    begin
        if not TaskScheduler.CanCreateTask() then
            exit;

        FASetup.Get();
        if FASetup."Last time scanned" > (CurrentDateTime + GetCacheRefreshInterval()) then
            exit;

        FASetup.LockTable();
        FASetup."Last time scanned" := CurrentDateTime;
        FASetup.Modify();
        Commit();  // Clear the lock on FA Setup
        TaskScheduler.CreateTask(Codeunit::"FA Ledger Entries Scan", 0, true, CompanyName, CurrentDateTime + 1000); // Add 1s
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

    local procedure GetCacheRefreshInterval() Interval: Duration
    begin
        Interval := 7 * 24 * 60 * 60 * 1000; // 1 week
    end;

}
