// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.FinancialReports;

using Microsoft.CashFlow.Forecast;
using Microsoft.CostAccounting.Account;
using Microsoft.CostAccounting.Budget;
using Microsoft.Finance.Analysis;
using Microsoft.Finance.Consolidation;
using Microsoft.Finance.Dimension;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Budget;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Foundation.Company;
using Microsoft.Foundation.Period;
using System.Text;
using System.Utilities;

report 11795 "Income Statement CZL"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Src/Reports/IncomeStatement.rdl';
    AccessByPermission = tabledata "G/L Account" = R;
    ApplicationArea = Basic, Suite;
    Caption = 'Income Statement';
    UsageCategory = ReportsAndAnalysis;
    AllowScheduling = false;

    dataset
    {
        dataitem(AccScheduleName; "Acc. Schedule Name")
        {
            DataItemTableView = sorting(Name);
            column(AccScheduleName_Name; Name)
            {
            }
            dataitem(Heading; Integer)
            {
                DataItemTableView = sorting(Number) where(Number = const(1));
                column(ColumnLayoutName; ColumnLayoutName)
                {
                }
                column(FiscalStartDate; Format(FiscalStartDate))
                {
                }
                column(PeriodText; PeriodText)
                {
                }
                column(COMPANYNAME; CompanyProperty.DisplayName())
                {
                }
                column(AccScheduleName_Description; AccScheduleName.Description)
                {
                }
                column(AnalysisView_Code; AnalysisView.Code)
                {
                }
                column(AnalysisView_Name; AnalysisView.Name)
                {
                }
                column(HeaderText; HeaderText)
                {
                }
                column(AccScheduleLineTABLECAPTION_AccSchedLineFilter; "Acc. Schedule Line".TableCaption + ': ' + AccSchedLineFilter)
                {
                }
                column(AccSchedLineFilter; AccSchedLineFilter)
                {
                }
                column(ShowAccSchedSetup; ShowAccSchedSetup)
                {
                }
                column(CompanyInfo_Name; CompanyInformation.Name)
                {
                }
                dataitem(AccSchedLineSpec; "Acc. Schedule Line")
                {
                    DataItemLink = "Schedule Name" = field(Name);
                    DataItemLinkReference = AccScheduleName;
                    DataItemTableView = sorting("Schedule Name", "Line No.");
                    column(AccSchedLineSpec_Show; Show)
                    {
                    }
                    column(AccSchedLineSpec__Totaling_Type_; "Totaling Type")
                    {
                    }
                    column(AccSchedLineSpec_Totaling; Totaling)
                    {
                    }
                    column(AccSchedLineSpec_Description; Description)
                    {
                    }
                    column(AccSchedLineSpec__Row_No__; "Row No.")
                    {
                    }
                    column(AccSchedLineSpec__Row_Type_; "Row Type")
                    {
                    }
                    column(AccSchedLineSpec__Amount_Type_; "Amount Type")
                    {
                    }
                    column(Bold_format; Format(Bold))
                    {
                    }
                    column(Italic_format; Format(Italic))
                    {
                    }
                    column(Underline_format; Format(Underline))
                    {
                    }
                    column(ShowOppSign_format; Format("Show Opposite Sign"))
                    {
                    }
                    column(NewPage_format; Format("New Page"))
                    {
                    }
                    column(AnalysisView__Dimension_1_Code_; AnalysisView."Dimension 1 Code")
                    {
                    }
                    column(AccSchedLineSpec__Dimension_1_Totaling_; "Dimension 1 Totaling")
                    {
                    }
                    column(AnalysisView__Dimension_2_Code_; AnalysisView."Dimension 2 Code")
                    {
                    }
                    column(AccSchedLineSpec__Dimension_2_Totaling_; "Dimension 2 Totaling")
                    {
                    }
                    column(AnalysisView__Dimension_3_Code_; AnalysisView."Dimension 3 Code")
                    {
                    }
                    column(AccSchedLineSpec__Dimension_3_Totaling_; "Dimension 3 Totaling")
                    {
                    }
                    column(AnalysisView__Dimension_4_Code_; AnalysisView."Dimension 4 Code")
                    {
                    }
                    column(AccSchedLineSpec__Dimension_4_Totaling_; "Dimension 4 Totaling")
                    {
                    }
                    column(AccSchedLineSpec_Schedule_Name; "Schedule Name")
                    {
                    }
                    column(SetupLineShadowed; LineShadowed)
                    {
                    }
                    trigger OnAfterGetRecord()
                    begin
                        if "Row No." <> '' then
                            LineShadowed := not LineShadowed
                        else
                            LineShadowed := false;
                    end;

                    trigger OnPreDataItem()
                    begin
                        if not ShowAccSchedSetup then
                            CurrReport.Break();

                        NextPageGroupNo += 1;
                    end;
                }
                dataitem(PageBreak; Integer)
                {
                    DataItemTableView = sorting(Number) where(Number = const(1));

                    trigger OnPreDataItem()
                    begin
                        if not ShowAccSchedSetup then
                            CurrReport.Break();
                    end;
                }
                dataitem("Acc. Schedule Line"; "Acc. Schedule Line")
                {
                    DataItemLink = "Schedule Name" = field(Name);
                    DataItemLinkReference = AccScheduleName;
                    DataItemTableView = sorting("Schedule Name", "Line No.");
                    PrintOnlyIfDetail = true;
                    column(NextPageGroupNo; NextPageGroupNo)
                    {
                    }
                    column(Acc__Schedule_Line_Description; Description)
                    {
                    }
                    column(Acc__Schedule_Line__Row_No; "Row No.")
                    {
                    }
                    column(Acc__Schedule_Line_Line_No; "Line No.")
                    {
                    }
                    column(Bold_control; Bold_control)
                    {
                    }
                    column(Italic_control; Italic_control)
                    {
                    }
                    column(Underline_control; Underline_control)
                    {
                    }
                    column(LineShadowed; LineShadowed)
                    {
                    }
                    dataitem(ColumnLayoutLoop; Integer)
                    {
                        DataItemTableView = sorting(Number) where(Number = filter(1 .. 2));
                        column(ColumnNo; TempColumnLayout."Column No.")
                        {
                        }
                        column(Header; Header)
                        {
                        }
                        column(RoundingHeader; RoundingHeader)
                        {
                            AutoCalcField = false;
                        }
                        column(ColumnValuesAsText; ColumnValuesAsText)
                        {
                            AutoCalcField = false;
                        }
                        column(LineSkipped; LineSkipped)
                        {
                        }
                        column(LineNo_ColumnLayout; Number)
                        {
                        }
                        trigger OnAfterGetRecord()
                        begin
                            if TempColumnLayout.Show = TempColumnLayout.Show::Never then
                                CurrReport.Skip();

                            case Number of
                                1:
                                    TempColumnLayout.FindFirst();
                                2:
                                    TempColumnLayout.FindLast();
                            end;

                            case Number of
                                1:
                                    Header := ActualAccPeriodBalTxt;
                                2:
                                    Header := PrevAccPeriodBalTxt;
                            end;

                            RoundingHeader := '';

                            if TempColumnLayout."Rounding Factor" in [TempColumnLayout."Rounding Factor"::"1000", TempColumnLayout."Rounding Factor"::"1000000"] then
                                case TempColumnLayout."Rounding Factor" of
                                    TempColumnLayout."Rounding Factor"::"1000":
                                        RoundingHeader := ThousandsTxt;
                                    TempColumnLayout."Rounding Factor"::"1000000":
                                        RoundingHeader := MillionsTxt;
                                end;

                            ColumnValuesAsText := '';

                            ColumnValuesDisplayed := AccSchedManagement.CalcCell("Acc. Schedule Line", TempColumnLayout, UseAmtsInAddCurr);
                            if AccSchedManagement.GetDivisionError() then begin
                                if ShowError in [ShowError::"Division by Zero", ShowError::Both] then
                                    ColumnValuesAsText := ErrorTxt;
                            end else
                                if AccSchedManagement.GetPeriodError() then begin
                                    if ShowError in [ShowError::"Period Error", ShowError::Both] then
                                        ColumnValuesAsText := NotAvailableTxt;
                                end else begin
                                    ColumnValuesAsText :=
                                      AccSchedManagement.FormatCellAsText(TempColumnLayout, ColumnValuesDisplayed, UseAmtsInAddCurr);

                                    if "Acc. Schedule Line"."Totaling Type" = "Acc. Schedule Line"."Totaling Type"::Formula then
                                        case "Acc. Schedule Line".Show of
                                            "Acc. Schedule Line".Show::"When Positive Balance":
                                                if ColumnValuesDisplayed < 0 then
                                                    ColumnValuesAsText := '';
                                            "Acc. Schedule Line".Show::"When Negative Balance":
                                                if ColumnValuesDisplayed > 0 then
                                                    ColumnValuesAsText := '';
                                            "Acc. Schedule Line".Show::"If Any Column Not Zero":
                                                if ColumnValuesDisplayed = 0 then
                                                    ColumnValuesAsText := '';
                                        end;
                                end;

                            if (ColumnValuesAsText <> '') or ("Acc. Schedule Line".Show = "Acc. Schedule Line".Show::Yes) then
                                LineSkipped := false;
                        end;

                        trigger OnPostDataItem()
                        begin
                            if LineSkipped then
                                LineShadowed := not LineShadowed;
                        end;

                        trigger OnPreDataItem()
                        begin
                            LineSkipped := true;
                        end;
                    }
                    trigger OnAfterGetRecord()
                    begin
                        if (Show = Show::No) or not ShowLine(Bold, Italic) then
                            CurrReport.Skip();

                        if SkipEmptyLines then
                            if AccScheduleManagementCZL.EmptyLine("Acc. Schedule Line", ColumnLayoutName, UseAmtsInAddCurr) then
                                CurrReport.Skip();

                        Bold_control := Bold;
                        Italic_control := Italic;
                        Underline_control := Underline;
                        PageGroupNo := NextPageGroupNo;
                        if "New Page" then
                            NextPageGroupNo := PageGroupNo + 1;

                        if "Row No." <> '' then
                            LineShadowed := not LineShadowed
                        else
                            LineShadowed := false;
                    end;

                    trigger OnPreDataItem()
                    begin
                        PageGroupNo := NextPageGroupNo;

                        SetFilter("Dimension 1 Filter", Dim1Filter);
                        SetFilter("Dimension 2 Filter", Dim2Filter);
                        SetFilter("Dimension 3 Filter", Dim3Filter);
                        SetFilter("Dimension 4 Filter", Dim4Filter);
                        SetFilter("Date Filter", DateFilter);
                        SetFilter("G/L Budget Filter", GLBudgetFilter);
                        SetFilter("Cost Budget Filter", CostBudgetFilter);
                        SetFilter("Business Unit Filter", BusinessUnitFilter);
                        SetFilter("Cost Center Filter", CostCenterFilter);
                        SetFilter("Cost Object Filter", CostObjectFilter);
                        SetFilter("Cash Flow Forecast Filter", CashFlowFilter);
                    end;
                }
            }
            trigger OnAfterGetRecord()
            begin
                GeneralLedgerSetup.Get();
                if "Analysis View Name" <> '' then
                    AnalysisView.Get("Analysis View Name")
                else begin
                    AnalysisView.Init();
                    AnalysisView."Dimension 1 Code" := GeneralLedgerSetup."Global Dimension 1 Code";
                    AnalysisView."Dimension 2 Code" := GeneralLedgerSetup."Global Dimension 2 Code";
                end;

                if UseAmtsInAddCurr then
                    HeaderText := StrSubstNo(AmountsInTxt, GeneralLedgerSetup."Additional Reporting Currency")
                else
                    if GeneralLedgerSetup."LCY Code" <> '' then
                        HeaderText := StrSubstNo(AmountsInTxt, GeneralLedgerSetup."LCY Code")
                    else
                        HeaderText := '';
            end;

            trigger OnPreDataItem()
            begin
                SetRange(Name, AccSchedName);

                PageGroupNo := 1;
                NextPageGroupNo := 1;
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
                    group("Layout")
                    {
                        Caption = 'Layout';
                        Visible = AccSchedNameEditable;
                        field(AccSchedNameCZL; AccSchedName)
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Acc. Schedule Name';
                            Lookup = true;
                            TableRelation = "Acc. Schedule Name";
                            ToolTip = 'Specifies the name of the account schedule to be shown in the report.';

                            trigger OnLookup(var Text: Text): Boolean
                            var
                                EntrdSchedName: Text[10];
                            begin
                                EntrdSchedName := CopyStr(Text, 1, 10);
                                if AccSchedManagement.LookupName(AccSchedName, EntrdSchedName) then
                                    AccSchedName := EntrdSchedName;
                            end;

                            trigger OnValidate()
                            begin
                                ValidateAccSchedName()
                            end;
                        }
                        field(ColumnLayoutNameCZL; ColumnLayoutName)
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Column Layout Name';
                            Lookup = true;
                            TableRelation = "Column Layout Name".Name;
                            ToolTip = 'Specifies the name of the column layout that you want to use in the window.';

                            trigger OnLookup(var Text: Text): Boolean
                            var
                                EntrdColumnName: Text[10];
                            begin
                                EntrdColumnName := CopyStr(Text, 1, 10);
                                if AccSchedManagement.LookupColumnName(ColumnLayoutName, EntrdColumnName) then
                                    ColumnLayoutName := EntrdColumnName;
                            end;

                            trigger OnValidate()
                            begin
                                if ColumnLayoutName = '' then
                                    Error(ColumnLayoutNameErr);
                                AccSchedManagement.CheckColumnName(ColumnLayoutName);
                            end;
                        }
                    }
                    group(Filters)
                    {
                        Caption = 'Filters';
                        field(DateFilterCZL; DateFilter)
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Date Filter';
                            ToolTip = 'Specifies the date filter for G/L accounts entries.';

                            trigger OnValidate()
                            var
                                FilterTokens: Codeunit "Filter Tokens";
                            begin
                                FilterTokens.MakeDateFilter(DateFilter);
                                "Acc. Schedule Line".SetFilter("Date Filter", DateFilter);
                                DateFilter := "Acc. Schedule Line".GetFilter("Date Filter");
                            end;
                        }
                        field(GLBudgetFilterCZL; GLBudgetFilter)
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'G/L Budget Filter';
                            TableRelation = "G/L Budget Name".Name;
                            ToolTip = 'Specifies a general ledger budget filter for the report.';

                            trigger OnValidate()
                            begin
                                "Acc. Schedule Line".SetFilter("G/L Budget Filter", GLBudgetFilter);
                                GLBudgetFilter := "Acc. Schedule Line".GetFilter("G/L Budget Filter");
                            end;
                        }
                        field(CostBudgetFilterCZL; CostBudgetFilter)
                        {
                            ApplicationArea = CostAccounting;
                            Caption = 'Cost Budget Filter';
                            TableRelation = "Cost Budget Name".Name;
                            ToolTip = 'Specifies a cost budget filter for the report.';

                            trigger OnValidate()
                            begin
                                "Acc. Schedule Line".SetFilter("Cost Budget Filter", CostBudgetFilter);
                                CostBudgetFilter := "Acc. Schedule Line".GetFilter("Cost Budget Filter");
                            end;
                        }
                        field(BusinessUnitFilterCZL; BusinessUnitFilter)
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Business Unit Filter';
                            LookupPageId = "Business Unit List";
                            TableRelation = "Business Unit";
                            ToolTip = 'Specifies a business unit filter for the report.';

                            trigger OnValidate()
                            begin
                                "Acc. Schedule Line".SetFilter("Business Unit Filter", BusinessUnitFilter);
                                BusinessUnitFilter := "Acc. Schedule Line".GetFilter("Business Unit Filter");
                            end;
                        }
                    }
                    group("Dimension Filters")
                    {
                        Caption = 'Dimension Filters';
                        field(Dim1FilterCZL; Dim1Filter)
                        {
                            ApplicationArea = Basic, Suite;
                            CaptionClass = FormGetCaptionClass(1);
                            Caption = 'Dimension 1 Filter';
                            Enabled = Dim1FilterEnable;
                            ToolTip = 'Specifies the filter for dimension 1.';

                            trigger OnLookup(var Text: Text): Boolean
                            begin
                                exit(FormLookUpDimFilter(AnalysisView."Dimension 1 Code", Text));
                            end;
                        }
                        field(Dim2FilterCZL; Dim2Filter)
                        {
                            ApplicationArea = Basic, Suite;
                            CaptionClass = FormGetCaptionClass(2);
                            Caption = 'Dimension 2 Filter';
                            Enabled = Dim2FilterEnable;
                            ToolTip = 'Specifies the filter for dimension 2.';

                            trigger OnLookup(var Text: Text): Boolean
                            begin
                                exit(FormLookUpDimFilter(AnalysisView."Dimension 2 Code", Text));
                            end;
                        }
                        field(Dim3FilterCZL; Dim3Filter)
                        {
                            ApplicationArea = Basic, Suite;
                            CaptionClass = FormGetCaptionClass(3);
                            Caption = 'Dimension 3 Filter';
                            Enabled = Dim3FilterEnable;
                            ToolTip = 'Specifies the filter for dimension 3.';

                            trigger OnLookup(var Text: Text): Boolean
                            begin
                                exit(FormLookUpDimFilter(AnalysisView."Dimension 3 Code", Text));
                            end;
                        }
                        field(Dim4FilterCZL; Dim4Filter)
                        {
                            ApplicationArea = Basic, Suite;
                            CaptionClass = FormGetCaptionClass(4);
                            Caption = 'Dimension 4 Filter';
                            Enabled = Dim4FilterEnable;
                            ToolTip = 'Specifies the filter for dimension 4.';

                            trigger OnLookup(var Text: Text): Boolean
                            begin
                                exit(FormLookUpDimFilter(AnalysisView."Dimension 4 Code", Text));
                            end;
                        }
                        field(CostCenterFilterCZL; CostCenterFilter)
                        {
                            ApplicationArea = CostAccounting;
                            Caption = 'Cost Center Filter';
                            ToolTip = 'Specifies a cost center filter for the report.';

                            trigger OnLookup(var Text: Text): Boolean
                            var
                                CostCenter: Record "Cost Center";
                            begin
                                exit(CostCenter.LookupCostCenterFilter(Text));
                            end;
                        }
                        field(CostObjectFilterCZL; CostObjectFilter)
                        {
                            ApplicationArea = CostAccounting;
                            Caption = 'Cost Object Filter';
                            ToolTip = 'Specifies a cost object filter for the report.';

                            trigger OnLookup(var Text: Text): Boolean
                            var
                                CostObject: Record "Cost Object";
                            begin
                                exit(CostObject.LookupCostObjectFilter(Text));
                            end;
                        }
                        field(CashFlowFilterCZL; CashFlowFilter)
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Cash Flow Filter';
                            ToolTip = 'Specifies a cash flow filter for the report.';

                            trigger OnLookup(var Text: Text): Boolean
                            var
                                CashFlowForecast: Record "Cash Flow Forecast";
                            begin
                                exit(CashFlowForecast.LookupCashFlowFilter(Text));
                            end;
                        }
                    }
                    group(Show)
                    {
                        Caption = 'Show';
                        field(ShowErrorCZL; ShowError)
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Show Error';
                            OptionCaption = 'None,Division by Zero,Period Error,Both';
                            ToolTip = 'Specifies when the error is to be show';
                        }
                        field(UseAmtsInAddCurrCZL; UseAmtsInAddCurr)
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Show Amounts in Add. Reporting Currency';
                            MultiLine = true;
                            ToolTip = 'Specifies when the amounts in add. reporting currency is to be show';
                        }
                        field(ShowAccSchedSetupCZL; ShowAccSchedSetup)
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Show Account Schedule Setup';
                            MultiLine = true;
                            ToolTip = 'Specifies when the account schedule setup is to be show';
                        }
                        field(SkipEmptyLinesCZL; SkipEmptyLines)
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Skip Empty Lines';
                            ToolTip = 'Specifies when the empty lines are to be skip';
                        }
                    }
                }
            }
        }
        trigger OnInit()
        begin
            Dim4FilterEnable := true;
            Dim3FilterEnable := true;
            Dim2FilterEnable := true;
            Dim1FilterEnable := true;
            AccSchedNameEditable := true;
        end;

        trigger OnOpenPage()
        var
            FinancialReportMgt: Codeunit "Financial Report Mgt.";
        begin
            FinancialReportMgt.Initialize();
            GeneralLedgerSetup.Get();
            AccSchedName := '';
            ColumnLayoutName := '';
            TransferValues();
            if AccSchedName <> '' then
                if ColumnLayoutName = '' then
                    ValidateAccSchedName();
        end;
    }
    labels
    {
        ReportCaptionLbl = 'Income Statement';
        AccScheduleName_Name_CaptionLbl = 'Account Schedule';
        ColumnLayoutNameCaptionLbl = 'Column Layout';
        FiscalStartDateCaptionLbl = 'Fiscal Start Date';
        PeriodTextCaptionLbl = 'Period';
        CurrReport_PAGENOCaptionLbl = 'Page';
        AnalysisView__Dimension_1_Code_CaptionLbl = 'Dimension Code';
        AccSchedLineSpec_DescriptionCaptionLbl = 'Description';
        AccSchedLineSpec__Row_No__CaptionLbl = 'Row No.';
        AccSchedLineSpec__Show_Opposite_Sign_CaptionLbl = 'Show Opposite Sign';
        AccSchedLineSpec_UnderlineCaptionLbl = 'Underline';
        AccSchedLineSpec_ItalicCaptionLbl = 'Italic';
        AccSchedLineSpec_BoldCaptionLbl = 'Bold';
        AccSchedLineSpec_ShowCaptionLbl = 'Show';
        AccSchedLineSpec__New_Page_CaptionLbl = 'New Page';
        AccSchedLineSpec__Totaling_Type_CaptionLbl = 'Totaling Type';
        AccSchedLineSpec_TotalingCaptionLbl = 'Totaling';
        AccSchedLineSpec__Row_Type_CaptionLbl = 'Row Type';
        AccSchedLineSpec__Amount_Type_CaptionLbl = 'Amount Type';
    }
    trigger OnPreReport()
    var
        FinancialReportMgt: Codeunit "Financial Report Mgt.";
        TableFieldUniqueErr: Label '%1 %2 must be unique!', Comment = '%1 = TableCaption, %2 = FieldCaption';
    begin
        if AccSchedName = '' then begin
            if AccScheduleName.GetRangeMin(Name) <> AccScheduleName.GetRangeMax(Name) then
                Error(TableFieldUniqueErr, AccScheduleName.TableCaption, AccScheduleName.FieldCaption(Name));
            AccSchedName := AccScheduleName.GetRangeMin(Name);
        end;

        FinancialReportMgt.Initialize();
        TransferValues();
        UpdateFilters();
        InitAccSched();
        CompanyInformation.Get();
    end;

    var
        CompanyInformation: Record "Company Information";
        TempColumnLayout: Record "Column Layout" temporary;
        AnalysisView: Record "Analysis View";
        GeneralLedgerSetup: Record "General Ledger Setup";
        AccSchedManagement: Codeunit AccSchedManagement;
        AccScheduleManagementCZL: Codeunit "Acc. Schedule Management CZL";
        AccountingPeriodMgt: Codeunit "Accounting Period Mgt.";
        AccSchedName: Code[10];
        AccSchedNameHidden: Code[10];
        ColumnLayoutName: Code[10];
        ColumnLayoutNameHidden: Code[10];
        FinancialReportName: Code[10];
        EndDate: Date;
        ShowError: Option "None","Division by Zero","Period Error",Both;
        DateFilter: Text;
        UseHiddenFilters: Boolean;
        DateFilterHidden: Text;
        GLBudgetFilter: Text;
        GLBudgetFilterHidden: Text;
        CostBudgetFilter: Text;
        CostBudgetFilterHidden: Text;
        BusinessUnitFilter: Text;
        BusinessUnitFilterHidden: Text;
        Dim1Filter: Text;
        Dim1FilterHidden: Text;
        Dim2Filter: Text;
        Dim2FilterHidden: Text;
        Dim3Filter: Text;
        Dim3FilterHidden: Text;
        Dim4Filter: Text;
        Dim4FilterHidden: Text;
        CostCenterFilter: Text;
        CostObjectFilter: Text;
        CashFlowFilter: Text;
        FiscalStartDate: Date;
        ColumnValuesDisplayed: Decimal;
        ColumnValuesAsText: Text[30];
        PeriodText: Text;
        AccSchedLineFilter: Text;
        Header: Text[50];
        RoundingHeader: Text[30];
        UseAmtsInAddCurr: Boolean;
        ShowAccSchedSetup: Boolean;
        HeaderText: Text;
        Bold_control: Boolean;
        Italic_control: Boolean;
        Underline_control: Boolean;
        PageGroupNo: Integer;
        NextPageGroupNo: Integer;
        Dim1FilterEnable: Boolean;
        Dim2FilterEnable: Boolean;
        Dim3FilterEnable: Boolean;
        Dim4FilterEnable: Boolean;
        AccSchedNameEditable: Boolean;
        LineShadowed: Boolean;
        LineSkipped: Boolean;
        SkipEmptyLines: Boolean;
        ThousandsTxt: Label '(Thousands)';
        MillionsTxt: Label '(Millions)';
        ErrorTxt: Label '* ERROR *';
        AmountsInTxt: Label 'All amounts are in %1.', Comment = '%1 = Currency Code';
        NotAvailableTxt: Label 'Not Available';
        ColumnLayoutNameErr: Label 'Enter the Column Layout Name.';
        ActualAccPeriodBalTxt: Label 'Actual Accounting Period Balance';
        PrevAccPeriodBalTxt: Label 'Previous Accounting Period Balance';

    procedure InitAccSched()
    begin
        AccScheduleName.SetRange(Name, AccSchedName);
        "Acc. Schedule Line".SetFilter("Date Filter", DateFilter);
        "Acc. Schedule Line".SetFilter("G/L Budget Filter", GLBudgetFilter);
        "Acc. Schedule Line".SetFilter("Cost Budget Filter", CostBudgetFilter);
        "Acc. Schedule Line".SetFilter("Business Unit Filter", BusinessUnitFilter);
        "Acc. Schedule Line".SetFilter("Dimension 1 Filter", Dim1Filter);
        "Acc. Schedule Line".SetFilter("Dimension 2 Filter", Dim2Filter);
        "Acc. Schedule Line".SetFilter("Dimension 3 Filter", Dim3Filter);
        "Acc. Schedule Line".SetFilter("Dimension 4 Filter", Dim4Filter);
        "Acc. Schedule Line".SetFilter("Cost Center Filter", CostCenterFilter);
        "Acc. Schedule Line".SetFilter("Cost Object Filter", CostObjectFilter);
        "Acc. Schedule Line".SetFilter("Cash Flow Forecast Filter", CashFlowFilter);

        EndDate := "Acc. Schedule Line".GetRangeMax("Date Filter");
        FiscalStartDate := AccountingPeriodMgt.FindFiscalYear(EndDate);

        AccSchedLineFilter := "Acc. Schedule Line".GetFilters;
        PeriodText := "Acc. Schedule Line".GetFilter("Date Filter");
        AccSchedManagement.CopyColumnsToTemp(ColumnLayoutName, TempColumnLayout);
    end;

    procedure SetFinancialReportNameNonEditable(NewAccSchedName: Code[10])
    begin
        SetFinancialReportName(NewAccSchedName);
        AccSchedNameEditable := false;
    end;

    procedure SetFinancialReportName(NewFinancialReportName: Code[10])
    var
        FinancialReportLocal: Record "Financial Report";
    begin
        FinancialReportName := NewFinancialReportName;
        if FinancialReportLocal.Get(FinancialReportName) then begin
            AccSchedNameHidden := FinancialReportLocal."Financial Report Row Group";
            AccSchedNameEditable := false;
        end;
    end;

    procedure SetAccSchedName(NewAccSchedName: Code[10])
    begin
        AccSchedNameHidden := NewAccSchedName;
    end;

    procedure SetColumnLayoutName(ColLayoutName: Code[10])
    begin
        ColumnLayoutNameHidden := ColLayoutName;
    end;

    procedure SetFilters(NewDateFilter: Text; NewBudgetFilter: Text; NewCostBudgetFilter: Text; NewBusUnitFilter: Text; NewDim1Filter: Text; NewDim2Filter: Text; NewDim3Filter: Text; NewDim4Filter: Text)
    begin
        DateFilterHidden := NewDateFilter;
        GLBudgetFilterHidden := NewBudgetFilter;
        CostBudgetFilterHidden := NewCostBudgetFilter;
        BusinessUnitFilterHidden := NewBusUnitFilter;
        Dim1FilterHidden := NewDim1Filter;
        Dim2FilterHidden := NewDim2Filter;
        Dim3FilterHidden := NewDim3Filter;
        Dim4FilterHidden := NewDim4Filter;
        UseHiddenFilters := true;
    end;

    procedure ShowLine(Bold: Boolean; Italic: Boolean): Boolean
    begin
        if "Acc. Schedule Line"."Totaling Type" = "Acc. Schedule Line"."Totaling Type"::"Set Base For Percent" then
            exit(false);
        if "Acc. Schedule Line".Show = "Acc. Schedule Line".Show::No then
            exit(false);
        if "Acc. Schedule Line".Bold <> Bold then
            exit(false);
        if "Acc. Schedule Line".Italic <> Italic then
            exit(false);

        exit(true);
    end;

    local procedure FormLookUpDimFilter(Dim: Code[20]; var Text: Text): Boolean
    var
        DimensionValue: Record "Dimension Value";
        DimensionValueList: Page "Dimension Value List";
    begin
        if Dim = '' then
            exit(false);
        DimensionValueList.LookupMode(true);
        DimensionValue.SetRange("Dimension Code", Dim);
        DimensionValueList.SetTableView(DimensionValue);
        if DimensionValueList.RunModal() = Action::LookupOK then begin
            DimensionValueList.GetRecord(DimensionValue);
            Text := DimensionValueList.GetSelectionFilter();
            exit(true);
        end;
        exit(false)
    end;

    local procedure FormGetCaptionClass(DimNo: Integer): Text[250]
    begin
        exit(AnalysisView.GetCaptionClassCZL(DimNo));
    end;

    local procedure TransferValues()
    begin
        GeneralLedgerSetup.Get();
        if AccSchedNameHidden <> '' then
            AccSchedName := AccSchedNameHidden;
        if ColumnLayoutNameHidden <> '' then
            ColumnLayoutName := ColumnLayoutNameHidden;

        if AccSchedName <> '' then
            if not AccScheduleName.Get(AccSchedName) then
                AccSchedName := '';
        if AccSchedName = '' then begin
            AccScheduleName.SetRange("Acc. Schedule Type CZL", AccScheduleName."Acc. Schedule Type CZL"::"Income Statement");
            if AccScheduleName.IsEmpty() then
                AccScheduleName.SetRange("Acc. Schedule Type CZL");
            if AccScheduleName.FindFirst() then
                AccSchedName := AccScheduleName.Name;
        end;

        if AccScheduleName."Analysis View Name" <> '' then
            AnalysisView.Get(AccScheduleName."Analysis View Name")
        else begin
            AnalysisView."Dimension 1 Code" := GeneralLedgerSetup."Global Dimension 1 Code";
            AnalysisView."Dimension 2 Code" := GeneralLedgerSetup."Global Dimension 2 Code";
        end;
    end;

    local procedure UpdateFilters()
    begin
        if UseHiddenFilters then begin
            DateFilter := DateFilterHidden;
            GLBudgetFilter := GLBudgetFilterHidden;
            CostBudgetFilter := CostBudgetFilterHidden;
            BusinessUnitFilter := BusinessUnitFilterHidden;
            Dim1Filter := Dim1FilterHidden;
            Dim2Filter := Dim2FilterHidden;
            Dim3Filter := Dim3FilterHidden;
            Dim4Filter := Dim4FilterHidden;
        end;
    end;

    procedure ValidateAccSchedName()
    begin
        AccSchedManagement.CheckName(AccSchedName);
        AccScheduleName.Get(AccSchedName);
        if AccScheduleName."Analysis View Name" <> '' then
            AnalysisView.Get(AccScheduleName."Analysis View Name")
        else begin
            Clear(AnalysisView);
            AnalysisView."Dimension 1 Code" := GeneralLedgerSetup."Global Dimension 1 Code";
            AnalysisView."Dimension 2 Code" := GeneralLedgerSetup."Global Dimension 2 Code";
        end;
        Dim1FilterEnable := AnalysisView."Dimension 1 Code" <> '';
        Dim2FilterEnable := AnalysisView."Dimension 2 Code" <> '';
        Dim3FilterEnable := AnalysisView."Dimension 3 Code" <> '';
        Dim4FilterEnable := AnalysisView."Dimension 4 Code" <> '';
    end;
}
