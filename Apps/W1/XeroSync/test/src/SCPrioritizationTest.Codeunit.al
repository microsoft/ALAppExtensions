codeunit 139512 "XS SC Prioritization Test"
{
    // [FEATURE] [Sync Change Prioritization] [Sync Management - Sync Base]
    Subtype = Test;

    var
        LibrarySynchronize: Codeunit "XS Library - Synchronize";
        Assert: Codeunit Assert;
        LibraryLowerPermissions: Codeunit "Library - Lower Permissions";
        ChangeType: Option Create,Update,Delete;
        IsInitialized: Boolean;

    [Test]
    procedure TestSyncChangePrioritizationIncomingUpdateOutgoingUpdateForCustomer()
    var
        SyncMapping: Record "Sync Mapping";
        SyncChange: Record "Sync Change";
        SyncManagement: Codeunit "Sync Management";
    begin
        Initialize();

        LibraryLowerPermissions.SetInvoiceApp();

        // [Given] Incoming and Outgoing Sync Change (Update) for Customer that is already synchronized with Xero (Sync Mapping exists)
        LibrarySynchronize.Initialize(Database::Customer);
        LibrarySynchronize.CreateOutgoingSyncChangeForEntity(SyncMapping, ChangeType::Update, Database::Customer);
        LibrarySynchronize.CreateIncomingSyncChangeForEntity(SyncMapping, ChangeType::Update, Database::Customer);

        // [When] Merge Sync Changes is run
        SyncManagement.MergeSyncChanges();

        // [Then] Sync changes that affect the same record should be compared and outgoing update sync change should win
        LibrarySynchronize.GetLastCreatedSyncChange(SyncChange);
        Assert.IsTrue(SyncChange.Count() = 1, 'Sync Changes should be compared and only one should left.');
        Assert.IsTrue(SyncChange.Direction = SyncChange.Direction::Bidirectional, 'Outgoing sync change should win and direction should be changed to Bidirectional.');
        Assert.IsTrue(SyncChange."Change Type" = SyncChange."Change Type"::Update, 'Change type should be Update.');
    end;

    [Test]
    procedure TestSyncChangePrioritizationIncomingUpdateOutgoingDeleteForCustomer()
    var
        SyncMapping: Record "Sync Mapping";
        SyncChange: Record "Sync Change";
        SyncManagement: Codeunit "Sync Management";
    begin
        Initialize();

        LibraryLowerPermissions.SetInvoiceApp();

        // [Given] Incoming update and Outgoing delete Sync Change for Customer that is already synchronized with Xero (Sync Mapping exists)
        LibrarySynchronize.Initialize(Database::Customer);
        LibrarySynchronize.CreateOutgoingSyncChangeForEntity(SyncMapping, ChangeType::Delete, Database::Customer);
        LibrarySynchronize.CreateIncomingSyncChangeForEntity(SyncMapping, ChangeType::Update, Database::Customer);

        // [When]  Merge Sync Changes is run
        SyncManagement.MergeSyncChanges();

        // [Then] Sync changes that affect the same record should be compared and outgoing delete sync change should win
        LibrarySynchronize.GetLastCreatedSyncChange(SyncChange);
        Assert.IsTrue(SyncChange.Count() = 1, 'Changes should be compared and only one should left.');
        Assert.IsTrue(SyncChange.Direction = SyncChange.Direction::Bidirectional, 'Outgoing sync change should win and direction should be changed to Bidirectional.');
        Assert.IsTrue(SyncChange."Change Type" = SyncChange."Change Type"::Delete, 'Change type should be Delete.');
    end;

    [Test]
    procedure TestSyncChangePrioritizationIncomingDeleteOutgoingDeleteForCustomer()
    var
        SyncMapping: Record "Sync Mapping";
        SyncChange: Record "Sync Change";
        SyncManagement: Codeunit "Sync Management";
    begin
        Initialize();

        LibraryLowerPermissions.SetInvoiceApp();

        // [Given] Incoming delete and Outgoing delete Sync Change for Customer that is already synchronized with Xero (Sync Mapping exists)
        LibrarySynchronize.Initialize(Database::Customer);
        LibrarySynchronize.CreateOutgoingSyncChangeForEntity(SyncMapping, ChangeType::Delete, Database::Customer);
        LibrarySynchronize.CreateIncomingSyncChangeForEntity(SyncMapping, ChangeType::Delete, Database::Customer);

        // [When] Merge Sync Changes is run
        SyncManagement.MergeSyncChanges();

        // [Then] Sync changes that affect the same record should be compared and, because the both changes are delete (the record is deleted in both systems), sync change should be deleted
        Assert.IsTrue(SyncChange.Count() = 0, 'Changes should be compared and, because the both changes are Delete, they both should be deleted from the Sync queue.');
    end;

    [Test]
    procedure TestSyncChangePrioritizationIncomingDeleteOutgoingUpdateForCustomer()
    var
        SyncMapping: Record "Sync Mapping";
        SyncChange: Record "Sync Change";
        SyncManagement: Codeunit "Sync Management";
    begin
        Initialize();

        LibraryLowerPermissions.SetInvoiceApp();

        // [Given] Incoming delete and Outgoing update Sync Change for Customer that is already synchronized with Xero (Sync Mapping exists)
        LibrarySynchronize.Initialize(Database::Customer);
        LibrarySynchronize.CreateOutgoingSyncChangeForEntity(SyncMapping, ChangeType::Update, Database::Customer);
        LibrarySynchronize.CreateIncomingSyncChangeForEntity(SyncMapping, ChangeType::Delete, Database::Customer);

        // [When] Merge Sync Changes is run
        SyncManagement.MergeSyncChanges();

        // [Then] Sync changes that affect the same record should be compared and incoming delete sync change should win
        LibrarySynchronize.GetLastCreatedSyncChange(SyncChange);
        Assert.IsTrue(SyncChange.Count() = 1, 'Changes should be compared and only one should left.');
        Assert.IsTrue(SyncChange.Direction = SyncChange.Direction::Incoming, 'Incoming sync change should win.');
        Assert.IsTrue(SyncChange."Change Type" = SyncChange."Change Type"::Delete, 'Change type should be Delete.');
    end;

    [Test]
    procedure TestSyncChangePrioritizationIncomingUpdateOutgoingUpdateForItem()
    var
        SyncMapping: Record "Sync Mapping";
        SyncChange: Record "Sync Change";
        SyncManagement: Codeunit "Sync Management";
    begin
        Initialize();

        LibraryLowerPermissions.SetInvoiceApp();

        // [Given] Incoming and Outgoing Sync Change (Update) for Item that is already synchronized with Xero (Sync Mapping exists)
        LibrarySynchronize.Initialize(Database::Item);
        LibrarySynchronize.CreateOutgoingSyncChangeForEntity(SyncMapping, ChangeType::Update, Database::Item);
        LibrarySynchronize.CreateIncomingSyncChangeForEntity(SyncMapping, ChangeType::Update, Database::Item);

        // [When] Merge Sync Changes is run
        SyncManagement.MergeSyncChanges();

        // [Then] Sync changes that affect the same record should be compared and outgoing update sync change should win
        LibrarySynchronize.GetLastCreatedSyncChange(SyncChange);
        Assert.IsTrue(SyncChange.Count() = 1, 'Sync Changes should be compared and only one should left.');
        Assert.IsTrue(SyncChange.Direction = SyncChange.Direction::Bidirectional, 'Outgoing sync change should win and direction should be changed to Bidirectional.');
        Assert.IsTrue(SyncChange."Change Type" = SyncChange."Change Type"::Update, 'Change type should be Update.');
    end;

    [Test]
    procedure TestSyncChangePrioritizationIncomingUpdateOutgoingDeleteForItem()
    var
        SyncMapping: Record "Sync Mapping";
        SyncChange: Record "Sync Change";
        SyncManagement: Codeunit "Sync Management";
    begin
        Initialize();

        LibraryLowerPermissions.SetInvoiceApp();

        // [Given] Incoming update and Outgoing delete Sync Change for Item that is already synchronized with Xero (Sync Mapping exists)
        LibrarySynchronize.Initialize(Database::Item);
        LibrarySynchronize.CreateOutgoingSyncChangeForEntity(SyncMapping, ChangeType::Delete, Database::Item);
        LibrarySynchronize.CreateIncomingSyncChangeForEntity(SyncMapping, ChangeType::Update, Database::Item);

        // [When]  Merge Sync Changes is run
        SyncManagement.MergeSyncChanges();

        // [Then] Sync changes that affect the same record should be compared and outgoing delete sync change should win
        LibrarySynchronize.GetLastCreatedSyncChange(SyncChange);
        Assert.IsTrue(SyncChange.Count() = 1, 'Changes should be compared and only one should left.');
        Assert.IsTrue(SyncChange.Direction = SyncChange.Direction::Bidirectional, 'Outgoing sync change should win and direction should be changed to Bidirectional.');
        Assert.IsTrue(SyncChange."Change Type" = SyncChange."Change Type"::Delete, 'Change type should be Delete.');
    end;

    [Test]
    procedure TestSyncChangePrioritizationIncomingDeleteOutgoingDeleteForItem()
    var
        SyncMapping: Record "Sync Mapping";
        SyncChange: Record "Sync Change";
        SyncManagement: Codeunit "Sync Management";
    begin
        Initialize();

        LibraryLowerPermissions.SetInvoiceApp();

        // [Given] Incoming delete and Outgoing delete Sync Change for Item that is already synchronized with Xero (Sync Mapping exists)
        LibrarySynchronize.Initialize(Database::Item);
        LibrarySynchronize.CreateOutgoingSyncChangeForEntity(SyncMapping, ChangeType::Delete, Database::Item);
        LibrarySynchronize.CreateIncomingSyncChangeForEntity(SyncMapping, ChangeType::Delete, Database::Item);

        // [When] Merge Sync Changes is run
        SyncManagement.MergeSyncChanges();

        // [Then] Sync changes that affect the same record should be compared and, because the both changes are delete (the record is deleted in both systems), sync change should be deleted
        Assert.IsTrue(SyncChange.Count() = 0, 'Changes should be compared and, because the both changes are Delete, they both should be deleted from the Sync queue.');
    end;

    [Test]
    procedure TestSyncChangePrioritizationIncomingDeleteOutgoingUpdateForItem()
    var
        SyncMapping: Record "Sync Mapping";
        SyncChange: Record "Sync Change";
        SyncManagement: Codeunit "Sync Management";
    begin
        Initialize();

        LibraryLowerPermissions.SetInvoiceApp();

        // [Given] Incoming delete and Outgoing update Sync Change for Item that is already synchronized with Xero (Sync Mapping exists)
        LibrarySynchronize.Initialize(Database::Item);
        LibrarySynchronize.CreateOutgoingSyncChangeForEntity(SyncMapping, ChangeType::Update, Database::Item);
        LibrarySynchronize.CreateIncomingSyncChangeForEntity(SyncMapping, ChangeType::Delete, Database::Item);

        // [When] Merge Sync Changes is run
        SyncManagement.MergeSyncChanges();

        // [Then] Sync changes that affect the same record should be compared and incoming delete sync change should win
        LibrarySynchronize.GetLastCreatedSyncChange(SyncChange);
        Assert.IsTrue(SyncChange.Count() = 1, 'Changes should be compared and only one should left.');
        Assert.IsTrue(SyncChange.Direction = SyncChange.Direction::Incoming, 'Incoming sync change should win.');
        Assert.IsTrue(SyncChange."Change Type" = SyncChange."Change Type"::Delete, 'Change type should be Delete.');
    end;

    local procedure Initialize()
    var
        SyncSetup: Record "Sync Setup";
    begin
        if IsInitialized then
            exit;
        IsInitialized := true;

        SyncSetup.GetSingleInstance();
        SyncSetup."XS Enabled" := true;
        SyncSetup.Modify();
    end;
}
