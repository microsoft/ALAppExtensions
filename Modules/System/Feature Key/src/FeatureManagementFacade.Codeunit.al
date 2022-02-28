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
        exit(FeatureManagementImpl.GetImplementation(FeatureDataUpdateStatus));
    end;

    /// <summary>
    /// Retrurns the result of the interface's GetTaskDescription method.
    /// </summary>
    procedure GetTaskDescription(FeatureDataUpdateStatus: Record "Feature Data Update Status") TaskDescription: Text;
    begin
        exit(FeatureManagementImpl.GetTaskDescription(FeatureDataUpdateStatus));
    end;

    /// <summary>
    /// Runs the interface's review data method.
    /// </summary>
    procedure ReviewData(FeatureDataUpdateStatus: Record "Feature Data Update Status"): Boolean;
    begin
        exit(FeatureManagementImpl.ReviewData(FeatureDataUpdateStatus));
    end;

    /// <summary>
    /// Schedules or starts update depending on the options picked on the wizard page.
    /// </summary>
    /// <param name="FeatureDataUpdateStatus">The current status record</param>
    /// <returns>true if user picked Update or Schedule and the task is scheduled or executed.</returns>
    procedure Update(var FeatureDataUpdateStatus: Record "Feature Data Update Status"): Boolean;
    begin
        exit(FeatureManagementImpl.Update(FeatureDataUpdateStatus));
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
        FeatureManagementImpl.UpdateData(FeatureDataUpdateStatus);
    end;

    internal procedure GetFeatureDataUpdateStatus(FeatureKey: Record "Feature Key"; var FeatureDataUpdateStatus: Record "Feature Data Update Status")
    begin
        FeatureManagementImpl.GetFeatureDataUpdateStatus(FeatureKey, FeatureDataUpdateStatus);
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterUpdateData(var FeatureDataUpdateStatus: Record "Feature Data Update Status")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeUpdateData(var FeatureDataUpdateStatus: Record "Feature Data Update Status")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeScheduleTask(FeatureDataUpdateStatus: Record "Feature Data Update Status"; var DoNotScheduleTask: Boolean; var TaskId: Guid)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnGetImplementation(FeatureDataUpdateStatus: Record "Feature Data Update Status"; var FeatureDataUpdate: interface "Feature Data Update"; var ImplementedId: Text[50])
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnShowTaskLog(FeatureDataUpdateStatus: Record "Feature Data Update Status")
    begin
    end;

}