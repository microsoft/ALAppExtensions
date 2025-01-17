// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Sales.ExcelReports;

using Microsoft.Sales.Customer;
using Microsoft.ExcelReports;

report 4409 "EXR Customer Top List"
{
    ApplicationArea = All;
    Caption = 'Customer - Top List Excel (Preview)';
    DataAccessIntent = ReadOnly;
    DefaultRenderingLayout = CustomerTopTrendExcel;
    ExcelLayoutMultipleDataSheets = true;
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(TopCustomerData; "EXR Top Customer Report Buffer")
        {
            RequestFilterHeading = 'Top Customer filters';
            RequestFilterFields = "Customer No.", "Customer Posting Group", "Currency Code", "Date Filter";
            DataItemTableView = sorting("Amount (LCY)", "Customer No.");
            column(CustomerNo; TopCustomerData."Customer No.")
            {
                IncludeCaption = true;
            }
            column(CustomerName; TopCustomerData."Customer Name")
            {
                IncludeCaption = true;
            }
            column(AmountLCY; TopCustomerData."Amount (LCY)")
            {
                IncludeCaption = true;
            }
            column(Amount2LCY; TopCustomerData."Amount 2 (LCY)")
            {
                IncludeCaption = true;
            }
        }
    }

    requestpage
    {
        AboutText = 'This report contains aggregated sales (LCY) and balance (LCY) data for the top number of customers selected. The data is aggregated for the period specified in the request page''s Datefilter parameter.';
        AboutTitle = 'Customer - Top Trends';
        SaveValues = true;
        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';

                    field(Show; GlobalExtTopCustomerReportBuffer."Ranking Based On")
                    {
                        ApplicationArea = Suite;
                        Caption = 'Show';
                        OptionCaption = 'Sales (LCY),Balance (LCY)';
                        ToolTip = 'Specifies how the report will sort the Customers: Sales, to sort by sale volume; or balance. In either case, the Customers with the largest amounts will be shown first.';

                        trigger OnValidate()
                        begin
                            ChangeShowType(GlobalExtTopCustomerReportBuffer."Ranking Based On");
                        end;
                    }
                    field(Quantity; NoOfRecordsToPrint)
                    {
                        ApplicationArea = Suite;
                        Caption = 'Quantity';
                        ToolTip = 'Specifies the number of Customers that will be included in the report.';
                    }
                }
            }
        }

        trigger OnOpenPage()
        begin
            NoOfRecordsToPrint := 10;
            ChangeShowType(GlobalExtTopCustomerReportBuffer."Ranking Based On"::"Sales (LCY)");
        end;
    }
    rendering
    {
        layout(CustomerTopTrendExcel)
        {
            Caption = 'Customer - Top Trends Excel';
            LayoutFile = './ReportLayouts/Excel/Customer/CustomerTopListExcel.xlsx';
            Type = Excel;
            Summary = 'Built in layout for the Customer - Top Trends excel report. This report contains aggregated sales (LCY) and balance (LCY) data for the top number of customers selected. Report uses Query connections.';
        }
    }
    labels
    {
        DataRetrieved = 'Data retrieved:';
        RankAccordingTo = 'Rank according to:';
        TopCustomerListLabel = 'Top Customer List';
    }

    var
        ExcelReportsTelemetry: Codeunit "Excel Reports Telemetry";

    protected var
        GlobalExtTopCustomerReportBuffer: Record "EXR Top Customer Report Buffer";
        EXTTopCustomerCaptionHandler: Codeunit "EXT Top Cust. Caption Handler";
        NoOfRecordsToPrint: Integer;

    trigger OnPreReport()
    begin
        ExcelReportsTelemetry.LogReportUsage(Report::"EXR Customer Top List");
        BindSubscription(EXTTopCustomerCaptionHandler);
        BuildDataSet();
    end;

    local procedure BuildDataSet()
    var
        CustomerFilter: Text;
    begin
        if GlobalExtTopCustomerReportBuffer."Ranking Based On" = GlobalExtTopCustomerReportBuffer."Ranking Based On"::"Sales (LCY)" then begin
            CustomerFilter := GetEntriesForTopCustomersBasedOnSales();
            FillDataForTopCustomersBasedOnSales(CustomerFilter);
            exit;
        end;

        if GlobalExtTopCustomerReportBuffer."Ranking Based On" = GlobalExtTopCustomerReportBuffer."Ranking Based On"::"Balance (LCY)" then begin
            CustomerFilter := GetEntriesForTopCustomersBasedOnBalance();
            FillDataForTopCustomersBasedOnBalance(CustomerFilter);
            exit;
        end;
    end;

    local procedure GetEntriesForTopCustomersBasedOnSales(): Text
    var
        EXTTopCustomerSale: Query "EXR Top Customer Sales";
        CustomerFilter: Text;
    begin
        EXTTopCustomerSale.TopNumberOfRows := NoOfRecordsToPrint;
        TransferFilters(EXTTopCustomerSale, TopCustomerData);
        EXTTopCustomerSale.Open();
        if EXTTopCustomerSale.Read() then
            repeat
                InsertAggregatedSales(EXTTopCustomerSale.Customer_No, EXTTopCustomerSale.Sum_Purch_LCY);
                CustomerFilter += EscapeCustomerNoFilter(EXTTopCustomerSale.Customer_No) + '|';
            until (not EXTTopCustomerSale.Read());

        exit(CustomerFilter.TrimEnd('|'));
    end;

    local procedure GetEntriesForTopCustomersBasedOnBalance(): Text
    var
        EXTTopCustomerBalance: Query "EXR Top Customer Balance";
        CustomerFilter: Text;
    begin
        EXTTopCustomerBalance.TopNumberOfRows := NoOfRecordsToPrint;
        TransferFilters(EXTTopCustomerBalance, TopCustomerData);
        EXTTopCustomerBalance.Open();
        if EXTTopCustomerBalance.Read() then
            repeat
                InsertAggregatedSales(EXTTopCustomerBalance.Customer_No, EXTTopCustomerBalance.Balance_LCY);
                CustomerFilter += EscapeCustomerNoFilter(EXTTopCustomerBalance.Customer_No) + '|';
            until (not EXTTopCustomerBalance.Read());

        exit(CustomerFilter.TrimEnd('|'));
    end;

    local procedure EscapeCustomerNoFilter(CustomerNo: Code[20]): Text
    begin
        exit('''' + CustomerNo + '''');
    end;

    local procedure ChangeShowType(NewShowType: Option)
    begin
        GlobalExtTopCustomerReportBuffer."Ranking Based On" := NewShowType;
        EXTTopCustomerCaptionHandler.SetRankingBasedOn(GlobalExtTopCustomerReportBuffer."Ranking Based On");
    end;

    local procedure FillDataForTopCustomersBasedOnBalance(CustomerFilter: Text)
    var
        Customer: Record Customer;
        EXTTopCustomerSale: Query "EXR Top Customer Sales";
    begin
        TransferFilters(EXTTopCustomerSale, TopCustomerData);
        EXTTopCustomerSale.SetFilter(EXTTopCustomerSale.Customer_No, CustomerFilter);
        EXTTopCustomerSale.Open();
        if EXTTopCustomerSale.Read() then
            repeat
                TopCustomerData.SetFilter(TopCustomerData."Customer No.", EXTTopCustomerSale.Customer_No);
                if TopCustomerData.FindFirst() then begin
                    TopCustomerData."Amount 2 (LCY)" := EXTTopCustomerSale.Sum_Purch_LCY;
                    if Customer.Get(TopCustomerData."Customer No.") then
                        TopCustomerData."Customer Name" := Customer.Name;
                    TopCustomerData.Modify();
                end;
            until (not EXTTopCustomerSale.Read());
    end;

    local procedure FillDataForTopCustomersBasedOnSales(CustomerFilter: Text)
    var
        Customer: Record Customer;
        EXTTopCustomerBalance: Query "EXR Top Customer Balance";
    begin
        TransferFilters(EXTTopCustomerBalance, TopCustomerData);
        EXTTopCustomerBalance.SetFilter(EXTTopCustomerBalance.Customer_No, CustomerFilter);
        EXTTopCustomerBalance.Open();
        if EXTTopCustomerBalance.Read() then
            repeat
                TopCustomerData.SetFilter(TopCustomerData."Customer No.", EscapeCustomerNoFilter(EXTTopCustomerBalance.Customer_No));
                if TopCustomerData.FindFirst() then begin
                    TopCustomerData."Amount 2 (LCY)" := EXTTopCustomerBalance.Balance_LCY;
                    if Customer.Get(TopCustomerData."Customer No.") then
                        TopCustomerData."Customer Name" := Customer.Name;
                    TopCustomerData.Modify();
                end;
            until (not EXTTopCustomerBalance.Read());
    end;

    local procedure InsertAggregatedSales(CustomerNo: Code[20]; AmountLCY: Decimal)
    begin
        Clear(TopCustomerData);
        TopCustomerData."Customer No." := CustomerNo;
        TopCustomerData."Amount (LCY)" := AmountLCY;
        TopCustomerData."Ranking Based On" := GlobalExtTopCustomerReportBuffer."Ranking Based On";
        TopCustomerData.Insert();
    end;

    local procedure TransferFilters(var EXTTopCustomerBalance: Query "EXR Top Customer Balance"; var EXRTopReportBuffer: Record "EXR Top Customer Report Buffer")
    begin
        EXTTopCustomerBalance.TopNumberOfRows := NoOfRecordsToPrint;
        if EXRTopReportBuffer.GetFilter("Global Dimension 1 Filter") <> '' then
            EXTTopCustomerBalance.SetFilter(EXTTopCustomerBalance.InitialEntryGlobalDim1Code, EXRTopReportBuffer.GetFilter("Global Dimension 1 Filter"));

        if EXRTopReportBuffer.GetFilter("Global Dimension 2 Filter") <> '' then
            EXTTopCustomerBalance.SetFilter(EXTTopCustomerBalance.InitialEntryGlobalDim2Code, EXRTopReportBuffer.GetFilter("Global Dimension 2 Filter"));

        if EXRTopReportBuffer.GetFilter("Currency Code") <> '' then
            EXTTopCustomerBalance.SetFilter(EXTTopCustomerBalance.Currency_Code, EXRTopReportBuffer.GetFilter("Currency Code"));

        if EXRTopReportBuffer.GetFilter("Customer Posting Group") <> '' then
            EXTTopCustomerBalance.SetFilter(EXTTopCustomerBalance.CustomerPostingGroup, EXRTopReportBuffer.GetFilter("Customer Posting Group"));

        if EXRTopReportBuffer.GetFilter("Date Filter") <> '' then
            EXTTopCustomerBalance.SetFilter(EXTTopCustomerBalance.Posting_Date, EXRTopReportBuffer.GetFilter("Date Filter"));
    end;

    local procedure TransferFilters(var EXTTopCustomerSale: Query "EXR Top Customer Sales"; var EXRTopReportBuffer: Record "EXR Top Customer Report Buffer")
    begin
        EXTTopCustomerSale.TopNumberOfRows := NoOfRecordsToPrint;
        if EXRTopReportBuffer.GetFilter("Global Dimension 1 Filter") <> '' then
            EXTTopCustomerSale.SetFilter(EXTTopCustomerSale.GlobalDimension1Code, EXRTopReportBuffer.GetFilter("Global Dimension 1 Filter"));

        if EXRTopReportBuffer.GetFilter("Global Dimension 2 Filter") <> '' then
            EXTTopCustomerSale.SetFilter(EXTTopCustomerSale.GlobalDimension2Code, EXRTopReportBuffer.GetFilter("Global Dimension 2 Filter"));

        if EXRTopReportBuffer.GetFilter("Currency Code") <> '' then
            EXTTopCustomerSale.SetFilter(EXTTopCustomerSale.Currency_Code, EXRTopReportBuffer.GetFilter("Currency Code"));

        if EXRTopReportBuffer.GetFilter("Customer Posting Group") <> '' then
            EXTTopCustomerSale.SetFilter(EXTTopCustomerSale.CustomerPostingGroup, EXRTopReportBuffer.GetFilter("Customer Posting Group"));

        if EXRTopReportBuffer.GetFilter("Date Filter") <> '' then
            EXTTopCustomerSale.SetFilter(EXTTopCustomerSale.Posting_Date, EXRTopReportBuffer.GetFilter("Date Filter"));
    end;
}
