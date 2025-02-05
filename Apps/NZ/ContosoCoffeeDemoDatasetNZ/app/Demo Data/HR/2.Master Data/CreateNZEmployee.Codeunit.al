codeunit 17141 "Create NZ Employee"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::Employee, 'OnBeforeOnInsert', '', false, false)]
    local procedure OnBeforeInsertEmployee(var Employee: Record Employee)
    var
        CreateEmployee: Codeunit "Create Employee";
    begin
        case Employee."No." of
            CreateEmployee.ManagingDirector():
                ValidateEmployee(Employee, AroValleyLbl, '6002', '');
            CreateEmployee.SalesManager(),
            CreateEmployee.ProductionManager(),
            CreateEmployee.Secretary():
                ValidateEmployee(Employee, AramohoCityLbl, '5001', '');
            CreateEmployee.Designer():
                ValidateEmployee(Employee, AucklandCityLbl, '1001', '');
            CreateEmployee.ProductionAssistant(),
            CreateEmployee.InventoryManager():
                ValidateEmployee(Employee, AucklandPostmasterLbl, '1030', '');
        end;
    end;

    local procedure ValidateEmployee(var Employee: Record Employee; City: Text[30]; PostCode: Code[20]; County: Text[30])
    begin
        Employee.Validate(City, City);
        Employee.Validate("Post Code", PostCode);
        Employee.Validate(County, County);
    end;

    var
        AramohoCityLbl: Label 'Aramoho', MaxLength = 30;
        AroValleyLbl: Label 'Aro Valley', MaxLength = 30;
        AucklandCityLbl: Label 'Auckland', MaxLength = 30;
        AucklandPostmasterLbl: Label 'Auckland Postmaster', MaxLength = 30;
}