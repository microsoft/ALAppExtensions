codeunit 11235 "Create Employee Template SE"
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
        CreateEmployeePostingGroup: Codeunit "Create Employee Posting Group";
    begin
        EmployeeTemplate.Get(EmployeeTemplateCode);
        EmployeeTemplate.Validate("Employee Posting Group", CreateEmployeePostingGroup.EmployeeExpenses());
        EmployeeTemplate.Modify(true);
    end;
}