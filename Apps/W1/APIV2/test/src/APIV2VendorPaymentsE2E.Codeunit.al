codeunit 139843 "APIV2 - Vendor Payments E2E"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Graph] [Vendor Payments]
    end;

    var
        LibraryGraphMgt: Codeunit "Library - Graph Mgt";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        Assert: Codeunit Assert;
        GraphMgtVendorPayments: Codeunit "Graph Mgt - Vendor Payments";
        LibraryGraphJournalLines: Codeunit "Library - Graph Journal Lines";
        GraphMgtJournal: Codeunit "Graph Mgt - Journal";
        ServiceNameTxt: Label 'vendorPaymentJournals';
        ServiceSubpageNameTxt: Label 'vendorPayments';
        LineNumberNameTxt: Label 'lineNumber';
        AppliesToInvoiceIdTxt: Label 'appliesToInvoiceId';
        AppliesToDocNoNameTxt: Label 'appliesToInvoiceNumber';
        VendorIdFieldTxt: Label 'vendorId';
        VendorNoNameTxt: Label 'vendorNumber';
        BalAccountNoNameTxt: Label 'balancingAccountNumber';
        isInitialized: Boolean;

    [Test]
    [Scope('OnPrem')]
    procedure TestCreateVendorPayment()
    var
        PurchInvHeader: Record "Purch. Inv. Header";
        GenJournalLine: Record "Gen. Journal Line";
        GenJournalBatch: Record "Gen. Journal Batch";
        LibraryERM: Codeunit "Library - ERM";
        PurchInvAggregator: Codeunit "Purch. Inv. Aggregator";
        JournalName: Code[10];
        Amount: Decimal;
        LineNo: Integer;
        VendorNo: Code[20];
        AppliesToDocNo: Code[20];
        LineJSON: Text;
        TargetURL: Text;
        ResponseText: Text;
    begin
        // [SCENARIO] Create a vendor payment through a POST method and check if it was created
        Initialize();
        LibraryGraphJournalLines.Initialize();

        // [GIVEN] a journal
        JournalName := LibraryGraphJournalLines.CreateVendorPaymentsJournal();
        if GenJournalBatch.Get(GraphMgtJournal.GetDefaultJournalLinesTemplateName(), JournalName) then begin
            GenJournalBatch.Validate("Bal. Account Type", GenJournalBatch."Bal. Account Type"::"G/L Account");
            GenJournalBatch.Validate("Bal. Account No.", LibraryERM.CreateGLAccountNoWithDirectPosting());
            GenJournalBatch.Modify();
        end;

        // [GIVEN] a JSON text with a vendor payment containing the LineNo, Amount, Description and Posting Date fields
        LineNo := LibraryGraphJournalLines.GetNextVendorPaymentNo(JournalName);
        LineJSON := LibraryGraphJournalLines.CreateLineWithGenericLineValuesJSON(LineNo, Amount);
        VendorNo := LibraryGraphJournalLines.CreateVendor();
        AppliesToDocNo := LibraryGraphJournalLines.CreatePostedPurchaseInvoice(VendorNo);
        LineJSON := LibraryGraphMgt.AddPropertytoJSON(LineJSON, VendorNoNameTxt, VendorNo);
        LineJSON := LibraryGraphMgt.AddPropertytoJSON(LineJSON, AppliesToDocNoNameTxt, AppliesToDocNo);
        Commit();

        // [WHEN] we POST the JSON to the web service
        TargetURL :=
          LibraryGraphMgt.CreateTargetURLWithSubpage(
            GetJournalID(JournalName), Page::"APIV2 - Vendor Paym. Journals", ServiceNameTxt, ServiceSubpageNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, LineJSON, ResponseText);

        // [THEN] the response text should contain the vendor payment information and the integration record table should map the JournalLineID with the ID
        Assert.AreNotEqual('', ResponseText, 'JSON Should not be blank');
        VerifyLineNoInJson(ResponseText, Format(LineNo));
        LibraryGraphMgt.VerifyIDFieldInJsonWithoutIntegrationRecord(ResponseText, 'id');

        GraphMgtVendorPayments.SetVendorPaymentsFilters(GenJournalLine);
        GenJournalLine.SetRange("Line No.", LineNo);
        GenJournalLine.SetRange("Account No.", VendorNo);
        GenJournalLine.FindLast();
        LibraryGraphJournalLines.CheckLineWithGenericLineValues(GenJournalLine, Amount);
        Assert.AreEqual(VendorNo, GenJournalLine."Account No.", 'Journal Line ' + VendorNo + ' should be changed');
        Assert.AreEqual(AppliesToDocNo, GenJournalLine."Applies-to Doc. No.", 'Journal Line ' + AppliesToDocNo + ' should be changed');
        PurchInvHeader.Get(AppliesToDocNo);

        Assert.AreEqual(
          PurchInvAggregator.GetPurchaseInvoiceHeaderId(PurchInvHeader),
          GenJournalLine."Applies-to Invoice Id",
          'Journal Line ' + Format(PurchInvAggregator.GetPurchaseInvoiceHeaderId(PurchInvHeader)) + ' should match the invoice no.');

        Assert.AreEqual(
          GenJournalBatch."Bal. Account No.",
          GenJournalLine."Bal. Account No.",
          'Journal Line ' + BalAccountNoNameTxt + ' should be changed');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestCreateVendorPaymentWithoutDocNo()
    var
        GenJournalLine: Record "Gen. Journal Line";
        JournalName: Code[10];
        LineNo: Integer;
        LineJSON: Text;
        TargetURL: Text;
        ResponseText: Text;
    begin
        // [SCENARIO] Create a vendor payment through a POST method without Document No and see if it was filled
        Initialize();
        LibraryGraphJournalLines.Initialize();

        // [GIVEN] a journal
        JournalName := LibraryGraphJournalLines.CreateVendorPaymentsJournal();

        // [GIVEN] a JSON text with a vendor payment containing the only the amount
        LineNo := LibraryGraphJournalLines.GetNextVendorPaymentNo(JournalName);
        LineJSON := LibraryGraphMgt.AddComplexTypetoJSON('{}', LineNumberNameTxt, Format(LineNo));
        Commit();

        // [WHEN] we POST the JSON to the web service
        TargetURL :=
          LibraryGraphMgt.CreateTargetURLWithSubpage(
            GetJournalID(JournalName), Page::"APIV2 - Vendor Paym. Journals", ServiceNameTxt, ServiceSubpageNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, LineJSON, ResponseText);

        // [THEN] the response text should contain the vendor payment information and the integration record table should map the JournalLineID with the ID
        GraphMgtVendorPayments.SetVendorPaymentsFilters(GenJournalLine);
        GenJournalLine.SetRange("Line No.", LineNo);
        GenJournalLine.FindLast();
        Assert.AreNotEqual('', GenJournalLine."Document No.", 'Journal Line documentNumber should not be empty');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestCreateVendorPaymentWithInvoiceId()
    var
        GenJournalLine: Record "Gen. Journal Line";
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchInvAggregator: Codeunit "Purch. Inv. Aggregator";
        JournalName: Code[10];
        VendorNo: Code[20];
        AppliesToDocNo: Code[20];
        ResponseText: Text;
        LineJSON: Text;
        TargetURL: Text;
        LineNo: Integer;
    begin
        // [SCENARIO] Create a vendor payment through a POST method with Document Id and see if the No is set correctly.
        Initialize();
        LibraryGraphJournalLines.Initialize();

        // [GIVEN] a journal
        JournalName := LibraryGraphJournalLines.CreateVendorPaymentsJournal();

        // [GIVEN] a JSON text with a vendor payment containing the LineNo, Amount, Description, Posting Date Fields and Document Id.
        LineNo := LibraryGraphJournalLines.GetNextVendorPaymentNo(JournalName);
        VendorNo := LibraryGraphJournalLines.CreateVendor();
        AppliesToDocNo := LibraryGraphJournalLines.CreatePostedPurchaseInvoice(VendorNo);
        LineJSON := LibraryGraphMgt.AddPropertytoJSON('', VendorNoNameTxt, VendorNo);
        PurchInvHeader.Get(AppliesToDocNo);
        LineJSON :=
          LibraryGraphMgt.AddPropertytoJSON(LineJSON, AppliesToInvoiceIdTxt, LibraryGraphMgt.StripBrackets(Format(PurchInvAggregator.GetPurchaseInvoiceHeaderId(PurchInvHeader))));
        Commit();

        // [WHEN] we POST the JSON to the web service
        TargetURL :=
          LibraryGraphMgt.CreateTargetURLWithSubpage(
            GetJournalID(JournalName), Page::"APIV2 - Vendor Paym. Journals", ServiceNameTxt, ServiceSubpageNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, LineJSON, ResponseText);

        // [THEN] the response text should contain the vendor payment information, the invoice id should be set
        // to the supplied id and the number should match the id.
        GraphMgtVendorPayments.SetVendorPaymentsFilters(GenJournalLine);
        GenJournalLine.SetRange("Line No.", LineNo);
        GenJournalLine.SetRange("Account No.", VendorNo);
        GenJournalLine.FindLast();

        Assert.AreEqual(
          PurchInvAggregator.GetPurchaseInvoiceHeaderId(PurchInvHeader), GenJournalLine."Applies-to Invoice Id",
          'Applies-to Invoice Id of the journal line should be ' + Format(PurchInvAggregator.GetPurchaseInvoiceHeaderId(PurchInvHeader)) + ' but is ' +
          Format(GenJournalLine."Applies-to Invoice Id"));

        Assert.AreEqual(
          AppliesToDocNo,
          GenJournalLine."Applies-to Doc. No.",
          'Applies-to Doc. No. of the journal line should match with the supplied invoice id');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestCreateVendorPaymentWithIdThatIsNotFromPurchaseInvoice()
    var
        Vendor: Record Vendor;
        JournalName: Code[10];
        LineJSON: Text;
        ResponseText: Text;
        TargetURL: Text;
        VendorNo: Code[20];
        RandomId: Guid;
    begin
        // [SCENARIO] Create a vendor payment through a POST method with Applies-to Invoice Id of something that is not a Purchase Invoice.
        Initialize();
        LibraryGraphJournalLines.Initialize();

        // [GIVEN] a journal
        JournalName := LibraryGraphJournalLines.CreateVendorPaymentsJournal();

        // [GIVEN] a JSON text with a vendor payment with the Applies-to invoice id from a vendor.
        VendorNo := LibraryGraphJournalLines.CreateVendor();
        Vendor.Get(VendorNo);
        RandomId := Vendor.SystemId;
        LineJSON := LibraryGraphMgt.AddPropertytoJSON('', AppliesToInvoiceIdTxt, LibraryGraphMgt.StripBrackets(Format(RandomId)));
        Commit();

        // [WHEN] we POST the JSON to the api
        TargetURL :=
          LibraryGraphMgt.CreateTargetURLWithSubpage(
            GetJournalID(JournalName), Page::"APIV2 - Vendor Paym. Journals", ServiceNameTxt, ServiceSubpageNameTxt);
        asserterror LibraryGraphMgt.PostToWebService(TargetURL, LineJSON, ResponseText);

        // [THEN] the request should not go through and we will get a blank response text.
        Assert.AreEqual('', ResponseText, 'Response should return blank but is ' + ResponseText);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestGetVendorPayment()
    var
        GenJournalLine: Record "Gen. Journal Line";
        JournalName: Code[10];
        BlankGUID: Guid;
        VendorPaymentGUID: Guid;
        LineNo: Integer;
        LineNoInJSON: Text;
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] Create a line and use a GET method with an ID specified to retrieve it
        Initialize();
        LibraryGraphJournalLines.Initialize();

        // [GIVEN] a journal
        JournalName := LibraryGraphJournalLines.CreateVendorPaymentsJournal();

        // [GIVEN] a line in the Cash Receipts Journal Table
        LineNo := LibraryGraphJournalLines.CreateVendorPayment(JournalName, '', BlankGUID, '', BlankGUID, 0, '');
        GenJournalLine.Reset();
        GenJournalLine.SetRange("Line No.", LineNo);
        GraphMgtVendorPayments.SetVendorPaymentsFilters(GenJournalLine);
        GenJournalLine.SetRange("Account No.", '');
        GenJournalLine.FindLast();
        VendorPaymentGUID := GenJournalLine.SystemId;
        Commit();

        // [WHEN] we GET the line from the web service
        TargetURL :=
          LibraryGraphMgt.CreateTargetURLWithSubpage(
            GetJournalID(JournalName), Page::"APIV2 - Vendor Paym. Journals", ServiceNameTxt, GetVendorPaymentURL(VendorPaymentGUID));
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] the line should exist in the response
        LibraryGraphMgt.VerifyIDFieldInJsonWithoutIntegrationRecord(ResponseText, 'id');
        Assert.IsTrue(
          LibraryGraphMgt.GetObjectIDFromJSON(ResponseText, LineNumberNameTxt, LineNoInJSON),
          'Could not find the ' + LineNumberNameTxt + ' in the JSON');
        Assert.AreEqual(Format(LineNo), LineNoInJSON, 'The response JSON does not contain the correct Line No');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestModifyVendorPayment()
    var
        GenJournalLine: Record "Gen. Journal Line";
        JournalName: Code[10];
        BlankGUID: Guid;
        VendorPaymentGUID: Guid;
        LineNo: Integer;
        LineJSON: Text;
        TargetURL: Text;
        ResponseText: Text;
        NewLineNo: Integer;
        NewAmount: Decimal;
        NewVendorNo: Code[20];
        NewAppliesToDocNo: Code[20];
    begin
        // [SCENARIO] Create a vendor payment, use a PATCH method to change it and then verify the changes
        Initialize();
        LibraryGraphJournalLines.Initialize();

        // [GIVEN] a journal
        JournalName := LibraryGraphJournalLines.CreateVendorPaymentsJournal();

        // [GIVEN] a line in the Cash Receipts Journal Table
        LineNo := LibraryGraphJournalLines.CreateVendorPayment(JournalName, '', BlankGUID, '', BlankGUID, 0, '');

        // [GIVEN] a JSON text with an amount property
        NewLineNo := LibraryGraphJournalLines.GetNextVendorPaymentNo(JournalName);
        LineJSON := LibraryGraphJournalLines.CreateLineWithGenericLineValuesJSON(NewLineNo, NewAmount);
        NewVendorNo := LibraryGraphJournalLines.CreateVendor();
        NewAppliesToDocNo := LibraryGraphJournalLines.CreatePostedPurchaseInvoice(NewVendorNo);
        LineJSON := LibraryGraphMgt.AddPropertytoJSON(LineJSON, VendorNoNameTxt, NewVendorNo);
        LineJSON := LibraryGraphMgt.AddPropertytoJSON(LineJSON, AppliesToDocNoNameTxt, NewAppliesToDocNo);

        // [GIVEN] the vendor payment's unique GUID
        GraphMgtVendorPayments.SetVendorPaymentsFilters(GenJournalLine);
        GenJournalLine.SetFilter("Line No.", Format(LineNo));
        GenJournalLine.SetRange("Account No.", '');
        GenJournalLine.FindLast();
        VendorPaymentGUID := GenJournalLine.SystemId;
        Assert.AreNotEqual('', VendorPaymentGUID, 'Vendor Payment GUID should not be empty');
        Commit();

        // [WHEN] we PATCH the JSON to the web service, with the unique VendorPaymentID
        TargetURL :=
          LibraryGraphMgt.CreateTargetURLWithSubpage(
            GetJournalID(JournalName), Page::"APIV2 - Vendor Paym. Journals", ServiceNameTxt, GetVendorPaymentURL(VendorPaymentGUID));
        LibraryGraphMgt.PatchToWebService(TargetURL, LineJSON, ResponseText);

        // [THEN] the JournalLine in the table should have the values that were given
        GraphMgtVendorPayments.SetVendorPaymentsFilters(GenJournalLine);
        GenJournalLine.SetRange("Line No.", NewLineNo);
        GenJournalLine.SetRange("Account No.", NewVendorNo);
        GenJournalLine.FindLast();
        LibraryGraphJournalLines.CheckLineWithGenericLineValues(GenJournalLine, NewAmount);
        Assert.AreEqual(NewVendorNo, GenJournalLine."Account No.", 'Journal Line ' + NewVendorNo + ' should be changed');
        Assert.AreEqual(
          NewAppliesToDocNo, GenJournalLine."Applies-to Doc. No.", 'Journal Line ' + NewAppliesToDocNo + ' should be changed');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestModifyVendorPaymentWithRandomDocNo()
    var
        GenJournalLine: Record "Gen. Journal Line";
        JournalName: Code[10];
        VendorPaymentGUID: Guid;
        RandomDocNo: Code[20];
        AppliesToDocNo: Code[20];
        VendorNo: Code[20];
        LineJSON: Text;
        ResponseText: Text;
        TargetURL: Text;
        LineNo: Integer;
    begin
        // [SCENARIO] Create a vendor payment through a POST method with Document No. Then PATCH it with a random Document No. and verify that the Document Id is blanked.
        Initialize();
        LibraryGraphJournalLines.Initialize();

        // [GIVEN] a journal
        JournalName := LibraryGraphJournalLines.CreateVendorPaymentsJournal();

        // [GIVEN] a JSON text with a vendor payment containing the LineNo, Amount, Description, Posting Date Fields and Valid Document No.
        LineNo := LibraryGraphJournalLines.GetNextVendorPaymentNo(JournalName);
        VendorNo := LibraryGraphJournalLines.CreateVendor();
        AppliesToDocNo := LibraryGraphJournalLines.CreatePostedPurchaseInvoice(VendorNo);
        LineJSON := LibraryGraphMgt.AddPropertytoJSON(LineJSON, VendorNoNameTxt, VendorNo);
        LineJSON := LibraryGraphMgt.AddPropertytoJSON(LineJSON, AppliesToDocNoNameTxt, AppliesToDocNo);
        Commit();

        TargetURL :=
          LibraryGraphMgt.CreateTargetURLWithSubpage(
            GetJournalID(JournalName), Page::"APIV2 - Vendor Paym. Journals", ServiceNameTxt, ServiceSubpageNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, LineJSON, ResponseText);

        GraphMgtVendorPayments.SetVendorPaymentsFilters(GenJournalLine);
        GenJournalLine.SetRange("Line No.", LineNo);
        GenJournalLine.SetRange("Account No.", VendorNo);
        GenJournalLine.FindLast();
        VendorPaymentGUID := GenJournalLine.SystemId;
        RandomDocNo := LibraryUtility.GenerateGUID();
        LineJSON := LibraryGraphMgt.AddPropertytoJSON('', AppliesToDocNoNameTxt, RandomDocNo);

        // [WHEN] we PATCH the existing vendor payment and update the Doc. No. to a random value.
        TargetURL :=
          LibraryGraphMgt.CreateTargetURLWithSubpage(
            GetJournalID(JournalName), Page::"APIV2 - Vendor Paym. Journals", ServiceNameTxt, GetVendorPaymentURL(VendorPaymentGUID));
        LibraryGraphMgt.PatchToWebService(TargetURL, LineJSON, ResponseText);

        // [THEN] the response text should contain the random Doc. No. but the Id should be blanked.
        GraphMgtVendorPayments.SetVendorPaymentsFilters(GenJournalLine);
        GenJournalLine.SetRange("Line No.", LineNo);
        GenJournalLine.SetRange("Account No.", VendorNo);
        GenJournalLine.FindLast();

        Assert.AreEqual(
          RandomDocNo, GenJournalLine."Applies-to Doc. No.",
          'Journal Line ' + AppliesToDocNo + ' should be changed');

        Assert.IsTrue(
          IsNullGuid(GenJournalLine."Applies-to Invoice Id"),
          'Journal Line Applies-to Invoice Id should be blank but is ' + Format(GenJournalLine."Applies-to Invoice Id"));
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestDeleteVendorPayment()
    var
        GenJournalLine: Record "Gen. Journal Line";
        JournalName: Code[10];
        BlankGUID: Guid;
        VendorPaymentGUID: Guid;
        LineNo: Integer;
        TargetURL: Text;
        ResponseText: Text;
    begin
        // [SCENARIO] Create a vendor payment, use a DELETE method to remove it and then verify the deletion
        Initialize();
        LibraryGraphJournalLines.Initialize();

        // [GIVEN] a journal
        JournalName := LibraryGraphJournalLines.CreateVendorPaymentsJournal();

        // [GIVEN] a line in the Cash Receipts Journal Table
        LineNo := LibraryGraphJournalLines.CreateVendorPayment(JournalName, '', BlankGUID, '', BlankGUID, 0, '');

        // [GIVEN] the vendor payment's unique GUID
        GraphMgtVendorPayments.SetVendorPaymentsFilters(GenJournalLine);
        GenJournalLine.SetFilter("Line No.", Format(LineNo));
        GenJournalLine.SetRange("Account No.", '');
        GenJournalLine.FindLast();
        VendorPaymentGUID := GenJournalLine.SystemId;
        Assert.AreNotEqual('', VendorPaymentGUID, 'VendorPaymentGUID should not be empty');
        Commit();

        // [WHEN] we DELETE the vendor payment from the web service, with the vendor payment's unique ID
        TargetURL :=
          LibraryGraphMgt.CreateTargetURLWithSubpage(
            GetJournalID(JournalName), Page::"APIV2 - Vendor Paym. Journals", ServiceNameTxt, GetVendorPaymentURL(VendorPaymentGUID));
        LibraryGraphMgt.DeleteFromWebService(TargetURL, '', ResponseText);

        // [THEN] the vendor payment shouldn't exist in the table
        GraphMgtVendorPayments.SetVendorPaymentsFilters(GenJournalLine);
        GenJournalLine.SetFilter("Line No.", Format(LineNo));
        GenJournalLine.SetFilter(SystemId, VendorPaymentGUID);
        //GenJournalLine.SetFilter("Journal Batch Name", );
        Assert.IsTrue(GenJournalLine.IsEmpty(), 'The Vendor Payment should be deleted.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestVendorAutofillWhenGivingInvoiceNumber()
    var
        GenJournalLine: Record "Gen. Journal Line";
        JournalName: Code[10];
        LineNo: Integer;
        VendorNo: Code[20];
        AppliesToDocNo: Code[20];
        LineJSON: Text;
        TargetURL: Text;
        ResponseText: Text;
    begin
        // [SCENARIO] Create a vendor payment through a POST method and check if the Vendor was Auto-filled
        Initialize();
        LibraryGraphJournalLines.Initialize();

        // [GIVEN] a journal
        JournalName := LibraryGraphJournalLines.CreateVendorPaymentsJournal();

        // [GIVEN] a JSON text with a vendor payment containing an InvoiceNumber
        LineNo := LibraryGraphJournalLines.GetNextVendorPaymentNo(JournalName);
        VendorNo := LibraryGraphJournalLines.CreateVendor();
        AppliesToDocNo := LibraryGraphJournalLines.CreatePostedPurchaseInvoice(VendorNo);
        LineJSON := LibraryGraphMgt.AddPropertytoJSON('', AppliesToDocNoNameTxt, AppliesToDocNo);
        Commit();

        // [WHEN] we POST the JSON to the web service
        TargetURL :=
          LibraryGraphMgt.CreateTargetURLWithSubpage(
            GetJournalID(JournalName), Page::"APIV2 - Vendor Paym. Journals", ServiceNameTxt, ServiceSubpageNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, LineJSON, ResponseText);

        // [THEN] the response text should contain the Invoice Number and the Vendor Number should be filled with the Invoice's Vendor
        Assert.AreNotEqual('', ResponseText, 'JSON Should not be blank');
        VerifyLineNoInJson(ResponseText, Format(LineNo));
        LibraryGraphMgt.VerifyIDFieldInJsonWithoutIntegrationRecord(ResponseText, 'id');

        GraphMgtVendorPayments.SetVendorPaymentsFilters(GenJournalLine);
        GenJournalLine.SetRange("Line No.", LineNo);
        GenJournalLine.SetRange("Account No.", VendorNo);
        GenJournalLine.FindLast();
        Assert.AreEqual(VendorNo, GenJournalLine."Account No.", 'Journal Line ' + VendorNo + ' should be autofilled');
        Assert.AreEqual(AppliesToDocNo, GenJournalLine."Applies-to Doc. No.", 'Journal Line ' + AppliesToDocNo + ' should be changed');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestVendorAutofillDoesNotOverwrite()
    var
        GenJournalLine: Record "Gen. Journal Line";
        JournalName: Code[10];
        LineNo: Integer;
        VendorNo: array[2] of Code[20];
        AppliesToDocNo: Code[20];
        LineJSON: Text;
        TargetURL: Text;
        ResponseText: Text;
    begin
        // [SCENARIO] Create a vendor payment through a POST method and check if the Vendor was Auto-filled
        Initialize();
        LibraryGraphJournalLines.Initialize();

        // [GIVEN] a journal
        JournalName := LibraryGraphJournalLines.CreateVendorPaymentsJournal();

        // [GIVEN] a JSON text with a vendor payment containing an InvoiceNumber
        LineNo := LibraryGraphJournalLines.GetNextVendorPaymentNo(JournalName);
        VendorNo[1] := LibraryGraphJournalLines.CreateVendor();
        VendorNo[2] := LibraryGraphJournalLines.CreateVendor();
        AppliesToDocNo := LibraryGraphJournalLines.CreatePostedPurchaseInvoice(VendorNo[1]);
        LineJSON := LibraryGraphMgt.AddPropertytoJSON('', VendorNoNameTxt, VendorNo[2]);
        LineJSON := LibraryGraphMgt.AddPropertytoJSON(LineJSON, AppliesToDocNoNameTxt, AppliesToDocNo);
        Commit();

        // [WHEN] we POST the JSON to the web service
        TargetURL :=
          LibraryGraphMgt.CreateTargetURLWithSubpage(
            GetJournalID(JournalName), Page::"APIV2 - Vendor Paym. Journals", ServiceNameTxt, ServiceSubpageNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, LineJSON, ResponseText);

        // [THEN] the response text should contain the Invoice Number and the Vendor Number should be filled with the Invoice's Vendor
        Assert.AreNotEqual('', ResponseText, 'JSON Should not be blank');
        VerifyLineNoInJson(ResponseText, Format(LineNo));
        LibraryGraphMgt.VerifyIDFieldInJsonWithoutIntegrationRecord(ResponseText, 'id');

        GraphMgtVendorPayments.SetVendorPaymentsFilters(GenJournalLine);
        GenJournalLine.SetRange("Line No.", LineNo);
        GenJournalLine.SetRange("Account No.", VendorNo[2]);
        GenJournalLine.FindLast();
        Assert.AreEqual(VendorNo[2], GenJournalLine."Account No.", 'Journal Line ' + VendorNo[2] + ' should not be autofilled');
        Assert.AreEqual(AppliesToDocNo, GenJournalLine."Applies-to Doc. No.", 'Journal Line ' + AppliesToDocNo + ' should be changed');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestVendorNoAndIdSync()
    var
        GenJournalLine: Record "Gen. Journal Line";
        Vendor: Record Vendor;
        JournalName: Code[10];
        LineNo: array[3] of Integer;
        VendorNo: Code[20];
        VendorGUID: Guid;
        LineJSON: array[3] of Text;
        TargetURL: Text;
        ResponseText: array[3] of Text;
    begin
        // [SCENARIO] Create a vendor payment through a POST method and check if the Vendor No and Id are filled correctly
        // [GIVEN] an empty journal
        Initialize();
        LibraryGraphJournalLines.Initialize();

        // [GIVEN] a journal
        JournalName := LibraryGraphJournalLines.CreateVendorPaymentsJournal();

        // [GIVEN] a vendpr
        VendorNo := LibraryGraphJournalLines.CreateVendor();
        Vendor.Get(VendorNo);
        VendorGUID := Vendor.SystemId;

        // [GIVEN] JSON texts for a vendor payment with and without VendorNo and VendorId
        LineNo[1] := LibraryGraphJournalLines.GetNextVendorPaymentNo(JournalName);
        LineNo[2] := LibraryGraphJournalLines.GetNextVendorPaymentNo(JournalName);
        LineNo[3] := LibraryGraphJournalLines.GetNextVendorPaymentNo(JournalName);

        LineJSON[3] := LibraryGraphMgt.AddPropertytoJSON('', VendorNoNameTxt, VendorNo);
        LineJSON[3] := LibraryGraphMgt.AddPropertytoJSON(LineJSON[3], VendorIdFieldTxt, VendorGUID);
        LineJSON[1] := LibraryGraphMgt.AddPropertytoJSON('', VendorNoNameTxt, VendorNo);
        LineJSON[2] := LibraryGraphMgt.AddPropertytoJSON('', VendorIdFieldTxt, VendorGUID);

        Commit();

        // [WHEN] we POST the JSONs to the web service
        TargetURL :=
          LibraryGraphMgt.CreateTargetURLWithSubpage(
            GetJournalID(JournalName), Page::"APIV2 - Vendor Paym. Journals", ServiceNameTxt, ServiceSubpageNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, LineJSON[1], ResponseText[1]);
        LibraryGraphMgt.PostToWebService(TargetURL, LineJSON[2], ResponseText[2]);
        LibraryGraphMgt.PostToWebService(TargetURL, LineJSON[3], ResponseText[3]);

        // [THEN] the response text should contain the vendor payment information and the integration record table should map the JournalLineID with the ID
        GraphMgtVendorPayments.SetVendorPaymentsFilters(GenJournalLine);
        GenJournalLine.SetRange("Line No.", LineNo[1]);
        GenJournalLine.SetRange("Account No.", VendorNo);
        GenJournalLine.FindLast();
        Assert.AreEqual(
          VendorNo, GenJournalLine."Account No.", 'Vendor Payment ' + VendorNoNameTxt + ' should have the correct Vendor No');
        Assert.AreEqual(
          VendorGUID, GenJournalLine."Vendor Id", 'Vendor Payment ' + VendorIdFieldTxt + ' should have the correct Vendor Id');

        GenJournalLine.Reset();
        GraphMgtVendorPayments.SetVendorPaymentsFilters(GenJournalLine);
        GenJournalLine.SetRange("Line No.", LineNo[2]);
        GenJournalLine.SetRange("Account No.", VendorNo);
        GenJournalLine.FindLast();
        Assert.AreEqual(
          VendorNo, GenJournalLine."Account No.", 'Vendor Payment ' + VendorNoNameTxt + ' should have the correct Vendor No');
        Assert.AreEqual(
          VendorGUID, GenJournalLine."Vendor Id", 'Vendor Payment ' + VendorIdFieldTxt + ' should have the correct Vendor Id');

        GenJournalLine.Reset();
        GraphMgtVendorPayments.SetVendorPaymentsFilters(GenJournalLine);
        GenJournalLine.SetRange("Line No.", LineNo[3]);
        GenJournalLine.SetRange("Account No.", VendorNo);
        GenJournalLine.FindLast();
        Assert.AreEqual(
          VendorNo, GenJournalLine."Account No.", 'Vendor Payment ' + VendorNoNameTxt + ' should have the correct Vendor No');
        Assert.AreEqual(
          VendorGUID, GenJournalLine."Vendor Id", 'Vendor Payment ' + VendorIdFieldTxt + ' should have the correct Vendor Id');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestVendorNoAndIdSyncErrors()
    var
        Vendor: Record Vendor;
        JournalName: Code[10];
        VendorNo: Code[20];
        VendorGUID: Guid;
        LineJSON: array[3] of Text;
        TargetURL: Text;
        ResponseText: array[3] of Text;
    begin
        // [SCENARIO] Create a Vendor payment through a POST method and check if the Vendor Id and the Vendor No Sync throws the errors
        // [GIVEN] an empty journal
        Initialize();
        LibraryGraphJournalLines.Initialize();

        // [GIVEN] a journal
        JournalName := LibraryGraphJournalLines.CreatevendorPaymentsJournal();

        // [GIVEN] a vendor
        VendorNo := LibraryGraphJournalLines.CreateVendor();
        Vendor.Get(VendorNo);
        VendorGUID := Vendor.SystemId;
        Vendor.Delete();

        // [GIVEN] JSON texts for a vendor payment with and without VendorNo and VendorId
        LineJSON[1] := LibraryGraphMgt.AddPropertytoJSON('', VendorNoNameTxt, VendorNo);
        LineJSON[2] := LibraryGraphMgt.AddPropertytoJSON('', VendorIdFieldTxt, VendorGUID);

        Commit();

        // [WHEN] we POST the JSONs to the web service
        // [THEN] we will get errors because the Vendor doesn't exist
        TargetURL :=
          LibraryGraphMgt.CreateTargetURLWithSubpage(
            GetJournalID(JournalName), Page::"APIV2 - Vendor Paym. Journals", ServiceNameTxt, ServiceSubpageNameTxt);
        asserterror LibraryGraphMgt.PostToWebService(TargetURL, LineJSON[1], ResponseText[1]);
        asserterror LibraryGraphMgt.PostToWebService(TargetURL, LineJSON[2], ResponseText[2]);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestAppliesToInvoiceNoAndIdSync()
    var
        PurchInvHeader: Record "Purch. Inv. Header";
        GenJournalLine: Record "Gen. Journal Line";
        PurchInvAggregator: Codeunit "Purch. Inv. Aggregator";
        JournalName: Code[10];
        LineNo: array[3] of Integer;
        VendorNo: Code[20];
        AppliesToDocNo: Code[20];
        AppliesToDocGUID: Guid;
        LineJSON: array[3] of Text;
        TargetURL: Text;
        ResponseText: array[3] of Text;
    begin
        // [SCENARIO] Create a vendor payment through a POST method and check if the AppliesToInvoice No and Id are filled correctly
        // [GIVEN] an empty journal
        Initialize();
        LibraryGraphJournalLines.Initialize();

        // [GIVEN] a journal
        JournalName := LibraryGraphJournalLines.CreateVendorPaymentsJournal();

        // [GIVEN] a vendor
        VendorNo := LibraryGraphJournalLines.CreateVendor();

        // [GIVEN] a posted purchase invoice
        AppliesToDocNo := LibraryGraphJournalLines.CreatePostedPurchaseInvoice(VendorNo);
        PurchInvHeader.Get(AppliesToDocNo);
        AppliesToDocGUID := PurchInvAggregator.GetPurchaseInvoiceHeaderId(PurchInvHeader);

        // [GIVEN] JSON texts for a vendor payment with and without VendorNo and VendorId
        LineNo[1] := LibraryGraphJournalLines.GetNextVendorPaymentNo(JournalName);
        LineNo[2] := LibraryGraphJournalLines.GetNextVendorPaymentNo(JournalName);
        LineNo[3] := LibraryGraphJournalLines.GetNextVendorPaymentNo(JournalName);

        LineJSON[1] := LibraryGraphMgt.AddPropertytoJSON('', AppliesToDocNoNameTxt, AppliesToDocNo);
        LineJSON[2] := LibraryGraphMgt.AddPropertytoJSON('', AppliesToInvoiceIdTxt, AppliesToDocGUID);
        LineJSON[3] := LibraryGraphMgt.AddPropertytoJSON('', AppliesToDocNoNameTxt, AppliesToDocNo);
        LineJSON[3] := LibraryGraphMgt.AddPropertytoJSON(LineJSON[3], AppliesToInvoiceIdTxt, AppliesToDocGUID);

        Commit();

        // [WHEN] we POST the JSONs to the web service
        TargetURL :=
          LibraryGraphMgt.CreateTargetURLWithSubpage(
            GetJournalID(JournalName), Page::"APIV2 - Vendor Paym. Journals", ServiceNameTxt, ServiceSubpageNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, LineJSON[1], ResponseText[1]);
        LibraryGraphMgt.PostToWebService(TargetURL, LineJSON[2], ResponseText[2]);
        LibraryGraphMgt.PostToWebService(TargetURL, LineJSON[3], ResponseText[3]);

        // [THEN] the response text should contain the vendor payment information and the integration record table should map the JournalLineID with the ID
        GraphMgtVendorPayments.SetVendorPaymentsFilters(GenJournalLine);
        GenJournalLine.SetRange("Line No.", LineNo[1]);
        GenJournalLine.SetRange("Account No.", VendorNo);
        GenJournalLine.FindLast();
        Assert.AreEqual(
          AppliesToDocNo, GenJournalLine."Applies-to Doc. No.",
          'Vendor Payment ' + AppliesToDocNoNameTxt + ' should have the correct AppliesToDoc No');
        Assert.AreEqual(
          AppliesToDocGUID, GenJournalLine."Applies-to Invoice Id",
          'Vendor Payment ' + AppliesToInvoiceIdTxt + ' should have the correct AppliesToDoc Id');

        GenJournalLine.Reset();
        GenJournalLine.SetRange("Line No.", LineNo[2]);
        GenJournalLine.SetRange("Account No.", VendorNo);
        GraphMgtVendorPayments.SetVendorPaymentsFilters(GenJournalLine);
        GenJournalLine.FindLast();
        Assert.AreEqual(
          AppliesToDocNo, GenJournalLine."Applies-to Doc. No.",
          'Vendor Payment ' + AppliesToDocNoNameTxt + ' should have the correct AppliesToDoc No');
        Assert.AreEqual(
          AppliesToDocGUID, GenJournalLine."Applies-to Invoice Id",
          'Vendor Payment ' + AppliesToInvoiceIdTxt + ' should have the correct AppliesToDoc Id');

        GenJournalLine.Reset();
        GenJournalLine.SetRange("Line No.", LineNo[3]);
        GenJournalLine.SetRange("Account No.", VendorNo);
        GraphMgtVendorPayments.SetVendorPaymentsFilters(GenJournalLine);
        GenJournalLine.FindLast();
        Assert.AreEqual(
          AppliesToDocNo, GenJournalLine."Applies-to Doc. No.",
          'Vendor Payment ' + AppliesToDocNoNameTxt + ' should have the correct AppliesToDoc No');
        Assert.AreEqual(
          AppliesToDocGUID, GenJournalLine."Applies-to Invoice Id",
          'Vendor Payment ' + AppliesToInvoiceIdTxt + ' should have the correct AppliesToDoc Id');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestAppliesToInvoiceNoAndIdSyncErrors()
    var
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchInvAggregator: Codeunit "Purch. Inv. Aggregator";
        JournalName: Code[10];
        VendorNo: Code[20];
        AppliesToDocNo: Code[20];
        AppliesToDocGUID: Guid;
        LineJSON: Text;
        TargetURL: Text;
        ResponseText: Text;
    begin
        // [SCENARIO] Create a Vendor payment through a POST method and check if the AppliesToInvoiceNo Sync throws the errors
        // [GIVEN] an empty journal
        Initialize();
        LibraryGraphJournalLines.Initialize();

        // [GIVEN] a journal
        JournalName := LibraryGraphJournalLines.CreateVendorPaymentsJournal();

        // [GIVEN] a vendor
        VendorNo := LibraryGraphJournalLines.CreateVendor();

        // [GIVEN] a posted purchase invoice
        AppliesToDocNo := LibraryGraphJournalLines.CreatePostedPurchaseInvoice(VendorNo);
        PurchInvHeader.Get(AppliesToDocNo);
        AppliesToDocGUID := PurchInvAggregator.GetPurchaseInvoiceHeaderId(PurchInvHeader);
        PurchInvHeader.Delete();

        // [GIVEN] JSON texts for a vendor payment with and without VendorNo and VendorId
        LineJSON := LibraryGraphMgt.AddPropertytoJSON('', AppliesToInvoiceIdTxt, AppliesToDocGUID);

        Commit();

        // [WHEN] we POST the JSON to the web service
        // [THEN] we will get errors because the Account doesn't exist
        TargetURL :=
          LibraryGraphMgt.CreateTargetURLWithSubpage(
            GetJournalID(JournalName), Page::"APIV2 - Vendor Paym. Journals", ServiceNameTxt, ServiceSubpageNameTxt);
        asserterror LibraryGraphMgt.PostToWebService(TargetURL, LineJSON, ResponseText);
    end;

    local procedure Initialize()
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"APIV2 - Vendor Payments E2E");

        if not isInitialized then
            isInitialized := true;

        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"APIV2 - Vendor Payments E2E");
    end;

    local procedure VerifyLineNoInJson(JSONTxt: Text; ExpectedLineNo: Text)
    var
        GenJournalLine: Record "Gen. Journal Line";
        LineNo: Integer;
        LineNoValue: Text;
    begin
        Assert.IsTrue(LibraryGraphMgt.GetObjectIDFromJSON(JSONTxt, LineNumberNameTxt, LineNoValue), 'Could not find LineNo');
        Assert.AreEqual(ExpectedLineNo, LineNoValue, 'LineNo does not match');

        GraphMgtVendorPayments.SetVendorPaymentsFilters(GenJournalLine);
        Evaluate(LineNo, LineNoValue);
        GenJournalLine.SetRange("Line No.", LineNo);
        Assert.IsFalse(GenJournalLine.IsEmpty(), 'Gen. Journal Line for such Line No. should be empty');
    end;

    local procedure GetJournalID(JournalName: Code[10]): Guid
    var
        GenJournalBatch: Record "Gen. Journal Batch";
    begin
        GenJournalBatch.Get(GraphMgtJournal.GetDefaultVendorPaymentsTemplateName(), JournalName);
        exit(GenJournalBatch.SystemId);
    end;

    local procedure GetVendorPaymentURL(VendorPaymentId: Text): Text
    begin
        exit(ServiceSubpageNameTxt + '(' + LibraryGraphMgt.StripBrackets(VendorPaymentId) + ')');
    end;
}