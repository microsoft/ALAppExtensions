#if not CLEAN25
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Purchases.Document;
using Microsoft.Purchases.Payables;
using Microsoft.Purchases.Vendor;

codeunit 10040 "IRS 1099 Transfer From BaseApp"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        StatementLineFilterExpressionTxt: Label 'Form Box No.: %1', Comment = '%1 = Form Box No.';
        CreatedDuringDataTransferMsg: Label 'Created during data transfer';

    trigger OnRun()
    var
        IRSFormsSetup: Record "IRS Forms Setup";
        IRSReportingPeriod: Record "IRS Reporting Period";
        IRSFormsData: Codeunit "IRS Forms Data";
    begin
        IRSFormsSetup.Get();
        IRSFormsSetup.TestField("Init Reporting Year");
        CreateReportingPeriod(IRSReportingPeriod, IRSFormsSetup."Init Reporting Year");
        TransferFormBoxes(IRSReportingPeriod."No.");
        TransferVendorSetup(IRSReportingPeriod."No.");
        TransferAdjustments(IRSReportingPeriod."No.", IRSFormsSetup."Init Reporting Year");
        TransferPurchaseDocuments(IRSReportingPeriod."No.", IRSReportingPeriod."Starting Date", IRSReportingPeriod."Ending Date");
        TransferVendorLedgerEntries(IRSReportingPeriod."No.", IRSReportingPeriod."Starting Date", IRSReportingPeriod."Ending Date");
        IRSFormsData.AddFormInstructionLines(IRSReportingPeriod."No.");

        Clear(IRSFormsSetup."Data Transfer Task ID");
        Clear(IRSFormsSetup."Task Start Date/Time");
        IRSFormsSetup."Data Transfer Completed" := true;
        IRSFormsSetup.Modify();
    end;

    local procedure CreateReportingPeriod(var IRSReportingPeriod: Record "IRS Reporting Period"; ReportingYear: Integer)
    begin
        IRSReportingPeriod.Init();
        IRSReportingPeriod."No." := Format(ReportingYear);
        IRSReportingPeriod."Starting Date" := DMY2Date(1, 1, ReportingYear);
        IRSReportingPeriod."Ending Date" := DMY2Date(31, 12, ReportingYear);
        IRSReportingPeriod.Description := CreatedDuringDataTransferMsg;
        IRSReportingPeriod.Insert();
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
                IRS1099VendorFormBoxSetup.Insert();
            end;
            Vendor."FATCA Requirement" := Vendor."FATCA filing requirement";
            Vendor.Modify();
        until Vendor.Next() = 0;
#pragma warning restore AL0432
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

    local procedure TransferPurchaseDocuments(PeriodNo: Code[20]; StartingDate: Date; EndingDate: Date)
    var
        PurchHeader: Record "Purchase Header";
    begin
#pragma warning disable AL0432
        PurchHeader.SetFilter(
            "Document Type", '%1|%2|%3|%4', PurchHeader."Document Type"::Invoice, PurchHeader."Document Type"::"Credit Memo", PurchHeader."Document Type"::Order, PurchHeader."Document Type"::"Return Order");
        PurchHeader.SetRange("Posting Date", StartingDate, EndingDate);
        PurchHeader.SetFilter("IRS 1099 Code", '<>%1', '');
        if not PurchHeader.FindSet(true) then
            exit;
        repeat
            if IsOld1099FormBoxTransferable(PurchHeader."IRS 1099 Code") then begin
                PurchHeader."IRS 1099 Reporting Period" := PeriodNo;
                PurchHeader."IRS 1099 Form No." := GetFormNoFromOldFormBox(PurchHeader."IRS 1099 Code");
                PurchHeader."IRS 1099 Form Box No." := PurchHeader."IRS 1099 Code";
                PurchHeader.Modify();
            end;
        until PurchHeader.Next() = 0;
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
        if not VendorLedgerEntry.FindSet(true) then
            exit;
        repeat
            if IsOld1099FormBoxTransferable(VendorLedgerEntry."IRS 1099 Code") then begin
                VendorLedgerEntry."IRS 1099 Reporting Period" := PeriodNo;
                VendorLedgerEntry."IRS 1099 Form No." := GetFormNoFromOldFormBox(VendorLedgerEntry."IRS 1099 Code");
                VendorLedgerEntry."IRS 1099 Form Box No." := VendorLedgerEntry."IRS 1099 Code";
                VendorLedgerEntry.CalcFields(Amount);
                if VendorLedgerEntry."Document Type" = VendorLedgerEntry."Document Type"::Invoice then
                    VendorLedgerEntry."IRS 1099 Reporting Amount" := VendorLedgerEntry.Amount
                else
                    VendorLedgerEntry."IRS 1099 Reporting Amount" := -VendorLedgerEntry.Amount;
                VendorLedgerEntry."IRS 1099 Subject For Reporting" := VendorLedgerEntry."IRS 1099 Reporting Amount" <> 0;
                VendorLedgerEntry.Modify();
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

    local procedure AddFormStatementLine(PeriodNo: Code[20]; FormNo: Code[20]; FormBoxNo: Code[20]; StatementLineNo: Integer; Description: Text)
    var
        IRS1099FormStatementLine: Record "IRS 1099 Form Statement Line";
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
}
#endif