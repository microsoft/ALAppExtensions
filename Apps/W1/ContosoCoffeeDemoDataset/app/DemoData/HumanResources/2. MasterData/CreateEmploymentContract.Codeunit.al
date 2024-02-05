codeunit 5175 "Create Employment Contract"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoHumanResources: Codeunit "Contoso Human Resources";
    begin
        ContosoHumanResources.InsertEmploymentContract(Administrators(), AdministratorLbl);
        ContosoHumanResources.InsertEmploymentContract(Developers(), DeveloperLbl);
        ContosoHumanResources.InsertEmploymentContract(ProductionStaff(), ProductionLbl);
    end;

    procedure Administrators(): Code[10]
    begin
        exit(AdministratorTok);
    end;

    procedure Developers(): Code[10]
    begin
        exit(DeveloperTok);
    end;

    procedure ProductionStaff(): Code[10]
    begin
        exit(ProductionTok);
    end;

    var
        AdministratorTok: Label 'ADM', MaxLength = 10;
        AdministratorLbl: Label 'Administrators', MaxLength = 100;
        DeveloperTok: Label 'DEV', MaxLength = 10;
        DeveloperLbl: Label 'Developers', MaxLength = 100;
        ProductionTok: Label 'PROD', MaxLength = 10;
        ProductionLbl: Label 'Production Staff', MaxLength = 100;
}