// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

using Microsoft.Foundation.Company;

codeunit 13688 "Install SAF-T DK"
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
    begin
        if not AuditFileExportSetup.Get() then
            AuditFileExportSetup.InitSetup(Enum::"Audit File Export Format"::SAFT);
        AuditFileExportSetup.Validate("SAF-T Modification", Enum::"SAF-T Modification"::DK);
        AuditFileExportSetup.Modify(true);
    end;
}
