// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.FixedAsset.Depreciation;

using Microsoft.Finance.GeneralLedger.Budget;
using Microsoft.FixedAssets.Depreciation;
using Microsoft.FixedAssets.FixedAsset;
using Microsoft.FixedAssets.Ledger;
using Microsoft.FixedAssets.Setup;
using Microsoft.Foundation.Period;
using System.Utilities;

report 10605 "FA - Projected Value GB"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/Reports/FAProjectedValue.rdlc';
    Caption = 'FA - Projected Value';

    dataset
    {
        dataitem("Fixed Asset"; "Fixed Asset")
        {
            DataItemTableView = sorting("No.");
            RequestFilterFields = "No.", "FA Class Code", "FA Subclass Code", "Budgeted Asset";
            column(COMPANYNAME; COMPANYPROPERTY.DisplayName())
            {
            }
            column(FORMAT_TODAY_0_4_; Format(Today, 0, 4))
            {
            }
            column(USERID; UserId)
            {
            }
            column(DeprBookText; DeprBookText)
            {
            }
            column(Fixed_Asset__TABLECAPTION__________FAFilter; "Fixed Asset".TableCaption + ': ' + FAFilter)
            {
            }
            column(FAFilter; FAFilter)
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
            column(PrintDetails; PrintDetails)
            {
            }
            column(GroupTotalsValue; GroupTotalsValue)
            {
            }
            column(Fixed_Asset__No__; "No.")
            {
            }
            column(Fixed_Asset_Description; Description)
            {
            }
            column(GroupAmounts_1_; GroupAmounts[1])
            {
                AutoFormatType = 1;
            }
            column(DeprText2; DeprText2)
            {
            }
            column(TotalBookValue_1_; TotalBookValue[1])
            {
                AutoFormatType = 1;
            }
            column(Text002__________GroupHeadLine; Text002Lbl + ': ' + GroupHeadLine)
            {
            }
            column(GroupAmounts_2_; GroupAmounts[2])
            {
                AutoFormatType = 1;
            }
            column(Custom1Text; Custom1Text)
            {
            }
            column(GroupAmounts_1____GroupAmounts_2_; GroupAmounts[1] + GroupAmounts[2])
            {
                AutoFormatType = 1;
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
            column(GroupAmounts_3_; GroupAmounts[3])
            {
                AutoFormatType = 1;
            }
            column(GroupAmounts_4_; GroupAmounts[4])
            {
                AutoFormatType = 1;
            }
            column(ProjectedDisposal; ProjectedDisposal)
            {
            }
            column(Fixed_Asset_FA_Class_Code; "FA Class Code")
            {
            }
            column(Fixed_Asset_FA_Subclass_Code; "FA Subclass Code")
            {
            }
            column(Fixed_Asset_Global_Dimension_1_Code; "Global Dimension 1 Code")
            {
            }
            column(Fixed_Asset_Global_Dimension_2_Code; "Global Dimension 2 Code")
            {
            }
            column(Fixed_Asset_FA_Location_Code; "FA Location Code")
            {
            }
            column(Fixed_Asset_Component_of_Main_Asset; "Component of Main Asset")
            {
            }
            column(Fixed_Asset_FA_Posting_Group; "FA Posting Group")
            {
            }
            column(CurrReport_PAGENOCaption; CurrReport_PAGENOCaptionLbl)
            {
            }
            column(Fixed_Asset___Projected_ValueCaption; Fixed_Asset___Projected_ValueCaptionLbl)
            {
            }
            column(FA_Ledger_Entry__FA_Posting_Date_Caption; FA_Ledger_Entry__FA_Posting_Date_CaptionLbl)
            {
            }
            column(FA_Ledger_Entry__FA_Posting_Type_Caption; "FA Ledger Entry".FieldCaption("FA Posting Type"))
            {
            }
            column(FA_Ledger_Entry_AmountCaption; "FA Ledger Entry".FieldCaption(Amount))
            {
            }
            column(BookValueCaption; BookValueCaptionLbl)
            {
            }
            column(FA_Ledger_Entry__No__of_Depreciation_Days_Caption; "FA Ledger Entry".FieldCaption("No. of Depreciation Days"))
            {
            }
            dataitem("FA Ledger Entry"; "FA Ledger Entry")
            {
                DataItemTableView = sorting("FA No.", "Depreciation Book Code", "FA Posting Date");
                column(FA_Ledger_Entry__FA_Posting_Date_; Format("FA Posting Date"))
                {
                }
                column(FA_Ledger_Entry__FA_Posting_Type_; "FA Posting Type")
                {
                }
                column(FA_Ledger_Entry_Amount; Amount)
                {
                }
                column(FA_Ledger_Entry__FA_No__; "FA No.")
                {
                }
                column(BookValue; BookValue)
                {
                    AutoFormatType = 1;
                }
                column(FA_Ledger_Entry__No__of_Depreciation_Days_; "No. of Depreciation Days")
                {
                }
                column(IncludePostedFrom; Format(IncludePostedFrom))
                {
                }
                column(FA_Ledger_Entry_Entry_No_; "Entry No.")
                {
                }
                column(Posted_EntryCaption; Posted_EntryCaptionLbl)
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
                column(EntryAmounts_1_____Custom1Amount; EntryAmounts[1] - Custom1Amount)
                {
                    AutoFormatType = 1;
                }
                column(UntilDate; Format(UntilDate))
                {
                }
                column(DeprText; DeprText)
                {
                }
                column(NumberOfDays; NumberOfDays)
                {
                }
                column(Fixed_Asset___No__; "Fixed Asset"."No.")
                {
                }
                column(Fixed_Asset___No___Control29; "Fixed Asset"."No.")
                {
                }
                column(UntilDate_Control30; Format(UntilDate))
                {
                }
                column(Custom1Text_Control31; Custom1Text)
                {
                }
                column(Custom1NumberOfDays; Custom1NumberOfDays)
                {
                }
                column(Custom1Amount; Custom1Amount)
                {
                    AutoFormatType = 1;
                }
                column(EntryAmounts_1_; EntryAmounts[1])
                {
                    AutoFormatType = 1;
                }
                column(DeprBook__Use_Custom_1_Depr_; DeprBook."Use Custom 1 Depreciation")
                {
                }
                column(ProjectedDepreciation_Number; Number)
                {
                }
                column(AssetAmounts_1_; AssetAmounts[1])
                {
                    AutoFormatType = 1;
                }
                column(Fixed_Asset___No___Control42; "Fixed Asset"."No.")
                {
                }
                column(Fixed_Asset__Description; "Fixed Asset".Description)
                {
                }
                column(DeprText2_Control51; DeprText2)
                {
                }
                column(EntryAmounts_1__Control50; EntryAmounts[1])
                {
                    AutoFormatType = 1;
                }
                column(Custom1Text_Control22; Custom1Text)
                {
                }
                column(AssetAmounts_2_; AssetAmounts[2])
                {
                    AutoFormatType = 1;
                }
                column(AssetAmounts_1____AssetAmounts_2_; AssetAmounts[1] + AssetAmounts[2])
                {
                    AutoFormatType = 1;
                }
                column(DeprCustom1Text_Control57; DeprCustom1Text)
                {
                }
                column(AssetAmounts_3_; AssetAmounts[3])
                {
                    AutoFormatType = 1;
                }
                column(AssetAmounts_4_; AssetAmounts[4])
                {
                    AutoFormatType = 1;
                }
                column(SalesPriceFieldname_Control81; SalesPriceFieldname)
                {
                }
                column(GainLossFieldname_Control82; GainLossFieldname)
                {
                }
                column(DoProjectedDisposal; DoProjectedDisposal)
                {
                }

                trigger OnAfterGetRecord()
                begin
                    if UntilDate >= EndingDate then
                        CurrReport.Break()
                        ;
                    if Number = 1 then begin
                        CalculateFirstDeprAmount(Done);
                        if FADeprBook."Book Value" <> 0 then
                            Done := Done or not EntryPrinted;
                    end else
                        CalculateSecondDeprAmount(Done);
                    if Done then
                        UpdateTotals()
                    else
                        CurrReport.Break();

                    if DoProjectedDisposal then
                        CalculateGainLoss();
                end;
            }

            trigger OnAfterGetRecord()
            begin
                if not FADeprBook.Get("No.", DeprBookCode) then
                    CurrReport.Skip();
                if SkipRecord() then
                    CurrReport.Skip();

                if GroupTotals = GroupTotals::"FA Posting Group" then
                    if "FA Posting Group" <> FADeprBook."FA Posting Group" then
                        Error(Text004Err, FieldCaption("FA Posting Group"), "No.");

                StartingDate := StartingDate2;
                EndingDate := EndingDate2;
                DoProjectedDisposal := false;
                EntryPrinted := false;
                if ProjectedDisposal and
                   (FADeprBook."Projected Disposal Date" > 0D) and
                   (FADeprBook."Projected Disposal Date" <= EndingDate)
                then begin
                    EndingDate := FADeprBook."Projected Disposal Date";
                    if StartingDate > EndingDate then
                        StartingDate := EndingDate;
                    DoProjectedDisposal := true;
                end;

                MakeGroupHeadLine();
                if GroupHeadLine <> GroupHeadLineOld then
                    InitGroupTotals();

                GroupHeadLineOld := GroupHeadLine;
                TransferValues();
                GroupTotalsValue := GroupTotals;
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
                end;
            end;
        }
        dataitem(ProjectionTotal; "Integer")
        {
            DataItemTableView = sorting(Number) where(Number = const(1));
            column(TotalBookValue_2_; TotalBookValue[2])
            {
                AutoFormatType = 1;
            }
            column(TotalAmounts_1_; TotalAmounts[1])
            {
                AutoFormatType = 1;
            }
            column(DeprText2_Control49; DeprText2)
            {
            }
            column(ProjectionTotal_Number; Number)
            {
            }
            column(Custom1Text_Control61; Custom1Text)
            {
            }
            column(TotalAmounts_2_; TotalAmounts[2])
            {
                AutoFormatType = 1;
            }
            column(DeprCustom1Text_Control59; DeprCustom1Text)
            {
            }
            column(TotalAmounts_1_____TotalAmounts_2_; TotalAmounts[1] + TotalAmounts[2])
            {
                AutoFormatType = 1;
            }
            column(SalesPriceFieldname_Control87; SalesPriceFieldname)
            {
            }
            column(GainLossFieldname_Control88; GainLossFieldname)
            {
            }
            column(TotalAmounts_3_; TotalAmounts[3])
            {
                AutoFormatType = 1;
            }
            column(TotalAmounts_4_; TotalAmounts[4])
            {
                AutoFormatType = 1;
            }
            column(ProjectedDisposal_Control1040010; ProjectedDisposal)
            {
            }
            column(TotalCaption; TotalCaptionLbl)
            {
            }
        }
        dataitem(Buffer; "Integer")
        {
            DataItemTableView = sorting(Number) where(Number = filter(1 ..));
            column(FORMAT_TODAY_0_4__Control68; Format(Today, 0, 4))
            {
            }
            column(USERID_Control72; UserId)
            {
            }
            column(COMPANYNAME_Control76; COMPANYPROPERTY.DisplayName())
            {
            }
            column(DeprBookText_Control77; DeprBookText)
            {
            }
            column(Custom1Text_Control64; Custom1Text)
            {
            }
            column(GroupCodeName2; GroupCodeName2)
            {
            }
            column(Buffer_Number; Number)
            {
            }
            column(FABufferProjection__FA_Posting_Date_; Format(FABufferProjection."FA Posting Date"))
            {
            }
            column(FABufferProjection_Depreciation; FABufferProjection.Depreciation)
            {
            }
            column(FABufferProjection__Custom_1_; FABufferProjection."Custom 1")
            {
            }
            column(FABufferProjection__Code_Name_; FABufferProjection."Code Name")
            {
            }
            column(CurrReport_PAGENO_Control73Caption; CurrReport_PAGENO_Control73CaptionLbl)
            {
            }
            column(Projected_Amounts_per_DateCaption; Projected_Amounts_per_DateCaptionLbl)
            {
            }
            column(FABufferProjection__FA_Posting_Date_Caption; FABufferProjection__FA_Posting_Date_CaptionLbl)
            {
            }
            column(FABufferProjection_DepreciationCaption; FABufferProjection_DepreciationCaptionLbl)
            {
            }
            column(Fixed_Asset___Projected_ValueCaption_Control91; Fixed_Asset___Projected_ValueCaption_Control91Lbl)
            {
            }

            trigger OnAfterGetRecord()
            begin
                if Number = 1 then begin
                    if not FABufferProjection.Find('-') then
                        CurrReport.Break();
                end else
                    if FABufferProjection.Next() = 0 then
                        CurrReport.Break();
            end;

            trigger OnPreDataItem()
            begin
                if not PrintAmountsPerDate then
                    CurrReport.Break();
                FABufferProjection.Reset();
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
                        ApplicationArea = Basic, Suite;
                        Caption = 'Depreciation Book';
                        TableRelation = "Depreciation Book";
                        ToolTip = 'Specifies the code for the depreciation book to be included in the report or batch job.';

                        trigger OnValidate()
                        begin
                            DeprBook.Get(DeprBookCode);
                            UseAccountingPeriod := DeprBook."Use Accounting Period";
                            if UseAccountingPeriod then begin
                                PeriodLength := 0;
                                NumberofDaysEnable := false;
                            end else begin
                                PeriodLength := 30;
                                NumberofDaysEnable := true;
                            end;
                        end;
                    }
                    field(FirstDepreciationDate; StartingDate)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'First Depreciation Date';
                        ToolTip = 'Specifies the date to be used as the first date in the period for which you want to calculate projected depreciation.';
                    }
                    field(LastDepreciationDate; EndingDate)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Last Depreciation Date';
                        ToolTip = 'Specifies the Fixed Asset posting date of the last posted depreciation.';
                    }
                    field(DaysInFirstPeriod; DaysInFirstPeriod)
                    {
                        ApplicationArea = Basic, Suite;
                        BlankZero = true;
                        Caption = 'No. of Days in First Period';
                        MinValue = 0;
                        ToolTip = 'Specifies the number of days that must be used for calculating the depreciation as of the first depreciation date, regardless of the actual number of days from the last depreciation entry. The number you enter in this field does not affect the total number of days from the starting date to the ending date.';
                    }
                    field("Number of Days"; PeriodLength)
                    {
                        ApplicationArea = Basic, Suite;
                        BlankZero = true;
                        Caption = 'Number of Days';
                        Enabled = NumberofDaysEnable;
                        MinValue = 0;
                        ToolTip = 'Specifies the length of the periods between the first depreciation date and the last depreciation date. The program then calculates depreciation for each period. If you leave this field blank, the program automatically sets the contents of this field to equal the number of days in a fiscal year, normally 360.';

                        trigger OnValidate()
                        begin
                            if PeriodLength > 0 then
                                UseAccountingPeriod := false;
                        end;
                    }
                    field(IncludePostedFrom; IncludePostedFrom)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Posted Entries From';
                        ToolTip = 'Specifies the fixed asset posting date from which the report includes all types of posted entries.';
                    }
                    field(GroupTotals; GroupTotals)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Group Totals';
                        OptionCaption = ' ,FA Class,FA Subclass,FA Location,Main Asset,Global Dimension 1,Global Dimension 2,FA Posting Group';
                        ToolTip = 'Specifies if you want the report to group fixed assets and print totals using the category defined in this field. For example, maintenance expenses for fixed assets can be shown for each fixed asset class.';
                    }
                    field(CopyToGLBudgetName; BudgetNameCode)
                    {
                        ApplicationArea = Basic, Suite;
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
                        ApplicationArea = Basic, Suite;
                        Caption = 'Insert Bal. Account';
                        ToolTip = 'Specifies if you want the batch job to automatically insert fixed asset entries with balancing accounts.';

                        trigger OnValidate()
                        begin
                            if BalAccount then
                                if BudgetNameCode = '' then
                                    Error(Text006Err, GLBudgetName.TableCaption());
                        end;
                    }
                    field(PrintPerFixedAsset; PrintDetails)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Print per Fixed Asset';
                        ToolTip = 'Specifies if you want the report to print information separately for each fixed asset.';
                    }
                    field(ProjectedDisposal; ProjectedDisposal)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Projected Disposal';
                        ToolTip = 'Specifies if you want the report to include projected disposals: the contents of the Projected Proceeds on Disposal field and the Projected Disposal Date field on the FA depreciation book.';
                    }
                    field(PrintAmountsPerDate; PrintAmountsPerDate)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Print Amounts per Date';
                        ToolTip = 'Specifies if you want the program to include on the last page of the report a summary of the calculated depreciation for all assets.';
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnInit()
        begin
            NumberofDaysEnable := true;
        end;

        trigger OnOpenPage()
        begin
            if DeprBookCode = '' then begin
                FASetup.Get();
                DeprBookCode := FASetup."Default Depr. Book";
            end;

            DeprBook.Get(DeprBookCode);
            UseAccountingPeriod := DeprBook."Use Accounting Period";
            if UseAccountingPeriod then begin
                PeriodLength := 0;
                NumberofDaysEnable := false;
            end else
                // PeriodLength := 30;
                NumberofDaysEnable := true;
        end;
    }

    labels
    {
    }

    trigger OnPreReport()
    begin
        DeprBook.Get(DeprBookCode);
        Year365Days := DeprBook."Fiscal Year 365 Days";
        if GroupTotals = GroupTotals::"FA Posting Group" then
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
        if PeriodLength = 0 then
            PeriodLength := DaysInFiscalYear;
        if (PeriodLength <= 5) or (PeriodLength > DaysInFiscalYear) then
            Error(
              Text000Err, DaysInFiscalYear);
        FALedgEntry2."FA Posting Type" := FALedgEntry2."FA Posting Type"::Depreciation;
        DeprText := StrSubstNo('%1', FALedgEntry2."FA Posting Type");
        if DeprBook."Use Custom 1 Depreciation" then begin
            DeprText2 := DeprText;
            FALedgEntry2."FA Posting Type" := FALedgEntry2."FA Posting Type"::"Custom 1";
            Custom1Text := StrSubstNo('%1', FALedgEntry2."FA Posting Type");
            DeprCustom1Text := StrSubstNo('%1 %2 %3', DeprText, '+', Custom1Text);
        end;
        SalesPriceFieldname := FADeprBook.FieldCaption("Projected Proceeds on Disposal");
        GainLossFieldname := Text001Txt;
    end;

    var
        GLBudgetName: Record "G/L Budget Name";
        FASetup: Record "FA Setup";
        DeprBook: Record "Depreciation Book";
        FADeprBook: Record "FA Depreciation Book";
        FA: Record "Fixed Asset";
        FALedgEntry2: Record "FA Ledger Entry";
        FABufferProjection: Record "FA Buffer Projection" temporary;
        AccPeriod: Record "Accounting Period";
        FAGenReport: Codeunit "FA General Report";
        CalculateDepr: Codeunit "Calculate Depreciation";
        FADateCalc: Codeunit "FA Date Calculation";
        DepreciationCalc: Codeunit "Depreciation Calculation";
        DeprBookCode: Code[10];
        FAFilter: Text;
        DeprBookText: Text;
        GroupCodeName: Text;
        GroupCodeName2: Text;
        GroupHeadLine: Text;
        GroupHeadLineOld: Text;
        DeprText: Text;
        DeprText2: Text;
        Custom1Text: Text;
        DeprCustom1Text: Text;
        IncludePostedFrom: Date;
        FANo: Text;
        FADescription: Text;
        GroupTotals: Option " ","FA Class","FA Subclass","FA Location","Main Asset","Global Dimension 1","Global Dimension 2","FA Posting Group";
        BookValue: Decimal;
        NewFiscalYear: Date;
        EndFiscalYear: Date;
        DaysInFiscalYear: Integer;
        Custom1DeprUntil: Date;
        PeriodLength: Integer;
        UseAccountingPeriod: Boolean;
        StartingDate: Date;
        StartingDate2: Date;
        EndingDate: Date;
        EndingDate2: Date;
        PrintAmountsPerDate: Boolean;
        UntilDate: Date;
        PrintDetails: Boolean;
        EntryAmounts: array[4] of Decimal;
        AssetAmounts: array[4] of Decimal;
        GroupAmounts: array[4] of Decimal;
        TotalAmounts: array[4] of Decimal;
        TotalBookValue: array[2] of Decimal;
        DateFromProjection: Date;
        DeprAmount: Decimal;
        Custom1Amount: Decimal;
        NumberOfDays: Integer;
        Custom1NumberOfDays: Integer;
        DaysInFirstPeriod: Integer;
        GroupTotalsValue: Integer;
        Done: Boolean;
        NotFirstGroupTotal: Boolean;
        SalesPriceFieldname: Text;
        GainLossFieldname: Text;
        ProjectedDisposal: Boolean;
        DoProjectedDisposal: Boolean;
        EntryPrinted: Boolean;
        Text005Txt: Label ' ,FA Class,FA Subclass,FA Location,Main Asset,Global Dimension 1,Global Dimension 2,FA Posting Group';
        Text000Err: Label 'Number of Days must not be greater than %1 or less than 5.';
        Text001Txt: Label 'Projected Gain/Loss';
        Text002Lbl: Label 'Group Total';
        Text003Txt: Label 'Group Totals';
        Text004Err: Label '%1 has been modified in fixed asset %2.';
        BudgetNameCode: Code[10];
        BalAccount: Boolean;
        Text006Err: Label 'You must specify %1.';
        Year365Days: Boolean;
        NumberofDaysEnable: Boolean;
        CurrReport_PAGENOCaptionLbl: Label 'Page';
        Fixed_Asset___Projected_ValueCaptionLbl: Label 'Fixed Asset - Projected Value';
        FA_Ledger_Entry__FA_Posting_Date_CaptionLbl: Label 'FA Posting Date';
        BookValueCaptionLbl: Label 'Book Value';
        Posted_EntryCaptionLbl: Label 'Posted Entry';
        TotalCaptionLbl: Label 'Total';
        CurrReport_PAGENO_Control73CaptionLbl: Label 'Page';
        Projected_Amounts_per_DateCaptionLbl: Label 'Projected Amounts per Date';
        FABufferProjection__FA_Posting_Date_CaptionLbl: Label 'FA Posting Date';
        FABufferProjection_DepreciationCaptionLbl: Label 'Depreciation';
        Fixed_Asset___Projected_ValueCaption_Control91Lbl: Label 'Fixed Asset - Projected Value';

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
        FADeprBook.CalcFields("Book Value", Depreciation, "Custom 1");
        DateFromProjection := 0D;
        EntryAmounts[1] := FADeprBook."Book Value";
        EntryAmounts[2] := FADeprBook."Custom 1";
        EntryAmounts[3] :=
          DepreciationCalc.DeprInFiscalYear("Fixed Asset"."No.", DeprBookCode, StartingDate);
        TotalBookValue[1] := TotalBookValue[1] + FADeprBook."Book Value";
        TotalBookValue[2] := TotalBookValue[2] + FADeprBook."Book Value";
        NewFiscalYear := FADateCalc.GetFiscalYear(DeprBookCode, StartingDate);

        if DeprBook."Use Accounting Period" then begin
            AccPeriod.SetFilter("Starting Date", '<=%1', StartingDate);
            AccPeriod.FindLast();
            EndFiscalYear := AccPeriodEndDate(AccPeriod."Starting Date");
        end else
            EndFiscalYear := FADateCalc.CalculateDate(
                DepreciationCalc.Yesterday(NewFiscalYear, Year365Days, DeprBook."Use Accounting Period"),
                DaysInFiscalYear, Year365Days);
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

    local procedure CalculateFirstDeprAmount(var Done: Boolean)
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
              DeprAmount, Custom1Amount, NumberOfDays, Custom1NumberOfDays,
              "Fixed Asset"."No.", DeprBookCode, UntilDate, EntryAmounts, 0D, DaysInFirstPeriod);
            Done := (DeprAmount <> 0) or (Custom1Amount <> 0);
        until (UntilDate >= EndingDate) or Done;
        EntryAmounts[3] :=
          DepreciationCalc.DeprInFiscalYear("Fixed Asset"."No.", DeprBookCode, UntilDate);
    end;

    local procedure CalculateSecondDeprAmount(var Done: Boolean)
    begin
        GetNextDate();
        CalculateDepr.Calculate(
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
        if (UntilDate < EndFiscalYear) and (UntilDate2 > EndFiscalYear) then
            UntilDate2 := EndFiscalYear;

        if UntilDate = EndFiscalYear then begin
            EntryAmounts[3] := 0;
            NewFiscalYear := DepreciationCalc.ToMorrow(EndFiscalYear, Year365Days, DeprBook."Use Accounting Period");
            if DeprBook."Use Accounting Period" then begin
                AccPeriod.SetFilter("Starting Date", '<= %1', StartingDate);
                AccPeriod.FindLast();
                EndFiscalYear := AccPeriodEndDate(AccPeriod."Starting Date");
            end else
                EndFiscalYear := FADateCalc.CalculateDate(EndFiscalYear, DaysInFiscalYear, Year365Days);
        end;

        DateFromProjection := DepreciationCalc.ToMorrow(UntilDate, Year365Days, DeprBook."Use Accounting Period");
        UntilDate := UntilDate2;
        if UntilDate >= EndingDate then
            UntilDate := EndingDate;
    end;

    local procedure GetPeriodEndingDate(UseAccountingPeriod: Boolean; PeriodEndingDate: Date; var PeriodLength: Integer): Date
    var
        AccountingPeriod: Record "Accounting Period";
        UntilDate2: Date;
    begin
        if not UseAccountingPeriod then
            exit(FADateCalc.CalculateDate(PeriodEndingDate, PeriodLength, Year365Days));
        AccountingPeriod.SetFilter(
          "Starting Date", '>=%1', DepreciationCalc.ToMorrow(PeriodEndingDate, Year365Days, DeprBook."Use Accounting Period") + 1);
        if AccountingPeriod.FindFirst() then begin
            UntilDate2 := DepreciationCalc.Yesterday(AccountingPeriod."Starting Date", Year365Days, DeprBook."Use Accounting Period");
            PeriodLength :=
              DepreciationCalc.DeprDays(
                DepreciationCalc.ToMorrow(PeriodEndingDate, Year365Days, DeprBook."Use Accounting Period"), UntilDate2,
                Year365Days, DeprBook."Use Accounting Period");
            if (PeriodLength <= 5) or (PeriodLength > DaysInFiscalYear) then
                PeriodLength := DaysInFiscalYear;
            exit(UntilDate2);
        end;
        exit(FADateCalc.CalculateDate(PeriodEndingDate, PeriodLength, Year365Days));
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
        end;
        if GroupCodeName <> '' then begin
            GroupCodeName2 := GroupCodeName;
            if GroupTotals = GroupTotals::"Main Asset" then
                GroupCodeName2 := StrSubstNo('%1', SelectStr(GroupTotals + 1, Text005Txt));
            GroupCodeName := StrSubstNo('%1%2 %3', Text003Txt, ':', GroupCodeName2);
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
        case GroupTotals of
            GroupTotals::"FA Class":
                GroupHeadLine := "Fixed Asset"."FA Class Code";
            GroupTotals::"FA Subclass":
                GroupHeadLine := "Fixed Asset"."FA Subclass Code";
            GroupTotals::"FA Location":
                GroupHeadLine := "Fixed Asset"."FA Location Code";
            GroupTotals::"Main Asset":
                begin
                    FA."Main Asset/Component" := FA."Main Asset/Component"::"Main Asset";
                    GroupHeadLine :=
                      StrSubstNo('%1 %2', FA."Main Asset/Component", "Fixed Asset"."Component of Main Asset");
                    if "Fixed Asset"."Component of Main Asset" = '' then
                        GroupHeadLine := StrSubstNo('%1%2', GroupHeadLine, '*****');
                end;
            GroupTotals::"Global Dimension 1":
                GroupHeadLine := "Fixed Asset"."Global Dimension 1 Code";
            GroupTotals::"Global Dimension 2":
                GroupHeadLine := "Fixed Asset"."Global Dimension 2 Code";
            GroupTotals::"FA Posting Group":
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
        if BudgetNameCode <> '' then
            BudgetDepreciation.CopyProjectedValueToBudget(
              FADeprBook, BudgetNameCode, UntilDate, DeprAmount, Custom1Amount, BalAccount);

        if (UntilDate > 0D) or PrintAmountsPerDate then begin
            FABufferProjection.Reset();
            if FABufferProjection.Find('+') then
                EntryNo := FABufferProjection."Entry No." + 1
            else
                EntryNo := 1;
            FABufferProjection.SetRange("FA Posting Date", UntilDate);
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
                end;
                FABufferProjection.SetRange("Code Name", CodeName);
            end;
            if not FABufferProjection.Find('=><') then begin
                FABufferProjection.Init();
                FABufferProjection."Code Name" := CodeName;
                FABufferProjection."FA Posting Date" := UntilDate;
                FABufferProjection."Entry No." := EntryNo;
                FABufferProjection.Depreciation := DeprAmount;
                FABufferProjection."Custom 1" := Custom1Amount;
                FABufferProjection.Insert();
            end else begin
                FABufferProjection.Depreciation := FABufferProjection.Depreciation + DeprAmount;
                FABufferProjection."Custom 1" := FABufferProjection."Custom 1" + Custom1Amount;
                FABufferProjection.Modify();
            end;
        end;
    end;

    local procedure InitGroupTotals()
    begin
        GroupAmounts[1] := 0;
        GroupAmounts[2] := 0;
        GroupAmounts[3] := 0;
        GroupAmounts[4] := 0;
        if NotFirstGroupTotal then
            TotalBookValue[1] := 0
        else
            TotalBookValue[1] := EntryAmounts[1];
        NotFirstGroupTotal := true;
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
        EntryAmounts: array[14] of Decimal;
    begin
        CalculateDisposal.CalcGainLoss("Fixed Asset"."No.", DeprBookCode, EntryAmounts);
        AssetAmounts[3] := FADeprBook."Projected Proceeds on Disposal";
        if EntryAmounts[1] <> 0 then
            AssetAmounts[4] := EntryAmounts[1]
        else
            AssetAmounts[4] := EntryAmounts[2];
        AssetAmounts[4] :=
          AssetAmounts[4] + AssetAmounts[1] + AssetAmounts[2] - FADeprBook."Projected Proceeds on Disposal";
        GroupAmounts[3] := GroupAmounts[3] + AssetAmounts[3];
        GroupAmounts[4] := GroupAmounts[4] + AssetAmounts[4];
        TotalAmounts[3] := TotalAmounts[3] + AssetAmounts[3];
        TotalAmounts[4] := TotalAmounts[4] + AssetAmounts[4];
    end;

    local procedure CalculationDone(Done: Boolean; FirstDeprDate: Date): Boolean
    var
        TableDeprCalc: Codeunit "Table Depr. Calculation";
    begin
        if Done or
           (FADeprBook."Depreciation Method" <> FADeprBook."Depreciation Method"::"User-Defined")
        then
            exit(Done);
        exit(
          TableDeprCalc.GetTablePercent(
            DeprBookCode, FADeprBook."Depreciation Table Code",
            FADeprBook."First User-Defined Depr. Date", FirstDeprDate, UntilDate) = 0);
    end;

    local procedure AccPeriodEndDate(UseStartDate: Date): Date
    var
        AccountingPeriod2: Record "Accounting Period";
    begin
        AccountingPeriod2."Starting Date" := UseStartDate;
        if AccountingPeriod2.Find('>') then
            exit(AccountingPeriod2."Starting Date" - 1);
        exit(DMY2Date(31, 12, 9999));
    end;
}

