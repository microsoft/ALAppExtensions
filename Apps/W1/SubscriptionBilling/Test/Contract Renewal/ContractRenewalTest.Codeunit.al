namespace Microsoft.SubscriptionBilling;

using Microsoft.Utilities;
using Microsoft.Inventory.Item;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using Microsoft.Purchases.Vendor;

codeunit 139692 "Contract Renewal Test"
{
    Subtype = Test;
    TestPermissions = Disabled;
    Access = Internal;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure CheckInsertRenewalLineFromServComm()
    var
        ServiceCommitment: Record "Service Commitment";
        ContractRenewalLine: Record "Contract Renewal Line";
    begin
        // Test: Values of Contract Renewal Lines should match with their source (Service Commitments)
        Initialize();
        CreateBaseData();

        ServiceObject.TestField("No.");
        ServiceCommitment.Reset();
        ServiceCommitment.SetRange("Service Object No.", ServiceObject."No.");
        ServiceCommitment.SetRange(Partner, ServiceCommitment.Partner::Customer);
        ServiceCommitment.FindSet();
        repeat
            ContractRenewalLine.InitFromServiceCommitment(ServiceCommitment);
            ContractRenewalLine.TestField("Contract No.", ServiceCommitment."Contract No.");
            ContractRenewalLine.TestField("Contract Line No.", ServiceCommitment."Contract Line No.");
            ContractRenewalLine.TestField("Linked to Contract No.", ServiceCommitment."Contract No.");
            ContractRenewalLine.TestField("Linked to Contract Line No.", ServiceCommitment."Contract Line No.");
            ContractRenewalLine.TestField("Service Object No.", ServiceCommitment."Service Object No.");
            ContractRenewalLine.TestField("Service Commitment Entry No.", ServiceCommitment."Entry No.");
        until ServiceCommitment.Next() = 0;
    end;

    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler,SelectContractRenewalHandler')]
    [Test]
    procedure CheckNoOfCreatedRenewalLinesFromContract()
    var
        ContractRenewalLine: Record "Contract Renewal Line";
        ServiceCommitment: Record "Service Commitment";
    begin
        // Test: Check if Service Commitments (Partner Customer, Customer + Vendor) are inserted as Contract Renewal Lines
        Initialize();
        CreateBaseData();
        Commit(); // close transaction before report is called

        ServiceObject.TestField("No.");
        ServiceCommitment.Reset();
        ServiceCommitment.SetRange("Service Object No.", ServiceObject."No.");
        ServiceCommitment.SetRange(Partner, ServiceCommitment.Partner::Customer);

        AddVendorServices := false;
        CreateContractRenewalLinesFromContract();
        ContractRenewalLine.Reset();
        ContractRenewalLine.SetRange("Linked to Contract No.", CustomerContract."No.");
        Assert.AreEqual(ServiceCommitment.Count(), ContractRenewalLine.Count(), 'No. of Renewal Lines (Partner: Customer) does not match the no. of Service commitments.');

        DropContractRenewalLines();
        Commit(); // close transaction before report is called
        ServiceCommitment.SetRange(Partner);
        AddVendorServices := true;
        CreateContractRenewalLinesFromContract();
        Assert.AreEqual(ServiceCommitment.Count(), ContractRenewalLine.Count(), 'No. of Renewal Lines (Partner: Customer + Vendor) does not match the no. of Service commitments.');
    end;

    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler,SelectContractRenewalHandler')]
    [Test]
    procedure CheckAndVerifyCreateSingleSalesQuote()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesQuoteNo: Code[20];
        NoOfSalesQuotes: array[2] of Integer;
    begin
        // Test: Create a Contract Renewal Quote and verify Header & Lines
        Initialize();
        CreateBaseData();

        SalesHeader.Reset();
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Quote);
        NoOfSalesQuotes[1] := SalesHeader.Count();

        SalesQuoteNo := CreateSalesQuoteFromContract(); //SelectContractRenewalHandler

        SalesHeader.Reset();
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Quote);
        NoOfSalesQuotes[2] := SalesHeader.Count();

        Assert.AreEqual(1, NoOfSalesQuotes[2] - NoOfSalesQuotes[1], 'Expected: one Sales Quote should be created.');

        SalesHeader.Get(SalesHeader."Document Type"::Quote, SalesQuoteNo);
        SalesHeader.TestField("Sell-to Customer No.", CustomerContract."Sell-to Customer No.");
        SalesHeader.TestField("Bill-to Customer No.", CustomerContract."Bill-to Customer No.");

        FilterSalesLineOnDocumentAndServiceObject(SalesLine, SalesHeader."Document Type", SalesHeader."No.");
        SalesLine.SetAutoCalcFields("Service Commitments");
        SalesLine.FindSet();
        repeat
            TestCreateRenewalSalesLine(SalesLine);
        until SalesLine.Next() = 0;

        SalesLine.SetRange(Type, SalesLine.Type::"Service Object");
        SalesLine.FindSet();
        repeat
            SalesLine.TestField("Exclude from Doc. Total", true);
        until SalesLine.Next() = 0;
    end;

    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler,SelectContractRenewalHandler')]
    [Test]
    procedure CheckSortingInRenewalQuote()
    var
        SalesServiceCommitment: Record "Sales Service Commitment";
        SalesQuoteNo: Code[20];
    begin
        // Test: Create a Contract Renewal Quote and verify that the order if the sales lines is identical the contract lines
        Initialize();
        CreateBaseData();

        ReSortContractLines();
        SalesQuoteNo := CreateSalesQuoteFromContract();

        SalesServiceCommitment.SetRange("Document Type", "Sales Document Type"::Quote);
        SalesServiceCommitment.SetRange("Document No.", SalesQuoteNo);
        SalesServiceCommitment.SetRange(Process, Enum::Process::"Contract Renewal");
        Assert.RecordIsNotEmpty(SalesServiceCommitment);
        if SalesServiceCommitment.FindSet() then
            repeat
                SalesServiceCommitment.TestField("Linked to No.");
                SalesServiceCommitment.TestField("Linked to Line No.");
                SalesServiceCommitment.TestField(Process, Enum::Process::"Contract Renewal");
            until SalesServiceCommitment.Next() = 0;
    end;

    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler,SelectContractRenewalHandler,ConfirmHandler')]
    [Test]
    procedure CheckCreateMultipleContractRenewalQuotes()
    var
        SalesHeader: Record "Sales Header";
        ContractRenewalLine: Record "Contract Renewal Line";
        SelectContractRenewal: Report "Select Contract Renewal";
        CreateContractRenewal: Codeunit "Create Contract Renewal";
        NoOfSalesQuotes: array[2] of Integer;
    begin
        // Test: Create multiple Contract Renewal Quotes
        Initialize();
        DropContracts();

        CreateBaseData();
        CustomerContract.Reset();
        Assert.AreEqual(1, CustomerContract.Count(), 'One Contract should have been created.');

        CreateBaseData(true);
        CustomerContract.Reset();
        Assert.AreEqual(2, CustomerContract.Count(), 'Two Contracts should have been created.');

        CreateBaseData(true);
        // Commit to prevent an error "An error occurred and the transaction is stopped."
        Commit();

        CustomerContract.Reset();
        Assert.AreEqual(3, CustomerContract.Count(), 'Three Contracts should have been created.');

        SalesHeader.Reset();
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Quote);
        NoOfSalesQuotes[1] := SalesHeader.Count();

        // Create Contract Renewal Llines for all contracts
        AddVendorServices := true;
        SelectContractRenewal.Run();

        // Create Sales Orders for all Contract Renewal Lines
        ConfirmOption := false;
        ContractRenewalLine.Reset();
        CreateContractRenewal.BatchCreateContractRenewal(ContractRenewalLine);

        SalesHeader.Reset();
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Quote);
        NoOfSalesQuotes[2] := SalesHeader.Count();
        Assert.AreEqual(3, NoOfSalesQuotes[2] - NoOfSalesQuotes[1], 'Expected one Sales Quote per Contract (3)');
    end;

    [Test]
    procedure DisallowSalesQuoteToInvoiceForContractRenewal()
    var
        SalesHeader: Record "Sales Header";
    begin
        // Test: Regular conversion to Sales Invoice should be blocked
        Initialize();

        CreateFakeContractRenewalQuote(SalesHeader);
        SalesHeader.SetRecFilter();

        ConfirmOption := true;
        asserterror Codeunit.Run(Codeunit::"Sales-Quote to Invoice Yes/No", SalesHeader);
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler,SelectContractRenewalHandler')]
    procedure TestSalesQuoteToOrderYesNoForContractRenewal()
    var
        SalesHeader: Record "Sales Header";
        SalesOrderHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
    begin
        Initialize();
        CreateBaseData();
        SalesHeader.Get(SalesHeader."Document Type"::Quote, CreateSalesQuoteFromContract()); //SelectContractRenewalHandler

        Codeunit.Run(Codeunit::"Sales-Quote to Order", SalesHeader);
        FindSalesOrderFromQuote(SalesOrderHeader, SalesHeader."No.");

        FilterSalesLineOnDocumentAndServiceObject(SalesLine, SalesOrderHeader."Document Type", SalesOrderHeader."No.");
        SalesLine.SetAutoCalcFields("Service Commitments");
        SalesLine.FindSet();
        repeat
            TestCreateRenewalSalesLine(SalesLine);
        until SalesLine.Next() = 0;
    end;

    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler,SelectContractRenewalHandler')]
    [Test]
    procedure PostContractRenewalAndVerifyResult()
    var
        SalesHeader: Record "Sales Header";
        PlannedServiceCommitment: Record "Planned Service Commitment";
        ServiceCommitment: Record "Service Commitment";
        TempServiceCommitment: Record "Service Commitment" temporary;
        SalesOrderHeader: Record "Sales Header";
        LibrarySales: Codeunit "Library - Sales";
    begin
        // Test: Post a Contract Renewal Quote and verify Result
        CreateBaseData();

        SalesHeader.Get(SalesHeader."Document Type"::Quote, CreateSalesQuoteFromContract()); //SelectContractRenewalHandler
        SalesHeader.SetRecFilter();

        BufferServiceCommitments(TempServiceCommitment);
        Codeunit.Run(Codeunit::"Sales-Quote to Order", SalesHeader);
        FindSalesOrderFromQuote(SalesOrderHeader, SalesHeader."No.");
        LibrarySales.PostSalesDocument(SalesOrderHeader, true, true);

        // No. of planned commitments should be zero; Renewals should be equal to the Service commitments and update on posting
        PlannedServiceCommitment.Reset();
        PlannedServiceCommitment.SetRange("Service Object No.", ServiceObject."No.");
        Assert.AreEqual(0, PlannedServiceCommitment.Count(), 'No. of planned commitments should be zero.');

        TempContractRenewalLine.Reset();
        if TempContractRenewalLine.FindSet() then
            repeat
                TempContractRenewalLine.TestField("Service Object No.");
                TempContractRenewalLine.TestField("Service Commitment Entry No.");
                TempServiceCommitment.Get(TempContractRenewalLine."Service Commitment Entry No.");
                ServiceCommitment.Get(TempContractRenewalLine."Service Commitment Entry No.");

                // Service Date should be updated
                TempContractRenewalLine.TestField("Renewal Term");
                TempServiceCommitment.TestField("Service End Date");
                ServiceCommitment.TestField("Service End Date", CalcDate(TempContractRenewalLine."Renewal Term", TempServiceCommitment."Service End Date"));
                // Remaining values should be unchanged
                ServiceCommitment.TestField("Calculation Base Amount", TempServiceCommitment."Calculation Base Amount");
                ServiceCommitment.TestField("Calculation Base %", TempServiceCommitment."Calculation Base %");
                ServiceCommitment.TestField(Price, TempServiceCommitment.Price);
                ServiceCommitment.TestField("Discount %", TempServiceCommitment."Discount %");
                ServiceCommitment.TestField("Discount Amount", TempServiceCommitment."Discount Amount");
                ServiceCommitment.TestField("Billing Rhythm", TempServiceCommitment."Billing Rhythm");
                ServiceCommitment.TestField("Billing Base Period", TempServiceCommitment."Billing Base Period");
            until TempContractRenewalLine.Next() = 0;
        // expect that the contract is deleted
        asserterror SalesHeader.Get(SalesHeader."Document Type", SalesHeader."No.");
    end;

    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler,SelectContractRenewalHandler')]
    [Test]
    procedure PostModifiedContractRenewalWithFinalInvoiceAndVerifyResult()
    var
        SalesHeader: Record "Sales Header";
        ServiceCommitment: Record "Service Commitment";
        PlannedServiceCommitment: Record "Planned Service Commitment";
        CustomerContractLine: Record "Customer Contract Line";
        SalesOrderHeader: Record "Sales Header";
        LibrarySales: Codeunit "Library - Sales";
        BillingProposal: Codeunit "Billing Proposal";
        ReferenceDate: Date;
    begin
        // Test: Post a Contract Renewal Quote and verify Result
        CreateBaseData();

        SalesHeader.Get(SalesHeader."Document Type"::Quote, CreateSalesQuoteFromContract()); //SelectContractRenewalHandler
        SalesHeader.SetRecFilter();
        ApplyDiscountToSalesServiceCommitments(SalesHeader);

        // No. of planned commitments should be zero
        PlannedServiceCommitment.Reset();
        Assert.AreEqual(0, PlannedServiceCommitment.Count(), 'No. of planned commitments should be zero.');

        Codeunit.Run(Codeunit::"Sales-Quote to Order", SalesHeader);
        FindSalesOrderFromQuote(SalesOrderHeader, SalesHeader."No.");
        LibrarySales.PostSalesDocument(SalesOrderHeader, true, true);

        // Planned commitment(s) should be greater than zero (should not auto-update due to changed discount %)
        PlannedServiceCommitment.Reset();
        Assert.RecordIsNotEmpty(PlannedServiceCommitment);

        // Create + Post final contract invoice to update the services
        CustomerContract.TestField("No.");
        CustomerContractLine.Reset();
        CustomerContractLine.SetRange("Contract No.", CustomerContract."No.");
        CustomerContractLine.SetRange("Contract Line Type", CustomerContractLine."Contract Line Type"::"Service Commitment");
        // Find highest End Date
        ReferenceDate := 0D;
        CustomerContractLine.FindSet();
        repeat
            CustomerContractLine.TestField("Service Object No.");
            CustomerContractLine.TestField("Service Commitment Entry No.");
            PlannedServiceCommitment.Get(CustomerContractLine."Service Commitment Entry No.");
            PlannedServiceCommitment.TestField("Type Of Update", Enum::"Type Of Price Update"::"Contract Renewal");
            ServiceCommitment.Get(CustomerContractLine."Service Commitment Entry No.");
            ServiceCommitment.TestField("Service End Date");
            if ReferenceDate < ServiceCommitment."Service End Date" then
                ReferenceDate := ServiceCommitment."Service End Date";
        until CustomerContractLine.Next() = 0;
        // Create a billing proposal for the contract
        BillingProposal.CreateBillingProposalForContract(Enum::"Service Partner"::Customer, CustomerContract."No.", '', '',
                                                         ReferenceDate, // Billing Date
                                                         ReferenceDate); // Billing To Date
        // Create + post an invoice
        BillingProposal.CreateBillingDocument(Enum::"Service Partner"::Customer, CustomerContract."No.", WorkDate(), WorkDate(),
                                              true, // PostDocument
                                              false); // OpenDocument

        PlannedServiceCommitment.Reset();
        PlannedServiceCommitment.SetRange(Partner, PlannedServiceCommitment.Partner::Customer);
        Assert.AreEqual(0, PlannedServiceCommitment.Count(), 'No. of planned commitments should be zero after posting the final invoice.');
    end;

    [Test]
    procedure CheckDisallowChangesToContractRenewalQuote()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        LibraryERM: Codeunit "Library - ERM";
        SalesQuoteTestPage: TestPage "Sales Quote";
    begin
        // Test: Changes in Header & Sales Line should be disallowed
        ContractTestLibrary.CreateCustomer(Customer);
        Initialize();
        CreateFakeContractRenewalQuote(SalesHeader);
        Commit(); // retain data after asserterror

        // Check with validation from page (FieldNo must not be zero for check to work)
        SalesQuoteTestPage.OpenEdit();
        SalesQuoteTestPage.GoToRecord(SalesHeader);
        asserterror SalesQuoteTestPage."Currency Code".SetValue(LibraryERM.CreateCurrencyWithRandomExchRates());

        // Check with direct validation
        SalesHeader.Get(SalesHeader."Document Type"::Quote, SalesHeader."No.");
        asserterror SalesHeader.Validate("Sell-to Customer No.", Customer."No.");
    end;

    [Test]
    procedure CheckActionsOnSalesQuoteForRenewalQuote()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesQuoteTestPage: TestPage "Sales Quote";
    begin
        ContractTestLibrary.CreateCustomer(Customer);
        Initialize();
        CreateFakeContractRenewalQuote(SalesHeader);

        // Check status of actions "Make Order"
        SalesQuoteTestPage.OpenEdit();
        SalesQuoteTestPage.GoToRecord(SalesHeader);
        Assert.AreEqual(true, SalesQuoteTestPage.MakeOrder.Enabled(), 'The Action "Make Order" should be enabled if Contract Renewal Lines are present in a Sales Quote.');
    end;

    [Test]
    procedure CheckDisallowCopyContractRenewalQuote()
    var
        SalesHeader: Record "Sales Header";
        SalesHeader2: Record "Sales Header";
        SalesLine: Record "Sales Line";
        CopyDocMgt: Codeunit "Copy Document Mgt.";
        FromDocType: Enum "Sales Document Type From";
    begin
        // Test: Copying a Contract Renewal Quote will be allowed
        //No Service object lines will be copied
        Initialize();
        CreateFakeContractRenewalQuote(SalesHeader);

        SalesHeader2.Init();
        SalesHeader2."No." := '';
        SalesHeader2.Insert(true);

        Clear(CopyDocMgt);
        CopyDocMgt.SetProperties(true, true, false, false, false, false, false);
        CopyDocMgt.CopySalesDoc(FromDocType::Quote, SalesHeader."No.", SalesHeader2);
        FilterSalesLineOnDocumentAndServiceObject(SalesLine, SalesHeader2."Document Type", SalesHeader2."No.");
        asserterror SalesLine.FindFirst();
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler,ConfirmHandler,ContractRenewalSelectionHandler')]
    procedure CheckServCommSelectionPageAcceptChanges()
    var
        ServiceCommitment: Record "Service Commitment";
        EmptyDateFormula: DateFormula;
        RenewalTermCust: DateFormula;
        RenewalTermVend: DateFormula;
        NoOfServices: array[2] of Integer;
        CustomerContractPage: TestPage "Customer Contract";
    begin
        // Test: Renewal Term is
        // a) changeable from the Contract Renewal Action,
        // b) transferred back into the Service Commitments and
        // c) synchronized to the Vendor Service Commitment
        Initialize();
        CreateBaseData();

        ServiceCommitment.Reset();
        Assert.AreEqual(3, ServiceCommitment.Count(), 'Setup-Failure: Three Service Commitments should have been created.');
        ServiceCommitment.ModifyAll("Renewal Term", EmptyDateFormula, false); // Make sure not Renewl Term is set

        // Enter values through the page, accept the lookup; changes should Should be written back into the Service Commitments on Page Close (LookupOk)
        CustomerContract.TestField("No.");
        CustomerContractPage.OpenEdit();
        CustomerContractPage.GoToRecord(CustomerContract);
        CustomerContractPage.CreateContractRenewalQuote.Invoke();

        // Verify Results
        Clear(NoOfServices);
        ServiceCommitment.Reset();
        ServiceCommitment.FindSet();
        repeat
            ServiceCommitment.TestField("Renewal Term");
            case ServiceCommitment.Partner of
                ServiceCommitment.Partner::Customer:
                    begin
                        NoOfServices[1] += 1;
                        RenewalTermCust := ServiceCommitment."Renewal Term";
                    end;
                ServiceCommitment.Partner::Vendor:
                    begin
                        NoOfServices[2] += 1;
                        RenewalTermVend := ServiceCommitment."Renewal Term";
                    end;
                else
                    Error('Unexpected type of Partner');
            end;
        until ServiceCommitment.Next() = 0;
        Assert.AreEqual(2, NoOfServices[1], 'Setup-Failure: There should be two Service Commitments for Partner = Customer');
        Assert.AreEqual(1, NoOfServices[2], 'Setup-Failure: There should be one Service Commitment for Partner = Vendor');
        Assert.AreEqual(RenewalTermCust, RenewalTermVend, 'The Renewal-Term for the Vendor Service Commitment should be identical to the Customer Service Commitment.');
    end;

    [ModalPageHandler]
    procedure ContractRenewalSelectionHandler(var ContractRenewalSelection: TestPage "Contract Renewal Selection")
    var
        CurrentRenewalTerm: DateFormula;
        NewRenewalTerm: DateFormula;
        EmptyDateFormula: DateFormula;
    begin
        // Set a renewal Term for both Service Commitments and Add Vendor Services; close with Ok
        Evaluate(NewRenewalTerm, '<1Y>');
        ContractRenewalSelection.AddVendorServicesCtrl.SetValue(true);

        ContractRenewalSelection.First();
        Evaluate(CurrentRenewalTerm, ContractRenewalSelection.RenewalTermCtrl.Value());
        Assert.AreEqual(EmptyDateFormula, CurrentRenewalTerm, 'Service Commitment should not have a value for Renewal Term at this point.');
        ContractRenewalSelection.RenewalTermCtrl.SetValue(NewRenewalTerm);

        ContractRenewalSelection.Next();
        Evaluate(CurrentRenewalTerm, ContractRenewalSelection.RenewalTermCtrl.Value());
        Assert.AreEqual(EmptyDateFormula, CurrentRenewalTerm, 'Service Commitment should not have a value for Renewal Term at this point.');
        ContractRenewalSelection.RenewalTermCtrl.SetValue(NewRenewalTerm);

        ContractRenewalSelection.OK().Invoke();
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

    [RequestPageHandler]
    procedure SelectContractRenewalHandler(var SelectContractRenewal: TestRequestPage "Select Contract Renewal")
    begin
        SelectContractRenewal.ServiceEndDatePeriodFilterCtrl.SetValue('');
        SelectContractRenewal.AddVendorServicesCtrl.SetValue(AddVendorServices);
        SelectContractRenewal.OK().Invoke();
    end;

    [ConfirmHandler]
    procedure ConfirmHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := ConfirmOption;
    end;

    local procedure Initialize()
    begin
        ClearAll();
        ContractTestLibrary.ResetContractRecords();
        ContractTestLibrary.InitContractsApp();
    end;

    local procedure DropContracts()
    var
        CustomerContractLine: Record "Customer Contract Line";
    begin
        CustomerContract.Reset();
        if not CustomerContract.IsEmpty() then
            CustomerContract.DeleteAll(false);

        CustomerContractLine.Reset();
        if not CustomerContractLine.IsEmpty() then
            CustomerContractLine.DeleteAll(false);
    end;

    local procedure DropContractRenewalData()
    var
        SalesLine: Record "Sales Line";
        PlannedServiceCommitment: Record "Planned Service Commitment";
        SalesServiceCommitment: Record "Sales Service Commitment";
    begin
        DropContractRenewalLines();

        PlannedServiceCommitment.Reset();
        if not PlannedServiceCommitment.IsEmpty() then
            PlannedServiceCommitment.DeleteAll(true);

        SalesServiceCommitment.Reset();
        SalesServiceCommitment.SetRange("Document Type", SalesLine."Document Type"::Quote);
        if not SalesServiceCommitment.IsEmpty() then
            SalesServiceCommitment.DeleteAll(false);

        SalesLine.Reset();
        SalesLine.SetRange("Document Type", SalesLine."Document Type"::Quote);
        if not SalesLine.IsEmpty() then
            SalesLine.DeleteAll(false);

        TempContractRenewalLine.Reset();
        if not TempContractRenewalLine.IsEmpty() then
            TempContractRenewalLine.DeleteAll(false);
    end;

    local procedure DropContractRenewalLines()
    var
        ContractRenewalLine: Record "Contract Renewal Line";
    begin
        ContractRenewalLine.Reset();
        if not ContractRenewalLine.IsEmpty() then
            ContractRenewalLine.DeleteAll(true);
    end;

    local procedure CreateBaseData()
    begin
        CreateBaseData(false);
    end;

    local procedure CreateBaseData(KeepContractRenewalData: Boolean)
    begin
        CreateBaseData(KeepContractRenewalData, false, 2, 1);
    end;

    local procedure CreateBaseData(KeepContractRenewalData: Boolean; SNSpecific: Boolean; NoOfNewCustomerServCommLines: Integer; NoOfNewVendorServCommLines: Integer)
    var
        Customer: Record Customer;
        Vendor: Record Vendor;
        Item: Record Item;
        ServiceCommitment: Record "Service Commitment";
        ContractType: Record "Contract Type";
        NewInvocingVia: Enum "Invoicing Via";
    begin
        if not KeepContractRenewalData then
            DropContractRenewalData();
        Clear(CustomerContract);
        ContractTestLibrary.CreateCustomerContractWithContractType(CustomerContract, ContractType);
        // 1 Service Object, 2 Customer- & 1 Vendor-related service commitment
        Clear(ServiceObject);
        ContractTestLibrary.CreateServiceObjectWithItemAndWithServiceCommitment(ServiceObject, NewInvocingVia::Contract, SNSpecific, Item, NoOfNewCustomerServCommLines, NoOfNewVendorServCommLines);

        // Set Start- / End-Date for Services
        ServiceCommitment.Reset();
        ServiceCommitment.SetRange("Service Object No.", ServiceObject."No.");
        ServiceCommitment.FindSet();
        repeat
            ServiceCommitment."Service Start Date" := CalcDate('<-CY>', WorkDate());
            ServiceCommitment.Validate("Service End Date", CalcDate('<+CY>', WorkDate()));
            Evaluate(ServiceCommitment."Initial Term", '<1Y>');
            ServiceCommitment.Validate("Initial Term");
            ServiceCommitment.Modify(false);
        until ServiceCommitment.Next() = 0;

        // Link Service Object
        ServiceObject.SetHideValidationDialog(true);
        ServiceObject.Validate("End-User Customer No.", CustomerContract."Sell-to Customer No.");
        ServiceObject.Modify(false);
        ContractTestLibrary.AssignServiceObjectToCustomerContract(CustomerContract, ServiceObject, false); //ExchangeRateSelectionModalPageHandler, MessageHandler

        if NoOfNewVendorServCommLines > 0 then begin
            Clear(VendorContract);
            ContractTestLibrary.CreateVendorContractWithContractType(VendorContract, ContractType);
            ContractTestLibrary.AssignServiceObjectToVendorContract(VendorContract, ServiceObject, false);

            VendorContract.TestField("Buy-from Vendor No.");
            Vendor.Get(VendorContract."Buy-from Vendor No.");
            ContractTestLibrary.SetGeneralPostingSetup(Vendor."Gen. Bus. Posting Group", Item."Gen. Prod. Posting Group", false, Enum::"Service Partner"::Vendor);
        end;

        CustomerContract.TestField("Sell-to Customer No.");
        Customer.Get(CustomerContract."Sell-to Customer No.");
        ContractTestLibrary.SetGeneralPostingSetup(Customer."Gen. Bus. Posting Group", Item."Gen. Prod. Posting Group", false, Enum::"Service Partner"::Customer);
    end;

    local procedure CreateContractRenewalLinesFromContract()
    var
        CustomerContract2: Record "Customer Contract";
        SelectContractRenewal: Report "Select Contract Renewal";
    begin
        CustomerContract.TestField("No.");
        CustomerContract2.Reset();
        CustomerContract2 := CustomerContract;
        CustomerContract.SetRecFilter();
        Clear(SelectContractRenewal);
        SelectContractRenewal.SetTableView(CustomerContract);
        SelectContractRenewal.Run();
    end;

    local procedure CreateSalesQuoteFromContract(): Code[20]
    var
        ContractRenewalLine: Record "Contract Renewal Line";
        CreateContractRenewal: Codeunit "Create Contract Renewal";
    begin
        DropContractRenewalData();
        Commit(); // close transaction before report is called
        AddVendorServices := true;
        CreateContractRenewalLinesFromContract();
        CustomerContract.TestField("No.");
        ContractRenewalLine.Reset();
        ContractRenewalLine.SetRange("Linked to Contract No.", CustomerContract."No.");

        // Buffer Source lines (Contract Renewal Lines are deleted after creating the Sales Quote)
        TempContractRenewalLine.Reset();
        if not TempContractRenewalLine.IsEmpty() then
            TempContractRenewalLine.DeleteAll(false);
        if ContractRenewalLine.FindSet() then
            repeat
                TempContractRenewalLine := ContractRenewalLine;
                TempContractRenewalLine.Insert(false);
            until ContractRenewalLine.Next() = 0;

        Clear(CreateContractRenewal);
        ConfirmOption := false;
        CreateContractRenewal.Run(ContractRenewalLine);
        exit(CreateContractRenewal.GetSalesQuoteNo());
    end;

    local procedure BufferServiceCommitments(var TempServiceCommitment: Record "Service Commitment" temporary)
    var
        ServiceCommitment: Record "Service Commitment";
    begin
        TempServiceCommitment.Reset();
        if not TempServiceCommitment.IsEmpty() then
            TempServiceCommitment.DeleteAll(false);
        TempContractRenewalLine.Reset();
        if TempContractRenewalLine.FindSet() then
            repeat
                ServiceCommitment.Get(TempContractRenewalLine."Service Commitment Entry No.");
                TempServiceCommitment := ServiceCommitment;
                TempServiceCommitment.Insert(false);
            until TempContractRenewalLine.Next() = 0;
    end;

    local procedure CreateFakeContractRenewalQuote(var SalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";

        LibrarySales: Codeunit "Library - Sales";
    begin
        LibrarySales.CreateSalesQuoteForCustomerNo(SalesHeader, '');
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::"Service Object", '', 1);
    end;

    local procedure ApplyDiscountToSalesServiceCommitments(var SalesHeader: Record "Sales Header")
    var
        SalesServiceCommitment: Record "Sales Service Commitment";
        DiscountAsInt: Integer;
    begin
        SalesServiceCommitment.Reset();
        SalesServiceCommitment.SetRange("Document Type", SalesHeader."Document Type");
        SalesServiceCommitment.SetRange("Document No.", SalesHeader."No.");
        SalesServiceCommitment.FindSet(true);
        repeat
            repeat
                DiscountAsInt := LibraryRandom.RandIntInRange(1, 100);
            until DiscountAsInt <> SalesServiceCommitment."Discount %";
            SalesServiceCommitment.Validate("Discount %", DiscountAsInt);
            SalesServiceCommitment.Modify(true);
        until SalesServiceCommitment.Next() = 0;
    end;

    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler,SelectContractRenewalHandler')]
    [Test]
    procedure CheckVatCalculationForContractRenewalServiceCommitmentRhytmInReports()
    var
        NewRenewalTerm: DateFormula;
    begin
        // Test: Price in Contract Renewal Lines of Sales Quote should be calculated properly
        CreateBaseData();

        Evaluate(NewRenewalTerm, '<10D>');
        TestContractRenewalPeriodCalculation(NewRenewalTerm);
        Evaluate(NewRenewalTerm, '<1M+1D>');
        TestContractRenewalPeriodCalculation(NewRenewalTerm);
        Evaluate(NewRenewalTerm, '<7W>');
        TestContractRenewalPeriodCalculation(NewRenewalTerm);
    end;

    local procedure TestContractRenewalPeriodCalculation(NewRenewalTerm: DateFormula)
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesServiceCommitment: Record "Sales Service Commitment";
        TempSalesServiceCommitmentBuff: Record "Sales Service Commitment Buff." temporary;
        DateFormulaManagement: Codeunit "Date Formula Management";
        SalesQuoteNo: Code[20];
        PriceRatio: Decimal;
        ExpectedCalculatedLineAmount: Decimal;
        UniqueRhythmDictionary: Dictionary of [Code[20], Text];
    begin
        UpdateContractLinesWithNewRenealTerm(NewRenewalTerm);

        Clear(ContractRenewalMgt);
        SalesQuoteNo := CreateSalesQuoteFromContract();

        SalesHeader.Get(SalesHeader."Document Type"::Quote, SalesQuoteNo);
        FilterSalesLineOnDocumentAndServiceObject(SalesLine, SalesHeader."Document Type", SalesHeader."No.");
        SalesLine.FindSet();
        repeat
            SalesServiceCommitment.FilterOnSalesLine(SalesLine);
            SalesServiceCommitment.FindFirst();
            SalesServiceCommitment.TestField("Initial Term", NewRenewalTerm);
            SalesServiceCommitment.TestField("Billing Rhythm");
            PriceRatio := DateFormulaManagement.CalculateRenewalTermRatioByBillingRhythm(SalesServiceCommitment."Agreed Serv. Comm. Start Date", SalesServiceCommitment."Initial Term", SalesServiceCommitment."Billing Rhythm");
            ExpectedCalculatedLineAmount += SalesServiceCommitment."Service Amount" * PriceRatio;
        until SalesLine.Next() = 0;

        SalesServiceCommitment.CalcVATAmountLines(SalesHeader, TempSalesServiceCommitmentBuff, UniqueRhythmDictionary);
        Assert.AreEqual(UniqueRhythmDictionary.Count, TempSalesServiceCommitmentBuff.Count, 'VAT Amount Line for Contract Renewal not created properly.');
        TempSalesServiceCommitmentBuff.CalcSums("Line Amount");
        Assert.AreEqual(ExpectedCalculatedLineAmount, TempSalesServiceCommitmentBuff."Line Amount", 'Contract Renewal Sales Quote VAT Line Amount not calculated properly.');
    end;

    local procedure UpdateContractLinesWithNewRenealTerm(NewRenewalTerm: DateFormula)
    var
        CustomerContractLine: Record "Customer Contract Line";
        ServiceCommitment: Record "Service Commitment";
    begin
        // Create Customer Contract Lines and Update Renewal Term for Service Commitments
        CustomerContract.TestField("No.");
        CustomerContractLine.Reset();
        CustomerContractLine.SetRange("Contract No.", CustomerContract."No.");
        CustomerContractLine.SetRange("Contract Line Type", CustomerContractLine."Contract Line Type"::"Service Commitment");
        // Find highest End Date
        CustomerContractLine.FindSet();
        repeat
            CustomerContractLine.TestField("Service Object No.");
            CustomerContractLine.TestField("Service Commitment Entry No.");
            ServiceCommitment.Get(CustomerContractLine."Service Commitment Entry No.");
            ServiceCommitment.TestField("Service End Date");
            ServiceCommitment."Renewal Term" := NewRenewalTerm;
            ServiceCommitment.Modify(false);
        until CustomerContractLine.Next() = 0;
    end;

    local procedure ReSortContractLines()
    var
        CustomerContractLine: Record "Customer Contract Line";
        TempServiceCommitment: Record "Service Commitment" temporary;
        ServiceCommitment: Record "Service Commitment";
    begin
        // Expected: 2 Contract Lines, not bundled; delete the first and move it to the end of the contract
        CustomerContract.TestField("No.");
        CustomerContractLine.Reset();
        CustomerContractLine.SetRange("Contract No.", CustomerContract."No.");
        CustomerContractLine.FindFirst();
        CustomerContractLine.TestField("Service Object No.");
        CustomerContractLine.TestField("Service Commitment Entry No.");
        ServiceCommitment.Get(CustomerContractLine."Service Commitment Entry No.");
        CustomerContractLine.Delete(true);

        TempServiceCommitment := ServiceCommitment;
        TempServiceCommitment.Insert(false);
        CustomerContract.CreateCustomerContractLinesFromServiceCommitments(TempServiceCommitment);
    end;

    local procedure TestCreateRenewalSalesLine(SalesLine: Record "Sales Line")
    var
        CustomerContractLine: Record "Customer Contract Line";
        ServiceCommitment: Record "Service Commitment";
        SalesServiceCommitment: Record "Sales Service Commitment";
    begin
        SalesLine.TestField("No.", ServiceObject."No.");
        SalesLine.TestField("Unit of Measure Code", ServiceObject."Unit of Measure");
        SalesLine.TestField(Quantity, ServiceObject."Quantity Decimal");
        SalesLine.TestField(Description, ServiceObject.Description);
        SalesLine.TestField("Exclude from Doc. Total", true);
        SalesLine.TestField("VAT Prod. Posting Group");

        // Test that values of Contract Line get passed correctly
        SalesServiceCommitment.FilterOnSalesLine(SalesLine);
        SalesServiceCommitment.SetRange(Process, Enum::Process::"Contract Renewal");
        SalesServiceCommitment.FindFirst();
        ServiceCommitment.Get(SalesServiceCommitment."Service Commitment Entry No.");
        CustomerContractLine.Get(ServiceCommitment."Contract No.", ServiceCommitment."Contract Line No.");
        SalesLine.TestField("Unit Price", ServiceCommitment.Price);
        TempContractRenewalLine.Reset();
        TempContractRenewalLine.SetRange("Linked to Contract No.", ServiceCommitment."Contract No.");
        TempContractRenewalLine.SetRange("Linked to Contract Line No.", ServiceCommitment."Contract Line No.");
        Assert.AreEqual(TempContractRenewalLine.Count(), SalesLine."Service Commitments", 'The no. of Sales Service Commitments should match the number of Contract Renewal lines for that Service Commitment.');
    end;

    local procedure FilterSalesLineOnDocumentAndServiceObject(var SalesLine: Record "Sales Line"; DocumentType: Enum "Sales Document Type"; DocumentNo: Code[20])
    begin
        SalesLine.Reset();
        SalesLine.SetRange("Document Type", DocumentType);
        SalesLine.SetRange("Document No.", DocumentNo);
        SalesLine.SetRange(Type, SalesLine.Type::"Service Object");
    end;

    local procedure FindSalesOrderFromQuote(var SalesOrderHeader: Record "Sales Header"; QuoteNo: Code[20])
    begin
        SalesOrderHeader.SetRange("Document Type", SalesOrderHeader."Document Type"::Order);
        SalesOrderHeader.SetRange("Quote No.", QuoteNo);
        SalesOrderHeader.FindFirst();
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler,SelectContractRenewalHandler')]
    procedure CheckSerialNoDescriptionForRenewalSalesQuoteWithSNTracking()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesLine2: Record "Sales Line";
    begin
        CreateBaseData(false, true, 2, 1);

        SalesHeader.Get(SalesHeader."Document Type"::Quote, CreateSalesQuoteFromContract()); //SelectContractRenewalHandler

        FilterSalesLineOnDocumentAndServiceObject(SalesLine, SalesHeader."Document Type", SalesHeader."No.");
        SalesLine.FindFirst();

        SalesLine2.SetRange("Document Type", SalesLine."Document Type");
        SalesLine2.SetRange("Document No.", SalesLine."Document No.");
        SalesLine2.SetRange("Attached to Line No.", SalesLine."Line No.");
        SalesLine2.FindLast();
        SalesLine2.TestField(Description, ServiceObject.GetSerialNoDescription());
    end;

    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler,SelectContractRenewalHandler')]
    [Test]
    procedure CheckEndDateForRenewalTermDifferentThanSubsequentTerm()
    var
        SalesServiceCommitment: Record "Sales Service Commitment";
        ServiceCommitment: Record "Service Commitment";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesOrderHeader: Record "Sales Header";
        LibrarySales: Codeunit "Library - Sales";
        NewRenewalTerm: DateFormula;
        SalesQuoteNo: Code[20];
        OriginalServiceEndDate: Date;
        EndDateErr: Label 'The new Service End Date should be %1 + %2';
    begin
        // Test: End Date of Service Commitment should be calculated according new Renewal Term
        // Create only one service commitment with initial term 1Y and subsequent term 1Y
        CreateBaseData(false, true, 1, 0); //ExchangeRateSelectionModalPageHandler, MessageHandler

        ServiceCommitment.Reset();
        ServiceCommitment.SetRange("Service Object No.", ServiceObject."No.");
        ServiceCommitment.FindLast();
        ServiceCommitment."Extension Term" := ServiceCommitment."Initial Term";
        ServiceCommitment.Modify(false);

        OriginalServiceEndDate := ServiceCommitment."Service End Date";

        Evaluate(NewRenewalTerm, '<3M>');
        UpdateContractLinesWithNewRenealTerm(NewRenewalTerm);

        Clear(ContractRenewalMgt);
        SalesQuoteNo := CreateSalesQuoteFromContract(); //SelectContractRenewalHandler

        SalesHeader.Get(SalesHeader."Document Type"::Quote, SalesQuoteNo);
        FilterSalesLineOnDocumentAndServiceObject(SalesLine, SalesHeader."Document Type", SalesHeader."No.");
        SalesLine.FindSet();
        repeat
            SalesServiceCommitment.FilterOnSalesLine(SalesLine);
            SalesServiceCommitment.FindFirst();
            SalesServiceCommitment.TestField("Initial Term", NewRenewalTerm);
            SalesServiceCommitment.TestField("Billing Rhythm");
        until SalesLine.Next() = 0;

        Codeunit.Run(Codeunit::"Sales-Quote to Order", SalesHeader);
        FindSalesOrderFromQuote(SalesOrderHeader, SalesHeader."No.");
        LibrarySales.PostSalesDocument(SalesOrderHeader, true, true);

        ServiceCommitment.Get(ServiceCommitment."Entry No.");
        Assert.AreEqual(CalcDate(NewRenewalTerm, OriginalServiceEndDate), ServiceCommitment."Service End Date", StrSubstNo(EndDateErr, OriginalServiceEndDate, NewRenewalTerm));
    end;

    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler,SelectContractRenewalHandler')]
    [Test]
    procedure ExpectNoPostedSalesInvoiceOnPostRenewalSalesOrder()
    var
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesOrderHeader: Record "Sales Header";
        LibrarySales: Codeunit "Library - Sales";
        PostedDocumentNo: Code[20];
    begin
        CreateBaseData();
        SalesHeader.Get(SalesHeader."Document Type"::Quote, CreateSalesQuoteFromContract()); //SelectContractRenewalHandler
        SalesHeader.SetRecFilter();

        Codeunit.Run(Codeunit::"Sales-Quote to Order", SalesHeader);
        FindSalesOrderFromQuote(SalesOrderHeader, SalesHeader."No.");
        PostedDocumentNo := LibrarySales.PostSalesDocument(SalesOrderHeader, true, true);
        asserterror SalesInvoiceHeader.Get(PostedDocumentNo);
    end;

    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler,SelectContractRenewalHandler')]
    [Test]
    procedure TestPostedDocumentsOnPostRenewalSalesOrder()
    var
        SalesHeader: Record "Sales Header";
        SalesInvoiceLine: Record "Sales Invoice Line";
        SalesOrderHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        Item: Record Item;
        SalesShipmentHeader: Record "Sales Shipment Header";
        SalesShipmentLine: Record "Sales Shipment Line";
        LibrarySales: Codeunit "Library - Sales";
        PostedDocumentNo: Code[20];
    begin
        CreateBaseData();

        SalesHeader.Get(SalesHeader."Document Type"::Quote, CreateSalesQuoteFromContract()); //SelectContractRenewalHandler
        ContractTestLibrary.CreateBasicItem(Item, Enum::"Item Type"::Inventory, false);
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, "Sales Line Type"::Item, Item."No.", 1);

        SalesHeader.SetRecFilter();
        Codeunit.Run(Codeunit::"Sales-Quote to Order", SalesHeader);
        FindSalesOrderFromQuote(SalesOrderHeader, SalesHeader."No.");
        PostedDocumentNo := LibrarySales.PostSalesDocument(SalesOrderHeader, true, true);

        SalesInvoiceLine.SetRange("Document No.", PostedDocumentNo);
        SalesInvoiceLine.SetRange(Type, "Sales Line Type"::Item, "Sales Line Type"::"Service Object");
        Assert.RecordCount(SalesInvoiceLine, 1);

        SalesShipmentHeader.SetRange("Order No.", SalesOrderHeader."No.");
        SalesShipmentHeader.FindFirst();
        SalesShipmentLine.SetRange("Document No.", SalesShipmentHeader."No.");
        SalesInvoiceLine.SetRange(Type, "Sales Line Type"::Item, "Sales Line Type"::"Service Object");
        Assert.RecordCount(SalesInvoiceLine, 1);
    end;

    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler,SelectContractRenewalHandler')]
    [Test]
    procedure ExpectErrorOnChangeQtyToShip()
    var
        SalesHeader: Record "Sales Header";
        SalesOrderHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
    begin
        CreateBaseData();

        SalesHeader.Get(SalesHeader."Document Type"::Quote, CreateSalesQuoteFromContract()); //SelectContractRenewalHandler
        SalesHeader.SetRecFilter();
        Codeunit.Run(Codeunit::"Sales-Quote to Order", SalesHeader);
        FindSalesOrderFromQuote(SalesOrderHeader, SalesHeader."No.");

        SalesLine.SetRange("Document Type", SalesOrderHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesOrderHeader."No.");
        SalesLine.SetRange(Type, "Sales Line Type"::"Service Object");
        SalesLine.FindFirst();

        asserterror SalesLine.Validate("Qty. to Ship", SalesLine.Quantity / 2);
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler,TestContractRenewalSelectionModalPageHandler,ServiceObjectModalPageHandler')]
    procedure TestIfContractRenewalSelectionIsUpdateOnAfterValidateCalcBasePerc()
    begin
        //GIVEN We Create all the needed data
        ClearAll();
        CreateBaseData();
        BaseCalculationPctg := LibraryRandom.RandDecInDecimalRange(80, 100, 2);
        CalculationBaseAmount := LibraryRandom.RandDecInDecimalRange(80, 100, 2);
        //WHEN We run the action Contract Renewal Quote and change the values on service object, values are tested in a ContractRenewalSelectionModalPageHandler
        ContractRenewalMgt.StartContractRenewalFromContract(CustomerContract);
    end;

    [ModalPageHandler]
    procedure TestContractRenewalSelectionModalPageHandler(var ContractRenewalSelection: TestPage "Contract Renewal Selection")
    begin
        ContractRenewalSelection."Service Object Description".AssistEdit();
        //THEN We check if the amounts are updated
        Assert.AreEqual(ContractRenewalSelection."Calculation Base %".AsDecimal(), BaseCalculationPctg, 'Calculation Base % has not been updated');
        Assert.AreEqual(ContractRenewalSelection."Calculation Base Amount".AsDecimal(), CalculationBaseAmount, 'Calculation Base Amount has not been updated');
    end;

    [ModalPageHandler]
    procedure ServiceObjectModalPageHandler(var ServiceObjectTestPage: TestPage "Service Object")
    begin
        if not ServiceObjectTestPage.Editable then
            ServiceObjectTestPage.Edit().Invoke();
        ServiceObjectTestPage.Services."Calculation Base %".SetValue(BaseCalculationPctg);
        ServiceObjectTestPage.Services."Calculation Base Amount".SetValue(CalculationBaseAmount);
    end;

    var
        CustomerContract: Record "Customer Contract";
        VendorContract: Record "Vendor Contract";
        ServiceObject: Record "Service Object";
        TempContractRenewalLine: Record "Contract Renewal Line" temporary;
        ContractTestLibrary: Codeunit "Contract Test Library";
        Assert: Codeunit Assert;
        ContractRenewalMgt: Codeunit "Contract Renewal Mgt.";
        LibraryRandom: Codeunit "Library - Random";
        AddVendorServices: Boolean;
        ConfirmOption: Boolean;
        BaseCalculationPctg: Decimal;
        CalculationBaseAmount: Decimal;
}