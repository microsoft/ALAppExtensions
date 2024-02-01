codeunit 5169 "Create Grounds for Termination"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoHumanResources: Codeunit "Contoso Human Resources";
    begin
        ContosoHumanResources.InsertGroundsForTermination(Dismissed(), DismissedLbl);
        ContosoHumanResources.InsertGroundsForTermination(Retired(), RetiredLbl);
        ContosoHumanResources.InsertGroundsForTermination(Resigned(), ResignedLbl);
    end;

    procedure Dismissed(): Code[10]
    begin
        exit(DismissedTok);
    end;

    procedure Retired(): Code[10]
    begin
        exit(RetiredTok);
    end;

    procedure Resigned(): Code[10]
    begin
        exit(ResignedTok);
    end;

    var
        DismissedTok: Label 'DISMISSED', MaxLength = 10;
        DismissedLbl: Label 'Employee is dismissed', MaxLength = 100;
        RetiredTok: Label 'RETIRED', MaxLength = 10;
        RetiredLbl: Label 'Employee is retired', MaxLength = 100;
        ResignedTok: Label 'RESIGNED', MaxLength = 10;
        ResignedLbl: Label 'Employee has resigned', MaxLength = 100;
}