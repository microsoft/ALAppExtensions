codeunit 11506 "Create Employee Template NL"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        CreateEmployeeTemplate: Codeunit "Create Employee Template";
    begin
        UpdateEmployeeTemplate(CreateEmployeeTemplate.AdminCode());
        UpdateEmployeeTemplate(CreateEmployeeTemplate.ITCode());
    end;

    local procedure UpdateEmployeeTemplate(EmployeeTemplateCode: Code[20])
    var
        EmployeeTemplate: Record "Employee Templ.";
    begin
        EmployeeTemplate.Get(EmployeeTemplateCode);
        EmployeeTemplate.Validate("Employee Posting Group", '');
        EmployeeTemplate.Modify(true);
    end;
}