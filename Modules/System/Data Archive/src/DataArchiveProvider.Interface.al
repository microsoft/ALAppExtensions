// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary> 
/// Exposes an interface for Data Archive.
/// Data Archive is called from application objects to store data.
/// </summary>
interface "Data Archive Provider"
{
    /// <summary> 
    /// Creates a new archive entry.
    /// </summary>
    /// <param name="Description">The name or description for the archive entry. Will typically be the calling object name.</param>
    /// <returns>The entry no. of the created archive entry - if any.</returns>
    procedure Create(Description: Text): Integer;

    /// <summary> 
    /// Opens an existing archive entry.
    /// </summary>
    /// <param name="ID">The ID of the archive entry.</param>
    procedure Open(ID: Integer);

    /// <summary> 
    /// Saves and closes the currently open archive entry.
    /// </summary>
    procedure Save();

    /// <summary> 
    /// Discards any additions and closes the currently open archive entry.
    /// </summary>
    procedure DiscardChanges();

    /// <summary> 
    /// Saves the supplied record to the currently open archive entry.
    /// </summary>
    /// <param name="RecordRef">The record will be copied to the archive.</param>
    procedure SaveRecord(var RecordRef: RecordRef);

    /// <summary> 
    /// Saves the supplied record to the currently open archive entry.
    /// </summary>
    /// <param name="RecordVar">The record will be copied to the archive.</param>
    procedure SaveRecord(RecordVar: Variant);

    /// <summary> 
    /// Saves all records within the filters to the currently open archive entry.
    /// </summary>
    /// <param name="RecordRef">All records for the RecRef within the filters will be copied to the archive.</param>
    procedure SaveRecords(var RecordRef: RecordRef);

    /// <summary> 
    /// Starts subscription to the OnDatabaseDelete trigger and calls SaveRecord with any deleted record.
    /// </summary>
    procedure StartSubscriptionToDelete();

    /// <summary> 
    /// Starts subscription to the OnDatabaseDelete trigger and calls SaveRecord with any deleted record.
    /// </summary>
    /// <param name="ResetSession">If true, then the session will be reset. This can be necessary if a deletion has already been made on any table that should be archived.</param>
    procedure StartSubscriptionToDelete(ResetSession: Boolean);

    /// <summary> 
    /// Stops the subscription to the OnDatabaseDelete trigger.
    /// </summary>
    procedure StopSubscriptionToDelete();

    /// <summary> 
    /// Informs the consumer app whether there is a provider for this interface.
    /// </summary>
    /// <returns>Returns true if a provider for this interface is installed.</returns>
    procedure DataArchiveProviderExists(): Boolean;

    /// <summary> 
    /// Sets the instance of the provider. Needed for self-reference.
    /// </summary>
    /// <param name="NewDataArchiveProvider">The global instance of IDataArchiveProvider.</param>
    procedure SetDataArchiveProvider(var NewDataArchiveProvider: Interface "Data Archive Provider")
}