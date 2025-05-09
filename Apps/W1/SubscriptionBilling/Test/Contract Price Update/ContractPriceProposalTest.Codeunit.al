namespace Microsoft.SubscriptionBilling;

using Microsoft.Inventory.Item;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using Microsoft.Purchases.Vendor;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Finance.Currency;
using System.TestLibraries.Utilities;

codeunit 139690 "Contract Price Proposal Test"
{
    Subtype = Test;
    TestPermissions = Disabled;
    Access = Internal;

    var
        BillingLine: Record "Billing Line";
        BillingTemplate: Record "Billing Template";
        ContractPriceUpdateLine: Record "Sub. Contr. Price Update Line";
        TempContractPriceUpdateLine: Record "Sub. Contr. Price Update Line" temporary;
        Currency: Record Currency;
        Customer: Record Customer;
        Customer2: Record Customer;
        Item: Record Item;
        PriceUpdateTemplateCustomer: Record "Price Update Template";
        PriceUpdateTemplateVendor: Record "Price Update Template";
        ServiceCommPackageLine: Record "Subscription Package Line";
        ServiceCommitment: Record "Subscription Line";
        ServiceCommitmentPackage: Record "Subscription Package";
        ServiceCommitmentTemplate: Record "Sub. Package Line Template";
        ServiceObject: Record "Subscription Header";
        Vendor: Record Vendor;
        Vendor2: Record Vendor;
        Assert: Codeunit Assert;
        ContractTestLibrary: Codeunit "Contract Test Library";
        LibraryERMCountryData: Codeunit "Library - ERM Country Data";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryRandom: Codeunit "Library - Random";
        LibrarySales: Codeunit "Library - Sales";
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        PriceUpdateManagement: Codeunit "Price Update Management";
        IsInitialized: Boolean;

    #region Tests

    [Test]
    procedure CreateContractPriceUpdateProposalCalculationBaseByPercentage()
    var
        CalcDiscountAmount: Decimal;
        NewDiscountAmount: Decimal;
        NewServiceAmount: Decimal;
    begin
        Initialize();

        CreateContractPriceUpdateProposalForCustomerServiceCommitments("Price Update Method"::"Calculation Base by %", WorkDate(), '<12M>', '<1M>', LibraryRandom.RandDec(100, 2), '<12M>', '<12M>', '<12M>');
        Currency.InitRoundingPrecision();
        ContractPriceUpdateLine.SetRange("Price Update Template Code", PriceUpdateTemplateCustomer.Code);
        ContractPriceUpdateLine.FindSet();
        repeat
            ServiceCommitment.Get(ContractPriceUpdateLine."Subscription Line Entry No.");
            ContractPriceUpdateLine.TestField("Old Price", ServiceCommitment.Price);
            ContractPriceUpdateLine.TestField("Old Calculation Base", ServiceCommitment."Calculation Base Amount");
            ContractPriceUpdateLine.TestField("Old Calculation Base %", ServiceCommitment."Calculation Base %");
            ContractPriceUpdateLine.TestField("Old Amount", ServiceCommitment.Amount);

            ContractPriceUpdateLine.TestField("New Calculation Base %", PriceUpdateTemplateCustomer."Update Value %");
            ContractPriceUpdateLine.TestField("New Calculation Base", ContractPriceUpdateLine."Old Calculation Base");
            Assert.AreNearlyEqual(Round(ContractPriceUpdateLine."New Calculation Base" * ContractPriceUpdateLine."New Calculation Base %" / 100, Currency."Unit-Amount Rounding Precision"), ContractPriceUpdateLine."New Price", 0.01, 'New  Price was not calculated properly');
            ContractPriceUpdateLine.TestField("Additional Amount", ContractPriceUpdateLine."New Amount" - ContractPriceUpdateLine."Old Amount");

            // The rounding was applied in the test for stability, as the calculations were performed at different locations
            NewServiceAmount := Round(ContractPriceUpdateLine."New Price" * ContractPriceUpdateLine.Quantity, Currency."Amount Rounding Precision");
            NewDiscountAmount := Round(ContractPriceUpdateLine."Discount %" * NewServiceAmount / 100, Currency."Amount Rounding Precision");
            CalcDiscountAmount := Round(ContractPriceUpdateLine."Discount Amount", Currency."Amount Rounding Precision");
            Assert.AreEqual(CalcDiscountAmount, NewDiscountAmount, 'Discount Amount was not calculated properly');

            NewServiceAmount := Round((ContractPriceUpdateLine."New Price" * ContractPriceUpdateLine.Quantity), Currency."Amount Rounding Precision");
            NewServiceAmount := NewServiceAmount - NewDiscountAmount;
            Assert.AreEqual(NewServiceAmount, ContractPriceUpdateLine."New Amount", 'New Service Amount was not calculated properly');
        until ContractPriceUpdateLine.Next() = 0;
    end;

    [Test]
    procedure CreateContractPriceUpdateProposalPriceByPercentage()
    var
        CalcDiscountAmount: Decimal;
        NewDiscountAmount: Decimal;
        NewServiceAmount: Decimal;
    begin
        Initialize();

        CreateContractPriceUpdateProposalForCustomerServiceCommitments("Price Update Method"::"Price by %", WorkDate(), '<12M>', '<1M>', LibraryRandom.RandDec(100, 2), '<12M>', '<12M>', '<12M>');
        Currency.InitRoundingPrecision();
        ContractPriceUpdateLine.SetRange("Price Update Template Code", PriceUpdateTemplateCustomer.Code);
        ContractPriceUpdateLine.FindSet();
        repeat
            ServiceCommitment.Get(ContractPriceUpdateLine."Subscription Line Entry No.");
            ContractPriceUpdateLine.TestField("Old Price", ServiceCommitment.Price);
            ContractPriceUpdateLine.TestField("Old Calculation Base", ServiceCommitment."Calculation Base Amount");
            ContractPriceUpdateLine.TestField("Old Calculation Base %", ServiceCommitment."Calculation Base %");
            ContractPriceUpdateLine.TestField("Old Amount", ServiceCommitment.Amount);

            ContractPriceUpdateLine.TestField("New Calculation Base %", ContractPriceUpdateLine."Old Calculation Base %");
            ContractPriceUpdateLine.TestField("New Calculation Base", Round(ContractPriceUpdateLine."Old Calculation Base" + ContractPriceUpdateLine."Old Calculation Base" * PriceUpdateTemplateCustomer."Update Value %" / 100, Currency."Amount Rounding Precision"));
            ContractPriceUpdateLine.TestField("New Price", Round(ContractPriceUpdateLine."Old Price" + ContractPriceUpdateLine."Old Price" * PriceUpdateTemplateCustomer."Update Value %" / 100, Currency."Unit-Amount Rounding Precision"));
            ContractPriceUpdateLine.TestField("Additional Amount", ContractPriceUpdateLine."New Amount" - ContractPriceUpdateLine."Old Amount");

            // The rounding was applied in the test for stability, as the calculations were performed at different locations
            NewServiceAmount := Round(ContractPriceUpdateLine."New Price" * ContractPriceUpdateLine.Quantity, Currency."Amount Rounding Precision");
            NewDiscountAmount := Round(ContractPriceUpdateLine."Discount %" * NewServiceAmount / 100, Currency."Amount Rounding Precision");
            CalcDiscountAmount := Round(ContractPriceUpdateLine."Discount Amount", Currency."Amount Rounding Precision");
            Assert.AreEqual(CalcDiscountAmount, NewDiscountAmount, 'Discount Amount was not calculated properly');

            NewServiceAmount := NewServiceAmount - NewDiscountAmount;
            Assert.AreEqual(NewServiceAmount, ContractPriceUpdateLine."New Amount", '"New Service Amount" was not calculated properly');
        until ContractPriceUpdateLine.Next() = 0;
    end;

    [Test]
    procedure CreateContractPriceUpdateProposalRecentItemPrices()
    var
        CalcDiscountAmount: Decimal;
        NewDiscountAmount: Decimal;
        NewServiceAmount: Decimal;
    begin
        Initialize();

        CreateContractPriceUpdateProposalForCustomerServiceCommitments("Price Update Method"::"Recent Item Prices", WorkDate(), '<12M>', '<1M>', 0, '<12M>', '<12M>', '<12M>');

        ContractPriceUpdateLine.SetRange("Price Update Template Code", PriceUpdateTemplateCustomer.Code);
        ContractPriceUpdateLine.FindSet();
        repeat
            ServiceCommitment.Get(ContractPriceUpdateLine."Subscription Line Entry No.");
            ContractPriceUpdateLine.TestField("Old Price", ServiceCommitment.Price);
            ContractPriceUpdateLine.TestField("Old Calculation Base", ServiceCommitment."Calculation Base Amount");
            ContractPriceUpdateLine.TestField("Old Calculation Base %", ServiceCommitment."Calculation Base %");
            ContractPriceUpdateLine.TestField("Old Amount", ServiceCommitment.Amount);

            ContractPriceUpdateLine.TestField("New Calculation Base %", ContractPriceUpdateLine."Old Calculation Base %");
            ContractPriceUpdateLine.TestField("New Price", Round(ContractPriceUpdateLine."New Calculation Base" * ContractPriceUpdateLine."New Calculation Base %" / 100, Currency."Unit-Amount Rounding Precision"));
            ContractPriceUpdateLine.TestField("Additional Amount", ContractPriceUpdateLine."New Amount" - ContractPriceUpdateLine."Old Amount");

            // The rounding was applied in the test for stability, as the calculations were performed at different locations
            NewServiceAmount := Round(ContractPriceUpdateLine."New Price" * ContractPriceUpdateLine.Quantity, Currency."Amount Rounding Precision");
            NewDiscountAmount := Round(ContractPriceUpdateLine."Discount %" * NewServiceAmount / 100, Currency."Amount Rounding Precision");
            CalcDiscountAmount := Round(ContractPriceUpdateLine."Discount Amount", Currency."Amount Rounding Precision");
            Assert.AreEqual(CalcDiscountAmount, NewDiscountAmount, 'Discount Amount was not calculated properly');

            NewServiceAmount := Round((ContractPriceUpdateLine."New Price" * ContractPriceUpdateLine.Quantity), Currency."Amount Rounding Precision");
            NewServiceAmount := NewServiceAmount - NewDiscountAmount;
            Assert.AreEqual(NewServiceAmount, ContractPriceUpdateLine."New Amount", '"New Service Amount" was not calculated properly');
        until ContractPriceUpdateLine.Next() = 0;
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure CheckContractPriceUpdatePageGroupingLines()
    var
        CustomerContract: Record "Customer Subscription Contract";
        CustomerContract2: Record "Customer Subscription Contract";
    begin
        Initialize();

        CreateCustomerContractPriceUpdateFromMultipleContracts(CustomerContract, CustomerContract2);
        PriceUpdateManagement.InitTempTable(TempContractPriceUpdateLine, Enum::"Contract Billing Grouping"::None);
        TempContractPriceUpdateLine.SetRange(Indent, 0);
        Assert.IsTrue(TempContractPriceUpdateLine.IsEmpty(), 'Grouping Line should not be found.');

        PriceUpdateManagement.InitTempTable(TempContractPriceUpdateLine, Enum::"Contract Billing Grouping"::Contract);
        TempContractPriceUpdateLine.SetFilter("Subscription Contract No.", '%1|%2', CustomerContract."No.", CustomerContract2."No.");
        TempContractPriceUpdateLine.FindFirst();
        Assert.AreEqual(CustomerContract."No.", TempContractPriceUpdateLine."Subscription Contract No.", 'Contract No. is not set correctly in grouping line (Group by Contract).');
        Assert.AreEqual(Customer."No.", TempContractPriceUpdateLine."Partner No.", 'Partner No. is not set correctly in grouping line (Group by Contract).');

        TempContractPriceUpdateLine.Next();
        Assert.AreEqual(CustomerContract2."No.", TempContractPriceUpdateLine."Subscription Contract No.", 'Contract No. is not set correctly in grouping line (Group by Contract).');
        Assert.AreEqual(Customer2."No.", TempContractPriceUpdateLine."Partner No.", 'Partner No. is not set correctly in grouping line (Group by Contract).');

        TempContractPriceUpdateLine.SetRange("Subscription Contract No.");
        PriceUpdateManagement.InitTempTable(TempContractPriceUpdateLine, Enum::"Contract Billing Grouping"::"Contract Partner");
        TempContractPriceUpdateLine.SetFilter("Partner No.", '%1|%2', Customer."No.", Customer2."No.");
        TempContractPriceUpdateLine.FindFirst();
        Assert.AreEqual('', TempContractPriceUpdateLine."Subscription Contract No.", 'Contract No. is not set correctly in grouping line (Group by "Contract Partner").');
        Assert.AreEqual(Customer."No.", TempContractPriceUpdateLine."Partner No.", 'Partner No. is not set correctly in grouping line (Group by "Contract Partner").');

        TempContractPriceUpdateLine.Next();
        Assert.AreEqual('', TempContractPriceUpdateLine."Subscription Contract No.", 'Contract No. is not set correctly in grouping line (Group by "Contract Partner").');
        Assert.AreEqual(Customer2."No.", TempContractPriceUpdateLine."Partner No.", 'Partner No. is not set correctly in grouping line (Group by "Contract Partner").');
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure CheckRecurringBillingPageGroupingLinesForVendor()
    var
        VendorContract: Record "Vendor Subscription Contract";
        VendorContract2: Record "Vendor Subscription Contract";
    begin
        Initialize();

        CreateVendorContractPriceUpdateFromMultipleContracts(VendorContract, VendorContract2);
        PriceUpdateManagement.InitTempTable(TempContractPriceUpdateLine, Enum::"Contract Billing Grouping"::None);
        TempContractPriceUpdateLine.SetRange(Indent, 0);
        Assert.IsTrue(TempContractPriceUpdateLine.IsEmpty(), 'Grouping Line should not be found.');

        PriceUpdateManagement.InitTempTable(TempContractPriceUpdateLine, Enum::"Contract Billing Grouping"::Contract);

        TempContractPriceUpdateLine.SetFilter("Subscription Contract No.", '%1|%2', VendorContract."No.", VendorContract2."No.");
        TempContractPriceUpdateLine.FindFirst();
        Assert.AreEqual(VendorContract."No.", TempContractPriceUpdateLine."Subscription Contract No.", 'Contract No. is not set correctly in grouping line (Group by Contract).');
        Assert.AreEqual(Vendor."No.", TempContractPriceUpdateLine."Partner No.", 'Partner No. is not set correctly in grouping line (Group by Contract).');

        TempContractPriceUpdateLine.Next();
        Assert.AreEqual(VendorContract2."No.", TempContractPriceUpdateLine."Subscription Contract No.", 'Contract No. is not set correctly in grouping line (Group by Contract).');
        Assert.AreEqual(Vendor2."No.", TempContractPriceUpdateLine."Partner No.", 'Partner No. is not set correctly in grouping line (Group by Contract).');

        TempContractPriceUpdateLine.SetRange("Subscription Contract No.");
        PriceUpdateManagement.InitTempTable(TempContractPriceUpdateLine, Enum::"Contract Billing Grouping"::"Contract Partner");
        TempContractPriceUpdateLine.SetFilter("Partner No.", '%1|%2', Vendor."No.", Vendor2."No.");
        TempContractPriceUpdateLine.FindFirst();
        Assert.AreEqual('', TempContractPriceUpdateLine."Subscription Contract No.", 'Contract No. is not set correctly in grouping line (Group by "Contract Partner").');
        Assert.AreEqual(Vendor."No.", TempContractPriceUpdateLine."Partner No.", 'Partner No. is not set correctly in grouping line (Group by "Contract Partner").');

        TempContractPriceUpdateLine.Next();
        Assert.AreEqual('', TempContractPriceUpdateLine."Subscription Contract No.", 'Contract No. is not set correctly in grouping line (Group by "Contract Partner").');
        Assert.AreEqual(Vendor2."No.", TempContractPriceUpdateLine."Partner No.", 'Partner No. is not set correctly in grouping line (Group by "Contract Partner").');
    end;

    [Test]
    [HandlerFunctions('CreateCustomerBillingDocsContractPageHandler,MessageHandler,ExchangeRateSelectionModalPageHandler')]
    procedure TestCancelPostedSalesInvoiceWithContractPriceUpdate()
    var
        CustomerContract: Record "Customer Subscription Contract";
        PlannedServiceCommitment: Record "Planned Subscription Line";
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        OldServiceCommitment: Record "Subscription Line";
        ServiceCommitmentArchive: Record "Subscription Line Archive";
        CorrectPostedSalesInvoice: Codeunit "Correct Posted Sales Invoice";
    begin
        Initialize();

        CreateContractPriceUpdateProposalForCustomerServiceCommitments("Price Update Method"::"Calculation Base by %", CalcDate('<1M>', WorkDate()), '<12M>', '<12M>', 50, '<12M>', '<24M>', '<12M>');

        ContractPriceUpdateLine.Reset();
        ContractPriceUpdateLine.FindLast();

        Commit(); // Commit before processing
        PriceUpdateManagement.PerformPriceUpdate();
        Commit(); // Commit after processing

        ServiceCommitment.Get(ContractPriceUpdateLine."Subscription Line Entry No.");
        ServiceCommitment.CalcFields("Planned Sub. Line exists");
        Assert.IsTrue(ServiceCommitment."Planned Sub. Line exists", 'Planned Service Commitment was not created on Process Price Update.');

        PlannedServiceCommitment.Get(ContractPriceUpdateLine."Subscription Line Entry No.");
        ContractTestLibrary.CreateCustomerContractAndCreateContractLinesForItems(CustomerContract, ServiceObject, ServiceObject."End-User Customer No.");
        CreateAndPostSalesBillingDocuments(SalesHeader, SalesInvoiceHeader);
        Commit(); // retain data after asserterror

        ServiceCommitmentArchive.SetRange("Subscription Header No.", ServiceCommitment."Subscription Header No.");
        ServiceCommitmentArchive.SetRange("Original Entry No.", ServiceCommitment."Entry No.");
        ServiceCommitmentArchive.FindLast();
        OldServiceCommitment.Get(ContractPriceUpdateLine."Subscription Line Entry No.");

        CorrectPostedSalesInvoice.CreateCreditMemoCopyDocument(SalesInvoiceHeader, SalesHeader);
        LibrarySales.PostSalesDocument(SalesHeader, true, true);
        // Subscription Line is updated from Subscription Line archive
        ServiceCommitment.Get(ContractPriceUpdateLine."Subscription Line Entry No.");
        TestServiceCommitmentPrices(ServiceCommitmentArchive.Price, ServiceCommitmentArchive."Calculation Base %", ServiceCommitmentArchive."Calculation Base Amount", ServiceCommitmentArchive.Amount,
                                    ServiceCommitmentArchive."Discount %", ServiceCommitmentArchive."Discount Amount", ServiceCommitmentArchive."Next Price Update");

        // Planned Subscription Line will be updated with old Subscription Line
        PlannedServiceCommitment.Get(ContractPriceUpdateLine."Subscription Line Entry No.");
        TestPlannedServiceCommitment(PlannedServiceCommitment, OldServiceCommitment.Price, OldServiceCommitment."Calculation Base %", OldServiceCommitment."Calculation Base Amount", OldServiceCommitment.Amount,
                                     OldServiceCommitment."Discount %", OldServiceCommitment."Discount Amount", OldServiceCommitment."Next Price Update");
    end;

    [Test]
    [HandlerFunctions('CreateVendorBillingDocsContractPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure TestCancelPostedPurchaseInvoiceWithContractPriceUpdate()
    var
        PlannedServiceCommitment: Record "Planned Subscription Line";
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchaseHeader: Record "Purchase Header";
        OldServiceCommitment: Record "Subscription Line";
        ServiceCommitmentArchive: Record "Subscription Line Archive";
        CorrectPostedPurchInvoice: Codeunit "Correct Posted Purch. Invoice";
    begin
        Initialize();

        CreateContractPriceUpdateProposalForVendorServiceCommitments("Price Update Method"::"Recent Item Prices", CalcDate('<1M>', WorkDate()), 0, '<12M>', '<24M>', '<12M>');
        ContractPriceUpdateLine.Reset();
        ContractPriceUpdateLine.FindLast();

        Commit(); // Commit before processing
        PriceUpdateManagement.PerformPriceUpdate();
        Commit(); // Commit after processing

        ServiceCommitment.Get(ContractPriceUpdateLine."Subscription Line Entry No.");
        ServiceCommitment.CalcFields("Planned Sub. Line exists");
        Assert.IsTrue(ServiceCommitment."Planned Sub. Line exists", 'Planned Service Commitment was not created on Process Price Update.');
        PlannedServiceCommitment.Get(ContractPriceUpdateLine."Subscription Line Entry No.");

        CreateAndPostPurchaseBillingDocuments(PurchaseHeader, PurchInvHeader);
        Commit(); // retain data after asserterror

        ServiceCommitmentArchive.SetRange("Subscription Header No.", ServiceCommitment."Subscription Header No.");
        ServiceCommitmentArchive.SetRange("Original Entry No.", ServiceCommitment."Entry No.");
        ServiceCommitmentArchive.FindLast();
        OldServiceCommitment.Get(ContractPriceUpdateLine."Subscription Line Entry No.");

        CorrectPostedPurchInvoice.CreateCreditMemoCopyDocument(PurchInvHeader, PurchaseHeader);
        PurchaseHeader.Validate("Vendor Cr. Memo No.", LibraryUtility.GenerateGUID());
        PurchaseHeader.Modify(false);
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);
        // Subscription Line is updated from Subscription Line archive
        ServiceCommitment.Get(ContractPriceUpdateLine."Subscription Line Entry No.");
        TestServiceCommitmentPrices(ServiceCommitmentArchive.Price, ServiceCommitmentArchive."Calculation Base %", ServiceCommitmentArchive."Calculation Base Amount", ServiceCommitmentArchive.Amount,
                                    ServiceCommitmentArchive."Discount %", ServiceCommitmentArchive."Discount Amount", ServiceCommitmentArchive."Next Price Update");

        // Planned Subscription Line will be updated with old Subscription Line
        PlannedServiceCommitment.Get(ContractPriceUpdateLine."Subscription Line Entry No.");
        TestPlannedServiceCommitment(PlannedServiceCommitment, OldServiceCommitment.Price, OldServiceCommitment."Calculation Base %", OldServiceCommitment."Calculation Base Amount", OldServiceCommitment.Amount,
                                     OldServiceCommitment."Discount %", OldServiceCommitment."Discount Amount", OldServiceCommitment."Next Price Update");
    end;

    [Test]
    procedure TestCreateContractPriceUpdateProposal()
    begin
        Initialize();

        CreateContractPriceUpdateProposalForCustomerServiceCommitments("Price Update Method"::"Calculation Base by %", WorkDate(), '<12M>', '<1M>', LibraryRandom.RandDec(100, 2), '<12M>', '<12M>', '<12M>');
        ContractPriceUpdateLine.SetRange("Price Update Template Code", PriceUpdateTemplateCustomer.Code);
        Assert.RecordIsNotEmpty(ContractPriceUpdateLine);
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure TestContractPriceUpdateTemplateFilters()
    var
        ContractType: Record "Subscription Contract Type";
        CustomerContract: Record "Customer Subscription Contract";
        CurrentServiceCommitment: Record "Subscription Line";
        i: Integer;
        Iterations: Integer;
        BadServiceObjectFilterText: Text;
        ContractFilterText: Text;
        ServiceCommitmentFilterText: Text;
        ServiceObjectFilterText: Text;
        SerialNo: Text[50];
    begin
        // [GIVEN]
        Initialize();
        ContractTestLibrary.CreateContractType(ContractType);
        Iterations := 12;
        SerialNo := CreateGuid();
        ComposePriceUpdateTemplateFilters(ServiceCommitmentFilterText, ServiceObjectFilterText, BadServiceObjectFilterText, ContractFilterText, SerialNo, ContractType.Code);
        // Create 12 Contracts with 1 Subscription and 1 Subscription Line
        for i := 1 to Iterations do begin
            Clear(CustomerContract);
            Clear(ServiceObject);
            Clear(Customer);
            ContractTestLibrary.CreateCustomerContractAndCreateContractLinesForItems(CustomerContract, ServiceObject, Customer."No.");
            // every 2nd Contract gets a ContractType
            if i mod 2 = 0 then
                CustomerContract."Contract Type" := ContractType.Code
            else
                CustomerContract."Contract Type" := '';
            CustomerContract.Modify(false);
            // every 3rd Subscription gets a Serial Number
            if i mod 3 = 0 then
                ServiceObject."Serial No." := SerialNo
            else
                ServiceObject."Serial No." := '';
            ServiceObject.Modify(false);
            // every 4th Subscription Line gets a Subscription Line End Date
            CurrentServiceCommitment.SetRange("Subscription Header No.", ServiceObject."No.");
            if CurrentServiceCommitment.FindFirst() then
                if i mod 4 = 0 then
                    CurrentServiceCommitment."Subscription Line End Date" := 99991231D
                else
                    CurrentServiceCommitment."Subscription Line End Date" := 0D;
            CurrentServiceCommitment.Modify(false);
        end;

        // Create Price Update Template and apply Contract Filter
        CreatePriceUpdateTemplateWithFilterAndUpdateCreateProposal('', '', '', 12);
        CreatePriceUpdateTemplateWithFilterAndUpdateCreateProposal(ContractFilterText, '', '', 6);
        CreatePriceUpdateTemplateWithFilterAndUpdateCreateProposal('', ServiceCommitmentFilterText, '', 3);
        CreatePriceUpdateTemplateWithFilterAndUpdateCreateProposal('', '', ServiceObjectFilterText, 4);
        CreatePriceUpdateTemplateWithFilterAndUpdateCreateProposal(ContractFilterText, ServiceCommitmentFilterText, '', 3);
        CreatePriceUpdateTemplateWithFilterAndUpdateCreateProposal(ContractFilterText, '', ServiceObjectFilterText, 2);
        CreatePriceUpdateTemplateWithFilterAndUpdateCreateProposal('', ServiceCommitmentFilterText, ServiceObjectFilterText, 1);
        CreatePriceUpdateTemplateWithFilterAndUpdateCreateProposal(ContractFilterText, ServiceCommitmentFilterText, ServiceObjectFilterText, 1);
        CreatePriceUpdateTemplateWithFilterAndUpdateCreateProposal('', '', BadServiceObjectFilterText, 0);
    end;

    [Test]
    procedure TestIfContractPriceUpdateLinesAreDeletedAfterPerformPriceUpdate()
    begin
        Initialize();

        CreateContractPriceUpdateProposalForCustomerServiceCommitments("Price Update Method"::"Recent Item Prices", CalcDate('<1M>', WorkDate()), '<12M>', '<12M>', 0, '<12M>', '<24M>', '<12M>');

        Commit(); // Commit before processing
        PriceUpdateManagement.PerformPriceUpdate();
        Commit(); // Commit after processing
        ContractPriceUpdateLine.Reset();
        Assert.RecordIsEmpty(ContractPriceUpdateLine);
    end;

    [Test]
    [HandlerFunctions('StrMenuHandler')]
    procedure TestDeleteContractPriceUpdateProposal()
    begin
        Initialize();

        CreateContractPriceUpdateProposalForCustomerServiceCommitments("Price Update Method"::"Calculation Base by %", WorkDate(), '<12M>', '<1M>', LibraryRandom.RandDec(100, 2), '<12M>', '<12M>', '<12M>');

        LibraryVariableStorage.Enqueue(1);
        PriceUpdateManagement.DeleteProposal(PriceUpdateTemplateCustomer.Code);
        ContractPriceUpdateLine.Reset();
        Assert.RecordIsEmpty(ContractPriceUpdateLine);

        PriceUpdateManagement.CreatePriceUpdateProposal(PriceUpdateTemplateCustomer.Code, CalcDate(PriceUpdateTemplateCustomer.InclContrLinesUpToDateFormula, WorkDate()), WorkDate());

        LibraryVariableStorage.Enqueue(2);
        PriceUpdateManagement.DeleteProposal(PriceUpdateTemplateCustomer.Code);
        ContractPriceUpdateLine.SetRange("Price Update Template Code", PriceUpdateTemplateCustomer.Code);
        Assert.RecordIsEmpty(ContractPriceUpdateLine);
    end;

    [Test]
    procedure TestIfServiceCommitmentWithoutNextPriceUpdateIsIncludedInContractPriceUpdateProposal()
    begin
        Initialize();

        ContractTestLibrary.CreatePriceUpdateTemplate(PriceUpdateTemplateCustomer, "Service Partner"::Customer, Enum::"Price Update Method"::"Calculation Base by %", LibraryRandom.RandDec(100, 2), '<12M>', '<12M>', '<12M>');
        ContractTestLibrary.CreateMultipleServiceObjectsWithItemSetup(Customer, ServiceObject, Item, 2);
        ContractTestLibrary.CreateServiceCommitmentTemplateSetup(ServiceCommitmentTemplate, '<12M>', Enum::"Invoicing Via"::Contract);
        ContractTestLibrary.CreateServiceCommPackageAndAssignItemToServiceCommitmentSetup(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage, ServiceCommPackageLine, Item, '<12M>');
        ContractTestLibrary.UpdateServiceCommitmentPackageLineWithInvoicingItem(ServiceCommPackageLine, '');
        ContractTestLibrary.InsertServiceCommitmentFromServiceCommPackageSetup(ServiceCommitmentPackage, ServiceObject);

        // Force Next Price Update Date to empty
        ServiceCommitment.Reset();
        ServiceCommitment.SetRange("Subscription Header No.", ServiceObject."No.");
        ServiceCommitment.FindSet();
        repeat
            ServiceCommitment."Next Price Update" := 0D;
            ServiceCommitment.Modify(false);
        until ServiceCommitment.Next() = 0;

        PriceUpdateManagement.CreatePriceUpdateProposal(PriceUpdateTemplateCustomer.Code, CalcDate(PriceUpdateTemplateCustomer.InclContrLinesUpToDateFormula, WorkDate()), WorkDate());
        ContractPriceUpdateLine.SetRange("Price Update Template Code", PriceUpdateTemplateCustomer.Code);
        Assert.RecordIsNotEmpty(ContractPriceUpdateLine);
    end;

    [Test]
    [HandlerFunctions('CreateCustomerBillingDocsContractPageHandler,MessageHandler,ExchangeRateSelectionModalPageHandler')]
    procedure TestIfServiceCommIsUpdatedFromPlannedServiceCommitmentAfterPostSalesInvoice()
    var
        CustomerContract: Record "Customer Subscription Contract";
        PlannedServiceCommitment: Record "Planned Subscription Line";
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        Initialize();

        CreateContractPriceUpdateProposalForCustomerServiceCommitments("Price Update Method"::"Recent Item Prices", CalcDate('<1M>', WorkDate()), '<12M>', '<12M>', 0, '<12M>', '<24M>', '<12M>');
        ContractPriceUpdateLine.Reset();
        ContractPriceUpdateLine.FindLast();

        Commit(); // Commit before processing
        PriceUpdateManagement.PerformPriceUpdate();
        Commit(); // Commit after processing

        ServiceCommitment.Get(ContractPriceUpdateLine."Subscription Line Entry No.");
        ServiceCommitment.CalcFields("Planned Sub. Line exists");
        Assert.IsTrue(ServiceCommitment."Planned Sub. Line exists", 'Planned Service Commitment was not created on Process Price Update.');

        PlannedServiceCommitment.Get(ContractPriceUpdateLine."Subscription Line Entry No.");

        ContractTestLibrary.CreateCustomerContractAndCreateContractLinesForItems(CustomerContract, ServiceObject, ServiceObject."End-User Customer No.");
        CreateAndPostSalesBillingDocuments(SalesHeader, SalesInvoiceHeader);
        Commit(); // retain data after asserterror

        // Subscription Line is updated from Planned Subscription Line
        ServiceCommitment.Get(ContractPriceUpdateLine."Subscription Line Entry No.");
        TestServiceCommitmentPrices(PlannedServiceCommitment.Price, PlannedServiceCommitment."Calculation Base %", PlannedServiceCommitment."Calculation Base Amount", PlannedServiceCommitment.Amount,
                                    PlannedServiceCommitment."Discount %", PlannedServiceCommitment."Discount Amount", PlannedServiceCommitment."Next Price Update");

        // Planned Subscription Line will be deleted after sales invoice is posted
        asserterror PlannedServiceCommitment.Get(ContractPriceUpdateLine."Subscription Line Entry No.");
    end;

    [Test]
    [HandlerFunctions('CreateVendorBillingDocsContractPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure TestIfServiceCommIsUpdatedFromPlannedServiceCommitmentAfterPostPurchaseInvoice()
    var
        PlannedServiceCommitment: Record "Planned Subscription Line";
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchaseHeader: Record "Purchase Header";
    begin
        Initialize();

        CreateContractPriceUpdateProposalForVendorServiceCommitments("Price Update Method"::"Recent Item Prices", CalcDate('<1M>', WorkDate()), 0, '<12M>', '<24M>', '<12M>');
        ContractPriceUpdateLine.Reset();
        ContractPriceUpdateLine.FindLast();

        Commit(); // Commit before processing
        PriceUpdateManagement.PerformPriceUpdate();
        Commit(); // Commit after processing

        ServiceCommitment.Get(ContractPriceUpdateLine."Subscription Line Entry No.");
        ServiceCommitment.CalcFields("Planned Sub. Line exists");
        Assert.IsTrue(ServiceCommitment."Planned Sub. Line exists", 'Planned Service Commitment was not created on Process Price Update.');

        PlannedServiceCommitment.Get(ContractPriceUpdateLine."Subscription Line Entry No.");
        CreateAndPostPurchaseBillingDocuments(PurchaseHeader, PurchInvHeader);
        Commit(); // retain data after asserterror

        // Subscription Line is updated from Planned Subscription Line
        ServiceCommitment.Get(ContractPriceUpdateLine."Subscription Line Entry No.");
        TestServiceCommitmentPrices(PlannedServiceCommitment.Price, PlannedServiceCommitment."Calculation Base %", PlannedServiceCommitment."Calculation Base Amount", PlannedServiceCommitment.Amount,
                                    PlannedServiceCommitment."Discount %", PlannedServiceCommitment."Discount Amount", PlannedServiceCommitment."Next Price Update");

        // Planned Subscription Line will be deleted after sales invoice is posted
        asserterror PlannedServiceCommitment.Get(ContractPriceUpdateLine."Subscription Line Entry No.");
    end;

    [Test]
    procedure TestPlannedServiceCommitmentAfterPerformPriceUpdate()
    var
        TempContractPriceUpdateLine2: Record "Sub. Contr. Price Update Line" temporary;
        PlannedServiceCommitment: Record "Planned Subscription Line";
    begin
        Initialize();

        CreateContractPriceUpdateProposalForCustomerServiceCommitments("Price Update Method"::"Recent Item Prices", CalcDate('<1M>', WorkDate()), '<12M>', '<12M>', 0, '<12M>', '<24M>', '<12M>');

        ContractPriceUpdateLine.SetRange("Price Update Template Code", PriceUpdateTemplateCustomer.Code);
        ContractPriceUpdateLine.FindSet();
        repeat
            TempContractPriceUpdateLine2 := ContractPriceUpdateLine;
            TempContractPriceUpdateLine2.Insert(false);
        until ContractPriceUpdateLine.Next() = 0;

        Commit(); // Commit before processing
        PriceUpdateManagement.PerformPriceUpdate();
        Commit(); // Commit after processing
        TempContractPriceUpdateLine2.Reset();
        TempContractPriceUpdateLine2.FindSet();
        repeat
            PlannedServiceCommitment.Get(TempContractPriceUpdateLine2."Subscription Line Entry No.");
            TestPlannedServiceCommitment(PlannedServiceCommitment, TempContractPriceUpdateLine2."New Price", TempContractPriceUpdateLine2."New Calculation Base %", TempContractPriceUpdateLine2."New Calculation Base",
                                         TempContractPriceUpdateLine2."New Amount", TempContractPriceUpdateLine2."Discount %", TempContractPriceUpdateLine2."Discount Amount", CalcDate(PriceUpdateTemplateCustomer."Price Binding Period", ContractPriceUpdateLine."Perform Update On"));
        until TempContractPriceUpdateLine2.Next() = 0;
    end;

    [Test]
    [HandlerFunctions('CreateCustomerBillingDocsContractPageHandler,MessageHandler,ExchangeRateSelectionModalPageHandler')]
    procedure TestServiceCommitmentAfterPerformPriceUpdate()
    var
        TempContractPriceUpdateLine2: Record "Sub. Contr. Price Update Line" temporary;
        CustomerContract: Record "Customer Subscription Contract";
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        TempServiceCommitment: Record "Subscription Line" temporary;
    begin
        Initialize();

        CreateContractPriceUpdateProposalForCustomerServiceCommitments("Price Update Method"::"Calculation Base by %", WorkDate(), '<12M>', '<12M>', LibraryRandom.RandDec(100, 2), '<1M>', '<1M>', '<1M>');
        // Make sure that the Subscription Line is fully invoice until date of next price update
        ContractTestLibrary.CreateCustomerContractAndCreateContractLinesForItems(CustomerContract, ServiceObject, ServiceObject."End-User Customer No.");
        CreateAndPostSalesBillingDocuments(SalesHeader, SalesInvoiceHeader);
        Commit(); // retain data after asserterror

        ContractPriceUpdateLine.SetRange("Price Update Template Code", PriceUpdateTemplateCustomer.Code);
        ContractPriceUpdateLine.FindSet();
        repeat
            TempContractPriceUpdateLine2 := ContractPriceUpdateLine;
            TempContractPriceUpdateLine2.Insert(false);
            ServiceCommitment.Get(TempContractPriceUpdateLine2."Subscription Line Entry No.");
            TempServiceCommitment := ServiceCommitment;
            TempServiceCommitment.Insert(false);
        until ContractPriceUpdateLine.Next() = 0;

        Commit(); // Commit before processing
        PriceUpdateManagement.PerformPriceUpdate();
        Commit(); // Commit after processing

        TempContractPriceUpdateLine2.Reset();
        TempContractPriceUpdateLine2.FindSet();
        repeat
            ServiceCommitment.Get(TempContractPriceUpdateLine2."Subscription Line Entry No.");
            TempServiceCommitment.Get(ServiceCommitment."Entry No.");
            TestServiceCommitmentPrices(TempContractPriceUpdateLine2."New Price", TempContractPriceUpdateLine2."New Calculation Base %", TempContractPriceUpdateLine2."New Calculation Base", TempContractPriceUpdateLine2."New Amount",
                                        TempContractPriceUpdateLine2."Discount %", TempContractPriceUpdateLine2."Discount Amount", TempContractPriceUpdateLine2."Next Price Update");
            TestIfArchivedServiceCommitmentIsCreated(TempServiceCommitment);
        until TempContractPriceUpdateLine2.Next() = 0;
    end;

    [Test]
    procedure UT_ContractPriceUpdateLine_UpdatePerformUpdateOn()
    var
        PerformUpdateOn: Date;
    begin
        // Test the return date value for procedure UpdatePerformUpdateOn()
        // [GIVEN] Create dummy Subscription Line with only Next Billing Date filled out
        // [GIVEN] Create random dates where PerformUpdateOn is the latest date
        ServiceCommitment.Init();
        ServiceCommitment."Next Billing Date" := LibraryRandom.RandDateFrom(WorkDate(), 12);
        ServiceCommitment."Next Price Update" := LibraryRandom.RandDateFrom(ServiceCommitment."Next Billing Date", 12);
        PerformUpdateOn := LibraryRandom.RandDateFrom(ServiceCommitment."Next Price Update", 12);

        // [WHEN] Run UpdatePerformUpdateOn in Contract Price Update Line
        ContractPriceUpdateLine.UpdatePerformUpdateOn(ServiceCommitment, PerformUpdateOn);

        // [THEN] Expect that "Contract Price Update Line"."Perform Update On" is updated with the latest date
        Assert.AreEqual(PerformUpdateOn, ContractPriceUpdateLine."Perform Update On", 'UpdatePerformUpdateOn did not return correct value');

        PerformUpdateOn := 0D;
        // [WHEN] Run UpdatePerformUpdateOn in Contract Price Update Line
        ContractPriceUpdateLine.UpdatePerformUpdateOn(ServiceCommitment, PerformUpdateOn);
        // [THEN] Expect that "Contract Price Update Line"."Perform Update On" is updated with the latest date
        Assert.AreEqual(ServiceCommitment."Next Price Update", ContractPriceUpdateLine."Perform Update On", 'UpdatePerformUpdateOn did not return correct value');
    end;

    #endregion Tests

    #region Procedures

    local procedure Initialize()
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Contract Price Proposal Test");
        ContractTestLibrary.InitContractsApp();
        Currency.InitRoundingPrecision();

        ClearAll();

        if IsInitialized then
            exit;

        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"Contract Price Proposal Test");
        LibraryERMCountryData.UpdatePurchasesPayablesSetup();
        LibraryERMCountryData.UpdateSalesReceivablesSetup();
        LibraryERMCountryData.UpdateGeneralLedgerSetup();
        LibraryERMCountryData.UpdateJournalTemplMandatory(false);
        ContractTestLibrary.InitSourceCodeSetup();
        IsInitialized := true;
        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"Contract Price Proposal Test");
    end;

    local procedure CreateBillingDocuments()
    begin
        BillingLine.SetRange("Billing Template Code", BillingTemplate.Code);
        BillingLine.SetRange(Partner, BillingTemplate.Partner);
        Codeunit.Run(Codeunit::"Create Billing Documents", BillingLine);
    end;

    local procedure CreateAndPostPurchaseBillingDocuments(var PurchaseHeader: Record "Purchase Header"; var PurchInvHeader: Record "Purch. Inv. Header")
    begin
        ContractTestLibrary.CreateBillingProposal(BillingTemplate, Enum::"Service Partner"::Vendor);
        CreateBillingDocuments();
        BillingLine.Reset();
        BillingLine.FindFirst();
        PurchaseHeader.Get(Enum::"Purchase Document Type"::Invoice, BillingLine."Document No.");
        PurchaseHeader.Validate("Vendor Invoice No.", LibraryUtility.GenerateGUID());
        PurchaseHeader.Modify(false);
        PurchInvHeader.Get(LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true));
    end;

    local procedure CreateAndPostSalesBillingDocuments(var SalesHeader: Record "Sales Header"; var SalesInvoiceHeader: Record "Sales Invoice Header")
    begin
        ContractTestLibrary.CreateBillingProposal(BillingTemplate, Enum::"Service Partner"::Customer);
        CreateBillingDocuments();
        BillingLine.Reset();
        BillingLine.FindFirst();
        SalesHeader.Get(Enum::"Sales Document Type"::Invoice, BillingLine."Document No.");
        SalesInvoiceHeader.Get(LibrarySales.PostSalesDocument(SalesHeader, true, true));
    end;

    local procedure CreateCustomerContractPriceUpdateFromMultipleContracts(var CustomerContract: Record "Customer Subscription Contract"; var CustomerContract2: Record "Customer Subscription Contract")
    var
        ServiceObject2: Record "Subscription Header";
    begin
        ContractTestLibrary.CreatePriceUpdateTemplate(PriceUpdateTemplateCustomer, "Service Partner"::Customer, "Price Update Method"::"Recent Item Prices", 0, '<12M>', '<12M>', '<12M>');
        PriceUpdateTemplateCustomer."Group by" := Enum::"Contract Billing Grouping"::Contract;

        ContractTestLibrary.CreateCustomer(Customer);
        ContractTestLibrary.CreateCustomerContractAndCreateContractLinesForItems(CustomerContract, ServiceObject, Customer."No.", false);
        ContractTestLibrary.CreateCustomer(Customer2);
        ContractTestLibrary.CreateCustomerContractAndCreateContractLinesForItems(CustomerContract2, ServiceObject2, Customer2."No.", false);

        PriceUpdateManagement.CreatePriceUpdateProposal(PriceUpdateTemplateCustomer.Code, CalcDate(PriceUpdateTemplateCustomer.InclContrLinesUpToDateFormula, WorkDate()), WorkDate());
    end;

    local procedure CreateContractPriceUpdateProposalForCustomerServiceCommitments(PriceUpdateMethod: Enum "Price Update Method"; ContractPriceUpdateBaseDate: Date;
                                                                                    CalculationBaseFormula: Text; CalculationRhythmDateFormula: Text; UpdateValuePercentage: Decimal;
                                                                                    PerformUpdateOnFormula: Text; InclContrLinesUpToDateFormula: Text; PriceBindingPeriod: Text)
    begin
        ContractTestLibrary.CreatePriceUpdateTemplate(PriceUpdateTemplateCustomer, "Service Partner"::Customer, PriceUpdateMethod, UpdateValuePercentage, PerformUpdateOnFormula, InclContrLinesUpToDateFormula, PriceBindingPeriod);
        ContractTestLibrary.CreateMultipleServiceObjectsWithItemSetup(Customer, ServiceObject, Item, 2);
        ContractTestLibrary.CreateServiceCommitmentTemplateSetup(ServiceCommitmentTemplate, CalculationBaseFormula, Enum::"Invoicing Via"::Contract);
        ContractTestLibrary.CreateServiceCommPackageAndAssignItemToServiceCommitmentSetup(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage, ServiceCommPackageLine, Item, CalculationRhythmDateFormula);
        ContractTestLibrary.InsertServiceCommitmentFromServiceCommPackageSetup(ServiceCommitmentPackage, ServiceObject);
        UpdateServiceCommitmentWithAmounts();
        PriceUpdateManagement.CreatePriceUpdateProposal(PriceUpdateTemplateCustomer.Code, CalcDate(PriceUpdateTemplateCustomer.InclContrLinesUpToDateFormula, ContractPriceUpdateBaseDate), ContractPriceUpdateBaseDate);
    end;

    local procedure CreateContractPriceUpdateProposalForVendorServiceCommitments(PriceUpdateMethod: Enum "Price Update Method"; ContractPriceUpdateBaseDate: Date;
                                                                                UpdateValuePercentage: Decimal; PerformUpdateOnFormula: Text; InclContrLinesUpToDateFormula: Text; PriceBindingPeriod: Text)
    var
        VendorContract: Record "Vendor Subscription Contract";
    begin
        ContractTestLibrary.CreatePriceUpdateTemplate(PriceUpdateTemplateVendor, "Service Partner"::Vendor, PriceUpdateMethod, UpdateValuePercentage, PerformUpdateOnFormula, InclContrLinesUpToDateFormula, PriceBindingPeriod);
        ContractTestLibrary.CreateVendor(Vendor);
        ContractTestLibrary.CreateVendorContractAndCreateContractLinesForItems(VendorContract, ServiceObject, Vendor."No.", false);
        UpdateItemUnitCost(ServiceObject."Source No.");
        PriceUpdateManagement.CreatePriceUpdateProposal(PriceUpdateTemplateVendor.Code, CalcDate(PriceUpdateTemplateVendor.InclContrLinesUpToDateFormula, ContractPriceUpdateBaseDate), ContractPriceUpdateBaseDate);
    end;

    local procedure CreatePriceUpdateTemplateWithFilterAndUpdateCreateProposal(ContractFilterText: Text; ServiceCommitmentFilterText: Text; ServiceObjectFilterText: Text; ExpectedValue: Integer)
    begin
        ContractPriceUpdateLine.Reset();
        ContractPriceUpdateLine.DeleteAll(false);
        ContractTestLibrary.CreatePriceUpdateTemplate(PriceUpdateTemplateCustomer, "Service Partner"::Customer, Enum::"Price Update Method"::"Calculation Base by %", LibraryRandom.RandDec(100, 2), '<12M>', '<12M>', '<12M>');
        PriceUpdateTemplateCustomer.WriteFilter(PriceUpdateTemplateCustomer.FieldNo("Subscription Contract Filter"), ContractFilterText);
        PriceUpdateTemplateCustomer.WriteFilter(PriceUpdateTemplateCustomer.FieldNo("Subscription Filter"), ServiceObjectFilterText);
        PriceUpdateTemplateCustomer.WriteFilter(PriceUpdateTemplateCustomer.FieldNo("Subscription Line Filter"), ServiceCommitmentFilterText);
        // Execute Proposal
        PriceUpdateManagement.CreatePriceUpdateProposal(PriceUpdateTemplateCustomer.Code, CalcDate(PriceUpdateTemplateCustomer.InclContrLinesUpToDateFormula, WorkDate()), WorkDate());
        // Check
        ContractPriceUpdateLine.SetRange("Price Update Template Code", PriceUpdateTemplateCustomer.Code);
        Assert.AreEqual(ExpectedValue, ContractPriceUpdateLine.Count(), 'Filtering failed.');
    end;

    local procedure ComposePriceUpdateTemplateFilters(var ServiceCommitmentFilterText: Text; var ServiceObjectFilterText: Text; var BadServiceObjectFilterText: Text; var ContractFilterText: Text; SerialNo: Guid; ContractTypeCode: Code[10])
    var
        DummyContract: Record "Customer Subscription Contract";
        DummyServComm: Record "Subscription Line";
        DummyServObj: Record "Subscription Header";
    begin
        DummyServComm.SetRange("Subscription Line End Date", 99991231D);
        ServiceCommitmentFilterText := DummyServComm.GetView(false);
        DummyServObj.SetRange("Serial No.", SerialNo);
        ServiceObjectFilterText := DummyServObj.GetView(false);
        DummyServObj.SetRange("Source No.", LibraryRandom.RandText(19));
        BadServiceObjectFilterText := DummyServObj.GetView(false);
        DummyContract.SetRange("Contract Type", ContractTypeCode);
        ContractFilterText := DummyContract.GetView(false);
    end;

    local procedure CreateVendorContractPriceUpdateFromMultipleContracts(var VendorContract: Record "Vendor Subscription Contract"; var VendorContract2: Record "Vendor Subscription Contract")
    var
        ServiceObject2: Record "Subscription Header";
    begin
        ContractTestLibrary.CreatePriceUpdateTemplate(PriceUpdateTemplateVendor, "Service Partner"::Vendor, "Price Update Method"::"Recent Item Prices", 0, '<24M>', '<24M>', '<12M>');
        PriceUpdateTemplateCustomer."Group by" := Enum::"Contract Billing Grouping"::Contract;

        ContractTestLibrary.CreateVendor(Vendor);
        ContractTestLibrary.CreateVendorContractAndCreateContractLinesForItems(VendorContract, ServiceObject, Vendor."No.", false);
        UpdateItemUnitCost(ServiceObject."Source No.");
        ContractTestLibrary.CreateVendor(Vendor2);
        ContractTestLibrary.CreateVendorContractAndCreateContractLinesForItems(VendorContract2, ServiceObject2, Vendor2."No.", false);
        UpdateItemUnitCost(ServiceObject2."Source No.");
        PriceUpdateManagement.CreatePriceUpdateProposal(PriceUpdateTemplateVendor.Code, CalcDate(PriceUpdateTemplateVendor.InclContrLinesUpToDateFormula, WorkDate()), WorkDate());
    end;

    local procedure TestIfArchivedServiceCommitmentIsCreated(TempServiceCommitment: Record "Subscription Line" temporary)
    var
        ServiceCommitmentArchive: Record "Subscription Line Archive";
    begin
        ServiceCommitmentArchive.FilterOnServiceCommitment(TempServiceCommitment."Entry No.");
        Assert.AreEqual(1, ServiceCommitmentArchive.Count, 'Service commitment was not archived properly on after perform price update');

        ServiceCommitmentArchive.FindLast();
        ServiceCommitmentArchive.TestField(Price, TempServiceCommitment.Price);
        ServiceCommitmentArchive.TestField(Amount, TempServiceCommitment.Amount);
        ServiceCommitmentArchive.TestField("Calculation Base %", TempServiceCommitment."Calculation Base %");
        ServiceCommitmentArchive.TestField("Calculation Base Amount", TempServiceCommitment."Calculation Base Amount");
        ServiceCommitmentArchive.TestField("Type Of Update", Enum::"Type Of Price Update"::"Price Update");
    end;

    local procedure TestPlannedServiceCommitment(PlannedServiceCommitment: Record "Planned Subscription Line"; ExpectedPrice: Decimal; ExpectedCalculationBase: Decimal; ExpectedCalculationBaseAmount: Decimal; ExpectedServiceAmount: Decimal; ExpectedDiscountPct: Decimal; ExpectedDiscountAmount: Decimal; ExpectedNextPriceUpdate: Date)
    begin
        PlannedServiceCommitment.TestField(Price, ExpectedPrice);
        PlannedServiceCommitment.TestField("Calculation Base %", ExpectedCalculationBase);
        PlannedServiceCommitment.TestField("Calculation Base Amount", ExpectedCalculationBaseAmount);
        PlannedServiceCommitment.TestField(Amount, ExpectedServiceAmount);
        PlannedServiceCommitment.TestField("Next Price Update", ExpectedNextPriceUpdate);
        PlannedServiceCommitment.TestField("Discount %", ExpectedDiscountPct);
        PlannedServiceCommitment.TestField("Discount Amount", ExpectedDiscountAmount);
    end;

    local procedure TestServiceCommitmentPrices(ExpectedPrice: Decimal; ExpectedCalculationBase: Decimal; ExpectedCalculationBaseAmount: Decimal; ExpectedServiceAmount: Decimal; ExpectedDiscountPct: Decimal; ExpectedDiscountAmount: Decimal; ExpectedNextPriceUpdate: Date)
    begin
        ServiceCommitment.TestField(Price, ExpectedPrice);
        ServiceCommitment.TestField("Calculation Base %", ExpectedCalculationBase);
        ServiceCommitment.TestField("Calculation Base Amount", ExpectedCalculationBaseAmount);
        ServiceCommitment.TestField(Amount, ExpectedServiceAmount);
        ServiceCommitment.TestField("Next Price Update", ExpectedNextPriceUpdate);
        ServiceCommitment.TestField("Discount %", ExpectedDiscountPct);
        ServiceCommitment.TestField("Discount Amount", ExpectedDiscountAmount);
    end;

    local procedure UpdateItemUnitCost(ItemNo: Code[20])
    begin
        Item.Get(ItemNo);
        Item.Modify(false);
    end;

    local procedure UpdateServiceCommitmentWithAmounts()
    begin
        ServiceCommitment.SetRange("Subscription Header No.", ServiceObject."No.");
        if ServiceCommitment.FindSet() then
            repeat
                ServiceCommitment.Validate("Calculation Base Amount", LibraryRandom.RandDec(1000, 1));
                ServiceCommitment.Validate("Calculation Base %", 100);
                ServiceCommitment.Validate("Discount %", LibraryRandom.RandDec(100, 1));
                ServiceCommitment.Modify(false);
            until ServiceCommitment.Next() = 0;
    end;

    #endregion Procedures

    #region Handlers

    [ModalPageHandler]
    procedure CreateCustomerBillingDocsContractPageHandler(var CreateCustomerBillingDocs: TestPage "Create Customer Billing Docs")
    begin
        CreateCustomerBillingDocs.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure CreateVendorBillingDocsContractPageHandler(var CreateVendorBillingDocs: TestPage "Create Vendor Billing Docs")
    begin
        CreateVendorBillingDocs.OK().Invoke();
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

    [StrMenuHandler]
    procedure StrMenuHandler(Option: Text[1024]; var Choice: Integer; Instruction: Text[1024])
    begin
        Choice := LibraryVariableStorage.DequeueInteger();
    end;

    #endregion Handlers
}
