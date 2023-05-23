codeunit 4761 "Create Mfg Cap Unit of Measure"
{
    Permissions = tabledata "Capacity Unit of Measure" = ri;

    trigger OnRun()
    begin
        InsertData(XMINUTESTok, XMinutesLowerCaseTok, Enum::"Capacity Unit of Measure"::Minutes);
        InsertData(XHOURSTok, XHoursLowerCaseTok, Enum::"Capacity Unit of Measure"::Hours);
        InsertData(XDAYSTok, XDaysLowerCaseTok, Enum::"Capacity Unit of Measure"::Days);
    end;

    var
        XMINUTESTok: Label 'MINUTES', MaxLength = 10;
        XMinutesLowerCaseTok: Label 'Minutes', MaxLength = 10;
        XHOURSTok: Label 'HOURS', MaxLength = 10;
        XHoursLowerCaseTok: Label 'Hours', MaxLength = 10;
        XDAYSTok: Label 'DAYS', MaxLength = 10;
        XDaysLowerCaseTok: Label 'Days', MaxLength = 10;

    local procedure InsertData("Code": Text[10]; Description: Text[50]; Type: Enum "Capacity Unit of Measure")
    var
        CapacityUnitOfMeasure: Record "Capacity Unit of Measure";
    begin
        CapacityUnitOfMeasure.Validate(Code, Code);
        CapacityUnitOfMeasure.Validate(Description, Description);
        CapacityUnitOfMeasure.Validate(Type, Type);
        CapacityUnitOfMeasure.Insert();
    end;
}