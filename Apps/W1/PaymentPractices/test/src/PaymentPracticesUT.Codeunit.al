// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Test.Finance.Analysis;

using Microsoft.Finance.Analysis;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Purchases.Payables;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Receivables;

codeunit 134197 "Payment Practices UT"
{
    Subtype = Test;
    TestType = IntegrationTest;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Payment Practices]
    end;

    var
        PaymentPeriods: array[3] of Record "Payment Period";
        Assert: Codeunit "Assert";
        PaymentPracticesLibrary: Codeunit "Payment Practices Library";
        PaymentPractices: Codeunit "Payment Practices";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        LibraryRandom: Codeunit "Library - Random";
        LibrarySales: Codeunit "Library - Sales";
        CompanySizeCodes: array[3] of Code[20];
        Initialized: Boolean;

    [Test]
    procedure VendorPaymentPractices_SizeEmpty()
    var
        PaymentPracticeHeader: Record "Payment Practice Header";
    begin
        // [SCENARIO] Generate payment practices for vendors by size with severals sizes and no entries in those dates. Report dataset will contain lines for each size with 0 entries.
        Initialize();

        // [GIVEN] Three vendors with different company size
        PaymentPracticesLibrary.CreateVendorNoWithSizeAndExcl(CompanySizeCodes[1], false);
        PaymentPracticesLibrary.CreateVendorNoWithSizeAndExcl(CompanySizeCodes[2], false);
        PaymentPracticesLibrary.CreateVendorNoWithSizeAndExcl(CompanySizeCodes[3], false);

        // [WHEN] Generate payment practices for vendors by size
        PaymentPracticesLibrary.CreatePaymentPracticeHeaderSimple(PaymentPracticeHeader);
        PaymentPractices.Generate(PaymentPracticeHeader);

        // [THEN] Report dataset will contain 3 lines, but 0 entries
        PaymentPracticesLibrary.VerifyLinesCount(PaymentPracticeHeader, 3);
        PaymentPracticesLibrary.VerifyBufferCount(PaymentPracticeHeader, 0, "Paym. Prac. Header Type"::Vendor);
    end;

    [Test]
    procedure VendorExclFromPaymentPractices()
    var
        PaymentPracticeHeader: Record "Payment Practice Header";
        VendorNo: Code[20];
        VendorExcludedNo: Code[20];
    begin
        // [SCENARIO] Generate payment practices for vendor with excl. from payment practices = true and existing entries in those dates. Report dataset will contain entries only for vendor without excl.
        Initialize();

        // [GIVEN] Vendor with company size and an entry in the period
        VendorNo := PaymentPracticesLibrary.CreateVendorNoWithSizeAndExcl(CompanySizeCodes[1], false);
        MockVendorInvoice(VendorNo, WorkDate(), WorkDate());

        // [GIVEN]Vendor with company size and an entry in the period, but with Excl. from Payment Practice = true
        VendorExcludedNo := PaymentPracticesLibrary.CreateVendorNoWithSizeAndExcl(CompanySizeCodes[2], true);
        MockVendorInvoice(VendorExcludedNo, WorkDate(), WorkDate());

        // [WHEN] Generate payment practices for vendors by size
        PaymentPracticesLibrary.CreatePaymentPracticeHeaderSimple(PaymentPracticeHeader);
        PaymentPractices.Generate(PaymentPracticeHeader);

        // [THEN] Report dataset will contain only 1 entry
        PaymentPracticesLibrary.VerifyBufferCount(PaymentPracticeHeader, 1, "Paym. Prac. Header Type"::Vendor);
    end;

    [Test]
    procedure CustomerExclFromPaymentPractices()
    var
        PaymentPracticeHeader: Record "Payment Practice Header";
        Customer: Record Customer;
        CustomerExcluded: Record Customer;
    begin
        // [SCENARIO] Generate payment practices for customers with excl. from payment practices = true and existing entries in those dates. Report dataset will contain entries only for vendor without excl.
        Initialize();

        // [GIVEN] Customer with an entry in the period
        LibrarySales.CreateCustomer(Customer);
        MockCustomerInvoice(Customer."No.", WorkDate(), WorkDate());

        // [GIVEN] Customer with an entry in the period, but with Excl. from Payment Practice = true
        LibrarySales.CreateCustomer(CustomerExcluded);
        PaymentPracticesLibrary.SetExcludeFromPaymentPractices(CustomerExcluded, true);
        MockCustomerInvoice(CustomerExcluded."No.", WorkDate(), WorkDate());

        // [WHEN] Generate payment practices for cust+vendors
        PaymentPracticesLibrary.CreatePaymentPracticeHeaderSimple(PaymentPracticeHeader, "Paym. Prac. Header Type"::"Vendor+Customer", "Paym. Prac. Aggregation Type"::Period);
        PaymentPractices.Generate(PaymentPracticeHeader);

        // [THEN] Report dataset will contain only 1 entry
        PaymentPracticesLibrary.VerifyBufferCount(PaymentPracticeHeader, 1, "Paym. Prac. Header Type"::Customer);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler_Yes')]
    procedure ConfirmToCleanUpOnAggrValidation_Yes()
    var
        PaymentPracticeHeader: Record "Payment Practice Header";
        VendorNo: Code[20];
    begin
        // [SCENARIO] When lines already exist on header and you change Aggregation Type you need to confirm that lines will be deleted
        Initialize();

        // [GIVEN] Vendor with company size and an entry in the period
        VendorNo := PaymentPracticesLibrary.CreateVendorNoWithSizeAndExcl(CompanySizeCodes[1], false);
        MockVendorInvoice(VendorNo, WorkDate(), WorkDate());

        // [GIVEN] Lines were generated for Header
        PaymentPracticesLibrary.CreatePaymentPracticeHeaderSimple(PaymentPracticeHeader);
        PaymentPractices.Generate(PaymentPracticeHeader);

        // [WHEN] Change Aggregation Type
        PaymentPracticeHeader.Validate("Aggregation Type", PaymentPracticeHeader."Aggregation Type"::Period);
        // handled by Confirm handler

        // [THEN] Lines were deleted
        PaymentPracticesLibrary.VerifyLinesCount(PaymentPracticeHeader, 0);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler_No')]
    procedure ConfirmToCleanUpOnAggrValidation_No()
    var
        PaymentPracticeHeader: Record "Payment Practice Header";
        VendorNo: Code[20];
    begin
        // [SCENARIO] When lines already exist on header and you change Aggregation Type you need to confirm that lines will be deleted
        Initialize();

        // [GIVEN] Vendor with company size and an entry in the period
        VendorNo := PaymentPracticesLibrary.CreateVendorNoWithSizeAndExcl(CompanySizeCodes[1], false);
        MockVendorInvoice(VendorNo, WorkDate(), WorkDate());

        // [GIVEN] Lines were generated for Header
        PaymentPracticesLibrary.CreatePaymentPracticeHeaderSimple(PaymentPracticeHeader);
        PaymentPractices.Generate(PaymentPracticeHeader);

        // [WHEN] Change Aggregation Type and say "no" in confirm handler
        PaymentPracticeHeader.Validate("Aggregation Type", PaymentPracticeHeader."Aggregation Type"::Period);
        // handled by Confirm handler

        // [THEN] Lines were not deleted and aggregation type was not changed
        PaymentPracticesLibrary.VerifyLinesCount(PaymentPracticeHeader, 3);
        PaymentPracticeHeader.TestField("Aggregation Type", PaymentPracticeHeader."Aggregation Type"::"Company Size");
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler_Yes')]
    procedure ConfirmToCleanUpOnTypeValidation()
    var
        PaymentPracticeHeader: Record "Payment Practice Header";
        VendorNo: Code[20];
    begin
        // [SCENARIO] When lines already exist on header and you change Header Type you need to confirm that lines will be deleted
        Initialize();

        // [GIVEN] Vendor with company size and an entry in the period
        VendorNo := PaymentPracticesLibrary.CreateVendorNoWithSizeAndExcl(CompanySizeCodes[1], false);
        MockVendorInvoice(VendorNo, WorkDate(), WorkDate());

        // [GIVEN] Lines were generated for Header
        PaymentPracticesLibrary.CreatePaymentPracticeHeaderSimple(PaymentPracticeHeader, "Paym. Prac. Header Type"::Vendor, "Paym. Prac. Aggregation Type"::Period);
        PaymentPractices.Generate(PaymentPracticeHeader);

        // [WHEN] Change Aggregation Type and say "yes" in confirm handler
        PaymentPracticeHeader.Validate("Header Type", PaymentPracticeHeader."Header Type"::Customer);
        // handled by Confirm handler

        // [THEN] Lines were deleted
        PaymentPracticesLibrary.VerifyLinesCount(PaymentPracticeHeader, 0);
    end;

    [Test]
    procedure ReportDataSetForVendorsByPeriod()
    var
        PaymentPracticeHeader: Record "Payment Practice Header";
        PeriodAmounts: array[3] of Decimal;
        TotalAmount: Decimal;
        ExpectedPeriodPcts: array[3] of Decimal;
        PeriodCounts: array[3] of Integer;
        TotalCount: Integer;
        ExpectedPeriodAmountPcts: array[3] of Decimal;
        VendorNo: Code[20];
        Amount: Decimal;
        i: Integer;
        j: Integer;
    begin
        // [SCENARIO] Check report dataset for vendors by several entries in different periods
        Initialize();

        // [GIVEN] Create a vendor
        VendorNo := LibraryPurchase.CreateVendorNo();

        // [GIVEN] Create a payment practice header for Current Year of type Vendor
        PaymentPracticesLibrary.CreatePaymentPracticeHeaderSimple(PaymentPracticeHeader, "Paym. Prac. Header Type"::Vendor, "Paym. Prac. Aggregation Type"::Period);

        // [GIVEN] Post several entries for the vendor in 3 different periods
        for i := 1 to 3 do
            for j := 1 to LibraryRandom.RandInt(10) do begin
                PeriodCounts[i] += 1;
                TotalCount += 1;
                Amount := MockVendorInvoiceAndPaymentInPeriod(VendorNo, WorkDate(), PaymentPeriods[i]."Days From", PaymentPeriods[i]."Days To");
                PeriodAmounts[i] += Amount;
                TotalAmount += Amount;
            end;

        // [WHEN] Lines were generated for Header
        PaymentPractices.Generate(PaymentPracticeHeader);

        // [THEN] Check that report dataset contains correct percentages for each period
        PrepareExpectedPeriodPcts(ExpectedPeriodPcts, ExpectedPeriodAmountPcts, PeriodCounts, TotalCount, PeriodAmounts, TotalAmount);
        PaymentPracticesLibrary.VerifyPeriodLine(PaymentPracticeHeader."No.", "Paym. Prac. Header Type"::Vendor, PaymentPeriods[1].Code, ExpectedPeriodPcts[1], ExpectedPeriodAmountPcts[1]);
        PaymentPracticesLibrary.VerifyPeriodLine(PaymentPracticeHeader."No.", "Paym. Prac. Header Type"::Vendor, PaymentPeriods[2].Code, ExpectedPeriodPcts[2], ExpectedPeriodAmountPcts[2]);
        PaymentPracticesLibrary.VerifyPeriodLine(PaymentPracticeHeader."No.", "Paym. Prac. Header Type"::Vendor, PaymentPeriods[3].Code, ExpectedPeriodPcts[3], ExpectedPeriodAmountPcts[3]);
    end;

    [Test]
    procedure ReportDataSetForCustomersByPeriod()
    var
        PaymentPracticeHeader: Record "Payment Practice Header";
        ExpectedPeriodPcts: array[3] of Decimal;
        ExpectedPeriodAmountPcts: array[3] of Decimal;
        PeriodAmounts: array[3] of Decimal;
        TotalAmount: Decimal;
        PeriodCounts: array[3] of Integer;
        TotalCount: Integer;
        CustomerNo: Code[20];
        Amount: Decimal;
        i: Integer;
        j: Integer;
    begin
        // [SCENARIO] Check report dataset for customers by several entries in different periods
        Initialize();

        // [GIVEN] Create a Customer
        CustomerNo := LibrarySales.CreateCustomerNo();

        // [GIVEN] Create a payment practice header for Current Year of type Customer
        PaymentPracticesLibrary.CreatePaymentPracticeHeaderSimple(PaymentPracticeHeader, "Paym. Prac. Header Type"::Customer, "Paym. Prac. Aggregation Type"::Period);

        // [GIVEN] Post several entries for the customer in 3 different periods
        for i := 1 to 3 do
            for j := 1 to LibraryRandom.RandInt(10) do begin
                PeriodCounts[i] += 1;
                TotalCount += 1;
                Amount := MockCustomerInvoiceAndPaymentInPeriod(CustomerNo, WorkDate(), PaymentPeriods[i]."Days From", PaymentPeriods[i]."Days To");
                PeriodAmounts[i] += Amount;
                TotalAmount += Amount;
            end;

        // [WHEN] Lines were generated for Header
        PaymentPractices.Generate(PaymentPracticeHeader);

        // [THEN] Check that report dataset contains correct percentages for each period
        PrepareExpectedPeriodPcts(ExpectedPeriodPcts, ExpectedPeriodAmountPcts, PeriodCounts, TotalCount, PeriodAmounts, TotalAmount);
        PaymentPracticesLibrary.VerifyPeriodLine(PaymentPracticeHeader."No.", "Paym. Prac. Header Type"::Customer, PaymentPeriods[1].Code, ExpectedPeriodPcts[1], ExpectedPeriodAmountPcts[1]);
        PaymentPracticesLibrary.VerifyPeriodLine(PaymentPracticeHeader."No.", "Paym. Prac. Header Type"::Customer, PaymentPeriods[2].Code, ExpectedPeriodPcts[2], ExpectedPeriodAmountPcts[2]);
        PaymentPracticesLibrary.VerifyPeriodLine(PaymentPracticeHeader."No.", "Paym. Prac. Header Type"::Customer, PaymentPeriods[3].Code, ExpectedPeriodPcts[3], ExpectedPeriodAmountPcts[3]);
    end;

    [Test]
    procedure ReportDataSetForCustomersVendorsByPeriod()
    var
        PaymentPracticeHeader: Record "Payment Practice Header";
        Vendor_PeriodAmounts: array[3] of Decimal;
        Vendor_TotalAmount: Decimal;
        Vendor_PeriodCounts: array[3] of Integer;
        Vendor_TotalCount: Integer;
        Vendor_ExpectedPeriodPcts: array[3] of Decimal;
        Vendor_ExpectedPeriodAmountPcts: array[3] of Decimal;
        Customer_PeriodAmounts: array[3] of Decimal;
        Customer_TotalAmount: Decimal;
        Customer_PeriodCounts: array[3] of Integer;
        Customer_TotalCount: Integer;
        Customer_ExpectedPeriodPcts: array[3] of Decimal;
        Customer_ExpectedPeriodAmountPcts: array[3] of Decimal;
        CustomerNo: Code[20];
        VendorNo: Code[20];
        Amount: Decimal;
        i: Integer;
        j: Integer;
    begin
        // [SCENARIO] Check report dataset for customers by several entries in different periods
        Initialize();

        // [GIVEN] Create a Customer
        CustomerNo := LibrarySales.CreateCustomerNo();

        // [GIVEN] Create a vendor
        VendorNo := LibraryPurchase.CreateVendorNo();

        // [GIVEN] Create a payment practice header for Current Year of Type Vendor+Customer
        PaymentPracticesLibrary.CreatePaymentPracticeHeaderSimple(PaymentPracticeHeader, "Paym. Prac. Header Type"::"Vendor+Customer", "Paym. Prac. Aggregation Type"::Period);

        // [GIVEN] Post several entries for the vendor in 3 different periods
        for i := 1 to 3 do
            for j := 1 to LibraryRandom.RandInt(10) do begin
                Vendor_PeriodCounts[i] += 1;
                Vendor_TotalCount += 1;
                Amount := MockVendorInvoiceAndPaymentInPeriod(VendorNo, WorkDate(), PaymentPeriods[i]."Days From", PaymentPeriods[i]."Days To");
                Vendor_PeriodAmounts[i] += Amount;
                Vendor_TotalAmount += Amount;
            end;

        // [GIVEN] Post several entries for the customer in 3 different periods
        for i := 1 to 3 do
            for j := 1 to LibraryRandom.RandInt(10) do begin
                Customer_PeriodCounts[i] += 1;
                Customer_TotalCount += 1;
                Amount := MockCustomerInvoiceAndPaymentInPeriod(CustomerNo, WorkDate(), PaymentPeriods[i]."Days From", PaymentPeriods[i]."Days To");
                Customer_PeriodAmounts[i] += Amount;
                Customer_TotalAmount += Amount;
            end;

        // [WHEN] Lines were generated for Header
        PaymentPractices.Generate(PaymentPracticeHeader);

        // [THEN] Check that report dataset contains correct percentages for each period for vendors
        PrepareExpectedPeriodPcts(Vendor_ExpectedPeriodPcts, Vendor_ExpectedPeriodAmountPcts, Vendor_PeriodCounts, Vendor_TotalCount, Vendor_PeriodAmounts, Vendor_TotalAmount);
        PaymentPracticesLibrary.VerifyPeriodLine(PaymentPracticeHeader."No.", "Paym. Prac. Header Type"::Vendor, PaymentPeriods[1].Code, Vendor_ExpectedPeriodPcts[1], Vendor_ExpectedPeriodAmountPcts[1]);
        PaymentPracticesLibrary.VerifyPeriodLine(PaymentPracticeHeader."No.", "Paym. Prac. Header Type"::Vendor, PaymentPeriods[2].Code, Vendor_ExpectedPeriodPcts[2], Vendor_ExpectedPeriodAmountPcts[2]);
        PaymentPracticesLibrary.VerifyPeriodLine(PaymentPracticeHeader."No.", "Paym. Prac. Header Type"::Vendor, PaymentPeriods[3].Code, Vendor_ExpectedPeriodPcts[3], Vendor_ExpectedPeriodAmountPcts[3]);

        // [THEN] Check that report dataset contains correct percentages for each period for customers
        PrepareExpectedPeriodPcts(Customer_ExpectedPeriodPcts, Customer_ExpectedPeriodAmountPcts, Customer_PeriodCounts, Customer_TotalCount, Customer_PeriodAmounts, Customer_TotalAmount);
        PaymentPracticesLibrary.VerifyPeriodLine(PaymentPracticeHeader."No.", "Paym. Prac. Header Type"::Customer, PaymentPeriods[1].Code, Customer_ExpectedPeriodPcts[1], Customer_ExpectedPeriodAmountPcts[1]);
        PaymentPracticesLibrary.VerifyPeriodLine(PaymentPracticeHeader."No.", "Paym. Prac. Header Type"::Customer, PaymentPeriods[2].Code, Customer_ExpectedPeriodPcts[2], Customer_ExpectedPeriodAmountPcts[2]);
        PaymentPracticesLibrary.VerifyPeriodLine(PaymentPracticeHeader."No.", "Paym. Prac. Header Type"::Customer, PaymentPeriods[3].Code, Customer_ExpectedPeriodPcts[3], Customer_ExpectedPeriodAmountPcts[3]);
    end;

    [Test]
    procedure AveragesCalculationInHeader_PctPaidOnTime()
    var
        PaymentPracticeHeader: Record "Payment Practice Header";
        PaidOnTimeCount: Integer;
        PaidLateCount: Integer;
        UnpaidOverdueCount: Integer;
        ExpectedPctPaidOnTime: Decimal;
        VendorNo: Code[20];
        i: Integer;
    begin
        // [SCENARIO] Check averages calcation in header, for percentage of entries paid in time
        Initialize();

        // [GIVEN] Create a vendor
        VendorNo := LibraryPurchase.CreateVendorNo();

        // [GIVEN] Create a payment practice header for Current Year of type Vendor
        PaymentPracticesLibrary.CreatePaymentPracticeHeaderSimple(PaymentPracticeHeader, "Paym. Prac. Header Type"::Vendor, "Paym. Prac. Aggregation Type"::Period);

        // [GIVEN] Post several entries paid on time, this will affect total entries considered and total entries paid on time.
        PaidOnTimeCount := LibraryRandom.RandInt(20);
        for i := 1 to PaidOnTimeCount do
            MockVendorInvoiceAndPayment(VendorNo, WorkDate(), WorkDate() + LibraryRandom.RandInt(10), WorkDate());

        // [GIVEN] Post several entries paid late, this will affect total entries considered.
        PaidLateCount := LibraryRandom.RandInt(20);
        for i := 1 to PaidLateCount do
            MockVendorInvoiceAndPayment(VendorNo, WorkDate(), WorkDate(), WorkDate() + LibraryRandom.RandInt(10));

        // [GIVEN] Post several entries unpaid overdue, this will affect total entries considered.
        UnpaidOverdueCount := LibraryRandom.RandInt(20);
        for i := 1 to UnpaidOverdueCount do
            MockVendorInvoice(VendorNo, WorkDate() - 50, WorkDate() - LibraryRandom.RandInt(40));

        // [GIVEN] Post several entries unpaid not overdue, these will not affect count
        for i := 1 to LibraryRandom.RandInt(20) do
            MockVendorInvoice(VendorNo, WorkDate(), WorkDate() + LibraryRandom.RandInt(10));

        // [WHEN] Lines were generated for Header
        PaymentPractices.Generate(PaymentPracticeHeader);

        // [THEN] Check that report dataset contains correct percentage paid on time.
        ExpectedPctPaidOnTime := PaidOnTimeCount / (PaidOnTimeCount + PaidLateCount + UnpaidOverdueCount) * 100;
        PaymentPracticeHeader.Get(PaymentPracticeHeader."No.");
        Assert.AreNearlyEqual(ExpectedPctPaidOnTime, PaymentPracticeHeader."Pct Paid On Time", 0.01, 'Pct Paid On Time is not equal to expected.');
    end;

    [Test]
    procedure AveragesCalculationInHeader_ActualPaymentTime()
    var
        PaymentPracticeHeader: Record "Payment Practice Header";
        ExpectedActualPaymentTime: Integer;
        TotalEntries: Integer;
        ActualPaymentTime: Integer;
        ActualPaymentTimeSum: Integer;
        i: Integer;
        VendorNo: Code[20];
    begin
        // [SCENARIO] Check averages calcation in header, for average actual payment times
        Initialize();

        // [GIVEN] Create a vendor
        VendorNo := LibraryPurchase.CreateVendorNo();

        // [GIVEN] Create a payment practice header for Current Year of type Vendor
        PaymentPracticesLibrary.CreatePaymentPracticeHeaderSimple(PaymentPracticeHeader, "Paym. Prac. Header Type"::Vendor, "Paym. Prac. Aggregation Type"::Period);

        // [GIVEN] Post a lot of entries with varying actual payment time
        TotalEntries := LibraryRandom.RandInt(100);
        for i := 1 to TotalEntries do begin
            ActualPaymentTime := LibraryRandom.RandInt(30);
            MockVendorInvoiceAndPayment(VendorNo, WorkDate(), WorkDate(), WorkDate() + ActualPaymentTime);
            ActualPaymentTimeSum += ActualPaymentTime;
        end;

        // [WHEN] Lines were generated for Header
        PaymentPractices.Generate(PaymentPracticeHeader);

        // [THEN] Check that report dataset contains correct average for actual payment time. It's integer, so rounded.
        PaymentPracticeHeader.Get(PaymentPracticeHeader."No.");
        ExpectedActualPaymentTime := Round(ActualPaymentTimeSum / TotalEntries, 1);
        Assert.AreEqual(ExpectedActualPaymentTime, PaymentPracticeHeader."Average Actual Payment Period", 'Average Actual Payment Time is not equal to expected.');
    end;

    [Test]
    procedure AveragesCalculationInHeader_AgreedPaymentTime()
    var
        PaymentPracticeHeader: Record "Payment Practice Header";
        ExpectedAgreedPaymentTime: Integer;
        TotalPaidEntries: Integer;
        TotalUnpaidEntries: Integer;
        AgreedPaymentTime: Integer;
        AgreedPaymentTimeSum: Integer;
        i: Integer;
        VendorNo: Code[20];
    begin
        // [SCENARIO] Check averages calcation in header, for agreed actual payment times
        Initialize();

        // [GIVEN] Create a vendor
        VendorNo := LibraryPurchase.CreateVendorNo();

        // [GIVEN] Create a payment practice header for Current Year of type Vendor
        PaymentPracticesLibrary.CreatePaymentPracticeHeaderSimple(PaymentPracticeHeader, "Paym. Prac. Header Type"::Vendor, "Paym. Prac. Aggregation Type"::Period);

        // [GIVEN] Post a lot of entries with varying agreed payment time. Paid
        TotalPaidEntries := LibraryRandom.RandInt(100);
        for i := 1 to TotalPaidEntries do begin
            AgreedPaymentTime := LibraryRandom.RandInt(30);
            MockVendorInvoiceAndPayment(VendorNo, WorkDate(), WorkDate() + AgreedPaymentTime, WorkDate() + AgreedPaymentTime);
            AgreedPaymentTimeSum += AgreedPaymentTime;
        end;

        // [GIVEN] Post a lot of entries with varying agreed payment time. Unpaid
        TotalUnpaidEntries += LibraryRandom.RandInt(100);
        for i := 1 to TotalUnpaidEntries do begin
            AgreedPaymentTime := LibraryRandom.RandInt(30);
            MockVendorInvoice(VendorNo, WorkDate(), WorkDate() + AgreedPaymentTime);
            AgreedPaymentTimeSum += AgreedPaymentTime;
        end;
        // [WHEN] Lines were generated for Header
        PaymentPractices.Generate(PaymentPracticeHeader);

        // [THEN] Check that report dataset contains correct average for agreed payment time. It's integer, so rounded.
        PaymentPracticeHeader.Get(PaymentPracticeHeader."No.");
        ExpectedAgreedPaymentTime := Round(AgreedPaymentTimeSum / (TotalPaidEntries + TotalUnpaidEntries), 1);
        Assert.AreEqual(ExpectedAgreedPaymentTime, PaymentPracticeHeader."Average Actual Payment Period", 'Average Actual Payment Time is not equal to expected.');
    end;


    [Test]
    procedure ReportDataSetForVendorsByPeriod_DaysToZero()
    var
        PaymentPracticeHeader: Record "Payment Practice Header";
        PaymentPeriod: Record "Payment Period";
        VendorNo: Code[20];
    begin
        // [SCENARIO 493671] Payment is processed correctly for Payment Period with Days To = 0
        Initialize();

        // [GIVEN] Create a vendor
        VendorNo := LibraryPurchase.CreateVendorNo();

        // [GIVEN] Create a payment period with DaysTo = 0
        PaymentPracticesLibrary.InitAndGetLastPaymentPeriod(PaymentPeriod);

        // [GIVEN] Create a payment practice header for Current Year of type Vendor
        PaymentPracticesLibrary.CreatePaymentPracticeHeaderSimple(PaymentPracticeHeader, "Paym. Prac. Header Type"::Vendor, "Paym. Prac. Aggregation Type"::Period);

        // [GIVEN] Post an entry for the vendor in the period
        MockVendorInvoiceAndPaymentInPeriod(VendorNo, WorkDate(), PaymentPeriod."Days From", PaymentPeriod."Days To");

        // [WHEN] Lines were generated for Header
        PaymentPractices.Generate(PaymentPracticeHeader);

        // [THEN] Check that report dataset contains the line for the period correcly
        PaymentPracticesLibrary.VerifyPeriodLine(PaymentPracticeHeader."No.", "Paym. Prac. Header Type"::Vendor, PaymentPeriod.Code, 100, 0);
    end;

    [Test]
    procedure PaymentPracticeHeader_EmptyDate()
    var
        PaymentPracticeHeader: Record "Payment Practice Header";
    begin
        // [SCENARIO 492413] Payment Practice header with empty date is not allowed to generate
        Initialize();

        // [GIVEN] Create a payment practice header with Starting Date = 0D
        PaymentPracticesLibrary.CreatePaymentPracticeHeader(PaymentPracticeHeader, "Paym. Prac. Header Type"::Vendor, "Paym. Prac. Aggregation Type"::"Company Size", 0D, 0D);

        // [WHEN] Generate payment practices for vendors by size
        asserterror PaymentPractices.Generate(PaymentPracticeHeader);

        // [THEN] Error occurs for empty date
        Assert.ExpectedErrorCode('TestField');
    end;

    [Test]
    procedure PaymentPracticeHeader_ValidDates()
    var
        PaymentPracticeHeader: Record "Payment Practice Header";
    begin
        // [SCENARIO 492413] Payment Practice header can't accept starting date > ending date
        Initialize();

        // [GIVEN] Create a payment practice header with Starting Date = 0D and Ending date = 01/01/2020
        PaymentPracticesLibrary.CreatePaymentPracticeHeader(PaymentPracticeHeader, "Paym. Prac. Header Type"::Vendor, "Paym. Prac. Aggregation Type"::"Company Size", 0D, WorkDate());

        // [WHEN] Assigning Startin Date = 10/01/2020
        asserterror PaymentPracticeHeader.Validate("Starting Date", WorkDate() + LibraryRandom.RandInt(10));

        // [THEN] Error occurs for invalid dates
        Assert.ExpectedError('Starting Date must be less than or equal to Ending Date.');
    end;

    [Test]
    procedure PaymentPracticeLine_ModifiedManually()
    var
        PaymentPracticeHeader: Record "Payment Practice Header";
        PaymentPracticeLine: Record "Payment Practice Line";
    begin
        // [SCENARIO 492413] Payment Practice Line "Modified Manually" gets changed when validating numerical values
        Initialize();

        // [GIVEN] Create vendor with size code
        PaymentPracticesLibrary.CreateVendorNoWithSizeAndExcl(CompanySizeCodes[1], false);

        // [GIVEN] Generate payment practices for vendors by size
        PaymentPracticesLibrary.CreatePaymentPracticeHeaderSimple(PaymentPracticeHeader);
        PaymentPractices.Generate(PaymentPracticeHeader);

        // [GIVEN] Find the generated line
        PaymentPracticeLine.SetRange("Header No.", PaymentPracticeHeader."No.");
        PaymentPracticeLine.FindFirst();

        // [WHEN] Modify Pct Paid in Period in line
        PaymentPracticeLine.Validate("Pct Paid in Period", LibraryRandom.RandDecInDecimalRange(0, 50, 2));
        PaymentPracticeLine.Modify();

        // [THEN] "Modified Manually" = true
        PaymentPracticeLine.TestField("Modified Manually");
    end;

    local procedure Initialize()
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Payment Practices UT");

        // This is so demodata and previous tests doesn't influence the tests
        PaymentPracticesLibrary.SetExcludeFromPaymentPracticesOnAllVendorsAndCustomers();

        if Initialized then
            exit;

        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"Payment Practices UT");

        PaymentPracticesLibrary.InitializeCompanySizes(CompanySizeCodes);
        PaymentPracticesLibrary.InitializePaymentPeriods(PaymentPeriods);
        Initialized := true;

        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"Payment Practices UT");
    end;

    local procedure MockVendLedgerEntry(VendorNo: Code[20]; var VendorLedgerEntry: Record "Vendor Ledger Entry"; DocType: Enum "Gen. Journal Document Type"; PostingDate: Date; DueDate: Date; PmtPostingDate: Date; IsOpen: Boolean)
    begin
        VendorLedgerEntry.Init();
        VendorLedgerEntry."Entry No." := LibraryUtility.GetNewRecNo(VendorLedgerEntry, VendorLedgerEntry.FieldNo("Entry No."));
        VendorLedgerEntry."Document Type" := DocType;
        VendorLedgerEntry."Posting Date" := PostingDate;
        VendorLedgerEntry."Document Date" := PostingDate;
        VendorLedgerEntry."Vendor No." := VendorNo;
        VendorLedgerEntry."Due Date" := DueDate;
        VendorLedgerEntry.Open := IsOpen;
        VendorLedgerEntry."Closed at Date" := PmtPostingDate;
        VendorLedgerEntry.Amount := LibraryRandom.RandDec(1000, 2);
        VendorLedgerEntry.Insert();
    end;

    local procedure MockVendorInvoice(VendorNo: Code[20]; PostingDate: Date; DueDate: Date) InvoiceAmount: Decimal;
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
    begin
        MockVendLedgerEntry(VendorNo, VendorLedgerEntry, "Gen. Journal Document Type"::Invoice, PostingDate, DueDate, 0D, true);
        VendorLedgerEntry.CalcFields("Amount (LCY)");
        InvoiceAmount := VendorLedgerEntry."Amount (LCY)";
    end;

    local procedure MockVendorInvoiceAndPayment(VendorNo: Code[20]; PostingDate: Date; DueDate: Date; PaymentPostingDate: Date) InvoiceAmount: Decimal;
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
    begin
        MockVendLedgerEntry(VendorNo, VendorLedgerEntry, "Gen. Journal Document Type"::Invoice, PostingDate, DueDate, PaymentPostingDate, false);
        VendorLedgerEntry.CalcFields("Amount (LCY)");
        InvoiceAmount := VendorLedgerEntry."Amount (LCY)";
    end;

    local procedure MockVendorInvoiceAndPaymentInPeriod(VendorNo: Code[20]; StartingDate: Date; PaidInDays_min: Integer; PaidInDays_max: Integer) InvoiceAmount: Decimal;
    var
        PostingDate: Date;
        DueDate: Date;
        PaymentPostingDate: Date;
    begin
        PostingDate := StartingDate;
        DueDate := StartingDate;
        if PaidInDays_max <> 0 then
            PaymentPostingDate := PostingDate + LibraryRandom.RandIntInRange(PaidInDays_min, PaidInDays_max)
        else
            PaymentPostingDate := PostingDate + PaidInDays_min + LibraryRandom.RandInt(10);
        InvoiceAmount := MockVendorInvoiceAndPayment(VendorNo, PostingDate, DueDate, PaymentPostingDate);
    end;

    local procedure MockCustLedgerEntry(CustomerNo: Code[20]; var CustLedgerEntry: Record "Cust. Ledger Entry"; DocType: Enum "Gen. Journal Document Type"; PostingDate: Date; DueDate: Date; PmtPostingDate: Date; IsOpen: Boolean)
    begin
        CustLedgerEntry.Init();
        CustLedgerEntry."Entry No." := LibraryUtility.GetNewRecNo(CustLedgerEntry, CustLedgerEntry.FieldNo("Entry No."));
        CustLedgerEntry."Document Type" := DocType;
        CustLedgerEntry."Posting Date" := PostingDate;
        CustLedgerEntry."Document Date" := PostingDate;
        CustLedgerEntry."Customer No." := CustomerNo;
        CustLedgerEntry."Due Date" := DueDate;
        CustLedgerEntry.Open := IsOpen;
        CustLedgerEntry."Closed at Date" := PmtPostingDate;
        CustLedgerEntry.Amount := LibraryRandom.RandDec(1000, 2);
        CustLedgerEntry.Insert();
    end;

    local procedure MockCustomerInvoice(CustomerNo: Code[20]; PostingDate: Date; DueDate: Date) InvoiceAmount: Decimal;
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        MockCustLedgerEntry(CustomerNo, CustLedgerEntry, "Gen. Journal Document Type"::Invoice, PostingDate, DueDate, 0D, true);
        CustLedgerEntry.CalcFields("Amount (LCY)");
        InvoiceAmount := CustLedgerEntry."Amount (LCY)";
    end;

    local procedure MockCustomerInvoiceAndPayment(CustomerNo: Code[20]; PostingDate: Date; DueDate: Date; PaymentPostingDate: Date) InvoiceAmount: Decimal;
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        MockCustLedgerEntry(CustomerNo, CustLedgerEntry, "Gen. Journal Document Type"::Invoice, PostingDate, DueDate, PaymentPostingDate, false);
        CustLedgerEntry.CalcFields("Amount (LCY)");
        InvoiceAmount := CustLedgerEntry."Amount (LCY)";
    end;

    local procedure MockCustomerInvoiceAndPaymentInPeriod(CustomerNo: Code[20]; StartingDate: Date; PaidInDays_min: Integer; PaidInDays_max: Integer) InvoiceAmount: Decimal;
    var
        PostingDate: Date;
        DueDate: Date;
        PaymentPostingDate: Date;
    begin
        PostingDate := StartingDate;
        DueDate := StartingDate + LibraryRandom.RandIntInRange(1, 5);
        PaymentPostingDate := PostingDate + LibraryRandom.RandIntInRange(PaidInDays_min, PaidInDays_max);
        InvoiceAmount := MockCustomerInvoiceAndPayment(CustomerNo, PostingDate, DueDate, PaymentPostingDate);
    end;

    local procedure PrepareExpectedPeriodPcts(var ExpectedPeriodPcts: array[3] of Decimal; var ExpectedPeriodAmountPcts: array[3] of Decimal; PeriodCounts: array[3] of Integer; TotalCount: Integer; PeriodAmounts: array[3] of Decimal; TotalAmount: Decimal)
    var
        i: Integer;
    begin
        for i := 1 to ArrayLen(ExpectedPeriodPcts) do begin
            if TotalCount <> 0 then
                ExpectedPeriodPcts[i] := PeriodCounts[i] / TotalCount * 100;
            if TotalAmount <> 0 then
                ExpectedPeriodAmountPcts[i] := PeriodAmounts[i] / TotalAmount * 100;
        end;
    end;

    [ConfirmHandler]
    procedure ConfirmHandler_Yes(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := true;
    end;

    [ConfirmHandler]
    procedure ConfirmHandler_No(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := false;
    end;
}
