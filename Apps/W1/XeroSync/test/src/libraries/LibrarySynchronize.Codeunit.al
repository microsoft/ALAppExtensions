codeunit 130302 "XS Library - Synchronize"
{
    Subtype = Test;
    
    var
        LibrarySales: Codeunit "Library - Sales";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryRandom: Codeunit "Library - Random";

    procedure Initialize(NAVEntityID: Integer)
    var
        Item: Record Item;
        Customer: Record Customer;
        SyncChange: Record "Sync Change";
        SyncMapping: Record "Sync Mapping";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        SetTestMode();
        case NAVEntityID of
            Database::Item:
                Item.DeleteAll();
            Database::Customer:
                Customer.DeleteAll();
            Database::"Sales Invoice Header":
                begin
                    SalesHeader.DeleteAll();
                    SalesLine.DeleteAll();
                    SalesInvoiceHeader.DeleteAll();
                    Customer.DeleteAll();
                    Item.DeleteAll();
                end;
        end;
        SyncChange.DeleteAll();
        SyncMapping.DeleteAll();
    end;

    local procedure SetTestMode()
    var
        SyncSetup: Record "Sync Setup";
    begin
        SyncSetup.GetSingleInstance();
        SyncSetup."XS In Test Mode" := true;
        SyncSetup.Modify();
    end;

    procedure GetLastCreatedSyncChange(var SyncChange: Record "Sync Change")
    begin
        SyncChange.FindLast();
    end;

    procedure CreateEntityAndSynchronizeItWithXero(NAVEntityID: Integer) CreatedEntityCode: Code[20]
    var
        Item: Record Item;
        Customer: Record Customer;
        WebServiceMockClass: Codeunit "XS Web Service Mock Class";
    begin
        WebServiceMockClass.SetMockWebServiceChangeType(WebServiceMockClass.MockCreationsCode());
        WebServiceMockClass.SetNumberOfResponsesRequired(1);
        case NAVEntityID of
            Database::Item:
                begin
                    WebServiceMockClass.SetWebServiceResponseContentType(WebServiceMockClass.MockItemsResponse());
                    LibraryInventory.CreateItem(Item);
                    CreatedEntityCode := Item."No.";
                end;
            Database::Customer:
                begin
                    WebServiceMockClass.SetWebServiceResponseContentType(WebServiceMockClass.MockCustomersResponse());
                    LibrarySales.CreateCustomer(Customer);
                    CreatedEntityCode := Customer."No.";
                end;
        end;
        ProcessXeroChange();
    end;

    procedure ProcessXeroChange()
    var
        SyncChange: Record "Sync Change";
        ProcessSyncChange: Codeunit "XS Process Xero Change";
    begin
        GetLastCreatedSyncChange(SyncChange);
        ProcessSyncChange.ProcessXeroChange(SyncChange);
        SyncChange.DeleteAll();
    end;

    procedure CreateEntityThatExixtsFromBeforeAppIsInstalledAndIsNotSynchronizedWithXero(NAVEntityID: Integer) CreatedEntityCode: Code[20]
    var
        Item: Record Item;
        Customer: Record Customer;
        SyncChange: Record "Sync Change";
    begin
        case NAVEntityID of
            Database::Item:
                begin
                    LibraryInventory.CreateItem(Item);
                    CreatedEntityCode := Item."No.";
                end;
            Database::Customer:
                begin
                    LibrarySales.CreateCustomer(Customer);
                    CreatedEntityCode := Customer."No.";
                end;
        end;
        SyncChange.DeleteAll();
    end;

    procedure CreateOutgoingSyncChangeForEntity(var SyncMapping: Record "Sync Mapping"; ChangeType: Option Create,Update,Delete; NAVEntityID: Integer)
    var
        Customer: Record Customer;
        Item: Record Item;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        CreatedEntityRecordID: RecordId;
    begin
        SetWebServiceMockingSettings(NAVEntityID);
        if ChangeType <> ChangeType::Create then
            case NAVEntityID of
                Database::Customer:
                    begin
                        Customer.Get(CreateEntityAndSynchronizeItWithXero(NAVEntityID));
                        CreatedEntityRecordID := Customer.RecordId();
                    end;
                Database::Item:
                    begin
                        Item.Get(CreateEntityAndSynchronizeItWithXero(NAVEntityID));
                        CreatedEntityRecordID := Item.RecordId();
                    end;
            end;

        case NAVEntityID of
            Database::Customer:
                case ChangeType of
                    ChangeType::Create:
                        CreateCustomer(Customer);
                    ChangeType::Update:
                        UpdateCustomer(Customer);
                    ChangeType::Delete:
                        DeleteCustomer(Customer);
                end;
            Database::Item:
                case ChangeType of
                    ChangeType::Create:
                        CreateItem(Item);
                    ChangeType::Update:
                        UpdateItem(Item);
                    ChangeType::Delete:
                        DeleteItem(Item);
                end;
            Database::"Sales Header":
                case ChangeType of
                    ChangeType::Create:
                        begin
                            Customer.Get(CreateEntityAndSynchronizeItWithXero(Database::Customer));
                            Item.Get(CreateEntityAndSynchronizeItWithXero(Database::Item));
                            CreateSalesInvoice(SalesHeader, SalesLine, Customer."No.", Item."No.");
                            LibrarySales.PostSalesDocument(SalesHeader, true, true);
                        end;
                end;
        end;
        if ChangeType <> ChangeType::Create then
            FindCreatedSyncMapping(SyncMapping, CreatedEntityRecordID);
    end;

    local procedure SetWebServiceMockingSettings(NAVEntityID: Integer)
    var
        WebServiceMockClass: Codeunit "XS Web Service Mock Class";
    begin
        WebServiceMockClass.SetMockWebServiceChangeType(WebServiceMockClass.MockCreationsCode());
        WebServiceMockClass.SetNumberOfResponsesRequired(1);
        case NAVEntityID of
            Database::Item:
                WebServiceMockClass.SetWebServiceResponseContentType(WebServiceMockClass.MockItemsResponse());
            Database::Customer:
                WebServiceMockClass.SetWebServiceResponseContentType(WebServiceMockClass.MockCustomersResponse());
            Database::"Sales Header":
                WebServiceMockClass.SetWebServiceResponseContentType(WebServiceMockClass.MockSalesInvoiceResponse());
        end;
    end;

    procedure CreateIncomingSyncChangeForEntity(var SyncMapping: Record "Sync Mapping"; ChangeType: Option Create,Update,Delete; NAVEntityID: Integer)
    var
        IncomingSyncChange: Record "Sync Change";
        DummySyncSetup: Record "Sync Setup";
        GetChangesFromXero: Codeunit "XS Get Changes From Xero";
        CreateIncomingDeleteSC: Codeunit "XS Create Incoming Delete SC";
        WebServiceMockClass: Codeunit "XS Web Service Mock Class";
    begin
        case NAVEntityID of
            Database::Item:
                WebServiceMockClass.SetWebServiceResponseContentType(WebServiceMockClass.MockItemsResponse());
            Database::Customer:
                WebServiceMockClass.SetWebServiceResponseContentType(WebServiceMockClass.MockCustomersResponse());
        end;

        case ChangeType of
            ChangeType::Create:
                begin
                    WebServiceMockClass.SetMockWebServiceChangeType(WebServiceMockClass.MockCreationsCode());
                    WebServiceMockClass.SetNumberOfResponsesRequired(1);
                    GetChangesFromXero.GetChangesFromXero(IncomingSyncChange, DummySyncSetup, NAVEntityID, '');
                end;
            ChangeType::Update:
                begin
                    WebServiceMockClass.SetMockWebServiceChangeType(WebServiceMockClass.MockUpdatesCode());
                    WebServiceMockClass.SetNumberOfResponsesRequired(1);
                    GetChangesFromXero.GetChangesFromXero(IncomingSyncChange, DummySyncSetup, NAVEntityID, '');
                end;
            ChangeType::Delete:
                begin
                    WebServiceMockClass.SetMockWebServiceChangeType(WebServiceMockClass.MockDeletionsCode());
                    WebServiceMockClass.SetNumberOfResponsesRequired(1);
                    CreateIncomingDeleteSC.CreateIncomingDeleteSyncChangesForEntity(NAVEntityID);
                end;
        end;
    end;

    procedure FindCreatedSyncMapping(var SyncMapping: Record "Sync Mapping"; InternalId: RecordId)
    begin
        SyncMapping.SetRange("Internal ID", InternalId);
        SyncMapping.FindFirst();
    end;

    procedure FindCreatedSyncMapping(var SyncMapping: Record "Sync Mapping"; NAVEntityID: Integer)
    var
        Customer: Record Customer;
        Item: Record Item;
        SalesInvoiceHeader: Record "Sales Invoice Header";
        InternalId: RecordId;
    begin
        case NAVEntityID of
            Database::Customer:
                begin
                    Customer.FindLast();
                    InternalId := Customer.RecordId();
                end;
            Database::Item:
                begin
                    Item.FindLast();
                    InternalId := Item.RecordId();
                end;
            Database::"Sales Invoice Header":
                begin
                    SalesInvoiceHeader.FindLast();
                    InternalId := SalesInvoiceHeader.RecordId();
                end;
        end;
        SyncMapping.SetRange("Internal ID", InternalId);
        SyncMapping.FindLast();
    end;

    procedure CreateCustomer(var Customer: Record Customer)
    var
        LibrarySales: Codeunit "Library - Sales";
    begin
        LibrarySales.CreateCustomer(Customer);
    end;

    procedure UpdateCustomer(var Customer: Record Customer)
    begin
        Customer.Address := CopyStr(LibraryRandom.RandText(15), 1, 50);
        Customer.Modify();
    end;

    procedure DeleteCustomer(var Customer: Record Customer)
    begin
        Customer.Delete();
    end;

    procedure CreateItem(var Item: Record Item)
    var
        LibraryInventory: Codeunit "Library - Inventory";
    begin
        LibraryInventory.CreateItem(Item);
    end;

    procedure UpdateItem(var Item: Record Item)
    begin
        Item.Description := CopyStr(LibraryRandom.RandText(15), 1, 50);
        Item."Unit Price" := LibraryRandom.RandDec(10, 2);
        Item.Modify();
    end;

    procedure DeleteItem(var Item: Record Item)
    begin
        Item.Delete();
    end;

    procedure CreateSalesInvoice(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; SellToCustomerNo: Code[20]; SellItemNo: Code[20]);
    begin
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Invoice, SellToCustomerNo);
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, SellItemNo, 1);
        SalesLine.Validate("Unit Price", LibraryRandom.RandIntInRange(5000, 10000));
        SalesLine.Modify();
    end;
}