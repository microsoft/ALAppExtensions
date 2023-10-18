// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Finance.Core;

using Microsoft.Foundation.Company;
using Microsoft.Foundation.Reporting;
using System.Environment.Configuration;

codeunit 13603 "Install DK Core"
{
    Access = Internal;

    Subtype = Install;
    trigger OnInstallAppPerCompany()
    begin
        SaveExperienceTier();
        SetDefaultReportLayout();
    end;

    local procedure SaveExperienceTier()
    var
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
        BasicExtTxt: Label 'Basic Ext', Locked = true;
    begin
        ApplicationAreaMgmtFacade.SaveExperienceTierCurrentCompany(BasicExtTxt);
    end;

    local procedure SetDefaultReportLayout()
    var
        TenantReportLayoutSelection: Record "Tenant Report Layout Selection";
        ReportLayoutSelection: Record "Report Layout Selection";
        CompanyInformation: Record "Company Information";
        NewLayoutReports: Dictionary of [Integer, Text[250]];
        CompanyName: Text[30];
        EmptyGuid: Guid;
        ReportID: Integer;
    begin
        // The layout specified in a report extension will not automatically be used when the report extension is deployed.
        // Change "Report Layout Selection" on install

        // Layouts from reportExt are listed in Table "Report Layout List"
        // Not sure how to query properly, so manualy listed for now
        NewLayoutReports.Add(116, './src/Reports/Statement.rdlc');
        NewLayoutReports.Add(117, './src/Reports/Reminder.rdlc');
        NewLayoutReports.Add(118, './src/Reports/FinanceChargeMemo.rdlc');

        if CompanyInformation.Get() then begin
            CompanyName := CopyStr(CompanyInformation.Name, 1, 30);

            foreach ReportID in NewLayoutReports.Keys() do begin
                if not TenantReportLayoutSelection.Get(ReportID, CompanyName, EmptyGuid) then begin
                    TenantReportLayoutSelection.Init();
                    TenantReportLayoutSelection."Company Name" := CompanyName;
                    TenantReportLayoutSelection."Layout Name" := NewLayoutReports.Get(ReportID);
                    TenantReportLayoutSelection."Report ID" := ReportID;
                    TenantReportLayoutSelection.Insert();
                end;

                if not ReportLayoutSelection.Get(ReportID, CompanyName) then begin
                    ReportLayoutSelection.Init();
                    ReportLayoutSelection."Report ID" := ReportID;
                    ReportLayoutSelection."Company Name" := CompanyName;
                    ReportLayoutSelection.Type := ReportLayoutSelection.Type::"RDLC (built-in)";
                    ReportLayoutSelection.Insert();
                end;
            end;
        end;
    end;
}
