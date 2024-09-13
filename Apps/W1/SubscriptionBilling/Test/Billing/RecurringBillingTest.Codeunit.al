namespace Microsoft.SubscriptionBilling;

using Microsoft.Sales.Customer;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using Microsoft.Purchases.Vendor;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Inventory.Item;
using Microsoft.Finance.Currency;
using Microsoft.Finance.GeneralLedger.Setup;

codeunit 139688 "Recurring Billing Test"
{
    Subtype = Test;
    TestPermissions = Disabled;
    Access = Internal;

    var
        BillingTemplate: Record "Billing Template";
        BillingTemplate2: Record "Billing Template";
        ServiceCommitment: Record "Service Commitment";
        Item: Record Item;
        ServiceObject: Record "Service Object";
        ServiceObject2: Record "Service Object";
        ServiceCommitmentTemplate: Record "Service Commitment Template";
        ServiceCommitmentPackage: Record "Service Commitment Package";
        ServiceCommPackageLine: Record "Service Comm. Package Line";
        BillingLine: Record "Billing Line";
        Currency: Record Currency;
        CustomerContract: Record "Customer Contract";
        CustomerContract2: Record "Customer Contract";
        VendorContract: Record "Vendor Contract";
        VendorContract2: Record "Vendor Contract";
        Customer: Record Customer;
        Vendor: Record Vendor;
        Vendor2: Record Vendor;
        Customer2: Record Customer;
        CustomerContractLine: Record "Customer Contract Line";
        VendorContractLine: Record "Vendor Contract Line";
        SalesHeader: Record "Sales Header";
        PurchaseHeader: Record "Purchase Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        PurchInvHeader: Record "Purch. Inv. Header";
        BillingLineArchive: Record "Billing Line Archive";
        TempDeletedCustomerContractLine: Record "Customer Contract Line" temporary;
        TempDeletedVendorContractLine: Record "Vendor Contract Line" temporary;
        TempBillingLine: Record "Billing Line" temporary;
        LibraryRandom: Codeunit "Library - Random";
        ContractTestLibrary: Codeunit "Contract Test Library";
        AssertThat: Codeunit Assert;
        LibrarySales: Codeunit "Library - Sales";
        LibraryPurchase: Codeunit "Library - Purchase";
        BillingProposal: Codeunit "Billing Proposal";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryERMCountryData: Codeunit "Library - ERM Country Data";
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        BillingRhythm: DateFormula;
        RecurringBillingPage: TestPage "Recurring Billing";
        BillingProposalNotCreatedErr: Label 'Billing proposal not created.';
        StrMenuHandlerStep: Integer;
        PostedDocumentNo: Code[20];
        IsInitialized: Boolean;

    [Test]
    procedure CreateBillingTemplate()
    var
        FilterText: Text;
    begin
        Initialize();

        CustomerContract.SetRange("Contract Type", LibraryRandom.RandText(MaxStrLen(CustomerContract."Contract Type")));
        CreateRecurringBillingTemplateSetupForCustomerContract('<-CM>', '<CM>', CustomerContract.GetView());
        FilterText := BillingTemplate.ReadFilter(BillingTemplate.FieldNo(Filter));
        AssertThat.AreEqual(CustomerContract.GetView(), FilterText, 'Billing Template customer contract filter failed.');
    end;

    [Test]
    [HandlerFunctions('BillingTemplateModalPageHandler')]
    procedure CheckBillingDateCalculationFromCustomerBillingTemplate()
    var
        BillingDateValue: Date;
        BillingToDateValue: Date;
        ExpectedBillingDate: Date;
        ExpectedBillingToDate: Date;
    begin
        Initialize();

        CreateRecurringBillingTemplateSetupForCustomerContract('<-CM>', '<CM>', '');

        RecurringBillingPage.OpenEdit();
        RecurringBillingPage.BillingTemplateField.Lookup();

        Evaluate(BillingDateValue, RecurringBillingPage.BillingDateField.Value());
        Evaluate(BillingToDateValue, RecurringBillingPage.BillingToDateField.Value());
        ExpectedBillingDate := CalcDate('<-CM>', WorkDate());
        ExpectedBillingToDate := CalcDate('<CM>', WorkDate());

        AssertThat.AreEqual(ExpectedBillingDate, BillingDateValue, 'Expected Billing Date calculation failed.');
        AssertThat.AreEqual(ExpectedBillingToDate, BillingToDateValue, 'Expected Billing to Date calculation failed.');
    end;

    [Test]
    procedure CheckCreateBillingProposalForCustomerContract()
    begin
        Initialize();

        CreateBillingProposalForCustomerContractUsingRealTemplate();

        BillingLine.SetRange("Billing Template Code", BillingTemplate.Code);
        BillingLine.SetRange("Service Object No.", ServiceObject."No.");
        if BillingLine.FindSet() then
            repeat
                ServiceCommitment.Get(BillingLine."Service Commitment Entry No.");
                AssertThat.AreEqual(BillingLine."Billing Template Code", BillingTemplate.Code, BillingLine."Billing Template Code");
                AssertThat.AreEqual(BillingLine."Service Object No.", ServiceCommitment."Service Object No.", BillingLine.FieldName("Service Object No."));
                AssertThat.AreEqual(BillingLine."Service Commitment Entry No.", ServiceCommitment."Entry No.", BillingLine.FieldName("Service Commitment Entry No."));
                AssertThat.AreEqual(BillingLine."Service Commitment Description", ServiceCommitment.Description, BillingLine.FieldName("Service Commitment Description"));
                AssertThat.AreEqual(BillingLine."Service Start Date", ServiceCommitment."Service Start Date", BillingLine.FieldName("Service Start Date"));
                AssertThat.AreEqual(BillingLine."Service End Date", ServiceCommitment."Service End Date", BillingLine.FieldName("Service End Date"));
                AssertThat.AreEqual(BillingLine."Billing Rhythm", ServiceCommitment."Billing Rhythm", BillingLine.FieldName("Billing Rhythm"));
                AssertThat.AreEqual(BillingLine."Discount %", ServiceCommitment."Discount %", BillingLine.FieldName("Discount %"));
                AssertThat.AreEqual(BillingLine."Service Obj. Quantity Decimal", ServiceObject."Quantity Decimal", BillingLine.FieldName("Service Obj. Quantity Decimal"));
            until BillingLine.Next() = 0
        else
            Error(BillingProposalNotCreatedErr);
    end;

    [Test]
    procedure CheckCreateBillingProposalForCustomerContractWithEmptyBillingToDate()
    begin
        Initialize();

        CreateCustomerContract('<12M>', '<1M>');
        CreateRecurringBillingTemplateSetupForCustomerContract('<2M-CM>', '<8M+CM>', CustomerContract.GetView());
        ContractTestLibrary.CreateBillingProposal(BillingTemplate, Enum::"Service Partner"::Customer, WorkDate(), 0D);

        BillingLine.SetRange("Billing Template Code", BillingTemplate.Code);
        BillingLine.SetRange("Service Object No.", ServiceObject."No.");
        BillingLine.FindSet();
    end;

    [Test]
    [HandlerFunctions('StrMenuHandlerClearBillingProposal')]
    procedure CheckClearBillingProposalForCustomerContract()
    begin
        Initialize();

        CreateBillingProposalForCustomerContractUsingRealTemplate();

        BillingLine.SetRange("Billing Template Code", BillingTemplate.Code);
        BillingLine.SetRange("Service Object No.", ServiceObject."No.");
        if not BillingLine.FindSet() then
            Error(BillingProposalNotCreatedErr);

        StrMenuHandlerStep := 1;
        BillingProposal.DeleteBillingProposal(BillingTemplate.Code);

        BillingLine.Reset();
        BillingLine.SetRange("Billing Template Code", BillingTemplate.Code);
        AssertThat.AreEqual(BillingLine.IsEmpty(), true, 'Delete Billing proposal failed.');

        ContractTestLibrary.CreateBillingProposal(BillingTemplate, Enum::"Service Partner"::Customer);

        BillingLine.SetRange("Billing Template Code", BillingTemplate.Code);
        BillingLine.SetRange("Service Object No.", ServiceObject."No.");
        if not BillingLine.FindSet() then
            Error(BillingProposalNotCreatedErr);

        StrMenuHandlerStep := 2;
        BillingProposal.DeleteBillingProposal(BillingTemplate.Code);

        BillingLine.Reset();
        BillingLine.SetRange("Billing Template Code", BillingTemplate.Code);
        AssertThat.AreEqual(BillingLine.IsEmpty(), true, 'Delete Billing proposal failed.');
    end;

    [Test]
    procedure CheckChangeBillingToDateForCustomer()
    begin
        Initialize();

        CreateBillingProposalForCustomerContractUsingRealTemplate();

        FindFirstServiceCommitment();

        BillingLine.SetRange("Billing Template Code", BillingTemplate.Code);
        BillingLine.SetRange("Service Object No.", ServiceObject."No.");
        BillingLine.SetRange("Billing to", CalcDate('<-1D>', ServiceCommitment."Next Billing Date"));
        BillingLine.FindFirst();
        BillingProposal.UpdateBillingToDate(BillingLine, CalcDate('<+3D>', BillingLine."Billing to"));
        BillingLine.SetRange("Billing to");
        BillingLine.FindFirst();
        asserterror BillingProposal.UpdateBillingToDate(BillingLine, CalcDate('<+3D>', BillingLine."Billing to"));
    end;

    [Test]
    procedure CheckDeleteBillingLineForCustomerContract()
    begin
        Initialize();

        CreateBillingProposalForCustomerContractUsingRealTemplate();

        FindFirstServiceCommitment();
        Commit(); // retain data after asserterror

        BillingLine.SetRange("Billing Template Code", BillingTemplate.Code);
        BillingLine.SetRange("Service Object No.", ServiceObject."No.");
        if BillingLine.FindSet() then
            repeat
                if (CalcDate('<-1D>', ServiceCommitment."Next Billing Date") = BillingLine."Billing to") then
                    BillingLine.Delete(true)
                else
                    asserterror BillingLine.Delete(true);
            until BillingLine.Next() = 0
        else
            Error(BillingProposalNotCreatedErr);
    end;

    [Test]
    procedure CheckBillingLineServiceAmountCalculation()
    var
        ExpectedServiceAmount: Decimal;
    begin
        // [SCENARIO] Unit testing the function CalculateBillingLineServiceAmount from Codeunit BillingProposal
        Initialize();

        // [GIVEN] BillingLine has values
        MockBillingLineForPartnerNoWithUnitPriceAndDiscountAndServicObjectQuantity(LibraryRandom.RandDec(100, 2), LibraryRandom.RandDec(50, 2), LibraryRandom.RandDec(10, 2));
        ExpectedServiceAmount := BillingLine."Unit Price" * BillingLine."Service Obj. Quantity Decimal" * (1 - BillingLine."Discount %" / 100);

        AssertThat.AreEqual(ExpectedServiceAmount, BillingProposal.CalculateBillingLineServiceAmount(BillingLine), 'Service Amount has not been calculated correctly on a Billing Line.');
    end;

    [Test]
    procedure CheckLineDiscountTransferedToBillingLineForCustomerContract()
    var
        ExpectedServiceAmount: Decimal;
    begin
        // [SCENARIO] When the "Discount %" is entered on a Service Commitment it should be transferred to a billing line when creating billing proposal.
        Initialize();

        // [GIVEN] Contract has been created
        CreateCustomerContract('<1M>', '<12M>');

        // [GIVEN] "Discount %" is updated on a Service Commitment
        FindFirstServiceCommitment();
        ServiceCommitment."Discount %" := LibraryRandom.RandDec(50, 2);
        ServiceCommitment.Modify(false);

        // [WHEN] The billing proposal has been created
        CreateRecurringBillingTemplateSetupForCustomerContract('<2M-CM>', '<8M+CM>', CustomerContract.GetView());
        ContractTestLibrary.CreateBillingProposal(BillingTemplate, Enum::"Service Partner"::Customer);

        // [THEN] Billing Lines must have correctly calculated service amount taking discount % from Service Commitment into account
        BillingLine.SetRange("Billing Template Code", BillingTemplate.Code);
        BillingLine.SetRange("Service Object No.", ServiceObject."No.");
        if BillingLine.FindSet() then
            repeat
                ExpectedServiceAmount := Round(BillingLine."Unit Price" * BillingLine."Service Obj. Quantity Decimal" * (1 - ServiceCommitment."Discount %" / 100), Currency."Amount Rounding Precision");
                AssertThat.AreEqual(ExpectedServiceAmount, BillingLine."Service Amount", 'Discount not transfered from Service Commitment to a Billing Line.');
            until BillingLine.Next() = 0;
    end;

    [Test]
    procedure CheckNextToDateCalculationToStartOfMonth()
    begin
        Initialize();

        CheckNextToDate("Period Calculation"::"Align to Start of Month", '1M', 20240128D, 20240227D);
        CheckNextToDate("Period Calculation"::"Align to Start of Month", '1M', 20240129D, 20240228D);
        CheckNextToDate("Period Calculation"::"Align to Start of Month", '1M', 20240130D, 20240228D);
        CheckNextToDate("Period Calculation"::"Align to Start of Month", '1M', 20240131D, 20240228D);
        CheckNextToDate("Period Calculation"::"Align to Start of Month", '1M', 20240229D, 20240328D);
        CheckNextToDate("Period Calculation"::"Align to Start of Month", '2M', 20240131D, 20240330D);
        CheckNextToDate("Period Calculation"::"Align to Start of Month", '2M', 20240229D, 20240428D);
        CheckNextToDate("Period Calculation"::"Align to Start of Month", '1Q', 20240131D, 20240429D);
        CheckNextToDate("Period Calculation"::"Align to Start of Month", '1Q', 20240229D, 20240528D);
        CheckNextToDate("Period Calculation"::"Align to Start of Month", '1Y', 20240131D, 20250130D);
        CheckNextToDate("Period Calculation"::"Align to Start of Month", '1Y', 20240229D, 20250227D);
    end;

    [Test]
    procedure CheckNextToDateCalculationToEndOfMonth()
    begin
        Initialize();

        CheckNextToDate("Period Calculation"::"Align to End of Month", '1M', 20230128D, 20230227D);
        CheckNextToDate("Period Calculation"::"Align to End of Month", '1M', 20230129D, 20230225D);
        CheckNextToDate("Period Calculation"::"Align to End of Month", '1M', 20230130D, 20230226D);
        CheckNextToDate("Period Calculation"::"Align to End of Month", '1M', 20230131D, 20230227D);
        CheckNextToDate("Period Calculation"::"Align to End of Month", '1M', 20230225D, 20230324D);
        CheckNextToDate("Period Calculation"::"Align to End of Month", '1M', 20230226D, 20230328D);
        CheckNextToDate("Period Calculation"::"Align to End of Month", '1M', 20230227D, 20230329D);
        CheckNextToDate("Period Calculation"::"Align to End of Month", '1M', 20230228D, 20230330D);
        CheckNextToDate("Period Calculation"::"Align to End of Month", '1M', 20230329D, 20230427D);
        CheckNextToDate("Period Calculation"::"Align to End of Month", '1M', 20230330D, 20230428D);
        CheckNextToDate("Period Calculation"::"Align to End of Month", '1M', 20230331D, 20230429D);
        CheckNextToDate("Period Calculation"::"Align to End of Month", '2M', 20230131D, 20230330D);
        CheckNextToDate("Period Calculation"::"Align to End of Month", '2M', 20230228D, 20230429D);
        CheckNextToDate("Period Calculation"::"Align to End of Month", '1Q', 20230131D, 20230429D);
        CheckNextToDate("Period Calculation"::"Align to End of Month", '1Q', 20230228D, 20230530D);
        CheckNextToDate("Period Calculation"::"Align to End of Month", '1Y', 20230131D, 20240130D);
        CheckNextToDate("Period Calculation"::"Align to End of Month", '1Y', 20220228D, 20230227D);
        CheckNextToDate("Period Calculation"::"Align to End of Month", '1Y', 20230228D, 20240228D);

        CheckNextToDate("Period Calculation"::"Align to End of Month", '1M', 20240128D, 20240227D);
        CheckNextToDate("Period Calculation"::"Align to End of Month", '1M', 20240129D, 20240226D);
        CheckNextToDate("Period Calculation"::"Align to End of Month", '1M', 20240130D, 20240227D);
        CheckNextToDate("Period Calculation"::"Align to End of Month", '1M', 20240131D, 20240228D);
        CheckNextToDate("Period Calculation"::"Align to End of Month", '1M', 20240225D, 20240324D);
        CheckNextToDate("Period Calculation"::"Align to End of Month", '1M', 20240226D, 20240325D);
        CheckNextToDate("Period Calculation"::"Align to End of Month", '1M', 20240227D, 20240328D);
        CheckNextToDate("Period Calculation"::"Align to End of Month", '1M', 20240228D, 20240329D);
        CheckNextToDate("Period Calculation"::"Align to End of Month", '1M', 20240229D, 20240330D);
        CheckNextToDate("Period Calculation"::"Align to End of Month", '1M', 20240329D, 20240427D);
        CheckNextToDate("Period Calculation"::"Align to End of Month", '1M', 20240330D, 20240428D);
        CheckNextToDate("Period Calculation"::"Align to End of Month", '1M', 20240331D, 20240429D);
        CheckNextToDate("Period Calculation"::"Align to End of Month", '2M', 20240131D, 20240330D);
        CheckNextToDate("Period Calculation"::"Align to End of Month", '2M', 20240229D, 20240429D);
        CheckNextToDate("Period Calculation"::"Align to End of Month", '1Q', 20240131D, 20240429D);
        CheckNextToDate("Period Calculation"::"Align to End of Month", '1Q', 20240229D, 20240530D);
        CheckNextToDate("Period Calculation"::"Align to End of Month", '1Y', 20240131D, 20250130D);
        CheckNextToDate("Period Calculation"::"Align to End of Month", '1Y', 20240229D, 20250227D);
        CheckNextToDate("Period Calculation"::"Align to End of Month", '1Y', 20240228D, 20250226D);
    end;

    [Test]
    procedure CheckNextToDateCalculationToEndOfMonthInLoop()
    var
        MonthFormula: DateFormula;
        YearFormula: DateFormula;
        DistanceToEndOfMonth: Integer;
        MonthForStart: Integer;
        MonthForLoop: Integer;
        Year: Integer;
        ExpectedNextToDate: Date;
        NextToDate: Date;
        StartDate: Date;
    begin
        Initialize();

        Evaluate(MonthFormula, '<1M>');
        Evaluate(YearFormula, '<1Y>');

        for Year := 2020 to 2030 do
            for DistanceToEndOfMonth := 0 to 5 do
                for MonthForStart := 1 to 12 do begin
                    StartDate := CalcDate('<CM>', DMY2Date(1, MonthForStart, Year)) - DistanceToEndOfMonth;
                    NextToDate := StartDate - 1;
                    ExpectedNextToDate := CalcDate('<1Y>', StartDate) - 1;
                    if DistanceToEndOfMonth < 3 then
                        ExpectedNextToDate := CalcDate('<CM>', ExpectedNextToDate) - DistanceToEndOfMonth - 1;
                    ServiceCommitment."Period Calculation" := ServiceCommitment."Period Calculation"::"Align to End of Month";
                    ServiceCommitment."Service Start Date" := StartDate;
                    for MonthForLoop := 1 to 12 do
                        NextToDate := BillingProposal.CalculateNextToDate(ServiceCommitment, MonthFormula, NextToDate + 1);
                    AssertThat.AreEqual(ExpectedNextToDate, NextToDate, 'Next Date not calculated correctly.');
                end;
    end;

    [Test]
    procedure CheckBillingLineAmountCalculationForCustomerAlignedToStartOfMonth()
    begin
        Initialize();

        CreateBillingProposalForCustomerContractUsingTempTemplate("Period Calculation"::"Align to Start of Month", '<1Y>', '<1M>', 20230101D, 20230131D);
        CheckBillingLineAmountAndPrice(100);

        CreateBillingProposalForCustomerContractUsingTempTemplate("Period Calculation"::"Align to Start of Month", '<1Y>', '<1M>', 20230111D, 20230210D);
        CheckBillingLineAmountAndPrice(100);

        CreateBillingProposalForCustomerContractUsingTempTemplate("Period Calculation"::"Align to Start of Month", '<1Y>', '<1M>', 20230131D, 20230228D);
        CheckBillingLineAmountAndPrice(103.226);

        CreateBillingProposalForCustomerContractUsingTempTemplate("Period Calculation"::"Align to Start of Month", '<1Y>', '<1M>', 20230129D, 20230227D);
        CheckBillingLineAmountAndPrice(100);

        CreateBillingProposalForCustomerContractUsingTempTemplate("Period Calculation"::"Align to Start of Month", '<1Y>', '<1M>', 20230228D, 20230331D);
        CheckBillingLineAmountAndPrice(112.903);

        CreateBillingProposalForCustomerContractUsingTempTemplate("Period Calculation"::"Align to Start of Month", '<1Y>', '<1M>', 20230228D, 20230330D);
        CheckBillingLineAmountAndPrice(109.677);

        CreateBillingProposalForCustomerContractUsingTempTemplate("Period Calculation"::"Align to Start of Month", '<1Y>', '<1M>', 20240229D, 20240328D);
        CheckBillingLineAmountAndPrice(100);

        CreateBillingProposalForCustomerContractUsingTempTemplate("Period Calculation"::"Align to Start of Month", '<1Y>', '<1M>', 20240131D, 20240330D);
        CheckBillingLineAmountAndPrice(200);

        CreateBillingProposalForCustomerContractUsingTempTemplate("Period Calculation"::"Align to Start of Month", '<1Y>', '<1Q>', 20230228D, 20230527D);
        CheckBillingLineAmountAndPrice(100);

        CreateBillingProposalForCustomerContractUsingTempTemplate("Period Calculation"::"Align to Start of Month", '<1Y>', '<1Q>', 20230228D, 20230531D);
        CheckBillingLineAmountAndPrice(104.348);

        CreateBillingProposalForCustomerContractUsingTempTemplate("Period Calculation"::"Align to Start of Month", '<1Y>', '<1M>', 20230101D, 20230228D);
        CheckBillingLineAmountAndPrice(200);

        CreateBillingProposalForCustomerContractUsingTempTemplate("Period Calculation"::"Align to Start of Month", '<1M>', '<1M>', 20230101D, 20230228D);
        CheckBillingLineAmountAndPrice(100);

        CreateBillingProposalForCustomerContractUsingTempTemplate("Period Calculation"::"Align to Start of Month", '<1Y>', '<1M>', 20230228D, 20230427D);
        CheckBillingLineAmountAndPrice(200);

        CreateBillingProposalForCustomerContractUsingTempTemplate("Period Calculation"::"Align to Start of Month", '<1M>', '<1M>', 20230228D, 20230427D);
        CheckBillingLineAmountAndPrice(100);

        CreateBillingProposalForCustomerContractUsingTempTemplate("Period Calculation"::"Align to Start of Month", '<1Y>', '<1M>', 20230131D, 20230330D);
        CheckBillingLineAmountAndPrice(200);

        CreateBillingProposalForCustomerContractUsingTempTemplate("Period Calculation"::"Align to Start of Month", '<1Y>', '<1M>', 20230101D, 20230115D);
        CheckBillingLineAmountAndPrice(48.387);

        CreateBillingProposalForCustomerContractUsingTempTemplate("Period Calculation"::"Align to Start of Month", '<1Y>', '<1M>', 20230131D, 20230328D);
        CheckBillingLineAmountAndPrice(193.548);

        CreateBillingProposalForCustomerContractUsingTempTemplate("Period Calculation"::"Align to Start of Month", '<1Y>', '<1M>', 20230101D, 20230214D);
        CheckBillingLineAmountAndPrice(150);

        CreateBillingProposalForCustomerContractUsingTempTemplate("Period Calculation"::"Align to Start of Month", '<1Y>', '<1M>', 20230101D, 20230114D);
        CheckBillingLineAmountAndPrice(45.161);

        CreateBillingProposalForCustomerContractUsingTempTemplate("Period Calculation"::"Align to Start of Month", '<1Y>', '<1M>', 20230201D, 20230214D);
        CheckBillingLineAmountAndPrice(50);

        CreateBillingProposalForCustomerContractUsingTempTemplate("Period Calculation"::"Align to Start of Month", '<1Y>', '<1M>', 20230131D, 20230301D);
        CheckBillingLineAmountAndPrice(106.452);

        CreateBillingProposalForCustomerContractUsingTempTemplate("Period Calculation"::"Align to Start of Month", '<1Y>', '<1Q>', 20230101D, 20230114D);
        CheckBillingLineAmountAndPrice(15.556);

        CreateBillingProposalForCustomerContractUsingTempTemplate("Period Calculation"::"Align to Start of Month", '<1Y>', '<1Q>', 20230112D, 20230223D);
        CheckBillingLineAmountAndPrice(47.778);

        CreateBillingProposalForCustomerContractUsingTempTemplate("Period Calculation"::"Align to Start of Month", '<1Y>', '<1Q>', 20230101D, 20230414D);
        CheckBillingLineAmountAndPrice(115.385);

        CreateBillingProposalForCustomerContractUsingTempTemplate("Period Calculation"::"Align to Start of Month", '<1Y>', '<1Q>', 20230102D, 20230415D);
        CheckBillingLineAmountAndPrice(115.385);

        CreateBillingProposalForCustomerContractUsingTempTemplate("Period Calculation"::"Align to Start of Month", '<1Y>', '<1Q>', 20230228D, 20230614D);
        CheckBillingLineAmountAndPrice(119.565);
    end;

    [Test]
    procedure CheckBillingLineAmountCalculationForCustomerAlignedToEndOfMonth()
    begin
        Initialize();

        CreateBillingProposalForCustomerContractUsingTempTemplate("Period Calculation"::"Align to End of Month", '<1Y>', '<1M>', 20230101D, 20230131D);
        CheckBillingLineAmountAndPrice(100);

        CreateBillingProposalForCustomerContractUsingTempTemplate("Period Calculation"::"Align to End of Month", '<1Y>', '<1M>', 20230111D, 20230210D);
        CheckBillingLineAmountAndPrice(100);

        CreateBillingProposalForCustomerContractUsingTempTemplate("Period Calculation"::"Align to End of Month", '<1Y>', '<1M>', 20230131D, 20230228D);
        CheckBillingLineAmountAndPrice(103.226);

        CreateBillingProposalForCustomerContractUsingTempTemplate("Period Calculation"::"Align to End of Month", '<1Y>', '<1M>', 20230129D, 20230227D);
        CheckBillingLineAmountAndPrice(106.452);

        CreateBillingProposalForCustomerContractUsingTempTemplate("Period Calculation"::"Align to End of Month", '<1Y>', '<1M>', 20230228D, 20230331D);
        CheckBillingLineAmountAndPrice(103.333);

        CreateBillingProposalForCustomerContractUsingTempTemplate("Period Calculation"::"Align to End of Month", '<1Y>', '<1M>', 20230228D, 20230330D);
        CheckBillingLineAmountAndPrice(100);

        CreateBillingProposalForCustomerContractUsingTempTemplate("Period Calculation"::"Align to End of Month", '<1Y>', '<1M>', 20240229D, 20240328D);
        CheckBillingLineAmountAndPrice(93.548);

        CreateBillingProposalForCustomerContractUsingTempTemplate("Period Calculation"::"Align to End of Month", '<1Y>', '<1M>', 20240131D, 20240330D);
        CheckBillingLineAmountAndPrice(200);

        CreateBillingProposalForCustomerContractUsingTempTemplate("Period Calculation"::"Align to End of Month", '<1Y>', '<1Q>', 20230228D, 20230530D);
        CheckBillingLineAmountAndPrice(100);

        CreateBillingProposalForCustomerContractUsingTempTemplate("Period Calculation"::"Align to End of Month", '<1Y>', '<1Q>', 20230228D, 20230531D);
        CheckBillingLineAmountAndPrice(101.087);

        CreateBillingProposalForCustomerContractUsingTempTemplate("Period Calculation"::"Align to End of Month", '<1Y>', '<1M>', 20230101D, 20230228D);
        CheckBillingLineAmountAndPrice(200);

        CreateBillingProposalForCustomerContractUsingTempTemplate("Period Calculation"::"Align to End of Month", '<1M>', '<1M>', 20230101D, 20230228D);
        CheckBillingLineAmountAndPrice(100);

        CreateBillingProposalForCustomerContractUsingTempTemplate("Period Calculation"::"Align to End of Month", '<1Y>', '<1M>', 20230228D, 20230429D);
        CheckBillingLineAmountAndPrice(200);

        CreateBillingProposalForCustomerContractUsingTempTemplate("Period Calculation"::"Align to End of Month", '<1M>', '<1M>', 20230228D, 20230429D);
        CheckBillingLineAmountAndPrice(100);

        CreateBillingProposalForCustomerContractUsingTempTemplate("Period Calculation"::"Align to End of Month", '<1Y>', '<1M>', 20230101D, 20230115D);
        CheckBillingLineAmountAndPrice(48.387);

        CreateBillingProposalForCustomerContractUsingTempTemplate("Period Calculation"::"Align to End of Month", '<1Y>', '<1M>', 20230101D, 20230214D);
        CheckBillingLineAmountAndPrice(150);

        CreateBillingProposalForCustomerContractUsingTempTemplate("Period Calculation"::"Align to End of Month", '<1Y>', '<1M>', 20230101D, 20230114D);
        CheckBillingLineAmountAndPrice(45.161);

        CreateBillingProposalForCustomerContractUsingTempTemplate("Period Calculation"::"Align to End of Month", '<1Y>', '<1M>', 20230201D, 20230214D);
        CheckBillingLineAmountAndPrice(50);

        CreateBillingProposalForCustomerContractUsingTempTemplate("Period Calculation"::"Align to End of Month", '<1Y>', '<1M>', 20230131D, 20230301D);
        CheckBillingLineAmountAndPrice(106.452);

        CreateBillingProposalForCustomerContractUsingTempTemplate("Period Calculation"::"Align to End of Month", '<1Y>', '<1Q>', 20230101D, 20230114D);
        CheckBillingLineAmountAndPrice(15.556);

        CreateBillingProposalForCustomerContractUsingTempTemplate("Period Calculation"::"Align to End of Month", '<1Y>', '<1Q>', 20230112D, 20230223D);
        CheckBillingLineAmountAndPrice(47.778);

        CreateBillingProposalForCustomerContractUsingTempTemplate("Period Calculation"::"Align to End of Month", '<1Y>', '<1Q>', 20230101D, 20230414D);
        CheckBillingLineAmountAndPrice(115.385);

        CreateBillingProposalForCustomerContractUsingTempTemplate("Period Calculation"::"Align to End of Month", '<1Y>', '<1Q>', 20230102D, 20230415D);
        CheckBillingLineAmountAndPrice(115.385);

        CreateBillingProposalForCustomerContractUsingTempTemplate("Period Calculation"::"Align to End of Month", '<1Y>', '<1Q>', 20230228D, 20230614D);
        CheckBillingLineAmountAndPrice(116.304);
    end;

    [Test]
    [HandlerFunctions('CreateBillingDocsCustomerPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure CheckBillingLinesArchiving()
    begin
        Initialize();

        // Check that Billing Lines are being archived when posting Sales Invoice
        BillingLinesArchiveSetup();
        //Check Archived Billing Lines exist
        CustomerContractLine.SetRange("Contract No.", CustomerContract."No.");
        CustomerContractLine.FindSet();
        repeat
            TestArchivedBillingLinesExist(CustomerContractLine."Contract No.", CustomerContractLine."Line No.", Enum::"Service Partner"::Customer);
            ContractTestLibrary.FilterBillingLineArchiveOnContractLine(BillingLineArchive, CustomerContractLine."Contract No.", CustomerContractLine."Line No.", Enum::"Service Partner"::Customer);
            BillingLineArchive.FindSet();
            repeat
                BillingLineArchive.TestField("Document Type", BillingLineArchive."Document Type"::Invoice);
                BillingLineArchive.TestField("Document No.", PostedDocumentNo);
            until BillingLineArchive.Next() = 0;
        until CustomerContractLine.Next() = 0;
    end;

    [Test]
    [HandlerFunctions('CreateBillingDocsCustomerPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure CheckDeleteArchivedBillingLinesCustomerContractFirst()
    begin
        Initialize();

        // Check that Archived Billing Lines are deleted only when both related Customer Contract Line and posted sales documents have been deleted
        // This test deletes the Customer Contract Line connected to Archived Billing Lines first
        BillingLinesArchiveSetup();

        //Check that the Archived Billing Lines are deleted correctly after the posted sales document has been deleted
        // - should not be deleted while posted sales document exist
        CustomerContractLine.SetRange("Contract No.", CustomerContract."No.");
        CustomerContractLine.FindFirst();
        TestArchivedBillingLinesExist(CustomerContractLine."Contract No.", CustomerContractLine."Line No.", Enum::"Service Partner"::Customer);
        TempDeletedCustomerContractLine := CustomerContractLine;
        CustomerContractLine.Delete(true);

        CustomerContractLine.Next();
        TestArchivedBillingLinesExist(CustomerContractLine."Contract No.", CustomerContractLine."Line No.", Enum::"Service Partner"::Customer);
        TestArchivedBillingLinesExist(TempDeletedCustomerContractLine."Contract No.", TempDeletedCustomerContractLine."Line No.", Enum::"Service Partner"::Customer);
        DeletePostedSalesDocument();
        TestArchivedBillingLinesExist(CustomerContractLine."Contract No.", CustomerContractLine."Line No.", Enum::"Service Partner"::Customer);
        asserterror TestArchivedBillingLinesExist(TempDeletedCustomerContractLine."Contract No.", TempDeletedCustomerContractLine."Line No.", Enum::"Service Partner"::Customer);
    end;

    [Test]
    [HandlerFunctions('CreateBillingDocsCustomerPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure CheckDeleteArchivedBillingLinesPostedInvoiceFirst()
    begin
        Initialize();

        // Check that Archived Billing Lines are deleted only when both related Customer Contract Line and posted sales documents have been deleted
        // This test deletes the posted sales document connected to Archived Billing Lines first
        BillingLinesArchiveSetup();

        //Check that the Archived Billing Lines are deleted correctly when deleting Customer Contract Line
        // - posted sales document should be deleted first
        DeletePostedSalesDocument();
        CustomerContractLine.SetRange("Contract No.", CustomerContract."No.");
        CustomerContractLine.FindFirst();
        TestArchivedBillingLinesExist(CustomerContractLine."Contract No.", CustomerContractLine."Line No.", Enum::"Service Partner"::Customer);
        TempDeletedCustomerContractLine := CustomerContractLine;
        CustomerContractLine.Delete(true);
        asserterror TestArchivedBillingLinesExist(TempDeletedCustomerContractLine."Contract No.", TempDeletedCustomerContractLine."Line No.", Enum::"Service Partner"::Customer);
        CustomerContractLine.Next();
        TestArchivedBillingLinesExist(CustomerContractLine."Contract No.", CustomerContractLine."Line No.", Enum::"Service Partner"::Customer);
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure CheckRecurringBillingPageRecords()
    begin
        Initialize();

        RecurringBillingPageSetupForCustomer();

        BillingProposal.InitTempTable(TempBillingLine, Enum::"Contract Billing Grouping"::None);
        CheckTempBillingLineRecords();

        BillingProposal.InitTempTable(TempBillingLine, Enum::"Contract Billing Grouping"::Contract);
        CheckTempBillingLineRecords();

        BillingProposal.InitTempTable(TempBillingLine, Enum::"Contract Billing Grouping"::"Contract Partner");
        CheckTempBillingLineRecords();
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure CheckRecurringBillingPageGroupingLines()
    begin
        Initialize();

        RecurringBillingPageSetupForCustomer();
        BillingProposal.InitTempTable(TempBillingLine, Enum::"Contract Billing Grouping"::None);
        TempBillingLine.SetRange(Indent, 0);
        AssertThat.IsTrue(TempBillingLine.IsEmpty(), 'Grouping Line should not be found.');

        BillingProposal.InitTempTable(TempBillingLine, Enum::"Contract Billing Grouping"::Contract);

        TempBillingLine.SetFilter("Contract No.", '%1|%2', CustomerContract."No.", CustomerContract2."No.");
        TempBillingLine.FindFirst();
        AssertThat.AreEqual(CustomerContract."No.", TempBillingLine."Contract No.", 'Contract No. is not set correctly in grouping line (Group by Contract).');
        AssertThat.AreEqual(Customer."No.", TempBillingLine."Partner No.", 'Partner No. is not set correctly in grouping line (Group by Contract).');
        AssertThat.AreEqual(GetBillingLineServiceAmount(Enum::"Contract Billing Grouping"::Contract, CustomerContract."No."), TempBillingLine."Service Amount", 'Service Amount not calculated correctly in grouping line (Group by Contract).');

        TempBillingLine.Next();
        AssertThat.AreEqual(CustomerContract2."No.", TempBillingLine."Contract No.", 'Contract No. is not set correctly in grouping line (Group by Contract).');
        AssertThat.AreEqual(Customer2."No.", TempBillingLine."Partner No.", 'Partner No. is not set correctly in grouping line (Group by Contract).');
        AssertThat.AreEqual(GetBillingLineServiceAmount(Enum::"Contract Billing Grouping"::Contract, CustomerContract2."No."), TempBillingLine."Service Amount", 'Service Amount not calculated correctly in grouping line (Group by Contract).');

        TempBillingLine.SetRange("Contract No.");
        BillingProposal.InitTempTable(TempBillingLine, Enum::"Contract Billing Grouping"::"Contract Partner");
        TempBillingLine.SetFilter("Partner No.", '%1|%2', Customer."No.", Customer2."No.");
        TempBillingLine.FindFirst();
        AssertThat.AreEqual('', TempBillingLine."Contract No.", 'Contract No. is not set correctly in grouping line (Group by "Contract Partner").');
        AssertThat.AreEqual(Customer."No.", TempBillingLine."Partner No.", 'Partner No. is not set correctly in grouping line (Group by "Contract Partner").');
        AssertThat.AreEqual(GetBillingLineServiceAmount(Enum::"Contract Billing Grouping"::"Contract Partner", Customer."No."), TempBillingLine."Service Amount", 'Service Amount not calculated correctly in grouping line (Group by "Contract Partner").');

        TempBillingLine.Next();
        AssertThat.AreEqual('', TempBillingLine."Contract No.", 'Contract No. is not set correctly in grouping line (Group by "Contract Partner").');
        AssertThat.AreEqual(Customer2."No.", TempBillingLine."Partner No.", 'Partner No. is not set correctly in grouping line (Group by "Contract Partner").');
        AssertThat.AreEqual(GetBillingLineServiceAmount(Enum::"Contract Billing Grouping"::"Contract Partner", Customer2."No."), TempBillingLine."Service Amount", 'Service Amount not calculated correctly in grouping line (Group by "Contract Partner").');
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure CheckBillingLineUpdateRequiredOnModifyCustomerContractLine()
    var
        CustomerContractLineSubPage: TestPage "Customer Contract Line Subp.";
        DiscountPercent: Decimal;
        DiscountAmount: Decimal;
        ServiceAmount: Decimal;
    begin
        Initialize();

        ContractTestLibrary.CreateCustomer(Customer);
        ContractTestLibrary.CreateCustomerContractAndCreateContractLines(CustomerContract, ServiceObject, Customer."No.");
        ContractTestLibrary.CreateBillingProposal(BillingTemplate, Enum::"Service Partner"::Customer);
        BillingLine.Reset();
        BillingLine.SetRange("Billing Template Code", BillingTemplate.Code);
        BillingLine.FindFirst();
        DiscountPercent := BillingLine."Discount %" + 1;
        DiscountAmount := BillingLine."Unit Price" * BillingLine."Discount %" + 1;
        ServiceAmount := BillingLine."Service Amount" - 1;
        CustomerContractLine.SetRange("Contract No.", BillingLine."Contract No.");
        CustomerContractLine.SetRange("Line No.", BillingLine."Contract Line No.");
        CustomerContractLine.FindFirst();

        CustomerContractLineSubPage.OpenEdit();

        CustomerContractLineSubPage.GoToRecord(CustomerContractLine);
        CustomerContractLineSubPage."Service Amount".SetValue(ServiceAmount);
        TestBillingLineUpdateRequiredSetAndReset(CustomerContractLine."Contract No.", CustomerContractLine."Line No.");
        BillingProposal.CreateBillingProposal(BillingLine."Billing Template Code", BillingLine."Billing from", BillingLine."Billing to");

        CustomerContractLineSubPage.GoToRecord(CustomerContractLine);
        CustomerContractLineSubPage."Discount Amount".SetValue(DiscountAmount);
        TestBillingLineUpdateRequiredSetAndReset(CustomerContractLine."Contract No.", CustomerContractLine."Line No.");
        BillingProposal.CreateBillingProposal(BillingLine."Billing Template Code", BillingLine."Billing from", BillingLine."Billing to");

        CustomerContractLineSubPage.GoToRecord(CustomerContractLine);
        CustomerContractLineSubPage."Discount %".SetValue(DiscountPercent);
        TestBillingLineUpdateRequiredSetAndReset(CustomerContractLine."Contract No.", CustomerContractLine."Line No.");
        BillingProposal.CreateBillingProposal(BillingLine."Billing Template Code", BillingLine."Billing from", BillingLine."Billing to");

        CustomerContractLineSubPage.GoToRecord(CustomerContractLine);
        Evaluate(BillingRhythm, '2M');
        CustomerContractLineSubPage."Billing Rhythm".SetValue(BillingRhythm);
        TestBillingLineUpdateRequiredSetAndReset(CustomerContractLine."Contract No.", CustomerContractLine."Line No.");

        CustomerContractLineSubPage.GoToRecord(CustomerContractLine);
        CustomerContractLineSubPage."Service Commitment Description".SetValue(LibraryRandom.RandText(100));
        TestBillingLineUpdateRequiredSetAndReset(CustomerContractLine."Contract No.", CustomerContractLine."Line No.");
    end;

    [Test]
    procedure CreateBillingTemplateForVendor()
    var
        FilterText: Text;
    begin
        Initialize();

        VendorContract.SetRange("Contract Type", LibraryRandom.RandText(MaxStrLen(VendorContract."Contract Type")));
        CreateRecurringBillingTemplateSetupForVendorContract('<-CM>', '<CM>', VendorContract.GetView());
        FilterText := BillingTemplate.ReadFilter(BillingTemplate.FieldNo(Filter));
        AssertThat.AreEqual(VendorContract.GetView(), FilterText, 'Billing Template vendor contract filter failed.');
    end;

    [Test]
    [HandlerFunctions('BillingTemplateModalPageHandler')]
    procedure CheckBillingDateCalculationFromVendorBillingTemplate()
    var
        BillingDateValue: Date;
        BillingToDateValue: Date;
        ExpectedBillingDate: Date;
        ExpectedBillingToDate: Date;
    begin
        Initialize();

        CreateRecurringBillingTemplateSetupForVendorContract('<-CM>', '<CM>', '');

        RecurringBillingPage.OpenEdit();
        RecurringBillingPage.BillingTemplateField.Lookup();

        Evaluate(BillingDateValue, RecurringBillingPage.BillingDateField.Value());
        Evaluate(BillingToDateValue, RecurringBillingPage.BillingToDateField.Value());
        ExpectedBillingDate := CalcDate('<-CM>', WorkDate());
        ExpectedBillingToDate := CalcDate('<CM>', WorkDate());

        AssertThat.AreEqual(ExpectedBillingDate, BillingDateValue, 'Expected Billing Date calculation failed.');
        AssertThat.AreEqual(ExpectedBillingToDate, BillingToDateValue, 'Expected Billing to Date calculation failed.');
    end;

    [Test]
    procedure CheckCreateBillingProposalForVendorContract()
    begin
        Initialize();

        CreateBillingProposalForVendorContractUsingRealTemplate();

        BillingLine.SetRange("Billing Template Code", BillingTemplate.Code);
        BillingLine.SetRange("Service Object No.", ServiceObject."No.");
        if BillingLine.FindSet() then
            repeat
                ServiceCommitment.Get(BillingLine."Service Commitment Entry No.");
                AssertThat.AreEqual(BillingLine."Billing Template Code", BillingTemplate.Code, BillingLine."Billing Template Code");
                AssertThat.AreEqual(BillingLine."Service Object No.", ServiceCommitment."Service Object No.", BillingLine.FieldName("Service Object No."));
                AssertThat.AreEqual(BillingLine."Service Commitment Entry No.", ServiceCommitment."Entry No.", BillingLine.FieldName("Service Commitment Entry No."));
                AssertThat.AreEqual(BillingLine."Service Commitment Description", ServiceCommitment.Description, BillingLine.FieldName("Service Commitment Description"));
                AssertThat.AreEqual(BillingLine."Service Start Date", ServiceCommitment."Service Start Date", BillingLine.FieldName("Service Start Date"));
                AssertThat.AreEqual(BillingLine."Service End Date", ServiceCommitment."Service End Date", BillingLine.FieldName("Service End Date"));
                AssertThat.AreEqual(BillingLine."Billing Rhythm", ServiceCommitment."Billing Rhythm", BillingLine.FieldName("Billing Rhythm"));
                AssertThat.AreEqual(BillingLine."Discount %", ServiceCommitment."Discount %", BillingLine.FieldName("Discount %"));
                AssertThat.AreEqual(BillingLine."Service Obj. Quantity Decimal", ServiceObject."Quantity Decimal", BillingLine.FieldName("Service Obj. Quantity Decimal"));
            until BillingLine.Next() = 0
        else
            Error(BillingProposalNotCreatedErr);
    end;

    [Test]
    procedure CheckCreateBillingProposalForVendorContractWithEmptyBillingToDate()
    begin
        Initialize();

        CreateVendorContract('<12M>', '<1M>');
        CreateRecurringBillingTemplateSetupForVendorContract('<2M-CM>', '<8M+CM>', VendorContract.GetView());
        ContractTestLibrary.CreateBillingProposal(BillingTemplate, Enum::"Service Partner"::Vendor, WorkDate(), 0D);
        BillingLine.SetRange("Billing Template Code", BillingTemplate.Code);
        BillingLine.SetRange("Service Object No.", ServiceObject."No.");
        BillingLine.FindSet();
    end;

    [Test]
    [HandlerFunctions('StrMenuHandlerClearBillingProposal')]
    procedure CheckClearBillingProposalForVendorContract()
    begin
        Initialize();

        CreateBillingProposalForVendorContractUsingRealTemplate();

        BillingLine.SetRange("Billing Template Code", BillingTemplate.Code);
        BillingLine.SetRange("Service Object No.", ServiceObject."No.");
        if not BillingLine.FindSet() then
            Error(BillingProposalNotCreatedErr);

        StrMenuHandlerStep := 1;
        BillingProposal.DeleteBillingProposal(BillingTemplate.Code);

        BillingLine.Reset();
        BillingLine.SetRange("Billing Template Code", BillingTemplate.Code);
        AssertThat.AreEqual(BillingLine.IsEmpty(), true, 'Delete Billing proposal failed.');

        ContractTestLibrary.CreateBillingProposal(BillingTemplate, Enum::"Service Partner"::Vendor);

        BillingLine.SetRange("Billing Template Code", BillingTemplate.Code);
        BillingLine.SetRange("Service Object No.", ServiceObject."No.");
        if not BillingLine.FindSet() then
            Error(BillingProposalNotCreatedErr);

        StrMenuHandlerStep := 2;
        BillingProposal.DeleteBillingProposal(BillingTemplate.Code);

        BillingLine.Reset();
        BillingLine.SetRange("Billing Template Code", BillingTemplate.Code);
        AssertThat.AreEqual(BillingLine.IsEmpty(), true, 'Delete Billing proposal failed.');
    end;

    [Test]
    procedure CheckChangeBillingToDateForVendor()
    begin
        Initialize();

        CreateBillingProposalForVendorContractUsingRealTemplate();

        FindFirstServiceCommitment();

        BillingLine.SetRange("Billing Template Code", BillingTemplate.Code);
        BillingLine.SetRange("Service Object No.", ServiceObject."No.");
        BillingLine.SetRange("Billing to", CalcDate('<-1D>', ServiceCommitment."Next Billing Date"));
        BillingLine.FindFirst();
        BillingProposal.UpdateBillingToDate(BillingLine, CalcDate('<+3D>', BillingLine."Billing to"));
        BillingLine.SetRange("Billing to");
        BillingLine.FindFirst();
        asserterror BillingProposal.UpdateBillingToDate(BillingLine, CalcDate('<+3D>', BillingLine."Billing to"));
    end;

    [Test]
    procedure CheckDeleteBillingLineForVendorContract()
    begin
        Initialize();

        CreateBillingProposalForVendorContractUsingRealTemplate();

        FindFirstServiceCommitment();
        Commit(); // retain data after asserterror
        BillingLine.SetRange("Billing Template Code", BillingTemplate.Code);
        BillingLine.SetRange("Service Object No.", ServiceObject."No.");
        if BillingLine.FindSet() then
            repeat
                if (CalcDate('<-1D>', ServiceCommitment."Next Billing Date") = BillingLine."Billing to") then
                    BillingLine.Delete(true)
                else
                    asserterror BillingLine.Delete(true);
            until BillingLine.Next() = 0
        else
            Error(BillingProposalNotCreatedErr);
    end;

    [Test]
    procedure CheckLineDiscountTransferedToBillingLineForVendorContract()
    var
        ExpectedServiceAmount: Decimal;
    begin
        // [SCENARIO] When the "Discount %" is entered on a Service Commitment it should be transferred to a billing line when creating billing proposal.
        Initialize();

        // [GIVEN] Contract has been created
        CreateVendorContract('<1M>', '<12M>');

        // [GIVEN] "Discount %" is updated on a Service Commitment
        FindFirstServiceCommitment();
        ServiceCommitment."Discount %" := LibraryRandom.RandDec(50, 2);
        ServiceCommitment.Modify(false);

        // [WHEN] The billing proposal has been created
        CreateRecurringBillingTemplateSetupForVendorContract('<2M-CM>', '<8M+CM>', VendorContract.GetView());
        ContractTestLibrary.CreateBillingProposal(BillingTemplate, Enum::"Service Partner"::Vendor);

        // [THEN] Billing Lines must have correctly calculated service amount taking discount % from Service Commitment into account
        BillingLine.SetRange("Billing Template Code", BillingTemplate.Code);
        BillingLine.SetRange("Service Object No.", ServiceObject."No.");
        if BillingLine.FindSet() then
            repeat
                ExpectedServiceAmount := Round(BillingLine."Unit Price" * BillingLine."Service Obj. Quantity Decimal" * (1 - ServiceCommitment."Discount %" / 100), Currency."Amount Rounding Precision");
                AssertThat.AreEqual(ExpectedServiceAmount, BillingLine."Service Amount", 'Discount not transfered from Service Commitment to a Billing Line.');
            until BillingLine.Next() = 0
    end;

    [Test]
    procedure CheckBillingLineAmountCalculationForVendorAlignedToStartOfMonth()
    begin
        Initialize();

        CreateBillingProposalForVendorContractUsingTempTemplate("Period Calculation"::"Align to Start of Month", '<1Y>', '<1M>', 20230101D, 20230131D);
        CheckBillingLineAmountAndPrice(50);

        CreateBillingProposalForVendorContractUsingTempTemplate("Period Calculation"::"Align to Start of Month", '<1Y>', '<1M>', 20230111D, 20230210D);
        CheckBillingLineAmountAndPrice(50);

        CreateBillingProposalForVendorContractUsingTempTemplate("Period Calculation"::"Align to Start of Month", '<1Y>', '<1M>', 20230131D, 20230228D);
        CheckBillingLineAmountAndPrice(51.613);

        CreateBillingProposalForVendorContractUsingTempTemplate("Period Calculation"::"Align to Start of Month", '<1Y>', '<1M>', 20230129D, 20230227D);
        CheckBillingLineAmountAndPrice(50);

        CreateBillingProposalForVendorContractUsingTempTemplate("Period Calculation"::"Align to Start of Month", '<1Y>', '<1M>', 20230228D, 20230331D);
        CheckBillingLineAmountAndPrice(56.452);

        CreateBillingProposalForVendorContractUsingTempTemplate("Period Calculation"::"Align to Start of Month", '<1Y>', '<1M>', 20230228D, 20230330D);
        CheckBillingLineAmountAndPrice(54.839);

        CreateBillingProposalForVendorContractUsingTempTemplate("Period Calculation"::"Align to Start of Month", '<1Y>', '<1M>', 20240229D, 20240328D);
        CheckBillingLineAmountAndPrice(50);

        CreateBillingProposalForVendorContractUsingTempTemplate("Period Calculation"::"Align to Start of Month", '<1Y>', '<1M>', 20240131D, 20240330D);
        CheckBillingLineAmountAndPrice(100);

        CreateBillingProposalForVendorContractUsingTempTemplate("Period Calculation"::"Align to Start of Month", '<1Y>', '<1Q>', 20230228D, 20230527D);
        CheckBillingLineAmountAndPrice(50);

        CreateBillingProposalForVendorContractUsingTempTemplate("Period Calculation"::"Align to Start of Month", '<1Y>', '<1Q>', 20230228D, 20230531D);
        CheckBillingLineAmountAndPrice(52.174);

        CreateBillingProposalForVendorContractUsingTempTemplate("Period Calculation"::"Align to Start of Month", '<1Y>', '<1M>', 20230101D, 20230228D);
        CheckBillingLineAmountAndPrice(100);

        CreateBillingProposalForVendorContractUsingTempTemplate("Period Calculation"::"Align to Start of Month", '<1M>', '<1M>', 20230101D, 20230228D);
        CheckBillingLineAmountAndPrice(50);

        CreateBillingProposalForVendorContractUsingTempTemplate("Period Calculation"::"Align to Start of Month", '<1Y>', '<1M>', 20230228D, 20230427D);
        CheckBillingLineAmountAndPrice(100);

        CreateBillingProposalForVendorContractUsingTempTemplate("Period Calculation"::"Align to Start of Month", '<1M>', '<1M>', 20230228D, 20230427D);
        CheckBillingLineAmountAndPrice(50);

        CreateBillingProposalForVendorContractUsingTempTemplate("Period Calculation"::"Align to Start of Month", '<1Y>', '<1M>', 20230131D, 20230330D);
        CheckBillingLineAmountAndPrice(100);

        CreateBillingProposalForVendorContractUsingTempTemplate("Period Calculation"::"Align to Start of Month", '<1Y>', '<1M>', 20230101D, 20230115D);
        CheckBillingLineAmountAndPrice(24.194);

        CreateBillingProposalForVendorContractUsingTempTemplate("Period Calculation"::"Align to Start of Month", '<1Y>', '<1M>', 20230131D, 20230328D);
        CheckBillingLineAmountAndPrice(96.774);

        CreateBillingProposalForVendorContractUsingTempTemplate("Period Calculation"::"Align to Start of Month", '<1Y>', '<1M>', 20230101D, 20230214D);
        CheckBillingLineAmountAndPrice(75);

        CreateBillingProposalForVendorContractUsingTempTemplate("Period Calculation"::"Align to Start of Month", '<1Y>', '<1M>', 20230101D, 20230114D);
        CheckBillingLineAmountAndPrice(22.581);

        CreateBillingProposalForVendorContractUsingTempTemplate("Period Calculation"::"Align to Start of Month", '<1Y>', '<1M>', 20230201D, 20230214D);
        CheckBillingLineAmountAndPrice(25);

        CreateBillingProposalForVendorContractUsingTempTemplate("Period Calculation"::"Align to Start of Month", '<1Y>', '<1M>', 20230131D, 20230301D);
        CheckBillingLineAmountAndPrice(53.226);

        CreateBillingProposalForVendorContractUsingTempTemplate("Period Calculation"::"Align to Start of Month", '<1Y>', '<1Q>', 20230101D, 20230114D);
        CheckBillingLineAmountAndPrice(7.778);

        CreateBillingProposalForVendorContractUsingTempTemplate("Period Calculation"::"Align to Start of Month", '<1Y>', '<1Q>', 20230112D, 20230223D);
        CheckBillingLineAmountAndPrice(23.889);

        CreateBillingProposalForVendorContractUsingTempTemplate("Period Calculation"::"Align to Start of Month", '<1Y>', '<1Q>', 20230101D, 20230414D);
        CheckBillingLineAmountAndPrice(57.692);

        CreateBillingProposalForVendorContractUsingTempTemplate("Period Calculation"::"Align to Start of Month", '<1Y>', '<1Q>', 20230102D, 20230415D);
        CheckBillingLineAmountAndPrice(57.692);

        CreateBillingProposalForVendorContractUsingTempTemplate("Period Calculation"::"Align to Start of Month", '<1Y>', '<1Q>', 20230228D, 20230614D);
        CheckBillingLineAmountAndPrice(59.783);
    end;

    [Test]
    procedure CheckBillingLineAmountCalculationForVendorAlignedToEndOfMonth()
    begin
        Initialize();

        CreateBillingProposalForVendorContractUsingTempTemplate("Period Calculation"::"Align to End of Month", '<1Y>', '<1M>', 20230101D, 20230131D);
        CheckBillingLineAmountAndPrice(50);

        CreateBillingProposalForVendorContractUsingTempTemplate("Period Calculation"::"Align to End of Month", '<1Y>', '<1M>', 20230111D, 20230210D);
        CheckBillingLineAmountAndPrice(50);

        CreateBillingProposalForVendorContractUsingTempTemplate("Period Calculation"::"Align to End of Month", '<1Y>', '<1M>', 20230131D, 20230228D);
        CheckBillingLineAmountAndPrice(51.613);

        CreateBillingProposalForVendorContractUsingTempTemplate("Period Calculation"::"Align to End of Month", '<1Y>', '<1M>', 20230129D, 20230227D);
        CheckBillingLineAmountAndPrice(53.226);

        CreateBillingProposalForVendorContractUsingTempTemplate("Period Calculation"::"Align to End of Month", '<1Y>', '<1M>', 20230228D, 20230331D);
        CheckBillingLineAmountAndPrice(51.667);

        CreateBillingProposalForVendorContractUsingTempTemplate("Period Calculation"::"Align to End of Month", '<1Y>', '<1M>', 20230228D, 20230330D);
        CheckBillingLineAmountAndPrice(50);

        CreateBillingProposalForVendorContractUsingTempTemplate("Period Calculation"::"Align to End of Month", '<1Y>', '<1M>', 20240229D, 20240328D);
        CheckBillingLineAmountAndPrice(46.774);

        CreateBillingProposalForVendorContractUsingTempTemplate("Period Calculation"::"Align to End of Month", '<1Y>', '<1M>', 20240131D, 20240330D);
        CheckBillingLineAmountAndPrice(100);

        CreateBillingProposalForVendorContractUsingTempTemplate("Period Calculation"::"Align to End of Month", '<1Y>', '<1Q>', 20230228D, 20230530D);
        CheckBillingLineAmountAndPrice(50);

        CreateBillingProposalForVendorContractUsingTempTemplate("Period Calculation"::"Align to End of Month", '<1Y>', '<1Q>', 20230228D, 20230531D);
        CheckBillingLineAmountAndPrice(50.543);

        CreateBillingProposalForVendorContractUsingTempTemplate("Period Calculation"::"Align to End of Month", '<1Y>', '<1M>', 20230101D, 20230228D);
        CheckBillingLineAmountAndPrice(100);

        CreateBillingProposalForVendorContractUsingTempTemplate("Period Calculation"::"Align to End of Month", '<1M>', '<1M>', 20230101D, 20230228D);
        CheckBillingLineAmountAndPrice(50);

        CreateBillingProposalForVendorContractUsingTempTemplate("Period Calculation"::"Align to End of Month", '<1Y>', '<1M>', 20230228D, 20230429D);
        CheckBillingLineAmountAndPrice(100);

        CreateBillingProposalForVendorContractUsingTempTemplate("Period Calculation"::"Align to End of Month", '<1M>', '<1M>', 20230228D, 20230429D);
        CheckBillingLineAmountAndPrice(50);

        CreateBillingProposalForVendorContractUsingTempTemplate("Period Calculation"::"Align to End of Month", '<1Y>', '<1M>', 20230101D, 20230115D);
        CheckBillingLineAmountAndPrice(24.194);

        CreateBillingProposalForVendorContractUsingTempTemplate("Period Calculation"::"Align to End of Month", '<1Y>', '<1M>', 20230101D, 20230214D);
        CheckBillingLineAmountAndPrice(75);

        CreateBillingProposalForVendorContractUsingTempTemplate("Period Calculation"::"Align to End of Month", '<1Y>', '<1M>', 20230101D, 20230114D);
        CheckBillingLineAmountAndPrice(22.581);

        CreateBillingProposalForVendorContractUsingTempTemplate("Period Calculation"::"Align to End of Month", '<1Y>', '<1M>', 20230201D, 20230214D);
        CheckBillingLineAmountAndPrice(25);

        CreateBillingProposalForVendorContractUsingTempTemplate("Period Calculation"::"Align to End of Month", '<1Y>', '<1M>', 20230131D, 20230301D);
        CheckBillingLineAmountAndPrice(53.226);

        CreateBillingProposalForVendorContractUsingTempTemplate("Period Calculation"::"Align to End of Month", '<1Y>', '<1Q>', 20230101D, 20230114D);
        CheckBillingLineAmountAndPrice(7.778);

        CreateBillingProposalForVendorContractUsingTempTemplate("Period Calculation"::"Align to End of Month", '<1Y>', '<1Q>', 20230112D, 20230223D);
        CheckBillingLineAmountAndPrice(23.889);

        CreateBillingProposalForVendorContractUsingTempTemplate("Period Calculation"::"Align to End of Month", '<1Y>', '<1Q>', 20230101D, 20230414D);
        CheckBillingLineAmountAndPrice(57.692);

        CreateBillingProposalForVendorContractUsingTempTemplate("Period Calculation"::"Align to End of Month", '<1Y>', '<1Q>', 20230102D, 20230415D);
        CheckBillingLineAmountAndPrice(57.692);

        CreateBillingProposalForVendorContractUsingTempTemplate("Period Calculation"::"Align to End of Month", '<1Y>', '<1Q>', 20230228D, 20230614D);
        CheckBillingLineAmountAndPrice(58.152);
    end;

    [Test]
    internal procedure GetSalesDocumentTypeFromBillingLineForContractNo()
    var
        ContractNo: Code[20];
    begin
        Initialize();

        // if Sum of Billing Lines for Contract is Positive = Invoice, Negative = Credit Memo
        // Invoice
        ContractNo := LibraryUtility.GenerateGUID();
        MockBillingLineForContractWithAmount(ContractNo, LibraryRandom.RandDecInRange(60, 100, 2));
        MockBillingLineForContractWithAmount(ContractNo, -LibraryRandom.RandDecInRange(1, 50, 2));
        BillingLine.SetRange("Contract No.", ContractNo);
        AssertThat.AreEqual("Sales Document Type"::Invoice, BillingLine.GetSalesDocumentTypeForContractNo(), 'Sales Document Type is not calculated correctly for Invoice.');
        // Credit Memo
        ContractNo := LibraryUtility.GenerateGUID();
        MockBillingLineForContractWithAmount(ContractNo, -LibraryRandom.RandDecInRange(60, 100, 2));
        MockBillingLineForContractWithAmount(ContractNo, LibraryRandom.RandDecInRange(1, 50, 2));
        BillingLine.SetRange("Contract No.", ContractNo);
        AssertThat.AreEqual("Sales Document Type"::"Credit Memo", BillingLine.GetSalesDocumentTypeForContractNo(), 'Sales Document Type is not calculated correctly for Credit Memo.');
    end;

    [Test]
    internal procedure GetPurchaseDocumentTypeFromBillingLineForContractNo()
    var
        ContractNo: Code[20];
    begin
        Initialize();

        // if Sum of Billing Lines for Contract is Positive = Invoice, Negative = Credit Memo
        // Invoice
        ContractNo := LibraryUtility.GenerateGUID();
        MockBillingLineForContractWithAmount(ContractNo, LibraryRandom.RandDecInRange(60, 100, 2));
        MockBillingLineForContractWithAmount(ContractNo, -LibraryRandom.RandDecInRange(1, 50, 2));
        BillingLine.SetRange("Contract No.", ContractNo);
        AssertThat.AreEqual("Purchase Document Type"::Invoice, BillingLine.GetPurchaseDocumentTypeForContractNo(), 'Purchase Document Type is not calculated correctly for Invoice.');
        // Credit Memo
        ContractNo := LibraryUtility.GenerateGUID();
        MockBillingLineForContractWithAmount(ContractNo, -LibraryRandom.RandDecInRange(60, 100, 2));
        MockBillingLineForContractWithAmount(ContractNo, LibraryRandom.RandDecInRange(1, 50, 2));
        BillingLine.SetRange("Contract No.", ContractNo);
        AssertThat.AreEqual("Purchase Document Type"::"Credit Memo", BillingLine.GetPurchaseDocumentTypeForContractNo(), 'Purchase Document Type is not calculated correctly for Credit Memo.');
    end;

    [Test]
    internal procedure GetSalesDocumentTypeFromBillingLineForCustomerNo()
    var
        PartnerNo: Code[20];
    begin
        Initialize();

        // if Sum of Billing Lines for Customer is Positive = Invoice, Negative = Credit Memo
        // Invoice
        PartnerNo := LibraryUtility.GenerateGUID();
        MockBillingLineForPartnerNoWithServiceAmount("Service Partner"::Customer, PartnerNo, LibraryRandom.RandDecInRange(60, 100, 2));
        MockBillingLineForPartnerNoWithServiceAmount("Service Partner"::Customer, PartnerNo, -LibraryRandom.RandDecInRange(1, 50, 2));
        BillingLine.SetRange(Partner, "Service Partner"::Customer);
        BillingLine.SetRange("Partner No.", PartnerNo);
        AssertThat.AreEqual("Sales Document Type"::Invoice, BillingLine.GetSalesDocumentTypeForContractNo(), 'Sales Document Type is not calculated correctly for Invoice.');
        // Credit Memo
        PartnerNo := LibraryUtility.GenerateGUID();
        MockBillingLineForPartnerNoWithServiceAmount("Service Partner"::Customer, PartnerNo, -LibraryRandom.RandDecInRange(60, 100, 2));
        MockBillingLineForPartnerNoWithServiceAmount("Service Partner"::Customer, PartnerNo, LibraryRandom.RandDecInRange(1, 50, 2));
        BillingLine.SetRange("Partner No.", PartnerNo);
        AssertThat.AreEqual("Sales Document Type"::"Credit Memo", BillingLine.GetSalesDocumentTypeForContractNo(), 'Sales Document Type is not calculated correctly for Credit Memo.');
    end;

    [Test]
    internal procedure GetPurchaseDocumentTypeFromBillingLineForVendorNo()
    var
        PartnerNo: Code[20];
    begin
        Initialize();

        // if Sum of Billing Lines for Customer is Positive = Invoice, Negative = Credit Memo
        // Invoice
        PartnerNo := LibraryUtility.GenerateGUID();
        MockBillingLineForPartnerNoWithServiceAmount("Service Partner"::Vendor, PartnerNo, LibraryRandom.RandDecInRange(60, 100, 2));
        MockBillingLineForPartnerNoWithServiceAmount("Service Partner"::Vendor, PartnerNo, -LibraryRandom.RandDecInRange(1, 50, 2));
        BillingLine.SetRange(Partner, "Service Partner"::Vendor);
        BillingLine.SetRange("Partner No.", PartnerNo);
        AssertThat.AreEqual("Purchase Document Type"::Invoice, BillingLine.GetPurchaseDocumentTypeForVendorNo(), 'Purchase Document Type is not calculated correctly for Invoice.');
        // Credit Memo
        PartnerNo := LibraryUtility.GenerateGUID();
        MockBillingLineForPartnerNoWithServiceAmount("Service Partner"::Vendor, PartnerNo, -LibraryRandom.RandDecInRange(60, 100, 2));
        MockBillingLineForPartnerNoWithServiceAmount("Service Partner"::Vendor, PartnerNo, LibraryRandom.RandDecInRange(1, 50, 2));
        BillingLine.SetRange("Partner No.", PartnerNo);
        AssertThat.AreEqual("Purchase Document Type"::"Credit Memo", BillingLine.GetPurchaseDocumentTypeForVendorNo(), 'Purchase Document Type is not calculated correctly for Credit Memo.');
    end;

    [Test]
    [HandlerFunctions('StrMenuHandlerClearBillingProposal,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure CheckClearBillingProposalForVendorContractsWithoutClearCustomerProposal()
    begin
        Initialize();

        ContractTestLibrary.CreateVendor(Vendor);
        ContractTestLibrary.CreateVendorContractAndCreateContractLines(VendorContract, ServiceObject, Vendor."No.");
        ContractTestLibrary.CreateBillingProposal(BillingTemplate, Enum::"Service Partner"::Vendor);
        ContractTestLibrary.CreateCustomer(Customer);
        ContractTestLibrary.CreateCustomerContractAndCreateContractLines(CustomerContract, ServiceObject2, Customer."No.");
        ContractTestLibrary.CreateBillingProposal(BillingTemplate2, Enum::"Service Partner"::Customer);

        StrMenuHandlerStep := 1;
        BillingProposal.DeleteBillingProposal(BillingTemplate.Code);
        BillingLine.Reset();
        BillingLine.SetRange(Partner, BillingLine.Partner::Customer);
        BillingLine.FindFirst();
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure CheckBillingLineUpdateRequiredOnModifyVendorContractLine()
    var
        VendorContractLineSubPage: TestPage "Vendor Contract Line Subpage";
        DiscountPercent: Decimal;
        DiscountAmount: Decimal;
        ServiceAmount: Decimal;
    begin
        Initialize();

        ContractTestLibrary.CreateVendor(Vendor);
        ContractTestLibrary.CreateVendorContractAndCreateContractLines(VendorContract, ServiceObject, Vendor."No.");
        ContractTestLibrary.CreateBillingProposal(BillingTemplate, Enum::"Service Partner"::Vendor);
        BillingLine.Reset();
        BillingLine.SetRange("Billing Template Code", BillingTemplate.Code);
        BillingLine.FindFirst();
        DiscountPercent := BillingLine."Discount %" + 1;
        DiscountAmount := BillingLine."Unit Price" * BillingLine."Discount %" + 1;
        ServiceAmount := BillingLine."Service Amount" - 1;
        VendorContractLine.SetRange("Contract No.", BillingLine."Contract No.");
        VendorContractLine.SetRange("Line No.", BillingLine."Contract Line No.");
        VendorContractLine.FindFirst();

        VendorContractLineSubPage.OpenEdit();

        VendorContractLineSubPage.GoToRecord(VendorContractLine);
        VendorContractLineSubPage."Service Amount".SetValue(ServiceAmount);
        TestBillingLineUpdateRequiredSetAndReset(VendorContractLine."Contract No.", VendorContractLine."Line No.");
        BillingProposal.CreateBillingProposal(BillingLine."Billing Template Code", BillingLine."Billing from", BillingLine."Billing to");

        VendorContractLineSubPage.GoToRecord(VendorContractLine);
        VendorContractLineSubPage."Discount Amount".SetValue(DiscountAmount);
        TestBillingLineUpdateRequiredSetAndReset(VendorContractLine."Contract No.", VendorContractLine."Line No.");
        BillingProposal.CreateBillingProposal(BillingLine."Billing Template Code", BillingLine."Billing from", BillingLine."Billing to");

        VendorContractLineSubPage.GoToRecord(VendorContractLine);
        VendorContractLineSubPage."Discount %".SetValue(DiscountPercent);
        TestBillingLineUpdateRequiredSetAndReset(VendorContractLine."Contract No.", VendorContractLine."Line No.");
        BillingProposal.CreateBillingProposal(BillingLine."Billing Template Code", BillingLine."Billing from", BillingLine."Billing to");

        VendorContractLineSubPage.GoToRecord(VendorContractLine);
        Evaluate(BillingRhythm, '<3M>');
        VendorContractLineSubPage."Billing Rhythm".SetValue(BillingRhythm);
        TestBillingLineUpdateRequiredSetAndReset(VendorContractLine."Contract No.", VendorContractLine."Line No.");

        VendorContractLineSubPage.GoToRecord(VendorContractLine);
        VendorContractLineSubPage."Service Commitment Description".SetValue(LibraryRandom.RandText(100));
        TestBillingLineUpdateRequiredSetAndReset(VendorContractLine."Contract No.", VendorContractLine."Line No.");
    end;

    [Test]
    [HandlerFunctions('CreateBillingDocsVendorPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure CheckBillingLinesArchivingForVendor()
    begin
        Initialize();

        // Check that Billing Lines are being archived when posting Purchase Invoice
        BillingLinesArchiveSetupForPurchaseDocs();

        //Check Archived Billing Lines exist
        VendorContractLine.SetRange("Contract No.", VendorContract."No.");
        VendorContractLine.FindSet();
        repeat
            TestArchivedBillingLinesExist(VendorContractLine."Contract No.", VendorContractLine."Line No.", Enum::"Service Partner"::Vendor);
            ContractTestLibrary.FilterBillingLineArchiveOnContractLine(BillingLineArchive, VendorContractLine."Contract No.", VendorContractLine."Line No.", Enum::"Service Partner"::Vendor);
            BillingLineArchive.FindSet();
            repeat
                BillingLineArchive.TestField("Document Type", BillingLineArchive."Document Type"::Invoice);
                BillingLineArchive.TestField("Document No.", PostedDocumentNo);
            until BillingLineArchive.Next() = 0;
        until VendorContractLine.Next() = 0;
    end;

    [Test]
    [HandlerFunctions('CreateBillingDocsVendorPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure CheckDeleteArchivedBillingLinesVendorContractFirst()
    begin
        Initialize();

        // Check that Archived Billing Lines are deleted only when both related Vustomer Contract Line and posted Purchase documents have been deleted
        // This test deletes the Vendor Contract Line connected to Archived Billing Lines first
        BillingLinesArchiveSetupForPurchaseDocs();
        //Check that the Archived Billing Lines are deleted correctly after the posted Purchase document has been deleted
        // - should not be deleted while posted Purchase document exist
        VendorContractLine.SetRange("Contract No.", VendorContract."No.");
        VendorContractLine.FindFirst();
        TestArchivedBillingLinesExist(VendorContractLine."Contract No.", VendorContractLine."Line No.", Enum::"Service Partner"::Vendor);
        TempDeletedVendorContractLine := VendorContractLine;
        VendorContractLine.Delete(true);

        VendorContractLine.Next();
        TestArchivedBillingLinesExist(VendorContractLine."Contract No.", VendorContractLine."Line No.", Enum::"Service Partner"::Vendor);
        TestArchivedBillingLinesExist(TempDeletedVendorContractLine."Contract No.", TempDeletedVendorContractLine."Line No.", Enum::"Service Partner"::Vendor);
        DeletePostedPurchaseDocument();
        asserterror TestArchivedBillingLinesExist(TempDeletedVendorContractLine."Contract No.", TempDeletedVendorContractLine."Line No.", Enum::"Service Partner"::Vendor);
    end;

    [Test]
    [HandlerFunctions('CreateBillingDocsVendorPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure CheckDeleteArchivedBillingLinesPostedInvoiceFirstForVendor()
    begin
        Initialize();

        // Check that Archived Billing Lines are deleted only when both related Vendor Contract Line and posted purchase documents have been deleted
        // This test deletes the posted purchase document connected to Archived Billing Lines first
        BillingLinesArchiveSetupForPurchaseDocs();
        //Check that the Archived Billing Lines are deleted correctly when deleting Vendor Contract Line
        // - posted purchase document should be deleted first
        DeletePostedPurchaseDocument();
        VendorContractLine.SetRange("Contract No.", VendorContract."No.");
        VendorContractLine.FindFirst();
        TestArchivedBillingLinesExist(VendorContractLine."Contract No.", VendorContractLine."Line No.", Enum::"Service Partner"::Vendor);
        TempDeletedVendorContractLine := VendorContractLine;
        VendorContractLine.Delete(true);
        asserterror TestArchivedBillingLinesExist(TempDeletedVendorContractLine."Contract No.", TempDeletedVendorContractLine."Line No.", Enum::"Service Partner"::Vendor);
        VendorContractLine.Next();
        TestArchivedBillingLinesExist(VendorContractLine."Contract No.", VendorContractLine."Line No.", Enum::"Service Partner"::Vendor);
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure CheckRecurringBillingPageGroupingLinesForVendor()
    begin
        Initialize();

        RecurringBillingPageSetupForVendor();
        BillingProposal.InitTempTable(TempBillingLine, Enum::"Contract Billing Grouping"::None);
        TempBillingLine.SetRange(Indent, 0);
        AssertThat.IsTrue(TempBillingLine.IsEmpty(), 'Grouping Line should not be found.');

        BillingProposal.InitTempTable(TempBillingLine, Enum::"Contract Billing Grouping"::Contract);

        TempBillingLine.SetFilter("Contract No.", '%1|%2', VendorContract."No.", VendorContract2."No.");
        TempBillingLine.FindFirst();
        AssertThat.AreEqual(VendorContract."No.", TempBillingLine."Contract No.", 'Contract No. is not set correctly in grouping line (Group by Contract).');
        AssertThat.AreEqual(Vendor."No.", TempBillingLine."Partner No.", 'Partner No. is not set correctly in grouping line (Group by Contract).');
        AssertThat.AreEqual(GetBillingLineServiceAmount(Enum::"Contract Billing Grouping"::Contract, VendorContract."No."), TempBillingLine."Service Amount", 'Service Amount not calculated correctly in grouping line (Group by Contract).');

        TempBillingLine.Next();
        AssertThat.AreEqual(VendorContract2."No.", TempBillingLine."Contract No.", 'Contract No. is not set correctly in grouping line (Group by Contract).');
        AssertThat.AreEqual(Vendor2."No.", TempBillingLine."Partner No.", 'Partner No. is not set correctly in grouping line (Group by Contract).');
        AssertThat.AreEqual(GetBillingLineServiceAmount(Enum::"Contract Billing Grouping"::Contract, VendorContract2."No."), TempBillingLine."Service Amount", 'Service Amount not calculated correctly in grouping line (Group by Contract).');

        TempBillingLine.SetRange("Contract No.");
        BillingProposal.InitTempTable(TempBillingLine, Enum::"Contract Billing Grouping"::"Contract Partner");
        TempBillingLine.SetFilter("Partner No.", '%1|%2', Vendor."No.", Vendor2."No.");
        TempBillingLine.FindFirst();
        AssertThat.AreEqual('', TempBillingLine."Contract No.", 'Contract No. is not set correctly in grouping line (Group by "Contract Partner").');
        AssertThat.AreEqual(Vendor."No.", TempBillingLine."Partner No.", 'Partner No. is not set correctly in grouping line (Group by "Contract Partner").');
        AssertThat.AreEqual(GetBillingLineServiceAmount(Enum::"Contract Billing Grouping"::"Contract Partner", Vendor."No."), TempBillingLine."Service Amount", 'Service Amount not calculated correctly in grouping line (Group by "Contract Partner").');

        TempBillingLine.Next();
        AssertThat.AreEqual('', TempBillingLine."Contract No.", 'Contract No. is not set correctly in grouping line (Group by "Contract Partner").');
        AssertThat.AreEqual(Vendor2."No.", TempBillingLine."Partner No.", 'Partner No. is not set correctly in grouping line (Group by "Contract Partner").');
        AssertThat.AreEqual(GetBillingLineServiceAmount(Enum::"Contract Billing Grouping"::"Contract Partner", Vendor2."No."), TempBillingLine."Service Amount", 'Service Amount not calculated correctly in grouping line (Group by "Contract Partner").');
    end;

    local procedure Initialize()
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Recurring Billing Test");
        ClearAll();
        ContractTestLibrary.InitContractsApp();

        if IsInitialized then
            exit;

        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"Recurring Billing Test");
        LibraryERMCountryData.UpdatePurchasesPayablesSetup();
        LibraryERMCountryData.UpdateSalesReceivablesSetup();
        IsInitialized := true;
        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"Recurring Billing Test");
    end;

    local procedure CreateCustomerContract(BillingPeriod: Text; BillingBasePeriod: Text)
    begin
        CreateCustomerContract("Period Calculation"::"Align to Start of Month", BillingPeriod, BillingBasePeriod, 0D, LibraryRandom.RandDec(1000, 2), LibraryRandom.RandDec(1000, 2));
    end;

    local procedure CreateCustomerContract(PeriodCalculation: Enum "Period Calculation"; BillingPeriod: Text; BillingBasePeriod: Text; BillFromDate: Date; UnitPrice: Decimal; UnitCost: Decimal)
    begin
        CreateServiceObjectWithItemSetup();
        ContractTestLibrary.UpdateItemUnitCostAndPrice(Item, UnitCost, UnitPrice, false);

        CreateServiceCommitmentTemplateSetup(BillingBasePeriod);
        CreateServiceCommPackageAndAssignItemToServiceCommitmentSetup(PeriodCalculation, BillingPeriod);
        InsertServiceCommitmentFromServiceCommPackageSetup(BillFromDate);
        ContractTestLibrary.CreateCustomerContractAndCreateContractLines(CustomerContract, ServiceObject, Customer."No.");
        CustomerContract.SetRange("No.", CustomerContract."No.");
    end;

    local procedure CreateBillingProposalForCustomerContractUsingRealTemplate()
    begin
        CreateCustomerContract('<1M>', '<12M>');
        CreateRecurringBillingTemplateSetupForCustomerContract('<2M-CM>', '<8M+CM>', CustomerContract.GetView());
        ContractTestLibrary.CreateBillingProposal(BillingTemplate, Enum::"Service Partner"::Customer);
    end;

    local procedure CreateBillingProposalForCustomerContractUsingTempTemplate(PeriodCalculation: Enum "Period Calculation"; BillingPeriod: Text; BillingBasePeriod: Text; BillFromDate: Date; BillToDate: Date)
    var
        GLSetup: Record "General Ledger Setup";
    begin
        GLSetup.Get();
        GLSetup."Unit-Amount Rounding Precision" := 0.001;
        GLSetup.Modify(false);
        CreateCustomerContract(PeriodCalculation, BillingPeriod, BillingBasePeriod, BillFromDate, 200, 100);
        BillingProposal.CreateBillingProposalForContract("Service Partner"::Customer, CustomerContract."No.", '', CustomerContract.GetFilter("Billing Rhythm Filter"), BillToDate, BillToDate);
        Currency.InitRoundingPrecision();
    end;

    local procedure CreateVendorContract(BillingPeriod: Text; BillingBasePeriod: Text)
    begin
        CreateVendorContract("Period Calculation"::"Align to Start of Month", BillingPeriod, BillingBasePeriod, 0D, LibraryRandom.RandDec(1000, 2), LibraryRandom.RandDec(1000, 2));
    end;

    local procedure CreateVendorContract(PeriodCalculation: Enum "Period Calculation"; BillingPeriod: Text; BillingBasePeriod: Text; BillFromDate: Date; UnitPrice: Decimal; UnitCost: Decimal)
    begin
        CreateServiceObjectWithItemSetup();
        ContractTestLibrary.UpdateItemUnitCostAndPrice(Item, UnitCost, UnitPrice, false);

        CreateServiceCommitmentTemplateSetup(BillingBasePeriod);
        CreateServiceCommPackageAndAssignItemToServiceCommitmentSetup(PeriodCalculation, BillingPeriod);
        ServiceCommPackageLine.Partner := ServiceCommPackageLine.Partner::Vendor;
        ServiceCommPackageLine.Modify(false);
        InsertServiceCommitmentFromServiceCommPackageSetup(BillFromDate);
        ContractTestLibrary.CreateVendorContractAndCreateContractLines(VendorContract, ServiceObject, Vendor."No.");
        VendorContract.SetRange("No.", VendorContract."No.");
    end;

    local procedure CreateBillingProposalForVendorContractUsingRealTemplate()
    var
        GLSetup: Record "General Ledger Setup";
    begin
        GLSetup.Get();
        GLSetup."Unit-Amount Rounding Precision" := 0.001;
        GLSetup.Modify(false);
        CreateVendorContract('<1M>', '<12M>');
        CreateRecurringBillingTemplateSetupForVendorContract('<2M-CM>', '<8M+CM>', VendorContract.GetView());
        ContractTestLibrary.CreateBillingProposal(BillingTemplate, Enum::"Service Partner"::Vendor);
    end;

    local procedure CreateBillingProposalForVendorContractUsingTempTemplate(PeriodCalculation: Enum "Period Calculation"; BillingPeriod: Text; BillingBasePeriod: Text; BillFromDate: Date; BillToDate: Date)
    begin
        CreateVendorContract(PeriodCalculation, BillingPeriod, BillingBasePeriod, BillFromDate, 200, 100);
        BillingProposal.CreateBillingProposalForContract("Service Partner"::Vendor, VendorContract."No.", '', VendorContract.GetFilter("Billing Rhythm Filter"), BillToDate, BillToDate);
        Currency.InitRoundingPrecision();
    end;

    local procedure CreateServiceObjectWithItemSetup()
    begin
        ContractTestLibrary.CreateCustomerInLCY(Customer);
        ContractTestLibrary.CreateVendorInLCY(Vendor);
        ContractTestLibrary.CreateServiceObjectWithItem(ServiceObject, Item, false);
        ServiceObject.SetHideValidationDialog(true);
        ServiceObject.Validate("End-User Customer Name", Customer.Name);
        ServiceObject."Quantity Decimal" := 5;
        ServiceObject.Modify(false);
    end;

    local procedure CreateServiceCommitmentTemplateSetup(CalcBasePeriodDateFormulaTxt: Text)
    begin
        ContractTestLibrary.CreateServiceCommitmentTemplate(ServiceCommitmentTemplate, CalcBasePeriodDateFormulaTxt, 50, Enum::"Invoicing Via"::Contract, Enum::"Calculation Base Type"::"Item Price");
    end;

    local procedure CreateServiceCommPackageAndAssignItemToServiceCommitmentSetup(PeriodCalculation: Enum "Period Calculation"; CalculationRhythmDateFormulaTxt: Text)
    begin
        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage, ServiceCommPackageLine);
        ServiceCommPackageLine."Period Calculation" := PeriodCalculation;
        if CalculationRhythmDateFormulaTxt <> '' then
            Evaluate(ServiceCommPackageLine."Billing Rhythm", CalculationRhythmDateFormulaTxt);
        if Format(ServiceCommitmentTemplate."Billing Base Period") <> '' then
            ServiceCommPackageLine."Billing Base Period" := ServiceCommitmentTemplate."Billing Base Period";
        ServiceCommPackageLine.Modify(false);
        ContractTestLibrary.AssignItemToServiceCommitmentPackage(Item, ServiceCommitmentPackage.Code);
    end;

    local procedure CreateRecurringBillingTemplateSetupForCustomerContract(DateFormula1Txt: Text; DateFormula2Txt: Text; FilterText: Text)
    begin
        ContractTestLibrary.CreateRecurringBillingTemplate(BillingTemplate, DateFormula1Txt, DateFormula2Txt, FilterText, Enum::"Service Partner"::Customer);
    end;

    local procedure CreateRecurringBillingTemplateSetupForVendorContract(DateFormula1Txt: Text; DateFormula2Txt: Text; FilterText: Text)
    begin
        ContractTestLibrary.CreateRecurringBillingTemplate(BillingTemplate, DateFormula1Txt, DateFormula2Txt, FilterText, Enum::"Service Partner"::Vendor);
    end;

    local procedure InsertServiceCommitmentFromServiceCommPackageSetup(ServiceAndCalculationStartDate: Date)
    begin
        ServiceCommitmentPackage.SetRecFilter();
        ServiceObject.InsertServiceCommitmentsFromServCommPackage(ServiceAndCalculationStartDate, ServiceCommitmentPackage);
    end;

    local procedure FindFirstServiceCommitment()
    begin
        ServiceCommitment.SetRange("Service Object No.", ServiceObject."No.");
        ServiceCommitment.SetRange("Package Code", ServiceCommitmentPackage.Code);
        ServiceCommitment.SetRange(Template, ServiceCommitmentTemplate.Code);
        ServiceCommitment.FindFirst();
    end;

    local procedure BillingLinesArchiveSetup()
    begin
        ContractTestLibrary.CreateCustomerContractAndCreateContractLines(CustomerContract, ServiceObject, Customer."No.", true);
        ContractTestLibrary.CreateBillingProposal(BillingTemplate, Enum::"Service Partner"::Customer);

        BillingLine.SetRange("Billing Template Code", BillingTemplate.Code);
        BillingLine.SetRange("Service Object No.", ServiceObject."No.");

        //Create Billing Document (Sales)
        Codeunit.Run(Codeunit::"Create Billing Documents", BillingLine);
        //Post Sales Document
        BillingLine.FindFirst();
        BillingLine.TestField("Document Type", BillingLine."Document Type"::Invoice);
        BillingLine.TestField("Document No.");
        SalesHeader.Get(SalesHeader."Document Type"::Invoice, BillingLine."Document No.");
        PostedDocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);
    end;

    local procedure BillingLinesArchiveSetupForPurchaseDocs()
    begin
        ContractTestLibrary.CreateVendorContractAndCreateContractLines(VendorContract, ServiceObject, Vendor."No.", true);
        ContractTestLibrary.CreateBillingProposal(BillingTemplate, Enum::"Service Partner"::Vendor);

        BillingLine.SetRange("Billing Template Code", BillingTemplate.Code);
        BillingLine.SetRange("Service Object No.", ServiceObject."No.");

        //Create Billing Document (Purchase)
        Codeunit.Run(Codeunit::"Create Billing Documents", BillingLine);
        //Post Purchase Document
        BillingLine.FindFirst();
        BillingLine.TestField("Document Type", BillingLine."Document Type"::Invoice);
        BillingLine.TestField("Document No.");
        PurchaseHeader.Get(PurchaseHeader."Document Type"::Invoice, BillingLine."Document No.");
        SetupVendorInvoiceNoForPurchaseHeader(PurchaseHeader);
        PostedDocumentNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);
    end;

    local procedure CheckBillingLineAmountAndPrice(ExpectedCalculatedUnitPrice: Decimal)
    var
        ExpectedCalculatedServiceAmount: Decimal;
    begin
        BillingLine.FindLast();
        ExpectedCalculatedServiceAmount := Round(ExpectedCalculatedUnitPrice * ServiceObject."Quantity Decimal", Currency."Amount Rounding Precision");
        AssertThat.AreEqual(ExpectedCalculatedUnitPrice, BillingLine."Unit Price", 'Billing Line Unit Price not calculated correctly.');
        AssertThat.AreEqual(ExpectedCalculatedServiceAmount, BillingLine."Service Amount", 'Billing Line Service Amount not calculated correctly.');
    end;

    local procedure CheckTempBillingLineRecords()
    begin
        BillingLine.SetFilter("Contract No.", '%1|%2', CustomerContract."No.", CustomerContract2."No.");
        BillingLine.FindSet();
        repeat
            AssertThat.IsTrue(TempBillingLine.Get(BillingLine."Entry No."), 'Record not found in temporary table.');
        until BillingLine.Next() = 0;
    end;

    local procedure CheckNextToDate(PeriodCalculation: Enum "Period Calculation"; PeriodTxt: Text; StartDate: Date; ExpectedEndDate: Date)
    var
        PeriodFormula: DateFormula;
    begin
        if PeriodTxt = '' then
            Error('Period must be entered when calculating Next To Date.');
        Evaluate(PeriodFormula, PeriodTxt);

        ServiceCommitment."Period Calculation" := PeriodCalculation;
        ServiceCommitment."Service Start Date" := StartDate;
        AssertThat.AreEqual(ExpectedEndDate, BillingProposal.CalculateNextToDate(ServiceCommitment, PeriodFormula, StartDate), 'Next Date not calculated correctly.');
    end;

    local procedure SetupVendorInvoiceNoForPurchaseHeader(var PurchHeader: Record "Purchase Header")
    begin
        PurchHeader.Validate("Vendor Invoice No.", LibraryUtility.GenerateGUID());
        PurchHeader.Modify(false);
    end;

    local procedure DeletePostedSalesDocument()
    begin
        SalesInvoiceHeader.Get(PostedDocumentNo);
        SalesInvoiceHeader."No. Printed" := 1;
        SalesInvoiceHeader.Modify(false);
        LibrarySales.SetAllowDocumentDeletionBeforeDate(SalesInvoiceHeader."Posting Date" + 1);
        SalesInvoiceHeader.Delete(true);
    end;

    local procedure TestBillingLineUpdateRequiredSetAndReset(ContractNo: Code[20]; ContractLineNo: Integer)
    begin
        BillingLine.SetRange("Contract No.", ContractNo);
        BillingLine.SetRange("Contract Line No.", ContractLineNo);
        BillingLine.SetRange("Update Required", true);
        BillingLine.FindFirst();
        BillingLine."Update Required" := false;
        BillingLine.Modify(false);
    end;

    local procedure DeletePostedPurchaseDocument()
    begin
        PurchInvHeader.Get(PostedDocumentNo);
        PurchInvHeader."No. Printed" := 1;
        PurchInvHeader.Modify(false);
        LibraryPurchase.SetAllowDocumentDeletionBeforeDate(PurchInvHeader."Posting Date" + 1);
        PurchInvHeader.Delete(true);
    end;

    local procedure TestArchivedBillingLinesExist(ContractNo: Code[20]; ContractLineNo: Integer; ServicePartner: Enum "Service Partner")
    var
        BillingLineArchive2: Record "Billing Line Archive";
    begin
        ContractTestLibrary.FilterBillingLineArchiveOnContractLine(BillingLineArchive2, ContractNo, ContractLineNo, ServicePartner);
        AssertThat.IsTrue(not BillingLineArchive2.IsEmpty(), 'Archived Billing Line not found.');
    end;

    local procedure RecurringBillingPageSetupForCustomer()
    begin
        ContractTestLibrary.CreateCustomer(Customer);
        ContractTestLibrary.CreateCustomerContractAndCreateContractLines(CustomerContract, ServiceObject, Customer."No.", false);
        ContractTestLibrary.CreateCustomer(Customer2);
        ContractTestLibrary.CreateCustomerContractAndCreateContractLines(CustomerContract2, ServiceObject2, Customer2."No.", false);
        ContractTestLibrary.CreateBillingProposal(BillingTemplate, Enum::"Service Partner"::Customer);
    end;

    local procedure RecurringBillingPageSetupForVendor()
    begin
        ContractTestLibrary.CreateVendor(Vendor);
        ContractTestLibrary.CreateVendorContractAndCreateContractLines(VendorContract, ServiceObject, Vendor."No.", false);
        ContractTestLibrary.CreateVendor(Vendor2);
        ContractTestLibrary.CreateVendorContractAndCreateContractLines(VendorContract2, ServiceObject2, Vendor2."No.", false);
        ContractTestLibrary.CreateBillingProposal(BillingTemplate, Enum::"Service Partner"::Vendor);
    end;

    local procedure GetBillingLineServiceAmount(GroupBy: Enum "Contract Billing Grouping"; FilterCodeNo: Code[20]): Decimal
    begin
        BillingLine.Reset();
        case GroupBy of
            Enum::"Contract Billing Grouping"::Contract:
                BillingLine.SetRange("Contract No.", FilterCodeNo);
            Enum::"Contract Billing Grouping"::"Contract Partner":
                BillingLine.SetRange("Partner No.", FilterCodeNo);
        end;
        BillingLine.CalcSums("Service Amount");
        exit(BillingLine."Service Amount");
    end;

    local procedure MockBillingLineForContractWithAmount(NewContractNo: Code[20]; NewServiceAmount: Decimal)
    begin
        BillingLine.InitNewBillingLine();
        BillingLine."Contract No." := NewContractNo;
        BillingLine."Service Amount" := NewServiceAmount;
        BillingLine.Insert(false);
    end;

    local procedure MockBillingLineForPartnerNoWithServiceAmount(NewPartner: Enum "Service Partner"; NewPartnerNo: Code[20]; NewServiceAmount: Decimal)
    begin
        BillingLine.InitNewBillingLine();
        BillingLine.Partner := NewPartner;
        BillingLine."Partner No." := NewPartnerNo;
        BillingLine."Service Amount" := NewServiceAmount;
        BillingLine.Insert(false);
    end;

    local procedure MockBillingLineForPartnerNoWithUnitPriceAndDiscountAndServicObjectQuantity(NewUnitPrice: Decimal; NewDiscountPerc: Decimal; NewServiceObjQuantity: Decimal)
    begin
        BillingLine.InitNewBillingLine();
        BillingLine."Unit Price" := NewUnitPrice;
        BillingLine."Discount %" := NewDiscountPerc;
        BillingLine."Service Obj. Quantity Decimal" := NewServiceObjQuantity;
        BillingLine.Insert(false);
    end;

    [ModalPageHandler]
    procedure CreateBillingDocsCustomerPageHandler(var CreateBillingDocsCustomerPage: TestPage "Create Customer Billing Docs")
    begin
        CreateBillingDocsCustomerPage.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure BillingTemplateModalPageHandler(var BillingTemplatesPage: TestPage "Billing Templates")
    begin
        BillingTemplatesPage.GoToRecord(BillingTemplate);
        BillingTemplatesPage.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure CreateBillingDocsVendorPageHandler(var CreateBillingDocsVendorPage: TestPage "Create Vendor Billing Docs")
    begin
        CreateBillingDocsVendorPage.OK().Invoke();
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
    procedure StrMenuHandlerClearBillingProposal(Option: Text[1024]; var Choice: Integer; Instruction: Text[1024])
    begin
        case StrMenuHandlerStep of
            1:
                Choice := 1;
            2:
                Choice := 2;
            else
                Choice := 0;
        end;
    end;

}