codeunit 139736 "APIV1 - Sales Quote Lines E2E"
{
    // version Test,ERM,W1,All

    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Graph] [Sales] [Quote]
    end;

    var
        Assert: Codeunit "Assert";
        SalesInvoiceAggregator: Codeunit "Sales Invoice Aggregator";
        APIV1SalesInvLinesE2E: Codeunit "APIV1 - Sales Inv. Lines E2E";
        LibraryGraphMgt: Codeunit "Library - Graph Mgt";
        LibraryGraphDocumentTools: Codeunit "Library - Graph Document Tools";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryRandom: Codeunit "Library - Random";
        LibrarySales: Codeunit "Library - Sales";
        LibrarySmallBusiness: Codeunit "Library - Small Business";
        LibraryApplicationArea: Codeunit "Library - Application Area";
        IsInitialized: Boolean;
        QuoteServiceNameTxt: Label 'salesQuotes';
        QuoteServiceLinesNameTxt: Label 'salesQuoteLines';
        LineTypeFieldNameTxt: Label 'lineType';

    local procedure Initialize()
    begin
        IF IsInitialized THEN
            EXIT;

        LibrarySales.SetStockoutWarning(FALSE);

        LibraryApplicationArea.EnableFoundationSetup();

        IsInitialized := TRUE;
        COMMIT();
    end;

    [Test]
    procedure TestGetQuoteLineDirectly()
    var
        SalesLine: Record "Sales Line";
        SalesHeader: Record "Sales Header";
        ResponseText: Text;
        TargetURL: Text;
        QuoteId: Text;
        LineNo: Integer;
        IdValue: Text;
        SequenceValue: Text;
    begin
        // [SCENARIO] Call GET on the Line of a quote
        // [GIVEN] A quote with a line.
        Initialize();
        QuoteId := CreateSalesQuoteWithLines(SalesHeader);

        SalesLine.SETRANGE("Document Type", SalesHeader."Document Type"::Quote);
        SalesLine.SETRANGE("Document No.", SalesHeader."No.");
        SalesLine.FINDFIRST();
        LineNo := SalesLine."Line No.";

        // [WHEN] we GET all the lines with the quote ID from the web service
        TargetURL := APIV1SalesInvLinesE2E.GetLinesURL(SalesInvoiceAggregator.GetIdFromDocumentIdAndSequence(QuoteId, LineNo), PAGE::"APIV1 - Sales Quotes", QuoteServiceNameTxt, QuoteServiceLinesNameTxt);
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] the line returned should be valid (numbers and integration id)
        Assert.AreNotEqual('', ResponseText, 'Response JSON should not be blank');
        LibraryGraphMgt.VerifyIDFieldInJson(ResponseText, 'documentId');
        LibraryGraphMgt.GetPropertyValueFromJSON(ResponseText, 'id', IdValue);
        Assert.AreEqual(IdValue, SalesInvoiceAggregator.GetIdFromDocumentIdAndSequence(QuoteId, LineNo), 'The id value is wrong.');
        LibraryGraphMgt.GetPropertyValueFromJSON(ResponseText, 'sequence', SequenceValue);
        Assert.AreEqual(SequenceValue, FORMAT(LineNo), 'The sequence value is wrong.');
    end;

    [Test]
    procedure TestGetQuoteLines()
    var
        SalesLine: Record "Sales Line";
        SalesHeader: Record "Sales Header";
        ResponseText: Text;
        TargetURL: Text;
        QuoteId: Text;
        LineNo1: Text;
        LineNo2: Text;
    begin
        // [SCENARIO] Call GET on the Lines of a quote
        // [GIVEN] A quote with lines.
        Initialize();
        QuoteId := CreateSalesQuoteWithLines(SalesHeader);

        SalesLine.SETRANGE("Document No.", SalesHeader."No.");
        SalesLine.SETRANGE("Document Type", SalesHeader."Document Type"::Quote);
        SalesLine.FINDFIRST();
        LineNo1 := FORMAT(SalesLine."Line No.");
        SalesLine.FINDLAST();
        LineNo2 := FORMAT(SalesLine."Line No.");

        // [WHEN] we GET all the lines with the  quote ID from the web service
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            QuoteId,
            PAGE::"APIV1 - Sales Quotes",
            QuoteServiceNameTxt,
            QuoteServiceLinesNameTxt);
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] the lines returned should be valid (numbers and integration ids)
        VerifyQuoteLines(ResponseText, LineNo1, LineNo2);
    end;

    [Test]
    procedure TestGetQuoteLinesDirectlyWithDocumentIdFilter()
    var
        SalesLine: Record "Sales Line";
        SalesHeader: Record "Sales Header";
        ResponseText: Text;
        TargetURL: Text;
        QuoteId: Text;
        LineNo1: Text;
        LineNo2: Text;
    begin
        // [SCENARIO] Call GET on the Lines of a quote
        // [GIVEN] a quote with lines.
        Initialize();
        QuoteId := CreateSalesQuoteWithLines(SalesHeader);

        SalesLine.SETRANGE("Document Type", SalesHeader."Document Type"::Quote);
        SalesLine.SETRANGE("Document No.", SalesHeader."No.");
        SalesLine.FINDFIRST();
        LineNo1 := FORMAT(SalesLine."Line No.");
        SalesLine.FINDLAST();
        LineNo2 := FORMAT(SalesLine."Line No.");

        // [WHEN] we GET all the lines with the quote ID from the web service
        TargetURL := APIV1SalesInvLinesE2E.GetLinesURLWithDocumentIdFilter(QuoteId, PAGE::"APIV1 - Sales Quotes", QuoteServiceNameTxt, QuoteServiceLinesNameTxt);
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] the lines returned should be valid (numbers and integration ids)
        VerifyQuoteLines(ResponseText, LineNo1, LineNo2);
    end;

    [Test]
    procedure TestPostQuoteLines()
    var
        Item: Record "Item";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ResponseText: Text;
        TargetURL: Text;
        QuoteLineJSON: Text;
        LineNoFromJSON: Text;
        QuoteId: Text;
        LineNo: Integer;
        SalesLineExists: Boolean;
    begin
        // [SCENARIO] POST a new line to a quote
        // [GIVEN] An existing  quote and a valid JSON describing the new quote line
        Initialize();
        QuoteId := CreateSalesQuoteWithLines(SalesHeader);
        LibraryInventory.CreateItem(Item);

        QuoteLineJSON := CreateQuoteLineJSON(Item.SystemId, LibraryRandom.RandIntInRange(1, 100));
        COMMIT();

        // [WHEN] we POST the JSON to the web service
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            QuoteId,
            PAGE::"APIV1 - Sales Quotes",
            QuoteServiceNameTxt,
            QuoteServiceLinesNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, QuoteLineJSON, ResponseText);

        // [THEN] the response text should contain the quote ID and the change should exist in the database
        Assert.AreNotEqual('', ResponseText, 'response JSON should not be blank');
        Assert.IsTrue(
          LibraryGraphMgt.GetObjectIDFromJSON(ResponseText, 'sequence', LineNoFromJSON), 'Could not find sequence');

        EVALUATE(LineNo, LineNoFromJSON);
        SalesLineExists := FindSalesLine(SalesLine, LineNo, SalesHeader."No.");
        Assert.IsTrue(SalesLineExists, 'The quote line should exist');
    end;

    [Test]
    procedure TestModifyQuoteLines()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ResponseText: Text;
        TargetURL: Text;
        QuoteLineJSON: Text;
        LineNo: Integer;
        QuoteId: Text;
        SalesQuantity: Integer;
        SalesLineExists: Boolean;
    begin
        // [SCENARIO] PATCH a line of a quote
        // [GIVEN] a quote with lines and a valid JSON describing the fields that we want to change
        Initialize();
        QuoteId := CreateSalesQuoteWithLines(SalesHeader);
        Assert.AreNotEqual('', QuoteId, 'ID should not be empty');
        SalesLine.SETRANGE("Document No.", SalesHeader."No.");
        SalesLine.SETRANGE("Document Type", SalesHeader."Document Type"::Quote);
        SalesLine.FINDFIRST();
        LineNo := SalesLine."Line No.";

        SalesQuantity := 4;
        QuoteLineJSON := LibraryGraphMgt.AddComplexTypetoJSON('{}', 'quantity', FORMAT(SalesQuantity));

        // [WHEN] we PATCH the line
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            QuoteId,
            PAGE::"APIV1 - Sales Quotes",
            QuoteServiceNameTxt,
            APIV1SalesInvLinesE2E.GetLineSubURL(QuoteId, LineNo, QuoteServiceLinesNameTxt));
        LibraryGraphMgt.PatchToWebService(TargetURL, QuoteLineJSON, ResponseText);

        // [THEN] the line should be changed in the table and the response JSON text should contain our changed field
        Assert.AreNotEqual('', ResponseText, 'Response JSON should not be blank');

        SalesLine.RESET();
        SalesLineExists := FindSalesLine(SalesLine, LineNo, SalesHeader."No.");
        Assert.IsTrue(SalesLineExists, 'The  quote line should exist after modification');
        Assert.AreEqual(SalesLine.Quantity, SalesQuantity, 'The patch of Sales line quantity was unsuccessful');
    end;

    [Test]
    procedure TestModifyQuoteLineFailsOnSequenceIdOrDocumentIdChange()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ResponseText: Text;
        TargetURL: Text;
        QuoteLineJSON: Array[3] of Text;
        LineNo: Integer;
        QuoteId: Text;
        NewSequence: Integer;
    begin
        // [SCENARIO] PATCH a line of a quote will fail if sequence is modified
        // [GIVEN] A quote with lines and a valid JSON describing the fields that we want to change
        Initialize();
        QuoteId := CreateSalesQuoteWithLines(SalesHeader);
        Assert.AreNotEqual('', QuoteId, 'ID should not be empty');
        SalesLine.SETRANGE("Document Type", SalesHeader."Document Type"::Quote);
        SalesLine.SETRANGE("Document No.", SalesHeader."No.");
        SalesLine.FINDFIRST();
        LineNo := SalesLine."Line No.";

        NewSequence := SalesLine."Line No." + 1;
        QuoteLineJSON[1] := LibraryGraphMgt.AddPropertytoJSON('', 'sequence', NewSequence);
        QuoteLineJSON[2] := LibraryGraphMgt.AddPropertytoJSON('', 'documentId', LibraryGraphMgt.StripBrackets(CreateGuid()));
        QuoteLineJSON[3] := LibraryGraphMgt.AddPropertytoJSON('', 'id', SalesInvoiceAggregator.GetIdFromDocumentIdAndSequence(CreateGuid(), NewSequence));

        // [WHEN] we PATCH the line
        // [THEN] the request will fail
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            QuoteId,
            PAGE::"APIV1 - Sales Quotes",
            QuoteServiceNameTxt,
            APIV1SalesInvLinesE2E.GetLineSubURL(QuoteId, LineNo, QuoteServiceLinesNameTxt));
        ASSERTERROR LibraryGraphMgt.PatchToWebService(TargetURL, QuoteLineJSON[1], ResponseText);

        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            QuoteId,
            PAGE::"APIV1 - Sales Quotes",
            QuoteServiceNameTxt,
            APIV1SalesInvLinesE2E.GetLineSubURL(QuoteId, LineNo, QuoteServiceLinesNameTxt));
        ASSERTERROR LibraryGraphMgt.PatchToWebService(TargetURL, QuoteLineJSON[2], ResponseText);

        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            QuoteId,
            PAGE::"APIV1 - Sales Quotes",
            QuoteServiceNameTxt,
            APIV1SalesInvLinesE2E.GetLineSubURL(QuoteId, LineNo, QuoteServiceLinesNameTxt));
        ASSERTERROR LibraryGraphMgt.PatchToWebService(TargetURL, QuoteLineJSON[3], ResponseText);
    end;

    [Test]
    procedure TestDeleteQuoteLine()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ResponseText: Text;
        TargetURL: Text;
        QuoteId: Text;
        LineNo: Integer;
        SalesLineExists: Boolean;
    begin
        // [SCENARIO] DELETE a line from a quote
        // [GIVEN] a quote with lines
        Initialize();
        QuoteId := CreateSalesQuoteWithLines(SalesHeader);

        SalesLine.SETRANGE("Document No.", SalesHeader."No.");
        SalesLine.SETRANGE("Document Type", SalesHeader."Document Type"::Quote);
        SalesLine.FINDFIRST();
        LineNo := SalesLine."Line No.";

        COMMIT();

        // [WHEN] we DELETE the first line of that quote
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            QuoteId,
            PAGE::"APIV1 - Sales Quotes",
            QuoteServiceNameTxt,
            APIV1SalesInvLinesE2E.GetLineSubURL(QuoteId, LineNo, QuoteServiceLinesNameTxt));
        LibraryGraphMgt.DeleteFromWebService(TargetURL, '', ResponseText);

        // [THEN] the line should no longer exist in the database
        SalesLine.RESET();
        SalesLineExists := FindSalesLine(SalesLine, LineNo, SalesHeader."No.");
        Assert.IsFalse(SalesLineExists, 'The quote line should not exist');
    end;

    [Test]
    procedure TestInsertingLineUpdatesQuoteDiscountPct()
    var
        SalesHeader: Record "Sales Header";
        Customer: Record "Customer";
        Item: Record "Item";
        TargetURL: Text;
        QuoteLineJSON: Text;
        ResponseText: Text;
        MinAmount: Decimal;
        DiscountPct: Decimal;
    begin
        // [FEATURE] [Discount]
        // [SCENARIO] Creating a line through API should update Discount Pct
        // [GIVEN] A quote for customer with discount pct
        Initialize();
        CreateQuoteWithTwoLines(SalesHeader, Customer, Item);
        SalesHeader.CALCFIELDS(Amount);
        MinAmount := SalesHeader.Amount + Item."Unit Price" / 2;
        DiscountPct := LibraryRandom.RandDecInDecimalRange(1, 90, 2);
        LibrarySmallBusiness.SetInvoiceDiscountToCustomer(Customer, DiscountPct, MinAmount, SalesHeader."Currency Code");
        QuoteLineJSON := CreateQuoteLineJSON(Item.SystemId, LibraryRandom.RandIntInRange(1, 100));
        COMMIT();

        // [WHEN] We create a line through API
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            SalesHeader.SystemId,
            PAGE::"APIV1 - Sales Quotes",
            QuoteServiceNameTxt,
            QuoteServiceLinesNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, QuoteLineJSON, ResponseText);

        // [THEN] quote discount is applied
        Assert.AreNotEqual('', ResponseText, 'Response JSON should not be blank');
        LibraryGraphMgt.VerifyIDFieldInJson(ResponseText, 'itemId');
        VerifyTotals(SalesHeader, DiscountPct, SalesHeader."Invoice Discount Calculation"::"%");
    end;

    [Test]
    procedure TestModifyingLineUpdatesQuoteDiscountPct()
    var
        SalesHeader: Record "Sales Header";
        Customer: Record "Customer";
        Item: Record "Item";
        SalesLine: Record "Sales Line";
        TargetURL: Text;
        QuoteLineJSON: Text;
        ResponseText: Text;
        MinAmount: Decimal;
        DiscountPct: Decimal;
        SalesQuantity: Integer;
    begin
        // [FEATURE] [Discount]
        // [SCENARIO] Modifying a line through API should update Discount Pct
        // [GIVEN] A quote for customer with discount pct
        Initialize();
        CreateQuoteWithTwoLines(SalesHeader, Customer, Item);
        SalesHeader.CALCFIELDS(Amount);
        MinAmount := SalesHeader.Amount + Item."Unit Price" / 2;
        DiscountPct := LibraryRandom.RandDecInDecimalRange(1, 90, 2);
        LibrarySmallBusiness.SetInvoiceDiscountToCustomer(Customer, DiscountPct, MinAmount, SalesHeader."Currency Code");
        QuoteLineJSON := CreateQuoteLineJSON(Item.SystemId, LibraryRandom.RandIntInRange(1, 100));
        FindFirstSalesLine(SalesHeader, SalesLine);
        SalesQuantity := SalesLine.Quantity * 2;

        COMMIT();

        QuoteLineJSON := LibraryGraphMgt.AddComplexTypetoJSON('{}', 'quantity', FORMAT(SalesQuantity));

        // [WHEN] we PATCH the line
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            SalesHeader.SystemId,
            PAGE::"APIV1 - Sales Quotes",
            QuoteServiceNameTxt,
            APIV1SalesInvLinesE2E.GetLineSubURL(SalesHeader.SystemId, SalesLine."Line No.", QuoteServiceLinesNameTxt));
        LibraryGraphMgt.PatchToWebService(TargetURL, QuoteLineJSON, ResponseText);

        // [THEN] discount is applied
        Assert.AreNotEqual('', ResponseText, 'Response JSON should not be blank');
        LibraryGraphMgt.VerifyIDFieldInJson(ResponseText, 'itemId');
        VerifyTotals(SalesHeader, DiscountPct, SalesHeader."Invoice Discount Calculation"::"%");
    end;

    [Test]
    procedure TestDeletingLineMovesQuoteDiscountPct()
    var
        SalesHeader: Record "Sales Header";
        Customer: Record "Customer";
        Item: Record "Item";
        SalesLine: Record "Sales Line";
        TargetURL: Text;
        ResponseText: Text;
        MinAmount1: Decimal;
        DiscountPct1: Decimal;
        MinAmount2: Decimal;
        DiscountPct2: Decimal;
    begin
        // [FEATURE] [Discount]
        // [SCENARIO] Deleting a line through API should update Discount Pct
        // [GIVEN] A quote for customer with quote discount pct
        Initialize();
        CreateQuoteWithTwoLines(SalesHeader, Customer, Item);
        SalesHeader.CALCFIELDS(Amount);
        FindFirstSalesLine(SalesHeader, SalesLine);

        MinAmount1 := SalesHeader.Amount - 2 * SalesLine."Line Amount";
        DiscountPct1 := LibraryRandom.RandDecInDecimalRange(1, 20, 2);
        LibrarySmallBusiness.SetInvoiceDiscountToCustomer(Customer, DiscountPct1, MinAmount1, SalesHeader."Currency Code");

        MinAmount2 := SalesHeader.Amount - SalesLine."Line Amount" / 2;
        DiscountPct2 := LibraryRandom.RandDecInDecimalRange(30, 50, 2);
        LibrarySmallBusiness.SetInvoiceDiscountToCustomer(Customer, DiscountPct2, MinAmount2, SalesHeader."Currency Code");

        CODEUNIT.RUN(CODEUNIT::"Sales - Calc Discount By Type", SalesLine);
        SalesHeader.FIND();
        Assert.AreEqual(SalesHeader."Invoice Discount Value", DiscountPct2, 'Discount Pct was not assigned');
        COMMIT();

        // [WHEN] we DELETE the line
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            SalesHeader.SystemId,
            PAGE::"APIV1 - Sales Quotes",
            QuoteServiceNameTxt,
            APIV1SalesInvLinesE2E.GetLineSubURL(SalesHeader.SystemId, SalesLine."Line No.", QuoteServiceLinesNameTxt));
        LibraryGraphMgt.DeleteFromWebService(TargetURL, '', ResponseText);

        // [THEN] Lower discount is applied
        VerifyTotals(SalesHeader, DiscountPct1, SalesHeader."Invoice Discount Calculation"::"%");
        RecallNotifications();
    end;

    [Test]
    procedure TestDeletingLineRemovesQuoteDiscountPct()
    var
        SalesHeader: Record "Sales Header";
        Customer: Record "Customer";
        Item: Record "Item";
        SalesLine: Record "Sales Line";
        TargetURL: Text;
        ResponseText: Text;
        MinAmount: Decimal;
        DiscountPct: Decimal;
    begin
        // [FEATURE] [Discount]
        // [SCENARIO] Deleting a line through API should update Discount Pct
        // [GIVEN] A quote for customer with discount pct
        Initialize();
        CreateQuoteWithTwoLines(SalesHeader, Customer, Item);
        SalesHeader.CALCFIELDS(Amount);
        FindFirstSalesLine(SalesHeader, SalesLine);

        MinAmount := SalesHeader.Amount - SalesLine."Line Amount" / 2;
        DiscountPct := LibraryRandom.RandDecInDecimalRange(30, 50, 2);
        LibrarySmallBusiness.SetInvoiceDiscountToCustomer(Customer, DiscountPct, MinAmount, SalesHeader."Currency Code");

        CODEUNIT.RUN(CODEUNIT::"Sales - Calc Discount By Type", SalesLine);
        SalesHeader.FIND();
        Assert.AreEqual(SalesHeader."Invoice Discount Value", DiscountPct, 'Discount Pct was not assigned');
        COMMIT();

        // [WHEN] we DELETE the line
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            SalesHeader.SystemId,
            PAGE::"APIV1 - Sales Quotes",
            QuoteServiceNameTxt,
            APIV1SalesInvLinesE2E.GetLineSubURL(SalesHeader.SystemId, SalesLine."Line No.", QuoteServiceLinesNameTxt));
        LibraryGraphMgt.DeleteFromWebService(TargetURL, '', ResponseText);

        // [THEN] Lower discount is applied
        VerifyTotals(SalesHeader, 0, SalesHeader."Invoice Discount Calculation"::"%");
        RecallNotifications();
    end;

    [Test]
    procedure TestInsertingLineKeepsQuoteDiscountAmt()
    var
        SalesHeader: Record "Sales Header";
        Item: Record "Item";
        TargetURL: Text;
        ResponseText: Text;
        QuoteLineJSON: Text;
        DiscountAmount: Decimal;
    begin
        // [FEATURE] [Discount]
        // [SCENARIO] Adding a quote through API will keep Discount Amount
        // [GIVEN] A quote for customer with discount amount
        Initialize();
        SetupAmountDiscountTest(SalesHeader, Item, DiscountAmount);
        QuoteLineJSON := CreateQuoteLineJSON(Item.SystemId, LibraryRandom.RandIntInRange(1, 100));

        COMMIT();

        // [WHEN] We create a line through API
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            SalesHeader.SystemId,
            PAGE::"APIV1 - Sales Quotes",
            QuoteServiceNameTxt,
            QuoteServiceLinesNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, QuoteLineJSON, ResponseText);

        // [THEN] Discount Amount is Kept
        VerifyTotals(SalesHeader, DiscountAmount, SalesHeader."Invoice Discount Calculation"::Amount);
        RecallNotifications();
    end;

    [Test]
    procedure TestModifyingLineKeepsQuoteDiscountAmt()
    var
        SalesHeader: Record "Sales Header";
        Item: Record "Item";
        SalesLine: Record "Sales Line";
        DiscountAmount: Decimal;
        TargetURL: Text;
        QuoteLineJSON: Text;
        ResponseText: Text;
        SalesQuantity: Integer;
    begin
        // [FEATURE] [Discount]
        // [SCENARIO] Modifying a line through API should keep existing Discount Amount
        // [GIVEN] A quote for customer with discount amt
        Initialize();
        SetupAmountDiscountTest(SalesHeader, Item, DiscountAmount);
        QuoteLineJSON := CreateQuoteLineJSON(Item.SystemId, LibraryRandom.RandIntInRange(1, 100));

        SalesQuantity := 0;
        QuoteLineJSON := LibraryGraphMgt.AddComplexTypetoJSON('{}', 'quantity', FORMAT(SalesQuantity));
        COMMIT();

        FindFirstSalesLine(SalesHeader, SalesLine);

        // [WHEN] we PATCH the line
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            SalesHeader.SystemId,
            PAGE::"APIV1 - Sales Quotes",
            QuoteServiceNameTxt,
            APIV1SalesInvLinesE2E.GetLineSubURL(SalesHeader.SystemId, SalesLine."Line No.", QuoteServiceLinesNameTxt));
        LibraryGraphMgt.PatchToWebService(TargetURL, QuoteLineJSON, ResponseText);

        // [THEN] discount is kept
        Assert.AreNotEqual('', ResponseText, 'Response JSON should not be blank');
        LibraryGraphMgt.VerifyIDFieldInJson(ResponseText, 'itemId');
        VerifyTotals(SalesHeader, DiscountAmount, SalesHeader."Invoice Discount Calculation"::Amount);
        RecallNotifications();
    end;

    [Test]
    procedure TestDeletingLineKeepsQuoteDiscountAmt()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        Item: Record "Item";
        DiscountAmount: Decimal;
        TargetURL: Text;
        ResponseText: Text;
    begin
        // [FEATURE] [Discount]
        // [SCENARIO] Deleting a line through API should update Discount Pct
        // [GIVEN] A quote for customer with discount pct
        Initialize();
        SetupAmountDiscountTest(SalesHeader, Item, DiscountAmount);
        COMMIT();

        FindFirstSalesLine(SalesHeader, SalesLine);

        // [WHEN] we DELETE the line
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            SalesHeader.SystemId,
            PAGE::"APIV1 - Sales Quotes",
            QuoteServiceNameTxt,
            APIV1SalesInvLinesE2E.GetLineSubURL(SalesHeader.SystemId, SalesLine."Line No.", QuoteServiceLinesNameTxt));
        LibraryGraphMgt.DeleteFromWebService(TargetURL, '', ResponseText);

        // [THEN] Lower discount is applied
        VerifyTotals(SalesHeader, DiscountAmount, SalesHeader."Invoice Discount Calculation"::Amount);
        RecallNotifications();
    end;

    [Test]
    procedure TestPostingBlankLineDefaultsToItemType()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TargetURL: Text;
        ResponseText: Text;
        QuoteLineJSON: Text;
    begin
        // [SCENARIO] Posting a line with description only will get a type item
        // [GIVEN] A post request with description only
        Initialize();
        CreateSalesQuoteWithLines(SalesHeader);

        COMMIT();

        QuoteLineJSON := '{"description":"test"}';

        // [WHEN] we just POST a blank line
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            SalesHeader.SystemId,
            PAGE::"APIV1 - Sales Quotes",
            QuoteServiceNameTxt,
            QuoteServiceLinesNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, QuoteLineJSON, ResponseText);

        // [THEN] Line of type Item is created
        FindFirstSalesLine(SalesHeader, SalesLine);
        SalesLine.FINDLAST();
        Assert.AreEqual('', SalesLine."No.", 'No should be blank');
        Assert.AreEqual(SalesLine.Type, SalesLine.Type::Item, 'Wrong type is set');

        VerifyIdsAreBlank(ResponseText);
    end;

    [Test]
    procedure TestPostingCommentLine()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TargetURL: Text;
        ResponseText: Text;
        QuoteLineJSON: Text;
    begin
        // [FEATURE] [Comment]
        // [SCENARIO] Posting a line with Type Comment and description will make a comment line
        // [GIVEN] A post request with type and description
        Initialize();
        CreateSalesQuoteWithLines(SalesHeader);

        QuoteLineJSON := '{"' + LineTypeFieldNameTxt + '":"Comment","description":"test"}';

        COMMIT();

        // [WHEN] we just POST a blank line
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            SalesHeader.SystemId,
            PAGE::"APIV1 - Sales Quotes",
            QuoteServiceNameTxt,
            QuoteServiceLinesNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, QuoteLineJSON, ResponseText);

        // [THEN] Line of type Item is created
        FindFirstSalesLine(SalesHeader, SalesLine);
        SalesLine.FINDLAST();
        Assert.AreEqual(SalesLine.Type, SalesLine.Type::" ", 'Wrong type is set');
        Assert.AreEqual('test', SalesLine.Description, 'Wrong description is set');

        LibraryGraphDocumentTools.VerifySalesObjectTxtDescription(SalesLine, ResponseText);
        VerifyIdsAreBlank(ResponseText);
    end;

    [Test]
    procedure TestPatchingTheTypeBlanksIds()
    var
        SalesHeader: Record "Sales Header";
        SalesInvoiceLineAggregate: Record "Sales Invoice Line Aggregate";
        SalesLine: Record "Sales Line";
        TargetURL: Text;
        ResponseText: Text;
        QuoteLineJSON: Text;
        QuoteId: Text;
        LineNo: Integer;
    begin
        // [SCENARIO] PATCH a Type on a line of a quote
        // [GIVEN] a quote with lines and a valid JSON describing the fields that we want to change
        Initialize();
        QuoteId := CreateSalesQuoteWithLines(SalesHeader);
        Assert.AreNotEqual('', QuoteId, 'ID should not be empty');
        FindFirstSalesLine(SalesHeader, SalesLine);
        LineNo := SalesLine."Line No.";

        QuoteLineJSON := STRSUBSTNO('{"%1":"%2"}', LineTypeFieldNameTxt, FORMAT(SalesInvoiceLineAggregate."API Type"::Account));

        // [WHEN] we PATCH the line
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            QuoteId,
            PAGE::"APIV1 - Sales Quotes",
            QuoteServiceNameTxt,
            APIV1SalesInvLinesE2E.GetLineSubURL(QuoteId, LineNo, QuoteServiceLinesNameTxt));
        LibraryGraphMgt.PatchToWebService(TargetURL, QuoteLineJSON, ResponseText);

        // [THEN] Line type is changed to Account
        FindFirstSalesLine(SalesHeader, SalesLine);
        Assert.AreEqual(SalesLine.Type::"G/L Account", SalesLine.Type, 'Type was not changed');
        Assert.AreEqual('', SalesLine."No.", 'No should be blank');

        VerifyIdsAreBlank(ResponseText);
    end;

    [Test]
    procedure TestPostQuoteLinesWithItemVariant()
    var
        Item: Record "Item";
        ItemVariant: Record "Item Variant";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ItemNo: Code[20];
        ItemVariantCode: Code[10];
        ResponseText: Text;
        TargetURL: Text;
        QuoteLineJSON: Text;
        LineNoFromJSON: Text;
        QuoteId: Text;
        LineNo: Integer;
    begin
        // [SCENARIO] POST a new line to a quote with item variant
        // [GIVEN] An existing  quote and a valid JSON describing the new quote line with item variant
        Initialize();
        QuoteId := CreateSalesQuoteWithLines(SalesHeader);
        ItemNo := LibraryInventory.CreateItem(Item);
        ItemVariantCode := LibraryInventory.CreateItemVariant(ItemVariant, ItemNo);
        Commit();

        // [WHEN] we POST the JSON to the web service
        QuoteLineJSON := CreateQuoteLineJSONWithItemVariantId(Item.SystemId, LibraryRandom.RandIntInRange(1, 100), ItemVariant.SystemId);
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            QuoteId,
            PAGE::"APIV1 - Sales Quotes",
            QuoteServiceNameTxt,
            QuoteServiceLinesNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, QuoteLineJSON, ResponseText);

        // [THEN] the response text should contain the quote ID and the change should exist in the database
        Assert.AreNotEqual('', ResponseText, 'response JSON should not be blank');
        Assert.IsTrue(
          LibraryGraphMgt.GetObjectIDFromJSON(ResponseText, 'sequence', LineNoFromJSON), 'Could not find sequence');

        Evaluate(LineNo, LineNoFromJSON);
        SalesLine.SETRANGE("Document No.", SalesHeader."No.");
        SalesLine.SETRANGE("Document Type", SalesHeader."Document Type"::Quote);
        SalesLine.SETRANGE("Line No.", LineNo);
        SalesLine.SetRange("Variant Code", ItemVariantCode);
        Assert.IsFalse(SalesLine.IsEmpty(), 'The quote line should exist');
    end;

    [Test]
    procedure TestPostQuoteLinesWithWrongItemVariant()
    var
        Item1: Record "Item";
        Item2: Record "Item";
        ItemVariant: Record "Item Variant";
        SalesHeader: Record "Sales Header";
        ItemNo2: Code[20];
        ResponseText: Text;
        TargetURL: Text;
        QuoteLineJSON: Text;
        QuoteId: Text;
    begin
        // [SCENARIO] POST a new line to a quote with wrong item variant
        // [GIVEN] An existing  quote and a valid JSON describing the new quote line with item variant
        Initialize();
        QuoteId := CreateSalesQuoteWithLines(SalesHeader);
        LibraryInventory.CreateItem(Item1);
        ItemNo2 := LibraryInventory.CreateItem(Item2);
        LibraryInventory.CreateItemVariant(ItemVariant, ItemNo2);
        Commit();

        // [WHEN] we POST the JSON to the web service
        QuoteLineJSON := CreateQuoteLineJSONWithItemVariantId(Item1.SystemId, LibraryRandom.RandIntInRange(1, 100), ItemVariant.SystemId);
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            QuoteId,
            PAGE::"APIV1 - Sales Quotes",
            QuoteServiceNameTxt,
            QuoteServiceLinesNameTxt);

        // [THEN] the request will fail
        asserterror LibraryGraphMgt.PostToWebService(TargetURL, QuoteLineJSON, ResponseText);
    end;

    [Normal]
    local procedure CreateQuoteLineJSON(ItemId: Guid; Quantity: Integer): Text
    var
        LineJSON: Text;
    begin
        LineJSON := LibraryGraphMgt.AddPropertytoJSON('', 'itemId', LibraryGraphMgt.StripBrackets(Format(ItemId)));
        LineJSON := LibraryGraphMgt.AddPropertytoJSON(LineJSON, 'quantity', Quantity);
        EXIT(LineJSON);
    end;

    local procedure CreateQuoteLineJSONWithItemVariantId(ItemId: Guid; Quantity: Integer; ItemVariantId: Guid): Text
    var
        LineJSON: Text;
    begin
        LineJSON := CreateQuoteLineJSON(ItemId, Quantity);
        LineJSON := LibraryGraphMgt.AddPropertytoJSON(LineJSON, 'itemVariantId', LibraryGraphMgt.StripBrackets(Format(ItemVariantId)));
        exit(LineJSON);
    end;

    local procedure VerifyQuoteLines(ResponseText: Text; LineNo1: Text; LineNo2: Text)
    var
        LineJSON1: Text;
        LineJSON2: Text;
        SequenceNumber1: Text;
        SequenceNumber2: Text;
    begin
        Assert.AreNotEqual('', ResponseText, 'Response JSON should not be blank');
        Assert.IsTrue(
          LibraryGraphMgt.GetObjectsFromJSONResponse(
            ResponseText, 'sequence', LineNo1, LineNo2, LineJSON1, LineJSON2),
          'Could not find the quote lines in JSON');
        LibraryGraphMgt.VerifyIDFieldInJson(LineJSON1, 'documentId');
        LibraryGraphMgt.VerifyIDFieldInJson(LineJSON2, 'documentId');
        LibraryGraphMgt.GetObjectIDFromJSON(LineJSON1, 'sequence', SequenceNumber1);
        LibraryGraphMgt.GetObjectIDFromJSON(LineJSON2, 'sequence', SequenceNumber2);
        Assert.AreNotEqual(SequenceNumber1, SequenceNumber2, 'Sequence numbers should be different for different lines');
    end;

    local procedure VerifyIdsAreBlank(JsonObjectTxt: Text)
    var
        itemId: Text;
        accountId: Text;
        ExpectedId: Text;
        BlankGuid: Guid;
    begin
        ExpectedId := LibraryGraphMgt.StripBrackets(Format(BlankGuid));

        Assert.IsTrue(LibraryGraphMgt.GetPropertyValueFromJSON(JsonObjectTxt, 'itemId', itemId), 'Could not find itemId');
        Assert.IsTrue(LibraryGraphMgt.GetPropertyValueFromJSON(JsonObjectTxt, 'accountId', accountId), 'Could not find accountId');

        Assert.AreEqual(UPPERCASE(ExpectedId), UPPERCASE(accountId), 'Account id should be blank');
        Assert.AreEqual(UPPERCASE(ExpectedId), UPPERCASE(itemId), 'Item id should be blank');
    end;

    local procedure CreateQuoteWithTwoLines(var SalesHeader: Record "Sales Header"; var Customer: Record "Customer"; var Item: Record "Item")
    var
        SalesLine: Record "Sales Line";
        Quantity: Integer;
    begin
        LibraryInventory.CreateItemWithUnitPriceUnitCostAndPostingGroup(
          Item, LibraryRandom.RandDecInDecimalRange(1000, 3000, 2), LibraryRandom.RandDecInDecimalRange(1000, 3000, 2));
        LibrarySales.CreateCustomer(Customer);
        Quantity := LibraryRandom.RandIntInRange(1, 10);

        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Quote, Customer."No.");
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, Item."No.", Quantity);
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, Item."No.", Quantity);
    end;

    local procedure VerifyTotals(var SalesHeader: Record "Sales Header"; ExpectedInvDiscValue: Decimal; ExpectedInvDiscType: Option)
    var
        SalesQuoteEntityBuffer: Record "Sales Quote Entity Buffer";
    begin
        SalesHeader.FIND();
        SalesHeader.CALCFIELDS(Amount, "Amount Including VAT", "Invoice Discount Amount", "Recalculate Invoice Disc.");
        Assert.AreEqual(ExpectedInvDiscType, SalesHeader."Invoice Discount Calculation", 'Wrong discount type');
        Assert.AreEqual(ExpectedInvDiscValue, SalesHeader."Invoice Discount Value", 'Wrong discount value');
        Assert.IsFalse(SalesHeader."Recalculate Invoice Disc.", 'Recalculate inv. discount should be false');

        IF ExpectedInvDiscValue = 0 THEN
            Assert.AreEqual(0, SalesHeader."Invoice Discount Amount", 'Wrong sales discount amount')
        ELSE
            Assert.IsTrue(SalesHeader."Invoice Discount Amount" > 0, 'discount amount value is wrong');

        // Verify Aggregate table
        SalesQuoteEntityBuffer.GET(SalesHeader."No.");
        Assert.AreEqual(SalesHeader.Amount, SalesQuoteEntityBuffer.Amount, 'Amount was not updated on Buffer Table');
        Assert.AreEqual(
          SalesHeader."Amount Including VAT", SalesQuoteEntityBuffer."Amount Including VAT",
          'Amount Including VAT was not updated on Buffer Table');
        Assert.AreEqual(
          SalesHeader."Amount Including VAT" - SalesHeader.Amount, SalesQuoteEntityBuffer."Total Tax Amount",
          'Total Tax Amount was not updated on Buffer Table');
        Assert.AreEqual(
          SalesHeader."Invoice Discount Amount", SalesQuoteEntityBuffer."Invoice Discount Amount",
          'Amount was not updated on Buffer Table');
    end;

    local procedure FindFirstSalesLine(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line")
    begin
        SalesLine.SETRANGE("Document Type", SalesHeader."Document Type");
        SalesLine.SETRANGE("Document No.", SalesHeader."No.");
        SalesLine.FINDFIRST();
    end;

    local procedure SetupAmountDiscountTest(var SalesHeader: Record "Sales Header"; var Item: Record "Item"; var DiscountAmount: Decimal)
    var
        Customer: Record "Customer";
        SalesCalcDiscountByType: Codeunit "Sales - Calc Discount By Type";
    begin
        CreateQuoteWithTwoLines(SalesHeader, Customer, Item);
        SalesHeader.CALCFIELDS(Amount);
        DiscountAmount := LibraryRandom.RandDecInDecimalRange(1, SalesHeader.Amount / 2, 2);
        SalesCalcDiscountByType.ApplyInvDiscBasedOnAmt(DiscountAmount, SalesHeader);
    end;

    local procedure CreateSalesQuoteWithLines(var SalesHeader: Record "Sales Header"): Text
    var
        Customer: Record "Customer";
        Item: Record "Item";
    begin
        LibrarySmallBusiness.CreateCustomer(Customer);
        LibraryInventory.CreateItem(Item);
        LibrarySmallBusiness.CreateSalesQuoteHeaderWithLines(SalesHeader, Customer, Item, 2, 1);
        COMMIT();
        EXIT(SalesHeader.SystemId);
    end;

    local procedure FindSalesLine(var SalesLine: Record "Sales Line"; LineNumber: Integer; QuoteNumber: Text): Boolean
    var
        DummySalesHeader: Record "Sales Header";
    begin
        SalesLine.SETRANGE("Document No.", QuoteNumber);
        SalesLine.SETRANGE("Document Type", DummySalesHeader."Document Type"::Quote);
        SalesLine.SETRANGE("Line No.", LineNumber);
        EXIT(SalesLine.FINDFIRST());
    end;

    local procedure RecallNotifications()
    var
        NotificationLifecycleMgt: Codeunit "Notification Lifecycle Mgt.";
    begin
        NotificationLifecycleMgt.RecallAllNotifications();
    end;
}








































































