#if not CLEAN25
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
using System.Reflection;

codeunit 10040 "IRS 1099 Transfer From BaseApp"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions =
        tabledata "Purch. Inv. Header" = rm,
        tabledata "Purch. Inv. Line" = rm,
        tabledata "Purch. Cr. Memo Hdr." = rm,
        tabledata "Purch. Cr. Memo Line" = rm,
        tabledata "Vendor Ledger Entry" = rm;

    var
        Telemetry: Codeunit Telemetry;
        UpgradeDataDict: Dictionary of [Integer, Integer];
        CreatedDuringDataTransferMsg: Label 'Created during data transfer';

    trigger OnRun()
    var
        IRSFormsSetup: Record "IRS Forms Setup";
        IRSReportingPeriod: Record "IRS Reporting Period";
    begin
        IRSFormsSetup.Get();
        IRSFormsSetup.TestField("Init Reporting Year");
        CreateReportingPeriod(IRSReportingPeriod, IRSFormsSetup."Init Reporting Year");
        TransferIRS1099Setup(IRSReportingPeriod, IRSFormsSetup."Init Reporting Year");
        TransferIRS1099Data(IRSReportingPeriod);

        Clear(IRSFormsSetup."Data Transfer Task ID");
        Clear(IRSFormsSetup."Task Start Date/Time");
        IRSFormsSetup."Data Transfer Completed" := true;
        IRSFormsSetup."Data Transfer Error Message" := '';
        IRSFormsSetup.Modify();
    end;

    procedure TransferIRS1099Setup(IRSReportingPeriod: Record "IRS Reporting Period"; ReportingYear: Integer)
    var
        IRSFormsData: Codeunit "IRS Forms Data";
    begin
        Telemetry.LogMessage('0000PZA', 'IRS 1099 setup transfer started', Verbosity::Normal, DataClassification::SystemMetadata);
        TransferVendorSetup(IRSReportingPeriod."No.");
        IRSFormsData.AddFormInstructionLines(IRSReportingPeriod."No.");
        Telemetry.LogMessage('0000PZB', 'IRS 1099 setup transfer completed', Verbosity::Normal, DataClassification::SystemMetadata);
    end;

    procedure TransferIRS1099Data(IRSReportingPeriod: Record "IRS Reporting Period")
    var
        NoDataWasTransferredLbl: Label 'No data was transferred during the upgrade.';
    begin
        Telemetry.LogMessage('0000PZC', 'IRS 1099 data transfer started', Verbosity::Normal, DataClassification::SystemMetadata);
        TransferPurchaseDocuments(IRSReportingPeriod."No.", IRSReportingPeriod."Starting Date", IRSReportingPeriod."Ending Date");
        TransferPostedPurchInvoices(IRSReportingPeriod."No.", IRSReportingPeriod."Starting Date", IRSReportingPeriod."Ending Date");
        TransferPostedPurchCrMemos(IRSReportingPeriod."No.", IRSReportingPeriod."Starting Date", IRSReportingPeriod."Ending Date");
        TransferVendorLedgerEntries(IRSReportingPeriod."No.", IRSReportingPeriod."Starting Date", IRSReportingPeriod."Ending Date");
        Telemetry.LogMessage('0000PZD', 'IRS 1099 data transfer completed', Verbosity::Normal, DataClassification::SystemMetadata);
        if not GuiAllowed() then
            exit;
        if UpgradeDataDict.Count() = 0 then begin
            Telemetry.LogMessage('0000PZE', 'No data was transferred during the upgrade', Verbosity::Normal, DataClassification::SystemMetadata);
            Message(NoDataWasTransferredLbl);
            exit;
        end;
        Message(UpgradedDataDictToMessage());
    end;

    procedure CreateReportingPeriod(var IRSReportingPeriod: Record "IRS Reporting Period"; ReportingYear: Integer)
    var
        NewIRSReportingPeriodCreatedLbl: Label 'New IRS Reporting Period created for year %1', Comment = '%1 = Reporting Year';
    begin
        IRSReportingPeriod.Init();
        IRSReportingPeriod."No." := Format(ReportingYear);
        IRSReportingPeriod."Starting Date" := DMY2Date(1, 1, ReportingYear);
        IRSReportingPeriod."Ending Date" := DMY2Date(31, 12, ReportingYear);
        IRSReportingPeriod.Description := CreatedDuringDataTransferMsg;
        IRSReportingPeriod.Insert();
        Telemetry.LogMessage('0000PZF', StrSubstNo(NewIRSReportingPeriodCreatedLbl, ReportingYear), Verbosity::Normal, DataClassification::SystemMetadata);
    end;

    procedure TransferVendorSetup(PeriodNo: Code[20])
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
                IRS1099VendorFormBoxSetup.Insert();
            end;
            Vendor."FATCA Requirement" := Vendor."FATCA filing requirement";
            Vendor.Modify();
            IncValueInUpgradedDataDict(Database::Vendor);
        until Vendor.Next() = 0;
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
                IncValueInUpgradedDataDict(Database::"Purchase Header");
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
                IncValueInUpgradedDataDict(Database::"Purch. Inv. Header");
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
                IncValueInUpgradedDataDict(Database::"Purch. Cr. Memo Hdr.");
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
                IncValueInUpgradedDataDict(Database::"Vendor Ledger Entry");
            end;
        until VendorLedgerEntry.Next() = 0;
#pragma warning restore AL0432
    end;


    local procedure IsOld1099FormBoxTransferable(OldFormBox: Text): Boolean
    begin
        exit((OldFormBox.Contains('MISC') or OldFormBox.Contains('DIV') or OldFormBox.Contains('INT') or OldFormBox.Contains('NEC')) and OldFormBox.Contains('-'));
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

    local procedure IncValueInUpgradedDataDict(TableId: Integer)
    begin
        if not UpgradeDataDict.ContainsKey(TableId) then
            UpgradeDataDict.Add(TableId, 0);
        UpgradeDataDict.Set(TableId, UpgradeDataDict.Get(TableId) + 1);
    end;

    local procedure UpgradedDataDictToMessage() Message: Text
    var
        AllObjWithCaption: Record AllObjWithCaption;
        TableId: Integer;
        Count: Integer;
        StatisticsOfTransferreddDataLbl: Label 'Statistics of transferred data';
    begin
        Message := StatisticsOfTransferreddDataLbl + '\';
        foreach TableId in UpgradeDataDict.Keys() do begin
            Count := UpgradeDataDict.Get(TableId);
            Message += '\';
            AllObjWithCaption.Get(AllObjWithCaption."Object Type"::Table, TableId);
            Message += StrSubstNo('%1: %2', AllObjWithCaption."Object Caption", Count);
        end;
    end;
}
#endif