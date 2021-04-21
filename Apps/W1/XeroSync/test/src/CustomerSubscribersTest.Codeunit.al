codeunit 139515 "XS Customer Subscribers Test"
{
    // [FEATURE] [Customer Subscribers]
    Subtype = Test;
    EventSubscriberInstance = Manual;

    var
        LibrarySynchronize: Codeunit "XS Library - Synchronize";
        Assert: Codeunit Assert;
        LibraryLowerPermissions: Codeunit "Library - Lower Permissions";
        XSCustomerSubscribersTest: Codeunit "XS Customer Subscribers Test";
        IsInitialized: Boolean;

    [Test]
    procedure TestCreateSyncChangeOnAfterCreateCustomer()
    var
        Customer: Record Customer;
        SyncChange: Record "Sync Change";
        CountryRegion: Record "Country/Region";
        JsonObjectHelper: Codeunit "XS Json Object Helper";
        RecordRef: RecordRef;
        CustomerObject: JsonObject;
        AddressObject: JsonObject;
        PhoneObject: JsonObject;
        Token: JsonToken;
        PhoneToken: JsonToken;
    begin
        Initialize();

        BindSubscription(XSCustomerSubscribersTest);

        LibraryLowerPermissions.SetInvoiceApp();

        // [Given] 
        LibrarySynchronize.Initialize(Database::Customer);

        // [When] When a Customer is created
        LibrarySynchronize.CreateCustomer(Customer);

        // [Then] Sync Change (Direction - Outgoing, Type - Create, Internal ID - RecordId of that Customer) for that record is created
        LibrarySynchronize.GetLastCreatedSyncChange(SyncChange);
        Assert.IsTrue(SyncChange.Direction = SyncChange.Direction::Outgoing, 'Created Sync Change should be Outgoing (Direction).');
        Assert.IsTrue(SyncChange."Change Type" = SyncChange."Change Type"::Create, 'Created Sync Change should be Create (Type)');
        Assert.IsTrue(SyncChange."Internal ID" = Customer.RecordId(), 'Created Sync Change should have Internal Id equal to the crated Customer''s RecordId');

        RecordRef.GetTable(SyncChange);
        CustomerObject := JsonObjectHelper.GetBLOBDataAsJsonObject(RecordRef, SyncChange.FieldNo("NAV Data"));
        JsonObjectHelper.SetJsonObject(CustomerObject);
        Assert.AreEqual(Customer.Name, JsonObjectHelper.GetJsonValueAsText('Name'), 'A different Name was expected.');
        Assert.AreEqual(Customer."E-Mail", JsonObjectHelper.GetJsonValueAsText('EmailAddress'), 'A different EmailAddress was expected.');
        Assert.AreEqual(Customer."VAT Registration No.", JsonObjectHelper.GetJsonValueAsText('TaxNumber'), 'A different TaxNumber was expected.');

        Token := JsonObjectHelper.GetJsonToken('Addresses');
        Token.AsArray().Get(0, Token);
        AddressObject := Token.AsObject();
        JsonObjectHelper.SetJsonObject(AddressObject);
        Assert.AreEqual('POBOX', JsonObjectHelper.GetJsonValueAsText('AddressType'), 'A different AddressType was expected.');
        Assert.AreEqual(Customer.Contact, JsonObjectHelper.GetJsonValueAsText('AttentionTo'), 'A different AttentionTo was expected.');
        Assert.AreEqual(Customer.Address, JsonObjectHelper.GetJsonValueAsText('AddressLine1'), 'A different AddressLine1 was expected.');
        Assert.AreEqual(Customer.City, JsonObjectHelper.GetJsonValueAsText('City'), 'A different AddressLine1 was expected.');
        Assert.AreEqual(Customer.County, JsonObjectHelper.GetJsonValueAsText('Region'), 'A different AddressLine1 was expected.');
        Assert.AreEqual(Customer."Post Code", JsonObjectHelper.GetJsonValueAsText('PostalCode'), 'A different AddressLine1 was expected.');
        Assert.AreEqual(CountryRegion.Name, JsonObjectHelper.GetJsonValueAsText('Country'), 'A different AddressLine1 was expected.');

        JsonObjectHelper.SetJsonObject(CustomerObject);
        Token := JsonObjectHelper.GetJsonToken('Phones');
        Token.AsArray().Get(0, PhoneToken);
        PhoneObject := PhoneToken.AsObject();
        JsonObjectHelper.SetJsonObject(PhoneObject);
        Assert.AreEqual('DEFAULT', JsonObjectHelper.GetJsonValueAsText('PhoneType'), 'A different PhoneType was expected.');
        Assert.AreEqual(Customer."Phone No.", JsonObjectHelper.GetJsonValueAsText('PhoneNumber'), 'A different PhoneNumber was expected.');
        Token.AsArray().Get(1, PhoneToken);
        PhoneObject := PhoneToken.AsObject();
        JsonObjectHelper.SetJsonObject(PhoneObject);
        Assert.AreEqual('FAX', JsonObjectHelper.GetJsonValueAsText('PhoneType'), 'A different PhoneType was expected.');
        Assert.AreEqual(Customer."Fax No.", JsonObjectHelper.GetJsonValueAsText('PhoneNumber'), 'A different PhoneNumber was expected.');

        UnBindSubscription(XSCustomerSubscribersTest);
    end;

    [Test]
    procedure TestCreateSyncChangeOnAfterUpdateCustomer()
    var
        Customer: Record Customer;
        SyncChange: Record "Sync Change";
        CountryRegion: Record "Country/Region";
        JsonObjectHelper: Codeunit "XS Json Object Helper";
        RecordRef: RecordRef;
        CustomerObject: JsonObject;
        AddressObject: JsonObject;
        PhoneObject: JsonObject;
        Token: JsonToken;
        PhoneToken: JsonToken;
    begin
        Initialize();

        BindSubscription(XSCustomerSubscribersTest);

        LibraryLowerPermissions.SetInvoiceApp();

        // [Given] Customer that is already synchronised with Xero (Sync Mapping exists)
        LibrarySynchronize.Initialize(Database::Customer);
        Customer.Get(LibrarySynchronize.CreateEntityAndSynchronizeItWithXero(Database::Customer));

        // [When] When a Customer is updated 
        Customer."E-Mail" := 'abc@mail.com';
        Customer.Address := 'some street 1';
        Customer.City := 'some city';
        Customer.County := 'some county';
        Customer."Post Code" := 'some post code';
        CountryRegion.FindFirst();
        Customer."Country/Region Code" := CountryRegion.Code;
        Customer."Phone No." := '123456789';
        Customer."Fax No." := '123456789';
        Customer."VAT Registration No." := '123456789';
        Customer.Contact := 'some contact';
        Customer.Modify();

        // [Then] Sync Change (Direction - Outgoing, Type - Update, Internal ID - RecordId of that Customer) for that record is created
        LibrarySynchronize.GetLastCreatedSyncChange(SyncChange);
        Assert.IsTrue(SyncChange.Direction = SyncChange.Direction::Outgoing, 'Created Sync Change should be Outgoing (Direction).');
        Assert.IsTrue(SyncChange."Change Type" = SyncChange."Change Type"::Update, 'Created Sync Change should be Update (Type)');
        Assert.IsTrue(SyncChange."Internal ID" = Customer.RecordId(), 'Created Sync Change should have Internal Id equal to the crated Customer''s RecordId');

        RecordRef.GetTable(SyncChange);
        CustomerObject := JsonObjectHelper.GetBLOBDataAsJsonObject(RecordRef, SyncChange.FieldNo("NAV Data"));
        JsonObjectHelper.SetJsonObject(CustomerObject);
        Assert.AreEqual(Customer.Name, JsonObjectHelper.GetJsonValueAsText('Name'), 'A different Name was expected.');
        Assert.AreEqual(Customer."E-Mail", JsonObjectHelper.GetJsonValueAsText('EmailAddress'), 'A different EmailAddress was expected.');
        Assert.AreEqual(Customer."VAT Registration No.", JsonObjectHelper.GetJsonValueAsText('TaxNumber'), 'A different TaxNumber was expected.');

        Token := JsonObjectHelper.GetJsonToken('Addresses');
        Token.AsArray().Get(0, Token);
        AddressObject := Token.AsObject();
        JsonObjectHelper.SetJsonObject(AddressObject);
        Assert.AreEqual('POBOX', JsonObjectHelper.GetJsonValueAsText('AddressType'), 'A different AddressType was expected.');
        Assert.AreEqual(Customer.Contact, JsonObjectHelper.GetJsonValueAsText('AttentionTo'), 'A different AttentionTo was expected.');
        Assert.AreEqual(Customer.Address, JsonObjectHelper.GetJsonValueAsText('AddressLine1'), 'A different AddressLine1 was expected.');
        Assert.AreEqual(Customer.City, JsonObjectHelper.GetJsonValueAsText('City'), 'A different AddressLine1 was expected.');
        Assert.AreEqual(Customer.County, JsonObjectHelper.GetJsonValueAsText('Region'), 'A different AddressLine1 was expected.');
        Assert.AreEqual(Customer."Post Code", JsonObjectHelper.GetJsonValueAsText('PostalCode'), 'A different AddressLine1 was expected.');
        Assert.AreEqual(CountryRegion.Name, JsonObjectHelper.GetJsonValueAsText('Country'), 'A different AddressLine1 was expected.');

        JsonObjectHelper.SetJsonObject(CustomerObject);
        Token := JsonObjectHelper.GetJsonToken('Phones');
        Token.AsArray().Get(0, PhoneToken);
        PhoneObject := PhoneToken.AsObject();
        JsonObjectHelper.SetJsonObject(PhoneObject);
        Assert.AreEqual('DEFAULT', JsonObjectHelper.GetJsonValueAsText('PhoneType'), 'A different PhoneType was expected.');
        Assert.AreEqual(Customer."Phone No.", JsonObjectHelper.GetJsonValueAsText('PhoneNumber'), 'A different PhoneNumber was expected.');
        Token.AsArray().Get(1, PhoneToken);
        PhoneObject := PhoneToken.AsObject();
        JsonObjectHelper.SetJsonObject(PhoneObject);
        Assert.AreEqual('FAX', JsonObjectHelper.GetJsonValueAsText('PhoneType'), 'A different PhoneType was expected.');
        Assert.AreEqual(Customer."Fax No.", JsonObjectHelper.GetJsonValueAsText('PhoneNumber'), 'A different PhoneNumber was expected.');

        UnBindSubscription(XSCustomerSubscribersTest);
    end;

    [Test]
    procedure TestCreateSyncChangeOnAfterDeleteCustomer()
    var
        Customer: Record Customer;
        SyncChange: Record "Sync Change";
    begin
        Initialize();

        LibraryLowerPermissions.SetInvoiceApp();

        // [Given] Customer that is already synchronised with Xero (Sync Mapping exists)
        LibrarySynchronize.Initialize(Database::Customer);
        Customer.Get(LibrarySynchronize.CreateEntityAndSynchronizeItWithXero(Database::Customer));

        // [When] When a Customer is deleted 
        LibrarySynchronize.DeleteCustomer(Customer);

        // [Then] Sync Change (Direction - Outgoing, Type - Delete, Internal ID - RecordId of that Customer) for that record is created
        LibrarySynchronize.GetLastCreatedSyncChange(SyncChange);
        Assert.IsTrue(SyncChange.Direction = SyncChange.Direction::Outgoing, 'Created Sync Change should be Outgoing (Direction).');
        Assert.IsTrue(SyncChange."Change Type" = SyncChange."Change Type"::Delete, 'Created Sync Change should be Delete (Type)');
        Assert.IsTrue(SyncChange."Internal ID" = Customer.RecordId(), 'Created Sync Change should have Internal Id equal to the crated Customer''s RecordId');
    end;

    [Test]
    procedure TestDoNotCreateDeleteSyncChangeIfNoSyncMapping()
    var
        Customer: Record Customer;
    begin
        Initialize();

        LibraryLowerPermissions.SetInvoiceApp();

        // [Scenario] This refers to Customers and Items that are created before this app is installed. They will be synchronized with Xero only if they are modified after the app is installed.         
        // [Given] Customer that is not synchronised with Xero (Sync Mapping doesn't exist)
        LibrarySynchronize.Initialize(Database::Customer);
        Customer.Get(LibrarySynchronize.CreateEntityThatExixtsFromBeforeAppIsInstalledAndIsNotSynchronizedWithXero(Database::Customer));

        // [When] When that Customer is deleted 
        LibrarySynchronize.DeleteCustomer(Customer);

        // [Then] Sync Change record should not be created
        Assert.TableIsEmpty(DataBase::"Sync Change");
    end;

    [Test]
    procedure TestDeleteSyncChangeIfRecordDeletedBeforeItIsSynchronizedWithXero()
    var
        Customer: Record Customer;
    begin
        Initialize();

        LibraryLowerPermissions.SetInvoiceApp();

        // [Given] Customer that is not synchronised with Xero (Sync Mapping doesn't exist)
        LibrarySynchronize.Initialize(Database::Customer);
        LibrarySynchronize.CreateCustomer(Customer);

        // [When] When that Customer is deleted 
        LibrarySynchronize.DeleteCustomer(Customer);

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
        LibrarySynchronize.Initialize(Database::Customer);
        LibrarySynchronize.CreateIncomingSyncChangeForEntity(SyncMapping, ChangeType::Create, Database::Customer);
        LibrarySynchronize.GetLastCreatedSyncChange(SyncChange);

        // [When] When that Sync Change is processed
        ProcesXeroChange.ProcessXeroChange(SyncChange);

        // [Then] Sync Mapping record should be created
        LibrarySynchronize.FindCreatedSyncMapping(SyncMapping, Database::Customer);
        Assert.TableIsNotEmpty(DataBase::"Sync Mapping");
        Assert.IsTrue(SyncMapping."External Id" = SyncMapping."External Id", 'Created Sync Mapping should have External Id equal to the Sync Change''s External Id');
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
        LibrarySynchronize.Initialize(Database::Customer);
        LibrarySynchronize.CreateOutgoingSyncChangeForEntity(SyncMapping, ChangeType::Create, Database::Customer);
        LibrarySynchronize.GetLastCreatedSyncChange(SyncChange);

        // [When] When that Sync Change is processed
        ProcesXeroChange.ProcessXeroChange(SyncChange);

        // [Then] Sync Mapping record should be created
        LibrarySynchronize.FindCreatedSyncMapping(SyncMapping, Database::Customer);
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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Application System Constants", 'OnAfterGetApplicationVersion', '', true, true)]
    local procedure OnAfterGetApplicationVersionSubscriber(VAR ApplicationVersion: Text[248])
    begin
        ApplicationVersion := 'GB';
    end;
}