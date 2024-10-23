namespace Microsoft.SubscriptionBilling;

using System.Globalization;
using Microsoft.Utilities;
using Microsoft.Foundation.Attachment;
using Microsoft.Inventory.Item;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using Microsoft.Finance.Currency;

codeunit 148155 "Contracts Test"
{
    Subtype = Test;
    TestPermissions = Disabled;
    Access = Internal;

    var
        Customer: Record Customer;
        Customer2: Record Customer;
        ContractType: Record "Contract Type";
        CustomerContract: Record "Customer Contract";
        ServiceObject: Record "Service Object";
        Item: Record Item;
        ServiceCommitmentTemplate: Record "Service Commitment Template";
        ServiceCommitmentTemplate2: Record "Service Commitment Template";
        Currency: Record Currency;
        CustomerContractLine: Record "Customer Contract Line";
        ServiceCommitment: Record "Service Commitment";
        SalesHeader: Record "Sales Header";
        BillingTemplate: Record "Billing Template";
        BillingLine: Record "Billing Line";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        CurrExchRate: Record "Currency Exchange Rate";
        ServiceObject1: Record "Service Object";
        ServiceCommitment1: Record "Service Commitment";
        NewServiceObject: Record "Service Object";
        SalesLine: Record "Sales Line";
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        LibraryERMCountryData: Codeunit "Library - ERM Country Data";
        ContractTestLibrary: Codeunit "Contract Test Library";
        LibraryRandom: Codeunit "Library - Random";
        AssertThat: Codeunit Assert;
        LibrarySales: Codeunit "Library - Sales";
        CorrectPostedSalesInvoice: Codeunit "Correct Posted Sales Invoice";
        CopyDocMgt: Codeunit "Copy Document Mgt.";
        TextMgmt: Codeunit "Text Management";
        LibraryERM: Codeunit "Library - ERM";
        BillingRhythmValue: DateFormula;
        CustomerContractPage: TestPage "Customer Contract";
        DescriptionText: Text;
        ContractsFilter: Text;
        ExpectedDate: Date;
        ExpectedDecimalValue: Decimal;
        DocumentNo: Code[20];
        PostedDocumentNo: Code[20];
        DocumentsCount: Integer;
        NextBillingTo: Date;
        CustomerReference: Text;
        IsInitialized: Boolean;

    [Test]
    procedure CheckNewContractFromCustomer()
    begin
        ClearAll();

        ContractTestLibrary.CreateCustomer(Customer);
        CustomerContract.Init();
        CustomerContract.Validate("Sell-to Customer No.", Customer."No.");
        CustomerContract.Insert(true);
    end;

    [Test]
    procedure CheckContractInitValues()
    begin
        ClearAll();

        ContractTestLibrary.CreateCustomerContract(CustomerContract, '');

        CustomerContract.TestField(Active, true);
        CustomerContract.TestField("Assigned User ID", UserId());
    end;

    [Test]
    procedure DeleteAssignedContractTypeError()
    begin
        ClearAll();

        ContractTestLibrary.CreateCustomerContractWithContractType(CustomerContract, ContractType);

        asserterror ContractType.Delete(true);
    end;

    [Test]
    procedure RemoveAndDeleteAssignedContractType()
    begin
        ClearAll();

        ContractTestLibrary.CreateCustomerContractWithContractType(CustomerContract, ContractType);

        CustomerContract.Validate("Contract Type", '');
        CustomerContract.Modify(false);

        ContractType.Delete(true);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    procedure CheckTransferDefaultsFromCustomerToCustomerContract()
    begin
        ClearAll();

        ContractTestLibrary.CreateCustomer(Customer);
        ContractTestLibrary.CreateCustomer(Customer2);
        ContractTestLibrary.CreateCustomerContract(CustomerContract, '');
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

    [ConfirmHandler]
    procedure ConfirmHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := true;
    end;

    [Test]
    procedure CheckServiceCommitmentsWithoutCustomerContract()
    var
        ServCommWOCustContract: TestPage "Serv. Comm. WO Cust. Contract";
    begin
        SetupServiceObjectWithServiceCommitment(false);

        ServCommWOCustContract.OpenEdit();

        ServiceCommitment.Reset();
        ServiceCommitment.SetRange("Service Object No.", ServiceObject."No.");
        ServiceCommitment.FindSet();
        repeat
            if ServiceCommitment."Invoicing via" = Enum::"Invoicing Via"::Contract then
                AssertThat.IsTrue(ServCommWOCustContract.GoToRecord(ServiceCommitment), 'Expected Service Commitment not found.')
            else
                AssertThat.IsFalse(ServCommWOCustContract.GoToRecord(ServiceCommitment), 'Service Commitment is found but it should not be.');
        until ServiceCommitment.Next() = 0;
    end;

    [Test]
    [HandlerFunctions('ServCommWOCustContractPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure CheckServiceCommitmentAssignmentToCustomerContract()
    begin
        //SCENARIO: Check that proper Service Commitments are assigned to Customer Contract Lines.
        SetupServiceObjectWithServiceCommitment(false);
        ContractTestLibrary.CreateCustomerContract(CustomerContract, Customer."No.");

        CustomerContractPage.OpenEdit();
        CustomerContractPage.GoToRecord(CustomerContract);
        CustomerContractPage.GetServiceCommitmentsAction.Invoke();

        ServiceCommitment.Reset();
        ServiceCommitment.SetRange("Service Object No.", ServiceObject."No.");
        ServiceCommitment.FindSet();
        repeat
            CustomerContractLine.SetRange("Contract No.", CustomerContract."No.");
            CustomerContractLine.SetRange("Contract Line Type", CustomerContractLine."Contract Line Type"::"Service Commitment");
            CustomerContractLine.SetRange("Service Object No.", ServiceCommitment."Service Object No.");
            CustomerContractLine.SetRange("Service Commitment Entry No.", ServiceCommitment."Entry No.");
            case ServiceCommitment."Invoicing via" of
                Enum::"Invoicing Via"::Contract:
                    begin
                        AssertThat.IsTrue(CustomerContractLine.FindFirst(), 'Service Commitment not assiged to expected Customer Contract Line.');
                        CustomerContractLine.TestField("Contract No.", ServiceCommitment."Contract No.");
                        CustomerContractLine.TestField("Contract Line Type", CustomerContractLine."Contract Line Type"::"Service Commitment");
                    end;
                Enum::"Invoicing Via"::Sales:
                    begin
                        AssertThat.IsTrue(CustomerContractLine.IsEmpty(), 'Service Commitment is assigned to Customer Contract Line but it is not expected.');
                        ServiceCommitment.TestField("Contract No.", '');
                    end;
                else
                    Error('Invoicing via %1 not managed', Format(ServiceCommitment."Invoicing via"));
            end;
        until ServiceCommitment.Next() = 0;
    end;

    [PageHandler]
    procedure ServCommWOCustContractPageHandler(var ServCommWOCustContractPage: TestPage "Serv. Comm. WO Cust. Contract")
    begin
        ServCommWOCustContractPage.AssignAllServiceCommitmentsAction.Invoke();
    end;

    [Test]
    [HandlerFunctions('MessageHandler,ExchangeRateSelectionModalPageHandler')]
    procedure ExpectErrorForWrongServiceCommitmentToCustomerContractAssignment()
    var
        TempServiceCommitment: Record "Service Commitment" temporary;
        ServCommWOCustContractPage: TestPage "Serv. Comm. WO Cust. Contract";
    begin
        //SCENARIO: try to assign Service Commitment to wrong Contract No (different Customer No.)
        SetupServiceObjectWithServiceCommitment(false);
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
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure CheckValueChangesOnCustomerContractLines()
    var
        OldServiceCommitment: Record "Service Commitment";
        MaxServiceAmount: Decimal;
    begin
        //SCENARIO: Assign Service Commitments to Customer Contract Lines. Change values on Customer Contract Lines and check that Service Commitment has changed values.
        SetupServiceObjectWithServiceCommitment(false);
        Currency.InitRoundingPrecision();
        CreateCustomerContractSetup();

        CustomerContractPage.OpenEdit();
        CustomerContractPage.GoToRecord(CustomerContract);

        CustomerContractLine.Reset();
        CustomerContractLine.SetRange("Contract No.", CustomerContract."No.");
        CustomerContractLine.SetRange("Contract Line Type", CustomerContractLine."Contract Line Type"::"Service Commitment");
        CustomerContractLine.FindFirst();
        CustomerContractPage.Lines.GoToRecord(CustomerContractLine);

        DescriptionText := LibraryRandom.RandText(100);
        CustomerContractPage.Lines."Service Object Description".SetValue(DescriptionText);
        ServiceObject.Get(CustomerContractLine."Service Object No.");
        AssertThat.AreEqual(ServiceObject.Description, DescriptionText, 'Service Object Description not transferred from Customer Contract Line.');

        OldServiceCommitment.Get(CustomerContractLine."Service Commitment Entry No.");

        ExpectedDate := CalcDate('<-1D>', OldServiceCommitment."Service Start Date");
        CustomerContractPage.Lines."Service Start Date".SetValue(ExpectedDate);
        ServiceCommitment.Get(OldServiceCommitment."Entry No.");
        AssertThat.AreEqual(ExpectedDate, ServiceCommitment."Service Start Date", StrSubstNo('Service Commitment field "%1" not transfered from Customer Contract Line.', ServiceCommitment.FieldCaption("Service Start Date")));

        ExpectedDate := CalcDate('<1D>', WorkDate());
        CustomerContractPage.Lines."Service End Date".SetValue(ExpectedDate);
        ServiceCommitment.Get(OldServiceCommitment."Entry No.");
        AssertThat.AreEqual(ExpectedDate, ServiceCommitment."Service End Date", StrSubstNo('Service Commitment field "%1" not transfered from Customer Contract Line.', ServiceCommitment.FieldCaption("Service End Date")));

        ExpectedDecimalValue := LibraryRandom.RandDecInDecimalRange(1, 100, 2);
        while ExpectedDecimalValue = OldServiceCommitment."Discount %" do
            ExpectedDecimalValue := LibraryRandom.RandDecInDecimalRange(1, 100, 2);
        CustomerContractPage.Lines."Discount %".SetValue(ExpectedDecimalValue);
        ServiceCommitment.Get(OldServiceCommitment."Entry No.");
        AssertThat.AreEqual(ExpectedDecimalValue, ServiceCommitment."Discount %", StrSubstNo('Service Commitment field "%1" not transfered from Customer Contract Line.', ServiceCommitment.FieldCaption("Discount %")));

        MaxServiceAmount := Round((OldServiceCommitment.Price * ServiceObject."Quantity Decimal"), Currency."Amount Rounding Precision");
        ExpectedDecimalValue := LibraryRandom.RandDecInDecimalRange(1, MaxServiceAmount, 2);
        while ExpectedDecimalValue = OldServiceCommitment."Discount Amount" do
            ExpectedDecimalValue := LibraryRandom.RandDecInDecimalRange(1, MaxServiceAmount, 2);
        CustomerContractPage.Lines."Discount Amount".SetValue(ExpectedDecimalValue);
        ServiceCommitment.Get(OldServiceCommitment."Entry No.");
        AssertThat.AreEqual(ExpectedDecimalValue, ServiceCommitment."Discount Amount", StrSubstNo('Service Commitment field "%1" not transfered from Customer Contract Line.', ServiceCommitment.FieldCaption("Discount Amount")));

        ExpectedDecimalValue := LibraryRandom.RandDecInDecimalRange(1, MaxServiceAmount, 2);
        while ExpectedDecimalValue = OldServiceCommitment."Service Amount" do
            ExpectedDecimalValue := LibraryRandom.RandDecInDecimalRange(1, MaxServiceAmount, 2);
        CustomerContractPage.Lines."Service Amount".SetValue(ExpectedDecimalValue);
        ServiceCommitment.Get(OldServiceCommitment."Entry No.");
        AssertThat.AreEqual(ExpectedDecimalValue, ServiceCommitment."Service Amount", StrSubstNo('Service Commitment field "%1" not transfered from Customer Contract Line.', ServiceCommitment.FieldCaption("Service Amount")));

        ExpectedDecimalValue := LibraryRandom.RandDec(10000, 2);
        while ExpectedDecimalValue = OldServiceCommitment."Calculation Base Amount" do
            ExpectedDecimalValue := LibraryRandom.RandDec(10000, 2);
        CustomerContractPage.Lines."Calculation Base Amount".SetValue(ExpectedDecimalValue);
        ServiceCommitment.Get(OldServiceCommitment."Entry No.");
        AssertThat.AreEqual(ExpectedDecimalValue, ServiceCommitment."Calculation Base Amount", StrSubstNo('Service Commitment field "%1" not transfered from Customer Contract Line.', ServiceCommitment.FieldCaption("Calculation Base Amount")));

        ExpectedDecimalValue := LibraryRandom.RandDecInDecimalRange(1, 100, 2);
        while ExpectedDecimalValue = OldServiceCommitment."Calculation Base Amount" do
            ExpectedDecimalValue := LibraryRandom.RandDecInDecimalRange(1, 100, 2);
        CustomerContractPage.Lines."Calculation Base %".SetValue(ExpectedDecimalValue);
        ServiceCommitment.Get(OldServiceCommitment."Entry No.");
        AssertThat.AreEqual(ExpectedDecimalValue, ServiceCommitment."Calculation Base %", StrSubstNo('Service Commitment field "%1" not transfered from Customer Contract Line.', ServiceCommitment.FieldCaption("Calculation Base %")));

        DescriptionText := LibraryRandom.RandText(100);
        CustomerContractPage.Lines."Service Commitment Description".SetValue(DescriptionText);
        ServiceCommitment.Get(OldServiceCommitment."Entry No.");
        AssertThat.AreEqual(DescriptionText, ServiceCommitment.Description, StrSubstNo('Service Commitment field "%1" not transfered from Customer Contract Line.', ServiceCommitment.FieldCaption(Description)));

        Evaluate(BillingRhythmValue, '<3M>');
        CustomerContractPage.Lines."Billing Rhythm".SetValue(BillingRhythmValue);
        ServiceCommitment.Get(OldServiceCommitment."Entry No.");
        AssertThat.AreEqual(BillingRhythmValue, ServiceCommitment."Billing Rhythm", StrSubstNo('Service Commitment field "%1" not transfered from Customer Contract Line.', ServiceCommitment.FieldCaption("Billing Rhythm")));
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure CheckContractLineTypeForCommentOnCustomerContractLine()
    var
        DescriptionText2: Text;
    begin
        //SCENARIO: Create Customer Contract. Add Description and check if the ContractLineType for that line is Comment
        SetupServiceObjectWithServiceCommitment(false);
        CreateCustomerContractSetup();

        CustomerContractPage.OpenEdit();
        CustomerContractPage.GoToRecord(CustomerContract);
        DescriptionText := LibraryRandom.RandText(100);
        DescriptionText2 := LibraryRandom.RandText(100);
        while DescriptionText2 = DescriptionText do
            DescriptionText2 := LibraryRandom.RandText(100);
        CustomerContractPage.Lines.New();
        CustomerContractPage.Lines."Service Object Description".SetValue(DescriptionText);
        CustomerContractPage.Lines.New();
        CustomerContractPage.Lines."Service Commitment Description".SetValue(DescriptionText2);
        CustomerContractPage.Close();

        CustomerContractLine.SetRange("Contract No.", CustomerContract."No.");
        CustomerContractLine.SetRange("Contract Line Type", Enum::"Contract Line Type"::Comment);
        CustomerContractLine.SetRange("Service Object Description", DescriptionText);
        CustomerContractLine.FindFirst();
        AssertThat.AreEqual(Enum::"Contract Line Type"::Comment, CustomerContractLine."Contract Line Type", 'Customer Contract Line Type not set correctly for Comment.');
        CustomerContractLine.SetRange("Service Object Description");
        CustomerContractLine.SetRange("Service Commitment Description", DescriptionText2);
        CustomerContractLine.FindFirst();
        AssertThat.AreEqual(Enum::"Contract Line Type"::Comment, CustomerContractLine."Contract Line Type", 'Customer Contract Line Type not set correctly for Comment.');
    end;

    local procedure SetupServiceObjectWithServiceCommitment(SNSpecificTracking: Boolean; AddVendorServiceCommitment: Boolean)
    var
        ServiceCommitmentPackage: Record "Service Commitment Package";
        ServiceCommPackageLine: Record "Service Comm. Package Line";
        ItemServCommitmentPackage: Record "Item Serv. Commitment Package";
    begin
        ClearAll();
        ContractTestLibrary.CreateCustomer(Customer);
        ContractTestLibrary.CreateServiceObjectWithItem(ServiceObject, Item, SNSpecificTracking);
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
        ServiceCommitmentPackage.SetFilter(Code, ItemServCommitmentPackage.GetPackageFilterForItem(ServiceObject."Item No."));
        ServiceObject.InsertServiceCommitmentsFromServCommPackage(WorkDate(), ServiceCommitmentPackage);
    end;

    local procedure SetupServiceObjectWithServiceCommitment(SNSpecificTracking: Boolean)
    begin
        SetupServiceObjectWithServiceCommitment(SNSpecificTracking, false);
    end;

    local procedure SetupNewServiceObjectWithServiceCommitment(var NewServiceObject2: Record "Service Object"; SNSpecificTracking: Boolean)
    var
        OldServiceObject: Record "Service Object";
    begin
        OldServiceObject := NewServiceObject2;
        SetupServiceObjectWithServiceCommitment(SNSpecificTracking);
        NewServiceObject2 := ServiceObject;
        ServiceObject := OldServiceObject;
    end;

    local procedure CreateCustomerContractSetup()
    var
        TempServiceCommitment: Record "Service Commitment" temporary;
    begin
        ContractTestLibrary.CreateCustomerContract(CustomerContract, Customer."No.");
        ContractTestLibrary.FillTempServiceCommitment(TempServiceCommitment, ServiceObject, CustomerContract);
        CustomerContract.CreateCustomerContractLinesFromServiceCommitments(TempServiceCommitment);
    end;

    [Test]
    [HandlerFunctions('ServCommWOCustContractPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure CheckServiceCommitmentAssignmentToCustomerContractWithShipToCode()
    var
        ServiceObject2: Record "Service Object";
        ShipToAddress: Record "Ship-to Address";
    begin
        //SCENARIO: Check that proper Service Commitments are assigned to Customer Contract Lines.
        SetupServiceObjectWithServiceCommitment(false);
        SetupNewServiceObjectWithServiceCommitment(ServiceObject2, false);
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

        ServiceCommitment.Reset();
        ServiceCommitment.SetRange("Service Object No.", ServiceObject."No.");
        ServiceCommitment.SetRange("Contract No.", CustomerContract."No.");
        AssertThat.RecordIsEmpty(ServiceCommitment);
        ServiceCommitment.SetRange("Service Object No.", ServiceObject2."No.");
        AssertThat.RecordIsNotEmpty(ServiceCommitment);
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler,CreateCustomerBillingDocsContractPageHandler,SalesInvoiceListPageHandler,PostedSalesInvoicesPageHandler,SalesCreditMemosPageHandler,PostedSalesCrMemosPageHandler')]
    procedure CheckCustomerContractRelatedDocuments()
    begin
        Initialize();

        ContractTestLibrary.ResetContractRecords();
        ContractTestLibrary.CreateCustomerContractAndCreateContractLines(CustomerContract, ServiceObject, Customer."No.", true);
        ContractTestLibrary.CreateBillingProposal(BillingTemplate, Enum::"Service Partner"::Customer, WorkDate());
        BillingLine.SetRange("Billing Template Code", BillingTemplate.Code);
        BillingLine.SetRange(Partner, BillingLine.Partner::Customer);
        Codeunit.Run(Codeunit::"Create Billing Documents", BillingLine);
        //Post Sales Document
        BillingLine.FindFirst();
        SalesHeader.Get(BillingLine.GetSalesDocumentTypeFromBillingDocumentType(), BillingLine."Document No.");

        DocumentNo := SalesHeader."No.";

        CustomerContractPage.OpenView();
        CustomerContractPage.GoToRecord(CustomerContract);
        CustomerContractPage.ShowSalesInvoices.Invoke();

        PostedDocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);
        CustomerContractPage.ShowPostedSalesInvoices.Invoke();
        SalesInvoiceHeader.Get(PostedDocumentNo);

        Clear(DocumentNo);
        Clear(PostedDocumentNo);

        CorrectPostedSalesInvoice.CreateCreditMemoCopyDocument(SalesInvoiceHeader, SalesHeader);
        DocumentNo := SalesHeader."No.";
        CustomerContractPage.ShowSalesCreditMemos.Invoke();

        SalesHeader.Get(Enum::"Sales Document Type"::"Credit Memo", DocumentNo);
        PostedDocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);
        CustomerContractPage.ShowPostedSalesCreditMemos.Invoke();
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler,CreateCustomerBillingDocsContractPageHandler')]
    procedure CheckClosedCustomerContractLines()
    var
        CustomerContractLine2: Record "Customer Contract Line";
        NewServiceStartDateTok: Label '<-%1-1D>', Locked = true;
    begin
        ClearAll();
        ContractTestLibrary.ResetContractRecords();
        SetupServiceObjectWithServiceCommitment(false);
        ContractTestLibrary.CreateCustomerContractAndCreateContractLines(CustomerContract, ServiceObject, Customer."No."); //ExchangeRateSelectionModalPageHandler, MessageHandler
        ContractTestLibrary.InsertCustomerContractCommentLine(CustomerContract, CustomerContractLine2);
        ServiceCommitment.SetRange("Service Object No.", ServiceObject."No.");
        ServiceCommitment.SetRange("Contract No.", CustomerContract."No.");
        if ServiceCommitment.FindSet() then
            repeat
                ServiceCommitment."Service Start Date" := CalcDate(StrSubstNo(NewServiceStartDateTok, Format(ServiceCommitment."Billing Rhythm")), CalcDate('<-1M>', Today()));
                ServiceCommitment."Service End Date" := CalcDate('<-1D>', Today());
                ServiceCommitment."Next Billing Date" := CalcDate('<-1D>', ServiceCommitment."Service Start Date");
                ServiceCommitment.Modify(false);
            until ServiceCommitment.Next() = 0;

        // Check if closed service commitments are actually invoiced
        ContractTestLibrary.CustomerContractUpdateServicesDates(CustomerContract);
        CheckIfClosedServiceCommitmentsAreInvoiced(ServiceCommitment);

        // Invoice the contract and check closing of service commitments
        CreateAndPostBillingProposal(Today()); //CreateCustomerBillingDocsContractPageHandler
        ContractTestLibrary.CustomerContractUpdateServicesDates(CustomerContract);
        CheckIfClosedServiceCommitmentsAreInvoiced(ServiceCommitment);

        // Check if any contract lines are left open
        CustomerContractLine.SetRange("Contract No.", CustomerContract."No.");
        CustomerContractLine.SetRange("Contract Line Type", "Contract Line Type"::"Service Commitment");
        CustomerContractLine.SetRange(Closed, false);
        asserterror CustomerContractLine.FindFirst();
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure ExpectNoClosedCustomerContractLines()
    var
        CustomerContractLine2: Record "Customer Contract Line";
    begin
        SetupServiceObjectWithServiceCommitment(false);
        ContractTestLibrary.CreateCustomerContractAndCreateContractLines(CustomerContract, ServiceObject, Customer."No.");
        ContractTestLibrary.InsertCustomerContractCommentLine(CustomerContract, CustomerContractLine2);
        ServiceCommitment.SetRange("Service Object No.", ServiceObject."No.");
        ServiceCommitment.SetRange("Contract No.", CustomerContract."No.");
        if ServiceCommitment.FindSet() then
            repeat
                ServiceCommitment."Service Start Date" := CalcDate('<1D>', Today);
                ServiceCommitment."Service End Date" := CalcDate('<2D>', Today);
                ServiceCommitment.Modify(false);
            until ServiceCommitment.Next() = 0;
        CustomerContract.UpdateServicesDates();
        CustomerContractLine.SetRange("Contract No.", CustomerContract."No.");
        CustomerContractLine.SetRange("Contract Line Type", "Contract Line Type"::"Service Commitment");
        CustomerContractLine.SetRange(Closed, false);
        CustomerContractLine.FindFirst();
    end;

    [PageHandler]
    procedure SalesInvoiceListPageHandler(var SalesInvoiceList: TestPage "Sales Invoice List")
    begin
        SalesHeader.Get(Enum::"Sales Document Type"::Invoice, DocumentNo);
        SalesInvoiceList.GoToRecord(SalesHeader);
    end;

    [PageHandler]
    procedure PostedSalesInvoicesPageHandler(var PostedSalesInvoices: TestPage "Posted Sales Invoices")
    var
        SalesInvoiceHeader2: Record "Sales Invoice Header";
    begin
        SalesInvoiceHeader2.Get(PostedDocumentNo);
        PostedSalesInvoices.GoToRecord(SalesInvoiceHeader2);
    end;

    [PageHandler]
    procedure SalesCreditMemosPageHandler(var SalesCreditMemos: TestPage "Sales Credit Memos")
    begin
        SalesHeader.Get(Enum::"Sales Document Type"::"Credit Memo", DocumentNo);
        SalesCreditMemos.GoToRecord(SalesHeader);
    end;

    [PageHandler]
    procedure PostedSalesCrMemosPageHandler(var PostedSalesCreditMemos: TestPage "Posted Sales Credit Memos")
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
    begin
        SalesCrMemoHeader.Get(PostedDocumentNo);
        PostedSalesCreditMemos.GoToRecord(SalesCrMemoHeader);
    end;

    [Test]
    [HandlerFunctions('CreateCustomerBillingDocsContractPageHandler,MessageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure CheckTransferOfDetailOverviewToSalesInvoice()
    var
        i: Integer;
    begin
        ClearAll();
        for i := 0 to 2 do begin
            CreateContractWithDetailOverviewAndSalesInvoice(i);
            SalesHeader.TestField("Contract Detail Overview", CustomerContract."Detail Overview");
            PostedDocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);
            SalesInvoiceHeader.Get(PostedDocumentNo);
            SalesInvoiceHeader.TestField("Contract Detail Overview", CustomerContract."Detail Overview");
        end;
    end;

    [Test]
    [HandlerFunctions('CreateCustomerBillingDocsContractPageHandler,MessageHandler,ExchangeRateSelectionModalPageHandler')]
    procedure CheckDetailOverviewOnCreditMemoFromCancelledPostedInvoice()
    var
        i: Integer;
    begin
        ClearAll();
        for i := 0 to 2 do begin
            CreateContractWithDetailOverviewAndSalesInvoice(i);
            PostedDocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);
            SalesInvoiceHeader.Get(PostedDocumentNo);
            CorrectPostedSalesInvoice.CreateCreditMemoCopyDocument(SalesInvoiceHeader, SalesHeader);
            SalesHeader.TestField("Contract Detail Overview", CustomerContract."Detail Overview");
        end;
    end;

    [Test]
    [HandlerFunctions('CreateCustomerBillingDocsContractPageHandler,MessageHandler,ExchangeRateSelectionModalPageHandler')]
    procedure CheckDetailOverviewOnCreditMemoFromCopiedPostedInvoice()
    var
        i: Integer;
    begin
        ClearAll();
        for i := 0 to 2 do begin
            CreateContractWithDetailOverviewAndSalesInvoice(i);
            PostedDocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);
            SalesInvoiceHeader.Get(PostedDocumentNo);
            CopyDocMgt.SetProperties(true, false, false, false, true, true, false);
            Clear(SalesHeader);
            SalesHeader."Document Type" := SalesHeader."Document Type"::"Credit Memo";
            SalesHeader.Insert(true);
            CopyDocMgt.CopySalesDoc(Enum::"Sales Document Type From"::"Posted Invoice", SalesInvoiceHeader."No.", SalesHeader);
            SalesHeader.TestField("Contract Detail Overview", CustomerContract."Detail Overview");
        end;
    end;

    [Test]
    [HandlerFunctions('CreateCustomerBillingDocsSellToCustomerPageHandler,MessageHandler,ExchangeRateSelectionModalPageHandler')]
    procedure CheckCreateMultipleSalesInvoicesPerDetailOverview()
    begin
        //Contract1, Sell-to Customer1, "Detail Overview"::"Without prices"
        //Contract2, Sell-to Customer1, "Detail Overview"::Complete
        //Contract3, Sell-to Customer1, "Detail Overview"::"Without prices"
        //Contract4, Sell-to Customer1, "Detail Overview"::None
        //Contract5, Sell-to Customer1, "Detail Overview"::Complete
        // Expect 3 Sales Invoice Documents grouped per Detail Overview although is grouped by Sell-to Customer

        ClearAll();
        ContractTestLibrary.ResetContractRecords();
        ContractTestLibrary.CreateCustomer(Customer);

        CreateCustomerContractWithDetailOverview(CustomerContract."Detail Overview"::"Without prices");
        CreateCustomerContractWithDetailOverview(CustomerContract."Detail Overview"::Complete);
        CreateCustomerContractWithDetailOverview(CustomerContract."Detail Overview"::"Without prices");
        CreateCustomerContractWithDetailOverview(CustomerContract."Detail Overview"::None);
        CreateCustomerContractWithDetailOverview(CustomerContract."Detail Overview"::Complete);

        ContractTestLibrary.CreateBillingProposal(BillingTemplate, Enum::"Service Partner"::Customer);
        BillingLine.SetRange("Billing Template Code", BillingTemplate.Code);
        BillingLine.SetRange(Partner, BillingLine.Partner::Customer);
        BillingLine.SetFilter("Contract No.", ContractsFilter);
        Codeunit.Run(Codeunit::"Create Billing Documents", BillingLine);

        CountCreatedSalesDocuments();
        AssertThat.AreEqual(3, DocumentsCount, 'Sales Documents were not created correctly');
    end;

    [Test]
    [HandlerFunctions('ServCommWOCustContractPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure CheckServiceCommitmentAssignmentToCustomerContractInFCY()
    begin
        SetupServiceObjectWithServiceCommitment(false);
        ContractTestLibrary.CreateCustomerContract(CustomerContract, Customer."No.");

        CustomerContractPage.OpenEdit();
        CustomerContractPage.GoToRecord(CustomerContract);
        CustomerContractPage.GetServiceCommitmentsAction.Invoke();

        TestServiceCommitmentUpdateOnCurrencyChange(WorkDate(), CurrExchRate.ExchangeRate(WorkDate(), CustomerContract."Currency Code"), true);
    end;

    [Test]
    [HandlerFunctions('ServCommWOCustContractPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure ExpectErrorOnAssignServiceCommitmentsWithMultipleCurrencies()
    begin
        SetupServiceObjectWithServiceCommitment(false);
        ContractTestLibrary.CreateCustomerContract(CustomerContract, Customer."No.");

        ServiceCommitment.Reset();
        ServiceCommitment.SetRange("Service Object No.", ServiceObject."No.");
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
    [HandlerFunctions('ServCommWOCustContractPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure TestRecalculateServiceCommitmentsOnChangeCurrencyCode()
    begin
        SetupServiceObjectWithServiceCommitment(false);
        ContractTestLibrary.CreateCustomerContract(CustomerContract, Customer."No.");

        CustomerContractPage.OpenEdit();
        CustomerContractPage.GoToRecord(CustomerContract);
        CustomerContractPage.GetServiceCommitmentsAction.Invoke();

        Currency.Get(LibraryERM.CreateCurrencyWithRandomExchRates());
        CustomerContract.Validate("Currency Code", Currency.Code);
        CustomerContract.Modify(false);

        TestServiceCommitmentUpdateOnCurrencyChange(WorkDate(), CurrExchRate.ExchangeRate(WorkDate(), CustomerContract."Currency Code"), true);
    end;

    [Test]
    [HandlerFunctions('ServCommWOCustContractPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure TestResetServiceCommitmentsOnCurrencyCodeDelete()
    begin
        SetupServiceObjectWithServiceCommitment(false);
        ContractTestLibrary.CreateCustomerContract(CustomerContract, Customer."No.");

        CustomerContractPage.OpenEdit();
        CustomerContractPage.GoToRecord(CustomerContract);
        CustomerContractPage.GetServiceCommitmentsAction.Invoke();

        Currency.Get(LibraryERM.CreateCurrencyWithRandomExchRates());
        CustomerContract.Validate("Currency Code", '');
        CustomerContract.Modify(false);

        TestServiceCommitmentUpdateOnCurrencyChange(0D, 0, false);
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure ExpectErrorOnMergeTextLine()
    begin
        SetupNewContract(false);
        CreateContractCommentLine(500);
        CustomerContractLine.Reset();
        asserterror CustomerContractLine.MergeContractLines(CustomerContractLine);
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure ExpectErrorOnMergeContractLinesWithDifferencCustomerReference()
    begin
        ClearAll();
        ContractTestLibrary.ResetContractRecords();
        ContractTestLibrary.InitContractsApp();
        ContractTestLibrary.CreateCustomerContractAndCreateContractLines(CustomerContract, ServiceObject, '', false);
        ServiceObject."Customer Reference" := CopyStr(LibraryRandom.RandText(MaxStrLen(ServiceObject."Customer Reference")), 1, MaxStrLen(ServiceObject."Customer Reference"));
        ServiceObject.Modify(false);

        ContractTestLibrary.CreateCustomerContractAndCreateContractLines(CustomerContract, ServiceObject1, '', false);
        ServiceObject1."Customer Reference" := CopyStr(LibraryRandom.RandText(MaxStrLen(ServiceObject1."Customer Reference")), 1, MaxStrLen(ServiceObject1."Customer Reference"));
        ServiceObject1.Modify(false);

        CustomerContractLine.Reset();
        CustomerContractLine.SetRange("Contract No.", CustomerContract."No.");
        asserterror CustomerContractLine.MergeContractLines(CustomerContractLine);

    end;

    [HandlerFunctions('ConfirmHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure TestChangeOfHarmonizedBillingFieldInContractType()
    begin
        //Create CustomerContract with Harmonized billing contract type
        //Expect Harmonized billing fields in Cust. Contract to be filled after adding service commitments
        ClearAll();
        ContractTestLibrary.CreateCustomerContractWithContractType(CustomerContract, ContractType);
        ContractType.HarmonizedBillingCustContracts := true;
        ContractType.Modify(false);
        ContractTestLibrary.AssignServiceObjectToCustomerContract(CustomerContract, ServiceObject, true);
        CustomerContract.TestField("Billing Base Date");
        CustomerContract.TestField("Default Billing Rhythm");
        CustomerContract.TestField("Next Billing From");
        CustomerContract.TestField("Next Billing To");
        ContractType.Validate(HarmonizedBillingCustContracts, false);
        ContractType.Modify(false);
        //Confirmation dialog - true = expect Harmonized billing fields in CC to be cleared
        CustomerContract.Get(CustomerContract."No.");
        CustomerContract.TestField("Billing Base Date", 0D);
        AssertThat.AreNotEqual('', CustomerContract."Default Billing Rhythm", 'Default Billig Rhythm was not reset.');
        CustomerContract.TestField("Next Billing From", 0D);
        CustomerContract.TestField("Next Billing To", 0D);
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure ExpectErrorOnMergeOneCustomerContractLine()
    begin
        SetupNewContract(false);
        asserterror CustomerContractLine.MergeContractLines(CustomerContractLine);
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure ExpectErrorOnMergeCustomerContractLineWithBillingProposal()
    begin
        SetupNewContract(false);
        CreateTwoEqualServiceObjectsWithServiceCommitments();
        ContractTestLibrary.AssignServiceObjectToCustomerContract(CustomerContract, ServiceObject1, false);
        ContractTestLibrary.CreateBillingProposal(BillingTemplate, Enum::"Service Partner"::Customer);
        asserterror CustomerContractLine.MergeContractLines(CustomerContractLine);
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure ExpectErrorOnMergeCustomerContractLineWithDifferentNextBillingDate()
    begin
        SetupNewContract(false);
        CreateTwoEqualServiceObjectsWithServiceCommitments();
        ContractTestLibrary.AssignServiceObjectToCustomerContract(CustomerContract, ServiceObject1, false);
        CustomerContractLine.FindFirst();
        CustomerContractLine.GetServiceCommitment(ServiceCommitment);
        ServiceCommitment."Next Billing Date" := CalcDate('<1D>', ServiceCommitment."Next Billing Date");
        ServiceCommitment.Modify(false);
        CustomerContractLine.Reset();
        asserterror CustomerContractLine.MergeContractLines(CustomerContractLine);
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler,SelectCustomerContractLinePageHandler')]
    procedure TestMergeCustomerContractLines()
    var
        ExpectedServiceAmount: Decimal;
    begin
        SetupNewContract(false);
        CreateTwoEqualServiceObjectsWithServiceCommitments();
        ExpectedServiceAmount := GetTotalServiceAmountFromServiceCommitments();
        ContractTestLibrary.AssignServiceObjectToCustomerContract(CustomerContract, ServiceObject1, false);

        CustomerContractLine.Reset();
        CustomerContractLine.MergeContractLines(CustomerContractLine);
        CustomerContractLine.FindLast();
        TestNewServiceObject();
        ServiceCommitment.SetRange("Service Object No.", NewServiceObject."No.");
        AssertThat.AreEqual(1, ServiceCommitment.Count(), 'Service Commitments not created correctly');
        ServiceCommitment.FindFirst();
        ServiceCommitment.TestField("Service Amount", ExpectedServiceAmount);

        //Expect two closed Customer Contract Lines
        CustomerContractLine.Reset();
        CustomerContractLine.SetRange(Closed, true);
        AssertThat.AreEqual(2, CustomerContractLine.Count(), 'Merged Customer Contract lines are not closed');

        //Expect one open Customer Contract Line created from New service object
        CustomerContractLine.Reset();
        CustomerContractLine.SetRange(Closed, false);
        AssertThat.AreEqual(1, CustomerContractLine.Count(), 'Merged Customer Contract line is not created properly');
        CustomerContractLine.FindFirst();
        CustomerContractLine.TestField("Service Object No.", NewServiceObject."No.");
        CustomerContractLine.TestField("Service Commitment Entry No.");
    end;

    local procedure CreateContractCommentLine(LineNo: Integer)
    begin
        CustomerContractLine.Init();
        CustomerContractLine."Line No." := LineNo;
        CustomerContractLine."Contract No." := CustomerContract."No.";
        CustomerContractLine."Contract Line Type" := CustomerContractLine."Contract Line Type"::Comment;
        CustomerContractLine.Insert(true);
    end;

    local procedure SetupNewContract(CreateAdditionalLine: Boolean)
    begin
        ClearAll();
        ContractTestLibrary.ResetContractRecords();
        ContractTestLibrary.InitContractsApp();
        ContractTestLibrary.CreateCustomerContractAndCreateContractLines(CustomerContract, ServiceObject, '', CreateAdditionalLine);
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure ExpectNextBillingDateInCustomerContractToBeFromFirstServiceCOmmitment()
    begin
        //Create CustomerContract with Harmonized billing contract type
        //Expect Harmonized billing fields in Cust. Contract to be filled after adding service commitments
        ClearAll();
        ContractTestLibrary.CreateCustomerContractWithContractType(CustomerContract, ContractType);
        ContractType.HarmonizedBillingCustContracts := true;
        ContractType.Modify(false);
        ContractTestLibrary.AssignServiceObjectToCustomerContract(CustomerContract, ServiceObject, true);
        CustomerContract.FindEarliestServiceCommitment(ServiceCommitment, 0);
        CustomerContract.TestField("Billing Base Date", ServiceCommitment."Next Billing Date");
        CustomerContract.TestField("Default Billing Rhythm", ServiceCommitment."Billing Rhythm");
        CustomerContract.TestField("Next Billing From", ServiceCommitment."Next Billing Date");
        NextBillingTo := CalcDate(CustomerContract."Default Billing Rhythm", CustomerContract."Billing Base Date");
        NextBillingTo := CalcDate('<-1D>', NextBillingTo);
        CustomerContract.TestField("Next Billing To", NextBillingTo);
    end;

    [Test]
    procedure ExpectErrorIfBillingBaseDateIsEmptyInCustomerContractHeader()
    begin
        ClearAll();
        ContractTestLibrary.CreateCustomerContractWithContractType(CustomerContract, ContractType);
        ContractType.HarmonizedBillingCustContracts := true;
        ContractType.Modify(false);
        Evaluate(CustomerContract."Default Billing Rhythm", '2M');
        asserterror CustomerContract.Validate("Default Billing Rhythm");
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure TestCustomerContractHarmonization()
    begin
        //Create customer contract with two service commitments with different Service Start Date and Billing Rhythm
        //Expect the same Next Billing Date for both service commitments after Billing proposal
        //Expect that Next Billing to and Billing from in Contract will be recalculated
        ClearAll();
        ContractTestLibrary.ResetContractRecords();
        ContractTestLibrary.CreateCustomer(Customer);
        ContractTestLibrary.CreateCustomerContract(CustomerContract, Customer."No.");
        CreateAndAssignHarmonizationCustomerContractType();
        ContractTestLibrary.AssignServiceObjectToCustomerContract(CustomerContract, ServiceObject, true);
        ServiceCommitment.FindLast();
        ServiceCommitment.Validate("Service Start Date", CalcDate('<-1M>', ServiceCommitment."Service Start Date"));
        Evaluate(ServiceCommitment."Billing Rhythm", '2M');
        ServiceCommitment.Validate("Billing Rhythm");
        ServiceCommitment.Modify(false);
        ContractTestLibrary.CreateBillingProposal(BillingTemplate, Enum::"Service Partner"::Customer);
        TestHarmonizationForCustomerContract();
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,CreateCustomerBillingDocsContractPageHandler,MessageHandler')]
    procedure CheckTransferCustomerReferenceToSalesInvoice()
    var
        ReferenceNoLbl: Label 'Reference No.: %1', Locked = true;
    begin
        ClearAll();
        ContractTestLibrary.ResetContractRecords();
        ContractTestLibrary.CreateCustomerContractAndCreateContractLines(CustomerContract, ServiceObject, Customer."No.", true);
        CustomerReference := CopyStr(LibraryRandom.RandText(MaxStrLen(ServiceObject."Customer Reference")), 1, MaxStrLen(ServiceObject."Customer Reference"));
        ServiceObject."Customer Reference" := CopyStr(CustomerReference, 1, MaxStrLen(ServiceObject."Customer Reference"));
        ServiceObject.Modify(false);

        ContractTestLibrary.CreateBillingProposal(BillingTemplate, Enum::"Service Partner"::Customer);
        BillingLine.SetRange("Contract No.", CustomerContract."No.");
        BillingLine.SetRange("Billing Template Code", BillingTemplate.Code);
        BillingLine.SetRange(Partner, BillingLine.Partner::Customer);
        Codeunit.Run(Codeunit::"Create Billing Documents", BillingLine);
        BillingLine.FindFirst();

        SalesLine.SetRange("Document Type", Enum::"Sales Document Type"::Invoice);
        SalesLine.SetRange("Document No.", BillingLine."Document No.");
        SalesLine.SetRange(Description, StrSubstNo(ReferenceNoLbl, CustomerReference));
        AssertThat.AreNotEqual(0, SalesLine.Count(), 'Customer Reference was not created as description in Sales Invoice Lines');
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure CheckServiceObjectDescriptionInCustomerContractLines()
    begin
        ClearAll();
        ContractTestLibrary.ResetContractRecords();
        ContractTestLibrary.CreateCustomerContractAndCreateContractLines(CustomerContract, ServiceObject, Customer."No.", true);
        TestCustomerContractLinesServiceObjectDescription(CustomerContract."No.", ServiceObject.Description);

        ServiceObject.Description := CopyStr(LibraryRandom.RandText(100), 1, MaxStrLen(ServiceObject.Description));
        ServiceObject.Modify(true);
        TestCustomerContractLinesServiceObjectDescription(CustomerContract."No.", ServiceObject.Description);
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure TestEqualServiceStartDateAndNextBillingDate()
    begin
        ClearAll();
        ContractTestLibrary.ResetContractRecords();
        ContractTestLibrary.CreateCustomerContractAndCreateContractLines(CustomerContract, ServiceObject, Customer."No.", true);

        UpdateServiceStartDateFromCustomerContractSubpage();

        CustomerContractLine.GetServiceCommitment(ServiceCommitment);
        ServiceCommitment.TestField("Next Billing Date", ServiceCommitment."Service Start Date");
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure ExpectErrorOnModifyServiceStartDateWhenBillingLineExist()
    begin
        ClearAll();
        ContractTestLibrary.ResetContractRecords();
        ContractTestLibrary.CreateCustomerContractAndCreateContractLines(CustomerContract, ServiceObject, Customer."No.", true);
        ContractTestLibrary.CreateBillingProposal(BillingTemplate, Enum::"Service Partner"::Customer);

        asserterror UpdateServiceStartDateFromCustomerContractSubpage();
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler,CreateCustomerBillingDocsContractPageHandler')]
    procedure ExpectErrorOnModifyServiceStartDateWhenBillingLineArchiveExist()
    begin
        ClearAll();
        ContractTestLibrary.ResetContractRecords();
        ContractTestLibrary.CreateCustomerContractAndCreateContractLines(CustomerContract, ServiceObject, Customer."No.", true);
        CreateAndPostBillingProposal(WorkDate());

        asserterror UpdateServiceStartDateFromCustomerContractSubpage();
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure ContractLineDisconnectServiceOnTypeChange()
    begin
        // Test: Service Commitment should be disconnected from the contract when the line type changes
        ClearAll();
        SetupNewContract(false);

        CustomerContractLine.Reset();
        CustomerContractLine.SetRange("Contract No.", CustomerContract."No.");
        CustomerContractLine.SetRange("Contract Line Type", CustomerContractLine."Contract Line Type"::"Service Commitment");
        CustomerContractLine.SetFilter("Service Object No.", '<>%1', '');
        CustomerContractLine.SetFilter("Service Commitment Entry No.", '<>%1', 0);
        CustomerContractLine.FindFirst();
        asserterror CustomerContractLine.Validate("Contract Line Type", CustomerContractLine."Contract Line Type"::Comment);
    end;

    local procedure UpdateServiceStartDateFromCustomerContractSubpage()
    var
        CustomerContractSubpage: TestPage "Customer Contract Line Subp.";
        NewServiceStartDate: Date;
    begin
        CustomerContractLine.SetRange("Contract No.", CustomerContract."No.");
        CustomerContractLine.FindFirst();
        CustomerContractLine.GetServiceCommitment(ServiceCommitment);
        NewServiceStartDate := CalcDate('<1M>', ServiceCommitment."Service Start Date");

        CustomerContractSubpage.OpenEdit();
        CustomerContractSubpage.GoToRecord(CustomerContractLine);
        CustomerContractSubpage."Service Start Date".SetValue(NewServiceStartDate);
        CustomerContractSubpage.Close();
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
    procedure SelectCustomerContractLinePageHandler(var SelectCustContractLines: TestPage "Select Cust. Contract Lines")
    begin
        SelectCustContractLines.OK().Invoke();
    end;

    [MessageHandler]
    procedure MessageHandler(Message: Text[1024])
    begin
    end;

    local procedure CreateContractWithDetailOverviewAndSalesInvoice(i: Integer)
    begin
        ContractTestLibrary.ResetContractRecords();
        CreateCustomerContractWithDetailOverview(Enum::"Contract Detail Overview".FromInteger(i));
        ContractTestLibrary.CreateBillingProposal(BillingTemplate, Enum::"Service Partner"::Customer);
        BillingLine.SetRange("Contract No.", CustomerContract."No.");
        BillingLine.SetRange("Billing Template Code", BillingTemplate.Code);
        BillingLine.SetRange(Partner, BillingLine.Partner::Customer);
        Codeunit.Run(Codeunit::"Create Billing Documents", BillingLine);
        BillingLine.FindFirst();
        SalesHeader.Get(SalesHeader."Document Type"::Invoice, BillingLine."Document No.");
    end;

    local procedure CreateCustomerContractWithDetailOverview(DetailOverview: Enum "Contract Detail Overview")
    begin
        Clear(ServiceObject);
        ContractTestLibrary.CreateCustomerContractAndCreateContractLines(CustomerContract, ServiceObject, Customer."No.", true);
        CustomerContract."Detail Overview" := DetailOverview;
        CustomerContract.Modify(false);
        TextMgmt.AppendText(ContractsFilter, CustomerContract."No.", '|');
    end;

    local procedure CountCreatedSalesDocuments()
    var
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
    end;

    local procedure TestServiceCommitmentUpdateOnCurrencyChange(CurrencyFactorDate: Date; CurrencyFactor: Decimal; RecalculatePrice: Boolean)
    begin
        ServiceCommitment.SetRange("Service Object No.", ServiceObject."No.");
        ServiceCommitment.SetRange("Contract No.", CustomerContract."No.");
        ServiceCommitment.FindFirst();
        repeat
            ServiceCommitment.TestField("Currency Code", CustomerContract."Currency Code");
            ServiceCommitment.TestField("Currency Factor Date", CurrencyFactorDate);
            ServiceCommitment.TestField("Currency Factor", CurrencyFactor);

            if RecalculatePrice then begin //if currency code is changed to '', amounts and amonts in lcy in service commitments should be the same
                ServiceCommitment.TestField(Price,
                CurrExchRate.ExchangeAmtLCYToFCY(CurrencyFactorDate, Customer."Currency Code", ServiceCommitment."Price (LCY)", CurrencyFactor));

                ServiceCommitment.TestField("Service Amount",
                CurrExchRate.ExchangeAmtLCYToFCY(CurrencyFactorDate, Customer."Currency Code", ServiceCommitment."Service Amount (LCY)", CurrencyFactor));

                ServiceCommitment.TestField("Discount Amount",
                CurrExchRate.ExchangeAmtLCYToFCY(CurrencyFactorDate, Customer."Currency Code", ServiceCommitment."Discount Amount (LCY)", CurrencyFactor));
            end
            else begin
                ServiceCommitment.TestField(Price, ServiceCommitment."Price (LCY)");
                ServiceCommitment.TestField("Service Amount", ServiceCommitment."Service Amount (LCY)");
                ServiceCommitment.TestField("Discount Amount", ServiceCommitment."Discount Amount (LCY)");
            end;
        until ServiceCommitment.Next() = 0;
    end;

    local procedure CreateTwoEqualServiceObjectsWithServiceCommitments()
    begin
        ServiceObject1 := ServiceObject;
        ServiceObject1."No." := IncStr(ServiceObject."No.");
        ServiceObject1.Insert(false);
        ServiceCommitment.SetRange("Service Object No.", ServiceObject."No.");
        if ServiceCommitment.FindSet() then begin
            ServiceCommitment."Service Start Date" := CalcDate('<-2M>', Today);
            ServiceCommitment."Next Billing Date" := ServiceCommitment."Service Start Date";
            ServiceCommitment.Validate("Service Start Date");
            ServiceCommitment.Modify(false);
            repeat
                ServiceCommitment1 := ServiceCommitment;
                ServiceCommitment1."Entry No." := 0;
                ServiceCommitment1."Contract No." := '';
                ServiceCommitment1."Service Object No." := ServiceObject1."No.";
                ServiceCommitment1.Insert(false);
            until ServiceCommitment.Next() = 0;
        end;
    end;

    local procedure TestNewServiceObject()
    begin
        NewServiceObject.Get(CustomerContractLine."Service Object No.");
        NewServiceObject.TestField(Description, ServiceObject.Description);
        NewServiceObject.TestField("Item No.", ServiceObject."Item No.");
        NewServiceObject.TestField("End-User Customer No.", ServiceObject."End-User Customer No.");
        NewServiceObject.TestField("Quantity Decimal", ServiceObject."Quantity Decimal" + ServiceObject1."Quantity Decimal");
    end;

    local procedure CreateAndAssignHarmonizationCustomerContractType()
    begin
        ContractTestLibrary.CreateContractType(ContractType);
        ContractType.HarmonizedBillingCustContracts := true;
        ContractType.Modify(false);
        CustomerContract."Contract Type" := ContractType.Code;
        CustomerContract.Modify(false);
    end;

    local procedure TestHarmonizationForCustomerContract()
    begin
        BillingLine.FindLast();
        ServiceCommitment.FindSet();
        repeat
            ServiceCommitment.TestField("Next Billing Date", CalcDate('<1D>', BillingLine."Billing to"));
        until ServiceCommitment.Next() = 0;
        CustomerContract.Get(CustomerContract."No.");
        CustomerContract.TestField("Next Billing From", ServiceCommitment."Next Billing Date");
        CustomerContract.TestField("Next Billing To",
                                   CalcDate('<' + Format(CustomerContract."Default Billing Rhythm") + '-1D>', CustomerContract."Next Billing From"));
    end;

    local procedure TestCustomerContractLinesServiceObjectDescription(CustomerContractNo: Code[20]; ServiceObjectDescription: Text[100])
    begin
        CustomerContractLine.SetRange("Contract No.", CustomerContractNo);
        CustomerContractLine.FindSet();
        repeat
            CustomerContractLine.TestField("Service Object Description", ServiceObjectDescription);
        until CustomerContractLine.Next() = 0;
    end;

    local procedure GetTotalServiceAmountFromServiceCommitments(): Decimal
    begin
        ServiceCommitment.SetRange("Service Object No.", ServiceObject."No.", ServiceObject1."No.");
        ServiceCommitment.CalcSums("Service Amount");
        exit(ServiceCommitment."Service Amount");
    end;

    local procedure CreateAndPostBillingProposal(BillingDate: Date)
    begin
        ContractTestLibrary.CreateBillingProposal(BillingTemplate, Enum::"Service Partner"::Customer, BillingDate);
        BillingLine.SetRange("Billing Template Code", BillingTemplate.Code);
        BillingLine.SetRange(Partner, BillingLine.Partner::Customer);
        Codeunit.Run(Codeunit::"Create Billing Documents", BillingLine);
        //Post Sales Document
        BillingLine.FindFirst();
        SalesHeader.Get(Enum::"Sales Document Type"::Invoice, BillingLine."Document No.");
        LibrarySales.PostSalesDocument(SalesHeader, true, true);
    end;

    [ModalPageHandler]
    procedure ExchangeRateSelectionModalPageHandler(var ExchangeRateSelectionPage: TestPage "Exchange Rate Selection")
    begin
        ExchangeRateSelectionPage.OK().Invoke();
    end;

    [Test]
    procedure TestTransferOfDefaultWithoutContractDeferralsFromContractType()
    begin
        //Create CustomerContract with contract type
        //Create new Contract Type with field "Def. Without Contr. Deferrals" = true
        //Check that the field value has been transferred
        ClearAll();
        ContractTestLibrary.CreateCustomerContractWithContractType(CustomerContract, ContractType);
        CustomerContract.TestField("Without Contract Deferrals", ContractType."Def. Without Contr. Deferrals");
        ContractTestLibrary.CreateContractType(ContractType);
        ContractType."Def. Without Contr. Deferrals" := true;
        ContractType.Modify(false);
        CustomerContract.Validate("Contract Type", ContractType.Code);
        CustomerContract.Modify(false);
        CustomerContract.TestField("Without Contract Deferrals", ContractType."Def. Without Contr. Deferrals");
        //allow manually changing the value of the field
        CustomerContract.Validate("Without Contract Deferrals", false);
        CustomerContract.Modify(false);
        CustomerContract.TestField("Contract Type", ContractType.Code);
    end;

    [Test]
    procedure ExpectErrorIfBillingRhytmIsEmptyInServiceCommPackage()
    var
        ServiceCommitmentPackage: Record "Service Commitment Package";
        ServiceCommPackageLine: Record "Service Comm. Package Line";
        EmptyDateFormula: DateFormula;
    begin
        ClearAll();
        ContractTestLibrary.ResetContractRecords();
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
    procedure DeleteRelatedTranslationsWhenDeletingContractType()
    var
        FieldTranslation: Record "Field Translation";
        LanguageMgt: Codeunit Language;
    begin
        FieldTranslation.Reset();
        if not FieldTranslation.IsEmpty() then
            FieldTranslation.DeleteAll(false);
        ContractTestLibrary.CreateContractType(ContractType);
        ContractTestLibrary.CreateTranslationForField(FieldTranslation, ContractType, ContractType.FieldNo(Description), LanguageMgt.GetLanguageCode(GlobalLanguage));

        FieldTranslation.Reset();
        AssertThat.AreEqual(1, FieldTranslation.Count, 'Setup-Failure: expected exactly one translation');
        ContractType.Delete(true);
        AssertThat.AreEqual(0, FieldTranslation.Count, 'Translation has not been deleted with its master-record');
    end;

    local procedure CheckIfClosedServiceCommitmentsAreInvoiced(var SourceServiceCommitment: Record "Service Commitment")
    begin
        if SourceServiceCommitment.FindSet() then
            repeat
                if ContractTestLibrary.ServiceCommitmentIsClosed(SourceServiceCommitment) then
                    SourceServiceCommitment.TestField("Next Billing Date", CalcDate('<+1D>', SourceServiceCommitment."Service End Date"));
            until SourceServiceCommitment.Next() = 0;
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure TestDeleteServiceCommitmentLinkedToContractLineNotClosed()
    begin
        // Test: Service Commitment cannot be deleted if an open contract line exists
        ClearAll();
        ContractTestLibrary.ResetContractRecords();
        SetupServiceObjectWithServiceCommitment(false);
        ContractTestLibrary.CreateCustomerContractAndCreateContractLines(CustomerContract, ServiceObject, Customer."No."); //ExchangeRateSelectionModalPageHandler, MessageHandler

        ServiceCommitment.Reset();
        ServiceCommitment.SetRange("Service Object No.", ServiceObject."No.");
        ServiceCommitment.SetRange("Contract No.", CustomerContract."No.");
        ServiceCommitment.FindFirst();

        CustomerContractLine.Get(ServiceCommitment."Contract No.", ServiceCommitment."Contract Line No.");
        CustomerContractLine.TestField(Closed, false);
        asserterror ServiceCommitment.Delete(true);
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure TestDeleteServiceCommitmentLinkedToContractLineIsClosed()
    begin
        // Test: A closed Contract Line is deleted when deleting the Service Commitment
        ClearAll();
        ContractTestLibrary.ResetContractRecords();
        SetupServiceObjectWithServiceCommitment(false);
        ContractTestLibrary.CreateCustomerContractAndCreateContractLines(CustomerContract, ServiceObject, Customer."No."); //ExchangeRateSelectionModalPageHandler, MessageHandler

        ServiceCommitment.Reset();
        ServiceCommitment.SetRange("Service Object No.", ServiceObject."No.");
        ServiceCommitment.SetRange("Contract No.", CustomerContract."No.");
        ServiceCommitment.FindFirst();

        CustomerContractLine.Get(ServiceCommitment."Contract No.", ServiceCommitment."Contract Line No.");
        CustomerContractLine.TestField(Closed, false);
        CustomerContractLine.Closed := true;
        CustomerContractLine.Modify(false);
        ServiceCommitment.Delete(true);

        asserterror CustomerContractLine.Get(CustomerContractLine."Contract No.", CustomerContractLine."Line No.");
    end;

    [Test]
    procedure ContractCheckShipToAddressSetFromFirstServiceCommitment()
    var
        ShipToAddress: Record "Ship-to Address";
    begin
        ClearAll();
        SetupServiceObjectWithServiceCommitment(false);
        ContractTestLibrary.CreateCustomerContract(CustomerContract, Customer."No.");
        LibrarySales.CreateShipToAddress(ShipToAddress, Customer."No.");

        AssertThat.AreEqual(true, CustomerContract.IsShipToAddressEqualToServiceObjectShipToAddress(ServiceObject), 'Setup-Failure: Ship-To Address should be identical between Contract and Service Object.');
        ServiceObject.Validate("Ship-to Code", ShipToAddress.Code);
        ServiceObject."Ship-to Address" := CopyStr(LibraryRandom.RandText(MaxStrLen(ServiceObject."Ship-to Address")), 1, MaxStrLen(ServiceObject."Ship-to Address"));
        ServiceObject."Ship-to Address 2" := CopyStr(LibraryRandom.RandText(MaxStrLen(ServiceObject."Ship-to Address 2")), 1, MaxStrLen(ServiceObject."Ship-to Address 2"));
        ServiceObject.Modify(false);
        AssertThat.AreEqual(false, CustomerContract.IsShipToAddressEqualToServiceObjectShipToAddress(ServiceObject), 'Ship-To Address should NOT be returned as identical between Contract and Service Object.');

        ServiceCommitment.Reset();
        ServiceCommitment.SetRange("Service Object No.", ServiceObject."No.");
        ServiceCommitment.SetRange(Partner, ServiceCommitment.Partner::Customer);
        ServiceCommitment.FindFirst();
        ServiceCommitment.SetRecFilter();
        CustomerContract.CreateCustomerContractLineFromServiceCommitment(ServiceCommitment, CustomerContract."No.");

        CustomerContract.Get(CustomerContract."No.");
        AssertThat.AreEqual(false, CustomerContract.IsShipToAddressEqualToServiceObjectShipToAddress(ServiceObject), 'Ship-To Address should NOT be identical between Contract and Service Object after calling the first serv. comm.');
    end;

    [Test]
    procedure ExpectCustomerContractDocumentAttachmentsAreDeleted()
    var
        DocumentAttachment: Record "Document Attachment";
        i: Integer;
        RandomNoOfAttachments: Integer;
    begin
        // Service Object has Document Attachments created
        // when Service Object is deleted
        // expect that Document Attachments are deleted
        ContractTestLibrary.CreateCustomerContract(CustomerContract, '');
        CustomerContract.TestField("No.");
        RandomNoOfAttachments := LibraryRandom.RandInt(10);
        for i := 1 to RandomNoOfAttachments do
            ContractTestLibrary.InsertDocumentAttachment(Database::"Customer Contract", CustomerContract."No.");

        DocumentAttachment.SetRange("Table ID", Database::"Customer Contract");
        DocumentAttachment.SetRange("No.", CustomerContract."No.");
        AssertThat.AreEqual(RandomNoOfAttachments, DocumentAttachment.Count(), 'Actual number of Document Attachment(s) is incorrect.');

        CustomerContract.Delete(true);
        AssertThat.AreEqual(0, DocumentAttachment.Count(), 'Document Attachment(s) should be deleted.');
    end;

    procedure ContractInvoiceShowsSubtotalForServCommItem()
    var
        SessionStore: Codeunit "Session Store";
        SalesInvoice: TestPage "Sales Invoice";
    begin
        // [GIVEN] Simulated Contract Invoice with Sales Line and Item with "Service Commitment Option" = "Service Commitment Item"
        LibrarySales.CreateSalesHeader(SalesHeader, Enum::"Sales Document Type"::Invoice, '');
        SessionStore.SetBooleanKey('SkipContractSalesHeaderModifyCheck', true); // Avoid PreventChangeSalesHeader of "Document Change Management"
        SalesHeader."Recurring Billing" := true;
        SalesHeader.Modify(false);
        SessionStore.SetBooleanKey('SkipContractSalesHeaderModifyCheck', false);

        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item");
        ContractTestLibrary.UpdateItemUnitCostAndPrice(Item, LibraryRandom.RandDec(1000, 2), LibraryRandom.RandDec(1000, 2), true);

        LibrarySales.CreateSalesLineSimple(SalesLine, SalesHeader);
        SalesLine.Validate(Type, SalesLine.Type::Item);
        SalesLine.Validate("No.", Item."No.");
        SalesLine.TestField("Exclude from Doc. Total", false);
        SalesLine.Validate(Quantity, LibraryRandom.RandDec(10, 2));
        SalesLine.Modify(false);

        // [THEN] Total Amount should be filled in Sales Invoice page
        SalesLine.TestField("Line Amount");
        SalesLine.TestField("Exclude from Doc. Total", false);
        SalesInvoice.OpenView();
        SalesInvoice.GoToRecord(SalesHeader);
        AssertThat.AreNotEqual(0, SalesInvoice.SalesLines."Total Amount Excl. VAT".AsDecimal(), 'Sales Line Total in Sales Invoice should have a value');
    end;

    [Test]
    procedure SalesDocShowsNoSubtotalForServCommItem()
    var
        SalesQuote: TestPage "Sales Quote";
    begin
        // [GIVEN] Sales Document with Sales Line and Item with "Service Commitment Option" = "Service Commitment Item"
        LibrarySales.CreateSalesHeader(SalesHeader, Enum::"Sales Document Type"::Quote, '');
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item");
        ContractTestLibrary.UpdateItemUnitCostAndPrice(Item, LibraryRandom.RandDec(1000, 2), LibraryRandom.RandDec(1000, 2), true);

        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, Item."No.", LibraryRandom.RandDec(10, 2));

        // [THEN] Total Amount should NOT be filled in Sales Quote page
        SalesLine.TestField("Line Amount");
        SalesLine.TestField("Exclude from Doc. Total", true);
        SalesQuote.OpenView();
        SalesQuote.GoToRecord(SalesHeader);
        AssertThat.AreEqual(0, SalesQuote.SalesLines."Total Amount Excl. VAT".AsDecimal(), 'Sales Line Total in Sales Quote should not have a value');
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure TestCreateContractAnalysisEntries()
    var
        ContractAnalysisEntry: Record "Contract Analysis Entry";
    begin
        //[SCENARIO]: Try to create Contract Analysis Entry and test the values

        //[GIVEN]:
        SetupServiceObjectWithServiceCommitment(false, true);
        ContractTestLibrary.CreateCustomerContractAndCreateContractLines(CustomerContract, ServiceObject, Customer."No."); //ExchangeRateSelectionModalPageHandler, MessageHandler

        //[WHEN]:
        Report.Run(Report::"Create Contract Analysis");

        //THEN
        AssertThat.RecordIsNotEmpty(ContractAnalysisEntry);
        if ContractAnalysisEntry.FindSet() then
            repeat
                ServiceCommitment.Get(ContractAnalysisEntry."Service Commitment Entry No.");
                ServiceCommitment.CalcFields("Item No.", "Service Object Description", "Quantity Decimal");
                ContractAnalysisEntry.TestField("Service Object No.", ServiceCommitment."Service Object No.");
                ContractAnalysisEntry.TestField("Service Object Item No.", ServiceCommitment."Item No.");
                ContractAnalysisEntry.TestField("Service Object Description", ServiceCommitment."Service Object Description");
                ContractAnalysisEntry.TestField("Service Commitment Entry No.", ServiceCommitment."Entry No.");
                ContractAnalysisEntry.TestField("Package Code", ServiceCommitment."Package Code");
                ContractAnalysisEntry.TestField(Template, ServiceCommitment.Template);
                ContractAnalysisEntry.TestField(Description, ServiceCommitment.Description);
                ContractAnalysisEntry.TestField("Service Start Date", ServiceCommitment."Service Start Date");
                ContractAnalysisEntry.TestField("Service End Date", ServiceCommitment."Service End Date");
                ContractAnalysisEntry.TestField("Next Billing Date", ServiceCommitment."Next Billing Date");
                ContractAnalysisEntry.TestField("Calculation Base Amount", ServiceCommitment."Calculation Base Amount");
                ContractAnalysisEntry.TestField("Calculation Base %", ServiceCommitment."Calculation Base %");
                ContractAnalysisEntry.TestField("Price", ServiceCommitment."Price");
                ContractAnalysisEntry.TestField("Discount %", ServiceCommitment."Discount %");
                ContractAnalysisEntry.TestField("Discount Amount", ServiceCommitment."Discount Amount");
                ContractAnalysisEntry.TestField("Service Amount", ServiceCommitment."Service Amount");
                ContractAnalysisEntry.TestField("Analysis Date", Today());
                ContractAnalysisEntry.TestField("Billing Base Period", ServiceCommitment."Billing Base Period");
                ContractAnalysisEntry.TestField("Invoicing Item No.", ServiceCommitment."Invoicing Item No.");
                ContractAnalysisEntry.TestField(Partner, ServiceCommitment.Partner);
                ContractAnalysisEntry.TestField("Contract No.", ServiceCommitment."Contract No.");
                ContractAnalysisEntry.TestField("Contract Line No.", ServiceCommitment."Contract Line No.");
                ContractAnalysisEntry.TestField("Notice Period", ServiceCommitment."Notice Period");
                ContractAnalysisEntry.TestField("Initial Term", ServiceCommitment."Initial Term");
                ContractAnalysisEntry.TestField("Extension Term", ServiceCommitment."Extension Term");
                ContractAnalysisEntry.TestField("Billing Rhythm", ServiceCommitment."Billing Rhythm");
                ContractAnalysisEntry.TestField("Cancellation Possible Until", ServiceCommitment."Cancellation Possible Until");
                ContractAnalysisEntry.TestField("Term Until", ServiceCommitment."Term Until");
                ContractAnalysisEntry.TestField("Price (LCY)", ServiceCommitment."Price (LCY)");
                ContractAnalysisEntry.TestField("Discount Amount (LCY)", ServiceCommitment."Discount Amount (LCY)");
                ContractAnalysisEntry.TestField("Service Amount (LCY)", ServiceCommitment."Service Amount (LCY)");
                ContractAnalysisEntry.TestField("Currency Code", ServiceCommitment."Currency Code");
                ContractAnalysisEntry.TestField("Currency Factor", ServiceCommitment."Currency Factor");
                ContractAnalysisEntry.TestField("Currency Factor Date", ServiceCommitment."Currency Factor Date");
                ContractAnalysisEntry.TestField("Calculation Base Amount (LCY)", ServiceCommitment."Calculation Base Amount (LCY)");
                ContractAnalysisEntry.TestField(Discount, ServiceCommitment.Discount);
                ContractAnalysisEntry.TestField("Quantity Decimal", ServiceCommitment."Quantity Decimal");
                ContractAnalysisEntry.TestField("Renewal Term", ServiceCommitment."Renewal Term");
                ContractAnalysisEntry.TestField("Dimension Set ID", ServiceCommitment."Dimension Set ID");
            until ContractAnalysisEntry.Next() = 0;
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure TestMonthlyRecurringRevenueInContractAnalysis()
    var
        ContractAnalysisEntry: Record "Contract Analysis Entry";
        VendorContract: Record "Vendor Contract";
        BillingBasePeriodArray: Array[7] of Text;
        AmountArray: Array[7] of Decimal;
        i: Integer;
    begin
        //[SCENARIO]: Try to create Contract Analysis Entry and test the values
        //Setup multiple customer service commitments with different options
        //1. Service Amount = 1200 Billing base period = 12M; MRR = 100
        //2. Service Amount = 200 Billing base period = 2M; MRR = 100
        //3. Service Amount = 100 Billing base period = 1M; MRR = 100
        //4. Service Amount = 1200 Billing base period = 1Y; MRR = 100
        //5. Service Amount = 2400 Billing base period = 2Y; MRR = 100
        //6. Service Amount = 300 Billing base period = 1Q; MRR = 100
        //7. Service Amount = 600 Billing base period = 2Q; MRR = 100
        //Add Vendor Service Commitment with Billing base period 2Q and Service Amount = 600 Expected for Customer Service Commitment MRC = 100

        //[GIVEN]:
        ClearAll();
        ContractAnalysisEntry.Reset();
        ContractAnalysisEntry.DeleteAll();

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

        SetupServiceObjectWithCustomerServiceCommitments(BillingBasePeriodArray, AmountArray, 7);
        ContractTestLibrary.CreateCustomerContractAndCreateContractLines(CustomerContract, ServiceObject, Customer."No."); //ExchangeRateSelectionModalPageHandler, MessageHandler
        ContractTestLibrary.CreateVendorContractAndCreateContractLines(VendorContract, ServiceObject, '');

        //[WHEN]:
        Report.Run(Report::"Create Contract Analysis");

        //THEN
        ContractAnalysisEntry.SetRange("Service Object No.", ServiceObject."No.");
        AssertThat.RecordIsNotEmpty(ContractAnalysisEntry);
        ContractAnalysisEntry.FindFirst();
        for i := 1 to 7 do begin
            ContractAnalysisEntry.TestField("Monthly Recurr. Revenue (LCY)", 100);
            ContractAnalysisEntry.TestField("Monthly Recurring Cost (LCY)", 100);
            ContractAnalysisEntry.Next();
        end;
        ContractAnalysisEntry.TestField("Monthly Recurr. Revenue (LCY)", 0);
        ContractAnalysisEntry.TestField("Monthly Recurring Cost (LCY)", 100);
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure TestDailyPricesInMonthlyRecurringRevenueInContractAnalysis()
    var
        ContractAnalysisEntry: Record "Contract Analysis Entry";
        VendorContract: Record "Vendor Contract";
        BillingBasePeriodArray: Array[4] of Text;
        ExpectedResultArray: Array[4] of Decimal;
        AmountArray: Array[4] of Decimal;
        RoundedExpectedResult: Decimal;
        RoundedResult: Decimal;
        i: Integer;
    begin
        //[SCENARIO]: Try to create Contract Analysis Entry and test the values
        //Setup multiple customer service commitments with different options
        //To make the calculation clearer set the service amount to 1
        //Expected result will be Daily price * numer of days in current month regardless of Billing Base Period

        //[GIVEN]:
        ClearAll();
        ContractAnalysisEntry.Reset();
        ContractAnalysisEntry.DeleteAll();

        BillingBasePeriodArray[1] := '<1D>';
        BillingBasePeriodArray[2] := '<2D>';
        BillingBasePeriodArray[3] := '<1W>';
        BillingBasePeriodArray[4] := '<2W>';
        AmountArray[1] := 1;
        AmountArray[2] := 1;
        AmountArray[3] := 1;
        AmountArray[4] := 1;
        ExpectedResultArray[1] := 1;
        ExpectedResultArray[2] := 1 / 2;
        ExpectedResultArray[3] := 1 / 7; //1W
        ExpectedResultArray[4] := 1 / 14; //2W

        SetupServiceObjectWithCustomerServiceCommitments(BillingBasePeriodArray, AmountArray, 4);
        ContractTestLibrary.CreateCustomerContractAndCreateContractLines(CustomerContract, ServiceObject, Customer."No."); //ExchangeRateSelectionModalPageHandler, MessageHandler
        ContractTestLibrary.CreateVendorContractAndCreateContractLines(VendorContract, ServiceObject, '');

        //[WHEN]:
        Report.Run(Report::"Create Contract Analysis");

        //THEN
        Currency.InitRoundingPrecision();
        ContractAnalysisEntry.SetRange("Service Object No.", ServiceObject."No.");
        AssertThat.RecordIsNotEmpty(ContractAnalysisEntry);
        ContractAnalysisEntry.FindFirst();
        for i := 1 to 4 do begin
            RoundedResult := Round(ContractAnalysisEntry."Monthly Recurr. Revenue (LCY)", Currency."Amount Rounding Precision");
            RoundedExpectedResult := Round(ExpectedResultArray[i] * (CalcDate('<CM>', ContractAnalysisEntry."Analysis Date") - CalcDate('<-CM>', ContractAnalysisEntry."Analysis Date")), Currency."Amount Rounding Precision");
            AssertThat.AreEqual(RoundedExpectedResult, RoundedResult, 'Monthly Recurr. Revenue (LCY) was not calculated correctly');

            RoundedResult := Round(ContractAnalysisEntry."Monthly Recurring Cost (LCY)", Currency."Amount Rounding Precision");
            RoundedExpectedResult := Round(ExpectedResultArray[i] * (CalcDate('<CM>', ContractAnalysisEntry."Analysis Date") - CalcDate('<-CM>', ContractAnalysisEntry."Analysis Date")), Currency."Amount Rounding Precision");
            AssertThat.AreEqual(RoundedExpectedResult, RoundedResult, 'Monthly Recurring Cost (LCY) was not calculated correctly');
            ContractAnalysisEntry.Next();
        end;
        // Test Vendor Service Commitment in Contract Analysis Entry
        ContractAnalysisEntry.TestField("Monthly Recurr. Revenue (LCY)", 0);
        ContractAnalysisEntry.TestField("Monthly Recurring Cost (LCY)", ExpectedResultArray[i] * (CalcDate('<CM>', ContractAnalysisEntry."Analysis Date") - CalcDate('<-CM>', ContractAnalysisEntry."Analysis Date")));
    end;

    local procedure SetupServiceObjectWithCustomerServiceCommitments(BillingBasePeriodArray: array[4] of Text; AmountArray: array[4] of Decimal; NoOfRecords: Integer)
    var
        ServiceCommitmentPackage: Record "Service Commitment Package";
        ServiceCommPackageLine: Record "Service Comm. Package Line";
        ItemServCommitmentPackage: Record "Item Serv. Commitment Package";
        i: Integer;
    begin
        ContractTestLibrary.CreateCustomer(Customer);
        ContractTestLibrary.CreateServiceObjectWithItem(ServiceObject, Item, false);
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
        ServiceCommitmentPackage.SetFilter(Code, ItemServCommitmentPackage.GetPackageFilterForItem(ServiceObject."Item No."));
        ServiceObject.InsertServiceCommitmentsFromServCommPackage(WorkDate(), ServiceCommitmentPackage);
        ServiceCommitment.SetRange("Service Object No.", ServiceObject."No.");
        ServiceCommitment.FindFirst();
        for i := 1 to NoOfRecords do begin
            ServiceCommitment.Validate("Calculation Base %", 100);
            ServiceCommitment.Validate("Calculation Base Amount", AmountArray[i]);
            ServiceCommitment.Validate("Service Amount", AmountArray[i]);
            ServiceCommitment.Modify();
            ServiceCommitment.Next();
        end;
        //+1 to make sure that vendor service commitment is  updated as well with the value of the last cust. service commitment
        ServiceCommitment.Validate("Calculation Base %", 100);
        ServiceCommitment.Validate("Calculation Base Amount", AmountArray[i]);
        ServiceCommitment.Validate("Service Amount", AmountArray[i]);
        ServiceCommitment.Modify();
    end;

    local procedure Initialize()
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Contracts Test");
        ClearAll();

        if IsInitialized then
            exit;

        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"Contracts Test");
        LibraryERMCountryData.UpdatePurchasesPayablesSetup();
        LibraryERMCountryData.UpdateSalesReceivablesSetup();
        LibraryERMCountryData.UpdateGeneralLedgerSetup();
        LibraryERMCountryData.UpdateJournalTemplMandatory(false);
        IsInitialized := true;
        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"Contracts Test");
    end;
}