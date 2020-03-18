codeunit 1956 "LPP Scheduler"
{
    trigger OnRun()
    begin

    end;

    var
        SetupScheduledLPPMsg: Label 'You can get the payment prediction updated automatically every day.';
        SetupScheduledLPPTxt: Label 'Enable Scheduled Payment Predictions';
        SetupScheduledLPPDescriptionTxt: Label 'Show notification if you want to enable payment prediction to be automatically updated every day';
        DontAskAgainTxt: Label 'Don''t ask again';
        ScheduledLPPEnabledMsg: Label 'The payment predictions will be updated every day. You can change the schedule in the Late Payment Prediction Setup window.';
        LPPUpdateJobQueueEntryDescriptionTxt: Label 'Late Payment Prediction Update';

    procedure CreateJobQueueEntryAndOpenCard()
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        CreateJobQueueEntry(JobQueueEntry, true);
        Page.Run(Page::"Job Queue Entry Card", JobQueueEntry);
    end;

    procedure CreateJobQueueEntry(var JobQueueEntry: Record "Job Queue Entry"; Recurring: Boolean)
    var
        JobQueueManagement: Codeunit "Job Queue Management";
    begin
        if Recurring then
            JobQueueEntry."No. of Minutes between Runs" := 60 * 24 // Daily
        else
            JobQueueEntry."No. of Minutes between Runs" := 0; // Never
        JobQueueEntry."Object Type to Run" := JobQueueEntry."Object Type to Run"::Codeunit;
        JobQueueEntry."Object ID to Run" := Codeunit::"LPP Update";
        JobQueueEntry.Description := CopyStr(LPPUpdateJobQueueEntryDescriptionTxt, 1, 250);
        JobQueueManagement.CreateJobQueueEntry(JobQueueEntry);
    end;

    procedure RemoveScheduledTaskIfUserInactive()
    var
        JobQueueEntry: Record "Job Queue Entry";
        JobQueueManagement: Codeunit "Job Queue Management";
        UserLoginTimeTracker: Codeunit "User Login Time Tracker";
        FromDate: Date;
    begin
        FromDate := CalcDate('<-2W>');

        if not UserLoginTimeTracker.AnyUserLoggedInSinceDate(FromDate) then
            JobQueueManagement.DeleteJobQueueEntries(JobQueueEntry."Object Type to Run"::Codeunit, Codeunit::"LPP Update");
    end;

    procedure SetupScheduledLPP(SetupNotification: Notification)
    var
        JobQueueEntry: Record "Job Queue Entry";
        LPMachineLearningSetup: Record "LP Machine Learning Setup";
        Date: Record Date;
    begin
        LPMachineLearningSetup.GetSingleInstance();

        CreateJobQueueEntry(JobQueueEntry, true);
        Codeunit.Run(Codeunit::"Job Queue - Enqueue", JobQueueEntry);
        Date.Get(Date."Period Type"::Date, DT2Date(JobQueueEntry."Earliest Start Date/Time"));
        Message(ScheduledLPPEnabledMsg);
    end;

    procedure DeactivateNotification(SetupNotification: Notification)
    var
        MyNotifications: Record "My Notifications";
    begin
        // Insert notification incase the My Notifications page has not been opened yet
        MyNotifications.InsertDefault(GetSetupNotificationID(),
            CopyStr(SetupScheduledLPPMsg, 1, 128),
            SetupScheduledLPPDescriptionTxt,
            true);
        MyNotifications.Disable(GetSetupNotificationID());
    end;

    local procedure JobQueueEntryExists(): Boolean
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"LPP Update");
        exit(not JobQueueEntry.IsEmpty());
    end;

    local procedure GetDatabase(): Text[250]
    var
        ActiveSession: Record "Active Session";
    begin
        ActiveSession.Get(ServiceInstanceId(), SessionId());
        exit(ActiveSession."Database Name");
    end;

    local procedure CreateSetupNotification()
    var
        SetupNotification: Notification;
    begin
        if not ShowNotification() then
            exit;

        SetupNotification.Message := SetupScheduledLPPMsg;
        SetupNotification.Scope := NotificationScope::LocalScope;
        SetupNotification.AddAction(SetupScheduledLPPTxt, Codeunit::"LPP Scheduler", 'SetupScheduledLPP');
        SetupNotification.AddAction(DontAskAgainTxt, Codeunit::"LPP Scheduler", 'DeactivateNotification');
        SetupNotification.Send();
    end;

    local procedure ShowNotification(): Boolean
    var
        LPMachineLearningSetup: Record "LP Machine Learning Setup";
        O365GettingStarted: Record "O365 Getting Started";
        EnvironmentInfo: Codeunit "Environment Information";
    begin
        if JobQueueEntryExists() then
            exit(false);

        if not IsSetupNotificationIDEnabled() then
            exit(false);

        if O365GettingStarted.Get(UserId(), CurrentClientType()) then
            if O365GettingStarted."Tour in Progress" then
                exit(false);

        if not EnvironmentInfo.IsSaaS() then
            exit(false);

        if not LPMachineLearningSetup.Get() then
            exit(false);

        if not LPMachineLearningSetup."Make Predictions" then
            exit(false);

        exit(true);
    end;

    [EventSubscriber(ObjectType::Page, Page::"LP Machine Learning Setup", 'OnOpenPageEvent', '', false, false)]
    local procedure OnOpenLPMachineLearningSetup(var Rec: Record "LP Machine Learning Setup")
    begin
        CreateSetupNotification();
    end;

    [EventSubscriber(ObjectType::Page, Page::"Customer Ledger Entries", 'OnOpenPageEvent', '', false, false)]
    local procedure OnOpenCustomerLedgerEntries(var Rec: Record "Cust. Ledger Entry")
    begin
        CreateSetupNotification();
    end;

    procedure GetSetupNotificationID(): Guid
    begin
        exit('b3e7ee1f-5f09-4c96-8544-29a2889594ef')
    end;

    local procedure IsSetupNotificationIDEnabled(): Boolean
    var
        MyNotifications: Record "My Notifications";
    begin
        exit(MyNotifications.IsEnabled(GetSetupNotificationID()));
    end;

    [EventSubscriber(ObjectType::Page, Page::"My Notifications", 'OnInitializingNotificationWithDefaultState', '', false, false)]
    local procedure OnInitializingNotificationWithDefaultState()
    var
        MyNotifications: Record "My Notifications";
    begin
        MyNotifications.InsertDefault(GetSetupNotificationID(),
            CopyStr(SetupScheduledLPPMsg, 1, 128),
            SetupScheduledLPPDescriptionTxt,
            true);
    end;

    procedure JobQueueEntryCreationInProcess(): Boolean
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        with JobQueueEntry do begin
            SetRange("Object Type to Run", "Object Type to Run"::Codeunit);
            SetRange("Object ID to Run", Codeunit::"LPP Update");
            SetRange(Status, Status::"In Process");
            if FindFirst() then
                exit(true);
            exit(false);
        end;
    end;

}