// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

using Microsoft.Foundation.Company;
using System.Environment;
using System.Privacy;

codeunit 5288 "Install SAF-T"
{
    Access = Internal;
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    var
        AppInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(AppInfo);
        if (AppInfo.DataVersion() <> Version.Create('0.0.0.0')) then
            exit;

        SetupSAFT();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Company-Initialize", 'OnCompanyInitialize', '', false, false)]
    local procedure CompanyInitialize()
    begin
        SetupSAFT();
    end;

    local procedure SetupSAFT()
    var
        AuditFileExportSetup: Record "Audit File Export Setup";
        MappingHelperSAFT: Codeunit "Mapping Helper SAF-T";
    begin
        ApplyEvaluationClassificationsForPrivacy();

        AuditFileExportSetup.InitSetup(Enum::"Audit File Export Format"::SAFT);
        MappingHelperSAFT.InsertSAFTSourceCodes();
        MappingHelperSAFT.UpdateSAFTSourceCodesBySetup();
    end;

    local procedure ApplyEvaluationClassificationsForPrivacy()
    var
        Company: Record Company;
        DataClassificationMgt: Codeunit "Data Classification Mgt.";
    begin
        Company.Get(CompanyName());
        if not Company."Evaluation Company" then
            exit;

        DataClassificationMgt.SetTableFieldsToNormal(Database::"Source Code SAF-T");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"Missing Field SAF-T");
    end;
}
