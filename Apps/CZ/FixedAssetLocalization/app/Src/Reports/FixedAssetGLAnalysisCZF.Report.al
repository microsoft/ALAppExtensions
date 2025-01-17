// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.FixedAssets;

using Microsoft.FixedAssets.Depreciation;
using Microsoft.FixedAssets.FixedAsset;
using Microsoft.FixedAssets.Posting;
using Microsoft.FixedAssets.Setup;

report 31247 "Fixed Asset - G/L Analysis CZF"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Src/Reports/FixedAssetGLAnalysis.rdl';
    ApplicationArea = FixedAssets;
    Caption = 'Fixed Asset G/L Analysis';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem("Fixed Asset"; "Fixed Asset")
        {
            RequestFilterFields = "No.", "FA Class Code", "FA Subclass Code", "Budgeted Asset";
            column(CompanyName; CompanyProperty.DisplayName())
            {
            }
            column(DeprBookText; DeprBookText)
            {
            }
            column(ReportFilter; FAFilter)
            {
            }
            column(HeadLineText1; HeadLineText[1])
            {
            }
            column(GroupCodeName; GroupCodeName)
            {
            }
            column(FANo; FANoCaption)
            {
            }
            column(FADescription; FADescriptionCaption)
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
            column(GroupTotalsPrintDetails; (GroupTotals.AsInteger() = 0) or not PrintDetails)
            {
            }
            column(PrintDetailsGroupTotals; PrintDetails and (GroupTotals.AsInteger() <> 0))
            {
            }
            column(GroupHeadLine; GroupHeadLine)
            {
            }
            column(No_FixedAsset; "No.")
            {
            }
            column(Description_FixedAsset; Description)
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
            column(Date1; Format(Date[1]))
            {
            }
            column(Date2; Format(Date[2]))
            {
            }
            column(PrintDetails; PrintDetails)
            {
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
            column(GroupTotalsNotEqualZero; GroupTotals.AsInteger() <> 0)
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

                Date[1] :=
                  FAGeneralReport.GetLastDate(
                    "No.", DateTypeNo1, EndingDate, DeprBookCode, true);
                Date[2] :=
                  FAGeneralReport.GetLastDate(
                    "No.", DateTypeNo2, EndingDate, DeprBookCode, true);

                Amounts[1] :=
                  FAGeneralReport.CalcGLPostedAmount(
                    "No.", PostingTypeNo1, Period1.AsInteger(), StartingDate, EndingDate, DeprBookCode);
                Amounts[2] :=
                  FAGeneralReport.CalcGLPostedAmount(
                    "No.", PostingTypeNo2, Period2.AsInteger(), StartingDate, EndingDate, DeprBookCode);
                Amounts[3] :=
                  FAGeneralReport.CalcGLPostedAmount(
                    "No.", PostingTypeNo3, Period3.AsInteger(), StartingDate, EndingDate, DeprBookCode);

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
                CheckPostingType(PostingType1, PostingTypeNo1);
                CheckPostingType(PostingType2, PostingTypeNo2);
                CheckPostingType(PostingType3, PostingTypeNo3);
                MakeGroupTotalText();
                FAGeneralReport.ValidateDates(StartingDate, EndingDate);
                MakeDateHeadLine();
                MakeAmountHeadLine(3, PostingType1, PostingTypeNo1, Period1);
                MakeAmountHeadLine(4, PostingType2, PostingTypeNo2, Period2);
                MakeAmountHeadLine(5, PostingType3, PostingTypeNo3, Period3);
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
                        ToolTip = 'Specifies the code for the depreciation book to be included in the report or batch job.';
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
                        ToolTip = 'Specifies the date when you want the report to end.';
                    }
                    field(DateField1; DateType1)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'Date Field 1';
                        TableRelation = "FA Date Type"."FA Date Type Name" where("G/L Entry" = const(true));
                        ToolTip = 'Specifies the first type of date that the report must show. The report has two columns in which two types of dates can be displayed. In each of the fields, select one of the available date types.';
                    }
                    field(DateField2; DateType2)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'Date Field 2';
                        TableRelation = "FA Date Type"."FA Date Type Name" where("G/L Entry" = const(true));
                        ToolTip = 'Specifies the second type of date that the report must show.';
                    }
                    field(AmountField1; PostingType1)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'Amount Field 1';
                        TableRelation = "FA Posting Type"."FA Posting Type Name" where("G/L Entry" = const(true));
                        ToolTip = 'Specifies an Amount field that you use to create your own analysis. The report has three columns in which three types of amounts can be displayed. Choose the relevant FA posting type for each column.';
                    }
                    field(Period1CZF; Period1)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'Period 1';
                        ToolTip = 'Specifies how the report determines the nature of the amounts in the first amount field. (Blank): The amounts consist of fixed asset ledger entries with the posting type that corresponds to the option in the amount field. Disposal: The amounts consists of fixed asset ledger entries with the posting type that corresponds to the option in the amount field if these entries have been posted to disposal accounts. Bal. Disposal: The amounts consist of fixed asset ledger entries with the posting type that corresponds to the option in the amount field if these entries have been posted to balancing disposal accounts.';
                    }
                    field(AmountField2; PostingType2)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'Amount Field 2';
                        TableRelation = "FA Posting Type"."FA Posting Type Name" where("G/L Entry" = const(true));
                        ToolTip = 'Specifies an Amount field that you use to create your own analysis.';
                    }
                    field(Period2CZF; Period2)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'Period 2';
                        ToolTip = 'Specifies how the report determines the nature of the amounts in the second amount field. (Blank): The amounts consist of fixed asset ledger entries with the posting type that corresponds to the option in the amount field. Disposal: The amounts consists of fixed asset ledger entries with the posting type that corresponds to the option in the amount field if these entries have been posted to disposal accounts. Bal. Disposal: The amounts consist of fixed asset ledger entries with the posting type that corresponds to the option in the amount field if these entries have been posted to balancing disposal accounts.';
                    }
                    field(AmountField3; PostingType3)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'Amount Field 3';
                        TableRelation = "FA Posting Type"."FA Posting Type Name" where("G/L Entry" = const(true));
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
                        ToolTip = 'Specifies a group type if you want the report to group the fixed assets and print group totals. For example, if you have set up six FA classes, then select the FA Class option to have group totals printed for each of the six class codes. Select to see the available options. If you do not want group totals to be printed, select the blank option.';
                    }
                    field(PrintperFixedAsset; PrintDetails)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'Print per Fixed Asset';
                        ToolTip = 'Specifies if you want the report to print information separately for each fixed asset.';
                    }
                    field(OnlySoldAssets; SalesReport)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'Only Sold Assets';
                        ToolTip = 'Specifies if you want the report to show information only for sold fixed assets.';
                    }
                }
            }
        }

        trigger OnOpenPage()
        begin
            GetFASetup();
        end;
    }

    labels
    {
        FixedAssetGLAnalysisLbl = 'Fixed Asset - G/L Analysis';
        PageLbl = 'Page';
        TotalLbl = 'Total';
    }

    trigger OnPreReport()
    begin
        DepreciationBook.Get(DeprBookCode);
        FAFilter := "Fixed Asset".GetFilters;

        if GroupTotals = GroupTotals::"FA Posting Group" then
            FAGeneralReport.SetFAPostingGroup("Fixed Asset", DepreciationBook.Code);
        if GroupTotals = GroupTotals::"Tax Depreciation Group" then
            FAGeneralReportCZF.SetFATaxDeprGroup("Fixed Asset", DepreciationBook.Code);
        FAGeneralReport.AppendPostingDateFilter(FAFilter, StartingDate, EndingDate);
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
        FAFilter, DeprBookText, GroupCodeName, GroupHeadLine, FANoCaption, FADescriptionCaption : Text;
        GroupTotals: Enum "FA Analysis Group CZF";
        GroupAmounts, TotalAmounts, Amounts : array[3] of Decimal;
        HeadLineText: array[5] of Text;
        Date: array[2] of Date;
        i: Integer;
        Period1, Period2, Period3 : Enum "FA Analysis Disposal CZF";
        PostingType1, PostingType2, PostingType3 : Text[30];
        PostingTypeNo1, PostingTypeNo2, PostingTypeNo3 : Integer;
        DateType1, DateType2 : Text[30];
        DateTypeNo1, DateTypeNo2 : Integer;
        StartingDate, EndingDate : Date;
        DeprBookCode: Code[10];
        PrintDetails, SalesReport, TypeExist : Boolean;
        GroupTotalTxt: Label 'Group Total';
        GroupTotalsTxt: Label 'Group Totals';
        SpecifyTogetherErr: Label '%1 must be specified only together with the types %2, %3, %4 or %5.', Comment = '%1 = Period, %2 = Write-Down FieldCaption, %3 = Appreciation FieldCaption, %4 = Custom 1 FieldCaption, %5 = Custom 2 FieldCaption';
        DateTypeErr: Label 'The date type %1 is not a valid option.', Comment = '%1 = Date Type';
        PostingTypeErr: Label 'The posting type %1 is not a valid option.', Comment = '%1 = Posting Type';
        HasBeenModifiedInFAErr: Label '%1 has been modified in fixed asset %2', Comment = '%1 = FieldCaption, %2 = Fixed Asset No.';
        GroupsTxt: Label ' ,FA Class,FA Subclass,FA Location,Main Asset,Global Dimension 1,Global Dimension 2,FA Posting Group,Tax Depreciation Group';
        TwoPlaceholdersTok: Label '%1 %2', Locked = true;

    local procedure SkipRecord(): Boolean
    begin
        exit(
          "Fixed Asset".Inactive or
          (FADepreciationBook."Acquisition Date" = 0D) or
          SalesReport and (FADepreciationBook."Disposal Date" = 0D));
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
            GroupCodeName := StrSubstNo(TwoPlaceholdersTok, GroupTotalsTxt, GroupCodeName);
    end;

    local procedure MakeDateHeadLine()
    begin
        if not PrintDetails then
            exit;
        HeadLineText[1] := DateType1;
        HeadLineText[2] := DateType2;
    end;

    local procedure MakeAmountHeadLine(j: Integer; PostingType: Text[50]; PostingTypeNo: Integer; var Period: Enum "FA Analysis Disposal CZF")
    var
        DisposalTxt: Label ' ,Disposal,Bal. Disposal';
    begin
        if PostingTypeNo = 0 then
            exit;
        if Period = Period::"Bal. Disposal" then
            if (PostingTypeNo <> FADepreciationBook.FieldNo("Write-Down")) and
               (PostingTypeNo <> FADepreciationBook.FieldNo(Appreciation)) and
               (PostingTypeNo <> FADepreciationBook.FieldNo("Custom 1")) and
               (PostingTypeNo <> FADepreciationBook.FieldNo("Custom 2"))
            then
                Error(
                  SpecifyTogetherErr,
                  SelectStr(Period.AsInteger() + 1, DisposalTxt),
                  FADepreciationBook.FieldCaption("Write-Down"),
                  FADepreciationBook.FieldCaption(Appreciation),
                  FADepreciationBook.FieldCaption("Custom 1"),
                  FADepreciationBook.FieldCaption("Custom 2"));

        case PostingTypeNo of
            FADepreciationBook.FieldNo("Proceeds on Disposal"),
          FADepreciationBook.FieldNo("Gain/Loss"):
                Period := Period::" ";
            FADepreciationBook.FieldNo("Book Value on Disposal"):
                Period := Period::Disposal;
        end;
        HeadLineText[j] := StrSubstNo(TwoPlaceholdersTok, PostingType, SelectStr(Period.AsInteger() + 1, DisposalTxt));
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

    local procedure CheckDateType(DateType: Text[30]; var DateTypeNo: Integer)
    begin
        if DateType = '' then
            exit;
        FADateType.SetRange(FADateType."G/L Entry", true);
        if FADateType.FindSet() then
            repeat
                TypeExist := DateType = FADateType."FA Date Type Name";
                if TypeExist then
                    DateTypeNo := FADateType."FA Date Type No.";
            until (FADateType.Next() = 0) or TypeExist;
        if FADateType.FindSet() then;
        if not TypeExist then
            Error(DateTypeErr, DateType);
    end;

    local procedure CheckPostingType(PostingType: Text[30]; var PostingTypeNo: Integer)
    begin
        if PostingType = '' then
            exit;
        FAPostingType.SetRange(FAPostingType."G/L Entry", true);
        if FAPostingType.FindSet() then
            repeat
                TypeExist := PostingType = FAPostingType."FA Posting Type Name";
                if TypeExist then
                    PostingTypeNo := FAPostingType."FA Posting Type No.";
            until (FAPostingType.Next() = 0) or TypeExist;
        if FAPostingType.FindSet() then;
        if not TypeExist then
            Error(PostingTypeErr, PostingType);
    end;

    procedure SetMandatoryFields(DepreciationBookCodeFrom: Code[10]; StartingDateFrom: Date; EndingDateFrom: Date)
    begin
        DeprBookCode := DepreciationBookCodeFrom;
        StartingDate := StartingDateFrom;
        EndingDate := EndingDateFrom;
    end;

    procedure SetDateType(DateType1From: Text[30]; DateType2From: Text[30])
    begin
        DateType1 := DateType1From;
        DateType2 := DateType2From;
    end;

    procedure SetPostingType(PostingType1From: Text[30]; PostingType2From: Text[30]; PostingType3From: Text[30])
    begin
        PostingType1 := PostingType1From;
        PostingType2 := PostingType2From;
        PostingType3 := PostingType3From;
    end;

    procedure SetPeriod(Period1From: Enum "FA Analysis Disposal CZF"; Period2From: Enum "FA Analysis Disposal CZF"; Period3From: Enum "FA Analysis Disposal CZF")
    begin
        Period1 := Period1From;
        Period2 := Period2From;
        Period3 := Period3From;
    end;

    procedure SetTotalFields(GroupTotalsFrom: Enum "FA Analysis Group CZF"; PrintDetailsFrom: Boolean; SalesReportFrom: Boolean)
    begin
        GroupTotals := GroupTotalsFrom;
        PrintDetails := PrintDetailsFrom;
        SalesReport := SalesReportFrom;
    end;

    procedure GetFASetup()
    begin
        if DeprBookCode = '' then begin
            FASetup.Get();
            DeprBookCode := FASetup."Default Depr. Book";
        end;
        FAPostingType.CreateTypes();
        FADateType.CreateTypes();
    end;
}
