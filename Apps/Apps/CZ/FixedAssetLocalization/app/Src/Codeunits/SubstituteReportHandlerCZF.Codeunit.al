// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.FixedAssets;

using Microsoft.FixedAssets.Depreciation;
using Microsoft.FixedAssets.Maintenance;
using Microsoft.FixedAssets.Reports;
using Microsoft.Foundation.Reporting;
using Microsoft.Utilities;
using System.Apps;
using System.Environment.Configuration;

#pragma warning disable AL0432
codeunit 31245 "Substitute Report Handler CZF"
{
    Permissions = tabledata "NAV App Installed App" = r;

    var
        InstructionMgt: Codeunit "Instruction Mgt.";

    [EventSubscriber(ObjectType::Codeunit, Codeunit::ReportManagement, 'OnAfterSubstituteReport', '', false, false)]
    local procedure OnSubstituteFAReport(ReportId: Integer; var NewReportId: Integer)
    var
        UsedStandardReportMsg: Label 'Used standard report (ID %1) instead of Fixed Asset Localization for Czech report.', Comment = '%1 = NewReportId';
    begin
        if IsTestingEnvironment() then
            exit;

        if not InstructionMgt.IsEnabled(GetSubstituteFAReportsNotificationId()) then begin
            // "Use standard FA reports substitution" in My Notifications is disaled
            case ReportId of
                Report::"Calculate Depreciation CZF":
                    NewReportId := Report::"Calculate Depreciation";
                Report::"Fixed Asset - Analysis CZF":
                    NewReportId := Report::"Fixed Asset - Analysis";
                Report::"Fixed Asset - Book Value 1 CZF":
                    NewReportId := Report::"Fixed Asset - Book Value 01";
                Report::"Fixed Asset - Book Value 2 CZF":
                    NewReportId := Report::"Fixed Asset - Book Value 02";
                Report::"Fixed Asset Card CZF":
                    NewReportId := Report::"Fixed Asset - G/L Analysis";
                Report::"Fixed Asset - Proj. Value CZF":
                    NewReportId := Report::"Fixed Asset - Projected Value";
                Report::"Maintenance - Analysis CZF":
                    NewReportId := Report::"Maintenance - Analysis";
            end;
            if GuiAllowed() then
                if (NewReportId <> ReportId) and (NewReportId <> -1) then
                    Message(UsedStandardReportMsg, NewReportId);
        end else
            case ReportId of
                Report::"Calculate Depreciation":
                    NewReportId := Report::"Calculate Depreciation CZF";
                Report::"Fixed Asset - Analysis":
                    NewReportId := Report::"Fixed Asset - Analysis CZF";
                Report::"Fixed Asset - Book Value 01":
                    NewReportId := Report::"Fixed Asset - Book Value 1 CZF";
                Report::"Fixed Asset - Book Value 02":
                    NewReportId := Report::"Fixed Asset - Book Value 2 CZF";
                Report::"Fixed Asset - G/L Analysis":
                    NewReportId := Report::"Fixed Asset - G/L Analysis CZF";
                Report::"Fixed Asset - Projected Value":
                    NewReportId := Report::"Fixed Asset - Proj. Value CZF";
                Report::"Maintenance - Analysis":
                    NewReportId := Report::"Maintenance - Analysis CZF";
            end;
    end;

    local procedure IsTestingEnvironment(): Boolean
    var
        NAVAppInstalledApp: Record "NAV App Installed App";
    begin
        exit(NAVAppInstalledApp.Get('c81764a5-be79-4d50-ba3e-4ade02073780')); // application "Tests-Fixed Asset"
    end;

    local procedure GetSubstituteFAReportsNotificationId(): Guid
    begin
        exit('0425b159-b4bc-4235-904f-0047f20886d8');
    end;

    [EventSubscriber(ObjectType::Page, Page::"My Notifications", 'OnInitializingNotificationWithDefaultState', '', false, false)]
    local procedure OnInitializingNotificationWithDefaultState()
    var
        MyNotifications: Record "My Notifications";
        UseStandardFAReportsSubstitutionTxt: Label 'Use standard FA reports substitution.';
        UseStandardFAReportsSubstitutionDescriptionTxt: Label 'If substitution is not enabled, fixed assets reports from Base Application will be invoked, even though application "Fixed Asset Localization for Czech" is installed.';
    begin
        MyNotifications.InsertDefault(GetSubstituteFAReportsNotificationId(),
          UseStandardFAReportsSubstitutionTxt,
          UseStandardFAReportsSubstitutionDescriptionTxt,
          true);
    end;

    [EventSubscriber(ObjectType::Table, Database::"My Notifications", 'OnStateChanged', '', false, false)]
    local procedure OnStateChanged(NotificationId: Guid; NewEnabledState: Boolean)
    begin
        case NotificationId of
            GetSubstituteFAReportsNotificationId():
                if NewEnabledState then
                    InstructionMgt.EnableMessageForCurrentUser(GetSubstituteFAReportsNotificationId())
                else
                    InstructionMgt.DisableMessageForCurrentUser(GetSubstituteFAReportsNotificationId());
        end;
    end;
}
