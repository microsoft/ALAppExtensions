codeunit 11700 "Acc. Schedule Management CZL"
{
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
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Acc. Schedule Name", 'OnBeforePrint', '', false, false)]
    local procedure AccScheduleNameOnBeforePrint(var AccScheduleName: Record "Acc. Schedule Name"; var IsHandled: Boolean)
    var
        AccountSchedule: Report "Account Schedule";
        BalanceSheetCZL: Report "Balance Sheet CZL";
        IncomeStatementCZL: Report "Income Statement CZL";
    begin
        case AccScheduleName."Acc. Schedule Type CZL" of
            AccScheduleName."Acc. Schedule Type CZL"::Standard:
                begin
                    AccountSchedule.SetAccSchedName(AccScheduleName.Name);
                    AccountSchedule.SetColumnLayoutName(AccScheduleName."Default Column Layout");
                    AccountSchedule.Run();
                end;
            AccScheduleName."Acc. Schedule Type CZL"::"Balance Sheet":
                begin
                    BalanceSheetCZL.SetAccSchedName(AccScheduleName.Name);
                    BalanceSheetCZL.SetColumnLayoutName(AccScheduleName."Default Column Layout");
                    BalanceSheetCZL.Run();
                end;
            AccScheduleName."Acc. Schedule Type CZL"::"Income Statement":
                begin
                    IncomeStatementCZL.SetAccSchedName(AccScheduleName.Name);
                    IncomeStatementCZL.SetColumnLayoutName(AccScheduleName."Default Column Layout");
                    IncomeStatementCZL.Run();
                end;
        end;
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Acc. Schedule Overview", 'OnBeforePrint', '', false, false)]
    local procedure AccScheduleOverviewOnBeforePrint(var AccScheduleLine: Record "Acc. Schedule Line"; ColumnLayoutName: Code[10]; var IsHandled: Boolean)
    var
        AccScheduleName: Record "Acc. Schedule Name";
        AccountSchedule: Report "Account Schedule";
        BalanceSheetCZL: Report "Balance Sheet CZL";
        IncomeStatementCZL: Report "Income Statement CZL";
        DateFilter2, GLBudgetFilter2, BusUnitFilter, CostBudgetFilter2, Dim1Filter, Dim2Filter, Dim3Filter, Dim4Filter : Text;
    begin
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
            AccScheduleName."Acc. Schedule Type CZL"::Standard:
                begin
                    AccountSchedule.SetAccSchedName(AccScheduleName.Name);
                    AccountSchedule.SetColumnLayoutName(ColumnLayoutName);
                    AccountSchedule.SetFilters(DateFilter2, GLBudgetFilter2, CostBudgetFilter2, BusUnitFilter, Dim1Filter, Dim2Filter, Dim3Filter, Dim4Filter);
                    AccountSchedule.Run();
                end;
            AccScheduleName."Acc. Schedule Type CZL"::"Balance Sheet":
                begin
                    BalanceSheetCZL.SetAccSchedName(AccScheduleName.Name);
                    BalanceSheetCZL.SetColumnLayoutName(ColumnLayoutName);
                    BalanceSheetCZL.SetFilters(DateFilter2, GLBudgetFilter2, CostBudgetFilter2, BusUnitFilter, Dim1Filter, Dim2Filter, Dim3Filter, Dim4Filter);
                    BalanceSheetCZL.Run();
                end;
            AccScheduleName."Acc. Schedule Type CZL"::"Income Statement":
                begin
                    IncomeStatementCZL.SetAccSchedName(AccScheduleName.Name);
                    IncomeStatementCZL.SetColumnLayoutName(ColumnLayoutName);
                    IncomeStatementCZL.SetFilters(DateFilter2, GLBudgetFilter2, CostBudgetFilter2, BusUnitFilter, Dim1Filter, Dim2Filter, Dim3Filter, Dim4Filter);
                    IncomeStatementCZL.Run();
                end;
        end;
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
        if ColumnLayout.FindSet(false, false) then
            repeat
                NonZero := AccSchedManagement.CalcCell(AccScheduleLine, ColumnLayout, CalcAddCurr) <> 0;
            until (ColumnLayout.Next() = 0) or NonZero;
        exit(not NonZero);
    end;
}
