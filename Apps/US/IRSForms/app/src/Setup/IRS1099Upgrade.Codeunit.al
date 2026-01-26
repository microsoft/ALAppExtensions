#if not CLEAN28
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Purchases.Payables;
using Microsoft.Purchases.Vendor;
using System.Telemetry;
using System.Upgrade;

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
        UpgradeData(2025);
        UpgradeData(2026);
        Telemetry.LogMessage('0000PZI', 'Upgrade procedure completed', Verbosity::Normal, DataClassification::SystemMetadata);

        UpgradeTag.SetUpgradeTag(UpgradeIRS1099Tag());
        Telemetry.LogMessage('0000PZJ', 'Set upgrade tag', Verbosity::Normal, DataClassification::SystemMetadata);
    end;

    local procedure UpgradeData(ReportingYear: Integer)
    var
        IRSReportingPeriod: Record "IRS Reporting Period";
        IRS1099FormBox: Record "IRS 1099 Form Box";
    begin
        if IRS1099DataTransferCompleted() then
            exit;
        if not IRS1099UpgradeRequired(IRSReportingPeriod, ReportingYear) then
            exit;
        IRS1099FormBox.SetRange("Period No.", IRSReportingPeriod."No.");
        if IRS1099FormBox.IsEmpty() then begin
            Telemetry.LogMessage('0000Q1T', 'Setup transfer', Verbosity::Normal, DataClassification::SystemMetadata);
            TransferIRS1099Setup(IRSReportingPeriod, ReportingYear);

        end;
        Telemetry.LogMessage('0000Q1U', 'Data transfer', Verbosity::Normal, DataClassification::SystemMetadata);
        TransferIRS1099Data(IRSReportingPeriod);
    end;

    local procedure TransferIRS1099Setup(IRSReportingPeriod: Record "IRS Reporting Period"; ReportingYear: Integer)
    var
        IRSFormsData: Codeunit "IRS Forms Data";
    begin
        Telemetry.LogMessage('0000PZA', 'IRS 1099 setup transfer started', Verbosity::Normal, DataClassification::SystemMetadata);
        TransferFormBoxes(IRSReportingPeriod."No.");
        TransferVendorSetup(IRSReportingPeriod."No.");
        TransferAdjustments(IRSReportingPeriod."No.", ReportingYear);
        IRSFormsData.AddFormInstructionLines(IRSReportingPeriod."No.");
        Telemetry.LogMessage('0000PZB', 'IRS 1099 setup transfer completed', Verbosity::Normal, DataClassification::SystemMetadata);
    end;

    local procedure TransferVendorSetup(PeriodNo: Code[20])
    var
        Vendor: Record Vendor;
        IRS1099VendorFormBoxSetup: Record "IRS 1099 Vendor Form Box Setup";
    begin
#pragma warning disable AL0432
        Vendor.SetFilter("IRS 1099 Code", '<>%1', '');
        if not Vendor.FindSet(true) then
            exit;
        repeat
            if IsOld1099FormBoxTransferable(Vendor."IRS 1099 Code") then begin
                IRS1099VendorFormBoxSetup.Init();
                IRS1099VendorFormBoxSetup."Period No." := PeriodNo;
                IRS1099VendorFormBoxSetup."Vendor No." := Vendor."No.";
                IRS1099VendorFormBoxSetup."Form No." := GetFormNoFromOldFormBox(Vendor."IRS 1099 Code");
                IRS1099VendorFormBoxSetup."Form Box No." := Vendor."IRS 1099 Code";
                if IRS1099VendorFormBoxSetup.Insert() then;
            end;
            Vendor."FATCA Requirement" := Vendor."FATCA filing requirement";
            Vendor.Modify();
        until Vendor.Next() = 0;
#pragma warning restore AL0432
    end;

    local procedure TransferIRS1099Data(IRSReportingPeriod: Record "IRS Reporting Period")
    begin
        Telemetry.LogMessage('0000PZC', 'IRS 1099 data transfer started', Verbosity::Normal, DataClassification::SystemMetadata);
        TransferPurchaseDocuments(IRSReportingPeriod."No.", IRSReportingPeriod."Starting Date", IRSReportingPeriod."Ending Date");
        TransferPostedPurchInvoices(IRSReportingPeriod."No.", IRSReportingPeriod."Starting Date", IRSReportingPeriod."Ending Date");
        TransferPostedPurchCrMemos(IRSReportingPeriod."No.", IRSReportingPeriod."Starting Date", IRSReportingPeriod."Ending Date");
        TransferVendorLedgerEntries(IRSReportingPeriod."No.", IRSReportingPeriod."Starting Date", IRSReportingPeriod."Ending Date");
        Telemetry.LogMessage('0000PZD', 'IRS 1099 data transfer completed', Verbosity::Normal, DataClassification::SystemMetadata);
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
                    if IRS1099Form.Insert() then;
                    StatementLineNo := 0;
                end;
                IRS1099FormBoxNew.Init();
                IRS1099FormBoxNew."Period No." := PeriodNo;
                IRS1099FormBoxNew."Form No." := IRS1099Form."No.";
                IRS1099FormBoxNew."No." := IRS1099FormBoxOld.Code;
                IRS1099FormBoxNew.Description := IRS1099FormBoxOld.Description;
                IRS1099FormBoxNew."Minimum Reportable Amount" := IRS1099FormBoxOld."Minimum Reportable";
                if IRS1099FormBoxNew.Insert() then;
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
                if IRS1099VendorFormBoxAdj.Insert() then;
            end;
        until IRS1099Adjustment.Next() = 0;
#pragma warning restore AL0432
    end;

    local procedure TransferPurchaseDocuments(PeriodNo: Code[20]; StartingDate: Date; EndingDate: Date)
    var
        PurchHeader: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
    begin
#pragma warning disable AL0432
        PurchHeader.SetFilter(
            "Document Type", '%1|%2|%3|%4', PurchHeader."Document Type"::Invoice, PurchHeader."Document Type"::"Credit Memo", PurchHeader."Document Type"::Order, PurchHeader."Document Type"::"Return Order");
        PurchHeader.SetRange("Posting Date", StartingDate, EndingDate);
        PurchHeader.SetFilter("IRS 1099 Code", '<>%1', '');
        PurchHeader.SetRange("IRS 1099 Reporting Period", '');
        if not PurchHeader.FindSet(true) then
            exit;
        PurchLine.SetRange("IRS 1099 Liable", true);
        repeat
            if IsOld1099FormBoxTransferable(PurchHeader."IRS 1099 Code") then begin
                PurchHeader."IRS 1099 Reporting Period" := PeriodNo;
                PurchHeader."IRS 1099 Form No." := GetFormNoFromOldFormBox(PurchHeader."IRS 1099 Code");
                PurchHeader."IRS 1099 Form Box No." := PurchHeader."IRS 1099 Code";
                PurchHeader.Modify();
                PurchLine.SetRange("Document Type", PurchHeader."Document Type");
                PurchLine.SetRange("Document No.", PurchHeader."No.");
                if PurchLine.FindSet(true) then
                    repeat
                        PurchLine."1099 Liable" := PurchLine."IRS 1099 Liable";
                        PurchLine.Modify();
                    until PurchLine.Next() = 0;
            end;
        until PurchHeader.Next() = 0;
#pragma warning restore AL0432
    end;

    local procedure TransferPostedPurchInvoices(PeriodNo: Code[20]; StartingDate: Date; EndingDate: Date)
    var
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchInvLine: Record "Purch. Inv. Line";
    begin
#pragma warning disable AL0432
        PurchInvHeader.SetRange("Posting Date", StartingDate, EndingDate);
        PurchInvHeader.SetFilter("IRS 1099 Code", '<>%1', '');
        PurchInvHeader.SetRange("IRS 1099 Reporting Period", '');
        if not PurchInvHeader.FindSet(true) then
            exit;
        repeat
            if IsOld1099FormBoxTransferable(PurchInvHeader."IRS 1099 Code") then begin
                PurchInvHeader."IRS 1099 Reporting Period" := PeriodNo;
                PurchInvHeader."IRS 1099 Form No." := GetFormNoFromOldFormBox(PurchInvHeader."IRS 1099 Code");
                PurchInvHeader."IRS 1099 Form Box No." := PurchInvHeader."IRS 1099 Code";
                PurchInvHeader.Modify();
                PurchInvLine.SetRange("Document No.", PurchInvHeader."No.");
                if PurchInvLine.FindSet(true) then
                    repeat
                        PurchInvLine."1099 Liable" := PurchInvLine."IRS 1099 Liable";
                        PurchInvLine.Modify();
                    until PurchInvLine.Next() = 0;
            end;
        until PurchInvHeader.Next() = 0;
#pragma warning restore AL0432
    end;

    local procedure TransferPostedPurchCrMemos(PeriodNo: Code[20]; StartingDate: Date; EndingDate: Date)
    var
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        PurchCrMemoLine: Record "Purch. Cr. Memo Line";
    begin
#pragma warning disable AL0432
        PurchCrMemoHdr.SetRange("Posting Date", StartingDate, EndingDate);
        PurchCrMemoHdr.SetFilter("IRS 1099 Code", '<>%1', '');
        PurchCrMemoHdr.SetRange("IRS 1099 Reporting Period", '');
        if not PurchCrMemoHdr.FindSet(true) then
            exit;
        repeat
            if IsOld1099FormBoxTransferable(PurchCrMemoHdr."IRS 1099 Code") then begin
                PurchCrMemoHdr."IRS 1099 Reporting Period" := PeriodNo;
                PurchCrMemoHdr."IRS 1099 Form No." := GetFormNoFromOldFormBox(PurchCrMemoHdr."IRS 1099 Code");
                PurchCrMemoHdr."IRS 1099 Form Box No." := PurchCrMemoHdr."IRS 1099 Code";
                PurchCrMemoHdr.Modify();
                PurchCrMemoLine.SetRange("Document No.", PurchCrMemoHdr."No.");
                if PurchCrMemoLine.FindSet(true) then
                    repeat
                        PurchCrMemoLine."1099 Liable" := PurchCrMemoLine."IRS 1099 Liable";
                        PurchCrMemoLine.Modify();
                    until PurchCrMemoLine.Next() = 0;
            end;
        until PurchCrMemoHdr.Next() = 0;
#pragma warning restore AL0432
    end;

    local procedure TransferVendorLedgerEntries(PeriodNo: Code[20]; StartingDate: Date; EndingDate: Date)
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
    begin
#pragma warning disable AL0432
        VendorLedgerEntry.SetRange("Posting Date", StartingDate, EndingDate);
        VendorLedgerEntry.SetFilter("Document Type", '%1|%2', VendorLedgerEntry."Document Type"::Invoice, VendorLedgerEntry."Document Type"::"Credit Memo");
        VendorLedgerEntry.SetFilter("IRS 1099 Code", '<>%1', '');
        VendorLedgerEntry.SetRange("IRS 1099 Reporting Period", '');
        if not VendorLedgerEntry.FindSet(true) then
            exit;
        repeat
            if IsOld1099FormBoxTransferable(VendorLedgerEntry."IRS 1099 Code") then begin
                VendorLedgerEntry."IRS 1099 Reporting Period" := PeriodNo;
                VendorLedgerEntry."IRS 1099 Form No." := GetFormNoFromOldFormBox(VendorLedgerEntry."IRS 1099 Code");
                VendorLedgerEntry."IRS 1099 Form Box No." := VendorLedgerEntry."IRS 1099 Code";
                VendorLedgerEntry."IRS 1099 Reporting Amount" := VendorLedgerEntry."IRS 1099 Amount";
                VendorLedgerEntry."IRS 1099 Subject For Reporting" := VendorLedgerEntry."IRS 1099 Reporting Amount" <> 0;
                VendorLedgerEntry.Modify();
            end;
        until VendorLedgerEntry.Next() = 0;
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
        if IRS1099FormStatementLine.Insert(true) then;
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
        CreateReportingPeriod(IRSReportingPeriod, ReportingYear);
        exit(true);
    end;

    local procedure CreateReportingPeriod(var IRSReportingPeriod: Record "IRS Reporting Period"; ReportingYear: Integer)
    var
        NewIRSReportingPeriodCreatedLbl: Label 'New IRS Reporting Period created for year %1', Comment = '%1 = Reporting Year';
        CreatedDuringDataTransferMsg: Label 'Created during data transfer';
    begin
        IRSReportingPeriod.Init();
        IRSReportingPeriod."No." := Format(ReportingYear);
        IRSReportingPeriod."Starting Date" := DMY2Date(1, 1, ReportingYear);
        IRSReportingPeriod."Ending Date" := DMY2Date(31, 12, ReportingYear);
        IRSReportingPeriod.Description := CreatedDuringDataTransferMsg;
        IRSReportingPeriod.Insert();
        Telemetry.LogMessage('0000PZF', StrSubstNo(NewIRSReportingPeriodCreatedLbl, ReportingYear), Verbosity::Normal, DataClassification::SystemMetadata);
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