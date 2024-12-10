codeunit 11598 "Create CH Employee Template"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Employee Templ.", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertEmployeeTempl(var Rec: Record "Employee Templ.")
    var
        CreateEmployeeTemplate: Codeunit "Create Employee Template";
    begin
        case Rec.Code of
            CreateEmployeeTemplate.AdminCode(),
            CreateEmployeeTemplate.ITCode():
                ValidateRecordFields(Rec, '');
        end;
    end;

    local procedure ValidateRecordFields(var EmployeeTempl: Record "Employee Templ."; EmployeePostingGroup: Code[20])
    begin
        EmployeeTempl.Validate("Employee Posting Group", EmployeePostingGroup);
    end;
}