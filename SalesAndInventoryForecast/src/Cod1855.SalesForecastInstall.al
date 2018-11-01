// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 1855 "Sales Forecast Install"
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
        Item: Record Item;
        Company: Record Company;
        DataClassificationMgt: Codeunit "Data Classification Mgt.";
    begin
        Company.Get(CompanyName());
        if not Company."Evaluation Company" then
            exit;

        DataClassificationMgt.SetFieldToNormal(Database::Item, Item.FieldNo("Has Sales Forecast"));

        DataClassificationMgt.SetTableFieldsToNormal(Database::"MS - Sales Forecast");

        DataClassificationMgt.SetTableFieldsToNormal(Database::"MS - Sales Forecast Parameter");

        DataClassificationMgt.SetTableFieldsToNormal(Database::"MS - Sales Forecast Setup");
    end;

}