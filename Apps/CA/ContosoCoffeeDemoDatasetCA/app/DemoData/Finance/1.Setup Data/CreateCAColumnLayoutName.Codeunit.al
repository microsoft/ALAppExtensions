codeunit 27017 "Create CA Column Layout Name"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoAccountSchedule: Codeunit "Contoso Account Schedule";
    begin
        ContosoAccountSchedule.InsertColumnLayoutName(PeriodandYeartoDate(), PeriodandYeartoDateLbl);
        ContosoAccountSchedule.InsertColumnLayoutName(PeriodandYeartoDatewithPercentofTotalRevenue(), PeriodandYeartoDatewithPercentofTotalRevenueLbl);
        ContosoAccountSchedule.InsertColumnLayoutName(ThisYeartoDatevsPriorYeartoDate(), ThisYeartoDatevsPriorYeartoDateLbl);
    end;

    procedure PeriodandYeartoDate(): Code[10]
    begin
        exit(PeriodandYeartoDateTok);
    end;

    procedure PeriodandYeartoDatewithPercentofTotalRevenue(): Code[10]
    begin
        exit(PeriodandYeartoDatewithPercentofTotalRevenueTok);
    end;

    procedure ThisYeartoDatevsPriorYeartoDate(): Code[10]
    begin
        exit(ThisYeartoDatevsPriorYeartoDateTok);
    end;

    var
        PeriodandYeartoDateTok: Label 'PTD + YTD', MaxLength = 10;
        PeriodandYeartoDatewithPercentofTotalRevenueTok: Label 'PTD+YTD+%', MaxLength = 10;
        ThisYeartoDatevsPriorYeartoDateTok: Label 'YTDCOMPARE', MaxLength = 10;
        PeriodandYeartoDateLbl: Label 'Period and Year to Date', MaxLength = 80;
        PeriodandYeartoDatewithPercentofTotalRevenueLbl: Label 'Period and Year to Date with Percent of Total Revenue', MaxLength = 80;
        ThisYeartoDatevsPriorYeartoDateLbl: Label 'This Year to Date vs. Prior Year to Date', MaxLength = 80;
}