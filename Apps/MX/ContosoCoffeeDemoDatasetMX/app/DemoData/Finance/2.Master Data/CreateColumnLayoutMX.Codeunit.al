codeunit 14115 "Create Column Layout MX"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        CreateColumnLayoutName: Codeunit "Create Column Layout Name";
        ContosoAccountSchedule: Codeunit "Contoso Account Schedule";
        CreateColumnLayoutNameMX: Codeunit "Create Column Layout Name MX";
        ColumnLayoutName: Code[10];
    begin
        ColumnLayoutName := CreateColumnLayoutName.BudgetAnalysis();
        ContosoAccountSchedule.InsertColumnLayout(ColumnLayoutName, 40000, '', NetChangeLastYearLbl, Enum::"Column Layout Type"::"Net Change", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, '', false);

        ColumnLayoutName := CreateColumnLayoutNameMX.PeriodandYeartoDate();
        ContosoAccountSchedule.InsertColumnLayout(ColumnLayoutName, 10000, '', CurrentPeriodLbl, Enum::"Column Layout Type"::"Net Change", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, '', false);
        ContosoAccountSchedule.InsertColumnLayout(ColumnLayoutName, 20000, '', YearToDateLbl, Enum::"Column Layout Type"::"Year to Date", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, '', false);

        ColumnLayoutName := CreateColumnLayoutNameMX.PeriodandYeartoDatewithPercentofTotalRevenue();
        ContosoAccountSchedule.InsertColumnLayout(ColumnLayoutName, 10000, PtdLbl, CurrentPeriodLbl, Enum::"Column Layout Type"::Formula, Enum::"Column Layout Entry Type"::"Budget Entries", '', false, Enum::"Column Layout Show"::Always, '', false);
        ContosoAccountSchedule.InsertColumnLayout(ColumnLayoutName, 20000, '', '', Enum::"Column Layout Type"::Formula, Enum::"Column Layout Entry Type"::Entries, PtdPercentageLbl, true, Enum::"Column Layout Show"::Always, '', false);
        ContosoAccountSchedule.InsertColumnLayout(ColumnLayoutName, 30000, YtdLbl, YearToDateLbl, Enum::"Column Layout Type"::"Year to Date", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, '', false);
        ContosoAccountSchedule.InsertColumnLayout(ColumnLayoutName, 40000, '', '', Enum::"Column Layout Type"::Formula, Enum::"Column Layout Entry Type"::Entries, YtdPercentageLbl, true, Enum::"Column Layout Show"::Always, '', false);

        ColumnLayoutName := CreateColumnLayoutNameMX.ThisYeartoDatevsPriorYeartoDate();
        ContosoAccountSchedule.InsertColumnLayout(ColumnLayoutName, 10000, CurLbl, CurrentYearToDateLbl, Enum::"Column Layout Type"::"Year to Date", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, '', false);
        ContosoAccountSchedule.InsertColumnLayout(ColumnLayoutName, 20000, '', '', Enum::"Column Layout Type"::Formula, Enum::"Column Layout Entry Type"::Entries, CurPercentageLbl, true, Enum::"Column Layout Show"::Always, '', false);
        ContosoAccountSchedule.InsertColumnLayout(ColumnLayoutName, 30000, PriorLbl, PriorYearToDateLbl, Enum::"Column Layout Type"::"Year to Date", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, '', false);
        ContosoAccountSchedule.InsertColumnLayout(ColumnLayoutName, 40000, '', '', Enum::"Column Layout Type"::Formula, Enum::"Column Layout Entry Type"::Entries, PriorPercentageLbl, true, Enum::"Column Layout Show"::Always, '', false);
        ContosoAccountSchedule.InsertColumnLayout(ColumnLayoutName, 50000, DiffLbl, DifferenceLbl, Enum::"Column Layout Type"::Formula, Enum::"Column Layout Entry Type"::Entries, CurPriorLbl, false, Enum::"Column Layout Show"::Always, '', false);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Column Layout", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnInsertRecord(var Rec: Record "Column Layout")
    var
        CreateColumnLayoutName: Codeunit "Create Column Layout Name";
        CreateColumnLayoutNameMX: Codeunit "Create Column Layout Name MX";
    begin
        case Rec."Column Layout Name" of
            CreateColumnLayoutName.BudgetAnalysis():
                begin
                    if Rec."Line No." = 30000 then
                        Rec.Validate("Column Header", DeviationFromBudgetPercantageLbl);
                    if Rec."Line No." = 40000 then
                        ValidateRecordFields(Rec, '<-1Y>');
                end;
            CreateColumnLayoutNameMX.PeriodandYeartoDatewithPercentofTotalRevenue():
                begin
                    if Rec."Line No." = 20000 then
                        Rec.Validate("Rounding Factor", Enum::"Analysis Rounding Factor"::"1");
                    if Rec."Line No." = 40000 then
                        Rec.Validate("Rounding Factor", Enum::"Analysis Rounding Factor"::"1");
                end;
            CreateColumnLayoutNameMX.ThisYeartoDatevsPriorYeartoDate():
                begin
                    Rec.Validate("Rounding Factor", Enum::"Analysis Rounding Factor"::"1");
                    if Rec."Line No." = 30000 then
                        ValidateRecordFields(Rec, '<-1Y>');
                end;
        end;
    end;

    local procedure ValidateRecordFields(var ColumnLayout: Record "Column Layout"; ComparisonDateFormula: Text[10])
    begin
        Evaluate(ColumnLayout."Comparison Date Formula", ComparisonDateFormula);
        ColumnLayout.Validate("Comparison Date Formula");
    end;

    var
        DeviationFromBudgetPercantageLbl: Label 'Deviation from Budget %', MaxLength = 30;
        NetChangeLastYearLbl: Label 'Net Change Last Year', MaxLength = 30;
        CurrentPeriodLbl: Label 'Current Period', MaxLength = 30;
        YearToDateLbl: Label 'Year to Date', MaxLength = 30;
        CurrentYearToDateLbl: Label 'Current Year to Date', MaxLength = 30;
        PriorYearToDateLbl: Label 'Prior Year to Date', MaxLength = 30;
        DifferenceLbl: Label 'Difference', MaxLength = 30;
        DiffLbl: Label 'DIFF', MaxLength = 10;
        PriorLbl: Label 'PRIOR', MaxLength = 10;
        CurLbl: Label 'CUR', MaxLength = 10;
        YtdLbl: Label 'YTD', MaxLength = 10;
        PtdLbl: Label 'PTD', MaxLength = 10;
        PtdPercentageLbl: Label 'PTD%', MaxLength = 10;
        YtdPercentageLbl: Label 'YTD%', MaxLength = 10;
        CurPercentageLbl: Label 'CUR%', MaxLength = 10;
        PriorPercentageLbl: Label 'PRIOR%', MaxLength = 10;
        CurPriorLbl: Label 'CUR-PRIOR', MaxLength = 10;
}