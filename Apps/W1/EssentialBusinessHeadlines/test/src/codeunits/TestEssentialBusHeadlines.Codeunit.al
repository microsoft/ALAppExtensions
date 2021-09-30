// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 139600 "Test Essential Bus. Headlines"
{
    Subtype = Test;
    TestPermissions = Disabled;
    EventSubscriberInstance = Manual;

    trigger OnRun()
    begin
        // [FEATURE] [Headlines]
    end;

    var
        EssentialBusinessHeadline: Record "Ess. Business Headline Per Usr";
        RCHeadlinesUserData: Record "RC Headlines User Data";
        SalesHeader: Record "Sales Header";
        Assert: Codeunit Assert;
        TypeHelper: Codeunit "Type Helper";
        EssentialBusHeadlineMgt: Codeunit "Essential Bus. Headline Mgt.";
        LibrarySales: Codeunit "Library - Sales";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryResource: Codeunit "Library - Resource";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryRandom: Codeunit "Library - Random";
        LibraryHeadlines: Codeunit "Library - Headlines";
        TestEssentialBusHeadlines: Codeunit "Test Essential Bus. Headlines";
        HeadlineRcBusinessManagerPage: TestPage "Headline RC Business Manager";
        HeadlineRcRelationshipMgtPage: TestPage "Headline RC Relationship Mgt.";
        HeadlineRcOrderProcessorPage: TestPage "Headline RC Order Processor";
        HeadlineRcAccountantPage: TestPage "Headline RC Accountant";
        IsInitialized: Boolean;
        VATReturnQualifierLbl: Label 'VAT Return';
        OverdueVATReturnPeriodTxt: Label 'Your VAT return is overdue since %1 (%2 days)', Comment = '%1 - date; %2 - days count';
        OpenVATReturnPeriodTxt: Label 'Your VAT return is due %1 (in %2 days)', Comment = '%1 - date; %2 - days count';


    [Test]
    procedure TestMostPopularItemHeadline()
    var
        Customer: Record Customer;
        Item: Record Item;
        Item2: Record Item;
        Item3: Record Item;
    begin
        Initialize();
        // [WHEN] We run the computation with no data to be found
        EssentialBusHeadlineMgt.HandleMostPopularItemHeadline();
        // [THEN] The headline is hidden
        Assert.IsFalse(GetVisibility(EssentialBusinessHeadline."Headline Name"::MostPopularItem), 'Expected most popular item headline not to be visible');

        // [WHEN] We create 2 items and post an invoice with the 2 items, which is not enough, and run the computation
        LibrarySales.CreateCustomer(Customer);
        LibraryInventory.CreateItemWithUnitPriceAndUnitCost(Item, 12, 2);
        LibraryInventory.CreateItemWithUnitPriceAndUnitCost(Item2, 17, 10);
        CreateInvoice(Customer);
        AddSalesLineItem(Item, 1);
        AddSalesLineItem(Item2, 2);
        PostInvoice();
        EssentialBusHeadlineMgt.HandleMostPopularItemHeadline();
        // [THEN] the headline is hidden because we only have 2 items
        Assert.IsFalse(GetVisibility(EssentialBusinessHeadline."Headline Name"::MostPopularItem), 'Expected most popular item headline not to be visible');
        EssentialBusinessHeadline.DeleteAll();
        RCHeadlinesUserData.DeleteAll();
        HeadlineRcBusinessManagerPage.OpenView();
        Assert.IsFalse(HeadlineRcBusinessManagerPage.MostPopularItemText.Visible(), 'Expected most popular item headline not to be visible in the page');
        HeadlineRcBusinessManagerPage.Close();


        // [WHEN] We create a third item, which is enough now, and run the computation
        LibraryInventory.CreateItemWithUnitPriceAndUnitCost(Item3, 17, 10);
        EssentialBusHeadlineMgt.HandleMostPopularItemHeadline();
        // [THEN] The headline is visible and the correct item is in the message
        Assert.IsTrue(GetVisibility(EssentialBusinessHeadline."Headline Name"::MostPopularItem), 'Expected most popular item headline to be visible now');
        Assert.IsTrue(StrPos(GetHeadlineText(EssentialBusinessHeadline."Headline Name"::MostPopularItem), Item2.Description) > 0, 'Expected message to contain item 2 description');
        EssentialBusinessHeadline.DeleteAll();
        RCHeadlinesUserData.DeleteAll();
        HeadlineRcBusinessManagerPage.OpenView();
        Assert.IsTrue(HeadlineRcBusinessManagerPage.MostPopularItemText.Visible(), 'Expected most popular item headline to be visible in the page');
        HeadlineRcBusinessManagerPage.Close();

        Assert.AreEqual('The best-selling item was <emphasize>0123456789012345678901</emphasize> with <emphasize>11,234,567</emphasize> units sold',
            EssentialBusHeadlineMgt.GetBestItemPayload('0123456789012345678901', '11,234,567'), 'Invalid best item text in normal case');

        Assert.AreEqual('The best-selling item was <emphasize>012345678901234567...</emphasize> with <emphasize>111,234,567</emphasize> units sold',
            EssentialBusHeadlineMgt.GetBestItemPayload('0123456789012345678901', '111,234,567'), 'Invalid best item text in truncate case');
    end;

    [Test]
    procedure TestBusiestResourceHeadline()
    var
        Customer: Record Customer;
        Resource: Record Resource;
        Resource2: Record Resource;
        Resource3: Record Resource;
    begin
        Initialize();

        // [WHEN] We run the computation with not enough data
        EssentialBusHeadlineMgt.HandleBusiestResourceHeadline();
        // [THEN] The headline is hidden
        Assert.IsFalse(GetVisibility(EssentialBusinessHeadline."Headline Name"::BusiestResource), 'Expected most busy resource headline not to be visible');


        // [WHEN] We create 2 resources, post an invoice with 2 resources, which is not enough, and run the computation
        LibrarySales.CreateCustomer(Customer);
        CreateResource(Resource);
        CreateResource(Resource2);
        CreateInvoice(Customer);
        AddSalesLineRes(Resource, 1);
        AddSalesLineRes(Resource2, 2);
        PostInvoice();
        EssentialBusHeadlineMgt.HandleBusiestResourceHeadline();
        // [THEN] The headline is hidden
        Assert.IsFalse(GetVisibility(EssentialBusinessHeadline."Headline Name"::BusiestResource), 'Expected most busy resource headline not to be visible');
        EssentialBusinessHeadline.DeleteAll();
        RCHeadlinesUserData.DeleteAll();
        HeadlineRcBusinessManagerPage.OpenView();
        Assert.IsFalse(HeadlineRcBusinessManagerPage.BusiestResourceText.Visible(), 'Expected most busy resource headline not to be visible in the page');
        HeadlineRcBusinessManagerPage.Close();

        // [WHEN] We create a third resource, which is enough now, and run the computation
        CreateResource(Resource3);
        EssentialBusHeadlineMgt.HandleBusiestResourceHeadline();
        // [THEN] The headline is visible and the correct resource is in the message
        Assert.IsTrue(GetVisibility(EssentialBusinessHeadline."Headline Name"::BusiestResource), 'Expected most busy resource headline to be visible now');
        Assert.IsTrue(StrPos(GetHeadlineText(EssentialBusinessHeadline."Headline Name"::BusiestResource), Resource2.Name) > 0, 'Expected message to contain resource 2 name');
        EssentialBusinessHeadline.DeleteAll();
        RCHeadlinesUserData.DeleteAll();
        HeadlineRcBusinessManagerPage.OpenView();
        Assert.IsTrue(HeadlineRcBusinessManagerPage.BusiestResourceText.Visible(), 'Expected most busy resource headline to be visible in the page');
        HeadlineRcBusinessManagerPage.Close();

        Assert.AreEqual('<emphasize>012345678901234567890123456789123456</emphasize> was busy, with <emphasize>11,234,567</emphasize> units booked',
            EssentialBusHeadlineMgt.GetBusiestResoucePayload('012345678901234567890123456789123456', '11,234,567'), 'Invalid busiest resource text in normal case');

        Assert.AreEqual('<emphasize>01234567890123456789012345678912...</emphasize> was busy, with <emphasize>111,234,567</emphasize> units booked',
            EssentialBusHeadlineMgt.GetBusiestResoucePayload('012345678901234567890123456789123456', '111,234,567'), 'Invalid busiest resource text in truncate case');
    end;

    [Test]
    procedure TestLargestOrderHeadline()
    var
        HighestAmount: Decimal;
    begin
        Initialize();

        // [WHEN] We run the computation with not enough data
        EssentialBusHeadlineMgt.HandleLargestOrderHeadline();
        // [THEN] The headline is hidden
        Assert.IsFalse(GetVisibility(EssentialBusinessHeadline."Headline Name"::LargestOrder), 'Expected largest order headline not to be visible');

        // [WHEN] We create 5 orders, which is not enough, and run the computation
        LibrarySales.CreateSalesOrder(SalesHeader);
        SalesHeader.CalcFields(Amount);
        HighestAmount := SalesHeader.Amount;
        LibrarySales.CreateSalesOrder(SalesHeader);
        SalesHeader.CalcFields(Amount);
        if SalesHeader.Amount > HighestAmount then
            HighestAmount := SalesHeader.Amount;
        LibrarySales.CreateSalesOrder(SalesHeader);
        SalesHeader.CalcFields(Amount);
        if SalesHeader.Amount > HighestAmount then
            HighestAmount := SalesHeader.Amount;
        LibrarySales.CreateSalesOrder(SalesHeader);
        SalesHeader.CalcFields(Amount);
        if SalesHeader.Amount > HighestAmount then
            HighestAmount := SalesHeader.Amount;
        LibrarySales.CreateSalesOrder(SalesHeader);
        SalesHeader.CalcFields(Amount);
        if SalesHeader.Amount > HighestAmount then
            HighestAmount := SalesHeader.Amount;
        EssentialBusHeadlineMgt.HandleLargestOrderHeadline();
        // [THEN] The headline is hidden
        Assert.IsFalse(GetVisibility(EssentialBusinessHeadline."Headline Name"::LargestOrder), 'Expected largest order headline not to be visible');
        EssentialBusinessHeadline.DeleteAll();
        RCHeadlinesUserData.DeleteAll();
        HeadlineRcBusinessManagerPage.OpenView();
        Assert.IsFalse(HeadlineRcBusinessManagerPage.LargestOrderText.Visible(), 'Expected largest order headline not to be visible in the page');
        HeadlineRcBusinessManagerPage.Close();
        EssentialBusinessHeadline.DeleteAll();
        RCHeadlinesUserData.DeleteAll();
        HeadlineRcOrderProcessorPage.OpenView();
        Assert.IsFalse(HeadlineRcOrderProcessorPage.LargestOrderText.Visible(), 'Expected largest order headline not to be visible in the page');
        HeadlineRcOrderProcessorPage.Close();
        EssentialBusinessHeadline.DeleteAll();
        RCHeadlinesUserData.DeleteAll();
        HeadlineRcAccountantPage.OpenView();
        Assert.IsFalse(HeadlineRcAccountantPage.LargestOrderText.Visible(), 'Expected largest order headline not to be visible in the page');
        HeadlineRcAccountantPage.Close();

        // [WHEN] We create 1 more order, which is enough, and run the computation
        LibrarySales.CreateSalesOrder(SalesHeader);
        SalesHeader.CalcFields(Amount);
        if SalesHeader.Amount > HighestAmount then
            HighestAmount := SalesHeader.Amount;
        EssentialBusHeadlineMgt.HandleLargestOrderHeadline();
        // [THEN] The headline is visible and the correct message is set
        Assert.IsTrue(GetVisibility(EssentialBusinessHeadline."Headline Name"::LargestOrder), 'Expected largest order headline to be visible now');
        Assert.IsTrue(StrPos(GetHeadlineText(EssentialBusinessHeadline."Headline Name"::LargestOrder), Format(HighestAmount, 0, TypeHelper.GetAmountFormatLCYWithUserLocale())) > 0, 'Incorrect amount of the largest order');
        EssentialBusinessHeadline.DeleteAll();
        RCHeadlinesUserData.DeleteAll();
        HeadlineRcBusinessManagerPage.OpenView();
        Assert.IsTrue(HeadlineRcBusinessManagerPage.LargestOrderText.Visible(), 'Expected largest order headline to be visible in the page');
        HeadlineRcBusinessManagerPage.Close();
        EssentialBusinessHeadline.DeleteAll();
        RCHeadlinesUserData.DeleteAll();
        HeadlineRcOrderProcessorPage.OpenView();
        Assert.IsTrue(HeadlineRcOrderProcessorPage.LargestOrderText.Visible(), 'Expected largest order headline to be visible in the page');
        HeadlineRcOrderProcessorPage.Close();
        EssentialBusinessHeadline.DeleteAll();
        RCHeadlinesUserData.DeleteAll();
        HeadlineRcAccountantPage.OpenView();
        Assert.IsTrue(HeadlineRcAccountantPage.LargestOrderText.Visible(), 'Expected largest order headline to be visible in the page');
        HeadlineRcAccountantPage.Close();
    end;

    [Test]
    procedure TestLargestSaleHeadline()
    var
        Customer: Record Customer;
        Item: Record Item;
        HighestAmount: Decimal;
        CurrentAmount: Decimal;
    begin
        Initialize();

        // [WHEN] We run the computation with not enought data
        EssentialBusHeadlineMgt.HandleLargestSaleHeadline();
        // [THEN] The headline is hidden
        Assert.IsFalse(GetVisibility(EssentialBusinessHeadline."Headline Name"::LargestSale), 'Expected largest sale headline not to be visible');

        // [WHEN] We post 5 invoices, which is not enough, and run the computation
        LibrarySales.CreateCustomer(Customer);
        LibraryInventory.CreateItemWithUnitPriceAndUnitCost(Item, 12, 2);
        CreateInvoice(Customer);
        AddSalesLineItem(Item, 1);
        HighestAmount := PostInvoice();
        CreateInvoice(Customer);
        AddSalesLineItem(Item, 2);
        CurrentAmount := PostInvoice();
        if CurrentAmount > HighestAmount then
            HighestAmount := CurrentAmount;
        CreateInvoice(Customer);
        AddSalesLineItem(Item, 3);
        CurrentAmount := PostInvoice();
        if CurrentAmount > HighestAmount then
            HighestAmount := CurrentAmount;
        CreateInvoice(Customer);
        AddSalesLineItem(Item, 4);
        CurrentAmount := PostInvoice();
        if CurrentAmount > HighestAmount then
            HighestAmount := CurrentAmount;
        CreateInvoice(Customer);
        AddSalesLineItem(Item, 5);
        CurrentAmount := PostInvoice();
        if CurrentAmount > HighestAmount then
            HighestAmount := CurrentAmount;
        EssentialBusHeadlineMgt.HandleLargestSaleHeadline();
        // [THEN] The headline is hidden
        Assert.IsFalse(GetVisibility(EssentialBusinessHeadline."Headline Name"::LargestSale), 'Expected largest sale headline not to be visible');
        EssentialBusinessHeadline.DeleteAll();
        RCHeadlinesUserData.DeleteAll();
        HeadlineRcBusinessManagerPage.OpenView();
        Assert.IsFalse(HeadlineRcBusinessManagerPage.LargestSaleText.Visible(), 'Expected largest sale headline not to be visible in the page');
        HeadlineRcBusinessManagerPage.Close();
        EssentialBusinessHeadline.DeleteAll();
        RCHeadlinesUserData.DeleteAll();
        HeadlineRcOrderProcessorPage.OpenView();
        Assert.IsFalse(HeadlineRcOrderProcessorPage.LargestSaleText.Visible(), 'Expected largest sale headline not to be visible in the page');
        HeadlineRcOrderProcessorPage.Close();
        EssentialBusinessHeadline.DeleteAll();
        RCHeadlinesUserData.DeleteAll();
        HeadlineRcAccountantPage.OpenView();
        Assert.IsFalse(HeadlineRcAccountantPage.LargestSaleText.Visible(), 'Expected largest sale headline not to be visible in the page');
        HeadlineRcAccountantPage.Close();

        // [WHEN] We post 1 more sale invoice, which is enough now, and run the computation
        CreateInvoice(Customer);
        AddSalesLineItem(Item, 6);
        CurrentAmount := PostInvoice();
        if CurrentAmount > HighestAmount then
            HighestAmount := CurrentAmount;
        EssentialBusHeadlineMgt.HandleLargestSaleHeadline();
        // [THEN] The headline is set and the correct message is set
        Assert.IsTrue(GetVisibility(EssentialBusinessHeadline."Headline Name"::LargestSale), 'Expected largest sale headline to be visible now');
        Assert.IsTrue(StrPos(GetHeadlineText(EssentialBusinessHeadline."Headline Name"::LargestSale), Format(HighestAmount, 0, TypeHelper.GetAmountFormatLCYWithUserLocale())) > 0, 'Incorrect amount of the largest sale');
        EssentialBusinessHeadline.DeleteAll();
        RCHeadlinesUserData.DeleteAll();
        HeadlineRcBusinessManagerPage.OpenView();
        Assert.IsTrue(HeadlineRcBusinessManagerPage.LargestSaleText.Visible(), 'Expected largest sale headline to be visible in the page');
        HeadlineRcBusinessManagerPage.Close();
        EssentialBusinessHeadline.DeleteAll();
        RCHeadlinesUserData.DeleteAll();
        HeadlineRcOrderProcessorPage.OpenView();
        Assert.IsTrue(HeadlineRcOrderProcessorPage.LargestSaleText.Visible(), 'Expected largest sale headline to be visible in the page');
        HeadlineRcOrderProcessorPage.Close();
        EssentialBusinessHeadline.DeleteAll();
        RCHeadlinesUserData.DeleteAll();
        HeadlineRcAccountantPage.OpenView();
        Assert.IsTrue(HeadlineRcAccountantPage.LargestSaleText.Visible(), 'Expected largest sale headline to be visible in the page');
        HeadlineRcAccountantPage.Close();
    end;

    [Test]
    procedure TestSalesIncreaseHeadline()
    var
        Customer: Record Customer;
        Item: Record Item;
        OldWorkDate: Date;
    begin
        Initialize();

        // [WHEN] We run the computation with not enough data
        EssentialBusHeadlineMgt.HandleSalesIncreaseHeadline();
        // [THEN] The headline is hidden
        Assert.IsFalse(GetVisibility(EssentialBusinessHeadline."Headline Name"::SalesIncrease), 'Expected sales increase headline not to be visible');

        // [WHEN] We post 1 sales invoice last year, and run the computation
        OldWorkDate := WorkDate();
        WorkDate(Calcdate('<-1Y>', WorkDate()));
        LibrarySales.CreateCustomer(Customer);
        LibraryInventory.CreateItemWithUnitPriceAndUnitCost(Item, 12, 2);
        CreateInvoice(Customer);
        AddSalesLineItem(Item, 1);
        PostInvoice();
        EssentialBusHeadlineMgt.HandleSalesIncreaseHeadline();
        // [THEN] The headline is hidden
        Assert.IsFalse(GetVisibility(EssentialBusinessHeadline."Headline Name"::SalesIncrease), 'Expected sales increase not to be visible');

        // [WHEN] We post 1 sale invoice this year, which is not enough because it does not increase, and run the computation
        WorkDate(OldWorkDate);
        CreateInvoice(Customer);
        AddSalesLineItem(Item, 1);
        PostInvoice();
        EssentialBusHeadlineMgt.HandleSalesIncreaseHeadline();
        // [THEN] The headline is hidden
        Assert.IsFalse(GetVisibility(EssentialBusinessHeadline."Headline Name"::SalesIncrease), 'Expected sales increase not to be visible');
        EssentialBusinessHeadline.DeleteAll();
        RCHeadlinesUserData.DeleteAll();
        HeadlineRcBusinessManagerPage.OpenView();
        Assert.IsFalse(HeadlineRcBusinessManagerPage.SalesIncreaseText.Visible(), 'Expected sales increase not to be visible in the page');
        HeadlineRcBusinessManagerPage.Close();
        EssentialBusinessHeadline.DeleteAll();
        RCHeadlinesUserData.DeleteAll();
        HeadlineRcAccountantPage.OpenView();
        Assert.IsFalse(HeadlineRcAccountantPage.SalesIncreaseText.Visible(), 'Expected sales increase headline not to be visible in the page');
        HeadlineRcAccountantPage.Close();

        // [WHEN] We post another sale invoice this year, which is now enough, and run the computation
        CreateInvoice(Customer);
        AddSalesLineItem(Item, 2);
        PostInvoice();
        EssentialBusHeadlineMgt.HandleSalesIncreaseHeadline();
        // [THEN] The headline is visible and the correct message is set
        Assert.IsTrue(GetVisibility(EssentialBusinessHeadline."Headline Name"::SalesIncrease), 'Expected sales increase to be visible now');
        Assert.IsTrue(StrPos(GetHeadlineText(EssentialBusinessHeadline."Headline Name"::SalesIncrease), '<emphasize>1</emphasize> ') > 0, 'Incorrect increase of sales');
        EssentialBusinessHeadline.DeleteAll();
        RCHeadlinesUserData.DeleteAll();
        HeadlineRcBusinessManagerPage.OpenView();
        Assert.IsTrue(HeadlineRcBusinessManagerPage.SalesIncreaseText.Visible(), 'Expected sales increase to be visible in the page');
        HeadlineRcBusinessManagerPage.Close();
        EssentialBusinessHeadline.DeleteAll();
        RCHeadlinesUserData.DeleteAll();
        HeadlineRcAccountantPage.OpenView();
        Assert.IsTrue(HeadlineRcAccountantPage.SalesIncreaseText.Visible(), 'Expected sales increase headline to be visible in the page');
        HeadlineRcAccountantPage.Close();
    end;

    [Test]
    procedure TestInvalidateHeadlines()
    var
        UserSettings: TestPage "User Settings";
    begin
        Initialize();

        // [WHEN] We don't change the date
        EssentialBusinessHeadline.GetOrCreateHeadline(EssentialBusinessHeadline."Headline Name"::BusiestResource);
        // [THEN] Nothing happens
        Assert.IsFalse(EssentialBusinessHeadline.IsEmpty(), 'expected the headlines not to be deleted when not changing workdate nor language');

        // [WHEN] We change the date to the same one
        UserSettings.OpenEdit();
        UserSettings."Work Date".Value(Format(WorkDate()));
        UserSettings.OK().Invoke();
        // [THEN] Nothing happens
        Assert.IsFalse(EssentialBusinessHeadline.IsEmpty(), 'expected the headlines not to be deleted when changing workdate to the same workdate');

        // [WHEN] We change the date
        UserSettings.OpenEdit();
        UserSettings."Work Date".Value(Format(0D));
        UserSettings.OK().Invoke();
        // [THEN] Headlines are invalidated
        Assert.IsTrue(EssentialBusinessHeadline.IsEmpty(), 'expected the headlines to be deleted when changing workdate');
    end;

    [Test]
    procedure TestTopCustomerHeadline()
    var
        Customer: Record Customer;
        Customer2: Record Customer;
        Item: Record Item;
        CustLedgerEntry: Record "Cust. Ledger Entry";
        AmountLcy: Decimal;
    begin
        Initialize();

        // [WHEN] We run the computation with no data to be found
        EssentialBusHeadlineMgt.HandleTopCustomer();
        // [THEN] The headline is hidden
        Assert.IsFalse(GetVisibility(EssentialBusinessHeadline."Headline Name"::TopCustomer), 'Expected best customer headline not to be visible');


        // [WHEN] We create 1 item and post 2 invoices, which is not enough, and run the computation
        LibrarySales.CreateCustomer(Customer);
        Customer.Validate(Name, 'John Doe');
        Customer.Modify();
        LibraryInventory.CreateItemWithUnitPriceAndUnitCost(Item, 12, 2);
        CreateInvoice(Customer);
        AddSalesLineItem(Item, 1);
        PostInvoice();
        CreateInvoice(Customer);
        AddSalesLineItem(Item, 10);
        PostInvoice();
        EssentialBusHeadlineMgt.HandleTopCustomer();
        // [THEN] the headline is hidden because we only have 1 customer buying from us
        Assert.IsFalse(GetVisibility(EssentialBusinessHeadline."Headline Name"::TopCustomer), 'Expected best customer headline not to be visible');
        EssentialBusinessHeadline.DeleteAll();
        RCHeadlinesUserData.DeleteAll();
        HeadlineRcRelationshipMgtPage.OpenView();
        Assert.IsFalse(HeadlineRcRelationshipMgtPage.TopCustomerText.Visible(), 'Expected best customer headline not to be visible in the page');
        HeadlineRcRelationshipMgtPage.Close();

        // [WHEN] We create another invoice for another customer, which is enough now, and run the computation
        LibrarySales.CreateCustomer(Customer2);
        CreateInvoice(Customer2);
        AddSalesLineItem(Item, 2);
        PostInvoice();
        EssentialBusHeadlineMgt.HandleTopCustomer();
        // [THEN] The headline is visible and the correct customer is in the message
        Assert.IsTrue(GetVisibility(EssentialBusinessHeadline."Headline Name"::TopCustomer), 'Expected best customer headline to be visible now');
        Assert.IsTrue(StrPos(GetHeadlineText(EssentialBusinessHeadline."Headline Name"::TopCustomer), 'John Doe') > 0, 'Expected message to contain customer name');
        CustLedgerEntry.SetRange("Customer No.", Customer."No.");
        CustLedgerEntry.FindSet();
        repeat
            CustLedgerEntry.CalcFields("Amount (LCY)");
            AmountLcy += CustLedgerEntry."Amount (LCY)";
        until CustLedgerEntry.Next() = 0;
        Assert.IsTrue(StrPos(GetHeadlineText(EssentialBusinessHeadline."Headline Name"::TopCustomer), Format(AmountLcy, 0, TypeHelper.GetAmountFormatLCYWithUserLocale())) > 0, 'Expected message to contain correct amount for customer');
        EssentialBusinessHeadline.DeleteAll();
        RCHeadlinesUserData.DeleteAll();
        HeadlineRcRelationshipMgtPage.OpenView();
        Assert.IsTrue(HeadlineRcRelationshipMgtPage.TopCustomerText.Visible(), 'Expected best customer headline to be visible in the page');
        HeadlineRcRelationshipMgtPage.Close();

        Assert.AreEqual('Your top customer was <emphasize>012345678901234567890123456789</emphasize>, bought for <emphasize>234,567 kr</emphasize>',
            EssentialBusHeadlineMgt.GetTopCustomerPayload('012345678901234567890123456789', '234,567 kr'), 'Invalid top customer text in normal case');

        Assert.AreEqual('Your top customer was <emphasize>0123456789012345678901234...</emphasize>, bought for <emphasize>1,234,567 kr</emphasize>',
            EssentialBusHeadlineMgt.GetTopCustomerPayload('01234567890123456789012345678', '1,234,567 kr'), 'Invalid top customer text in truncate case');
    end;

    [Test]
    procedure TestOpenOverdueVATReturnHeadlineIsVisible()
    var
        DueDate: Date;
        DaysCount: Integer;
    begin
        // [FEATURE] [VAT Return Period]
        // [SCENARIO 258181] Open VAT Return Period with overdue Due Date is visible
        // [SCENARIO 306583] The calculation is based on VATReportSetup."Period Reminder Calculation"
        Initialize();

        // [GIVEN] No VAT Return Period records, WorkDate = 20-01-2020
        DaysCount := LibraryRandom.RandIntInRange(10, 30);
        DueDate := WorkDate() - DaysCount;
        // [GIVEN] Run the computation, both OverdueVATReturn and OpenVATReturnheadline are hidden
        VerifyVATReturnPeriodHeadlinesAreNotVisible();

        // [GIVEN] A new Open VAT Return Period record with Due Date = 10-01-2020
        MockOpenVATReturnPeriod(DueDate);

        // [WHEN] Run the headline computation
        ComputeVATReturnHeadlines();

        // [THEN] OverdueVATReturn Headline is visible: "Your VAT return is overdue since 10-01-2020 (10 days)"
        VerifyOverdueVATReturnPeriodHeadlineIsVisible(DueDate, DaysCount);
        VerifyUpcomingVATReturnPeriodHeadlineIsNotVisible();
    end;

    [Test]
    procedure TestClosedOverdueVATReturnHeadlineIsNotVisible()
    var
        DueDate: Date;
        DaysCount: Integer;
    begin
        // [FEATURE] [VAT Return Period]
        // [SCENARIO 258181] Closed VAT Return Period with overdue Due Date is not visible
        // [SCENARIO 306583] The calculation is based on VATReportSetup."Period Reminder Calculation"
        Initialize();

        // [GIVEN] No VAT Return Period records, WorkDate = 20-01-2020
        DaysCount := LibraryRandom.RandIntInRange(10, 30);
        DueDate := WorkDate() - DaysCount;
        // [GIVEN] Run the computation, both OverdueVATReturn and OpenVATReturnheadline are hidden
        VerifyVATReturnPeriodHeadlinesAreNotVisible();

        // [GIVEN] A new Closed VAT Return Period record with Due Date = 10-01-2020
        MockClosedVATReturnPeriod(DueDate);

        // [WHEN] Run the headline computation
        ComputeVATReturnHeadlines();

        // [THEN] OverdueVATReturn Headline is not visible
        VerifyOverdueVATReturnPeriodHeadlineIsNotVisible();
        VerifyUpcomingVATReturnPeriodHeadlineIsNotVisible();
    end;

    [Test]
    procedure TestUpcomingOpenVATReturnHeadlineIsVisible()
    var
        DueDate: Date;
        DaysCount: Integer;
    begin
        // [FEATURE] [VAT Return Period]
        // [SCENARIO 258181] Open VAT Return Period with upcoming Due Date is visible
        // [SCENARIO 306583] The calculation is based on VATReportSetup."Period Reminder Calculation"
        Initialize();

        // [GIVEN] No VAT Return Period records, WorkDate = 20-01-2020, VATReportSetup."Period Reminder Time" = 10
        DaysCount := LibraryRandom.RandIntInRange(10, 30);
        DueDate := WorkDate() + DaysCount;
        UpdateVATReportSetup(DaysCount);
        // [GIVEN] Run the computation, both OverdueVATReturn and OpenVATReturnheadline are hidden
        VerifyVATReturnPeriodHeadlinesAreNotVisible();

        // [GIVEN] A new VAT Return Period record with Due Date = 25-01-2020
        MockOpenVATReturnPeriod(DueDate);

        // [WHEN] Run the headline computation
        ComputeVATReturnHeadlines();

        // [THEN] OpenVATReturn Headline is visible: "Your VAT return is due 25-01-2020 (in 5 days)"
        VerifyUpcomingVATReturnPeriodHeadlineIsVisible(DueDate, DaysCount);
        VerifyOverdueVATReturnPeriodHeadlineIsNotVisible();
    end;

    [Test]
    procedure TestNotUpcomingOpenVATReturnHeadlineIsNotVisible()
    var
        DueDate: Date;
        DaysCount: Integer;
    begin
        // [FEATURE] [VAT Return Period]
        // [SCENARIO 258181] Open VAT Return Period with not upcoming Due Date is not visible
        // [SCENARIO 306583] The calculation is based on VATReportSetup."Period Reminder Calculation"
        Initialize();

        // [GIVEN] No VAT Return Period records, WorkDate = 20-01-2020, VATReportSetup."Period Reminder Time" = 10
        DaysCount := LibraryRandom.RandIntInRange(10, 30);
        DueDate := WorkDate() + DaysCount + 1;
        UpdateVATReportSetup(DaysCount);
        // [GIVEN] Run the computation, both OverdueVATReturn and OpenVATReturnheadline are hidden
        VerifyVATReturnPeriodHeadlinesAreNotVisible();

        // [GIVEN] A new VAT Return Period record with Due Date = 31-01-2020
        MockOpenVATReturnPeriod(DueDate);

        // [WHEN] Run the headline computation
        ComputeVATReturnHeadlines();

        // [THEN] OpenVATReturn Headline is not visible
        VerifyUpcomingVATReturnPeriodHeadlineIsNotVisible();
        VerifyOverdueVATReturnPeriodHeadlineIsNotVisible();
    end;

    [Test]
    procedure TestUpcomingClosedVATReturnHeadlineIsNotVisible()
    var
        DueDate: Date;
        DaysCount: Integer;
    begin
        // [FEATURE] [VAT Return Period]
        // [SCENARIO 258181] Closed VAT Return Period with upcoming Due Date is not visible
        // [SCENARIO 306583] The calculation is based on VATReportSetup."Period Reminder Calculation"
        Initialize();

        // [GIVEN] No VAT Return Period records, WorkDate = 20-01-2020, VATReportSetup."Period Reminder Time" = 10
        DaysCount := LibraryRandom.RandIntInRange(10, 30);
        DueDate := WorkDate() + DaysCount;
        UpdateVATReportSetup(DaysCount);
        // [GIVEN] Run the computation, both OverdueVATReturn and OpenVATReturnheadline are hidden
        VerifyVATReturnPeriodHeadlinesAreNotVisible();

        // [GIVEN] A new Closed VAT Return Period record with Due Date = 25-01-2020
        MockClosedVATReturnPeriod(DueDate);

        // [WHEN] Run the headline computation
        ComputeVATReturnHeadlines();

        // [THEN] Both OverdueVATReturn and OpenVATReturnheadline are hidden
        VerifyUpcomingVATReturnPeriodHeadlineIsNotVisible();
        VerifyOverdueVATReturnPeriodHeadlineIsNotVisible();
    end;

    [Test]
    procedure TestNotUpcomingClosedVATReturnHeadlineIsNotVisible()
    var
        DueDate: Date;
        DaysCount: Integer;
    begin
        // [FEATURE] [VAT Return Period]
        // [SCENARIO 258181] Closed VAT Return Period with not upcoming Due Date is not visible
        // [SCENARIO 306583] The calculation is based on VATReportSetup."Period Reminder Calculation"
        Initialize();

        // [GIVEN] No VAT Return Period records, WorkDate = 20-01-2020, VATReportSetup."Period Reminder Time" = 10
        DaysCount := LibraryRandom.RandIntInRange(10, 30);
        DueDate := WorkDate() + DaysCount + 1;
        UpdateVATReportSetup(DaysCount);
        // [GIVEN] Run the computation, both OverdueVATReturn and OpenVATReturnheadline are hidden
        VerifyVATReturnPeriodHeadlinesAreNotVisible();

        // [GIVEN] A new Closed VAT Return Period record with Due Date = 31-01-2020
        MockClosedVATReturnPeriod(DueDate);

        // [WHEN] Run the headline computation
        ComputeVATReturnHeadlines();

        // [THEN] Both OverdueVATReturn and OpenVATReturnheadline are hidden
        VerifyUpcomingVATReturnPeriodHeadlineIsNotVisible();
        VerifyOverdueVATReturnPeriodHeadlineIsNotVisible();
    end;

    [Test]
    procedure TestBothUpcomingAndOverdueVATReturnHeadlinesAreVisible()
    var
        UpcomingDueDate: Date;
        UpcomingDaysCount: Integer;
        OverdueDueDate: Date;
        OverdueDaysCount: Integer;
    begin
        // [FEATURE] [VAT Return Period]
        // [SCENARIO 258181] Both upcoming Open VAT Return Period and overdue open VAT Return Period are visible
        // [SCENARIO 306583] The calculation is based on VATReportSetup."Period Reminder Calculation"
        Initialize();

        // [GIVEN] No VAT Return Period records, WorkDate = 20-01-2020, VATReportSetup."Period Reminder Time" = 10
        OverdueDaysCount := LibraryRandom.RandIntInRange(10, 30);
        OverdueDueDate := WorkDate() - OverdueDaysCount;
        UpcomingDaysCount := LibraryRandom.RandIntInRange(10, 30);
        UpcomingDueDate := WorkDate() + UpcomingDaysCount;
        UpdateVATReportSetup(UpcomingDaysCount);
        // [GIVEN] Run the computation, both OverdueVATReturn and OpenVATReturnheadline are hidden
        VerifyVATReturnPeriodHeadlinesAreNotVisible();

        // [GIVEN] A new Open VAT Return Period record with Due Date = 10-01-2020
        MockOpenVATReturnPeriod(OverdueDueDate);
        // [GIVEN] A new Open VAT Return Period record with Due Date = 25-01-2020
        MockOpenVATReturnPeriod(UpcomingDueDate);

        // [WHEN] Run the headline computation
        ComputeVATReturnHeadlines();

        // [THEN] OpenVATReturn Headline is visible: "Your VAT return is due 25-01-2020 (in 5 days)"
        // [THEN] OverdueVATReturn Headline is visible: "Your VAT return is overdue since 10-01-2020 (10 days)"
        VerifyUpcomingVATReturnPeriodHeadlineIsVisible(UpcomingDueDate, UpcomingDaysCount);
        VerifyOverdueVATReturnPeriodHeadlineIsVisible(OverdueDueDate, OverdueDaysCount);
    end;


    [Test]
    procedure TestRecentlyOverdueInvoiceHeadlineInitialVisibility()
    begin
        // [GIVEN] Initial state when no data is present
        Initialize();

        // [WHEN] We run the computation
        EssentialBusHeadlineMgt.HandleRecentlyOverdueInvoices();

        // [THEN] The headline is hidden
        Assert.IsFalse(GetVisibility(EssentialBusinessHeadline."Headline Name"::RecentlyOverdueInvoices), 'Expected recently overdue invoices headline not to be visible');
    end;

    [Test]
    procedure TestRecentlyOverdueInvoiceHeadlineWithOneInvoice()
    begin
        TestRecentlyOverdueInvoiceWithOverdueInvoices(1);
    end;

    [Test]
    procedure TestRecentlyOverdueInvoiceHeadlineWithTwoInvoice()
    begin
        TestRecentlyOverdueInvoiceWithOverdueInvoices(2);
    end;

    [Test]
    procedure TestRecentlyOverdueInvoiceHeadlineWithFiveInvoice()
    begin
        TestRecentlyOverdueInvoiceWithOverdueInvoices(5);
    end;

    local procedure TestRecentlyOverdueInvoiceWithOverdueInvoices(NumberOfNewlyOverdueInvoices: Integer)
    var
        OverdueInvoicesTxt: Text;
        OverdueInvoicesAmountTxt: Text;
        TotalAmount: Decimal;
    begin

        // [GIVEN] Initial step with one invoice that was due yesterday
        Initialize();


        OverdueInvoicesTxt := StrSubstNo('Overdue invoices up by <emphasize>%1</emphasize>.', NumberOfNewlyOverdueInvoices);
        TotalAmount := CreateInvoicesWithDueDateYesterday(NumberOfNewlyOverdueInvoices);
        OverdueInvoicesAmountTxt := StrSubstNo('You can collect <emphasize>%1</emphasize>', EssentialBusHeadlineMgt.FormatLocalCurrency(TotalAmount));
        CreateRandomNumberOfOlderOverdueInvoices();

        // [WHEN] We run the computation
        EssentialBusHeadlineMgt.HandleRecentlyOverdueInvoices();

        // [THEN] The headline is visible and the message is correct
        EssentialBusinessHeadline.Get(EssentialBusinessHeadline."Headline Name"::RecentlyOverdueInvoices, UserSecurityId());

        Assert.IsTrue(EssentialBusinessHeadline."Headline Visible", 'Expected recently overdue invoices headline to be visible');
        Assert.IsTrue(StrPos(EssentialBusinessHeadline."Headline Text", OverdueInvoicesTxt) > 0, 'Wrong number of sales invoices');
        Assert.IsTrue(StrPos(EssentialBusinessHeadline."Headline Text", OverdueInvoicesAmountTxt) > 0, 'Wrong total amount');
    end;


    procedure Initialize()
    var
        Item: Record Item;
        SalesInvoiceHeader: Record "Sales Invoice Header";
        Resource: Record Resource;
        SalesLine: Record "Sales Line";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        VATReturnPeriod: Record "VAT Return Period";
        EssentialBusinessHeadlines: Record "Ess. Business Headline Per Usr";
        LibraryERMCountryData: Codeunit "Library - ERM Country Data";
    begin
        EssentialBusinessHeadlines.DeleteAll();
        Item.DeleteAll();
        Resource.DeleteAll();
        SalesInvoiceHeader.DeleteAll();
        SalesHeader.DeleteAll();
        SalesLine.DeleteAll();
        CustLedgerEntry.DeleteAll();
        VATReturnPeriod.DeleteAll();
        if IsInitialized then
            exit;

        BindSubscription(LibraryHeadlines);
        Bindsubscription(TestEssentialBusHeadlines);
        LibraryERMCountryData.UpdateLocalData();
        FillInCompanyForCurrentUser();

        IsInitialized := true;
    end;

    local procedure CreateInvoice(Customer: Record Customer);
    var
    begin
        Clear(SalesHeader);
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Invoice, Customer."No.");
    end;

    local procedure MockOpenVATReturnPeriod(NewDueDate: Date)
    var
        DummyVATReturnPeriod: Record "VAT Return Period";
    begin
        MockVATReturnPeriod(NewDueDate, DummyVATReturnPeriod.Status::Open);
    end;

    local procedure MockClosedVATReturnPeriod(NewDueDate: Date)
    var
        DummyVATReturnPeriod: Record "VAT Return Period";
    begin
        MockVATReturnPeriod(NewDueDate, DummyVATReturnPeriod.Status::Closed);
    end;

    local procedure MockVATReturnPeriod(NewDueDate: Date; NewStatus: Option)
    var
        VATReturnPeriod: Record "VAT Return Period";
    begin
        with VATReturnPeriod do begin
            "No." := LibraryUtility.GenerateGUID();
            Status := NewStatus;
            "Due Date" := NewDueDate;
            Insert();
        end;
    end;

    local procedure CreateInvoicesWithDueDateYesterday(NumberOfInvoices: Integer): Decimal
    var
        Yesterday: Date;
        Count: Integer;
        TotalAmount: Decimal;
    begin
        Yesterday := CalcDate('<-1D>', WorkDate());
        TotalAmount := 0.0;
        for Count := 1 to NumberOfInvoices do
            TotalAmount := TotalAmount + CreateInvoiceWithDueDate(Yesterday);

        SetDueDateInCasePaymentTermsAreUsed(Yesterday);
        exit(TotalAmount);
    end;

    local procedure CreateInvoiceWithDueDate(DueDate: Date): Decimal
    var
        SalesHeaderLocal: Record "Sales Header";
        Amount: Decimal;
    begin
        LibrarySales.CreateSalesInvoice(SalesHeaderLocal);
        SalesHeaderLocal.Validate("Due Date", DueDate);
        SalesHeaderLocal.Modify(true);

        SalesHeaderLocal.CalcFields("Amount Including VAT");
        Amount := SalesHeaderLocal."Amount Including VAT";

        LibrarySales.PostSalesDocument(SalesHeaderLocal, false, true);
        exit(Amount);
    end;

    local procedure SetDueDateInCasePaymentTermsAreUsed(DueDate: Date)
    var
        CustomerLedgerEntry: Record "Cust. Ledger Entry";
    begin
        // For some countries (currently only Italy) the original sales invoices are split into [potentially]
        // multiple payment lines - and then payment lines are inserted into customer ledger entry instead
        // (with its own due date which is different from the due date of the sales invoice).
        // Ensure that the due date is set correctly by setting it in the customer ledger entry.
        CustomerLedgerEntry.SetRange(Open, true);
        CustomerLedgerEntry.SetRange("Document Type", CustomerLedgerEntry."Document Type"::Invoice);
        CustomerLedgerEntry.FindSet();
        repeat
            CustomerLedgerEntry."Due Date" := DueDate;
            CustomerLedgerEntry.Modify();
        until CustomerLedgerEntry.Next() = 0;
    end;

    local procedure CreateRandomNumberOfOlderOverdueInvoices()
    var
        DueDate: Date;
        RandomNumber: Integer;
        Count: Integer;
    begin
        // Get random number between 0 and 5, inclusive
        RandomNumber := Random(6) - 1;

        // Create Random number of overdue invoices with due date before yesterday
        for Count := 1 to RandomNumber do begin
            // Get random date, 1 to 10 days before yesterday
            DueDate := CalcDate(StrSubstNo('<-%1D>', Format(1 + Random(10))), WorkDate());
            CreateInvoiceWithDueDate(DueDate);
        end;
    end;

    local procedure AddSalesLineItem(Item: Record Item; Quantity: Integer);
    var
        SalesLine: Record "Sales Line";
    begin
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, Item."No.", Quantity);
    end;

    local procedure AddSalesLineRes(Resource: Record Resource; Quantity: Integer);
    var
        SalesLine: Record "Sales Line";
    begin
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Resource, Resource."No.", Quantity);
    end;

    local procedure PostInvoice(): Decimal;
    var
        CustLedgEntry: Record "Cust. Ledger Entry";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        PostedSalesInvoiceCode: Code[20];
    begin
        PostedSalesInvoiceCode := LibrarySales.PostSalesDocument(SalesHeader, true, true);
        SalesInvoiceHeader.Get(PostedSalesInvoiceCode);
        CustLedgEntry.get(SalesInvoiceHeader."Cust. Ledger Entry No.");
        CustLedgEntry.CalcFields("Amount (LCY)");
        exit(CustLedgEntry."Amount (LCY)");
    end;

    local procedure CreateResource(var Resource: Record Resource);
    var
        VATPostingSetup: Record "VAT Posting Setup";
        LibraryERM: Codeunit "Library - ERM";
    begin
        LibraryERM.FindVATPostingSetup(VATPostingSetup, VATPostingSetup."VAT Calculation Type"::"Normal VAT");
        LibraryResource.CreateResource(Resource, VATPostingSetup."VAT Bus. Posting Group");
    end;

    local procedure FillInCompanyForCurrentUser();
    var
        UserPersonalization: Record "User Personalization";
    begin
        UserPersonalization.Get(UserSecurityId());
        UserPersonalization.Company := CopyStr(CompanyName(), 1, MaxStrLen(UserPersonalization.Company));
        UserPersonalization.Modify(true);
    end;

    local procedure GetVisibility(HeadlineName: Option): Boolean
    var
        EssentialBusinessHeadlineLocal: Record "Ess. Business Headline Per Usr";
    begin
        if EssentialBusinessHeadlineLocal.Get(HeadlineName, UserSecurityId()) then
            exit(EssentialBusinessHeadlineLocal."Headline Visible");
    end;

    local procedure GetHeadlineText(HeadlineName: Option): Text[250]
    var
        EssentialBusinessHeadlineLocal: Record "Ess. Business Headline Per Usr";
    begin
        if EssentialBusinessHeadlineLocal.Get(HeadlineName, UserSecurityId()) then
            exit(EssentialBusinessHeadlineLocal."Headline Text");
    end;

    local procedure ComputeVATReturnHeadlines()
    begin
        EssentialBusHeadlineMgt.HandleOverdueVATReturn();
        EssentialBusHeadlineMgt.HandleOpenVATReturn();
    end;

    local procedure UpdateVATReportSetup(NewPeriodReminderTime: Integer)
    var
        VATReportSetup: Record "VAT Report Setup";
        DateFormaula: DateFormula;
    begin
        with VATReportSetup do begin
            Get();
            Evaluate(DateFormaula, StrSubstNo('<%1D>', NewPeriodReminderTime));
            "Period Reminder Calculation" := DateFormaula;
            Modify();
        end;
    end;

    local procedure VerifyOverdueVATReturnPeriodHeadlineIsVisible(DueDate: Date; DaysCount: Integer)
    var
        HeadlineMgt: Codeunit Headlines;
    begin
        Assert.IsTrue(GetVisibility(EssentialBusinessHeadline."Headline Name"::OverdueVATReturn), 'OverdueVATReturn headline should be visible');
        Assert.AreEqual(
            StrSubstNo(
                '<qualifier>%1</qualifier><payload>%2</payload>',
                VATReturnQualifierLbl, StrSubstNo(OverdueVATReturnPeriodTxt, HeadlineMgt.Emphasize(Format(DueDate)), DaysCount)),
            GetHeadlineText(EssentialBusinessHeadline."Headline Name"::OverdueVATReturn),
            'Expected message to contain "VAT return is overdue since"');

        EssentialBusinessHeadline.DeleteAll();
        RCHeadlinesUserData.DeleteAll();
        HeadlineRcBusinessManagerPage.OpenView();
        Assert.IsTrue(HeadlineRcBusinessManagerPage.OverdueVATReturnText.Visible(), 'OverdueVATReturn headline should be visible');
        HeadlineRcBusinessManagerPage.Close();
    end;

    local procedure VerifyOverdueVATReturnPeriodHeadlineIsNotVisible()
    begin
        Assert.IsFalse(GetVisibility(EssentialBusinessHeadline."Headline Name"::OverdueVATReturn), 'OverdueVATReturn headline should not be visible');
        EssentialBusinessHeadline.DeleteAll();
        RCHeadlinesUserData.DeleteAll();
        HeadlineRcBusinessManagerPage.OpenView();
        Assert.IsFalse(HeadlineRcBusinessManagerPage.OverdueVATReturnText.Visible(), 'OverdueVATReturn headline should not be visible');
        HeadlineRcBusinessManagerPage.Close();
    end;

    local procedure VerifyUpcomingVATReturnPeriodHeadlineIsVisible(DueDate: Date; DaysCount: Integer)
    var
        HeadlineMgt: Codeunit Headlines;
    begin
        Assert.IsTrue(GetVisibility(EssentialBusinessHeadline."Headline Name"::OpenVATReturn), 'OpenVATReturn headline should be visible');
        Assert.AreEqual(
            StrSubstNo(
                '<qualifier>%1</qualifier><payload>%2</payload>',
                VATReturnQualifierLbl, StrSubstNo(OpenVATReturnPeriodTxt, HeadlineMgt.Emphasize(Format(DueDate)), DaysCount)),
            GetHeadlineText(EssentialBusinessHeadline."Headline Name"::OpenVATReturn),
            'Expected message to contain "Your VAT return is due"');

        EssentialBusinessHeadline.DeleteAll();
        RCHeadlinesUserData.DeleteAll();
        HeadlineRcBusinessManagerPage.OpenView();
        Assert.IsTrue(HeadlineRcBusinessManagerPage.OpenVATReturnText.Visible(), 'OpenVATReturnText headline should be visible');
        HeadlineRcBusinessManagerPage.Close();
    end;

    local procedure VerifyUpcomingVATReturnPeriodHeadlineIsNotVisible()
    begin
        Assert.IsFalse(GetVisibility(EssentialBusinessHeadline."Headline Name"::OpenVATReturn), 'OpenVATReturn headline should not be visible');
        EssentialBusinessHeadline.DeleteAll();
        RCHeadlinesUserData.DeleteAll();
        HeadlineRcBusinessManagerPage.OpenView();
        Assert.IsFalse(HeadlineRcBusinessManagerPage.OpenVATReturnText.Visible(), 'OpenVATReturnText headline should not be visible');
        HeadlineRcBusinessManagerPage.Close();
    end;

    local procedure VerifyVATReturnPeriodHeadlinesAreNotVisible()
    begin
        ComputeVATReturnHeadlines();
        VerifyOverdueVATReturnPeriodHeadlineIsNotVisible();
        VerifyUpcomingVATReturnPeriodHeadlineIsNotVisible();
    end;
}
