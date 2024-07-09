// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance;

using Microsoft.Foundation.Company;
using Microsoft.Foundation.Reporting;
using System.Environment.Configuration;
using System.Reflection;

codeunit 11295 "Install SE Core"
{
    Access = Internal;
    Subtype = Install;
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions =
        tabledata "Company Information" = rm,
        tabledata "Report Layout List" = r,
        tabledata "Report Layout Selection" = ri,
        tabledata "Tenant Report Layout Selection" = ri;

    trigger OnInstallAppPerCompany()
    begin
        SetDefaultReportLayouts();
#if not CLEAN23
        UpgradeCompanyInformationTable();
#endif
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Company-Initialize", 'OnCompanyInitialize', '', false, false)]
    local procedure OnCompanyInitialize()
    begin
        SetDefaultReportLayouts();
    end;

#if not CLEAN23
    local procedure UpgradeCompanyInformationTable()
    var
        CompanyInformation: Record "Company Information";
        RecRef: RecordRef;
        TargetFieldRef: FieldRef;
        SourceFieldRef: FieldRef;
    begin
        if not CompanyInformation.Get() then
            exit;

        RecRef.Open(Database::"Company Information", false);
        RecRef.GetBySystemId(CompanyInformation.SystemId);
        
        if RecRef.FieldExist(11200) then begin // field 11290 - CompanyInformation."Plus Giro No."
            SourceFieldRef := RecRef.Field(11200);
            TargetFieldRef := RecRef.Field(11290);
            TargetFieldRef.VALUE := SourceFieldRef.VALUE;
            RecRef.Modify(false);
        end;

        if RecRef.FieldExist(11201) then begin // field 11291 - CompanyInformation."Registered Office"
            SourceFieldRef := RecRef.Field(11201);
            TargetFieldRef := RecRef.Field(11291);
            TargetFieldRef.VALUE := SourceFieldRef.VALUE;
            RecRef.Modify(false);
        end;
    end;
#endif

    internal procedure SetDefaultReportLayouts()
    var
        ReportLayoutList: Record "Report Layout List";
        ReportLayoutSelection: Record "Report Layout Selection";
        TenantReportLayoutSelection: Record "Tenant Report Layout Selection";
        CompanyInformation: Record "Company Information";
        ExtensionID, EmptyGuid : Guid;
        CompanyName: Text[30];
    begin
        if not CompanyInformation.Get() then
            exit;

        if CompanyName = '' then
            CompanyName := CopyStr(CompanyName(), 1, 30)
        else
            CompanyName := CopyStr(CompanyInformation.Name, 1, 30);

        ExtensionID := '275032ba-04a6-457f-bc79-1ffe6cb63596';

        ReportLayoutList.SetRange("Application ID", ExtensionID);

        if ReportLayoutList.FindSet() then
            repeat
                if not TenantReportLayoutSelection.Get(ReportLayoutList."Report ID", CompanyName, EmptyGuid) then begin
                    TenantReportLayoutSelection.Init();
                    TenantReportLayoutSelection."App ID" := ReportLayoutList."Application ID";
                    TenantReportLayoutSelection."Company Name" := CompanyName;
                    TenantReportLayoutSelection."Layout Name" := ReportLayoutList.Name;
                    TenantReportLayoutSelection."Report ID" := ReportLayoutList."Report ID";
                    TenantReportLayoutSelection."User ID" := EmptyGuid;
                    TenantReportLayoutSelection.Insert(true);
                end;

                if not ReportLayoutSelection.Get(ReportLayoutList."Report ID", CompanyName) then begin
                    ReportLayoutSelection.Init();
                    ReportLayoutSelection."Report ID" := ReportLayoutList."Report ID";
                    ReportLayoutSelection."Company Name" := CompanyName;
                    ReportLayoutSelection.Type := ReportLayoutSelection.Type::"RDLC (built-in)";
                    ReportLayoutSelection.Insert(true);
                end;
            until ReportLayoutList.Next() = 0;
    end;
}
