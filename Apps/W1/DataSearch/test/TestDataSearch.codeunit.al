// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Test.Foundation.DataSearch;

using Microsoft.Finance.Currency;
using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Foundation.DataSearch;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Sales.Archive;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using Microsoft.Sales.Reminder;
using Microsoft.Service.Document;
using Microsoft.Service.History;
using System.Reflection;
using System.TestLibraries.Utilities;

/// <summary>
/// This codeunit tests data search scenarios.
/// </summary>
codeunit 139507 "Test Data Search"
{
    Subtype = Test;
    TestType = IntegrationTest;

    var
        LibraryAssert: Codeunit "Library Assert";


    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestSetupTables()
    var
        DataSearchSetupTable: Record "Data Search Setup (Table)";
        DataSearchSetupField: Record "Data Search Setup (Field)";
        TestDataSearchOnArchives: Codeunit "Test Data Search On Archives";
    begin
        // precondition: no setup exists
        DataSearchSetupTable.DeleteAll();
        DataSearchSetupField.DeleteAll();

        // activate the sales archive test subscribers
        BindSubscription(TestDataSearchOnArchives);

        // When a search is initiated, a default setup is added via "Data Search Defaults"
        Codeunit.run(Codeunit::"Data Search Defaults");

        UnBindSubscription(TestDataSearchOnArchives);

        LibraryAssert.IsFalse(DataSearchSetupTable.IsEmpty, 'Data Search (Table) should not be empty.');
        LibraryAssert.IsFalse(DataSearchSetupField.IsEmpty, 'Data Search (Field) should not be empty.');
        DataSearchSetupTable.SetRange("Table No.", Database::"Sales Header Archive");
        LibraryAssert.IsFalse(DataSearchSetupTable.IsEmpty, 'Data Search (Table) should contain Sales Header Archive.');
        DataSearchSetupTable.SetRange("Table No.", Database::"Sales Line Archive");
        LibraryAssert.IsFalse(DataSearchSetupTable.IsEmpty, 'Data Search (Table) should contain Sales Line Archive.');
    end;

    [Test]
    [HandlerFunctions('DataSearchSetupListsPageHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestSetupListsToSearch()
    var
        DataSearchSetupTable: Record "Data Search Setup (Table)";
        DataSearchPage: TestPage "Data Search";
    begin
        Init();
        // Precondition: Reminders are not selected for search
        DataSearchSetupTable.SetFilter("Table No.", '%1|%2', Database::"Reminder Header", Database::"Reminder Line");
        DataSearchSetupTable.DeleteAll();

        // Open Search, select to also search 'Reminders'
        DataSearchPage.OpenEdit();
        DataSearchPage.LinesPart.SetupLists.Invoke();
        DataSearchPage.Close();

        // Now both Reminder Header and Reminder Line should be active.
        LibraryAssert.AreEqual(2, DataSearchSetupTable.Count(), 'Reminders not activated.');

        // Cleanup
        DataSearchSetupTable.DeleteAll();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestInvalidSearchTerm()
    var
        DataSearchPage: TestPage "Data Search";
    begin
        Init();
        DataSearchPage.OpenEdit();
        asserterror DataSearchPage.SearchString.Value('10000..30000'); // ranges are not allowed as search filters
        asserterror DataSearchPage.SearchString.Value('(hello)'); // parentheses are not allowed as search filters
    end;

    /*  Bug 546705: [Test Defect]Tests that involve pagebackgroundtasks make the system hang
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
    */
    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestSearchFewFound()
    var
        TestDataSearch: Record "Test Data Search";
        DataSearchInTable: Codeunit "Data Search in Table";
        Results: Dictionary of [Text, Text];
        SearchTerm: Text;
        i: Integer;
    begin
        Init();
        SearchTerm := CopyStr(Format(CreateGuid()), 1, 35);
        for i := 1 to 3 do begin
            CreateDummyTestDataSearch(TestDataSearch, SearchTerm, 1);
            DataSearchInTable.FindInTable(Database::"Test Data Search", 0, SearchTerm, Results);
            LibraryAssert.AreEqual(i, Results.Count, 'Wrong no. of results returned');
            LibraryAssert.AreEqual(Format(TestDataSearch.SystemId), Results.Keys.Get(i), 'Wrong system id');
            LibraryAssert.IsTrue(StrPos(Results.Values.Get(i), SearchTerm) > 0, 'Wrong match');
        end;
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestSearchManyFound()
    var
        TestDataSearch: Record "Test Data Search";
        DataSearchInTable: Codeunit "Data Search in Table";
        Results: Dictionary of [Text, Text];
        SearchTerm: Text;
    begin
        Init();
        SearchTerm := CopyStr(Format(CreateGuid()), 1, 35);
        CreateDummyTestDataSearch(TestDataSearch, SearchTerm, 5);
        DataSearchInTable.FindInTable(Database::"Test Data Search", 0, SearchTerm, Results);
        LibraryAssert.AreEqual(4, Results.Count, 'Wrong no. of results returned');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestMultiTermSearch()
    var
        TestDataSearch: Record "Test Data Search";
        DataSearchInTable: Codeunit "Data Search in Table";
        Results: Dictionary of [Text, Text];
        SearchTerm: Text;
    begin
        Init();
        SearchTerm := CopyStr(Format(CreateGuid()), 1, 35);
        CreateDummyTestDataSearch(TestDataSearch, SearchTerm, 5);
        DataSearchInTable.FindInTable(Database::"Test Data Search", 0, SearchTerm + ' ' + TestDataSearch."No.", Results);
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
        DataSearchSetupField: Record "Data Search Setup (Field)";
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
        DataSearchSetupTable.InsertRec(true);
        DataSearchSetupField.Init();
        DataSearchSetupField."Table No." := Database::"Sales Line";
        DataSearchSetupField."Field No." := 40; // "Shortcut Dimension 1 Code"
        DataSearchSetupField."Enable Search" := true;
        DataSearchSetupField.Insert();
        DataSearchSetupField."Field No." := 41; // "Shortcut Dimension 1 Code"
        DataSearchSetupField.Insert();
        DataSearchSetupTable.Init();
        DataSearchSetupTable."Table No." := Database::"Sales Line Archive";
        DataSearchSetupTable."Table Subtype" := 0;
        DataSearchSetupTable.InsertRec(true);
        DataSearchSetupField.Init();
        DataSearchSetupField."Table No." := Database::"Sales Line Archive";
        DataSearchSetupField."Field No." := 40; // "Shortcut Dimension 1 Code"
        DataSearchSetupField."Enable Search" := true;
        DataSearchSetupField.Insert();
        DataSearchSetupField."Field No." := 41; // "Shortcut Dimension 1 Code"
        DataSearchSetupField.Insert();

        LibrarySales.CreateCustomer(Customer);
        LibrarySales.CreateSalesOrder(SalesHeader);
        SalesDocumentType := SalesHeader."Document Type";
        LibrarySales.CreateSimpleItemSalesLine(SalesLine, SalesHeader, SalesDocumentType);
        SalesLine."Shortcut Dimension 1 Code" := 'Hello';  // are not marked as OptimizeForTextSearch
        SalesLine."Shortcut Dimension 2 Code" := 'World';
        SalesLine.Modify();

        // When user searches for 'hello world'...
        DataSearchPage.OpenEdit();
        DataSearchPage.TestSearchForSalesOrders.Invoke();

        // there should be at least one sales line found
        DataSearchPage.LinesPart.First();
        LibraryAssert.AreEqual('Sales Orders - lines', DataSearchPage.LinesPart.Description.Value, 'wrong header');
        DataSearchPage.LinesPart.Next();
        // example:  '  Order 101017 20000: hortcut Dimension 1 Code: HELLO, Shortcut Dimension 2 Code: WORLD'
#pragma warning disable AA0217
        LibraryAssert.AreEqual(StrSubstNo('  %1 %2 %3: Shortcut Dimension 1 Code: HELLO, Shortcut Dimension 2 Code: WORLD', SalesLine."Document Type", SalesLine."Document No.", SalesLine."Line No."),
#pragma warning restore AA0217
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
        DataSearchSetupTable.InsertRec(true);

        DataSearchPage.TestSearchForSalesOrders.Invoke();

        DataSearchPage.LinesPart.First(); // the sales lines header
        DataSearchPage.LinesPart.Next();  // The first sales line
        i := 0;
        while (i < 4) and (StrPos(DataSearchPage.LinesPart.Description.Value, 'Sales Order Archives') < 1) do begin
            DataSearchPage.LinesPart.Next();  // Maybe the sales line archive header
            i += 1;
        end;
        LibraryAssert.AreEqual('Sales Order Archives - lines', DataSearchPage.LinesPart.Description.Value, 'wrong header for archive');

        DataSearchPage.LinesPart.Next();  // The first sales line archive
                                          // example:  '  Order 101017 1 1 20000: Shortcut Dimension 1 Code: HELLO, Shortcut Dimension 2 Code: WORLD'
        LibraryAssert.IsTrue(StrPos(DataSearchPage.LinesPart.Description.Value, 'Order') > 0, 'wrong line for archive');
        LibraryAssert.IsTrue(StrPos(DataSearchPage.LinesPart.Description.Value, 'Shortcut Dimension 1 Code: HELLO, Shortcut Dimension 2 Code: WORLD') > 0, 'wrong line for archive 2');
        DataSearchPage.LinesPart.Description.Drilldown(); // should open a sales order archive page which invokes the archive function

        UnBindSubscription(TestDataSearchOnArchives);
        DataSearchPage.Close();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestGetPageIdForCustomer()
    var
        Customer: Record Customer;
        DataSearchObjectMapping: Codeunit "Data Search Object Mapping";
        LibrarySales: Codeunit "Library - Sales";
        DisplayPageId: Integer;
        DisplayTableNo: Integer;
        DisplaySystemId: Guid;
    begin
        LibrarySales.CreateCustomer(Customer);

        DataSearchObjectMapping.GetDisplayPageId(Database::Customer, Customer.SystemId, DisplayPageId, DisplayTableNo, DisplaySystemId);

        LibraryAssert.AreEqual(Page::"Customer Card", DisplayPageId, 'Wrong card id');
        LibraryAssert.AreEqual(DisplayTableNo, Database::Customer, 'Wrong display table no.');
        LibraryAssert.AreEqual(DisplaySystemId, Customer.SystemId, 'Wrong system id for TestDataSearch');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestGetPageIdForSalesOrder()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        DataSearchObjectMapping: Codeunit "Data Search Object Mapping";
        LibrarySales: Codeunit "Library - Sales";
        DisplayPageId: Integer;
        DisplayTableNo: Integer;
        DisplaySystemId: Guid;
    begin
        LibrarySales.CreateCustomer(Customer);
        LibrarySales.CreateSalesOrder(SalesHeader);

        DataSearchObjectMapping.GetDisplayPageId(Database::"Sales Header", SalesHeader.SystemId, DisplayPageId, DisplayTableNo, DisplaySystemId);

        LibraryAssert.AreEqual(Page::"Sales Order", DisplayPageId, 'Wrong card id');
        LibraryAssert.AreEqual(DisplayTableNo, Database::"Sales Header", 'Wrong display table no.');
        LibraryAssert.AreEqual(DisplaySystemId, SalesHeader.SystemId, 'Wrong system id for SalesHeader');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoCommit)]
    procedure TestGetPageIdForSalesOrderLine()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        DataSearchObjectMapping: Codeunit "Data Search Object Mapping";
        LibrarySales: Codeunit "Library - Sales";
        DisplayPageId: Integer;
        DisplayTableNo: Integer;
        DisplaySystemId: Guid;
    begin
        LibrarySales.CreateCustomer(Customer);
        LibrarySales.CreateSalesOrder(SalesHeader);
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.FindFirst();

        DataSearchObjectMapping.GetDisplayPageId(Database::"Sales Line", SalesLine.SystemId, DisplayPageId, DisplayTableNo, DisplaySystemId);

        LibraryAssert.AreEqual(Page::"Sales Order", DisplayPageId, 'Wrong card id');
        LibraryAssert.AreEqual(DisplayTableNo, Database::"Sales Header", 'Wrong display table no.');
        LibraryAssert.AreEqual(DisplaySystemId, SalesHeader.SystemId, 'Wrong system id for SalesHeader');
    end;


    /*
    Expects the search setup in the format of (example):
    [
      {
         "tableNo": 1234,
         "tableSubtype": 0,
         "tableSubtypeFieldNo": 3,
         "tableSearchFieldNos": [ 1, 2, 5, 8 ]
      }
    ]
    */

    [Test]
    [TransactionModel(TransactionModel::AutoCommit)]
    procedure TestGetSetup()
    var
        DataSearchObjectMapping: Codeunit "Data Search Object Mapping";
        jArray: JsonArray;
        jObject: JsonObject;
        jToken: JsonToken;
        i: Integer;
    begin
        DataSearchObjectMapping.GetDataSearchSetup(jArray);

        LibraryAssert.IsTrue(jArray.Count() > 0, 'Setup was empty');
        jArray.Get(1, jToken);
        jObject := jToken.AsObject();
        jObject.Get('tableNo', jToken);
        LibraryAssert.IsTrue(jToken.AsValue().AsInteger() > 0, 'No tableNo provided.');
        jObject.Get('tableSubtype', jToken);
        i := jToken.AsValue().AsInteger(); // to verify that it can be read as an integer
        jObject.Get('tableSubtypeFieldNo', jToken);
        i := jToken.AsValue().AsInteger(); // to verify that it can be read as an integer
        jObject.Get('tableSearchFieldNos', jToken);
        jArray := jToken.AsArray();
        LibraryAssert.IsTrue(i <> 0, 'No integer was read.');
        LibraryAssert.IsTrue(jArray.Count() > 0, 'tableSearchFieldNos not provided.');
    end;

    [ModalPageHandler]
    procedure DataSearchSetupListsPageHandler(var DataSearchSetupListsPage: TestPage "Data Search Setup (Lists)")
    begin
        DataSearchSetupListsPage.ShowAllLists.Invoke();
        DataSearchSetupListsPage.GoToKey(Page::"Reminder List");
        DataSearchSetupListsPage.ListIsEnabledCtrl.SetValue(true);
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

    /*  Bug 546705: [Test Defect]Tests that involve pagebackgroundtasks make the system hang
        [Test]
        [HandlerFunctions('DataSearchPageHandler')]
        [TransactionModel(TransactionModel::AutoRollback)]
        procedure TestStartUpParameter()
        var
            DataSearch: Page "Data Search";
        begin
            DataSearch.SetSearchString('*Hello World');
            DataSearch.Run();
        end;

        [PageHandler]
        procedure DataSearchPageHandler(var DataSearch: TestPage "Data Search")
        begin
            LibraryAssert.IsTrue(StrPos(DataSearch.SearchString.Value, 'Searching for "*Hello World"') = 1, 'Start-up parameter not specified correctly.');
            DataSearch.Close();
        end;
    */

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

    local procedure CreateDummyTestDataSearch(var TestDataSearch: Record "Test Data Search"; PartOfName: Text; NoOfTestDataSearchs: Integer)
    var
        i: Integer;
    begin
        for i := 1 to NoOfTestDataSearchs do begin
            TestDataSearch.Init();
            TestDataSearch."No." := CopyStr(Format(CreateGuid()), 1, MaxStrLen(TestDataSearch."No."));
            TestDataSearch.Name := 'a ' + PartOfName + format(i);
            TestDataSearch.Insert();
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
        DataSearchSetupTable."Table No." := Database::"Test Data Search";
        DataSearchSetupTable.Insert(true);

        LibraryAssert.IsFalse(DataSearchSetupField.IsEmpty, 'Data Search (Field) should not be empty.');
    end;
}
