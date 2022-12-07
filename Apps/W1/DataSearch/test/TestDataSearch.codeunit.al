// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// This codeunit tests data search scenarios.
/// </summary>
codeunit 139507 "Test Data Search"
{
    Subtype = Test;

    var
        LibraryAssert: Codeunit "Library Assert";

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestSetupTables()
    var
        DataSearchSetupTable: Record "Data Search Setup (Table)";
        DataSearchSetupField: Record "Data Search Setup (Field)";
        TestDataSearchOnArchives: Codeunit "Test Data Search On Archives";
        DataSearchPage: TestPage "Data Search";
    begin
        // precondition: no setup exists
        DataSearchSetupTable.DeleteAll();
        DataSearchSetupField.DeleteAll();

        // activate the sales archive test subscribers
        BindSubscription(TestDataSearchOnArchives);

        // When a search is initiated, a default setup is added
        DataSearchPage.OpenEdit();
        DataSearchPage.SearchString.Value('Gibberish');  // doesn't matter if it finds anything
        DataSearchPage.Close();

        UnBindSubscription(TestDataSearchOnArchives);

        LibraryAssert.IsFalse(DataSearchSetupTable.IsEmpty, 'Data Search (Table) should not be empty.');
        LibraryAssert.IsFalse(DataSearchSetupField.IsEmpty, 'Data Search (Field) should not be empty.');
        DataSearchSetupTable.SetRange("Table No.", Database::"Sales Header Archive");
        LibraryAssert.IsFalse(DataSearchSetupTable.IsEmpty, 'Data Search (Table) should contain Sales Header Archive.');
        DataSearchSetupTable.SetRange("Table No.", Database::"Sales Line Archive");
        LibraryAssert.IsFalse(DataSearchSetupTable.IsEmpty, 'Data Search (Table) should contain Sales Line Archive.');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestSearchNothingFound()
    var
        DataSearchPage: TestPage "Data Search";
    begin
        Init();
        DataSearchPage.OpenEdit();
        DataSearchPage.SearchString.Value(Format(CreateGuid())); // should hopeully not find anything

        LibraryAssert.AreEqual('', Format(DataSearchPage.LinesPart.Description), 'Should be empty');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestSearchFewFound()
    var
        Customer: Record Customer;
        DataSearchInTable: Codeunit "Data Search in Table";
        Results: Dictionary of [Text, Text];
        SearchTerm: Text;
        i: Integer;
    begin
        Init();
        SearchTerm := CopyStr(Format(CreateGuid()), 1, 35);
        for i := 1 to 3 do begin
            CreateDummyCustomer(Customer, SearchTerm, 1);
            DataSearchInTable.FindInTable(Database::Customer, 0, SearchTerm, Results);
            LibraryAssert.AreEqual(i, Results.Count, 'Wrong no. of results returned');
            LibraryAssert.AreEqual(Format(Customer.SystemId), Results.Keys.Get(i), 'Wrong system id');
            LibraryAssert.IsTrue(StrPos(Results.Values.Get(i), SearchTerm) > 0, 'Wrong match');
        end;
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestSearchManyFound()
    var
        Customer: Record Customer;
        DataSearchInTable: Codeunit "Data Search in Table";
        Results: Dictionary of [Text, Text];
        SearchTerm: Text;
    begin
        Init();
        SearchTerm := CopyStr(Format(CreateGuid()), 1, 35);
        CreateDummyCustomer(Customer, SearchTerm, 5);
        DataSearchInTable.FindInTable(Database::Customer, 0, SearchTerm, Results);
        LibraryAssert.AreEqual(4, Results.Count, 'Wrong no. of results returned');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestMultiTermSearch()
    var
        Customer: Record Customer;
        DataSearchInTable: Codeunit "Data Search in Table";
        Results: Dictionary of [Text, Text];
        SearchTerm: Text;
    begin
        Init();
        SearchTerm := CopyStr(Format(CreateGuid()), 1, 35);
        CreateDummyCustomer(Customer, SearchTerm, 5);
        DataSearchInTable.FindInTable(Database::Customer, 0, SearchTerm + ' ' + Customer."No.", Results);
        LibraryAssert.AreEqual(1, Results.Count, 'Wrong no. of results returned');
    end;


    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestGetTableCaption()
    var
        SalesDocumentType: Enum "Sales Document Type";
        PurchaseDocumentType: Enum "Purchase Document Type";
        ServiceDocumentType: Enum "Service Document Type";
    begin
        VerifyTableCaptionForTable(Database::Currency, 0, Page::Currencies);
        VerifyTableCaptionForTable(Database::"G/L Entry", 0, Page::"General Ledger Entries");
        VerifyTableCaptionForTable(Database::Customer, 0, Page::"Customer List");
        VerifyTableCaptionForTable(Database::"Sales Header", SalesDocumentType::"Blanket Order".AsInteger(), Page::"Blanket Sales Orders");
        VerifyTableCaptionForTable(Database::"Sales Header", SalesDocumentType::Quote.AsInteger(), Page::"Sales Quotes");
        VerifyTableCaptionForTable(Database::"Sales Line", SalesDocumentType::Quote.AsInteger(), Page::"Sales Quotes");
        VerifyTableCaptionForTable(Database::"Sales Header", SalesDocumentType::Order.AsInteger(), Page::"Sales Orders");
        VerifyTableCaptionForTable(Database::"Sales Line", SalesDocumentType::Order.AsInteger(), Page::"Sales Orders");
        VerifyTableCaptionForTable(Database::"Purchase Header", PurchaseDocumentType::"Blanket Order".AsInteger(), Page::"Blanket Purchase Orders");
        VerifyTableCaptionForTable(Database::"Purchase Header", PurchaseDocumentType::Quote.AsInteger(), Page::"Purchase Quotes");
        VerifyTableCaptionForTable(Database::"Purchase Line", PurchaseDocumentType::Quote.AsInteger(), Page::"Purchase Quotes");
        VerifyTableCaptionForTable(Database::"Purchase Line", PurchaseDocumentType::Order.AsInteger(), Page::"Purchase Orders");
        VerifyTableCaptionForTable(Database::"Service Header", ServiceDocumentType::"Order".AsInteger(), Page::"Service Orders");
        VerifyTableCaptionForTable(Database::"Service Item Line", ServiceDocumentType::Invoice.AsInteger(), Page::"Service Invoices");
    end;

    [Test]
    [HandlerFunctions('SalesOrderPageHandler,ConfirmDlgYes,CloseMessage,SalesOrderArchivePageHandler')]
    [TransactionModel(TransactionModel::AutoCommit)]
    procedure TestSearchSalesOrders()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        Customer: Record Customer;
        DataSearchSetupTable: Record "Data Search Setup (Table)";
        TestDataSearchOnArchives: Codeunit "Test Data Search On Archives";
        LibrarySales: Codeunit "Library - Sales";
        DataSearchPage: TestPage "Data Search";
        SalesDocumentType: Enum "Sales Document Type";
        i: Integer;
    begin
        BindSubscription(TestDataSearchOnArchives);
        // Given: Sales order with sales line with description 'Hello' and descr.2 'World';
        DataSearchSetupTable.Setrange("Role Center ID", DataSearchSetupTable.GetRoleCenterID());
        DataSearchSetupTable.SetFilter("Table No.", '%1|%2', Database::"Sales Line", Database::"Sales Line Archive");
        DataSearchSetupTable.DeleteAll();
        DataSearchSetupTable.Init();
        DataSearchSetupTable."Role Center ID" := DataSearchSetupTable.GetRoleCenterID();
        DataSearchSetupTable."Table No." := Database::"Sales Line";
        DataSearchSetupTable.Insert(true);
        DataSearchSetupTable.Init();
        DataSearchSetupTable."Table No." := Database::"Sales Line Archive";
        DataSearchSetupTable."Table Subtype" := 0;
        DataSearchSetupTable.Insert(true);

        LibrarySales.CreateCustomer(Customer);
        LibrarySales.CreateSalesOrder(SalesHeader);
        SalesDocumentType := SalesHeader."Document Type";
        LibrarySales.CreateSimpleItemSalesLine(SalesLine, SalesHeader, SalesDocumentType);
        SalesLine.Description := 'Hello';
        SalesLine."Description 2" := 'World';
        SalesLine.Modify();

        // When user searches for 'hello world'...
        DataSearchPage.OpenEdit();
        DataSearchPage.TestSearchForSalesOrders.Invoke();

        // there should be at least one sales line found
        DataSearchPage.LinesPart.First();
        LibraryAssert.AreEqual('Sales Orders - lines', DataSearchPage.LinesPart.Description.Value, 'wrong header');
        DataSearchPage.LinesPart.Next();
        // example:  '  Order 101017 20000: Description: Hello, Description 2: World'
        LibraryAssert.AreEqual(StrSubstNo(
            '  %1 %2 %3: Description: Hello, Description 2: World', SalesLine."Document Type", SalesLine."Document No.", SalesLine."Line No."),
            DataSearchPage.LinesPart.Description.Value, 'wrong line');
        DataSearchPage.LinesPart.Description.Drilldown(); // should open a sales order page which invokes the archive function

        // New search for same data - this time there should also be a sales order archive
        // activate the sales archive test subscribers
        DataSearchPage.TestClearResults.Invoke();

        DataSearchSetupTable.Setrange("Role Center ID", DataSearchSetupTable.GetRoleCenterID());
        DataSearchSetupTable.Setrange("Table No.", Database::"Sales Line Archive");
        DataSearchSetupTable.DeleteAll();

        DataSearchSetupTable.Init();
        DataSearchSetupTable."Role Center ID" := DataSearchSetupTable.GetRoleCenterID();
        DataSearchSetupTable."Table No." := Database::"Sales Line Archive";
        DataSearchSetupTable.Insert(true);

        DataSearchPage.TestSearchForSalesOrders.Invoke();

        DataSearchPage.LinesPart.First(); // the sales lines header
        DataSearchPage.LinesPart.Next();  // The first sales line
        i := 0;
        while (i < 4) and (StrPos(DataSearchPage.LinesPart.Description.Value, 'Sales List Archive') < 1) do begin
            DataSearchPage.LinesPart.Next();  // Maybe the sales line archive header
            i += 1;
        end;
        LibraryAssert.AreEqual('Sales List Archive - lines', DataSearchPage.LinesPart.Description.Value, 'wrong header for archive');

        DataSearchPage.LinesPart.Next();  // The first sales line archive
        // example:  '  Order 101017 1 1 20000: Description: Hello, Description 2: World'
        LibraryAssert.IsTrue(StrPos(DataSearchPage.LinesPart.Description.Value, 'Order') > 0, 'wrong line for archive');
        LibraryAssert.IsTrue(StrPos(DataSearchPage.LinesPart.Description.Value, 'Description: Hello, Description 2: World') > 0, 'wrong line for archive 2');
        DataSearchPage.LinesPart.Description.Drilldown(); // should open a sales order archive page which invokes the archive function

        UnBindSubscription(TestDataSearchOnArchives);
        DataSearchPage.Close();
    end;

    [PageHandler]
    procedure SalesOrderPageHandler(var SalesOrder: TestPage "Sales Order")
    begin
        SalesOrder."Archive Document".Invoke();
        SalesOrder.Close();
    end;


    [PageHandler]
    procedure SalesOrderArchivePageHandler(var SalesOrderArchive: TestPage "Sales Order Archive")
    begin
        SalesOrderArchive.Close();
    end;

    [ConfirmHandler]
    procedure ConfirmDlgYes(Question: Text[1024]; var Answer: Boolean)
    begin
        Answer := true;
    end;

    [MessageHandler]
    procedure CloseMessage(Message: Text[1024])
    begin
    end;

    [Test]
    [HandlerFunctions('DataSearchPageHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestStartUpParameter()
    var
        DataSearch: Page "Data Search";
    begin
        DataSearch.SetSearchString('Hello World');
        DataSearch.Run();
    end;

    [PageHandler]
    procedure DataSearchPageHandler(var DataSearch: TestPage "Data Search")
    begin
        LibraryAssert.AreEqual('Hello World', DataSearch.SearchString.Value, 'Start-up parameter not specified correctly.');
        DataSearch.Close();
    end;

    local procedure VerifyTableCaptionForTable(TableNo: Integer; TableSubType: Integer; PageNo: Integer)
    var
        TempDataSearchResult: Record "Data Search Result" temporary;
        PageMetadata: Record "Page Metadata";
        ExpectedCaption: Text;
    begin
        if (PageNo = 0) or (TableNo = 0) then
            exit;
        TempDataSearchResult."Table No." := TableNo;
        TempDataSearchResult."Table Subtype" := TableSubType;
        PageMetadata.Get(PageNo);
        ExpectedCaption := PageMetadata.Caption;
        if TableNo in
            [Database::"Sales Line", Database::"Sales Invoice Line", Database::"Sales Shipment Line", Database::"Sales Cr.Memo Line",
             Database::"Purchase Line", Database::"Purch. Inv. Line", Database::"Purch. Rcpt. Line", Database::"Purch. Cr. Memo Line",
             Database::"Service Item Line", Database::"Service Invoice Line", Database::"Service Cr.Memo Line"]
        then
            ExpectedCaption += ' - ' + 'lines';

        LibraryAssert.AreEqual(ExpectedCaption, TempDataSearchResult.GetTableCaption(), 'Wrong table caption');
    end;

    local procedure CreateDummyCustomer(var Customer: Record Customer; PartOfName: Text; NoOfCustomers: Integer)
    var
        i: Integer;
    begin
        for i := 1 to NoOfCustomers do begin
            Customer.Init();
            Customer."No." := CopyStr(Format(CreateGuid()), 1, MaxStrLen(Customer."No."));
            Customer.Name := 'a' + PartOfName + format(i);
            Customer.Insert();
        end;
    end;

    local procedure Init()
    var
        DataSearchSetupTable: Record "Data Search Setup (Table)";
        DataSearchSetupField: Record "Data Search Setup (Field)";
    begin
        DataSearchSetupTable.DeleteAll();
        DataSearchSetupField.DeleteAll();
        DataSearchSetupTable."Role Center ID" := DataSearchSetupTable.GetRoleCenterID();
        DataSearchSetupTable."Table No." := Database::Customer;
        DataSearchSetupTable.Insert(true);

        LibraryAssert.IsFalse(DataSearchSetupField.IsEmpty, 'Data Search (Field) should not be empty.');
    end;
}