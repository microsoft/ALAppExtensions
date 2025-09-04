#if not CLEAN28
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using System.Upgrade;
using System.Telemetry;
using Microsoft.Purchases.Payables;
using Microsoft.Purchases.Vendor;

codeunit 10058 "IRS 1099 Upgrade"
{
    Subtype = Upgrade;
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;
    ObsoleteState = Pending;
    ObsoleteReason = 'This report will be removed in a future release as the IRS 1099 data upgrade is no longer needed.';
    ObsoleteTag = '28.0';
    Permissions =
        tabledata "Vendor Ledger Entry" = r;

    var
        Telemetry: Codeunit Telemetry;
        IRS1099TransferFromBaseApp: Codeunit "IRS 1099 Transfer From BaseApp";

    trigger OnUpgradePerCompany()
    begin
        UpgradeIRS1099();
    end;

    procedure UpgradeIRS1099()
    var
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeIRS1099Tag()) then begin
            Telemetry.LogMessage('0000PZG', 'Has upgrade tag', Verbosity::Normal, DataClassification::SystemMetadata);
            exit;
        end;

        Telemetry.LogMessage('0000PZH', 'Upgrade procedure started', Verbosity::Normal, DataClassification::SystemMetadata);
        UpgradeData();
        Telemetry.LogMessage('0000PZI', 'Upgrade procedure completed', Verbosity::Normal, DataClassification::SystemMetadata);

        UpgradeTag.SetUpgradeTag(UpgradeIRS1099Tag());
        Telemetry.LogMessage('0000PZJ', 'Set upgrade tag', Verbosity::Normal, DataClassification::SystemMetadata);
    end;

    local procedure UpgradeData()
    var
        IRSReportingPeriod: Record "IRS Reporting Period";
        IRS1099FormBox: Record "IRS 1099 Form Box";
        ReportingYear: Integer;
    begin
        if IRS1099DataTransferCompleted() then
            exit;
        ReportingYear := 2025;
        if not IRS1099UpgradeRequired(IRSReportingPeriod, ReportingYear) then
            exit;
        if IRS1099FormBox.IsEmpty() then begin
            Telemetry.LogMessage('0000Q1T', 'Setup transfer', Verbosity::Normal, DataClassification::SystemMetadata);
            IRS1099TransferFromBaseApp.TransferIRS1099Setup(IRSReportingPeriod, Date2DMY(IRSReportingPeriod."Starting Date", 3));
        end;
        Telemetry.LogMessage('0000Q1U', 'Data transfer', Verbosity::Normal, DataClassification::SystemMetadata);
        IRS1099TransferFromBaseApp.TransferIRS1099Data(IRSReportingPeriod);
    end;

    local procedure IRS1099DataTransferCompleted(): Boolean
    var
        IRSFormsSetup: Record "IRS Forms Setup";
    begin
        if not IRSFormsSetup.Get() then
            exit(false);
        if IRSFormsSetup."Data Transfer Completed" then begin
            Telemetry.LogMessage('0000PZK', 'Data Transfer Completed has been already completed', Verbosity::Normal, DataClassification::SystemMetadata);
            exit(true);
        end;
        exit(false);
    end;

    local procedure IRS1099UpgradeRequired(var IRSReportingPeriod: Record "IRS Reporting Period"; ReportingYear: Integer): Boolean
    var
        Vendor: Record Vendor;
        VendorLedgerEntry: Record "Vendor Ledger Entry";
    begin
        IRSReportingPeriod.SetFilter("Starting Date", '<=%1', DMY2Date(1, 1, ReportingYear));
        IRSReportingPeriod.SetFilter("Ending Date", '>= %1', DMY2Date(31, 12, ReportingYear));
        if IRSReportingPeriod.FindFirst() then begin
            Telemetry.LogMessage('0000PZL', 'IRS Reporting Period found', Verbosity::Normal, DataClassification::SystemMetadata);
            exit(true);
        end;
        if IRSReportingPeriod.Get(Format(ReportingYear)) then begin
            Telemetry.LogMessage('0000PZM', 'IRS Reporting Period for the year 2025 already exists, but the dates are not right.', Verbosity::Normal, DataClassification::SystemMetadata);
            exit(false);
        end;
        Vendor.SetFilter("IRS 1099 Code", '<>%1', '');
        if Vendor.IsEmpty() then begin
            Telemetry.LogMessage('0000Q1V', 'No vendors with IRS 1099 Code found', Verbosity::Normal, DataClassification::SystemMetadata);
            VendorLedgerEntry.SetRange("Posting Date", DMY2Date(1, 1, ReportingYear), DMY2Date(31, 12, ReportingYear));
            VendorLedgerEntry.SetFilter("IRS 1099 Code", '<>%1', '');
            VendorLedgerEntry.SetFilter("IRS 1099 Amount", '>0');
            if VendorLedgerEntry.IsEmpty() then begin
                Telemetry.LogMessage('0000Q1W', 'No vendor ledger entries with IRS 1099 Code and Amount found', Verbosity::Normal, DataClassification::SystemMetadata);
                exit(false);
            end;
        end;
        Telemetry.LogMessage('0000PZN', 'Creating new IRS Reporting Period', Verbosity::Normal, DataClassification::SystemMetadata);
        IRS1099TransferFromBaseApp.CreateReportingPeriod(IRSReportingPeriod, ReportingYear);
        Telemetry.LogMessage('0000PZO', 'Transferring IRS 1099 setup', Verbosity::Normal, DataClassification::SystemMetadata);
        IRS1099TransferFromBaseApp.TransferIRS1099Setup(IRSReportingPeriod, ReportingYear);
        exit(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", 'OnGetPerCompanyUpgradeTags', '', false, false)]
    local procedure RegisterPerCompanyTags(var PerCompanyUpgradeTags: List of [Code[250]])
    begin
        PerCompanyUpgradeTags.Add(UpgradeIRS1099Tag());
    end;

    local procedure UpgradeIRS1099Tag(): Code[250]
    begin
        exit('MS-591538-UpdateIRS1099-20250822');
    end;
}
#endif