// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.FixedAssets;

using Microsoft.FixedAssets.Depreciation;
using Microsoft.FixedAssets.FixedAsset;
using Microsoft.FixedAssets.Maintenance;
using Microsoft.FixedAssets.Setup;

report 31249 "Maintenance - Analysis CZF"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Src/Reports/MaintenanceAnalysis.rdl';
    ApplicationArea = FixedAssets;
    Caption = 'Fixed Asset Maintenance Analysis';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem("Fixed Asset"; "Fixed Asset")
        {
            RequestFilterFields = "No.", "FA Class Code", "FA Subclass Code";
            column(CompanyName; CompanyProperty.DisplayName())
            {
            }
            column(TodayFormatted; Format(Today, 0, 4))
            {
            }
            column(DeprBookText; DeprBookText)
            {
            }
            column(FATablecaptionFAFilter; TableCaption + ': ' + FAFilter)
            {
            }
            column(HeadLineText1; HeadLineText[1])
            {
            }
            column(HeadLineText2; HeadLineText[2])
            {
            }
            column(HeadLineText3; HeadLineText[3])
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
            column(PrintDetails; PrintDetails)
            {
            }
            column(GroupHeadLine; GroupHeadLine)
            {
            }
            column(No_FA; "No.")
            {
            }
            column(Description_FA; Description)
            {
            }
            column(Amounts1; Amounts[1])
            {
                AutoFormatType = 1;
            }
            column(Amounts2; Amounts[2])
            {
                AutoFormatType = 1;
            }
            column(Amounts3; Amounts[3])
            {
                AutoFormatType = 1;
            }
            column(GroupAmounts1; GroupAmounts[1])
            {
                AutoFormatType = 1;
            }
            column(GroupAmounts2; GroupAmounts[2])
            {
                AutoFormatType = 1;
            }
            column(GroupAmounts3; GroupAmounts[3])
            {
                AutoFormatType = 1;
            }
            column(GroupTotalGroupHeadLine; GroupTotalTxt + ': ' + GroupHeadLine)
            {
            }
            column(TotalAmounts1; TotalAmounts[1])
            {
                AutoFormatType = 1;
            }
            column(TotalAmounts2; TotalAmounts[2])
            {
                AutoFormatType = 1;
            }
            column(TotalAmounts3; TotalAmounts[3])
            {
                AutoFormatType = 1;
            }
            column(CurrReportPageNoCaption; CurrReportPageNoCaptionLbl)
            {
            }
            column(MaintenanceAnalysisCaption; MaintenanceAnalysisCaptionLbl)
            {
            }
            column(TotalCaption; TotalCaptionLbl)
            {
            }

            trigger OnAfterGetRecord()
            begin
                if Inactive then
                    CurrReport.Skip();
                if not FADepreciationBook.Get("No.", DeprBookCode) then
                    CurrReport.Skip();

                if GroupTotals = GroupTotals::"FA Posting Group" then
                    if "FA Posting Group" <> FADepreciationBook."FA Posting Group" then
                        Error(HasBeenModifiedInFAErr, FieldCaption("FA Posting Group"), "No.");
                if GroupTotals = GroupTotals::"Tax Depreciation Group" then
                    if "Tax Deprec. Group Code CZF" <> FADepreciationBook."Tax Deprec. Group Code CZF" then
                        Error(HasBeenModifiedInFAErr, FieldCaption("Tax Deprec. Group Code CZF"), "No.");

                MaintenanceLedgerEntry.SetRange("FA No.", "No.");
                Amounts[1] := CalculateAmount(MaintenanceCode1, Period1);
                Amounts[2] := CalculateAmount(MaintenanceCode2, Period2);
                Amounts[3] := CalculateAmount(MaintenanceCode3, Period3);
                if (Amounts[1] = 0) and (Amounts[2] = 0) and (Amounts[3] = 0) then
                    CurrReport.Skip();
                for i := 1 to 3 do
                    GroupAmounts[i] := 0;
                MakeGroupHeadLine();
            end;

            trigger OnPreDataItem()
            begin
                case GroupTotals of
                    GroupTotals::"FA Class":
                        SetCurrentKey("FA Class Code");
                    GroupTotals::"FA SubClass":
                        SetCurrentKey("FA Subclass Code");
                    GroupTotals::"Main Asset":
                        SetCurrentKey("Component of Main Asset");
                    GroupTotals::"Global Dimension 1":
                        SetCurrentKey("Global Dimension 1 Code");
                    GroupTotals::"FA Location":
                        SetCurrentKey("FA Location Code");
                    GroupTotals::"Global Dimension 2":
                        SetCurrentKey("Global Dimension 2 Code");
                    GroupTotals::"FA Posting Group":
                        SetCurrentKey("FA Posting Group");
                    GroupTotals::"Tax Depreciation Group":
                        SetCurrentKey("Tax Deprec. Group Code CZF");
                end;
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
                    field(DeprBookCodeCZF; DeprBookCode)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'Depreciation Book';
                        TableRelation = "Depreciation Book";
                        ToolTip = 'Specifies the code for the depreciation book to be included in the report or batch job.';
                    }
                    field(DateSelectionCZF; DateSelection)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'Date Selection';
                        ToolTip = 'Specifies the date options that can be used in the report. You can choose between the posting date and the fixed asset posting date.';
                    }
                    field(StartingDateCZF; StartingDate)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'Starting Date';
                        ToolTip = 'Specifies the date when you want the report to start.';
                    }
                    field(EndingDateCZF; EndingDate)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'Ending Date';
                        ToolTip = 'Specifies the last date to be included in the report.';
                    }
                    field(AmountField1; MaintenanceCode1)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'Amount Field 1';
                        TableRelation = Maintenance;
                        ToolTip = 'Specifies an Amount field that you use to create your own analysis.';
                    }
                    field(Period1CZF; Period1)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'Period 1';
                        ToolTip = 'Specifies how the report determines the nature of the amounts in the first amount field. (Blank): The amounts consist of fixed asset ledger entries with the posting type that corresponds to the option in the amount field. Disposal: The amounts consists of fixed asset ledger entries with the posting type that corresponds to the option in the amount field if these entries have been posted to disposal accounts. Bal. Disposal: The amounts consist of fixed asset ledger entries with the posting type that corresponds to the option in the amount field if these entries have been posted to balancing disposal accounts.';
                    }
                    field(AmountField2; MaintenanceCode2)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'Amount Field 2';
                        TableRelation = Maintenance;
                        ToolTip = 'Specifies an Amount field that you use to create your own analysis.';
                    }
                    field(Period2CZF; Period2)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'Period 2';
                        ToolTip = 'Specifies how the report determines the nature of the amounts in the second amount field. (Blank): The amounts consist of fixed asset ledger entries with the posting type that corresponds to the option in the amount field. Disposal: The amounts consists of fixed asset ledger entries with the posting type that corresponds to the option in the amount field if these entries have been posted to disposal accounts. Bal. Disposal: The amounts consist of fixed asset ledger entries with the posting type that corresponds to the option in the amount field if these entries have been posted to balancing disposal accounts.';
                    }
                    field(AmountField3; MaintenanceCode3)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'Amount Field 3';
                        TableRelation = Maintenance;
                        ToolTip = 'Specifies an Amount field that you use to create your own analysis.';
                    }
                    field(Period3CZF; Period3)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'Period 3';
                        ToolTip = 'Specifies how the report determines the nature of the amounts in the third amount field. (Blank): The amounts consist of fixed asset ledger entries with the posting type that corresponds to the option in the amount field. Disposal: The amounts consists of fixed asset ledger entries with the posting type that corresponds to the option in the amount field if these entries have been posted to disposal accounts. Bal. Disposal: The amounts consist of fixed asset ledger entries with the posting type that corresponds to the option in the amount field if these entries have been posted to balancing disposal accounts.';
                    }
                    field(GroupTotalsCZF; GroupTotals)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'Group Totals';
                        ToolTip = 'Specifies if you want the report to group fixed assets and print totals using the category defined in this field. For example, maintenance expenses for fixed assets can be shown for each fixed asset class.';
                    }
                    field(PrintPerFixedAsset; PrintDetails)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'Print per Fixed Asset';
                        ToolTip = 'Specifies if you want the report to print information separately for each fixed asset.';
                    }
                }
            }
        }

        trigger OnOpenPage()
        begin
            if DeprBookCode = '' then begin
                FASetup.Get();
                DeprBookCode := FASetup."Default Depr. Book";
            end;
        end;
    }

    trigger OnPreReport()
    begin
        DepreciationBook.Get(DeprBookCode);
        if GroupTotals = GroupTotals::"FA Posting Group" then
            FAGeneralReport.SetFAPostingGroup("Fixed Asset", DepreciationBook.Code);
        if GroupTotals = GroupTotals::"Tax Depreciation Group" then
            FAGeneralReportCZF.SetFATaxDeprGroup("Fixed Asset", DepreciationBook.Code);
        if DateSelection = DateSelection::"FA Posting Date" then
            FAGeneralReport.AppendFAPostingFilter("Fixed Asset", StartingDate, EndingDate);

        FAFilter := "Fixed Asset".GetFilters;

        if DateSelection = DateSelection::"Posting Date" then
            FAGeneralReport.AppendPostingDateFilter(FAFilter, StartingDate, EndingDate);

        DeprBookText := StrSubstNo(TwoPlaceholdersTok, DepreciationBook.TableCaption, DeprBookCode);
        MakeGroupTotalText();
        ValidateDates();
        MakeAmountHeadLine(1, MaintenanceCode1, Period1);
        MakeAmountHeadLine(2, MaintenanceCode2, Period2);
        MakeAmountHeadLine(3, MaintenanceCode3, Period3);
        if DateSelection = DateSelection::"Posting Date" then
            MaintenanceLedgerEntry.SetCurrentKey(
              "FA No.", "Depreciation Book Code", "Maintenance Code", "Posting Date")
        else
            MaintenanceLedgerEntry.SetCurrentKey(
              "FA No.", "Depreciation Book Code", "Maintenance Code", "FA Posting Date");
        MaintenanceLedgerEntry.SetRange("Depreciation Book Code", DeprBookCode);
        if PrintDetails then begin
            FANo := "Fixed Asset".FieldCaption("No.");
            FADescription := "Fixed Asset".FieldCaption(Description);
        end;
    end;

    var
        FASetup: Record "FA Setup";
        DepreciationBook: Record "Depreciation Book";
        FADepreciationBook: Record "FA Depreciation Book";
        MaintenanceLedgerEntry: Record "Maintenance Ledger Entry";
        FAGeneralReport: Codeunit "FA General Report";
        FAGeneralReportCZF: Codeunit "FA General Report CZF";
        FAFilter, FANo, FADescription, GroupCodeName, DeprBookText, GroupHeadLine : Text;
        GroupTotals: Enum "FA Analysis Group CZF";
        GroupAmounts, TotalAmounts, Amounts : array[3] of Decimal;
        HeadLineText: array[3] of Text;
        MaintenanceCode1, MaintenanceCode2, MaintenanceCode3 : Code[10];
        Period1, Period2, Period3 : Enum "FA Analysis Period CZF";
        StartingDate: Date;
        EndingDate: Date;
        DeprBookCode: Code[10];
        PrintDetails: Boolean;
        DateSelection: Enum "FA Analysis Date CZF";
        i: Integer;
        CurrReportPageNoCaptionLbl: Label 'Page';
        MaintenanceAnalysisCaptionLbl: Label 'Maintenance - Analysis';
        TotalCaptionLbl: Label 'Total';
        GroupTotalTxt: Label 'Group Total';
        GroupTotalsTxt: Label 'Group Totals';
        SpecifyStartingAndEndingDateErr: Label 'You must specify the starting date and the ending date.';
        StartingDateIsLaterErr: Label 'The starting date is later than the ending date.';
        SpecifyStartingDateErr: Label 'The starting date must be specified when you use the option %1.', Comment = '%1 = Period';
        HasBeenModifiedInFAErr: Label '%1 has been modified in fixed asset %2', Comment = '%1 = FieldCaption, %2 = Fixed Asset No.';
        PeriodsTxt: Label 'before Starting Date,Net Change,at Ending Date';
        GroupsTxt: Label ' ,FA Class,FA Subclass,FA Location,Main Asset,Global Dimension 1,Global Dimension 2,FA Posting Group,Tax Depreciation Group';
        TwoPlaceholdersTok: Label '%1 %2', Locked = true;

    local procedure MakeGroupTotalText()
    begin
        case GroupTotals of
            GroupTotals::"FA Class":
                GroupCodeName := "Fixed Asset".FieldCaption("FA Class Code");
            GroupTotals::"FA SubClass":
                GroupCodeName := "Fixed Asset".FieldCaption("FA Subclass Code");
            GroupTotals::"Main Asset":
                GroupCodeName := "Fixed Asset".FieldCaption("Main Asset/Component");
            GroupTotals::"Global Dimension 1":
                GroupCodeName := "Fixed Asset".FieldCaption("Global Dimension 1 Code");
            GroupTotals::"FA Location":
                GroupCodeName := "Fixed Asset".FieldCaption("FA Location Code");
            GroupTotals::"Global Dimension 2":
                GroupCodeName := "Fixed Asset".FieldCaption("Global Dimension 2 Code");
            GroupTotals::"FA Posting Group":
                GroupCodeName := "Fixed Asset".FieldCaption("FA Posting Group");
            GroupTotals::"Tax Depreciation Group":
                GroupCodeName := "Fixed Asset".FieldCaption("Tax Deprec. Group Code CZF");
        end;
        if GroupCodeName <> '' then
            GroupCodeName := GroupTotalsTxt + ': ' + GroupCodeName;
    end;

    local procedure ValidateDates()
    begin
        if (EndingDate = 0D) or (StartingDate = 0D) then
            Error(SpecifyStartingAndEndingDateErr);
        if (EndingDate > 0D) and (StartingDate > EndingDate) then
            Error(StartingDateIsLaterErr);
    end;

    local procedure MakeAmountHeadLine(j: Integer; PostingType: Code[10]; Period: Enum "FA Analysis Period CZF")
    begin
        if Period = Period::"before Starting Date" then
            if StartingDate < 00020101D then
                Error(
                  SpecifyStartingDateErr, SelectStr(Period.AsInteger() + 1, PeriodsTxt));
        if PostingType <> '' then
            HeadLineText[j] := StrSubstNo(TwoPlaceholdersTok, PostingType, SelectStr(Period.AsInteger() + 1, PeriodsTxt))
        else
            HeadLineText[j] := SelectStr(Period.AsInteger() + 1, PeriodsTxt);
    end;

    local procedure MakeGroupHeadLine()
    begin
        case GroupTotals of
            GroupTotals::"FA Class":
                GroupHeadLine := "Fixed Asset"."FA Class Code";
            GroupTotals::"FA SubClass":
                GroupHeadLine := "Fixed Asset"."FA Subclass Code";
            GroupTotals::"Main Asset":
                begin
                    GroupHeadLine := StrSubstNo(TwoPlaceholdersTok, SelectStr(GroupTotals.AsInteger() + 1, GroupsTxt), "Fixed Asset"."Component of Main Asset");
                    if "Fixed Asset"."Component of Main Asset" = '' then
                        GroupHeadLine := GroupHeadLine + '*****';
                end;
            GroupTotals::"Global Dimension 1":
                GroupHeadLine := "Fixed Asset"."Global Dimension 1 Code";
            GroupTotals::"FA Location":
                GroupHeadLine := "Fixed Asset"."FA Location Code";
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

    local procedure CalculateAmount(MaintenanceCode: Code[10]; Period: Enum "FA Analysis Period CZF"): Decimal
    var
        EndingDate2: Date;
    begin
        EndingDate2 := EndingDate;
        if EndingDate2 = 0D then
            EndingDate2 := DMY2Date(31, 12, 9999);
        if DateSelection = DateSelection::"Posting Date" then
            case Period of
                Period::"before Starting Date":
                    MaintenanceLedgerEntry.SetRange(MaintenanceLedgerEntry."Posting Date", 0D, StartingDate - 1);
                Period::"Net Change":
                    MaintenanceLedgerEntry.SetRange(MaintenanceLedgerEntry."Posting Date", StartingDate, EndingDate2);
                Period::"at Ending Date":
                    MaintenanceLedgerEntry.SetRange(MaintenanceLedgerEntry."Posting Date", 0D, EndingDate2);
            end;
        if DateSelection = DateSelection::"FA Posting Date" then
            case Period of
                Period::"before Starting Date":
                    MaintenanceLedgerEntry.SetRange(MaintenanceLedgerEntry."FA Posting Date", 0D, StartingDate - 1);
                Period::"Net Change":
                    MaintenanceLedgerEntry.SetRange(MaintenanceLedgerEntry."FA Posting Date", StartingDate, EndingDate2);
                Period::"at Ending Date":
                    MaintenanceLedgerEntry.SetRange(MaintenanceLedgerEntry."FA Posting Date", 0D, EndingDate2);
            end;
        MaintenanceLedgerEntry.SetRange(MaintenanceLedgerEntry."Maintenance Code");
        if MaintenanceCode <> '' then
            MaintenanceLedgerEntry.SetRange(MaintenanceLedgerEntry."Maintenance Code", MaintenanceCode);
        MaintenanceLedgerEntry.CalcSums(MaintenanceLedgerEntry.Amount);
        exit(MaintenanceLedgerEntry.Amount);
    end;
}
