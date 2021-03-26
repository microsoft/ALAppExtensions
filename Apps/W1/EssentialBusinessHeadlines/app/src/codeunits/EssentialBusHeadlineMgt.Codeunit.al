// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 1437 "Essential Bus. Headline Mgt."
{
    var
        Headlines: Codeunit Headlines;
        QualifierYesterdayTxt: Label 'Insight from today', MaxLength = 50;
        QualifierWeekTxt: Label 'Insight from last week', MaxLength = 50;
        QualifierMonthTxt: Label 'Insight from last month', MaxLength = 50;
        Qualifier3MonthsTxt: Label 'Insight from the last three months', MaxLength = 50;
        MostPopularItemPayloadTxt: Label 'The best-selling item was %1 with %2 units sold', Comment = '%1 is the item name, %2 is the quantity sold', MaxLength = 50; // support 20 chars for item and number up to 9 chars: '1,234,567'
        BusiestResourcePayloadTxt: Label '%1 was busy, with %2 units booked', Comment = '%1 is the resource name, %2 is the quantity sold', MaxLength = 50;  // support 20 chars for resource and number up to 9 chars: '1,234,567'
        LargestOrderPayloadTxt: Label 'The biggest sales order was for %1', Comment = '%1 is the order amount with currency symbol/name.', MaxLength = 65; // support currencies up to 12 chars: '1,234,567 kr'
        LargestSalePayloadTxt: Label 'The largest posted sales invoice was for %1', Comment = ' %1 is the sales amount with currency symbol/name.', MaxLength = 65; // support currencies up to 12 chars: '1,234,567 kr'
        SalesIncreaseComparedToLastYearPayloadTxt: Label 'You closed %1 more deals than in the same period last year', Comment = '%1 is the difference of sales (positive) between this period and the same period the previous year.', MaxLength = 68; // support numbers up to 9 chars: '1,234,567'
        TopCustomerPayloadTxt: Label 'Your top customer was %1, bought for %2', Comment = '%1 is the Customer name, %2 is the sales amount with currency symbol/name.', MaxLength = 47; // support 20 chars for customer and currencies up to 12 chars: '1,234,567 kr'
        VATReturnQualifierTxt: Label 'VAT Return';
        OverdueVATReturnPeriodTxt: Label 'Your VAT return is overdue since %1 (%2 days)', Comment = '%1 - date; %2 - days count';
        OpenVATReturnPeriodTxt: Label 'Your VAT return is due %1 (in %2 days)', Comment = '%1 - date; %2 - days count';
        RecentlyOverdueInvoicesPayloadTxt: Label 'Overdue invoices up by %1. You can collect %2', Comment = '%1 is the number of recently overdue invoices, %2 is the total amount of the recently overdue invoices', MaxLength = 60; // support up to 3-digit number of overdue invoices and currencies up to 12 chars: '1,234,567 kr'

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
        HeadlineText: Text;
    begin
        BestSoldItemQuery.SetFilter(PostDate, '>=%1&<=%2', CalcDate(StrSubstNo('<-%1D>', DaysSearch), WorkDate()), WorkDate());
        BestSoldItemQuery.SetRange(ProductType, SalesLine.Type::Item);
        if not BestSoldItemQuery.Open() then
            exit;

        if not BestSoldItemQuery.Read() then
            exit;

        BestQty := BestSoldItemQuery.SumQuantity;
        Item.Get(BestSoldItemQuery.ProductNo);
        HeadlineText := EssentialBusinessHeadline."Headline Text";

        if not Headlines.GetHeadlineText(
                ChooseQualifier(QualifierWeekTxt, QualifierMonthTxt, Qualifier3MonthsTxt, DaysSearch),
                GetBestItemPayload(Item.Description, Format(BestQty)),
                HeadlineText)
        then
            exit;

        EssentialBusinessHeadline."Headline Text" := CopyStr(HeadlineText, 1, MaxStrLen(EssentialBusinessHeadline."Headline Text"));
        HeadlineDetails.SetRange(Type, HeadlineDetails.Type::Item);
        HeadlineDetails.SetRange("User Id", UserSecurityId());
        HeadlineDetails.DeleteAll();

        InsertHeadlineDetails(BestSoldItemQuery.ProductNo, HeadlineDetails.Type::Item, Item.Description, Item."Base Unit of Measure", BestSoldItemQuery.SumQuantity, 0);

        // if there is only one item sold in the time period, do not set to visible
        if BestSoldItemQuery.Read() then
            if BestSoldItemQuery.SumQuantity < BestQty then begin // if there is another resource that is also the best, do not set to visible
                EssentialBusinessHeadline.Validate("Headline Visible", true);
                EssentialBusinessHeadline.Validate("Headline Computation WorkDate", WorkDate());
                EssentialBusinessHeadline.Validate("Headline Computation Period", DaysSearch);

                repeat
                    Item.get(BestSoldItemQuery.ProductNo);
                    InsertHeadlineDetails(BestSoldItemQuery.ProductNo, HeadlineDetails.Type::Item, Item.Description, Item."Base Unit of Measure", BestSoldItemQuery.SumQuantity, 0);
                until not BestSoldItemQuery.Read();

                exit(true);
            end;
    end;

    procedure GetBestItemPayload(ItemName: Text[100]; TextQuantity: Text): Text
    begin
        exit(StrSubstNo(MostPopularItemPayloadTxt,
            Headlines.Emphasize(
                Headlines.Truncate(
                    ItemName,
                    Headlines.GetMaxPayloadLength() - StrLen(MostPopularItemPayloadTxt) + 4 - StrLen(TextQuantity))),
            Headlines.Emphasize(TextQuantity)));
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
        HeadlineText: Text;
    begin
        BusiestResource.SetFilter(PostDate, '>=%1&<=%2', CalcDate(StrSubstNo('<-%1D>', DaysSearch), WorkDate()), WorkDate());
        BusiestResource.SetRange(ProductType, SalesLine.Type::Resource);
        if not BusiestResource.Open() then
            exit;

        if not BusiestResource.Read() then
            exit;
        BestQty := BusiestResource.SumQuantity;
        Resource.Get(BusiestResource.ProductNo);
        HeadlineText := EssentialBusinessHeadline."Headline Text";

        if not Headlines.GetHeadlineText(
                ChooseQualifier(QualifierWeekTxt, QualifierMonthTxt, Qualifier3MonthsTxt, DaysSearch),
                GetBusiestResoucePayload(Resource.Name, Format(BestQty)),
                HeadlineText)
        then
            exit;

        EssentialBusinessHeadline."Headline Text" := CopyStr(HeadlineText, 1, MaxStrLen(EssentialBusinessHeadline."Headline Text"));
        HeadlineDetails.SetRange(Type, HeadlineDetails.Type::Resource);
        HeadlineDetails.SetRange("User Id", UserSecurityId());
        HeadlineDetails.DeleteAll();

        InsertHeadlineDetails(BusiestResource.ProductNo, HeadlineDetails.Type::Resource, Resource.Name, Resource."Base Unit of Measure", BusiestResource.SumQuantity, 0);

        // if there is only one active resource in the time period, do not set to visible
        if BusiestResource.Read() then
            if BusiestResource.SumQuantity < BestQty then begin // if there is another resource that is also the best, do not set to visible
                EssentialBusinessHeadline.Validate("Headline Visible", true);
                EssentialBusinessHeadline.Validate("Headline Computation WorkDate", WorkDate());
                EssentialBusinessHeadline.Validate("Headline Computation Period", DaysSearch);

                repeat
                    Resource.Get(BusiestResource.ProductNo);
                    InsertHeadlineDetails(BusiestResource.ProductNo, HeadlineDetails.Type::Resource, Resource.Name, Resource."Base Unit of Measure", BusiestResource.SumQuantity, 0);
                until not BusiestResource.Read();

                exit(true);
            end;
    end;

    local procedure InsertHeadlineDetails(No: Code[20]; Type: Option; Name: Text[100]; UnitOfMeasure: Code[10]; Quantity: Decimal; AmountLcy: Decimal)
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

    procedure GetBusiestResoucePayload(ResourceName: Text[100]; TextQuantity: Text): Text
    begin
        exit(StrSubstNo(BusiestResourcePayloadTxt,
            Headlines.Emphasize(
                Headlines.Truncate(
                    ResourceName,
                    Headlines.GetMaxPayloadLength() - StrLen(BusiestResourcePayloadTxt) + 4 - StrLen(TextQuantity))),
            Headlines.Emphasize(TextQuantity)));
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
        [SecurityFiltering(SecurityFilter::Filtered)]
        SalesHeader: Record "Sales Header";
        CurrentKeyOk: Boolean;
        HeadlineText: Text;
    begin
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.SetFilter("Posting Date", '>=%1&<=%2', CalcDate(StrSubstNo('<-%1D>', DaysSearch), WorkDate()), WorkDate());
        CurrentKeyOk := SalesHeader.SetCurrentKey(Amount);
        SalesHeader.SetAscending(Amount, false);
        HeadlineText := EssentialBusinessHeadline."Headline Text";

        // we need at least 5 orders for this headline to be valid
        if (SalesHeader.Count() > 5) and SalesHeader.FindFirst() then begin
            if not Headlines.GetHeadlineText(
                ChooseQualifier(QualifierWeekTxt, QualifierMonthTxt, Qualifier3MonthsTxt, DaysSearch),
                StrSubstNo(LargestOrderPayloadTxt,
                   Headlines.Emphasize(FormatCurrency(SalesHeader.Amount, SalesHeader."Currency Code"))),
                HeadlineText)
            then
                exit;

            EssentialBusinessHeadline."Headline Text" := CopyStr(HeadlineText, 1, MaxStrLen(EssentialBusinessHeadline."Headline Text"));
            EssentialBusinessHeadline.Validate("Headline Visible", true);
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
        [SecurityFiltering(SecurityFilter::Filtered)]
        CustomerLedgerEntry: Record "Cust. Ledger Entry";
        CurrentKeyOk: Boolean;
        HeadlineText: Text;
    begin
        CustomerLedgerEntry.SetFilter("Posting Date", '>=%1&<=%2', CalcDate(StrSubstNo('<-%1D>', DaysSearch), WorkDate()), WorkDate());
        CustomerLedgerEntry.SetRange("Document Type", CustomerLedgerEntry."Document Type"::Invoice);
        CustomerLedgerEntry.SetRange(Reversed, false);
        CurrentKeyOk := CustomerLedgerEntry.SetCurrentKey("Amount (LCY)");
        CustomerLedgerEntry.SetAscending("Amount (LCY)", false);
        HeadlineText := EssentialBusinessHeadline."Headline Text";

        // we need at least 5 sales for this headline to be valid
        if (CustomerLedgerEntry.Count() > 5) and CustomerLedgerEntry.FindFirst() then begin
            CustomerLedgerEntry.CalcFields(Amount);

            if not Headlines.GetHeadlineText(
                ChooseQualifier(QualifierWeekTxt, QualifierMonthTxt, Qualifier3MonthsTxt, DaysSearch),
                StrSubstNo(LargestSalePayloadTxt,
                  Headlines.Emphasize(FormatCurrency(CustomerLedgerEntry.Amount, CustomerLedgerEntry."Currency Code"))),
                HeadlineText)
            then
                exit;

            EssentialBusinessHeadline."Headline Text" := CopyStr(HeadlineText, 1, MaxStrLen(EssentialBusinessHeadline."Headline Text"));
            EssentialBusinessHeadline.Validate("Headline Visible", true);
            EssentialBusinessHeadline.Validate("Headline Computation WorkDate", WorkDate());
            EssentialBusinessHeadline.Validate("Headline Computation Period", DaysSearch);
            exit(true);
        end else
            EssentialBusinessHeadline.Validate("Headline Visible", false);
    end;

    procedure OnDrillDownLargestSale()
    var
        [SecurityFiltering(SecurityFilter::Filtered)]
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
        SalesIncreaseHeadline: Query "Sales Increase Headline";
        SalesThisMonth: Integer;
        SalesThisMonthLastYear: Integer;
        HeadlineText: Text;
    begin
        SalesIncreaseHeadline.SetFilter(PostDate, '>=%1&<=%2', CalcDate(StrSubstNo('<-%1D>', DaysSearch), WorkDate()), WorkDate());
        if not SalesIncreaseHeadline.Open() then
            exit;
        if not SalesIncreaseHeadline.Read() then
            exit;

        SalesThisMonth := SalesIncreaseHeadline.CountInvoices;

        if (SalesThisMonth = 0) then begin
            // we need sales this month for this headline to be valid
            EssentialBusinessHeadline.Validate("Headline Visible", false);
            exit;
        end;

        SalesIncreaseHeadline.SetFilter(PostDate, '>=%1&<=%2',
            CalcDate(StrSubstNo('<-%1D>', 365 + DaysSearch), WorkDate()),
            CalcDate(StrSubstNo('<-%1D>', 365), WorkDate()));

        if not SalesIncreaseHeadline.Open() then
            exit;
        if not SalesIncreaseHeadline.Read() then
            exit;

        SalesThisMonthLastYear := SalesIncreaseHeadline.CountInvoices;

        if (SalesThisMonthLastYear = 0) or (SalesThisMonth <= SalesThisMonthLastYear) then begin
            // we need sales this month on the previous year, and the sales to be better the current year for this headline to be valid
            EssentialBusinessHeadline.Validate("Headline Visible", false);
            exit;
        end;

        HeadlineText := EssentialBusinessHeadline."Headline Text";

        if not Headlines.GetHeadlineText(
            ChooseQualifier(QualifierWeekTxt, QualifierMonthTxt, Qualifier3MonthsTxt, DaysSearch),
            StrSubstNo(SalesIncreaseComparedToLastYearPayloadTxt,
                Headlines.Emphasize(Format(SalesThisMonth - SalesThisMonthLastYear))),
            HeadlineText)
        then
            exit;

        EssentialBusinessHeadline."Headline Text" := CopyStr(HeadlineText, 1, MaxStrLen(EssentialBusinessHeadline."Headline Text"));
        EssentialBusinessHeadline.Validate("Headline Visible", true);
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

    procedure HandleRecentlyOverdueInvoices()
    var
        EssentialBusinessHeadline: Record "Ess. Business Headline Per Usr";
        CustomerLedgerEntry: Record "Cust. Ledger Entry";
        RecentlyOverdueInvoices: Integer;
        TotalAmount: Decimal;
        HeadlineText: Text;
    begin
        EssentialBusinessHeadline.GetOrCreateHeadline(EssentialBusinessHeadline."Headline Name"::RecentlyOverdueInvoices);
        FindRecentlyOverdueInvoices(CustomerLedgerEntry, WorkDate());
        RecentlyOverdueInvoices := CustomerLedgerEntry.Count();

        // At least one entry is needed to show the headline
        if (RecentlyOverdueInvoices = 0) then begin
            HideHeadLine(EssentialBusinessHeadline."Headline Name"::RecentlyOverdueInvoices);
            exit;
        end;

        TotalAmount := 0.0;
        if CustomerLedgerEntry.FindSet() then
            repeat
                CustomerLedgerEntry.CalcFields("Amount (LCY)");
                TotalAmount := TotalAmount + CustomerLedgerEntry."Amount (LCY)";
            until CustomerLedgerEntry.Next() = 0;

        HeadlineText := EssentialBusinessHeadline."Headline Text";
        if not Headlines.GetHeadlineText(
            QualifierYesterdayTxt,
            StrSubstNo(RecentlyOverdueInvoicesPayloadTxt,
                Headlines.Emphasize(Format(RecentlyOverdueInvoices)),
                Headlines.Emphasize(FormatLocalCurrency(TotalAmount))),
            HeadlineText)
        then begin
            HideHeadLine(EssentialBusinessHeadline."Headline Name"::RecentlyOverdueInvoices);
            exit;
        end;

        EssentialBusinessHeadline."Headline Text" := CopyStr(HeadlineText, 1, MaxStrLen(EssentialBusinessHeadline."Headline Text"));
        EssentialBusinessHeadline.Validate("Headline Visible", true);
        EssentialBusinessHeadline.Validate("Headline Computation WorkDate", WorkDate());
        EssentialBusinessHeadline.Validate("Headline Computation Period", 1);
        EssentialBusinessHeadline.Modify(true);
    end;

    local procedure FindRecentlyOverdueInvoices(var CustomerLedgerEntry: Record "Cust. Ledger Entry"; ComputationDate: Date)
    begin
        CustomerLedgerEntry.SetRange(Open, true);
        CustomerLedgerEntry.SetFilter("Due Date", '=%1', CalcDate('<-1D>', ComputationDate));
        CustomerLedgerEntry.SetRange("Document Type", CustomerLedgerEntry."Document Type"::Invoice);
    end;

    procedure OnDrillDownRecentlyOverdueInvoices()
    var
        CustomerLedgerEntry: Record "Cust. Ledger Entry";
        EssentialBusinessHeadline: Record "Ess. Business Headline Per Usr";
    begin
        EssentialBusinessHeadline.GetOrCreateHeadline(EssentialBusinessHeadline."Headline Name"::RecentlyOverdueInvoices);

        FindRecentlyOverdueInvoices(CustomerLedgerEntry, EssentialBusinessHeadline."Headline Computation WorkDate");

        Page.Run(Page::"Customer Ledger Entries", CustomerLedgerEntry);
    end;

    procedure HandleTopCustomer()
    var
        EssentialBusinessHeadline: Record "Ess. Business Headline Per Usr";
        TimePeriods: List of [Integer];
        TimePeriodDays: Integer;
    begin
        EssentialBusinessHeadline.GetOrCreateHeadline(EssentialBusinessHeadline."Headline Name"::TopCustomer);
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
        HeadlineText: Text;
    begin
        TopCustomerHeadlineQuery.SetFilter(PostDate, '>=%1&<=%2',
            CalcDate(StrSubstNo('<-%1D>', DaysSearch), WorkDate()),
            WorkDate());
        if not TopCustomerHeadlineQuery.Open() then
            exit;

        if not TopCustomerHeadlineQuery.Read() then
            exit;

        Customer.Get(TopCustomerHeadlineQuery.CustomerNo);

        HeadlineText := EssentialBusinessHeadline."Headline Text";
        if not Headlines.GetHeadlineText(
            ChooseQualifier(QualifierWeekTxt, QualifierMonthTxt, Qualifier3MonthsTxt, DaysSearch),
            GetTopCustomerPayload(Customer.Name, FormatLocalCurrency(TopCustomerHeadlineQuery.SumAmountLcy)),
            HeadlineText)
        then
            exit;


        EssentialBusinessHeadline."Headline Text" := CopyStr(HeadlineText, 1, MaxStrLen(EssentialBusinessHeadline."Headline Text"));
        HeadlineDetails.SetRange(Type, HeadlineDetails.Type::Customer);
        HeadlineDetails.SetRange("User Id", UserSecurityId());
        HeadlineDetails.DeleteAll();
        InsertHeadlineDetails(TopCustomerHeadlineQuery.No, HeadlineDetails.Type::Customer, TopCustomerHeadlineQuery.CustomerName, '', 0, TopCustomerHeadlineQuery.SumAmountLcy);

        // if there is only one customer last month, do not set to visible
        if TopCustomerHeadlineQuery.Read() then begin
            if TopCustomerHeadlineQuery.SumAmountLcy <= 0 then
                exit;
            EssentialBusinessHeadline.Validate("Headline Visible", true);
            EssentialBusinessHeadline.Validate("Headline Computation WorkDate", WorkDate());
            EssentialBusinessHeadline.Validate("Headline Computation Period", DaysSearch);

            repeat
                InsertHeadlineDetails(TopCustomerHeadlineQuery.No, HeadlineDetails.Type::Customer, TopCustomerHeadlineQuery.CustomerName, '', 0, TopCustomerHeadlineQuery.SumAmountLcy);
            until not TopCustomerHeadlineQuery.Read();

            exit(true);
        end;
    end;

    procedure GetTopCustomerPayload(CustomerName: Text[100]; TextAmountLcy: Text): Text
    begin
        exit(StrSubstNo(TopCustomerPayloadTxt,
            Headlines.Emphasize(
                Headlines.Truncate(
                    CustomerName,
                    Headlines.GetMaxPayloadLength() - StrLen(TopCustomerPayloadTxt) + 4 - StrLen(TextAmountLcy))),
            Headlines.Emphasize(TextAmountLcy)));
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

    procedure HideHeadline(HeadlineName: Option)
    var
        EssentialBusinessHeadline: Record "Ess. Business Headline Per Usr";
    begin
        if EssentialBusinessHeadline.Get(HeadlineName) then begin
            EssentialBusinessHeadline.Validate("Headline Visible", false);
            EssentialBusinessHeadline.Modify();
        end;
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
        CurrencyFormat := TypeHelper.GetAmountFormatWithUserLocale(GeneralLedgerSetup.GetCurrencySymbol());
        exit(Format(AmountToFormat, 0, CurrencyFormat));
    end;

    procedure HandleOpenVATReturn()
    var
        VATReportSetup: Record "VAT Report Setup";
        EssentialBusinessHeadline: Record "Ess. Business Headline Per Usr";
        VATReturnPeriod: Record "VAT Return Period";
        HeadlineText: Text[250];
    begin
        EssentialBusinessHeadline.GetOrCreateHeadline(EssentialBusinessHeadline."Headline Name"::OpenVATReturn);
        VATReportSetup.Get();
        VATReturnPeriod.SetFilter("Due Date", '>=%1&<=%2', WorkDate(), CalcDate(VATReportSetup."Period Reminder Calculation", WorkDate()));
        if VATReportSetup.IsPeriodReminderCalculation() AND
           FindOpenVATReturnPeriod(VATReturnPeriod)
        then begin
            HeadlineText :=
                CopyStr(
                    StrSubstNo(
                        OpenVATReturnPeriodTxt,
                        Headlines.Emphasize(Format(VATReturnPeriod."Due Date")), VATReturnPeriod."Due Date" - WorkDate()),
                    1, MaxStrLen(HeadlineText));
            EssentialBusinessHeadline.Validate("VAT Return Period Record Id", VATReturnPeriod.RecordId());
        end;

        UpdateVATReturnHeadline(EssentialBusinessHeadline, HeadlineText);
    end;

    procedure HandleOverdueVATReturn()
    var
        VATReportSetup: Record "VAT Report Setup";
        EssentialBusinessHeadline: Record "Ess. Business Headline Per Usr";
        VATReturnPeriod: Record "VAT Return Period";
        HeadlineText: Text[250];
    begin
        EssentialBusinessHeadline.GetOrCreateHeadline(EssentialBusinessHeadline."Headline Name"::OverdueVATReturn);
        VATReportSetup.Get();
        VATReturnPeriod.SetFilter("Due Date", '>%1&<%2', 0D, WorkDate());
        if FindOpenVATReturnPeriod(VATReturnPeriod) then begin
            HeadlineText :=
                CopyStr(
                    StrSubstNo(
                        OverdueVATReturnPeriodTxt,
                        Headlines.Emphasize(Format(VATReturnPeriod."Due Date")), WorkDate() - VATReturnPeriod."Due Date"),
                    1, MaxStrLen(HeadlineText));
            EssentialBusinessHeadline.Validate("VAT Return Period Record Id", VATReturnPeriod.RecordId());
        end;

        UpdateVATReturnHeadline(EssentialBusinessHeadline, HeadlineText);
    end;

    local procedure FindOpenVATReturnPeriod(var VATReturnPeriod: Record "VAT Return Period"): Boolean
    begin
        VATReturnPeriod.SetRange(Status, VATReturnPeriod.Status::Open);
        exit(VATReturnPeriod.FindFirst());
    end;

    local procedure UpdateVATReturnHeadline(var EssentialBusinessHeadline: Record "Ess. Business Headline Per Usr"; HeadlineText: Text)
    begin
        with EssentialBusinessHeadline do begin
            Validate("Headline Visible", HeadlineText <> '');
            if "Headline Visible" then begin
                Headlines.GetHeadlineText(VATReturnQualifierTxt, HeadlineText, HeadlineText);
                Validate("Headline Text", CopyStr(HeadlineText, 1, MaxStrLen("Headline Text")));
                Validate("Headline Computation WorkDate", WorkDate());
            end;
            Modify();
        end;
    end;

    procedure OnDrillDownOpenVATReturn()
    var
        VATReturnPeriod: Record "VAT Return Period";
        EssentialBusinessHeadline: Record "Ess. Business Headline Per Usr";
    begin
        EssentialBusinessHeadline.GetOrCreateHeadline(EssentialBusinessHeadline."Headline Name"::OpenVATReturn);
        if VATReturnPeriod.Get(EssentialBusinessHeadline."VAT Return Period Record Id") then
            Page.RunModal(page::"VAT Return Period Card", VATReturnPeriod);
    end;

    procedure OnDrillDownOverdueVATReturn()
    var
        VATReturnPeriod: Record "VAT Return Period";
        EssentialBusinessHeadline: Record "Ess. Business Headline Per Usr";
    begin
        EssentialBusinessHeadline.GetOrCreateHeadline(EssentialBusinessHeadline."Headline Name"::OverdueVATReturn);
        if VATReturnPeriod.Get(EssentialBusinessHeadline."VAT Return Period Record Id") then
            Page.RunModal(page::"VAT Return Period Card", VATReturnPeriod);
    end;
}
