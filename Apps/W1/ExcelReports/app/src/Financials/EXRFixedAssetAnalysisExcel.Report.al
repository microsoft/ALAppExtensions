namespace Microsoft.Finance.ExcelReports;

using Microsoft.FixedAssets.FixedAsset;
using Microsoft.FixedAssets.Depreciation;
using Microsoft.FixedAssets.Setup;
using Microsoft.FixedAssets.Posting;

report 4412 "EXR Fixed Asset Analysis Excel"
{
    ApplicationArea = All;
    AdditionalSearchTerms = 'FA Analysis Excel,FA Analysis';
    Caption = 'Fixed Asset Analysis Excel (Preview)';
    DataAccessIntent = ReadOnly;
    DefaultRenderingLayout = FixedAssetAnalysisExcel;
    ExcelLayoutMultipleDataSheets = true;
    PreviewMode = PrintLayout;
    UsageCategory = ReportsAndAnalysis;
    MaximumDatasetSize = 1000000;
    dataset
    {
        dataitem(FixedAssetData; "Fixed Asset")
        {
            DataItemTableView = sorting("No.");
            RequestFilterFields = "No.", "FA Class Code", "FA Subclass Code";
            column(AssetNumber; "No.") { IncludeCaption = true; }
            column(AssetDescription; Description) { IncludeCaption = true; }
            column(FixedAssetClassCode; "FA Class Code") { IncludeCaption = true; }
            column(FixedAssetSubclassCode; "FA Subclass Code") { IncludeCaption = true; }
            column(FixedAssetLocationCode; "FA Location Code") { IncludeCaption = true; }
            column(BudgetedAsset; "Budgeted Asset") { IncludeCaption = true; }
            column(AcquisitionDateField; AcquisitionDate) { }
            column(DisposalDateField; DisposalDate) { }
            column(GlobalDimension1Code; "Global Dimension 1 Code") { IncludeCaption = true; }
            column(GlobalDimension2Code; "Global Dimension 2 Code") { IncludeCaption = true; }
            dataitem(FAPostingType; "FA Posting Type")
            {
                DataItemTableView = where("FA Entry" = const(true));
                column(FixedAssetPostingTypeNumber; "FA Posting Type No.") { IncludeCaption = true; }
                column(FixedAssetPostingTypeName; "FA Posting Type Name") { IncludeCaption = true; }
                column(BeforeStartingDate; BeforeStartingDate) { }
                column(AtEndingDate; AtEndingDate) { }
                column(NetChange; NetChange) { }
                trigger OnAfterGetRecord()
                var
                    FADepreciationBook: Record "FA Depreciation Book";
                    FAGeneralReport: Codeunit "FA General Report";
                    BudgetDepreciation: Codeunit "Budget Depreciation";
                    BeforeAmount, EndingAmount : Decimal;
                begin
                    if ShouldSkipRecord() then
                        CurrReport.Skip();
                    FADepreciationBook.Get(FixedAssetData."No.", DepreciationBookCode);
                    AcquisitionDate := FADepreciationBook."Acquisition Date";
                    DisposalDate := FADepreciationBook."Disposal Date";
                    if BudgetReport then
                        BudgetDepreciation.Calculate(FixedAssetData."No.", StartingDate - 1, EndingDate, DepreciationBookCode, BeforeAmount, EndingAmount);

                    Period := Period::"Before Starting Date";
                    BeforeStartingDate := GetFixedAssetPostedAmount(BeforeAmount, EndingAmount);
                    BeforeStartingDate := FAGeneralReport.CalcFAPostedAmount(FixedAssetData."No.", FAPostingType."FA Posting Type No.", Period, StartingDate, EndingDate, DepreciationBookCode, BeforeAmount, EndingAmount, false, false);
                    Period := Period::"At Ending Date";
                    AtEndingDate := FAGeneralReport.CalcFAPostedAmount(FixedAssetData."No.", FAPostingType."FA Posting Type No.", Period, StartingDate, EndingDate, DepreciationBookCode, BeforeAmount, EndingAmount, false, false);
                    Period := Period::"Net Change";
                    NetChange := FAGeneralReport.CalcFAPostedAmount(FixedAssetData."No.", FAPostingType."FA Posting Type No.", Period, StartingDate, EndingDate, DepreciationBookCode, BeforeAmount, EndingAmount, false, false);
                end;
            }
        }
    }
    requestpage
    {
        SaveValues = true;
        AboutTitle = 'Fixed Asset Analysis Excel';
        AboutText = 'This report shows different fixed asset details in the given time periods, such as book value, depreciation, and acquisitions. You can specify the starting and ending dates for the report, and whether you want to include only sold assets or include inactive fixed assets.';
        layout
        {
            area(Content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(DepreciationBookCodeField; DepreciationBookCode)
                    {
                        ApplicationArea = All;
                        Caption = 'Depreciation Book';
                        TableRelation = "Depreciation Book";
                        ToolTip = 'Specifies the code for the depreciation book to be included in the report or batch job.';
                        ShowMandatory = true;
                    }
                    field(StartingDateField; StartingDate)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'Starting Date';
                        ToolTip = 'Specifies the date when you want the report to start.';
                        ShowMandatory = true;
                    }
                    field(EndingDateField; EndingDate)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'Ending Date';
                        ToolTip = 'Specifies the date when you want the report to end.';
                        ShowMandatory = true;
                    }
                    field(SalesReportField; SalesReport)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'Only Sold Assets';
                        ToolTip = 'Specifies if you want the report to show information only for sold fixed assets.';
                    }
                    field(BudgetReportField; BudgetReport)
                    {
                        ApplicationArea = Suite;
                        Caption = 'Budget Report';
                        ToolTip = 'Specifies if you want the report to consider future depreciation and book value.';
                    }
                    field(IncludeInactiveField; IncludeInactive)
                    {
                        ApplicationArea = All;
                        Caption = 'Include Inactive Fixed Assets';
                        ToolTip = 'Specifies if you want to include inactive fixed assets in the report.';
                    }
                }
            }
        }
        trigger OnOpenPage()
        var
            DepreciationBook: Record "Depreciation Book";
            FixedAssetPostingType: Record "FA Posting Type";
            FASetup: Record "FA Setup";
        begin
            EndingDate := WorkDate();
            StartingDate := CalcDate('<-1M>', EndingDate);
            if DepreciationBookCode = '' then begin
                if DepreciationBook.FindFirst() then
                    DepreciationBookCode := DepreciationBook.Code;
                if FASetup.Get() then
                    if FASetup."Default Depr. Book" <> '' then
                        DepreciationBookCode := FASetup."Default Depr. Book";
            end;
            FixedAssetPostingType.CreateTypes();
        end;
    }
    rendering
    {
        layout(FixedAssetAnalysisExcel)
        {
            Type = Excel;
            LayoutFile = './ReportLayouts/Excel/FixedAsset/FixedAssetAnalysisExcel.xlsx';
            Caption = 'Fixed Asset Analysis Excel';
            Summary = 'Built in layout for Fixed Asset Analysis.';
        }
    }
    labels
    {
        DataRetrieved = 'Data retrieved:';
        FixedAssetAnalysis = 'Fixed Asset Analysis';
        BeforeStartingDateLabel = 'Before Starting Date';
        AtEndingDateLabel = 'At Ending Date';
        NetChangeLabel = 'Net Change';
        DepreciationBook = 'Depreciation Book';
        Period = 'Period:';
        BookValue = 'Book Value';
        AcquisitionDateLabel = 'Acquisition Date';
        DisposalDateLabel = 'Disposal Date';
        BookValueAnalysis = 'Book Value Analysis';
        AcquisitionCostAfter = 'Acquisition Cost After';
        AcquisitionCostBefore = 'Acquisition Cost Before';
        AcquisitionCostNetChange = 'Addition in Period';
        ProceedsOnDisposalNetChange = 'Disposal in Period';
        DepreciationNetChange = 'Depreciation in Period';
        DepreciationAfter = 'Depreciation After';
        DepreciationBefore = 'Depreciation Before';
        BookValueAfter = 'Book Value After';
        BookValueBefore = 'Book Value Before';
    }

    trigger OnPreReport()
    var
        DepreciationBook: Record "Depreciation Book";
    begin
        DepreciationBook.Get(DepreciationBookCode);
        if (StartingDate = 0D) or (EndingDate = 0D) then
            Error(SpecifyStartingAndEndingDatesErr);
        if StartingDate > EndingDate then
            Error(SpecifyStartingAndEndingDatesErr);
    end;

    var
        DepreciationBookCode: Code[10];
        StartingDate, EndingDate, AcquisitionDate, DisposalDate : Date;
        BeforeStartingDate, AtEndingDate, NetChange : Decimal;
        Period: Option "Before Starting Date","Net Change","At Ending Date";
        SalesReport, BudgetReport, IncludeInactive : Boolean;
        SpecifyStartingAndEndingDatesErr: Label 'Please specify valid starting and ending dates.';

    local procedure ShouldSkipRecord(): Boolean
    var
        FADepreciationBook: Record "FA Depreciation Book";
    begin
        if not FADepreciationBook.Get(FixedAssetData."No.", DepreciationBookCode) then
            exit(true);
        if FixedAssetData.Inactive and (not IncludeInactive) then
            exit(true);
        if FADepreciationBook."Acquisition Date" = 0D then
            exit(true);
        if FADepreciationBook."Acquisition Date" > EndingDate then
            exit(true);
        if SalesReport and ((FADepreciationBook."Disposal Date" > EndingDate) or (FADepreciationBook."Disposal Date" < StartingDate)) then
            exit(true);
        if (not SalesReport) and (FADepreciationBook."Disposal Date" > 0D) and (FADepreciationBook."Disposal Date" < StartingDate) then
            exit(true);
        exit(false);
    end;

    local procedure GetFixedAssetPostedAmount(BeforeAmount: Decimal; EndingAmount: Decimal): Decimal
    var
        FADepreciationBook: Record "FA Depreciation Book";
        FAGeneralReport: Codeunit "FA General Report";
    begin
        if FAPostingType."FA Posting Type No." = FADepreciationBook.FieldNo("Proceeds on Disposal") then
            exit(0);
        FADepreciationBook.Get(FixedAssetData."No.", DepreciationBookCode);
        if not SalesReport and (Period = Period::"at Ending Date") and SoldBeforeEndingDate(FADepreciationBook."Disposal Date") then
            exit(0);
        exit(FAGeneralReport.CalcFAPostedAmount(FixedAssetData."No.", FAPostingType."FA Posting Type No.", Period, StartingDate, EndingDate, DepreciationBookCode, BeforeAmount, EndingAmount, false, false));
    end;

    local procedure SoldBeforeEndingDate(DisposalDate: Date): Boolean
    begin
        if DisposalDate = 0D then
            exit(false);
        exit(DisposalDate <= EndingDate);
    end;

}