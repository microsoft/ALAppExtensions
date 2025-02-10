codeunit 10826 "Create ES Employee"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::Employee, 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertResource(var Rec: Record Employee)
    var
        CreateEmployee: Codeunit "Create Employee";
    begin
        case Rec."No." of
            CreateEmployee.ManagingDirector(),
            CreateEmployee.SalesManager(),
            CreateEmployee.Designer(),
            CreateEmployee.ProductionAssistant(),
            CreateEmployee.ProductionManager(),
            CreateEmployee.Secretary(),
            CreateEmployee.InventoryManager():
                Rec.Validate("Employee Posting Group", '');
        end;
    end;
}