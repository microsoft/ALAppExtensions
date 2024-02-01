codeunit 5160 "Create Employee Posting Group"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        HumanResourcesModuleSetup: Record "Human Resources Module Setup";
        ContosoHumanResources: Codeunit "Contoso Human Resources";
        HRGLAccount: Codeunit "Create HR GL Account";
    begin
        HumanResourcesModuleSetup.Get();

        if HumanResourcesModuleSetup."Employee Posting Group" = '' then begin
            ContosoHumanResources.InsertEmployeePostingGroup(EmployeeExpenses(), HRGLAccount.EmployeesPayable());

            HumanResourcesModuleSetup.Validate("Employee Posting Group", EmployeeExpenses());

            HumanResourcesModuleSetup.Modify(true);
        end;

    end;

    procedure EmployeeExpenses(): Code[20]
    begin
        exit(EmployeeExpensesTok);
    end;

    var
        EmployeeExpensesTok: Label 'EMPLEXP', MaxLength = 20;
}