codeunit 4761 "Create Mfg Cap Unit of Measure"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoUnitOfMeasure: Codeunit "Contoso Unit of Measure";
    begin
        ContosoUnitOfMeasure.InsertCapacityUnitOfMeasure(Minutes(), MinutesLowerCaseTok, Enum::"Capacity Unit of Measure"::Minutes);
        ContosoUnitOfMeasure.InsertCapacityUnitOfMeasure(Hours(), HoursLowerCaseTok, Enum::"Capacity Unit of Measure"::Hours);
        ContosoUnitOfMeasure.InsertCapacityUnitOfMeasure(Days(), DaysLowerCaseTok, Enum::"Capacity Unit of Measure"::Days);
    end;

    var
        MINUTESTok: Label 'MINUTES', MaxLength = 10;
        MinutesLowerCaseTok: Label 'Minutes', MaxLength = 50;
        HOURSTok: Label 'HOURS', MaxLength = 10;
        HoursLowerCaseTok: Label 'Hours', MaxLength = 50;
        DAYSTok: Label 'DAYS', MaxLength = 10;
        DaysLowerCaseTok: Label 'Days', MaxLength = 50;

    procedure Minutes(): Code[10]
    begin
        exit(MINUTESTok);
    end;

    procedure Hours(): Code[10]
    begin
        exit(HOURSTok);
    end;

    procedure Days(): Code[10]
    begin
        exit(DAYSTok);
    end;
}