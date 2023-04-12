// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// The Record Reference interface provides a method for delegating read/write operations for tables that require indirect permissions.
/// Use the Record Reference codeunit to intialize the interface with an implementation that has the required permissions.
/// </summary>
codeunit 3917 "Record Reference"
{
    Access = Public;
    InherentEntitlements = X;
    InherentPermissions = X;

    /// <summary>
    /// Initializes the Record Reference interface. The method raises the OnInitialize event. If no subscriber initializes the interface, a default implementation is assigned.
    /// </summary>
    /// <param name="RecordRef">The RecordRef parameter points to the table for which the read/write operations are to be handled by the interface.</param>
    /// <param name="RecordReference">The interface providing read/write operations.</param>
    procedure Initialize(RecordRef: RecordRef; var RecordReference: Interface "Record Reference")
    var
        RecordReferenceImpl: Codeunit "Record Reference Impl.";
        CallerModule: ModuleInfo;
    begin
        NavApp.GetCallerModuleInfo(CallerModule);
        RecordReferenceImpl.Initialize(RecordRef, RecordReference, CallerModule);
    end;

    /// <summary>
    /// Use this event to initialize the Record Reference interface with an implementation that has the required indirect permissions to read write to the table referenced by the RecordRef parameter.
    /// </summary>
    /// <param name="RecordRef">The RecordRef parameter points to the table for which the read/write operations are to be handled by the interface.</param>
    /// <param name="RecordReference">The interface providing read/write operations.</param>
    /// <param name="CallerModule">A ModuleInfo pointing to the app information of the app that called the Initialize method.</param>
    /// <param name="IsInitialized">Set this to true when the interface is initialized.</param>
    [IntegrationEvent(false, false, false)]
    internal procedure OnInitialize(RecordRef: RecordRef; var RecordReference: Interface "Record Reference"; CallerModuleInfo: ModuleInfo; var IsInitialized: Boolean)
    begin
    end;
}