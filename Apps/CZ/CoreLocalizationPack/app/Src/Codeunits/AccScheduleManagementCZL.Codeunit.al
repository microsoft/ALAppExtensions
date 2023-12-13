// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.FinancialReports;

using System.Utilities;

codeunit 11700 "Acc. Schedule Management CZL"
{
    var
        AccSChedExtensionMgtCZL: Codeunit "Acc. Sched. Extension Mgt. CZL";

    [EventSubscriber(ObjectType::Codeunit, Codeunit::AccSchedManagement, 'OnAfterCalcCellValue', '', false, false)]
    local procedure CalcCZLOnAfterCalcCellValue(var AccSchedLine: Record "Acc. Schedule Line"; var Result: Decimal)
    begin
        case AccSchedLine."Totaling Type" of
            AccSchedLine."Totaling Type"::"Posting Accounts", AccSchedLine."Totaling Type"::"Total Accounts":
                case AccSchedLine."Calc CZL" of
                    AccSchedLine."Calc CZL"::"When Positive":
                        if Result < 0 then
                            Result := 0;
                    AccSchedLine."Calc CZL"::"When Negative":
                        if Result > 0 then
                            Result := 0;
                    AccSchedLine."Calc CZL"::Never:
                        Result := 0;
                end;
            AccSchedLine."Totaling Type"::"Constant CZL":
                if not Evaluate(Result, AccSchedLine.Totaling) then
                    ;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Financial Report Mgt.", 'OnBeforePrint', '', false, false)]
    local procedure PrintAccScheduleByType(var FinancialReport: Record "Financial Report"; var IsHandled: Boolean)
    var
        AccScheduleName: Record "Acc. Schedule Name";
        BalanceSheetCZL: Report "Balance Sheet CZL";
        IncomeStatementCZL: Report "Income Statement CZL";
    begin
        OnBeforePrintAccScheduleByType(FinancialReport, IsHandled);
        if IsHandled then
            exit;

        AccScheduleName.Get(FinancialReport."Financial Report Row Group");
        case AccScheduleName."Acc. Schedule Type CZL" of
            AccScheduleName."Acc. Schedule Type CZL"::"Balance Sheet":
                begin
                    BalanceSheetCZL.SetFinancialReportName(FinancialReport.Name);
                    BalanceSheetCZL.Run();
                    IsHandled := true;
                end;
            AccScheduleName."Acc. Schedule Type CZL"::"Income Statement":
                begin
                    IncomeStatementCZL.SetFinancialReportName(FinancialReport.Name);
                    IncomeStatementCZL.Run();
                    IsHandled := true;
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Acc. Schedule Overview", 'OnBeforePrint', '', false, false)]
    local procedure AccScheduleOverviewOnBeforePrint(var AccScheduleLine: Record "Acc. Schedule Line"; ColumnLayoutName: Code[10]; var IsHandled: Boolean)
    var
        AccScheduleName: Record "Acc. Schedule Name";
        BalanceSheetCZL: Report "Balance Sheet CZL";
        IncomeStatementCZL: Report "Income Statement CZL";
        DateFilter2, GLBudgetFilter2, BusUnitFilter, CostBudgetFilter2, Dim1Filter, Dim2Filter, Dim3Filter, Dim4Filter : Text;
    begin
        OnBeforeAccScheduleOverviewOnBeforePrint(AccScheduleLine, ColumnLayoutName, IsHandled);
        if IsHandled then
            exit;

        DateFilter2 := AccScheduleLine.GetFilter("Date Filter");
        GLBudgetFilter2 := AccScheduleLine.GetFilter("G/L Budget Filter");
        CostBudgetFilter2 := AccScheduleLine.GetFilter("Cost Budget Filter");
        BusUnitFilter := AccScheduleLine.GetFilter("Business Unit Filter");
        Dim1Filter := AccScheduleLine.GetFilter("Dimension 1 Filter");
        Dim2Filter := AccScheduleLine.GetFilter("Dimension 2 Filter");
        Dim3Filter := AccScheduleLine.GetFilter("Dimension 3 Filter");
        Dim4Filter := AccScheduleLine.GetFilter("Dimension 4 Filter");

        AccScheduleName.Get(AccScheduleLine."Schedule Name");
        case AccScheduleName."Acc. Schedule Type CZL" of
            AccScheduleName."Acc. Schedule Type CZL"::"Balance Sheet":
                begin
                    BalanceSheetCZL.SetAccSchedName(AccScheduleName.Name);
                    BalanceSheetCZL.SetColumnLayoutName(ColumnLayoutName);
                    BalanceSheetCZL.SetFilters(DateFilter2, GLBudgetFilter2, CostBudgetFilter2, BusUnitFilter, Dim1Filter, Dim2Filter, Dim3Filter, Dim4Filter);
                    BalanceSheetCZL.Run();
                    IsHandled := true;
                end;
            AccScheduleName."Acc. Schedule Type CZL"::"Income Statement":
                begin
                    IncomeStatementCZL.SetAccSchedName(AccScheduleName.Name);
                    IncomeStatementCZL.SetColumnLayoutName(ColumnLayoutName);
                    IncomeStatementCZL.SetFilters(DateFilter2, GLBudgetFilter2, CostBudgetFilter2, BusUnitFilter, Dim1Filter, Dim2Filter, Dim3Filter, Dim4Filter);
                    IncomeStatementCZL.Run();
                    IsHandled := true;
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::AccSchedManagement, 'OnAfterCalcCellValue', '', false, false)]
    local procedure ExtendedOnAfterCalcCellValue(var AccSchedLine: Record "Acc. Schedule Line"; var SourceAccScheduleLine: Record "Acc. Schedule Line"; var ColumnLayout: Record "Column Layout"; var Result: Decimal)
    var
        StartDate: Date;
        EndDate: Date;
    begin
        if AccSchedLine."Totaling Type" = AccSchedLine."Totaling Type"::"Custom CZL" then begin
            AccSchedLine.CopyFilters(SourceAccScheduleLine);
            StartDate := SourceAccScheduleLine.GetRangeMin("Date Filter");
            EndDate := SourceAccScheduleLine.GetRangeMax("Date Filter");
            Result := AccSChedExtensionMgtCZL.CalcCustomFunc(AccSchedLine, ColumnLayout, StartDate, EndDate);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::AccSchedManagement, 'OnBeforeDrillDownOnAccounts', '', false, false)]
    local procedure ExtendedOnBeforeDrillDownOnAccounts(var AccScheduleLine: Record "Acc. Schedule Line"; var TempColumnLayout: Record "Column Layout")
    begin
        if AccScheduleLine.Totaling = '' then
            exit;
        if AccScheduleLine."Totaling Type" = AccScheduleLine."Totaling Type"::"Custom CZL" then
            AccSChedExtensionMgtCZL.DrillDownAmount(
              AccScheduleLine,
              TempColumnLayout,
              CopyStr(AccScheduleLine.Totaling, 1, 20),
              AccScheduleLine.GetRangeMin("Date Filter"),
              AccScheduleLine.GetRangeMax("Date Filter"));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::AccSchedManagement, 'OnBeforeDrillDownOnGLAccount', '', false, false)]
    local procedure ExtendedOnBeforeDrillDownOnGLAccount(var AccScheduleLine: Record "Acc. Schedule Line"; var IsHandled: Boolean)
    begin
        if AccScheduleLine."Totaling Type" = AccScheduleLine."Totaling Type"::"Custom CZL" then
            IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::AccSchedManagement, 'OnCalcCellValueInAccSchedLinesOnBeforeShowError', '', false, false)]
    local procedure ExtendedOnCalcCellValueInAccSchedLinesOnBeforeShowError(SourceAccScheduleLine: Record "Acc. Schedule Line"; var AccScheduleLine: Record "Acc. Schedule Line"; var ColumnLayout: Record "Column Layout"; CalcAddCurr: Boolean; StartDate: Date; EndDate: Date; var CellValue: Decimal; var Result: Decimal; var IsHandled: Boolean)
    begin
        if AccSChedExtensionMgtCZL.FindSharedAccountSchedule(SourceAccScheduleLine, AccScheduleLine, ColumnLayout, CalcAddCurr, CellValue, StartDate, EndDate, Result) then
            IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::AccSchedManagement, 'OnBeforeDrillDownFromOverviewPage', '', false, false)]
    local procedure ExtendedOnBeforeDrillDownFromOverviewPage(var AccScheduleLine: Record "Acc. Schedule Line"; var TempColumnLayout: Record "Column Layout"; var IsHandled: Boolean)
    var
        SourceAccScheduleLine: Record "Acc. Schedule Line";
        AccSchedPageDrillDownCZL: Page "Acc. Sched.Page.Drill-Down CZL";
    begin
        if AccScheduleLine."Totaling Type" <> AccScheduleLine."Totaling Type"::Formula then
            exit;

        SourceAccScheduleLine.Copy(AccScheduleLine);
        AccSchedPageDrillDownCZL.InitParameters(SourceAccScheduleLine, TempColumnLayout);
        AccSchedPageDrillDownCZL.Run();
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Acc. Schedule Name", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure ResultHeaderOnBeforeDeleteEvent(var Rec: Record "Acc. Schedule Name")
    var
        AccScheduleResultHeader: Record "Acc. Schedule Result Hdr. CZL";
        ConfirmManagement: Codeunit "Confirm Management";
        DeleteQst: Label '%1 has results. Do you want to delete it anyway?', Comment = '%1 = Description';
    begin
        if Rec.IsResultsExistCZL(Rec.Name) then
            if ConfirmManagement.GetResponseOrDefault(StrSubStNo(DeleteQst, Rec.GetRecordDescriptionCZL(Rec.Name)), true) then begin
                AccScheduleResultHeader.SetRange("Acc. Schedule Name", Rec.Name);
                AccScheduleResultHeader.DeleteAll(true);
            end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Acc. Schedule Line", 'OnBeforeValidateEvent', 'Totaling Type', false, false)]
    local procedure TotalingTypeOnBeforeValidateEvent(var Rec: Record "Acc. Schedule Line"; var xRec: Record "Acc. Schedule Line")
    begin
        if (xRec."Totaling Type" = Rec."Totaling Type"::Formula) and (Rec."Totaling Type" <> Rec."Totaling Type"::Formula) then
            Rec.Totaling := '';
    end;

    [EventSubscriber(ObjectType::Table, Database::"Acc. Schedule Line", 'OnAfterValidateEvent', 'Totaling', false, false)]
    local procedure TotalingOnAfterValidateEvent(var Rec: Record "Acc. Schedule Line"; var xRec: Record "Acc. Schedule Line")
    var
        Value: Decimal;
        EvaluateErr: Label 'It''s not possible assign value:%1 of field: %2 to data type decimal!', Comment = '%1 = Totaling, %2 = FieldCaption';
    begin
        case Rec."Totaling Type" of
            Rec."Totaling Type"::"Constant CZL":
                if Rec.Totaling <> '' then
                    if not Evaluate(Value, Rec.Totaling) then
                        Error(EvaluateErr, Rec.Totaling, Rec.FieldCaption(Totaling));
        end;

        if Rec."Totaling Type" <> Rec."Totaling Type"::"Custom CZL" then
            AccSchedExtensionMgtCZL.ValidateFormula(Rec);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Categ. Generate Acc. Schedules", 'OnCreateIncomeStatementOnAfterCreateCOGSGroup', '', false, false)]
    local procedure DeleteAccSchedLinesOnCreateIncomeStatementOnAfterCreateCOGSGroup(var AccScheduleLine: Record "Acc. Schedule Line"; var IsHandled: Boolean)
    begin
        AccScheduleLine.Reset();
        AccScheduleLine.SetRange("Schedule Name", AccScheduleLine."Schedule Name");
        AccScheduleLine.DeleteAll();
        IsHandled := true;
    end;

    procedure CalcCorrectionCell(var AccScheduleLine: Record "Acc. Schedule Line"; var ColumnLayout: Record "Column Layout"; CalcAddCurr: Boolean): Decimal
    var
        LocalAccScheduleLine: Record "Acc. Schedule Line";
        AccSchedManagement: Codeunit AccSchedManagement;
    begin
        LocalAccScheduleLine.SetRange("Schedule Name", AccScheduleLine."Schedule Name");
        LocalAccScheduleLine.SetRange("Row Correction CZL", AccScheduleLine."Row No.");
        if LocalAccScheduleLine.FindFirst() then begin
            LocalAccScheduleLine.CopyFilters(AccScheduleLine);
            exit(AccSchedManagement.CalcCell(LocalAccScheduleLine, ColumnLayout, CalcAddCurr));
        end;
        exit(0);
    end;

    procedure EmptyLine(var AccScheduleLine: Record "Acc. Schedule Line"; ColumnLayoutName: Code[10]; CalcAddCurr: Boolean): Boolean
    var
        ColumnLayout: Record "Column Layout";
        AccSchedManagement: Codeunit AccSchedManagement;
        NonZero: Boolean;
    begin
        ColumnLayout.SetRange("Column Layout Name", ColumnLayoutName);
        if ColumnLayout.FindSet(false) then
            repeat
                NonZero := AccSchedManagement.CalcCell(AccScheduleLine, ColumnLayout, CalcAddCurr) <> 0;
            until (ColumnLayout.Next() = 0) or NonZero;
        exit(not NonZero);
    end;
#if not CLEAN22
    [Obsolete('The event will be replaced by OnBeforePrintAccScheduleByType.', '22.0')]
    [IntegrationEvent(false, false)]
    local procedure OnBeforeAccScheduleNameOnBeforePrint(var AccScheduleName: Record "Acc. Schedule Name"; var IsHandled: Boolean)
    begin
    end;
#endif

    [IntegrationEvent(false, false)]
    local procedure OnBeforePrintAccScheduleByType(var FinancialReport: Record "Financial Report"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeAccScheduleOverviewOnBeforePrint(var AccScheduleLine: Record "Acc. Schedule Line"; ColumnLayoutName: Code[10]; var IsHandled: Boolean)
    begin
    end;
}
