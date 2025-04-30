namespace Microsoft.SubscriptionBilling;

using Microsoft.Finance.Currency;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Foundation.Attachment;
using Microsoft.Inventory.Item;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using Microsoft.Utilities;
using System.Globalization;
using System.TestLibraries.Utilities;

codeunit 148155 "Contracts Test"
{
    Subtype = Test;
    TestPermissions = Disabled;
    Access = Internal;

    var
        Assert: Codeunit Assert;
        ContractTestLibrary: Codeunit "Contract Test Library";
        CorrectPostedSalesInvoice: Codeunit "Correct Posted Sales Invoice";
        LibraryERM: Codeunit "Library - ERM";
        LibraryERMCountryData: Codeunit "Library - ERM Country Data";
        LibraryRandom: Codeunit "Library - Random";
        LibrarySales: Codeunit "Library - Sales";
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        IsInitialized: Boolean;

    #region Tests

    [Test]
    [HandlerFunctions('CreateCustomerBillingDocsSellToCustomerPageHandler,MessageHandler,ExchangeRateSelectionModalPageHandler')]
    procedure CheckCreateMultipleSalesInvoicesPerDetailOverview()
    var
        BillingLine: Record "Billing Line";
        BillingTemplate: Record "Billing Template";
        Customer: Record Customer;
        CustomerContract: Record "Customer Subscription Contract";
        DocumentsCount: Integer;
        ContractsFilter: Text;
    begin
        // Contract1, Sell-to Customer1, "Detail Overview"::"Without prices"
        // Contract2, Sell-to Customer1, "Detail Overview"::Complete
        // Contract3, Sell-to Customer1, "Detail Overview"::"Without prices"
        // Contract4, Sell-to Customer1, "Detail Overview"::None
        // Contract5, Sell-to Customer1, "Detail Overview"::Complete
        // Expect 3 Sales Invoice Documents grouped per Detail Overview although is grouped by Sell-to Customer
        Initialize();

        ContractTestLibrary.CreateCustomer(Customer);

        CreateCustomerContractWithDetailOverview(ContractsFilter, CustomerContract."Detail Overview"::"Without prices", Customer."No.", CustomerContract);
        CreateCustomerContractWithDetailOverview(ContractsFilter, CustomerContract."Detail Overview"::Complete, Customer."No.", CustomerContract);
        CreateCustomerContractWithDetailOverview(ContractsFilter, CustomerContract."Detail Overview"::"Without prices", Customer."No.", CustomerContract);
        CreateCustomerContractWithDetailOverview(ContractsFilter, CustomerContract."Detail Overview"::None, Customer."No.", CustomerContract);
        CreateCustomerContractWithDetailOverview(ContractsFilter, CustomerContract."Detail Overview"::Complete, Customer."No.", CustomerContract);

        ContractTestLibrary.CreateBillingProposal(BillingTemplate, Enum::"Service Partner"::Customer);
        BillingLine.SetRange("Billing Template Code", BillingTemplate.Code);
        BillingLine.SetRange(Partner, BillingLine.Partner::Customer);
        BillingLine.SetFilter("Subscription Contract No.", ContractsFilter);
        Codeunit.Run(Codeunit::"Create Billing Documents", BillingLine);

        DocumentsCount := CountCreatedSalesDocuments(BillingLine);
        Assert.AreEqual(3, DocumentsCount, 'Sales Documents were not created correctly');
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure CheckContractLineTypeForCommentOnCustomerContractLine()
    var
        Customer: Record Customer;
        CustomerContract: Record "Customer Subscription Contract";
        CustomerContractLine: Record "Cust. Sub. Contract Line";
        ServiceObject: Record "Subscription Header";
        CustomerContractPage: TestPage "Customer Contract";
        DescriptionText: Text;
        DescriptionText2: Text;
    begin
        // [SCENARIO] Create Customer Subscription Contract. Add Description and check if the ContractLineType for that line is Comment
        Initialize();

        SetupServiceObjectForNewItemWithServiceCommitment(Customer, ServiceObject, false);
        CreateCustomerContractSetup(Customer, ServiceObject, CustomerContract);

        DescriptionText := LibraryRandom.RandText(100);
        DescriptionText2 := LibraryRandom.RandText(100);
        while DescriptionText2 = DescriptionText do
            DescriptionText2 := LibraryRandom.RandText(100);

        CustomerContractPage.OpenEdit();
        CustomerContractPage.GoToRecord(CustomerContract);
        CustomerContractPage.Lines.New();
        CustomerContractPage.Lines."Service Object Description".SetValue(DescriptionText);
        CustomerContractPage.Lines.New();
        CustomerContractPage.Lines."Service Commitment Description".SetValue(DescriptionText2);
        CustomerContractPage.Close();

        CustomerContractLine.SetRange("Subscription Contract No.", CustomerContract."No.");
        CustomerContractLine.SetRange("Contract Line Type", Enum::"Contract Line Type"::Comment);
        CustomerContractLine.SetRange("Subscription Description", DescriptionText);
        Assert.RecordIsNotEmpty(CustomerContractLine);

        CustomerContractLine.SetRange("Subscription Description");
        CustomerContractLine.SetRange("Subscription Line Description", DescriptionText2);
        CustomerContractLine.SetRange("Contract Line Type", Enum::"Contract Line Type"::Comment);
        CustomerContractLine.FindFirst();
        Assert.RecordIsNotEmpty(CustomerContractLine);
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler,CreateCustomerBillingDocsContractPageHandler,SalesInvoiceListPageHandler,PostedSalesInvoicesPageHandler,SalesCreditMemosPageHandler,PostedSalesCrMemosPageHandler')]
    procedure CheckCustomerContractRelatedDocuments()
    var
        BillingLine: Record "Billing Line";
        BillingTemplate: Record "Billing Template";
        CustomerContract: Record "Customer Subscription Contract";
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        ServiceObject: Record "Subscription Header";
        PostedDocumentNo: Code[20];
        CustomerContractPage: TestPage "Customer Contract";
    begin
        Initialize();

        ContractTestLibrary.CreateCustomerContractAndCreateContractLinesForItems(CustomerContract, ServiceObject, '', true);
        ContractTestLibrary.CreateBillingProposal(BillingTemplate, Enum::"Service Partner"::Customer, WorkDate());
        BillingLine.SetRange("Billing Template Code", BillingTemplate.Code);
        BillingLine.SetRange(Partner, BillingLine.Partner::Customer);
        Codeunit.Run(Codeunit::"Create Billing Documents", BillingLine);

        // Post Sales Document
        BillingLine.FindFirst();
        SalesHeader.Get(BillingLine.GetSalesDocumentTypeFromBillingDocumentType(), BillingLine."Document No.");

        CustomerContractPage.OpenView();
        CustomerContractPage.GoToRecord(CustomerContract);

        LibraryVariableStorage.Enqueue(SalesHeader."No.");
        CustomerContractPage.ShowSalesInvoices.Invoke();

        PostedDocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);
        LibraryVariableStorage.Enqueue(PostedDocumentNo);
        CustomerContractPage.ShowPostedSalesInvoices.Invoke();

        SalesInvoiceHeader.Get(PostedDocumentNo);
        CorrectPostedSalesInvoice.CreateCreditMemoCopyDocument(SalesInvoiceHeader, SalesHeader);
        LibraryVariableStorage.Enqueue(SalesHeader."No.");
        CustomerContractPage.ShowSalesCreditMemos.Invoke();

        PostedDocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);
        LibraryVariableStorage.Enqueue(PostedDocumentNo);
        CustomerContractPage.ShowPostedSalesCreditMemos.Invoke();
    end;

    [Test]
    [HandlerFunctions('CreateCustomerBillingDocsContractPageHandler,MessageHandler,ExchangeRateSelectionModalPageHandler')]
    procedure CheckDetailOverviewOnCreditMemoFromCancelledPostedInvoice()
    var
        CustomerContract: Record "Customer Subscription Contract";
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        PostedDocumentNo: Code[20];
        i: Integer;
    begin
        Initialize();
        for i := 0 to 2 do begin
            ContractTestLibrary.DeleteAllContractRecords();
            CreateContractWithDetailOverviewAndSalesInvoice(i, SalesHeader, CustomerContract);
            PostedDocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);
            SalesInvoiceHeader.Get(PostedDocumentNo);
            CorrectPostedSalesInvoice.CreateCreditMemoCopyDocument(SalesInvoiceHeader, SalesHeader);
            SalesHeader.TestField("Sub. Contract Detail Overview", CustomerContract."Detail Overview");
        end;
    end;

    [Test]
    [HandlerFunctions('CreateCustomerBillingDocsContractPageHandler,MessageHandler,ExchangeRateSelectionModalPageHandler')]
    procedure CheckDetailOverviewOnCreditMemoFromCopiedPostedInvoice()
    var
        CustomerContract: Record "Customer Subscription Contract";
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        CopyDocMgt: Codeunit "Copy Document Mgt.";
        PostedDocumentNo: Code[20];
        i: Integer;
    begin
        Initialize();
        for i := 0 to 2 do begin
            ContractTestLibrary.DeleteAllContractRecords();
            CreateContractWithDetailOverviewAndSalesInvoice(i, SalesHeader, CustomerContract);
            PostedDocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);
            SalesInvoiceHeader.Get(PostedDocumentNo);
            CopyDocMgt.SetProperties(true, false, false, false, true, true, false);
            Clear(SalesHeader);
            SalesHeader."Document Type" := SalesHeader."Document Type"::"Credit Memo";
            SalesHeader.Insert(true);
            CopyDocMgt.CopySalesDoc(Enum::"Sales Document Type From"::"Posted Invoice", SalesInvoiceHeader."No.", SalesHeader);
            SalesHeader.TestField("Sub. Contract Detail Overview", CustomerContract."Detail Overview");
        end;
    end;

    [Test]
    procedure CheckServiceCommitmentsWithoutCustomerContract()
    var
        Customer: Record Customer;
        ServiceCommitment: Record "Subscription Line";
        ServiceObject: Record "Subscription Header";
        ServCommWOCustContract: TestPage "Serv. Comm. WO Cust. Contract";
    begin
        Initialize();

        SetupServiceObjectForNewItemWithServiceCommitment(Customer, ServiceObject, false);

        ServCommWOCustContract.OpenEdit();
        ServiceCommitment.Reset();
        ServiceCommitment.SetRange("Subscription Header No.", ServiceObject."No.");
        ServiceCommitment.FindSet();
        repeat
            if ServiceCommitment."Invoicing via" = Enum::"Invoicing Via"::Contract then
                Assert.IsTrue(ServCommWOCustContract.GoToRecord(ServiceCommitment), 'Expected Service Commitment not found.')
            else
                Assert.IsFalse(ServCommWOCustContract.GoToRecord(ServiceCommitment), 'Service Commitment is found but it should not be.');
        until ServiceCommitment.Next() = 0;
    end;

    [Test]
    [HandlerFunctions('ServCommWOCustContractPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure CheckServiceCommitmentAssignmentToCustomerContractForServiceObjectWithItem()
    var
        Customer: Record Customer;
        CustomerContract: Record "Customer Subscription Contract";
        CustomerContractLine: Record "Cust. Sub. Contract Line";
        ServiceCommitment: Record "Subscription Line";
        ServiceObject: Record "Subscription Header";
        InvoicingViaNotManagedErr: Label 'Invoicing via %1 not managed', Locked = true;
        CustomerContractPage: TestPage "Customer Contract";
    begin
        // [SCENARIO] Check that proper Subscription Lines are assigned to Customer Subscription Contract Lines
        Initialize();

        SetupServiceObjectForNewItemWithServiceCommitment(Customer, ServiceObject, false);

        ContractTestLibrary.CreateCustomerContract(CustomerContract, Customer."No.");

        CustomerContractPage.OpenEdit();
        CustomerContractPage.GoToRecord(CustomerContract);
        CustomerContractPage.GetServiceCommitmentsAction.Invoke();

        ServiceCommitment.SetRange("Subscription Header No.", ServiceObject."No.");
        ServiceCommitment.FindSet();
        repeat
            CustomerContractLine.SetRange("Subscription Contract No.", CustomerContract."No.");
            CustomerContractLine.SetRange("Contract Line Type", Enum::"Contract Line Type"::Item);
            CustomerContractLine.SetRange("Subscription Header No.", ServiceCommitment."Subscription Header No.");
            CustomerContractLine.SetRange("Subscription Line Entry No.", ServiceCommitment."Entry No.");
            case ServiceCommitment."Invoicing via" of
                Enum::"Invoicing Via"::Contract:
                    begin
                        Assert.IsTrue(CustomerContractLine.FindFirst(), 'Service Commitment not assigned to expected Customer Subscription Contract Line.');
                        CustomerContractLine.TestField("Subscription Contract No.", ServiceCommitment."Subscription Contract No.");
                        CustomerContractLine.TestField("Contract Line Type", Enum::"Contract Line Type"::Item);
                        CustomerContractLine.TestField("No.", ServiceObject."Source No.");
                    end;
                Enum::"Invoicing Via"::Sales:
                    begin
                        Assert.IsTrue(CustomerContractLine.IsEmpty(), 'Service Commitment is assigned to Customer Subscription Contract Line but it is not expected.');
                        ServiceCommitment.TestField("Subscription Contract No.", '');
                    end;
                else
                    Error(InvoicingViaNotManagedErr, Format(ServiceCommitment."Invoicing via"));
            end;
        until ServiceCommitment.Next() = 0;
    end;

    [Test]
    [HandlerFunctions('ServCommWOCustContractPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure CheckServiceCommitmentAssignmentToCustomerContractForServiceObjectWithGLAccount()
    var
        Customer: Record Customer;
        CustomerContract: Record "Customer Subscription Contract";
        CustomerContractLine: Record "Cust. Sub. Contract Line";
        ServiceCommitment: Record "Subscription Line";
        ServiceObject: Record "Subscription Header";
        CustomerContractPage: TestPage "Customer Contract";
    begin
        // [SCENARIO] Create a Subscription for G/L Account and make sure that its Subscription Lines can be assigned to a contract

        // [GIVEN] A Subscription for G/L Account has been created with Subscription Lines included
        SetupServiceObjectForNewGLAccountWithServiceCommitment(Customer, ServiceObject);

        // [WHEN] A Contract has been created and Subscription Lines are assigned on a contract
        ContractTestLibrary.CreateCustomerContract(CustomerContract, Customer."No.");

        CustomerContractPage.OpenEdit();
        CustomerContractPage.GoToRecord(CustomerContract);
        CustomerContractPage.GetServiceCommitmentsAction.Invoke();

        // [THEN] A new Contract Line has been created for previously created Subscription Line
        ServiceCommitment.Reset();
        ServiceCommitment.SetRange("Subscription Header No.", ServiceObject."No.");
        ServiceCommitment.FindFirst();
        CustomerContractLine.SetRange("Subscription Contract No.", CustomerContract."No.");
        CustomerContractLine.SetRange("Contract Line Type", Enum::"Contract Line Type"::"G/L Account");
        CustomerContractLine.SetRange("Subscription Header No.", ServiceCommitment."Subscription Header No.");
        CustomerContractLine.SetRange("Subscription Line Entry No.", ServiceCommitment."Entry No.");
        Assert.IsTrue(CustomerContractLine.FindFirst(), 'Service Commitment not assigned to expected Customer Subscription Contract Line.');
        CustomerContractLine.TestField("Subscription Contract No.", ServiceCommitment."Subscription Contract No.");
        CustomerContractLine.TestField("Contract Line Type", Enum::"Contract Line Type"::"G/L Account");
        CustomerContractLine.TestField("No.", ServiceObject."Source No.");
    end;

    [Test]
    [HandlerFunctions('ServCommWOCustContractPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure CheckServiceCommitmentAssignmentToCustomerContractWithShipToCode()
    var
        Customer: Record Customer;
        CustomerContract: Record "Customer Subscription Contract";
        ServiceCommitment: Record "Subscription Line";
        ServiceObject: Record "Subscription Header";
        ServiceObject2: Record "Subscription Header";
        ShipToAddress: Record "Ship-to Address";
        CustomerContractPage: TestPage "Customer Contract";
    begin
        // [SCENARIO] Check that proper Subscription Lines are assigned to Customer Subscription Contract Lines
        Initialize();

        SetupServiceObjectForNewItemWithServiceCommitment(Customer, ServiceObject, false);
        SetupServiceObjectForNewItemWithServiceCommitment(Customer, ServiceObject2, false);
        ContractTestLibrary.CreateCustomerContract(CustomerContract, Customer."No.");
        ShipToAddress.SetRange("Customer No.", Customer."No.");
        ShipToAddress.FindFirst();

        CustomerContract.Validate("Ship-to Code", ShipToAddress.Code);
        CustomerContract.Modify(false);
        ServiceObject2.Validate("Ship-to Code", ShipToAddress.Code);
        ServiceObject2.Modify(false);

        CustomerContractPage.OpenEdit();
        CustomerContractPage.GoToRecord(CustomerContract);
        CustomerContractPage.GetServiceCommitmentsAction.Invoke();

        ServiceCommitment.SetRange("Subscription Header No.", ServiceObject."No.");
        ServiceCommitment.SetRange("Subscription Contract No.", CustomerContract."No.");
        Assert.RecordIsEmpty(ServiceCommitment);
        ServiceCommitment.SetRange("Subscription Header No.", ServiceObject2."No.");
        Assert.RecordIsNotEmpty(ServiceCommitment);
    end;

    [Test]
    [HandlerFunctions('ServCommWOCustContractPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure CheckServiceCommitmentAssignmentToCustomerContractInFCY()
    var
        Currency: Record Currency;
        CurrExchRate: Record "Currency Exchange Rate";
        Customer: Record Customer;
        CustomerContract: Record "Customer Subscription Contract";
        ServiceObject: Record "Subscription Header";
        CustomerContractPage: TestPage "Customer Contract";
    begin
        Initialize();
        Currency.InitRoundingPrecision();

        SetupServiceObjectForNewItemWithServiceCommitment(Customer, ServiceObject, false);
        ContractTestLibrary.CreateCustomerContract(CustomerContract, Customer."No.");

        CustomerContractPage.OpenEdit();
        CustomerContractPage.GoToRecord(CustomerContract);
        CustomerContractPage.GetServiceCommitmentsAction.Invoke();

        TestServiceCommitmentUpdateOnCurrencyChange(
            WorkDate(),
            CurrExchRate.ExchangeRate(WorkDate(), CustomerContract."Currency Code"),
            true, Customer."Currency Code", Currency, CurrExchRate, ServiceObject."No.", CustomerContract);
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure CheckServiceObjectDescriptionInCustomerContractLines()
    var
        CustomerContract: Record "Customer Subscription Contract";
        ServiceObject: Record "Subscription Header";
    begin
        Initialize();

        ContractTestLibrary.CreateCustomerContractAndCreateContractLinesForItems(CustomerContract, ServiceObject, '', true);
        TestCustomerContractLinesServiceObjectDescription(CustomerContract."No.", ServiceObject.Description);

        ServiceObject.Description := CopyStr(LibraryRandom.RandText(100), 1, MaxStrLen(ServiceObject.Description));
        ServiceObject.Modify(true);
        TestCustomerContractLinesServiceObjectDescription(CustomerContract."No.", ServiceObject.Description);
    end;

    [Test]
    [HandlerFunctions('CreateCustomerBillingDocsContractPageHandler,MessageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure CheckTransferOfDetailOverviewToSalesInvoice()
    var
        CustomerContract: Record "Customer Subscription Contract";
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        PostedDocumentNo: Code[20];
        i: Integer;
    begin
        Initialize();

        for i := 0 to 2 do begin
            CreateContractWithDetailOverviewAndSalesInvoice(i, SalesHeader, CustomerContract);
            SalesHeader.TestField("Sub. Contract Detail Overview", CustomerContract."Detail Overview");
            PostedDocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);
            SalesInvoiceHeader.Get(PostedDocumentNo);
            SalesInvoiceHeader.TestField("Sub. Contract Detail Overview", CustomerContract."Detail Overview");
        end;
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,CreateCustomerBillingDocsContractPageHandler,MessageHandler')]
    procedure CheckTransferCustomerReferenceToSalesInvoice()
    var
        BillingLine: Record "Billing Line";
        BillingTemplate: Record "Billing Template";
        CustomerContract: Record "Customer Subscription Contract";
        SalesLine: Record "Sales Line";
        ServiceObject: Record "Subscription Header";
        ReferenceNoLbl: Label 'Reference No.: %1', Locked = true;
        CustomerReference: Text;
    begin
        Initialize();

        ContractTestLibrary.CreateCustomerContractAndCreateContractLinesForItems(CustomerContract, ServiceObject, '', true);
        CustomerReference := CopyStr(LibraryRandom.RandText(MaxStrLen(ServiceObject."Customer Reference")), 1, MaxStrLen(ServiceObject."Customer Reference"));
        ServiceObject."Customer Reference" := CopyStr(CustomerReference, 1, MaxStrLen(ServiceObject."Customer Reference"));
        ServiceObject.Modify(false);

        ContractTestLibrary.CreateBillingProposal(BillingTemplate, Enum::"Service Partner"::Customer);
        BillingLine.SetRange("Subscription Contract No.", CustomerContract."No.");
        BillingLine.SetRange("Billing Template Code", BillingTemplate.Code);
        BillingLine.SetRange(Partner, BillingLine.Partner::Customer);
        Codeunit.Run(Codeunit::"Create Billing Documents", BillingLine);
        BillingLine.FindFirst();

        SalesLine.SetRange("Document Type", Enum::"Sales Document Type"::Invoice);
        SalesLine.SetRange("Document No.", BillingLine."Document No.");
        SalesLine.SetRange(Description, StrSubstNo(ReferenceNoLbl, CustomerReference));
        Assert.RecordIsNotEmpty(SalesLine);
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,ConfirmHandler,MessageHandler')]
    procedure CheckValueChangesOnCustomerContractLines()
    var
        Currency: Record Currency;
        Customer: Record Customer;
        CustomerContract: Record "Customer Subscription Contract";
        CustomerContractLine: Record "Cust. Sub. Contract Line";
        OldServiceCommitment: Record "Subscription Line";
        ServiceCommitment: Record "Subscription Line";
        ServiceObject: Record "Subscription Header";
        BillingRhythmValue: DateFormula;
        BillingBasePeriod: DateFormula;
        ExpectedDate: Date;
        ExpectedDecimalValue: Decimal;
        MaxServiceAmount: Decimal;
        SrvCommFieldNotTransferredErr: Label 'Subscription Line field "%1" not transferred from Customer Subscription Contract Line.', Locked = true;
        NotTransferredMisspelledTok: Label 'Subscription Line field "%1" not transfered from Customer Subscription Contract Line.', Locked = true;
        CustomerContractPage: TestPage "Customer Contract";
        DescriptionText: Text;
        ServiceObjectQuantity: Decimal;
    begin
        // [SCENARIO] Assign Subscription Lines to Customer Subscription Contract Lines. Change values on Customer Subscription Contract Lines and check that Subscription Line has changed values.
        Initialize();

        SetupServiceObjectForNewItemWithServiceCommitment(Customer, ServiceObject, false);
        Currency.InitRoundingPrecision();
        CreateCustomerContractSetup(Customer, ServiceObject, CustomerContract);

        CustomerContractPage.OpenEdit();
        CustomerContractPage.GoToRecord(CustomerContract);

        CustomerContractLine.Reset();
        CustomerContractLine.SetRange("Subscription Contract No.", CustomerContract."No.");
        CustomerContractLine.SetRange("Contract Line Type", Enum::"Contract Line Type"::Item);
        CustomerContractLine.FindFirst();
        CustomerContractPage.Lines.GoToRecord(CustomerContractLine);

        ServiceObjectQuantity := LibraryRandom.RandDecInDecimalRange(1, 100, 2);
        CustomerContractPage.Lines."Service Object Quantity".SetValue(ServiceObjectQuantity);
        ServiceObject.Get(CustomerContractLine."Subscription Header No.");
        Assert.AreEqual(ServiceObject.Quantity, ServiceObjectQuantity, 'Service Object Quantity not transferred from Customer Subscription Contract Line.');

        DescriptionText := LibraryRandom.RandText(100);
        CustomerContractPage.Lines."Service Object Description".SetValue(DescriptionText);
        ServiceObject.Get(CustomerContractLine."Subscription Header No.");
        Assert.AreEqual(ServiceObject.Description, DescriptionText, 'Service Object Description not transferred from Customer Subscription Contract Line.');

        OldServiceCommitment.Get(CustomerContractLine."Subscription Line Entry No.");

        ExpectedDate := CalcDate('<-1D>', OldServiceCommitment."Subscription Line Start Date");
        CustomerContractPage.Lines."Service Start Date".SetValue(ExpectedDate);
        ServiceCommitment.Get(OldServiceCommitment."Entry No.");
        Assert.AreEqual(ExpectedDate, ServiceCommitment."Subscription Line Start Date", StrSubstNo(SrvCommFieldNotTransferredErr, ServiceCommitment.FieldCaption("Subscription Line Start Date")));

        ExpectedDate := CalcDate('<1D>', WorkDate());
        CustomerContractPage.Lines."Service End Date".SetValue(ExpectedDate);
        ServiceCommitment.Get(OldServiceCommitment."Entry No.");
        Assert.AreEqual(ExpectedDate, ServiceCommitment."Subscription Line End Date", StrSubstNo(SrvCommFieldNotTransferredErr, ServiceCommitment.FieldCaption("Subscription Line End Date")));

        ExpectedDate := CalcDate('<1D>', WorkDate());
        CustomerContractPage.Lines."Cancellation Possible Until".SetValue(ExpectedDate);
        ServiceCommitment.Get(OldServiceCommitment."Entry No.");
        Assert.AreEqual(ExpectedDate, ServiceCommitment."Cancellation Possible Until", StrSubstNo(NotTransferredMisspelledTok, ServiceCommitment.FieldCaption("Cancellation Possible Until")));

        ExpectedDate := CalcDate('<1D>', WorkDate());
        CustomerContractPage.Lines."Term Until".SetValue(ExpectedDate);
        ServiceCommitment.Get(OldServiceCommitment."Entry No.");
        Assert.AreEqual(ExpectedDate, ServiceCommitment."Term Until", StrSubstNo(NotTransferredMisspelledTok, ServiceCommitment.FieldCaption("Term Until")));

        ExpectedDecimalValue := LibraryRandom.RandDecInDecimalRange(1, 100, 2);
        while ExpectedDecimalValue = OldServiceCommitment."Discount %" do
            ExpectedDecimalValue := LibraryRandom.RandDecInDecimalRange(1, 100, 2);
        CustomerContractPage.Lines."Discount %".SetValue(ExpectedDecimalValue);
        ServiceCommitment.Get(OldServiceCommitment."Entry No.");
        Assert.AreEqual(ExpectedDecimalValue, ServiceCommitment."Discount %", StrSubstNo(SrvCommFieldNotTransferredErr, ServiceCommitment.FieldCaption("Discount %")));

        MaxServiceAmount := Round((OldServiceCommitment.Price * ServiceObject.Quantity), Currency."Amount Rounding Precision");
        ExpectedDecimalValue := LibraryRandom.RandDecInDecimalRange(1, MaxServiceAmount, 2);
        while ExpectedDecimalValue = OldServiceCommitment."Discount Amount" do
            ExpectedDecimalValue := LibraryRandom.RandDecInDecimalRange(1, MaxServiceAmount, 2);
        CustomerContractPage.Lines."Discount Amount".SetValue(ExpectedDecimalValue);
        ServiceCommitment.Get(OldServiceCommitment."Entry No.");
        Assert.AreEqual(ExpectedDecimalValue, ServiceCommitment."Discount Amount", StrSubstNo(SrvCommFieldNotTransferredErr, ServiceCommitment.FieldCaption("Discount Amount")));

        ExpectedDecimalValue := LibraryRandom.RandDecInDecimalRange(1, MaxServiceAmount, 2);
        while ExpectedDecimalValue = OldServiceCommitment.Amount do
            ExpectedDecimalValue := LibraryRandom.RandDecInDecimalRange(1, MaxServiceAmount, 2);
        CustomerContractPage.Lines."Service Amount".SetValue(ExpectedDecimalValue);
        ServiceCommitment.Get(OldServiceCommitment."Entry No.");
        Assert.AreEqual(ExpectedDecimalValue, ServiceCommitment.Amount, StrSubstNo(SrvCommFieldNotTransferredErr, ServiceCommitment.FieldCaption(Amount)));

        ExpectedDecimalValue := LibraryRandom.RandDec(10000, 2);
        while ExpectedDecimalValue = OldServiceCommitment."Calculation Base Amount" do
            ExpectedDecimalValue := LibraryRandom.RandDec(10000, 2);
        CustomerContractPage.Lines."Calculation Base Amount".SetValue(ExpectedDecimalValue);
        ServiceCommitment.Get(OldServiceCommitment."Entry No.");
        Assert.AreEqual(ExpectedDecimalValue, ServiceCommitment."Calculation Base Amount", StrSubstNo(SrvCommFieldNotTransferredErr, ServiceCommitment.FieldCaption("Calculation Base Amount")));

        ExpectedDecimalValue := LibraryRandom.RandDecInDecimalRange(1, 100, 2);
        while ExpectedDecimalValue = OldServiceCommitment."Calculation Base Amount" do
            ExpectedDecimalValue := LibraryRandom.RandDecInDecimalRange(1, 100, 2);
        CustomerContractPage.Lines."Calculation Base %".SetValue(ExpectedDecimalValue);
        ServiceCommitment.Get(OldServiceCommitment."Entry No.");
        Assert.AreEqual(ExpectedDecimalValue, ServiceCommitment."Calculation Base %", StrSubstNo(SrvCommFieldNotTransferredErr, ServiceCommitment.FieldCaption("Calculation Base %")));

        DescriptionText := LibraryRandom.RandText(100);
        CustomerContractPage.Lines."Service Commitment Description".SetValue(DescriptionText);
        ServiceCommitment.Get(OldServiceCommitment."Entry No.");
        Assert.AreEqual(DescriptionText, ServiceCommitment.Description, StrSubstNo(SrvCommFieldNotTransferredErr, ServiceCommitment.FieldCaption(Description)));

        Evaluate(BillingBasePeriod, '<3M>');
        CustomerContractPage.Lines."Billing Base Period".SetValue(BillingBasePeriod);
        ServiceCommitment.Get(OldServiceCommitment."Entry No.");
        Assert.AreEqual(BillingBasePeriod, ServiceCommitment."Billing Base Period", StrSubstNo(NotTransferredMisspelledTok, ServiceCommitment.FieldCaption("Billing Base Period")));

        Evaluate(BillingRhythmValue, '<3M>');
        CustomerContractPage.Lines."Billing Rhythm".SetValue(BillingRhythmValue);
        ServiceCommitment.Get(OldServiceCommitment."Entry No.");
        Assert.AreEqual(BillingRhythmValue, ServiceCommitment."Billing Rhythm", StrSubstNo(SrvCommFieldNotTransferredErr, ServiceCommitment.FieldCaption("Billing Rhythm")));
    end;

    [Test]
    procedure ContractCheckShipToAddressSetFromFirstServiceCommitment()
    var
        Customer: Record Customer;
        CustomerContract: Record "Customer Subscription Contract";
        ServiceCommitment: Record "Subscription Line";
        ServiceObject: Record "Subscription Header";
        ShipToAddress: Record "Ship-to Address";
    begin
        Initialize();

        SetupServiceObjectForNewItemWithServiceCommitment(Customer, ServiceObject, false);
        ContractTestLibrary.CreateCustomerContract(CustomerContract, Customer."No.");
        LibrarySales.CreateShipToAddress(ShipToAddress, Customer."No.");

        Assert.IsTrue(CustomerContract.IsShipToAddressEqualToServiceObjectShipToAddress(ServiceObject), 'Setup-Failure: Ship-To Address should be identical between Contract and Service Object.');
        ServiceObject.Validate("Ship-to Code", ShipToAddress.Code);
        ServiceObject."Ship-to Address" := CopyStr(LibraryRandom.RandText(MaxStrLen(ServiceObject."Ship-to Address")), 1, MaxStrLen(ServiceObject."Ship-to Address"));
        ServiceObject."Ship-to Address 2" := CopyStr(LibraryRandom.RandText(MaxStrLen(ServiceObject."Ship-to Address 2")), 1, MaxStrLen(ServiceObject."Ship-to Address 2"));
        ServiceObject.Modify(false);
        Assert.IsFalse(CustomerContract.IsShipToAddressEqualToServiceObjectShipToAddress(ServiceObject), 'Ship-To Address should NOT be returned as identical between Contract and Service Object.');

        ServiceCommitment.SetRange("Subscription Header No.", ServiceObject."No.");
        ServiceCommitment.SetRange(Partner, ServiceCommitment.Partner::Customer);
        ServiceCommitment.FindFirst();
        ServiceCommitment.SetRecFilter();
        CustomerContract.CreateCustomerContractLineFromServiceCommitment(ServiceCommitment, CustomerContract."No.");

        CustomerContract.Get(CustomerContract."No.");
        Assert.IsFalse(CustomerContract.IsShipToAddressEqualToServiceObjectShipToAddress(ServiceObject), 'Ship-To Address should NOT be identical between Contract and Service Object after calling the first serv. comm.');
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure ContractLineDisconnectServiceOnTypeChange()
    var
        CustomerContract: Record "Customer Subscription Contract";
        CustomerContractLine: Record "Cust. Sub. Contract Line";
        ServiceCommitment: Record "Subscription Line";
        ServiceObject: Record "Subscription Header";
        EntryNo: Integer;
    begin
        // Test: Subscription Line should be disconnected from the contract when the line type changes
        Initialize();

        SetupNewContract(false, ServiceObject, CustomerContract);

        CustomerContractLine.Reset();
        CustomerContractLine.SetRange("Subscription Contract No.", CustomerContract."No.");
        CustomerContractLine.SetRange("Contract Line Type", Enum::"Contract Line Type"::Item);
        CustomerContractLine.SetFilter("Subscription Header No.", '<>%1', '');
        CustomerContractLine.SetFilter("Subscription Line Entry No.", '<>%1', 0);
        CustomerContractLine.FindFirst();
        EntryNo := CustomerContractLine."Subscription Line Entry No.";
        CustomerContractLine.Validate("Contract Line Type", CustomerContractLine."Contract Line Type"::Comment);
        ServiceCommitment.Get(EntryNo);
        ServiceCommitment.TestField("Subscription Contract No.", '');
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    procedure CurrencyCodeRemainsSameWhenBillToCustomerChanges()
    var
        Customer: Record Customer;
        Customer2: Record Customer;
        Item: Record Item;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SubscriptionHeader: Record "Subscription Header";
        CustomerSubscriptionContract: Record "Customer Subscription Contract";
        CurrencyCode: Code[10];
    begin
        //[SCENARIO]: Create Subscription Header from Sales Document
        //[SCENARIO]: Create two customers with same Currency Code; When Bill-to Customer is changed in Customer contract
        //[SCENARIO]: Currency code should remain the same

        //[GIVEN]: Create item with sales subscription lines
        Initialize();
        CreateItemWithSubscriptionLines(Item);
        //[GIVEN]: Create two customers with same Currency Code
        CurrencyCode := LibraryERM.CreateCurrencyWithRandomExchRates();
        ContractTestLibrary.CreateCustomer(Customer, CurrencyCode);
        ContractTestLibrary.CreateCustomer(Customer2, CurrencyCode);
        //[GIVEN]: Create Sales Document
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, Item."No.", LibraryRandom.RandInt(100));
        //[GIVEN]: Post Sales Document in order to create service object
        LibrarySales.PostSalesDocument(SalesHeader, true, true);
        SubscriptionHeader.SetRange(Type, Enum::"Service Object Type"::Item);
        SubscriptionHeader.SetRange("Source No.", Item."No.");
        SubscriptionHeader.FindFirst();

        //[GIVEN]: Create Customer Contract with Service Object
        ContractTestLibrary.CreateCustomerContractAndCreateContractLinesForItems(CustomerSubscriptionContract, SubscriptionHeader, Customer."No.");
        //[THEN]: Check that Currency Code is the same as in Customer
        CustomerSubscriptionContract.TestField("Currency Code", CurrencyCode);

        //[WHEN]: Change Bill-to Customer in Customer Contract
        CustomerSubscriptionContract.Validate("Bill-to Customer No.", Customer2."No.");
        CustomerSubscriptionContract.Modify(true);

        //[THEN]: Check that Currency Code is the same as in Customer - no change has been made
        CustomerSubscriptionContract.Get(CustomerSubscriptionContract."No.");
        CustomerSubscriptionContract.TestField("Currency Code", CurrencyCode);
    end;

    [Test]
    procedure ExpectCustomerContractDocumentAttachmentsAreDeleted()
    var
        CustomerContract: Record "Customer Subscription Contract";
        DocumentAttachment: Record "Document Attachment";
        i: Integer;
        RandomNoOfAttachments: Integer;
    begin
        Initialize();

        // Subscription has Document Attachments created
        // [WHEN] Subscription is deleted
        // expect that Document Attachments are deleted
        ContractTestLibrary.CreateCustomerContract(CustomerContract, '');
        CustomerContract.TestField("No.");
        RandomNoOfAttachments := LibraryRandom.RandInt(10);
        for i := 1 to RandomNoOfAttachments do
            ContractTestLibrary.InsertDocumentAttachment(Database::"Customer Subscription Contract", CustomerContract."No.");

        DocumentAttachment.SetRange("Table ID", Database::"Customer Subscription Contract");
        DocumentAttachment.SetRange("No.", CustomerContract."No.");
        Assert.AreEqual(RandomNoOfAttachments, DocumentAttachment.Count(), 'Actual number of Document Attachment(s) is incorrect.');

        CustomerContract.Delete(true);

        // Document Attachment(s) should be deleted
        Assert.RecordIsEmpty(DocumentAttachment);
    end;

    [Test]
    procedure ExpectErrorIfBillingRhythmIsEmptyInServiceCommPackage()
    var
        ServiceCommPackageLine: Record "Subscription Package Line";
        ServiceCommitmentPackage: Record "Subscription Package";
        ServiceCommitmentTemplate: Record "Sub. Package Line Template";
        ServiceCommitmentTemplate2: Record "Sub. Package Line Template";
        EmptyDateFormula: DateFormula;
    begin
        Initialize();

        ContractTestLibrary.CreateServiceCommitmentTemplate(ServiceCommitmentTemplate2);
        ServiceCommitmentTemplate2."Calculation Base %" := LibraryRandom.RandDec(100, 2);
        Evaluate(ServiceCommitmentTemplate."Billing Base Period", '<12M>');
        ServiceCommitmentTemplate2."Invoicing via" := Enum::"Invoicing Via"::Sales;
        ServiceCommitmentTemplate2.Modify(false);

        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage, ServiceCommPackageLine);
        ServiceCommPackageLine.Partner := Enum::"Service Partner"::Customer;
        Evaluate(ServiceCommPackageLine."Extension Term", '<1Y>');
        Evaluate(ServiceCommPackageLine."Notice Period", '<1M>');
        Evaluate(ServiceCommPackageLine."Initial Term", '<1Y>');
        Evaluate(ServiceCommPackageLine."Billing Rhythm", '<1M>');
        ServiceCommPackageLine.Modify(false);
        Evaluate(EmptyDateFormula, '');

        asserterror ServiceCommPackageLine.Validate("Billing Rhythm", EmptyDateFormula);
    end;

    [Test]
    [HandlerFunctions('MessageHandler,ExchangeRateSelectionModalPageHandler')]
    procedure ExpectErrorForWrongServiceCommitmentToCustomerContractAssignment()
    var
        Customer: Record Customer;
        Customer2: Record Customer;
        CustomerContract: Record "Customer Subscription Contract";
        TempServiceCommitment: Record "Subscription Line" temporary;
        ServiceObject: Record "Subscription Header";
        ServCommWOCustContractPage: TestPage "Serv. Comm. WO Cust. Contract";
    begin
        // [SCENARIO] try to assign Subscription Line to wrong Contract No (different Customer No.)
        Initialize();

        SetupServiceObjectForNewItemWithServiceCommitment(Customer, ServiceObject, false);
        ContractTestLibrary.CreateCustomerContract(CustomerContract, Customer."No.");
        ContractTestLibrary.CreateCustomer(Customer2);
        ContractTestLibrary.CreateCustomerContract(CustomerContract, Customer2."No.");
        Commit(); // retain data after asserterror

        ServCommWOCustContractPage.OpenEdit();
        asserterror ServCommWOCustContractPage."Contract No.".SetValue(CustomerContract."No.");

        ContractTestLibrary.FillTempServiceCommitment(TempServiceCommitment, ServiceObject, CustomerContract);
        asserterror CustomerContract.CreateCustomerContractLinesFromServiceCommitments(TempServiceCommitment);
    end;

    [Test]
    [HandlerFunctions('ServCommWOCustContractPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure ExpectErrorOnAssignServiceCommitmentsWithMultipleCurrencies()
    var
        Currency: Record Currency;
        Customer: Record Customer;
        CustomerContract: Record "Customer Subscription Contract";
        ServiceCommitment: Record "Subscription Line";
        ServiceObject: Record "Subscription Header";
        CustomerContractPage: TestPage "Customer Contract";
    begin
        Initialize();

        SetupServiceObjectForNewItemWithServiceCommitment(Customer, ServiceObject, false);
        ContractTestLibrary.CreateCustomerContract(CustomerContract, Customer."No.");

        ServiceCommitment.SetRange("Subscription Header No.", ServiceObject."No.");
        ServiceCommitment.FindSet();
        repeat
            Currency.Get(LibraryERM.CreateCurrencyWithRandomExchRates());
            ServiceCommitment."Currency Code" := Currency.Code;
        until ServiceCommitment.Next() = 0;

        CustomerContractPage.OpenEdit();
        CustomerContractPage.GoToRecord(CustomerContract);
        CustomerContractPage.GetServiceCommitmentsAction.Invoke();
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure ExpectErrorOnMergeTextLine()
    var
        CustomerContract: Record "Customer Subscription Contract";
        CustomerContractLine: Record "Cust. Sub. Contract Line";
        ServiceObject: Record "Subscription Header";
    begin
        Initialize();
        SetupNewContract(false, ServiceObject, CustomerContract);
        ContractTestLibrary.InsertCustomerContractCommentLine(CustomerContract, CustomerContractLine);
        CustomerContractLine.Reset();
        asserterror CustomerContractLine.MergeContractLines(CustomerContractLine);
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler,CreateCustomerBillingDocsContractPageHandler')]
    procedure ExpectErrorOnModifyServiceStartDateWhenBillingLineArchiveExist()
    var
        CustomerContract: Record "Customer Subscription Contract";
        CustomerContractLine: Record "Cust. Sub. Contract Line";
        ServiceCommitment: Record "Subscription Line";
        ServiceObject: Record "Subscription Header";
    begin
        Initialize();
        ContractTestLibrary.CreateCustomerContractAndCreateContractLinesForItems(CustomerContract, ServiceObject, '', true);
        CreateAndPostBillingProposal(WorkDate(), ServiceObject."No.");
        asserterror UpdateServiceStartDateFromCustomerContractSubpage(CustomerContract."No.", CustomerContractLine, ServiceCommitment);
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure ExpectErrorOnMergeContractLinesWithDifferenceCustomerReference()
    var
        CustomerContract: Record "Customer Subscription Contract";
        CustomerContractLine: Record "Cust. Sub. Contract Line";
        ServiceObject: Record "Subscription Header";
        ServiceObject2: Record "Subscription Header";
    begin
        Initialize();

        ContractTestLibrary.InitContractsApp();
        ContractTestLibrary.CreateCustomerContractAndCreateContractLinesForItems(CustomerContract, ServiceObject, '', false);
        ServiceObject."Customer Reference" := CopyStr(LibraryRandom.RandText(MaxStrLen(ServiceObject."Customer Reference")), 1, MaxStrLen(ServiceObject."Customer Reference"));
        ServiceObject.Modify(false);

        ContractTestLibrary.CreateCustomerContractAndCreateContractLinesForItems(CustomerContract, ServiceObject2, '', false);
        ServiceObject2."Customer Reference" := CopyStr(LibraryRandom.RandText(MaxStrLen(ServiceObject2."Customer Reference")), 1, MaxStrLen(ServiceObject2."Customer Reference"));
        ServiceObject2.Modify(false);

        CustomerContractLine.Reset();
        CustomerContractLine.SetRange("Subscription Contract No.", CustomerContract."No.");
        asserterror CustomerContractLine.MergeContractLines(CustomerContractLine);
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure ExpectErrorOnMergeCustomerContractLineWithBillingProposal()
    var
        BillingTemplate: Record "Billing Template";
        CustomerContract: Record "Customer Subscription Contract";
        CustomerContractLine: Record "Cust. Sub. Contract Line";
        ServiceObject: Record "Subscription Header";
        ServiceObject2: Record "Subscription Header";
    begin
        Initialize();

        SetupNewContract(false, ServiceObject, CustomerContract);
        CreateTwoEqualServiceObjectsWithServiceCommitments(ServiceObject, ServiceObject2);
        ContractTestLibrary.AssignServiceObjectForItemToCustomerContract(CustomerContract, ServiceObject2, false);
        ContractTestLibrary.CreateBillingProposal(BillingTemplate, Enum::"Service Partner"::Customer);
        asserterror CustomerContractLine.MergeContractLines(CustomerContractLine);
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure ExpectErrorOnMergeCustomerContractLineWithDifferentNextBillingDate()
    var
        CustomerContract: Record "Customer Subscription Contract";
        CustomerContractLine: Record "Cust. Sub. Contract Line";
        ServiceCommitment: Record "Subscription Line";
        ServiceObject: Record "Subscription Header";
        ServiceObject1: Record "Subscription Header";
    begin
        Initialize();

        SetupNewContract(false, ServiceObject, CustomerContract);
        CreateTwoEqualServiceObjectsWithServiceCommitments(ServiceObject, ServiceObject1);
        ContractTestLibrary.AssignServiceObjectForItemToCustomerContract(CustomerContract, ServiceObject1, false);
        CustomerContractLine.FindFirst();
        CustomerContractLine.GetServiceCommitment(ServiceCommitment);
        ServiceCommitment."Next Billing Date" := CalcDate('<1D>', ServiceCommitment."Next Billing Date");
        ServiceCommitment.Modify(false);
        CustomerContractLine.Reset();
        asserterror CustomerContractLine.MergeContractLines(CustomerContractLine);
    end;

    [Test]
    procedure ExpectErrorWhenDeleteCustomerIfExistInCustomerContract()
    var
        Customer: Record Customer;
        CustomerContract: Record "Customer Subscription Contract";
        CustomerContractExistErr: Label 'You cannot delete %1 %2 because there is at least one outstanding Contract for this customer.', Locked = true;
    begin
        // [SCENARIO] Customer cannot be deleted if exist in Customer Subscription Contract
        Initialize();

        // [GIVEN] Create Customer and Customer Subscription Contract
        ContractTestLibrary.CreateCustomer(Customer);
        ContractTestLibrary.CreateCustomerContract(CustomerContract, Customer."No.");

        // [WHEN] Delete Customer
        asserterror Customer.Delete(true);

        // [THEN] Error is displayed that it is not possible to delete Customer if exist in Customer Subscription Contract
        Assert.ExpectedError(StrSubstNo(CustomerContractExistErr, Customer.TableCaption, Customer."No."));
    end;

    [Test]
    procedure ExpectErrorWhenDeleteCustomerIfExistInServiceObject()
    var
        Customer: Record Customer;
        Item: Record Item;
        ServiceObject: Record "Subscription Header";
        ServiceObjectExistErr: Label 'You cannot delete %1 %2 because there is at least one outstanding Subscription for this customer.', Locked = true;
    begin
        // [SCENARIO] Customer cannot be deleted if exist in Subscription
        Initialize();

        // [GIVEN] Create Customer and Subscription
        ContractTestLibrary.CreateCustomer(Customer);
        ContractTestLibrary.CreateServiceObjectForItem(ServiceObject, Item, false);
        ServiceObject.Validate("End-User Customer No.", Customer."No.");
        ServiceObject.Modify(false);

        // [WHEN] Delete Customer
        asserterror Customer.Delete(true);

        // [THEN] Error is displayed that it is not possible to delete Customer if exist in Subscription
        Assert.ExpectedError(StrSubstNo(ServiceObjectExistErr, Customer.TableCaption, Customer."No."));
    end;

    [Test]
    procedure ExpectErrorWhenDeleteVendorIfExistInVendorContract()
    var
        Vendor: Record Vendor;
        VendorContract: Record "Vendor Subscription Contract";
        VendorContractExistErr: Label 'You cannot delete %1 %2 because there is at least one outstanding Contract for this vendor.', Locked = true;
    begin
        // [SCENARIO] Vendor cannot be deleted if exist in Vendor Subscription Contract
        Initialize();

        // [GIVEN] Create Vendor and Vendor Subscription Contract
        ContractTestLibrary.CreateVendor(Vendor);
        ContractTestLibrary.CreateVendorContract(VendorContract, Vendor."No.");

        // [WHEN] Delete Vendor
        asserterror Vendor.Delete(true);

        // [THEN] Error is displayed that it is not possible to delete Vendor if exist in Vendor Subscription Contract
        Assert.ExpectedError(StrSubstNo(VendorContractExistErr, Vendor.TableCaption, Vendor."No."));
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure ExpectNextBillingDateInCustomerContractToBeFromFirstServiceCOmmitment()
    var
        ContractType: Record "Subscription Contract Type";
        CustomerContract: Record "Customer Subscription Contract";
        ServiceCommitment: Record "Subscription Line";
        ServiceObject: Record "Subscription Header";
        NextBillingTo: Date;
    begin
        // Create Customer Contract with Harmonized billing contract type
        // Expect Harmonized billing fields in Cust. Contract to be filled after adding Subscription Lines
        Initialize();

        ContractTestLibrary.CreateCustomerContractWithContractType(CustomerContract, ContractType);
        ContractType.HarmonizedBillingCustContracts := true;
        ContractType.Modify(false);
        ContractTestLibrary.AssignServiceObjectForItemToCustomerContract(CustomerContract, ServiceObject, true);
        CustomerContract.FindEarliestServiceCommitment(ServiceCommitment, 0);
        CustomerContract.TestField("Billing Base Date", ServiceCommitment."Next Billing Date");
        CustomerContract.TestField("Default Billing Rhythm", ServiceCommitment."Billing Rhythm");
        CustomerContract.TestField("Next Billing From", ServiceCommitment."Next Billing Date");
        NextBillingTo := CalcDate(CustomerContract."Default Billing Rhythm", CustomerContract."Billing Base Date");
        NextBillingTo := CalcDate('<-1D>', NextBillingTo);
        CustomerContract.TestField("Next Billing To", NextBillingTo);
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure ExpectNoClosedCustomerContractLines()
    var
        Customer: Record Customer;
        CustomerContract: Record "Customer Subscription Contract";
        CustomerContractLine: Record "Cust. Sub. Contract Line";
        CustomerContractLine2: Record "Cust. Sub. Contract Line";
        ServiceCommitment: Record "Subscription Line";
        ServiceObject: Record "Subscription Header";
    begin
        Initialize();

        SetupServiceObjectForNewItemWithServiceCommitment(Customer, ServiceObject, false);
        ContractTestLibrary.CreateCustomerContractAndCreateContractLinesForItems(CustomerContract, ServiceObject, Customer."No.");
        ContractTestLibrary.InsertCustomerContractCommentLine(CustomerContract, CustomerContractLine2);
        ServiceCommitment.SetRange("Subscription Header No.", ServiceObject."No.");
        ServiceCommitment.SetRange("Subscription Contract No.", CustomerContract."No.");
        if ServiceCommitment.FindSet() then
            repeat
                ServiceCommitment."Subscription Line Start Date" := CalcDate('<1D>', Today);
                ServiceCommitment."Subscription Line End Date" := CalcDate('<2D>', Today);
                ServiceCommitment.Modify(false);
            until ServiceCommitment.Next() = 0;
        CustomerContract.UpdateServicesDates();
        CustomerContractLine.SetRange("Subscription Contract No.", CustomerContract."No.");
        CustomerContractLine.SetRange("Contract Line Type", Enum::"Contract Line Type"::Item);
        CustomerContractLine.SetRange(Closed, false);
        Assert.RecordIsNotEmpty(CustomerContractLine);
    end;

    [Test]
    procedure DeleteRelatedTranslationsWhenDeletingContractType()
    var
        ContractType: Record "Subscription Contract Type";
        FieldTranslation: Record "Field Translation";
        LanguageMgt: Codeunit Language;
    begin
        Initialize();

        FieldTranslation.Reset();
        if not FieldTranslation.IsEmpty() then
            FieldTranslation.DeleteAll(false);
        ContractTestLibrary.CreateContractType(ContractType);
        ContractTestLibrary.CreateTranslationForField(FieldTranslation, ContractType, ContractType.FieldNo(Description), LanguageMgt.GetLanguageCode(GlobalLanguage));

        FieldTranslation.Reset();
        // Setup-Failure: expected exactly one translation
        Assert.RecordCount(FieldTranslation, 1);

        ContractType.Delete(true);

        // Translation has been deleted with its master-record
        Assert.RecordIsEmpty(FieldTranslation);
    end;

    [Test]
    procedure ManuallyCreateContractLineForItem()
    var
        Customer: Record Customer;
        CustomerContract: Record "Customer Subscription Contract";
        CustomerContractLine: Record "Cust. Sub. Contract Line";
        ServiceCommitment: Record "Subscription Line";
        ServiceObject: Record "Subscription Header";
    begin
        // [SCENARIO] Manually create contract lines for Item and expect Subscription to be created

        // [GIVEN] A Customer Subscription Contract has been created
        ClearAll();
        ContractTestLibrary.InitContractsApp();
        ContractTestLibrary.CreateCustomer(Customer);
        ContractTestLibrary.CreateCustomerContract(CustomerContract, Customer."No.");

        // [WHEN] A Customer Subscription Contract Line has been manually created and Item No. is entered.
        ContractTestLibrary.InsertCustomerContractItemLine(CustomerContract, CustomerContractLine);

        // [THEN] Subscription has been created with a single Subscription Line
        ServiceObject.Get(CustomerContractLine."Subscription Header No.");
        ServiceObject.TestField(Quantity, 1);
        ServiceObject.TestField(ServiceObject.Type, ServiceObject.Type::Item);
        ServiceObject.TestField("End-User Customer No.", CustomerContract."Sell-to Customer No.");
        ServiceObject.TestField("Bill-to Customer No.", CustomerContract."Bill-to Customer No.");
        ServiceObject.TestField("Created in Contract line", true);
        ServiceCommitment.SetRange("Subscription Header No.", ServiceObject."No.");
        Assert.RecordCount(ServiceCommitment, 1);
        ServiceCommitment.FindFirst();
        ServiceCommitment.TestField("Invoicing via", ServiceCommitment."Invoicing via"::Contract);
        ServiceCommitment.TestField("Created in Contract line", true);
        ServiceCommitment.TestField("Subscription Contract No.", CustomerContractLine."Subscription Contract No.");
        ServiceCommitment.TestField("Subscription Contract Line No.", CustomerContractLine."Line No.");
    end;

    [Test]
    procedure ManuallyCreateContractLineForGLAccount()
    var
        Customer: Record Customer;
        CustomerContract: Record "Customer Subscription Contract";
        CustomerContractLine: Record "Cust. Sub. Contract Line";
        ServiceCommitment: Record "Subscription Line";
        ServiceObject: Record "Subscription Header";
    begin
        // [SCENARIO] Manually create contract lines for G/L Account and expect Subscription to be created

        // [GIVEN] A Customer Subscription Contract has been created
        ClearAll();
        ContractTestLibrary.DeleteAllContractRecords();
        ContractTestLibrary.CreateCustomer(Customer);
        ContractTestLibrary.CreateCustomerContract(CustomerContract, Customer."No.");

        // [WHEN] A Customer Subscription Contract Line has been manually created and G/L Account No. is entered.
        ContractTestLibrary.InsertCustomerContractGLAccountLine(CustomerContract, CustomerContractLine);

        // [THEN] Subscription has been created with a single Subscription Line
        ServiceObject.Get(CustomerContractLine."Subscription Header No.");
        ServiceObject.TestField(Quantity, 1);
        ServiceObject.TestField(ServiceObject.Type, ServiceObject.Type::"G/L Account");
        ServiceObject.TestField("End-User Customer No.", CustomerContract."Sell-to Customer No.");
        ServiceObject.TestField("Bill-to Customer No.", CustomerContract."Bill-to Customer No.");
        ServiceObject.TestField("Created in Contract line", true);
        ServiceCommitment.SetRange("Subscription Header No.", ServiceObject."No.");
        Assert.RecordCount(ServiceCommitment, 1);
        ServiceCommitment.FindFirst();
        ServiceCommitment.TestField("Invoicing via", ServiceCommitment."Invoicing via"::Contract);
        ServiceCommitment.TestField("Created in Contract line", true);
        ServiceCommitment.TestField("Subscription Contract No.", CustomerContractLine."Subscription Contract No.");
        ServiceCommitment.TestField("Subscription Contract Line No.", CustomerContractLine."Line No.");
    end;

    [Test]
    procedure SalesDocShowsNoSubtotalForServCommItem()
    var
        Item: Record Item;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesQuote: TestPage "Sales Quote";
    begin
        Initialize();

        // [GIVEN] Sales Document with Sales Line and Item with "Subscription Option" = "Subscription Item"
        LibrarySales.CreateSalesHeader(SalesHeader, Enum::"Sales Document Type"::Quote, '');
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item");
        ContractTestLibrary.UpdateItemUnitCostAndPrice(Item, LibraryRandom.RandDec(1000, 2), LibraryRandom.RandDec(1000, 2), true);

        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, Item."No.", LibraryRandom.RandDec(10, 2));

        // [THEN] Total Amount should NOT be filled in Sales Quote page
        SalesLine.TestField("Line Amount");
        SalesLine.TestField("Exclude from Doc. Total", true);

        // Sales Line Total in Sales Quote should not have a value
        SalesQuote.OpenView();
        SalesQuote.GoToRecord(SalesHeader);
        SalesQuote.SalesLines."Total Amount Excl. VAT".AssertEquals(0);
        SalesQuote.Close();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure TestChangeOfHarmonizedBillingFieldInContractType()
    var
        ContractType: Record "Subscription Contract Type";
        CustomerContract: Record "Customer Subscription Contract";
        ServiceObject: Record "Subscription Header";
    begin
        // Create Customer Contract with Harmonized billing contract type
        // Expect Harmonized billing fields in Cust. Contract to be filled after adding Subscription Lines
        Initialize();

        ContractTestLibrary.CreateCustomerContractWithContractType(CustomerContract, ContractType);
        ContractType.HarmonizedBillingCustContracts := true;
        ContractType.Modify(false);
        ContractTestLibrary.AssignServiceObjectForItemToCustomerContract(CustomerContract, ServiceObject, true);
        CustomerContract.TestField("Billing Base Date");
        CustomerContract.TestField("Default Billing Rhythm");
        CustomerContract.TestField("Next Billing From");
        CustomerContract.TestField("Next Billing To");
        ContractType.Validate(HarmonizedBillingCustContracts, false);
        ContractType.Modify(false);

        // Confirmation dialog - true = expect Harmonized billing fields in CC to be cleared
        CustomerContract.Get(CustomerContract."No.");
        CustomerContract.TestField("Billing Base Date", 0D);
        Assert.AreNotEqual('', CustomerContract."Default Billing Rhythm", 'Default Billig Rhythm was not reset.');
        CustomerContract.TestField("Next Billing From", 0D);
        CustomerContract.TestField("Next Billing To", 0D);
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure TestCreateContractAnalysisEntries()
    var
        ContractAnalysisEntry: Record "Sub. Contr. Analysis Entry";
        Customer: Record Customer;
        CustomerContract: Record "Customer Subscription Contract";
        ServiceCommitment: Record "Subscription Line";
        ServiceObject: Record "Subscription Header";
    begin
        // [SCENARIO] Try to create Contract Analysis Entry and test the values
        Initialize();

        // [GIVEN]
        ContractAnalysisEntry.DeleteAll(false);
        SetupServiceObjectForNewItemWithServiceCommitment(Customer, ServiceObject, false, true);
        ContractTestLibrary.CreateCustomerContractAndCreateContractLinesForItems(CustomerContract, ServiceObject, Customer."No."); // ExchangeRateSelectionModalPageHandler, MessageHandler

        // [WHEN]
        Report.Run(Report::"Create Contract Analysis");

        // [THEN]
        Assert.RecordIsNotEmpty(ContractAnalysisEntry);
        if ContractAnalysisEntry.FindSet() then
            repeat
                ServiceCommitment.Get(ContractAnalysisEntry."Subscription Line Entry No.");
                ServiceCommitment.CalcFields("Source Type", "Source No.", "Subscription Description", Quantity);
                ContractAnalysisEntry.TestField("Subscription Header No.", ServiceCommitment."Subscription Header No.");
                ContractAnalysisEntry.TestField("Sub. Header Source Type", ServiceCommitment."Source Type");
                ContractAnalysisEntry.TestField("Sub. Header Source No.", ServiceCommitment."Source No.");
                ContractAnalysisEntry.TestField("Subscription Description", ServiceCommitment."Subscription Description");
                ContractAnalysisEntry.TestField("Subscription Line Entry No.", ServiceCommitment."Entry No.");
                ContractAnalysisEntry.TestField("Subscription Package Code", ServiceCommitment."Subscription Package Code");
                ContractAnalysisEntry.TestField(Template, ServiceCommitment.Template);
                ContractAnalysisEntry.TestField(Description, ServiceCommitment.Description);
                ContractAnalysisEntry.TestField("Subscription Line Start Date", ServiceCommitment."Subscription Line Start Date");
                ContractAnalysisEntry.TestField("Subscription Line End Date", ServiceCommitment."Subscription Line End Date");
                ContractAnalysisEntry.TestField("Next Billing Date", ServiceCommitment."Next Billing Date");
                ContractAnalysisEntry.TestField("Calculation Base Amount", ServiceCommitment."Calculation Base Amount");
                ContractAnalysisEntry.TestField("Calculation Base %", ServiceCommitment."Calculation Base %");
                ContractAnalysisEntry.TestField(Price, ServiceCommitment.Price);
                ContractAnalysisEntry.TestField("Discount %", ServiceCommitment."Discount %");
                ContractAnalysisEntry.TestField("Discount Amount", ServiceCommitment."Discount Amount");
                ContractAnalysisEntry.TestField(Amount, ServiceCommitment.Amount);
                ContractAnalysisEntry.TestField("Analysis Date", Today());
                ContractAnalysisEntry.TestField("Billing Base Period", ServiceCommitment."Billing Base Period");
                ContractAnalysisEntry.TestField("Invoicing Item No.", ServiceCommitment."Invoicing Item No.");
                ContractAnalysisEntry.TestField(Partner, ServiceCommitment.Partner);
                ContractAnalysisEntry.TestField("Subscription Contract No.", ServiceCommitment."Subscription Contract No.");
                ContractAnalysisEntry.TestField("Subscription Contract Line No.", ServiceCommitment."Subscription Contract Line No.");
                ContractAnalysisEntry.TestField("Notice Period", ServiceCommitment."Notice Period");
                ContractAnalysisEntry.TestField("Initial Term", ServiceCommitment."Initial Term");
                ContractAnalysisEntry.TestField("Extension Term", ServiceCommitment."Extension Term");
                ContractAnalysisEntry.TestField("Billing Rhythm", ServiceCommitment."Billing Rhythm");
                ContractAnalysisEntry.TestField("Cancellation Possible Until", ServiceCommitment."Cancellation Possible Until");
                ContractAnalysisEntry.TestField("Term Until", ServiceCommitment."Term Until");
                ContractAnalysisEntry.TestField("Price (LCY)", ServiceCommitment."Price (LCY)");
                ContractAnalysisEntry.TestField("Discount Amount (LCY)", ServiceCommitment."Discount Amount (LCY)");
                ContractAnalysisEntry.TestField("Amount (LCY)", ServiceCommitment."Amount (LCY)");
                ContractAnalysisEntry.TestField("Currency Code", ServiceCommitment."Currency Code");
                ContractAnalysisEntry.TestField("Currency Factor", ServiceCommitment."Currency Factor");
                ContractAnalysisEntry.TestField("Currency Factor Date", ServiceCommitment."Currency Factor Date");
                ContractAnalysisEntry.TestField("Calculation Base Amount (LCY)", ServiceCommitment."Calculation Base Amount (LCY)");
                ContractAnalysisEntry.TestField(Discount, ServiceCommitment.Discount);
                ContractAnalysisEntry.TestField(Quantity, ServiceCommitment.Quantity);
                ContractAnalysisEntry.TestField("Renewal Term", ServiceCommitment."Renewal Term");
                ContractAnalysisEntry.TestField("Dimension Set ID", ServiceCommitment."Dimension Set ID");
                ContractAnalysisEntry.TestField("Unit Cost", ServiceCommitment."Unit Cost");
                ContractAnalysisEntry.TestField("Unit Cost (LCY)", ServiceCommitment."Unit Cost (LCY)");
            until ContractAnalysisEntry.Next() = 0;
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure TestCustomerContractHarmonization()
    var
        BillingLine: Record "Billing Line";
        BillingTemplate: Record "Billing Template";
        Customer: Record Customer;
        CustomerContract: Record "Customer Subscription Contract";
        ServiceCommitment: Record "Subscription Line";
        ServiceObject: Record "Subscription Header";
    begin
        // Create Customer Subscription Contract with two Subscription Lines with different Subscription Line Start Date and Billing Rhythm
        // Expect the same Next Billing Date for both Subscription Lines after Billing proposal
        // Expect that Next Billing to and Billing from in Contract will be recalculated
        Initialize();

        ContractTestLibrary.CreateCustomer(Customer);
        ContractTestLibrary.CreateCustomerContract(CustomerContract, Customer."No.");
        CreateAndAssignHarmonizationCustomerContractType(CustomerContract);
        ContractTestLibrary.AssignServiceObjectForItemToCustomerContract(CustomerContract, ServiceObject, true);
        ServiceCommitment.FindLast();
        ServiceCommitment.Validate("Subscription Line Start Date", CalcDate('<-1M>', ServiceCommitment."Subscription Line Start Date"));
        Evaluate(ServiceCommitment."Billing Rhythm", '2M');
        ServiceCommitment.Validate("Billing Rhythm");
        ServiceCommitment.Modify(false);
        ContractTestLibrary.CreateBillingProposal(BillingTemplate, Enum::"Service Partner"::Customer);
        BillingLine.SetRange("Billing Template Code", BillingTemplate.Code);
        TestHarmonizationForCustomerContract(CustomerContract, BillingLine, ServiceCommitment);
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure TestDailyPricesInMonthlyRecurringRevenueInContractAnalysis()
    var
        ContractAnalysisEntry: Record "Sub. Contr. Analysis Entry";
        Currency: Record Currency;
        CustomerContract: Record "Customer Subscription Contract";
        ServiceObject: Record "Subscription Header";
        VendorContract: Record "Vendor Subscription Contract";
        AmountArray: array[4] of Decimal;
        ExpectedResultAmountArray, ExpectedUnitCostLCYArray : array[4] of Decimal;
        RoundedExpectedResult: Decimal;
        RoundedResult: Decimal;
        UnitCostLCY: Decimal;
        i: Integer;
        BillingBasePeriodArray: array[4] of Text;
    begin
        // [SCENARIO] Try to create Contract Analysis Entry and test the values
        // Setup multiple customer Subscription Lines with different options
        // To make the calculation clearer set the Amount to 1
        // Expected result will be Daily price * number of days in current month regardless of Billing Base Period
        Initialize();
        ContractAnalysisEntry.DeleteAll(false);

        // [GIVEN]

        BillingBasePeriodArray[1] := '<1D>';
        BillingBasePeriodArray[2] := '<2D>';
        BillingBasePeriodArray[3] := '<1W>';
        BillingBasePeriodArray[4] := '<2W>';
        for i := 1 to 4 do
            AmountArray[i] := 280;

        UnitCostLCY := 140;

        ExpectedResultAmountArray[1] := AmountArray[1];
        ExpectedResultAmountArray[2] := AmountArray[2] / 2;
        ExpectedResultAmountArray[3] := AmountArray[3] / 7; //1W
        ExpectedResultAmountArray[4] := AmountArray[4] / 14; //2W

        SetupServiceObjectWithCustomerServiceCommitments(BillingBasePeriodArray, AmountArray, UnitCostLCY, 4, ServiceObject);

        ExpectedUnitCostLCYArray[1] := (UnitCostLCY * ServiceObject.Quantity) / 1;
        ExpectedUnitCostLCYArray[2] := (UnitCostLCY * ServiceObject.Quantity) / 2;
        ExpectedUnitCostLCYArray[3] := (UnitCostLCY * ServiceObject.Quantity) / 7;
        ExpectedUnitCostLCYArray[4] := (UnitCostLCY * ServiceObject.Quantity) / 14;

        ContractTestLibrary.CreateCustomerContractAndCreateContractLinesForItems(CustomerContract, ServiceObject, ServiceObject."End-User Customer No."); // ExchangeRateSelectionModalPageHandler, MessageHandler
        ContractTestLibrary.CreateVendorContractAndCreateContractLinesForItems(VendorContract, ServiceObject, '');

        // [WHEN]
        Report.Run(Report::"Create Contract Analysis");

        //[THEN]: Test Customer Subscription Contract Analysis Entry for Expected values
        Currency.InitRoundingPrecision();
        ContractAnalysisEntry.SetRange("Subscription Header No.", ServiceObject."No.");
        Assert.RecordIsNotEmpty(ContractAnalysisEntry);
        ContractAnalysisEntry.FindSet();
        for i := 1 to 4 do begin
            RoundedResult := Round(ContractAnalysisEntry."Monthly Recurr. Revenue (LCY)", Currency."Amount Rounding Precision");
            RoundedExpectedResult := Round(ExpectedResultAmountArray[i] * Date2DMY(CalcDate('<CM>', ContractAnalysisEntry."Analysis Date"), 1), Currency."Amount Rounding Precision");
            Assert.AreEqual(RoundedExpectedResult, RoundedResult, 'Monthly Recurr. Revenue (LCY) was not calculated correctly');

            RoundedResult := Round(ContractAnalysisEntry."Monthly Recurring Cost (LCY)", Currency."Amount Rounding Precision");
            RoundedExpectedResult := Round(ExpectedUnitCostLCYArray[i] * Date2DMY(CalcDate('<CM>', ContractAnalysisEntry."Analysis Date"), 1), Currency."Amount Rounding Precision");
            Assert.AreEqual(RoundedExpectedResult, RoundedResult, 'Monthly Recurring Cost (LCY) was not calculated correctly');
            ContractAnalysisEntry.Next();
        end;
        //[THEN]: Test Vendor Subscription Contract Analysis Entry for Expected values
        ContractAnalysisEntry.TestField("Monthly Recurr. Revenue (LCY)", 0);
        ContractAnalysisEntry.TestField("Monthly Recurring Cost (LCY)", ExpectedResultAmountArray[i] * Date2DMY(CalcDate('<CM>', ContractAnalysisEntry."Analysis Date"), 1));
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure TestDeleteServiceCommitmentLinkedToContractLineNotClosed()
    var
        Customer: Record Customer;
        CustomerContract: Record "Customer Subscription Contract";
        CustomerContractLine: Record "Cust. Sub. Contract Line";
        ServiceCommitment: Record "Subscription Line";
        ServiceObject: Record "Subscription Header";
    begin
        // Test: Subscription Line cannot be deleted if an open contract line exists
        Initialize();

        SetupServiceObjectForNewItemWithServiceCommitment(Customer, ServiceObject, false);
        ContractTestLibrary.CreateCustomerContractAndCreateContractLinesForItems(CustomerContract, ServiceObject, Customer."No."); // ExchangeRateSelectionModalPageHandler, MessageHandler

        ServiceCommitment.Reset();
        ServiceCommitment.SetRange("Subscription Header No.", ServiceObject."No.");
        ServiceCommitment.SetRange("Subscription Contract No.", CustomerContract."No.");
        ServiceCommitment.FindFirst();

        CustomerContractLine.Get(ServiceCommitment."Subscription Contract No.", ServiceCommitment."Subscription Contract Line No.");
        CustomerContractLine.TestField(Closed, false);
        asserterror ServiceCommitment.Delete(true);
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure TestDeleteServiceCommitmentLinkedToContractLineIsClosed()
    var
        Customer: Record Customer;
        CustomerContract: Record "Customer Subscription Contract";
        CustomerContractLine: Record "Cust. Sub. Contract Line";
        ServiceCommitment: Record "Subscription Line";
        ServiceObject: Record "Subscription Header";
    begin
        // Test: A closed Contract Line is deleted when deleting the Subscription Line
        Initialize();

        SetupServiceObjectForNewItemWithServiceCommitment(Customer, ServiceObject, false);
        ContractTestLibrary.CreateCustomerContractAndCreateContractLinesForItems(CustomerContract, ServiceObject, Customer."No."); // ExchangeRateSelectionModalPageHandler, MessageHandler

        ServiceCommitment.Reset();
        ServiceCommitment.SetRange("Subscription Header No.", ServiceObject."No.");
        ServiceCommitment.SetRange("Subscription Contract No.", CustomerContract."No.");
        ServiceCommitment.FindFirst();

        CustomerContractLine.Get(ServiceCommitment."Subscription Contract No.", ServiceCommitment."Subscription Contract Line No.");
        CustomerContractLine.TestField(Closed, false);
        CustomerContractLine.Closed := true;
        CustomerContractLine.Modify(false);
        ServiceCommitment.Delete(true);

        asserterror CustomerContractLine.Get(CustomerContractLine."Subscription Contract No.", CustomerContractLine."Line No.");
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure TestEqualServiceStartDateAndNextBillingDate()
    var
        CustomerContract: Record "Customer Subscription Contract";
        CustomerContractLine: Record "Cust. Sub. Contract Line";
        ServiceCommitment: Record "Subscription Line";
        ServiceObject: Record "Subscription Header";
    begin
        Initialize();

        ContractTestLibrary.CreateCustomerContractAndCreateContractLinesForItems(CustomerContract, ServiceObject, '', true);
        UpdateServiceStartDateFromCustomerContractSubpage(CustomerContract."No.", CustomerContractLine, ServiceCommitment);
        CustomerContractLine.GetServiceCommitment(ServiceCommitment);
        ServiceCommitment.TestField("Next Billing Date", ServiceCommitment."Subscription Line Start Date");
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler,SelectCustomerContractLinePageHandler')]
    procedure TestMergeCustomerContractLines()
    var
        Currency: Record Currency;
        CustomerContract: Record "Customer Subscription Contract";
        CustomerContractLine: Record "Cust. Sub. Contract Line";
        ServiceCommitment: Record "Subscription Line";
        NewServiceObject: Record "Subscription Header";
        ServiceObject: Record "Subscription Header";
        ServiceObject1: Record "Subscription Header";
        ExpectedServiceAmount: Decimal;
    begin
        Initialize();
        Currency.InitRoundingPrecision();

        SetupNewContract(false, ServiceObject, CustomerContract);
        CreateTwoEqualServiceObjectsWithServiceCommitments(ServiceObject, ServiceObject1);
        ExpectedServiceAmount := GetTotalServiceAmountFromServiceCommitments(Currency, ServiceObject."No.", ServiceObject1);
        ContractTestLibrary.AssignServiceObjectForItemToCustomerContract(CustomerContract, ServiceObject1, false);

        CustomerContractLine.Reset();
        CustomerContractLine.MergeContractLines(CustomerContractLine);
        CustomerContractLine.FindLast();
        TestNewServiceObject(ServiceObject, ServiceObject1, NewServiceObject, CustomerContractLine."Subscription Header No.");
        ServiceCommitment.SetRange("Subscription Header No.", NewServiceObject."No.");
        ServiceCommitment.FindFirst();
        ServiceCommitment.TestField(Amount, ExpectedServiceAmount);
        Assert.RecordCount(ServiceCommitment, 1);

        // Expect two closed Customer Subscription Contract Lines
        CustomerContractLine.Reset();
        CustomerContractLine.SetRange(Closed, true);
        Assert.RecordCount(CustomerContractLine, 2);

        // Expect one open Customer Subscription Contract Line created from New Subscription
        CustomerContractLine.Reset();
        CustomerContractLine.SetRange(Closed, false);
        Assert.RecordCount(CustomerContractLine, 1);
        CustomerContractLine.FindFirst();
        CustomerContractLine.TestField("Subscription Header No.", NewServiceObject."No.");
        CustomerContractLine.TestField("Subscription Line Entry No.");
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure TestMonthlyRecurringRevenueInContractAnalysis()
    var
        ContractAnalysisEntry: Record "Sub. Contr. Analysis Entry";
        CustomerContract: Record "Customer Subscription Contract";
        ServiceObject: Record "Subscription Header";
        VendorContract: Record "Vendor Subscription Contract";
        AmountArray, ExpectedUnitCostLCYArray : array[7] of Decimal;
        UnitCostLCY: Decimal;
        i: Integer;
        BillingBasePeriodArray: array[7] of Text;
    begin
        // [SCENARIO] Try to create Contract Analysis Entry and test the values
        // Setup multiple customer Subscription Lines with different options
        //1. Amount = 1200 Billing base period = 12M; MRR = 100, UnitCostLCY = 140
        //2. Amount = 200 Billing base period = 2M; MRR = 100, UnitCostLCY = 140
        //3. Amount = 100 Billing base period = 1M; MRR = 100, UnitCostLCY = 140
        //4. Amount = 1200 Billing base period = 1Y; MRR = 100, UnitCostLCY = 140
        //5. Amount = 2400 Billing base period = 2Y; MRR = 100, UnitCostLCY = 140
        //6. Amount = 300 Billing base period = 1Q; MRR = 100, UnitCostLCY = 140
        //7. Amount = 600 Billing base period = 2Q; MRR = 100, UnitCostLCY = 140
        // Add Vendor Subscription Line with Billing base period 2Q and Amount = 600 Expected for Customer Subscription Line MRC = 100
        Initialize();
        ContractAnalysisEntry.DeleteAll(false);

        // [GIVEN]
        BillingBasePeriodArray[1] := '<12M>';
        BillingBasePeriodArray[2] := '<2M>';
        BillingBasePeriodArray[3] := '<1M>';
        BillingBasePeriodArray[4] := '<1Y>';
        BillingBasePeriodArray[5] := '<2Y>';
        BillingBasePeriodArray[6] := '<1Q>';
        BillingBasePeriodArray[7] := '<2Q>';

        AmountArray[1] := 1200;
        AmountArray[2] := 200;
        AmountArray[3] := 100;
        AmountArray[4] := 1200;
        AmountArray[5] := 2400;
        AmountArray[6] := 300;
        AmountArray[7] := 600;

        UnitCostLCY := 140;

        SetupServiceObjectWithCustomerServiceCommitments(BillingBasePeriodArray, AmountArray, UnitCostLCY, 7, ServiceObject);

        ExpectedUnitCostLCYArray[1] := (UnitCostLCY * ServiceObject.Quantity) / 12;
        ExpectedUnitCostLCYArray[2] := (UnitCostLCY * ServiceObject.Quantity) / 2;
        ExpectedUnitCostLCYArray[3] := (UnitCostLCY * ServiceObject.Quantity) / 1;
        ExpectedUnitCostLCYArray[4] := (UnitCostLCY * ServiceObject.Quantity) / 12;
        ExpectedUnitCostLCYArray[5] := (UnitCostLCY * ServiceObject.Quantity) / 24;
        ExpectedUnitCostLCYArray[6] := (UnitCostLCY * ServiceObject.Quantity) / 3;
        ExpectedUnitCostLCYArray[7] := (UnitCostLCY * ServiceObject.Quantity) / 6;

        ContractTestLibrary.CreateCustomerContractAndCreateContractLinesForItems(CustomerContract, ServiceObject, ServiceObject."End-User Customer No."); // ExchangeRateSelectionModalPageHandler, MessageHandler
        ContractTestLibrary.CreateVendorContractAndCreateContractLinesForItems(VendorContract, ServiceObject, '');

        // [WHEN]
        Report.Run(Report::"Create Contract Analysis");

        //[THEN]: Test Customer Subscription Contract Analysis Entry for Expected values
        ContractAnalysisEntry.SetRange("Subscription Header No.", ServiceObject."No.");
        Assert.RecordIsNotEmpty(ContractAnalysisEntry);
        ContractAnalysisEntry.FindFirst();
        for i := 1 to ArrayLen(AmountArray) do begin
            ContractAnalysisEntry.TestField("Monthly Recurr. Revenue (LCY)", 100);
            ContractAnalysisEntry.TestField("Monthly Recurring Cost (LCY)", ExpectedUnitCostLCYArray[i]);
            ContractAnalysisEntry.Next();
        end;
        //[THEN]: Test Vendor Subscription Contract Analysis Entry for Expected values
        ContractAnalysisEntry.TestField("Monthly Recurr. Revenue (LCY)", 0);
        ContractAnalysisEntry.TestField("Monthly Recurring Cost (LCY)", 100);
    end;

    [Test]
    [HandlerFunctions('ServCommWOCustContractPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure TestRecalculateServiceCommitmentsOnChangeCurrencyCode()
    var
        Currency: Record Currency;
        CurrExchRate: Record "Currency Exchange Rate";
        Customer: Record Customer;
        CustomerContract: Record "Customer Subscription Contract";
        ServiceObject: Record "Subscription Header";
        CustomerContractPage: TestPage "Customer Contract";
    begin
        Initialize();
        Currency.InitRoundingPrecision();

        SetupServiceObjectForNewItemWithServiceCommitment(Customer, ServiceObject, false);
        ContractTestLibrary.CreateCustomerContract(CustomerContract, Customer."No.");

        CustomerContractPage.OpenEdit();
        CustomerContractPage.GoToRecord(CustomerContract);
        CustomerContractPage.GetServiceCommitmentsAction.Invoke();

        Currency.Get(LibraryERM.CreateCurrencyWithRandomExchRates());
        CustomerContract.Validate("Currency Code", Currency.Code);
        CustomerContract.Modify(false);

        TestServiceCommitmentUpdateOnCurrencyChange(
            WorkDate(),
            CurrExchRate.ExchangeRate(WorkDate(), CustomerContract."Currency Code"),
            true, Customer."Currency Code", Currency, CurrExchRate, ServiceObject."No.", CustomerContract);
    end;

    [Test]
    [HandlerFunctions('ServCommWOCustContractPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure TestResetServiceCommitmentsOnCurrencyCodeDelete()
    var
        Currency: Record Currency;
        CurrExchRate: Record "Currency Exchange Rate";
        Customer: Record Customer;
        CustomerContract: Record "Customer Subscription Contract";
        ServiceObject: Record "Subscription Header";
        CustomerContractPage: TestPage "Customer Contract";
    begin
        Initialize();
        Currency.InitRoundingPrecision();

        SetupServiceObjectForNewItemWithServiceCommitment(Customer, ServiceObject, false);
        ContractTestLibrary.CreateCustomerContract(CustomerContract, Customer."No.");

        CustomerContractPage.OpenEdit();
        CustomerContractPage.GoToRecord(CustomerContract);
        CustomerContractPage.GetServiceCommitmentsAction.Invoke();

        Currency.Get(LibraryERM.CreateCurrencyWithRandomExchRates());
        CustomerContract.Validate("Currency Code", '');
        CustomerContract.Modify(false);

        TestServiceCommitmentUpdateOnCurrencyChange(0D, 0, false, Customer."Currency Code", Currency, CurrExchRate, ServiceObject."No.", CustomerContract);
    end;

    [Test]
    procedure TransferCreateContractDeferralsFromContractType()
    var
        ContractType: Record "Subscription Contract Type";
        CustomerContract: Record "Customer Subscription Contract";
    begin
        // Create Customer Contract with contract type
        // Create new Contract Type with field "Def. Without Contr. Deferrals" = true
        // Check that the field value has been transferred
        Initialize();

        ContractTestLibrary.CreateCustomerContractWithContractType(CustomerContract, ContractType);
        ContractType.TestField("Create Contract Deferrals", true);
        CustomerContract.TestField("Create Contract Deferrals", true);
        ContractTestLibrary.CreateContractType(ContractType);
        ContractType."Create Contract Deferrals" := false;
        ContractType.Modify(false);
        CustomerContract.Validate("Contract Type", ContractType.Code);
        CustomerContract.Modify(false);
        CustomerContract.TestField("Create Contract Deferrals", false);

        // allow manually changing the value of the field
        CustomerContract.Validate("Create Contract Deferrals", true);
        CustomerContract.Modify(false);
        CustomerContract.TestField("Contract Type", ContractType.Code);
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler,CreateCustomerBillingDocsContractPageHandler')]
    procedure UpdatingServiceDatesWillNotCloseCustomerContractLinesWhenLineIsNotInvoicedCompletely()
    var
        Customer: Record Customer;
        CustomerContract: Record "Customer Subscription Contract";
        CustomerContractLine: Record "Cust. Sub. Contract Line";
        CustomerContractLine2: Record "Cust. Sub. Contract Line";
        ServiceCommitment: Record "Subscription Line";
        ServiceObject: Record "Subscription Header";
    begin
        // [SCENARIO] Test if the Customer Subscription Contract line will be closed in case of different constellations
        Initialize();

        SetupServiceObjectForNewItemWithServiceCommitment(Customer, ServiceObject, false);

        // [GIVEN] Create a Customer Subscription Contract with Subscription Lines
        ContractTestLibrary.CreateCustomerContractAndCreateContractLinesForItems(CustomerContract, ServiceObject, Customer."No."); // ExchangeRateSelectionModalPageHandler, MessageHandler
        ContractTestLibrary.InsertCustomerContractCommentLine(CustomerContract, CustomerContractLine2);

        // [GIVEN] Make sure that Subscription Line End Date is filled, to fullfil the requirement for close of the Customer Subscription Contract line
        ServiceCommitment.SetRange("Subscription Header No.", ServiceObject."No.");
        ServiceCommitment.SetRange("Subscription Contract No.", CustomerContract."No.");
        ServiceCommitment.SetRange("Sub. Header Customer No.", Customer."No.");
        if ServiceCommitment.FindSet() then
            repeat
                // Try to avoid Subscription Line start and end date to be in the future
                ServiceCommitment."Subscription Line End Date" := Today() - 1;
                ServiceCommitment."Subscription Line Start Date" :=
                    LibraryUtility.GenerateRandomDate(CalcDate('-' + Format(ServiceCommitment."Billing Rhythm"), ServiceCommitment."Subscription Line End Date"), ServiceCommitment."Subscription Line End Date");
                ServiceCommitment."Next Billing Date" := ServiceCommitment."Subscription Line Start Date";
                ServiceCommitment.Modify(false);
            until ServiceCommitment.Next() = 0;

        // [WHEN] Try to update Subscription Line dates
        ContractTestLibrary.CustomerContractUpdateServicesDates(CustomerContract);

        // [THEN] Expect that Customer Subscription Contract line is not closed and not invoiced
        VerifyServiceCommitmentClosureAndInvoicing(ServiceCommitment, false, false);

        // [WHEN] Invoice the contract and check closing of Subscription Lines
        CreateAndPostBillingProposal(ServiceCommitment."Subscription Line Start Date", ServiceObject."No."); // CreateCustomerBillingDocsContractPageHandler
        ContractTestLibrary.CustomerContractUpdateServicesDates(CustomerContract);
        VerifyServiceCommitmentClosureAndInvoicing(ServiceCommitment, true, true);

        // [THEN] Expect that all Customer Subscription Contract lines are closed and invoiced
        CustomerContractLine.Reset();
        CustomerContractLine.SetRange("Subscription Contract No.", CustomerContract."No.");
        CustomerContractLine.SetRange("Subscription Header No.", ServiceObject."No.");
        CustomerContractLine.SetRange("Contract Line Type", Enum::"Contract Line Type"::Item);
        CustomerContractLine.SetRange(Closed, false);
        Assert.RecordIsEmpty(CustomerContractLine);
    end;

    [Test]
    procedure UT_CheckContractInitValues()
    var
        CustomerContract: Record "Customer Subscription Contract";
    begin
        Initialize();
        ContractTestLibrary.CreateCustomerContract(CustomerContract, '');
        CustomerContract.TestField(Active, true);
        CustomerContract.TestField("Assigned User ID", UserId());
    end;

    [Test]
    procedure UT_CheckNewContractFromCustomer()
    var
        Customer: Record Customer;
        CustomerContract: Record "Customer Subscription Contract";
    begin
        Initialize();
        ContractTestLibrary.CreateCustomer(Customer);
        CustomerContract.Init();
        CustomerContract.Validate("Sell-to Customer No.", Customer."No.");
        CustomerContract.Insert(true);
    end;

    [Test]
    procedure UT_CheckTransferDefaultsFromCustomerToCustomerContract()
    var
        Customer: Record Customer;
        Customer2: Record Customer;
        CustomerContract: Record "Customer Subscription Contract";
    begin
        Initialize();

        ContractTestLibrary.CreateCustomer(Customer);
        ContractTestLibrary.CreateCustomer(Customer2);
        ContractTestLibrary.CreateCustomerContract(CustomerContract, '');
        CustomerContract.SetHideValidationDialog(true);

        CustomerContract.Validate("Sell-to Customer Name", Customer.Name);
        CustomerContract.TestField("Sell-to Customer No.", Customer."No.");
        CustomerContract.TestField("Salesperson Code", Customer."Salesperson Code");

        CustomerContract.Validate("Bill-to Name", Customer2.Name);
        CustomerContract.TestField("Bill-to Customer No.", Customer2."No.");
        CustomerContract.TestField("Payment Method Code", Customer2."Payment Method Code");
        CustomerContract.TestField("Payment Terms Code", Customer2."Payment Terms Code");
        CustomerContract.TestField("Currency Code", Customer2."Currency Code");
        CustomerContract.TestField("Salesperson Code", Customer2."Salesperson Code");
    end;

    [Test]
    procedure UT_DeleteAssignedContractTypeError()
    var
        ContractType: Record "Subscription Contract Type";
        CustomerContract: Record "Customer Subscription Contract";
    begin
        Initialize();
        ContractTestLibrary.CreateCustomerContractWithContractType(CustomerContract, ContractType);
        asserterror ContractType.Delete(true);
    end;

    [Test]
    procedure UT_ExpectErrorIfBillingBaseDateIsEmptyInCustomerContractHeader()
    var
        ContractType: Record "Subscription Contract Type";
        CustomerContract: Record "Customer Subscription Contract";
    begin
        Initialize();

        ContractTestLibrary.CreateCustomerContractWithContractType(CustomerContract, ContractType);
        ContractType.HarmonizedBillingCustContracts := true;
        ContractType.Modify(false);
        Evaluate(CustomerContract."Default Billing Rhythm", '2M');
        asserterror CustomerContract.Validate("Default Billing Rhythm");
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure UT_ExpectErrorOnMergeOneCustomerContractLine()
    var
        CustomerContract: Record "Customer Subscription Contract";
        CustomerContractLine: Record "Cust. Sub. Contract Line";
        ServiceObject: Record "Subscription Header";
    begin
        Initialize();
        SetupNewContract(false, ServiceObject, CustomerContract);
        asserterror CustomerContractLine.MergeContractLines(CustomerContractLine);
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure UT_ExpectErrorOnModifyServiceStartDateWhenBillingLineExist()
    var
        BillingTemplate: Record "Billing Template";
        CustomerContract: Record "Customer Subscription Contract";
        CustomerContractLine: Record "Cust. Sub. Contract Line";
        ServiceCommitment: Record "Subscription Line";
        ServiceObject: Record "Subscription Header";
    begin
        Initialize();
        ContractTestLibrary.CreateCustomerContractAndCreateContractLinesForItems(CustomerContract, ServiceObject, '', true);
        ContractTestLibrary.CreateBillingProposal(BillingTemplate, Enum::"Service Partner"::Customer);
        asserterror UpdateServiceStartDateFromCustomerContractSubpage(CustomerContract."No.", CustomerContractLine, ServiceCommitment);
    end;

    [Test]
    procedure UT_GetDateFiltersForCurrentAndPreviousMonth()
    begin
        // [SCENARIO] Test that GetDateFilters procedure returns proper date formula to get the
        // [SCENARIO] correct date for the beginning of the current month and previous month
        // Current Month Scenarios
        Initialize();

        TestDate(20240131D, 20240101D, 20240131D, true);
        TestDate(20240205D, 20240201D, 20240229D, true);
        TestDate(20240315D, 20240301D, 20240331D, true);
        TestDate(20240430D, 20240401D, 20240430D, true);
        TestDate(20240531D, 20240501D, 20240531D, true);
        TestDate(20240630D, 20240601D, 20240630D, true);
        TestDate(20240718D, 20240701D, 20240731D, true);
        TestDate(20240814D, 20240801D, 20240831D, true);
        TestDate(20240902D, 20240901D, 20240930D, true);
        TestDate(20241031D, 20241001D, 20241031D, true);
        TestDate(20241127D, 20241101D, 20241130D, true);
        TestDate(20241231D, 20241201D, 20241231D, true);

        // Previous Month Scenarios
        TestDate(20240131D, 20231201D, 20231231D, false);
        TestDate(20240205D, 20240101D, 20240131D, false);
        TestDate(20240315D, 20240201D, 20240229D, false);
        TestDate(20240430D, 20240301D, 20240331D, false);
        TestDate(20240531D, 20240401D, 20240430D, false);
        TestDate(20240630D, 20240501D, 20240531D, false);
        TestDate(20240718D, 20240601D, 20240630D, false);
        TestDate(20240814D, 20240701D, 20240731D, false);
        TestDate(20240902D, 20240801D, 20240831D, false);
        TestDate(20241031D, 20240901D, 20240930D, false);
        TestDate(20241127D, 20241001D, 20241031D, false);
        TestDate(20241231D, 20241101D, 20241130D, false);
        TestDate(20250131D, 20241201D, 20241231D, false);
    end;

    [Test]
    procedure UT_RemoveAndDeleteAssignedContractType()
    var
        ContractType: Record "Subscription Contract Type";
        CustomerContract: Record "Customer Subscription Contract";
    begin
        Initialize();
        ContractTestLibrary.CreateCustomerContractWithContractType(CustomerContract, ContractType);

        CustomerContract.Validate("Contract Type", '');
        CustomerContract.Modify(false);
        ContractType.Delete(true);
    end;

    #endregion Tests

    #region Procedures

    local procedure Initialize()
    begin
        LibraryVariableStorage.AssertEmpty();
        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"Contracts Test");
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Contracts Test");

        ContractTestLibrary.DeleteAllContractRecords();

        if IsInitialized then
            exit;

        ContractTestLibrary.InitContractsApp();
        LibraryERMCountryData.UpdatePurchasesPayablesSetup();
        LibraryERMCountryData.UpdateSalesReceivablesSetup();
        LibraryERMCountryData.UpdateGeneralLedgerSetup();
        LibraryERMCountryData.UpdateJournalTemplMandatory(false);
        ContractTestLibrary.InitSourceCodeSetup();
        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"Contracts Test");

        IsInitialized := true;
    end;

    procedure CreateItemWithSubscriptionLines(var Item: Record Item)
    var
        SubscriptionPackage: Record "Subscription Package";
        SubscriptionPackageLine: Record "Subscription Package Line";
        SubPackageLineTemplate: Record "Sub. Package Line Template";
    begin
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Invoicing Item");
        ContractTestLibrary.CreateServiceCommitmentTemplate(SubPackageLineTemplate);
        SubPackageLineTemplate."Invoicing Item No." := Item."No.";
        SubPackageLineTemplate."Calculation Base %" := LibraryRandom.RandDecInRange(0, 100, 2);
        Evaluate(SubPackageLineTemplate."Billing Base Period", '<12M>');
        SubPackageLineTemplate.Modify(false);
        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(SubPackageLineTemplate.Code, SubscriptionPackage, SubscriptionPackageLine);
        ContractTestLibrary.InitServiceCommitmentPackageLineFields(SubscriptionPackageLine);
        ContractTestLibrary.CreateServiceCommitmentPackageLine(SubscriptionPackage.Code, SubPackageLineTemplate.Code, SubscriptionPackageLine);
        ContractTestLibrary.InitServiceCommitmentPackageLineFields(SubscriptionPackageLine);
        ContractTestLibrary.SetupSalesServiceCommitmentItemAndAssignToServiceCommitmentPackage(Item, Enum::"Item Service Commitment Type"::"Sales with Service Commitment", SubscriptionPackage.Code);
    end;

    local procedure CalculateDatesFromDateFormula(ReferenceDate: Date; DateFilterFrom: Text; DateFilterTo: Text; var MonthStartDate: Date; var MonthEndDate: Date)
    begin
        MonthStartDate := CalcDate(DateFilterFrom, ReferenceDate);
        MonthEndDate := CalcDate(DateFilterTo, ReferenceDate);
    end;

    local procedure CreateAndAssignHarmonizationCustomerContractType(var CustomerContract: Record "Customer Subscription Contract")
    var
        ContractType: Record "Subscription Contract Type";
    begin
        ContractTestLibrary.CreateContractType(ContractType);
        ContractType.HarmonizedBillingCustContracts := true;
        ContractType.Modify(false);
        CustomerContract."Contract Type" := ContractType.Code;
        CustomerContract.Modify(false);
    end;

    local procedure CreateAndPostBillingProposal(BillingDate: Date; ServiceObjectNo: Code[20])
    var
        BillingLine: Record "Billing Line";
        BillingTemplate: Record "Billing Template";
        SalesHeader: Record "Sales Header";
    begin
        ContractTestLibrary.CreateBillingProposal(BillingTemplate, Enum::"Service Partner"::Customer, BillingDate);
        BillingLine.SetRange("Billing Template Code", BillingTemplate.Code);
        BillingLine.SetRange(Partner, BillingLine.Partner::Customer);
        BillingLine.SetRange("Subscription Header No.", ServiceObjectNo);
        Codeunit.Run(Codeunit::"Create Billing Documents", BillingLine);

        // Post Sales Document
        BillingLine.FindFirst();
        SalesHeader.Get(Enum::"Sales Document Type"::Invoice, BillingLine."Document No.");
        UpdateSalesLineGenPostingSetup(SalesHeader);
        LibrarySales.PostSalesDocument(SalesHeader, true, true);
    end;

    local procedure CreateContractWithDetailOverviewAndSalesInvoice(i: Integer; var SalesHeader: Record "Sales Header"; var CustomerContract: Record "Customer Subscription Contract")
    var
        BillingLine: Record "Billing Line";
        BillingTemplate: Record "Billing Template";
        ContractsFilter: Text;
    begin
        CreateCustomerContractWithDetailOverview(ContractsFilter, Enum::"Contract Detail Overview".FromInteger(i), '', CustomerContract);
        ContractTestLibrary.CreateBillingProposal(BillingTemplate, Enum::"Service Partner"::Customer);
        BillingLine.SetRange("Subscription Contract No.", CustomerContract."No.");
        BillingLine.SetRange("Billing Template Code", BillingTemplate.Code);
        BillingLine.SetRange(Partner, BillingLine.Partner::Customer);
        Codeunit.Run(Codeunit::"Create Billing Documents", BillingLine);
        BillingLine.FindFirst();
        SalesHeader.Get(SalesHeader."Document Type"::Invoice, BillingLine."Document No.");
    end;

    local procedure CreateCustomerContractSetup(var Customer: Record Customer; var ServiceObject: Record "Subscription Header"; var CustomerContract: Record "Customer Subscription Contract")
    var
        TempServiceCommitment: Record "Subscription Line" temporary;
    begin
        ContractTestLibrary.CreateCustomerContract(CustomerContract, Customer."No.");
        ContractTestLibrary.FillTempServiceCommitment(TempServiceCommitment, ServiceObject, CustomerContract);
        CustomerContract.CreateCustomerContractLinesFromServiceCommitments(TempServiceCommitment);
    end;

    local procedure CreateCustomerContractWithDetailOverview(var ContractsFilter: Text; DetailOverview: Enum "Contract Detail Overview"; CustomerNo: Code[20]; var CustomerContract: Record "Customer Subscription Contract")
    var
        ServiceObject: Record "Subscription Header";
        TextMgmt: Codeunit "Text Management";
    begin
        ContractTestLibrary.CreateCustomerContractAndCreateContractLinesForItems(CustomerContract, ServiceObject, CustomerNo, true);
        CustomerContract."Detail Overview" := DetailOverview;
        CustomerContract.Modify(false);
        TextMgmt.AppendText(ContractsFilter, CustomerContract."No.", '|');
    end;

    local procedure CreateTwoEqualServiceObjectsWithServiceCommitments(var ServiceObject: Record "Subscription Header"; var ServiceObject1: Record "Subscription Header")
    var
        ServiceCommitment: Record "Subscription Line";
        ServiceCommitment2: Record "Subscription Line";
    begin
        ServiceObject1 := ServiceObject;
        ServiceObject1."No." := IncStr(ServiceObject."No.");
        ServiceObject1.Insert(false);
        ServiceCommitment.SetRange("Subscription Header No.", ServiceObject."No.");
        if ServiceCommitment.FindSet() then begin
            ServiceCommitment."Subscription Line Start Date" := CalcDate('<-2M>', Today);
            ServiceCommitment."Next Billing Date" := ServiceCommitment."Subscription Line Start Date";
            ServiceCommitment.Validate("Subscription Line Start Date");
            ServiceCommitment.Modify(false);
            repeat
                ServiceCommitment2 := ServiceCommitment;
                ServiceCommitment2."Entry No." := 0;
                ServiceCommitment2."Subscription Contract No." := '';
                ServiceCommitment2."Subscription Header No." := ServiceObject1."No.";
                ServiceCommitment2.Insert(false);
            until ServiceCommitment.Next() = 0;
        end;
    end;

    local procedure CountCreatedSalesDocuments(var BillingLine: Record "Billing Line") DocumentsCount: Integer
    var
        SalesHeader: Record "Sales Header";
        TempSalesHeader: Record "Sales Header" temporary;
    begin
        if BillingLine.FindSet() then
            repeat
                BillingLine.TestField("Document Type", Enum::"Rec. Billing Document Type"::Invoice);
                BillingLine.TestField("Document No.");
                SalesHeader.Get(Enum::"Sales Document Type"::Invoice, BillingLine."Document No.");
                if not TempSalesHeader.Get(SalesHeader."Document Type", SalesHeader."No.") then begin
                    TempSalesHeader.TransferFields(SalesHeader);
                    TempSalesHeader.Insert(false);
                    DocumentsCount += 1;
                end;
            until BillingLine.Next() = 0;
        exit(DocumentsCount);
    end;

    local procedure GetTotalServiceAmountFromServiceCommitments(Currency: Record Currency; ServiceObjectNo: Code[20]; ServiceObject1: Record "Subscription Header"): Decimal
    var
        ServiceCommitment: Record "Subscription Line";
    begin
        ServiceCommitment.SetRange("Subscription Header No.", ServiceObjectNo, ServiceObject1."No.");
        ServiceCommitment.FindFirst();
        exit(Round(ServiceCommitment.Price * ServiceObject1.Quantity * 2, Currency."Amount Rounding Precision"));
    end;

    local procedure SetupNewContract(CreateAdditionalLine: Boolean; var ServiceObject: Record "Subscription Header"; var CustomerContract: Record "Customer Subscription Contract")
    begin
        ContractTestLibrary.CreateCustomerContractAndCreateContractLinesForItems(CustomerContract, ServiceObject, '', CreateAdditionalLine);
    end;

    local procedure SetupServiceObjectWithCustomerServiceCommitments(BillingBasePeriodArray: array[7] of Text; AmountArray: array[7] of Decimal; ItemUnitCost: Decimal; NoOfRecords: Integer; var ServiceObject: Record "Subscription Header")
    var
        Customer: Record Customer;
        Item: Record Item;
        ItemServCommitmentPackage: Record "Item Subscription Package";
        ServiceCommPackageLine: Record "Subscription Package Line";
        ServiceCommitment: Record "Subscription Line";
        ServiceCommitmentPackage: Record "Subscription Package";
        ServiceCommitmentTemplate: Record "Sub. Package Line Template";
        i: Integer;
    begin
        ContractTestLibrary.CreateCustomer(Customer);
        ContractTestLibrary.CreateServiceObjectForItem(ServiceObject, Item, false);
        Item."Unit Cost" := ItemUnitCost;
        Item.Modify(false);

        ServiceObject.Validate("End-User Customer Name", Customer.Name);
        ServiceObject.Modify(false);

        ContractTestLibrary.CreateServiceCommitmentTemplate(ServiceCommitmentTemplate);
        ServiceCommitmentTemplate."Calculation Base %" := LibraryRandom.RandDec(100, 2);
        ServiceCommitmentTemplate."Invoicing via" := Enum::"Invoicing Via"::Contract;
        ServiceCommitmentTemplate.Modify(false);

        ContractTestLibrary.CreateServiceCommitmentPackage(ServiceCommitmentPackage);
        for i := 1 to NoOfRecords do
            ContractTestLibrary.CreateServiceCommitmentPackageLine(ServiceCommitmentPackage.Code, ServiceCommitmentTemplate.Code, ServiceCommPackageLine, BillingBasePeriodArray[i], BillingBasePeriodArray[i], Enum::"Service Partner"::Customer);

        ContractTestLibrary.CreateServiceCommitmentPackageLine(ServiceCommitmentPackage.Code, ServiceCommitmentTemplate.Code, ServiceCommPackageLine, BillingBasePeriodArray[i], BillingBasePeriodArray[i], Enum::"Service Partner"::Vendor);
        ContractTestLibrary.AssignItemToServiceCommitmentPackage(Item, ServiceCommitmentPackage.Code);
        ServiceCommitmentPackage.SetFilter(Code, ItemServCommitmentPackage.GetPackageFilterForItem(ServiceObject."Source No."));
        ServiceObject.InsertServiceCommitmentsFromServCommPackage(WorkDate(), ServiceCommitmentPackage);
        ServiceCommitment.SetRange("Subscription Header No.", ServiceObject."No.");
        ServiceCommitment.FindFirst();
        for i := 1 to NoOfRecords do begin
            ServiceCommitment.Validate("Calculation Base %", 100);
            ServiceCommitment.Validate("Calculation Base Amount", AmountArray[i]);
            ServiceCommitment.Validate(Amount, AmountArray[i]);
            ServiceCommitment.CalculateUnitCost();
            ServiceCommitment.Modify(false);
            ServiceCommitment.Next();
        end;
        // +1 to make sure that vendor Subscription Line is  updated as well with the value of the last cust. Subscription Line
        ServiceCommitment.Validate("Calculation Base %", 100);
        ServiceCommitment.Validate("Calculation Base Amount", AmountArray[i]);
        ServiceCommitment.Validate(Amount, AmountArray[i]);
        ServiceCommitment.Modify(false);
    end;

    local procedure SetupServiceObjectForNewItemWithServiceCommitment(var Customer: Record Customer; var ServiceObject: Record "Subscription Header"; SNSpecificTracking: Boolean; AddVendorServiceCommitment: Boolean)
    var
        Item: Record Item;
        ItemServCommitmentPackage: Record "Item Subscription Package";
        ServiceCommPackageLine: Record "Subscription Package Line";
        ServiceCommitmentPackage: Record "Subscription Package";
        ServiceCommitmentTemplate: Record "Sub. Package Line Template";
        ServiceCommitmentTemplate2: Record "Sub. Package Line Template";
    begin
        ContractTestLibrary.CreateCustomer(Customer);
        ContractTestLibrary.CreateServiceObjectForItem(ServiceObject, Item, SNSpecificTracking);
        ServiceObject.Validate("End-User Customer Name", Customer.Name);
        ServiceObject.Modify(false);

        ContractTestLibrary.CreateServiceCommitmentTemplate(ServiceCommitmentTemplate);
        ServiceCommitmentTemplate."Calculation Base %" := LibraryRandom.RandDec(100, 2);
        Evaluate(ServiceCommitmentTemplate."Billing Base Period", '<12M>');
        ServiceCommitmentTemplate."Invoicing via" := Enum::"Invoicing Via"::Contract;
        ServiceCommitmentTemplate.Modify(false);

        ContractTestLibrary.CreateServiceCommitmentTemplate(ServiceCommitmentTemplate2);
        ServiceCommitmentTemplate2."Calculation Base %" := LibraryRandom.RandDec(100, 2);
        Evaluate(ServiceCommitmentTemplate."Billing Base Period", '<12M>');
        ServiceCommitmentTemplate2."Invoicing via" := Enum::"Invoicing Via"::Sales;
        ServiceCommitmentTemplate2.Modify(false);

        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage, ServiceCommPackageLine);
        ServiceCommPackageLine.Partner := Enum::"Service Partner"::Customer;
        Evaluate(ServiceCommPackageLine."Extension Term", '<1Y>');
        Evaluate(ServiceCommPackageLine."Notice Period", '<1M>');
        Evaluate(ServiceCommPackageLine."Initial Term", '<1Y>');
        Evaluate(ServiceCommPackageLine."Billing Rhythm", '<1M>');
        ServiceCommPackageLine.Modify(false);

        ContractTestLibrary.CreateServiceCommitmentPackageLine(ServiceCommitmentPackage.Code, ServiceCommitmentTemplate2.Code, ServiceCommPackageLine);
        ServiceCommPackageLine.Partner := Enum::"Service Partner"::Customer;
        Evaluate(ServiceCommPackageLine."Extension Term", '<1Y>');
        Evaluate(ServiceCommPackageLine."Notice Period", '<1M>');
        Evaluate(ServiceCommPackageLine."Initial Term", '<1Y>');
        Evaluate(ServiceCommPackageLine."Billing Rhythm", '<1M>');
        ServiceCommPackageLine.Modify(false);

        if AddVendorServiceCommitment then begin
            ContractTestLibrary.CreateServiceCommitmentPackageLine(ServiceCommitmentPackage.Code, ServiceCommitmentTemplate2.Code, ServiceCommPackageLine);
            ServiceCommPackageLine.Partner := Enum::"Service Partner"::Vendor;
            Evaluate(ServiceCommPackageLine."Extension Term", '<1Y>');
            Evaluate(ServiceCommPackageLine."Notice Period", '<1M>');
            Evaluate(ServiceCommPackageLine."Initial Term", '<1Y>');
            Evaluate(ServiceCommPackageLine."Billing Rhythm", '<1M>');
            ServiceCommPackageLine.Modify(false);
        end;

        ContractTestLibrary.AssignItemToServiceCommitmentPackage(Item, ServiceCommitmentPackage.Code);
        ServiceCommitmentPackage.SetFilter(Code, ItemServCommitmentPackage.GetPackageFilterForItem(ServiceObject."Source No."));
        ServiceObject.InsertServiceCommitmentsFromServCommPackage(WorkDate(), ServiceCommitmentPackage);
    end;

    local procedure SetupServiceObjectForNewItemWithServiceCommitment(var Customer: Record Customer; var ServiceObject: Record "Subscription Header"; SNSpecificTracking: Boolean)
    begin
        SetupServiceObjectForNewItemWithServiceCommitment(Customer, ServiceObject, SNSpecificTracking, false);
    end;

    local procedure SetupServiceObjectForNewGLAccountWithServiceCommitment(var Customer: Record Customer; var ServiceObject: Record "Subscription Header")
    var
        GLAccount: Record "G/L Account";
    begin
        ClearAll();
        ContractTestLibrary.CreateCustomer(Customer);
        ContractTestLibrary.CreateServiceObjectForGLAccountWithServiceCommitments(ServiceObject, GLAccount, 1, 0, '<1Y>', '<1M>');
        ServiceObject.Validate("End-User Customer Name", Customer.Name);
        ServiceObject.Modify(false);
    end;

    local procedure TestHarmonizationForCustomerContract(var CustomerContract: Record "Customer Subscription Contract"; var BillingLine: Record "Billing Line"; var ServiceCommitment: Record "Subscription Line")
    begin
        BillingLine.FindLast();
        ServiceCommitment.FindSet();
        repeat
            ServiceCommitment.TestField("Next Billing Date", CalcDate('<1D>', BillingLine."Billing to"));
        until ServiceCommitment.Next() = 0;
        CustomerContract.Get(CustomerContract."No.");
        CustomerContract.TestField("Next Billing From", ServiceCommitment."Next Billing Date");
        CustomerContract.TestField(
            "Next Billing To",
            CalcDate('<' + Format(CustomerContract."Default Billing Rhythm") + '-1D>', CustomerContract."Next Billing From"));
    end;

    local procedure TestCustomerContractLinesServiceObjectDescription(CustomerContractNo: Code[20]; ServiceObjectDescription: Text[100])
    var
        CustomerContractLine: Record "Cust. Sub. Contract Line";
    begin
        CustomerContractLine.SetRange("Subscription Contract No.", CustomerContractNo);
        CustomerContractLine.FindSet();
        repeat
            CustomerContractLine.TestField("Subscription Description", ServiceObjectDescription);
        until CustomerContractLine.Next() = 0;
    end;

    local procedure TestNewServiceObject(ServiceObject: Record "Subscription Header"; ServiceObject1: Record "Subscription Header"; var NewServiceObject: Record "Subscription Header"; ServiceObjectNo: Code[20])
    begin
        NewServiceObject.Get(ServiceObjectNo);
        NewServiceObject.TestField(Description, ServiceObject.Description);
        NewServiceObject.TestField(Type, NewServiceObject.Type::Item);
        NewServiceObject.TestField("Source No.", ServiceObject."Source No.");
        NewServiceObject.TestField("End-User Customer No.", ServiceObject."End-User Customer No.");
        NewServiceObject.TestField(Quantity, ServiceObject.Quantity + ServiceObject1.Quantity);
    end;

    local procedure TestServiceCommitmentUpdateOnCurrencyChange(CurrencyFactorDate: Date; CurrencyFactor: Decimal; RecalculatePrice: Boolean; CustomerCurrencyCode: Code[10]; Currency: Record Currency; CurrExchRate: Record "Currency Exchange Rate"; ServiceObjectNo: Code[20]; CustomerContract: Record "Customer Subscription Contract")
    var
        ServiceCommitment: Record "Subscription Line";
    begin
        ServiceCommitment.SetRange("Subscription Header No.", ServiceObjectNo);
        ServiceCommitment.SetRange("Subscription Contract No.", CustomerContract."No.");
        ServiceCommitment.FindSet(false);
        repeat
            ServiceCommitment.TestField("Currency Code", CustomerContract."Currency Code");
            ServiceCommitment.TestField("Currency Factor Date", CurrencyFactorDate);
            ServiceCommitment.TestField("Currency Factor", CurrencyFactor);

            if RecalculatePrice then begin // if currency code is changed to '', amounts and amounts in lcy in Subscription Lines should be the same
                Currency.Get(CustomerCurrencyCode);
                ServiceCommitment.TestField(
                    Price,
                    Round(CurrExchRate.ExchangeAmtLCYToFCY(CurrencyFactorDate, CustomerCurrencyCode, ServiceCommitment."Price (LCY)", CurrencyFactor), Currency."Unit-Amount Rounding Precision"));

                ServiceCommitment.TestField(
                    Amount,
                    Round(CurrExchRate.ExchangeAmtLCYToFCY(CurrencyFactorDate, CustomerCurrencyCode, ServiceCommitment."Amount (LCY)", CurrencyFactor), Currency."Amount Rounding Precision"));

                ServiceCommitment.TestField(
                    "Discount Amount",
                    Round(CurrExchRate.ExchangeAmtLCYToFCY(CurrencyFactorDate, CustomerCurrencyCode, ServiceCommitment."Discount Amount (LCY)", CurrencyFactor), Currency."Amount Rounding Precision"));
            end
            else begin
                ServiceCommitment.TestField(Price, ServiceCommitment."Price (LCY)");
                ServiceCommitment.TestField(Amount, ServiceCommitment."Amount (LCY)");
                ServiceCommitment.TestField("Discount Amount", ServiceCommitment."Discount Amount (LCY)");
            end;
        until ServiceCommitment.Next() = 0;
    end;

    local procedure TestDate(NewReferenceDate: Date; NewExpectedStartDate: Date; NewExpectedEndDate: Date; CurrentMonth: Boolean)
    var
        SubBillingActivitiesCue: Codeunit "Sub. Billing Activities Cue";
        DateFilterFrom, DateFilterTo : Text;
        ReferenceDate, ExpectedStartDate, ExpectedEndDate, MonthStartDate, MonthEndDate : Date;
    begin
        ReferenceDate := NewReferenceDate;
        ExpectedStartDate := NewExpectedStartDate;
        ExpectedEndDate := NewExpectedEndDate;

        SubBillingActivitiesCue.GetDateFilterFormulas(CurrentMonth, DateFilterFrom, DateFilterTo);
        CalculateDatesFromDateFormula(ReferenceDate, DateFilterFrom, DateFilterTo, MonthStartDate, MonthEndDate);

        Assert.AreEqual(ExpectedStartDate, MonthStartDate, 'Calculated Month Start Date is unexpected.');
        Assert.AreEqual(ExpectedEndDate, MonthEndDate, 'Calculated Month End Date is unexpected.');
    end;

    local procedure UpdateSalesLineGenPostingSetup(var SalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
    begin
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        if SalesLine.FindSet() then
            repeat
                ContractTestLibrary.SetGeneralPostingSetup(SalesLine."Gen. Bus. Posting Group", SalesLine."Gen. Prod. Posting Group", false, Enum::"Service Partner"::Customer);
            until SalesLine.Next() = 0;
    end;

    local procedure UpdateServiceStartDateFromCustomerContractSubpage(CustomerContractNo: Code[20]; var CustomerContractLine: Record "Cust. Sub. Contract Line"; var ServiceCommitment: Record "Subscription Line")
    var
        NewServiceStartDate: Date;
        CustomerContractSubpage: TestPage "Customer Contract Line Subp.";
    begin
        CustomerContractLine.SetRange("Subscription Contract No.", CustomerContractNo);
        CustomerContractLine.FindFirst();
        CustomerContractLine.GetServiceCommitment(ServiceCommitment);
        NewServiceStartDate := CalcDate('<1M>', ServiceCommitment."Subscription Line Start Date");

        CustomerContractSubpage.OpenEdit();
        CustomerContractSubpage.GoToRecord(CustomerContractLine);
        CustomerContractSubpage."Service Start Date".SetValue(NewServiceStartDate);
        CustomerContractSubpage.Close();
    end;

    local procedure VerifyServiceCommitmentClosureAndInvoicing(var SourceServiceCommitment: Record "Subscription Line"; ExpectedClosedValue: Boolean; IsContractLineInvoiced: Boolean)
    begin
        SourceServiceCommitment.SetRange(Closed, true);
        if SourceServiceCommitment.FindSet() then
            repeat
                Assert.AreEqual(ExpectedClosedValue, SourceServiceCommitment.Closed, 'Customer Subscription Contract line should not be closed');
                if IsContractLineInvoiced then // Double check that contract line is invoiced
                    SourceServiceCommitment.TestField("Next Billing Date", CalcDate('<+1D>', SourceServiceCommitment."Subscription Line End Date"));
            until SourceServiceCommitment.Next() = 0;
    end;

    #endregion Procedures

    #region Handlers

    [ConfirmHandler]
    procedure ConfirmHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := true;
    end;

    [ModalPageHandler]
    procedure CreateCustomerBillingDocsContractPageHandler(var CreateCustomerBillingDocs: TestPage "Create Customer Billing Docs")
    begin
        CreateCustomerBillingDocs.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure CreateCustomerBillingDocsSellToCustomerPageHandler(var CreateCustomerBillingDocs: TestPage "Create Customer Billing Docs")
    begin
        CreateCustomerBillingDocs.GroupingType.SetValue(Enum::"Customer Rec. Billing Grouping"::"Sell-to Customer No.");
        CreateCustomerBillingDocs.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure ExchangeRateSelectionModalPageHandler(var ExchangeRateSelectionPage: TestPage "Exchange Rate Selection")
    begin
        ExchangeRateSelectionPage.OK().Invoke();
    end;

    [MessageHandler]
    procedure MessageHandler(Message: Text[1024])
    begin
    end;

    [PageHandler]
    procedure PostedSalesCrMemosPageHandler(var PostedSalesCreditMemos: TestPage "Posted Sales Credit Memos")
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
    begin
        SalesCrMemoHeader.Get(LibraryVariableStorage.DequeueText());
        PostedSalesCreditMemos.GoToRecord(SalesCrMemoHeader);
    end;

    [PageHandler]
    procedure PostedSalesInvoicesPageHandler(var PostedSalesInvoices: TestPage "Posted Sales Invoices")
    var
        SalesInvoiceHeader2: Record "Sales Invoice Header";
    begin
        SalesInvoiceHeader2.Get(LibraryVariableStorage.DequeueText());
        PostedSalesInvoices.GoToRecord(SalesInvoiceHeader2);
    end;

    [PageHandler]
    procedure SalesCreditMemosPageHandler(var SalesCreditMemos: TestPage "Sales Credit Memos")
    var
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader.Get(Enum::"Sales Document Type"::"Credit Memo", LibraryVariableStorage.DequeueText());
        SalesCreditMemos.GoToRecord(SalesHeader);
    end;

    [PageHandler]
    procedure SalesInvoiceListPageHandler(var SalesInvoiceList: TestPage "Sales Invoice List")
    var
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader.Get(Enum::"Sales Document Type"::Invoice, LibraryVariableStorage.DequeueText());
        SalesInvoiceList.GoToRecord(SalesHeader);
    end;

    [PageHandler]
    procedure ServCommWOCustContractPageHandler(var ServCommWOCustContractPage: TestPage "Serv. Comm. WO Cust. Contract")
    begin
        ServCommWOCustContractPage.AssignAllServiceCommitmentsAction.Invoke();
    end;

    [ModalPageHandler]
    procedure SelectCustomerContractLinePageHandler(var SelectCustContractLines: TestPage "Select Cust. Contract Lines")
    begin
        SelectCustContractLines.OK().Invoke();
    end;

    #endregion Handlers
}
