namespace Microsoft.Sales.Document.Test;

using Microsoft.Inventory.Item;
using Microsoft.Sales.Customer;
using Microsoft.Warehouse.ADCS;
using Microsoft.Service.Test;
using Microsoft.Foundation.ExtendedText;
using Microsoft.Inventory.Item.Catalog;
using Microsoft.Sales.Document;
using System.TestLibraries.Utilities;

codeunit 139780 "Search Item Test"
{
    Subtype = Test;
    TestPermissions = Disabled;
    EventSubscriberInstance = Manual;

    var
        GlobalUserInput: Text;

    var
        Assert: Codeunit Assert;
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        LibrarySales: Codeunit "Library - Sales";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryService: Codeunit "Library - Service";
        NoSuggestionGeneratedErr: Label 'There are no suggestions for this description. Please rephrase it.';
        DescriptionIsIncorrectErr: Label 'Description is incorrect!';
        QuantityIsIncorrectErr: Label 'Quantity is incorrect!';
        NeedThreeItemButOneNotExistingLbl: Label 'I need one bike, one table and one Model Took Kit';
        NeedThreeItemButOneIsItemNoLbl: Label 'I need 3 red chairs and one 1928-W, 5 red bikes';
        NeedItemInNonEnglishLbl: Label 'I need one bicikl.';
        InvalidPrecisionErr: Label 'The value %1 in field %2 is of lower precision than expected. \\Note: Default rounding precision of %3 is used if a rounding precision is not defined.', Comment = '%1 - decimal value, %2 - field name, %3 - default rounding precision.';


    [Test]
    [HandlerFunctions('InvokeGenerateAndCheckItemsFound')]
    procedure TestSearchThreeItemsWithOneNotExistingItem()
    var
        SalesHeader: Record "Sales Header";
        SalesLineAISuggestions: Page "Sales Line AI Suggestions";
    begin
        // [FEATURE] [Sales with AI]:[Search Item End to End]
        // [Scenario] User wants to search for 3 items, but 1 one of them is not existing in the system, two lines will be generated.
        // [NOTE] This test is based on demo data. It should be refactored with independent items after the control of full-text searching indexing is supported.
        Initialize();
        // [GIVEN] User specifies 3 items, but one of them is not existing in the system
        LibraryVariableStorage.Enqueue(NeedThreeItemButOneNotExistingLbl);
        LibraryVariableStorage.Enqueue(2);
        EnqueueOneItemAndQty('Bicycle', 1);
        EnqueueOneItemAndQty('ANTWERP Conference Table', 1);
        EnqueueOneItemAndQty('Bicycle', 1);
        EnqueueOneItemAndQty('ANTWERP Conference Table', 1);
        // [WHEN] User input is given to the AI suggestions
        // [THEN] AI suggestions should generate two sales lines, it is handled in the handler function 'InvokeGenerateAndCheckItemsFound'
        CreateNewSalesOrderAndRunSalesLineAISuggestionsPage(SalesHeader, SalesLineAISuggestions);
        // [THEN] One line is inserted in the sales line
        CheckSalesLineContent(SalesHeader."No.");
    end;

    [Test]
    [HandlerFunctions('InvokeGenerateAndCheckItemsFound')]
    procedure TestSearchThreeItemsWithOneItemNo()
    var
        SalesHeader: Record "Sales Header";
        SalesLineAISuggestions: Page "Sales Line AI Suggestions";
    begin
        // [FEATURE] [Sales with AI]:[Search Item End to End]
        // [Scenario] User wants to search for 3 items, which 1 one of them Item No.
        // [NOTE] This test is based on demo data. It should be refactored with independent items after the control of full-text searching indexing is supported.
        Initialize();

        // [GIVEN] User specifies 3 items, but one of them is Item No.
        LibraryVariableStorage.Enqueue(NeedThreeItemButOneIsItemNoLbl);
        LibraryVariableStorage.Enqueue(3);
        EnqueueOneItemAndQty('SEOUL Guest Chair, red', 3);
        EnqueueOneItemAndQty('ST.MORITZ Storage Unit/Drawers', 1);
        EnqueueOneItemAndQty('Bicycle', 5);
        EnqueueOneItemAndQty('SEOUL Guest Chair, red', 3);
        EnqueueOneItemAndQty('ST.MORITZ Storage Unit/Drawers', 1);
        EnqueueOneItemAndQty('Bicycle', 5);

        // [WHEN] User input is given to the AI suggestions
        // [THEN] AI suggestions should generate two sales lines, it is handled in the handler function 'InvokeGenerateAndCheckItemsFound'
        CreateNewSalesOrderAndRunSalesLineAISuggestionsPage(SalesHeader, SalesLineAISuggestions);

        // [THEN] One line is inserted in the sales line
        CheckSalesLineContent(SalesHeader."No.");
    end;

    [Test]
    [HandlerFunctions('InvokeGenerateAndCheckItemsFound')]
    procedure TestSearchBasedOnItemNo()
    var
        SalesHeader: Record "Sales Header";
        Item: Record Item;
        SalesLineAISuggestions: Page "Sales Line AI Suggestions";
        UserInput: Text;
    begin
        // [FEATURE] [Sales with AI]:[Search Item End to End]
        // [Scenario] User wants to search for an item using item no. and AI should suggest the item 
        // [NOTE] This test is based on demo data. It should be refactored with independent items after the control of full-text searching indexing is supported.
        Initialize();
        // [GIVEN] Pick one item
        Item.FindFirst();
        UserInput := GlobalUserInput;
        UserInput += '5 quantity of ' + Item."No." + '; ';
        LibraryVariableStorage.Enqueue(UserInput);
        LibraryVariableStorage.Enqueue(1);
        EnqueueOneItemAndQty(Item.Description, 5);
        EnqueueOneItemAndQty(Item.Description, 5);
        // [WHEN] User input is given to the AI suggestions
        // [THEN] AI suggestions should one sales lines, it is handled in the handler function 'InvokeGenerateAndCheckItemsFound'
        CreateNewSalesOrderAndRunSalesLineAISuggestionsPage(SalesHeader, SalesLineAISuggestions);
        // [THEN] One line is inserted in the sales line
        CheckSalesLineContent(SalesHeader."No.");
    end;

    [Test]
    [HandlerFunctions('InvokeGenerateAndCheckItemsFound')]
    procedure TestSearchBasedOnItemDesc()
    var
        SalesHeader: Record "Sales Header";
        Item: Record Item;
        SalesLineAISuggestions: Page "Sales Line AI Suggestions";
        UserInput: Text;
    begin
        // [FEATURE] [Sales with AI]:[Search Item End to End]
        // [Scenario] User wants to search for an item using item description and AI should suggest the item
        // [NOTE] This test is based on demo data. It should be refactored with independent items after the control of full-text searching indexing is supported.
        Initialize();
        Item.FindFirst();
        UserInput := GlobalUserInput;
        UserInput += '5 quantity of ' + Item.Description + '; ';
        LibraryVariableStorage.Enqueue(UserInput);
        LibraryVariableStorage.Enqueue(1);
        EnqueueOneItemAndQty(Item.Description, 5);
        EnqueueOneItemAndQty(Item.Description, 5);
        // [WHEN] User input is given to the AI suggestions
        // [THEN] AI suggestions should one sales lines, it is handled in the handler function 'InvokeGenerateAndCheckItemsFound'
        CreateNewSalesOrderAndRunSalesLineAISuggestionsPage(SalesHeader, SalesLineAISuggestions);
        // [THEN] One line is inserted in the sales line
        CheckSalesLineContent(SalesHeader."No.");
    end;

    [Test]
    [HandlerFunctions('InvokeGenerateAndCheckItemsFound')]
    procedure TestSearchBasedOnVendorItemNo()
    var
        SalesHeader: Record "Sales Header";
        Item: Record Item;
        SalesLineAISuggestions: Page "Sales Line AI Suggestions";
        UserInput: Text;
    begin
        // [FEATURE] [Sales with AI]:[Search Item End to End]
        // [Scenario] User wants to search for an item with VendorItemNo. and AI should suggest the item 
        // [NOTE] This test is based on demo data. It should be refactored with independent items after the control of full-text searching indexing is supported.
        Initialize();
        // [GIVEN] Find an item with Vendor Item No.
        Item.SetFilter("Vendor Item No.", '<>%1', '');
        Item.FindFirst();
        UserInput := GlobalUserInput;
        UserInput += '5 quantity of ' + Item."Vendor Item No." + '; ';
        LibraryVariableStorage.Enqueue(UserInput);
        LibraryVariableStorage.Enqueue(1);
        EnqueueOneItemAndQty(Item.Description, 5);
        EnqueueOneItemAndQty(Item.Description, 5);
        // [WHEN] User input is given to the AI suggestions
        // [THEN] AI suggestions should one sales lines, it is handled in the handler function 'InvokeGenerateAndCheckItemsFound'
        CreateNewSalesOrderAndRunSalesLineAISuggestionsPage(SalesHeader, SalesLineAISuggestions);
        // [THEN] One line is inserted in the sales line
        CheckSalesLineContent(SalesHeader."No.");
    end;


    [Test]
    [HandlerFunctions('InvokeGenerateAndCheckItemsFound')]
    procedure TestSearchBasedOnItemVariantCode()
    var
        SalesHeader: Record "Sales Header";
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        SalesLineAISuggestions: Page "Sales Line AI Suggestions";
        UserInput: Text;
    begin
        // [FEATURE] [Sales with AI]:[Search Item End to End]
        // [Scenario] User wants to search for an item with Variant Code. and AI should suggest the item 
        // [NOTE] This test is based on demo data. It should be refactored with independent items after the control of full-text searching indexing is supported.
        Initialize();
        // [GIVEN] Find an item with Variant Code.
        ItemVariant.SetFilter("Code", '<>%1', '');
        ItemVariant.FindFirst();
        Item.SetRange("No.", ItemVariant."Item No.");
        Item.FindFirst();
        UserInput := GlobalUserInput;
        UserInput += '5 quantity of ' + ItemVariant.Code + '; ';
        LibraryVariableStorage.Enqueue(UserInput);
        LibraryVariableStorage.Enqueue(1);
        EnqueueOneItemAndQty(Item.Description, 5);
        EnqueueOneItemAndQty(Item.Description, 5);
        // [WHEN] User input is given to the AI suggestions
        // [THEN] AI suggestions should one sales lines, it is handled in the handler function 'InvokeGenerateAndCheckItemsFound'
        CreateNewSalesOrderAndRunSalesLineAISuggestionsPage(SalesHeader, SalesLineAISuggestions);
        // [THEN] One line is inserted in the sales line
        CheckSalesLineContent(SalesHeader."No.");
    end;

    [Test]
    [HandlerFunctions('InvokeGenerateAndCheckItemsFound')]
    procedure TestSearchBasedOnReferenceNo()
    var
        SalesHeader: Record "Sales Header";
        Item: Record Item;
        ItemReference: Record "Item Reference";
        SalesLineAISuggestions: Page "Sales Line AI Suggestions";
        UserInput: Text;
    begin
        // [FEATURE] [Sales with AI]:[Search Item End to End]
        // [Scenario] User wants to search for an item with Reference No. and AI should suggest the item 
        // [NOTE] This test is based on demo data. It should be refactored with independent items after the control of full-text searching indexing is supported.
        Initialize();
        // [GIVEN] Find an item with Reference No.
        ItemReference.SetFilter("Reference No.", '<>%1', '');
        ItemReference.FindFirst();
        Item.SetRange("No.", ItemReference."Item No.");
        Item.FindFirst();
        UserInput := GlobalUserInput;
        UserInput += '5 quantity of ' + ItemReference."Reference No." + '; ';
        LibraryVariableStorage.Enqueue(UserInput);
        LibraryVariableStorage.Enqueue(1);
        EnqueueOneItemAndQty(Item.Description, 5);
        EnqueueOneItemAndQty(Item.Description, 5);
        // [WHEN] User input is given to the AI suggestions
        // [THEN] AI suggestions should one sales lines, it is handled in the handler function 'InvokeGenerateAndCheckItemsFound'
        CreateNewSalesOrderAndRunSalesLineAISuggestionsPage(SalesHeader, SalesLineAISuggestions);
        // [THEN] One line is inserted in the sales line
        CheckSalesLineContent(SalesHeader."No.");
    end;

    [Test]
    [HandlerFunctions('InvokeGenerateAndCheckItemsFound')]
    procedure TestSearchBasedOnReferenceDesc()
    var
        SalesHeader: Record "Sales Header";
        Item: Record Item;
        ItemReference: Record "Item Reference";
        SalesLineAISuggestions: Page "Sales Line AI Suggestions";
        UserInput: Text;
    begin
        // [FEATURE] [Sales with AI]:[Search Item End to End]
        // [Scenario] User wants to search for an item with "Reference Description" and AI should suggest the item 
        // [NOTE] This test is based on demo data. It should be refactored with independent items after the control of full-text searching indexing is supported.
        Initialize();
        // [GIVEN] Find an item with Reference Description
#pragma warning disable AA0210
        ItemReference.SetFilter(Description, '<>%1', '');
        ItemReference.FindFirst();
        Item.SetRange("No.", ItemReference."Item No.");
        Item.FindFirst();
        UserInput := GlobalUserInput;
        UserInput += '5 quantity of ' + ItemReference.Description + '; ';
        LibraryVariableStorage.Enqueue(UserInput);
        LibraryVariableStorage.Enqueue(1);
        EnqueueOneItemAndQty(Item.Description, 5);
        EnqueueOneItemAndQty(Item.Description, 5);
        // [WHEN] User input is given to the AI suggestions
        // [THEN] AI suggestions should one sales lines, it is handled in the handler function 'InvokeGenerateAndCheckItemsFound'
        CreateNewSalesOrderAndRunSalesLineAISuggestionsPage(SalesHeader, SalesLineAISuggestions);
        // [THEN] One line is inserted in the sales line
        CheckSalesLineContent(SalesHeader."No.");
    end;

    [Test]
    [HandlerFunctions('InvokeGenerateAndCheckItemsFound')]
    procedure TestSearchBasedOnItemCategoryCode()
    var
        SalesHeader: Record "Sales Header";
        Item: Record Item;
        ItemCategory: Record "Item Category";
        SalesLineAISuggestions: Page "Sales Line AI Suggestions";
        UserInput: Text;
    begin
        // [FEATURE] [Sales with AI]:[Search Item End to End]
        // [Scenario] User wants to search for an item with Item Category and AI should suggest the item 
        // [NOTE] This test is based on demo data. It should be refactored with independent items after the control of full-text searching indexing is supported.
        Initialize();
        // [GIVEN] Find an item with Item Category Code
        Item.SetFilter("Item Category Code", '<>%1', '');
        Item.FindFirst();
        ItemCategory.SetRange("Code", Item."Item Category Code");
        ItemCategory.FindFirst();
        UserInput := GlobalUserInput;
        UserInput += '5 quantity of ' + ItemCategory.Code + '; ';
        LibraryVariableStorage.Enqueue(UserInput);
        LibraryVariableStorage.Enqueue(1);
        EnqueueOneItemAndQty(Item.Description, 5);
        EnqueueOneItemAndQty(Item.Description, 5);
        // [WHEN] User input is given to the AI suggestions
        // [THEN] AI suggestions should one sales lines, it is handled in the handler function 'InvokeGenerateAndCheckItemsFound'
        CreateNewSalesOrderAndRunSalesLineAISuggestionsPage(SalesHeader, SalesLineAISuggestions);
        // [THEN] One line is inserted in the sales line
        CheckSalesLineContent(SalesHeader."No.");
    end;

    [Test]
    [HandlerFunctions('InvokeGenerateAndCheckItemsFound')]
    procedure TestSearchBasedOnItemCategoryDesc()
    var
        SalesHeader: Record "Sales Header";
        Item: Record Item;
        ItemCategory: Record "Item Category";
        SalesLineAISuggestions: Page "Sales Line AI Suggestions";
        UserInput: Text;
    begin
        // [FEATURE] [Sales with AI]:[Search Item End to End]
        // [Scenario] User wants to search for an item with Item Category Description and AI should suggest the item 
        // [NOTE] This test is based on demo data. It should be refactored with independent items after the control of full-text searching indexing is supported.
        Initialize();
        // [GIVEN] Find an item with Item Category Description
        Item.SetFilter("Item Category Code", '<>%1', '');
        Item.FindFirst();
        ItemCategory.SetRange("Code", Item."Item Category Code");
        ItemCategory.FindFirst();
        UserInput := GlobalUserInput;
        UserInput += '5 quantity of ' + ItemCategory.Description + '; ';
        LibraryVariableStorage.Enqueue(UserInput);
        LibraryVariableStorage.Enqueue(1);
        EnqueueOneItemAndQty(Item.Description, 5);
        EnqueueOneItemAndQty(Item.Description, 5);
        // [WHEN] User input is given to the AI suggestions
        // [THEN] AI suggestions should one sales lines, it is handled in the handler function 'InvokeGenerateAndCheckItemsFound'
        CreateNewSalesOrderAndRunSalesLineAISuggestionsPage(SalesHeader, SalesLineAISuggestions);
        // [THEN] One line is inserted in the sales line
        CheckSalesLineContent(SalesHeader."No.");
    end;

    [Test]
    [HandlerFunctions('InvokeGenerateAndCheckItemsFound')]
    procedure TestSearchBasedOnItemCategoryParentCategory()
    var
        SalesHeader: Record "Sales Header";
        Item: Record Item;
        ItemCategory: Record "Item Category";
        SalesLineAISuggestions: Page "Sales Line AI Suggestions";
        UserInput: Text;
    begin
        // [FEATURE] [Sales with AI]:[Search Item End to End]
        // [Scenario] User wants to search for an item with Parent Category of the item category and AI should suggest the item 
        // [NOTE] This test is based on demo data. It should be refactored with independent items after the control of full-text searching indexing is supported.
        Initialize();
        // [GIVEN] Find an item with Parent Category of the Item Category
        Item.SetFilter("Item Category Code", '<>%1', '');
        Item.FindFirst();
        ItemCategory.SetRange("Code", Item."Item Category Code");
        ItemCategory.FindFirst();
        UserInput := GlobalUserInput;
        UserInput += '5 quantity of ' + ItemCategory."Parent Category" + '; ';
        LibraryVariableStorage.Enqueue(UserInput);
        LibraryVariableStorage.Enqueue(1);
        EnqueueOneItemAndQty(Item.Description, 5);
        EnqueueOneItemAndQty(Item.Description, 5);
        // [WHEN] User input is given to the AI suggestions
        // [THEN] AI suggestions should one sales lines, it is handled in the handler function 'InvokeGenerateAndCheckItemsFound'
        CreateNewSalesOrderAndRunSalesLineAISuggestionsPage(SalesHeader, SalesLineAISuggestions);
        // [THEN] One line is inserted in the sales line
        CheckSalesLineContent(SalesHeader."No.");
    end;

    [Test]
    [HandlerFunctions('InvokeGenerateAndCheckItemsFound')]
    procedure TestSearchBasedOnItemTranslationCode()
    var
        SalesHeader: Record "Sales Header";
        Item: Record Item;
        ItemTranslation: Record "Item Translation";
        SalesLineAISuggestions: Page "Sales Line AI Suggestions";
        UserInput: Text;
    begin
        // [FEATURE] [Sales with AI]:[Search Item End to End]
        // [Scenario] User wants to search for an item with "Item Translate Code" and AI should suggest the item 
        // [NOTE] This test is based on demo data. It should be refactored with independent items after the control of full-text searching indexing is supported.
        Initialize();
        // [GIVEN] Find an item with Item Translate Code
        ItemTranslation.FindFirst();
        Item.SetRange("No.", ItemTranslation."Item No.");
        Item.FindFirst();
        UserInput := GlobalUserInput;
        UserInput += '5 quantity of ' + ItemTranslation."Language Code" + '; ';
        LibraryVariableStorage.Enqueue(UserInput);
        LibraryVariableStorage.Enqueue(1);
        EnqueueOneItemAndQty(Item.Description, 5);
        EnqueueOneItemAndQty(Item.Description, 5);
        // [WHEN] User input is given to the AI suggestions
        // [THEN] AI suggestions should one sales lines, it is handled in the handler function 'InvokeGenerateAndCheckItemsFound'
        CreateNewSalesOrderAndRunSalesLineAISuggestionsPage(SalesHeader, SalesLineAISuggestions);
        // [THEN] One line is inserted in the sales line
        CheckSalesLineContent(SalesHeader."No.");
    end;

    [Test]
    [HandlerFunctions('InvokeGenerateAndCheckItemsFound')]
    procedure TestSearchBasedOnItemTranslationDesc()
    var
        SalesHeader: Record "Sales Header";
        Item: Record Item;
        ItemTranslation: Record "Item Translation";
        SalesLineAISuggestions: Page "Sales Line AI Suggestions";
        UserInput: Text;
    begin
        // [FEATURE] [Sales with AI]:[Search Item End to End]
        // [Scenario] User wants to search for an item with "Item Translate Description" and AI should suggest the item 
        // [NOTE] This test is based on demo data. It should be refactored with independent items after the control of full-text searching indexing is supported.
        Initialize();
        // [GIVEN] Find an item with Item Translate Description
        ItemTranslation.FindFirst();
        Item.SetRange("No.", ItemTranslation."Item No.");
        Item.FindFirst();
        UserInput := GlobalUserInput;
        UserInput += '5 quantity of ' + ItemTranslation.Description + '; ';
        LibraryVariableStorage.Enqueue(UserInput);
        LibraryVariableStorage.Enqueue(1);
        EnqueueOneItemAndQty(Item.Description, 5);
        EnqueueOneItemAndQty(Item.Description, 5);
        // [WHEN] User input is given to the AI suggestions
        // [THEN] AI suggestions should one sales lines, it is handled in the handler function 'InvokeGenerateAndCheckItemsFound'
        CreateNewSalesOrderAndRunSalesLineAISuggestionsPage(SalesHeader, SalesLineAISuggestions);
        // [THEN] One line is inserted in the sales line
        CheckSalesLineContent(SalesHeader."No.");
    end;

    [Test]
    [HandlerFunctions('InvokeGenerateAndCheckItemsFound')]
    procedure TestSearchBasedOnItemIdentifierCode()
    var
        SalesHeader: Record "Sales Header";
        Item: Record Item;
        ItemIdentifier: Record "Item Identifier";
        SalesLineAISuggestions: Page "Sales Line AI Suggestions";
        UserInput: Text;
    begin
        // [FEATURE] [Sales with AI]:[Search Item End to End]
        // [Scenario] User wants to search for an item with "Item Identifier Code" and AI should suggest the item 
        // [NOTE] This test is based on demo data. It should be refactored with independent items after the control of full-text searching indexing is supported.
        Initialize();
        // [GIVEN] Find an item with Item Identifier Code
        ItemIdentifier.FindFirst();
        Item.SetRange("No.", ItemIdentifier."Item No.");
        Item.FindFirst();
        UserInput := GlobalUserInput;
        UserInput += '5 quantity of ' + ItemIdentifier.Code + '; ';
        LibraryVariableStorage.Enqueue(UserInput);
        LibraryVariableStorage.Enqueue(1);
        EnqueueOneItemAndQty(Item.Description, 5);
        EnqueueOneItemAndQty(Item.Description, 5);
        // [WHEN] User input is given to the AI suggestions
        // [THEN] AI suggestions should one sales lines, it is handled in the handler function 'InvokeGenerateAndCheckItemsFound'
        CreateNewSalesOrderAndRunSalesLineAISuggestionsPage(SalesHeader, SalesLineAISuggestions);
        // [THEN] One line is inserted in the sales line
        CheckSalesLineContent(SalesHeader."No.");
    end;

    [Test]
    [HandlerFunctions('InvokeGenerateAndCheckItemsFound')]
    procedure TestSearchBasedOnItemExtendedText()
    var
        SalesHeader: Record "Sales Header";
        Item: Record Item;
        ItemExtendedTextLine: Record "Extended Text Line";
        SalesLineAISuggestions: Page "Sales Line AI Suggestions";
        UserInput: Text;
    begin
        // [FEATURE] [Sales with AI]:[Search Item End to End]
        // [Scenario] User wants to search for an item with "Item Extended Text" and AI should suggest the item 
        // [NOTE] This test is based on demo data. It should be refactored with independent items after the control of full-text searching indexing is supported.
        Initialize();
        // [GIVEN] Find an item with "Item Extended Text"
        ItemExtendedTextLine.FindFirst();
        Item.SetRange("No.", ItemExtendedTextLine."No.");
        Item.FindFirst();
        UserInput := GlobalUserInput;
        UserInput += '5 quantity of ' + ItemExtendedTextLine.Text + '; ';
        LibraryVariableStorage.Enqueue(UserInput);
        LibraryVariableStorage.Enqueue(1);
        EnqueueOneItemAndQty(Item.Description, 5);
        EnqueueOneItemAndQty(Item.Description, 5);
        // [WHEN] User input is given to the AI suggestions
        // [THEN] AI suggestions should one sales lines, it is handled in the handler function 'InvokeGenerateAndCheckItemsFound'
        CreateNewSalesOrderAndRunSalesLineAISuggestionsPage(SalesHeader, SalesLineAISuggestions);
        // [THEN] One line is inserted in the sales line
        CheckSalesLineContent(SalesHeader."No.");
    end;

    [Test]
    [HandlerFunctions('InvokeGenerateAndNoItemFound,SendNotificationHandler')]
    procedure TestSearchNotExistingItem()
    var
        SalesHeader: Record "Sales Header";
        SalesLineAISuggestions: Page "Sales Line AI Suggestions";
    begin
        // [FEATURE] [Sales with AI]:[Search Item End to End]
        // [Scenario] User wants to search for an item that does not exist in the system, AI should not suggest any item and show a notification
        // [NOTE] This test is based on demo data. It should be refactored with independent items after the control of full-text searching indexing is supported.
        Initialize();
        LibraryVariableStorage.Clear();
        // [GIVEN] Generate prompt with Document No.
        LibraryVariableStorage.Enqueue(GlobalUserInput + '5 MiawCrosoft');
        LibraryVariableStorage.Enqueue(NoSuggestionGeneratedErr);
        // [WHEN] User input is given to the AI suggestions
        // [THEN] AI suggestions should not generate any sales lines, it is handled in the handler function 'InvokeGenerateAndNoItemFound
        // [THEN] Show a notification, it is handled in the handler function 'SendNotificationHandler'
        CreateNewSalesOrderAndRunSalesLineAISuggestionsPage(SalesHeader, SalesLineAISuggestions);
        // [THEN] No line is inserted in the sales line
        CheckSalesLineContent(SalesHeader."No.");
    end;

    [Test]
    [HandlerFunctions('InvokeGenerateAndNoItemFound,SendNotificationHandler')]
    procedure TestSearchSalesBlockedItem()
    var
        Item: Record Item;
        SalesHeader: Record "Sales Header";
        SalesLineAISuggestions: Page "Sales Line AI Suggestions";
        Qty: Decimal;
        UserInput: Text;
    begin
        // [FEATURE] [Sales with AI]:[Search Item End to End]
        // [Scenario] User wants to search for sales blocked item, AI should not suggest sales blocked items  
        // [NOTE] This test is based on demo data. It should be refactored with independent items after the control of full-text searching indexing is supported.
        Initialize();
        Qty := 5;
        // [GIVEN] Change one item to sales blocked
        Item.FindFirst();
        Item.Validate("Sales Blocked", true);
        Item.Modify(true);
        UserInput := GlobalUserInput;
        UserInput += Format(Qty) + ' quantity of ' + Item."No." + '; ';
        // [WHEN] User input is given to the AI suggestions
        LibraryVariableStorage.Enqueue(UserInput);
        LibraryVariableStorage.Enqueue(NoSuggestionGeneratedErr);
        // [THEN] AI suggestions should not generate any sales lines, it is handled in the handler function 'InvokeGenerateAndNoItemFound
        // [THEN] Show a notification, it is handled in the handler function 'SendNotificationHandler'
        CreateNewSalesOrderAndRunSalesLineAISuggestionsPage(SalesHeader, SalesLineAISuggestions);
        // [THEN] No line is inserted in the sales line
        CheckSalesLineContent(SalesHeader."No.");
    end;

    [Test]
    [HandlerFunctions('EvaluateSearchItemForMultipleItemNos')]
    procedure EvaluateSearchItemForItemNoAsInput()
    var
        Item: Record Item;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesLineAISuggestionImpl: Codeunit "Sales Lines Suggestions Impl.";
        ListOfItems: List of [Text];
        Qty: Decimal;
        i: Integer;
        UserInput: Text;
    begin
        // [FEATURE] [Sales with AI]:[Search Item End to End]
        // [Scenario] Add up to 50 item no. in sales lines using AI suggestions in one user input  
        // [NOTE] This test is based on demo data. It should be refactored with independent items after the control of full-text searching indexing is supported.
        Initialize();
        Qty := 5;
        Item.SetLoadFields("No.");
        Item.SetRange(Blocked, false);
        Item.SetRange("Sales Blocked", false);
        UserInput := GlobalUserInput;
        if Item.FindSet() then
            repeat
                UserInput += Format(Qty) + ' quantity of ' + Item."No." + '; ';
                ListOfItems.Add(Item."No.");
                i += 1;
            until (Item.Next() = 0) or (i = 5);

        // [GIVEN] Create a new sales order for a new customer
        CreateSalesOrderWithSalesLine(SalesHeader, SalesLine);

        // [WHEN] User input is given to the AI suggestions
        LibraryVariableStorage.Enqueue(UserInput);
        LibraryVariableStorage.Enqueue(ListOfItems);
        LibraryVariableStorage.Enqueue(Qty);
        SalesLineAISuggestionImpl.GetLinesSuggestions(SalesLine);

        // [THEN] AI suggestions should generate the expected sales lines
        // Handled in EvaluateSearchItemForMultipleItems
    end;

    [Test]
    [HandlerFunctions('EvaluateSearchItemForMultipleItemNos')]
    procedure EvaluateSearchItemForItemDescAsInput()
    var
        Item: Record Item;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesLineAISuggestionImpl: Codeunit "Sales Lines Suggestions Impl.";
        ListOfItems: List of [Text];
        Qty: Decimal;
        i: Integer;
        UserInput: Text;
    begin
        // [FEATURE] [Sales with AI]:[Search Item End to End]
        // [Scenario] Add up to 50 item no. in sales lines using AI suggestions in one user input  
        // [NOTE] This test is based on demo data. It should be refactored with independent items after the control of full-text searching indexing is supported.
        Initialize();
        Qty := 5;
        Item.SetLoadFields("No.", Description);
        Item.SetRange(Blocked, false);
        Item.SetRange("Sales Blocked", false);
        UserInput := GlobalUserInput;
        if Item.FindSet() then
            repeat
                UserInput += Format(Qty) + ' quantity of ' + Item.Description + '; ';
                ListOfItems.Add(Item."No.");
                i += 1;
            until (Item.Next() = 0) or (i = 5);

        // [GIVEN] Create a new sales order for a new customer
        CreateSalesOrderWithSalesLine(SalesHeader, SalesLine);

        // [WHEN] User input is given to the AI suggestions
        LibraryVariableStorage.Enqueue(UserInput);
        LibraryVariableStorage.Enqueue(ListOfItems);
        LibraryVariableStorage.Enqueue(Qty);
        SalesLineAISuggestionImpl.GetLinesSuggestions(SalesLine);

        // [THEN] AI suggestions should generate the expected sales lines
        // Handled in EvaluateSearchItemForMultipleItems
    end;

    [Test]
    [HandlerFunctions('EvaluateSearchItemForMultipleItemNos')]
    procedure EvaluateSearchItemForItemNoAndDescAsInput()
    var
        Item: Record Item;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesLineAISuggestionImpl: Codeunit "Sales Lines Suggestions Impl.";
        ListOfItems: List of [Text];
        Qty: Decimal;
        i: Integer;
        UserInput: Text;
    begin
        // [FEATURE] [Sales with AI]:[Search Item End to End]
        // [Scenario] Add up to 50 item no. in sales lines using AI suggestions in one user input  
        // [NOTE] This test is based on demo data. It should be refactored with independent items after the control of full-text searching indexing is supported.
        Initialize();
        Qty := 5;
        Item.SetLoadFields("No.", Description);
        Item.SetRange(Blocked, false);
        Item.SetRange("Sales Blocked", false);
        UserInput := GlobalUserInput;
        if Item.FindSet() then
            repeat
                UserInput += Format(Qty) + ' quantity of ' + Item."No." + ' ' + Item.Description + '; ';
                ListOfItems.Add(Item."No.");
                i += 1;
            until (Item.Next() = 0) or (i = 5);

        // [GIVEN] Create a new sales order for a new customer
        CreateSalesOrderWithSalesLine(SalesHeader, SalesLine);

        // [WHEN] User input is given to the AI suggestions
        LibraryVariableStorage.Enqueue(UserInput);
        LibraryVariableStorage.Enqueue(ListOfItems);
        LibraryVariableStorage.Enqueue(Qty);
        SalesLineAISuggestionImpl.GetLinesSuggestions(SalesLine);

        // [THEN] AI suggestions should generate the expected sales lines
        // Handled in EvaluateSearchItemForMultipleItems
    end;

    [Test]
    [HandlerFunctions('InvokeGenerateAndCheckItemsFound')]
    procedure ExtendedTextIsInsertedOnSalesOrderLinesOnInsertSuggestedLines()
    var
        SalesHeader: Record "Sales Header";
        Item: Record Item;
        SalesLineAISuggestions: Page "Sales Line AI Suggestions";
        UserInput: Text;
        ItemExtText: Text[100];
    begin
        // [SCENARIO 525387] Verify Extended Text is added on Sales Order line on insert suggested lines
        Initialize();

        // [GIVEN] Find Item and set Automatic Ext. Text for Item
        Item.FindFirst();
        Item.Validate("Automatic Ext. Texts", true);
        Item.Modify(true);

        // [GIVEN] Create Item Extended Text
        CreateItemExtendedText(Item."No.", ItemExtText);

        // [GIVEN] Create user input
        UserInput := GlobalUserInput;
        UserInput += '5 quantity of ' + Item."No." + '; ';

        LibraryVariableStorage.Enqueue(UserInput);
        LibraryVariableStorage.Enqueue(1);

        EnqueueOneItemAndQty(Item.Description, 5);
        EnqueueOneItemAndQty(Item.Description, 5);
        EnqueueOneItemAndQty(ItemExtText, 0);

        // [WHEN] User input is given to the AI suggestions
        // [THEN] AI suggestions should one sales lines, it is handled in the handler function 'InvokeGenerateAndCheckItemsFound'
        CreateNewSalesOrderAndRunSalesLineAISuggestionsPage(SalesHeader, SalesLineAISuggestions);

        // [THEN] One line is inserted in the sales line
        CheckSalesLineContent(SalesHeader."No.");
    end;

    [Test]
    [HandlerFunctions('InvokeGenerateAndCheckItemsFound')]
    procedure TestSearchItemReturnedInOriginName()
    var
        SalesHeader: Record "Sales Header";
        SalesLineAISuggestions: Page "Sales Line AI Suggestions";
    begin
        // [FEATURE] [Sales with AI]:[Search Item End to End]
        // [Scenario] User wants to search for item, written in different language than english, returned in origin_name property
        Initialize();

        // [GIVEN] User specifies item in different language than english
        LibraryVariableStorage.Enqueue(NeedItemInNonEnglishLbl);
        LibraryVariableStorage.Enqueue(1);
        EnqueueOneItemAndQty('Bicycle', 1);
        EnqueueOneItemAndQty('Bicycle', 1);

        // [WHEN] User input is given to the AI suggestions
        // [THEN] AI suggestions should generate one sales line, it is handled in the handler function 'InvokeGenerateAndCheckItemsFound'
        CreateNewSalesOrderAndRunSalesLineAISuggestionsPage(SalesHeader, SalesLineAISuggestions);

        // [THEN] One line is inserted in the sales line
        CheckSalesLineContent(SalesHeader."No.");
    end;

    [Test]
    [HandlerFunctions('InvokeGenerateAndCheckItemsFound,SendNotificationHandler')]
    procedure SalesLineIsNotInsertedIfErrorOccursOnInsertSuggestedLine()
    var
        SalesHeader: Record "Sales Header";
        Item: Record Item;
        SalesLineAISuggestions: Page "Sales Line AI Suggestions";
        UserInput: Text;
        Quantity: Text;
    begin
        // [SCENARIO 507779] If error occurs on insert suggested lines, notification is thrown and lines are not inserted
        Initialize();

        // [GIVEN] Find first Item
        Item.FindFirst();
        UpdateRoundingPrecisonForItem(Item);

        // [GIVEN] Create user input
        Quantity := '2.5';
        UserInput := GlobalUserInput;
        UserInput += Quantity + ' quantity of ' + Item."No." + '; ';

        LibraryVariableStorage.Enqueue(UserInput);
        LibraryVariableStorage.Enqueue(1);
        EnqueueOneItemAndQty(Item.Description, 2.5);

        LibraryVariableStorage.Enqueue(StrSubstNo(InvalidPrecisionErr, Quantity, 'Quantity', '0.00001'));

        // [WHEN] AI suggestions should generate sales line
        // [HANDLER] Show a notification, it is handled in the handler function 'SendNotificationHandler'
        CreateNewSalesOrderAndRunSalesLineAISuggestionsPage(SalesHeader, SalesLineAISuggestions);

        // [THEN] No line is inserted in the sales line
        CheckSalesLineContent(SalesHeader."No.");
    end;

    local procedure CreateSalesOrderWithSalesLine(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line")
    var
        Customer: Record Customer;
    begin
        LibrarySales.CreateCustomer(Customer);
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");
        LibrarySales.CreateSalesLineSimple(SalesLine, SalesHeader);
    end;

    [PageHandler]
    procedure EvaluateSearchItemForMultipleItemNos(var SalesLineAISuggestions: TestPage "Sales Line AI Suggestions")
    var
        Qty: Decimal;
        ListOfItemsVariant: Variant;
        ListOfItems: List of [Text];
        ListOfUnexpectedItems: List of [Text];
        DictOfFailedQty: Dictionary of [Code[20], Decimal];
        UserInput: Text;
    begin
        UserInput := LibraryVariableStorage.DequeueText();
        SalesLineAISuggestions.SearchQueryTxt.SetValue(UserInput);
        LibraryVariableStorage.Dequeue(ListOfItemsVariant);
        ListOfItems := ListOfItemsVariant;
        Qty := LibraryVariableStorage.DequeueInteger();
        SalesLineAISuggestions.Generate.Invoke();

        SalesLineAISuggestions.SalesLinesSub.First();
        repeat
            if ListOfItems.Contains(SalesLineAISuggestions.SalesLinesSub."No.".Value()) then
                ListOfItems.Remove(SalesLineAISuggestions.SalesLinesSub."No.".Value())
            else
                ListOfUnexpectedItems.Add(SalesLineAISuggestions.SalesLinesSub."No.".Value());

            if Qty <> SalesLineAISuggestions.SalesLinesSub.Quantity.AsDecimal() then
                DictOfFailedQty.Add(Format(SalesLineAISuggestions.SalesLinesSub."No.".Value), SalesLineAISuggestions.SalesLinesSub.Quantity.AsDecimal());
        until SalesLineAISuggestions.SalesLinesSub.Next() = false;

        if (ListOfItems.Count > 0) or (ListOfUnexpectedItems.Count > 0) then
            Error('Some items are not found in the AI suggestions. User input: %1\Missing Items: %2\Unexpected Items:%3\QtyMisMatch: %4', UserInput, ListOfTextToText(ListOfItems), ListOfTextToText(ListOfUnexpectedItems), DictionaryOfCodeToDecimalToText(DictOfFailedQty));

        SalesLineAISuggestions.Cancel.Invoke();
    end;

    local procedure ListOfTextToText(var ListOfText: List of [Text]) Result: Text
    var
        Txt: Text;
    begin
        foreach Txt in ListOfText do
            Result += Txt + ', ';
        Result := Result.TrimEnd(', ');
    end;

    local procedure DictionaryOfCodeToDecimalToText(var DictOfCodeToDecimal: Dictionary of [Code[20], Decimal]) Result: Text
    var
        Key1: Code[20];
    begin
        foreach Key1 in DictOfCodeToDecimal.Keys do
            Result += Key1 + ':' + Format(DictOfCodeToDecimal.Get(Key1)) + ', ';
        Result := Result.TrimEnd(', ');
    end;

    local procedure Initialize()
    begin
        GlobalUserInput := 'I need the following items: ';

        LibraryVariableStorage.Clear();
    end;

    local procedure CreateNewSalesOrderAndRunSalesLineAISuggestionsPage(var SalesHeader: Record "Sales Header"; var SalesLineAISuggestions: Page "Sales Line AI Suggestions")
    var
        Customer: Record Customer;
    begin
        SalesHeader.Reset();
        LibrarySales.CreateCustomer(Customer);
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");
        SalesLineAISuggestions.SetSalesHeader(SalesHeader);
        SalesLineAISuggestions.LookupMode := true;
        SalesLineAISuggestions.RunModal();
    end;

    local procedure CheckSalesLineContent(DocumentNo: Text)
    var
        SalesLine: Record "Sales Line";
    begin
        SalesLine.Reset();
        SalesLine.SetRange("Document No.", DocumentNo);
        SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
        if SalesLine.FindSet() then
            repeat
                Assert.AreEqual(LibraryVariableStorage.DequeueText(), SalesLine.Description, DescriptionIsIncorrectErr);
                Assert.AreEqual(LibraryVariableStorage.DequeueInteger(), SalesLine.Quantity, QuantityIsIncorrectErr);
            until SalesLine.Next() = 0;
        LibraryVariableStorage.AssertEmpty();
    end;

    local procedure EnqueueOneItemAndQty(ItemDesc: Text; Qty: Decimal)
    begin
        LibraryVariableStorage.Enqueue(ItemDesc);
        LibraryVariableStorage.Enqueue(Qty);
    end;

    local procedure CreateItemExtendedText(ItemNo: Code[20]; var ExtText: Text[100])
    var
        ExtendedTextHeader: Record "Extended Text Header";
        ExtendedTextLine: Record "Extended Text Line";
    begin
        LibraryService.CreateExtendedTextHeaderItem(ExtendedTextHeader, ItemNo);
        LibraryService.CreateExtendedTextLineItem(ExtendedTextLine, ExtendedTextHeader);
        ExtendedTextLine.Validate(Text, LibraryUtility.GenerateGUID());
        ExtendedTextLine.Modify(true);
        ExtText := ExtendedTextLine.Text;
    end;

    local procedure UpdateRoundingPrecisonForItem(var Item: Record Item)
    var
        ItemUnitOfMeasure: Record "Item Unit of Measure";
    begin
        ItemUnitOfMeasure.SetRange("Item No.", Item."No.");
        ItemUnitOfMeasure.SetRange(Code, Item."Base Unit of Measure");
        if ItemUnitOfMeasure.FindSet() then
            repeat
                ItemUnitOfMeasure."Qty. Rounding Precision" := 1;
                ItemUnitOfMeasure.Modify();
            until ItemUnitOfMeasure.Next() = 0;
    end;

    [ModalPageHandler]
    procedure InvokeGenerateAndNoItemFound(var SalesLineAISuggestions: TestPage "Sales Line AI Suggestions")
    begin
        SalesLineAISuggestions.SearchQueryTxt.SetValue(LibraryVariableStorage.DequeueText());
        SalesLineAISuggestions.Generate.Invoke();
        Assert.IsFalse(SalesLineAISuggestions.SalesLinesSub.First(), 'No item should be found for the given input');
        SalesLineAISuggestions.OK.Invoke();
    end;

    [ModalPageHandler]
    procedure InvokeGenerateAndCheckItemsFound(var SalesLineAISuggestions: TestPage "Sales Line AI Suggestions")
    var
        ItemCount: Integer;
        quantityInSalesLineSub: Decimal;
        i: Integer;
    begin
        // Description for this queue:
        //[{User Input},{Expected Generated Number(shown in page)},{first item's description},{first item's quantity}, {second item's description}, {second item's quantity}...{last item's description}, {last item's quantity]
        // Example: ['I need all items from previous sales order 10000', '3', 'red bike', '2', 'blue bike','1', 'green bike', '1']
        // Create a new sales order for the new customer
        Commit();
        SalesLineAISuggestions.SearchQueryTxt.SetValue(LibraryVariableStorage.DequeueText());
        ItemCount := LibraryVariableStorage.DequeueInteger();
        SalesLineAISuggestions.Generate.Invoke();
        SalesLineAISuggestions.SalesLinesSub.First();
        for i := 1 to ItemCount do begin
            Assert.AreEqual(LibraryVariableStorage.DequeueText(), SalesLineAISuggestions.SalesLinesSub.Description.Value(), DescriptionIsIncorrectErr);
            Evaluate(quantityInSalesLineSub, SalesLineAISuggestions.SalesLinesSub.Quantity.Value());
            Assert.AreEqual(LibraryVariableStorage.DequeueDecimal(), quantityInSalesLineSub, QuantityIsIncorrectErr);
            SalesLineAISuggestions.SalesLinesSub.Next();
        end;
        SalesLineAISuggestions.OK.Invoke();
    end;

    [SendNotificationHandler]
    procedure SendNotificationHandler(var TheNotification: Notification): Boolean
    begin
        Assert.AreEqual(LibraryVariableStorage.DequeueText(), TheNotification.Message, 'Notification message is incorrect');
    end;
}