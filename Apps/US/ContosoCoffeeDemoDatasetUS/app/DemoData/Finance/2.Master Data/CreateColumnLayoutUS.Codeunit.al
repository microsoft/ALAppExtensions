codeunit 11479 "Create Column Layout US"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        CreateColumnLayoutName: Codeunit "Create Column Layout Name";
        ContosoAccountScheduleUS: Codeunit "Contoso Account Schedule US";
        CreateColumnLayoutNameUS: Codeunit "Create Column Layout Name US";
        ColumnLayoutName: Code[10];
    begin
        ColumnLayoutName := CreateColumnLayoutName.BudgetAnalysis();
        ContosoAccountScheduleUS.InsertColumnLayout(ColumnLayoutName, 40000, '', NetChangeLastYearLbl, Enum::"Column Layout Type"::"Net Change", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, '', false, '-1Y', Enum::"Analysis Rounding Factor"::None);

        ColumnLayoutName := CreateColumnLayoutNameUS.PeriodandYeartoDate();
        ContosoAccountScheduleUS.InsertColumnLayout(ColumnLayoutName, 10000, '', CurrentPeriodLbl, Enum::"Column Layout Type"::"Net Change", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, '', false, '', Enum::"Analysis Rounding Factor"::None);
        ContosoAccountScheduleUS.InsertColumnLayout(ColumnLayoutName, 20000, '', YeartoDateLbl, Enum::"Column Layout Type"::"Year to Date", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, '', false, '', Enum::"Analysis Rounding Factor"::None);

        ColumnLayoutName := CreateColumnLayoutNameUS.PeriodandYeartoDatewithPercentofTotalRevenue();
        ContosoAccountScheduleUS.InsertColumnLayout(ColumnLayoutName, 10000, 'PTD', CurrentPeriodLbl, Enum::"Column Layout Type"::Formula, Enum::"Column Layout Entry Type"::"Budget Entries", '', false, Enum::"Column Layout Show"::Always, '', false, '', Enum::"Analysis Rounding Factor"::None);
        ContosoAccountScheduleUS.InsertColumnLayout(ColumnLayoutName, 20000, '', '', Enum::"Column Layout Type"::Formula, Enum::"Column Layout Entry Type"::Entries, 'PTD%', true, Enum::"Column Layout Show"::Always, '', false, '', Enum::"Analysis Rounding Factor"::"1");
        ContosoAccountScheduleUS.InsertColumnLayout(ColumnLayoutName, 30000, 'YTD', YeartoDateLbl, Enum::"Column Layout Type"::"Year to Date", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, '', false, '', Enum::"Analysis Rounding Factor"::None);
        ContosoAccountScheduleUS.InsertColumnLayout(ColumnLayoutName, 40000, '', '', Enum::"Column Layout Type"::Formula, Enum::"Column Layout Entry Type"::Entries, 'YTD%', true, Enum::"Column Layout Show"::Always, '', false, '', Enum::"Analysis Rounding Factor"::"1");

        ColumnLayoutName := CreateColumnLayoutNameUS.ThisYeartoDatevsPriorYeartoDate();
        ContosoAccountScheduleUS.InsertColumnLayout(ColumnLayoutName, 10000, 'CUR', CurrentYeartoDateLbl, Enum::"Column Layout Type"::"Year to Date", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, '', false, '', Enum::"Analysis Rounding Factor"::"1");
        ContosoAccountScheduleUS.InsertColumnLayout(ColumnLayoutName, 20000, '', '', Enum::"Column Layout Type"::Formula, Enum::"Column Layout Entry Type"::Entries, 'CUR%', true, Enum::"Column Layout Show"::Always, '', false, '', Enum::"Analysis Rounding Factor"::"1");
        ContosoAccountScheduleUS.InsertColumnLayout(ColumnLayoutName, 30000, 'PRIOR', PriorYeartoDateLbl, Enum::"Column Layout Type"::"Year to Date", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, '', false, '-1Y', Enum::"Analysis Rounding Factor"::"1");
        ContosoAccountScheduleUS.InsertColumnLayout(ColumnLayoutName, 40000, '', '', Enum::"Column Layout Type"::Formula, Enum::"Column Layout Entry Type"::Entries, 'PRIOR%', true, Enum::"Column Layout Show"::Always, '', false, '', Enum::"Analysis Rounding Factor"::"1");
        ContosoAccountScheduleUS.InsertColumnLayout(ColumnLayoutName, 50000, 'DIFF', DifferenceLbl, Enum::"Column Layout Type"::Formula, Enum::"Column Layout Entry Type"::Entries, 'CUR-PRIOR', false, Enum::"Column Layout Show"::Always, '', false, '', Enum::"Analysis Rounding Factor"::"1");
    end;

    var
        NetChangeLastYearLbl: Label 'Net Change Last Year', MaxLength = 30;
        CurrentPeriodLbl: Label 'Current Period', MaxLength = 30;
        YeartoDateLbl: Label 'Year to Date', MaxLength = 30;
        CurrentYeartoDateLbl: Label 'Current Year to Date', MaxLength = 30;
        PriorYeartoDateLbl: Label 'Prior Year to Date', MaxLength = 30;
        DifferenceLbl: Label 'Difference', MaxLength = 30;
}