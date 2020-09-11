// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// This codeunit provides public functions for feature management.
/// </summary>
codeunit 2611 "Feature Management Facade"
{
    Access = Public;

    var
        FeatureManagementImpl: Codeunit "Feature Management Impl.";
        FeatureDataUpdate: interface "Feature Data Update";
        ImplementedId: Text[50];

    /// <summary>
    /// Returns true if the feature is enabled and data update, if required, is complete.
    /// </summary>
    /// <param name="FeatureId">the feature id in the system table "Feature Key"</param>
    /// <returns>if the feature is fully enabled</returns>
    procedure IsEnabled(FeatureId: Text[50]): Boolean;
    begin
        exit(FeatureManagementImpl.IsEnabled(FeatureId));
    end;

    /// <summary>
    /// Updates the status in "Feature Data Update Status" records related to all companies.
    /// Also sends the notification reminding user to sign in again after feature is enabled/disabled. 
    /// </summary>
    /// <param name="FeatureKey">the current "Feature Key" record</param>
    procedure AfterValidateEnabled(FeatureKey: Record "Feature Key")
    begin
        FeatureManagementImpl.AfterValidateEnabled(FeatureKey);
    end;

    /// <summary>
    /// Gets the URL to let users try out a feature.
    /// <param name="FeatureKey">The feature key for the feature to try.</param>
    /// </summary>
    procedure GetFeatureKeyUrlForWeb(FeatureKey: Text[50]): Text
    begin
        exit(FeatureManagementImpl.GetFeatureKeyUrlForWeb(FeatureKey))
    end;

    /// <summary>
    /// Returns true if the feature has an interface implementation.
    /// </summary>
    procedure GetImplementation(FeatureDataUpdateStatus: Record "Feature Data Update Status") Implemented: Boolean;
    begin
        if ImplementedId <> FeatureDataUpdateStatus."Feature Key" then
            OnGetImplementation(FeatureDataUpdateStatus, FeatureDataUpdate, ImplementedId);
        Implemented := ImplementedId = FeatureDataUpdateStatus."Feature Key";
    end;

    /// <summary>
    /// Retrurns the result of the interface's GetTaskDescription method.
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
        if not FeatureManagementImpl.ConfirmDataUpdate(FeatureDataUpdateStatus) then
            exit(false);

        if FeatureDataUpdateStatus."Background Task" then
            exit(ScheduleTask(FeatureDataUpdateStatus));
        Codeunit.Run(Codeunit::"Update Feature Data", FeatureDataUpdateStatus);
        exit(true);
    end;

    /// <summary>
    /// Creates the scheduled task.
    /// </summary>
    local procedure ScheduleTask(var FeatureDataUpdateStatus: Record "Feature Data Update Status"): Boolean;
    var
        DoNotScheduleTask: Boolean;
        TaskID: Guid;
    begin
        if not TaskScheduler.CanCreateTask() then
            exit(false);

        OnBeforeScheduleTask(FeatureDataUpdateStatus, DoNotScheduleTask, TaskID);
        if DoNotScheduleTask then
            FeatureDataUpdateStatus."Task ID" := TaskID
        else
            FeatureDataUpdateStatus."Task ID" :=
                FeatureManagementImpl.CreateTask(FeatureDataUpdateStatus);
        FeatureManagementImpl.ScheduleTask(FeatureDataUpdateStatus);
        exit(true);
    end;

    /// <summary>
    /// Cancels the scheduled task before it is started.
    /// </summary>
    procedure CancelTask(var FeatureDataUpdateStatus: Record "Feature Data Update Status"; ClearStartDateTime: Boolean)
    begin
        FeatureManagementImpl.CancelTask(FeatureDataUpdateStatus, ClearStartDateTime);
    end;

    /// <summary>
    /// Runs the interface's data updata method and updates the feature status.
    /// </summary>
    procedure UpdateData(var FeatureDataUpdateStatus: Record "Feature Data Update Status")
    begin
        if GetImplementation(FeatureDataUpdateStatus) then
            FeatureManagementImpl.UpdateData(FeatureDataUpdateStatus, FeatureDataUpdate);
    end;

    internal procedure GetFeatureDataUpdateStatus(FeatureKey: Record "Feature Key"; var FeatureDataUpdateStatus: Record "Feature Data Update Status")
    begin
        FeatureManagementImpl.GetFeatureDataUpdateStatus(FeatureKey, FeatureDataUpdateStatus);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeScheduleTask(FeatureDataUpdateStatus: Record "Feature Data Update Status"; var DoNotScheduleTask: Boolean; var TaskId: Guid)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetImplementation(FeatureDataUpdateStatus: Record "Feature Data Update Status"; var FeatureDataUpdate: interface "Feature Data Update"; var ImplementedId: Text[50])
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnShowTaskLog(FeatureDataUpdateStatus: Record "Feature Data Update Status")
    begin
    end;

}