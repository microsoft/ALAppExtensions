// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Purchases.ExcelReports;

using Microsoft.Purchases.Vendor;
using Microsoft.ExcelReports;

report 4404 "EXR Vendor Top List"
{
    ApplicationArea = All;
    Caption = 'Vendor - Top List Excel (Preview)';
    DataAccessIntent = ReadOnly;
    DefaultRenderingLayout = VendorTopTrendExcel;
    ExcelLayoutMultipleDataSheets = true;
    UsageCategory = ReportsAndAnalysis;
    MaximumDatasetSize = 1000000;

    dataset
    {
        dataitem(TopVendorData; "EXR Top Vendor Report Buffer")
        {
            RequestFilterHeading = 'Top vendor filters';
            RequestFilterFields = "Vendor No.", "Vendor Posting Group", "Currency Code", "Date Filter";
            DataItemTableView = sorting("Amount (LCY)", "Vendor No.");
            column(VendorNo; TopVendorData."Vendor No.")
            {
                IncludeCaption = true;
            }
            column(VendorName; TopVendorData."Vendor Name")
            {
                IncludeCaption = true;
            }
            column(AmountLCY; TopVendorData."Amount (LCY)")
            {
                IncludeCaption = true;
            }
            column(Amount2LCY; TopVendorData."Amount 2 (LCY)")
            {
                IncludeCaption = true;
            }
        }
    }

    requestpage
    {
        AboutText = 'This report contains aggregated purchase (LCY) and balance (LCY) data for the top number of vendors selected. The data is aggregated for the period specified in the request page''s Datefilter parameter.';
        AboutTitle = 'Vendor - Top Trends';
        SaveValues = true;
        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';

                    field(Show; GlobalExtTopVendorReportBuffer."Ranking Based On")
                    {
                        ApplicationArea = Suite;
                        Caption = 'Show';
                        OptionCaption = 'Purchases (LCY),Balance (LCY)';
                        ToolTip = 'Specifies how the report will sort the vendors: Purchases, to sort by purchase volume; or balance. In either case, the vendors with the largest amounts will be shown first.';

                        trigger OnValidate()
                        begin
                            ChangeShowType(GlobalExtTopVendorReportBuffer."Ranking Based On");
                        end;
                    }
                    field(Quantity; NoOfRecordsToPrint)
                    {
                        ApplicationArea = Suite;
                        Caption = 'Quantity';
                        ToolTip = 'Specifies the number of vendors that will be included in the report.';
                    }
                }
            }
        }

        trigger OnOpenPage()
        begin
            NoOfRecordsToPrint := 10;
            ChangeShowType(GlobalExtTopVendorReportBuffer."Ranking Based On"::"Purchases (LCY)");
        end;
    }
    rendering
    {
        layout(VendorTopTrendExcel)
        {
            Type = Excel;
            Caption = 'Vendor - Top Trends Excel';
            LayoutFile = './ReportLayouts/Excel/Vendor/VendorTopListExcel.xlsx';
            Summary = 'Built in layout for the Vendor - Top Trends excel report. This report contains aggregated purchase (LCY) and balance (LCY) data for the top number of vendors selected. Report uses Query connections.';
        }
    }
    labels
    {
        DataRetrieved = 'Data retrieved:';
        RankAccordingTo = 'Rank according to:';
        TopVendorListLabel = 'Top Vendor List';
    }

    var
        ExcelReportsTelemetry: Codeunit "Excel Reports Telemetry";

    protected var
        GlobalExtTopVendorReportBuffer: Record "EXR Top Vendor Report Buffer";
        EXTTopVendorCaptionHandler: Codeunit "EXT Top Vendor Caption Handler";
        NoOfRecordsToPrint: Integer;

    trigger OnPreReport()
    begin
        ExcelReportsTelemetry.LogReportUsage(Report::"EXR Vendor Top List");
        BindSubscription(EXTTopVendorCaptionHandler);
        BuildDataSet();
    end;

    local procedure BuildDataSet()
    var
        VendorFilter: Text;
    begin
        if GlobalExtTopVendorReportBuffer."Ranking Based On" = GlobalExtTopVendorReportBuffer."Ranking Based On"::"Purchases (LCY)" then begin
            VendorFilter := GetEntriesForTopVendorsBasedOnPurchases();
            FillDataForTopVendorsBasedOnPurchases(VendorFilter);
            exit;
        end;

        if GlobalExtTopVendorReportBuffer."Ranking Based On" = GlobalExtTopVendorReportBuffer."Ranking Based On"::"Balance (LCY)" then begin
            VendorFilter := GetEntriesForTopVendorsBasedOnBalance();
            FillDataForTopVendorsBasedOnBalance(VendorFilter);
            exit;
        end;
    end;

    local procedure GetEntriesForTopVendorsBasedOnPurchases(): Text
    var
        EXTTopVendorPurchase: Query "EXR Top Vendor Purchase";
        VendorFilter: Text;
    begin
        EXTTopVendorPurchase.TopNumberOfRows := NoOfRecordsToPrint;
        TransferFilters(EXTTopVendorPurchase, TopVendorData);
        EXTTopVendorPurchase.Open();
        if EXTTopVendorPurchase.Read() then
            repeat
                InsertAggregatedPurchases(EXTTopVendorPurchase.Vendor_No, EXTTopVendorPurchase.Sum_Purch_LCY);
                VendorFilter += EscapeVendorNoFilter(EXTTopVendorPurchase.Vendor_No) + '|';
            until (not EXTTopVendorPurchase.Read());

        exit(VendorFilter.TrimEnd('|'));
    end;

    local procedure GetEntriesForTopVendorsBasedOnBalance(): Text
    var
        EXTTopVendorBalance: Query "EXR Top Vendor Balance";
        VendorFilter: Text;
    begin
        EXTTopVendorBalance.TopNumberOfRows := NoOfRecordsToPrint;
        TransferFilters(EXTTopVendorBalance, TopVendorData);
        EXTTopVendorBalance.Open();
        if EXTTopVendorBalance.Read() then
            repeat
                InsertAggregatedPurchases(EXTTopVendorBalance.Vendor_No, EXTTopVendorBalance.Balance_LCY);
                VendorFilter += EscapeVendorNoFilter(EXTTopVendorBalance.Vendor_No) + '|';
            until (not EXTTopVendorBalance.Read());

        exit(VendorFilter.TrimEnd('|'));
    end;

    local procedure EscapeVendorNoFilter(VendorNo: Code[20]): Text
    begin
        exit('''' + VendorNo + '''');
    end;

    local procedure ChangeShowType(NewShowType: Option)
    begin
        GlobalExtTopVendorReportBuffer."Ranking Based On" := NewShowType;
        EXTTopVendorCaptionHandler.SetRankingBasedOn(GlobalExtTopVendorReportBuffer."Ranking Based On");
    end;

    local procedure FillDataForTopVendorsBasedOnBalance(VendorFilter: Text)
    var
        Vendor: Record Vendor;
        EXTTopVendorPurchase: Query "EXR Top Vendor Purchase";
    begin
        TransferFilters(EXTTopVendorPurchase, TopVendorData);
        EXTTopVendorPurchase.SetFilter(EXTTopVendorPurchase.Vendor_No, VendorFilter);
        EXTTopVendorPurchase.Open();
        if EXTTopVendorPurchase.Read() then
            repeat
                TopVendorData.SetFilter(TopVendorData."Vendor No.", EscapeVendorNoFilter(EXTTopVendorPurchase.Vendor_No));
                if TopVendorData.FindFirst() then begin
                    TopVendorData."Amount 2 (LCY)" := EXTTopVendorPurchase.Sum_Purch_LCY;
                    if Vendor.Get(TopVendorData."Vendor No.") then
                        TopVendorData."Vendor Name" := Vendor.Name;
                    TopVendorData.Modify();
                end;
            until (not EXTTopVendorPurchase.Read());
    end;

    local procedure FillDataForTopVendorsBasedOnPurchases(VendorFilter: Text)
    var
        Vendor: Record Vendor;
        EXTTopVendorBalance: Query "EXR Top Vendor Balance";
    begin
        TransferFilters(EXTTopVendorBalance, TopVendorData);
        EXTTopVendorBalance.SetFilter(EXTTopVendorBalance.Vendor_No, VendorFilter);
        EXTTopVendorBalance.Open();
        if EXTTopVendorBalance.Read() then
            repeat
                TopVendorData.SetFilter(TopVendorData."Vendor No.", EXTTopVendorBalance.Vendor_No);
                if TopVendorData.FindFirst() then begin
                    TopVendorData."Amount 2 (LCY)" := EXTTopVendorBalance.Balance_LCY;
                    if Vendor.Get(TopVendorData."Vendor No.") then
                        TopVendorData."Vendor Name" := Vendor.Name;
                    TopVendorData.Modify();
                end;
            until (not EXTTopVendorBalance.Read());
    end;

    local procedure InsertAggregatedPurchases(VendorNo: Code[20]; AmountLCY: Decimal)
    begin
        Clear(TopVendorData);
        TopVendorData."Vendor No." := VendorNo;
        TopVendorData."Amount (LCY)" := AmountLCY;
        TopVendorData."Ranking Based On" := GlobalExtTopVendorReportBuffer."Ranking Based On";
        TopVendorData.Insert();
    end;

    local procedure TransferFilters(var EXTTopVendorBalance: Query "EXR Top Vendor Balance"; var EXRTopReportBuffer: Record "EXR Top Vendor Report Buffer")
    begin
        EXTTopVendorBalance.TopNumberOfRows := NoOfRecordsToPrint;
        if EXRTopReportBuffer.GetFilter("Global Dimension 1 Filter") <> '' then
            EXTTopVendorBalance.SetFilter(EXTTopVendorBalance.InitialEntryGlobalDim1Code, EXRTopReportBuffer.GetFilter("Global Dimension 1 Filter"));

        if EXRTopReportBuffer.GetFilter("Global Dimension 2 Filter") <> '' then
            EXTTopVendorBalance.SetFilter(EXTTopVendorBalance.InitialEntryGlobalDim2Code, EXRTopReportBuffer.GetFilter("Global Dimension 2 Filter"));

        if EXRTopReportBuffer.GetFilter("Currency Code") <> '' then
            EXTTopVendorBalance.SetFilter(EXTTopVendorBalance.Currency_Code, EXRTopReportBuffer.GetFilter("Currency Code"));

        if EXRTopReportBuffer.GetFilter("Vendor Posting Group") <> '' then
            EXTTopVendorBalance.SetFilter(EXTTopVendorBalance.VendorPostingGroup, EXRTopReportBuffer.GetFilter("Vendor Posting Group"));

        if EXRTopReportBuffer.GetFilter("Date Filter") <> '' then
            EXTTopVendorBalance.SetFilter(EXTTopVendorBalance.Posting_Date, EXRTopReportBuffer.GetFilter("Date Filter"));
    end;

    local procedure TransferFilters(var EXTTopVendorPurchase: Query "EXR Top Vendor Purchase"; var EXRTopReportBuffer: Record "EXR Top Vendor Report Buffer")
    begin
        EXTTopVendorPurchase.TopNumberOfRows := NoOfRecordsToPrint;
        if EXRTopReportBuffer.GetFilter("Global Dimension 1 Filter") <> '' then
            EXTTopVendorPurchase.SetFilter(EXTTopVendorPurchase.GlobalDimension1Code, EXRTopReportBuffer.GetFilter("Global Dimension 1 Filter"));

        if EXRTopReportBuffer.GetFilter("Global Dimension 2 Filter") <> '' then
            EXTTopVendorPurchase.SetFilter(EXTTopVendorPurchase.GlobalDimension2Code, EXRTopReportBuffer.GetFilter("Global Dimension 2 Filter"));

        if EXRTopReportBuffer.GetFilter("Currency Code") <> '' then
            EXTTopVendorPurchase.SetFilter(EXTTopVendorPurchase.Currency_Code, EXRTopReportBuffer.GetFilter("Currency Code"));

        if EXRTopReportBuffer.GetFilter("Vendor Posting Group") <> '' then
            EXTTopVendorPurchase.SetFilter(EXTTopVendorPurchase.VendorPostingGroup, EXRTopReportBuffer.GetFilter("Vendor Posting Group"));

        if EXRTopReportBuffer.GetFilter("Date Filter") <> '' then
            EXTTopVendorPurchase.SetFilter(EXTTopVendorPurchase.Posting_Date, EXRTopReportBuffer.GetFilter("Date Filter"));
    end;
}
