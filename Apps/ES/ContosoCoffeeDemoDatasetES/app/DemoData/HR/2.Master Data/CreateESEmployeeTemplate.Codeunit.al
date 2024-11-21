codeunit 10825 "Create ES Employee Template"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Employee Templ.", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertResource(var Rec: Record "Employee Templ.")
    var
        CreateEmployeeTemplate: Codeunit "Create Employee Template";
    begin
        case Rec.Code of
            CreateEmployeeTemplate.AdminCode(),
            CreateEmployeeTemplate.ITCode():
                Rec.Validate("Employee Posting Group", '');
        end;
    end;
}