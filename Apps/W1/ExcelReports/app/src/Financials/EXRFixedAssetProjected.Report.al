namespace Microsoft.Finance.ExcelReports;

using Microsoft.FixedAssets.FixedAsset;
using Microsoft.FixedAssets.Depreciation;
using Microsoft.FixedAssets.Setup;
using Microsoft.Foundation.Period;
using Microsoft.FixedAssets.Ledger;

report 4413 "EXR Fixed Asset Projected"
{
    ApplicationArea = All;
    AdditionalSearchTerms = 'FA Projected Value, FA Projected Value Excel';
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
            RequestFilterFields = "No.", "FA Class Code", "FA Subclass Code";
            PrintOnlyIfDetail = true;
            column(AssetNumber; "No.") { IncludeCaption = true; }
            column(AssetDescription; Description) { IncludeCaption = true; }
            column(FixedAssetClassCode; "FA Class Code") { IncludeCaption = true; }
            column(FixedAssetSubclassCode; "FA Subclass Code") { IncludeCaption = true; }
            column(FixedAssetLocationCode; "FA Location Code") { IncludeCaption = true; }
            column(GlobalDimension1Code; "Global Dimension 1 Code") { IncludeCaption = true; }
            column(GlobalDimension2Code; "Global Dimension 2 Code") { IncludeCaption = true; }
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
                Clear(GlobalFADepreciationBook);
                GlobalFADepreciationBook.SetAutoCalcFields("Book Value", "Custom 1");
                if not GlobalFADepreciationBook.Get(FixedAssetData."No.", GlobalDepreciationBook.Code) then;

                if ShouldFixedAssetBeSkipped(FixedAssetData) then
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
                    field(FirstDepreciationDateField; StartDateProjection)
                    {
                        ApplicationArea = All;
                        Caption = 'First Depreciation Date';
                        ToolTip = 'Specifies the date to be used as the first date in the period for which you want to calculate projected depreciation.';
                        ShowMandatory = true;
                    }
                    field(SecondDepreciationDateField; EndDateProjection)
                    {
                        ApplicationArea = All;
                        Caption = 'Last Depreciation Date';
                        ToolTip = 'Specifies the Fixed Asset posting date of the last posted depreciation.';
                        ShowMandatory = true;
                    }
                    field(PeriodLengthField; GlobalPeriodLength)
                    {
                        ApplicationArea = All;
                        BlankZero = true;
                        Caption = 'Number of Days';
                        MinValue = 0;
                        ToolTip = 'Specifies the length of the periods between the first depreciation date and the last depreciation date. The program then calculates depreciation for each period. If you leave this field blank, the program automatically sets the contents of this field to equal the number of days in a fiscal year, normally 360.';

                        trigger OnValidate()
                        begin
                            if GlobalPeriodLength > 0 then
                                GlobalUseAccountingPeriod := false;
                        end;
                    }
                    field(DaysInFirstPeriodField; GlobalDaysInFirstPeriod)
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
                    field(ProjectedDisposalField; GlobalProjectDisposal)
                    {
                        ApplicationArea = All;
                        Caption = 'Projected Disposal';
                        ToolTip = 'Specifies if you want the report to include projected disposals: the contents of the Projected Proceeds on Disposal field and the Projected Disposal Date field on the FA depreciation book.';
                    }
                    field(UseAccountingPeriodField; GlobalUseAccountingPeriod)
                    {
                        ApplicationArea = All;
                        Caption = 'Use Accounting Period';
                        ToolTip = 'Specifies if you want the periods between the starting date and the ending date to correspond to the accounting periods you have specified in the Accounting Period table. When you select this field, the Number of Days field is cleared.';

                        trigger OnValidate()
                        begin
                            if GlobalUseAccountingPeriod then
                                GlobalPeriodLength := 0;
                        end;
                    }
                }
            }
        }

        trigger OnOpenPage()
        var
            FASetup: Record "FA Setup";
        begin
            if not FASetup.Get() then
                exit;
            SelectedDepreciationBookCode := FASetup."Default Depr. Book";
        end;

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
    trigger OnPreReport()
    begin
        GlobalDepreciationBook.Get(SelectedDepreciationBookCode);
        if (StartDateProjection = 0D) or (EndDateProjection = 0D) then
            Error(SpecifyStartingAndEndingDatesErr);
        if StartDateProjection > EndDateProjection then
            Error(SpecifyStartingAndEndingDatesErr);
    end;

    var
        GlobalDepreciationBook: Record "Depreciation Book";
        GlobalFADepreciationBook: Record "FA Depreciation Book";
        CalculateDepreciation: Codeunit "Calculate Depreciation";
        DepreciationCalculation: Codeunit "Depreciation Calculation";
        FADateCalculation: Codeunit "FA Date Calculation";
        CalculateDisposal: Codeunit "Calculate Disposal";
        TableDeprCalculation: Codeunit "Table Depr. Calculation";
        ProjectionTok: Label 'PROJECTED', Locked = true;
        SelectedDepreciationBookCode: Code[10];
        StartDateProjection, EndDateProjection : Date;
        BookValue: Decimal;
        GlobalPeriodLength: Integer;
        GlobalDaysInFirstPeriod: Integer;
        IncludePostedFrom: Date;
        GlobalProjectDisposal: Boolean;
        GlobalUseAccountingPeriod: Boolean;
        ProjectedEntry: Boolean;
        FirstFixedAssetLedgerEntry: Boolean;
        ConfigureAccountingPeriodsErr: Label 'There is no accounting period configured after %1. These accounting periods are required when using a fiscal year of 365 days and the setting ''Use Accounting Periods'' is enabled.', Comment = '%1 is a date';
        SpecifyStartingAndEndingDatesErr: Label 'Please specify valid starting and ending dates.';
        PeriodLengthErr: Label 'The period length must be greater than %1 and at most %2.', Comment = '%1, %2 - number of days';

    local procedure ShouldFixedAssetBeSkipped(FixedAsset: Record "Fixed Asset"): Boolean
    begin
        if GlobalDepreciationBook.Code = '' then
            exit(true);
        if FixedAsset.Inactive then
            exit(true);
        if (GlobalFADepreciationBook."Acquisition Date" = 0D) or (GlobalFADepreciationBook."Acquisition Date" > EndDateProjection) then
            exit(true);
        if GlobalFADepreciationBook."Last Depreciation Date" > EndDateProjection then
            exit(true);
        exit(GlobalFADepreciationBook."Disposal Date" > 0D);
    end;

    local procedure InsertPostedAndProjectedEntries(FixedAssetNo: Code[20]; var TempFixedAssetLedgerEntry: Record "FA Ledger Entry" temporary)
    var
        ProjectionsStart, ProjectionsEnd : Date;
        LastPostingDateOfPostedEntries: Date;
        EndCurrentFiscalYear: Date;
        DaysInFiscalYear, PeriodLength : Integer;
        BiggestPostedEntryNo: Integer;
        ProjectDisposal: Boolean;
    begin
        DaysInFiscalYear := GetDaysInFiscalYear(GlobalDepreciationBook);
        if GlobalPeriodLength = 0 then
            PeriodLength := DaysInFiscalYear
        else
            PeriodLength := GlobalPeriodLength;
        if not IsPeriodLengthWithinLimits(PeriodLength, GlobalDepreciationBook) then
            Error(PeriodLengthErr, MinPeriodLength(), GetDaysInFiscalYear(GlobalDepreciationBook));

        ProjectDisposal := ShouldProjectDisposal(GlobalProjectDisposal, EndDateProjection, GlobalFADepreciationBook);
        ProjectionsStart := StartDateProjection;
        ProjectionsEnd := EndDateProjection;
        if ProjectDisposal then
            ProjectionsEnd := GlobalFADepreciationBook."Projected Disposal Date";
        if ProjectionsStart > ProjectionsEnd then
            ProjectionsStart := ProjectionsEnd;

        TempFixedAssetLedgerEntry.DeleteAll();
        BiggestPostedEntryNo := InsertPostedEntries(FixedAssetNo, IncludePostedFrom, SelectedDepreciationBookCode, TempFixedAssetLedgerEntry);
        TempFixedAssetLedgerEntry."Entry No." := BiggestPostedEntryNo;
        LastPostingDateOfPostedEntries := TempFixedAssetLedgerEntry."Posting Date";
        if ProjectionsStart < LastPostingDateOfPostedEntries then begin
            InitializeFiscalYearEndDate(GlobalDepreciationBook, ProjectionsStart, EndCurrentFiscalYear);
            ProjectionsStart := GetNextProjectionDate(LastPostingDateOfPostedEntries, GlobalUseAccountingPeriod, PeriodLength, EndCurrentFiscalYear, ProjectionsEnd, GlobalDepreciationBook, GlobalFADepreciationBook);
        end;
        InsertProjectedEntries(ProjectionsStart, ProjectionsEnd, GlobalDaysInFirstPeriod, PeriodLength, GlobalUseAccountingPeriod, ProjectDisposal, GlobalDepreciationBook, GlobalFADepreciationBook, TempFixedAssetLedgerEntry);
    end;

    local procedure ShouldProjectDisposal(ProjectDisposalSetting: Boolean; EndProjectionsDate: Date; FADepreciationBook: Record "FA Depreciation Book"): Boolean
    begin
        if not ProjectDisposalSetting then
            exit(false);
        if FADepreciationBook."Projected Disposal Date" = 0D then
            exit(false);
        exit(FADepreciationBook."Projected Disposal Date" <= EndProjectionsDate);
    end;

    local procedure CalculatedDepreciationIsZero(LastDepreciationAmount: Decimal; LastCustom1Amount: Decimal): Boolean
    begin
        exit((LastDepreciationAmount = 0) and (LastCustom1Amount = 0));
    end;

    local procedure InsertProjectedEntries(ProjectionsStart: Date; ProjectionsEnd: Date; DaysInFirstPeriod: Integer; PeriodLength: Integer; UseAccountingPeriods: Boolean; ProjectDisposal: Boolean; DepreciationBook: Record "Depreciation Book"; FADepreciationBook: Record "FA Depreciation Book"; var TempFixedAssetLedgerEntry: Record "FA Ledger Entry" temporary)
    var
        FixedAssetNo: Code[20];
        DepreciationBookCode: Code[10];
        ProjectionDate: Date;
        DepreciationAmount, Custom1Amount : Decimal;
        EntryAmounts: array[4] of Decimal;
        NumberOfDays, Custom1NumberOfDays, DaysInPeriod : Integer;
        PreviousProjectionDate: Date;
        DateFromProjection: Date;
        EndCurrentFiscalYear: Date;
        FiscalYear365Days: Boolean;
        ProjectingFromPostedValues: Boolean;
        AssetWasDepreciated: Boolean;
        LastProjectionInserted: Boolean;
    begin
        FixedAssetNo := FADepreciationBook."FA No.";
        DepreciationBookCode := FADepreciationBook."Depreciation Book Code";
        FiscalYear365Days := DepreciationBook."Fiscal Year 365 Days";
        DateFromProjection := 0D;
        ProjectionDate := ProjectionsStart;
        DaysInPeriod := DaysInFirstPeriod;
        ProjectingFromPostedValues := true;
        InitializeProjectionEntryAmounts(ProjectionsStart, DepreciationBook, FADepreciationBook, EntryAmounts);
        InitializeFiscalYearEndDate(DepreciationBook, ProjectionsStart, EndCurrentFiscalYear);
        while not LastProjectionInserted do begin
            if not ProjectingFromPostedValues then
                DateFromProjection := DepreciationCalculation.ToMorrow(PreviousProjectionDate, FiscalYear365Days);

            CalculateDepreciation.Calculate(DepreciationAmount, Custom1Amount, NumberOfDays, Custom1NumberOfDays, FixedAssetNo, DepreciationBookCode, ProjectionDate, EntryAmounts, DateFromProjection, DaysInPeriod);
            AssetWasDepreciated := HasAssetBeenDepreciated(ProjectingFromPostedValues, DepreciationAmount, Custom1Amount, DateFromProjection, ProjectionDate, FADepreciationBook);

            if ProjectingFromPostedValues and AssetWasDepreciated then begin
                ProjectingFromPostedValues := false;
                InitializeDepreciationInFiscalYear(ProjectionDate, FADepreciationBook, EntryAmounts);
                DaysInPeriod := 0;
            end;

            if ProjectionDate = EndCurrentFiscalYear then begin
                EntryAmounts[3] := 0;
                UpdateToNextFiscalYearEndDate(DepreciationBook, EndCurrentFiscalYear);
            end;

            if AssetWasDepreciated then begin
                AccumulateProjectionEntryAmounts(DepreciationAmount, Custom1Amount, EntryAmounts);
                if ProjectDisposal then
                    CalculateDisposal.CalcGainLoss(FixedAssetNo, DepreciationBookCode, EntryAmounts);
            end;

            InsertProjectedFixedAssetLedgerEntry(ProjectionDate, FixedAssetNo, DepreciationAmount, NumberOfDays, TempFixedAssetLedgerEntry);
            LastProjectionInserted := ProjectionDate >= ProjectionsEnd;

            PreviousProjectionDate := ProjectionDate;
            ProjectionDate := GetNextProjectionDate(ProjectionDate, UseAccountingPeriods, PeriodLength, EndCurrentFiscalYear, ProjectionsEnd, DepreciationBook, FADepreciationBook);
            PeriodLength := GetPeriodLengthBetweenNextProjections(PreviousProjectionDate, ProjectionDate, DepreciationBook);
        end;
    end;

    local procedure HasAssetBeenDepreciated(ProjectingFromPostedValues: Boolean; DepreciationAmount: Decimal; Custom1Amount: Decimal; LastDateFromProjection: Date; ProjectionDate: Date; FADepreciationBook: Record "FA Depreciation Book"): Boolean
    begin
        if ProjectingFromPostedValues then
            exit(not CalculatedDepreciationIsZero(DepreciationAmount, Custom1Amount));
        if not CalculatedDepreciationIsZero(DepreciationAmount, Custom1Amount) then
            exit(true);
        if FADepreciationBook."Depreciation Method" <> FADepreciationBook."Depreciation Method"::"User-Defined" then
            exit(false);
        exit(TableDeprCalculation.GetTablePercent(FADepreciationBook."Depreciation Book Code", FADepreciationBook."Depreciation Table Code", FADepreciationBook."First User-Defined Depr. Date", LastDateFromProjection, ProjectionDate) = 0)
    end;

    local procedure AccumulateProjectionEntryAmounts(DepreciationAmount: Decimal; Custom1Amount: Decimal; var EntryAmounts: array[4] of Decimal)
    begin
        EntryAmounts[1] += DepreciationAmount + Custom1Amount;
        EntryAmounts[2] += Custom1Amount;
        EntryAmounts[3] += DepreciationAmount + Custom1Amount;
    end;

    local procedure InitializeProjectionEntryAmounts(ProjectionsStart: Date; DepreciationBook: Record "Depreciation Book"; FADepreciationBook: Record "FA Depreciation Book"; var EntryAmounts: array[4] of Decimal)
    begin
        EntryAmounts[1] := FADepreciationBook."Book Value";
        EntryAmounts[2] := FADepreciationBook."Custom 1";
        InitializeDepreciationInFiscalYear(ProjectionsStart, FADepreciationBook, EntryAmounts);
        if DepreciationBook."Use Custom 1 Depreciation" then
            EntryAmounts[4] := GetDepreciationBasis(DepreciationBook, FADepreciationBook);
    end;

    local procedure InitializeDepreciationInFiscalYear(ReferenceDate: Date; FADepreciationBook: Record "FA Depreciation Book"; var EntryAmounts: array[4] of Decimal)
    begin
        EntryAmounts[3] := DepreciationCalculation.DeprInFiscalYear(FADepreciationBook."FA No.", FADepreciationBook."Depreciation Book Code", ReferenceDate);
    end;

    local procedure GetDepreciationBasis(DepreciationBook: Record "Depreciation Book"; FADepreciationBook: Record "FA Depreciation Book"): Decimal
    var
        FALedgerEntry: Record "FA Ledger Entry";
    begin
        FALedgerEntry.ReadIsolation := IsolationLevel::ReadUncommitted;
        FALedgerEntry.SetCurrentKey("FA No.", "Depreciation Book Code", "Part of Book Value", "FA Posting Date");
        FALedgerEntry.SetRange("FA No.", FADepreciationBook."FA No.");
        FALedgerEntry.SetRange("Depreciation Book Code", DepreciationBook.Code);
        FALedgerEntry.SetRange("Part of Book Value", true);
        FALedgerEntry.SetRange("FA Posting Date", 0D, FADepreciationBook."Depr. Ending Date (Custom 1)");
        FALedgerEntry.CalcSums(Amount);
        exit(FALedgerEntry.Amount);
    end;

    local procedure InsertProjectedFixedAssetLedgerEntry(PostingDate: Date; FixedAssetNo: Code[20]; Amount: Decimal; NumberOfDepreciationDays: Integer; var TempFixedAssetLedgerEntry: Record "FA Ledger Entry" temporary)
    begin
        TempFixedAssetLedgerEntry."FA No." := FixedAssetNo;
        TempFixedAssetLedgerEntry."FA Posting Date" := PostingDate;
        TempFixedAssetLedgerEntry."FA Posting Type" := TempFixedAssetLedgerEntry."FA Posting Type"::Depreciation;
        TempFixedAssetLedgerEntry.Amount := Amount;
        TempFixedAssetLedgerEntry."No. of Depreciation Days" := NumberOfDepreciationDays;
        TempFixedAssetLedgerEntry."Entry No." += 1;
        TempFixedAssetLedgerEntry."Reason Code" := ProjectionTok;
        TempFixedAssetLedgerEntry.Insert();
    end;

    local procedure GetNextProjectionDate(Previous: Date; UseAccountingPeriods: Boolean; PeriodLength: Integer; EndCurrentFiscalYear: Date; ProjectionsEnd: Date; DepreciationBook: Record "Depreciation Book"; FADepreciationBook: Record "FA Depreciation Book"): Date
    var
        Next: Date;
        FiscalYear365Days: Boolean;
    begin
        FiscalYear365Days := DepreciationBook."Fiscal Year 365 Days";

        if UseAccountingPeriods then
            Next := GetNextProjectionDateFromAccountingPeriods(Previous, PeriodLength, FiscalYear365Days)
        else
            Next := GetNextProjectionDateAsNextPeriod(Previous, PeriodLength, FiscalYear365Days);
        if ShouldNextProjectionDateBeCustomDepreciationDate(Previous, Next, DepreciationBook, FADepreciationBook) then
            Next := FADepreciationBook."Depr. Ending Date (Custom 1)";
        if PeriodIncludesDate(Previous, Next, FADepreciationBook."Temp. Ending Date") then
            Next := FADepreciationBook."Temp. Ending Date";
        if PeriodIncludesDate(Previous, Next, EndCurrentFiscalYear) then
            Next := EndCurrentFiscalYear;
        if Next > ProjectionsEnd then
            Next := ProjectionsEnd;
        exit(Next);
    end;

    local procedure GetNextProjectionDateFromAccountingPeriods(Previous: Date; PeriodLength: Integer; FiscalYear365Days: Boolean): Date
    var
        AccountingPeriod: Record "Accounting Period";
        NextAccountingPeriodMinDate: Date;
    begin
        NextAccountingPeriodMinDate := DepreciationCalculation.ToMorrow(Previous, FiscalYear365Days) + 1;
        AccountingPeriod.SetFilter("Starting Date", '>= %1', NextAccountingPeriodMinDate);
        if not AccountingPeriod.FindFirst() then begin
            if FiscalYear365Days then
                Error(ConfigureAccountingPeriodsErr, NextAccountingPeriodMinDate);
            exit(GetNextProjectionDateAsNextPeriod(Previous, PeriodLength, FiscalYear365Days));
        end;
        if Date2DMY(AccountingPeriod."Starting Date", 1) <> 31 then
            exit(DepreciationCalculation.Yesterday(AccountingPeriod."Starting Date", FiscalYear365Days));
        exit(AccountingPeriod."Starting Date" - 1);
    end;

    local procedure GetNextProjectionDateAsNextPeriod(Previous: Date; PeriodLength: Integer; FiscalYear365Days: Boolean): Date
    begin
        exit(FADateCalculation.CalculateDate(Previous, PeriodLength, FiscalYear365Days));
    end;

    local procedure GetPeriodLengthBetweenNextProjections(Previous: Date; Next: Date; DepreciationBook: Record "Depreciation Book"): Integer
    var
        DayAfterPrevious: Date;
        FiscalYear365Days: Boolean;
        DepreciationDaysBetween: Integer;
    begin
        FiscalYear365Days := DepreciationBook."Fiscal Year 365 Days";
        DayAfterPrevious := DepreciationCalculation.ToMorrow(Previous, FiscalYear365Days);
        DepreciationDaysBetween := DepreciationCalculation.DeprDays(DayAfterPrevious, Next, FiscalYear365Days);
        if IsPeriodLengthWithinLimits(DepreciationDaysBetween, DepreciationBook) then
            exit(DepreciationDaysBetween);
        exit(GetDaysInFiscalYear(DepreciationBook));
    end;

    local procedure InitializeFiscalYearEndDate(DepreciationBook: Record "Depreciation Book"; ReferenceDate: Date; var EndFiscalYear: Date)
    var
        StartFiscalYear: Date;
        DaysInFiscalYear: Integer;
        FiscalYear365Days: Boolean;
    begin
        FiscalYear365Days := DepreciationBook."Fiscal Year 365 Days";
        DaysInFiscalYear := GetDaysInFiscalYear(DepreciationBook);
        StartFiscalYear := FADateCalculation.GetFiscalYear(DepreciationBook.Code, ReferenceDate);
        EndFiscalYear := FADateCalculation.CalculateDate(DepreciationCalculation.Yesterday(StartFiscalYear, FiscalYear365Days), DaysInFiscalYear, FiscalYear365Days);
    end;

    local procedure UpdateToNextFiscalYearEndDate(DepreciationBook: Record "Depreciation Book"; var EndFiscalYear: Date)
    var
        DaysInFiscalYear: Integer;
        FiscalYear365Days: Boolean;
    begin
        FiscalYear365Days := DepreciationBook."Fiscal Year 365 Days";
        DaysInFiscalYear := GetDaysInFiscalYear(DepreciationBook);
        EndFiscalYear := FADateCalculation.CalculateDate(EndFiscalYear, DaysInFiscalYear, FiscalYear365Days);
    end;

    local procedure GetDaysInFiscalYear(DepreciationBook: Record "Depreciation Book"): Integer
    begin
        if DepreciationBook."No. of Days in Fiscal Year" > 0 then
            exit(DepreciationBook."No. of Days in Fiscal Year");
        if DepreciationBook."Fiscal Year 365 Days" then
            exit(365);
        exit(360);
    end;

    local procedure ShouldNextProjectionDateBeCustomDepreciationDate(Previous: Date; Next: Date; DepreciationBook: Record "Depreciation Book"; FADepreciationBook: Record "FA Depreciation Book"): Boolean
    begin
        if not DepreciationBook."Use Custom 1 Depreciation" then
            exit(false);
        exit(PeriodIncludesDate(Previous, Next, FADepreciationBook."Depr. Ending Date (Custom 1)"));
    end;

    local procedure PeriodIncludesDate(PeriodStart: Date; PeriodEnd: Date; DateToCheck: Date): Boolean
    begin
        exit((PeriodStart < DateToCheck) and (PeriodEnd > DateToCheck));
    end;

    local procedure IsPeriodLengthWithinLimits(PeriodLength: Integer; DepreciationBook: Record "Depreciation Book"): Boolean
    begin
        exit((PeriodLength > MinPeriodLength()) and (PeriodLength <= GetDaysInFiscalYear(DepreciationBook)));
    end;

    local procedure MinPeriodLength(): Integer
    begin
        exit(5);
    end;

    local procedure InsertPostedEntries(FixedAssetNo: Code[20]; MinFAPostingDate: Date; FixedAssetDepreciationBookCode: Code[10]; var TempFixedAssetLedgerEntry: Record "FA Ledger Entry" temporary): Integer
    var
        FixedAssetLedgerEntry: Record "FA Ledger Entry";
        BiggestEntryNo: Integer;
    begin
        BiggestEntryNo := 0;
        if MinFAPostingDate = 0D then
            exit(BiggestEntryNo);
        FixedAssetLedgerEntry.SetCurrentKey("FA No.", "Depreciation Book Code", "Posting Date");
        FixedAssetLedgerEntry.SetAscending("Posting Date", true);
        FixedAssetLedgerEntry.SetRange("FA No.", FixedAssetNo);
        FixedAssetLedgerEntry.SetRange("Depreciation Book Code", FixedAssetDepreciationBookCode);
        FixedAssetLedgerEntry.SetFilter("FA Posting Date", '>=%1', MinFAPostingDate);
        if FixedAssetLedgerEntry.IsEmpty() then
            exit(BiggestEntryNo);
        FixedAssetLedgerEntry.FindSet();
        repeat
            TempFixedAssetLedgerEntry.Copy(FixedAssetLedgerEntry);
            Clear(TempFixedAssetLedgerEntry."Reason Code");
            TempFixedAssetLedgerEntry.Insert();
            if BiggestEntryNo < TempFixedAssetLedgerEntry."Entry No." then
                BiggestEntryNo := TempFixedAssetLedgerEntry."Entry No.";
        until FixedAssetLedgerEntry.Next() = 0;
        exit(BiggestEntryNo);
    end;

}