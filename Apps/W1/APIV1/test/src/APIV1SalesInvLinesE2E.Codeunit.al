codeunit 139734 "APIV1 - Sales Inv. Lines E2E"
{
    // version Test,ERM,W1,All

    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Graph] [Sales] [Invoice]
    end;

    var
        Assert: Codeunit "Assert";
        SalesInvoiceAggregator: Codeunit "Sales Invoice Aggregator";
        LibraryGraphMgt: Codeunit "Library - Graph Mgt";
        LibraryERM: Codeunit "Library - ERM";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryGraphDocumentTools: Codeunit "Library - Graph Document Tools";
        LibraryRandom: Codeunit "Library - Random";
        LibrarySales: Codeunit "Library - Sales";
        LibrarySmallBusiness: Codeunit "Library - Small Business";
        LibraryApplicationArea: Codeunit "Library - Application Area";
        IsInitialized: Boolean;
        InvoiceServiceNameTxt: Label 'salesInvoices';
        InvoiceServiceLinesNameTxt: Label 'salesInvoiceLines';
        LineTypeFieldNameTxt: Label 'lineType';
        UoMComplexTypeNameTxt: Label 'unitOfMeasure';
        UoMComplexTypeCodeNameTxt: Label 'code';
        UoMIdTxt: Label 'unitOfMeasureId';

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
    procedure TestFailsOnIDAbsense()
    var
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] Call GET on the lines without providing a parent Invoice ID.
        // [GIVEN] the invoice API exposed
        Initialize();

        // [WHEN] we GET all the lines without an ID from the web service
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage('',
            PAGE::"APIV1 - Sales Invoices",
            InvoiceServiceNameTxt,
            InvoiceServiceLinesNameTxt);
        ASSERTERROR LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] the response text should be empty
        Assert.AreEqual('', ResponseText, 'Response JSON should be blank');
    end;

    [Test]
    procedure TestGetInvoiceLineDirectly()
    var
        SalesLine: Record "Sales Line";
        SalesHeader: Record "Sales Header";
        ResponseText: Text;
        TargetURL: Text;
        InvoiceId: Text;
        LineNo: Integer;
        IdValue: Text;
        SequenceValue: Text;
    begin
        // [SCENARIO] Call GET on the Line of a unposted Invoice
        // [GIVEN] An invoice with a line.
        Initialize();
        InvoiceId := CreateSalesInvoiceWithLines(SalesHeader);

        SalesLine.SETRANGE("Document Type", SalesHeader."Document Type"::Invoice);
        SalesLine.SETRANGE("Document No.", SalesHeader."No.");
        SalesLine.FINDFIRST();
        LineNo := SalesLine."Line No.";

        // [WHEN] we GET all the lines with the unposted invoice ID from the web service
        TargetURL := GetLinesURL(SalesInvoiceAggregator.GetIdFromDocumentIdAndSequence(InvoiceId, LineNo), PAGE::"APIV1 - Sales Invoices", InvoiceServiceNameTxt, InvoiceServiceLinesNameTxt);
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] the line returned should be valid (numbers and integration id)
        Assert.AreNotEqual('', ResponseText, 'Response JSON should not be blank');
        LibraryGraphMgt.VerifyIDFieldInJson(ResponseText, 'documentId');
        LibraryGraphMgt.GetPropertyValueFromJSON(ResponseText, 'id', IdValue);
        Assert.AreEqual(IdValue, SalesInvoiceAggregator.GetIdFromDocumentIdAndSequence(InvoiceId, LineNo), 'The id value is wrong.');
        LibraryGraphMgt.GetPropertyValueFromJSON(ResponseText, 'sequence', SequenceValue);
        Assert.AreEqual(SequenceValue, FORMAT(LineNo), 'The sequence value is wrong.');
    end;

    [Test]
    procedure TestGetInvoiceLines()
    var
        SalesLine: Record "Sales Line";
        SalesHeader: Record "Sales Header";
        ResponseText: Text;
        TargetURL: Text;
        InvoiceId: Text;
        LineNo1: Text;
        LineNo2: Text;
    begin
        // [SCENARIO] Call GET on the Lines of a unposted Invoice
        // [GIVEN] An invoice with lines.
        Initialize();
        InvoiceId := CreateSalesInvoiceWithLines(SalesHeader);

        SalesLine.SETRANGE("Document Type", SalesHeader."Document Type"::Invoice);
        SalesLine.SETRANGE("Document No.", SalesHeader."No.");
        SalesLine.FINDFIRST();
        LineNo1 := FORMAT(SalesLine."Line No.");
        SalesLine.FINDLAST();
        LineNo2 := FORMAT(SalesLine."Line No.");

        // [WHEN] we GET all the lines with the unposted invoice ID from the web service
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            InvoiceId,
            PAGE::"APIV1 - Sales Invoices",
            InvoiceServiceNameTxt,
            InvoiceServiceLinesNameTxt);
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] the lines returned should be valid (numbers and integration ids)
        VerifyInvoiceLines(ResponseText, LineNo1, LineNo2);
    end;

    [Test]
    procedure TestGetInvoiceLinesDirectlyWithDocumentIdFilter()
    var
        SalesLine: Record "Sales Line";
        SalesHeader: Record "Sales Header";
        ResponseText: Text;
        TargetURL: Text;
        InvoiceId: Text;
        LineNo1: Text;
        LineNo2: Text;
    begin
        // [SCENARIO] Call GET on the Lines of a unposted Invoice
        // [GIVEN] An invoice with lines.
        Initialize();
        InvoiceId := CreateSalesInvoiceWithLines(SalesHeader);

        SalesLine.SETRANGE("Document Type", SalesHeader."Document Type"::Invoice);
        SalesLine.SETRANGE("Document No.", SalesHeader."No.");
        SalesLine.FINDFIRST();
        LineNo1 := FORMAT(SalesLine."Line No.");
        SalesLine.FINDLAST();
        LineNo2 := FORMAT(SalesLine."Line No.");

        // [WHEN] we GET all the lines with the unposted invoice ID from the web service
        TargetURL := GetLinesURLWithDocumentIdFilter(InvoiceId, PAGE::"APIV1 - Sales Invoices", InvoiceServiceNameTxt, InvoiceServiceLinesNameTxt);
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] the lines returned should be valid (numbers and integration ids)
        VerifyInvoiceLines(ResponseText, LineNo1, LineNo2);
    end;

    [Test]
    procedure TestGetPostedInvoiceLines()
    var
        SalesInvoiceLine: Record "Sales Invoice Line";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        ResponseText: Text;
        TargetURL: Text;
        PostedInvoiceId: Text;
        LineNo1: Text;
        LineNo2: Text;
    begin
        // [SCENARIO] Call GET on the Lines of a posted Invoice
        // [GIVEN] A posted invoice with lines.
        Initialize();
        PostedInvoiceId := CreatePostedSalesInvoiceWithLines(SalesInvoiceHeader);

        SalesInvoiceLine.SETRANGE("Document No.", SalesInvoiceHeader."No.");
        SalesInvoiceLine.FINDFIRST();
        LineNo1 := FORMAT(SalesInvoiceLine."Line No.");
        SalesInvoiceLine.FINDLAST();
        LineNo2 := FORMAT(SalesInvoiceLine."Line No.");

        // [WHEN] we GET all the lines with the posted invoice ID from the web service
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            PostedInvoiceId,
            PAGE::"APIV1 - Sales Invoices",
            InvoiceServiceNameTxt,
            InvoiceServiceLinesNameTxt);
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] the response text should contain the invoice ID
        VerifyInvoiceLines(ResponseText, LineNo1, LineNo2);
    end;

    [Test]
    procedure TestPostInvoiceLines()
    var
        Item: Record "Item";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ResponseText: Text;
        TargetURL: Text;
        InvoiceLineJSON: Text;
        LineNoFromJSON: Text;
        InvoiceID: Text;
        LineNo: Integer;
    begin
        // [SCENARIO] POST a new line to an unposted Invoice
        // [GIVEN] An existing unposted invoice and a valid JSON describing the new invoice line
        Initialize();
        InvoiceID := CreateSalesInvoiceWithLines(SalesHeader);
        LibraryInventory.CreateItem(Item);

        InvoiceLineJSON := CreateInvoiceLineJSON(Item.SystemId, LibraryRandom.RandIntInRange(1, 100));
        COMMIT();

        // [WHEN] we POST the JSON to the web service
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            InvoiceID,
            PAGE::"APIV1 - Sales Invoices",
            InvoiceServiceNameTxt,
            InvoiceServiceLinesNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, InvoiceLineJSON, ResponseText);

        // [THEN] the response text should contain the invoice ID and the change should exist in the database
        Assert.AreNotEqual('', ResponseText, 'response JSON should not be blank');
        Assert.IsTrue(
          LibraryGraphMgt.GetObjectIDFromJSON(ResponseText, 'sequence', LineNoFromJSON), 'Could not find sequence');

        EVALUATE(LineNo, LineNoFromJSON);
        SalesLine.SetRange("Document Type", SalesHeader."Document Type"::Invoice);
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange("Line No.", LineNo);
        Assert.IsFalse(SalesLine.IsEmpty(), 'The unposted invoice line should exist');
    end;

    [Test]
    procedure TestPostInvoiceLineWithSequence()
    var
        Item: Record "Item";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ResponseText: Text;
        TargetURL: Text;
        InvoiceLineJSON: Text;
        LineNoFromJSON: Text;
        InvoiceID: Text;
        LineNo: Integer;
    begin
        // [SCENARIO] POST a new line to an unposted Invoice with a sequence number
        // [GIVEN] An existing unposted invoice and a valid JSON describing the new invoice line
        Initialize();
        InvoiceID := CreateSalesInvoiceWithLines(SalesHeader);
        LibraryInventory.CreateItem(Item);

        InvoiceLineJSON := CreateInvoiceLineJSON(Item.SystemId, LibraryRandom.RandIntInRange(1, 100));
        LineNo := 500;
        InvoiceLineJSON := LibraryGraphMgt.AddPropertytoJSON(InvoiceLineJSON, 'sequence', LineNo);
        COMMIT();

        // [WHEN] we POST the JSON to the web service
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            InvoiceID,
            PAGE::"APIV1 - Sales Invoices",
            InvoiceServiceNameTxt,
            InvoiceServiceLinesNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, InvoiceLineJSON, ResponseText);

        // [THEN] the response text should contain the correct sequence and exist in the database
        Assert.AreNotEqual('', ResponseText, 'response JSON should not be blank');
        Assert.IsTrue(
          LibraryGraphMgt.GetObjectIDFromJSON(ResponseText, 'sequence', LineNoFromJSON), 'Could not find sequence');
        Assert.AreEqual(FORMAT(LineNo), LineNoFromJSON, 'The sequence in the response does not exist of the one that was given.');

        SalesLine.SETRANGE("Document Type", SalesHeader."Document Type"::Invoice);
        SalesLine.SETRANGE("Document No.", SalesHeader."No.");
        SalesLine.SETRANGE("Line No.", LineNo);
        Assert.IsTrue(SalesLine.FINDFIRST(), 'The unposted invoice line should exist');
        Assert.AreEqual(SalesLine."Line No.", LineNo, 'The line should have the line no that was given.');
    end;

    [Test]
    procedure TestPostInvoiceLinesWithUoM()
    var
        Item: Record "Item";
        SalesHeader: Record "Sales Header";
        UnitOfMeasure: Record "Unit of Measure";
        UoMJSON: Text;
        ResponseText: array[2] of Text;
        TargetURL: Text;
        InvoiceLineJSON: array[2] of Text;
        InvoiceID: Text;
    begin
        // [SCENARIO] POST a new line to an unposted Invoice with a unit of measure id and complex type
        // [GIVEN] an existing unposted invoice and 2 valid JSONs describing the new invoice lines
        Initialize();
        InvoiceID := CreateSalesInvoiceWithLines(SalesHeader);
        LibraryInventory.CreateItem(Item);

        // [GIVEN] a unit of measure
        LibraryInventory.CreateUnitOfMeasureCode(UnitOfMeasure);

        // [GIVEN] a JSON with an invoice line with UoM Id
        InvoiceLineJSON[1] := CreateInvoiceLineJSON(Item.SystemId, LibraryRandom.RandIntInRange(1, 100));
        InvoiceLineJSON[1] := LibraryGraphMgt.AddPropertytoJSON(InvoiceLineJSON[1], UoMIdTxt, UnitOfMeasure.SystemId);

        // [GIVEN] a JSON with UoM complex type
        UoMJSON := LibraryGraphMgt.AddPropertytoJSON('{}', UoMComplexTypeCodeNameTxt, UnitOfMeasure.Code);

        // [GIVEN] a JSON with an invoice line with UoM as complex type
        InvoiceLineJSON[2] := CreateInvoiceLineJSON(Item.SystemId, LibraryRandom.RandIntInRange(1, 100));
        InvoiceLineJSON[2] := LibraryGraphMgt.AddComplexTypetoJSON(InvoiceLineJSON[2], UoMComplexTypeNameTxt, UoMJSON);
        COMMIT();

        // [WHEN] we POST the JSONs to the web service
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            InvoiceID,
            PAGE::"APIV1 - Sales Invoices",
            InvoiceServiceNameTxt,
            InvoiceServiceLinesNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, InvoiceLineJSON[1], ResponseText[1]);
        LibraryGraphMgt.PostToWebService(TargetURL, InvoiceLineJSON[2], ResponseText[2]);

        // [THEN] the response texts should contain the correct Unit of Measure information
        VerifyUoMInJson(ResponseText[1], UnitOfMeasure);
        VerifyUoMInJson(ResponseText[2], UnitOfMeasure);
    end;

    [Test]
    procedure TestModifyInvoiceLine()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ResponseText: Text;
        TargetURL: Text;
        InvoiceLineJSON: Text;
        LineNo: Integer;
        InvoiceLineID: Text;
        SalesQuantity: Integer;
    begin
        // [SCENARIO] PATCH a line of an unposted Invoice
        // [GIVEN] An unposted invoice with lines and a valid JSON describing the fields that we want to change
        Initialize();
        InvoiceLineID := CreateSalesInvoiceWithLines(SalesHeader);
        Assert.AreNotEqual('', InvoiceLineID, 'ID should not be empty');
        SalesLine.SETRANGE("Document Type", SalesHeader."Document Type"::Invoice);
        SalesLine.SETRANGE("Document No.", SalesHeader."No.");
        SalesLine.FINDFIRST();
        LineNo := SalesLine."Line No.";

        SalesQuantity := 4;
        InvoiceLineJSON := LibraryGraphMgt.AddComplexTypetoJSON('{}', 'quantity', FORMAT(SalesQuantity));

        // [WHEN] we PATCH the line
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            InvoiceLineID,
            PAGE::"APIV1 - Sales Invoices",
            InvoiceServiceNameTxt,
            GetLineSubURL(InvoiceLineID, LineNo, InvoiceServiceLinesNameTxt));
        LibraryGraphMgt.PatchToWebService(TargetURL, InvoiceLineJSON, ResponseText);

        // [THEN] the line should be changed in the table and the response JSON text should contain our changed field
        Assert.AreNotEqual('', ResponseText, 'Response JSON should not be blank');

        SalesLine.RESET();
        SalesLine.SETRANGE("Document Type", SalesHeader."Document Type"::Invoice);
        SalesLine.SETRANGE("Document No.", SalesHeader."No.");
        SalesLine.SETRANGE("Line No.", LineNo);
        Assert.IsTrue(SalesLine.FINDFIRST(), 'The unposted invoice line should exist after modification');
        Assert.AreEqual(SalesLine.Quantity, SalesQuantity, 'The patch of Sales line quantity was unsuccessful');

        LibraryGraphMgt.VerifyPropertyInJSON(ResponseText, 'quantity', FORMAT(SalesQuantity));
    end;

    [Test]
    procedure TestModifyInvoiceLineFailsOnSequenceIdOrDocumentIdChange()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ResponseText: Text;
        TargetURL: Text;
        InvoiceLineJSON: Array[3] of Text;
        LineNo: Integer;
        InvoiceLineID: Text;
        NewSequence: Integer;
    begin
        // [SCENARIO] PATCH a line of an unposted Invoice will fail if sequence is modified
        // [GIVEN] An unposted invoice with lines and a valid JSON describing the fields that we want to change
        Initialize();
        InvoiceLineID := CreateSalesInvoiceWithLines(SalesHeader);
        Assert.AreNotEqual('', InvoiceLineID, 'ID should not be empty');
        SalesLine.SETRANGE("Document Type", SalesHeader."Document Type"::Invoice);
        SalesLine.SETRANGE("Document No.", SalesHeader."No.");
        SalesLine.FINDFIRST();
        LineNo := SalesLine."Line No.";

        NewSequence := SalesLine."Line No." + 1;
        InvoiceLineJSON[1] := LibraryGraphMgt.AddPropertytoJSON('', 'sequence', NewSequence);
        InvoiceLineJSON[2] := LibraryGraphMgt.AddPropertytoJSON('', 'documentId', LibraryGraphMgt.StripBrackets(CreateGuid()));
        InvoiceLineJSON[3] := LibraryGraphMgt.AddPropertytoJSON('', 'id', SalesInvoiceAggregator.GetIdFromDocumentIdAndSequence(CreateGuid(), NewSequence));

        // [WHEN] we PATCH the line
        // [THEN] the request will fail
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            InvoiceLineID,
            PAGE::"APIV1 - Sales Invoices",
            InvoiceServiceNameTxt,
            GetLineSubURL(InvoiceLineID, LineNo, InvoiceServiceLinesNameTxt));
        ASSERTERROR LibraryGraphMgt.PatchToWebService(TargetURL, InvoiceLineJSON[1], ResponseText);

        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            InvoiceLineID,
            PAGE::"APIV1 - Sales Invoices",
            InvoiceServiceNameTxt,
            GetLineSubURL(InvoiceLineID, LineNo, InvoiceServiceLinesNameTxt));
        ASSERTERROR LibraryGraphMgt.PatchToWebService(TargetURL, InvoiceLineJSON[2], ResponseText);

        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            InvoiceLineID,
            PAGE::"APIV1 - Sales Invoices",
            InvoiceServiceNameTxt,
            GetLineSubURL(InvoiceLineID, LineNo, InvoiceServiceLinesNameTxt));
        ASSERTERROR LibraryGraphMgt.PatchToWebService(TargetURL, InvoiceLineJSON[3], ResponseText);
    end;

    [Test]
    procedure TestModifyInvoiceLineWithUoM()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        UnitOfMeasure: Record "Unit of Measure";
        UoMJSON: Text;
        ResponseText: array[2] of Text;
        TargetURL: Text;
        InvoiceLineJSON: array[2] of Text;
        InvoiceLineID: Text;
        LineNo: array[2] of Integer;
    begin
        // [SCENARIO] PATCH a line to an unposted Invoice with a unit of measure id and complex type
        // [GIVEN] an existing unposted invoice with lines and 2 valid JSONs describing the new invoice lines
        Initialize();
        InvoiceLineID := CreateSalesInvoiceWithLines(SalesHeader);
        Assert.AreNotEqual('', InvoiceLineID, 'ID should not be empty');
        SalesLine.SETRANGE("Document Type", SalesHeader."Document Type"::Invoice);
        SalesLine.SETRANGE("Document No.", SalesHeader."No.");
        SalesLine.FINDFIRST();
        LineNo[1] := SalesLine."Line No.";
        SalesLine.FINDLAST();
        LineNo[2] := SalesLine."Line No.";

        // [GIVEN] a unit of measure
        LibraryInventory.CreateUnitOfMeasureCode(UnitOfMeasure);

        // [GIVEN] a JSON with an UoM Id
        InvoiceLineJSON[1] := LibraryGraphMgt.AddPropertytoJSON('', UoMIdTxt, UnitOfMeasure.SystemId);

        // [GIVEN] a JSON with UoM complex type
        UoMJSON := LibraryGraphMgt.AddPropertytoJSON('{}', UoMComplexTypeCodeNameTxt, UnitOfMeasure.Code);

        // [GIVEN] a JSON with a UoM as complex type
        InvoiceLineJSON[2] := LibraryGraphMgt.AddComplexTypetoJSON('', UoMComplexTypeNameTxt, UoMJSON);
        COMMIT();

        // [WHEN] we PATCH the JSONs to the web service
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            InvoiceLineID,
            PAGE::"APIV1 - Sales Invoices",
            InvoiceServiceNameTxt,
            GetLineSubURL(InvoiceLineID, LineNo[1], InvoiceServiceLinesNameTxt));
        LibraryGraphMgt.PatchToWebService(TargetURL, InvoiceLineJSON[1], ResponseText[1]);
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            InvoiceLineID,
            PAGE::"APIV1 - Sales Invoices",
            InvoiceServiceNameTxt,
            GetLineSubURL(InvoiceLineID, LineNo[2], InvoiceServiceLinesNameTxt));
        LibraryGraphMgt.PatchToWebService(TargetURL, InvoiceLineJSON[2], ResponseText[2]);

        // [THEN] the response texts should contain the correct Unit of Measure information
        VerifyUoMInJson(ResponseText[1], UnitOfMeasure);
        VerifyUoMInJson(ResponseText[2], UnitOfMeasure);
    end;

    [Test]
    procedure TestDeleteInvoiceLine()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ResponseText: Text;
        TargetURL: Text;
        InvoiceId: Text;
        LineNo: Integer;
    begin
        // [SCENARIO] DELETE a line from an unposted Invoice
        // [GIVEN] An unposted invoice with lines
        Initialize();
        InvoiceId := CreateSalesInvoiceWithLines(SalesHeader);

        SalesLine.SETRANGE("Document Type", SalesHeader."Document Type"::Invoice);
        SalesLine.SETRANGE("Document No.", SalesHeader."No.");
        SalesLine.FINDFIRST();
        LineNo := SalesLine."Line No.";

        COMMIT();

        // [WHEN] we DELETE the first line of that invoice
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            InvoiceId,
            PAGE::"APIV1 - Sales Invoices",
            InvoiceServiceNameTxt,
            GetLineSubURL(InvoiceId, LineNo, InvoiceServiceLinesNameTxt));
        LibraryGraphMgt.DeleteFromWebService(TargetURL, '', ResponseText);

        // [THEN] the line should no longer exist in the database
        SalesLine.Reset();
        SalesLine.SetRange("Document Type", SalesHeader."Document Type"::Invoice);
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange("Line No.", LineNo);
        Assert.IsTrue(SalesLine.IsEmpty(), 'The invoice line should not exist');
    end;

    [Test]
    procedure TestDeletePostedInvoiceLine()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesInvoiceLine: Record "Sales Invoice Line";
        ResponseText: Text;
        TargetURL: Text;
        PostedInvoiceId: Text;
        LineNo: Integer;
    begin
        // [SCENARIO] Call DELETE on a line of a posted Invoice
        // [GIVEN] A posted invoice with lines
        Initialize();
        PostedInvoiceId := CreatePostedSalesInvoiceWithLines(SalesInvoiceHeader);

        SalesInvoiceLine.SETRANGE("Document No.", SalesInvoiceHeader."No.");
        SalesInvoiceLine.FINDFIRST();
        LineNo := SalesInvoiceLine."Line No.";

        // [WHEN] we DELETE the first line through the API
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            PostedInvoiceId,
            PAGE::"APIV1 - Sales Invoices",
            InvoiceServiceNameTxt,
            GetLineSubURL(PostedInvoiceId, LineNo, InvoiceServiceLinesNameTxt));
        ASSERTERROR LibraryGraphMgt.DeleteFromWebService(TargetURL, '', ResponseText);

        // [THEN] the line should still exist, since it's not allowed to delete lines in posted invoices
        SalesInvoiceLine.Reset();
        SalesInvoiceLine.SetRange("Document No.", SalesInvoiceHeader."No.");
        SalesInvoiceLine.SetRange("Line No.", LineNo);
        Assert.IsFalse(SalesInvoiceLine.IsEmpty(), 'The invoice line should still exist');
    end;

    [Test]
    procedure TestCreateLineThroughPageAndAPI()
    var
        SalesHeader: Record "Sales Header";
        Item: Record "Item";
        PageSalesLine: Record "Sales Line";
        ApiSalesLine: Record "Sales Line";
        TempIgnoredFieldsForComparison: Record 2000000041 temporary;
        Customer: Record "Customer";
        PageRecordRef: RecordRef;
        ApiRecordRef: RecordRef;
        SalesInvoice: TestPage "Sales Invoice";
        ResponseText: Text;
        TargetURL: Text;
        InvoiceLineJSON: Text;
        LineNoFromJSON: Text;
        InvoiceID: Text;
        LineNo: Integer;
        ItemQuantity: Integer;
        ItemNo: Code[20];
        CustomerNo: Code[20];
    begin
        // [SCENARIO] Create an invoice both through the client UI and through the API and compare their final values.
        // [GIVEN] An unposted invoice and a JSON describing the line we want to create
        Initialize();
        LibrarySales.CreateCustomer(Customer);
        CustomerNo := Customer."No.";
        ItemNo := LibraryInventory.CreateItem(Item);
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Invoice, CustomerNo);
        InvoiceID := SalesHeader.SystemId;
        ItemQuantity := LibraryRandom.RandIntInRange(1, 100);
        InvoiceLineJSON := CreateInvoiceLineJSON(Item.SystemId, ItemQuantity);
        COMMIT();

        // [WHEN] we POST the JSON to the web service and when we create an invoice through the client UI
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            InvoiceID,
            PAGE::"APIV1 - Sales Invoices",
            InvoiceServiceNameTxt,
            InvoiceServiceLinesNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, InvoiceLineJSON, ResponseText);

        // [THEN] the response text should be valid, the invoice line should exist in the tables and the two invoices have the same field values.
        Assert.AreNotEqual('', ResponseText, 'response JSON should not be blank');
        Assert.IsTrue(
          LibraryGraphMgt.GetObjectIDFromJSON(ResponseText, 'sequence', LineNoFromJSON), 'Could not find sequence');

        EVALUATE(LineNo, LineNoFromJSON);
        ApiSalesLine.SETRANGE("Document Type", SalesHeader."Document Type"::Invoice);
        ApiSalesLine.SETRANGE("Document No.", SalesHeader."No.");
        ApiSalesLine.SETRANGE("Line No.", LineNo);
        Assert.IsTrue(ApiSalesLine.FINDFIRST(), 'The unposted invoice line should exist');

        CreateInvoiceAndLinesThroughPage(SalesInvoice, CustomerNo, ItemNo, ItemQuantity);

        PageSalesLine.SETRANGE("Document Type", SalesHeader."Document Type"::Invoice);
        PageSalesLine.SETRANGE("Document No.", SalesInvoice."No.".VALUE());
        Assert.IsTrue(PageSalesLine.FINDFIRST(), 'The unposted invoice line should exist');

        ApiRecordRef.GETTABLE(ApiSalesLine);
        PageRecordRef.GETTABLE(PageSalesLine);

        // Ignore these fields when comparing Page and API invoices
        LibraryUtility.AddTempField(TempIgnoredFieldsForComparison, ApiSalesLine.FIELDNO("Line No."), DATABASE::"Sales Line");
        LibraryUtility.AddTempField(TempIgnoredFieldsForComparison, ApiSalesLine.FIELDNO("Document No."), DATABASE::"Sales Line");
        LibraryUtility.AddTempField(TempIgnoredFieldsForComparison, ApiSalesLine.FIELDNO("No."), DATABASE::"Sales Line");
        LibraryUtility.AddTempField(TempIgnoredFieldsForComparison, ApiSalesLine.FIELDNO(Subtype), DATABASE::"Sales Line");
        LibraryUtility.AddTempField(
          TempIgnoredFieldsForComparison, ApiSalesLine.FIELDNO("Recalculate Invoice Disc."), DATABASE::"Sales Line"); // TODO: remove once other changes are checked in

        Assert.RecordsAreEqualExceptCertainFields(ApiRecordRef, PageRecordRef, TempIgnoredFieldsForComparison,
          'Page and API Invoice lines do not match');
    end;

    [Test]
    procedure TestInsertingLineUpdatesInvoiceDiscountPct()
    var
        SalesHeader: Record "Sales Header";
        Customer: Record "Customer";
        Item: Record "Item";
        TargetURL: Text;
        InvoiceLineJSON: Text;
        ResponseText: Text;
        MinAmount: Decimal;
        DiscountPct: Decimal;
    begin
        // [FEATURE] [Discount]
        // [SCENARIO] Creating a line through API should update Discount Pct
        // [GIVEN] An unposted invoice for customer with invoice discount pct
        Initialize();
        CreateInvoiceWithTwoLines(SalesHeader, Customer, Item);
        SalesHeader.CALCFIELDS(Amount);
        MinAmount := SalesHeader.Amount + Item."Unit Price" / 2;
        DiscountPct := LibraryRandom.RandDecInDecimalRange(1, 90, 2);
        LibrarySmallBusiness.SetInvoiceDiscountToCustomer(Customer, DiscountPct, MinAmount, SalesHeader."Currency Code");
        InvoiceLineJSON := CreateInvoiceLineJSON(Item.SystemId, LibraryRandom.RandIntInRange(1, 100));
        COMMIT();

        // [WHEN] We create a line through API
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            SalesHeader.SystemId,
            PAGE::"APIV1 - Sales Invoices",
            InvoiceServiceNameTxt,
            InvoiceServiceLinesNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, InvoiceLineJSON, ResponseText);

        // [THEN] Invoice discount is applied
        Assert.AreNotEqual('', ResponseText, 'Response JSON should not be blank');
        LibraryGraphMgt.VerifyIDFieldInJson(ResponseText, 'itemId');
        VerifyTotals(SalesHeader, DiscountPct, SalesHeader."Invoice Discount Calculation"::"%");
    end;

    [Test]
    procedure TestModifyingLineUpdatesInvoiceDiscountPct()
    var
        SalesHeader: Record "Sales Header";
        Customer: Record "Customer";
        Item: Record "Item";
        SalesLine: Record "Sales Line";
        TargetURL: Text;
        InvoiceLineJSON: Text;
        ResponseText: Text;
        MinAmount: Decimal;
        DiscountPct: Decimal;
        SalesQuantity: Integer;
    begin
        // [FEATURE] [Discount]
        // [SCENARIO] Modifying a line through API should update Discount Pct
        // [GIVEN] An unposted invoice for customer with invoice discount pct
        Initialize();
        CreateInvoiceWithTwoLines(SalesHeader, Customer, Item);
        SalesHeader.CALCFIELDS(Amount);
        MinAmount := SalesHeader.Amount + Item."Unit Price" / 2;
        DiscountPct := LibraryRandom.RandDecInDecimalRange(1, 90, 2);
        LibrarySmallBusiness.SetInvoiceDiscountToCustomer(Customer, DiscountPct, MinAmount, SalesHeader."Currency Code");
        InvoiceLineJSON := CreateInvoiceLineJSON(Item.SystemId, LibraryRandom.RandIntInRange(1, 100));
        FindFirstSalesLine(SalesHeader, SalesLine);
        SalesQuantity := SalesLine.Quantity * 2;

        COMMIT();

        InvoiceLineJSON := LibraryGraphMgt.AddComplexTypetoJSON('{}', 'quantity', FORMAT(SalesQuantity));

        // [WHEN] we PATCH the line
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            SalesHeader.SystemId,
            PAGE::"APIV1 - Sales Invoices",
            InvoiceServiceNameTxt,
            GetLineSubURL(SalesHeader.SystemId, SalesLine."Line No.", InvoiceServiceLinesNameTxt));
        LibraryGraphMgt.PatchToWebService(TargetURL, InvoiceLineJSON, ResponseText);

        // [THEN] Invoice discount is applied
        Assert.AreNotEqual('', ResponseText, 'Response JSON should not be blank');
        LibraryGraphMgt.VerifyIDFieldInJson(ResponseText, 'itemId');
        VerifyTotals(SalesHeader, DiscountPct, SalesHeader."Invoice Discount Calculation"::"%");
    end;

    [Test]
    procedure TestDeletingLineMovesInvoiceDiscountPct()
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
        // [GIVEN] An unposted invoice for customer with invoice discount pct
        Initialize();
        CreateInvoiceWithTwoLines(SalesHeader, Customer, Item);
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
            PAGE::"APIV1 - Sales Invoices",
            InvoiceServiceNameTxt,
            GetLineSubURL(SalesHeader.SystemId, SalesLine."Line No.", InvoiceServiceLinesNameTxt));
        LibraryGraphMgt.DeleteFromWebService(TargetURL, '', ResponseText);

        // [THEN] Lower Invoice discount is applied
        VerifyTotals(SalesHeader, DiscountPct1, SalesHeader."Invoice Discount Calculation"::"%");
    end;

    [Test]
    procedure TestDeletingLineRemovesInvoiceDiscountPct()
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
        // [GIVEN] An unposted invoice for customer with invoice discount pct
        Initialize();
        CreateInvoiceWithTwoLines(SalesHeader, Customer, Item);
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
            PAGE::"APIV1 - Sales Invoices",
            InvoiceServiceNameTxt,
            GetLineSubURL(SalesHeader.SystemId, SalesLine."Line No.", InvoiceServiceLinesNameTxt));
        LibraryGraphMgt.DeleteFromWebService(TargetURL, '', ResponseText);

        // [THEN] Lower Invoice discount is applied
        VerifyTotals(SalesHeader, 0, SalesHeader."Invoice Discount Calculation"::"%");
    end;

    [Test]
    procedure TestInsertingLineKeepsInvoiceDiscountAmt()
    var
        SalesHeader: Record "Sales Header";
        Item: Record "Item";
        TargetURL: Text;
        ResponseText: Text;
        InvoiceLineJSON: Text;
        DiscountAmount: Decimal;
    begin
        // [FEATURE] [Discount]
        // [SCENARIO] Adding an invoice through API will keep Discount Amount
        // [GIVEN] An unposted invoice for customer with invoice discount amount
        Initialize();
        SetupAmountDiscountTest(SalesHeader, DiscountAmount);
        InvoiceLineJSON := CreateInvoiceLineJSON(Item.SystemId, LibraryRandom.RandIntInRange(1, 100));

        COMMIT();

        // [WHEN] We create a line through API
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            SalesHeader.SystemId,
            PAGE::"APIV1 - Sales Invoices",
            InvoiceServiceNameTxt,
            InvoiceServiceLinesNameTxt);
        ASSERTERROR LibraryGraphMgt.PostToWebService(TargetURL, InvoiceLineJSON, ResponseText);

        // [THEN] Discount Amount is Kept
        VerifyTotals(SalesHeader, DiscountAmount, SalesHeader."Invoice Discount Calculation"::Amount);
    end;

    [Test]
    procedure TestModifyingLineKeepsInvoiceDiscountAmt()
    var
        SalesHeader: Record "Sales Header";
        Item: Record "Item";
        SalesLine: Record "Sales Line";
        DiscountAmount: Decimal;
        TargetURL: Text;
        InvoiceLineJSON: Text;
        ResponseText: Text;
        SalesQuantity: Integer;
    begin
        // [FEATURE] [Discount]
        // [SCENARIO] Modifying a line through API should keep existing Discount Amount
        // [GIVEN] An unposted invoice for customer with invoice discount amt
        Initialize();
        SetupAmountDiscountTest(SalesHeader, DiscountAmount);
        InvoiceLineJSON := CreateInvoiceLineJSON(Item.SystemId, LibraryRandom.RandIntInRange(1, 100));

        SalesQuantity := 0;
        InvoiceLineJSON := LibraryGraphMgt.AddComplexTypetoJSON('{}', 'quantity', FORMAT(SalesQuantity));
        COMMIT();

        FindFirstSalesLine(SalesHeader, SalesLine);

        // [WHEN] we PATCH the line
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            SalesHeader.SystemId,
            PAGE::"APIV1 - Sales Invoices",
            InvoiceServiceNameTxt,
            GetLineSubURL(SalesHeader.SystemId, SalesLine."Line No.", InvoiceServiceLinesNameTxt));
        LibraryGraphMgt.PatchToWebService(TargetURL, InvoiceLineJSON, ResponseText);

        // [THEN] Invoice discount is kept
        Assert.AreNotEqual('', ResponseText, 'Response JSON should not be blank');
        LibraryGraphMgt.VerifyIDFieldInJson(ResponseText, 'itemId');
        VerifyTotals(SalesHeader, DiscountAmount, SalesHeader."Invoice Discount Calculation"::Amount);
    end;

    [Test]
    procedure TestDeletingLineKeepsInvoiceDiscountAmt()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        DiscountAmount: Decimal;
        TargetURL: Text;
        ResponseText: Text;
    begin
        // [FEATURE] [Discount]
        // [SCENARIO] Deleting a line through API should update Discount Pct
        // [GIVEN] An unposted invoice for customer with invoice discount pct
        Initialize();
        SetupAmountDiscountTest(SalesHeader, DiscountAmount);
        COMMIT();

        FindFirstSalesLine(SalesHeader, SalesLine);

        // [WHEN] we DELETE the line
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            SalesHeader.SystemId,
            PAGE::"APIV1 - Sales Invoices",
            InvoiceServiceNameTxt,
            GetLineSubURL(SalesHeader.SystemId, SalesLine."Line No.", InvoiceServiceLinesNameTxt));
        LibraryGraphMgt.DeleteFromWebService(TargetURL, '', ResponseText);

        // [THEN] Lower Invoice discount is applied
        VerifyTotals(SalesHeader, DiscountAmount, SalesHeader."Invoice Discount Calculation"::Amount);
    end;

    [Test]
    procedure TestGettingLinesWithDifferentTypes()
    var
        SalesHeader: Record "Sales Header";
        ExpectedNumberOfLines: Integer;
        TargetURL: Text;
        ResponseText: Text;
        LinesJSON: Text;
    begin
        // [SCENARIO] Getting a line through API lists all possible types
        // [GIVEN] An invoice with lines of different types
        Initialize();
        CreateInvoiceWithAllPossibleLineTypes(SalesHeader, ExpectedNumberOfLines);

        COMMIT();

        // [WHEN] we GET the lines
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(SalesHeader.SystemId,
            PAGE::"APIV1 - Sales Invoices",
            InvoiceServiceNameTxt,
            InvoiceServiceLinesNameTxt);
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] All lines are shown in the response
        LibraryGraphMgt.GetComplexPropertyTxtFromJSON(ResponseText, 'value', LinesJSON);
        Assert.AreEqual(ExpectedNumberOfLines, LibraryGraphMgt.GetCollectionCountFromJSON(LinesJSON), 'Four lines should be returned');
        VerifySalesInvoiceLinesForSalesHeader(SalesHeader, LinesJSON);
    end;

    [Test]
    procedure TestPostingBlankLineDefaultsToItemType()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TargetURL: Text;
        ResponseText: Text;
        InvoiceLineJSON: Text;
    begin
        // [SCENARIO] Posting a line with description only will get a type item
        // [GIVEN] A post request with description only
        Initialize();
        CreateSalesInvoiceWithLines(SalesHeader);

        COMMIT();

        InvoiceLineJSON := '{"description":"test"}';

        // [WHEN] we just POST a blank line
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            SalesHeader.SystemId,
            PAGE::"APIV1 - Sales Invoices",
            InvoiceServiceNameTxt,
            InvoiceServiceLinesNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, InvoiceLineJSON, ResponseText);

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
        InvoiceLineJSON: Text;
    begin
        // [FEATURE] [Comment]
        // [SCENARIO] Posting a line with Type Comment and description will make a comment line
        // [GIVEN] A post request with type and description
        Initialize();
        CreateSalesInvoiceWithLines(SalesHeader);

        InvoiceLineJSON := '{"' + LineTypeFieldNameTxt + '":"Comment","description":"test"}';

        COMMIT();

        // [WHEN] we just POST a blank line
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            SalesHeader.SystemId,
            PAGE::"APIV1 - Sales Invoices",
            InvoiceServiceNameTxt,
            InvoiceServiceLinesNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, InvoiceLineJSON, ResponseText);

        // [THEN] Line of type Item is created
        FindFirstSalesLine(SalesHeader, SalesLine);
        SalesLine.FINDLAST();
        Assert.AreEqual(SalesLine.Type, SalesLine.Type::" ", 'Wrong type is set');
        Assert.AreEqual('test', SalesLine.Description, 'Wrong description is set');

        LibraryGraphDocumentTools.VerifySalesObjectTxtDescription(SalesLine, ResponseText);
        VerifyIdsAreBlank(ResponseText);
    end;

    [Test]
    procedure TestPatchingTheIdToAccountChangesLineType()
    var
        SalesHeader: Record "Sales Header";
        GLAccount: Record "G/L Account";
        SalesLine: Record "Sales Line";
        VATPostingSetup: Record "VAT Posting Setup";
        IntegrationManagement: Codeunit "Integration Management";
        TargetURL: Text;
        ResponseText: Text;
        InvoiceLineJSON: Text;
        InvoiceLineID: Text;
        LineNo: Integer;
    begin
        // [SCENARIO] PATCH a Type on a line of an unposted Invoice
        // [GIVEN] An unposted invoice with lines and a valid JSON describing the fields that we want to change
        Initialize();
        InvoiceLineID := CreateSalesInvoiceWithLines(SalesHeader);
        Assert.AreNotEqual('', InvoiceLineID, 'ID should not be empty');
        FindFirstSalesLine(SalesHeader, SalesLine);
        LineNo := SalesLine."Line No.";

        CreateVATPostingSetup(VATPostingSetup, SalesLine."VAT Bus. Posting Group", SalesLine."VAT Prod. Posting Group");
        GetGLAccountWithVATPostingGroup(GLAccount, SalesLine."VAT Bus. Posting Group", SalesLine."VAT Prod. Posting Group");

        InvoiceLineJSON := STRSUBSTNO('{"accountId":"%1"}', IntegrationManagement.GetIdWithoutBrackets(GLAccount.SystemId));

        // [WHEN] we PATCH the line
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            InvoiceLineID,
            PAGE::"APIV1 - Sales Invoices",
            InvoiceServiceNameTxt,
            GetLineSubURL(InvoiceLineID, LineNo, InvoiceServiceLinesNameTxt));
        LibraryGraphMgt.PatchToWebService(TargetURL, InvoiceLineJSON, ResponseText);

        // [THEN] Line type is changed to Account
        FindFirstSalesLine(SalesHeader, SalesLine);
        Assert.AreEqual(SalesLine.Type::"G/L Account", SalesLine.Type, 'Type was not changed');
        Assert.AreEqual(GLAccount."No.", SalesLine."No.", 'G/L Account No was not set');
        VerifySalesLineResponseWithSalesLine(SalesLine, ResponseText);
    end;

    [Test]
    procedure TestPatchingTheIdToItemChangesLineType()
    var
        SalesHeader: Record "Sales Header";
        Item: Record "Item";
        SalesLine: Record "Sales Line";

        IntegrationManagement: Codeunit "Integration Management";
        ExpectedNumberOfLines: Integer;
        TargetURL: Text;
        ResponseText: Text;
        InvoiceLineJSON: Text;
        InvoiceLineID: Text;
        LineNo: Integer;
    begin
        // [SCENARIO] PATCH a Type on a line of an unposted Invoice
        // [GIVEN] An unposted invoice with lines and a valid JSON describing the fields that we want to change
        Initialize();
        CreateInvoiceWithAllPossibleLineTypes(SalesHeader, ExpectedNumberOfLines);
        InvoiceLineID := IntegrationManagement.GetIdWithoutBrackets(SalesHeader.SystemId);
        SalesLine.SETRANGE(Type, SalesLine.Type::"G/L Account");
        SalesLine.SETRANGE("Document No.", SalesHeader."No.");
        SalesLine.SETRANGE("Document Type", SalesHeader."Document Type");
        SalesLine.FINDFIRST();
        SalesLine.SETRANGE(Type);

        Assert.AreNotEqual('', InvoiceLineID, 'ID should not be empty');
        LineNo := SalesLine."Line No.";
        LibraryInventory.CreateItem(Item);

        InvoiceLineJSON := STRSUBSTNO('{"itemId":"%1"}', IntegrationManagement.GetIdWithoutBrackets(Item.SystemId));
        COMMIT();

        // [WHEN] we PATCH the line
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            SalesHeader.SystemId,
            PAGE::"APIV1 - Sales Invoices",
            InvoiceServiceNameTxt,
            GetLineSubURL(SalesHeader.SystemId, LineNo, InvoiceServiceLinesNameTxt));
        LibraryGraphMgt.PatchToWebService(TargetURL, InvoiceLineJSON, ResponseText);

        // [THEN] Line type is changed to Item and other fields are updated
        SalesLine.FIND();
        Assert.AreEqual(SalesLine.Type::Item, SalesLine.Type, 'Type was not changed');
        Assert.AreEqual(Item."No.", SalesLine."No.", 'Item No was not set');
        VerifySalesLineResponseWithSalesLine(SalesLine, ResponseText);
    end;

    [Test]
    procedure TestPatchingTheTypeBlanksIds()
    var
        SalesHeader: Record "Sales Header";
        SalesInvoiceLineAggregate: Record "Sales Invoice Line Aggregate";
        SalesLine: Record "Sales Line";
        TargetURL: Text;
        ResponseText: Text;
        InvoiceLineJSON: Text;
        InvoiceLineID: Text;
        LineNo: Integer;
    begin
        // [SCENARIO] PATCH a Type on a line of an unposted Invoice
        // [GIVEN] An unposted invoice with lines and a valid JSON describing the fields that we want to change
        Initialize();
        InvoiceLineID := CreateSalesInvoiceWithLines(SalesHeader);
        Assert.AreNotEqual('', InvoiceLineID, 'ID should not be empty');
        FindFirstSalesLine(SalesHeader, SalesLine);
        LineNo := SalesLine."Line No.";

        InvoiceLineJSON := STRSUBSTNO('{"%1":"%2"}', LineTypeFieldNameTxt, FORMAT(SalesInvoiceLineAggregate."API Type"::Account));

        // [WHEN] we PATCH the line
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            InvoiceLineID,
            PAGE::"APIV1 - Sales Invoices",
            InvoiceServiceNameTxt,
            GetLineSubURL(InvoiceLineID, LineNo, InvoiceServiceLinesNameTxt));
        LibraryGraphMgt.PatchToWebService(TargetURL, InvoiceLineJSON, ResponseText);

        // [THEN] Line type is changed to Account
        FindFirstSalesLine(SalesHeader, SalesLine);
        Assert.AreEqual(SalesLine.Type::"G/L Account", SalesLine.Type, 'Type was not changed');
        Assert.AreEqual('', SalesLine."No.", 'No should be blank');
        VerifyIdsAreBlank(ResponseText);
    end;

    [Test]
    procedure TestPostInvoiceLinesWithItemVariant()
    var
        Item: Record "Item";
        ItemVariant: Record "Item Variant";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ItemNo: Code[20];
        ItemVariantCode: Code[10];
        ResponseText: Text;
        TargetURL: Text;
        InvoiceLineJSON: Text;
        LineNoFromJSON: Text;
        InvoiceID: Text;
        LineNo: Integer;
    begin
        // [SCENARIO] POST a new line to an unposted Invoice with item variant
        // [GIVEN] An existing unposted invoice and a valid JSON describing the new invoice line with item variant
        Initialize();
        InvoiceID := CreateSalesInvoiceWithLines(SalesHeader);
        ItemNo := LibraryInventory.CreateItem(Item);
        ItemVariantCode := LibraryInventory.CreateItemVariant(ItemVariant, ItemNo);
        Commit();

        // [WHEN] we POST the JSON to the web service
        InvoiceLineJSON := CreateInvoiceLineJSONWithItemVariantId(Item.SystemId, LibraryRandom.RandIntInRange(1, 100), ItemVariant.SystemId);
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            InvoiceID,
            PAGE::"APIV1 - Sales Invoices",
            InvoiceServiceNameTxt,
            InvoiceServiceLinesNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, InvoiceLineJSON, ResponseText);

        // [THEN] the response text should contain the invoice ID and the change should exist in the database
        Assert.AreNotEqual('', ResponseText, 'response JSON should not be blank');
        Assert.IsTrue(
          LibraryGraphMgt.GetObjectIDFromJSON(ResponseText, 'sequence', LineNoFromJSON), 'Could not find sequence');

        Evaluate(LineNo, LineNoFromJSON);
        SalesLine.SetRange("Document Type", SalesHeader."Document Type"::Invoice);
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange("Line No.", LineNo);
        SalesLine.SetRange("Variant Code", ItemVariantCode);
        Assert.IsFalse(SalesLine.IsEmpty(), 'The unposted invoice line should exist');
    end;

    [Test]
    procedure TestPostInvoiceLinesWithWrongItemVariant()
    var
        Item1: Record "Item";
        Item2: Record "Item";
        ItemVariant: Record "Item Variant";
        SalesHeader: Record "Sales Header";
        ItemNo1: Code[20];
        ItemNo2: Code[20];
        ItemVariantCode: Code[10];
        ResponseText: Text;
        TargetURL: Text;
        InvoiceLineJSON: Text;
        InvoiceID: Text;
    begin
        // [SCENARIO] POST a new line to an unposted Invoice with wrong item variant
        // [GIVEN] An existing unposted invoice and a valid JSON describing the new invoice line with item variant
        Initialize();
        InvoiceID := CreateSalesInvoiceWithLines(SalesHeader);
        ItemNo1 := LibraryInventory.CreateItem(Item1);
        ItemNo2 := LibraryInventory.CreateItem(Item2);
        ItemVariantCode := LibraryInventory.CreateItemVariant(ItemVariant, ItemNo2);
        Commit();

        // [WHEN] we POST the JSON to the web service
        InvoiceLineJSON := CreateInvoiceLineJSONWithItemVariantId(Item1.SystemId, LibraryRandom.RandIntInRange(1, 100), ItemVariant.SystemId);
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            InvoiceID,
            PAGE::"APIV1 - Sales Invoices",
            InvoiceServiceNameTxt,
            InvoiceServiceLinesNameTxt);

        // [THEN] the response text should contain the invoice ID and the change should exist in the database
        asserterror LibraryGraphMgt.PostToWebService(TargetURL, InvoiceLineJSON, ResponseText);
    end;

    local procedure CreateInvoiceWithAllPossibleLineTypes(var SalesHeader: Record "Sales Header"; var ExpectedNumberOfLines: Integer)
    var
        SalesLine: Record "Sales Line";
    begin
        CreateSalesInvoiceWithLines(SalesHeader);

        LibraryGraphDocumentTools.CreateSalesLinesWithAllPossibleTypes(SalesHeader);

        SalesLine.SETRANGE("Document No.", SalesHeader."No.");
        SalesLine.SETRANGE("Document Type", SalesHeader."Document Type");
        ExpectedNumberOfLines := SalesLine.COUNT();
    end;

    local procedure CreateSalesInvoiceWithLines(var SalesHeader: Record "Sales Header"): Text
    var
        SalesLine: Record "Sales Line";
        Item: Record "Item";
    begin
        LibrarySales.CreateSalesInvoice(SalesHeader);
        LibraryInventory.CreateItem(Item);
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, Item."No.", 2);
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, Item."No.", 2);
        COMMIT();
        EXIT(SalesHeader.SystemId);
    end;

    local procedure CreatePostedSalesInvoiceWithLines(var SalesInvoiceHeader: Record "Sales Invoice Header"): Text
    var
        SalesLine: Record "Sales Line";
        Item: Record "Item";
        SalesHeader: Record "Sales Header";
        PostedSalesInvoiceID: Text;
        NewNo: Code[20];
    begin
        LibrarySales.CreateSalesInvoice(SalesHeader);
        LibraryInventory.CreateItem(Item);
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, Item."No.", 2);
        PostedSalesInvoiceID := SalesHeader.SystemId;
        NewNo := LibrarySales.PostSalesDocument(SalesHeader, FALSE, TRUE);
        COMMIT();

        SalesInvoiceHeader.RESET();
        SalesInvoiceHeader.SETFILTER("No.", NewNo);
        SalesInvoiceHeader.FINDFIRST();

        EXIT(PostedSalesInvoiceID);
    end;

    [Normal]
    local procedure CreateInvoiceLineJSON(ItemId: Guid; Quantity: Integer): Text
    var
        IntegrationManagement: Codeunit "Integration Management";
        LineJSON: Text;
    begin
        LineJSON := LibraryGraphMgt.AddPropertytoJSON('', 'itemId', IntegrationManagement.GetIdWithoutBrackets(ItemId));
        LineJSON := LibraryGraphMgt.AddComplexTypetoJSON(LineJSON, 'quantity', FORMAT(Quantity));
        EXIT(LineJSON);
    end;

    local procedure CreateInvoiceLineJSONWithItemVariantId(ItemId: Guid; Quantity: Integer; ItemVariantId: Guid): Text
    var
        IntegrationManagement: Codeunit "Integration Management";
        LineJSON: Text;
    begin
        LineJSON := CreateInvoiceLineJSON(ItemId, Quantity);
        LineJSON := LibraryGraphMgt.AddPropertytoJSON(LineJSON, 'itemVariantId', IntegrationManagement.GetIdWithoutBrackets(ItemVariantId));
        exit(LineJSON);
    end;

    local procedure CreateInvoiceAndLinesThroughPage(var SalesInvoice: TestPage "Sales Invoice"; CustomerNo: Text; ItemNo: Text; ItemQuantity: Integer)
    var
        SalesLine: Record "Sales Line";
    begin
        SalesInvoice.OPENNEW();
        SalesInvoice."Sell-to Customer No.".SETVALUE(CustomerNo);

        SalesInvoice.SalesLines.LAST();
        SalesInvoice.SalesLines.NEXT();
        SalesInvoice.SalesLines.FilteredTypeField.SETVALUE(SalesLine.Type::Item);
        SalesInvoice.SalesLines."No.".SETVALUE(ItemNo);

        SalesInvoice.SalesLines.Quantity.SETVALUE(ItemQuantity);

        // Trigger Save
        SalesInvoice.SalesLines.NEXT();
        SalesInvoice.SalesLines.Previous();
    end;

    procedure GetLineSubURL(DocumentId: Text; Sequence: Integer; ServiceLinesName: Text): Text
    var
    begin
        EXIT(ServiceLinesName + '(''' + SalesInvoiceAggregator.GetIdFromDocumentIdAndSequence(DocumentId, Sequence) + ''')');
    end;

    procedure GetLinesURL(Id: Text; PageNumber: Integer; ServiceName: Text; ServiceLinesName: Text): Text
    var
        TargetURL: Text;
    begin
        IF Id <> '' THEN
            TargetURL := LibraryGraphMgt.CreateTargetURL('''' + Id + '''', PageNumber, ServiceName)
        ELSE
            TargetURL := LibraryGraphMgt.CreateTargetURL('', PageNumber, '');
        TargetURL := LibraryGraphMgt.STRREPLACE(TargetURL, ServiceName, ServiceLinesName);
        EXIT(TargetURL);
    end;

    procedure GetLinesURLWithDocumentIdFilter(DocumentId: Text; PageNumber: Integer; ServiceName: Text; ServiceLinesName: Text): Text
    var
        TargetURL: Text;
        URLFilter: Text;
    begin
        TargetURL := GetLinesURL('', PageNumber, ServiceName, ServiceLinesName);
        URLFilter := '$filter=documentId eq ' + LOWERCASE(LibraryGraphMgt.StripBrackets(DocumentId));

        IF STRPOS(TargetURL, '?') <> 0 THEN
            TargetURL := TargetURL + '&' + UrlFilter
        ELSE
            TargetURL := TargetURL + '?' + UrlFilter;

        EXIT(TargetURL);
    end;

    local procedure CreateVATPostingSetup(var VATPostingSetup: Record "VAT Posting Setup"; VATBusPostingGroup: Code[20]; VATProdPostingGroup: Code[20])
    begin
        VATPostingSetup.SETRANGE("VAT Bus. Posting Group", VATBusPostingGroup);
        VATPostingSetup.SETRANGE("VAT Prod. Posting Group", VATProdPostingGroup);
        if not VATPostingSetup.FINDFIRST() then
            LibraryERM.CreateVATPostingSetup(VATPostingSetup, VATBusPostingGroup, VATProdPostingGroup);
    end;

    local procedure GetGLAccountWithVATPostingGroup(var GLAccount: Record "G/L Account"; VATBusPostingGroup: Code[20]; VATProdPostingGroup: Code[20])
    begin
        GLAccount.SETRANGE("Account Type", GLAccount."Account Type"::Posting);
        GLAccount.SETRANGE("Direct Posting", TRUE);
        GLAccount.SETRANGE("VAT Bus. Posting Group", VATBusPostingGroup);
        GLAccount.SETRANGE("VAT Prod. Posting Group", VATProdPostingGroup);
        if not GLAccount.FINDFIRST() then
            CreateGLAccountWithPostingGroup(GLAccount, VATBusPostingGroup, VATProdPostingGroup);
    end;

    local procedure CreateGLAccountWithPostingGroup(var GLAccount: Record "G/L Account"; VATBusPostingGroup: Code[20]; VATProdPostingGroup: Code[20])
    begin
        LibraryERM.CreateGLAccount(GLAccount);
        GLAccount.VALIDATE("VAT Bus. Posting Group", VATBusPostingGroup);
        GLAccount.VALIDATE("VAT Prod. Posting Group", VATProdPostingGroup);
        GLAccount.MODIFY();
    end;

    local procedure VerifyInvoiceLines(ResponseText: Text; LineNo1: Text; LineNo2: Text)
    var
        LineJSON1: Text;
        LineJSON2: Text;
        ItemId1: Text;
        ItemId2: Text;
    begin
        Assert.AreNotEqual('', ResponseText, 'Response JSON should not be blank');
        Assert.IsTrue(
          LibraryGraphMgt.GetObjectsFromJSONResponse(
            ResponseText, 'sequence', LineNo1, LineNo2, LineJSON1, LineJSON2),
          'Could not find the invoice lines in JSON');
        LibraryGraphMgt.VerifyIDFieldInJson(LineJSON1, 'documentId');
        LibraryGraphMgt.VerifyIDFieldInJson(LineJSON2, 'documentId');
        LibraryGraphMgt.GetObjectIDFromJSON(LineJSON1, 'itemId', ItemId1);
        LibraryGraphMgt.GetObjectIDFromJSON(LineJSON2, 'itemId', ItemId2);
        Assert.AreNotEqual(ItemId1, ItemId2, 'Item Ids should be different for different items');
    end;

    local procedure VerifySalesInvoiceLinesForSalesHeader(var SalesHeader: Record "Sales Header"; ObjectTxt: Text)
    var
        SalesLine: Record "Sales Line";
        JSONManagement: Codeunit "JSON Management";
        CurrentIndex: Integer;
        LineJsonTxt: Text;
    begin
        SalesLine.SETRANGE("Document No.", SalesHeader."No.");
        SalesLine.SETRANGE("Document Type", SalesHeader."Document Type");
        SalesLine.FINDSET();
        CurrentIndex := 0;

        JSONManagement.InitializeCollection(ObjectTxt);
        REPEAT
            Assert.IsTrue(JSONManagement.GetObjectFromCollectionByIndex(LineJsonTxt, CurrentIndex),
              STRSUBSTNO('Could not find line %1.', SalesLine."Line No."));
            VerifySalesLineResponseWithSalesLine(SalesLine, LineJsonTxt);
            CurrentIndex += 1;
        UNTIL SalesLine.NEXT() = 0;
    end;

    local procedure VerifySalesLineResponseWithSalesLine(var SalesLine: Record "Sales Line"; ObjectTxt: Text)
    begin
        LibraryGraphDocumentTools.VerifySalesObjectTxtDescription(SalesLine, ObjectTxt);
        LibraryGraphDocumentTools.VerifySalesIdsSetFromTxt(SalesLine, ObjectTxt);
    end;

    local procedure VerifyIdsAreBlank(JsonObjectTxt: Text)
    var
        IntegrationManagement: Codeunit "Integration Management";
        itemId: Text;
        accountId: Text;
        ExpectedId: Text;
        BlankGuid: Guid;
    begin
        ExpectedId := IntegrationManagement.GetIdWithoutBrackets(BlankGuid);

        Assert.IsTrue(LibraryGraphMgt.GetPropertyValueFromJSON(JsonObjectTxt, 'itemId', itemId), 'Could not find itemId');
        Assert.IsTrue(LibraryGraphMgt.GetPropertyValueFromJSON(JsonObjectTxt, 'accountId', accountId), 'Could not find accountId');

        Assert.AreEqual(UPPERCASE(ExpectedId), UPPERCASE(accountId), 'Account id should be blank');
        Assert.AreEqual(UPPERCASE(ExpectedId), UPPERCASE(itemId), 'Item id should be blank');
    end;

    local procedure CreateInvoiceWithTwoLines(var SalesHeader: Record "Sales Header"; var Customer: Record "Customer"; var Item: Record "Item")
    var
        SalesLine: Record "Sales Line";
        Quantity: Integer;
    begin
        LibraryInventory.CreateItemWithUnitPriceUnitCostAndPostingGroup(
          Item, LibraryRandom.RandDecInDecimalRange(1000, 3000, 2), LibraryRandom.RandDecInDecimalRange(1000, 3000, 2));
        LibrarySales.CreateCustomer(Customer);
        Quantity := LibraryRandom.RandIntInRange(1, 10);

        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Invoice, Customer."No.");
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, Item."No.", Quantity);
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, Item."No.", Quantity);
    end;

    local procedure VerifyTotals(var SalesHeader: Record "Sales Header"; ExpectedInvDiscValue: Decimal; ExpectedInvDiscType: Option)
    var
        SalesInvoiceEntityAggregate: Record "Sales Invoice Entity Aggregate";
    begin
        SalesHeader.FIND();
        SalesHeader.CALCFIELDS(Amount, "Amount Including VAT", "Invoice Discount Amount", "Recalculate Invoice Disc.");
        Assert.AreEqual(ExpectedInvDiscType, SalesHeader."Invoice Discount Calculation", 'Wrong invoice discount type');
        Assert.AreEqual(ExpectedInvDiscValue, SalesHeader."Invoice Discount Value", 'Wrong invoice discount value');
        Assert.IsFalse(SalesHeader."Recalculate Invoice Disc.", 'Recalculate inv. discount should be false');

        IF ExpectedInvDiscValue = 0 THEN
            Assert.AreEqual(0, SalesHeader."Invoice Discount Amount", 'Wrong sales invoice discount amount')
        ELSE
            Assert.IsTrue(SalesHeader."Invoice Discount Amount" > 0, 'Invoice discount amount value is wrong');

        // Verify Aggregate table
        SalesInvoiceEntityAggregate.GET(SalesHeader."No.", FALSE);
        Assert.AreEqual(SalesHeader.Amount, SalesInvoiceEntityAggregate.Amount, 'Amount was not updated on Aggregate Table');
        Assert.AreEqual(
          SalesHeader."Amount Including VAT", SalesInvoiceEntityAggregate."Amount Including VAT",
          'Amount Including VAT was not updated on Aggregate Table');
        Assert.AreEqual(
          SalesHeader."Amount Including VAT" - SalesHeader.Amount, SalesInvoiceEntityAggregate."Total Tax Amount",
          'Total Tax Amount was not updated on Aggregate Table');
        Assert.AreEqual(
          SalesHeader."Invoice Discount Amount", SalesInvoiceEntityAggregate."Invoice Discount Amount",
          'Amount was not updated on Aggregate Table');
    end;

    local procedure FindFirstSalesLine(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line")
    begin
        SalesLine.SETRANGE("Document Type", SalesHeader."Document Type");
        SalesLine.SETRANGE("Document No.", SalesHeader."No.");
        SalesLine.FINDFIRST();
    end;

    local procedure SetupAmountDiscountTest(var SalesHeader: Record "Sales Header"; var DiscountAmount: Decimal)
    var
        Customer: Record "Customer";
        Item: Record "Item";
        SalesCalcDiscountByType: Codeunit "Sales - Calc Discount By Type";
    begin
        CreateInvoiceWithTwoLines(SalesHeader, Customer, Item);
        SalesHeader.CALCFIELDS(Amount);
        DiscountAmount := LibraryRandom.RandDecInDecimalRange(1, SalesHeader.Amount / 2, 2);
        SalesCalcDiscountByType.ApplyInvDiscBasedOnAmt(DiscountAmount, SalesHeader);
    end;

    local procedure VerifyUoMInJson(JSONObjectTxt: Text; UnitOfMeasure: Record "Unit of Measure")
    var
        JSONUoMValue: Text;
        UoMCodeValue: Text;
        UoMIdValue: Text;
        UoMGUID: Guid;
    begin
        Assert.IsTrue(LibraryGraphMgt.GetComplexPropertyTxtFromJSON(JSONObjectTxt, UoMComplexTypeNameTxt, JSONUoMValue),
          'Could not find the UnitOfMeasure complex type in' + JSONObjectTxt);
        Assert.AreNotEqual('null', JSONUoMValue, 'UnitOfMeasure complex type should not be null in ' + JSONObjectTxt);
        Assert.IsTrue(LibraryGraphMgt.GetPropertyValueFromJSON(JSONObjectTxt, UoMIdTxt, UoMIdValue),
          'Could not find the UnitOfMeasureId in' + JSONObjectTxt);
        UoMGUID := UoMIdValue;
        Assert.AreEqual(UnitOfMeasure.SystemId, UoMGUID, 'UnitOfMeasure Id should be ' + UoMIdValue);

        Assert.IsTrue(LibraryGraphMgt.GetPropertyValueFromJSON(JSONUoMValue, UoMComplexTypeCodeNameTxt, UoMCodeValue),
          'Could not find the UnitOfMeasure code in' + JSONObjectTxt);
        Assert.AreEqual(UnitOfMeasure.Code, UoMCodeValue, 'UnitOfMeasure code complex type should not be null in ' + JSONObjectTxt);
    end;
}
