// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.FixedAssets;

using Microsoft.FixedAssets.Depreciation;
using Microsoft.FixedAssets.FixedAsset;
using Microsoft.FixedAssets.Posting;
using Microsoft.FixedAssets.Setup;

report 31241 "Fixed Asset - An. Dep.Book CZF"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Src/Reports/FixedAssetAnDepBook.rdl';
    ApplicationArea = FixedAssets;
    Caption = 'Fixed Asset - Depreciation Book Analysis';
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
            column(ReportFilter; GetFilters())
            {
            }
            column(DepreciationBookText; DepreciationBookText)
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
            column(HeadLineText8; HeadLineText[8])
            {
            }
            column(HeadLineText9; HeadLineText[9])
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
            column(Amounts11; Amounts1[1])
            {
                AutoFormatType = 1;
            }
            column(Amounts12; Amounts1[2])
            {
                AutoFormatType = 1;
            }
            column(Amounts13; Amounts1[3])
            {
                AutoFormatType = 1;
            }
            column(Amounts21; Amounts2[1])
            {
                AutoFormatType = 1;
            }
            column(Amounts22; Amounts2[2])
            {
                AutoFormatType = 1;
            }
            column(Amounts23; Amounts2[3])
            {
                AutoFormatType = 1;
            }
            column(Amounts31; Amounts1[1] - Amounts2[1])
            {
                AutoFormatType = 1;
            }
            column(Amounts32; Amounts1[2] - Amounts2[2])
            {
                AutoFormatType = 1;
            }
            column(Amounts33; Amounts1[3] - Amounts2[3])
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
                if (not FADepreciationBook1.Get("No.", DeprBookCode1)) and (not FADepreciationBook2.Get("No.", DeprBookCode2)) then
                    CurrReport.Skip();
                if SkipRecord() then
                    CurrReport.Skip();

                if GroupTotals = GroupTotals::"FA Posting Group" then
                    if "FA Posting Group" <> FADepreciationBook1."FA Posting Group" then
                        Error(HasBeenModifiedInFAErr, FieldCaption("FA Posting Group"), "No.");
                if GroupTotals = GroupTotals::"Tax Depreciation Group" then
                    if "Tax Deprec. Group Code CZF" <> FADepreciationBook1."Tax Deprec. Group Code CZF" then
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

                BeforeAmount1 := 0;
                EndingAmount1 := 0;
                if BudgetReport then
                    BudgetDepreciation.Calculate("No.", GetStartDate(StartingDate), EndingDate, DeprBookCode1, BeforeAmount1, EndingAmount1);
                BeforeAmount2 := 0;
                EndingAmount2 := 0;
                if BudgetReport then
                    BudgetDepreciation.Calculate("No.", GetStartDate(StartingDate), EndingDate, DeprBookCode2, BeforeAmount2, EndingAmount2);

                if SetAmountToZero1(PostingTypeNo1, Period1.AsInteger()) then
                    Amounts1[1] := 0
                else
                    Amounts1[1] := FAGeneralReport.CalcFAPostedAmount("No.", PostingTypeNo1, Period1.AsInteger(), StartingDate, EndingDate,
                        DeprBookCode1, BeforeAmount1, EndingAmount1, false, false);
                if SetAmountToZero1(PostingTypeNo2, Period2.AsInteger()) then
                    Amounts1[2] := 0
                else
                    Amounts1[2] := FAGeneralReport.CalcFAPostedAmount("No.", PostingTypeNo2, Period2.AsInteger(), StartingDate, EndingDate,
                        DeprBookCode1, BeforeAmount1, EndingAmount1, false, false);
                if SetAmountToZero1(PostingTypeNo3, Period3.AsInteger()) then
                    Amounts1[3] := 0
                else
                    Amounts1[3] := FAGeneralReport.CalcFAPostedAmount("No.", PostingTypeNo3, Period3.AsInteger(), StartingDate, EndingDate,
                        DeprBookCode1, BeforeAmount1, EndingAmount1, false, false);

                if SetAmountToZero2(PostingTypeNo1, Period1.AsInteger()) then
                    Amounts2[1] := 0
                else
                    Amounts2[1] := FAGeneralReport.CalcFAPostedAmount("No.", PostingTypeNo1, Period1.AsInteger(), StartingDate, EndingDate,
                        DeprBookCode2, BeforeAmount2, EndingAmount2, false, false);
                if SetAmountToZero2(PostingTypeNo2, Period2.AsInteger()) then
                    Amounts2[2] := 0
                else
                    Amounts2[2] := FAGeneralReport.CalcFAPostedAmount("No.", PostingTypeNo2, Period2.AsInteger(), StartingDate, EndingDate,
                        DeprBookCode2, BeforeAmount2, EndingAmount2, false, false);
                if SetAmountToZero2(PostingTypeNo3, Period3.AsInteger()) then
                    Amounts2[3] := 0
                else
                    Amounts2[3] := FAGeneralReport.CalcFAPostedAmount("No.", PostingTypeNo3, Period3.AsInteger(), StartingDate, EndingDate,
                        DeprBookCode2, BeforeAmount2, EndingAmount2, false, false);
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
                CheckPostingType(PostingType1, PostingTypeNo1);
                CheckPostingType(PostingType2, PostingTypeNo2);
                CheckPostingType(PostingType3, PostingTypeNo3);
                MakeGroupTotalText();
                FAGeneralReport.ValidateDates(StartingDate, EndingDate);
                MakeAmountHeadLine(1, PostingType1, PostingTypeNo1, Period1.AsInteger(), DeprBookCode1);
                MakeAmountHeadLine(2, PostingType1, PostingTypeNo1, Period1.AsInteger(), DeprBookCode2);
                MakeAmountHeadLine(4, PostingType2, PostingTypeNo2, Period2.AsInteger(), DeprBookCode1);
                MakeAmountHeadLine(5, PostingType2, PostingTypeNo2, Period2.AsInteger(), DeprBookCode2);
                MakeAmountHeadLine(7, PostingType3, PostingTypeNo3, Period3.AsInteger(), DeprBookCode1);
                MakeAmountHeadLine(8, PostingType3, PostingTypeNo3, Period3.AsInteger(), DeprBookCode2);
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
                    field(DeprBookCodeCZF; DeprBookCode1)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'Depreciation Book';
                        TableRelation = "Depreciation Book";
                        ToolTip = 'Specifies the depreciation book for the printing of entries.';
                    }
                    field(DeprBookCode2CZF; DeprBookCode2)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'Depreciation Book';
                        TableRelation = "Depreciation Book";
                        ToolTip = 'Specifies the deprecation book code.';
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
            if DeprBookCode1 = '' then begin
                FASetup.Get();
                DeprBookCode1 := FASetup."Default Depr. Book";
            end;
            FAPostingType.CreateTypes();
            FADateType.CreateTypes();
        end;
    }

    labels
    {
        PageLbl = 'Page';
        TotalLbl = 'Total';
        DifferenceLbl = 'DIFFERENCE';
    }

    trigger OnPreReport()
    begin
        DepreciationBook1.Get(DeprBookCode1);
        DepreciationBook2.Get(DeprBookCode2);
        DepreciationBookText := StrSubstNo(DepreciationBooksLbl, DeprBookCode1, DepreciationBook1.Description,
                                           DeprBookCode2, DepreciationBook2.Description, StartingDate, EndingDate);

        if GroupTotals = GroupTotals::"FA Posting Group" then
            FAGeneralReport.SetFAPostingGroup("Fixed Asset", DepreciationBook1.Code);
        if GroupTotals = GroupTotals::"Tax Depreciation Group" then
            FAGeneralReportCZF.SetFATaxDeprGroup("Fixed Asset", DepreciationBook1.Code);
        FAGeneralReport.AppendFAPostingFilter("Fixed Asset", StartingDate, EndingDate);
        MainHeadLineText := ReportNameTxt;
        if BudgetReport then
            MainHeadLineText := StrSubstNo(TwoPlaceholdersTok, MainHeadLineText, BudgetReportTxt);
        if PrintDetails then begin
            FANoCaption := "Fixed Asset".FieldCaption("No.");
            FADescriptionCaption := "Fixed Asset".FieldCaption(Description);
        end;
    end;

    var
        FASetup: Record "FA Setup";
        DepreciationBook1: Record "Depreciation Book";
        DepreciationBook2: Record "Depreciation Book";
        FADepreciationBook1: Record "FA Depreciation Book";
        FADepreciationBook2: Record "FA Depreciation Book";
        FAPostingType: Record "FA Posting Type";
        FADateType: Record "FA Date Type";
        FAGeneralReport: Codeunit "FA General Report";
        FAGeneralReportCZF: Codeunit "FA General Report CZF";
        BudgetDepreciation: Codeunit "Budget Depreciation";
        DeprBookCode1, DeprBookCode2 : Code[10];
        MainHeadLineText, DepreciationBookText, GroupCodeName, GroupHeadLine, FANoCaption, FADescriptionCaption : Text;
        HeadLineText: array[10] of Text;
        PostingType1, PostingType2, PostingType3 : Text[30];
        Date, Date2 : array[3] of Date;
        StartingDate, EndingDate, AcquisitionDate1, AcquisitionDate2, DisposalDate1, DisposalDate2 : Date;
        BeforeAmount1, BeforeAmount2, EndingAmount1, EndingAmount2 : Decimal;
        Amounts1, Amounts2 : array[3] of Decimal;
        PostingTypeNo1, PostingTypeNo2, PostingTypeNo3 : Integer;
        Period1, Period2, Period3 : Enum "FA Analysis Period CZF";
        PrintDetails, BudgetReport, SalesReport, TypeExist : Boolean;
        Group: Code[50];
        GroupTotals: Enum "FA Analysis Group CZF";
        ReportNameTxt: Label 'Fixed Asset - Analysis Depreciation Book';
        BudgetReportTxt: Label '(Budget Report)';
        GroupTotalTxt: Label 'Group Total';
        GroupTotalsTxt: Label 'Group Totals: %1', Comment = '%1 = Group Code';
        SpecifyTogetherErr: Label '%1 or %2 must be specified only together with the option %3.', Comment = '%1 = Proceeds on Disposal FieldCaption, %2 = Gain/Loss FieldCaption, %3 = Period';
        SpecifyStartingDateErr: Label 'The Starting Date must be specified when you use the option %1.', Comment = '%1 = Period';
        PostingTypeErr: Label 'The posting type %1 is not a valid option.', Comment = '%1 = Posting Type';
        HasBeenModifiedInFAErr: Label '%1 has been modified in fixed asset %2', Comment = '%1 = FieldCaption, %2 = Fixed Asset No.';
        PeriodsTxt: Label 'before Starting Date,Net Change,at Ending Date';
        TwoPlaceholdersTok: Label '%1 %2', Locked = true;
        ThreePlaceholdersTok: Label '%1 %2 %3', Locked = true;
        DepreciationBooksLbl: Label 'Depreciation Books: %1 %2 and %3 %4, Starting Date: %5, Ending Date %6.', Comment = '%1 = Depr. Book Code, %2 = Depr. Book Description, %3 = Depr. Book Code, %4 = Depr. Book Description, %5 = Starting Date, %6 = Ending Date';

    local procedure SkipRecord(): Boolean
    begin
        AcquisitionDate1 := FADepreciationBook1."Acquisition Date";
        DisposalDate1 := FADepreciationBook1."Disposal Date";
        AcquisitionDate2 := FADepreciationBook2."Acquisition Date";
        DisposalDate2 := FADepreciationBook2."Disposal Date";

        if (AcquisitionDate1 = 0D) and (AcquisitionDate2 = 0D) then
            exit(true);
        if (AcquisitionDate1 > EndingDate) and (AcquisitionDate2 > EndingDate) and (EndingDate > 0D) then
            exit(true);
        if SalesReport and (DisposalDate1 = 0D) and (DisposalDate2 = 0D) then
            exit(true);
        if SalesReport and (EndingDate > 0D) and
           ((DisposalDate1 > EndingDate) or (DisposalDate1 < StartingDate)) and
           ((DisposalDate2 > EndingDate) or (DisposalDate2 < StartingDate))
        then
            exit(true);

        if not SalesReport and (DisposalDate1 > 0D) and (DisposalDate1 < StartingDate) and
           (DisposalDate2 > 0D) and (DisposalDate2 < StartingDate)
        then
            exit(true);
        exit(false);
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

    local procedure MakeAmountHeadLine(i: Integer; PostingType: Text[50]; PostingTypeNo: Integer; Period: Option "Before Starting Date","Net Change","at Ending Date"; DepreciationBook: Text)
    begin
        if PostingTypeNo = 0 then
            exit;
        case PostingTypeNo of
            FADepreciationBook1.FieldNo("Proceeds on Disposal"),
          FADepreciationBook1.FieldNo("Gain/Loss"):
                if Period <> Period::"at Ending Date" then begin
                    Period := Period::"at Ending Date";
                    Error(
                      SpecifyTogetherErr,
                      FADepreciationBook1.FieldCaption("Proceeds on Disposal"),
                      FADepreciationBook1.FieldCaption("Gain/Loss"),
                      SelectStr(Period + 1, PeriodsTxt));
                end;
        end;
        if Period = Period::"Before Starting Date" then
            if StartingDate = 0D then
                Error(
                  SpecifyStartingDateErr, SelectStr(Period + 1, PeriodsTxt));

        HeadLineText[i] := StrSubstNo(ThreePlaceholdersTok, PostingType, SelectStr(Period + 1, PeriodsTxt), DepreciationBook);
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
                    GroupHeadLine := StrSubstNo(TwoPlaceholdersTok, GroupTotals, "Fixed Asset"."Component of Main Asset");
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
                GroupHeadLine := Format("Fixed Asset"."FA Posting Group");
            GroupTotals::"Tax Depreciation Group":
                GroupHeadLine := "Fixed Asset"."Tax Deprec. Group Code CZF";
        end;
        if GroupHeadLine = '' then
            GroupHeadLine := '*****';
    end;

    local procedure SetAmountToZero1(PostingTypeNo: Integer; Period: Option "Before Starting Date","Net Change","at Ending Date"): Boolean
    begin
        case PostingTypeNo of
            FADepreciationBook1.FieldNo("Proceeds on Disposal"), FADepreciationBook1.FieldNo("Gain/Loss"):
                exit(false);
        end;
        if not SalesReport and (Period = Period::"at Ending Date") and ((DisposalDate1 > 0D) and ((EndingDate = 0D) or (DisposalDate1 <= EndingDate))) then
            exit(true);
        exit(false);
    end;

    local procedure SetAmountToZero2(PostingTypeNo: Integer; Period: Option "Before Starting Date","Net Change","at Ending Date"): Boolean
    begin
        case PostingTypeNo of
            FADepreciationBook2.FieldNo("Proceeds on Disposal"), FADepreciationBook2.FieldNo("Gain/Loss"):
                exit(false);
        end;
        if not SalesReport and (Period = Period::"at Ending Date") and ((DisposalDate2 > 0D) and ((EndingDate = 0D) or (DisposalDate2 <= EndingDate))) then
            exit(true);
        exit(false);
    end;

    local procedure GetStartDate(StartDate: Date): Date
    begin
        if StartDate <= 00000101D then
            exit(0D);
        exit(StartDate - 1);
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
