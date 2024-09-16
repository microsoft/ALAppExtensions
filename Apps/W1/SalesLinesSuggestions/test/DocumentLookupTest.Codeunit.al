namespace Microsoft.Sales.Document.Test;

using Microsoft.Inventory.Item;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Document;
using System.TestLibraries.Utilities;

codeunit 139783 "Document Lookup Test"
{
    Subtype = Test;
    TestPermissions = Disabled;
    EventSubscriberInstance = Manual;

    trigger OnRun()
    begin
        // [FEATURE] [Sales with AI]:[Document Lookup]
    end;

    var
        Assert: Codeunit Assert;
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        LibraryInventory: Codeunit "Library - Inventory";
        LibrarySales: Codeunit "Library - Sales";
        TestUtility: Codeunit "SLS Test Utility";
        IsInitialized: Boolean;

        Item1DescriptionLbl: Label 'High Quality Mouse Mat';
        Item2DescriptionLbl: Label 'Yoga Mat';
        Item3DescriptionLbl: Label 'Model Tool Kit';

        Item4DescriptionLbl: Label 'Mobile Phone Holder';
        NeedAllItemFromSpecifiedSalesOrderLbl: Label 'I need all items from sales order %1', Comment = '%1 = Label for document number';
        NeedAllItemFromSpecifiedSalesInvoiceLbl: Label 'I need all items from sales Invoice %1', Comment = '%1 =Label for document number';
        NeedAllItemFromSpecifiedSalesShipmentLbl: Label 'I need all items from sales Shipment %1', Comment = '%1 =Label for document number';
        NeedAllItemFromSpecifiedSalesQuoteLbl: Label 'I need all items from sales quote %1', Comment = '%1 =Label for document number';
        NeedAllItemFromUnknownDocumentLbl: Label 'I need 40 keyboards from the latest unknown document';

        DescriptionIsIncorrectErr: Label 'Description is incorrect!';
        VariantIsIncorrectErr: Label 'Variant is incorrect!';
        QuantityIsIncorrectErr: Label 'Quantity is incorrect!';
        UoMIsIncorrectErr: Label 'Unit of Measure is incorrect!';
        UnknownDocTypeErr: Label 'Copilot does not support the specified document type. Please rephrase the description';
        CannotFindDocumentErr: Label 'Copilot could not find the requested Sales Order %1. Please rephrase the description and try again.', Comment = '%1 =Label for document number';
    // --------------------------------------------------------------------------------------
    // Corner cases

    [Test]
    [HandlerFunctions('CheckNothingGeneratedFromSalesOrder,SendNotificationHandler')]
    procedure TestCopySalesOrderWithNoExceedingMaxLen()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        CreatedItem: Record Item;
        SalesLineAISuggestions: Page "Sales Line AI Suggestions";
    begin
        // [FEATURE] [Sales Line with AI] [Document Lookup] [Sales Order]
        // [SCENARIO] When user try to copy sales order with a document No exceeding max acceptable length, the system should not generate any lines and send a notification to the user.
        Initialize();
        LibrarySales.CreateCustomer(Customer);
        // [GIVEN] Create a new sales order for the new customer
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");
        // [GIVEN] Create 3 lines with item description and add it to the new sales order
        Create3SalesLinesWithItemDescription(SalesHeader, SalesLine, CreatedItem);
        // [GIVEN] Generate prompt with Document No.
        LibraryVariableStorage.Enqueue(StrSubstNo(NeedAllItemFromSpecifiedSalesOrderLbl, '123456789123456789123456789123456789123456789123456789123456789'));
        LibraryVariableStorage.Enqueue(StrSubstNo(CannotFindDocumentErr, '123456789123456789123456789123456789123456789123456789123456789'));
        // [WHEN] Create a new sales order for this customer and run Sales Line AI Suggestions Page to generate suggestions lines
        // [THEN] Check that no sales lines are generated in 'CheckNothingGeneratedFromSalesOrder' handler function
        // [THEN] Check the error message in 'SendNotificationHandler' handler function
        CreateNewSalesHeaderAndRunSalesLineAISuggestionsPage(SalesHeader, SalesLineAISuggestions, Customer."No.", SalesHeader."Document Type"::Order);
        // [THEN] Check no sales lines are inserted to this document
        CheckSalesLineContent(SalesLine, SalesHeader."No.");
    end;

    [Test]
    [HandlerFunctions('CheckGenerateFromSalesOrder')]
    procedure TestCopySalesOrderWithItemVariant()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        CreatedItem: Record Item;
        ItemVariant: Record "Item Variant";
        SalesLineAISuggestions: Page "Sales Line AI Suggestions";
        VariantCode: Code[10];
    begin
        // [FEATURE] [Sales Line with AI] [Document Lookup] [Sales Order]
        // [SCENARIO] When copying a sales order, the item variant should also be copied.
        Initialize();
        LibrarySales.CreateCustomer(Customer);
        // [GIVEN] Create a new sales order for the new customer
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");
        // [GIVEN] Create Item and Item Variant
        LibrarySales.CreateSimpleItemSalesLine(SalesLine, SalesHeader, "Sales Line Type"::Item);
        LibraryInventory.CreateItem(CreatedItem);
        VariantCode := LibraryInventory.CreateItemVariant(ItemVariant, CreatedItem."No.");
        CreatedItem.Validate(Description, Item1DescriptionLbl);
        CreatedItem.Modify(true);
        SalesLine.Validate("No.", CreatedItem."No.");
        SalesLine.Validate(Quantity, 5);
        SalesLine.Validate("Variant Code", VariantCode);
        SalesLine.Modify(true);

        // [GIVEN] Generate prompt with Document No.
        LibraryVariableStorage.Enqueue(StrSubstNo(NeedAllItemFromSpecifiedSalesOrderLbl, SalesHeader."No."));
        LibraryVariableStorage.Enqueue('1');
        EnqueueItemWithVariantCode(VariantCode, '5');
        EnqueueItemWithVariantCode(VariantCode, '5');
        // [WHEN] Create a new sales order for this customer and run Sales Line AI Suggestions Page to generate suggestions lines
        // [THEN] Check that correct lines are generated in 'CheckGenerateFromSalesOrder' handler function
        CreateNewSalesHeaderAndRunSalesLineAISuggestionsPage(SalesHeader, SalesLineAISuggestions, Customer."No.", SalesHeader."Document Type"::Order);
        // [THEN] Check the correct sales lines are inserted
        CheckSalesLineContent(SalesLine, SalesHeader."No.");
    end;

    [Test]
    [HandlerFunctions('CheckGenerateFromSalesOrder')]
    procedure TestCopySalesOrderWithSalesBlockedItem()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        CreatedItem: Record Item;
        SalesLineAISuggestions: Page "Sales Line AI Suggestions";
    begin
        // [FEATURE] [Sales Line with AI] [Document Lookup] [Sales Order]
        // [SCENARIO] There are 2 lines in the sales order. The second line are blocked. The system should generate only the first line.
        Initialize();
        LibrarySales.CreateCustomer(Customer);
        // [GIVEN] Create a new sales order for the new customer
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");
        // [GIVEN] Create a new item1 and add it to the new sales order 
        CreateSalesLinesWithItem1(SalesHeader, SalesLine, CreatedItem);
        // [GIVEN] Create a new item4 with SalesBlock = true, and add it to the new sales order 
        CreateSalesLinesWithItem4AndSalesBlock(SalesHeader, SalesLine, CreatedItem);
        LibraryVariableStorage.Enqueue(StrSubstNo(NeedAllItemFromSpecifiedSalesOrderLbl, SalesHeader."No."));
        LibraryVariableStorage.Enqueue('1');
        EnqueueItem1();
        EnqueueItem1();
        // [WHEN] Create a new sales order for this customer and run Sales Line AI Suggestions Page to generate suggestions lines
        // [THEN] Only Item1 is not blocked, hence only 1 line should be generated are generated. Check it in 'CheckGenerateFromSalesOrder' handler function
        CreateNewSalesHeaderAndRunSalesLineAISuggestionsPage(SalesHeader, SalesLineAISuggestions, Customer."No.", SalesHeader."Document Type"::Order);
        // [THEN] Check only 1 line is inserted
        CheckSalesLineContent(SalesLine, SalesHeader."No.");
    end;

    [Test]
    [HandlerFunctions('CheckGenerateFromSalesOrder')]
    procedure TestCopySalesOrderWithUoMItem()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        CreatedItem: Record Item;
        ItemUoM: Record "Item Unit of Measure";
        SalesLineAISuggestions: Page "Sales Line AI Suggestions";
    begin
        // [FEATURE] [Sales Line with AI] [Document Lookup] [Sales Order]
        // [SCENARIO] We have one item with a new UoM. When copying a sales order, the item UoM should be set to the default one defined in item.
        Initialize();
        LibrarySales.CreateCustomer(Customer);
        // [GIVEN] Create a new sales order for the new customer
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");
        // [GIVEN] Create a new item1 and add it to the new sales order 
        CreateSalesLinesWithItem1AndUoM(ItemUoM, SalesHeader, SalesLine, CreatedItem);
        LibraryVariableStorage.Enqueue(StrSubstNo(NeedAllItemFromSpecifiedSalesOrderLbl, SalesHeader."No."));
        LibraryVariableStorage.Enqueue('1');
        EnqueueItem1();
        EnqueueItem1WithUoM(CreatedItem."Base Unit of Measure");
        // [WHEN] Create a new sales order for this customer and run Sales Line AI Suggestions Page to generate suggestions lines
        // [THEN] One line is generated. Check it in 'CheckGenerateFromSalesOrder' handler function
        CreateNewSalesHeaderAndRunSalesLineAISuggestionsPage(SalesHeader, SalesLineAISuggestions, Customer."No.", SalesHeader."Document Type"::Order);
        // [THEN] After inserting, check the UoM is set to the default one defined in item
        CheckSalesLineContentWithUoM(SalesLine, SalesHeader."No.");
    end;

    // --------------------------------------------------------------------------------------
    // Test cases for Sales Order
    [Test]
    [HandlerFunctions('CheckGenerateFromSalesOrder')]
    procedure TestCopySalesOrderByDocNo()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        CreatedItem: Record Item;
        SalesLineAISuggestions: Page "Sales Line AI Suggestions";
    begin
        // [FEATURE] [Sales Line with AI] [Document Lookup] [Sales Order]
        // [SCENARIO] User input 'I want all the items from sales order 10000' in current customer's sales order. System will find the order and copy all the lines to the current sales order.
        Initialize();
        LibrarySales.CreateCustomer(Customer);
        // [GIVEN] Create a new sales order for the new customer
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");
        // [GIVEN] Create 3 lines with item description and add it to the new sales order
        Create3SalesLinesWithItemDescription(SalesHeader, SalesLine, CreatedItem);
        LibraryVariableStorage.Enqueue(StrSubstNo(NeedAllItemFromSpecifiedSalesOrderLbl, SalesHeader."No."));
        LibraryVariableStorage.Enqueue('3');
        Enqueue3SalesLineWithItemDescription();
        Enqueue3SalesLineWithItemDescription();
        // [WHEN] Create a new sales order for this customer and run Sales Line AI Suggestions Page to generate suggestions lines
        // [THEN] Check that correct lines are generated in 'CheckGenerateFromSalesOrder' handler function
        CreateNewSalesHeaderAndRunSalesLineAISuggestionsPage(SalesHeader, SalesLineAISuggestions, Customer."No.", SalesHeader."Document Type"::Order);
        // [THEN] Check all the 3 lines are inserted
        CheckSalesLineContent(SalesLine, SalesHeader."No.");
    end;

    [Test]
    [HandlerFunctions('CheckGenerateFromSalesOrder')]
    procedure TestCopySalesOrderByDocNoFromDifferentCustomer()
    var
        Customer: Record Customer;
        Customer2: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        CreatedItem: Record Item;
        SalesLineAISuggestions: Page "Sales Line AI Suggestions";
    begin
        // [FEATURE] [Sales Line with AI] [Document Lookup] [Sales Order]
        // [SCENARIO] User input 'I want all the items from sales order 10000' in another customer's sales order. The system should generate 3 lines with item description and quantity.
        Initialize();
        LibrarySales.CreateCustomer(Customer);
        LibrarySales.CreateCustomer(Customer2);
        // [GIVEN] Create a new sales order for the new customer
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");
        // [GIVEN] Create 3 lines with item description and add it to the new sales order
        Create3SalesLinesWithItemDescription(SalesHeader, SalesLine, CreatedItem);
        LibraryVariableStorage.Enqueue(StrSubstNo(NeedAllItemFromSpecifiedSalesOrderLbl, SalesHeader."No."));
        LibraryVariableStorage.Enqueue('3');
        Enqueue3SalesLineWithItemDescription();
        Enqueue3SalesLineWithItemDescription();
        // [WHEN] Create a new sales order for this customer and run Sales Line AI Suggestions Page to generate suggestions lines
        // [THEN] Check that correct lines are generated in 'CheckGenerateFromSalesOrder' handler function
        CreateNewSalesHeaderAndRunSalesLineAISuggestionsPage(SalesHeader, SalesLineAISuggestions, Customer2."No.", SalesHeader."Document Type"::Order);
        // [THEN] Check all the 3 lines are inserted
        CheckSalesLineContent(SalesLine, SalesHeader."No.");
    end;

    [Test]
    [HandlerFunctions('CheckGenerateFromSalesOrder')]
    procedure TestCopySalesOrderByExternalDocumentNo()
    var
        Customer: Record Customer;
        Customer2: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        CreatedItem: Record Item;
        SalesLineAISuggestions: Page "Sales Line AI Suggestions";
    begin
        // [FEATURE] [Sales Line with AI] [Document Lookup] [Sales Order]
        // [SCENARIO] User input 'I want all the items from sales order EXTNO123456789123456789123456789123' in another customer's sales order. The system should generate 3 lines with item description and quantity.
        Initialize();
        LibrarySales.CreateCustomer(Customer);
        LibrarySales.CreateCustomer(Customer2);
        // [GIVEN] Create a new sales order for the new customer
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");
        // [GIVEN] Update External Document No.
        SalesHeader.Validate("External Document No.", 'EXTNO123456789123456789123456789123');
        SalesHeader.Modify(true);
        // [GIVEN] Create 3 lines with item description and add it to the new sales order
        Create3SalesLinesWithItemDescription(SalesHeader, SalesLine, CreatedItem);
        LibraryVariableStorage.Enqueue(StrSubstNo(NeedAllItemFromSpecifiedSalesOrderLbl, SalesHeader."External Document No."));
        LibraryVariableStorage.Enqueue('3');
        Enqueue3SalesLineWithItemDescription();
        Enqueue3SalesLineWithItemDescription();
        // [WHEN] Create a new sales order for this customer and run Sales Line AI Suggestions Page to generate suggestions lines
        // [THEN] Check that correct lines are generated in 'CheckGenerateFromSalesOrder' handler function
        CreateNewSalesHeaderAndRunSalesLineAISuggestionsPage(SalesHeader, SalesLineAISuggestions, Customer2."No.", SalesHeader."Document Type"::Order);
        // [THEN] Check all the 3 lines are inserted
        CheckSalesLineContent(SalesLine, SalesHeader."No.");
    end;

    [Test]
    [HandlerFunctions('CheckGenerateFromSalesOrder')]
    procedure TestCopySalesOrderByQuoteNo()
    var
        Customer: Record Customer;
        Customer2: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        CreatedItem: Record Item;
        SalesLineAISuggestions: Page "Sales Line AI Suggestions";
    begin
        // [FEATURE] [Sales Line with AI] [Document Lookup] [Sales Order]
        // [SCENARIO] User input 'I want all the items from sales order QTO214500' in another customer's sales order. The system should generate 3 lines with item description and quantity.
        Initialize();
        LibrarySales.CreateCustomer(Customer);
        LibrarySales.CreateCustomer(Customer2);
        // [GIVEN] Create a new sales order for the new customer
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");
        // [GIVEN] Update Quote No.
        SalesHeader.Validate("Quote No.", 'QTO214500');
        SalesHeader.Modify(true);
        // [GIVEN] Create 3 lines with item description and add it to the new sales order
        Create3SalesLinesWithItemDescription(SalesHeader, SalesLine, CreatedItem);
        LibraryVariableStorage.Enqueue(StrSubstNo(NeedAllItemFromSpecifiedSalesOrderLbl, SalesHeader."Quote No."));
        LibraryVariableStorage.Enqueue('3');
        Enqueue3SalesLineWithItemDescription();
        Enqueue3SalesLineWithItemDescription();
        // [WHEN] Create a new sales order for this customer and run Sales Line AI Suggestions Page to generate suggestions lines
        // [THEN] Check that correct lines are generated in 'CheckGenerateFromSalesOrder' handler function
        CreateNewSalesHeaderAndRunSalesLineAISuggestionsPage(SalesHeader, SalesLineAISuggestions, Customer2."No.", SalesHeader."Document Type"::Order);
        // [THEN] Check all the 3 lines are inserted
        CheckSalesLineContent(SalesLine, SalesHeader."No.");
    end;

    [Test]
    [HandlerFunctions('CheckGenerateFromSalesOrder')]
    procedure TestCopySalesOrderByReferenceNo()
    var
        Customer: Record Customer;
        Customer2: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        CreatedItem: Record Item;
        SalesLineAISuggestions: Page "Sales Line AI Suggestions";
    begin
        // [FEATURE] [Sales Line with AI] [Document Lookup] [Sales Order]
        // [SCENARIO] User input 'I want all the items from sales order REF214500' in another customer's sales order. The system should generate 3 lines with item description and quantity.
        Initialize();
        LibrarySales.CreateCustomer(Customer);
        LibrarySales.CreateCustomer(Customer2);
        // [GIVEN] Create a new sales order for the new customer
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");
        // [GIVEN] Update Your Reference No.
        SalesHeader.Validate("Your Reference", 'REF214500');
        SalesHeader.Modify(true);
        // [GIVEN] Create 3 lines with item description and add it to the new sales order
        Create3SalesLinesWithItemDescription(SalesHeader, SalesLine, CreatedItem);
        LibraryVariableStorage.Enqueue(StrSubstNo(NeedAllItemFromSpecifiedSalesOrderLbl, SalesHeader."Your Reference"));
        LibraryVariableStorage.Enqueue('3');
        Enqueue3SalesLineWithItemDescription();
        Enqueue3SalesLineWithItemDescription();
        // [WHEN] Create a new sales order for this customer and run Sales Line AI Suggestions Page to generate suggestions lines
        // [THEN] Check that correct lines are generated in 'CheckGenerateFromSalesOrder' handler function
        CreateNewSalesHeaderAndRunSalesLineAISuggestionsPage(SalesHeader, SalesLineAISuggestions, Customer2."No.", SalesHeader."Document Type"::Order);
        // [THEN] Check all the 3 lines are inserted
        CheckSalesLineContent(SalesLine, SalesHeader."No.");
    end;

    [Test]
    [HandlerFunctions('CheckGenerateFromSalesOrder')]
    procedure TestAmbiguouslyCopySalesOrderByExternalDocumentNo()
    var
        Customer: Record Customer;
        Customer2: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        CreatedItem: Record Item;
        SalesLineAISuggestions: Page "Sales Line AI Suggestions";
    begin
        // [FEATURE] [Sales Line with AI] [Document Lookup] [Sales Order]
        // [SCENARIO] User input 'I want all the items from sales order EXTNO123456789123456789123456789123' in another customer's sales order. The system should generate 3 lines with item description and quantity.
        Initialize();
        LibrarySales.CreateCustomer(Customer);
        LibrarySales.CreateCustomer(Customer2);
        // [GIVEN] Create a new sales order for the new customer
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");
        // Update External Document No.
        SalesHeader.Validate("External Document No.", 'EXTNO123456789123456789123456789123');
        SalesHeader.Modify(true);
        // [GIVEN] Create 3 lines with item description and add it to the new sales order
        Create3SalesLinesWithItemDescription(SalesHeader, SalesLine, CreatedItem);
        LibraryVariableStorage.Enqueue(StrSubstNo(NeedAllItemFromSpecifiedSalesOrderLbl, CopyStr(SalesHeader."External Document No.", 2, StrLen(SalesHeader."External Document No.") - 1)));
        LibraryVariableStorage.Enqueue('3');
        Enqueue3SalesLineWithItemDescription();
        Enqueue3SalesLineWithItemDescription();
        // [WHEN] Create a new sales order for this customer and run Sales Line AI Suggestions Page to generate suggestions lines
        // [THEN] Check that correct lines are generated in 'CheckGenerateFromSalesOrder' handler function
        CreateNewSalesHeaderAndRunSalesLineAISuggestionsPage(SalesHeader, SalesLineAISuggestions, Customer2."No.", SalesHeader."Document Type"::Order);
        // [THEN] Check all the 3 lines are inserted
        CheckSalesLineContent(SalesLine, SalesHeader."No.");
    end;

    [Test]
    [HandlerFunctions('CheckGenerateFromSalesOrder')]
    procedure TestAmbiguouslyCopySalesOrderByQuoteNo()
    var
        Customer: Record Customer;
        Customer2: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        CreatedItem: Record Item;
        SalesLineAISuggestions: Page "Sales Line AI Suggestions";
    begin
        // [FEATURE] [Sales Line with AI] [Document Lookup] [Sales Order] [Ambiguous Search]
        // [SCENARIO] There is an item with Reference Number 'EXTNO123456789123456789123456789123'. User input 'I want all the items from sales order XTNO12345678912345678912345678912' in another customer's sales order. The system should generate 3 lines with item description and quantity.
        Initialize();
        LibrarySales.CreateCustomer(Customer);
        LibrarySales.CreateCustomer(Customer2);
        // [GIVEN] Create a new sales order for the new customer
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");
        SalesHeader.Validate("Quote No.", 'QTO214500');
        SalesHeader.Modify(true);
        // [GIVEN] Create 3 lines with item description and add it to the new sales order
        Create3SalesLinesWithItemDescription(SalesHeader, SalesLine, CreatedItem);
        // [GIVEN] Remove the first and last character from the Quote No.
        LibraryVariableStorage.Enqueue(StrSubstNo(NeedAllItemFromSpecifiedSalesOrderLbl, CopyStr(SalesHeader."Quote No.", 2, StrLen(SalesHeader."Quote No.") - 1)));
        LibraryVariableStorage.Enqueue('3');
        Enqueue3SalesLineWithItemDescription();
        Enqueue3SalesLineWithItemDescription();
        // [WHEN] Create a new sales order for this customer and run Sales Line AI Suggestions Page to generate suggestions lines
        // [THEN] Check that correct lines are generated in 'CheckGenerateFromSalesOrder' handler function
        CreateNewSalesHeaderAndRunSalesLineAISuggestionsPage(SalesHeader, SalesLineAISuggestions, Customer2."No.", SalesHeader."Document Type"::Order);
        // [THEN] Check all the 3 lines are inserted
        CheckSalesLineContent(SalesLine, SalesHeader."No.");
    end;

    [Test]
    [HandlerFunctions('CheckGenerateFromSalesOrder')]
    procedure TestAmbiguouslyCopySalesOrderByReferenceNo()
    var
        Customer: Record Customer;
        Customer2: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        CreatedItem: Record Item;
        SalesLineAISuggestions: Page "Sales Line AI Suggestions";
    begin
        // [FEATURE] [Sales Line with AI] [Document Lookup] [Sales Order] [Ambiguous Search]
        // [SCENARIO] There is an item with Reference Number 'REF214500'. User input 'I want all the items from sales order EF214500' in another customer's sales order. The system should generate 3 lines with item description and quantity.
        Initialize();
        LibrarySales.CreateCustomer(Customer);
        LibrarySales.CreateCustomer(Customer2);
        // [GIVEN] Create a new sales order for the new customer
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");
        SalesHeader.Validate("Your Reference", 'REF214500');
        SalesHeader.Modify(true);
        // [GIVEN] Create 3 lines with item description and add it to the new sales order
        Create3SalesLinesWithItemDescription(SalesHeader, SalesLine, CreatedItem);
        // [GIVEN] Remove the first and last character from the Your Reference No.
        LibraryVariableStorage.Enqueue(StrSubstNo(NeedAllItemFromSpecifiedSalesOrderLbl, CopyStr(SalesHeader."Your Reference", 2, StrLen(SalesHeader."Your Reference") - 1)));
        LibraryVariableStorage.Enqueue('3');
        Enqueue3SalesLineWithItemDescription();
        Enqueue3SalesLineWithItemDescription();
        // [WHEN] Create a new sales order for this customer and run Sales Line AI Suggestions Page to generate suggestions lines
        // [THEN] Check that correct lines are generated in 'CheckGenerateFromSalesOrder' handler function
        CreateNewSalesHeaderAndRunSalesLineAISuggestionsPage(SalesHeader, SalesLineAISuggestions, Customer2."No.", SalesHeader."Document Type"::Order);
        // [THEN] Check all the 3 lines are inserted
        CheckSalesLineContent(SalesLine, SalesHeader."No.");
    end;

    [Test]
    [HandlerFunctions('CheckGenerateFromSalesOrder')]
    procedure TestCopySalesOrderByDate1()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        CreatedItem: Record Item;
        SalesLineAISuggestions: Page "Sales Line AI Suggestions";
        StartDate: Date;
    begin
        // [FEATURE] [Sales Line with AI] [Document Lookup] [Sales Order]
        // [SCENARIO] User input 'I want all the items from sales order with posting date 01/01/2019' in current customer's sales order. System will find the order and copy all the lines to the current sales order.
        Initialize();
        LibrarySales.CreateCustomer(Customer);
        // [GIVEN] Create a new sales order for the new customer
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");
        Evaluate(StartDate, '01/01/2019');
        SalesHeader.Validate("Posting Date", StartDate);
        SalesHeader.Modify(true);
        // [GIVEN] Create 3 lines with item description and add it to the new sales order
        Create3SalesLinesWithItemDescription(SalesHeader, SalesLine, CreatedItem);
        LibraryVariableStorage.Enqueue('I need all items from sales order with posting date 01/01/2019');
        LibraryVariableStorage.Enqueue('3');
        Enqueue3SalesLineWithItemDescription();
        Enqueue3SalesLineWithItemDescription();
        // [WHEN] Create a new sales order for this customer and run Sales Line AI Suggestions Page to generate suggestions lines
        // [THEN] Check that correct lines are generated in 'CheckGenerateFromSalesOrder' handler function
        CreateNewSalesHeaderAndRunSalesLineAISuggestionsPage(SalesHeader, SalesLineAISuggestions, Customer."No.", SalesHeader."Document Type"::Order);
        // [THEN] Check all the 3 lines are inserted
        CheckSalesLineContent(SalesLine, SalesHeader."No.");
    end;

    [Test]
    [HandlerFunctions('CheckGenerateFromSalesOrder')]
    procedure TestCopySalesOrderByDateWithStyle1()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        CreatedItem: Record Item;
        SalesLineAISuggestions: Page "Sales Line AI Suggestions";
        StartDate: Date;
    begin
        // [FEATURE] [Sales Line with AI] [Document Lookup] [Sales Order]
        // [SCENARIO] User input 'I want all the items from sales order with posting date 2019 1 1' in current customer's sales order. System will find the order and copy all the lines to the current sales order.
        Initialize();
        LibrarySales.CreateCustomer(Customer);
        // [GIVEN] Create a new sales order for the new customer
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");
        Evaluate(StartDate, '01/01/2019');
        SalesHeader.Validate("Posting Date", StartDate);
        SalesHeader.Modify(true);
        // [GIVEN] Create 3 lines with item description and add it to the new sales order
        Create3SalesLinesWithItemDescription(SalesHeader, SalesLine, CreatedItem);
        LibraryVariableStorage.Enqueue('I need all items from sales order with posting date 2019 1 1');
        LibraryVariableStorage.Enqueue('3');
        Enqueue3SalesLineWithItemDescription();
        Enqueue3SalesLineWithItemDescription();
        // [WHEN] Create a new sales order for this customer and run Sales Line AI Suggestions Page to generate suggestions lines
        // [THEN] Check that correct lines are generated in 'CheckGenerateFromSalesOrder' handler function
        CreateNewSalesHeaderAndRunSalesLineAISuggestionsPage(SalesHeader, SalesLineAISuggestions, Customer."No.", SalesHeader."Document Type"::Order);
        // [THEN] Check all the 3 lines are inserted
        CheckSalesLineContent(SalesLine, SalesHeader."No.");
    end;

    [Test]
    [HandlerFunctions('CheckGenerateFromSalesOrder')]
    procedure TestCopySalesOrderByDateWithStyle2()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        CreatedItem: Record Item;
        SalesLineAISuggestions: Page "Sales Line AI Suggestions";
        StartDate: Date;
    begin
        // [FEATURE] [Sales Line with AI] [Document Lookup] [Sales Order]
        // [SCENARIO] User input 'I want all the items from sales order with posting date 2019 1 Jan' in current customer's sales order. System will find the order and copy all the lines to the current sales order.
        Initialize();
        LibrarySales.CreateCustomer(Customer);
        // [GIVEN] Create a new sales order for the new customer
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");
        Evaluate(StartDate, '01/01/2019');
        SalesHeader.Validate("Posting Date", StartDate);
        SalesHeader.Modify(true);
        // [GIVEN] Create 3 lines with item description and add it to the new sales order
        Create3SalesLinesWithItemDescription(SalesHeader, SalesLine, CreatedItem);
        LibraryVariableStorage.Enqueue('I need all items from sales order with posting date 2019 1 Jan');
        LibraryVariableStorage.Enqueue('3');
        Enqueue3SalesLineWithItemDescription();
        Enqueue3SalesLineWithItemDescription();
        // [WHEN] Create a new sales order for this customer and run Sales Line AI Suggestions Page to generate suggestions lines
        // [THEN] Check that correct lines are generated in 'CheckGenerateFromSalesOrder' handler function
        CreateNewSalesHeaderAndRunSalesLineAISuggestionsPage(SalesHeader, SalesLineAISuggestions, Customer."No.", SalesHeader."Document Type"::Order);
        // [THEN] Check all the 3 lines are inserted
        CheckSalesLineContent(SalesLine, SalesHeader."No.");
    end;

    [Test]
    [HandlerFunctions('CheckGenerateFromSalesOrder')]
    procedure TestCopySalesOrderByDateWithStyle3()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        CreatedItem: Record Item;
        SalesLineAISuggestions: Page "Sales Line AI Suggestions";
        StartDate: Date;
    begin
        // [FEATURE] [Sales Line with AI] [Document Lookup] [Sales Order]
        // [SCENARIO] User input 'I want all the items from sales order with posting date 1/Jan/2019' in current customer's sales order. System will find the order and copy all the lines to the current sales order.
        Initialize();
        LibrarySales.CreateCustomer(Customer);
        // [GIVEN] Create a new sales order for the new customer
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");
        Evaluate(StartDate, '01/01/2019');
        SalesHeader.Validate("Posting Date", StartDate);
        SalesHeader.Modify(true);
        // [GIVEN] Create 3 lines with item description and add it to the new sales order
        Create3SalesLinesWithItemDescription(SalesHeader, SalesLine, CreatedItem);
        LibraryVariableStorage.Enqueue('I need all items from sales order with posting date 1/Jan/2019');
        LibraryVariableStorage.Enqueue('3');
        Enqueue3SalesLineWithItemDescription();
        Enqueue3SalesLineWithItemDescription();
        // [WHEN] Create a new sales order for this customer and run Sales Line AI Suggestions Page to generate suggestions lines
        // [THEN] Check that correct lines are generated in 'CheckGenerateFromSalesOrder' handler function
        CreateNewSalesHeaderAndRunSalesLineAISuggestionsPage(SalesHeader, SalesLineAISuggestions, Customer."No.", SalesHeader."Document Type"::Order);
        // [THEN] Check all the 3 lines are inserted
        CheckSalesLineContent(SalesLine, SalesHeader."No.");
    end;

    [Test]
    [HandlerFunctions('CheckNothingGeneratedFromSalesOrder')]
    procedure TestCopySalesOrderByDateFromAnotherCustomer()
    var
        Customer: Record Customer;
        Customer2: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        CreatedItem: Record Item;
        SalesLineAISuggestions: Page "Sales Line AI Suggestions";
        StartDate: Date;
    begin
        // [FEATURE] [Sales Line with AI] [Document Lookup] [Sales Order]
        // [SCENARIO] User input 'I want all the items from sales order with posting date 01/01/2019' from another customer's sales order. System cannot find the order and should not generate any lines.
        Initialize();
        LibrarySales.CreateCustomer(Customer);
        LibrarySales.CreateCustomer(Customer2);
        // [GIVEN] Create a new sales order for the new customer
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");
        Evaluate(StartDate, '01/01/2019');
        SalesHeader.Validate("Posting Date", StartDate);
        SalesHeader.Modify(true);
        // [GIVEN] Create 3 lines with item description and add it to the new sales order
        Create3SalesLinesWithItemDescription(SalesHeader, SalesLine, CreatedItem);
        LibraryVariableStorage.Enqueue('I need all items from sales order with posting date 01/01/2019');
        // [WHEN] Create a new sales order for another customer and run Sales Line AI Suggestions Page to generate suggestions lines
        // [THEN] Check no line is generated in 'CheckNothingGeneratedFromSalesOrder' handler function
        CreateNewSalesHeaderAndRunSalesLineAISuggestionsPage(SalesHeader, SalesLineAISuggestions, Customer2."No.", SalesHeader."Document Type"::Order);
        // [THEN] Check no line is inserted to this document
        CheckEmptySalesLineContent(SalesLine, SalesHeader."No.");
    end;

    [Test]
    [HandlerFunctions('CheckGenerateFromSalesOrder')]
    procedure TestCopySalesOrderByDateRange1()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        CreatedItem: Record Item;
        SalesLineAISuggestions: Page "Sales Line AI Suggestions";
        StartDate: Date;
    begin
        // [FEATURE] [Sales Line with AI] [Document Lookup] [Sales Order]
        // [SCENARIO] User input 'I need all items from sales order on January of 2019' in current customer's sales order. System will find the order and copy all the lines to the current sales order.
        Initialize();
        LibrarySales.CreateCustomer(Customer);
        // [GIVEN] Create a new sales order for the new customer
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");
        Evaluate(StartDate, '01/01/2019');
        SalesHeader.Validate("Posting Date", StartDate);
        SalesHeader.Modify(true);
        // [GIVEN] Create 3 lines with item description and add it to the new sales order
        Create3SalesLinesWithItemDescription(SalesHeader, SalesLine, CreatedItem);
        LibraryVariableStorage.Enqueue('I need all items from sales order on January of 2019');
        LibraryVariableStorage.Enqueue('3');
        Enqueue3SalesLineWithItemDescription();
        Enqueue3SalesLineWithItemDescription();
        // [WHEN] Create a new sales order for this customer and run Sales Line AI Suggestions Page to generate suggestions lines
        // [THEN] Check that correct lines are generated in 'CheckGenerateFromSalesOrder' handler function
        CreateNewSalesHeaderAndRunSalesLineAISuggestionsPage(SalesHeader, SalesLineAISuggestions, Customer."No.", SalesHeader."Document Type"::Order);
        // [THEN] Check all the 3 lines are inserted
        CheckSalesLineContent(SalesLine, SalesHeader."No.");
    end;

    [Test]
    [HandlerFunctions('CheckGenerateFromSalesOrder')]
    procedure TestCopySalesOrderByDateRange2()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        CreatedItem: Record Item;
        SalesLineAISuggestions: Page "Sales Line AI Suggestions";
        StartDate: Date;
    begin
        // [FEATURE] [Sales Line with AI] [Document Lookup] [Sales Order]
        // [SCENARIO] User input 'I need all items from sales order from 2018-12-30 to 2019-Jan-5' in current customer's sales order. System will find the order and copy all the lines to the current sales order.
        Initialize();
        LibrarySales.CreateCustomer(Customer);
        // [GIVEN] Create a new sales order for the new customer
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");
        Evaluate(StartDate, '01/01/2019');
        SalesHeader.Validate("Posting Date", StartDate);
        SalesHeader.Modify(true);
        // [GIVEN] Create 3 lines with item description and add it to the new sales order
        Create3SalesLinesWithItemDescription(SalesHeader, SalesLine, CreatedItem);
        LibraryVariableStorage.Enqueue('I need all items from sales order from 2018-12-30 to 2019-Jan-5');
        LibraryVariableStorage.Enqueue('3');
        Enqueue3SalesLineWithItemDescription();
        Enqueue3SalesLineWithItemDescription();
        // [WHEN] Create a new sales order for this customer and run Sales Line AI Suggestions Page to generate suggestions lines
        // [THEN] Check that correct lines are generated in 'CheckGenerateFromSalesOrder' handler function
        CreateNewSalesHeaderAndRunSalesLineAISuggestionsPage(SalesHeader, SalesLineAISuggestions, Customer."No.", SalesHeader."Document Type"::Order);
        // [THEN] Check all the 3 lines are inserted
        CheckSalesLineContent(SalesLine, SalesHeader."No.");
    end;

    [Test]
    [HandlerFunctions('CheckNothingGeneratedFromSalesOrder,SendNotificationHandler')]
    procedure TestCopySalesLineWithIncorrectDocumentType()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        CreatedItem: Record Item;
        SalesLineAISuggestions: Page "Sales Line AI Suggestions";
    begin
        // [FEATURE] [Sales Line with AI] [Document Lookup] [Sales Order]
        // [SCENARIO] User input 'I want all the items from unknown document'. System cannot find the order and should not generate any lines.
        Initialize();
        LibrarySales.CreateCustomer(Customer);
        // [GIVEN] Create a new sales order for the new customer
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");
        // [GIVEN] Create 3 lines with item description and add it to the new sales order
        Create3SalesLinesWithItemDescription(SalesHeader, SalesLine, CreatedItem);
        LibraryVariableStorage.Enqueue(NeedAllItemFromUnknownDocumentLbl);
        LibraryVariableStorage.Enqueue(UnknownDocTypeErr);
        // [WHEN] Create a new sales order for this customer and run Sales Line AI Suggestions Page to generate suggestions lines
        // [THEN] Check no line is generated in 'CheckNothingGeneratedFromSalesOrder' handler function
        // [THEN] Check the error message in 'SendNotificationHandler' handler function
        CreateNewSalesHeaderAndRunSalesLineAISuggestionsPage(SalesHeader, SalesLineAISuggestions, Customer."No.", SalesHeader."Document Type"::Order);
        // [THEN] Check no line is inserted to this document
        CheckEmptySalesLineContent(SalesLine, SalesHeader."No.");
    end;
    //--------------------------------------------------------------------------------------
    // Test cases for Sales Invoice
    [Test]
    [HandlerFunctions('CheckGenerateFromSalesOrder')]
    procedure TestCopySalesInvoiceByDocNo()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        CreatedItem: Record Item;
        SalesLineAISuggestions: Page "Sales Line AI Suggestions";
    begin
        // [FEATURE] [Sales Line with AI] [Document Lookup] [Sales Invoice]
        // [SCENARIO] User input 'I want all the items from sales invoice 10000' in current customer's sales order. System will find the invoice and copy all the lines to the current sales order.
        Initialize();
        LibrarySales.CreateCustomer(Customer);
        // [GIVEN] Create a new sales order for the new customer
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");
        // [GIVEN] Create 3 lines with item description and add it to the new sales order
        Create3SalesLinesWithItemDescription(SalesHeader, SalesLine, CreatedItem);
        // [GIVEN] Post the sales order to create the sales invoice
        LibrarySales.PostSalesDocument(SalesHeader, true, true);
        LibraryVariableStorage.Enqueue(StrSubstNo(NeedAllItemFromSpecifiedSalesInvoiceLbl, SalesHeader."No."));
        LibraryVariableStorage.Enqueue('3');
        Enqueue3SalesLineWithItemDescription();
        Enqueue3SalesLineWithItemDescription();
        // [WHEN] Create a new sales order for this customer and run Sales Line AI Suggestions Page to generate suggestions lines
        // [THEN] Check that correct lines are generated in 'CheckGenerateFromSalesOrder' handler function
        CreateNewSalesHeaderAndRunSalesLineAISuggestionsPage(SalesHeader, SalesLineAISuggestions, Customer."No.", SalesHeader."Document Type"::Order);
        // [THEN] Check all the 3 lines are inserted
        CheckSalesLineContent(SalesLine, SalesHeader."No.");
    end;

    [Test]
    [HandlerFunctions('CheckGenerateFromSalesOrder')]
    procedure TestCopySalesInvoiceByDocNoFromDifferentCustomer()
    var
        Customer: Record Customer;
        Customer2: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        CreatedItem: Record Item;
        SalesLineAISuggestions: Page "Sales Line AI Suggestions";
    begin
        // [FEATURE] [Sales Line with AI] [Document Lookup] [Sales Invoice]
        // [SCENARIO] User input 'I want all the items from sales invoice 10000' in another customer's sales order. The system should generate 3 lines with item description and quantity.
        Initialize();
        LibrarySales.CreateCustomer(Customer);
        LibrarySales.CreateCustomer(Customer2);
        // [GIVEN] Create a new sales order for the new customer
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");
        // [GIVEN] Create 3 lines with item description and add it to the new sales order
        Create3SalesLinesWithItemDescription(SalesHeader, SalesLine, CreatedItem);
        // [GIVEN] Post the sales order to create the sales invoice
        LibrarySales.PostSalesDocument(SalesHeader, true, true);
        LibraryVariableStorage.Enqueue(StrSubstNo(NeedAllItemFromSpecifiedSalesInvoiceLbl, SalesHeader."No."));
        LibraryVariableStorage.Enqueue('3');
        Enqueue3SalesLineWithItemDescription();
        Enqueue3SalesLineWithItemDescription();
        // [WHEN] Create a new sales order for this customer and run Sales Line AI Suggestions Page to generate suggestions lines
        // [THEN] Check that correct lines are generated in 'CheckGenerateFromSalesOrder' handler function
        CreateNewSalesHeaderAndRunSalesLineAISuggestionsPage(SalesHeader, SalesLineAISuggestions, Customer2."No.", SalesHeader."Document Type"::Order);
        // [THEN] Check all the 3 lines are inserted
        CheckSalesLineContent(SalesLine, SalesHeader."No.");
    end;

    [Test]
    [HandlerFunctions('CheckGenerateFromSalesOrder')]
    procedure TestCopySalesInvoiceByExternalDocumentNo()
    var
        Customer: Record Customer;
        Customer2: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        CreatedItem: Record Item;
        SalesLineAISuggestions: Page "Sales Line AI Suggestions";
    begin
        // [FEATURE] [Sales Line with AI] [Document Lookup] [Sales Invoice]
        // [SCENARIO] User input 'I want all the items from sales invoice EXT10000' in another customer's sales order. The system should generate 3 lines with item description and quantity.
        Initialize();
        LibrarySales.CreateCustomer(Customer);
        LibrarySales.CreateCustomer(Customer2);
        // [GIVEN] Create a new sales order for the new customer
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");
        // [GIVEN]Update External Document No.
        SalesHeader.Validate("External Document No.", 'EXTNO123456789123456789123456789123');
        SalesHeader.Modify(true);
        // [GIVEN] Create 3 lines with item description and add it to the new sales order
        Create3SalesLinesWithItemDescription(SalesHeader, SalesLine, CreatedItem);
        // [GIVEN] Post the sales order to create the sales invoice
        LibrarySales.PostSalesDocument(SalesHeader, true, true);
        LibraryVariableStorage.Enqueue(StrSubstNo(NeedAllItemFromSpecifiedSalesInvoiceLbl, SalesHeader."External Document No."));
        LibraryVariableStorage.Enqueue('3');
        Enqueue3SalesLineWithItemDescription();
        Enqueue3SalesLineWithItemDescription();
        // [WHEN] Create a new sales order for this customer and run Sales Line AI Suggestions Page to generate suggestions lines
        // [THEN] Check that correct lines are generated in 'CheckGenerateFromSalesOrder' handler function
        CreateNewSalesHeaderAndRunSalesLineAISuggestionsPage(SalesHeader, SalesLineAISuggestions, Customer2."No.", SalesHeader."Document Type"::Order);
        // [THEN] Check all the 3 lines are inserted
        CheckSalesLineContent(SalesLine, SalesHeader."No.");
    end;

    [Test]
    [HandlerFunctions('CheckGenerateFromSalesOrder')]
    procedure TestCopySalesInvoiceByQuoteNo()
    var
        Customer: Record Customer;
        Customer2: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        CreatedItem: Record Item;
        SalesLineAISuggestions: Page "Sales Line AI Suggestions";
    begin
        // [FEATURE] [Sales Line with AI] [Document Lookup] [Sales Invoice]
        // [SCENARIO] User input 'I want all the items from sales invoice QTO214500' in another customer's sales order. The system should generate 3 lines with item description and quantity.
        Initialize();
        LibrarySales.CreateCustomer(Customer);
        LibrarySales.CreateCustomer(Customer2);
        // [GIVEN] Create a new sales order for the new customer
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");
        SalesHeader.Validate("Quote No.", 'QTO214500');
        SalesHeader.Modify(true);
        // [GIVEN] Create 3 lines with item description and add it to the new sales order
        Create3SalesLinesWithItemDescription(SalesHeader, SalesLine, CreatedItem);
        // [GIVEN] Post the sales order to create the sales invoice
        LibrarySales.PostSalesDocument(SalesHeader, true, true);
        //  generate prompt with quote No.
        LibraryVariableStorage.Enqueue(StrSubstNo(NeedAllItemFromSpecifiedSalesInvoiceLbl, SalesHeader."Quote No."));
        LibraryVariableStorage.Enqueue('3');
        Enqueue3SalesLineWithItemDescription();
        Enqueue3SalesLineWithItemDescription();
        // [WHEN] Create a new sales order for this customer and run Sales Line AI Suggestions Page to generate suggestions lines
        // [THEN] Check that correct lines are generated in 'CheckGenerateFromSalesOrder' handler function
        CreateNewSalesHeaderAndRunSalesLineAISuggestionsPage(SalesHeader, SalesLineAISuggestions, Customer2."No.", SalesHeader."Document Type"::Order);
        // [THEN] Check all the 3 lines are inserted
        CheckSalesLineContent(SalesLine, SalesHeader."No.");
    end;

    [Test]
    [HandlerFunctions('CheckGenerateFromSalesOrder')]
    procedure TestCopySalesInvoiceByReferenceNo()
    var
        Customer: Record Customer;
        Customer2: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        CreatedItem: Record Item;
        SalesLineAISuggestions: Page "Sales Line AI Suggestions";
    begin
        // [FEATURE] [Sales Line with AI] [Document Lookup] [Sales Invoice]
        // [SCENARIO] User input 'I want all the items from sales invoice REF214500' in another customer's sales order. The system should generate 3 lines with item description and quantity.
        Initialize();
        LibrarySales.CreateCustomer(Customer);
        LibrarySales.CreateCustomer(Customer2);
        // [GIVEN] Create a new sales order for the new customer
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");
        SalesHeader.Validate("Your Reference", 'REF214500');
        SalesHeader.Modify(true);
        // [GIVEN] Create 3 lines with item description and add it to the new sales order
        Create3SalesLinesWithItemDescription(SalesHeader, SalesLine, CreatedItem);
        // [GIVEN] Post the sales order to create the sales invoice
        LibrarySales.PostSalesDocument(SalesHeader, true, true);
        LibraryVariableStorage.Enqueue(StrSubstNo(NeedAllItemFromSpecifiedSalesInvoiceLbl, SalesHeader."Your Reference"));
        LibraryVariableStorage.Enqueue('3');
        Enqueue3SalesLineWithItemDescription();
        Enqueue3SalesLineWithItemDescription();
        // [WHEN] Create a new sales order for this customer and run Sales Line AI Suggestions Page to generate suggestions lines
        // [THEN] Check that correct lines are generated in 'CheckGenerateFromSalesOrder' handler function
        CreateNewSalesHeaderAndRunSalesLineAISuggestionsPage(SalesHeader, SalesLineAISuggestions, Customer2."No.", SalesHeader."Document Type"::Order);
        // [THEN] Check all the 3 lines are inserted
        CheckSalesLineContent(SalesLine, SalesHeader."No.");
    end;

    [Test]
    [HandlerFunctions('CheckGenerateFromSalesOrder')]
    procedure TestAmbiguouslyCopySalesInvoiceByExternalDocumentNo()
    var
        Customer: Record Customer;
        Customer2: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        CreatedItem: Record Item;
        SalesLineAISuggestions: Page "Sales Line AI Suggestions";
    begin
        // [FEATURE] [Sales Line with AI] [Document Lookup] [Sales Invoice] [Ambiguous Search]
        // [SCENARIO] There is an item with External Document Number 'EXTNO123456789123456789123456789123'. User input 'I want all the items from sales invoice XTNO12345678912345678912345678912' in another customer's sales order. The system should generate 3 lines with item description and quantity.
        Initialize();
        LibrarySales.CreateCustomer(Customer);
        LibrarySales.CreateCustomer(Customer2);
        // [GIVEN] Create a new sales order for the new customer
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");
        // [GIVEN] Update External Document No.
        SalesHeader.Validate("External Document No.", 'EXTNO123456789123456789123456789123');
        SalesHeader.Modify(true);
        // [GIVEN] Create 3 lines with item description and add it to the new sales order
        Create3SalesLinesWithItemDescription(SalesHeader, SalesLine, CreatedItem);
        // [GIVEN] Post the sales order to create the sales invoice
        LibrarySales.PostSalesDocument(SalesHeader, true, true);
        // [GIVEN] Remove the first and last character from the External Document No. as user's input
        LibraryVariableStorage.Enqueue(StrSubstNo(NeedAllItemFromSpecifiedSalesInvoiceLbl, CopyStr(SalesHeader."External Document No.", 2, StrLen(SalesHeader."External Document No.") - 1)));
        LibraryVariableStorage.Enqueue('3');
        Enqueue3SalesLineWithItemDescription();
        Enqueue3SalesLineWithItemDescription();
        // [WHEN] Create a new sales order for this customer and run Sales Line AI Suggestions Page to generate suggestions lines
        // [THEN] Check that correct lines are generated in 'CheckGenerateFromSalesOrder' handler function
        CreateNewSalesHeaderAndRunSalesLineAISuggestionsPage(SalesHeader, SalesLineAISuggestions, Customer2."No.", SalesHeader."Document Type"::Order);
        // [THEN] Check all the 3 lines are inserted
        CheckSalesLineContent(SalesLine, SalesHeader."No.");
    end;

    [Test]
    [HandlerFunctions('CheckGenerateFromSalesOrder')]
    procedure TestAmbiguouslyCopySalesInvoiceByQuoteNo()
    var
        Customer: Record Customer;
        Customer2: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        CreatedItem: Record Item;
        SalesLineAISuggestions: Page "Sales Line AI Suggestions";
    begin
        // [FEATURE] [Sales Line with AI] [Document Lookup] [Sales Invoice] [Ambiguous Search]
        // [SCENARIO] There is an item with Quote Number 'QTO214500'. User input 'I want all the items from sales invoice XTNO12345678912345678912345678912' in another customer's sales order. The system should generate 3 lines with item description and quantity.
        Initialize();
        LibrarySales.CreateCustomer(Customer);
        LibrarySales.CreateCustomer(Customer2);
        // [GIVEN] Create a new sales order for the new customer
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");
        SalesHeader.Validate("Quote No.", 'QTO214500');
        SalesHeader.Modify(true);
        // [GIVEN] Create 3 lines with item description and add it to the new sales order
        Create3SalesLinesWithItemDescription(SalesHeader, SalesLine, CreatedItem);
        // [GIVEN] Post the sales order to create the sales invoice
        LibrarySales.PostSalesDocument(SalesHeader, true, true);
        LibraryVariableStorage.Enqueue(StrSubstNo(NeedAllItemFromSpecifiedSalesInvoiceLbl, CopyStr(SalesHeader."Quote No.", 2, StrLen(SalesHeader."Quote No.") - 1)));
        LibraryVariableStorage.Enqueue('3');
        Enqueue3SalesLineWithItemDescription();
        Enqueue3SalesLineWithItemDescription();
        // [WHEN] Create a new sales order for this customer and run Sales Line AI Suggestions Page to generate suggestions lines
        // [THEN] Check that correct lines are generated in 'CheckGenerateFromSalesOrder' handler function
        CreateNewSalesHeaderAndRunSalesLineAISuggestionsPage(SalesHeader, SalesLineAISuggestions, Customer2."No.", SalesHeader."Document Type"::Order);
        // [THEN] Check all the 3 lines are inserted
        CheckSalesLineContent(SalesLine, SalesHeader."No.");
    end;

    [Test]
    [HandlerFunctions('CheckGenerateFromSalesOrder')]
    procedure TestAmbiguouslyCopySalesInvoiceByReferenceNo()
    var
        Customer: Record Customer;
        Customer2: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        CreatedItem: Record Item;
        SalesLineAISuggestions: Page "Sales Line AI Suggestions";
    begin
        // [FEATURE] [Sales Line with AI] [Document Lookup] [Sales Invoice] [Ambiguous Search]
        // [SCENARIO] There is an item with Reference Number 'REF214500'. User input 'I want all the items from sales invoice XTNO12345678912345678912345678912' in another customer's sales order. The system should generate 3 lines with item description and quantity.
        Initialize();
        LibrarySales.CreateCustomer(Customer);
        LibrarySales.CreateCustomer(Customer2);
        // [GIVEN] Create a new sales order for the new customer
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");
        SalesHeader.Validate("Your Reference", 'REF214500');
        SalesHeader.Modify(true);
        // [GIVEN] Create 3 lines with item description and add it to the new sales order
        Create3SalesLinesWithItemDescription(SalesHeader, SalesLine, CreatedItem);
        // [GIVEN] Post the sales order to create the sales invoice
        LibrarySales.PostSalesDocument(SalesHeader, true, true);
        // [GIVEN] Remove the first and last character from the Your Reference No.
        LibraryVariableStorage.Enqueue(StrSubstNo(NeedAllItemFromSpecifiedSalesInvoiceLbl, CopyStr(SalesHeader."Your Reference", 2, StrLen(SalesHeader."Your Reference") - 1)));
        LibraryVariableStorage.Enqueue('3');
        Enqueue3SalesLineWithItemDescription();
        Enqueue3SalesLineWithItemDescription();
        // [WHEN] Create a new sales order for this customer and run Sales Line AI Suggestions Page to generate suggestions lines
        // [THEN] Check that correct lines are generated in 'CheckGenerateFromSalesOrder' handler function
        CreateNewSalesHeaderAndRunSalesLineAISuggestionsPage(SalesHeader, SalesLineAISuggestions, Customer2."No.", SalesHeader."Document Type"::Order);
        // [THEN] Check all the 3 lines are inserted
        CheckSalesLineContent(SalesLine, SalesHeader."No.");
    end;

    [Test]
    [HandlerFunctions('CheckGenerateFromSalesOrder')]
    procedure TestCopySalesInvoiceByDate1()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        CreatedItem: Record Item;
        SalesLineAISuggestions: Page "Sales Line AI Suggestions";
        StartDate: Date;
    begin
        // [FEATURE] [Sales Line with AI] [Document Lookup] [Sales Invoice]
        // [SCENARIO] User input 'I need all items from sales invoice with posting date 01/01/2019' in current customer's sales order. System will find the invoice and copy all the lines to the current sales order.
        Initialize();
        LibrarySales.CreateCustomer(Customer);
        // [GIVEN] Create a new sales order for the new customer
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");
        Evaluate(StartDate, '01/01/2019');
        SalesHeader.Validate("Posting Date", StartDate);
        SalesHeader.Modify(true);
        // [GIVEN] Create 3 lines with item description and add it to the new sales order
        Create3SalesLinesWithItemDescription(SalesHeader, SalesLine, CreatedItem);
        // [GIVEN] Post the sales order to create the sales invoice
        LibrarySales.PostSalesDocument(SalesHeader, true, true);
        LibraryVariableStorage.Enqueue('I need all items from sales invoice with posting date 01/01/2019');
        LibraryVariableStorage.Enqueue('3');
        Enqueue3SalesLineWithItemDescription();
        Enqueue3SalesLineWithItemDescription();
        // [WHEN] Create a new sales order for this customer and run Sales Line AI Suggestions Page to generate suggestions lines
        // [THEN] Check that correct lines are generated in 'CheckGenerateFromSalesOrder' handler function
        CreateNewSalesHeaderAndRunSalesLineAISuggestionsPage(SalesHeader, SalesLineAISuggestions, Customer."No.", SalesHeader."Document Type"::Order);
        // [THEN] Check all the 3 lines are inserted
        CheckSalesLineContent(SalesLine, SalesHeader."No.");
    end;

    [Test]
    [HandlerFunctions('CheckNothingGeneratedFromSalesOrder')]
    procedure TestCopySalesInvoiceByDateFromAnotherCustomer()
    var
        Customer: Record Customer;
        Customer2: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        CreatedItem: Record Item;
        SalesLineAISuggestions: Page "Sales Line AI Suggestions";
        StartDate: Date;
    begin
        // [FEATURE] [Sales Line with AI] [Document Lookup] [Sales Invoice]
        // [SCENARIO] User input 'I need all items from sales invoice with posting date 01/01/2019' from another customer's sales order. System cannot find the order and should not generate any lines.
        Initialize();
        LibrarySales.CreateCustomer(Customer);
        LibrarySales.CreateCustomer(Customer2);
        // [GIVEN] Create a new sales order for the new customer
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");
        // [GIVEN] Change the date of the sales order
        Evaluate(StartDate, '01/01/2019');
        SalesHeader.Validate("Posting Date", StartDate);
        SalesHeader.Modify(true);
        // [GIVEN] Create 3 lines with item description and add it to the new sales order
        Create3SalesLinesWithItemDescription(SalesHeader, SalesLine, CreatedItem);
        // [GIVEN] Post the sales order to create the sales invoice
        LibrarySales.PostSalesDocument(SalesHeader, true, true);
        LibraryVariableStorage.Enqueue('I need all items from sales invoice with posting date 01/01/2019');
        // [WHEN] Create a new sales order for this customer and run Sales Line AI Suggestions Page to generate suggestions lines
        // [THEN] Check no line is generated in 'CheckNothingGeneratedFromSalesOrder' handler function
        CreateNewSalesHeaderAndRunSalesLineAISuggestionsPage(SalesHeader, SalesLineAISuggestions, Customer2."No.", SalesHeader."Document Type"::Order);
        // [THEN] Check no line is inserted to this document
        CheckEmptySalesLineContent(SalesLine, SalesHeader."No.");
    end;

    [Test]
    [HandlerFunctions('CheckGenerateFromSalesOrder')]
    procedure TestCopySalesInvoiceByDateRange1()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        CreatedItem: Record Item;
        SalesLineAISuggestions: Page "Sales Line AI Suggestions";
        StartDate: Date;
    begin
        // [FEATURE] [Sales Line with AI] [Document Lookup] [Sales Invoice]
        // [SCENARIO] User input 'I need all items from sales invoice on January of 2019' in current customer's sales order. System will find the invoice and copy all the lines to the current sales order.
        Initialize();
        LibrarySales.CreateCustomer(Customer);
        // [GIVEN] Create a new sales order for the new customer
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");
        Evaluate(StartDate, '01/01/2019');
        SalesHeader.Validate("Posting Date", StartDate);
        SalesHeader.Modify(true);
        // [GIVEN] Create 3 lines with item description and add it to the new sales order
        Create3SalesLinesWithItemDescription(SalesHeader, SalesLine, CreatedItem);
        // [GIVEN] Post the sales order to create the sales invoice
        LibrarySales.PostSalesDocument(SalesHeader, true, true);
        LibraryVariableStorage.Enqueue('I need all items from sales invoice on January of 2019');
        LibraryVariableStorage.Enqueue('3');
        Enqueue3SalesLineWithItemDescription();
        Enqueue3SalesLineWithItemDescription();
        // [WHEN] Create a new sales order for this customer and run Sales Line AI Suggestions Page to generate suggestions lines
        // [THEN] Check that correct lines are generated in 'CheckGenerateFromSalesOrder' handler function
        CreateNewSalesHeaderAndRunSalesLineAISuggestionsPage(SalesHeader, SalesLineAISuggestions, Customer."No.", SalesHeader."Document Type"::Order);
        // [THEN] Check all the 3 lines are inserted
        CheckSalesLineContent(SalesLine, SalesHeader."No.");
    end;

    [Test]
    [HandlerFunctions('CheckGenerateFromSalesOrder')]
    procedure TestCopySalesInvoiceByDateRange2()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        CreatedItem: Record Item;
        SalesLineAISuggestions: Page "Sales Line AI Suggestions";
        StartDate: Date;
    begin
        // [FEATURE] [Sales Line with AI] [Document Lookup] [Sales Invoice]
        // [SCENARIO] User input 'I need all items from sales invoice from 2018-12-30 to 2019-Jan-5' in current customer's sales order. System will find the invoice and copy all the lines to the current sales order.
        Initialize();
        LibrarySales.CreateCustomer(Customer);
        // [GIVEN] Create a new sales order for the new customer
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");
        // [GIVEN] Change the date of the sales order
        Evaluate(StartDate, '01/01/2019');
        SalesHeader.Validate("Posting Date", StartDate);
        SalesHeader.Modify(true);
        // [GIVEN] Create 3 lines with item description and add it to the new sales order
        Create3SalesLinesWithItemDescription(SalesHeader, SalesLine, CreatedItem);
        // [GIVEN] Post the sales order to create the sales invoice
        LibrarySales.PostSalesDocument(SalesHeader, true, true);
        LibraryVariableStorage.Enqueue('I need all items from sales invoice from 2018-12-30 to 2019-Jan-5');
        LibraryVariableStorage.Enqueue('3');
        Enqueue3SalesLineWithItemDescription();
        Enqueue3SalesLineWithItemDescription();
        // [WHEN] Create a new sales order for this customer and run Sales Line AI Suggestions Page to generate suggestions lines
        // [THEN] Check that correct lines are generated in 'CheckGenerateFromSalesOrder' handler function
        CreateNewSalesHeaderAndRunSalesLineAISuggestionsPage(SalesHeader, SalesLineAISuggestions, Customer."No.", SalesHeader."Document Type"::Order);
        // [THEN] Check all the 3 lines are inserted
        CheckSalesLineContent(SalesLine, SalesHeader."No.");
    end;
    //--------------------------------------------------------------------------------------
    // Test cases for Sales Shipment
    [Test]
    [HandlerFunctions('CheckGenerateFromSalesOrder')]
    procedure TestCopySalesShipmentByDocNo()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        CreatedItem: Record Item;
        SalesLineAISuggestions: Page "Sales Line AI Suggestions";
    begin
        // [FEATURE] [Sales Line with AI] [Document Lookup] [Sales Shipment]
        // [SCENARIO] User input 'I want all the items from sales shipment 10000' in current customer's sales order. System will find the shipment and copy all the lines to the current sales order.
        Initialize();
        LibrarySales.CreateCustomer(Customer);
        // [GIVEN] Create a new sales order for the new customer
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");
        // [GIVEN] Create 3 lines with item description and add it to the new sales order
        Create3SalesLinesWithItemDescription(SalesHeader, SalesLine, CreatedItem);
        // [GIVEN] Post the sales order to create the sales shipment
        LibrarySales.PostSalesDocument(SalesHeader, true, true);
        LibraryVariableStorage.Enqueue(StrSubstNo(NeedAllItemFromSpecifiedSalesShipmentLbl, SalesHeader."No."));
        LibraryVariableStorage.Enqueue('3');
        Enqueue3SalesLineWithItemDescription();
        Enqueue3SalesLineWithItemDescription();
        // [WHEN] Create a new sales order for this customer and run Sales Line AI Suggestions Page to generate suggestions lines
        // [THEN] Check that correct lines are generated in 'CheckGenerateFromSalesOrder' handler function
        CreateNewSalesHeaderAndRunSalesLineAISuggestionsPage(SalesHeader, SalesLineAISuggestions, Customer."No.", SalesHeader."Document Type"::Order);
        // [THEN] Check all the 3 lines are inserted
        CheckSalesLineContent(SalesLine, SalesHeader."No.");
    end;

    [Test]
    [HandlerFunctions('CheckGenerateFromSalesOrder')]
    procedure TestCopySalesShipmentByDocNoFromDifferentCustomer()
    var
        Customer: Record Customer;
        Customer2: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        CreatedItem: Record Item;
        SalesLineAISuggestions: Page "Sales Line AI Suggestions";
    begin
        // [FEATURE] [Sales Line with AI] [Document Lookup] [Sales Shipment]
        // [SCENARIO] User input 'I want all the items from sales shipment 10000' in another customer's sales order. The system should generate 3 lines with item description and quantity.
        Initialize();
        LibrarySales.CreateCustomer(Customer);
        LibrarySales.CreateCustomer(Customer2);
        // [GIVEN] Create a new sales order for the new customer
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");
        // [GIVEN] Create 3 lines with item description and add it to the new sales order
        Create3SalesLinesWithItemDescription(SalesHeader, SalesLine, CreatedItem);
        // [GIVEN] Post the sales order to create the sales shipment
        LibrarySales.PostSalesDocument(SalesHeader, true, true);
        LibraryVariableStorage.Enqueue(StrSubstNo(NeedAllItemFromSpecifiedSalesShipmentLbl, SalesHeader."No."));
        LibraryVariableStorage.Enqueue('3');
        Enqueue3SalesLineWithItemDescription();
        Enqueue3SalesLineWithItemDescription();
        // [WHEN] Create a new sales order for this customer and run Sales Line AI Suggestions Page to generate suggestions lines
        // [THEN] Check that correct lines are generated in 'CheckGenerateFromSalesOrder' handler function
        CreateNewSalesHeaderAndRunSalesLineAISuggestionsPage(SalesHeader, SalesLineAISuggestions, Customer2."No.", SalesHeader."Document Type"::Order);
        // [THEN] Check all the 3 lines are inserted
        CheckSalesLineContent(SalesLine, SalesHeader."No.");
    end;

    [Test]
    [HandlerFunctions('CheckGenerateFromSalesOrder')]
    procedure TestCopySalesShipmentByExternalDocumentNo()
    var
        Customer: Record Customer;
        Customer2: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        CreatedItem: Record Item;
        SalesLineAISuggestions: Page "Sales Line AI Suggestions";
    begin
        // [FEATURE] [Sales Line with AI] [Document Lookup] [Sales Shipment]
        // [SCENARIO] User input 'I want all the items from sales shipment EXT10000' in another customer's sales order. The system should generate 3 lines with item description and quantity.
        Initialize();
        LibrarySales.CreateCustomer(Customer);
        LibrarySales.CreateCustomer(Customer2);
        // [GIVEN] Create a new sales order for the new customer
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");
        // [GIVEN] Update External Document No.
        SalesHeader.Validate("External Document No.", 'EXTNO123456789123456789123456789123');
        SalesHeader.Modify(true);
        // [GIVEN] Create 3 lines with item description and add it to the new sales order
        Create3SalesLinesWithItemDescription(SalesHeader, SalesLine, CreatedItem);
        // [GIVEN] Post the sales order to create the sales shipment
        LibrarySales.PostSalesDocument(SalesHeader, true, true);
        LibraryVariableStorage.Enqueue(StrSubstNo(NeedAllItemFromSpecifiedSalesShipmentLbl, SalesHeader."External Document No."));
        LibraryVariableStorage.Enqueue('3');
        Enqueue3SalesLineWithItemDescription();
        Enqueue3SalesLineWithItemDescription();
        // [WHEN] Create a new sales order for this customer and run Sales Line AI Suggestions Page to generate suggestions lines
        // [THEN] Check that correct lines are generated in 'CheckGenerateFromSalesOrder' handler function
        CreateNewSalesHeaderAndRunSalesLineAISuggestionsPage(SalesHeader, SalesLineAISuggestions, Customer2."No.", SalesHeader."Document Type"::Order);
        // [THEN] Check all the 3 lines are inserted
        CheckSalesLineContent(SalesLine, SalesHeader."No.");
    end;

    [Test]
    [HandlerFunctions('CheckGenerateFromSalesOrder')]
    procedure TestCopySalesShipmentByQuoteNo()
    var
        Customer: Record Customer;
        Customer2: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        CreatedItem: Record Item;
        SalesLineAISuggestions: Page "Sales Line AI Suggestions";
    begin
        // [FEATURE] [Sales Line with AI] [Document Lookup] [Sales Shipment]
        // [SCENARIO] User input 'I want all the items from sales shipment QTO214500' in another customer's sales order. The system should generate 3 lines with item description and quantity.
        Initialize();
        LibrarySales.CreateCustomer(Customer);
        LibrarySales.CreateCustomer(Customer2);
        // [GIVEN] Create a new sales order for the new customer
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");
        SalesHeader.Validate("Quote No.", 'QTO214500');
        SalesHeader.Modify(true);
        // [GIVEN] Create 3 lines with item description and add it to the new sales order
        Create3SalesLinesWithItemDescription(SalesHeader, SalesLine, CreatedItem);
        // [GIVEN] Post the sales order to create the sales shipment
        LibrarySales.PostSalesDocument(SalesHeader, true, true);
        LibraryVariableStorage.Enqueue(StrSubstNo(NeedAllItemFromSpecifiedSalesShipmentLbl, SalesHeader."Quote No."));
        LibraryVariableStorage.Enqueue('3');
        Enqueue3SalesLineWithItemDescription();
        Enqueue3SalesLineWithItemDescription();
        // [WHEN] Create a new sales order for this customer and run Sales Line AI Suggestions Page to generate suggestions lines
        // [THEN] Check that correct lines are generated in 'CheckGenerateFromSalesOrder' handler function
        CreateNewSalesHeaderAndRunSalesLineAISuggestionsPage(SalesHeader, SalesLineAISuggestions, Customer2."No.", SalesHeader."Document Type"::Order);
        // [THEN] Check all the 3 lines are inserted
        CheckSalesLineContent(SalesLine, SalesHeader."No.");
    end;

    [Test]
    [HandlerFunctions('CheckGenerateFromSalesOrder')]
    procedure TestCopySalesShipmentByReferenceNo()
    var
        Customer: Record Customer;
        Customer2: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        CreatedItem: Record Item;
        SalesLineAISuggestions: Page "Sales Line AI Suggestions";
    begin
        // [FEATURE] [Sales Line with AI] [Document Lookup] [Sales Shipment]
        // [SCENARIO] User input 'I want all the items from sales shipment REF214500' in another customer's sales order. The system should generate 3 lines with item description and quantity.
        Initialize();
        LibrarySales.CreateCustomer(Customer);
        LibrarySales.CreateCustomer(Customer2);
        // [GIVEN] Create a new sales order for the new customer
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");
        SalesHeader.Validate("Your Reference", 'REF214500');
        SalesHeader.Modify(true);
        // [GIVEN] Create 3 lines with item description and add it to the new sales order
        Create3SalesLinesWithItemDescription(SalesHeader, SalesLine, CreatedItem);
        // [GIVEN] Post the sales order to create the sales shipment
        LibrarySales.PostSalesDocument(SalesHeader, true, true);
        LibraryVariableStorage.Enqueue(StrSubstNo(NeedAllItemFromSpecifiedSalesShipmentLbl, SalesHeader."Your Reference"));
        LibraryVariableStorage.Enqueue('3');
        Enqueue3SalesLineWithItemDescription();
        Enqueue3SalesLineWithItemDescription();
        // [WHEN] Create a new sales order for this customer and run Sales Line AI Suggestions Page to generate suggestions lines
        // [THEN] Check that correct lines are generated in 'CheckGenerateFromSalesOrder' handler function
        CreateNewSalesHeaderAndRunSalesLineAISuggestionsPage(SalesHeader, SalesLineAISuggestions, Customer2."No.", SalesHeader."Document Type"::Order);
        // [THEN] Check all the 3 lines are inserted
        CheckSalesLineContent(SalesLine, SalesHeader."No.");
    end;

    [Test]
    [HandlerFunctions('CheckGenerateFromSalesOrder')]
    procedure TestAmbiguouslyCopySalesShipmentByExternalDocumentNo()
    var
        Customer: Record Customer;
        Customer2: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        CreatedItem: Record Item;
        SalesLineAISuggestions: Page "Sales Line AI Suggestions";
    begin
        // [FEATURE] [Sales Line with AI] [Document Lookup] [Sales Order]
        // [SCENARIO] User input 'I want all the items from sales shipment EXT10000' in another customer's sales order. The system should generate 3 lines with item description and quantity.
        Initialize();
        LibrarySales.CreateCustomer(Customer);
        LibrarySales.CreateCustomer(Customer2);
        // [GIVEN] Create a new sales order for the new customer
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");
        SalesHeader.Validate("External Document No.", 'EXTNO123456789123456789123456789123');
        SalesHeader.Modify(true);
        // [GIVEN] Create 3 lines with item description and add it to the new sales order
        Create3SalesLinesWithItemDescription(SalesHeader, SalesLine, CreatedItem);
        // [GIVEN] Post the sales order to create the sales shipment
        LibrarySales.PostSalesDocument(SalesHeader, true, true);
        LibraryVariableStorage.Enqueue(StrSubstNo(NeedAllItemFromSpecifiedSalesShipmentLbl, CopyStr(SalesHeader."External Document No.", 2, StrLen(SalesHeader."External Document No.") - 1)));
        LibraryVariableStorage.Enqueue('3');
        Enqueue3SalesLineWithItemDescription();
        Enqueue3SalesLineWithItemDescription();
        // [WHEN] Create a new sales order for this customer and run Sales Line AI Suggestions Page to generate suggestions lines
        // [THEN] Check that correct lines are generated in 'CheckGenerateFromSalesOrder' handler function
        CreateNewSalesHeaderAndRunSalesLineAISuggestionsPage(SalesHeader, SalesLineAISuggestions, Customer2."No.", SalesHeader."Document Type"::Order);
        // [THEN] Check all the 3 lines are inserted
        CheckSalesLineContent(SalesLine, SalesHeader."No.");
    end;

    [Test]
    [HandlerFunctions('CheckGenerateFromSalesOrder')]
    procedure TestAmbiguouslyCopySalesShipmentByQuoteNo()
    var
        Customer: Record Customer;
        Customer2: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        CreatedItem: Record Item;
        SalesLineAISuggestions: Page "Sales Line AI Suggestions";
    begin
        // [FEATURE] [Sales Line with AI] [Document Lookup] [Sales Shipment] [Ambiguous Search]
        // [SCENARIO] There is an item with Quote Number 'QTO214500'. User input 'I want all the items from sales shipment XTNO12345678912345678912345678912' in another customer's sales order. The system should generate 3 lines with item description and quantity.
        Initialize();
        LibrarySales.CreateCustomer(Customer);
        LibrarySales.CreateCustomer(Customer2);
        // [GIVEN] Create a new sales order for the new customer
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");
        SalesHeader.Validate("Quote No.", 'QTO214500');
        SalesHeader.Modify(true);
        // [GIVEN] Create 3 lines with item description and add it to the new sales order
        Create3SalesLinesWithItemDescription(SalesHeader, SalesLine, CreatedItem);
        // [GIVEN] Post the sales order to create the sales shipment
        LibrarySales.PostSalesDocument(SalesHeader, true, true);
        LibraryVariableStorage.Enqueue(StrSubstNo(NeedAllItemFromSpecifiedSalesShipmentLbl, CopyStr(SalesHeader."Quote No.", 2, StrLen(SalesHeader."Quote No.") - 1)));
        LibraryVariableStorage.Enqueue('3');
        Enqueue3SalesLineWithItemDescription();
        Enqueue3SalesLineWithItemDescription();
        // [WHEN] Create a new sales order for this customer and run Sales Line AI Suggestions Page to generate suggestions lines
        // [THEN] Check that correct lines are generated in 'CheckGenerateFromSalesOrder' handler function
        CreateNewSalesHeaderAndRunSalesLineAISuggestionsPage(SalesHeader, SalesLineAISuggestions, Customer2."No.", SalesHeader."Document Type"::Order);
        // [THEN] Check all the 3 lines are inserted
        CheckSalesLineContent(SalesLine, SalesHeader."No.");
    end;

    [Test]
    [HandlerFunctions('CheckGenerateFromSalesOrder')]
    procedure TestAmbiguouslyCopySalesShipmentByReferenceNo()
    var
        Customer: Record Customer;
        Customer2: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        CreatedItem: Record Item;
        SalesLineAISuggestions: Page "Sales Line AI Suggestions";
    begin
        // [FEATURE] [Sales Line with AI] [Document Lookup] [Sales Shipment] [Ambiguous Search]
        // [SCENARIO] There is an item with Reference Number 'REF214500'. User input 'I want all the items from sales shipment XTNO12345678912345678912345678912' in another customer's sales order. The system should generate 3 lines with item description and quantity.
        Initialize();
        LibrarySales.CreateCustomer(Customer);
        LibrarySales.CreateCustomer(Customer2);
        // [GIVEN] Create a new sales order for the new customer
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");
        SalesHeader.Validate("Your Reference", 'REF214500');
        SalesHeader.Modify(true);
        // [GIVEN] Create 3 lines with item description and add it to the new sales order
        Create3SalesLinesWithItemDescription(SalesHeader, SalesLine, CreatedItem);
        // [GIVEN] Post the sales order to create the sales shipment
        LibrarySales.PostSalesDocument(SalesHeader, true, true);
        LibraryVariableStorage.Enqueue(StrSubstNo(NeedAllItemFromSpecifiedSalesShipmentLbl, CopyStr(SalesHeader."Your Reference", 2, StrLen(SalesHeader."Your Reference") - 1)));
        LibraryVariableStorage.Enqueue('3');
        Enqueue3SalesLineWithItemDescription();
        Enqueue3SalesLineWithItemDescription();
        // [WHEN] Create a new sales order for this customer and run Sales Line AI Suggestions Page to generate suggestions lines
        // [THEN] Check that correct lines are generated in 'CheckGenerateFromSalesOrder' handler function
        CreateNewSalesHeaderAndRunSalesLineAISuggestionsPage(SalesHeader, SalesLineAISuggestions, Customer2."No.", SalesHeader."Document Type"::Order);
        // [THEN] Check all the 3 lines are inserted
        CheckSalesLineContent(SalesLine, SalesHeader."No.");
    end;

    [Test]
    [HandlerFunctions('CheckGenerateFromSalesOrder')]
    procedure TestCopySalesShipmentByDate1()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        CreatedItem: Record Item;
        SalesLineAISuggestions: Page "Sales Line AI Suggestions";
        StartDate: Date;
    begin
        // [FEATURE] [Sales Line with AI] [Document Lookup] [Sales Shipment]
        // [SCENARIO] User input 'I need all items from sales shipment with posting date 01/01/2019' in current customer's sales order. System will find the shipment and copy all the lines to the current sales order.
        Initialize();
        LibrarySales.CreateCustomer(Customer);
        // [GIVEN] Create a new sales order for the new customer
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");
        Evaluate(StartDate, '01/01/2019');
        SalesHeader.Validate("Posting Date", StartDate);
        SalesHeader.Modify(true);
        // [GIVEN] Create 3 lines with item description and add it to the new sales order
        Create3SalesLinesWithItemDescription(SalesHeader, SalesLine, CreatedItem);
        // [GIVEN] Post the sales order to create the sales shipment
        LibrarySales.PostSalesDocument(SalesHeader, true, true);
        LibraryVariableStorage.Enqueue('I need all items from sales shipment with posting date 01/01/2019');
        LibraryVariableStorage.Enqueue('3');
        Enqueue3SalesLineWithItemDescription();
        Enqueue3SalesLineWithItemDescription();
        // [WHEN] Create a new sales order for this customer and run Sales Line AI Suggestions Page to generate suggestions lines
        // [THEN] Check that correct lines are generated in 'CheckGenerateFromSalesOrder' handler function
        CreateNewSalesHeaderAndRunSalesLineAISuggestionsPage(SalesHeader, SalesLineAISuggestions, Customer."No.", SalesHeader."Document Type"::Order);
        // [THEN] Check all the 3 lines are inserted
        CheckSalesLineContent(SalesLine, SalesHeader."No.");
    end;

    [Test]
    [HandlerFunctions('CheckNothingGeneratedFromSalesOrder')]
    procedure TestCopySalesShipmentByDateFromAnotherCustomer()
    var
        Customer: Record Customer;
        Customer2: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        CreatedItem: Record Item;
        SalesLineAISuggestions: Page "Sales Line AI Suggestions";
        StartDate: Date;
    begin
        // [FEATURE] [Sales Line with AI] [Document Lookup] [Sales Shipment]
        // [SCENARIO] User input 'I need all items from sales shipment with posting date 01/01/2019' from another customer's sales order. System cannot find the order and should not generate any lines.
        Initialize();
        LibrarySales.CreateCustomer(Customer);
        LibrarySales.CreateCustomer(Customer2);
        // [GIVEN] Create a new sales order for the new customer
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");
        Evaluate(StartDate, '01/01/2019');
        SalesHeader.Validate("Posting Date", StartDate);
        SalesHeader.Modify(true);
        // [GIVEN] Create 3 lines with item description and add it to the new sales order
        Create3SalesLinesWithItemDescription(SalesHeader, SalesLine, CreatedItem);
        // [GIVEN] Post the sales order to create the sales shipment
        LibrarySales.PostSalesDocument(SalesHeader, true, true);
        LibraryVariableStorage.Enqueue('I need all items from sales shipment with posting date 01/01/2019');
        // [WHEN] Create a new sales order for this customer and run Sales Line AI Suggestions Page to generate suggestions lines
        // [THEN] Check no line is generated in 'CheckGenerateFromSalesOrder' handler function
        CreateNewSalesHeaderAndRunSalesLineAISuggestionsPage(SalesHeader, SalesLineAISuggestions, Customer2."No.", SalesHeader."Document Type"::Order);
        // [THEN] Check no line is inserted to this document
        CheckEmptySalesLineContent(SalesLine, SalesHeader."No.");
    end;

    [Test]
    [HandlerFunctions('CheckGenerateFromSalesOrder')]
    procedure TestCopySalesShipmentByDateRange1()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        CreatedItem: Record Item;
        SalesLineAISuggestions: Page "Sales Line AI Suggestions";
        StartDate: Date;
    begin
        // [FEATURE] [Sales Line with AI] [Document Lookup] [Sales Shipment]
        // [SCENARIO] User input 'I need all items from sales shipment on January of 2019' in current customer's sales order. System will find the shipment and copy all the lines to the current sales order.
        Initialize();
        LibrarySales.CreateCustomer(Customer);
        // [GIVEN] Create a new sales order for the new customer
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");
        Evaluate(StartDate, '01/01/2019');
        SalesHeader.Validate("Posting Date", StartDate);
        SalesHeader.Modify(true);
        // [GIVEN] Create 3 lines with item description and add it to the new sales order
        Create3SalesLinesWithItemDescription(SalesHeader, SalesLine, CreatedItem);
        // [GIVEN] Post the sales order to create the sales shipment
        LibrarySales.PostSalesDocument(SalesHeader, true, true);
        LibraryVariableStorage.Enqueue('I need all items from sales shipment on January of 2019');
        LibraryVariableStorage.Enqueue('3');
        Enqueue3SalesLineWithItemDescription();
        Enqueue3SalesLineWithItemDescription();
        // [WHEN] Create a new sales order for this customer and run Sales Line AI Suggestions Page to generate suggestions lines
        // [THEN] Check that correct lines are generated in 'CheckGenerateFromSalesOrder' handler function
        CreateNewSalesHeaderAndRunSalesLineAISuggestionsPage(SalesHeader, SalesLineAISuggestions, Customer."No.", SalesHeader."Document Type"::Order);
        // [THEN] Check all the 3 lines are inserted
        CheckSalesLineContent(SalesLine, SalesHeader."No.");
    end;

    [Test]
    [HandlerFunctions('CheckGenerateFromSalesOrder')]
    procedure TestCopySalesShipmentByDateRange2()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        CreatedItem: Record Item;
        SalesLineAISuggestions: Page "Sales Line AI Suggestions";
        StartDate: Date;
    begin
        // [FEATURE] [Sales Line with AI] [Document Lookup] [Sales Shipment]
        // [SCENARIO] User input 'I need all items from sales shipment from 2018-12-30 to 2019-Jan-5' in current customer's sales order. System will find the shipment and copy all the lines to the current sales order.
        Initialize();
        LibrarySales.CreateCustomer(Customer);
        // [GIVEN] Create a new sales order for the new customer
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");
        Evaluate(StartDate, '01/01/2019');
        SalesHeader.Validate("Posting Date", StartDate);
        SalesHeader.Modify(true);
        // [GIVEN] Create 3 lines with item description and add it to the new sales order
        Create3SalesLinesWithItemDescription(SalesHeader, SalesLine, CreatedItem);
        // [GIVEN] Post the sales order to create the sales shipment
        LibrarySales.PostSalesDocument(SalesHeader, true, true);
        LibraryVariableStorage.Enqueue('I need all items from sales shipment from 2018-12-30 to 2019-Jan-5');
        LibraryVariableStorage.Enqueue('3');
        Enqueue3SalesLineWithItemDescription();
        Enqueue3SalesLineWithItemDescription();
        // [WHEN] Create a new sales order for this customer and run Sales Line AI Suggestions Page to generate suggestions lines
        // [THEN] Check that correct lines are generated in 'CheckGenerateFromSalesOrder' handler function
        CreateNewSalesHeaderAndRunSalesLineAISuggestionsPage(SalesHeader, SalesLineAISuggestions, Customer."No.", SalesHeader."Document Type"::Order);
        // [THEN] Check all the 3 lines are inserted
        CheckSalesLineContent(SalesLine, SalesHeader."No.");
    end;
    //--------------------------------------------------------------------------------------
    // Test cases for Sales Quote
    [Test]
    [HandlerFunctions('CheckGenerateFromSalesOrder')]
    procedure TestCopySalesQuoteByDocNo()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        CreatedItem: Record Item;
        SalesLineAISuggestions: Page "Sales Line AI Suggestions";
    begin
        // [FEATURE] [Sales Line with AI] [Document Lookup] [Sales Quote]
        // [SCENARIO] User input 'I want all the items from sales quote 10000' in current customer's sales order. System will find the quote and copy all the lines to the current sales order.
        Initialize();
        LibrarySales.CreateCustomer(Customer);
        // [GIVEN] Create sales quote for customer
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Quote, Customer."No.");
        // [GIVEN] Create 3 lines with item description and add it to the new sales order
        Create3SalesLinesWithItemDescription(SalesHeader, SalesLine, CreatedItem);
        LibraryVariableStorage.Enqueue(StrSubstNo(NeedAllItemFromSpecifiedSalesQuoteLbl, SalesHeader."No."));
        LibraryVariableStorage.Enqueue('3');
        Enqueue3SalesLineWithItemDescription();
        Enqueue3SalesLineWithItemDescription();
        // [WHEN] Create a new sales order for this customer and run Sales Line AI Suggestions Page to generate suggestions lines
        // [THEN] Check that correct lines are generated in 'CheckGenerateFromSalesOrder' handler function
        CreateNewSalesHeaderAndRunSalesLineAISuggestionsPage(SalesHeader, SalesLineAISuggestions, Customer."No.", SalesHeader."Document Type"::Order);
        // [THEN] Check all the 3 lines are inserted
        CheckSalesLineContent(SalesLine, SalesHeader."No.");
    end;

    [Test]
    [HandlerFunctions('CheckGenerateFromSalesOrder')]
    procedure TestCopySalesQuoteByDocNoWFromDifferentCustomer()
    var
        Customer: Record Customer;
        Customer2: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        CreatedItem: Record Item;
        SalesLineAISuggestions: Page "Sales Line AI Suggestions";
    begin
        // [FEATURE] [Sales Line with AI] [Document Lookup] [Sales Quote]
        // [SCENARIO] User input 'I want all the items from sales quote 10000' in another customer's sales order. The system should generate 3 lines with item description and quantity.
        Initialize();
        LibrarySales.CreateCustomer(Customer);
        LibrarySales.CreateCustomer(Customer2);
        // [GIVEN] Create a new sales order for the new customer
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Quote, Customer."No.");
        // [GIVEN] Create 3 lines with item description and add it to the new sales order
        Create3SalesLinesWithItemDescription(SalesHeader, SalesLine, CreatedItem);
        LibraryVariableStorage.Enqueue(StrSubstNo(NeedAllItemFromSpecifiedSalesQuoteLbl, SalesHeader."No."));
        LibraryVariableStorage.Enqueue('3');
        Enqueue3SalesLineWithItemDescription();
        Enqueue3SalesLineWithItemDescription();
        // [WHEN] Create a new sales order for this customer and run Sales Line AI Suggestions Page to generate suggestions lines
        // [THEN] Check that correct lines are generated in 'CheckGenerateFromSalesOrder' handler function
        CreateNewSalesHeaderAndRunSalesLineAISuggestionsPage(SalesHeader, SalesLineAISuggestions, Customer2."No.", SalesHeader."Document Type"::Order);
        // [THEN] Check all the 3 lines are inserted
        CheckSalesLineContent(SalesLine, SalesHeader."No.");
    end;

    [Test]
    [HandlerFunctions('CheckGenerateFromSalesOrder')]
    procedure TestCopySalesQuoteByExternalDocumentNo()
    var
        Customer: Record Customer;
        Customer2: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        CreatedItem: Record Item;
        SalesLineAISuggestions: Page "Sales Line AI Suggestions";
    begin
        // [FEATURE] [Sales Line with AI] [Document Lookup] [Sales Quote]
        // [SCENARIO] User input 'I want all the items from sales quote EXT10000' in another customer's sales order. The system should generate 3 lines with item description and quantity.
        Initialize();
        LibrarySales.CreateCustomer(Customer);
        LibrarySales.CreateCustomer(Customer2);
        // [GIVEN] Create a new sales order for the new customer
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Quote, Customer."No.");
        // [GIVEN] Update External Document No.
        SalesHeader.Validate("External Document No.", 'EXTNO123456789123456789123456789123');
        SalesHeader.Modify(true);
        // [GIVEN] Create 3 lines with item description and add it to the new sales order
        Create3SalesLinesWithItemDescription(SalesHeader, SalesLine, CreatedItem);
        LibraryVariableStorage.Enqueue(StrSubstNo(NeedAllItemFromSpecifiedSalesQuoteLbl, SalesHeader."External Document No."));
        LibraryVariableStorage.Enqueue('3');
        Enqueue3SalesLineWithItemDescription();
        Enqueue3SalesLineWithItemDescription();
        // [WHEN] Create a new sales order for this customer and run Sales Line AI Suggestions Page to generate suggestions lines
        // [THEN] Check that correct lines are generated in 'CheckGenerateFromSalesOrder' handler function
        CreateNewSalesHeaderAndRunSalesLineAISuggestionsPage(SalesHeader, SalesLineAISuggestions, Customer2."No.", SalesHeader."Document Type"::Order);
        // [THEN] Check all the 3 lines are inserted
        CheckSalesLineContent(SalesLine, SalesHeader."No.");
    end;

    [Test]
    [HandlerFunctions('CheckGenerateFromSalesOrder')]
    procedure TestCopySalesQuoteByQuoteNo()
    var
        Customer: Record Customer;
        Customer2: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        CreatedItem: Record Item;
        SalesLineAISuggestions: Page "Sales Line AI Suggestions";
    begin
        // [FEATURE] [Sales Line with AI] [Document Lookup] [Sales Quote]
        // [SCENARIO] User input 'I want all the items from sales quote QTO214500' in another customer's sales order. The system should generate 3 lines with item description and quantity.
        Initialize();
        LibrarySales.CreateCustomer(Customer);
        LibrarySales.CreateCustomer(Customer2);
        // [GIVEN] Create a new sales order for the new customer
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Quote, Customer."No.");
        SalesHeader.Validate("Quote No.", 'QTO214500');
        SalesHeader.Modify(true);
        // [GIVEN] Create 3 lines with item description and add it to the new sales order
        Create3SalesLinesWithItemDescription(SalesHeader, SalesLine, CreatedItem);
        LibraryVariableStorage.Enqueue(StrSubstNo(NeedAllItemFromSpecifiedSalesQuoteLbl, SalesHeader."Quote No."));
        LibraryVariableStorage.Enqueue('3');
        Enqueue3SalesLineWithItemDescription();
        Enqueue3SalesLineWithItemDescription();
        // [WHEN] Create a new sales order for this customer and run Sales Line AI Suggestions Page to generate suggestions lines
        // [THEN] Check that correct lines are generated in 'CheckGenerateFromSalesOrder' handler function
        CreateNewSalesHeaderAndRunSalesLineAISuggestionsPage(SalesHeader, SalesLineAISuggestions, Customer2."No.", SalesHeader."Document Type"::Order);
        // [THEN] Check all the 3 lines are inserted
        CheckSalesLineContent(SalesLine, SalesHeader."No.");
    end;

    [Test]
    [HandlerFunctions('CheckGenerateFromSalesOrder')]
    procedure TestCopySalesQuoteByReferenceNo()
    var
        Customer: Record Customer;
        Customer2: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        CreatedItem: Record Item;
        SalesLineAISuggestions: Page "Sales Line AI Suggestions";
    begin
        // [FEATURE] [Sales Line with AI] [Document Lookup] [Sales Quote]
        // [SCENARIO] User input 'I want all the items from sales quote QTO214500' in another customer's sales order. The system should generate 3 lines with item description and quantity.
        Initialize();
        LibrarySales.CreateCustomer(Customer);
        LibrarySales.CreateCustomer(Customer2);
        // [GIVEN] Create a new sales order for the new customer
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Quote, Customer."No.");
        SalesHeader.Validate("Your Reference", 'REF214500');
        SalesHeader.Modify(true);
        // [GIVEN] Create 3 lines with item description and add it to the new sales order
        Create3SalesLinesWithItemDescription(SalesHeader, SalesLine, CreatedItem);
        LibraryVariableStorage.Enqueue(StrSubstNo(NeedAllItemFromSpecifiedSalesQuoteLbl, SalesHeader."Your Reference"));
        LibraryVariableStorage.Enqueue('3');
        Enqueue3SalesLineWithItemDescription();
        Enqueue3SalesLineWithItemDescription();
        // [WHEN] Create a new sales order for this customer and run Sales Line AI Suggestions Page to generate suggestions lines
        // [THEN] Check that correct lines are generated in 'CheckGenerateFromSalesOrder' handler function
        CreateNewSalesHeaderAndRunSalesLineAISuggestionsPage(SalesHeader, SalesLineAISuggestions, Customer2."No.", SalesHeader."Document Type"::Order);
        // [THEN] Check all the 3 lines are inserted
        CheckSalesLineContent(SalesLine, SalesHeader."No.");
    end;

    [Test]
    [HandlerFunctions('CheckGenerateFromSalesOrder')]
    procedure TestAmbiguouslyCopySalesQuoteByExternalDocumentNo()
    var
        Customer: Record Customer;
        Customer2: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        CreatedItem: Record Item;
        SalesLineAISuggestions: Page "Sales Line AI Suggestions";
    begin
        // [FEATURE] [Sales Line with AI] [Document Lookup] [Sales Quote]
        // [SCENARIO] User input 'I want all the items from sales order EXT10000' in another customer's sales order. The system should generate 3 lines with item description and quantity.
        Initialize();
        LibrarySales.CreateCustomer(Customer);
        LibrarySales.CreateCustomer(Customer2);
        // [GIVEN] Create a new sales order for the new customer
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Quote, Customer."No.");
        // [GIVEN] Update External Document No.
        SalesHeader.Validate("External Document No.", 'EXTNO123456789123456789123456789123');
        SalesHeader.Modify(true);
        // [GIVEN] Create 3 lines with item description and add it to the new sales order
        Create3SalesLinesWithItemDescription(SalesHeader, SalesLine, CreatedItem);
        LibraryVariableStorage.Enqueue(StrSubstNo(NeedAllItemFromSpecifiedSalesQuoteLbl, CopyStr(SalesHeader."External Document No.", 2, StrLen(SalesHeader."External Document No.") - 1)));
        LibraryVariableStorage.Enqueue('3');
        Enqueue3SalesLineWithItemDescription();
        Enqueue3SalesLineWithItemDescription();
        // [WHEN] Create a new sales order for this customer and run Sales Line AI Suggestions Page to generate suggestions lines
        // [THEN] Check that correct lines are generated in 'CheckGenerateFromSalesOrder' handler function
        CreateNewSalesHeaderAndRunSalesLineAISuggestionsPage(SalesHeader, SalesLineAISuggestions, Customer2."No.", SalesHeader."Document Type"::Order);
        // [THEN] Check all the 3 lines are inserted
        CheckSalesLineContent(SalesLine, SalesHeader."No.");
    end;

    [Test]
    [HandlerFunctions('CheckGenerateFromSalesOrder')]
    procedure TestAmbiguouslyCopySalesQuoteByQuoteNo()
    var
        Customer: Record Customer;
        Customer2: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        CreatedItem: Record Item;
        SalesLineAISuggestions: Page "Sales Line AI Suggestions";
    begin
        // [FEATURE] [Sales Line with AI] [Document Lookup] [Sales Quote]
        // [SCENARIO] There is an item with Quote Number 'QTO214500'. User input 'I want all the items from sales quote XTNO12345678912345678912345678912' in another customer's sales order. The system should generate 3 lines with item description and quantity.
        Initialize();
        LibrarySales.CreateCustomer(Customer);
        LibrarySales.CreateCustomer(Customer2);
        // [GIVEN] Create a new sales order for the new customer
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Quote, Customer."No.");
        SalesHeader.Validate("Quote No.", 'QTO214500');
        SalesHeader.Modify(true);
        // [GIVEN] Create 3 lines with item description and add it to the new sales order
        Create3SalesLinesWithItemDescription(SalesHeader, SalesLine, CreatedItem);
        LibraryVariableStorage.Enqueue(StrSubstNo(NeedAllItemFromSpecifiedSalesQuoteLbl, CopyStr(SalesHeader."Quote No.", 2, StrLen(SalesHeader."Quote No.") - 1)));
        LibraryVariableStorage.Enqueue('3');
        Enqueue3SalesLineWithItemDescription();
        Enqueue3SalesLineWithItemDescription();
        // [WHEN] Create a new sales order for this customer and run Sales Line AI Suggestions Page to generate suggestions lines
        // [THEN] Check that correct lines are generated in 'CheckGenerateFromSalesOrder' handler function
        CreateNewSalesHeaderAndRunSalesLineAISuggestionsPage(SalesHeader, SalesLineAISuggestions, Customer2."No.", SalesHeader."Document Type"::Order);
        // [THEN] Check all the 3 lines are inserted
        CheckSalesLineContent(SalesLine, SalesHeader."No.");
    end;

    [Test]
    [HandlerFunctions('CheckGenerateFromSalesOrder')]
    procedure TestAmbiguouslyCopySalesQuoteByReferenceNo()
    var
        Customer: Record Customer;
        Customer2: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        CreatedItem: Record Item;
        SalesLineAISuggestions: Page "Sales Line AI Suggestions";
    begin
        // [FEATURE] [Sales Line with AI] [Document Lookup] [Sales Quote]
        // [SCENARIO] There is an item with Reference Number 'REF214500'. User input 'I want all the items from sales quote XTNO12345678912345678912345678912' in another customer's sales order. The system should generate 3 lines with item description and quantity.
        Initialize();
        LibrarySales.CreateCustomer(Customer);
        LibrarySales.CreateCustomer(Customer2);
        // [GIVEN] Create a new sales order for the new customer
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Quote, Customer."No.");
        SalesHeader.Validate("Your Reference", 'REF214500');
        SalesHeader.Modify(true);
        // [GIVEN] Create 3 lines with item description and add it to the new sales order
        Create3SalesLinesWithItemDescription(SalesHeader, SalesLine, CreatedItem);
        LibraryVariableStorage.Enqueue(StrSubstNo(NeedAllItemFromSpecifiedSalesQuoteLbl, CopyStr(SalesHeader."Your Reference", 2, StrLen(SalesHeader."Your Reference") - 1)));
        LibraryVariableStorage.Enqueue('3');
        Enqueue3SalesLineWithItemDescription();
        Enqueue3SalesLineWithItemDescription();
        // [WHEN] Create a new sales order for this customer and run Sales Line AI Suggestions Page to generate suggestions lines
        // [THEN] Check that correct lines are generated in 'CheckGenerateFromSalesOrder' handler function
        CreateNewSalesHeaderAndRunSalesLineAISuggestionsPage(SalesHeader, SalesLineAISuggestions, Customer2."No.", SalesHeader."Document Type"::Order);
        // [THEN] Check all the 3 lines are inserted
        CheckSalesLineContent(SalesLine, SalesHeader."No.");
    end;

    [Test]
    [HandlerFunctions('CheckGenerateFromSalesOrder')]
    procedure TestCopySalesQuoteByDate1()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        CreatedItem: Record Item;
        SalesLineAISuggestions: Page "Sales Line AI Suggestions";
        StartDate: Date;
    begin
        // [FEATURE] [Sales Line with AI] [Document Lookup] [Sales Quote]
        // [SCENARIO] User input 'I need all items from sales quote with posting date 01/01/2019' in current customer's sales order. System will find the quote and copy all the lines to the current sales order.
        Initialize();
        LibrarySales.CreateCustomer(Customer);
        // [GIVEN] Create a new sales order for the new customer
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Quote, Customer."No.");
        Evaluate(StartDate, '01/01/2019');
        SalesHeader.Validate("Posting Date", StartDate);
        SalesHeader.Modify(true);
        // [GIVEN] Create 3 lines with item description and add it to the new sales order
        Create3SalesLinesWithItemDescription(SalesHeader, SalesLine, CreatedItem);
        LibraryVariableStorage.Enqueue('I need all items from sales quote with posting date 01/01/2019');
        LibraryVariableStorage.Enqueue('3');
        Enqueue3SalesLineWithItemDescription();
        Enqueue3SalesLineWithItemDescription();
        // [WHEN] Create a new sales order for this customer and run Sales Line AI Suggestions Page to generate suggestions lines
        // [THEN] Check that correct lines are generated in 'CheckGenerateFromSalesOrder' handler function
        CreateNewSalesHeaderAndRunSalesLineAISuggestionsPage(SalesHeader, SalesLineAISuggestions, Customer."No.", SalesHeader."Document Type"::Order);
        // [THEN] Check all the 3 lines are inserted
        CheckSalesLineContent(SalesLine, SalesHeader."No.");
    end;

    [Test]
    [HandlerFunctions('CheckNothingGeneratedFromSalesOrder')]
    procedure TestCopySalesQuoteByDateFromAnotherCustomer()
    var
        Customer: Record Customer;
        Customer2: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        CreatedItem: Record Item;
        SalesLineAISuggestions: Page "Sales Line AI Suggestions";
        StartDate: Date;
    begin
        // [FEATURE] [Sales Line with AI] [Document Lookup] [Sales Quote]
        // [SCENARIO] User input 'I need all items from sales quote with posting date 01/01/2019' from another customer's sales order. System cannot find the order and should not generate any lines.
        Initialize();
        LibrarySales.CreateCustomer(Customer);
        LibrarySales.CreateCustomer(Customer2);
        // [GIVEN] Create a new sales order for the new customer
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Quote, Customer."No.");
        Evaluate(StartDate, '01/01/2019');
        SalesHeader.Validate("Posting Date", StartDate);
        SalesHeader.Modify(true);
        // [GIVEN] Create 3 lines with item description and add it to the new sales order
        Create3SalesLinesWithItemDescription(SalesHeader, SalesLine, CreatedItem);
        LibraryVariableStorage.Enqueue('I need all items from sales quote with posting date 01/01/2019');
        // [WHEN] Create a new sales order for this customer and run Sales Line AI Suggestions Page to generate suggestions lines
        // [THEN] Check no line is generated in 'CheckNothingGeneratedFromSalesOrder' handler function
        CreateNewSalesHeaderAndRunSalesLineAISuggestionsPage(SalesHeader, SalesLineAISuggestions, Customer2."No.", SalesHeader."Document Type"::Order);
        // [THEN] Check no line is inserted to this document
        CheckEmptySalesLineContent(SalesLine, SalesHeader."No.");
    end;

    [Test]
    [HandlerFunctions('CheckGenerateFromSalesOrder')]
    procedure TestCopySalesQuoteByDateRange1()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        CreatedItem: Record Item;
        SalesLineAISuggestions: Page "Sales Line AI Suggestions";
        StartDate: Date;
    begin
        // [FEATURE] [Sales Line with AI] [Document Lookup] [Sales Quote]
        // [SCENARIO] User input 'I need all items from sales quote on January of 2019' in current customer's sales order. System will find the quote and copy all the lines to the current sales order.
        Initialize();
        LibrarySales.CreateCustomer(Customer);
        // [GIVEN] Create a new sales order for the new customer  
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Quote, Customer."No.");
        Evaluate(StartDate, '01/01/2019');
        SalesHeader.Validate("Posting Date", StartDate);
        SalesHeader.Modify(true);
        // [GIVEN] Create 3 lines with item description and add it to the new sales order
        Create3SalesLinesWithItemDescription(SalesHeader, SalesLine, CreatedItem);
        LibraryVariableStorage.Enqueue('I need all items from sales quote on January of 2019');
        LibraryVariableStorage.Enqueue('3');
        Enqueue3SalesLineWithItemDescription();
        Enqueue3SalesLineWithItemDescription();
        // [WHEN] Create a new sales order for this customer and run Sales Line AI Suggestions Page to generate suggestions lines
        // [THEN] Check that correct lines are generated in 'CheckGenerateFromSalesOrder' handler function
        CreateNewSalesHeaderAndRunSalesLineAISuggestionsPage(SalesHeader, SalesLineAISuggestions, Customer."No.", SalesHeader."Document Type"::Order);
        // [THEN] Check all the 3 lines are inserted
        CheckSalesLineContent(SalesLine, SalesHeader."No.");
    end;

    [Test]
    [HandlerFunctions('CheckGenerateFromSalesOrder')]
    procedure TestCopySalesQuoteByDateRange2()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        CreatedItem: Record Item;
        SalesLineAISuggestions: Page "Sales Line AI Suggestions";
        StartDate: Date;
    begin
        // [FEATURE] [Sales Line with AI] [Document Lookup] [Sales Quote]
        // [SCENARIO] User input 'I need all items from sales quote from 2018-12-30 to 2019-Jan-5' in current customer's sales order. System will find the quote and copy all the lines to the current sales order.
        Initialize();
        LibrarySales.CreateCustomer(Customer);
        // [GIVEN] Create a new sales order for the new customer
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Quote, Customer."No.");
        Evaluate(StartDate, '01/01/2019');
        SalesHeader.Validate("Posting Date", StartDate);
        SalesHeader.Modify(true);
        // [GIVEN] Create 3 lines with item description and add it to the new sales order
        Create3SalesLinesWithItemDescription(SalesHeader, SalesLine, CreatedItem);
        LibraryVariableStorage.Enqueue('I need all items from sales quote from 2018-12-30 to 2019-Jan-5');
        LibraryVariableStorage.Enqueue('3');
        Enqueue3SalesLineWithItemDescription();
        Enqueue3SalesLineWithItemDescription();
        // [WHEN] Create a new sales order for this customer and run Sales Line AI Suggestions Page to generate suggestions lines
        // [THEN] Check that correct lines are generated in 'CheckGenerateFromSalesOrder' handler function
        CreateNewSalesHeaderAndRunSalesLineAISuggestionsPage(SalesHeader, SalesLineAISuggestions, Customer."No.", SalesHeader."Document Type"::Order);
        // [THEN] Check all the 3 lines are inserted
        CheckSalesLineContent(SalesLine, SalesHeader."No.");
    end;
    //--------------------------------------------------------------------------------------

    local procedure Initialize()
    begin
        LibraryVariableStorage.Clear();

        if IsInitialized then
            exit;

        TestUtility.RegisterCopilotCapability();

        IsInitialized := true;
    end;

    // Help functions
    local procedure Create3SalesLinesWithItemDescription(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; var CreatedItem: Record Item)
    begin
        LibrarySales.CreateSimpleItemSalesLine(SalesLine, SalesHeader, "Sales Line Type"::Item);
        LibraryInventory.CreateItem(CreatedItem);
        CreatedItem.Validate(Description, Item1DescriptionLbl);
        CreatedItem.Modify(true);

        SalesLine.Validate("No.", CreatedItem."No.");
        SalesLine.Validate(Quantity, 5);
        SalesLine.Modify(true);

        LibrarySales.CreateSimpleItemSalesLine(SalesLine, SalesHeader, "Sales Line Type"::Item);
        LibraryInventory.CreateItem(CreatedItem);
        CreatedItem.Validate(Description, Item2DescriptionLbl);
        CreatedItem.Modify(true);

        SalesLine.Validate("No.", CreatedItem."No.");
        SalesLine.Validate(Quantity, 3);
        SalesLine.Modify(true);

        LibrarySales.CreateSimpleItemSalesLine(SalesLine, SalesHeader, "Sales Line Type"::Item);
        LibraryInventory.CreateItem(CreatedItem);
        CreatedItem.Validate(Description, Item3DescriptionLbl);
        CreatedItem.Modify(true);

        SalesLine.Validate("No.", CreatedItem."No.");
        SalesLine.Validate(Quantity, 2);
        SalesLine.Modify(true);
        LibraryVariableStorage.AssertEmpty();
    end;

    local procedure CreateSalesLinesWithItem1AndUoM(var ItemUoM: Record "Item Unit of Measure"; var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; var CreatedItem: Record Item)
    begin
        LibrarySales.CreateSimpleItemSalesLine(SalesLine, SalesHeader, "Sales Line Type"::Item);
        LibraryInventory.CreateItem(CreatedItem);
        CreatedItem.Validate(Description, Item1DescriptionLbl);
        CreatedItem.Modify(true);
        LibraryInventory.CreateItemUnitOfMeasureCode(ItemUoM, CreatedItem."No.", 1);
        SalesLine.Validate("No.", CreatedItem."No.");
        SalesLine.Validate("Unit of Measure Code", ItemUoM."Code");
        SalesLine.Validate(Quantity, 5);
        SalesLine.Modify(true);
    end;

    local procedure CreateSalesLinesWithItem1(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; var CreatedItem: Record Item)
    begin
        LibrarySales.CreateSimpleItemSalesLine(SalesLine, SalesHeader, "Sales Line Type"::Item);
        LibraryInventory.CreateItem(CreatedItem);
        CreatedItem.Validate(Description, Item1DescriptionLbl);
        CreatedItem.Modify(true);

        SalesLine.Validate("No.", CreatedItem."No.");
        SalesLine.Validate(Quantity, 5);
        SalesLine.Modify(true);
    end;

    local procedure CreateSalesLinesWithItem4AndSalesBlock(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; var CreatedItem: Record Item)
    begin
        LibrarySales.CreateSimpleItemSalesLine(SalesLine, SalesHeader, "Sales Line Type"::Item);
        LibraryInventory.CreateItem(CreatedItem);
        CreatedItem.Validate(Description, Item4DescriptionLbl);
        CreatedItem.Modify(true);

        SalesLine.Validate("No.", CreatedItem."No.");
        SalesLine.Validate(Quantity, 5);
        SalesLine.Modify(true);

        CreatedItem.Validate("Sales Blocked", true);
        CreatedItem.Modify(true);
    end;

    local procedure CreateNewSalesHeaderAndRunSalesLineAISuggestionsPage(var SalesHeader: Record "Sales Header"; var SalesLineAISuggestions: Page "Sales Line AI Suggestions"; CustomerNo: Code[20];
                                                                                                                                                 DocumentType: Enum "Sales Document Type")
    begin
        SalesHeader.Reset();
        LibrarySales.CreateSalesHeader(SalesHeader, DocumentType, CustomerNo);
        SalesLineAISuggestions.SetSalesHeader(SalesHeader);
        SalesLineAISuggestions.LookupMode := true;
        SalesLineAISuggestions.RunModal();
    end;

    local procedure CheckSalesLineContent(SalesLine: Record "Sales Line"; DocumentNo: Text)
    begin
        SalesLine.Reset();
        SalesLine.SetRange("Document No.", DocumentNo);
        SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
        if SalesLine.FindSet() then
            repeat
                Assert.AreEqual(LibraryVariableStorage.DequeueText(), SalesLine.Description, DescriptionIsIncorrectErr);
                Assert.AreEqual(LibraryVariableStorage.DequeueText(), SalesLine."Variant Code", VariantIsIncorrectErr);
                Assert.AreEqual(LibraryVariableStorage.DequeueInteger(), SalesLine.Quantity, QuantityIsIncorrectErr);
            until SalesLine.Next() = 0;
        LibraryVariableStorage.AssertEmpty();
    end;


    local procedure CheckSalesLineContentWithUoM(SalesLine: Record "Sales Line"; DocumentNo: Text)
    begin
        SalesLine.Reset();
        SalesLine.SetRange("Document No.", DocumentNo);
        SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
        if SalesLine.FindSet() then
            repeat
                Assert.AreEqual(LibraryVariableStorage.DequeueText(), SalesLine.Description, DescriptionIsIncorrectErr);
                Assert.AreEqual(LibraryVariableStorage.DequeueText(), SalesLine."Variant Code", VariantIsIncorrectErr);
                Assert.AreEqual(LibraryVariableStorage.DequeueInteger(), SalesLine.Quantity, QuantityIsIncorrectErr);
                Assert.AreEqual(LibraryVariableStorage.DequeueText(), SalesLine."Unit of Measure Code", UoMIsIncorrectErr);
            until SalesLine.Next() = 0;
        LibraryVariableStorage.AssertEmpty();
    end;

    local procedure CheckEmptySalesLineContent(SalesLine: Record "Sales Line"; DocumentNo: Text)
    begin
        SalesLine.Reset();
        SalesLine.SetRange("Document No.", DocumentNo);
        SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
        Assert.IsFalse(SalesLine.FindFirst(), 'No sales line should be generated');
    end;

    local procedure EnqueueItem1()
    begin
        LibraryVariableStorage.Enqueue(Item1DescriptionLbl);
        LibraryVariableStorage.Enqueue('');
        LibraryVariableStorage.Enqueue('5');
    end;

    local procedure EnqueueItem1WithUoM(UoM: Code[10])
    begin
        LibraryVariableStorage.Enqueue(Item1DescriptionLbl);
        LibraryVariableStorage.Enqueue('');
        LibraryVariableStorage.Enqueue('5');
        LibraryVariableStorage.Enqueue(UoM);
    end;

    local procedure EnqueueItemWithVariantCode(VariantCode: Code[10]; Qty: Text)
    begin
        LibraryVariableStorage.Enqueue(VariantCode);
        LibraryVariableStorage.Enqueue(VariantCode);
        LibraryVariableStorage.Enqueue(Qty);
    end;

    local procedure Enqueue3SalesLineWithItemDescription()
    begin
        LibraryVariableStorage.Enqueue(Item1DescriptionLbl);
        LibraryVariableStorage.Enqueue('');
        LibraryVariableStorage.Enqueue('5');
        LibraryVariableStorage.Enqueue(Item2DescriptionLbl);
        LibraryVariableStorage.Enqueue('');
        LibraryVariableStorage.Enqueue('3');
        LibraryVariableStorage.Enqueue(Item3DescriptionLbl);
        LibraryVariableStorage.Enqueue('');
        LibraryVariableStorage.Enqueue('2');
    end;

    [ModalPageHandler]
    procedure CheckGenerateFromSalesOrder(var SalesLineAISuggestions: TestPage "Sales Line AI Suggestions")
    var
        itemCount: Integer;
        quantityInSalesLineSub: Integer;
        i: Integer;
    begin
        // Description for this queue:
        //[{User Input},{Expected Generated Number(shown in page)},{first item's description},{first item's quantity}, {second item's description}, {second item's quantity}...{last item's description}, {last item's quantity]
        // Example: ['I need all items from previous sales order 10000', '3', 'red bike', 'variant code1', '2', 'blue bike','variant code2, '1', 'green bike', 'variant code3', '1']
        // Create a new sales order for the new customer
        Commit();
        SalesLineAISuggestions.SearchQueryTxt.SetValue(LibraryVariableStorage.DequeueText());
        itemCount := LibraryVariableStorage.DequeueInteger();
        SalesLineAISuggestions.Generate.Invoke();
        SalesLineAISuggestions.SalesLinesSub.First();
        for i := 1 to itemCount do begin
            Assert.AreEqual(LibraryVariableStorage.DequeueText(), SalesLineAISuggestions.SalesLinesSub.Description.Value(), DescriptionIsIncorrectErr);
            Assert.AreEqual(LibraryVariableStorage.DequeueText(), SalesLineAISuggestions.SalesLinesSub."Variant Code".Value(), VariantIsIncorrectErr);
            Evaluate(quantityInSalesLineSub, SalesLineAISuggestions.SalesLinesSub.Quantity.Value());
            Assert.AreEqual(LibraryVariableStorage.DequeueInteger(), quantityInSalesLineSub, QuantityIsIncorrectErr);
            SalesLineAISuggestions.SalesLinesSub.Next();
        end;
        SalesLineAISuggestions.OK.Invoke();
    end;

    [ModalPageHandler]
    procedure CheckNothingGeneratedFromSalesOrder(var SalesLineAISuggestions: TestPage "Sales Line AI Suggestions")
    begin
        SalesLineAISuggestions.SearchQueryTxt.SetValue(LibraryVariableStorage.DequeueText());
        SalesLineAISuggestions.Generate.Invoke();
    end;

    [SendNotificationHandler]
    procedure SendNotificationHandler(var TheNotification: Notification): Boolean
    begin
        Assert.AreEqual(LibraryVariableStorage.DequeueText(), TheNotification.Message, 'Notification message is incorrect');
    end;
}