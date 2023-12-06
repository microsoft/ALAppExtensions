// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.FixedAssets;

using Microsoft.FixedAssets.Depreciation;
using Microsoft.FixedAssets.FixedAsset;
using Microsoft.FixedAssets.Posting;
using Microsoft.FixedAssets.Setup;

report 31242 "Fixed Asset - Analysis CZF"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Src/Reports/FixedAssetAnalysis.rdl';
    ApplicationArea = FixedAssets;
    Caption = 'Fixed Asset - Analysis';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem("Fixed Asset"; "Fixed Asset")
        {
            DataItemTableView = where(Inactive = const(false));
            RequestFilterFields = "No.", "FA Class Code", "FA Subclass Code", "Budgeted Asset";
            column(COMPANYNAME; CompanyProperty.DisplayName())
            {
            }
            column(Group; Group)
            {
            }
            column(MainHeadLineText; MainHeadLineText)
            {
            }
            column(DepreciationBookText; DeprBookText)
            {
            }
            column(ReportFilter; GetFilters())
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
            column(HeadLineText1; HeadLineText[1])
            {
            }
            column(HeadLineText2; HeadLineText[2])
            {
            }
            column(HeadLineText3; HeadLineText[3])
            {
            }
            column(HeadLineText4; HeadLineText[4])
            {
            }
            column(HeadLineText5; HeadLineText[5])
            {
            }
            column(HeadLineText6; HeadLineText[6])
            {
            }
            column(HeadLineText7; HeadLineText[7])
            {
            }
            column(GroupHeadLine; GroupHeadLine)
            {
            }
            column(FixedAsset_No; "No.")
            {
            }
            column(FixedAsset_Description; Description)
            {
            }
            column(SetSalesMark; SetSalesMark())
            {
            }
            column(Date1; Date[1])
            {
            }
            column(Date2; Date[2])
            {
            }
            column(Date3; Date[3])
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
            column(Amounts4; Amounts[4])
            {
                AutoFormatType = 1;
            }
            column(GroupFooterLine; GroupHeadLine + ' ' + GroupTotalTxt)
            {
            }
            column(PrintDetails; PrintDetails)
            {
            }
            column(GroupTotals; GroupTotals)
            {
            }

            trigger OnAfterGetRecord()
            begin
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

                case GroupTotals of
                    GroupTotals::"FA Class":
                        Group := "FA Class Code";
                    GroupTotals::"FA Subclass":
                        Group := "FA Subclass Code";
                    GroupTotals::"Main Asset":
                        Group := "Component of Main Asset";
                    GroupTotals::"Global Dimension 1":
                        Group := "Global Dimension 1 Code";
                    GroupTotals::"FA Location":
                        Group := "FA Location Code";
                    GroupTotals::"Global Dimension 2":
                        Group := "Global Dimension 2 Code";
                    GroupTotals::"FA Posting Group":
                        Group := "FA Posting Group";
                    GroupTotals::"Tax Depreciation Group":
                        Group := "Tax Deprec. Group Code CZF";
                end;
                MakeGroupHeadLine();

                Date[1] := FAGeneralReport.GetLastDate("No.", DateTypeNo1, EndingDate, DeprBookCode, false);
                Date[2] := FAGeneralReport.GetLastDate("No.", DateTypeNo2, EndingDate, DeprBookCode, false);
                Date[3] := FAGeneralReport.GetLastDate("No.", DateTypeNo3, EndingDate, DeprBookCode, false);

                BeforeAmount := 0;
                EndingAmount := 0;
                if BudgetReport then
                    BudgetDepreciation.Calculate("No.", GetStartDate(StartingDate), EndingDate, DeprBookCode, BeforeAmount, EndingAmount);

                if SetAmountToZero(PostingTypeNo1, Period1.AsInteger()) then
                    Amounts[1] := 0
                else
                    Amounts[1] := FAGeneralReport.CalcFAPostedAmount("No.", PostingTypeNo1, Period1.AsInteger(), StartingDate, EndingDate,
                        DeprBookCode, BeforeAmount, EndingAmount, false, false);
                if SetAmountToZero(PostingTypeNo2, Period2.AsInteger()) then
                    Amounts[2] := 0
                else
                    Amounts[2] := FAGeneralReport.CalcFAPostedAmount("No.", PostingTypeNo2, Period2.AsInteger(), StartingDate, EndingDate,
                        DeprBookCode, BeforeAmount, EndingAmount, false, false);
                if SetAmountToZero(PostingTypeNo3, Period3.AsInteger()) then
                    Amounts[3] := 0
                else
                    Amounts[3] := FAGeneralReport.CalcFAPostedAmount("No.", PostingTypeNo3, Period3.AsInteger(), StartingDate, EndingDate,
                        DeprBookCode, BeforeAmount, EndingAmount, false, false);
                if SetAmountToZero(PostingTypeNo4, Period4.AsInteger()) then
                    Amounts[4] := 0
                else
                    Amounts[4] := FAGeneralReport.CalcFAPostedAmount("No.", PostingTypeNo4, Period4.AsInteger(), StartingDate, EndingDate,
                        DeprBookCode, BeforeAmount, EndingAmount, false, false);
            end;

            trigger OnPreDataItem()
            begin
                case GroupTotals of
                    GroupTotals::"FA Class":
                        SetCurrentKey("FA Class Code");
                    GroupTotals::"FA Subclass":
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

                FAPostingType.CreateTypes();
                FADateType.CreateTypes();
                CheckDateType(DateType1, DateTypeNo1);
                CheckDateType(DateType2, DateTypeNo2);
                CheckDateType(DateType3, DateTypeNo3);
                CheckPostingType(PostingType1, PostingTypeNo1);
                CheckPostingType(PostingType2, PostingTypeNo2);
                CheckPostingType(PostingType3, PostingTypeNo3);
                CheckPostingType(PostingType4, PostingTypeNo4);
                MakeGroupTotalText();
                FAGeneralReport.ValidateDates(StartingDate, EndingDate);
                MakeDateHeadLine();
                MakeAmountHeadLine(3, PostingType1, PostingTypeNo1, Period1.AsInteger());
                MakeAmountHeadLine(4, PostingType2, PostingTypeNo2, Period2.AsInteger());
                MakeAmountHeadLine(5, PostingType3, PostingTypeNo3, Period3.AsInteger());
                MakeAmountHeadLine(7, PostingType4, PostingTypeNo4, Period4.AsInteger());
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
                        ToolTip = 'Specifies the depreciation book for the printing of entries.';
                    }
                    field(StartingDateCZF; StartingDate)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'Starting Date';
                        ToolTip = 'Specifies the starting date';
                    }
                    field(EndingDateCZF; EndingDate)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'Ending Date';
                        ToolTip = 'Specifies the last date in the period.';
                    }
                    field(DateType1CZF; DateType1)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'Date Field 1';
                        TableRelation = "FA Date Type"."FA Date Type Name" where("FA Entry" = const(true));
                        ToolTip = 'Specifies the data field which can be printed.';
                    }
                    field(DateType2CZF; DateType2)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'Date Field 2';
                        TableRelation = "FA Date Type"."FA Date Type Name" where("FA Entry" = const(true));
                        ToolTip = 'Specifies the data field which can be printed.';
                    }
                    field(DateType3CZF; DateType3)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'Date Field 3';
                        TableRelation = "FA Date Type"."FA Date Type Name" where("FA Entry" = const(true));
                        ToolTip = 'Specifies the data field which can be printed.';
                    }
                    field(PostingType1CZF; PostingType1)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'Amount Field 1';
                        TableRelation = "FA Posting Type"."FA Posting Type Name" where("FA Entry" = const(true));
                        ToolTip = 'Specifies the FA posting type which can be printed.';
                    }
                    field(Period1CZF; Period1)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'Period 1';
                        ToolTip = 'Specifies the method for amounts calculation';
                    }
                    field(PostingType2CZF; PostingType2)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'Amount Field 2';
                        TableRelation = "FA Posting Type"."FA Posting Type Name" where("FA Entry" = const(true));
                        ToolTip = 'Specifies the FA posting type which can be printed.';
                    }
                    field(Period2CZF; Period2)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'Period 2';
                        ToolTip = 'Specifies the method for amounts calculation';
                    }
                    field(PostingType3CZF; PostingType3)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'Amount Field 3';
                        TableRelation = "FA Posting Type"."FA Posting Type Name" where("FA Entry" = const(true));
                        ToolTip = 'Specifies the FA posting type which can be printed.';
                    }
                    field(Period3CZF; Period3)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'Period 3';
                        ToolTip = 'Specifies the method for amounts calculation';
                    }
                    field(PostingType4CZF; PostingType4)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'Amount Field 4';
                        TableRelation = "FA Posting Type"."FA Posting Type Name" where("FA Entry" = const(true));
                        ToolTip = 'Specifies the FA posting type which can be printed.';
                    }
                    field(Period4CZF; Period4)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'Period 4';
                        ToolTip = 'Specifies the method for amounts calculation';
                    }
                    field(GroupTotalsCZF; GroupTotals)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'Group Totals';
                        ToolTip = 'Specifies according to what the entries can be sumed.';
                    }
                    field(PrintDetailsCZF; PrintDetails)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'Print per Fixed Asset';
                        ToolTip = 'Specifies if the sum will be printed in common or only the Specifiesed FA cards.';
                    }
                    field(SalesReportCZF; SalesReport)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'Only Sold Assets';
                        ToolTip = 'Specifies only sold assets.';
                    }
                    field(BudgetReportCZF; BudgetReport)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'Budget Report';
                        ToolTip = 'Specifies if the budget report will be used';
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
            FAPostingType.CreateTypes();
            FADateType.CreateTypes();
        end;
    }

    labels
    {
        PageLbl = 'Page';
        TotalLbl = 'Total';
    }

    trigger OnPreReport()
    begin
        DepreciationBook.Get(DeprBookCode);
        if GroupTotals = GroupTotals::"FA Posting Group" then
            FAGeneralReport.SetFAPostingGroup("Fixed Asset", DepreciationBook.Code);
        if GroupTotals = GroupTotals::"Tax Depreciation Group" then
            FAGeneralReportCZF.SetFATaxDeprGroup("Fixed Asset", DepreciationBook.Code);
        FAGeneralReport.AppendFAPostingFilter("Fixed Asset", StartingDate, EndingDate);
        if BudgetReport then
            MainHeadLineText := ReportNameBudgetReportTxt
        else
            MainHeadLineText := ReportNameTxt;
        DeprBookText := StrSubstNo(TwoPlaceholdersTok, DepreciationBook.TableCaption, DeprBookCode);
        if PrintDetails then begin
            FANoCaption := "Fixed Asset".FieldCaption("No.");
            FADescriptionCaption := "Fixed Asset".FieldCaption(Description);
        end;
    end;

    var
        FASetup: Record "FA Setup";
        DepreciationBook: Record "Depreciation Book";
        FADepreciationBook: Record "FA Depreciation Book";
        FAPostingType: Record "FA Posting Type";
        FADateType: Record "FA Date Type";
        FAGeneralReport: Codeunit "FA General Report";
        FAGeneralReportCZF: Codeunit "FA General Report CZF";
        BudgetDepreciation: Codeunit "Budget Depreciation";
        DeprBookCode: Code[10];
        MainHeadLineText, DeprBookText, GroupCodeName, GroupHeadLine, FANoCaption, FADescriptionCaption : Text;
        HeadLineText: array[7] of Text;
        PostingType1, PostingType2, PostingType3, PostingType4, DateType1, DateType2, DateType3 : Text[30];
        Date: array[3] of Date;
        StartingDate, EndingDate, AcquisitionDate, DisposalDate : Date;
        BeforeAmount, EndingAmount : Decimal;
        Amounts: array[4] of Decimal;
        Period1, Period2, Period3, Period4 : Enum "FA Analysis Period CZF";
        PostingTypeNo1, PostingTypeNo2, PostingTypeNo3, PostingTypeNo4 : Integer;
        DateTypeNo1, DateTypeNo2, DateTypeNo3 : Integer;
        PrintDetails, BudgetReport, SalesReport, TypeExist : Boolean;
        Group: Code[50];
        GroupTotals: Enum "FA Analysis Group CZF";
        ReportNameTxt: Label 'Fixed Asset - Analysis';
        ReportNameBudgetReportTxt: Label 'Fixed Asset - Analysis (Budget Report)';
        GroupTotalTxt: Label 'Group Total';
        SoldTxt: Label 'Sold';
        GroupTotalsTxt: Label 'Group Totals: %1', Comment = '%1 = Group Code';
        SpecifyTogetherErr: Label '%1 or %2 must be specified only together with the option %3.', Comment = '%1 = Proceeds on Disposal FildCaption, %2 = Gain/Loss FieldCaption, %3 = Period';
        SpecifyStartingDateErr: Label 'The Starting Date must be specified when you use the option %1.', Comment = '%1 = Period';
        DateTypeErr: Label 'The date type %1 is not a valid option.', Comment = '%1 = Date Type';
        PostingTypeErr: Label 'The posting type %1 is not a valid option.', Comment = '%1 = Posting Type';
        HasBeenModifiedInFAErr: Label '%1 has been modified in fixed asset %2', Comment = '%1 = FieldCaption, %2 = Fixed Asset No.';
        PeriodsTxt: Label 'before Starting Date,Net Change,at Ending Date';
        GroupsTxt: Label ' ,FA Class,FA Subclass,FA Location,Main Asset,Global Dimension 1,Global Dimension 2,FA Posting Group,Tax Depreciation Group';
        TwoPlaceholdersTok: Label '%1 %2', Locked = true;

    local procedure SkipRecord(): Boolean
    begin
        AcquisitionDate := FADepreciationBook."Acquisition Date";
        DisposalDate := FADepreciationBook."Disposal Date";

        if AcquisitionDate = 0D then
            exit(true);
        if (AcquisitionDate > EndingDate) and (EndingDate > 0D) then
            exit(true);
        if SalesReport and (DisposalDate = 0D) then
            exit(true);
        if SalesReport and (EndingDate > 0D) and ((DisposalDate > EndingDate) or (DisposalDate < StartingDate)) then
            exit(true);
        if not SalesReport and (DisposalDate > 0D) and (DisposalDate < StartingDate) then
            exit(true);
        exit(false);
    end;

    local procedure SetSalesMark(): Text[30]
    begin
        if DisposalDate > 0D then
            if (EndingDate = 0D) or (DisposalDate <= EndingDate) then
                exit(SoldTxt);
        exit('');
    end;

    local procedure MakeGroupTotalText()
    begin
        case GroupTotals of
            GroupTotals::"FA Class":
                GroupCodeName := "Fixed Asset".FieldCaption("FA Class Code");
            GroupTotals::"FA Subclass":
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
            GroupCodeName := StrSubstNo(GroupTotalsTxt, GroupCodeName);
    end;

    local procedure MakeDateHeadLine()
    begin
        if not PrintDetails then
            exit;
        HeadLineText[1] := DateType1;
        HeadLineText[2] := DateType2;
        HeadLineText[6] := DateType3;
    end;

    local procedure MakeAmountHeadLine(i: Integer; PostingType: Text[50]; PostingTypeNo: Integer; Period: Option "Before Starting Date","Net Change","at Ending Date")
    begin
        if PostingTypeNo = 0 then
            exit;
        case PostingTypeNo of
            FADepreciationBook.FieldNo("Proceeds on Disposal"),
          FADepreciationBook.FieldNo("Gain/Loss"):
                if Period <> Period::"at Ending Date" then begin
                    Period := Period::"at Ending Date";
                    Error(
                      SpecifyTogetherErr,
                      FADepreciationBook.FieldCaption("Proceeds on Disposal"),
                      FADepreciationBook.FieldCaption("Gain/Loss"),
                      SelectStr(Period + 1, PeriodsTxt));
                end;
        end;
        if Period = Period::"Before Starting Date" then
            if StartingDate = 0D then
                Error(
                  SpecifyStartingDateErr, SelectStr(Period + 1, PeriodsTxt));
        HeadLineText[i] := StrSubstNo(TwoPlaceholdersTok, PostingType, SelectStr(Period + 1, PeriodsTxt));
    end;

    local procedure MakeGroupHeadLine()
    begin
        case GroupTotals of
            GroupTotals::"FA Class":
                GroupHeadLine := "Fixed Asset"."FA Class Code";
            GroupTotals::"FA Subclass":
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

    local procedure SetAmountToZero(PostingTypeNo: Integer; Period: Option "Before Starting Date","Net Change","at Ending Date"): Boolean
    begin
        case PostingTypeNo of
            FADepreciationBook.FieldNo("Proceeds on Disposal"), FADepreciationBook.FieldNo("Gain/Loss"):
                exit(false);
        end;
        if not SalesReport and (Period = Period::"at Ending Date") and (SetSalesMark() <> '') then
            exit(true);
        exit(false);
    end;

    local procedure GetStartDate(StartDate: Date): Date
    begin
        if StartDate = 0D then
            exit(0D);
        exit(StartDate - 1);
    end;

    local procedure CheckDateType(DateType: Text[30]; var DateTypeNo: Integer)
    begin
        DateTypeNo := 0;
        if DateType = '' then
            exit;
        FADateType.SetRange(FADateType."FA Entry", true);
        if FADateType.FindSet() then
            repeat
                TypeExist := DateType = FADateType."FA Date Type Name";
                if TypeExist then
                    DateTypeNo := FADateType."FA Date Type No.";
            until (FADateType.Next() = 0) or TypeExist;
        if not TypeExist then
            Error(DateTypeErr, DateType);
    end;

    local procedure CheckPostingType(PostingType: Text[30]; var PostingTypeNo: Integer)
    begin
        PostingTypeNo := 0;
        if PostingType = '' then
            exit;
        FAPostingType.SetRange(FAPostingType."FA Entry", true);
        if FAPostingType.FindSet() then
            repeat
                TypeExist := PostingType = FAPostingType."FA Posting Type Name";
                if TypeExist then
                    PostingTypeNo := FAPostingType."FA Posting Type No.";
            until (FAPostingType.Next() = 0) or TypeExist;
        if not TypeExist then
            Error(PostingTypeErr, PostingType);
    end;
}
