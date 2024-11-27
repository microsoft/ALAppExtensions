codeunit 10524 "Create Employee US"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    trigger OnRun()
    var
        CreateEmployee: Codeunit "Create Employee";
    begin
        UpdateEmployeeEmail(CreateEmployee.ManagingDirector(), 19731212D, 20010601D, FifthAvenueLbl);
        UpdateEmployeeEmail(CreateEmployee.SalesManager(), 19790212D, 20040301D, WestchesterAvenueLbl);
        UpdateEmployeeEmail(CreateEmployee.Designer(), 19760310D, 20100801D, ColumbusCircleLbl);
        UpdateEmployeeEmail(CreateEmployee.ProductionAssistant(), 19820807D, 20010601D, DestinyUSADriveLbl);
        UpdateEmployeeEmail(CreateEmployee.ProductionManager(), 19670705D, 20010601D, WaltWhitmanRoadLbl);
        UpdateEmployeeEmail(CreateEmployee.Secretary(), 19790507D, 20010601D, CommonsWayLbl);
        UpdateEmployeeEmail(CreateEmployee.InventoryManager(), 19831207D, 20061201D, RouteSouthLbl);
    end;

    local procedure UpdateEmployeeEmail(EmployeeNo: Code[20]; BirthDate: Date; EmploymentDate: Date; Address: Text[100])
    var
        Employee: Record Employee;
        CreateEmployee: Codeunit "Create Employee";
    begin
        Employee.Get(EmployeeNo);
        Employee.Validate("Birth Date", BirthDate);
        Employee.Validate("Employment Date", EmploymentDate);
        Employee.Validate(Address, Address);
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
        FifthAvenueLbl: Label '677 Fifth Avenue', MaxLength = 30, Locked = true;
        WestchesterAvenueLbl: Label '125 Westchester Avenue', MaxLength = 30;
        WaltWhitmanRoadLbl: Label '160 Walt Whitman Road', MaxLength = 30, Locked = true;
        ColumbusCircleLbl: Label '10 Columbus Circle', MaxLength = 30, Locked = true;
        CommonsWayLbl: Label '400 Commons Way', MaxLength = 30, Locked = true;
        DestinyUSADriveLbl: Label '10344 Destiny USA Drive', MaxLength = 30, Locked = true;
        RouteSouthLbl: Label '3710 Route 9 South', MaxLength = 30, Locked = true;
        ProductionAssistantLbl: Label 'Production Assistant', MaxLength = 30;
#pragma warning disable AA0240
        EmpEmailLbl: Label '%1@cronus-demosite.com', Locked = true;
#pragma warning restore AA0240
}