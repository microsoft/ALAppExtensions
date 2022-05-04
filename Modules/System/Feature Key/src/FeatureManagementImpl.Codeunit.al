// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Provides functionality for feature management.
/// </summary>
codeunit 2610 "Feature Management Impl."
{
    Access = Internal;
    Permissions = tabledata "Active Session" = r,
                  tabledata Company = r,
                  tabledata "Feature Key" = rimd,
                  tabledata "Feature Data Update Status" = rimd,
                  tabledata "Session Event" = r,
                  tabledata "Scheduled Task" = r;

    var
        FeatureDataUpdate: interface "Feature Data Update";
        ImplementedId: Text[50];
        SignInAgainMsg: Label 'You must sign out and then sign in again to make the changes take effect.', Comment = '"sign out" and "sign in" are the same terms as shown in the Business Central client.';
        SignInAgainNotificationGuidTok: Label '63b6f5ec-6db4-4e87-b103-c4bcb539f09e', Locked = true;
        PreviewFeatureParameterTxt: Label 'previewfeatures=%1', Comment = '%1 = the feature ID for the feature to be previewed', Locked = true;
        ErrorTraceTagMsg: Label 'Error on the feature data update task for feature %1 in company %2: %3', Comment = '%1- Feature id; %2 - CompanyName; %3 - error message', Locked = true;
        ScheduledTraceTagMsg: Label 'The task for updating data for feature %1 in company %2 is scheduled to start at %3.', Comment = '%1- Feature id; %2 - CompanyName; %3 - DateTime', Locked = true;
        StartedTraceTagMsg: Label 'The task for updating data for feature %1 in company %2 is started.', Comment = '%1- Feature id; %2 - CompanyName', Locked = true;
        FinishedTraceTagMsg: Label 'Data is updated for feature %1 in company %2.', Comment = '%1- Feature id; %2 - CompanyName', Locked = true;
        TagCategoryTxt: Label 'Feature Data Update', Locked = true;

    /// <summary>
    /// Gets the URL to let users try out a feature.
    /// <param name="FeatureKey">The feature key for the feature to try.</param>
    /// </summary>
    procedure GetFeatureKeyUrlForWeb(FeatureKey: Text[50]): Text
    var
        DotNetUriBuilder: DotNet UriBuilder;
        DotNetUri: DotNet Uri;
        QueryString: Text;
        ClientUrl: Text;
        QueryStringLbl: Label '%1&%2', Comment = '%1 - Query string, %2 - Preview feature parameter', Locked = true;
    begin
        ClientUrl := GetUrl(ClientType::Web);
        DotNetUriBuilder := DotNetUriBuilder.UriBuilder(ClientUrl);
        QueryString := DotNetUriBuilder.Query();

        QueryString := DelChr(QueryString, '<', '?');
        if StrLen(QueryString) > 0 then
            QueryString := StrSubstNo(QueryStringLbl,
                QueryString,
                StrSubstNo(PreviewFeatureParameterTxt, DotNetUri.EscapeDataString(FeatureKey)))
        else
            QueryString := StrSubstNo(PreviewFeatureParameterTxt, DotNetUri.EscapeDataString(FeatureKey));

        DotNetUriBuilder.Query := QueryString;
        DotNetUri := DotNetUriBuilder.Uri();
        exit(DotNetUri.AbsoluteUri());
    end;

    /// <summary>
    /// Sends a notification to ask user to sign out and sign in again to make the changes take effect
    /// </summary>
    local procedure SendSignInAgainNotification()
    var
        SignInAgainNotification: Notification;
    begin
        SignInAgainNotification.Id := SignInAgainNotificationGuidTok;
        SignInAgainNotification.Message := SignInAgainMsg;
        SignInAgainNotification.Scope := NOTIFICATIONSCOPE::LocalScope;
        SignInAgainNotification.Send();
    end;

    /// <summary>
    /// Inserts record to "Feature Data Update Status" table to show the feature status per company.
    /// </summary>
    local procedure InitializeFeatureDataUpdateStatus(FeatureKey: Record "Feature Key"; var FeatureDataUpdateStatus: Record "Feature Data Update Status")
    var
        FeatureManagementFacade: Codeunit "Feature Management Facade";
        InitializeHandled: Boolean;
    begin
        if FeatureDataUpdateStatus.Get(FeatureKey.ID, CompanyName()) then
            exit;

        FeatureDataUpdateStatus.Init();
        FeatureDataUpdateStatus."Feature Key" := FeatureKey.ID;
        FeatureDataUpdateStatus."Company Name" := CopyStr(CompanyName(), 1, MaxStrLen(FeatureDataUpdateStatus."Company Name"));
        FeatureDataUpdateStatus."Data Update Required" := FeatureKey."Data Update Required";
        FeatureManagementFacade.OnInitializeFeatureDataUpdateStatus(FeatureDataUpdateStatus, InitializeHandled);
        if not InitializeHandled then
            case FeatureKey.Enabled of
                FeatureKey.Enabled::None:
                    FeatureDataUpdateStatus."Feature Status" := FeatureDataUpdateStatus."Feature Status"::Disabled;
                FeatureKey.Enabled::"All Users":
                    if FeatureDataUpdateStatus."Data Update Required" then
                        FeatureDataUpdateStatus."Feature Status" := FeatureDataUpdateStatus."Feature Status"::Pending
                    else
                        FeatureDataUpdateStatus."Feature Status" := FeatureDataUpdateStatus."Feature Status"::Enabled;
            end;
        // If the table extension is not in sync during upgrade then Get() always returns False, 
        // so the following insert will fail if the record does exist.
        if FeatureDataUpdateStatus.Insert() then;
    end;

    /// <summary>
    /// Updates the status in "Feature Data Update Status" records related to all companies.
    /// Also sends the notification reminding user to sign in again after feature is enabled/disabled. 
    /// </summary>
    /// <param name="FeatureKey">the current "Feature Key" record</param>
    procedure AfterValidateEnabled(FeatureKey: Record "Feature Key")
    begin
        if FeatureKey.Enabled = FeatureKey.Enabled::None then
            DisableFeature(FeatureKey)
        else
            EnableFeature(FeatureKey);

        SendSignInAgainNotification();
    end;

    local procedure EnableFeature(FeatureKey: Record "Feature Key");
    var
        FeatureDataUpdateStatus: Record "Feature Data Update Status";
    begin
        FeatureDataUpdateStatus.SetRange("Feature Key", FeatureKey.ID);
        if FeatureKey."Data Update Required" then begin
            FeatureDataUpdateStatus.SetFilter("Company Name", '<>%1', CompanyName());
            FeatureDataUpdateStatus.ModifyAll("Feature Status", FeatureDataUpdateStatus."Feature Status"::Pending);
        end else
            FeatureDataUpdateStatus.ModifyAll("Feature Status", FeatureDataUpdateStatus."Feature Status"::Enabled);
    end;

    local procedure DisableFeature(FeatureKey: Record "Feature Key");
    var
        FeatureDataUpdateStatus: Record "Feature Data Update Status";
    begin
        FeatureDataUpdateStatus.SetRange("Feature Key", FeatureKey.ID);
        FeatureDataUpdateStatus.ModifyAll("Feature Status", FeatureDataUpdateStatus."Feature Status"::Disabled);
    end;

    /// <summary>
    /// Returns the fresh values of the "Feature Data Update Status" record for the current "Feature Key".
    /// </summary>
    /// <param name="FeatureKey">the current feature key record</param>
    /// <param name="FeatureDataUpdateStatus">returned the fresh "Feature Data Update Status" record</param>
    procedure GetFeatureDataUpdateStatus(FeatureKey: Record "Feature Key"; var FeatureDataUpdateStatus: Record "Feature Data Update Status")
    begin
        if FeatureDataUpdateStatus.Get(FeatureKey.ID, CompanyName()) then begin
            if FeatureDataUpdateStatus."Background Task" then
                UpdateBackgroundTaskStatus(FeatureDataUpdateStatus);
        end else
            InitializeFeatureDataUpdateStatus(FeatureKey, FeatureDataUpdateStatus);
    end;

    /// <summary>
    /// Returns true if the user has confirmed the data update for the selected feature.
    /// Opens the "Schedule Feature Data Update" page where user can confirm the update or schedule it.
    /// </summary>
    /// <param name="FeatureDataUpdateStatus">the current feature status</param>
    /// <returns>if the data update has been confirmed</returns>
    procedure ConfirmDataUpdate(var FeatureDataUpdateStatus: Record "Feature Data Update Status") Confirmed: Boolean;
    var
        ScheduleFeatureDataUpdate: Page "Schedule Feature Data Update";
    begin
        ScheduleFeatureDataUpdate.Set(FeatureDataUpdateStatus);
        if ScheduleFeatureDataUpdate.RunModal() = Action::OK then begin
            FeatureDataUpdateStatus.Find();
            Confirmed := FeatureDataUpdateStatus.Confirmed;
        end;
    end;

    /// <summary>
    /// Returns true if the feature has an interface implementation.
    /// </summary>
    procedure GetImplementation(FeatureDataUpdateStatus: Record "Feature Data Update Status") Implemented: Boolean;
    var
        FeatureManagementFacade: Codeunit "Feature Management Facade";
    begin
        if ImplementedId <> FeatureDataUpdateStatus."Feature Key" then
            FeatureManagementFacade.OnGetImplementation(FeatureDataUpdateStatus, FeatureDataUpdate, ImplementedId);
        Implemented := ImplementedId = FeatureDataUpdateStatus."Feature Key";
    end;

    /// <summary>
    /// Returns the result of the interface's GetTaskDescription method.
    /// </summary>
    procedure GetTaskDescription(FeatureDataUpdateStatus: Record "Feature Data Update Status") TaskDescription: Text;
    begin
        if GetImplementation(FeatureDataUpdateStatus) then
            TaskDescription := FeatureDataUpdate.GetTaskDescription();
    end;

    /// <summary>
    /// Runs the interface's review data method.
    /// </summary>
    procedure ReviewData(FeatureDataUpdateStatus: Record "Feature Data Update Status"): Boolean;
    begin
        if GetImplementation(FeatureDataUpdateStatus) then
            if FeatureDataUpdate.IsDataUpdateRequired() then begin
                FeatureDataUpdate.ReviewData();
                exit(true);
            end;
    end;

    /// <summary>
    /// Schedules or starts update depending on the options picked on the wizard page.
    /// </summary>
    /// <param name="FeatureDataUpdateStatus">The current status record</param>
    /// <returns>true if user picked Update or Schedule and the task is scheduled or executed.</returns>
    procedure Update(var FeatureDataUpdateStatus: Record "Feature Data Update Status"): Boolean;
    begin
        if not FeatureDataUpdateStatus."Data Update Required" then
            exit(true);
        if not ConfirmDataUpdate(FeatureDataUpdateStatus) then
            exit(false);

        if FeatureDataUpdateStatus."Background Task" then
            exit(ScheduleTask(FeatureDataUpdateStatus));
        Codeunit.Run(Codeunit::"Update Feature Data", FeatureDataUpdateStatus);
        exit(true);
    end;

    /// <summary>
    /// Runs the interface's data update method and updates the feature status.
    /// </summary>
    procedure UpdateData(var FeatureDataUpdateStatus: Record "Feature Data Update Status")
    var
        FeatureManagementFacade: Codeunit "Feature Management Facade";
    begin
        if GetImplementation(FeatureDataUpdateStatus) then begin
            FeatureManagementFacade.OnBeforeUpdateData(FeatureDataUpdateStatus);
            UpdateData(FeatureDataUpdateStatus, FeatureDataUpdate);
            FeatureManagementFacade.OnAfterUpdateData(FeatureDataUpdateStatus);
        end;
    end;

    /// <summary>
    /// Runs the interface's data update method and updates the feature status.
    /// </summary>
    procedure UpdateData(var FeatureDataUpdateStatus: Record "Feature Data Update Status"; FeatureDataUpdate: Interface "Feature Data Update")
    begin
        SendTraceTagOnStart(FeatureDataUpdateStatus);
        SetSessionInProgress(FeatureDataUpdateStatus);
        FeatureDataUpdate.UpdateData(FeatureDataUpdateStatus);
        FeatureDataUpdateStatus."Feature Status" := "Feature Status"::Complete;
        FeatureDataUpdateStatus.Modify();
        FeatureDataUpdate.AfterUpdate(FeatureDataUpdateStatus);
        SendTraceTagOnFinish(FeatureDataUpdateStatus);
    end;

    /// <summary>
    /// Sets Incomplete status and send trace tags.
    /// </summary>
    /// <param name="FeatureDataUpdateStatus">current status record</param>
    procedure HandleUpdateError(var FeatureDataUpdateStatus: Record "Feature Data Update Status")
    begin
        FeatureDataUpdateStatus.LockTable();
        if not FeatureDataUpdateStatus.Get(
            FeatureDataUpdateStatus."Feature Key", FeatureDataUpdateStatus."Company Name")
        then
            exit;
        FeatureDataUpdateStatus."Feature Status" := FeatureDataUpdateStatus."Feature Status"::Incomplete;
        FeatureDataUpdateStatus."Session ID" := -1;
        FeatureDataUpdateStatus."Server Instance ID" := -1;
        FeatureDataUpdateStatus.Modify();

        SendTraceTagOnError(FeatureDataUpdateStatus);
    end;

    /// <summary>
    /// Sets the "Feature Status" to the 'Updating' state, when the background task is started.
    /// </summary>
    local procedure SetSessionInProgress(var FeatureDataUpdateStatus: Record "Feature Data Update Status")
    begin
        if not FeatureDataUpdateStatus."Background Task" then
            FeatureDataUpdateStatus."Task Id" := CreateGuid();
        FeatureDataUpdateStatus."Session Id" := SessionId();
        FeatureDataUpdateStatus."Server Instance Id" := ServiceInstanceId();
        FeatureDataUpdateStatus."Feature Status" := "Feature Status"::Updating;
        FeatureDataUpdateStatus.Modify();
    end;

    /// <summary>
    /// Updates the status of the background task based on its activity.
    /// </summary>
    /// <returns>the previous status</returns>
    local procedure UpdateBackgroundTaskStatus(var FeatureDataUpdateStatus: Record "Feature Data Update Status") OldStatus: Enum "Feature Status";
    begin
        OldStatus := FeatureDataUpdateStatus."Feature Status";
        if IsNullGuid(FeatureDataUpdateStatus."Task Id") then
            FeatureDataUpdateStatus."Feature Status" := "Feature Status"::Pending
        else
            if FeatureDataUpdateStatus."Feature Status" <> "Feature Status"::Complete then
                if FeatureDataUpdateStatus."Session Id" = 0 then begin
                    if IsTaskScheduled(FeatureDataUpdateStatus."Task Id") then
                        FeatureDataUpdateStatus."Feature Status" := "Feature Status"::Scheduled
                    else
                        FeatureDataUpdateStatus."Feature Status" := "Feature Status"::Incomplete;
                end else
                    if IsSessionActive(FeatureDataUpdateStatus) then
                        FeatureDataUpdateStatus."Feature Status" := "Feature Status"::Updating
                    else begin
                        FeatureDataUpdateStatus."Feature Status" := "Feature Status"::Incomplete;
                        FeatureDataUpdateStatus."Session Id" := -1;
                        FeatureDataUpdateStatus."Server Instance Id" := -1;
                    end;
    end;

    /// <summary>
    /// Returns true if the feature is enabled and data update, if required, is complete.
    /// </summary>
    /// <param name="FeatureId">the feature id in the system table "Feature Key"</param>
    /// <returns>if the feature is fully enabled</returns>
    procedure IsEnabled(FeatureId: Text[50]): Boolean;
    var
        FeatureKey: Record "Feature Key";
        FeatureDataUpdateStatus: Record "Feature Data Update Status";
    begin
        if FeatureKey.Get(FeatureId) then begin
            InitializeFeatureDataUpdateStatus(FeatureKey, FeatureDataUpdateStatus);
            exit(FeatureDataUpdateStatus."Feature Status" in ["Feature Status"::Complete, "Feature Status"::Enabled])
        end;
    end;

    local procedure IsSessionActive(FeatureDataUpdateStatus: Record "Feature Data Update Status"): Boolean;
    var
        ActiveSession: Record "Active Session";
    begin
        if FeatureDataUpdateStatus."Server Instance Id" = ServiceInstanceId() then
            exit(ActiveSession.Get(FeatureDataUpdateStatus."Server Instance Id", FeatureDataUpdateStatus."Session Id"));
        if FeatureDataUpdateStatus."Server Instance Id" <= 0 then
            exit(false);
        exit(not IsSessionLoggedOff(FeatureDataUpdateStatus));
    end;

    local procedure IsSessionLoggedOff(FeatureDataUpdateStatus: Record "Feature Data Update Status"): Boolean;
    var
        SessionEvent: Record "Session Event";
    begin
        SessionEvent.SetRange("Server Instance Id", FeatureDataUpdateStatus."Server Instance Id");
        SessionEvent.SetRange("Session Id", FeatureDataUpdateStatus."Session Id");
        SessionEvent.SetRange("Event Type", SessionEvent."Event Type"::Logoff);
        SessionEvent.SetFilter("Event Datetime", '>%1', FeatureDataUpdateStatus."Start Date/Time");
        SessionEvent.SetRange("User SId", UserSecurityId());
        exit(not SessionEvent.IsEmpty);
    end;

    local procedure IsTaskScheduled(var TaskId: Guid): Boolean
    begin
        exit(TaskScheduler.TaskExists(TaskId));
    end;

    /// <summary>
    /// Cancels the scheduled task before it is started.
    /// </summary>
    procedure CancelTask(var FeatureDataUpdateStatus: Record "Feature Data Update Status"; ClearStartDateTime: Boolean)
    var
        ScheduledTask: Record "Scheduled Task";
    begin
        if not IsNullGuid(FeatureDataUpdateStatus."Task Id") then begin
            if ScheduledTask.Get(FeatureDataUpdateStatus."Task Id") then
                TaskScheduler.CancelTask(FeatureDataUpdateStatus."Task Id");
            Clear(FeatureDataUpdateStatus."Task Id");
        end;
        if ClearStartDateTime then
            FeatureDataUpdateStatus."Start Date/Time" := 0DT;
        FeatureDataUpdateStatus."Feature Status" := "Feature Status"::Pending;
        FeatureDataUpdateStatus.Modify();
    end;

    /// <summary>
    /// Creates the task bu the task scheduler.
    /// </summary>
    /// <param name="FeatureDataUpdateStatus">current status record</param>
    /// <returns>id of the scheduled task</returns>
    procedure CreateTask(var FeatureDataUpdateStatus: Record "Feature Data Update Status") TaskId: Guid
    begin
        CancelTask(FeatureDataUpdateStatus, False);
        AdjustStartDateTime(FeatureDataUpdateStatus);
        TaskId :=
            TaskScheduler.CreateTask(
                Codeunit::"Update Feature Data", Codeunit::"Feature Data Error Handler",
                true, FeatureDataUpdateStatus."Company Name", FeatureDataUpdateStatus."Start Date/Time",
                FeatureDataUpdateStatus.RecordId);
    end;

    /// <summary>
    /// Updates the status and properties related to scheduling and sends the trace tag.
    /// </summary>
    procedure ScheduleTask(var FeatureDataUpdateStatus: Record "Feature Data Update Status"): Boolean;
    var
        FeatureManagementFacade: Codeunit "Feature Management Facade";
        DoNotScheduleTask: Boolean;
        TaskID: Guid;
    begin
        if not TaskScheduler.CanCreateTask() then
            exit(false);

        FeatureManagementFacade.OnBeforeScheduleTask(FeatureDataUpdateStatus, DoNotScheduleTask, TaskID);
        if DoNotScheduleTask then
            FeatureDataUpdateStatus."Task ID" := TaskID
        else
            FeatureDataUpdateStatus."Task ID" :=
                CreateTask(FeatureDataUpdateStatus);

        if IsNullGuid(FeatureDataUpdateStatus."Task ID") then begin
            FeatureDataUpdateStatus."Feature Status" := FeatureDataUpdateStatus."Feature Status"::Pending;
            FeatureDataUpdateStatus."Start Date/Time" := 0DT;
        end else
            FeatureDataUpdateStatus."Feature Status" := "Feature Status"::Scheduled;
        FeatureDataUpdateStatus."Server Instance Id" := 0;
        FeatureDataUpdateStatus."Session Id" := 0;
        FeatureDataUpdateStatus.Modify();
        SendTraceTagOnScheduling(FeatureDataUpdateStatus);
        exit(true);
    end;

    local procedure AdjustStartDateTime(FeatureDataUpdateStatus: Record "Feature Data Update Status")
    var
        Delta: Duration;
    begin
        Delta := 500; // Time to update the status record before the task is started.
        if FeatureDataUpdateStatus."Start Date/Time" = 0DT then
            FeatureDataUpdateStatus."Start Date/Time" := CurrentDateTime() + Delta
        else
            if FeatureDataUpdateStatus."Start Date/Time" - CurrentDateTime() < Delta then
                FeatureDataUpdateStatus."Start Date/Time" := CurrentDateTime() + Delta;
    end;

    /// <summary>
    /// Opens the dialog for entering a date and time values.
    /// </summary>
    /// <param name="InitDateTime">default DataTime value</param>
    /// <returns>the new DataTime value entered by user</returns>
    procedure LookupDateTime(InitDateTime: DateTime) NewDateTime: DateTime
    var
        DateTimeDialog: Page "Date-Time Dialog";
    begin
        NewDateTime := InitDateTime;
        DateTimeDialog.SetDateTime(RoundDateTime(InitDateTime, 1000));
        if DateTimeDialog.RunModal() = ACTION::OK then
            NewDateTime := DateTimeDialog.GetDateTime();
        exit(NewDateTime);
    end;

    /// <summary>
    /// Sends the trace tag in case of error during feature data update.
    /// </summary>
    internal procedure SendTraceTagOnError(FeatureDataUpdateStatus: Record "Feature Data Update Status")
    var
        TelemetryCustomDimensions: Dictionary of [Text, Text];
    begin
        GetTelemetryCustomDimensions(FeatureDataUpdateStatus, 'Error', TelemetryCustomDimensions);
        Session.LogMessage(
            '0000DE3',
            StrSubstNo(
                ErrorTraceTagMsg, FeatureDataUpdateStatus."Feature Key",
                FeatureDataUpdateStatus."Company Name", GetLastErrorText()),
            Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, TelemetryCustomDimensions);
    end;

    /// <summary>
    /// Sends the trace tag when the feature data update is scheduled.
    /// </summary>
    local procedure SendTraceTagOnScheduling(FeatureDataUpdateStatus: Record "Feature Data Update Status")
    var
        TelemetryCustomDimensions: Dictionary of [Text, Text];
    begin
        GetTelemetryCustomDimensions(FeatureDataUpdateStatus, 'Schedule', TelemetryCustomDimensions);
        Session.LogMessage(
            '0000DE4',
            StrSubstNo(
                ScheduledTraceTagMsg, FeatureDataUpdateStatus."Feature Key",
                FeatureDataUpdateStatus."Company Name", Format(FeatureDataUpdateStatus."Start Date/Time", 0, 9)),
            Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, TelemetryCustomDimensions);
    end;

    /// <summary>
    /// Sends the trace tag when the feature data update is started.
    /// </summary>
    local procedure SendTraceTagOnStart(FeatureDataUpdateStatus: Record "Feature Data Update Status")
    var
        TelemetryCustomDimensions: Dictionary of [Text, Text];
    begin
        GetTelemetryCustomDimensions(FeatureDataUpdateStatus, 'Start', TelemetryCustomDimensions);
        Session.LogMessage(
            '0000EBB',
            StrSubstNo(
                StartedTraceTagMsg, FeatureDataUpdateStatus."Feature Key", FeatureDataUpdateStatus."Company Name"),
            Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, TelemetryCustomDimensions);
    end;

    /// <summary>
    /// Sends the trace tag when the feature data update is finished.
    /// </summary>
    local procedure SendTraceTagOnFinish(FeatureDataUpdateStatus: Record "Feature Data Update Status")
    var
        TelemetryCustomDimensions: Dictionary of [Text, Text];
    begin
        GetTelemetryCustomDimensions(FeatureDataUpdateStatus, 'Finish', TelemetryCustomDimensions);
        Session.LogMessage(
            '0000EBC',
            StrSubstNo(
                FinishedTraceTagMsg, FeatureDataUpdateStatus."Feature Key", FeatureDataUpdateStatus."Company Name"),
            Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, TelemetryCustomDimensions);
    end;

    local procedure GetTelemetryCustomDimensions(FeatureDataUpdateStatus: Record "Feature Data Update Status"; Operation: Text; var TelemetryCustomDimensions: Dictionary of [Text, Text])
    var
        Company: Record Company;
    begin
        TelemetryCustomDimensions.Add('Category', TagCategoryTxt);
        TelemetryCustomDimensions.Add('Operation', Operation);
        TelemetryCustomDimensions.Add('FeatureKey', FeatureDataUpdateStatus."Feature Key");
        TelemetryCustomDimensions.Add('CompanyName', FeatureDataUpdateStatus."Company Name");
        if Company.Get(FeatureDataUpdateStatus."Company Name") then
            TelemetryCustomDimensions.Add('EvaluationCompany', Format(Company."Evaluation Company", 0, 9));
    end;

    [EventSubscriber(ObjectType::Table, Database::"Company", 'OnAfterDeleteEvent', '', false, false)]
    local procedure OnAfterCompanyDeleteRemoveReferences(var Rec: Record Company; RunTrigger: Boolean)
    var
        FeatureDataUpdateStatus: Record "Feature Data Update Status";
    begin
        if Rec.IsTemporary then
            exit;

        FeatureDataUpdateStatus.SetRange("Company Name", Rec.Name);
        FeatureDataUpdateStatus.DeleteAll();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Company", 'OnAfterRenameEvent', '', false, false)]
    local procedure OnAfterCompanyRenameMoveReferences(var Rec: Record Company; var xRec: Record Company)
    var
        FeatureDataUpdateStatus: Record "Feature Data Update Status";
        RenameFeatureDataUpdateStatus: Record "Feature Data Update Status";
    begin
        if Rec.IsTemporary then
            exit;

        FeatureDataUpdateStatus.SetRange("Company Name", xRec.Name);
        if not FeatureDataUpdateStatus.FindSet(true) then
            exit;

        repeat
            RenameFeatureDataUpdateStatus.GetBySystemId(FeatureDataUpdateStatus.SystemId);
            RenameFeatureDataUpdateStatus.Rename(RenameFeatureDataUpdateStatus."Feature Key", Rec.Name);
        until FeatureDataUpdateStatus.Next() = 0;
    end;
}
