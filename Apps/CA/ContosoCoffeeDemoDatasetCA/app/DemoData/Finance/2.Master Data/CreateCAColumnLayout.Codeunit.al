codeunit 27042 "Create CA Column Layout"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        CreateCAColumnLayoutName: Codeunit "Create CA Column Layout Name";
        ContosoAccountSchedule: Codeunit "Contoso Account Schedule";
    begin
        ContosoAccountSchedule.InsertColumnLayout(CreateCAColumnLayoutName.PeriodandYeartoDate(), 10000, '', CurrentPeriodLbl, Enum::"Column Layout Type"::"Net Change", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, '', false);
        ContosoAccountSchedule.InsertColumnLayout(CreateCAColumnLayoutName.PeriodandYeartoDate(), 20000, '', YeartoDateLbl, Enum::"Column Layout Type"::"Year to Date", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, '', false);

        ContosoAccountSchedule.InsertColumnLayout(CreateCAColumnLayoutName.PeriodandYeartoDatewithPercentofTotalRevenue(), 10000, 'PTD', CurrentPeriodLbl, Enum::"Column Layout Type"::"Formula", Enum::"Column Layout Entry Type"::"Budget Entries", '', false, Enum::"Column Layout Show"::Always, '', false);
        ContosoAccountSchedule.InsertColumnLayout(CreateCAColumnLayoutName.PeriodandYeartoDatewithPercentofTotalRevenue(), 20000, '', '', Enum::"Column Layout Type"::"Formula", Enum::"Column Layout Entry Type"::Entries, 'PTD%', true, Enum::"Column Layout Show"::Always, '', false);
        ContosoAccountSchedule.InsertColumnLayout(CreateCAColumnLayoutName.PeriodandYeartoDatewithPercentofTotalRevenue(), 30000, 'YTD', YeartoDateLbl, Enum::"Column Layout Type"::"Year to Date", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, '', false);
        ContosoAccountSchedule.InsertColumnLayout(CreateCAColumnLayoutName.PeriodandYeartoDatewithPercentofTotalRevenue(), 40000, '', '', Enum::"Column Layout Type"::"Formula", Enum::"Column Layout Entry Type"::Entries, 'YTD%', true, Enum::"Column Layout Show"::Always, '', false);

        ContosoAccountSchedule.InsertColumnLayout(CreateCAColumnLayoutName.ThisYeartoDatevsPriorYeartoDate(), 10000, 'CUR', CurrentYeartoDateLbl, Enum::"Column Layout Type"::"Year to Date", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, '', false);
        ContosoAccountSchedule.InsertColumnLayout(CreateCAColumnLayoutName.ThisYeartoDatevsPriorYeartoDate(), 20000, '', '', Enum::"Column Layout Type"::"Formula", Enum::"Column Layout Entry Type"::Entries, 'CUR%', true, Enum::"Column Layout Show"::Always, '', false);
        ContosoAccountSchedule.InsertColumnLayout(CreateCAColumnLayoutName.ThisYeartoDatevsPriorYeartoDate(), 30000, 'PRIOR', PriorYeartoDateLbl, Enum::"Column Layout Type"::"Year to Date", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, '', false);
        ContosoAccountSchedule.InsertColumnLayout(CreateCAColumnLayoutName.ThisYeartoDatevsPriorYeartoDate(), 40000, '', '', Enum::"Column Layout Type"::"Formula", Enum::"Column Layout Entry Type"::Entries, 'PRIOR%', true, Enum::"Column Layout Show"::Always, '', false);
        ContosoAccountSchedule.InsertColumnLayout(CreateCAColumnLayoutName.ThisYeartoDatevsPriorYeartoDate(), 50000, 'DIFF', DifferenceLbl, Enum::"Column Layout Type"::"Formula", Enum::"Column Layout Entry Type"::Entries, 'CUR-PRIOR', false, Enum::"Column Layout Show"::Always, '', false);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Column Layout", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnInsertRecord(var Rec: Record "Column Layout")
    var
        CreateCAColumnLayoutName: Codeunit "Create CA Column Layout Name";
    begin
        if Rec."Column Layout Name" = CreateCAColumnLayoutName.PeriodandYeartoDatewithPercentofTotalRevenue() then
            case
                Rec."Line No." of
                20000:
                    ValidateRecordFields(Rec, '', '', Enum::"Analysis Rounding Factor"::"1", 0, Enum::"Account Schedule Amount Type"::"Net Amount");
                40000:
                    ValidateRecordFields(Rec, '', '', Enum::"Analysis Rounding Factor"::"1", 0, Enum::"Account Schedule Amount Type"::"Net Amount");
            end;

        if Rec."Column Layout Name" = CreateCAColumnLayoutName.ThisYeartoDatevsPriorYeartoDate() then
            case
                Rec."Line No." of
                10000:
                    ValidateRecordFields(Rec, CurrentYeartoDateLbl, '', Enum::"Analysis Rounding Factor"::"1", 0, Enum::"Account Schedule Amount Type"::"Net Amount");
                20000:
                    ValidateRecordFields(Rec, '', '', Enum::"Analysis Rounding Factor"::"1", 0, Enum::"Account Schedule Amount Type"::"Net Amount");
                30000:
                    ValidateRecordFields(Rec, PriorYeartoDateLbl, '<-1Y>', Enum::"Analysis Rounding Factor"::"1", 0, Enum::"Account Schedule Amount Type"::"Net Amount");
                40000:
                    ValidateRecordFields(Rec, '', '', Enum::"Analysis Rounding Factor"::"1", 0, Enum::"Account Schedule Amount Type"::"Net Amount");
                50000:
                    ValidateRecordFields(Rec, DifferenceLbl, '', Enum::"Analysis Rounding Factor"::"1", 0, Enum::"Account Schedule Amount Type"::"Net Amount");
            end;
    end;

    local procedure ValidateRecordFields(var ColumnLayout: Record "Column Layout"; ColumnHeader: Text[30]; ComparisonDateFormula: Text[10]; RoundingFactor: Enum "Analysis Rounding Factor"; ComparisonPeriodFormulaLCID: Integer; AmountType: Enum "Account Schedule Amount Type")
    begin
        ColumnLayout.Validate("Column Header", ColumnHeader);
        Evaluate(ColumnLayout."Comparison Date Formula", ComparisonDateFormula);
        ColumnLayout.Validate("Comparison Date Formula");
        ColumnLayout.Validate("Amount Type", AmountType);
        ColumnLayout.Validate("Rounding Factor", RoundingFactor);
        ColumnLayout.Validate("Comparison Period Formula LCID", ComparisonPeriodFormulaLCID);
    end;

    var
        DifferenceLbl: Label 'Difference', MaxLength = 30;
        CurrentPeriodLbl: Label 'Current Period', MaxLength = 30;
        YeartoDateLbl: Label 'Year to Date', MaxLength = 30;
        CurrentYeartoDateLbl: Label 'Current Year to Date', MaxLength = 30;
        PriorYeartoDateLbl: Label 'Prior Year to Date', MaxLength = 30;
}