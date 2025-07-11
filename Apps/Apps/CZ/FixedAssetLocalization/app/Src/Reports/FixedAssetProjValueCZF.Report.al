// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.FixedAssets;

using Microsoft.Finance.GeneralLedger.Budget;
using Microsoft.FixedAssets.Depreciation;
using Microsoft.FixedAssets.FixedAsset;
using Microsoft.FixedAssets.Ledger;
using Microsoft.FixedAssets.Setup;
using Microsoft.Foundation.Period;
using System.Utilities;

report 31248 "Fixed Asset - Proj. Value CZF"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Src/Reports/FixedAssetProjValue.rdl';
    ApplicationArea = FixedAssets;
    Caption = 'Fixed Asset Projected Value';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem("Fixed Asset"; "Fixed Asset")
        {
            DataItemTableView = sorting("No.");
            RequestFilterFields = "No.", "FA Class Code", "FA Subclass Code", "Budgeted Asset";
            column(CompanyName; CompanyProperty.DisplayName())
            {
            }
            column(DeprBookText; DeprBookText)
            {
            }
            column(ReportFilter; GetFilters())
            {
            }
            column(PrintDetails; PrintDetails)
            {
            }
            column(ProjectedDisposal; ProjectedDisposal)
            {
            }
            column(DeprBookUseCustom1Depr; DepreciationBook."Use Custom 1 Depreciation")
            {
            }
            column(DoProjectedDisposal; DoProjectedDisposal)
            {
            }
            column(GroupTotalsInt; GroupTotalsInt)
            {
            }
            column(IncludePostedFrom; Format(IncludePostedFrom))
            {
            }
            column(GroupCodeName; GroupCodeName)
            {
            }
            column(FANoCaption; FANoCaption)
            {
            }
            column(FADescriptionCaption; FADescriptionCaption)
            {
            }
            column(GroupHeadLine; GroupHeadLine)
            {
            }
            column(DeprText2; DeprText2)
            {
            }
            column(GroupFooterLine; GroupHeadLine + ' ' + GroupTotalTxt)
            {
            }
            column(Custom1Text; Custom1Text)
            {
            }
            column(DeprCustom1Text; DeprCustom1Text)
            {
            }
            column(SalesPriceCaption; SalesPriceCaption)
            {
            }
            column(GainLossCaption; GainLossCaption)
            {
            }
            column(GroupAmounts3; GroupAmounts[3])
            {
                AutoFormatType = 1;
            }
            column(GroupAmounts4; GroupAmounts[4])
            {
                AutoFormatType = 1;
            }
            column(FixedAsset_No; "No.")
            {
            }
            column(FixedAsset_Description; Description)
            {
            }
            column(FixedAsset_FAClassCode; "FA Class Code")
            {
            }
            column(FixedAsset_FASubclassCode; "FA Subclass Code")
            {
            }
            column(FixedAsset_GlobalDim1Code; "Global Dimension 1 Code")
            {
            }
            column(FixedAsset_GlobalDim2Code; "Global Dimension 2 Code")
            {
            }
            column(FixedAsset_FALocationCode; "FA Location Code")
            {
            }
            column(FixedAsset_ComponentOfMainAsset; "Component of Main Asset")
            {
            }
            column(FixedAsset_FAPostingGroup; "FA Posting Group")
            {
            }
            column(FixedAsset_TaxDepreciationGroupCode; "Tax Deprec. Group Code CZF")
            {
            }
            dataitem("FA Ledger Entry"; "FA Ledger Entry")
            {
                DataItemTableView = sorting("FA No.", "Depreciation Book Code", "FA Posting Date");
                column(FALedgerEntry_FAPostingDate; "FA Posting Date")
                {
                    IncludeCaption = true;
                }
                column(FALedgerEntry_FAPostingType; "FA Posting Type")
                {
                    IncludeCaption = true;
                }
                column(FALedgerEntry_Amount; Amount)
                {
                    IncludeCaption = true;
                }
                column(BookValue; BookValue)
                {
                    AutoFormatType = 1;
                }
                column(FALedgerEntry_NoOfDepreciationDays; "No. of Depreciation Days")
                {
                    IncludeCaption = true;
                }
                column(FALedgerEntry_EntryNo; "Entry No.")
                {
                }

                trigger OnAfterGetRecord()
                begin
                    if "Part of Book Value" then
                        BookValue := BookValue + Amount;
                    if "FA Posting Date" < IncludePostedFrom then
                        CurrReport.Skip();
                    EntryPrinted := true;
                end;

                trigger OnPreDataItem()
                begin
                    SetRange("FA No.", "Fixed Asset"."No.");
                    SetRange("Depreciation Book Code", DeprBookCode);
                    BookValue := 0;
                    if (IncludePostedFrom = 0D) or not PrintDetails then
                        CurrReport.Break();
                end;
            }
            dataitem(ProjectedDepreciation; "Integer")
            {
                DataItemTableView = sorting(Number) where(Number = filter(1 .. 1000000));
                column(DeprAmount; DeprAmount)
                {
                    AutoFormatType = 1;
                }
                column(EntryAmt1Custom1Amt; EntryAmounts[1] - Custom1Amount)
                {
                    AutoFormatType = 1;
                }
                column(FormatUntilDate; Format(UntilDate))
                {
                }
                column(DeprText; DeprText)
                {
                }
                column(NumberOfDays; NumberOfDays)
                {
                }
                column(Custom1Text_ProjectedDepr; Custom1Text)
                {
                }
                column(Custom1NumberOfDays; Custom1NumberOfDays)
                {
                }
                column(Custom1Amount; Custom1Amount)
                {
                    AutoFormatType = 1;
                }
                column(EntryAmounts1; EntryAmounts[1])
                {
                    AutoFormatType = 1;
                }
                column(AssetAmounts1; AssetAmounts[1])
                {
                    AutoFormatType = 1;
                }
                column(Description1_FixedAsset; "Fixed Asset".Description)
                {
                }
                column(AssetAmounts2; AssetAmounts[2])
                {
                    AutoFormatType = 1;
                }
                column(AssetAmt1AssetAmt2; AssetAmounts[1] + AssetAmounts[2])
                {
                    AutoFormatType = 1;
                }
                column(DeprCustom1Text_ProjectedDepr; DeprCustom1Text)
                {
                }
                column(AssetAmounts3; AssetAmounts[3])
                {
                    AutoFormatType = 1;
                }
                column(AssetAmounts4; AssetAmounts[4])
                {
                    AutoFormatType = 1;
                }
                column(SalesPriceCaption_ProjectedDepr; SalesPriceCaption)
                {
                }
                column(GainLossCaption_ProjectedDepr; GainLossCaption)
                {
                }
                column(GroupAmounts_1; GroupAmounts[1])
                {
                }
                column(GroupTotalBookValue; GroupTotalBookValue)
                {
                }
                column(TotalBookValue_1; TotalBookValue[1])
                {
                }

                trigger OnAfterGetRecord()
                begin
                    if UntilDate >= EndingDate then
                        CurrReport.Break();
                    if Number = 1 then begin
                        CalculateFirstDeprAmount();
                        if FADepreciationBook."Book Value" <> 0 then
                            Done := Done or not EntryPrinted;
                    end else
                        CalculateSecondDeprAmount();
                    if Done then
                        UpdateTotals()
                    else
                        UpdateGroupTotals();

                    if Done then
                        if DoProjectedDisposal then
                            CalculateGainLoss();
                end;

                trigger OnPostDataItem()
                begin
                    if DoProjectedDisposal then begin
                        TotalAmounts[3] += AssetAmounts[3];
                        TotalAmounts[4] += AssetAmounts[4];
                    end;
                end;
            }

            trigger OnAfterGetRecord()
            begin
                case GroupTotals of
                    GroupTotals::"FA Class":
                        NewValue := "FA Class Code";
                    GroupTotals::"FA Subclass":
                        NewValue := "FA Subclass Code";
                    GroupTotals::"FA Location":
                        NewValue := "FA Location Code";
                    GroupTotals::"Main Asset":
                        NewValue := "Component of Main Asset";
                    GroupTotals::"Global Dimension 1":
                        NewValue := "Global Dimension 1 Code";
                    GroupTotals::"Global Dimension 2":
                        NewValue := "Global Dimension 2 Code";
                    GroupTotals::"FA Posting Group":
                        NewValue := "FA Posting Group";
                    GroupTotals::"Tax Depreciation Group":
                        NewValue := "Tax Deprec. Group Code CZF";
                end;

                if NewValue <> OldValue then begin
                    MakeGroupHeadLine();
                    InitGroupTotals();
                    OldValue := NewValue;
                end;

                if not FADepreciationBook.Get("No.", DeprBookCode) then
                    CurrReport.Skip();
                if SkipRecord() then
                    CurrReport.Skip();

                if GroupTotals = GroupTotals::"FA Posting Group" then
                    if "FA Posting Group" <> FADepreciationBook."FA Posting Group" then
                        Error(HasBeenModifiedInFAErr, FieldCaption("FA Posting Group"), "No.");
                if GroupTotals = GroupTotals::"Tax Depreciation Group" then
                    if "Tax Deprec. Group Code CZF" <> FADepreciationBook."Tax Deprec. Group Code CZF" then
                        Error(HasBeenModifiedInFAErr, FieldCaption("Tax Deprec. Group Code CZF"), "No.");

                StartingDate := StartingDate2;
                EndingDate := EndingDate2;
                DoProjectedDisposal := false;
                EntryPrinted := false;
                if ProjectedDisposal and
                   (FADepreciationBook."Projected Disposal Date" > 0D) and
                   (FADepreciationBook."Projected Disposal Date" <= EndingDate)
                then begin
                    EndingDate := FADepreciationBook."Projected Disposal Date";
                    if StartingDate > EndingDate then
                        StartingDate := EndingDate;
                    DoProjectedDisposal := true;
                end;

                TransferValues();
            end;

            trigger OnPreDataItem()
            begin
                case GroupTotals of
                    GroupTotals::"FA Class":
                        SetCurrentKey("FA Class Code");
                    GroupTotals::"FA Subclass":
                        SetCurrentKey("FA Subclass Code");
                    GroupTotals::"FA Location":
                        SetCurrentKey("FA Location Code");
                    GroupTotals::"Main Asset":
                        SetCurrentKey("Component of Main Asset");
                    GroupTotals::"Global Dimension 1":
                        SetCurrentKey("Global Dimension 1 Code");
                    GroupTotals::"Global Dimension 2":
                        SetCurrentKey("Global Dimension 2 Code");
                    GroupTotals::"FA Posting Group":
                        SetCurrentKey("FA Posting Group");
                    GroupTotals::"Tax Depreciation Group":
                        SetCurrentKey("Tax Deprec. Group Code CZF");
                end;

                GroupTotalsInt := GroupTotals.AsInteger();
                MakeGroupHeadLine();
                InitGroupTotals();
            end;
        }
        dataitem(ProjectionTotal; "Integer")
        {
            DataItemTableView = sorting(Number) where(Number = const(1));
            column(TotalBookValue2; TotalBookValue[2])
            {
                AutoFormatType = 1;
            }
            column(TotalAmounts1; TotalAmounts[1])
            {
                AutoFormatType = 1;
            }
            column(DeprText2_ProjectionTotal; DeprText2)
            {
            }
            column(ProjectedDisposal_ProjectionTotal; ProjectedDisposal)
            {
            }
            column(DeprBookUseCustDepr_ProjectionTotal; DepreciationBook."Use Custom 1 Depreciation")
            {
            }
            column(Custom1Text_ProjectionTotal; Custom1Text)
            {
            }
            column(TotalAmounts2; TotalAmounts[2])
            {
                AutoFormatType = 1;
            }
            column(DeprCustom1Text_ProjectionTotal; DeprCustom1Text)
            {
            }
            column(TotalAmt1TotalAmt2; TotalAmounts[1] + TotalAmounts[2])
            {
                AutoFormatType = 1;
            }
            column(SalesPriceCaption_ProjectionTotal; SalesPriceCaption)
            {
            }
            column(GainLossCaption_ProjectionTotal; GainLossCaption)
            {
            }
            column(TotalAmounts3; TotalAmounts[3])
            {
                AutoFormatType = 1;
            }
            column(TotalAmounts4; TotalAmounts[4])
            {
                AutoFormatType = 1;
            }
            column(TotalCaption; TotalLbl)
            {
            }
        }
        dataitem(Buffer; "Integer")
        {
            DataItemTableView = sorting(Number) where(Number = filter(1 ..));
            column(DeprBookText_Buffer; DeprBookText)
            {
            }
            column(Custom1TextText_Buffer; Custom1Text)
            {
            }
            column(GroupCodeName2; GroupCodeName2)
            {
            }
            column(FAPostingDate_FABufferProjection; Format(TempFABufferProjection."FA Posting Date"))
            {
            }
            column(Desc_FABufferProjection; TempFABufferProjection.Depreciation)
            {
            }
            column(Cust1_FABufferProjection; TempFABufferProjection."Custom 1")
            {
            }
            column(CodeName_FABufferProj; TempFABufferProjection."Code Name")
            {
            }
            column(ProjectedValueCaption; ProjectedValueLbl)
            {
            }

            trigger OnAfterGetRecord()
            begin
                if Number = 1 then begin
                    if not TempFABufferProjection.FindSet() then
                        CurrReport.Break();
                end else
                    if TempFABufferProjection.Next() = 0 then
                        CurrReport.Break();
            end;

            trigger OnPreDataItem()
            begin
                if not PrintAmountsPerDate then
                    CurrReport.Break();
                TempFABufferProjection.Reset();
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(DepreciationBookCZF; DeprBookCode)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'Depreciation Book';
                        TableRelation = "Depreciation Book";
                        ToolTip = 'Specifies the depreciation book for the printing of entries.';

                        trigger OnValidate()
                        begin
                            UpdateReqForm();
                        end;
                    }
                    field(FirstDeprDate; StartingDate)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'First Depreciation Date';
                        ToolTip = 'Specifies the date to be used as the first date in the period for which you want to calculate projected depreciation.';
                    }
                    field(LastDeprDate; EndingDate)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'Last Depreciation Date';
                        ToolTip = 'Specifies the date to be used as the last date in the period for which you want to calculate projected depreciation. This date must be later than the date in the First Depreciation Date field.';
                    }
                    field(NumberOfDaysCZF; PeriodLength)
                    {
                        ApplicationArea = FixedAssets;
                        BlankZero = true;
                        Caption = 'Number of Days';
                        Editable = NumberOfDaysCtrlEditable;
                        MinValue = 0;
                        ToolTip = 'Specifies the length of the periods between the first depreciation date and the last depreciation date.';

                        trigger OnValidate()
                        begin
                            if PeriodLength > 0 then
                                UseAccountingPeriod := false;
                        end;
                    }
                    field(DaysInFirstPeriodCZF; DaysInFirstPeriod)
                    {
                        ApplicationArea = FixedAssets;
                        BlankZero = true;
                        Caption = 'No. of Days in First Period';
                        MinValue = 0;
                        ToolTip = 'Specifies the number of days that must be used for calculating the depreciation as of the first depreciation date, regardless of the actual number of days from the last depreciation entry.';
                    }
                    field(IncludePostedFromCZF; IncludePostedFrom)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'Posted Entries From';
                        ToolTip = 'Specifies a date if you want the report to include posted entries.';
                    }
                    field(GroupTotalsCZF; GroupTotals)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'Group Totals';
                        ToolTip = 'Specifies a group type if you want the report to group the fixed assets and print group totals.';
                    }
                    field(CopyToGLBudgetName; BudgetNameCode)
                    {
                        ApplicationArea = Suite;
                        Caption = 'Copy to G/L Budget Name';
                        TableRelation = "G/L Budget Name";
                        ToolTip = 'Specifies the name of the budget you want to copy projected values to.';

                        trigger OnValidate()
                        begin
                            if BudgetNameCode = '' then
                                BalAccount := false;
                        end;
                    }
                    field(InsertBalAccount; BalAccount)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'Insert Bal. Account';
                        ToolTip = 'Specifies if you want the program to automatically insert budget entries with balancing accounts.';

                        trigger OnValidate()
                        begin
                            if BalAccount then
                                if BudgetNameCode = '' then
                                    Error(YouMustSpecifyErr, GLBudgetName.TableCaption);
                        end;
                    }
                    field(PrintPerFixedAsset; PrintDetails)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'Print per Fixed Asset';
                        ToolTip = 'Specifies if you want the report to print information separately for each fixed asset.';
                    }
                    field(ProjectedDisposalCZF; ProjectedDisposal)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'Projected Disposal';
                        ToolTip = 'Specifies if you want the report to include projected disposals: the contents of the Projected Proceeds on Disposalfield and the Projected Disposal Date field on the fixed asset depreciation book.';
                    }
                    field(PrintAmountsPerDateCZF; PrintAmountsPerDate)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'Print Amounts per Date';
                        ToolTip = 'Specifies if you want the program to include on the last page of the report a summary of the calculated depreciation for all assets.';
                    }
                    field(UseAccountingPeriodCZF; UseAccountingPeriod)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'Use Accounting Period';
                        ToolTip = 'Specifies if the accounting period will be used for fixed asset report';

                        trigger OnValidate()
                        begin
                            if UseAccountingPeriod then
                                PeriodLength := 0;

                            UpdateReqForm();
                        end;
                    }
                }
            }
        }

        trigger OnInit()
        begin
            NumberOfDaysCtrlEditable := true;
        end;

        trigger OnOpenPage()
        begin
            GetFASetup();
        end;
    }

    labels
    {
        ReportLbl = 'Fixed Asset - Projected Value';
        PageLbl = 'Page';
        DepreciationLbl = 'Depreciation';
        BookValueLbl = 'Book Value';
        ProjectedAmountsPerDateLbl = 'Projected Amounts per Date';
    }

    trigger OnPreReport()
    begin
        DepreciationBook.Get(DeprBookCode);
        Year365Days := DepreciationBook."Fiscal Year 365 Days";
        if GroupTotals = GroupTotals::"FA Posting Group" then
            FAGeneralReport.SetFAPostingGroup("Fixed Asset", DepreciationBook.Code);
        if GroupTotals = GroupTotals::"Tax Depreciation Group" then
            FAGeneralReportCZF.SetFATaxDeprGroup("Fixed Asset", DepreciationBook.Code);
        FAGeneralReport.AppendFAPostingFilter("Fixed Asset", StartingDate, EndingDate);
        DeprBookText := StrSubstNo(TwoPlaceholdersTok, DepreciationBook.TableCaption, DeprBookCode);
        MakeGroupTotalText();
        ValidateDates();
        if PrintDetails then begin
            FANoCaption := "Fixed Asset".FieldCaption("No.");
            FADescriptionCaption := "Fixed Asset".FieldCaption(Description);
        end;
        if DepreciationBook."No. of Days in Fiscal Year" > 0 then
            DaysInFiscalYear := DepreciationBook."No. of Days in Fiscal Year"
        else
            DaysInFiscalYear := 360;
        if Year365Days then
            DaysInFiscalYear := 365;
        if PeriodLength = 0 then
            PeriodLength := DaysInFiscalYear;
        if (PeriodLength <= 5) or (PeriodLength > DaysInFiscalYear) then
            Error(NumberOfDaysMustNotBeGreaterThanErr, DaysInFiscalYear);
        FALedgerEntry2."FA Posting Type" := FALedgerEntry2."FA Posting Type"::Depreciation;
        DeprText := Format(FALedgerEntry2."FA Posting Type");
        if DepreciationBook."Use Custom 1 Depreciation" then begin
            DeprText2 := DeprText;
            FALedgerEntry2."FA Posting Type" := FALedgerEntry2."FA Posting Type"::"Custom 1";
            Custom1Text := Format(FALedgerEntry2."FA Posting Type");
            DeprCustom1Text := StrSubstNo(TwoPlaceholdersTok, DeprText, Custom1Text);
        end;
        SalesPriceCaption := FADepreciationBook.FieldCaption("Projected Proceeds on Disposal");
        GainLossCaption := ProjectedGainLossTxt;
    end;

    var
        GLBudgetName: Record "G/L Budget Name";
        FASetup: Record "FA Setup";
        DepreciationBook: Record "Depreciation Book";
        FADepreciationBook: Record "FA Depreciation Book";
        FixedAsset: Record "Fixed Asset";
        FALedgerEntry2: Record "FA Ledger Entry";
        TempFABufferProjection: Record "FA Buffer Projection" temporary;
        FAGeneralReport: Codeunit "FA General Report";
        FAGeneralReportCZF: Codeunit "FA General Report CZF";
        CalculateDepreciation: Codeunit "Calculate Depreciation";
        FADateCalculation: Codeunit "FA Date Calculation";
        DepreciationCalculation: Codeunit "Depreciation Calculation";
        DeprBookCode: Code[10];
        GroupCodeName, GroupCodeName2, FANoCaption, FADescriptionCaption, SalesPriceCaption, GainLossCaption, GroupHeadLine, DeprCustom1Text : Text;
        DeprBookText, DeprText, DeprText2, Custom1Text : Text[50];
        GroupTotals: Enum "FA Analysis Group CZF";
        BookValue: Decimal;
        NewFiscalYear, EndFiscalYear : Date;
        DaysInFiscalYear, PeriodLength, NumberOfDays, Custom1NumberOfDays, DaysInFirstPeriod : Integer;
        IncludePostedFrom, Custom1DeprUntil, StartingDate, StartingDate2, EndingDate, EndingDate2, UntilDate : Date;
        PrintDetails, PrintAmountsPerDate, UseAccountingPeriod : Boolean;
        EntryAmounts, AssetAmounts, GroupAmounts, TotalAmounts : array[4] of Decimal;
        TotalBookValue: array[2] of Decimal;
        GroupTotalBookValue: Decimal;
        DateFromProjection: Date;
        DeprAmount: Decimal;
        Custom1Amount: Decimal;
        Done, NotFirstGroupTotal, ProjectedDisposal, DoProjectedDisposal, EntryPrinted : Boolean;
        BudgetNameCode: Code[10];
        OldValue: Code[20];
        NewValue: Code[20];
        BalAccount: Boolean;
        YouMustSpecifyErr: Label 'You must specify %1.', Comment = '%1 = G/L Budget Name caption';
        TempDeprDate: Date;
        GroupTotalsInt: Integer;
        Year365Days: Boolean;
        YouMustCreateAccPeriodsErr: Label 'You must create accounting periods until %1 to use 365 days depreciation and ''Use Accounting Periods''.', Comment = '%1 = Date';
        NumberOfDaysCtrlEditable: Boolean;
        NumberOfDaysMustNotBeGreaterThanErr: Label 'Number of Days must not be greater than %1 or less than 5.', Comment = '%1 = Number of days in fiscal year';
        ProjectedGainLossTxt: Label 'Projected Gain/Loss';
        ProjectedValueLbl: Label 'Projected Value';
        TotalLbl: Label 'Total';
        GroupTotalTxt: Label 'Group Total';
        GroupTotalsTxt: Label 'Group Totals';
        GroupsTxt: Label ' ,FA Class,FA Subclass,FA Location,Main Asset,Global Dimension 1,Global Dimension 2,FA Posting Group,Tax Depreciation Group';
        HasBeenModifiedInFAErr: Label '%1 has been modified in fixed asset %2.', Comment = '%1 = FA Posting Group caption, %2 = FA No.';
        TwoPlaceholdersTok: Label '%1 %2', Locked = true;

    local procedure SkipRecord(): Boolean
    begin
        exit(
          "Fixed Asset".Inactive or
          (FADepreciationBook."Acquisition Date" = 0D) or
          (FADepreciationBook."Acquisition Date" > EndingDate) or
          (FADepreciationBook."Last Depreciation Date" > EndingDate) or
          (FADepreciationBook."Disposal Date" > 0D));
    end;

    local procedure TransferValues()
    begin
        FADepreciationBook.CalcFields(FADepreciationBook."Book Value", FADepreciationBook.Depreciation, FADepreciationBook."Custom 1");
        DateFromProjection := 0D;
        EntryAmounts[1] := FADepreciationBook."Book Value";
        EntryAmounts[2] := FADepreciationBook."Custom 1";
        EntryAmounts[3] := DepreciationCalculation.DeprInFiscalYear("Fixed Asset"."No.", DeprBookCode, StartingDate);
        TotalBookValue[1] := TotalBookValue[1] + FADepreciationBook."Book Value";
        TotalBookValue[2] := TotalBookValue[2] + FADepreciationBook."Book Value";
        GroupTotalBookValue += FADepreciationBook."Book Value";
        NewFiscalYear := FADateCalculation.GetFiscalYear(DeprBookCode, StartingDate);
        EndFiscalYear := FADateCalculation.CalculateDate(
            DepreciationCalculation.Yesterday(NewFiscalYear, Year365Days), DaysInFiscalYear, Year365Days);
        TempDeprDate := FADepreciationBook."Temp. Ending Date";
        if DepreciationBook."Use Custom 1 Depreciation" then
            Custom1DeprUntil := FADepreciationBook."Depr. Ending Date (Custom 1)"
        else
            Custom1DeprUntil := 0D;

        if Custom1DeprUntil > 0D then
            EntryAmounts[4] := GetDeprBasis();

        UntilDate := 0D;
        AssetAmounts[1] := 0;
        AssetAmounts[2] := 0;
        AssetAmounts[3] := 0;
        AssetAmounts[4] := 0;
    end;

    local procedure CalculateFirstDeprAmount()
    var
        FirstTime: Boolean;
    begin
        FirstTime := true;
        UntilDate := StartingDate;
        repeat
            if not FirstTime then
                GetNextDate();
            FirstTime := false;
            CalculateDepreciation.Calculate(
              DeprAmount, Custom1Amount, NumberOfDays, Custom1NumberOfDays,
              "Fixed Asset"."No.", DeprBookCode, UntilDate, EntryAmounts, 0D, DaysInFirstPeriod);
            Done := (DeprAmount <> 0) or (Custom1Amount <> 0);
        until (UntilDate >= EndingDate) or Done;
        EntryAmounts[3] :=
          DepreciationCalculation.DeprInFiscalYear("Fixed Asset"."No.", DeprBookCode, UntilDate);
    end;

    local procedure CalculateSecondDeprAmount()
    begin
        GetNextDate();
        CalculateDepreciation.Calculate(
          DeprAmount, Custom1Amount, NumberOfDays, Custom1NumberOfDays,
          "Fixed Asset"."No.", DeprBookCode, UntilDate, EntryAmounts, DateFromProjection, 0);
        Done := CalculationDone(
            (DeprAmount <> 0) or (Custom1Amount <> 0), DateFromProjection);
    end;

    local procedure GetNextDate()
    var
        UntilDate2: Date;
    begin
        UntilDate2 := GetPeriodEndingDate(UseAccountingPeriod, UntilDate, PeriodLength);
        if Custom1DeprUntil > 0D then
            if (UntilDate < Custom1DeprUntil) and (UntilDate2 > Custom1DeprUntil) then
                UntilDate2 := Custom1DeprUntil;

        if TempDeprDate > 0D then
            if (UntilDate < TempDeprDate) and (UntilDate2 > TempDeprDate) then
                UntilDate2 := TempDeprDate;

        if (UntilDate < EndFiscalYear) and (UntilDate2 > EndFiscalYear) then
            UntilDate2 := EndFiscalYear;

        if UntilDate = EndFiscalYear then begin
            EntryAmounts[3] := 0;
            NewFiscalYear := DepreciationCalculation.ToMorrow(EndFiscalYear, Year365Days);
            EndFiscalYear := FADateCalculation.CalculateDate(EndFiscalYear, DaysInFiscalYear, Year365Days);
        end;

        DateFromProjection := DepreciationCalculation.ToMorrow(UntilDate, Year365Days);
        UntilDate := UntilDate2;
        if UntilDate >= EndingDate then
            UntilDate := EndingDate;
    end;

    local procedure GetPeriodEndingDate(UseAccountingPeriod2: Boolean; PeriodEndingDate: Date; var PeriodLength2: Integer): Date
    var
        AccountingPeriod: Record "Accounting Period";
        UntilDate2: Date;
    begin
        if not UseAccountingPeriod2 or AccountingPeriod.IsEmpty then
            exit(FADateCalculation.CalculateDate(PeriodEndingDate, PeriodLength2, Year365Days));
        AccountingPeriod.SetFilter(
          "Starting Date", '>=%1', DepreciationCalculation.ToMorrow(PeriodEndingDate, Year365Days) + 1);
        if AccountingPeriod.FindFirst() then begin
            if Date2DMY(AccountingPeriod."Starting Date", 1) <> 31 then
                UntilDate2 := DepreciationCalculation.Yesterday(AccountingPeriod."Starting Date", Year365Days)
            else
                UntilDate2 := AccountingPeriod."Starting Date" - 1;
            PeriodLength2 :=
              DepreciationCalculation.DeprDays(
                DepreciationCalculation.ToMorrow(PeriodEndingDate, Year365Days), UntilDate2, Year365Days);
            if (PeriodLength2 <= 5) or (PeriodLength2 > DaysInFiscalYear) then
                PeriodLength2 := DaysInFiscalYear;
            exit(UntilDate2);
        end;
        if Year365Days then
            Error(YouMustCreateAccPeriodsErr, DepreciationCalculation.ToMorrow(EndingDate, Year365Days) + 1);
        exit(FADateCalculation.CalculateDate(PeriodEndingDate, PeriodLength2, Year365Days));
    end;

    local procedure MakeGroupTotalText()
    begin
        case GroupTotals of
            GroupTotals::"FA Class":
                GroupCodeName := "Fixed Asset".FieldCaption("FA Class Code");
            GroupTotals::"FA Subclass":
                GroupCodeName := "Fixed Asset".FieldCaption("FA Subclass Code");
            GroupTotals::"FA Location":
                GroupCodeName := "Fixed Asset".FieldCaption("FA Location Code");
            GroupTotals::"Main Asset":
                GroupCodeName := "Fixed Asset".FieldCaption("Main Asset/Component");
            GroupTotals::"Global Dimension 1":
                GroupCodeName := "Fixed Asset".FieldCaption("Global Dimension 1 Code");
            GroupTotals::"Global Dimension 2":
                GroupCodeName := "Fixed Asset".FieldCaption("Global Dimension 2 Code");
            GroupTotals::"FA Posting Group":
                GroupCodeName := "Fixed Asset".FieldCaption("FA Posting Group");
            GroupTotals::"Tax Depreciation Group":
                GroupCodeName := "Fixed Asset".FieldCaption("Tax Deprec. Group Code CZF");
        end;
        if GroupCodeName <> '' then begin
            GroupCodeName2 := GroupCodeName;
            if GroupTotals = GroupTotals::"Main Asset" then
                GroupCodeName2 := SelectStr(GroupTotals.AsInteger() + 1, GroupsTxt);
            GroupCodeName := StrSubstNo(TwoPlaceholdersTok, GroupTotalsTxt, GroupCodeName2);
        end;
    end;

    local procedure ValidateDates()
    begin
        FAGeneralReport.ValidateDeprDates(StartingDate, EndingDate);
        EndingDate2 := EndingDate;
        StartingDate2 := StartingDate;
    end;

    local procedure MakeGroupHeadLine()
    begin
        case GroupTotals of
            GroupTotals::"FA Class":
                GroupHeadLine := "Fixed Asset"."FA Class Code";
            GroupTotals::"FA Subclass":
                GroupHeadLine := "Fixed Asset"."FA Subclass Code";
            GroupTotals::"FA Location":
                GroupHeadLine := "Fixed Asset"."FA Location Code";
            GroupTotals::"Main Asset":
                begin
                    FixedAsset."Main Asset/Component" := FixedAsset."Main Asset/Component"::"Main Asset";
                    GroupHeadLine :=
                      StrSubstNo(TwoPlaceholdersTok, FixedAsset."Main Asset/Component", "Fixed Asset"."Component of Main Asset");
                    if "Fixed Asset"."Component of Main Asset" = '' then
                        GroupHeadLine := StrSubstNo(TwoPlaceholdersTok, GroupHeadLine, '*****');
                end;
            GroupTotals::"Global Dimension 1":
                GroupHeadLine := "Fixed Asset"."Global Dimension 1 Code";
            GroupTotals::"Global Dimension 2":
                GroupHeadLine := "Fixed Asset"."Global Dimension 2 Code";
            GroupTotals::"FA Posting Group":
                GroupHeadLine := "Fixed Asset"."FA Posting Group";
            GroupTotals::"Tax Depreciation Group":
                GroupHeadLine := "Fixed Asset"."Tax Deprec. Group Code CZF";
        end;
        if GroupHeadLine = '' then
            GroupHeadLine := '*****';
    end;

    local procedure UpdateTotals()
    var
        BudgetDepreciation: Codeunit "Budget Depreciation";
        EntryNo: Integer;
        CodeName: Code[20];
    begin
        EntryAmounts[1] := EntryAmounts[1] + DeprAmount + Custom1Amount;
        if Custom1DeprUntil > 0D then
            if UntilDate <= Custom1DeprUntil then
                EntryAmounts[4] := EntryAmounts[4] + DeprAmount + Custom1Amount;
        EntryAmounts[2] := EntryAmounts[2] + Custom1Amount;
        EntryAmounts[3] := EntryAmounts[3] + DeprAmount + Custom1Amount;
        AssetAmounts[1] := AssetAmounts[1] + DeprAmount;
        AssetAmounts[2] := AssetAmounts[2] + Custom1Amount;
        GroupAmounts[1] := GroupAmounts[1] + DeprAmount;
        GroupAmounts[2] := GroupAmounts[2] + Custom1Amount;
        TotalAmounts[1] := TotalAmounts[1] + DeprAmount;
        TotalAmounts[2] := TotalAmounts[2] + Custom1Amount;
        TotalBookValue[1] := TotalBookValue[1] + DeprAmount + Custom1Amount;
        TotalBookValue[2] := TotalBookValue[2] + DeprAmount + Custom1Amount;
        GroupTotalBookValue += DeprAmount + Custom1Amount;
        if BudgetNameCode <> '' then
            BudgetDepreciation.CopyProjectedValueToBudget(
              FADepreciationBook, BudgetNameCode, UntilDate, DeprAmount, Custom1Amount, BalAccount);

        if (UntilDate > 0D) or PrintAmountsPerDate then begin
            TempFABufferProjection.Reset();
            if TempFABufferProjection.Find('+') then
                EntryNo := TempFABufferProjection."Entry No." + 1
            else
                EntryNo := 1;
            TempFABufferProjection.SetRange(TempFABufferProjection."FA Posting Date", UntilDate);
            if GroupTotals <> GroupTotals::" " then begin
                case GroupTotals of
                    GroupTotals::"FA Class":
                        CodeName := "Fixed Asset"."FA Class Code";
                    GroupTotals::"FA Subclass":
                        CodeName := "Fixed Asset"."FA Subclass Code";
                    GroupTotals::"FA Location":
                        CodeName := "Fixed Asset"."FA Location Code";
                    GroupTotals::"Main Asset":
                        CodeName := "Fixed Asset"."Component of Main Asset";
                    GroupTotals::"Global Dimension 1":
                        CodeName := "Fixed Asset"."Global Dimension 1 Code";
                    GroupTotals::"Global Dimension 2":
                        CodeName := "Fixed Asset"."Global Dimension 2 Code";
                    GroupTotals::"FA Posting Group":
                        CodeName := "Fixed Asset"."FA Posting Group";
                    GroupTotals::"Tax Depreciation Group":
                        CodeName := "Fixed Asset"."Tax Deprec. Group Code CZF";
                end;
                TempFABufferProjection.SetRange(TempFABufferProjection."Code Name", CodeName);
            end;
            if not TempFABufferProjection.Find('=><') then begin
                TempFABufferProjection.Init();
                TempFABufferProjection."Code Name" := CodeName;
                TempFABufferProjection."FA Posting Date" := UntilDate;
                TempFABufferProjection."Entry No." := EntryNo;
                TempFABufferProjection.Depreciation := DeprAmount;
                TempFABufferProjection."Custom 1" := Custom1Amount;
                TempFABufferProjection.Insert();
            end else begin
                TempFABufferProjection.Depreciation := TempFABufferProjection.Depreciation + DeprAmount;
                TempFABufferProjection."Custom 1" := TempFABufferProjection."Custom 1" + Custom1Amount;
                TempFABufferProjection.Modify();
            end;
        end;
    end;

    local procedure InitGroupTotals()
    begin
        GroupAmounts[1] := 0;
        GroupAmounts[2] := 0;
        GroupAmounts[3] := 0;
        GroupAmounts[4] := 0;
        GroupTotalBookValue := 0;
        if NotFirstGroupTotal then
            TotalBookValue[1] := 0
        else
            TotalBookValue[1] := EntryAmounts[1];
        NotFirstGroupTotal := true;
    end;

    local procedure GetDeprBasis(): Decimal
    var
        CalculatedFALedgerEntry: Record "FA Ledger Entry";
    begin
        CalculatedFALedgerEntry.SetCurrentKey(CalculatedFALedgerEntry."FA No.", CalculatedFALedgerEntry."Depreciation Book Code", CalculatedFALedgerEntry."Part of Book Value", CalculatedFALedgerEntry."FA Posting Date");
        CalculatedFALedgerEntry.SetRange(CalculatedFALedgerEntry."FA No.", "Fixed Asset"."No.");
        CalculatedFALedgerEntry.SetRange(CalculatedFALedgerEntry."Depreciation Book Code", DeprBookCode);
        CalculatedFALedgerEntry.SetRange(CalculatedFALedgerEntry."Part of Book Value", true);
        CalculatedFALedgerEntry.SetRange(CalculatedFALedgerEntry."FA Posting Date", 0D, Custom1DeprUntil);
        CalculatedFALedgerEntry.CalcSums(CalculatedFALedgerEntry.Amount);
        exit(CalculatedFALedgerEntry.Amount);
    end;

    local procedure CalculateGainLoss()
    var
        CalculateDisposal: Codeunit "Calculate Disposal";
        GainLossEntryAmounts: array[14] of Decimal;
        PrevAmount: array[2] of Decimal;
    begin
        PrevAmount[1] := AssetAmounts[3];
        PrevAmount[2] := AssetAmounts[4];

        CalculateDisposal.CalcGainLoss("Fixed Asset"."No.", DeprBookCode, GainLossEntryAmounts);
        AssetAmounts[3] := FADepreciationBook."Projected Proceeds on Disposal";
        if GainLossEntryAmounts[1] <> 0 then
            AssetAmounts[4] := GainLossEntryAmounts[1]
        else
            AssetAmounts[4] := GainLossEntryAmounts[2];
        AssetAmounts[4] :=
          AssetAmounts[4] + AssetAmounts[1] + AssetAmounts[2] - FADepreciationBook."Projected Proceeds on Disposal";

        GroupAmounts[3] += AssetAmounts[3] - PrevAmount[1];
        GroupAmounts[4] += AssetAmounts[4] - PrevAmount[2];
    end;

    local procedure CalculationDone(Done2: Boolean; FirstDeprDate2: Date): Boolean
    var
        TableDeprCalculation: Codeunit "Table Depr. Calculation";
    begin
        if Done2 or
           (FADepreciationBook."Depreciation Method" <> FADepreciationBook."Depreciation Method"::"User-Defined")
        then
            exit(Done2);
        exit(
          TableDeprCalculation.GetTablePercent(
            DeprBookCode, FADepreciationBook."Depreciation Table Code",
            FADepreciationBook."First User-Defined Depr. Date", FirstDeprDate2, UntilDate) = 0);
    end;

    local procedure UpdateReqForm()
    begin
        PageUpdateReqForm();
    end;

    local procedure PageUpdateReqForm()
    begin
        if DeprBookCode <> '' then
            DepreciationBook.Get(DeprBookCode);

        PeriodLength := 0;
        if DepreciationBook."Fiscal Year 365 Days" and not UseAccountingPeriod then
            PeriodLength := 365;
    end;

    procedure SetMandatoryFields(DepreciationBookCodeFrom: Code[10]; StartingDateFrom: Date; EndingDateFrom: Date)
    begin
        DeprBookCode := DepreciationBookCodeFrom;
        StartingDate := StartingDateFrom;
        EndingDate := EndingDateFrom;
    end;

    procedure SetPeriodFields(PeriodLengthFrom: Integer; DaysInFirstPeriodFrom: Integer; IncludePostedFromFrom: Date; UseAccountingPeriodFrom: Boolean)
    begin
        PeriodLength := PeriodLengthFrom;
        DaysInFirstPeriod := DaysInFirstPeriodFrom;
        IncludePostedFrom := IncludePostedFromFrom;
        UseAccountingPeriod := UseAccountingPeriodFrom;
    end;

    procedure SetTotalFields(GroupTotalsFrom: Enum "FA Analysis Group CZF"; PrintDetailsFrom: Boolean)
    begin
        GroupTotals := GroupTotalsFrom;
        PrintDetails := PrintDetailsFrom;
    end;

    procedure SetBudgetField(BudgetNameCodeFrom: Code[10]; BalAccountFrom: Boolean; ProjectedDisposalFrom: Boolean; PrintAmountsPerDateFrom: Boolean)
    begin
        BudgetNameCode := BudgetNameCodeFrom;
        BalAccount := BalAccountFrom;
        ProjectedDisposal := ProjectedDisposalFrom;
        PrintAmountsPerDate := PrintAmountsPerDateFrom;
    end;

    procedure GetFASetup()
    begin
        if DeprBookCode = '' then begin
            FASetup.Get();
            DeprBookCode := FASetup."Default Depr. Book";
        end;
        UpdateReqForm();
    end;

    local procedure UpdateGroupTotals()
    begin
        GroupAmounts[1] := GroupAmounts[1] + DeprAmount;
        TotalAmounts[1] := TotalAmounts[1] + DeprAmount;
    end;
}
