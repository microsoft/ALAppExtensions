// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Purchases.Payables;
using Microsoft.Purchases.Vendor;
using System.Utilities;

codeunit 10041 "IRS 1099 Form Box Calc. Impl." implements "IRS 1099 Form Box Calc."
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions = TableData "Vendor Ledger Entry" = r;

    var
        IRSFormsSetup: Record "IRS Forms Setup";
        DateIsNotSpecifiedErr: Label '%1 of the IRS reporting period is not specified', Comment = '%1 = starting or ending date';
        No1099FormsGivenFilterErr: Label 'No 1099 forms are found given the input filter';
        NoVendorsGivenFilterErr: Label 'No vendors are found given the input filter';

    procedure GetVendorFormBoxAmount(var TempVendFormBoxBuffer: Record "IRS 1099 Vend. Form Box Buffer" temporary; IRS1099CalcParameters: Record "IRS 1099 Calc. Params")
    var
        IRSReportingPeriod: Record "IRS Reporting Period";
        Vendor: Record Vendor;
        IRS1099Form: Record "IRS 1099 Form";
        TempIRS1099Form: Record "IRS 1099 Form" temporary;
        TempAppliedVendLedgEntry: Record "Vendor Ledger Entry" temporary;
        EntryNo: Integer;
    begin
        if IRS1099CalcParameters."Period No." = '' then
            exit;
        if not IRSReportingPeriod.Get(IRS1099CalcParameters."Period No.") then
            exit;

        if IRSReportingPeriod."Starting Date" = 0D then
            error(DateIsNotSpecifiedErr, IRSReportingPeriod.FieldCaption("Starting Date"));
        if IRSReportingPeriod."Ending Date" = 0D then
            error(DateIsNotSpecifiedErr, IRSReportingPeriod.FieldCaption("Ending Date"));

        IRSFormsSetup.Get();
        IRS1099Form.SetRange("Period No.", IRS1099CalcParameters."Period No.");
        if IRS1099CalcParameters."Form No." <> '' then
            IRS1099Form.SetRange("No.", IRS1099CalcParameters."Form No.");
        if not IRS1099Form.FindSet() then
            error(No1099FormsGivenFilterErr);
        repeat
            TempIRS1099Form := IRS1099Form;
            TempIRS1099Form.Insert();
        until IRS1099Form.Next() = 0;

        if IRS1099CalcParameters."Vendor No." <> '' then
            Vendor.SetRange("No.", IRS1099CalcParameters."Vendor No.");
        if not Vendor.Findset() then
            error(NoVendorsGivenFilterErr);
        repeat
            TempAppliedVendLedgEntry.Reset();
            TempAppliedVendLedgEntry.DeleteAll();
            GetAppliedVendorEntries(TempAppliedVendLedgEntry, TempIRS1099Form, Vendor."No.", IRSReportingPeriod);
            TransferVengLedgEntryBufferToVendFormBoxBuffer(TempVendFormBoxBuffer, TempAppliedVendLedgEntry, EntryNo, IRS1099CalcParameters."Period No.");
            FinalizeVendFormBoxBuffer(TempVendFormBoxBuffer, EntryNo, IRSReportingPeriod."No.", Vendor."No.");
        until Vendor.Next() = 0;
    end;

    local procedure GetAppliedVendorEntries(var TempAppliedVendLedgEntry: Record "Vendor Ledger Entry" temporary; var TempIRS1099Form: Record "IRS 1099 Form" temporary;
                                          VendorNo: Code[20]; IRSReportingPeriod: Record "IRS Reporting Period");
    var
        PmtDtldVendLedgEntry: Record "Detailed Vendor Ledg. Entry";
        InvDtldVendLedgEntry: Record "Detailed Vendor Ledg. Entry";
        PmtVendLedgEntry: Record "Vendor Ledger Entry";
        TempInteger: Record "Integer" temporary;
    begin
        TempAppliedVendLedgEntry.Reset();
        TempAppliedVendLedgEntry.DeleteAll();

        FilterPaymentVendorLedgerEntries(PmtVendLedgEntry, VendorNo, IRSReportingPeriod);
        if PmtVendLedgEntry.FindSet() then
            repeat
                FilterApplicationDetailedVendorLedgerEntries(PmtDtldVendLedgEntry, PmtVendLedgEntry);
                if PmtDtldVendLedgEntry.FindSet() then
                    repeat
                        FindRelatedApplicationDetailedVendorLedgerEntries(InvDtldVendLedgEntry, PmtVendLedgEntry, PmtDtldVendLedgEntry);
                        repeat
                            if TryCacheEntryNo(TempInteger, InvDtldVendLedgEntry."Entry No.") then
                                UpdateTempVendLedgEntryBuffer(
                                    TempAppliedVendLedgEntry, TempIRS1099Form, InvDtldVendLedgEntry, PmtVendLedgEntry);
                        until InvDtldVendLedgEntry.Next() = 0;
                    until PmtDtldVendLedgEntry.Next() = 0;
            until PmtVendLedgEntry.Next() = 0;
    end;

    local procedure FilterPaymentVendorLedgerEntries(var VendLedgEntry: Record "Vendor Ledger Entry"; VendorNo: Code[20]; IRSReportingPeriod: Record "IRS Reporting Period")
    begin
        VendLedgEntry.SetCurrentKey("Document Type", "Vendor No.", "Posting Date");
        VendLedgEntry.SetLoadFields("Document Type", "Vendor No.", "Posting Date", "Closed by Entry No.");
        VendLedgEntry.SetFilter("Document Type", '%1|%2', VendLedgEntry."Document Type"::Payment, VendLedgEntry."Document Type"::Refund);
        VendLedgEntry.SetRange("Vendor No.", VendorNo);
        VendLedgEntry.SetRange("Posting Date", IRSReportingPeriod."Starting Date", IRSReportingPeriod."Ending Date");
    end;

    local procedure FilterApplicationDetailedVendorLedgerEntries(var DtldVendLedgEntry: Record "Detailed Vendor Ledg. Entry"; VendLedgEntry: Record "Vendor Ledger Entry")
    begin
        DtldVendLedgEntry.SetCurrentKey("Vendor Ledger Entry No.");
        DtldVendLedgEntry.SetLoadFields("Vendor Ledger Entry No.", "Entry Type", Unapplied, "Transaction No.", "Application No.");
        DtldVendLedgEntry.SetRange("Vendor Ledger Entry No.", VendLedgEntry."Entry No.");
        DtldVendLedgEntry.SetRange("Entry Type", DtldVendLedgEntry."Entry Type"::Application);
        DtldVendLedgEntry.SetRange(Unapplied, false);
    end;

    local procedure FindRelatedApplicationDetailedVendorLedgerEntries(var DtldVendLedgEntry: Record "Detailed Vendor Ledg. Entry"; VendLedgEntry: Record "Vendor Ledger Entry"; RelatedDtldVendLedgEntry: Record "Detailed Vendor Ledg. Entry")
    begin
        DtldVendLedgEntry.SetCurrentKey("Vendor Ledger Entry No.", "Entry Type");
        DtldVendLedgEntry.SetLoadFields("Vendor Ledger Entry No.", "Entry Type", "Vendor No.", "Transaction No.", "Application No.", Amount, "Amount (LCY)");
        DtldVendLedgEntry.SetFilter("Vendor Ledger Entry No.", '<>%1', VendLedgEntry."Entry No.");
        DtldVendLedgEntry.SetRange("Entry Type", DtldVendLedgEntry."Entry Type"::Application);
        DtldVendLedgEntry.SetRange("Vendor No.", VendLedgEntry."Vendor No.");
        DtldVendLedgEntry.SetRange("Transaction No.", RelatedDtldVendLedgEntry."Transaction No.");
        DtldVendLedgEntry.SetRange("Application No.", RelatedDtldVendLedgEntry."Application No.");
        DtldVendLedgEntry.FindSet();
    end;

    local procedure UpdateTempVendLedgEntryBuffer(var TempAppliedVendLedgEntry: Record "Vendor Ledger Entry" temporary; var TempIRS1099Form: Record "IRS 1099 Form" temporary; InvDtldVendLedgEntry: Record "Detailed Vendor Ledg. Entry"; PmtVendLedgEntry: Record "Vendor Ledger Entry")
    var
        InvVendLedgEntry: Record "Vendor Ledger Entry";
        ClosingVendLedgEntry: Record "Vendor Ledger Entry";
        AmountToApply: Decimal;
    begin
        AmountToApply := -InvDtldVendLedgEntry."Amount (LCY)";
        InvVendLedgEntry.Get(InvDtldVendLedgEntry."Vendor Ledger Entry No.");
        if not (InvVendLedgEntry."Document Type" in [InvVendLedgEntry."Document Type"::Invoice, InvVendLedgEntry."Document Type"::"Credit Memo"]) or
            (InvVendLedgEntry."IRS 1099 Form No." = '') or
            (InvVendLedgEntry."IRS 1099 Reporting Amount" = 0) or
            (not InvVendLedgEntry."IRS 1099 Subject For Reporting")
        then
            exit;

        TempIRS1099Form.SetRange("No.", InvVendLedgEntry."IRS 1099 Form No.");
        if not TempIRS1099Form.FindFirst() then
            exit;

        TempAppliedVendLedgEntry := InvVendLedgEntry;
        if TempAppliedVendLedgEntry.Find() then begin
            TempAppliedVendLedgEntry."Amount to Apply" += AmountToApply;
            TempAppliedVendLedgEntry.Modify();
        end else begin
            TempAppliedVendLedgEntry := InvVendLedgEntry;
            TempAppliedVendLedgEntry."Amount to Apply" := AmountToApply;

            if PmtVendLedgEntry."Closed by Entry No." <> 0 then begin
                ClosingVendLedgEntry.Get(InvDtldVendLedgEntry."Vendor Ledger Entry No.");
                if ClosingVendLedgEntry."Closed by Entry No." <> TempAppliedVendLedgEntry."Entry No." then
                    TempAppliedVendLedgEntry."Pmt. Disc. Rcd.(LCY)" := 0;
                TempAppliedVendLedgEntry."Amount to Apply" +=
                    GetPaymentDiscount(ClosingVendLedgEntry."Closed by Entry No.");
            end;
            TempAppliedVendLedgEntry.Insert();
        end;
    end;

    local procedure TransferVengLedgEntryBufferToVendFormBoxBuffer(var TempVendFormBoxBuffer: Record "IRS 1099 Vend. Form Box Buffer" temporary; var TempAppliedVendLedgEntry: Record "Vendor Ledger Entry" temporary; var EntryNo: Integer; PeriodNo: Code[20])
    begin
        if not TempAppliedVendLedgEntry.FindSet() then
            exit;
        repeat
            if not FindVendFormBoxBuffer(
                TempVendFormBoxBuffer, PeriodNo, TempAppliedVendLedgEntry."Vendor No.", TempAppliedVendLedgEntry."IRS 1099 Form No.",
                TempAppliedVendLedgEntry."IRS 1099 Form Box No.")
            then
                InsertVendFormBoxBufferFromVendLedgEntry(TempVendFormBoxBuffer, EntryNo, TempAppliedVendLedgEntry, PeriodNo);
            TempAppliedVendLedgEntry.CalcFields(Amount);
            TempVendFormBoxBuffer.Amount +=
                -TempAppliedVendLedgEntry."Amount to Apply" * TempAppliedVendLedgEntry."IRS 1099 Reporting Amount" / TempAppliedVendLedgEntry.Amount;
            TempVendFormBoxBuffer.Modify();
            if IRSFormsSetup."Collect Details For Line" then
                InsertVendEntryIntoBuffer(TempVendFormBoxBuffer, EntryNo, TempAppliedVendLedgEntry."Entry No.");
        until TempAppliedVendLedgEntry.Next() = 0;
    end;

    local procedure AddAdjustmentsToVendFormBoxBuffer(var TempVendFormBoxBuffer: Record "IRS 1099 Vend. Form Box Buffer" temporary; var EntryNo: Integer; PeriodNo: Code[20]; VendorNo: Code[20]): Boolean
    var
        IRS1099VendorFormBoxAdj: Record "IRS 1099 Vendor Form Box Adj.";
    begin
        IRS1099VendorFormBoxAdj.SetRange("Period No.", PeriodNo);
        IRS1099VendorFormBoxAdj.SetRange("Vendor No.", VendorNo);
        if not IRS1099VendorFormBoxAdj.FindSet() then
            exit(false);
        repeat
            TempVendFormBoxBuffer.Init();
            EntryNo += 1;
            TempVendFormBoxBuffer."Entry No." := EntryNo;
            TempVendFormBoxBuffer."Period No." := PeriodNo;
            TempVendFormBoxBuffer."Vendor No." := IRS1099VendorFormBoxAdj."Vendor No.";
            TempVendFormBoxBuffer."Form No." := IRS1099VendorFormBoxAdj."Form No.";
            TempVendFormBoxBuffer."Form Box No." := IRS1099VendorFormBoxAdj."Form Box No.";
            TempVendFormBoxBuffer.Insert();
        until IRS1099VendorFormBoxAdj.Next() = 0;
        exit(true);
    end;

    local procedure FinalizeVendFormBoxBuffer(var TempVendFormBoxBuffer: Record "IRS 1099 Vend. Form Box Buffer" temporary; var EntryNo: Integer; PeriodNo: Code[20]; VendorNo: Code[20])
    begin
        TempVendFormBoxBuffer.Reset();
        TempVendFormBoxBuffer.SetRange("Vendor No.", VendorNo);
        TempVendFormBoxBuffer.SetRange("Buffer Type", TempVendFormBoxBuffer."Buffer Type"::Amount);
        TempVendFormBoxBuffer.SetAutoCalcFields("Adjustment Amount", "Minimum Reportable Amount");
        if not TempVendFormBoxBuffer.FindSet() then
            if AddAdjustmentsToVendFormBoxBuffer(TempVendFormBoxBuffer, EntryNo, PeriodNo, VendorNo) then
                TempVendFormBoxBuffer.FindSet()
            else
                exit;

        repeat
            TempVendFormBoxBuffer."Reporting Amount" := TempVendFormBoxBuffer.Amount + TempVendFormBoxBuffer."Adjustment Amount";
            TempVendFormBoxBuffer."Include In 1099" := TempVendFormBoxBuffer."Reporting Amount" >= TempVendFormBoxBuffer."Minimum Reportable Amount";
            TempVendFormBoxBuffer.Modify();
        until TempVendFormBoxBuffer.Next() = 0;
    end;

    local procedure FindVendFormBoxBuffer(var TempVendFormBoxBuffer: Record "IRS 1099 Vend. Form Box Buffer" temporary; PeriodNo: Code[20]; VendorNo: Code[20]; FormNo: Code[20]; FormBoxNo: Code[20]): Boolean
    begin
        TempVendFormBoxBuffer.SetRange("Period No.", PeriodNo);
        TempVendFormBoxBuffer.SetRange("Vendor No.", VendorNo);
        TempVendFormBoxBuffer.SetRange("Form No.", FormNo);
        TempVendFormBoxBuffer.SetRange("Form Box No.", FormBoxNo);
        exit(TempVendFormBoxBuffer.FindFirst());
    end;

    local procedure InsertVendFormBoxBufferFromVendLedgEntry(var VendFormBoxBuffer: Record "IRS 1099 Vend. Form Box Buffer" temporary; var EntryNo: Integer; VendLedgEntry: Record "Vendor Ledger Entry"; PeriodNo: Code[20])
    begin
        VendFormBoxBuffer.Init();
        EntryNo += 1;
        VendFormBoxBuffer."Entry No." := EntryNo;
        VendFormBoxBuffer."Period No." := PeriodNo;
        VendFormBoxBuffer."Vendor No." := VendLedgEntry."Vendor No.";
        VendFormBoxBuffer."Form No." := VendLedgEntry."IRS 1099 Form No.";
        VendFormBoxBuffer."Form Box No." := VendLedgEntry."IRS 1099 Form Box No.";
        VendFormBoxBuffer.CalcFields("Adjustment Amount");
        VendFormBoxBuffer."Reporting Amount" += VendFormBoxBuffer."Adjustment Amount";
        VendFormBoxBuffer.Insert();
    end;

    local procedure TryCacheEntryNo(var TempInteger: Record "Integer" temporary; EntryNo: Integer): Boolean
    begin
        TempInteger.Number := EntryNo;
        exit(TempInteger.Insert());
    end;

    local procedure GetPaymentDiscount(ClosingVendLedgEntryNo: Integer): Decimal
    var
        DtldVendLedgEntry: Record "Detailed Vendor Ledg. Entry";
    begin
        DtldVendLedgEntry.SetCurrentKey("Vendor Ledger Entry No.", "Entry Type", "Posting Date");
        DtldVendLedgEntry.SetLoadFields("Vendor Ledger Entry No.", "Entry Type", Unapplied, Amount, "Amount (LCY)");
        DtldVendLedgEntry.SetRange("Vendor Ledger Entry No.", ClosingVendLedgEntryNo);
        DtldVendLedgEntry.SetRange("Entry Type", DtldVendLedgEntry."Entry Type"::"Payment Discount");
        DtldVendLedgEntry.SetRange(Unapplied, false);
        if DtldVendLedgEntry.FindFirst() then
            exit(DtldVendLedgEntry."Amount (LCY)");
    end;

    local procedure InsertVendEntryIntoBuffer(var TempVendFormBoxBuffer: Record "IRS 1099 Vend. Form Box Buffer" temporary; var EntryNo: Integer; VendLedgEntryNo: Integer)
    var
        ParentEntryNo: Integer;
    begin
        ParentEntryNo := TempVendFormBoxBuffer."Entry No.";
        EntryNo += 1;
        TempVendFormBoxBuffer.Init();
        TempVendFormBoxBuffer."Entry No." := EntryNo;
        TempVendFormBoxBuffer."Parent Entry No." := ParentEntryNo;
        TempVendFormBoxBuffer."Buffer Type" := TempVendFormBoxBuffer."Buffer Type"::"Ledger Entry";
        TempVendFormBoxBuffer."Vendor Ledger Entry No." := VendLedgEntryNo;
        TempVendFormBoxBuffer.Insert();
    end;
}
