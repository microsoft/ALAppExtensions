// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 1436 "Headlines Install"
{
    Subtype = install;

    trigger OnInstallAppPerCompany()
    begin
        CompanyInitialize();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Company-Initialize", 'OnCompanyInitialize', '', false, false)]
    local procedure CompanyInitialize()
    begin
        ApplyEvaluationClassificationsForPrivacy();
    end;

    local procedure ApplyEvaluationClassificationsForPrivacy()
    var
        Company: Record Company;
        EssBusinessHeadlinePerUsr: Record "Ess. Business Headline Per Usr";
        DataClassificationMgt: Codeunit "Data Classification Mgt.";
    begin
        Company.Get(CompanyName());
        if not Company."Evaluation Company" then
            exit;

        DataClassificationMgt.SetTableFieldsToNormal(Database::"Ess. Business Headline Per Usr");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"Headline Details Per User");

        DataClassificationMgt.SetFieldToCompanyConfidential(Database::"Ess. Business Headline Per Usr", EssBusinessHeadlinePerUsr.FieldNo("VAT Return Period Record Id"));
    end;

}