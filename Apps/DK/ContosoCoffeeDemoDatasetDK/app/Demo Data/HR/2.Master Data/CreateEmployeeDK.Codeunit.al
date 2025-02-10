codeunit 13720 "Create Employee DK"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
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
    begin
        Employee.Get(EmployeeNo);
        Employee.Validate("E-Mail", StrSubstNo(EmpEmailLbl, LowerCase(Employee."No.")));
        Employee.Validate("Social Security No.", '');
        Employee.Validate(Initials, GetInitials(Employee));
        Employee.Modify(true)
    end;

    [EventSubscriber(ObjectType::Table, Database::Employee, 'OnBeforeOnInsert', '', false, false)]
    local procedure OnBeforeInsertEmployee(var Employee: Record Employee)
    var
        CreateEmployee: Codeunit "Create Employee";
    begin
        case Employee."No." of
            CreateEmployee.ManagingDirector():
                ValidateEmployee(Employee, '', '', '');
            CreateEmployee.SalesManager():
                ValidateEmployee(Employee, '', '', '');
            CreateEmployee.Designer():
                ValidateEmployee(Employee, '', '', '');
            CreateEmployee.ProductionAssistant():
                ValidateEmployee(Employee, '', '', '');
            CreateEmployee.ProductionManager():
                ValidateEmployee(Employee, '', '', '');
            CreateEmployee.Secretary():
                ValidateEmployee(Employee, '', '', '');
            CreateEmployee.InventoryManager():
                begin
                    Employee.Validate("Job Title", ProductionAssistantLbl);
                    ValidateEmployee(Employee, '', '', '');
                end;
        end;
    end;

    local procedure ValidateEmployee(var Employee: Record Employee; UnionCode: Code[10]; EmploymentContractCode: Code[10]; StatisticsGroupCode: Code[10])
    begin
        Employee.Validate("E-Mail", StrSubstNo(EmpEmailLbl, LowerCase(Employee."No.")));
        Employee.Validate("Emplymt. Contract Code", EmploymentContractCode);
        Employee.Validate("Statistics Group Code", StatisticsGroupCode);
        Employee.Validate("Union Code", UnionCode);
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