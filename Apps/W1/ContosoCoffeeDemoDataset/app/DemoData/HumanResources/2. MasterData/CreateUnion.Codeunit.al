codeunit 5174 "Create Union"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoHumanResources: Codeunit "Contoso Human Resources";
    begin
        ContosoHumanResources.InsertUnion(AdministratorUnion(), AdministratorUnionLbl);
        ContosoHumanResources.InsertUnion(DevelopmentEngineerUnion(), DevelopmentEngineerUnionLbl);
        ContosoHumanResources.InsertUnion(ProductionWorkerUnion(), ProductionWorkerUnionLbl);
    end;

    procedure AdministratorUnion(): Code[10]
    begin
        exit(AdministratorUnionTok);
    end;

    procedure DevelopmentEngineerUnion(): Code[10]
    begin
        exit(DevelopmentEngineerUnionTok);
    end;

    procedure ProductionWorkerUnion(): Code[10]
    begin
        exit(ProductionWorkerUnionTok);
    end;

    var
        AdministratorUnionTok: Label 'UADMI', MaxLength = 10;
        AdministratorUnionLbl: Label 'Administrators'' Union', MaxLength = 100;
        DevelopmentEngineerUnionTok: Label 'UDEVE', MaxLength = 10;
        DevelopmentEngineerUnionLbl: Label 'Development Engineers'' Union', MaxLength = 100;
        ProductionWorkerUnionTok: Label 'UPROD', MaxLength = 10;
        ProductionWorkerUnionLbl: Label 'Production Workers'' Union', MaxLength = 100;
}