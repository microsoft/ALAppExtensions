// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Exposes functionality to archive / save data before deleting it.
/// </summary>
codeunit 600 "Data Archive"
{
    Access = Public;

    var
        DataArchiveImplementation: Codeunit "Data Archive Implementation";

    /// <summary> 
    /// Creates a new archive entry.
    /// </summary>
    /// <param name="Description">The name or description for the archive entry. Will typically be the calling object name.</param>
    /// <error>The archive has already been created or opened.</error>
    /// <returns>The entry no. of the created archive entry - if any.</returns>
    procedure Create(Description: Text): Integer
    begin
        exit(DataArchiveImplementation.Create(Description));
    end;

    /// <summary> 
    /// Creates a new archive entry, resets the session and starts logging all new deletions.
    /// </summary>
    /// <param name="Description">The name or description for the archive entry. Will typically be the calling object name.</param>
    /// <returns>The entry no. of the created archive entry - if any.</returns>
    /// <error>The archive has already been created or opened.</error>
    procedure CreateAndStartLoggingDeletions(Description: Text): Integer
    begin
        exit(DataArchiveImplementation.CreateAndStartLoggingDeletions(Description));
    end;

    /// <summary> 
    /// Opens an existing archive entry.
    /// </summary>
    /// <param name="ID">The ID of the archive entry.</param>
    /// <error>The archive has already been created or opened.</error>
    procedure Open(ID: Integer)
    begin
        DataArchiveImplementation.Open(ID);
    end;

    /// <summary> 
    /// Saves and closes the currently open archive entry.
    /// </summary>
    /// <error>The archive must be created or opened first.</error>
    procedure Save()
    begin
        DataArchiveImplementation.Save();
    end;

    /// <summary> 
    /// Discards any additions and closes the currently open archive entry.
    /// </summary>
    /// <error>The archive must be created or opened first.</error>
    procedure DiscardChanges()
    begin
        DataArchiveImplementation.DiscardChanges();
    end;

    /// <summary> 
    /// Saves the supplied record to the currently open archive entry.
    /// </summary>
    /// <param name="RecordVariant">The record will be copied to the archive.</param>
    /// <error>The archive must be created or opened first.</error>
    procedure SaveRecord(RecordVariant: Variant);
    begin
        DataArchiveImplementation.SaveRecord(RecordVariant);
    end;

    /// <summary> 
    /// Saves the supplied record to the currently open archive entry.
    /// </summary>
    /// <param name="RecordRef">The record will be copied to the archive.</param>
    /// <error>The archive must be created or opened first.</error>
    procedure SaveRecord(var RecordRef: RecordRef)
    begin
        DataArchiveImplementation.SaveRecord(RecordRef);
    end;

    /// <summary> 
    /// Saves all records within the filters to the currently open archive entry.
    /// </summary>
    /// <error>The archive must be created or opened first.</error>
    procedure SaveRecords(var RecordRef: RecordRef)
    begin
        DataArchiveImplementation.SaveRecords(RecordRef);
    end;

    /// <summary> 
    /// Starts subscription to the OnDatabaseDelete trigger and calls SaveRecord with any deleted record.
    /// </summary>
    procedure StartSubscriptionToDelete()
    begin
        DataArchiveImplementation.StartSubscriptionToDelete();
    end;

    /// <summary> 
    /// Starts subscription to the OnDatabaseDelete trigger and calls SaveRecord with any deleted record.
    /// </summary>
    procedure StartSubscriptionToDelete(ResetSession: Boolean)
    begin
        DataArchiveImplementation.StartSubscriptionToDelete(ResetSession);
    end;

    /// <summary> 
    /// Stops the subscription to the OnDatabaseDelete trigger.
    /// </summary>
    procedure StopSubscriptionToDelete()
    begin
        DataArchiveImplementation.StopSubscriptionToDelete();
    end;

    /// <summary> 
    /// Informs the consumer app whether there is a provider for this interface.
    /// </summary>
    /// <returns>Returns true if a provider for this interface is installed.</returns>
    procedure DataArchiveProviderExists(): Boolean
    begin
        exit(DataArchiveImplementation.DataArchiveProviderExists());
    end;

    /// <summary> 
    /// Checks if there is an implementation of an IDataArchiveProvider
    /// </summary>
    /// <param name="Exists">A subscriber should set the value to true if it is an implementation of IDataArchiveProvider.</param>
    procedure SetDataArchiveProvider(var NewDataArchiveProvider: Interface "Data Archive Provider")
    begin
        DataArchiveImplementation.SetDataArchiveProvider(NewDataArchiveProvider);
    end;

    /// <summary> 
    /// Checks if there is an implementation of an IDataArchiveProvider
    /// </summary>
    /// <param name="Exists">A subscriber should set the value to true if it is an implementation of IDataArchiveProvider.</param>
    [IntegrationEvent(false, false)]
    internal procedure OnDataArchiveImplementationExists(var Exists: Boolean)
    begin
    end;

    /// <summary> 
    /// Asks for an implementation of an IDataArchiveProvider
    /// </summary>
    /// <param name="ResetSession">If true, then the session will be reset. This can be necessary if a deletion has already been made on any table that should be archived.</param>
    /// <param name="DataArchiveProvider">The data archive provider that should be called from the OnDelete Events. Typically it will be 'this' codeunit.</param>
    /// <param name="IsBound">The first subscriber should set this parameter to true. If it was already true, the code should just exit immediately without binding a provider.</param>
    [IntegrationEvent(false, false)]
    internal procedure OnDataArchiveImplementationBind(var IDataArchiveProvider: Interface "Data Archive Provider"; var IsBound: Boolean)
    begin
    end;
}