codeunit 5158 "Create Causes of Absence"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoHumanResources: Codeunit "Contoso Human Resources";
        HumanResourceUoM: Codeunit "Create Human Resources UoM";
    begin
        ContosoHumanResources.InsertCauseOfAbsence(Sick(), SickLbl, HumanResourceUoM.Hour());
        ContosoHumanResources.InsertCauseOfAbsence(DayOff(), DayOffLbl, HumanResourceUoM.Hour());
        ContosoHumanResources.InsertCauseOfAbsence(Holiday(), HolidayLbl, HumanResourceUoM.Day());
    end;

    procedure Sick(): Text[10]
    begin
        exit(SickTok);
    end;

    procedure DayOff(): Text[10]
    begin
        exit(DayOffTok);
    end;

    procedure Holiday(): Text[10]
    begin
        exit(HolidayTok);
    end;

    var
        SickTok: Label 'SICK', MaxLength = 10;
        SickLbl: Label 'Sick', MaxLength = 100;
        DayOffTok: Label 'DAYOFF', MaxLength = 10;
        DayOffLbl: Label 'Day Off', MaxLength = 100;
        HolidayTok: Label 'HOLIDAY', MaxLength = 10;
        HolidayLbl: Label 'Holiday', MaxLength = 100;
}