namespace Microsoft.Finance.ExcelReports;

using Microsoft.FixedAssets.FixedAsset;
using Microsoft.FixedAssets.Depreciation;
using Microsoft.Foundation.Period;
using Microsoft.FixedAssets.Ledger;

report 4413 "EXR Fixed Asset Projected"
{
    ApplicationArea = All;
    Caption = 'Fixed Asset Projected Value Excel (Preview)';
    DataAccessIntent = ReadOnly;
    DefaultRenderingLayout = FixedAssetProjectedValueExcel;
    ExcelLayoutMultipleDataSheets = true;
    PreviewMode = PrintLayout;
    UsageCategory = ReportsAndAnalysis;
    MaximumDatasetSize = 1000000;
    dataset
    {
        dataitem(FixedAssetData; "Fixed Asset")
        {
            DataItemTableView = sorting("No.");
            PrintOnlyIfDetail = true;
            column(AssetNumber; "No.") { IncludeCaption = true; }
            column(AssetDescription; Description) { IncludeCaption = true; }
            column(FixedAssetClassCode; "FA Class Code") { IncludeCaption = true; }
            column(FixedAssetSubclassCode; "FA Subclass Code") { IncludeCaption = true; }
            column(FixedAssetLocationCode; "FA Location Code") { IncludeCaption = true; }
            dataitem(FixedAssetLedgerEntries; "FA Ledger Entry")
            {
                DataItemLink = "FA No." = field("No.");
                UseTemporary = true;
                column(FixedAssetPostingDate; "FA Posting Date") { IncludeCaption = true; }
                column(FixedAssetPostingType; "FA Posting Type") { IncludeCaption = true; }
                column(Amount; Amount) { IncludeCaption = true; }
                column(BookValue; BookValue) { }
                column(ProjectedEntry; ProjectedEntry) { }
                column(NumberOfDepreciationDays; "No. of Depreciation Days") { IncludeCaption = true; }

                trigger OnAfterGetRecord()
                var
                    FADepreciationBook: Record "FA Depreciation Book";
                begin
                    ProjectedEntry := FixedAssetLedgerEntries."Reason Code" = ProjectionTok;

                    if FirstFixedAssetLedgerEntry then begin
                        FADepreciationBook.SetFilter("FA Posting Date Filter", '<%1', FixedAssetLedgerEntries."FA Posting Date");
                        FADepreciationBook.SetAutoCalcFields("Book Value");
                        FADepreciationBook.Get(FixedAssetData."No.", SelectedDepreciationBookCode);
                        BookValue := FADepreciationBook."Book Value";
                    end;
                    FirstFixedAssetLedgerEntry := false;
                    BookValue += FixedAssetLedgerEntries.Amount;
                end;
            }
            trigger OnAfterGetRecord()
            begin
                if FixedAssetData.Inactive or FixedAssetData.Blocked then
                    CurrReport.Skip();
                InsertPostedAndProjectedEntries(FixedAssetData."No.", FixedAssetLedgerEntries);
                FirstFixedAssetLedgerEntry := true;
            end;
        }
    }
    requestpage
    {
        SaveValues = true;
        AboutTitle = 'Fixed Asset Projected Value Excel';
        AboutText = 'This report shows how Fixed Asset Ledger entries would look if depreciated in the given dates.';
        layout
        {
            area(Content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(DepreciationBookCodeField; SelectedDepreciationBookCode)
                    {
                        ApplicationArea = All;
                        Caption = 'Depreciation Book';
                        TableRelation = "Depreciation Book";
                        ToolTip = 'Specifies the code for the depreciation book to be included in the report or batch job.';
                        ShowMandatory = true;
                    }
                    field(FirstDepreciationDateField; FirstDepreciationDate)
                    {
                        ApplicationArea = All;
                        Caption = 'First Depreciation Date';
                        ToolTip = 'Specifies the date to be used as the first date in the period for which you want to calculate projected depreciation.';
                        ShowMandatory = true;
                    }
                    field(SecondDepreciationDateField; SecondDepreciationDate)
                    {
                        ApplicationArea = All;
                        Caption = 'Second Depreciation Date';
                        ToolTip = 'Specifies the Fixed Asset posting date of the last posted depreciation.';
                        ShowMandatory = true;
                    }
                    field(PeriodLengthField; PeriodLength)
                    {
                        ApplicationArea = FixedAssets;
                        BlankZero = true;
                        Caption = 'Number of Days';
                        MinValue = 0;
                        ToolTip = 'Specifies the length of the periods between the first depreciation date and the last depreciation date. The program then calculates depreciation for each period. If you leave this field blank, the program automatically sets the contents of this field to equal the number of days in a fiscal year, normally 360.';

                        trigger OnValidate()
                        begin
                            if PeriodLength > 0 then
                                UseAccountingPeriod := false;
                        end;
                    }
                    field(DaysInFirstPeriodField; DaysInFirstPeriod)
                    {
                        ApplicationArea = All;
                        BlankZero = true;
                        Caption = 'No. of Days in First Period';
                        MinValue = 0;
                        ToolTip = 'Specifies the number of days that must be used for calculating the depreciation as of the first depreciation date, regardless of the actual number of days from the last depreciation entry. The number you enter in this field does not affect the total number of days from the starting date to the ending date.';
                    }
                    field(IncludePostedFromField; IncludePostedFrom)
                    {
                        ApplicationArea = All;
                        Caption = 'Posted Entries From';
                        ToolTip = 'Specifies the fixed asset posting date from which the report includes all types of posted entries.';
                    }
                    field(ProjectedDisposalField; ProjectedDisposal)
                    {
                        ApplicationArea = All;
                        Caption = 'Projected Disposal';
                        ToolTip = 'Specifies if you want the report to include projected disposals: the contents of the Projected Proceeds on Disposal field and the Projected Disposal Date field on the FA depreciation book.';
                    }
                    field(UseAccountingPeriodField; UseAccountingPeriod)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'Use Accounting Period';
                        ToolTip = 'Specifies if you want the periods between the starting date and the ending date to correspond to the accounting periods you have specified in the Accounting Period table. When you select this field, the Number of Days field is cleared.';
                    }
                }
            }
        }
    }
    rendering
    {
        layout(FixedAssetProjectedValueExcel)
        {
            Type = Excel;
            LayoutFile = './ReportLayouts/Excel/FixedAsset/FixedAssetProjectedValueExcel.xlsx';
            Caption = 'Fixed Asset Projected Value Excel';
            Summary = 'Built in layout for Fixed Asset Projected Value.';
        }
    }
    labels
    {
        DataRetrieved = 'Data retrieved:';
        FixedAssetProjectedValue = 'Fixed Asset Projected Value';
        ProjectedValue = 'Projected Value';
        BookValueCaption = 'Book Value';
        ProjectedEntryCaption = 'Projected entry';
    }

    local procedure InsertPostedAndProjectedEntries(FixedAssetNo: Code[20]; var TempFixedAssetLedgerEntry: Record "FA Ledger Entry" temporary)
    var
        TempProjectedDepreciationDates: Record "Accounting Period" temporary;
    begin
        TempFixedAssetLedgerEntry.DeleteAll();
        InsertPostedEntries(FixedAssetNo, IncludePostedFrom, SelectedDepreciationBookCode, TempFixedAssetLedgerEntry);
        TempProjectedDepreciationDates."Starting Date" := FirstDepreciationDate;
        TempProjectedDepreciationDates.Insert();

        if UseAccountingPeriod then
            InsertDatesForAccountingPeriods(TempProjectedDepreciationDates, FirstDepreciationDate, SecondDepreciationDate);

        TempProjectedDepreciationDates."Starting Date" := SecondDepreciationDate;
        TempProjectedDepreciationDates.Insert();

        InsertProjectedEntries(FixedAssetNo, SelectedDepreciationBookCode, TempProjectedDepreciationDates, TempFixedAssetLedgerEntry);
    end;

    local procedure InsertProjectedEntries(FixedAssetNo: Code[20]; DepreciationBookCode: Code[10]; var TempProjectedDepreciationDates: Record "Accounting Period" temporary; var TempFixedAssetLedgerEntry: Record "FA Ledger Entry" temporary)
    var
        DepreciationBook: Record "Depreciation Book";
        FADepreciationBook: Record "FA Depreciation Book";
        CalculateDepreciation: Codeunit "Calculate Depreciation";
        DepreciationCalculation: Codeunit "Depreciation Calculation";
        DateFromProjection: Date;
        DepreciationAmount, Custom1Amount : Decimal;
        NumberOfDays, Custom1NumberOfDays, DaysInPeriod : Integer;
        EntryAmounts: array[4] of Decimal;
        First: Boolean;
    begin
        if TempProjectedDepreciationDates.IsEmpty() then
            exit;

        FADepreciationBook.SetAutoCalcFields("Book Value", "Custom 1");
        FADepreciationBook.Get(FixedAssetNo, DepreciationBookCode);
        DepreciationBook.Get(DepreciationBookCode);
        EntryAmounts[1] := FADepreciationBook."Book Value";
        EntryAmounts[2] := FADepreciationBook."Custom 1";
        EntryAmounts[3] := DepreciationCalculation.DeprInFiscalYear(FixedAssetNo, DepreciationBookCode, FirstDepreciationDate);
        DateFromProjection := 0D;
        First := true;
        TempProjectedDepreciationDates.FindSet();
        repeat
            CalculateDepreciation.Calculate(DepreciationAmount, Custom1Amount, NumberOfDays, Custom1NumberOfDays, FixedAssetNo, DepreciationBookCode, TempProjectedDepreciationDates."Starting Date", EntryAmounts, DateFromProjection, DaysInPeriod);
            DateFromProjection := DepreciationCalculation.ToMorrow(TempProjectedDepreciationDates."Starting Date", DepreciationBook."Fiscal Year 365 Days");
            EntryAmounts[1] += DepreciationAmount + Custom1Amount;
            EntryAmounts[2] += Custom1Amount;
            EntryAmounts[3] += DepreciationAmount + Custom1Amount;
            if First then begin
                EntryAmounts[3] := DepreciationCalculation.DeprInFiscalYear(FixedAssetNo, DepreciationBookCode, TempProjectedDepreciationDates."Starting Date");
                First := false;
            end;
            TempFixedAssetLedgerEntry."FA No." := FixedAssetNo;
            TempFixedAssetLedgerEntry."FA Posting Date" := TempProjectedDepreciationDates."Starting Date";
            TempFixedAssetLedgerEntry."FA Posting Type" := TempFixedAssetLedgerEntry."FA Posting Type"::Depreciation;
            TempFixedAssetLedgerEntry.Amount := DepreciationAmount;
            TempFixedAssetLedgerEntry."No. of Depreciation Days" := NumberOfDays;
            TempFixedAssetLedgerEntry."Entry No." += 1;
            TempFixedAssetLedgerEntry."Reason Code" := ProjectionTok;
            TempFixedAssetLedgerEntry.Insert();
        until TempProjectedDepreciationDates.Next() = 0;
    end;

    local procedure InsertDatesForAccountingPeriods(var TempProjectedDepreciationDates: Record "Accounting Period" temporary; FromDate: Date; ToDate: Date)
    var
        AccountingPeriod: Record "Accounting Period";
    begin
        AccountingPeriod.SetRange("Starting Date", FromDate + 2, ToDate);
        if AccountingPeriod.IsEmpty() then
            exit;
        AccountingPeriod.FindSet();
        repeat
            TempProjectedDepreciationDates."Starting Date" := AccountingPeriod."Starting Date" - 1;
            TempProjectedDepreciationDates.Insert();
        until AccountingPeriod.Next() = 0;
    end;

    local procedure InsertPostedEntries(FixedAssetNo: Code[20]; MinFAPostingDate: Date; FixedAssetDepreciationBookCode: Code[10]; var TempFixedAssetLedgerEntry: Record "FA Ledger Entry" temporary)
    var
        FixedAssetLedgerEntry: Record "FA Ledger Entry";
    begin
        if MinFAPostingDate = 0D then
            exit;
        FixedAssetLedgerEntry.SetRange("FA No.", FixedAssetNo);
        FixedAssetLedgerEntry.SetRange("Depreciation Book Code", FixedAssetDepreciationBookCode);
        FixedAssetLedgerEntry.SetFilter("FA Posting Date", '>=%1', MinFAPostingDate);
        if FixedAssetLedgerEntry.IsEmpty() then
            exit;
        FixedAssetLedgerEntry.FindSet();
        repeat
            TempFixedAssetLedgerEntry.Copy(FixedAssetLedgerEntry);
            Clear(TempFixedAssetLedgerEntry."Reason Code");
            TempFixedAssetLedgerEntry.Insert();
        until FixedAssetLedgerEntry.Next() = 0;
    end;

    trigger OnPreReport()
    var
        DepreciationBook: Record "Depreciation Book";
    begin
        DepreciationBook.Get(SelectedDepreciationBookCode);
        if (FirstDepreciationDate = 0D) or (SecondDepreciationDate = 0D) then
            Error(SpecifyStartingAndEndingDatesErr);
        if FirstDepreciationDate > SecondDepreciationDate then
            Error(SpecifyStartingAndEndingDatesErr);
    end;

    var
        ProjectionTok: Label 'PROJECTED', Locked = true;
        SelectedDepreciationBookCode: Code[10];
        FirstDepreciationDate, SecondDepreciationDate : Date;
        BookValue: Decimal;
        PeriodLength: Integer;
        DaysInFirstPeriod: Integer;
        IncludePostedFrom: Date;
        ProjectedDisposal: Boolean;
        UseAccountingPeriod: Boolean;
        ProjectedEntry: Boolean;
        FirstFixedAssetLedgerEntry: Boolean;
        SpecifyStartingAndEndingDatesErr: Label 'Please specify valid starting and ending dates.';
}