codeunit 11130 "Create DE Employee"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        CreateEmployee: Codeunit "Create Employee";
    begin
        UpdateEmployee(CreateEmployee.ManagingDirector());
        UpdateEmployee(CreateEmployee.SalesManager());
        UpdateEmployee(CreateEmployee.Designer());
        UpdateEmployee(CreateEmployee.ProductionAssistant());
        UpdateEmployee(CreateEmployee.ProductionManager());
        UpdateEmployee(CreateEmployee.Secretary());
        UpdateEmployee(CreateEmployee.InventoryManager());
    end;

    local procedure UpdateEmployee(EmployeeNo: Code[20])
    var
        Employee: Record Employee;
        CreateEmployee: Codeunit "Create Employee";
    begin
        Employee.Get(EmployeeNo);
        Employee.Validate("E-Mail", StrSubstNo(EmpEmailLbl, LowerCase(Employee."No.")));
        Employee.Validate("Social Security No.", '');
        Employee.Validate("Emplymt. Contract Code", '');
        Employee.Validate("Statistics Group Code", '');
        Employee.Validate("Union Code", '');
        Employee.Validate(Initials, GetInitials(Employee));
        if EmployeeNo = CreateEmployee.InventoryManager() then
            Employee.Validate("Job Title", ProductionAssistantLbl);
        Employee.Modify(true);
    end;

    local procedure GetInitials(Employee: Record Employee): Text
    begin
        exit(UpperCase(CopyStr(Employee."First Name", 1, 1) + Employee."Last Name"));
    end;

    var
        ProductionAssistantLbl: Label 'Production Assistant', MaxLength = 30;
#pragma warning disable AA0240
        EmpEmailLbl: Label '%1@cronus-demosite.com', Locked = true;
#pragma warning restore AA0240
}