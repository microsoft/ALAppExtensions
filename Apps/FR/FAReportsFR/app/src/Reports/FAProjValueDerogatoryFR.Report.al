// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.FixedAssets.Reports;

using Microsoft.Finance.GeneralLedger.Budget;
using Microsoft.FixedAssets.Depreciation;
using Microsoft.FixedAssets.FixedAsset;
using Microsoft.FixedAssets.Ledger;
using Microsoft.FixedAssets.Setup;
using Microsoft.Foundation.Period;
using System.Utilities;

report 10817 "FA-Proj. Value (Derogatory) FR"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/Reports/FAProjValueDerogatoryFR.rdlc';
    ApplicationArea = FixedAssets;
    Caption = 'Fixed Asset - Projected Value (Derogatory)';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem("Fixed Asset"; "Fixed Asset")
        {
            DataItemTableView = sorting("No.");
            RequestFilterFields = "No.", "FA Class Code", "FA Subclass Code", "Budgeted Asset";
            column(CompanyName; COMPANYPROPERTY.DisplayName())
            {
            }
            column(DeprBookText; DeprBookText)
            {
            }
            column(FixedAssetTabcaptFAFilter; TableCaption + ': ' + FAFilter)
            {
            }
            column(FAFilter; FAFilter)
            {
            }
            column(PrintDetails; PrintDetails)
            {
            }
            column(ProjectedDisposal; ProjectedDisposalFlag)
            {
            }
            column(DeprBookUseCustom1Depr; DeprBook."Use Custom 1 Depreciation")
            {
            }
            column(DoProjectedDisposal; DoProjectedDisposal)
            {
            }
            column(GroupTotalsInt; GroupTotalsInt)
            {
            }
            column(IncludePostedFrom; Format(IncludePostedFromFilter))
            {
            }
            column(GroupCodeName; GroupCodeName)
            {
            }
            column(FANo; FANo)
            {
            }
            column(FADescription; FADescription)
            {
            }
            column(GroupHeadLine; GroupHeadLine)
            {
            }
            column(FixedAssetNo; "No.")
            {
            }
            column(Description_FixedAsset; Description)
            {
            }
            column(DeprText2; DeprText2)
            {
            }
            column(Text002GroupHeadLine; GroupTotalTxt + ': ' + GroupHeadLine)
            {
            }
            column(Custom1Text; Custom1Text)
            {
            }
            column(DeprCustom1Text; DeprCustom1Text)
            {
            }
            column(SalesPriceFieldname; SalesPriceFieldname)
            {
            }
            column(GainLossFieldname; GainLossFieldname)
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
            column(FAClassCode_FixedAsset; "FA Class Code")
            {
            }
            column(FASubclassCode_FixedAsset; "FA Subclass Code")
            {
            }
            column(GlobalDim1Code_FixedAsset; "Global Dimension 1 Code")
            {
            }
            column(GlobalDim2Code_FixedAsset; "Global Dimension 2 Code")
            {
            }
            column(FALocationCode_FixedAsset; "FA Location Code")
            {
            }
            column(CompofMainAss_FixedAsset; "Component of Main Asset")
            {
            }
            column(FAPostingGroup_FixedAsset; "FA Posting Group")
            {
            }
            column(CurrReportPAGENOCaption; PageNoLbl)
            {
            }
            column(FixedAssetProjectedValueCaption; FAProjectedValueLbl)
            {
            }
            column(FALedgerEntryFAPostingDateCaption; FAPostingDateLbl)
            {
            }
            column(BookValueCaption; BookValueLbl)
            {
            }
            column(DerogAssetsIncluded; DerogAssetsIncluded)
            {
            }
            column(HasDerogatorySetup; HasDerogatorySetup)
            {
            }
            column(FAPostingTypeCaption; FAPostingTypeLbl)
            {
            }
            column(NoofDepreciationDaysCaption; NoofDepreciationDaysLbl)
            {
            }
            column(AmtCaption; AmountLbl)
            {
            }
            column(DerogatoryAmountCaption; DerogatoryAmountLbl)
            {
            }
            column(DerogatoryBookValueCaption; DerogatoryBookValueLbl)
            {
            }
            column(DifferenceBookValueCaption; DifferenceBookValueLbl)
            {
            }
            dataitem("FA Ledger Entry"; "FA Ledger Entry")
            {
                DataItemTableView = sorting("FA No.", "Depreciation Book Code", "FA Posting Date");
                column(FAPostingDt_FALedgerEntry; Format("FA Posting Date"))
                {
                }
                column(PostingDt_FALedgerEntry; "FA Posting Type")
                {
                    IncludeCaption = false;
                }
                column(Amount_FALedgerEntry; Amount)
                {
                    IncludeCaption = false;
                }
                column(FANo_FALedgerEntry; "FA No.")
                {
                }
                column(BookValue; BookValue)
                {
                    AutoFormatType = 1;
                }
                column(NoofDeprDays_FALedgEntry; "No. of Depreciation Days")
                {
                    IncludeCaption = false;
                }
                column(FALedgerEntryEntryNo; "Entry No.")
                {
                }
                column(PostedEntryCaption; PostedEntryLbl)
                {
                }
                column(FALedgerEntryDerogAmount; FALedgerEntryDerogAmount)
                {
                }
                column(FALedgerEntryDerogBookValue; FALedgerEntryDerogBookValue)
                {
                }
                column(FALedgerEntryDerogDiffBookValue; FALedgerEntryDerogDiffBookValue)
                {
                }

                trigger OnAfterGetRecord()
                begin
                    if "Part of Book Value" then begin
                        BookValue := BookValue + Amount;
                        if HasDerogatorySetup then begin
                            FALedgerEntryDerogAmount :=
                              Amount + GetFALedgerEntryDerogatoryAmount("Fixed Asset"."No.", DeprBookCode, "Document No.", "FA Posting Date");
                            FALedgerEntryDerogBookValue += FALedgerEntryDerogAmount;
                            FALedgerEntryDerogDiffBookValue := FALedgerEntryDerogBookValue - BookValue;
                        end;
                    end;
                    if "FA Posting Date" < IncludePostedFromFilter then
                        CurrReport.Skip();
                    EntryPrinted := true;
                end;

                trigger OnPreDataItem()
                begin
                    SetRange("FA No.", "Fixed Asset"."No.");
                    SetRange("Depreciation Book Code", DeprBookCode);
                    SetRange("Exclude Derogatory", false);
                    BookValue := 0;
                    FALedgerEntryDerogBookValue := 0;
                    if (IncludePostedFromFilter = 0D) or not PrintDetails then
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
                column(NumberOfDays; DerogNumberOfDays)
                {
                }
                column(No1_FixedAsset; "Fixed Asset"."No.")
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
                column(SalesPriceFieldname_ProjectedDepr; SalesPriceFieldname)
                {
                }
                column(GainLossFieldname_ProjectedDepr; GainLossFieldname)
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
                column(DerogAmount; DerogAmount)
                {
                    AutoFormatType = 1;
                }
                column(DerogBookValue; DerogBookValue)
                {
                    AutoFormatType = 1;
                }
                column(DerogDiffBookValue; DerogDiffBookValue)
                {
                }
                column(AssetDerogAmount; AssetDerogAmount)
                {
                    AutoFormatType = 1;
                }
                column(AssetDerogBookValue; AssetDerogBookValue)
                {
                }
                column(AssetDerogDiffBookValue; AssetDerogDiffBookValue)
                {
                }
                column(GroupDerogAmount; GroupDerogAmount)
                {
                }
                column(GroupDerogBookValue; GroupDerogBookValue)
                {
                }
                column(GroupDerogDiffBookValue; GroupDerogDiffBookValue)
                {
                }

                trigger OnAfterGetRecord()
                begin
                    if UntilDate >= EndingDate then
                        CurrReport.Break();
                    if Number = 1 then begin
                        CalculateFirstDeprAmount(Done);
                        DateFromProjection := DepreciationCalculation.Yesterday(DateFromProjection, Year365Days);
                        if FADeprBook."Book Value" <> 0 then
                            Done := Done or not EntryPrinted;
                    end else
                        CalculateSecondDeprAmount(Done);
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
                case GroupTotalsOption of
                    GroupTotalsOption::"FA Class":
                        NewValue := "FA Class Code";
                    GroupTotalsOption::"FA Subclass":
                        NewValue := "FA Subclass Code";
                    GroupTotalsOption::"FA Location":
                        NewValue := "FA Location Code";
                    GroupTotalsOption::"Main Asset":
                        NewValue := "Component of Main Asset";
                    GroupTotalsOption::"Global Dimension 1":
                        NewValue := "Global Dimension 1 Code";
                    GroupTotalsOption::"Global Dimension 2":
                        NewValue := "Global Dimension 2 Code";
                    GroupTotalsOption::"FA Posting Group":
                        NewValue := "FA Posting Group";
                end;

                if NewValue <> OldValue then begin
                    MakeGroupHeadLine();
                    InitGroupTotals();
                    OldValue := NewValue;
                end;

                if not FADeprBook.Get("No.", DeprBookCode) then
                    CurrReport.Skip();
                if SkipRecord() then
                    CurrReport.Skip();

                HasDerogatorySetup := IsDerogatorySetup("No.");
                if HasDerogatorySetup then begin
                    DerogAssetsIncluded := true;
                    TotalDerogAssetsIncluded := true;
                end;

                if GroupTotalsOption = GroupTotalsOption::"FA Posting Group" then
                    if "FA Posting Group" <> FADeprBook."FA Posting Group" then
                        Error(HasBeenModifiedInFAErr, FieldCaption("FA Posting Group"), "No.");

                StartingDate := StartingDate2;
                EndingDate := EndingDate2;
                DoProjectedDisposal := false;
                EntryPrinted := false;
                if ProjectedDisposalFlag and
                   (FADeprBook."Projected Disposal Date" > 0D) and
                   (FADeprBook."Projected Disposal Date" <= EndingDate)
                then begin
                    EndingDate := FADeprBook."Projected Disposal Date";
                    if StartingDate > EndingDate then
                        StartingDate := EndingDate;
                    DoProjectedDisposal := true;
                end;

                TransferValues();
            end;

            trigger OnPreDataItem()
            begin
                case GroupTotalsOption of
                    GroupTotalsOption::"FA Class":
                        SetCurrentKey("FA Class Code");
                    GroupTotalsOption::"FA Subclass":
                        SetCurrentKey("FA Subclass Code");
                    GroupTotalsOption::"FA Location":
                        SetCurrentKey("FA Location Code");
                    GroupTotalsOption::"Main Asset":
                        SetCurrentKey("Component of Main Asset");
                    GroupTotalsOption::"Global Dimension 1":
                        SetCurrentKey("Global Dimension 1 Code");
                    GroupTotalsOption::"Global Dimension 2":
                        SetCurrentKey("Global Dimension 2 Code");
                    GroupTotalsOption::"FA Posting Group":
                        SetCurrentKey("FA Posting Group");
                end;

                GroupTotalsInt := GroupTotalsOption;
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
            column(ProjectedDisposal_ProjectionTotal; ProjectedDisposalFlag)
            {
            }
            column(DeprBookUseCustDepr_ProjectionTotal; DeprBook."Use Custom 1 Depreciation")
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
            column(SalesPriceFieldname_ProjectionTotal; SalesPriceFieldname)
            {
            }
            column(GainLossFieldname_ProjectionTotal; GainLossFieldname)
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
            column(TotalDerogAmount; TotalDerogAmount)
            {
                AutoFormatType = 1;
            }
            column(TotalDerogBookValue; TotalDerogBookValue)
            {
            }
            column(TotalDerogDiffBookValue; TotalDerogDiffBookValue)
            {
            }
            column(TotalDerogAssetsIncluded; TotalDerogAssetsIncluded)
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
            column(ProjectedAmountsperDateCaption; ProjectedAmountsPerDateLbl)
            {
            }
            column(FABufferProjectionFAPostingDateCaption; FABufferProjectionFAPostingDateLbl)
            {
            }
            column(FABufferProjectionDepreciationCaption; FABufferProjectionDepreciationLbl)
            {
            }
            column(FixedAssetProjectedValueCaption_Buffer; FABufferProjectedValueLbl)
            {
            }

            trigger OnAfterGetRecord()
            begin
                if Number = 1 then begin
                    if not TempFABufferProjection.Find('-') then
                        CurrReport.Break();
                end else
                    if TempFABufferProjection.Next() = 0 then
                        CurrReport.Break();
            end;

            trigger OnPreDataItem()
            begin
                if not PrintAmountsPerDateFlag then
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
                    field(DepreciationBook; DeprBookCode)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'Depreciation Book';
                        TableRelation = "Depreciation Book";
                        ToolTip = 'Specifies the code for the depreciation book to be included in the report or batch job.';

                        trigger OnValidate()
                        begin
                            UpdateReqForm();
                        end;
                    }
                    field(FirstDeprDate; StartingDate)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'First Depreciation Date';
                        ToolTip = 'Specifies the date on which you want the depreciation calculation to start. This date is used to calculate the value in the No. of Depreciation Days field for the first depreciation of the asset. The date is used only if there are no entries other than acquisition cost and salvage value.';
                    }
                    field(LastDeprDate; EndingDate)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'Last Depreciation Date';
                        ToolTip = 'Specifies the fixed assed posting date of the last posted depreciation.';
                    }
                    field(NumberOfDays; PeriodLengthDays)
                    {
                        ApplicationArea = FixedAssets;
                        BlankZero = true;
                        Caption = 'Number of Days';
                        Editable = NumberOfDaysCtrlEditable;
                        MinValue = 0;
                        ToolTip = 'Specifies the length of the periods between the first depreciation date and the last depreciation date. The program then calculates depreciation for each period. If you leave this field blank, the program automatically sets the contents of this field to equal the number of days in a fiscal year, normally 360.';

                        trigger OnValidate()
                        begin
                            if PeriodLengthDays > 0 then
                                UseAccountingPeriodFlag := false;
                        end;
                    }
                    field(DaysInFirstPeriod; DaysInFirstPeriodCount)
                    {
                        ApplicationArea = FixedAssets;
                        BlankZero = true;
                        Caption = 'No. of Days in First Period';
                        MinValue = 0;
                        ToolTip = 'Specifies the number of days that must be used for calculating the depreciation as of the first depreciation date, regardless of the actual number of days from the last depreciation entry. The number you enter in this field does not affect the total number of days from the starting date to the ending date.';
                    }
                    field(IncludePostedFrom; IncludePostedFromFilter)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'Posted Entries From';
                        ToolTip = 'Specifies the fixed asset posting date from which the report includes all types of posted entries.';
                    }
                    field(GroupTotals; GroupTotalsOption)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'Group Totals';
                        OptionCaption = ' ,FA Class,FA Subclass,FA Location,Main Asset,Global Dimension 1,Global Dimension 2,FA Posting Group';
                        ToolTip = 'Specifies if you want the report to group fixed assets and print totals using the category defined in this field. For example, maintenance expenses for fixed assets can be shown for each fixed asset class.';
                    }
                    field(CopyToGLBudgetName; BudgetNameCode)
                    {
                        ApplicationArea = Suite;
                        Caption = 'Copy to G/L Budget Name';
                        TableRelation = "G/L Budget Name";
                        ToolTip = 'Specifies the general ledger budget name to copy the projected derogatory depreciation value to.';

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
                        ToolTip = 'Specifies if you want the batch job to automatically insert fixed asset entries with balancing accounts.';

                        trigger OnValidate()
                        begin
                            if BalAccount then
                                if BudgetNameCode = '' then
                                    Error(YouMustSpecifyErr, GLBudgetName.TableCaption());
                        end;
                    }
                    field(PrintPerFixedAsset; PrintDetails)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'Print per Fixed Asset';
                        ToolTip = 'Specifies if you want the report to print information separately for each fixed asset.';
                    }
                    field(ProjectedDisposal; ProjectedDisposalFlag)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'Projected Disposal';
                        ToolTip = 'Specifies whether to include information about the projected disposal of the fixed asset.';
                    }
                    field(PrintAmountsPerDate; PrintAmountsPerDateFlag)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'Print Amounts per Date';
                        ToolTip = 'Specifies if you want the program to include on the last page of the report a summary of the calculated depreciation for all assets.';
                    }
                    field(UseAccountingPeriod; UseAccountingPeriodFlag)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'Use Accounting Period';
                        ToolTip = 'Specifies if you want the periods between the starting date and the ending date to correspond to the accounting periods you have specified in the Accounting Period table. When you select this field, the Number of Days field is cleared.';

                        trigger OnValidate()
                        begin
                            if UseAccountingPeriodFlag then
                                PeriodLengthDays := 0;

                            UpdateReqForm();
                        end;
                    }
                }
            }
        }

        actions
        {
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
    }

    trigger OnPreReport()
    begin
        DeprBook.Get(DeprBookCode);
        InitDerogatoryDeprBook(DerogDeprBookCode, DeprBookCode);
        Year365Days := DeprBook."Fiscal Year 365 Days";
        if GroupTotalsOption = GroupTotalsOption::"FA Posting Group" then
            FAGenReport.SetFAPostingGroup("Fixed Asset", DeprBook.Code);
        FAGenReport.AppendFAPostingFilter("Fixed Asset", StartingDate, EndingDate);
        FAFilter := "Fixed Asset".GetFilters();
        DeprBookText := StrSubstNo('%1%2 %3', DeprBook.TableCaption(), ':', DeprBookCode);
        MakeGroupTotalText();
        ValidateDates();
        if PrintDetails then begin
            FANo := "Fixed Asset".FieldCaption("No.");
            FADescription := "Fixed Asset".FieldCaption(Description);
        end;
        if DeprBook."No. of Days in Fiscal Year" > 0 then
            DaysInFiscalYear := DeprBook."No. of Days in Fiscal Year"
        else
            DaysInFiscalYear := 360;
        if Year365Days then
            DaysInFiscalYear := 365;
        if PeriodLengthDays = 0 then
            PeriodLengthDays := DaysInFiscalYear;
        if (PeriodLengthDays <= 5) or (PeriodLengthDays > DaysInFiscalYear) then
            Error(NumberOfDaysMustNotBeGreaterThanErr, DaysInFiscalYear);
        FALedgEntry2."FA Posting Type" := FALedgEntry2."FA Posting Type"::Depreciation;
        DeprText := StrSubstNo('%1', FALedgEntry2."FA Posting Type");
        FALedgEntry2."FA Posting Type" := FALedgEntry2."FA Posting Type"::Derogatory;
        if DeprBook."Use Custom 1 Depreciation" then begin
            DeprText2 := DeprText;
            FALedgEntry2."FA Posting Type" := FALedgEntry2."FA Posting Type"::"Custom 1";
            Custom1Text := StrSubstNo('%1', FALedgEntry2."FA Posting Type");
            DeprCustom1Text := StrSubstNo('%1 %2 %3', DeprText, '+', Custom1Text);
        end;
        SalesPriceFieldname := FADeprBook.FieldCaption("Projected Proceeds on Disposal");
        GainLossFieldname := ProjectedGainLossTxt;
    end;

    var
        GLBudgetName: Record "G/L Budget Name";
        FASetup: Record "FA Setup";
        DeprBook: Record "Depreciation Book";
        FADeprBook: Record "FA Depreciation Book";
        FA: Record "Fixed Asset";
        FALedgEntry2: Record "FA Ledger Entry";
        TempFABufferProjection: Record "FA Buffer Projection" temporary;
        FAGenReport: Codeunit "FA General Report";
        CalculateDepr: Codeunit "Calculate Depreciation";
        FADateCalculation: Codeunit "FA Date Calculation";
        DepreciationCalculation: Codeunit "Depreciation Calculation";
        DeprBookCode: Code[10];
        DerogDeprBookCode: Code[10];
        FAFilter: Text;
        DeprBookText: Text;
        GroupCodeName: Text;
        GroupCodeName2: Text;
        GroupHeadLine: Text;
        DeprText: Text[50];
        DeprText2: Text[50];
        Custom1Text: Text[50];
        DeprCustom1Text: Text;
        IncludePostedFromFilter: Date;
        FANo: Text;
        FADescription: Text;
        GroupTotalsOption: Option " ","FA Class","FA Subclass","FA Location","Main Asset","Global Dimension 1","Global Dimension 2","FA Posting Group";
        BookValue: Decimal;
        NewFiscalYear: Date;
        EndFiscalYear: Date;
        DaysInFiscalYear: Integer;
        Custom1DeprUntil: Date;
        PeriodLengthDays: Integer;
        UseAccountingPeriodFlag: Boolean;
        StartingDate: Date;
        StartingDate2: Date;
        EndingDate: Date;
        EndingDate2: Date;
        PrintAmountsPerDateFlag: Boolean;
        UntilDate: Date;
        PrintDetails: Boolean;
        EntryAmounts: array[4] of Decimal;
        AssetAmounts: array[4] of Decimal;
        GroupAmounts: array[4] of Decimal;
        TotalAmounts: array[4] of Decimal;
        TotalBookValue: array[2] of Decimal;
        GroupTotalBookValue: Decimal;
        DateFromProjection: Date;
        DeprAmount: Decimal;
        Custom1Amount: Decimal;
        DerogNumberOfDays: Integer;
        Custom1NumberOfDays: Integer;
        DaysInFirstPeriodCount: Integer;
        Done: Boolean;
        NotFirstGroupTotal: Boolean;
        SalesPriceFieldname: Text;
        GainLossFieldname: Text[50];
        ProjectedDisposalFlag: Boolean;
        DoProjectedDisposal: Boolean;
        EntryPrinted: Boolean;
        GroupCodeNameTxt: Label ' ,FA Class,FA Subclass,FA Location,Main Asset,Global Dimension 1,Global Dimension 2,FA Posting Group';
        BudgetNameCode: Code[10];
        OldValue: Code[20];
        NewValue: Code[20];
        BalAccount: Boolean;
        YouMustSpecifyErr: Label 'You must specify %1.', Comment = '%1 - G/L Budget Name caption';
        TempDeprDate: Date;
        GroupTotalsInt: Integer;
        Year365Days: Boolean;
        NumberOfDaysMustNotBeGreaterThanErr: Label 'Number of Days must not be greater than %1 or less than 5.', Comment = '%1 - Number of days in fiscal year';
        ProjectedGainLossTxt: Label 'Projected Gain/Loss';
        GroupTotalTxt: Label 'Group Total';
        GroupTotalsTxt: Label 'Group Totals';
        HasBeenModifiedInFAErr: Label '%1 has been modified in fixed asset %2.', Comment = '%1 - FA Posting Group caption; %2- FA No.';
        YouMustCreateAccPeriodsErr: Label 'You must create accounting periods until %1 to use 365 days depreciation and ''Use Accounting Periods''.', Comment = '%1 - Date';
        NumberOfDaysCtrlEditable: Boolean;
        PageNoLbl: Label 'Page';
        FAProjectedValueLbl: Label 'Fixed Asset - Projected Value (Derogatory)';
        FAPostingDateLbl: Label 'FA Posting Date';
        BookValueLbl: Label 'Book Value';
        PostedEntryLbl: Label 'Posted Entry';
        TotalLbl: Label 'Total';
        ProjectedAmountsPerDateLbl: Label 'Projected Amounts per Date';
        FABufferProjectionFAPostingDateLbl: Label 'FA Posting Date';
        FABufferProjectionDepreciationLbl: Label 'Depreciation';
        FABufferProjectedValueLbl: Label 'Fixed Asset - Projected Value (Derogatory)';
        FALedgerEntryDerogAmount: Decimal;
        FALedgerEntryDerogBookValue: Decimal;
        FALedgerEntryDerogDiffBookValue: Decimal;
        DerogAmount: Decimal;
        DerogBookValue: Decimal;
        DerogDiffBookValue: Decimal;
        AssetDerogAmount: Decimal;
        AssetDerogBookValue: Decimal;
        AssetDerogDiffBookValue: Decimal;
        GroupDerogAmount: Decimal;
        GroupDerogBookValue: Decimal;
        GroupDerogDiffBookValue: Decimal;
        TotalDerogAmount: Decimal;
        TotalDerogBookValue: Decimal;
        TotalDerogDiffBookValue: Decimal;
        HasDerogatorySetup: Boolean;
        DerogAssetsIncluded: Boolean;
        TotalDerogAssetsIncluded: Boolean;
        FAPostingTypeLbl: Label 'FA Posting Type';
        NoofDepreciationDaysLbl: Label 'No. Of Depreciation Days';
        AmountLbl: Label 'Amount';
        DerogatoryAmountLbl: Label 'Amount (Derogatory Book)';
        DerogatoryBookValueLbl: Label 'Book Value (Derogatory Book)';
        DifferenceBookValueLbl: Label 'Difference (Book Value)';

    local procedure SkipRecord(): Boolean
    begin
        exit(
          "Fixed Asset".Inactive or
          (FADeprBook."Acquisition Date" = 0D) or
          (FADeprBook."Acquisition Date" > EndingDate) or
          (FADeprBook."Last Depreciation Date" > EndingDate) or
          (FADeprBook."Disposal Date" > 0D));
    end;

    local procedure TransferValues()
    begin
        // set base amount for the standard depreciation calculation (without Derogatory)
        FADeprBook.CalcFields("Book Value", Depreciation, "Custom 1", Derogatory);
        DateFromProjection := 0D;
        // if the asset has depreciations already, derogatory must be substracted from book value to avoid wrong derogatory calculation
        // no problem for standard assets because derogatory is then zero
        EntryAmounts[1] := FADeprBook."Book Value";
        if HasDerogatorySetup then
            EntryAmounts[1] -= FADeprBook.Derogatory;
        EntryAmounts[2] := FADeprBook."Custom 1";
        EntryAmounts[3] := DepreciationCalculation.DeprInFiscalYear("Fixed Asset"."No.", DeprBookCode, StartingDate);
        TotalBookValue[1] := TotalBookValue[1] + FADeprBook."Book Value";
        TotalBookValue[2] := TotalBookValue[2] + FADeprBook."Book Value";
        GroupTotalBookValue += FADeprBook."Book Value";

        TransferDerogatoryValues(FADeprBook."FA No.", EntryAmounts[1]);

        NewFiscalYear := FADateCalculation.GetFiscalYear(DeprBookCode, StartingDate);
        EndFiscalYear := FADateCalculation.CalculateDate(
            DepreciationCalculation.Yesterday(NewFiscalYear, Year365Days), DaysInFiscalYear, Year365Days);
        TempDeprDate := FADeprBook."Temp. Ending Date";

        if DeprBook."Use Custom 1 Depreciation" then
            Custom1DeprUntil := FADeprBook."Depr. Ending Date (Custom 1)"
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

    local procedure CalculateFirstDeprAmount(var Done1: Boolean)
    var
        FirstTime: Boolean;
    begin
        FirstTime := true;
        UntilDate := StartingDate;
        repeat
            if not FirstTime then
                GetNextDate();
            FirstTime := false;
            CalculateDepr.Calculate(
              DeprAmount, Custom1Amount, DerogNumberOfDays, Custom1NumberOfDays,
              "Fixed Asset"."No.", DeprBookCode, UntilDate, EntryAmounts, 0D, DaysInFirstPeriodCount);
            Done1 := (DeprAmount <> 0) or (Custom1Amount <> 0);
            CalculateDerogDepreciation(0D, DaysInFirstPeriodCount);
        until (UntilDate >= EndingDate) or Done1;
        EntryAmounts[3] :=
          DepreciationCalculation.DeprInFiscalYear("Fixed Asset"."No.", DeprBookCode, UntilDate);
    end;

    local procedure CalculateSecondDeprAmount(var Done1: Boolean)
    begin
        GetNextDate();
        CalculateDepr.Calculate(
          DeprAmount, Custom1Amount, DerogNumberOfDays, Custom1NumberOfDays,
          "Fixed Asset"."No.", DeprBookCode, UntilDate, EntryAmounts, DateFromProjection, 0);
        Done1 := CalculationDone(
            (DeprAmount <> 0) or (Custom1Amount <> 0), DateFromProjection);
        CalculateDerogDepreciation(DateFromProjection, 0);
    end;

    local procedure GetNextDate()
    var
        UntilDate2: Date;
    begin
        UntilDate2 := GetPeriodEndingDate(UseAccountingPeriodFlag, UntilDate, PeriodLengthDays);
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

    local procedure GetPeriodEndingDate(UseAccPeriod: Boolean; PeriodEndingDate: Date; var PeriodLength: Integer): Date
    var
        AccountingPeriod: Record "Accounting Period";
        UntilDate2: Date;
    begin
        if not UseAccPeriod then
            exit(FADateCalculation.CalculateDate(PeriodEndingDate, PeriodLength, Year365Days));
        AccountingPeriod.SetFilter(
          "Starting Date", '>=%1', DepreciationCalculation.ToMorrow(PeriodEndingDate, Year365Days) + 1);
        if AccountingPeriod.FindFirst() then begin
            if Date2DMY(AccountingPeriod."Starting Date", 1) <> 31 then
                UntilDate2 := DepreciationCalculation.Yesterday(AccountingPeriod."Starting Date", Year365Days)
            else
                UntilDate2 := AccountingPeriod."Starting Date" - 1;
            PeriodLength :=
              DepreciationCalculation.DeprDays(
                DepreciationCalculation.ToMorrow(PeriodEndingDate, Year365Days), UntilDate2, Year365Days);
            if (PeriodLength <= 5) or (PeriodLength > DaysInFiscalYear) then
                PeriodLength := DaysInFiscalYear;
            exit(UntilDate2);
        end;
        if Year365Days then
            Error(YouMustCreateAccPeriodsErr, DepreciationCalculation.ToMorrow(EndingDate, Year365Days) + 1);
        exit(FADateCalculation.CalculateDate(PeriodEndingDate, PeriodLength, Year365Days));
    end;

    local procedure MakeGroupTotalText()
    begin
        case GroupTotalsOption of
            GroupTotalsOption::"FA Class":
                GroupCodeName := "Fixed Asset".FieldCaption("FA Class Code");
            GroupTotalsOption::"FA Subclass":
                GroupCodeName := "Fixed Asset".FieldCaption("FA Subclass Code");
            GroupTotalsOption::"FA Location":
                GroupCodeName := "Fixed Asset".FieldCaption("FA Location Code");
            GroupTotalsOption::"Main Asset":
                GroupCodeName := "Fixed Asset".FieldCaption("Main Asset/Component");
            GroupTotalsOption::"Global Dimension 1":
                GroupCodeName := "Fixed Asset".FieldCaption("Global Dimension 1 Code");
            GroupTotalsOption::"Global Dimension 2":
                GroupCodeName := "Fixed Asset".FieldCaption("Global Dimension 2 Code");
            GroupTotalsOption::"FA Posting Group":
                GroupCodeName := "Fixed Asset".FieldCaption("FA Posting Group");
        end;
        if GroupCodeName <> '' then begin
            GroupCodeName2 := GroupCodeName;
            if GroupTotalsOption = GroupTotalsOption::"Main Asset" then
                GroupCodeName2 := StrSubstNo('%1', SelectStr(GroupTotalsOption + 1, GroupCodeNameTxt));
            GroupCodeName := StrSubstNo('%1%2 %3', GroupTotalsTxt, ':', GroupCodeName2);
        end;
    end;

    local procedure ValidateDates()
    begin
        FAGenReport.ValidateDeprDates(StartingDate, EndingDate);
        EndingDate2 := EndingDate;
        StartingDate2 := StartingDate;
    end;

    local procedure MakeGroupHeadLine()
    begin
        case GroupTotalsOption of
            GroupTotalsOption::"FA Class":
                GroupHeadLine := "Fixed Asset"."FA Class Code";
            GroupTotalsOption::"FA Subclass":
                GroupHeadLine := "Fixed Asset"."FA Subclass Code";
            GroupTotalsOption::"FA Location":
                GroupHeadLine := "Fixed Asset"."FA Location Code";
            GroupTotalsOption::"Main Asset":
                begin
                    FA."Main Asset/Component" := FA."Main Asset/Component"::"Main Asset";
                    GroupHeadLine :=
                      StrSubstNo('%1 %2', FA."Main Asset/Component", "Fixed Asset"."Component of Main Asset");
                    if "Fixed Asset"."Component of Main Asset" = '' then
                        GroupHeadLine := StrSubstNo('%1%2', GroupHeadLine, '*****');
                end;
            GroupTotalsOption::"Global Dimension 1":
                GroupHeadLine := "Fixed Asset"."Global Dimension 1 Code";
            GroupTotalsOption::"Global Dimension 2":
                GroupHeadLine := "Fixed Asset"."Global Dimension 2 Code";
            GroupTotalsOption::"FA Posting Group":
                GroupHeadLine := "Fixed Asset"."FA Posting Group";
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
        UpdateDerogatoryTotals();

        if BudgetNameCode <> '' then
            BudgetDepreciation.CopyProjectedValueToBudget(
              FADeprBook, BudgetNameCode, UntilDate, DeprAmount, Custom1Amount, BalAccount);

        if (UntilDate > 0D) or PrintAmountsPerDateFlag then begin
            TempFABufferProjection.Reset();
            if TempFABufferProjection.Find('+') then
                EntryNo := TempFABufferProjection."Entry No." + 1
            else
                EntryNo := 1;
            TempFABufferProjection.SetRange("FA Posting Date", UntilDate);
            if GroupTotalsOption <> GroupTotalsOption::" " then begin
                case GroupTotalsOption of
                    GroupTotalsOption::"FA Class":
                        CodeName := "Fixed Asset"."FA Class Code";
                    GroupTotalsOption::"FA Subclass":
                        CodeName := "Fixed Asset"."FA Subclass Code";
                    GroupTotalsOption::"FA Location":
                        CodeName := "Fixed Asset"."FA Location Code";
                    GroupTotalsOption::"Main Asset":
                        CodeName := "Fixed Asset"."Component of Main Asset";
                    GroupTotalsOption::"Global Dimension 1":
                        CodeName := "Fixed Asset"."Global Dimension 1 Code";
                    GroupTotalsOption::"Global Dimension 2":
                        CodeName := "Fixed Asset"."Global Dimension 2 Code";
                    GroupTotalsOption::"FA Posting Group":
                        CodeName := "Fixed Asset"."FA Posting Group";
                end;
                TempFABufferProjection.SetRange("Code Name", CodeName);
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
        GroupDerogAmount := 0;
        if NotFirstGroupTotal then begin
            TotalBookValue[1] := 0;
            GroupDerogBookValue := 0;
            GroupDerogDiffBookValue := 0;
        end else begin
            TotalBookValue[1] := EntryAmounts[1];
            GroupDerogBookValue := AssetDerogBookValue;
            GroupDerogDiffBookValue := AssetDerogDiffBookValue;
        end;
        NotFirstGroupTotal := true;
        DerogAssetsIncluded := false;
    end;

    local procedure GetDeprBasis(): Decimal
    var
        FALedgEntry: Record "FA Ledger Entry";
    begin
        FALedgEntry.SetCurrentKey("FA No.", "Depreciation Book Code", "Part of Book Value", "FA Posting Date");
        FALedgEntry.SetRange("FA No.", "Fixed Asset"."No.");
        FALedgEntry.SetRange("Depreciation Book Code", DeprBookCode);
        FALedgEntry.SetRange("Part of Book Value", true);
        FALedgEntry.SetRange("FA Posting Date", 0D, Custom1DeprUntil);
        FALedgEntry.CalcSums(Amount);
        exit(FALedgEntry.Amount);
    end;

    local procedure CalculateGainLoss()
    var
        CalculateDisposal: Codeunit "Calculate Disposal";
        EntAmounts: array[14] of Decimal;
        PrevAmount: array[2] of Decimal;
    begin
        PrevAmount[1] := AssetAmounts[3];
        PrevAmount[2] := AssetAmounts[4];

        CalculateDisposal.CalcGainLoss("Fixed Asset"."No.", DeprBookCode, EntAmounts);
        AssetAmounts[3] := FADeprBook."Projected Proceeds on Disposal";
        if EntAmounts[1] <> 0 then
            AssetAmounts[4] := EntAmounts[1]
        else
            AssetAmounts[4] := EntAmounts[2];
        AssetAmounts[4] :=
          AssetAmounts[4] + AssetAmounts[1] + AssetAmounts[2] - FADeprBook."Projected Proceeds on Disposal";

        GroupAmounts[3] += AssetAmounts[3] - PrevAmount[1];
        GroupAmounts[4] += AssetAmounts[4] - PrevAmount[2];
    end;

    local procedure CalculationDone(Done1: Boolean; FirstDepreciationDate: Date): Boolean
    var
        TableDeprCalculation: Codeunit "Table Depr. Calculation";
    begin
        if Done1 or
           (FADeprBook."Depreciation Method" <> FADeprBook."Depreciation Method"::"User-Defined")
        then
            exit(Done1);
        exit(
          TableDeprCalculation.GetTablePercent(
            DeprBookCode, FADeprBook."Depreciation Table Code",
            FADeprBook."First User-Defined Depr. Date", FirstDepreciationDate, UntilDate) = 0);
    end;

    local procedure UpdateReqForm()
    begin
        PageUpdateReqForm();
    end;

    local procedure PageUpdateReqForm()
    var
        DepBook: Record "Depreciation Book";
    begin
        if DeprBookCode <> '' then
            DepBook.Get(DeprBookCode);

        PeriodLengthDays := 0;
        if DepBook."Fiscal Year 365 Days" and not UseAccountingPeriodFlag then
            PeriodLengthDays := 365;
    end;

    [Scope('OnPrem')]
    procedure SetMandatoryFields(DepreciationBookCodeFrom: Code[10]; StartingDateFrom: Date; EndingDateFrom: Date)
    begin
        DeprBookCode := DepreciationBookCodeFrom;
        StartingDate := StartingDateFrom;
        EndingDate := EndingDateFrom;
    end;

    [Scope('OnPrem')]
    procedure SetPeriodFields(PeriodLengthFrom: Integer; DaysInFirstPeriodFrom: Integer; IncludePostedFromFrom: Date; UseAccountingPeriodFrom: Boolean)
    begin
        PeriodLengthDays := PeriodLengthFrom;
        DaysInFirstPeriodCount := DaysInFirstPeriodFrom;
        IncludePostedFromFilter := IncludePostedFromFrom;
        UseAccountingPeriodFlag := UseAccountingPeriodFrom;
    end;

    [Scope('OnPrem')]
    procedure SetTotalFields(GroupTotalsFrom: Option; PrintDetailsFrom: Boolean)
    begin
        GroupTotalsOption := GroupTotalsFrom;
        PrintDetails := PrintDetailsFrom;
    end;

    [Scope('OnPrem')]
    procedure SetBudgetField(BudgetNameCodeFrom: Code[10]; BalAccountFrom: Boolean; ProjectedDisposalFrom: Boolean; PrintAmountsPerDateFrom: Boolean)
    begin
        BudgetNameCode := BudgetNameCodeFrom;
        BalAccount := BalAccountFrom;
        ProjectedDisposalFlag := ProjectedDisposalFrom;
        PrintAmountsPerDateFlag := PrintAmountsPerDateFrom;
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
        UpdateDerogatoryTotals();
    end;

    local procedure CalculateDerogDepreciation(DateFromProjection2: Date; DaysInFirstPeriod2: Integer)
    var
        DerogEntryAmounts: array[4] of Decimal;
    begin
        if not HasDerogatorySetup then
            exit;
        DerogEntryAmounts[1] := DerogBookValue;
        CalculateDepr.Calculate(
          DerogAmount, Custom1Amount, DerogNumberOfDays, Custom1NumberOfDays,
          "Fixed Asset"."No.", DerogDeprBookCode, UntilDate, DerogEntryAmounts, DateFromProjection2, DaysInFirstPeriod2);
        DerogBookValue += DerogAmount;
        DerogDiffBookValue += DerogAmount - DeprAmount;
    end;

    local procedure UpdateDerogatoryTotals()
    begin
        if not HasDerogatorySetup then
            exit;
        AssetDerogAmount += DerogAmount;
        AssetDerogBookValue += DerogAmount;
        AssetDerogDiffBookValue += DerogAmount - DeprAmount;
        GroupDerogAmount += DerogAmount;
        GroupDerogBookValue += DerogAmount;
        GroupDerogDiffBookValue += DerogAmount - DeprAmount;
        TotalDerogAmount += DerogAmount;
        TotalDerogBookValue += DerogAmount;
        TotalDerogDiffBookValue += DerogAmount - DeprAmount;
    end;

    local procedure TransferDerogatoryValues(FANo1: Code[20]; BookVal: Decimal)
    var
        FADepreciationBook: Record "FA Depreciation Book";
    begin
        if HasDerogatorySetup then begin
            FADepreciationBook.Get(FANo1, DerogDeprBookCode);
            FADepreciationBook.CalcFields("Book Value");
            DerogBookValue := FADepreciationBook."Book Value";
            AssetDerogBookValue := FADepreciationBook."Book Value";
            GroupDerogBookValue += FADepreciationBook."Book Value";
            TotalDerogBookValue += FADepreciationBook."Book Value";
            DerogDiffBookValue := FADepreciationBook."Book Value" - BookVal;
            AssetDerogDiffBookValue := FADepreciationBook."Book Value" - BookVal;
            GroupDerogDiffBookValue += FADepreciationBook."Book Value" - BookVal;
            TotalDerogDiffBookValue += FADepreciationBook."Book Value" - BookVal;
        end else begin
            DerogBookValue := 0;
            AssetDerogBookValue := 0;
            DerogDiffBookValue := 0;
            AssetDerogDiffBookValue := 0;
        end;
        DerogAmount := 0;
        AssetDerogAmount := 0;
    end;

    local procedure InitDerogatoryDeprBook(var DerogDepreciationBookCode: Code[10]; DepreciationBookCode: Code[10])
    var
        DerogDepreciationBook: Record "Depreciation Book";
    begin
        TotalDerogAssetsIncluded := false;
        DerogDepreciationBookCode := '';
        DerogDepreciationBook.SetRange("Derogatory Calculation", DepreciationBookCode);
        if DerogDepreciationBook.FindFirst() then
            DerogDepreciationBookCode := DerogDepreciationBook.Code;
    end;

    local procedure IsDerogatorySetup(FANo1: Code[20]): Boolean
    var
        FADepreciationBook: Record "FA Depreciation Book";
    begin
        FADepreciationBook.SetRange("FA No.", FANo1);
        FADepreciationBook.SetRange("Depreciation Book Code", DerogDeprBookCode);
        exit(not FADepreciationBook.IsEmpty);
    end;

    local procedure GetFALedgerEntryDerogatoryAmount(FANo1: Code[20]; DepreciationBookCode: Code[10]; DocumentNo: Code[20]; FAPostingDate: Date): Decimal
    var
        FALedgerEntry: Record "FA Ledger Entry";
    begin
        FALedgerEntry.SetRange("FA No.", FANo1);
        FALedgerEntry.SetRange("Depreciation Book Code", DepreciationBookCode);
        FALedgerEntry.SetRange("Part of Book Value", true);
        FALedgerEntry.SetRange("Document No.", DocumentNo);
        FALedgerEntry.SetRange("FA Posting Date", FAPostingDate);
        FALedgerEntry.SetRange("FA Posting Type", FALedgerEntry."FA Posting Type"::Derogatory);
        if FALedgerEntry.FindFirst() then
            exit(FALedgerEntry.Amount);
        exit(0);
    end;
}

