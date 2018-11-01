// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 1437 "Essential Bus. Headline Mgt."
{
    var
        HeadlineManagement: Codeunit "Headline Management";
        QualifierWeekTxt: Label 'Insight from last week', MaxLength = 50;
        QualifierMonthTxt: Label 'Insight from last month', MaxLength = 50;
        Qualifier3MonthsTxt: Label 'Insight from the last three months', MaxLength = 50;

        MostPopularItemPayloadTxt: Label 'The best-selling item was %1 with %2 units sold', Comment = '%1 is the item name, %2 is the quantity sold', MaxLength = 50; // support 20 chars for item and number up to 9 chars: '1,234,567'
        BusiestResourcePayloadTxt: Label '%1 was busy, with %2 units booked', Comment = '%1 is the resource name, %2 is the quantity sold', MaxLength = 50;  // support 20 chars for resource and number up to 9 chars: '1,234,567'
        LargestOrderPayloadTxt: Label 'The biggest sales order was for %1', Comment = '%1 is the order amount with currency symbol/name.', MaxLength = 65; // support currencies up to 12 chars: '1,234,567 kr'
        LargestSalePayloadTxt: Label 'The largest posted sales invoice was for %1', Comment = ' %1 is the sales amount with currency symbol/name.', MaxLength = 65; // support currencies up to 12 chars: '1,234,567 kr'
        SalesIncreaseComparedToLastYearPayloadTxt: Label 'You closed %1 more deals than in the same period last year', Comment = '%1 is the difference of sales (positive) between this period and the same period the previous year.', MaxLength = 68; // support numbers up to 9 chars: '1,234,567'
        TopCustomerPayloadTxt: Label 'Your top customer was %1, bought for %2', Comment = '%1 is the Customer name, %2 is the sales amount with currency symbol/name.', MaxLength = 47; // support 20 chars for customer and currencies up to 12 chars: '1,234,567 kr'


    local procedure NeedToUpdateHeadline(LastComputeDate: DateTime; PeriodBetween2ComputationsInSeconds: Integer; LastComputeWorkdate: Date): Boolean
    begin
        if (LastComputeDate = 0DT) then
            exit(true);

        if CurrentDateTime() - LastComputeDate >= PeriodBetween2ComputationsInSeconds * 1000 then
            exit(true);

        if LastComputeWorkdate <> WorkDate() then
            exit(true);
    end;

    local procedure ChooseQualifier(QualifierWeek: Text; QualifierMonth: Text; Qualifier3Months: Text; DaysSearch: Integer): Text
    begin
        case DaysSearch of
            7:
                exit(QualifierWeek);
            30:
                exit(QualifierMonth);
            90:
                exit(Qualifier3Months);
        end;
    end;

    procedure HandleMostPopularItemHeadline()
    var
        EssentialBusinessHeadline: Record "Ess. Business Headline Per Usr";
        Item: Record Item;
        TimePeriods: List of [Integer];
        TimePeriodDays: Integer;
    begin
        EssentialBusinessHeadline.GetOrCreateHeadline(EssentialBusinessHeadline."Headline Name"::MostPopularItem);
        if not NeedToUpdateHeadline(EssentialBusinessHeadline."Headline Computation Date", 10 * 60, EssentialBusinessHeadline."Headline Computation WorkDate") then
            exit;

        EssentialBusinessHeadline.Validate("Headline Visible", false);

        // we need at least 3 items for this headline to be valid
        if Item.CountApprox() < 3 then
            exit;

        TimePeriods.Add(7);
        TimePeriods.Add(30);
        TimePeriods.Add(90);

        foreach TimePeriodDays in TimePeriods do
            if TryHandleMostPopularItem(EssentialBusinessHeadline, TimePeriodDays) then
                break;

        EssentialBusinessHeadline.Modify();
    end;

    local procedure TryHandleMostPopularItem(var EssentialBusinessHeadline: Record "Ess. Business Headline Per Usr"; DaysSearch: Integer): Boolean
    var
        Item: Record Item;
        SalesLine: Record "Sales Line";
        HeadlineDetails: Record "Headline Details Per User";
        BestSoldItemQuery: Query "Best Sold Item Headline";
        BestQty: Decimal;
    begin
        BestSoldItemQuery.SetFilter(PostDate, '>=%1&<=%2', CalcDate(StrSubstNo('<-%1D>', DaysSearch), WorkDate()), WorkDate());
        BestSoldItemQuery.SetRange(ProductType, SalesLine.Type::Item);
        if not BestSoldItemQuery.Open() then
            exit;

        if not BestSoldItemQuery.Read() then
            exit;

        BestQty := BestSoldItemQuery.SumQuantity;
        Item.Get(BestSoldItemQuery.ProductNo);

        if not HeadlineManagement.GetHeadlineText(
                ChooseQualifier(QualifierWeekTxt, QualifierMonthTxt, Qualifier3MonthsTxt, DaysSearch),
                GetBestItemPayload(Item.Description, Format(BestQty)),
                EssentialBusinessHeadline."Headline Text")
        then
            exit;

        HeadlineDetails.SetRange(Type, HeadlineDetails.Type::Item);
        HeadlineDetails.SetRange("User Id", UserSecurityId());
        HeadlineDetails.DeleteAll();

        InsertHeadlineDetails(BestSoldItemQuery.ProductNo, HeadlineDetails.Type::Item, Item.Description, Item."Base Unit of Measure", BestSoldItemQuery.SumQuantity, 0);

        // if there is only one item sold in the time period, do not set to visible
        if BestSoldItemQuery.Read() then
            if BestSoldItemQuery.SumQuantity < BestQty then begin // if there is another resource that is also the best, do not set to visible
                EssentialBusinessHeadline.Validate("Headline Visible", true);
                EssentialBusinessHeadline.Validate("Headline Computation Date", CurrentDateTime());
                EssentialBusinessHeadline.Validate("Headline Computation WorkDate", WorkDate());
                EssentialBusinessHeadline.Validate("Headline Computation Period", DaysSearch);

                repeat
                    Item.get(BestSoldItemQuery.ProductNo);
                    InsertHeadlineDetails(BestSoldItemQuery.ProductNo, HeadlineDetails.Type::Item, Item.Description, Item."Base Unit of Measure", BestSoldItemQuery.SumQuantity, 0);
                until not BestSoldItemQuery.Read();

                exit(true);
            end;
    end;

    procedure GetBestItemPayload(ItemName: Text[50]; TextQuantity: Text): Text
    begin
        exit(StrSubstNo(MostPopularItemPayloadTxt,
            HeadlineManagement.Emphasize(
                HeadlineManagement.Truncate(
                    ItemName,
                    HeadlineManagement.GetMaxPayloadLength() - StrLen(MostPopularItemPayloadTxt) + 4 - StrLen(TextQuantity))),
            HeadlineManagement.Emphasize(TextQuantity)));
    end;

    procedure OnDrillDownMostPopularItem()
    var
        EssentialBusinessHeadlines: Record "Ess. Business Headline Per Usr";
        SalesLine: Record "Sales Line";
        HeadlineDetails: Page "Headline Details";
    begin
        EssentialBusinessHeadlines.GetOrCreateHeadline(EssentialBusinessHeadlines."Headline Name"::MostPopularItem);
        HeadlineDetails.InitProduct(SalesLine.Type::Item);
        HeadlineDetails.Run();
    end;

    procedure HandleBusiestResourceHeadline()
    var
        EssentialBusinessHeadline: Record "Ess. Business Headline Per Usr";
        Resource: Record Resource;
        TimePeriods: List of [Integer];
        TimePeriodDays: Integer;
    begin
        EssentialBusinessHeadline.GetOrCreateHeadline(EssentialBusinessHeadline."Headline Name"::BusiestResource);
        if not NeedToUpdateHeadline(EssentialBusinessHeadline."Headline Computation Date", 10 * 60, EssentialBusinessHeadline."Headline Computation WorkDate") then
            exit;

        EssentialBusinessHeadline.Validate("Headline Visible", false);

        // we need at least 3 items for this headline to be valid
        if Resource.CountApprox() < 3 then
            exit;

        TimePeriods.Add(7);
        TimePeriods.Add(30);
        TimePeriods.Add(90);

        foreach TimePeriodDays in TimePeriods do
            if TryHandleBusiestResource(EssentialBusinessHeadline, TimePeriodDays) then
                break;
        EssentialBusinessHeadline.Modify();
    end;

    local procedure TryHandleBusiestResource(var EssentialBusinessHeadline: Record "Ess. Business Headline Per Usr"; DaysSearch: Integer): Boolean
    var
        Resource: Record Resource;
        SalesLine: Record "Sales Line";
        HeadlineDetails: Record "Headline Details Per User";
        BusiestResource: Query "Best Sold Item Headline";
        BestQty: Decimal;
    begin
        BusiestResource.SetFilter(PostDate, '>=%1&<=%2', CalcDate(StrSubstNo('<-%1D>', DaysSearch), WorkDate()), WorkDate());
        BusiestResource.SetRange(ProductType, SalesLine.Type::Resource);
        if not BusiestResource.Open() then
            exit;

        if not BusiestResource.Read() then
            exit;
        BestQty := BusiestResource.SumQuantity;
        Resource.Get(BusiestResource.ProductNo);

        if not HeadlineManagement.GetHeadlineText(
                ChooseQualifier(QualifierWeekTxt, QualifierMonthTxt, Qualifier3MonthsTxt, DaysSearch),
                GetBusiestResoucePayload(Resource.Name, Format(BestQty)),
                EssentialBusinessHeadline."Headline Text")
        then
            exit;

        HeadlineDetails.SetRange(Type, HeadlineDetails.Type::Resource);
        HeadlineDetails.SetRange("User Id", UserSecurityId());
        HeadlineDetails.DeleteAll();

        InsertHeadlineDetails(BusiestResource.ProductNo, HeadlineDetails.Type::Resource, Resource.Name, Resource."Base Unit of Measure", BusiestResource.SumQuantity, 0);

        // if there is only one active resource in the time period, do not set to visible
        if BusiestResource.Read() then
            if BusiestResource.SumQuantity < BestQty then begin // if there is another resource that is also the best, do not set to visible
                EssentialBusinessHeadline.Validate("Headline Visible", true);
                EssentialBusinessHeadline.Validate("Headline Computation Date", CurrentDateTime());
                EssentialBusinessHeadline.Validate("Headline Computation WorkDate", WorkDate());
                EssentialBusinessHeadline.Validate("Headline Computation Period", DaysSearch);

                repeat
                    Resource.Get(BusiestResource.ProductNo);
                    InsertHeadlineDetails(BusiestResource.ProductNo, HeadlineDetails.Type::Resource, Resource.Name, Resource."Base Unit of Measure", BusiestResource.SumQuantity, 0);
                until not BusiestResource.Read();

                exit(true);
            end;
    end;

    local procedure InsertHeadlineDetails(No: Code[20]; Type: Option; Name: Text[50]; UnitOfMeasure: Code[10]; Quantity: Decimal; AmountLcy: Decimal)
    var
        HeadlineDetails: Record "Headline Details Per User";
    begin
        HeadlineDetails.Init();
        HeadlineDetails.Validate("No.", No);
        HeadlineDetails.Validate(Type, Type);
        HeadlineDetails.Validate(Name, Name);
        HeadlineDetails."Unit of Measure" := UnitOfMeasure;
        HeadlineDetails.Validate(Quantity, Quantity);
        HeadlineDetails.Validate("Amount (LCY)", AmountLcy);
        HeadlineDetails.Validate("User Id", UserSecurityId());
        HeadlineDetails.Insert();
    end;

    procedure GetBusiestResoucePayload(ResourceName: Text[50]; TextQuantity: Text): Text
    begin
        exit(StrSubstNo(BusiestResourcePayloadTxt,
            HeadlineManagement.Emphasize(
                HeadlineManagement.Truncate(
                    ResourceName,
                    HeadlineManagement.GetMaxPayloadLength() - StrLen(BusiestResourcePayloadTxt) + 4 - StrLen(TextQuantity))),
            HeadlineManagement.Emphasize(TextQuantity)));
    end;

    procedure OnDrillDownBusiestResource()
    var
        EssentialBusinessHeadlines: Record "Ess. Business Headline Per Usr";
        SalesLine: Record "Sales Line";
        HeadlineDetails: Page "Headline Details";
    begin
        EssentialBusinessHeadlines.GetOrCreateHeadline(EssentialBusinessHeadlines."Headline Name"::BusiestResource);
        HeadlineDetails.InitProduct(SalesLine.Type::Resource);
        HeadlineDetails.Run();
    end;

    procedure HandleLargestOrderHeadline()
    var
        EssentialBusinessHeadline: Record "Ess. Business Headline Per Usr";
        TimePeriods: List of [Integer];
        TimePeriodDays: Integer;
    begin
        EssentialBusinessHeadline.GetOrCreateHeadline(EssentialBusinessHeadline."Headline Name"::LargestOrder);
        if not NeedToUpdateHeadline(EssentialBusinessHeadline."Headline Computation Date", 10 * 60, EssentialBusinessHeadline."Headline Computation WorkDate") then
            exit;

        EssentialBusinessHeadline.Validate("Headline Visible", false);

        TimePeriods.Add(7);
        TimePeriods.Add(30);
        TimePeriods.Add(90);

        foreach TimePeriodDays in TimePeriods do
            if TryHandleLargestOrder(EssentialBusinessHeadline, TimePeriodDays) then
                break;

        EssentialBusinessHeadline.Modify();
    end;

    local procedure TryHandleLargestOrder(var EssentialBusinessHeadline: Record "Ess. Business Headline Per Usr"; DaysSearch: Integer): Boolean
    var
        SalesHeader: Record "Sales Header";
        CurrentKeyOk: Boolean;
    begin
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.SetFilter("Posting Date", '>=%1&<=%2', CalcDate(StrSubstNo('<-%1D>', DaysSearch), WorkDate()), WorkDate());
        CurrentKeyOk := SalesHeader.SetCurrentKey(Amount);
        SalesHeader.SetAscending(Amount, false);

        // we need at least 5 orders for this headline to be valid
        if (SalesHeader.Count() > 5) and SalesHeader.FindFirst() then begin
            if not HeadlineManagement.GetHeadlineText(
                ChooseQualifier(QualifierWeekTxt, QualifierMonthTxt, Qualifier3MonthsTxt, DaysSearch),
                StrSubstNo(LargestOrderPayloadTxt,
                   HeadlineManagement.Emphasize(FormatCurrency(SalesHeader.Amount, SalesHeader."Currency Code"))),
                EssentialBusinessHeadline."Headline Text")
            then
                exit;

            EssentialBusinessHeadline.Validate("Headline Visible", true);
            EssentialBusinessHeadline.Validate("Headline Computation Date", CurrentDateTime());
            EssentialBusinessHeadline.Validate("Headline Computation WorkDate", WorkDate());
            EssentialBusinessHeadline.Validate("Headline Computation Period", DaysSearch);
            exit(true);
        end else
            EssentialBusinessHeadline.Validate("Headline Visible", false);
    end;

    procedure OnDrillDownLargestOrder()
    var
        SalesHeader: Record "Sales Header";
        EssentialBusinessHeadline: Record "Ess. Business Headline Per Usr";
    begin
        EssentialBusinessHeadline.GetOrCreateHeadline(EssentialBusinessHeadline."Headline Name"::LargestOrder);
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.SetFilter("Posting Date", '>=%1&<=%2',
            CalcDate(StrSubstNo('<-%1D>', EssentialBusinessHeadline."Headline Computation Period"), WorkDate()),
            WorkDate());

        SalesHeader.SetCurrentKey(Amount);
        SalesHeader.Ascending(false);

        Page.Run(Page::"Sales Order List", SalesHeader);
    end;

    procedure HandleLargestSaleHeadline()
    var
        EssentialBusinessHeadline: Record "Ess. Business Headline Per Usr";
        TimePeriods: List of [Integer];
        TimePeriodDays: Integer;
    begin
        EssentialBusinessHeadline.GetOrCreateHeadline(EssentialBusinessHeadline."Headline Name"::LargestSale);
        if not NeedToUpdateHeadline(EssentialBusinessHeadline."Headline Computation Date", 10 * 60, EssentialBusinessHeadline."Headline Computation WorkDate") then
            exit;

        EssentialBusinessHeadline.Validate("Headline Visible", false);

        TimePeriods.Add(7);
        TimePeriods.Add(30);
        TimePeriods.Add(90);

        foreach TimePeriodDays in TimePeriods do
            if TryHandleLargestSale(EssentialBusinessHeadline, TimePeriodDays) then
                break;

        EssentialBusinessHeadline.Modify();
    end;

    local procedure TryHandleLargestSale(var EssentialBusinessHeadline: Record "Ess. Business Headline Per Usr"; DaysSearch: Integer): Boolean
    var
        CustomerLedgerEntry: Record "Cust. Ledger Entry";
        CurrentKeyOk: Boolean;
    begin
        CustomerLedgerEntry.SetFilter("Posting Date", '>=%1&<=%2', CalcDate(StrSubstNo('<-%1D>', DaysSearch), WorkDate()), WorkDate());
        CustomerLedgerEntry.SetRange("Document Type", CustomerLedgerEntry."Document Type"::Invoice);
        CustomerLedgerEntry.SetRange(Reversed, false);
        CurrentKeyOk := CustomerLedgerEntry.SetCurrentKey("Amount (LCY)");
        CustomerLedgerEntry.SetAscending("Amount (LCY)", false);

        // we need at least 5 sales for this headline to be valid
        if (CustomerLedgerEntry.Count() > 5) and CustomerLedgerEntry.FindFirst() then begin
            CustomerLedgerEntry.CalcFields(Amount);

            if not HeadlineManagement.GetHeadlineText(
                ChooseQualifier(QualifierWeekTxt, QualifierMonthTxt, Qualifier3MonthsTxt, DaysSearch),
                StrSubstNo(LargestSalePayloadTxt,
                  HeadlineManagement.Emphasize(FormatCurrency(CustomerLedgerEntry.Amount, CustomerLedgerEntry."Currency Code"))),
                EssentialBusinessHeadline."Headline Text")
            then
                exit;

            EssentialBusinessHeadline.Validate("Headline Visible", true);
            EssentialBusinessHeadline.Validate("Headline Computation Date", CurrentDateTime());
            EssentialBusinessHeadline.Validate("Headline Computation WorkDate", WorkDate());
            EssentialBusinessHeadline.Validate("Headline Computation Period", DaysSearch);
            exit(true);
        end else
            EssentialBusinessHeadline.Validate("Headline Visible", false);
    end;

    procedure OnDrillDownLargestSale()
    var
        CustomerLedgerEntry: Record "Cust. Ledger Entry";
        EssentialBusinessHeadline: Record "Ess. Business Headline Per Usr";
    begin
        EssentialBusinessHeadline.GetOrCreateHeadline(EssentialBusinessHeadline."Headline Name"::LargestSale);
        CustomerLedgerEntry.SetFilter("Posting Date", '>=%1&<=%2',
            CalcDate(StrSubstNo('<-%1D>', EssentialBusinessHeadline."Headline Computation Period"), WorkDate()),
            WorkDate());
        CustomerLedgerEntry.SetRange("Document Type", CustomerLedgerEntry."Document Type"::Invoice);
        CustomerLedgerEntry.SetRange(Reversed, false);

        CustomerLedgerEntry.SetCurrentKey("Amount (LCY)");
        CustomerLedgerEntry.SetAscending("Amount (LCY)", false);
        CustomerLedgerEntry.Ascending(false);

        Page.Run(Page::"Customer Ledger Entries", CustomerLedgerEntry);
    end;

    procedure HandleSalesIncreaseHeadline()
    var
        EssentialBusinessHeadline: Record "Ess. Business Headline Per Usr";
        TimePeriods: List of [Integer];
        TimePeriodDays: Integer;
    begin
        EssentialBusinessHeadline.GetOrCreateHeadline(EssentialBusinessHeadline."Headline Name"::SalesIncrease);
        if not NeedToUpdateHeadline(EssentialBusinessHeadline."Headline Computation Date", 10 * 60, EssentialBusinessHeadline."Headline Computation WorkDate") then
            exit;

        EssentialBusinessHeadline.Validate("Headline Visible", false);

        TimePeriods.Add(30);
        TimePeriods.Add(90);

        foreach TimePeriodDays in TimePeriods do
            if TryHandleSalesIncreaseHeadline(EssentialBusinessHeadline, TimePeriodDays) then
                break;

        EssentialBusinessHeadline.Modify();
    end;

    local procedure TryHandleSalesIncreaseHeadline(var EssentialBusinessHeadline: Record "Ess. Business Headline Per Usr"; DaysSearch: Integer): Boolean
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesThisMonth: Integer;
        SalesThisMonthLastYear: Integer;
    begin
        SalesInvoiceHeader.SetRange(Cancelled, false);
        SalesInvoiceHeader.SetFilter(Amount, '>%1', 0);
        SalesInvoiceHeader.SetFilter("Posting Date", '>=%1&<=%2', CalcDate(StrSubstNo('<-%1D>', DaysSearch), WorkDate()), WorkDate());
        SalesThisMonth := SalesInvoiceHeader.Count();

        if (SalesThisMonth = 0) then begin
            // we need sales this month for this headline to be valid
            EssentialBusinessHeadline.Validate("Headline Visible", false);
            exit;
        end;

        SalesInvoiceHeader.SetRange(Cancelled, false);
        SalesInvoiceHeader.SetFilter(Amount, '>%1', 0);
        SalesInvoiceHeader.SetFilter("Posting Date", '>=%1&<=%2',
            CalcDate(StrSubstNo('<-%1D>', 365 + DaysSearch), WorkDate()),
            CalcDate(StrSubstNo('<-%1D>', 365), WorkDate()));
        SalesThisMonthLastYear := SalesInvoiceHeader.Count();

        if (SalesThisMonthLastYear = 0) or (SalesThisMonth <= SalesThisMonthLastYear) then begin
            // we need sales this month on the previous year, and the sales to be better the current year for this headline to be valid
            EssentialBusinessHeadline.Validate("Headline Visible", false);
            exit;
        end;

        if not HeadlineManagement.GetHeadlineText(
            ChooseQualifier(QualifierWeekTxt, QualifierMonthTxt, Qualifier3MonthsTxt, DaysSearch),
            StrSubstNo(SalesIncreaseComparedToLastYearPayloadTxt,
                HeadlineManagement.Emphasize(Format(SalesThisMonth - SalesThisMonthLastYear))),
            EssentialBusinessHeadline."Headline Text")
        then
            exit;

        EssentialBusinessHeadline.Validate("Headline Visible", true);
        EssentialBusinessHeadline.Validate("Headline Computation Date", CurrentDateTime());
        EssentialBusinessHeadline.Validate("Headline Computation WorkDate", WorkDate());
        EssentialBusinessHeadline.Validate("Headline Computation Period", DaysSearch);
        exit(true);
    end;

    procedure OnDrillDownSalesIncrease()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        EssentialBusinessHeadline: Record "Ess. Business Headline Per Usr";
        DaysSearch: Integer;
    begin
        EssentialBusinessHeadline.GetOrCreateHeadline(EssentialBusinessHeadline."Headline Name"::SalesIncrease);
        DaysSearch := EssentialBusinessHeadline."Headline Computation Period";

        SalesInvoiceHeader.SetRange(Cancelled, false);
        SalesInvoiceHeader.SetFilter(Amount, '>%1', 0);
        SalesInvoiceHeader.SetFilter("Posting Date", '(>=%1&<=%2)|(>=%3&<=%4)',
            CalcDate(StrSubstNo('<-%1D>', DaysSearch), WorkDate()),
            WorkDate(),
            CalcDate(StrSubstNo('<-%1D>', 365 + DaysSearch), WorkDate()),
            CalcDate(StrSubstNo('<-%1D>', 365), WorkDate()));

        SalesInvoiceHeader.SetCurrentKey("Posting Date");
        SalesInvoiceHeader.Ascending(false);
        Page.Run(Page::"Posted Sales Invoices", SalesInvoiceHeader);
    end;

    procedure HandleTopCustomer()
    var
        EssentialBusinessHeadline: Record "Ess. Business Headline Per Usr";
        TimePeriods: List of [Integer];
        TimePeriodDays: Integer;
    begin
        EssentialBusinessHeadline.GetOrCreateHeadline(EssentialBusinessHeadline."Headline Name"::TopCustomer);
        if not NeedToUpdateHeadline(EssentialBusinessHeadline."Headline Computation Date", 10 * 60, EssentialBusinessHeadline."Headline Computation WorkDate") then
            exit;

        EssentialBusinessHeadline.Validate("Headline Visible", false);

        TimePeriods.Add(7);
        TimePeriods.Add(30);
        TimePeriods.Add(90);

        foreach TimePeriodDays in TimePeriods do
            if TryHandleTopCustomer(EssentialBusinessHeadline, TimePeriodDays) then
                break;

        EssentialBusinessHeadline.Modify();
    end;

    local procedure TryHandleTopCustomer(var EssentialBusinessHeadline: Record "Ess. Business Headline Per Usr"; DaysSearch: Integer): Boolean
    var
        Customer: Record Customer;
        HeadlineDetails: Record "Headline Details Per User";
        TopCustomerHeadlineQuery: Query "Top Customer Headline";
    begin
        TopCustomerHeadlineQuery.SetFilter(PostDate, '>=%1&<=%2',
            CalcDate(StrSubstNo('<-%1D>', DaysSearch), WorkDate()),
            WorkDate());
        if not TopCustomerHeadlineQuery.Open() then
            exit;

        if not TopCustomerHeadlineQuery.Read() then
            exit;

        Customer.Get(TopCustomerHeadlineQuery.CustomerNo);

        if not HeadlineManagement.GetHeadlineText(
            ChooseQualifier(QualifierWeekTxt, QualifierMonthTxt, Qualifier3MonthsTxt, DaysSearch),
            GetTopCustomerPayload(Customer.Name, FormatLocalCurrency(TopCustomerHeadlineQuery.SumAmountLcy)),
            EssentialBusinessHeadline."Headline Text")
        then
            exit;


        HeadlineDetails.SetRange(Type, HeadlineDetails.Type::Customer);
        HeadlineDetails.SetRange("User Id", UserSecurityId());
        HeadlineDetails.DeleteAll();
        InsertHeadlineDetails(TopCustomerHeadlineQuery.No, HeadlineDetails.Type::Customer, TopCustomerHeadlineQuery.CustomerName, '', 0, TopCustomerHeadlineQuery.SumAmountLcy);

        // if there is only one customer last month, do not set to visible
        if TopCustomerHeadlineQuery.Read() then begin
            if TopCustomerHeadlineQuery.SumAmountLcy <= 0 then
                exit;
            EssentialBusinessHeadline.Validate("Headline Visible", true);
            EssentialBusinessHeadline.Validate("Headline Computation Date", CurrentDateTime());
            EssentialBusinessHeadline.Validate("Headline Computation WorkDate", WorkDate());
            EssentialBusinessHeadline.Validate("Headline Computation Period", DaysSearch);

            repeat
                InsertHeadlineDetails(TopCustomerHeadlineQuery.No, HeadlineDetails.Type::Customer, TopCustomerHeadlineQuery.CustomerName, '', 0, TopCustomerHeadlineQuery.SumAmountLcy);
            until not TopCustomerHeadlineQuery.Read();

            exit(true);
        end;
    end;

    procedure GetTopCustomerPayload(CustomerName: Text[50]; TextAmountLcy: Text): Text
    begin
        exit(StrSubstNo(TopCustomerPayloadTxt,
            HeadlineManagement.Emphasize(
                HeadlineManagement.Truncate(
                    CustomerName,
                    HeadlineManagement.GetMaxPayloadLength() - StrLen(TopCustomerPayloadTxt) + 4 - StrLen(TextAmountLcy))),
            HeadlineManagement.Emphasize(TextAmountLcy)));
    end;

    procedure OnDrillDownTopCustomer()
    var
        EssentialBusinessHeadlines: Record "Ess. Business Headline Per Usr";
        HeadlineDetails: Page "Headline Details";
    begin
        EssentialBusinessHeadlines.GetOrCreateHeadline(EssentialBusinessHeadlines."Headline Name"::TopCustomer);
        HeadlineDetails.InitCustomer(EssentialBusinessHeadlines."Headline Computation Period");
        HeadlineDetails.Run();
    end;

    procedure FormatCurrency(AmountToFormat: Decimal; CurrencyCode: Code[10]): Text
    var
        Currency: Record Currency;
        TypeHelper: Codeunit "Type Helper";
        CurrencyFormat: Text;
    begin
        if CurrencyCode = '' then
            exit(FormatLocalCurrency(AmountToFormat));

        if Currency.get(CurrencyCode) and (Currency.Symbol <> '') then
            CurrencyFormat := TypeHelper.GetAmountFormatWithUserLocale(Currency.Symbol)
        else
            CurrencyFormat := '<Precision,0:0><Standard Format,0> ' + CurrencyCode;

        exit(Format(AmountToFormat, 0, CurrencyFormat));
    end;

    procedure FormatLocalCurrency(AmountToFormat: Decimal): Text
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        TypeHelper: Codeunit "Type Helper";
        CurrencyFormat: Text;
    begin
        GeneralLedgerSetup.Get();

        if GeneralLedgerSetup.Get() and (GeneralLedgerSetup."Local Currency Symbol" <> '') then
            CurrencyFormat := TypeHelper.GetAmountFormatWithUserLocale(GeneralLedgerSetup."Local Currency Symbol")
        else
            CurrencyFormat := '<Precision,0:0><Standard Format,0> ' + GeneralLedgerSetup."LCY Code";

        exit(Format(AmountToFormat, 0, CurrencyFormat));
    end;
}