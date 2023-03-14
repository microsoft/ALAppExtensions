// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 4510 "Email - Outlook API Install"
{
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    begin
        ApplyEvaluationClassificationsForPrivacy();
    end;

    local procedure ApplyEvaluationClassificationsForPrivacy()
    var
        Company: Record Company;
        Account: Record "Email - Outlook Account";
        APISetup: Record "Email - Outlook API Setup";
        DataClassificationMgt: Codeunit "Data Classification Mgt.";
    begin
        Company.Get(CompanyName());
        if not Company."Evaluation Company" then
            exit;

        DataClassificationMgt.SetFieldToPersonal(Database::"Email - Outlook Account", Account.FieldNo(Name));
        DataClassificationMgt.SetFieldToPersonal(Database::"Email - Outlook Account", Account.FieldNo("Email Address"));

        DataClassificationMgt.SetFieldToNormal(Database::"Email - Outlook API Setup", APISetup.FieldNo(ClientId));
        DataClassificationMgt.SetFieldToNormal(Database::"Email - Outlook API Setup", APISetup.FieldNo(ClientSecret));
    end;
}