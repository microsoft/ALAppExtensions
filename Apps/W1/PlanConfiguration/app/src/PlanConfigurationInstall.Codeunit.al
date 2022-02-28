// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// List page that hold the default user groups assigned to a plan.
/// </summary> 
codeunit 9039 "Plan Configuration Install"
{
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    begin
        ApplyEvaluationClassificationsForPrivacy();
    end;

    local procedure ApplyEvaluationClassificationsForPrivacy()
    var
        Company: Record Company;
        CustomUserGroupInPlan: Record "Custom User Group In Plan";
        DataClassificationMgt: Codeunit "Data Classification Mgt.";
    begin
        Company.Get(CompanyName());
        if not Company."Evaluation Company" then
            exit;

        DataClassificationMgt.SetFieldToPersonal(Database::"Custom User Group In Plan", CustomUserGroupInPlan.FieldNo("User Group Code"));
        DataClassificationMgt.SetFieldToPersonal(Database::"Custom User Group In Plan", CustomUserGroupInPlan.FieldNo("Company Name"));

        DataClassificationMgt.SetFieldToNormal(Database::"Custom User Group In Plan", CustomUserGroupInPlan.FieldNo(Id));
        DataClassificationMgt.SetFieldToNormal(Database::"Custom User Group In Plan", CustomUserGroupInPlan.FieldNo("Plan Id"));
    end;
}