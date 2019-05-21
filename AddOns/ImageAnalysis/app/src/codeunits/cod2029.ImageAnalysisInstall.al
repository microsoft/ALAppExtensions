// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

codeunit 2029 "Image Analysis Install"
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
        ImageAnalysisSetup: Record "Image Analysis Setup";
        Company: Record Company;
        DataClassificationMgt: Codeunit "Data Classification Mgt.";
    begin
        Company.Get(CompanyName());
        if not Company."Evaluation Company" then
            exit;

        DataClassificationMgt.SetFieldToNormal(DataBase::"Image Analysis Setup", ImageAnalysisSetup.FieldNo("Confidence Threshold"));
        DataClassificationMgt.SetFieldToNormal(DataBase::"Image Analysis Setup", ImageAnalysisSetup.FieldNo("Image-Based Attribute Recognition Enabled"));

        DataClassificationMgt.SetTableFieldsToNormal(Database::"MS - Image Analyzer Tags");

        DataClassificationMgt.SetTableFieldsToNormal(Database::"MS - Img. Analyzer Blacklist");
    end;

}