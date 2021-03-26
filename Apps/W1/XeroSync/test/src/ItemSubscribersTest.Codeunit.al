codeunit 139514 "XS Item Subscribers Test"
{
    // [FEATURE] [Item Subscribers]
    Subtype = Test;

    var
        LibrarySynchronize: Codeunit "XS Library - Synchronize";
        Assert: Codeunit Assert;
        LibraryLowerPermissions: Codeunit "Library - Lower Permissions";
        IsInitialized: Boolean;

    [Test]
    procedure TestCreateSyncChangeOnAfterCreateItem()
    var
        Item: Record Item;
        SyncChange: Record "Sync Change";
        JsonObjectHelper: Codeunit "XS Json Object Helper";
        RecordRef: RecordRef;
        ItemObject: JsonObject;
    begin
        Initialize();

        LibraryLowerPermissions.SetInvoiceApp();

        // [Given]
        LibrarySynchronize.Initialize(Database::Item);

        // [When] When an Item is created
        LibrarySynchronize.CreateItem(Item);

        // [Then] Sync Change (Direction - Outgoing, Type - Create, Internal ID - RecordId of that Item) for that record is created
        LibrarySynchronize.GetLastCreatedSyncChange(SyncChange);
        Assert.IsTrue(SyncChange.Direction = SyncChange.Direction::Outgoing, 'Created Sync Change should be Outgoing (Direction).');
        Assert.IsTrue(SyncChange."Change Type" = SyncChange."Change Type"::Create, 'Created Sync Change should be Create (Type)');
        Assert.IsTrue(SyncChange."Internal ID" = Item.RecordId(), 'Created Sync Change should have Internal Id equal to the crated Item''s RecordId');

        RecordRef.GetTable(SyncChange);
        ItemObject := JsonObjectHelper.GetBLOBDataAsJsonObject(RecordRef, SyncChange.FieldNo("NAV Data"));
        JsonObjectHelper.SetJsonObject(ItemObject);
        Assert.AreEqual(Item."No.", JsonObjectHelper.GetJsonValueAsText('Code'), 'A different Code was expected.');
        Assert.AreEqual(Item.Description, JsonObjectHelper.GetJsonValueAsText('Name'), 'A different Name was expected.');
        Assert.AreEqual(Item.Description, JsonObjectHelper.GetJsonValueAsText('Description'), 'A different Description was expected.');
        Assert.AreEqual('false', JsonObjectHelper.GetJsonValueAsText('IsTrackedAsInventory'), 'A different IsTrackedAsInventory was expected.');
    end;

    [Test]
    procedure TestCreateSyncChangeOnAfterUpdateItem()
    var
        Item: Record Item;
        SyncChange: Record "Sync Change";
        JsonObjectHelper: Codeunit "XS Json Object Helper";
        RecordRef: RecordRef;
        ItemObject: JsonObject;
        Token: JsonToken;
        SalesDetails: JsonObject;
    begin
        Initialize();

        LibraryLowerPermissions.SetInvoiceApp();

        // [Given] Item that is already synchronised with Xero (Sync Mapping exists)
        LibrarySynchronize.Initialize(Database::Item);
        Item.Get(LibrarySynchronize.CreateEntityAndSynchronizeItWithXero(Database::Item));

        // [When] When an Item is updated 
        LibrarySynchronize.UpdateItem(Item);

        // [Then] Sync Change (Direction - Outgoing, Type - Update, Internal ID - RecordId of that Item) for that record is created
        LibrarySynchronize.GetLastCreatedSyncChange(SyncChange);
        Assert.IsTrue(SyncChange.Direction = SyncChange.Direction::Outgoing, 'Created Sync Change should be Outgoing (Direction).');
        Assert.IsTrue(SyncChange."Change Type" = SyncChange."Change Type"::Update, 'Created Sync Change should be Update (Type)');
        Assert.IsTrue(SyncChange."Internal ID" = Item.RecordId(), 'Created Sync Change should have Internal Id equal to the crated Item''s RecordId');

        RecordRef.GetTable(SyncChange);
        ItemObject := JsonObjectHelper.GetBLOBDataAsJsonObject(RecordRef, SyncChange.FieldNo("NAV Data"));
        JsonObjectHelper.SetJsonObject(ItemObject);
        Assert.AreEqual(Item."No.", JsonObjectHelper.GetJsonValueAsText('Code'), 'A different Code was expected.');
        Assert.AreEqual(Item.Description, JsonObjectHelper.GetJsonValueAsText('Name'), 'A different Name was expected.');
        Assert.AreEqual(Item.Description, JsonObjectHelper.GetJsonValueAsText('Description'), 'A different Description was expected.');
        Assert.AreEqual('false', JsonObjectHelper.GetJsonValueAsText('IsTrackedAsInventory'), 'A different IsTrackedAsInventory was expected.');
        Assert.AreEqual('true', JsonObjectHelper.GetJsonValueAsText('IsSold'), 'A different IsSold was expected.');
        Token := JsonObjectHelper.GetJsonToken('SalesDetails');
        SalesDetails := Token.AsObject();
        JsonObjectHelper.SetJsonObject(SalesDetails);
        Assert.AreEqual(Item."Unit Price", JsonObjectHelper.GetJsonValueAsDecimal('UnitPrice'), 'A different UnitPrice was expected.');
    end;

    [Test]
    procedure TestCreateSyncChangeOnAfterDeleteItem()
    var
        Item: Record Item;
        SyncChange: Record "Sync Change";
    begin
        Initialize();

        LibraryLowerPermissions.SetInvoiceApp();

        // [Given] Item that is already synchronised with Xero (Sync Mapping exists)
        LibrarySynchronize.Initialize(Database::Item);
        Item.Get(LibrarySynchronize.CreateEntityAndSynchronizeItWithXero(Database::Item));

        // [When] When an Item is deleted 
        LibrarySynchronize.DeleteItem(Item);

        // [Then] Sync Change (Direction - Outgoing, Type - Delete, Internal ID - RecordId of that Item) for that record is created
        LibrarySynchronize.GetLastCreatedSyncChange(SyncChange);
        Assert.IsTrue(SyncChange.Direction = SyncChange.Direction::Outgoing, 'Created Sync Change should be Outgoing (Direction).');
        Assert.IsTrue(SyncChange."Change Type" = SyncChange."Change Type"::Delete, 'Created Sync Change should be Delete (Type)');
        Assert.IsTrue(SyncChange."Internal ID" = Item.RecordId(), 'Created Sync Change should have Internal Id equal to the crated Item''s RecordId');
    end;

    [Test]
    procedure TestDoNotCreateDeleteSyncChangeIfNoSyncMapping()
    var
        Item: Record Item;
    begin
        Initialize();

        LibraryLowerPermissions.SetInvoiceApp();

        // [Scenario] This refers to Customers and Items that are created before this app is installed. They will be synchronized with Xero only if they are modified after the app is installed.         
        // [Given] Item that is not synchronised with Xero (Sync Mapping doesn't exist)
        LibrarySynchronize.Initialize(Database::Item);
        Item.Get(LibrarySynchronize.CreateEntityThatExixtsFromBeforeAppIsInstalledAndIsNotSynchronizedWithXero(Database::Item));

        // [When] When that Item is deleted 
        LibrarySynchronize.DeleteItem(Item);

        // [Then] Sync Change record should not be created
        Assert.TableIsEmpty(DataBase::"Sync Change");
    end;

    [Test]
    procedure TestDeleteSyncChangeIfRecordDeletedBeforeItIsSynchronizedWithXero()
    var
        Item: Record Item;
    begin
        Initialize();

        LibraryLowerPermissions.SetInvoiceApp();

        // [Given] Item that is not synchronised with Xero (Sync Mapping doesn't exist)
        LibrarySynchronize.Initialize(Database::Item);
        LibrarySynchronize.CreateItem(Item);

        // [When] When that Item is deleted 
        LibrarySynchronize.DeleteItem(Item);

        // [Then] Sync Change record should not be created
        Assert.TableIsEmpty(DataBase::"Sync Change");
    end;

    [Test]
    procedure TestCreateSyncMappingAfterProcessingIncomingCreateSyncChange()
    var
        SyncMapping: Record "Sync Mapping";
        SyncChange: Record "Sync Change";
        ProcesXeroChange: Codeunit "XS Process Xero Change";
        ChangeType: Option Create,Update,Delete;
    begin
        Initialize();

        LibraryLowerPermissions.SetInvoiceApp();

        // [Given] Incoming Sync Change (Change Type = Create)
        LibrarySynchronize.Initialize(Database::Item);
        LibrarySynchronize.CreateIncomingSyncChangeForEntity(SyncMapping, ChangeType::Create, Database::Item);
        LibrarySynchronize.GetLastCreatedSyncChange(SyncChange);

        // [When] When that Sync Change is processed
        ProcesXeroChange.ProcessXeroChange(SyncChange);

        // [Then] Sync Mapping record should be created
        LibrarySynchronize.FindCreatedSyncMapping(SyncMapping, Database::Item);
        Assert.TableIsNotEmpty(DataBase::"Sync Mapping");
        Assert.IsTrue(SyncChange."External ID" = SyncMapping."External Id", 'Created Sync Mapping should have External Id equal to the Sync Change''s External Id');
    end;

    [Test]
    procedure TestCreateSyncMappingAfterProcessingOutgoingCreateSyncChange()
    var
        SyncMapping: Record "Sync Mapping";
        SyncChange: Record "Sync Change";
        ProcesXeroChange: Codeunit "XS Process Xero Change";
        ChangeType: Option Create,Update,Delete;
    begin
        Initialize();

        LibraryLowerPermissions.SetInvoiceApp();

        // [Given] Outgoing Sync Change (Change Type = Create)
        LibrarySynchronize.Initialize(Database::Item);
        LibrarySynchronize.CreateOutgoingSyncChangeForEntity(SyncMapping, ChangeType::Create, Database::Item);
        LibrarySynchronize.GetLastCreatedSyncChange(SyncChange);

        // [When] When that Sync Change is processed
        ProcesXeroChange.ProcessXeroChange(SyncChange);

        // [Then] Sync Mapping record should be created
        LibrarySynchronize.FindCreatedSyncMapping(SyncMapping, Database::Item);
        Assert.TableIsNotEmpty(DataBase::"Sync Mapping");
        Assert.IsTrue(SyncChange."Internal ID" = SyncMapping."Internal ID", 'Created Sync Mapping should have Internal Id equal to the Sync Change''s Internal Id');
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
