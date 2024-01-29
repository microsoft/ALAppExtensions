codeunit 5119 "Create Employee Stat. Group"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoHumanResources: Codeunit "Contoso Human Resources";
    begin
        ContosoHumanResources.InsertEmployeeStatisticsGroup(Monthly(), SalariedMonthlyLbl);
        ContosoHumanResources.InsertEmployeeStatisticsGroup(Days14(), SalariedTwiceMonthlyLbl);
        ContosoHumanResources.InsertEmployeeStatisticsGroup(Hourly(), HourlyWagesLbl);
    end;

    procedure Monthly(): Text[10]
    begin
        exit(SalariedMonthlyTok)
    end;

    procedure Days14(): Text[10]
    begin
        exit(Days14Tok)
    end;

    procedure Hourly(): Text[10]
    begin
        exit(HourlyTok)
    end;

    var
        SalariedMonthlyTok: Label 'MONTH', MaxLength = 10;
        SalariedMonthlyLbl: Label 'Salaried (Monthly)', MaxLength = 100;
        Days14Tok: Label '14DAYS', MaxLength = 10;
        SalariedTwiceMonthlyLbl: Label 'Salaried (Twice Monthly)', MaxLength = 100;
        HourlyTok: Label 'HOUR', MaxLength = 10;
        HourlyWagesLbl: Label 'Hourly Wages', MaxLength = 100;
}