// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Interface defines methods for feature data update task management.
/// </summary>
interface "Feature Data Update"
{
    /// <summary>
    /// Searches the database for data that must be updated before the feature can be enabled. 
    /// </summary>
    /// <returns>true if there is data to update</returns>
    procedure IsDataUpdateRequired(): Boolean;

    /// <summary>
    /// Opens the page showing the list of tables with counted records that require update.
    /// </summary>
    procedure ReviewData();

    /// <summary>
    /// Runs the process that updates data for the feature.
    /// </summary>
    /// <param name="FeatureDataUpdateStatus">the feature update status record</param>
    procedure UpdateData(FeatureDataUpdateStatus: Record "Feature Data Update Status");

    /// <summary>
    /// Method is called after the update is complete, e.g. to complete the setup for the feature.
    /// </summary>
    /// <param name="FeatureDataUpdateStatus">the feature update status record</param>
    procedure AfterUpdate(FeatureDataUpdateStatus: Record "Feature Data Update Status");

    /// <summary>
    /// Retruns the detailed description of the data update required for the feature.
    /// It is shown of the "Schedule Feature Data Update" page to explain the user what is going to happen.
    /// </summary>
    /// <returns>The process description</returns>
    procedure GetTaskDescription() TaskDescription: Text;
}