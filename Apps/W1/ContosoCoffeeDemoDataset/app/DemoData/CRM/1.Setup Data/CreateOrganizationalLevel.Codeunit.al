codeunit 5669 "Create Organizational Level"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoCRM: Codeunit "Contoso CRM";
    begin
        ContosoCRM.InsertOrganizationalLevel(CEO(), CEOLbl);
        ContosoCRM.InsertOrganizationalLevel(CFO(), CFOLbl);
        ContosoCRM.InsertOrganizationalLevel(JuniorManager(), JuniorManagerLbl);
        ContosoCRM.InsertOrganizationalLevel(Manager(), ManagerLbl);
        ContosoCRM.InsertOrganizationalLevel(SalariedEmployee(), SalariedEmployeeLbl);
        ContosoCRM.InsertOrganizationalLevel(SeniorManager(), SeniorManagerLbl);
    end;

    procedure CEO(): Code[10]
    begin
        exit(CEOTok);
    end;

    procedure CFO(): Code[10]
    begin
        exit(CFOTok);
    end;

    procedure JuniorManager(): Code[10]
    begin
        exit(JuniorManagerTok);
    end;

    procedure Manager(): Code[10]
    begin
        exit(ManagerTok);
    end;

    procedure SalariedEmployee(): Code[10]
    begin
        exit(SalariedEmployeeTok);
    end;

    procedure SeniorManager(): Code[10]
    begin
        exit(SeniorManagerTok);
    end;

    var
        CEOTok: Label 'CEO', MaxLength = 10;
        CFOTok: Label 'CFO', MaxLength = 10;
        JuniorManagerTok: Label 'J-MANA', MaxLength = 10;
        ManagerTok: Label 'MANA', MaxLength = 10;
        SalariedEmployeeTok: Label 'SALEMP', MaxLength = 10;
        SeniorManagerTok: Label 'SENMAN', MaxLength = 10;
        CEOLbl: Label 'Chief Executive Officer', MaxLength = 100;
        CFOLbl: Label 'Chief Financial Officer', MaxLength = 100;
        JuniorManagerLbl: Label 'Junior Manager', MaxLength = 100;
        ManagerLbl: Label 'Manager', MaxLength = 100;
        SalariedEmployeeLbl: Label 'Salaried Employee', MaxLength = 100;
        SeniorManagerLbl: Label 'Senior Manager', MaxLength = 100;

}