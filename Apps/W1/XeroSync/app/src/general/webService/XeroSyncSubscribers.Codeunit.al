codeunit 2427 "XS Xero Sync Subscribers"
{
    var
        ChangeType: Option Create,Update,Delete," ";
        XeroFeatureSwitchTxt: Label 'xero-allowed';
        XeroSyncWizardTitleLbl: Label 'Xero Sync Online';
        XeroSyncWizardDescriptionLbl: Label 'Share customers and items.';

        // Initial Xero Setup
    [EventSubscriber(ObjectType::Page, Page::"O365 Import Export Settings", 'OnInsertMenuItems', '', false, false)]
    local procedure OnInsertMenuItemsSubscriber(var O365SettingsMenu: Record "O365 Settings Menu")
    var
        AzureKeyVault: Codeunit "Azure Key Vault";
        IsXeroEnabledTxt: Text;
        IsXeroEnabled: Boolean;
    begin
        if not AzureKeyVault.GetAzureKeyVaultSecret(XeroFeatureSwitchTxt, IsXeroEnabledTxt) then
            exit;
        if IsXeroEnabledTxt = '' then
            exit;
        Evaluate(IsXeroEnabled, IsXeroEnabledTxt);
        if not IsXeroEnabled then
            exit;
        O365SettingsMenu.InsertPageMenuItem(Page::"XS Xero Synchronization Wizard", CopyStr(XeroSyncWizardTitleLbl, 1, 30), CopyStr(XeroSyncWizardDescriptionLbl, 1, 80));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Integration Management", 'OnGetIntegrationActivated', '', false, false)]
    procedure OnGetIntegrationActivatedSubscriber(var IsSyncEnabled: Boolean)
    var
        XeroSyncSetup: Record "Sync Setup";
        AzureKeyVault: Codeunit "Azure Key Vault";
        IsXeroEnabledTxt: Text;
        IsXeroEnabled: Boolean;
    begin
        if IsSyncEnabled then
            exit;

        if not AzureKeyVault.GetAzureKeyVaultSecret(XeroFeatureSwitchTxt, IsXeroEnabledTxt) then
            exit;
        if IsXeroEnabledTxt = '' then
            exit;
        Evaluate(IsXeroEnabled, IsXeroEnabledTxt);
        if not IsXeroEnabled then
            exit;

        XeroSyncSetup.GetSingleInstance();

        IsSyncEnabled := XeroSyncSetup."XS Enabled";
    end;

    // Synchronization
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sync Job", 'OnStartSync', '', false, false)]
    local procedure OnStartSyncHandler(var SyncSetup: Record "Sync Setup")
    var
        JobQueueFunctionsLibrary: Codeunit "XS Job Queue Management";
    begin
        if not SyncSetup.SynchronizationIsSetUp() then
            exit;

        SyncSetup."XS Xero Start Sync Time" := CurrentDateTime();
        SyncSetup.Modify();

        if JobQueueFunctionsLibrary.RemoveScheduledJobTaskIfUserInactive() then
            exit;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sync Job", 'OnGetChanges', '', false, false)]
    local procedure OnGetChangesForItems(var SyncChange: Record "Sync Change"; SyncSetup: Record "Sync Setup")
    begin
        if not SyncSetup.SynchronizationIsSetUp() then
            exit;

        SyncChange.GetChangesFromXero(SyncSetup, Database::Item, '');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sync Job", 'OnGetChanges', '', false, false)]
    local procedure OnGetChangesForCustomers(var SyncChange: Record "Sync Change"; SyncSetup: Record "Sync Setup")
    begin
        if not SyncSetup.SynchronizationIsSetUp() then
            exit;

        SyncChange.GetChangesFromXero(SyncSetup, Database::Customer, '');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sync Job", 'OnDiscoverDeletions', '', false, false)]
    procedure OnDiscoverItemDeletionsFromXero()
    var
        SyncChange: Record "Sync Change";
    begin
        SyncChange.CreateIncomingDeleteSyncChangeForEntity(Database::Item);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sync Job", 'OnDiscoverDeletions', '', false, false)]
    procedure OnDiscoverCustomerDeletionsFromXero()
    var
        SyncChange: Record "Sync Change";
    begin
        SyncChange.CreateIncomingDeleteSyncChangeForEntity(Database::Customer);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sync Job", 'OnProcessChange', '', false, false)]
    procedure OnProcessChangeHandler(var SyncChange: Record "Sync Change"; SyncSetup: Record "Sync Setup"; var Success: Boolean)
    begin
        if not SyncSetup.SynchronizationIsSetUp() then
            exit;

        Success := SyncChange.ProcessXeroChange();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sync Job", 'OnCreateJobQueueEntryLogForUnsuccessfulSync', '', false, false)]
    local procedure OnCreateJobQueueEntryLogForUnsuccessfulSyncHandler(var JobQueueEntry: Record "Job Queue Entry"; ErrorMessage: Text)
    var
        JobQueueFunctionsLibrary: Codeunit "XS Job Queue Management";
    begin
        JobQueueFunctionsLibrary.CreateJobQueueEntryLogForUnsuccessfulSync(JobQueueEntry, ErrorMessage);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sync Job", 'OnEndSync', '', false, false)]
    local procedure OnEndSyncHandler(var SyncSetup: Record "Sync Setup")
    begin
        if not SyncSetup.SynchronizationIsSetUp() then
            exit;

        SyncSetup."XS Xero Last Sync Time" := SyncSetup."XS Xero Start Sync Time";
        SyncSetup."Last Sync Time" := SyncSetup."XS Xero Start Sync Time";
        SyncSetup.Modify();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sync Job", 'OnInitialSync', '', false, false)]
    local procedure OnInitialSync()
    var
        SyncSetup: Record "Sync Setup";
    begin
        SyncSetup.GetSingleInstance();
        if not SyncSetup.SynchronizationIsSetUp() then
            exit;

        GetFromXero(SyncSetup);
        PushToXero();
    end;

    local procedure GetFromXero(SyncSetup: Record "Sync Setup")
    var
        SyncChange: Record "Sync Change";
    begin
        SyncChange.GetChangesFromXero(SyncSetup, Database::Customer, '');
        SyncChange.GetChangesFromXero(SyncSetup, Database::Item, '');
    end;

    local procedure PushToXero()
    var
        Customer: Record Customer;
        Item: Record Item;
    begin
        If Customer.FindSet() then
            repeat
                QueueRecordForSync(Customer);
            until Customer.Next() = 0;

        If Item.FindSet() then
            repeat
                QueueRecordForSync(Item);
            until Item.Next() = 0;
    end;


    local procedure QueueRecordForSync(RecordVariant: Variant)
    var
        SyncChange: Record "Sync Change";
        RecRef: RecordRef;
    begin
        RecRef.GetTable(RecordVariant);
        SyncChange.Init();
        SyncChange.QueueOutgoingChangeForEntity(RecRef, ChangeType::" ");
    end;
}