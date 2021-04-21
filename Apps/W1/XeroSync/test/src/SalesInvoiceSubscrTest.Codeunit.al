codeunit 139513 "XS Sales Invoice Subscr. Test"
{
    // [FEATURE] [Sales Invoice Subscribers]
    Subtype = Test;
    EventSubscriberInstance = Manual;

    var
        LibrarySynchronize: Codeunit "XS Library - Synchronize";
        Assert: Codeunit Assert;
        MockSalesInvoicePosting: Codeunit "XS Mock Sales Invoice Posting";
        LibraryLowerPermissions: Codeunit "Library - Lower Permissions";
        XSSalesInvoiceSubscrTest: Codeunit "XS Sales Invoice Subscr. Test";
        LibrarySales: Codeunit "Library - Sales";
        IsInitialized: Boolean;

    [Test]
    procedure TestCreateSyncChangeOnAfterPostSalesInvoice()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        Customer: Record Customer;
        Item: Record Item;
        CountryRegion: Record "Country/Region";
        SyncChange: Record "Sync Change";
        JsonObjectHelper: Codeunit "XS Json Object Helper";
        PostedSalesInvoiceRecordId: RecordId;
        RecordRef: RecordRef;
        Token: JsonToken;
        PhoneToken: JsonToken;
        InvoiceObject: JsonObject;
        CustomerObject: JsonObject;
        AddressObject: JsonObject;
        PhoneObject: JsonObject;
        LineObject: JsonObject;
    begin
        Initialize();

        LibraryLowerPermissions.SetInvoiceApp();

        // [Given] Customer and Item that are already synched with Xero
        SetBindingsForPosting();
        BindSubscription(XSSalesInvoiceSubscrTest);
        LibrarySynchronize.Initialize(Database::"Sales Header");
        Customer.Get(LibrarySynchronize.CreateEntityAndSynchronizeItWithXero(Database::Customer));

        Item.Get(LibrarySynchronize.CreateEntityAndSynchronizeItWithXero(Database::Item));
        Item."XS Account Code" := '200';
        Item."XS Tax Type" := 'OUTPUT';
        Item.Modify();

        // [When] When Sales Invoice is posted 
        LibrarySynchronize.CreateSalesInvoice(SalesHeader, SalesLine, Customer."No.", Item."No.");
        LibrarySales.PostSalesDocument(SalesHeader, true, true);

        MockSalesInvoicePosting.GetPostedSalesInvoiceRecordId(PostedSalesInvoiceRecordId);

        // [Then] Sync Change (Direction - Outgoing, Type - Create, Internal ID - RecordId of that Sales Invoice) for that record is created
        LibrarySynchronize.GetLastCreatedSyncChange(SyncChange);
        Assert.IsTrue(SyncChange.Direction = SyncChange.Direction::Outgoing, 'Created Sync Change should be Outgoing (Direction).');
        Assert.IsTrue(SyncChange."Change Type" = SyncChange."Change Type"::Create, 'Created Sync Change should be Create (Type)');
        Assert.IsTrue(SyncChange."Internal ID" = PostedSalesInvoiceRecordId, 'Created Sync Change should have Internal Id equal to the crated Sales Invoice RecordId');

        RecordRef.GetTable(SyncChange);
        InvoiceObject := JsonObjectHelper.GetBLOBDataAsJsonObject(RecordRef, SyncChange.FieldNo("NAV Data"));
        JsonObjectHelper.SetJsonObject(InvoiceObject);
        Assert.AreEqual('ACCREC', JsonObjectHelper.GetJsonValueAsText('Type'), 'A different type was expected.');

        Token := JsonObjectHelper.GetJsonToken('Contact');
        CustomerObject := Token.AsObject();
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

        JsonObjectHelper.SetJsonObject(InvoiceObject);
        Token := JsonObjectHelper.GetJsonToken('LineItems');
        Token.AsArray().Get(0, Token);
        LineObject := Token.AsObject();
        JsonObjectHelper.SetJsonObject(LineObject);
        Assert.AreEqual(Item.Description, JsonObjectHelper.GetJsonValueAsText('Description'), 'A different Description was expected.');
        Assert.AreEqual(SalesLine.Quantity, JsonObjectHelper.GetJsonValueAsDecimal('Quantity'), 'A different Quantity was expected.');
        Assert.AreEqual(SalesLine."Unit Price", JsonObjectHelper.GetJsonValueAsDecimal('UnitAmount'), 'A different UnitAmount was expected.');
        Assert.AreEqual(SalesLine."Line Discount %", JsonObjectHelper.GetJsonValueAsDecimal('DiscountRate'), 'A different DiscountRate was expected.');
        Assert.AreEqual(SalesLine."Amount Including VAT" - SalesLine.Amount, JsonObjectHelper.GetJsonValueAsDecimal('TaxAmount'), 'A different TaxAmount was expected.');
        Assert.AreEqual(Item."No.", JsonObjectHelper.GetJsonValueAsText('ItemCode'), 'A different ItemCode was expected.');
        Assert.AreEqual(Item."XS Tax Type", JsonObjectHelper.GetJsonValueAsText('TaxType'), 'A different TaxType was expected.');
        Assert.AreEqual(Item."XS Account Code", JsonObjectHelper.GetJsonValueAsText('AccountCode'), 'A different AccountCode was expected.');

        UnBindSubscription(XSSalesInvoiceSubscrTest);
    end;

    [Test]
    procedure TestCreateSyncChangeOnAfterPostSalesInvoiceUSandCanada()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        Customer: Record Customer;
        Item: Record Item;
        CountryRegion: Record "Country/Region";
        SyncChange: Record "Sync Change";
        JsonObjectHelper: Codeunit "XS Json Object Helper";
        PostedSalesInvoiceRecordId: RecordId;
        RecordRef: RecordRef;
        Token: JsonToken;
        PhoneToken: JsonToken;
        InvoiceObject: JsonObject;
        CustomerObject: JsonObject;
        AddressObject: JsonObject;
        PhoneObject: JsonObject;
        LineObject: JsonObject;
    begin
        Initialize();

        LibraryLowerPermissions.SetInvoiceApp();

        // [Given] Customer and Item that are already synched with Xero
        SetBindingsForPosting();
        LibrarySynchronize.Initialize(Database::"Sales Header");
        Customer.Get(LibrarySynchronize.CreateEntityAndSynchronizeItWithXero(Database::Customer));
        Customer."XS Tax Type" := 'OUTPUT';
        Customer.Modify();

        Item.Get(LibrarySynchronize.CreateEntityAndSynchronizeItWithXero(Database::Item));
        Item."XS Account Code" := '200';
        Item.Modify();

        // [When] When Sales Invoice is posted 
        LibrarySynchronize.CreateSalesInvoice(SalesHeader, SalesLine, Customer."No.", Item."No.");
        LibrarySales.PostSalesDocument(SalesHeader, true, true);

        MockSalesInvoicePosting.GetPostedSalesInvoiceRecordId(PostedSalesInvoiceRecordId);

        // [Then] Sync Change (Direction - Outgoing, Type - Create, Internal ID - RecordId of that Sales Invoice) for that record is created
        LibrarySynchronize.GetLastCreatedSyncChange(SyncChange);
        Assert.IsTrue(SyncChange.Direction = SyncChange.Direction::Outgoing, 'Created Sync Change should be Outgoing (Direction).');
        Assert.IsTrue(SyncChange."Change Type" = SyncChange."Change Type"::Create, 'Created Sync Change should be Create (Type)');
        Assert.IsTrue(SyncChange."Internal ID" = PostedSalesInvoiceRecordId, 'Created Sync Change should have Internal Id equal to the crated Sales Invoice RecordId');

        RecordRef.GetTable(SyncChange);
        InvoiceObject := JsonObjectHelper.GetBLOBDataAsJsonObject(RecordRef, SyncChange.FieldNo("NAV Data"));
        JsonObjectHelper.SetJsonObject(InvoiceObject);
        Assert.AreEqual('ACCREC', JsonObjectHelper.GetJsonValueAsText('Type'), 'A different type was expected.');

        Token := JsonObjectHelper.GetJsonToken('Contact');
        CustomerObject := Token.AsObject();
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

        JsonObjectHelper.SetJsonObject(InvoiceObject);
        Token := JsonObjectHelper.GetJsonToken('LineItems');
        Token.AsArray().Get(0, Token);
        LineObject := Token.AsObject();
        JsonObjectHelper.SetJsonObject(LineObject);
        Assert.AreEqual(Item.Description, JsonObjectHelper.GetJsonValueAsText('Description'), 'A different Description was expected.');
        Assert.AreEqual(SalesLine.Quantity, JsonObjectHelper.GetJsonValueAsDecimal('Quantity'), 'A different Quantity was expected.');
        Assert.AreEqual(SalesLine."Unit Price", JsonObjectHelper.GetJsonValueAsDecimal('UnitAmount'), 'A different UnitAmount was expected.');
        Assert.AreEqual(SalesLine."Line Discount %", JsonObjectHelper.GetJsonValueAsDecimal('DiscountRate'), 'A different DiscountRate was expected.');
        Assert.AreEqual(SalesLine."Amount Including VAT" - SalesLine.Amount, JsonObjectHelper.GetJsonValueAsDecimal('TaxAmount'), 'A different TaxAmount was expected.');
        Assert.AreEqual(Item."No.", JsonObjectHelper.GetJsonValueAsText('ItemCode'), 'A different ItemCode was expected.');
        Assert.AreEqual(Customer."XS Tax Type", JsonObjectHelper.GetJsonValueAsText('TaxType'), 'A different TaxType was expected.');
        Assert.AreEqual(Item."XS Account Code", JsonObjectHelper.GetJsonValueAsText('AccountCode'), 'A different AccountCode was expected.');
    end;

    [Test]
    procedure TestCreateSyncChangeOnAfterPostSalesInvoiceDefaultAccountandTAxType()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        Customer: Record Customer;
        SyncSetup: Record "Sync Setup";
        Item: Record Item;
        CountryRegion: Record "Country/Region";
        SyncChange: Record "Sync Change";
        JsonObjectHelper: Codeunit "XS Json Object Helper";
        PostedSalesInvoiceRecordId: RecordId;
        RecordRef: RecordRef;
        Token: JsonToken;
        PhoneToken: JsonToken;
        InvoiceObject: JsonObject;
        CustomerObject: JsonObject;
        AddressObject: JsonObject;
        PhoneObject: JsonObject;
        LineObject: JsonObject;
    begin
        Initialize();

        LibraryLowerPermissions.SetInvoiceApp();

        // [Given] Customer and Item that are already synched with Xero
        SetBindingsForPosting();
        LibrarySynchronize.Initialize(Database::"Sales Header");
        Customer.Get(LibrarySynchronize.CreateEntityAndSynchronizeItWithXero(Database::Customer));

        Item.Get(LibrarySynchronize.CreateEntityAndSynchronizeItWithXero(Database::Item));

        SyncSetup.GetSingleInstance();
        SyncSetup."XS Default Tax Type" := 'OUTPUT';
        SyncSetup."XS Default AccountCode" := '200';
        SyncSetup.Modify();

        // [When] When Sales Invoice is posted 
        LibrarySynchronize.CreateSalesInvoice(SalesHeader, SalesLine, Customer."No.", Item."No.");
        LibrarySales.PostSalesDocument(SalesHeader, true, true);

        MockSalesInvoicePosting.GetPostedSalesInvoiceRecordId(PostedSalesInvoiceRecordId);

        // [Then] Sync Change (Direction - Outgoing, Type - Create, Internal ID - RecordId of that Sales Invoice) for that record is created
        LibrarySynchronize.GetLastCreatedSyncChange(SyncChange);
        Assert.IsTrue(SyncChange.Direction = SyncChange.Direction::Outgoing, 'Created Sync Change should be Outgoing (Direction).');
        Assert.IsTrue(SyncChange."Change Type" = SyncChange."Change Type"::Create, 'Created Sync Change should be Create (Type)');
        Assert.IsTrue(SyncChange."Internal ID" = PostedSalesInvoiceRecordId, 'Created Sync Change should have Internal Id equal to the crated Sales Invoice RecordId');

        RecordRef.GetTable(SyncChange);
        InvoiceObject := JsonObjectHelper.GetBLOBDataAsJsonObject(RecordRef, SyncChange.FieldNo("NAV Data"));
        JsonObjectHelper.SetJsonObject(InvoiceObject);
        Assert.AreEqual('ACCREC', JsonObjectHelper.GetJsonValueAsText('Type'), 'A different type was expected.');

        Token := JsonObjectHelper.GetJsonToken('Contact');
        CustomerObject := Token.AsObject();
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

        JsonObjectHelper.SetJsonObject(InvoiceObject);
        Token := JsonObjectHelper.GetJsonToken('LineItems');
        Token.AsArray().Get(0, Token);
        LineObject := Token.AsObject();
        JsonObjectHelper.SetJsonObject(LineObject);
        Assert.AreEqual(Item.Description, JsonObjectHelper.GetJsonValueAsText('Description'), 'A different Description was expected.');
        Assert.AreEqual(SalesLine.Quantity, JsonObjectHelper.GetJsonValueAsDecimal('Quantity'), 'A different Quantity was expected.');
        Assert.AreEqual(SalesLine."Unit Price", JsonObjectHelper.GetJsonValueAsDecimal('UnitAmount'), 'A different UnitAmount was expected.');
        Assert.AreEqual(SalesLine."Line Discount %", JsonObjectHelper.GetJsonValueAsDecimal('DiscountRate'), 'A different DiscountRate was expected.');
        Assert.AreEqual(SalesLine."Amount Including VAT" - SalesLine.Amount, JsonObjectHelper.GetJsonValueAsDecimal('TaxAmount'), 'A different TaxAmount was expected.');
        Assert.AreEqual(Item."No.", JsonObjectHelper.GetJsonValueAsText('ItemCode'), 'A different ItemCode was expected.');
        Assert.AreEqual(SyncSetup."XS Default Tax Type", JsonObjectHelper.GetJsonValueAsText('TaxType'), 'A different TaxType was expected.');
        Assert.AreEqual(SyncSetup."XS Default AccountCode", JsonObjectHelper.GetJsonValueAsText('AccountCode'), 'A different AccountCode was expected.');
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    procedure TestInvoiceCreationWithAMissingCurrency();
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        Customer: Record Customer;
        Item: Record Item;
        SyncChange: Record "Sync Change";
    begin
        // [SCENARIO] A Sales Invoice with a currency that does not exist in Xero cannot be synced
        Initialize();

        LibraryLowerPermissions.SetInvoiceApp();
        BindSubscription(XSSalesInvoiceSubscrTest);

        // [GIVEN] A Sales Invoice with a currency that does not exist in Xero
        LibrarySynchronize.Initialize(Database::"Sales Header");
        Customer.Get(LibrarySynchronize.CreateEntityAndSynchronizeItWithXero(Database::Customer));
        Item.Get(LibrarySynchronize.CreateEntityAndSynchronizeItWithXero(Database::Item));

        LibrarySynchronize.CreateSalesInvoice(SalesHeader, SalesLine, Customer."No.", Item."No.");
        SalesHeader.Validate("Currency Code", 'NOTINXERO');
        SalesHeader.Modify();

        // [WHEN] The document is posted
        // [THEN] An Error is thrown for the missing currency
        assertError LibrarySales.PostSalesDocument(SalesHeader, true, true);
        Assert.ExpectedError(StrSubstNo('Currency %1 was not found in Xero.', 'NOTINXERO'));

        // [THEN] No etry is created in the Sync Change table
        SyncChange.SetRange("XS NAV Entity ID", Database::"Sales Invoice Header");
        Assert.IsTrue(SyncChange.IsEmpty(), 'No Sync Change Record is created');

        UnBindSubscription(XSSalesInvoiceSubscrTest);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    procedure TestInvoiceCreationWithCurrency();
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        Customer: Record Customer;
        Item: Record Item;
        SyncChange: Record "Sync Change";
    begin
        // [SCENARIO] A Sales Invoice with a currency that exists in Xero can be synced
        Initialize();

        LibraryLowerPermissions.SetInvoiceApp();
        BindSubscription(XSSalesInvoiceSubscrTest);

        // [GIVEN] A Sales Invoice with a currency that exists in Xero
        LibrarySynchronize.Initialize(Database::"Sales Header");
        Customer.Get(LibrarySynchronize.CreateEntityAndSynchronizeItWithXero(Database::Customer));
        Item.Get(LibrarySynchronize.CreateEntityAndSynchronizeItWithXero(Database::Item));

        LibrarySynchronize.CreateSalesInvoice(SalesHeader, SalesLine, Customer."No.", Item."No.");
        SalesHeader.Validate("Currency Code", 'INXERO');
        SalesHeader.Modify();

        // [WHEN] The document is posted
        LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [THEN] An etry is created in the Sync Change table to be synced with Xero
        SyncChange.SetRange("XS NAV Entity ID", Database::"Sales Invoice Header");
        Assert.RecordCount(SyncChange, 1);

        UnBindSubscription(XSSalesInvoiceSubscrTest);
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
        SetBindingsForPosting();
        LibrarySynchronize.Initialize(Database::"Sales Header");
        LibrarySynchronize.CreateOutgoingSyncChangeForEntity(SyncMapping, ChangeType::Create, Database::"Sales Header");
        LibrarySynchronize.GetLastCreatedSyncChange(SyncChange);

        // [When] When that Sync Change is processed
        ProcesXeroChange.ProcessXeroChange(SyncChange);

        // [Then] Sync Mapping record should be created
        LibrarySynchronize.FindCreatedSyncMapping(SyncMapping, Database::"Sales Invoice Header");
        Assert.TableIsNotEmpty(DataBase::"Sync Mapping");
        Assert.IsTrue(SyncChange."Internal ID" = SyncMapping."Internal ID", 'Created Sync Mapping should have Internal Id equal to the Sync Change''s Internal Id');
    end;

    local procedure Initialize()
    var
        SyncChange: Record "Sync Change";
        SyncSetup: Record "Sync Setup";
        Currency: Record Currency;
        CurrencyExchangeRate: Record "Currency Exchange Rate";
    begin
        if IsInitialized then
            exit;
        IsInitialized := true;

        SyncChange.DeleteAll();

        SyncSetup.GetSingleInstance();
        SyncSetup."XS Enabled" := true;
        SyncSetup.Modify();

        Currency.Init();
        Currency.Code := 'INXERO';
        Currency.Insert();

        Currency.Init();
        Currency.Code := 'NOTINXERO';
        Currency.Insert();

        CurrencyExchangeRate.Init();
        CurrencyExchangeRate."Currency Code" := 'INXERO';
        CurrencyExchangeRate."Starting Date" := WorkDate();
        CurrencyExchangeRate."Adjustment Exch. Rate Amount" := 1;
        CurrencyExchangeRate."Exchange Rate Amount" := 1;
        CurrencyExchangeRate."Relational Adjmt Exch Rate Amt" := 1;
        CurrencyExchangeRate."Relational Exch. Rate Amount" := 1;
        CurrencyExchangeRate.Insert();

        CurrencyExchangeRate.Init();
        CurrencyExchangeRate."Currency Code" := 'NOTINXERO';
        CurrencyExchangeRate."Starting Date" := WorkDate();
        CurrencyExchangeRate."Adjustment Exch. Rate Amount" := 1;
        CurrencyExchangeRate."Exchange Rate Amount" := 1;
        CurrencyExchangeRate."Relational Adjmt Exch Rate Amt" := 1;
        CurrencyExchangeRate."Relational Exch. Rate Amount" := 1;
        CurrencyExchangeRate.Insert();
    end;

    local procedure SetBindingsForPosting()
    begin
        UnbindSubscription(MockSalesInvoicePosting);
        BindSubscription(MockSalesInvoicePosting);
    end;

    [ConfirmHandler]
    procedure ConfirmHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"XS Communicate With Xero", 'OnBeforeQueryXeroCurrencies', '', true, true)]
    local procedure OnBeforeQueryXeroCurrenciesSubscriber(var Handled: Boolean; var ResponseArrayOut: JsonArray)
    var
        CurrencyObject: JsonObject;
    begin
        CurrencyObject.Add('Code', 'INXERO');
        CurrencyObject.Add('Description', 'Currency in Xero');
        ResponseArrayOut.Add(CurrencyObject);
        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Application System Constants", 'OnAfterGetApplicationVersion', '', true, true)]
    local procedure OnAfterGetApplicationVersionSubscriber(VAR ApplicationVersion: Text[248])
    begin
        ApplicationVersion := 'GB';
    end;
}