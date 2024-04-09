codeunit 5162 "Create Human Resources UoM"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoHumanResources: Codeunit "Contoso Human Resources";
    begin
        ContosoHumanResources.InsertHumanResourcesUom(Hour(), 1 / 8);
        ContosoHumanResources.InsertHumanResourcesUom(Day(), 1);
    end;

    // re-using the Label from Common Unit Of Measure, so we don't need to maintain them in two places
    // still need to create the separate procedures, so it is intuitive to use
    procedure Hour(): Code[10]
    begin
        exit(CommonUoM.Hour());
    end;

    procedure Day(): Code[10]
    begin
        exit(CommonUoM.Day());
    end;

    var
        CommonUoM: Codeunit "Create Common Unit Of Measure";
}