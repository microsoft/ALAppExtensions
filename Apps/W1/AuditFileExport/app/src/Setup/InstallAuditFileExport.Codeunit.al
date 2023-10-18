// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

using Microsoft.Foundation.Company;
using System.Environment;
using System.Privacy;

codeunit 5264 "Install Audit File Export"
{
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    var
        AppInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(AppInfo);
        if (AppInfo.DataVersion() <> Version.Create('0.0.0.0')) then
            exit;

        SetupAuditFileExport();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Company-Initialize", 'OnCompanyInitialize', '', false, false)]
    local procedure CompanyInitialize()
    begin
        SetupAuditFileExport();
    end;

    local procedure SetupAuditFileExport()
    var
        AuditMappingHelper: Codeunit "Audit Mapping Helper";
    begin
        ApplyEvaluationClassificationsForPrivacy();
        AuditMappingHelper.InsertDefaultNoSeriesInAuditFileExportSetup();
    end;

    local procedure ApplyEvaluationClassificationsForPrivacy()
    var
        Company: Record Company;
        DataClassificationMgt: Codeunit "Data Classification Mgt.";
    begin
        Company.Get(CompanyName());
        if not Company."Evaluation Company" then
            exit;

        DataClassificationMgt.SetTableFieldsToNormal(Database::"Audit File Export Setup");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"Audit File Export Format Setup");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"Audit Export Data Type Setup");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"Audit File Export Header");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"Audit File Export Line");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"Audit File");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"G/L Account Mapping Header");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"G/L Account Mapping Line");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"Standard Account");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"Standard Account Category");
    end;
}
