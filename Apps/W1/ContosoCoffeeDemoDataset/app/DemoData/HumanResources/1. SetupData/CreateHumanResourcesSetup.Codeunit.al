codeunit 5121 "Create Human Resources Setup"
{
    InherentPermissions = X;
    InherentEntitlements = X;
    Permissions = tabledata "Human Resources Setup" = rm;

    trigger OnRun()
    var
        HumanResourceSetup: Record "Human Resources Setup";
        HumanResourceUoM: Codeunit "Create Human Resources UoM";
        EmployeeNoSeries: Codeunit "Create Employee No Series";
    begin
        HumanResourceSetup.Get();

        HumanResourceSetup.Validate("Base Unit of Measure", HumanResourceUoM.Day());
        HumanResourceSetup.Validate("Employee Nos.", EmployeeNoSeries.Employee());

        HumanResourceSetup.Modify(true);
    end;
}