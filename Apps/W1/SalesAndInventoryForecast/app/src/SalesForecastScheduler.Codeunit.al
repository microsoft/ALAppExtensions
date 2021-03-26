// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 1852 "Sales Forecast Scheduler"
{
    var
        SpecifyApiKeyErr: Label 'You must specify an API key and an API URI in the Sales and Inventory Forecast Setup page before you can automate sales forecasting.';
        SetupScheduledForecastingMsg: Label 'You can get the sales forecast updated automatically every week.';
        SetupScheduledForecastingTxt: Label 'Set Up Scheduled Forecasting';
        SetupScheduledForecastingDescriptionTxt: Label 'Show notification if you want to enable sales forecast to become automatically updated every week';
        DontAskAgainTxt: Label 'Don''t ask again';
        ScheduledForecastingEnabledMsg: Label 'The sales forecast will be updated every week. You can change the schedule in the Setup Scheduled Forecasting window in the Sales Inventory Forecast Setup.';

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
            JobQueueEntry."No. of Minutes between Runs" := 60 * 24 * 7 // Weekly
        else
            JobQueueEntry."No. of Minutes between Runs" := 0; // Never
        JobQueueEntry."Object Type to Run" := JobQueueEntry."Object Type to Run"::Codeunit;
        JobQueueEntry."Object ID to Run" := Codeunit::"Sales Forecast Update";
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
            JobQueueManagement.DeleteJobQueueEntries(JobQueueEntry."Object Type to Run"::Codeunit, Codeunit::"Sales Forecast Update");
    end;

    procedure SetupScheduledForecasting(SetupNotification: Notification)
    var
        JobQueueEntry: Record "Job Queue Entry";
        MSSalesForecastSetup: Record "MS - Sales Forecast Setup";
    begin
        MSSalesForecastSetup.GetSingleInstance();
        if MSSalesForecastSetup.URIOrKeyEmpty() then
            Error(SpecifyApiKeyErr);

        CreateJobQueueEntry(JobQueueEntry, true);
        Codeunit.Run(Codeunit::"Job Queue - Enqueue", JobQueueEntry);
        Message(ScheduledForecastingEnabledMsg);
    end;

    procedure DeactivateNotification(SetupNotification: Notification)
    var
        MyNotifications: Record "My Notifications";
    begin
        // Insert notification incase the My Notifications page has not been opened yet
        MyNotifications.InsertDefault(GetSetupNotificationID(),
            SetupScheduledForecastingMsg,
            SetupScheduledForecastingDescriptionTxt,
            true);
        MyNotifications.Disable(GetSetupNotificationID());
    end;

    local procedure JobQueueEntryExists(): Boolean
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"Sales Forecast Update");
        exit(not JobQueueEntry.IsEmpty());
    end;

    local procedure CreateSetupNotification()
    var
        SetupNotification: Notification;
    begin
        if not ShowNotification() then
            exit;

        SetupNotification.Message := SetupScheduledForecastingMsg;
        SetupNotification.Scope := NotificationScope::LocalScope;
        SetupNotification.AddAction(SetupScheduledForecastingTxt, Codeunit::"Sales Forecast Scheduler", 'SetupScheduledForecasting');
        SetupNotification.AddAction(DontAskAgainTxt, Codeunit::"Sales Forecast Scheduler", 'DeactivateNotification');
        SetupNotification.Send();
    end;

    local procedure ShowNotification(): Boolean
    var
        MSSalesForecastSetup: Record "MS - Sales Forecast Setup";
        O365GettingStarted: Record "O365 Getting Started";
        Item: Record Item;
        EnvironmentInfo: Codeunit "Environment Information";
    begin
        if JobQueueEntryExists() then
            exit(false);

        if Item.IsEmpty() then
            exit(false);

        if not IsSetupNotificationIDEnabled() then
            exit(false);

        if O365GettingStarted.Get(UserId(), CurrentClientType()) then
            if O365GettingStarted."Tour in Progress" then
                exit(false);

        if MSSalesForecastSetup.Get() then begin
            // If not in SaaS check that URI and Key have been specified
            if not EnvironmentInfo.IsSaaS() and MSSalesForecastSetup.URIOrKeyEmpty() then
                exit(false);
        end else
            if not EnvironmentInfo.IsSaaS() then
                exit(false);

        exit(true);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales Forecast Setup Card", 'OnOpenPageEvent', '', false, false)]
    local procedure OnOpenSalesInventoryForecastSetup(var Rec: Record "MS - Sales Forecast Setup")
    begin
        CreateSetupNotification();
    end;

    [EventSubscriber(ObjectType::Page, Page::"Item List", 'OnOpenPageEvent', '', false, false)]
    local procedure OnOpenItemList(var Rec: Record Item)
    begin
        CreateSetupNotification();
    end;

    procedure GetSetupNotificationID(): Guid
    begin
        exit('05735C1A-FF05-469F-A8BB-D5B5E0ED8220')
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
            SetupScheduledForecastingMsg,
            SetupScheduledForecastingDescriptionTxt,
            true);
    end;

    procedure JobQueueEntryCreationInProcess(): Boolean
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        with JobQueueEntry do begin
            SetRange("Object Type to Run", "Object Type to Run"::Codeunit);
            SetRange("Object ID to Run", Codeunit::"Sales Forecast Update");
            SetRange(Status, Status::"In Process");
            if FindFirst() then
                exit(true);
            exit(false);
        end;
    end;
}

