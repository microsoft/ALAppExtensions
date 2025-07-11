codeunit 139874 "APIV2 - Purch. Cr.M. Lines E2E"
{
    // version Test,ERM,W1,All

    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Graph] [Purchase] [Credit Memo]
    end;

    var
        Assert: Codeunit "Assert";
        APIV2SalesInvLinesE2E: Codeunit "APIV2 - Sales Inv. Lines E2E";
        LibraryGraphMgt: Codeunit "Library - Graph Mgt";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryGraphDocumentTools: Codeunit "Library - Graph Document Tools";
        LibraryRandom: Codeunit "Library - Random";
        LibraryPurchase: Codeunit "Library - Purchase";
        CreditMemoServiceNameTxt: Label 'purchaseCreditMemos';
        CreditMemoServiceLinesNameTxt: Label 'purchaseCreditMemoLines';
        LineTypeFieldNameTxt: Label 'lineType';

    [Test]
    procedure TestFailsOnIDAbsense()
    var
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] Call GET on the lines without providing a parent Credit Memo ID.
        // [GIVEN] the credit memo API exposedSetAutoCalcFields

        // [WHEN] we GET all the lines without an ID from the web service
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage('',
            Page::"APIV2 - Purchase Credit Memos",
            CreditMemoServiceNameTxt,
            CreditMemoServiceLinesNameTxt);
        asserterror LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] the response text should be empty
        Assert.AreEqual('', ResponseText, 'Response JSON should be blank');
    end;

    [Test]
    procedure TestGetCreditMemoLineDirectly()
    var
        PurchaseLine: Record "Purchase Line";
        PurchaseHeader: Record "Purchase Header";
        ResponseText: Text;
        TargetURL: Text;
        CreditMemoId: Text;
        LineNo: Integer;
        SequenceValue: Text;
    begin
        // [SCENARIO] Call GET on the Line of a credit memo
        // [GIVEN] a credit memo with a line.SetAutoCalcFields
        CreditMemoId := CreatePurchaseCreditMemoWithLines(PurchaseHeader);

        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type"::"Credit Memo");
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        PurchaseLine.FindFirst();
        LineNo := PurchaseLine."Line No.";

        // [WHEN] we GET all the lines with the credit memo ID from the web service
        TargetURL := APIV2SalesInvLinesE2E.GetLinesURL(PurchaseLine.SystemId, Page::"APIV2 - Purchase Credit Memos", CreditMemoServiceNameTxt, CreditMemoServiceLinesNameTxt);
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] the line returned should be valid (numbers and integration id)
        Assert.AreNotEqual('', ResponseText, 'Response JSON should not be blank');
        LibraryGraphMgt.VerifyIDFieldInJson(ResponseText, 'documentId');
        LibraryGraphMgt.GetPropertyValueFromJSON(ResponseText, 'sequence', SequenceValue);
        Assert.AreEqual(SequenceValue, Format(LineNo), 'The sequence value is wrong.');
    end;

    [Test]
    procedure TestGetCreditMemoLines()
    var
        PurchaseLine: Record "Purchase Line";
        PurchaseHeader: Record "Purchase Header";
        ResponseText: Text;
        CreditMemoID: Text;
        LineNo1: Text;
        LineNo2: Text;
    begin
        // [SCENARIO] Call GET on the Lines of a unposted Credit Memo
        // [GIVEN] An credit memo with lines.SetAutoCalcFields
        CreditMemoID := CreatePurchaseCreditMemoWithLines(PurchaseHeader);

        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type"::"Credit Memo");
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        PurchaseLine.FindFirst();
        LineNo1 := Format(PurchaseLine."Line No.");
        PurchaseLine.FindLast();
        LineNo2 := Format(PurchaseLine."Line No.");

        // [WHEN] we GET all the lines with the unposted credit memo ID from the web service
        GetCreditMemoLinesThroughAPI(CreditMemoID, ResponseText);

        // [THEN] the lines returned should be valid (numbers and integration ids)
        VerifyCreditMemoLines(ResponseText, LineNo1, LineNo2);
    end;

    [Test]
    procedure TestGetCreditMemoLinesDirectlyWithDocumentIdFilter()
    var
        PurchaseLine: Record "Purchase Line";
        PurchaseHeader: Record "Purchase Header";
        ResponseText: Text;
        TargetURL: Text;
        CreditMemoId: Text;
        LineNo1: Text;
        LineNo2: Text;
    begin
        // [SCENARIO] Call GET on the Lines of a credit memo
        // [GIVEN] a credit memo with lines.SetAutoCalcFields
        CreditMemoId := CreatePurchaseCreditMemoWithLines(PurchaseHeader);

        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type"::"Credit Memo");
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        PurchaseLine.FindFirst();
        LineNo1 := Format(PurchaseLine."Line No.");
        PurchaseLine.FindLast();
        LineNo2 := Format(PurchaseLine."Line No.");

        // [WHEN] we GET all the lines with the credit memo ID from the web service
        TargetURL := APIV2SalesInvLinesE2E.GetLinesURLWithDocumentIdFilter(CreditMemoId, Page::"APIV2 - Purchase Credit Memos", CreditMemoServiceNameTxt, CreditMemoServiceLinesNameTxt);
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] the lines returned should be valid (numbers and integration ids)
        VerifyCreditMemoLines(ResponseText, LineNo1, LineNo2);
    end;

    [Test]
    procedure TestGetPostedCreditMemoLines()
    var
        PurchCrMemoLine: Record "Purch. Cr. Memo Line";
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        ResponseText: Text;
        CreditMemoID: Text;
        LineNo1: Text;
        LineNo2: Text;
    begin
        // [SCENARIO] Call GET on the Lines of a posted Credit Memo
        // [GIVEN] A posted credit memo with lines.SetAutoCalcFields
        CreditMemoID := CreatePostedPurchaseCreditMemoWithLines(PurchCrMemoHdr);

        PurchCrMemoLine.SetRange("Document No.", PurchCrMemoHdr."No.");
        PurchCrMemoLine.FindFirst();
        LineNo1 := Format(PurchCrMemoLine."Line No.");
        PurchCrMemoLine.FindLast();
        LineNo2 := Format(PurchCrMemoLine."Line No.");

        // [WHEN] we GET all the lines with the posted credit memo ID from the web service
        GetCreditMemoLinesThroughAPI(CreditMemoID, ResponseText);

        // [THEN] the response text should contain the credit memo ID
        VerifyCreditMemoLines(ResponseText, LineNo1, LineNo2);
    end;

    [Test]
    procedure TestPostCreditMemoLines()
    var
        Item: Record "Item";
        PurchaseHeader: Record "Purchase Header";
        ResponseText: Text;
        CreditMemoLineJSON: Text;
        LineNoFromJSON: Text;
        CreditMemoID: Text;
        LineNo: Integer;
    begin
        // [SCENARIO] POST a new line to an unposted Credit Memo
        // [GIVEN] An existing unposted credit memo and a valid JSON describing the new credit memo lineSetAutoCalcFields
        CreditMemoID := CreatePurchaseCreditMemoWithLines(PurchaseHeader);
        LibraryInventory.CreateItem(Item);

        CreditMemoLineJSON := CreateCreditMemoLineJSON(Item.SystemId, LibraryRandom.RandIntInRange(1, 100));
        Commit();

        // [WHEN] we POST the JSON to the web service
        CreateCreditMemoLinesThroughAPI(CreditMemoID, CreditMemoLineJSON, ResponseText);

        // [THEN] the response text should contain the credit memo ID and the change should exist in the database
        Assert.AreNotEqual('', ResponseText, 'response JSON should not be blank');
        Assert.IsTrue(
          LibraryGraphMgt.GetObjectIDFromJSON(ResponseText, 'sequence', LineNoFromJSON), 'Could not find sequence');

        Evaluate(LineNo, LineNoFromJSON);
        VerifyPurchaseCreditMemoLineExists(PurchaseHeader, LineNo, 'The unposted credit memo line should exist');
    end;

    [Test]
    procedure TestPostCreditMemoLineWithSequence()
    var
        Item: Record "Item";
        PurchaseHeader: Record "Purchase Header";
        ResponseText: Text;
        CreditMemoLineJSON: Text;
        LineNoFromJSON: Text;
        CreditMemoID: Text;
        LineNo: Integer;
    begin
        // [SCENARIO] POST a new line to an unposted Credit Memo with a sequence number
        // [GIVEN] An existing unposted credit memo and a valid JSON describing the new credit memo lineSetAutoCalcFields
        CreditMemoID := CreatePurchaseCreditMemoWithLines(PurchaseHeader);
        LibraryInventory.CreateItem(Item);

        CreditMemoLineJSON := CreateCreditMemoLineJSON(Item.SystemId, LibraryRandom.RandIntInRange(1, 100));
        LineNo := 500;
        CreditMemoLineJSON := LibraryGraphMgt.AddPropertytoJSON(CreditMemoLineJSON, 'sequence', LineNo);
        Commit();

        // [WHEN] we POST the JSON to the web service
        CreateCreditMemoLinesThroughAPI(CreditMemoID, CreditMemoLineJSON, ResponseText);

        // [THEN] the response text should contain the correct sequence and exist in the database
        Assert.AreNotEqual('', ResponseText, 'response JSON should not be blank');
        Assert.IsTrue(
          LibraryGraphMgt.GetObjectIDFromJSON(ResponseText, 'sequence', LineNoFromJSON), 'Could not find sequence');
        Assert.AreEqual(Format(LineNo), LineNoFromJSON, 'The sequence in the response does not exist of the one that was given.');

        Evaluate(LineNo, LineNoFromJSON);
        VerifyPurchaseCreditMemoLineExists(PurchaseHeader, LineNo, 'The unposted credit memo line should exist');

        Evaluate(LineNo, LineNoFromJSON);
        VerifyPurchaseCreditMemoLineExists(PurchaseHeader, LineNo, 'The unposted credit memo line should exist');
    end;

    [Test]
    procedure TestModifyCreditMemoLines()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        ResponseText: Text;
        CreditMemoLineJSON: Text;
        LineNo: Integer;
        CreditMemoID: Text;
        PurchaseQuantity: Integer;
        PurchaseQuantityFromJSON: Text;
    begin
        // [SCENARIO] PATCH a line of an unposted Credit Memo
        // [GIVEN] An unposted credit memo with lines and a valid JSON describing the fields that we want to changeSetAutoCalcFields
        CreditMemoID := CreatePurchaseCreditMemoWithLines(PurchaseHeader);
        Assert.AreNotEqual('', CreditMemoID, 'ID should not be empty');
        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type"::"Credit Memo");
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        PurchaseLine.FindFirst();
        LineNo := PurchaseLine."Line No.";

        PurchaseQuantity := 4;
        CreditMemoLineJSON := LibraryGraphMgt.AddComplexTypetoJSON('{}', 'quantity', Format(PurchaseQuantity));

        // [WHEN] we PATCH the line
        ModifyCreditMemoLinesThroughAPI(CreditMemoID, PurchaseLine.SystemId, CreditMemoLineJSON, ResponseText);

        // [THEN] the line should be changed in the table and the response JSON text should contain our changed field
        Assert.AreNotEqual('', ResponseText, 'Response JSON should not be blank');

        GetPurchaseCreditMemoLine(PurchaseHeader, PurchaseLine, LineNo, 'The unposted credit memo line should exist after modification');
        Assert.AreEqual(PurchaseLine.Quantity, PurchaseQuantity, 'The patch of Purchase line quantity was unsuccessful');

        Assert.IsTrue(LibraryGraphMgt.GetPropertyValueFromJSON(ResponseText, 'quantity', PurchaseQuantityFromJSON),
          'Could not find the quantity property in' + ResponseText);
        Assert.AreNotEqual('', PurchaseQuantityFromJSON, 'Quantity should not be blank in ' + ResponseText);
    end;

    [Test]
    procedure TestModifyCreditMemoLineFailsOnSequenceIdOrDocumentIdChange()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        ResponseText: Text;
        TargetURL: Text;
        CreditMemoLineJSON: Array[2] of Text;
        CreditMemoId: Text;
        NewSequence: Integer;
    begin
        // [SCENARIO] PATCH a line of a credit memo will fail if sequence is modified
        // [GIVEN] A credit memo with lines and a valid JSON describing the fields that we want to changeSetAutoCalcFields
        CreditMemoId := CreatePurchaseCreditMemoWithLines(PurchaseHeader);
        Assert.AreNotEqual('', CreditMemoId, 'ID should not be empty');
        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type"::"Credit Memo");
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        PurchaseLine.FindFirst();

        NewSequence := PurchaseLine."Line No." + 1;
        CreditMemoLineJSON[1] := LibraryGraphMgt.AddPropertytoJSON('', 'sequence', NewSequence);
        CreditMemoLineJSON[2] := LibraryGraphMgt.AddPropertytoJSON('', 'documentId', LibraryGraphMgt.StripBrackets(CreateGuid()));

        // [WHEN] we PATCH the line
        // [THEN] the request will fail
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            CreditMemoId,
            Page::"APIV2 - Purchase Credit Memos",
            CreditMemoServiceNameTxt,
            APIV2SalesInvLinesE2E.GetLineSubURL(PurchaseLine.SystemId, CreditMemoServiceLinesNameTxt));
        asserterror LibraryGraphMgt.PatchToWebService(TargetURL, CreditMemoLineJSON[1], ResponseText);

        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            CreditMemoId,
            Page::"APIV2 - Purchase Credit Memos",
            CreditMemoServiceNameTxt,
            APIV2SalesInvLinesE2E.GetLineSubURL(PurchaseLine.SystemId, CreditMemoServiceLinesNameTxt));
        asserterror LibraryGraphMgt.PatchToWebService(TargetURL, CreditMemoLineJSON[2], ResponseText);
    end;


    [Test]
    procedure TestDeleteCreditMemoLine()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        CreditMemoID: Text;
        LineNo: Integer;
    begin
        // [SCENARIO] DELETE a line from an unposted Credit Memo
        // [GIVEN] An unposted credit memo with linesSetAutoCalcFields
        CreditMemoID := CreatePurchaseCreditMemoWithLines(PurchaseHeader);

        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type"::"Credit Memo");
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        PurchaseLine.FindFirst();
        LineNo := PurchaseLine."Line No.";

        Commit();

        // [WHEN] we DELETE the first line of that credit memo
        DeleteCreditMemoLineThroughAPI(CreditMemoID, PurchaseLine.SystemId);

        // [THEN] the line should no longer exist in the database
        PurchaseLine.Reset();
        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type"::"Credit Memo");
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        PurchaseLine.SetRange("Line No.", LineNo);
        Assert.IsTrue(PurchaseLine.IsEmpty(), 'The credit memo line should not exist');
    end;

    [Test]
    procedure TestDeletePostedCreditMemoLine()
    var
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        PurchCrMemoLine: Record "Purch. Cr. Memo Line";
        CreditMemoID: Text;
        LineNo: Integer;
    begin
        // [SCENARIO] Call DELETE on a line of a posted Credit Memo
        // [GIVEN] A posted credit memo with linesSetAutoCalcFields
        CreditMemoID := CreatePostedPurchaseCreditMemoWithLines(PurchCrMemoHdr);

        PurchCrMemoLine.SetRange("Document No.", PurchCrMemoHdr."No.");
        PurchCrMemoLine.FindFirst();
        LineNo := PurchCrMemoLine."Line No.";

        // [WHEN] we DELETE the first line through the API
        asserterror DeleteCreditMemoLineThroughAPI(CreditMemoID, PurchCrMemoLine.SystemId);
        Assert.ExpectedError('credit memo has been posted');
        // [THEN] the line should still exist, since it's not allowed to delete lines in posted credit memos
        PurchCrMemoLine.Reset();
        PurchCrMemoLine.SetRange("Document No.", PurchCrMemoHdr."No.");
        PurchCrMemoLine.SetRange("Line No.", LineNo);
        Assert.IsFalse(PurchCrMemoLine.IsEmpty(), 'The credit memo line should still exist');
    end;

    [Test]
    procedure TestCreateLineThroughPageAndAPI()
    var
        PurchaseHeader: Record "Purchase Header";
        Item: Record "Item";
        Vendor: Record Vendor;
        ApiPurchaseLine: Record "Purchase Line";
        PagePurchaseLine: Record "Purchase Line";
        PurchaseCreditMemo: TestPage "Purchase Credit Memo";
        ResponseText: Text;
        CreditMemoLineJSON: Text;
        LineNoFromJSON: Text;
        CreditMemoID: Text;
        LineNo: Integer;
        ItemQuantity: Integer;
        ItemNo: Code[20];
        VendorNo: Code[20];
    begin
        // [SCENARIO] Create an credit memo both through the client UI and through the API and compare their final values.
        // [GIVEN] An unposted credit memo and a JSON describing the line we want to create
        LibraryPurchase.CreateVendor(Vendor);
        VendorNo := Vendor."No.";
        ItemNo := LibraryInventory.CreateItem(Item);
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, PurchaseHeader."Document Type"::"Credit Memo", VendorNo);
        CreditMemoID := PurchaseHeader.SystemId;
        ItemQuantity := LibraryRandom.RandIntInRange(1, 100);
        CreditMemoLineJSON := CreateCreditMemoLineJSON(Item.SystemId, ItemQuantity);
        Commit();

        // [WHEN] we POST the JSON to the web service and when we create an credit memo through the client UI
        CreateCreditMemoLinesThroughAPI(CreditMemoID, CreditMemoLineJSON, ResponseText);
        CreateCreditMemoAndLinesThroughPage(PurchaseCreditMemo, VendorNo, ItemNo, ItemQuantity);

        // [THEN] the response text should be valid, the credit memo line should exist in the tables and the two credit memos have the same field values.
        Assert.AreNotEqual('', ResponseText, 'response JSON should not be blank');
        Assert.IsTrue(
          LibraryGraphMgt.GetObjectIDFromJSON(ResponseText, 'sequence', LineNoFromJSON), 'Could not find sequence');

        Evaluate(LineNo, LineNoFromJSON);
        GetPurchaseCreditMemoLine(PurchaseHeader, ApiPurchaseLine, LineNo, 'The unposted credit memo line should exist');

        PagePurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type"::"Credit Memo");
        PagePurchaseLine.SetRange("Document No.", PurchaseCreditMemo."No.".Value());
        Assert.IsTrue(PagePurchaseLine.FindFirst(), 'The unposted credit memo line should exist');

        VerifyCreditMemoLinesMatching(ApiPurchaseLine, PagePurchaseLine);
    end;

    [Test]
    procedure TestGettingLinesWithDifferentTypes()
    var
        PurchaseHeader: Record "Purchase Header";
        ExpectedNumberOfLines: Integer;
        ResponseText: Text;
        LinesJSON: Text;
    begin
        // [SCENARIO] Getting a line through API lists all possible types
        // [GIVEN] An credit memo with lines of different typesSetAutoCalcFields
        CreateCreditMemoWithDifferentLineTypes(PurchaseHeader, ExpectedNumberOfLines);

        Commit();

        // [WHEN] we GET the lines
        GetCreditMemoLinesThroughAPI(PurchaseHeader.SystemId, ResponseText);

        // [THEN] All lines are shown in the response
        LibraryGraphMgt.GetPropertyValueFromJSON(ResponseText, 'value', LinesJSON);

        Assert.AreEqual(ExpectedNumberOfLines, LibraryGraphMgt.GetCollectionCountFromJSON(LinesJSON), 'Four lines should be returned');
        VerifyPurchaseCreditMemoLinesForPurchaseHeader(PurchaseHeader, LinesJSON);
    end;

    [Test]
    procedure TestPostingBlankLineDefaultsToCommentType()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        TargetURL: Text;
        ResponseText: Text;
        CreditMemoLineJSON: Text;
    begin
        // [SCENARIO] Posting a line with description only will get a type item
        // [GIVEN] A post request with description onlySetAutoCalcFields
        CreatePurchaseCreditMemoWithLines(PurchaseHeader);

        Commit();

        CreditMemoLineJSON := '{"description":"test"}';

        // [WHEN] we just POST a blank line
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            PurchaseHeader.SystemId,
            Page::"APIV2 - Purchase Credit Memos",
            CreditMemoServiceNameTxt,
            CreditMemoServiceLinesNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, CreditMemoLineJSON, ResponseText);

        // [THEN] Line of type Item is created
        FindFirstPurchaseLine(PurchaseHeader, PurchaseLine);
        PurchaseLine.FindLast();
        Assert.AreEqual('', PurchaseLine."No.", 'No should be blank');
        Assert.AreEqual(PurchaseLine.Type, PurchaseLine.Type::" ", 'Wrong type is set');

        VerifyIdsAreBlank(ResponseText);
    end;

    [Test]
    procedure TestPostingCommentLine()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        TargetURL: Text;
        ResponseText: Text;
        CreditMemoLineJSON: Text;
    begin
        // [FEATURE] [Comment]
        // [SCENARIO] Posting a line with Type Comment and description will make a comment line
        // [GIVEN] A post request with type and descriptionSetAutoCalcFields
        CreatePurchaseCreditMemoWithLines(PurchaseHeader);

        CreditMemoLineJSON := '{"' + LineTypeFieldNameTxt + '":"Comment","description":"test"}';

        Commit();

        // [WHEN] we just POST a blank line
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            PurchaseHeader.SystemId,
            Page::"APIV2 - Purchase Credit Memos",
            CreditMemoServiceNameTxt,
            CreditMemoServiceLinesNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, CreditMemoLineJSON, ResponseText);

        // [THEN] Line of type Item is created
        FindFirstPurchaseLine(PurchaseHeader, PurchaseLine);
        PurchaseLine.FindLast();
        Assert.AreEqual(PurchaseLine.Type, PurchaseLine.Type::" ", 'Wrong type is set');
        Assert.AreEqual('test', PurchaseLine.Description, 'Wrong description is set');

        LibraryGraphDocumentTools.VerifyPurchaseObjectTxtDescriptionWithoutComplexType(PurchaseLine, ResponseText);
        VerifyIdsAreBlank(ResponseText);
    end;

    [Test]
    procedure TestPatchingTheIdToAccountChangesLineType()
    var
        PurchaseHeader: Record "Purchase Header";
        GLAccount: Record "G/L Account";
        PurchaseLine: Record "Purchase Line";
        ResponseText: Text;
        CreditMemoLineJSON: Text;
        CreditMemoID: Text;
    begin
        // [SCENARIO] PATCH a Type on a line of an unposted Credit Memo
        // [GIVEN] An unposted credit memo with lines and a valid JSON describing the fields that we want to changeSetAutoCalcFields
        CreditMemoID := CreatePurchaseCreditMemoWithLines(PurchaseHeader);
        Assert.AreNotEqual('', CreditMemoID, 'ID should not be empty');
        FindFirstPurchaseLine(PurchaseHeader, PurchaseLine);

        GetGLAccount(GLAccount, PurchaseLine);
        CreditMemoLineJSON := StrSubstNo('{"accountId":"%1"}', LibraryGraphMgt.StripBrackets(GLAccount.SystemId));

        // [WHEN] we PATCH the line
        ModifyCreditMemoLinesThroughAPI(CreditMemoID, PurchaseLine.SystemId, CreditMemoLineJSON, ResponseText);

        // [THEN] Line type is changed to Account
        FindFirstPurchaseLine(PurchaseHeader, PurchaseLine);
        Assert.AreEqual(PurchaseLine.Type::"G/L Account", PurchaseLine.Type, 'Type was not changed');
        Assert.AreEqual(GLAccount."No.", PurchaseLine."No.", 'G/L Account No was not set');

        VerifyPurchaseLineResponseWithPurchaseLine(PurchaseLine, ResponseText);
    end;

    [Test]
    procedure TestPatchingTheIdToItemChangesLineType()
    var
        PurchaseHeader: Record "Purchase Header";
        Item: Record "Item";
        PurchaseLine: Record "Purchase Line";
        ExpectedNumberOfLines: Integer;
        ResponseText: Text;
        CreditMemoLineJSON: Text;
        CreditMemoLineID: Text;
    begin
        // [SCENARIO] PATCH a Type on a line of an unposted Credit Memo
        // [GIVEN] An unposted credit memo with lines and a valid JSON describing the fields that we want to changeSetAutoCalcFields
        CreateCreditMemoWithDifferentLineTypes(PurchaseHeader, ExpectedNumberOfLines);
        CreditMemoLineID := LibraryGraphMgt.StripBrackets(PurchaseHeader.SystemId);
        PurchaseLine.SetRange(Type, PurchaseLine.Type::"Fixed Asset");
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.FindFirst();
        PurchaseLine.SetRange(Type);

        Assert.AreNotEqual('', CreditMemoLineID, 'ID should not be empty');
        LibraryInventory.CreateItem(Item);

        CreditMemoLineJSON := StrSubstNo('{"itemId":"%1"}', LibraryGraphMgt.StripBrackets(Item.SystemId));
        Commit();

        // [WHEN] we PATCH the line
        ModifyCreditMemoLinesThroughAPI(PurchaseHeader.SystemId, PurchaseLine.SystemId, CreditMemoLineJSON, ResponseText);

        // [THEN] Line type is changed to Item and other fields are updated
        PurchaseLine.Find();
        Assert.AreEqual(PurchaseLine.Type::Item, PurchaseLine.Type, 'Type was not changed');
        Assert.AreEqual(Item."No.", PurchaseLine."No.", 'Item No was not set');

        VerifyPurchaseLineResponseWithPurchaseLine(PurchaseLine, ResponseText);
    end;

    [Test]
    procedure TestPatchingTheTypeBlanksIds()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchInvLineAggregate: Record "Purch. Inv. Line Aggregate";
        PurchaseLine: Record "Purchase Line";
        ResponseText: Text;
        CreditMemoLineJSON: Text;
        CreditMemoID: Text;
    begin
        // [SCENARIO] PATCH a Type on a line of an unposted Credit Memo
        // [GIVEN] An unposted credit memo with lines and a valid JSON describing the fields that we want to changeSetAutoCalcFields
        CreditMemoID := CreatePurchaseCreditMemoWithLines(PurchaseHeader);
        Assert.AreNotEqual('', CreditMemoID, 'ID should not be empty');
        FindFirstPurchaseLine(PurchaseHeader, PurchaseLine);

        CreditMemoLineJSON := StrSubstNo('{"%1":"%2"}', LineTypeFieldNameTxt, Format(PurchInvLineAggregate."API Type"::Account));

        // [WHEN] we PATCH the line
        ModifyCreditMemoLinesThroughAPI(CreditMemoID, PurchaseLine.SystemId, CreditMemoLineJSON, ResponseText);

        // [THEN] Line type is changed to Account
        FindFirstPurchaseLine(PurchaseHeader, PurchaseLine);
        Assert.AreEqual(PurchaseLine.Type::"G/L Account", PurchaseLine.Type, 'Type was not changed');
        Assert.AreEqual('', PurchaseLine."No.", 'No should be blank');

        VerifyIdsAreBlank(ResponseText);
    end;

    [Test]
    procedure TestPostCreditMemoLinesWithItemVariant()
    var
        Item: Record "Item";
        ItemVariant: Record "Item Variant";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        ItemNo: Code[20];
        ItemVariantCode: Code[10];
        ResponseText: Text;
        CreditMemoLineJSON: Text;
        LineNoFromJSON: Text;
        CreditMemoID: Text;
        LineNo: Integer;
    begin
        // [SCENARIO] POST a new line to an unposted Credit Memo with item variant
        // [GIVEN] An existing unposted credit memo and a valid JSON describing the new credit memo line with item variantSetAutoCalcFields
        CreditMemoID := CreatePurchaseCreditMemoWithLines(PurchaseHeader);
        ItemNo := LibraryInventory.CreateItem(Item);
        ItemVariantCode := LibraryInventory.CreateItemVariant(ItemVariant, ItemNo);
        Commit();

        // [WHEN] we POST the JSON to the web service
        CreditMemoLineJSON := CreateCreditMemoLineJSONWithItemVariantId(Item.SystemId, LibraryRandom.RandIntInRange(1, 100), ItemVariant.SystemId);
        CreateCreditMemoLinesThroughAPI(CreditMemoID, CreditMemoLineJSON, ResponseText);

        // [THEN] the response text should contain the credit memo ID and the change should exist in the database
        Assert.AreNotEqual('', ResponseText, 'response JSON should not be blank');
        Assert.IsTrue(
          LibraryGraphMgt.GetObjectIDFromJSON(ResponseText, 'sequence', LineNoFromJSON), 'Could not find sequence');

        Evaluate(LineNo, LineNoFromJSON);
        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type"::"Credit Memo");
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        PurchaseLine.SetRange("Line No.", LineNo);
        PurchaseLine.SetRange("Variant Code", ItemVariantCode);
        Assert.IsFalse(PurchaseHeader.IsEmpty(), 'The unposted credit memo line should exist');
    end;

    [Test]
    procedure TestPostCreditMemoLinesWithWrongItemVariant()
    var
        Item1: Record "Item";
        Item2: Record "Item";
        ItemVariant: Record "Item Variant";
        PurchaseHeader: Record "Purchase Header";
        ItemNo2: Code[20];
        ResponseText: Text;
        CreditMemoLineJSON: Text;
        CreditMemoID: Text;
    begin
        // [SCENARIO] POST a new line to an unposted Credit Memo with wrong item variant
        // [GIVEN] An existing unposted credit memo and a valid JSON describing the new credit memo line with item variantSetAutoCalcFields
        CreditMemoID := CreatePurchaseCreditMemoWithLines(PurchaseHeader);
        LibraryInventory.CreateItem(Item1);
        ItemNo2 := LibraryInventory.CreateItem(Item2);
        LibraryInventory.CreateItemVariant(ItemVariant, ItemNo2);
        Commit();

        // [WHEN] we POST the JSON to the web service
        CreditMemoLineJSON := CreateCreditMemoLineJSONWithItemVariantId(Item1.SystemId, LibraryRandom.RandIntInRange(1, 100), ItemVariant.SystemId);

        // [THEN] the request will fail
        asserterror CreateCreditMemoLinesThroughAPI(CreditMemoID, CreditMemoLineJSON, ResponseText);
    end;

    local procedure CreateCreditMemoWithDifferentLineTypes(var PurchaseHeader: Record "Purchase Header"; var ExpectedNumberOfLines: Integer)
    var
        PurchaseLine: Record "Purchase Line";
    begin
        CreatePurchaseCreditMemoWithLines(PurchaseHeader);
        CreateLinesWithDifferentTypes(PurchaseHeader);

        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
        ExpectedNumberOfLines := PurchaseLine.Count();
    end;

    local procedure CreatePurchaseCreditMemoWithLines(var PurchaseHeader: Record "Purchase Header"): Text
    var
        PurchaseLine: Record "Purchase Line";
        Item: Record "Item";
    begin
        LibraryPurchase.CreatePurchaseCreditMemo(PurchaseHeader);
        LibraryInventory.CreateItem(Item);
        LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, PurchaseLine.Type::Item, Item."No.", 2);
        Commit();
        exit(PurchaseHeader.SystemId);
    end;

    local procedure CreatePostedPurchaseCreditMemoWithLines(var PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr."): Text
    var
        PurchaseLine: Record "Purchase Line";
        Item: Record "Item";
        PurchaseHeader: Record "Purchase Header";
        LibraryERMCountryData: Codeunit "Library - ERM Country Data";
        PostedPurchaseCreditMemoID: Text;
        NewNo: Code[20];
    begin
        LibraryERMCountryData.UpdatePurchasesPayablesSetup();
        LibraryPurchase.CreatePurchaseCreditMemo(PurchaseHeader);
        LibraryInventory.CreateItem(Item);
        LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, PurchaseLine.Type::Item, Item."No.", 2);
        PostedPurchaseCreditMemoID := PurchaseHeader.SystemId;
        NewNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, false, true);
        Commit();

        PurchCrMemoHdr.Reset();
        PurchCrMemoHdr.SetFilter("No.", NewNo);
        PurchCrMemoHdr.FindFirst();

        exit(PostedPurchaseCreditMemoID);
    end;

    [Normal]
    local procedure CreateCreditMemoLineJSON(ItemId: Guid; Quantity: Integer): Text
    var
        LineJSON: Text;
    begin
        LineJSON := LibraryGraphMgt.AddPropertytoJSON('', 'itemId', LibraryGraphMgt.StripBrackets(ItemId));
        LineJSON := LibraryGraphMgt.AddComplexTypetoJSON(LineJSON, 'quantity', Format(Quantity));

        exit(LineJSON);
    end;

    local procedure CreateCreditMemoLineJSONWithItemVariantId(ItemId: Guid; Quantity: Integer; ItemVariantId: Guid): Text
    var
        LineJSON: Text;
    begin
        LineJSON := CreateCreditMemoLineJSON(ItemId, Quantity);
        LineJSON := LibraryGraphMgt.AddPropertytoJSON(LineJSON, 'itemVariantId', LibraryGraphMgt.StripBrackets(ItemVariantId));
        exit(LineJSON);
    end;

    local procedure CreateCreditMemoAndLinesThroughPage(var PurchaseCreditMemo: TestPage "Purchase Credit Memo"; VendorNo: Text; ItemNo: Text; ItemQuantity: Integer)
    var
        PurchaseLine: Record "Purchase Line";
    begin
        PurchaseCreditMemo.OpenNew();
        PurchaseCreditMemo."Buy-from Vendor No.".SetValue(VendorNo);

        PurchaseCreditMemo.PurchLines.LAST();
        PurchaseCreditMemo.PurchLines.next();
        PurchaseCreditMemo.PurchLines.FilteredTypeField.SetValue(PurchaseLine.Type::Item);
        PurchaseCreditMemo.PurchLines."No.".SetValue(ItemNo);

        PurchaseCreditMemo.PurchLines.Quantity.SetValue(ItemQuantity);

        // Trigger Save
        PurchaseCreditMemo.PurchLines.next();
        PurchaseCreditMemo.PurchLines.Previous();
    end;

    local procedure GetCreditMemoLinesThroughAPI(CreditMemoID: Text; var ResponseText: Text)
    var
        TargetURL: Text;
    begin
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(CreditMemoID,
            Page::"APIV2 - Purchase Credit Memos",
            CreditMemoServiceNameTxt,
            CreditMemoServiceLinesNameTxt);
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);
    end;

    local procedure CreateCreditMemoLinesThroughAPI(CreditMemoID: Text; CreditMemoLineJSON: Text; var ResponseText: Text)
    var
        TargetURL: Text;
    begin
        TargetURL := LibraryGraphMgt.CreateTargetURLWithSubpage(
            CreditMemoID,
            Page::"APIV2 - Purchase Credit Memos",
            CreditMemoServiceNameTxt,
            CreditMemoServiceLinesNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, CreditMemoLineJSON, ResponseText);
    end;

    local procedure ModifyCreditMemoLinesThroughAPI(CreditMemoID: Text; LineId: Guid; CreditMemoLineJSON: Text; var ResponseText: Text)
    var
        TargetURL: Text;
    begin
        TargetURL := LibraryGraphMgt.CreateTargetURLWithSubpage(
            CreditMemoID,
            Page::"APIV2 - Purchase Credit Memos",
            CreditMemoServiceNameTxt,
            APIV2SalesInvLinesE2E.GetLineSubURL(LineId, CreditMemoServiceLinesNameTxt));
        LibraryGraphMgt.PatchToWebService(TargetURL, CreditMemoLineJSON, ResponseText);
    end;

    local procedure DeleteCreditMemoLineThroughAPI(CreditMemoID: Text; LineId: Guid)
    var
        ResponseText: Text;
        TargetURL: Text;
    begin
        TargetURL := LibraryGraphMgt.CreateTargetURLWithSubpage(
            CreditMemoID,
            Page::"APIV2 - Purchase Credit Memos",
            CreditMemoServiceNameTxt,
            APIV2SalesInvLinesE2E.GetLineSubURL(LineId, CreditMemoServiceLinesNameTxt));
        LibraryGraphMgt.DeleteFromWebService(TargetURL, '', ResponseText);
    end;

    local procedure GetGLAccount(var GLAccount: Record "G/L Account"; var PurchaseLine: Record "Purchase Line")
    var
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        GLAccount.SetRange("Account Type", GLAccount."Account Type"::Posting);
        GLAccount.SetRange("Direct Posting", true);
        GLAccount.FindFirst();
        if not VATPostingSetup.Get(PurchaseLine."VAT Bus. Posting Group", GLAccount."VAT Prod. Posting Group") then begin
            VATPostingSetup.Init();
            VATPostingSetup."VAT Bus. Posting Group" := PurchaseLine."VAT Bus. Posting Group";
            VATPostingSetup."VAT Prod. Posting Group" := GLAccount."VAT Prod. Posting Group";
            VATPostingSetup.Insert();
            Commit();
        end;
    end;

    local procedure VerifyCreditMemoLines(ResponseText: Text; LineNo1: Text; LineNo2: Text)
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
          'Could not find the credit memo lines in JSON');
        LibraryGraphMgt.VerifyIDFieldInJson(LineJSON1, 'documentId');
        LibraryGraphMgt.VerifyIDFieldInJson(LineJSON2, 'documentId');
        LibraryGraphMgt.GetObjectIDFromJSON(LineJSON1, 'itemId', ItemId1);
        LibraryGraphMgt.GetObjectIDFromJSON(LineJSON2, 'itemId', ItemId2);
        Assert.AreNotEqual(ItemId1, ItemId2, 'Item Ids should be different for different items');
    end;

    local procedure VerifyPurchaseCreditMemoLinesForPurchaseHeader(var PurchaseHeader: Record "Purchase Header"; JsonObjectTxt: Text)
    var
        PurchaseLine: Record "Purchase Line";
        CurrentIndex: Integer;
    begin
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.FindSet();
        CurrentIndex := 0;

        repeat
            VerifyPurchaseLineResponseWithPurchaseLine(PurchaseLine, LibraryGraphMgt.GetObjectFromCollectionByIndex(JsonObjectTxt, CurrentIndex));
            CurrentIndex += 1;
        until PurchaseLine.next() = 0;
    end;

    local procedure VerifyPurchaseLineResponseWithPurchaseLine(var PurchaseLine: Record "Purchase Line"; JsonObjectTxt: Text)
    begin
        LibraryGraphDocumentTools.VerifyPurchaseObjectTxtDescriptionWithoutComplexType(PurchaseLine, JsonObjectTxt);
        LibraryGraphDocumentTools.VerifyPurchaseIdsSetFromTxt(PurchaseLine, JsonObjectTxt);
    end;

    local procedure VerifyIdsAreBlank(JsonObjectTxt: Text)
    var
        itemId: Text;
        accountId: Text;
        ExpectedId: Text;
        BlankGuid: Guid;
    begin
        ExpectedId := LibraryGraphMgt.StripBrackets(BlankGuid);

        Assert.IsTrue(LibraryGraphMgt.GetPropertyValueFromJSON(JsonObjectTxt, 'itemId', itemId), 'Could not find itemId');
        Assert.IsTrue(LibraryGraphMgt.GetPropertyValueFromJSON(JsonObjectTxt, 'accountId', accountId), 'Could not find accountId');

        Assert.AreEqual(Uppercase(ExpectedId), Uppercase(accountId), 'Account id should be blank');
        Assert.AreEqual(Uppercase(ExpectedId), Uppercase(itemId), 'Item id should be blank');
    end;

    local procedure FindFirstPurchaseLine(var PurchaseHeader: Record "Purchase Header"; var PurchaseLine: Record "Purchase Line")
    begin
        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        PurchaseLine.FindFirst();
    end;

    local procedure GetPurchaseCreditMemoLine(var PurchaseHeader: Record "Purchase Header"; var PurchaseLine: Record "Purchase Line"; LineNo: Integer; ErrorMessage: Text)
    begin
        PurchaseLine.Reset();
        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type"::"Credit Memo");
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        PurchaseLine.SetRange("Line No.", LineNo);
        Assert.IsTrue(PurchaseLine.FindFirst(), ErrorMessage);
    end;

    local procedure VerifyPurchaseCreditMemoLineExists(var PurchaseHeader: Record "Purchase Header"; LineNo: Integer; ErrorMessage: Text)
    var
        PurchaseLine: Record "Purchase Line";
    begin
        GetPurchaseCreditMemoLine(PurchaseHeader, PurchaseLine, LineNo, ErrorMessage);
    end;

    local procedure VerifyCreditMemoLinesMatching(var PurchaseLine1: Record "Purchase Line"; var PurchaseLine2: Record "Purchase Line")
    var
        TempIgnoredFieldsForComparison: Record 2000000041 temporary;
        PurchaseLine1RecordRef: RecordRef;
        PurchaseLine2RecordRef: RecordRef;
    begin
        // Ignore these fields when comparing Page and API credit memos
        LibraryUtility.AddTempField(TempIgnoredFieldsForComparison, PurchaseLine1.FieldNo("Line No."), Database::"Purchase Line");
        LibraryUtility.AddTempField(TempIgnoredFieldsForComparison, PurchaseLine1.FieldNo("Document No."), Database::"Purchase Line");
        LibraryUtility.AddTempField(TempIgnoredFieldsForComparison, PurchaseLine1.FieldNo("No."), Database::"Purchase Line");
        LibraryUtility.AddTempField(TempIgnoredFieldsForComparison, PurchaseLine1.FieldNo(Subtype), Database::"Purchase Line");
        LibraryUtility.AddTempField(
          TempIgnoredFieldsForComparison, PurchaseLine1.FieldNo("Recalculate Invoice Disc."), Database::"Purchase Line"); // TODO: remove once other changes are checked in

        PurchaseLine1RecordRef.GetTable(PurchaseLine1);
        PurchaseLine2RecordRef.GetTable(PurchaseLine2);

        Assert.RecordsAreEqualExceptCertainFields(PurchaseLine1RecordRef, PurchaseLine2RecordRef, TempIgnoredFieldsForComparison,
          'Credit Memo Lines do not match');
    end;

    local procedure CreateLinesWithDifferentTypes(var PurchaseHeader: Record "Purchase Header")
    var
        PurchaseLineFixedAsset: Record "Purchase Line";
        PurchaseLineResource: Record "Purchase Line";
        PurchaseLineComment: Record "Purchase Line";
        Resource: Record "Resource";
        VATBusinessPostingGroup: Record "VAT Business Posting Group";
        FixedAsset: Record "Fixed Asset";
        LibraryERM: Codeunit "Library - ERM";
        LibraryResource: Codeunit "Library - Resource";
        LibraryFixedAsset: Codeunit "Library - Fixed Asset";
    begin
        LibraryERM.FindVATBusinessPostingGroup(VATBusinessPostingGroup);
        LibraryResource.CreateResource(Resource, VATBusinessPostingGroup.Code);
        LibraryPurchase.CreatePurchaseLine(PurchaseLineResource, PurchaseHeader, PurchaseLineResource.Type::Resource, Resource."No.", 1);

        LibraryFixedAsset.CreateFixedAsset(FixedAsset);
        LibraryPurchase.CreatePurchaseLine(PurchaseLineFixedAsset, PurchaseHeader, PurchaseLineFixedAsset.Type::"Fixed Asset", FixedAsset."No.", 1);

        LibraryPurchase.CreatePurchaseLineSimple(PurchaseLineComment, PurchaseHeader);
        PurchaseLineComment.Type := PurchaseLineComment.Type::" ";
        PurchaseLineComment.Description := 'Thank you for your business!';
        PurchaseLineComment.Modify();
    end;
}