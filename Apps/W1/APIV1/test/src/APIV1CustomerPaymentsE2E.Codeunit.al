codeunit 139743 "APIV1 - Customer Payments E2E"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Graph] [Customer Payments]
    end;

    var
        LibraryGraphMgt: Codeunit "Library - Graph Mgt";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        Assert: Codeunit Assert;
        GraphMgtCustomerPayments: Codeunit "Graph Mgt - Customer Payments";
        LibraryGraphJournalLines: Codeunit "Library - Graph Journal Lines";
        GraphMgtJournal: Codeunit "Graph Mgt - Journal";
        ServiceNameTxt: Label 'customerPaymentJournals';
        ServiceSubpageNameTxt: Label 'customerPayments';
        LineNumberNameTxt: Label 'lineNumber';
        AppliesToInvoiceIdTxt: Label 'appliesToInvoiceId';
        AppliesToDocNoNameTxt: Label 'appliesToInvoiceNumber';
        CustomerIdFieldTxt: Label 'customerId';
        CustomerNoNameTxt: Label 'customerNumber';
        BalAccountNoNameTxt: Label 'balancingAccountNumber';
        isInitialized: Boolean;

    [Test]
    [Scope('OnPrem')]
    procedure TestCreateCustomerPayment()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        GenJournalLine: Record "Gen. Journal Line";
        GenJournalBatch: Record "Gen. Journal Batch";
        LibraryERM: Codeunit "Library - ERM";
        SalesInvoiceAggregator: Codeunit "Sales Invoice Aggregator";
        JournalName: Code[10];
        Amount: Decimal;
        LineNo: Integer;
        CustomerNo: Code[20];
        AppliesToDocNo: Code[20];
        LineJSON: Text;
        TargetURL: Text;
        ResponseText: Text;
    begin
        // [SCENARIO] Create a customer payment through a POST method and check if it was created
        Initialize();
        LibraryGraphJournalLines.Initialize();

        // [GIVEN] a journal
        JournalName := LibraryGraphJournalLines.CreateCustomerPaymentsJournal();
        if GenJournalBatch.Get(GraphMgtJournal.GetDefaultJournalLinesTemplateName(), JournalName) then begin
            GenJournalBatch.Validate("Bal. Account Type", GenJournalBatch."Bal. Account Type"::"G/L Account");
            GenJournalBatch.Validate("Bal. Account No.", LibraryERM.CreateGLAccountNoWithDirectPosting());
            GenJournalBatch.Modify();
        end;

        // [GIVEN] a JSON text with a customer payment containing the LineNo, Amount, Description and Posting Date fields
        LineNo := LibraryGraphJournalLines.GetNextCustomerPaymentNo(JournalName);
        LineJSON := LibraryGraphJournalLines.CreateLineWithGenericLineValuesJSON(LineNo, Amount);
        CustomerNo := LibraryGraphJournalLines.CreateCustomer();
        AppliesToDocNo := LibraryGraphJournalLines.CreatePostedSalesInvoice(CustomerNo);
        LineJSON := LibraryGraphMgt.AddPropertytoJSON(LineJSON, CustomerNoNameTxt, CustomerNo);
        LineJSON := LibraryGraphMgt.AddPropertytoJSON(LineJSON, AppliesToDocNoNameTxt, AppliesToDocNo);
        Commit();

        // [WHEN] we POST the JSON to the web service
        TargetURL :=
          LibraryGraphMgt.CreateTargetURLWithSubpage(
            GetJournalID(JournalName), PAGE::"APIV1 - Cust. Paym. Journals", ServiceNameTxt, ServiceSubpageNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, LineJSON, ResponseText);

        // [THEN] the response text should contain the customer payment information and the integration record table should map the JournalLineID with the ID
        Assert.AreNotEqual('', ResponseText, 'JSON Should not be blank');
        VerifyLineNoInJson(ResponseText, Format(LineNo));
        LibraryGraphMgt.VerifyIDFieldInJsonWithoutIntegrationRecord(ResponseText, 'id');

        GraphMgtCustomerPayments.SetCustomerPaymentsFilters(GenJournalLine);
        GenJournalLine.SetRange("Line No.", LineNo);
        GenJournalLine.FindFirst();
        LibraryGraphJournalLines.CheckLineWithGenericLineValues(GenJournalLine, Amount);
        Assert.AreEqual(CustomerNo, GenJournalLine."Account No.", 'Journal Line ' + CustomerNo + ' should be changed');
        Assert.AreEqual(AppliesToDocNo, GenJournalLine."Applies-to Doc. No.", 'Journal Line ' + AppliesToDocNo + ' should be changed');
        SalesInvoiceHeader.Get(AppliesToDocNo);

        Assert.AreEqual(
          SalesInvoiceAggregator.GetSalesInvoiceHeaderId(SalesInvoiceHeader),
          GenJournalLine."Applies-to Invoice Id",
          'Journal Line ' + Format(SalesInvoiceAggregator.GetSalesInvoiceHeaderId(SalesInvoiceHeader)) + ' should match the invoice no.');

        Assert.AreEqual(
          GenJournalBatch."Bal. Account No.",
          GenJournalLine."Bal. Account No.",
          'Journal Line ' + BalAccountNoNameTxt + ' should be changed');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestCreateCustomerPaymentWithoutDocNo()
    var
        GenJournalLine: Record "Gen. Journal Line";
        JournalName: Code[10];
        LineNo: Integer;
        LineJSON: Text;
        TargetURL: Text;
        ResponseText: Text;
    begin
        // [SCENARIO] Create a customer payment through a POST method without Document No and see if it was filled
        Initialize();
        LibraryGraphJournalLines.Initialize();

        // [GIVEN] a journal
        JournalName := LibraryGraphJournalLines.CreateCustomerPaymentsJournal();

        // [GIVEN] a JSON text with a customer payment containing the only the amount
        LineNo := LibraryGraphJournalLines.GetNextCustomerPaymentNo(JournalName);
        LineJSON := LibraryGraphMgt.AddComplexTypetoJSON('{}', LineNumberNameTxt, Format(LineNo));
        Commit();

        // [WHEN] we POST the JSON to the web service
        TargetURL :=
          LibraryGraphMgt.CreateTargetURLWithSubpage(
            GetJournalID(JournalName), PAGE::"APIV1 - Cust. Paym. Journals", ServiceNameTxt, ServiceSubpageNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, LineJSON, ResponseText);

        // [THEN] the response text should contain the customer payment information and the integration record table should map the JournalLineID with the ID
        GraphMgtCustomerPayments.SetCustomerPaymentsFilters(GenJournalLine);
        GenJournalLine.SetRange("Line No.", LineNo);
        GenJournalLine.FindFirst();
        Assert.AreNotEqual('', GenJournalLine."Document No.", 'Journal Line documentNumber should not be empty');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestCreateCustomerPaymentWithInvoiceId()
    var
        GenJournalLine: Record "Gen. Journal Line";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesInvoiceAggregator: Codeunit "Sales Invoice Aggregator";
        JournalName: Code[10];
        CustomerNo: Code[20];
        AppliesToDocNo: Code[20];
        ResponseText: Text;
        LineJSON: Text;
        TargetURL: Text;
        LineNo: Integer;
    begin
        // [SCENARIO] Create a customer payment through a POST method with Document Id and see if the No is set correctly.
        Initialize();
        LibraryGraphJournalLines.Initialize();

        // [GIVEN] a journal
        JournalName := LibraryGraphJournalLines.CreateCustomerPaymentsJournal();

        // [GIVEN] a JSON text with a customer payment containing the LineNo, Amount, Description, Posting Date Fields and Document Id.
        LineNo := LibraryGraphJournalLines.GetNextCustomerPaymentNo(JournalName);
        CustomerNo := LibraryGraphJournalLines.CreateCustomer();
        AppliesToDocNo := LibraryGraphJournalLines.CreatePostedSalesInvoice(CustomerNo);
        LineJSON := LibraryGraphMgt.AddPropertytoJSON('', CustomerNoNameTxt, CustomerNo);
        SalesInvoiceHeader.Get(AppliesToDocNo);
        LineJSON :=
          LibraryGraphMgt.AddPropertytoJSON(LineJSON, AppliesToInvoiceIdTxt, LibraryGraphMgt.StripBrackets(Format(SalesInvoiceAggregator.GetSalesInvoiceHeaderId(SalesInvoiceHeader))));
        Commit();

        // [WHEN] we POST the JSON to the web service
        TargetURL :=
          LibraryGraphMgt.CreateTargetURLWithSubpage(
            GetJournalID(JournalName), PAGE::"APIV1 - Cust. Paym. Journals", ServiceNameTxt, ServiceSubpageNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, LineJSON, ResponseText);

        // [THEN] the response text should contain the customer payment information, the invoice id should be set
        // to the supplied id and the number should match the id.
        GraphMgtCustomerPayments.SetCustomerPaymentsFilters(GenJournalLine);
        GenJournalLine.SetRange("Line No.", LineNo);
        GenJournalLine.FindFirst();

        Assert.AreEqual(
          SalesInvoiceAggregator.GetSalesInvoiceHeaderId(SalesInvoiceHeader), GenJournalLine."Applies-to Invoice Id",
          'Applies-to Invoice Id of the journal line should be ' + Format(SalesInvoiceAggregator.GetSalesInvoiceHeaderId(SalesInvoiceHeader)) + ' but is ' +
          Format(GenJournalLine."Applies-to Invoice Id"));

        Assert.AreEqual(
          AppliesToDocNo,
          GenJournalLine."Applies-to Doc. No.",
          'Applies-to Doc. No. of the journal line should match with the supplied invoice id');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestCreateCustomerPaymentWithIdThatIsNotFromSalesInvoice()
    var
        Customer: Record Customer;
        JournalName: Code[10];
        LineJSON: Text;
        ResponseText: Text;
        TargetURL: Text;
        CustomerNo: Code[20];
        RandomId: Guid;
    begin
        // [SCENARIO] Create a customer payment through a POST method with Applies-to Invoice Id of something that is not a Sales Invoice.
        Initialize();
        LibraryGraphJournalLines.Initialize();

        // [GIVEN] a journal
        JournalName := LibraryGraphJournalLines.CreateCustomerPaymentsJournal();

        // [GIVEN] a JSON text with a customer payment with the Applies-to invoice id from a customer.
        CustomerNo := LibraryGraphJournalLines.CreateCustomer();
        Customer.Get(CustomerNo);
        RandomId := Customer.SystemId;
        LineJSON := LibraryGraphMgt.AddPropertytoJSON('', AppliesToInvoiceIdTxt, LibraryGraphMgt.StripBrackets(Format(RandomId)));
        Commit();

        // [WHEN] we POST the JSON to the api
        TargetURL :=
          LibraryGraphMgt.CreateTargetURLWithSubpage(
            GetJournalID(JournalName), PAGE::"APIV1 - Cust. Paym. Journals", ServiceNameTxt, ServiceSubpageNameTxt);
        asserterror LibraryGraphMgt.PostToWebService(TargetURL, LineJSON, ResponseText);

        // [THEN] the request should not go through and we will get a blank response text.
        Assert.AreEqual('', ResponseText, 'Response should return blank but is ' + ResponseText);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestGetCustomerPayment()
    var
        GenJournalLine: Record "Gen. Journal Line";
        JournalName: Code[10];
        BlankGUID: Guid;
        CustomerPaymentGUID: Guid;
        LineNo: Integer;
        LineNoInJSON: Text;
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] Create a line and use a GET method with an ID specified to retrieve it
        Initialize();
        LibraryGraphJournalLines.Initialize();

        // [GIVEN] a journal
        JournalName := LibraryGraphJournalLines.CreateCustomerPaymentsJournal();

        // [GIVEN] a line in the Cash Receipts Journal Table
        LineNo := LibraryGraphJournalLines.CreateCustomerPayment(JournalName, '', BlankGUID, '', BlankGUID, 0, '');
        GenJournalLine.Reset();
        GenJournalLine.SetRange("Line No.", LineNo);
        GraphMgtCustomerPayments.SetCustomerPaymentsFilters(GenJournalLine);
        GenJournalLine.FindFirst();
        CustomerPaymentGUID := GenJournalLine.SystemId;
        Commit();

        // [WHEN] we GET the line from the web service
        TargetURL :=
          LibraryGraphMgt.CreateTargetURLWithSubpage(
            GetJournalID(JournalName), PAGE::"APIV1 - Cust. Paym. Journals", ServiceNameTxt, GetCustomerPaymentURL(CustomerPaymentGUID));
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
    procedure TestModifyCustomerPayment()
    var
        GenJournalLine: Record "Gen. Journal Line";
        JournalName: Code[10];
        BlankGUID: Guid;
        CustomerPaymentGUID: Guid;
        LineNo: Integer;
        LineJSON: Text;
        TargetURL: Text;
        ResponseText: Text;
        NewLineNo: Integer;
        NewAmount: Decimal;
        NewCustomerNo: Code[20];
        NewAppliesToDocNo: Code[20];
    begin
        // [SCENARIO] Create a customer payment, use a PATCH method to change it and then verify the changes
        Initialize();
        LibraryGraphJournalLines.Initialize();

        // [GIVEN] a journal
        JournalName := LibraryGraphJournalLines.CreateCustomerPaymentsJournal();

        // [GIVEN] a line in the Cash Receipts Journal Table
        LineNo := LibraryGraphJournalLines.CreateCustomerPayment(JournalName, '', BlankGUID, '', BlankGUID, 0, '');

        // [GIVEN] a JSON text with an amount property
        NewLineNo := LibraryGraphJournalLines.GetNextCustomerPaymentNo(JournalName);
        LineJSON := LibraryGraphJournalLines.CreateLineWithGenericLineValuesJSON(NewLineNo, NewAmount);
        NewCustomerNo := LibraryGraphJournalLines.CreateCustomer();
        NewAppliesToDocNo := LibraryGraphJournalLines.CreatePostedSalesInvoice(NewCustomerNo);
        LineJSON := LibraryGraphMgt.AddPropertytoJSON(LineJSON, CustomerNoNameTxt, NewCustomerNo);
        LineJSON := LibraryGraphMgt.AddPropertytoJSON(LineJSON, AppliesToDocNoNameTxt, NewAppliesToDocNo);

        // [GIVEN] the customer payment's unique GUID
        GraphMgtCustomerPayments.SetCustomerPaymentsFilters(GenJournalLine);
        GenJournalLine.SetFilter("Line No.", Format(LineNo));
        GenJournalLine.FindFirst();
        CustomerPaymentGUID := GenJournalLine.SystemId;
        Assert.AreNotEqual('', CustomerPaymentGUID, 'Customer Payment GUID should not be empty');
        Commit();

        // [WHEN] we PATCH the JSON to the web service, with the unique CustomerPaymentID
        TargetURL :=
          LibraryGraphMgt.CreateTargetURLWithSubpage(
            GetJournalID(JournalName), PAGE::"APIV1 - Cust. Paym. Journals", ServiceNameTxt, GetCustomerPaymentURL(CustomerPaymentGUID));
        LibraryGraphMgt.PatchToWebService(TargetURL, LineJSON, ResponseText);

        // [THEN] the JournalLine in the table should have the values that were given
        GraphMgtCustomerPayments.SetCustomerPaymentsFilters(GenJournalLine);
        GenJournalLine.SetRange("Line No.", NewLineNo);
        GenJournalLine.FindFirst();
        LibraryGraphJournalLines.CheckLineWithGenericLineValues(GenJournalLine, NewAmount);
        Assert.AreEqual(NewCustomerNo, GenJournalLine."Account No.", 'Journal Line ' + NewCustomerNo + ' should be changed');
        Assert.AreEqual(
          NewAppliesToDocNo, GenJournalLine."Applies-to Doc. No.", 'Journal Line ' + NewAppliesToDocNo + ' should be changed');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestModifyCustomerPaymentWithRandomDocNo()
    var
        GenJournalLine: Record "Gen. Journal Line";
        JournalName: Code[10];
        CustomerPaymentGUID: Guid;
        RandomDocNo: Code[20];
        AppliesToDocNo: Code[20];
        CustomerNo: Code[20];
        LineJSON: Text;
        ResponseText: Text;
        TargetURL: Text;
        LineNo: Integer;
    begin
        // [SCENARIO] Create a customer payment through a POST method with Document No. Then PATCH it with a random Document No. and verify that the Document Id is blanked.
        Initialize();
        LibraryGraphJournalLines.Initialize();

        // [GIVEN] a journal
        JournalName := LibraryGraphJournalLines.CreateCustomerPaymentsJournal();

        // [GIVEN] a JSON text with a customer payment containing the LineNo, Amount, Description, Posting Date Fields and Valid Document No.
        LineNo := LibraryGraphJournalLines.GetNextCustomerPaymentNo(JournalName);
        CustomerNo := LibraryGraphJournalLines.CreateCustomer();
        AppliesToDocNo := LibraryGraphJournalLines.CreatePostedSalesInvoice(CustomerNo);
        LineJSON := LibraryGraphMgt.AddPropertytoJSON(LineJSON, CustomerNoNameTxt, CustomerNo);
        LineJSON := LibraryGraphMgt.AddPropertytoJSON(LineJSON, AppliesToDocNoNameTxt, AppliesToDocNo);
        Commit();

        TargetURL :=
          LibraryGraphMgt.CreateTargetURLWithSubpage(
            GetJournalID(JournalName), PAGE::"APIV1 - Cust. Paym. Journals", ServiceNameTxt, ServiceSubpageNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, LineJSON, ResponseText);

        GraphMgtCustomerPayments.SetCustomerPaymentsFilters(GenJournalLine);
        GenJournalLine.SetRange("Line No.", LineNo);
        GenJournalLine.FindFirst();
        CustomerPaymentGUID := GenJournalLine.SystemId;
        RandomDocNo := LibraryUtility.GenerateGUID();
        LineJSON := LibraryGraphMgt.AddPropertytoJSON('', AppliesToDocNoNameTxt, RandomDocNo);

        // [WHEN] we PATCH the existing customer payment and update the Doc. No. to a random value.
        TargetURL :=
          LibraryGraphMgt.CreateTargetURLWithSubpage(
            GetJournalID(JournalName), PAGE::"APIV1 - Cust. Paym. Journals", ServiceNameTxt, GetCustomerPaymentURL(CustomerPaymentGUID));
        LibraryGraphMgt.PatchToWebService(TargetURL, LineJSON, ResponseText);

        // [THEN] the response text should contain the random Doc. No. but the Id should be blanked.
        GraphMgtCustomerPayments.SetCustomerPaymentsFilters(GenJournalLine);
        GenJournalLine.SetRange("Line No.", LineNo);
        GenJournalLine.FindFirst();

        Assert.AreEqual(
          RandomDocNo, GenJournalLine."Applies-to Doc. No.",
          'Journal Line ' + AppliesToDocNo + ' should be changed');

        Assert.IsTrue(
          IsNullGuid(GenJournalLine."Applies-to Invoice Id"),
          'Journal Line Applies-to Invoice Id should be blank but is ' + Format(GenJournalLine."Applies-to Invoice Id"));
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestDeleteCustomerPayment()
    var
        GenJournalLine: Record "Gen. Journal Line";
        JournalName: Code[10];
        BlankGUID: Guid;
        CustomerPaymentGUID: Guid;
        LineNo: Integer;
        TargetURL: Text;
        ResponseText: Text;
    begin
        // [SCENARIO] Create a customer payment, use a DELETE method to remove it and then verify the deletion
        Initialize();
        LibraryGraphJournalLines.Initialize();

        // [GIVEN] a journal
        JournalName := LibraryGraphJournalLines.CreateCustomerPaymentsJournal();

        // [GIVEN] a line in the Cash Receipts Journal Table
        LineNo := LibraryGraphJournalLines.CreateCustomerPayment(JournalName, '', BlankGUID, '', BlankGUID, 0, '');

        // [GIVEN] the customer payment's unique GUID
        GraphMgtCustomerPayments.SetCustomerPaymentsFilters(GenJournalLine);
        GenJournalLine.SetFilter("Line No.", Format(LineNo));
        GenJournalLine.FindFirst();
        CustomerPaymentGUID := GenJournalLine.SystemId;
        Assert.AreNotEqual('', CustomerPaymentGUID, 'CustomerPaymentGUID should not be empty');
        Commit();

        // [WHEN] we DELETE the customer payment from the web service, with the customer payment's unique ID
        TargetURL :=
          LibraryGraphMgt.CreateTargetURLWithSubpage(
            GetJournalID(JournalName), PAGE::"APIV1 - Cust. Paym. Journals", ServiceNameTxt, GetCustomerPaymentURL(CustomerPaymentGUID));
        LibraryGraphMgt.DeleteFromWebService(TargetURL, '', ResponseText);

        // [THEN] the customer payment shouldn't exist in the table
        GraphMgtCustomerPayments.SetCustomerPaymentsFilters(GenJournalLine);
        GenJournalLine.SetFilter("Line No.", Format(LineNo));
        Assert.IsFalse(GenJournalLine.FindFirst(), 'The Customer Payment should be deleted.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestCustomerAutofillWhenGivingInvoiceNumber()
    var
        GenJournalLine: Record "Gen. Journal Line";
        JournalName: Code[10];
        LineNo: Integer;
        CustomerNo: Code[20];
        AppliesToDocNo: Code[20];
        LineJSON: Text;
        TargetURL: Text;
        ResponseText: Text;
    begin
        // [SCENARIO] Create a customer payment through a POST method and check if the Customer was Auto-filled
        Initialize();
        LibraryGraphJournalLines.Initialize();

        // [GIVEN] a journal
        JournalName := LibraryGraphJournalLines.CreateCustomerPaymentsJournal();

        // [GIVEN] a JSON text with a customer payment containing an InvoiceNumber
        LineNo := LibraryGraphJournalLines.GetNextCustomerPaymentNo(JournalName);
        CustomerNo := LibraryGraphJournalLines.CreateCustomer();
        AppliesToDocNo := LibraryGraphJournalLines.CreatePostedSalesInvoice(CustomerNo);
        LineJSON := LibraryGraphMgt.AddPropertytoJSON('', AppliesToDocNoNameTxt, AppliesToDocNo);
        Commit();

        // [WHEN] we POST the JSON to the web service
        TargetURL :=
          LibraryGraphMgt.CreateTargetURLWithSubpage(
            GetJournalID(JournalName), PAGE::"APIV1 - Cust. Paym. Journals", ServiceNameTxt, ServiceSubpageNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, LineJSON, ResponseText);

        // [THEN] the response text should contain the Invoice Number and the Customer Number should be filled with the Invoice's Customer
        Assert.AreNotEqual('', ResponseText, 'JSON Should not be blank');
        VerifyLineNoInJson(ResponseText, Format(LineNo));
        LibraryGraphMgt.VerifyIDFieldInJsonWithoutIntegrationRecord(ResponseText, 'id');

        GraphMgtCustomerPayments.SetCustomerPaymentsFilters(GenJournalLine);
        GenJournalLine.SetRange("Line No.", LineNo);
        GenJournalLine.FindFirst();
        Assert.AreEqual(CustomerNo, GenJournalLine."Account No.", 'Journal Line ' + CustomerNo + ' should be autofilled');
        Assert.AreEqual(AppliesToDocNo, GenJournalLine."Applies-to Doc. No.", 'Journal Line ' + AppliesToDocNo + ' should be changed');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestCustomerAutofillDoesNotOverwrite()
    var
        GenJournalLine: Record "Gen. Journal Line";
        JournalName: Code[10];
        LineNo: Integer;
        CustomerNo: array[2] of Code[20];
        AppliesToDocNo: Code[20];
        LineJSON: Text;
        TargetURL: Text;
        ResponseText: Text;
    begin
        // [SCENARIO] Create a customer payment through a POST method and check if the Customer was Auto-filled
        Initialize();
        LibraryGraphJournalLines.Initialize();

        // [GIVEN] a journal
        JournalName := LibraryGraphJournalLines.CreateCustomerPaymentsJournal();

        // [GIVEN] a JSON text with a customer payment containing an InvoiceNumber
        LineNo := LibraryGraphJournalLines.GetNextCustomerPaymentNo(JournalName);
        CustomerNo[1] := LibraryGraphJournalLines.CreateCustomer();
        CustomerNo[2] := LibraryGraphJournalLines.CreateCustomer();
        AppliesToDocNo := LibraryGraphJournalLines.CreatePostedSalesInvoice(CustomerNo[1]);
        LineJSON := LibraryGraphMgt.AddPropertytoJSON('', CustomerNoNameTxt, CustomerNo[2]);
        LineJSON := LibraryGraphMgt.AddPropertytoJSON(LineJSON, AppliesToDocNoNameTxt, AppliesToDocNo);
        Commit();

        // [WHEN] we POST the JSON to the web service
        TargetURL :=
          LibraryGraphMgt.CreateTargetURLWithSubpage(
            GetJournalID(JournalName), PAGE::"APIV1 - Cust. Paym. Journals", ServiceNameTxt, ServiceSubpageNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, LineJSON, ResponseText);

        // [THEN] the response text should contain the Invoice Number and the Customer Number should be filled with the Invoice's Customer
        Assert.AreNotEqual('', ResponseText, 'JSON Should not be blank');
        VerifyLineNoInJson(ResponseText, Format(LineNo));
        LibraryGraphMgt.VerifyIDFieldInJsonWithoutIntegrationRecord(ResponseText, 'id');

        GraphMgtCustomerPayments.SetCustomerPaymentsFilters(GenJournalLine);
        GenJournalLine.SetRange("Line No.", LineNo);
        GenJournalLine.FindFirst();
        Assert.AreEqual(CustomerNo[2], GenJournalLine."Account No.", 'Journal Line ' + CustomerNo[2] + ' should not be autofilled');
        Assert.AreEqual(AppliesToDocNo, GenJournalLine."Applies-to Doc. No.", 'Journal Line ' + AppliesToDocNo + ' should be changed');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestCustomerNoAndIdSync()
    var
        GenJournalLine: Record "Gen. Journal Line";
        Customer: Record Customer;
        JournalName: Code[10];
        LineNo: array[3] of Integer;
        CustomerNo: Code[20];
        CustomerGUID: Guid;
        LineJSON: array[3] of Text;
        TargetURL: Text;
        ResponseText: array[3] of Text;
    begin
        // [SCENARIO] Create a customer payment through a POST method and check if the Customer No and Id are filled correctly
        // [GIVEN] an empty journal
        Initialize();
        LibraryGraphJournalLines.Initialize();

        // [GIVEN] a journal
        JournalName := LibraryGraphJournalLines.CreateCustomerPaymentsJournal();

        // [GIVEN] a customer
        CustomerNo := LibraryGraphJournalLines.CreateCustomer();
        Customer.Get(CustomerNo);
        CustomerGUID := Customer.SystemId;

        // [GIVEN] JSON texts for a customer payment with and without CustomerNo and CustomerId
        LineNo[1] := LibraryGraphJournalLines.GetNextCustomerPaymentNo(JournalName);
        LineNo[2] := LibraryGraphJournalLines.GetNextCustomerPaymentNo(JournalName);
        LineNo[3] := LibraryGraphJournalLines.GetNextCustomerPaymentNo(JournalName);

        LineJSON[3] := LibraryGraphMgt.AddPropertytoJSON('', CustomerNoNameTxt, CustomerNo);
        LineJSON[3] := LibraryGraphMgt.AddPropertytoJSON(LineJSON[3], CustomerIdFieldTxt, CustomerGUID);
        LineJSON[1] := LibraryGraphMgt.AddPropertytoJSON('', CustomerNoNameTxt, CustomerNo);
        LineJSON[2] := LibraryGraphMgt.AddPropertytoJSON('', CustomerIdFieldTxt, CustomerGUID);

        Commit();

        // [WHEN] we POST the JSONs to the web service
        TargetURL :=
          LibraryGraphMgt.CreateTargetURLWithSubpage(
            GetJournalID(JournalName), PAGE::"APIV1 - Cust. Paym. Journals", ServiceNameTxt, ServiceSubpageNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, LineJSON[1], ResponseText[1]);
        LibraryGraphMgt.PostToWebService(TargetURL, LineJSON[2], ResponseText[2]);
        LibraryGraphMgt.PostToWebService(TargetURL, LineJSON[3], ResponseText[3]);

        // [THEN] the response text should contain the customer payment information and the integration record table should map the JournalLineID with the ID
        GraphMgtCustomerPayments.SetCustomerPaymentsFilters(GenJournalLine);
        GenJournalLine.SetRange("Line No.", LineNo[1]);
        GenJournalLine.FindFirst();
        Assert.AreEqual(
          CustomerNo, GenJournalLine."Account No.", 'Customer Payment ' + CustomerNoNameTxt + ' should have the correct Customer No');
        Assert.AreEqual(
          CustomerGUID, GenJournalLine."Customer Id", 'Customer Payment ' + CustomerIdFieldTxt + ' should have the correct Customer Id');

        GenJournalLine.Reset();
        GraphMgtCustomerPayments.SetCustomerPaymentsFilters(GenJournalLine);
        GenJournalLine.SetRange("Line No.", LineNo[2]);
        GenJournalLine.FindFirst();
        Assert.AreEqual(
          CustomerNo, GenJournalLine."Account No.", 'Customer Payment ' + CustomerNoNameTxt + ' should have the correct Customer No');
        Assert.AreEqual(
          CustomerGUID, GenJournalLine."Customer Id", 'Customer Payment ' + CustomerIdFieldTxt + ' should have the correct Customer Id');

        GenJournalLine.Reset();
        GraphMgtCustomerPayments.SetCustomerPaymentsFilters(GenJournalLine);
        GenJournalLine.SetRange("Line No.", LineNo[3]);
        GenJournalLine.FindFirst();
        Assert.AreEqual(
          CustomerNo, GenJournalLine."Account No.", 'Customer Payment ' + CustomerNoNameTxt + ' should have the correct Customer No');
        Assert.AreEqual(
          CustomerGUID, GenJournalLine."Customer Id", 'Customer Payment ' + CustomerIdFieldTxt + ' should have the correct Customer Id');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestCustomerNoAndIdSyncErrors()
    var
        Customer: Record Customer;
        JournalName: Code[10];
        CustomerNo: Code[20];
        CustomerGUID: Guid;
        LineJSON: array[3] of Text;
        TargetURL: Text;
        ResponseText: array[3] of Text;
    begin
        // [SCENARIO] Create a customer payment through a POST method and check if the Customer Id and the Customer No Sync throws the errors
        // [GIVEN] an empty journal
        Initialize();
        LibraryGraphJournalLines.Initialize();

        // [GIVEN] a journal
        JournalName := LibraryGraphJournalLines.CreateCustomerPaymentsJournal();

        // [GIVEN] a customer
        CustomerNo := LibraryGraphJournalLines.CreateCustomer();
        Customer.Get(CustomerNo);
        CustomerGUID := Customer.SystemId;
        Customer.Delete();

        // [GIVEN] JSON texts for a customer payment with and without CustomerNo and CustomerId
        LineJSON[1] := LibraryGraphMgt.AddPropertytoJSON('', CustomerNoNameTxt, CustomerNo);
        LineJSON[2] := LibraryGraphMgt.AddPropertytoJSON('', CustomerIdFieldTxt, CustomerGUID);

        Commit();

        // [WHEN] we POST the JSONs to the web service
        // [THEN] we will get errors because the Customer doesn't exist
        TargetURL :=
          LibraryGraphMgt.CreateTargetURLWithSubpage(
            GetJournalID(JournalName), PAGE::"APIV1 - Cust. Paym. Journals", ServiceNameTxt, ServiceSubpageNameTxt);
        asserterror LibraryGraphMgt.PostToWebService(TargetURL, LineJSON[1], ResponseText[1]);
        asserterror LibraryGraphMgt.PostToWebService(TargetURL, LineJSON[2], ResponseText[2]);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestAppliesToInvoiceNoAndIdSync()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        GenJournalLine: Record "Gen. Journal Line";
        SalesInvoiceAggregator: Codeunit "Sales Invoice Aggregator";
        JournalName: Code[10];
        LineNo: array[3] of Integer;
        CustomerNo: Code[20];
        AppliesToDocNo: Code[20];
        AppliesToDocGUID: Guid;
        LineJSON: array[3] of Text;
        TargetURL: Text;
        ResponseText: array[3] of Text;
    begin
        // [SCENARIO] Create a customer payment through a POST method and check if the AppliesToInvoice No and Id are filled correctly
        // [GIVEN] an empty journal
        Initialize();
        LibraryGraphJournalLines.Initialize();

        // [GIVEN] a journal
        JournalName := LibraryGraphJournalLines.CreateCustomerPaymentsJournal();

        // [GIVEN] a customer
        CustomerNo := LibraryGraphJournalLines.CreateCustomer();

        // [GIVEN] a posted sales invoice
        AppliesToDocNo := LibraryGraphJournalLines.CreatePostedSalesInvoice(CustomerNo);
        SalesInvoiceHeader.Get(AppliesToDocNo);
        AppliesToDocGUID := SalesInvoiceAggregator.GetSalesInvoiceHeaderId(SalesInvoiceHeader);

        // [GIVEN] JSON texts for a customer payment with and without CustomerNo and CustomerId
        LineNo[1] := LibraryGraphJournalLines.GetNextCustomerPaymentNo(JournalName);
        LineNo[2] := LibraryGraphJournalLines.GetNextCustomerPaymentNo(JournalName);
        LineNo[3] := LibraryGraphJournalLines.GetNextCustomerPaymentNo(JournalName);

        LineJSON[1] := LibraryGraphMgt.AddPropertytoJSON('', AppliesToDocNoNameTxt, AppliesToDocNo);
        LineJSON[2] := LibraryGraphMgt.AddPropertytoJSON('', AppliesToInvoiceIdTxt, AppliesToDocGUID);
        LineJSON[3] := LibraryGraphMgt.AddPropertytoJSON('', AppliesToDocNoNameTxt, AppliesToDocNo);
        LineJSON[3] := LibraryGraphMgt.AddPropertytoJSON(LineJSON[3], AppliesToInvoiceIdTxt, AppliesToDocGUID);

        Commit();

        // [WHEN] we POST the JSONs to the web service
        TargetURL :=
          LibraryGraphMgt.CreateTargetURLWithSubpage(
            GetJournalID(JournalName), PAGE::"APIV1 - Cust. Paym. Journals", ServiceNameTxt, ServiceSubpageNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, LineJSON[1], ResponseText[1]);
        LibraryGraphMgt.PostToWebService(TargetURL, LineJSON[2], ResponseText[2]);
        LibraryGraphMgt.PostToWebService(TargetURL, LineJSON[3], ResponseText[3]);

        // [THEN] the response text should contain the customer payment information and the integration record table should map the JournalLineID with the ID
        GraphMgtCustomerPayments.SetCustomerPaymentsFilters(GenJournalLine);
        GenJournalLine.SetRange("Line No.", LineNo[1]);
        GenJournalLine.FindFirst();
        Assert.AreEqual(
          AppliesToDocNo, GenJournalLine."Applies-to Doc. No.",
          'Customer Payment ' + AppliesToDocNoNameTxt + ' should have the correct AppliesToDoc No');
        Assert.AreEqual(
          AppliesToDocGUID, GenJournalLine."Applies-to Invoice Id",
          'Customer Payment ' + AppliesToInvoiceIdTxt + ' should have the correct AppliesToDoc Id');

        GenJournalLine.Reset();
        GenJournalLine.SetRange("Line No.", LineNo[2]);
        GraphMgtCustomerPayments.SetCustomerPaymentsFilters(GenJournalLine);
        GenJournalLine.FindFirst();
        Assert.AreEqual(
          AppliesToDocNo, GenJournalLine."Applies-to Doc. No.",
          'Customer Payment ' + AppliesToDocNoNameTxt + ' should have the correct AppliesToDoc No');
        Assert.AreEqual(
          AppliesToDocGUID, GenJournalLine."Applies-to Invoice Id",
          'Customer Payment ' + AppliesToInvoiceIdTxt + ' should have the correct AppliesToDoc Id');

        GenJournalLine.Reset();
        GenJournalLine.SetRange("Line No.", LineNo[3]);
        GraphMgtCustomerPayments.SetCustomerPaymentsFilters(GenJournalLine);
        GenJournalLine.FindFirst();
        Assert.AreEqual(
          AppliesToDocNo, GenJournalLine."Applies-to Doc. No.",
          'Customer Payment ' + AppliesToDocNoNameTxt + ' should have the correct AppliesToDoc No');
        Assert.AreEqual(
          AppliesToDocGUID, GenJournalLine."Applies-to Invoice Id",
          'Customer Payment ' + AppliesToInvoiceIdTxt + ' should have the correct AppliesToDoc Id');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestAppliesToInvoiceNoAndIdSyncErrors()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesInvoiceAggregator: Codeunit "Sales Invoice Aggregator";
        JournalName: Code[10];
        CustomerNo: Code[20];
        AppliesToDocNo: Code[20];
        AppliesToDocGUID: Guid;
        LineJSON: Text;
        TargetURL: Text;
        ResponseText: Text;
    begin
        // [SCENARIO] Create a customer payment through a POST method and check if the AppliesToInvoiceNo Sync throws the errors
        // [GIVEN] an empty journal
        Initialize();
        LibraryGraphJournalLines.Initialize();

        // [GIVEN] a journal
        JournalName := LibraryGraphJournalLines.CreateCustomerPaymentsJournal();

        // [GIVEN] a customer
        CustomerNo := LibraryGraphJournalLines.CreateCustomer();

        // [GIVEN] a posted sales invoice
        AppliesToDocNo := LibraryGraphJournalLines.CreatePostedSalesInvoice(CustomerNo);
        SalesInvoiceHeader.Get(AppliesToDocNo);
        AppliesToDocGUID := SalesInvoiceAggregator.GetSalesInvoiceHeaderId(SalesInvoiceHeader);
        SalesInvoiceHeader.Delete();

        // [GIVEN] JSON texts for a customer payment with and without CustomerNo and CustomerId
        LineJSON := LibraryGraphMgt.AddPropertytoJSON('', AppliesToInvoiceIdTxt, AppliesToDocGUID);

        Commit();

        // [WHEN] we POST the JSON to the web service
        // [THEN] we will get errors because the Account doesn't exist
        TargetURL :=
          LibraryGraphMgt.CreateTargetURLWithSubpage(
            GetJournalID(JournalName), PAGE::"APIV1 - Cust. Paym. Journals", ServiceNameTxt, ServiceSubpageNameTxt);
        asserterror LibraryGraphMgt.PostToWebService(TargetURL, LineJSON, ResponseText);
    end;

    local procedure Initialize()
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"APIV1 - Customer Payments E2E");

        if not isInitialized then
            isInitialized := true;

        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"APIV1 - Customer Payments E2E");
    end;

    local procedure VerifyLineNoInJson(JSONTxt: Text; ExpectedLineNo: Text)
    var
        GenJournalLine: Record "Gen. Journal Line";
        LineNo: Integer;
        LineNoValue: Text;
    begin
        Assert.IsTrue(LibraryGraphMgt.GetObjectIDFromJSON(JSONTxt, LineNumberNameTxt, LineNoValue), 'Could not find LineNo');
        Assert.AreEqual(ExpectedLineNo, LineNoValue, 'LineNo does not match');

        GraphMgtCustomerPayments.SetCustomerPaymentsFilters(GenJournalLine);
        Evaluate(LineNo, LineNoValue);
        GenJournalLine.SetRange("Line No.", LineNo);
        GenJournalLine.FindFirst();
    end;

    local procedure VerifyCustomerFields(ExpectedCustomer: Record Customer; ResponseText: Text)
    var
        IntegrationManagement: Codeunit "Integration Management";
        customerIdValue: Text;
        customerNumberValue: Text;
    begin
        LibraryGraphMgt.GetObjectIDFromJSON(ResponseText, CustomerIdFieldTxt, customerIdValue);
        LibraryGraphMgt.GetObjectIDFromJSON(ResponseText, CustomerNoNameTxt, customerNumberValue);

        Assert.AreEqual(
          IntegrationManagement.GetIdWithoutBrackets(ExpectedCustomer.SystemId), UpperCase(customerIdValue), 'Wrong setting for Customer Id');
        Assert.AreEqual(ExpectedCustomer."No.", customerNumberValue, 'Wrong setting for Customer Number');
    end;

    local procedure VerifyValidPostRequest(ResponseText: Text; var LineNo: Text)
    begin
        Assert.AreNotEqual('', ResponseText, 'response JSON should not be blank');
        Assert.IsTrue(
          LibraryGraphMgt.GetObjectIDFromJSON(ResponseText, LineNumberNameTxt, LineNo),
          'Could not find customer payments number');
        LibraryGraphMgt.VerifyIDFieldInJsonWithoutIntegrationRecord(ResponseText, 'id');
    end;

    local procedure GetJournalID(JournalName: Code[10]): Guid
    var
        GenJournalBatch: Record "Gen. Journal Batch";
    begin
        GenJournalBatch.Get(GraphMgtJournal.GetDefaultCustomerPaymentsTemplateName(), JournalName);
        exit(GenJournalBatch.SystemId);
    end;

    local procedure GetCustomerPaymentURL(CustomerPaymentId: Text): Text
    begin
        exit(ServiceSubpageNameTxt + '(' + LibraryGraphMgt.StripBrackets(CustomerPaymentId) + ')');
    end;
}

