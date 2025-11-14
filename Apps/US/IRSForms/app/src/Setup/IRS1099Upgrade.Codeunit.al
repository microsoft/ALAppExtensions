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
            TransferIRS1099Setup(IRSReportingPeriod, ReportingYear);

        end;
        Telemetry.LogMessage('0000Q1U', 'Data transfer', Verbosity::Normal, DataClassification::SystemMetadata);
        IRS1099TransferFromBaseApp.TransferIRS1099Data(IRSReportingPeriod);
    end;

    local procedure TransferIRS1099Setup(IRSReportingPeriod: Record "IRS Reporting Period"; ReportingYear: Integer)
    var
        IRSFormsData: Codeunit "IRS Forms Data";
    begin
        Telemetry.LogMessage('0000PZA', 'IRS 1099 setup transfer started', Verbosity::Normal, DataClassification::SystemMetadata);
        TransferFormBoxes(IRSReportingPeriod."No.");
        IRS1099TransferFromBaseApp.TransferVendorSetup(IRSReportingPeriod."No.");
        TransferAdjustments(IRSReportingPeriod."No.", ReportingYear);
        IRSFormsData.AddFormInstructionLines(IRSReportingPeriod."No.");
        Telemetry.LogMessage('0000PZB', 'IRS 1099 setup transfer completed', Verbosity::Normal, DataClassification::SystemMetadata);
    end;

    local procedure TransferFormBoxes(PeriodNo: Code[20])
    var
#pragma warning disable AL0432
        IRS1099FormBoxOld: Record "IRS 1099 Form-Box";
#pragma warning restore AL0432
        IRS1099Form: Record "IRS 1099 Form";
        IRS1099FormBoxNew: Record "IRS 1099 Form Box";
        LastFormNo, CurrFormNo : Code[20];
        StatementLineNo: Integer;
    begin
        if not IRS1099FormBoxOld.FindSet() then
            exit;
        LastFormNo := '';
        repeat
            if IsOld1099FormBoxTransferable(IRS1099FormBoxOld.Code) then begin
                CurrFormNo := GetFormNoFromOldFormBox(IRS1099FormBoxOld.Code);
                if CurrFormNo <> LastFormNo then begin
                    IRS1099Form.Init();
                    IRS1099Form."Period No." := PeriodNo;
                    IRS1099Form."No." := CurrFormNo;
                    IRS1099Form.Insert();
                    StatementLineNo := 0;
                end;
                IRS1099FormBoxNew.Init();
                IRS1099FormBoxNew."Period No." := PeriodNo;
                IRS1099FormBoxNew."Form No." := IRS1099Form."No.";
                IRS1099FormBoxNew."No." := IRS1099FormBoxOld.Code;
                IRS1099FormBoxNew.Description := IRS1099FormBoxOld.Description;
                IRS1099FormBoxNew."Minimum Reportable Amount" := IRS1099FormBoxOld."Minimum Reportable";
                IRS1099FormBoxNew.Insert();
                StatementLineNo += 10000;
                AddFormStatementLine(PeriodNo, IRS1099Form."No.", IRS1099FormBoxNew."No.", StatementLineNo, IRS1099FormBoxNew.Description);
                LastFormNo := CurrFormNo;
            end;
        until IRS1099FormBoxOld.Next() = 0;
    end;

    local procedure TransferAdjustments(PeriodNo: Code[20]; ReportingYear: Integer)
    var
#pragma warning disable AL0432
        IRS1099Adjustment: Record "IRS 1099 Adjustment";
        IRS1099VendorFormBoxAdj: Record "IRS 1099 Vendor Form Box Adj.";
    begin
        IRS1099Adjustment.SetRange(Year, ReportingYear);
        if not IRS1099Adjustment.FindSet() then
            exit;
        repeat
            if IsOld1099FormBoxTransferable(IRS1099Adjustment."IRS 1099 Code") then begin
                IRS1099VendorFormBoxAdj.Init();
                IRS1099VendorFormBoxAdj."Period No." := PeriodNo;
                IRS1099VendorFormBoxAdj."Vendor No." := IRS1099Adjustment."Vendor No.";
                IRS1099VendorFormBoxAdj."Form No." := GetFormNoFromOldFormBox(IRS1099Adjustment."IRS 1099 Code");
                IRS1099VendorFormBoxAdj."Form Box No." := IRS1099Adjustment."IRS 1099 Code";
                IRS1099VendorFormBoxAdj.Amount := IRS1099Adjustment.Amount;
                IRS1099VendorFormBoxAdj.Insert();
            end;
        until IRS1099Adjustment.Next() = 0;
#pragma warning restore AL0432
    end;

    local procedure AddFormStatementLine(PeriodNo: Code[20]; FormNo: Code[20]; FormBoxNo: Code[20]; StatementLineNo: Integer; Description: Text)
    var
        IRS1099FormStatementLine: Record "IRS 1099 Form Statement Line";
        StatementLineFilterExpressionTxt: Label 'Form Box No.: %1', Comment = '%1 = Form Box No.';
    begin
        IRS1099FormStatementLine.Validate("Period No.", PeriodNo);
        IRS1099FormStatementLine.Validate("Form No.", FormNo);
        IRS1099FormStatementLine.Validate("Line No.", StatementLineNo);
        IRS1099FormStatementLine.Validate("Row No.", FormBoxNo);
        IRS1099FormStatementLine.Validate("Description", Description);
        if IRS1099FormStatementLine."Row No." = 'MISC-07' then
            IRS1099FormStatementLine."Print Value Type" := Enum::"IRS 1099 Print Value Type"::"Yes/No";
        IRS1099FormStatementLine.Validate("Filter Expression", StrSubstNo(StatementLineFilterExpressionTxt, FormBoxNo));
        IRS1099FormStatementLine.Insert(true);
    end;

    local procedure GetFormNoFromOldFormBox(OldFormBox: Code[20]): Code[20]
    var
        DashPosition: Integer;
    begin
        DashPosition := StrPos(OldFormBox, '-');
#pragma warning disable AA0139
        exit(CopyStr(OldFormBox, 1, DashPosition - 1));
#pragma warning restore AA0139
    end;

    local procedure IsOld1099FormBoxTransferable(OldFormBox: Text): Boolean
    begin
        exit((OldFormBox.Contains('MISC') or OldFormBox.Contains('DIV') or OldFormBox.Contains('INT') or OldFormBox.Contains('NEC')) and OldFormBox.Contains('-'));
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