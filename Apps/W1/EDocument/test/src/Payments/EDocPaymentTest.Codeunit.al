codeunit 139505 "E-Doc. Payment Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Customer: Record "Customer";
        EDocService: Record "E-Document Service";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Vendor: Record Vendor;
        Assert: Codeunit "Assert";
        EDocExportMgt: Codeunit "E-Doc. Export";
        EDocImplState: Codeunit "E-Doc. Impl. State";
        EDocLogTest: Codeunit "E-Doc Log Test";
        EDocPaymentImplState: Codeunit "E-Doc. Payment Impl. State";
        LibraryEDoc: Codeunit "Library - E-Document";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryRandom: Codeunit "Library - Random";
        LibraryInventory: Codeunit "Library - Inventory";
        PurchOrderTestBuffer: Codeunit "E-Doc. Test Buffer";

    //Create partial payment
    [Test]
    procedure CreateOutgoingPartialPaymentTest()
    var
        EDocument: Record "E-Document";
        EDocServicePage: TestPage "E-Document Service";
        PaymentAmount: Decimal;
        i: Integer;
    begin
        // [FEATURE] [E-Document]
        // [SCENARIO] Create partial payment for received E-Document
        this.Initialize();

        // [GIVEN] Create E-Document service setup
        this.LibraryEDoc.CreateTestPaymentServiceForEDoc(this.EDocService, Enum::"Service Integration"::Mock, Enum::"Payment Integration"::Mock);
        this.SetDefaultEDocServiceValues(this.EDocService, false);
        BindSubscription(this.EDocImplState);

        // [GIVEN] Create received E-Document
        this.LibraryPurchase.CreateVendorWithAddress(this.Vendor);
        this.Vendor."Receive E-Document To" := this.Vendor."Receive E-Document To"::"Purchase Invoice";
        this.Vendor.Modify();
        this.LibraryPurchase.CreatePurchHeader(this.PurchaseHeader, this.PurchaseHeader."Document Type"::Invoice, this.Vendor."No.");

        for i := 1 to 3 do begin
            this.LibraryPurchase.CreatePurchaseLine(this.PurchaseLine, this.PurchaseHeader, this.PurchaseLine.Type::Item, this.LibraryInventory.CreateItemNo(), this.LibraryRandom.RandInt(100));
            this.PurchaseLine.Validate("Direct Unit Cost", this.LibraryRandom.RandDecInRange(1, 100, 2));
            this.PurchaseLine.Modify(true);
        end;

        this.PurchOrderTestBuffer.ClearTempVariables();
        this.PurchOrderTestBuffer.AddPurchaseDocToTemp(this.PurchaseHeader);

        // [WHEN] Running Receive
        EDocServicePage.OpenView();
        EDocServicePage.Filter.SetFilter(Code, this.EDocService.Code);
        EDocServicePage.Receive.Invoke();
        UnbindSubscription(this.EDocImplState);

        // [THEN] Purchase invoice is created with corresponding values
        EDocument.FindLast();

        // [THEN] Check that Paid Amount for the document is 0
        this.CheckPaidAmount(EDocument, 0);

        // [GIVEN] Create partial payment for E-Document
        PaymentAmount := 100;
        this.CreateEDocumentPayment(EDocument, PaymentAmount);

        // [THEN] Check that Paid Amount for the document is updated
        this.CheckPaidAmount(EDocument, PaymentAmount);

        // [THEN] Check that Payments Direction is correct
        this.CheckPaymentDirection(EDocument, Enum::"E-Document Direction"::Outgoing);
    end;

    //Create full payment
    [Test]
    procedure CreateOutgoingFullPaymentTest()
    var
        EDocument: Record "E-Document";
        EDocServicePage: TestPage "E-Document Service";
        i: Integer;
    begin
        // [FEATURE] [E-Document]
        // [SCENARIO] Send payment for received E-Document
        this.Initialize();

        // [GIVEN] Create E-Document service setup
        this.LibraryEDoc.CreateTestPaymentServiceForEDoc(this.EDocService, Enum::"Service Integration"::Mock, Enum::"Payment Integration"::Mock);
        this.SetDefaultEDocServiceValues(this.EDocService, false);
        BindSubscription(this.EDocImplState);

        // [GIVEN] Create received E-Document
        this.LibraryPurchase.CreateVendorWithAddress(this.Vendor);
        this.Vendor."Receive E-Document To" := this.Vendor."Receive E-Document To"::"Purchase Invoice";
        this.Vendor.Modify();
        this.LibraryPurchase.CreatePurchHeader(this.PurchaseHeader, this.PurchaseHeader."Document Type"::Invoice, this.Vendor."No.");

        for i := 1 to 3 do begin
            this.LibraryPurchase.CreatePurchaseLine(this.PurchaseLine, this.PurchaseHeader, this.PurchaseLine.Type::Item, this.LibraryInventory.CreateItemNo(), this.LibraryRandom.RandInt(100));
            this.PurchaseLine.Validate("Direct Unit Cost", this.LibraryRandom.RandDecInRange(1, 100, 2));
            this.PurchaseLine.Modify(true);
        end;

        this.PurchOrderTestBuffer.ClearTempVariables();
        this.PurchOrderTestBuffer.AddPurchaseDocToTemp(this.PurchaseHeader);

        // [WHEN] Running Receive
        EDocServicePage.OpenView();
        EDocServicePage.Filter.SetFilter(Code, this.EDocService.Code);
        EDocServicePage.Receive.Invoke();
        UnbindSubscription(this.EDocImplState);

        // [THEN] Purchase invoice is created with corresponding values
        EDocument.FindLast();

        // [THEN] Check that Paid Amount for the document is 0
        this.CheckPaidAmount(EDocument, 0);

        // [GIVEN] Create partial payment for E-Document
        this.CreateFullEDocumentPayments(EDocument);

        // [THEN] Check that Paid Amount for the document is updated
        this.CheckPaidAmount(EDocument, EDocument."Amount Incl. VAT");

        // [THEN] Check that Payments Direction is correct
        this.CheckPaymentDirection(EDocument, Enum::"E-Document Direction"::Outgoing);
    end;

    //Create partial payment
    [Test]
    procedure CreateOutgoingPaymentWithVATCalculationTest()
    var
        EDocument: Record "E-Document";
        EDocServicePage: TestPage "E-Document Service";
        PaymentAmount: Decimal;
        i: Integer;
    begin
        // [FEATURE] [E-Document]
        // [SCENARIO] Create partial payment for received E-Document
        this.Initialize();

        // [GIVEN] Create E-Document service setup and set VAT calculation
        this.LibraryEDoc.CreateTestPaymentServiceForEDoc(this.EDocService, Enum::"Service Integration"::Mock, Enum::"Payment Integration"::Mock);
        this.SetDefaultEDocServiceValues(this.EDocService, true);
        BindSubscription(this.EDocImplState);

        // [GIVEN] Create received E-Document
        this.LibraryPurchase.CreateVendorWithAddress(this.Vendor);
        this.Vendor."Receive E-Document To" := this.Vendor."Receive E-Document To"::"Purchase Invoice";
        this.Vendor.Modify();
        this.LibraryPurchase.CreatePurchHeader(this.PurchaseHeader, this.PurchaseHeader."Document Type"::Invoice, this.Vendor."No.");

        for i := 1 to 3 do begin
            this.LibraryPurchase.CreatePurchaseLine(this.PurchaseLine, this.PurchaseHeader, this.PurchaseLine.Type::Item, this.LibraryInventory.CreateItemNo(), this.LibraryRandom.RandInt(100));
            this.PurchaseLine.Validate("Direct Unit Cost", this.LibraryRandom.RandDecInRange(1, 100, 2));
            this.PurchaseLine.Modify(true);
        end;

        this.PurchOrderTestBuffer.ClearTempVariables();
        this.PurchOrderTestBuffer.AddPurchaseDocToTemp(this.PurchaseHeader);

        // [WHEN] Running Receive
        EDocServicePage.OpenView();
        EDocServicePage.Filter.SetFilter(Code, this.EDocService.Code);
        EDocServicePage.Receive.Invoke();
        UnbindSubscription(this.EDocImplState);

        // [THEN] Purchase invoice is created with corresponding values
        EDocument.FindLast();

        // [THEN] Check that Paid Amount for the document is 0
        this.CheckPaidAmount(EDocument, 0);

        // [GIVEN] Create partial payment for E-Document
        PaymentAmount := 100;
        this.CreateEDocumentPayment(EDocument, PaymentAmount);

        // [THEN] Check that Paid Amount for the document is updated
        this.CheckPaidAmount(EDocument, PaymentAmount);

        // [THEN] Check that VAT amount is calculated
        this.CheckPaymentVATAmount(EDocument);
    end;

    //Create incoming partial payment
    [Test]
    procedure CreateIncomingPartialPaymentTest()
    var
        EDocument: Record "E-Document";
        PaymentAmount: Decimal;
    begin
        // [FEATURE] [E-Document]
        // [SCENARIO] Receive payment for sent E-Document
        this.Initialize();

        // [GIVEN] Setup E-Document service to send E-Document and receive payment
        this.LibraryEDoc.SetupStandardVAT();
        this.LibraryEDoc.SetupStandardSalesScenario(this.Customer, this.EDocService, Enum::"E-Document Format"::"PEPPOL BIS 3.0", Enum::"Service Integration"::Mock);
        this.EDocService."Payment Integration" := Enum::"Payment Integration"::Mock;
        this.EDocService."Calculate Payment VAT" := false;
        this.EDocService.Modify();

        // [WHEN] Create and post sales invoice to create E-Document
        this.LibraryEDoc.PostInvoice(this.Customer);
        EDocument.FindLast();

        // [WHEN] Export EDocument
        BindSubscription(this.EDocLogTest);
        this.EDocExportMgt.ExportEDocument(EDocument, this.EDocService);
        UnbindSubscription(this.EDocLogTest);

        // [THEN] Check that Paid Amount for the document is 0
        this.CheckPaidAmount(EDocument, 0);

        // [WHEN] Receive payment for E-Document
        PaymentAmount := 1;
        this.CreateEDocumentPayment(EDocument, PaymentAmount);

        // [THEN] Check that Paid Amount for the document is updated
        this.CheckPaidAmount(EDocument, PaymentAmount);

        // [THEN] Check that Payments Direction is correct
        this.CheckPaymentDirection(EDocument, Enum::"E-Document Direction"::Incoming);
    end;

    //Receive incoming payment
    [HandlerFunctions('EDocumentServiceSelectionHandler')]
    [Test]
    procedure ReceivePaymentTest()
    var
        EDocument: Record "E-Document";
    begin
        // [FEATURE] [E-Document]
        // [SCENARIO] Receive payment for sent E-Document
        this.Initialize();

        // [GIVEN] Setup E-Document service to send E-Document and receive payment
        this.LibraryEDoc.SetupStandardVAT();
        this.LibraryEDoc.SetupStandardSalesScenario(this.Customer, this.EDocService, Enum::"E-Document Format"::"PEPPOL BIS 3.0", Enum::"Service Integration"::Mock);
        this.EDocService."Payment Integration" := Enum::"Payment Integration"::Mock;
        this.EDocService."Calculate Payment VAT" := false;
        this.EDocService.Modify();

        // [WHEN] Create and post sales invoice to create E-Document
        this.LibraryEDoc.PostInvoice(this.Customer);
        EDocument.FindLast();

        // [WHEN] Export EDocument
        BindSubscription(this.EDocLogTest);
        this.EDocExportMgt.ExportEDocument(EDocument, this.EDocService);
        UnbindSubscription(this.EDocLogTest);

        // [THEN] Check that Paid Amount for the document is 0
        this.CheckPaidAmount(EDocument, 0);

        // [WHEN] Receive payment for E-Document
        this.ReceivePayment(EDocument);

        // [THEN] Check that Paid Amount for the document is updated
        this.CheckPaidAmount(EDocument, 1);

        // [THEN] Check that Payments Direction is correct
        this.CheckPaymentDirection(EDocument, Enum::"E-Document Direction"::Incoming);
    end;

    local procedure Initialize()
    var
        EDocument: Record "E-Document";
        EDocumentPayment: Record "E-Document Payment";
    begin
        Clear(this.EDocPaymentImplState);
        EDocument.DeleteAll(false);
        EDocumentPayment.DeleteAll(false);

        Clear(this.PurchaseHeader);
        this.PurchaseHeader.DeleteAll(false);

        Clear(this.EDocService);
    end;

    local procedure SetDefaultEDocServiceValues(var EDocService: Record "E-Document Service"; CalculateVAT: Boolean)
    begin
        EDocService."Lookup Account Mapping" := false;
        EDocService."Lookup Item GTIN" := false;
        EDocService."Lookup Item Reference" := false;
        EDocService."Resolve Unit Of Measure" := false;
        EDocService."Validate Line Discount" := false;
        EDocService."Verify Totals" := false;
        EDocService."Use Batch Processing" := false;
        EDocService."Calculate Payment VAT" := CalculateVAT;
        EDocService.Modify(false);
    end;

    local procedure CreateEDocumentPayment(EDocument: Record "E-Document"; PaymentAmount: Decimal)
    begin
        this.CreateEDocumentPaymentRecord(EDocument."Entry No", PaymentAmount)
    end;

    local procedure CreateFullEDocumentPayments(EDocument: Record "E-Document")
    begin
        this.CreateEDocumentPaymentRecord(EDocument."Entry No", 100);
        this.CreateEDocumentPaymentRecord(EDocument."Entry No", EDocument."Amount Incl. VAT" - 100)
    end;

    local procedure CreateEDocumentPaymentRecord(EDocumentEntryNo: Integer; Amount: Decimal)
    var
        EDocumentPayment: Record "E-Document Payment";
    begin
        EDocumentPayment.Init();
        EDocumentPayment.Validate("E-Document Entry No.", EDocumentEntryNo);
        EDocumentPayment.Date := Today();
        EDocumentPayment.Validate(Amount, Amount);
        EDocumentPayment.Insert(true);
    end;

    local procedure ReceivePayment(EDocument: Record "E-Document")
    var
        EDocumentPage: TestPage "E-Document";
    begin
        BindSubscription(this.EDocPaymentImplState);
        EDocumentPage.OpenView();
        EDocumentPage.GoToRecord(EDocument);
        EDocumentPage.ReceivePayments.Invoke();
        UnbindSubscription(this.EDocPaymentImplState);
    end;

    local procedure CheckPaidAmount(EDocument: Record "E-Document"; ExpectedPaidAmount: Decimal)
    begin
        EDocument.CalcFields("Paid Amount");
        this.Assert.AreEqual(ExpectedPaidAmount, EDocument."Paid Amount", 'Paid Amount is not updated.');
    end;

    local procedure CheckPaymentVATAmount(EDocument: Record "E-Document")
    var
        EDocumentPayment: Record "E-Document Payment";
    begin
        EDocumentPayment.SetRange("E-Document Entry No.", EDocument."Entry No");
        if EDocumentPayment.FindSet() then
            repeat
                this.Assert.AreNotEqual(0, EDocumentPayment."VAT Base", 'Payment Base Amount is not calculated.');
                this.Assert.AreNotEqual(0, EDocumentPayment."VAT Amount", 'Payment VAT Amount is not calculated.');
            until EDocumentPayment.Next() = 0;
    end;

    local procedure CheckPaymentDirection(EDocument: Record "E-Document"; ExpectedDirection: Enum "E-Document Direction")
    var
        EDocumentPayment: Record "E-Document Payment";
    begin
        EDocumentPayment.SetRange("E-Document Entry No.", EDocument."Entry No");
        if EDocumentPayment.FindSet() then
            repeat
                this.Assert.AreEqual(ExpectedDirection, EDocumentPayment.Direction, 'Payment Direction is not correct.');
            until EDocumentPayment.Next() = 0;
    end;

    [ModalPageHandler]
    procedure EDocumentServiceSelectionHandler(var EDocumentServices: TestPage "E-Document Services")
    begin
        EDocumentServices.GoToRecord(this.EDocService);
        EDocumentServices.OK().Invoke();
    end;
}
