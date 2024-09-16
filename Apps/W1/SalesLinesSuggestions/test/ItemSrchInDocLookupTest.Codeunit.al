namespace Microsoft.Sales.Document.Test;

using Microsoft.Inventory.Item;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Document;
using System.TestLibraries.Utilities;

codeunit 139787 "Item Srch. In Doc. Lookup Test"
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
        TestUtility: Codeunit "SLS Test Utility";
        LibrarySales: Codeunit "Library - Sales";
        IsInitialized: Boolean;

        NeedSpecificItemFromSpecifiedSalesOrderLbl: Label 'I need %1 from sales order %2', Comment = '%1 = item description, %2 = Label for document number';
        NeedTwoItemsFromSpecifiedSalesOrderLbl: Label 'I need %1 and %2 from sales order %3', Comment = '%1,%2 = item description, %3 = Label for document number';
        DescriptionIsIncorrectErr: Label 'Description is incorrect!';
        VariantIsIncorrectErr: Label 'Variant is incorrect!';
        QuantityIsIncorrectErr: Label 'Quantity is incorrect!';

    [Test]
    [HandlerFunctions('CheckGenerateFromSalesOrder')]
    procedure TestCopyOneOfThreeLinesFromSalesOrder()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        Item: Record Item;
        Item1: Record Item;
        Item2: Record Item;
        Item3: Record Item;
        SalesLineAISuggestions: Page "Sales Line AI Suggestions";
    begin
        // [FEATURE] [Sales Line with AI] [Document Lookup] [Item Search] [Sales Order]
        // [SCENARIO] Copy only the specified line from a document.
        Initialize();
        LibrarySales.CreateCustomer(Customer);

        // [GIVEN] Create a new sales order for the new customer
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");

        // [GIVEN] Find 3 items for the test
        Assert.IsTrue(Item.Count >= 3, 'There are not enough items in the system to run the test');
        Item.FindSet();
        Item1 := Item;
        Item.Next();
        Item2 := Item;
        Item.Next();
        Item3 := Item;

        // [GIVEN] Add 3 lines to the new sales order
        LibrarySales.CreateSimpleItemSalesLine(SalesLine, SalesHeader, "Sales Line Type"::Item);
        SalesLine.Validate("No.", Item1."No.");
        SalesLine.Validate(Quantity, 5);
        SalesLine.Modify(true);

        LibrarySales.CreateSimpleItemSalesLine(SalesLine, SalesHeader, "Sales Line Type"::Item);
        SalesLine.Validate("No.", Item2."No.");
        SalesLine.Validate(Quantity, 5);
        SalesLine.Modify(true);

        LibrarySales.CreateSimpleItemSalesLine(SalesLine, SalesHeader, "Sales Line Type"::Item);
        SalesLine.Validate("No.", Item3."No.");
        SalesLine.Validate(Quantity, 5);
        SalesLine.Modify(true);

        // [GIVEN] Generate prompt with Item name and Document No.
        LibraryVariableStorage.Enqueue(StrSubstNo(NeedSpecificItemFromSpecifiedSalesOrderLbl, Item1.Description, SalesHeader."No."));
        LibraryVariableStorage.Enqueue('1'); // Number of lines to copy
        LibraryVariableStorage.Enqueue(Item1.Description); // Item to look for
        LibraryVariableStorage.Enqueue(''); // Variant Code
        LibraryVariableStorage.Enqueue('5'); // Same quantity as the document is copied

        // [WHEN] Run Sales Line AI Suggestions Page to generate suggestions lines
        // [THEN] Check that correct lines are generated in 'CheckGenerateFromSalesOrder' handler function
        CreateNewSalesHeaderAndRunSalesLineAISuggestionsPage(SalesHeader, SalesLineAISuggestions, Customer."No.", SalesHeader."Document Type"::Order);

        // [THEN] Check the correct sales lines are inserted
        LibraryVariableStorage.Enqueue(Item1.Description);
        LibraryVariableStorage.Enqueue('');
        LibraryVariableStorage.Enqueue('5'); // Same quantity as the document is copied
        CheckSalesLineContent(SalesLine, SalesHeader."No.");
    end;

    [Test]
    [HandlerFunctions('CheckGenerateFromSalesOrder')]
    procedure TestNoLinesAreCopiedWhenNoMatchForItemOnLinesFromSalesOrder()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        Item: Record Item;
        Item1: Record Item;
        Item2: Record Item;
        Item3: Record Item;
        Item4: Record Item;
        SalesLineAISuggestions: Page "Sales Line AI Suggestions";
    begin
        // [FEATURE] [Sales Line with AI] [Document Lookup] [Item Search] [Sales Order]
        // [SCENARIO] Copy only the specified line from a document.
        Initialize();
        LibrarySales.CreateCustomer(Customer);

        // [GIVEN] Create a new sales order for the new customer
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");

        // [GIVEN] Find 3 items for the test
        Assert.IsTrue(Item.Count >= 4, 'There are not enough items in the system to run the test');
        Item.FindSet();
        Item1 := Item;
        Item.Next();
        Item2 := Item;
        Item.Next();
        Item3 := Item;
        Item.Next();
        Item4 := Item;

        // [GIVEN] Add 3 lines to the new sales order
        LibrarySales.CreateSimpleItemSalesLine(SalesLine, SalesHeader, "Sales Line Type"::Item);
        SalesLine.Validate("No.", Item1."No.");
        SalesLine.Validate(Quantity, 5);
        SalesLine.Modify(true);

        LibrarySales.CreateSimpleItemSalesLine(SalesLine, SalesHeader, "Sales Line Type"::Item);
        SalesLine.Validate("No.", Item2."No.");
        SalesLine.Validate(Quantity, 5);
        SalesLine.Modify(true);

        LibrarySales.CreateSimpleItemSalesLine(SalesLine, SalesHeader, "Sales Line Type"::Item);
        SalesLine.Validate("No.", Item3."No.");
        SalesLine.Validate(Quantity, 5);
        SalesLine.Modify(true);

        // [GIVEN] Generate prompt with Item name and Document No.
        LibraryVariableStorage.Enqueue(StrSubstNo(NeedSpecificItemFromSpecifiedSalesOrderLbl, Item4.Description, SalesHeader."No."));
        LibraryVariableStorage.Enqueue('0'); // Number of lines to copy

        // [WHEN] Run Sales Line AI Suggestions Page to generate suggestions lines
        // [THEN] Check that correct lines are generated in 'CheckGenerateFromSalesOrder' handler function
        CreateNewSalesHeaderAndRunSalesLineAISuggestionsPage(SalesHeader, SalesLineAISuggestions, Customer."No.", SalesHeader."Document Type"::Order);

        // [THEN] Check the correct sales lines are inserted
        CheckEmptySalesLineContent(SalesLine, SalesHeader."No.");
    end;

    [Test]
    [HandlerFunctions('CheckGenerateFromSalesOrder')]
    procedure TestCopyAllLinesFromSalesOrderByDocNo()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesLineAISuggestions: Page "Sales Line AI Suggestions";
        ItemDescriptions: array[3] of Text[100];
    begin
        // [FEATURE] [Sales Line with AI] [Document Lookup] [Sales Order]
        // [SCENARIO] User input 'I want all the products from sales order 10000' in current customer's sales order. System will find the order and copy all the lines to the current sales order.
        Initialize();
        LibrarySales.CreateCustomer(Customer);
        // [GIVEN] Create a new sales order for the new customer
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");
        // [GIVEN] Create 3 lines with item description and add it to the new sales order
        Create3SalesLinesWithItemDescription(SalesHeader, SalesLine, ItemDescriptions);
        LibraryVariableStorage.Enqueue(StrSubstNo(NeedSpecificItemFromSpecifiedSalesOrderLbl, 'all products', SalesHeader."No."));
        LibraryVariableStorage.Enqueue('3');
        Enqueue3SalesLineWithItemDescription(ItemDescriptions);
        // [WHEN] Create a new sales order for this customer and run Sales Line AI Suggestions Page to generate suggestions lines
        // [THEN] Check that correct lines are generated in 'CheckGenerateFromSalesOrder' handler function
        CreateNewSalesHeaderAndRunSalesLineAISuggestionsPage(SalesHeader, SalesLineAISuggestions, Customer."No.", SalesHeader."Document Type"::Order);
        // [THEN] Check all the 3 lines are inserted
        Enqueue3SalesLineWithItemDescription(ItemDescriptions);
        CheckSalesLineContent(SalesLine, SalesHeader."No.");
    end;

    [Test]
    [HandlerFunctions('CheckGenerateFromSalesOrder')]
    procedure TestMultipleLinesAreCopiedFromSalesOrder()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        Item: Record Item;
        Item1: Record Item;
        Item2: Record Item;
        Item3: Record Item;
        SalesLineAISuggestions: Page "Sales Line AI Suggestions";
        ItemDescriptions: array[2] of Text[100];
    begin
        // [FEATURE] [Sales Line with AI] [Document Lookup] [Item Search] [Sales Order]
        // [SCENARIO] Copy lines for multiple items from the specified document.
        Initialize();
        LibrarySales.CreateCustomer(Customer);

        // [GIVEN] Create a new sales order for the new customer
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");

        // [GIVEN] Find 3 items for the test
        Assert.IsTrue(Item.Count >= 3, 'There are not enough items in the system to run the test');
        Item.FindSet();
        Item1 := Item;
        Item.Next();
        Item2 := Item;
        Item.Next();
        Item3 := Item;

        // [GIVEN] Add 3 lines to the new sales order
        LibrarySales.CreateSimpleItemSalesLine(SalesLine, SalesHeader, "Sales Line Type"::Item);
        SalesLine.Validate("No.", Item1."No.");
        SalesLine.Validate(Quantity, 1);
        SalesLine.Modify(true);

        LibrarySales.CreateSimpleItemSalesLine(SalesLine, SalesHeader, "Sales Line Type"::Item);
        SalesLine.Validate("No.", Item2."No.");
        SalesLine.Validate(Quantity, 1);
        SalesLine.Modify(true);

        LibrarySales.CreateSimpleItemSalesLine(SalesLine, SalesHeader, "Sales Line Type"::Item);
        SalesLine.Validate("No.", Item3."No.");
        SalesLine.Validate(Quantity, 1);
        SalesLine.Modify(true);

        // [GIVEN] Generate prompt with Item name and Document No.
        LibraryVariableStorage.Enqueue(StrSubstNo(NeedTwoItemsFromSpecifiedSalesOrderLbl, Item1.Description, Item2.Description, SalesHeader."No."));
        LibraryVariableStorage.Enqueue('2'); // Number of lines to copy
        ItemDescriptions[1] := Item1.Description;
        ItemDescriptions[2] := Item2.Description;
        Enqueue2SalesLineWithItemDescription(ItemDescriptions);

        // [WHEN] Run Sales Line AI Suggestions Page to generate suggestions lines
        // [THEN] Check that correct lines are generated in 'CheckGenerateFromSalesOrder' handler function
        CreateNewSalesHeaderAndRunSalesLineAISuggestionsPage(SalesHeader, SalesLineAISuggestions, Customer."No.", SalesHeader."Document Type"::Order);

        // [THEN] Check the correct sales lines are inserted
        Enqueue2SalesLineWithItemDescription(ItemDescriptions);
        CheckSalesLineContent(SalesLine, SalesHeader."No.");
    end;

    local procedure Initialize()
    begin
        LibraryVariableStorage.Clear();

        if IsInitialized then
            exit;

        TestUtility.RegisterCopilotCapability();

        IsInitialized := true;
    end;

    // Help functions
    local procedure Create3SalesLinesWithItemDescription(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; var ItemDescriptions: array[3] of Text[100])
    var
        Item: Record Item;
    begin
        Item.FindSet();
        ItemDescriptions[1] := Item.Description;

        LibrarySales.CreateSimpleItemSalesLine(SalesLine, SalesHeader, "Sales Line Type"::Item);
        SalesLine.Validate("No.", Item."No.");
        SalesLine.Validate(Quantity, 5);
        SalesLine.Modify(true);

        Item.Next();
        ItemDescriptions[2] := Item.Description;

        LibrarySales.CreateSimpleItemSalesLine(SalesLine, SalesHeader, "Sales Line Type"::Item);
        SalesLine.Validate("No.", Item."No.");
        SalesLine.Validate(Quantity, 3);
        SalesLine.Modify(true);

        Item.Next();
        ItemDescriptions[3] := Item.Description;

        LibrarySales.CreateSimpleItemSalesLine(SalesLine, SalesHeader, "Sales Line Type"::Item);
        SalesLine.Validate("No.", Item."No.");
        SalesLine.Validate(Quantity, 2);
        SalesLine.Modify(true);

        LibraryVariableStorage.AssertEmpty();
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


    local procedure CheckEmptySalesLineContent(SalesLine: Record "Sales Line"; DocumentNo: Text)
    begin
        SalesLine.Reset();
        SalesLine.SetRange("Document No.", DocumentNo);
        SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
        Assert.IsFalse(SalesLine.FindFirst(), 'No sales line should be generated');
    end;

    local procedure Enqueue2SalesLineWithItemDescription(ItemDescriptions: array[2] of Text[100])
    begin
        LibraryVariableStorage.Enqueue(ItemDescriptions[1]);
        LibraryVariableStorage.Enqueue('');
        LibraryVariableStorage.Enqueue('1');
        LibraryVariableStorage.Enqueue(ItemDescriptions[2]);
        LibraryVariableStorage.Enqueue('');
        LibraryVariableStorage.Enqueue('1');
    end;

    local procedure Enqueue3SalesLineWithItemDescription(ItemDescriptions: array[3] of Text[100])
    begin
        LibraryVariableStorage.Enqueue(ItemDescriptions[1]);
        LibraryVariableStorage.Enqueue('');
        LibraryVariableStorage.Enqueue('5');
        LibraryVariableStorage.Enqueue(ItemDescriptions[2]);
        LibraryVariableStorage.Enqueue('');
        LibraryVariableStorage.Enqueue('3');
        LibraryVariableStorage.Enqueue(ItemDescriptions[3]);
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
}