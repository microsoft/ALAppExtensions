// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 139600 "Test Essential Bus. Headlines"
{
    Subtype = Test;
    TestPermissions = Disabled;
    EventSubscriberInstance = Manual;

    var
        EssentialBusinessHeadline: Record "Ess. Business Headline Per Usr";
        SalesHeader: Record "Sales Header";
        Assert: Codeunit Assert;
        TypeHelper: Codeunit "Type Helper";
        EssentialBusHeadlineMgt: Codeunit "Essential Bus. Headline Mgt.";
        LibrarySales: Codeunit "Library - Sales";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryResource: Codeunit "Library - Resource";
        TestEssentialBusHeadlines: Codeunit "Test Essential Bus. Headlines";
        HeadlineRcBusinessManagerPage: TestPage "Headline RC Business Manager";
        HeadlineRcRelationshipMgtPage: TestPage "Headline RC Relationship Mgt.";
        HeadlineRcOrderProcessorPage: TestPage "Headline RC Order Processor";
        HeadlineRcAccountantPage: TestPage "Headline RC Accountant";
        IsInitialized: Boolean;

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
        HeadlineRcBusinessManagerPage.OpenView();
        Assert.IsFalse(HeadlineRcBusinessManagerPage.LargestOrderText.Visible(), 'Expected largest order headline not to be visible in the page');
        HeadlineRcBusinessManagerPage.Close();
        EssentialBusinessHeadline.DeleteAll();
        HeadlineRcOrderProcessorPage.OpenView();
        Assert.IsFalse(HeadlineRcOrderProcessorPage.LargestOrderText.Visible(), 'Expected largest order headline not to be visible in the page');
        HeadlineRcOrderProcessorPage.Close();
        EssentialBusinessHeadline.DeleteAll();
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
        HeadlineRcBusinessManagerPage.OpenView();
        Assert.IsTrue(HeadlineRcBusinessManagerPage.LargestOrderText.Visible(), 'Expected largest order headline to be visible in the page');
        HeadlineRcBusinessManagerPage.Close();
        EssentialBusinessHeadline.DeleteAll();
        HeadlineRcOrderProcessorPage.OpenView();
        Assert.IsTrue(HeadlineRcOrderProcessorPage.LargestOrderText.Visible(), 'Expected largest order headline to be visible in the page');
        HeadlineRcOrderProcessorPage.Close();
        EssentialBusinessHeadline.DeleteAll();
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
        HeadlineRcBusinessManagerPage.OpenView();
        Assert.IsFalse(HeadlineRcBusinessManagerPage.LargestSaleText.Visible(), 'Expected largest sale headline not to be visible in the page');
        HeadlineRcBusinessManagerPage.Close();
        EssentialBusinessHeadline.DeleteAll();
        HeadlineRcOrderProcessorPage.OpenView();
        Assert.IsFalse(HeadlineRcOrderProcessorPage.LargestSaleText.Visible(), 'Expected largest sale headline not to be visible in the page');
        HeadlineRcOrderProcessorPage.Close();
        EssentialBusinessHeadline.DeleteAll();
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
        HeadlineRcBusinessManagerPage.OpenView();
        Assert.IsTrue(HeadlineRcBusinessManagerPage.LargestSaleText.Visible(), 'Expected largest sale headline to be visible in the page');
        HeadlineRcBusinessManagerPage.Close();
        EssentialBusinessHeadline.DeleteAll();
        HeadlineRcOrderProcessorPage.OpenView();
        Assert.IsTrue(HeadlineRcOrderProcessorPage.LargestSaleText.Visible(), 'Expected largest sale headline to be visible in the page');
        HeadlineRcOrderProcessorPage.Close();
        EssentialBusinessHeadline.DeleteAll();
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
        HeadlineRcBusinessManagerPage.OpenView();
        Assert.IsFalse(HeadlineRcBusinessManagerPage.SalesIncreaseText.Visible(), 'Expected sales increase not to be visible in the page');
        HeadlineRcBusinessManagerPage.Close();
        EssentialBusinessHeadline.DeleteAll();
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
        HeadlineRcBusinessManagerPage.OpenView();
        Assert.IsTrue(HeadlineRcBusinessManagerPage.SalesIncreaseText.Visible(), 'Expected sales increase to be visible in the page');
        HeadlineRcBusinessManagerPage.Close();
        EssentialBusinessHeadline.DeleteAll();
        HeadlineRcAccountantPage.OpenView();
        Assert.IsTrue(HeadlineRcAccountantPage.SalesIncreaseText.Visible(), 'Expected sales increase headline to be visible in the page');
        HeadlineRcAccountantPage.Close();
    end;

    [Test]
    procedure TestInvalidateHeadlines()
    var
        MySettings: TestPage "My Settings";
    begin
        Initialize();

        // [WHEN] We don't change the date
        EssentialBusinessHeadline.GetOrCreateHeadline(EssentialBusinessHeadline."Headline Name"::BusiestResource);
        // [THEN] Nothing happens
        Assert.IsFalse(EssentialBusinessHeadline.IsEmpty(), 'expected the headlines not to be deleted when not changing workdate nor language');

        // [WHEN] We change the date to the same one
        MySettings.OpenEdit();
        MySettings.NewWorkdate.Value(Format(WorkDate()));
        MySettings.OK().Invoke();
        // [THEN] Nothing happens
        Assert.IsFalse(EssentialBusinessHeadline.IsEmpty(), 'expected the headlines not to be deleted when changing workdate to the same workdate');

        // [WHEN] We change the date
        MySettings.OpenEdit();
        MySettings.NewWorkdate.Value(Format(0D));
        MySettings.OK().Invoke();
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
        HeadlineRcRelationshipMgtPage.OpenView();
        Assert.IsTrue(HeadlineRcRelationshipMgtPage.TopCustomerText.Visible(), 'Expected best customer headline to be visible in the page');
        HeadlineRcRelationshipMgtPage.Close();

        Assert.AreEqual('Your top customer was <emphasize>012345678901234567890123456789</emphasize>, bought for <emphasize>234,567 kr</emphasize>',
            EssentialBusHeadlineMgt.GetTopCustomerPayload('012345678901234567890123456789', '234,567 kr'), 'Invalid top customer text in normal case');

        Assert.AreEqual('Your top customer was <emphasize>0123456789012345678901234...</emphasize>, bought for <emphasize>1,234,567 kr</emphasize>',
            EssentialBusHeadlineMgt.GetTopCustomerPayload('01234567890123456789012345678', '1,234,567 kr'), 'Invalid top customer text in truncate case');
    end;

    procedure Initialize()
    var
        Item: Record Item;
        SalesInvoiceHeader: Record "Sales Invoice Header";
        Resource: Record Resource;
        SalesLine: Record "Sales Line";
        CustLedgerEntry: Record "Cust. Ledger Entry";
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
        if IsInitialized then
            exit;

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
        EssentialBusinessHeadline: Record "Ess. Business Headline Per Usr";
    begin
        if EssentialBusinessHeadline.Get(HeadlineName, UserSecurityId()) then
            exit(EssentialBusinessHeadline."Headline Visible");
    end;

    local procedure GetHeadlineText(HeadlineName: Option): Text[250]
    var
        EssentialBusinessHeadline: Record "Ess. Business Headline Per Usr";
    begin
        if EssentialBusinessHeadline.Get(HeadlineName, UserSecurityId()) then
            exit(EssentialBusinessHeadline."Headline Text");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Headline Management", 'OnBeforeScheduleTask', '', true, true)]
    local procedure OnBeforeScheduleTask(CodeunitId: Integer)
    begin
        Codeunit.Run(CodeunitId);
    end;

}