// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
codeunit 610 "Data Archive Implementation" implements "Data Archive Provider"
{
    Access = Internal;

    var
        DataArchiveProvider: Interface "Data Archive Provider";
        IsBound: Boolean;
        IsCreated: Boolean;
        StartedSubscriptionToDelete: Boolean;
        NotCreatedYetErr: Label 'The archive must be created or opened first.';
        AlreadyCreatedErr: Label 'The archive has already been created or opened.';
        NoArchivingAppErr: Label 'You need to install an archiving app to use this feature.';
        DataArchiveCategoryLbl: Label 'Data Archive', Locked = true;
        NewDataArchiveLbl: Label 'New Data Archive', Locked = true;

    procedure Create(Description: Text): Integer
    begin
        if IsCreated then
            Error(AlreadyCreatedErr);
        if not IsBound then
            BindImplementation();
        if not IsBound then
            Error(NoArchivingAppErr);
        IsCreated := true;
        exit(DataArchiveProvider.Create(Description));
    end;

    procedure CreateAndStartLoggingDeletions(Description: Text): Integer
    var
        NewEntryNo: Integer;
    begin
        NewEntryNo := Create(Description);
        StartSubscriptionToDelete();
        exit(NewEntryNo);
    end;

    procedure Open(ID: Integer)
    begin
        if IsCreated then
            Error(AlreadyCreatedErr);
        if not IsBound then
            BindImplementation();
        if not IsBound then
            Error(NoArchivingAppErr);
        DataArchiveProvider.Open(ID);
    end;

    procedure Save()
    begin
        TestIsCreated();
        DataArchiveProvider.Save();
        if StartedSubscriptionToDelete then
            StopSubscriptionToDelete();
        Session.LogMessage('0000FG4', NewDataArchiveLbl, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', DataArchiveCategoryLbl);
    end;

    procedure DiscardChanges()
    begin
        TestIsCreated();
        DataArchiveProvider.DiscardChanges();
    end;

    procedure SaveRecord(var RecordRef: RecordRef)
    begin
        TestIsCreated();
        DataArchiveProvider.SaveRecord(RecordRef);
    end;

    procedure SaveRecord(RecordVariant: Variant)
    begin
        TestIsCreated();
        DataArchiveProvider.SaveRecord(RecordVariant);
    end;

    procedure SaveRecords(var RecordRef: RecordRef)
    begin
        TestIsCreated();
        DataArchiveProvider.SaveRecords(RecordRef);
    end;

    procedure StartSubscriptionToDelete()
    begin
        StartSubscriptionToDelete(true);
    end;

    procedure StartSubscriptionToDelete(ResetSession: Boolean)
    begin
        TestIsCreated();
        if StartedSubscriptionToDelete then
            exit;
        DataArchiveProvider.StartSubscriptionToDelete(ResetSession);
    end;

    procedure StopSubscriptionToDelete()
    begin
        TestIsCreated();
        if not StartedSubscriptionToDelete then
            exit;
        DataArchiveProvider.StopSubscriptionToDelete();
    end;

    procedure DataArchiveProviderExists(): Boolean
    var
        DataArchive: Codeunit "Data Archive";
        ProviderExists: Boolean;
    begin
        DataArchive.OnDataArchiveImplementationExists(ProviderExists);
        exit(ProviderExists);
    end;

    local procedure TestIsCreated()
    begin
        if not IsCreated then
            Error(NotCreatedYetErr);
    end;

    procedure SetDataArchiveProvider(var IDataArchiveProvider: Interface "Data Archive Provider")
    begin
        if not IsBound then
            Error(NoArchivingAppErr);
        DataArchiveProvider := IDataArchiveProvider;
        DataArchiveProvider.SetDataArchiveProvider(DataArchiveProvider);
    end;

    local procedure BindImplementation()
    var
        DataArchive: Codeunit "Data Archive";
        IDataArchiveProvider: Interface "Data Archive Provider";
    begin
        DataArchive.OnDataArchiveImplementationBind(IDataArchiveProvider, IsBound);
        if IsBound then
            SetDataArchiveProvider(IDataArchiveProvider);
    end;
}