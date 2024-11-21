codeunit 11394 "Create Employee BE"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::Employee, 'OnBeforeModifyEvent', '', false, false)]
    local procedure OnBeforeInsertEmployee(var Rec: Record Employee)
    var
        CreateEmployee: Codeunit "Create Employee";
    begin
        case Rec."No." of
            CreateEmployee.ManagingDirector():
                ValidateEmployee(Rec, '02/704.31.84', '0476/50.71.83');
            CreateEmployee.SalesManager():
                ValidateEmployee(Rec, '0476/50.71.83', '0476/50.71.77');
            CreateEmployee.Designer():
                ValidateEmployee(Rec, '02/704.31.79', '0476/50.71.78');
            CreateEmployee.ProductionAssistant():
                ValidateEmployee(Rec, '02/704.31.85', '0476/50.71.80');
            CreateEmployee.ProductionManager():
                ValidateEmployee(Rec, '02/704.31.76', '0476/50.71.76');
            CreateEmployee.Secretary():
                ValidateEmployee(Rec, '02/704.31.91', '0476/50.71.82');
            CreateEmployee.InventoryManager():
                begin
                    Rec.Validate("Job Title", ProductionAssistantLbl);
                    ValidateEmployee(Rec, '02/704.31.96', '0478/55.59.84');
                end;
        end;
    end;

    local procedure ValidateEmployee(var Employee: Record Employee; PhoneNo: Text[30]; MobilePhoneNo: Text[30])
    begin
        Employee.Validate("Phone No.", PhoneNo);
        Employee.Validate("Mobile Phone No.", MobilePhoneNo);
    end;

    var
        ProductionAssistantLbl: Label 'Production Assistant', MaxLength = 30;
}