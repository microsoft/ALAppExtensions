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
        IRS1099VendEntryBuffer: Record "IRS 1099 Vend. Entry Buffer";
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
        if Vendor.IsEmpty() then
            error(NoVendorsGivenFilterErr);
        GetAppliedVendorEntries(IRS1099VendEntryBuffer, TempIRS1099Form, IRS1099CalcParameters."Vendor No.", IRSReportingPeriod);
        TransferVengLedgEntryBufferToVendFormBoxBuffer(TempVendFormBoxBuffer, IRS1099VendEntryBuffer, EntryNo, IRS1099CalcParameters."Period No.");
        FinalizeVendFormBoxBuffer(TempVendFormBoxBuffer, EntryNo, IRSReportingPeriod."No.");
    end;

    local procedure GetAppliedVendorEntries(var IRS1099VendEntryBuffer: Record "IRS 1099 Vend. Entry Buffer"; var TempIRS1099Form: Record "IRS 1099 Form" temporary;
                                          VendorNo: Code[20]; IRSReportingPeriod: Record "IRS Reporting Period");
    var
        PmtVendLedgEntry: Record "Vendor Ledger Entry";
    begin
        FilterPaymentVendorLedgerEntries(PmtVendLedgEntry, IRSReportingPeriod);
        if PmtVendLedgEntry.FindSet() then
            repeat
                GetAppliedVendorEntriesFromtPmtEntry(IRS1099VendEntryBuffer, TempIRS1099Form, PmtVendLedgEntry, VendorNo);
            until PmtVendLedgEntry.Next() = 0;
    end;

    local procedure GetAppliedVendorEntriesFromtPmtEntry(var IRS1099VendEntryBuffer: Record "IRS 1099 Vend. Entry Buffer"; var TempIRS1099Form: Record "IRS 1099 Form" temporary; PmtVendLedgEntry: Record "Vendor Ledger Entry"; VendorNo: Code[20])
    var
        PmtDtldVendLedgEntry, InvDtldVendLedgEntry : Record "Detailed Vendor Ledg. Entry";
        TempInteger: Record "Integer" temporary;
        PaymentDiscountEntries: List of [Integer];
    begin
        if (VendorNo <> '') and (PmtVendLedgEntry."Vendor No." <> VendorNo) then
            exit;
        FilterApplicationDetailedVendorLedgerEntries(PmtDtldVendLedgEntry, PmtVendLedgEntry);
        if PmtDtldVendLedgEntry.FindSet() then
            repeat
                FindRelatedApplicationDetailedVendorLedgerEntries(InvDtldVendLedgEntry, PmtVendLedgEntry, PmtDtldVendLedgEntry);
                repeat
                    if TryCacheEntryNo(TempInteger, InvDtldVendLedgEntry."Entry No.") then
                        UpdateTempVendLedgEntryBuffer(
                            IRS1099VendEntryBuffer, TempIRS1099Form, PaymentDiscountEntries, InvDtldVendLedgEntry, PmtVendLedgEntry);
                until InvDtldVendLedgEntry.Next() = 0;
            until PmtDtldVendLedgEntry.Next() = 0;
    end;

    local procedure FilterPaymentVendorLedgerEntries(var VendLedgEntry: Record "Vendor Ledger Entry"; IRSReportingPeriod: Record "IRS Reporting Period")
    begin
        VendLedgEntry.SetCurrentKey("Document Type", "Vendor No.", "Posting Date");
        VendLedgEntry.SetLoadFields("Document Type", "Vendor No.", "Posting Date", "Closed by Entry No.");
        VendLedgEntry.SetFilter("Document Type", '%1|%2', VendLedgEntry."Document Type"::Payment, VendLedgEntry."Document Type"::Refund);
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

    local procedure UpdateTempVendLedgEntryBuffer(var IRS1099VendEntryBuffer: Record "IRS 1099 Vend. Entry Buffer"; var TempIRS1099Form: Record "IRS 1099 Form" temporary; var PaymentDiscountEntries: List of [Integer]; InvDtldVendLedgEntry: Record "Detailed Vendor Ledg. Entry"; PmtVendLedgEntry: Record "Vendor Ledger Entry")
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

        IRS1099VendEntryBuffer."Entry No." := InvVendLedgEntry."Entry No.";
        if IRS1099VendEntryBuffer.Find() then begin
            IRS1099VendEntryBuffer."Amount to Apply" += AmountToApply;
            IRS1099VendEntryBuffer.Modify();
        end else begin
            IRS1099VendEntryBuffer."Vendor No." := InvDtldVendLedgEntry."Vendor No.";
            IRS1099VendEntryBuffer."IRS 1099 Form No." := InvVendLedgEntry."IRS 1099 Form No.";
            IRS1099VendEntryBuffer."IRS 1099 Form Box No." := InvVendLedgEntry."IRS 1099 Form Box No.";
            InvVendLedgEntry.CalcFields(Amount);
            IRS1099VendEntryBuffer.Amount := InvVendLedgEntry.Amount;
            IRS1099VendEntryBuffer."Amount to Apply" := AmountToApply;
            IRS1099VendEntryBuffer."IRS 1099 Reporting Amount" := InvVendLedgEntry."IRS 1099 Reporting Amount";

            if PmtVendLedgEntry."Closed by Entry No." <> 0 then begin
                ClosingVendLedgEntry.Get(InvDtldVendLedgEntry."Vendor Ledger Entry No.");
                if ClosingVendLedgEntry."Closed by Entry No." <> IRS1099VendEntryBuffer."Entry No." then
                    IRS1099VendEntryBuffer."Pmt. Disc. Rcd.(LCY)" := 0;
                if not PaymentDiscountEntries.Contains(ClosingVendLedgEntry."Closed by Entry No.") then begin
                    IRS1099VendEntryBuffer."Amount to Apply" +=
                        GetPaymentDiscount(ClosingVendLedgEntry."Closed by Entry No.");
                    PaymentDiscountEntries.Add(ClosingVendLedgEntry."Closed by Entry No.");
                end;
            end;
            IRS1099VendEntryBuffer.Insert();
        end;
    end;

    local procedure TransferVengLedgEntryBufferToVendFormBoxBuffer(var TempVendFormBoxBuffer: Record "IRS 1099 Vend. Form Box Buffer" temporary; var IRS1099VendEntryBuffer: Record "IRS 1099 Vend. Entry Buffer"; var EntryNo: Integer; PeriodNo: Code[20])
    begin
        if not IRS1099VendEntryBuffer.FindSet() then
            exit;
        repeat
            if not FindVendFormBoxBuffer(
                TempVendFormBoxBuffer, PeriodNo, IRS1099VendEntryBuffer."Vendor No.", IRS1099VendEntryBuffer."IRS 1099 Form No.",
                IRS1099VendEntryBuffer."IRS 1099 Form Box No.")
            then
                InsertVendFormBoxBufferFromVendLedgEntry(TempVendFormBoxBuffer, EntryNo, IRS1099VendEntryBuffer, PeriodNo);
            TempVendFormBoxBuffer.Amount +=
                -IRS1099VendEntryBuffer."Amount to Apply" * IRS1099VendEntryBuffer."IRS 1099 Reporting Amount" / IRS1099VendEntryBuffer.Amount;
            TempVendFormBoxBuffer.Modify();
            if IRSFormsSetup."Collect Details For Line" then
                InsertVendEntryIntoBuffer(TempVendFormBoxBuffer, EntryNo, IRS1099VendEntryBuffer."Entry No.");
        until IRS1099VendEntryBuffer.Next() = 0;
    end;

    local procedure AddAdjustmentsToVendFormBoxBuffer(var TempVendFormBoxBuffer: Record "IRS 1099 Vend. Form Box Buffer" temporary; var EntryNo: Integer; PeriodNo: Code[20]): Boolean
    var
        IRS1099VendorFormBoxAdj: Record "IRS 1099 Vendor Form Box Adj.";
    begin
        IRS1099VendorFormBoxAdj.SetRange("Period No.", PeriodNo);
        if not IRS1099VendorFormBoxAdj.FindSet() then
            exit(false);
        TempVendFormBoxBuffer.Reset();
        TempVendFormBoxBuffer.SetRange("Period No.", PeriodNo);
        repeat
            TempVendFormBoxBuffer.SetRange("Vendor No.", IRS1099VendorFormBoxAdj."Vendor No.");
            TempVendFormBoxBuffer.SetRange("Form No.", IRS1099VendorFormBoxAdj."Form No.");
            TempVendFormBoxBuffer.SetRange("Form Box No.", IRS1099VendorFormBoxAdj."Form Box No.");
            if not TempVendFormBoxBuffer.FindFirst() then begin
                TempVendFormBoxBuffer.Init();
                EntryNo += 1;
                TempVendFormBoxBuffer."Entry No." := EntryNo;
                TempVendFormBoxBuffer."Period No." := PeriodNo;
                TempVendFormBoxBuffer."Vendor No." := IRS1099VendorFormBoxAdj."Vendor No.";
                TempVendFormBoxBuffer."Form No." := IRS1099VendorFormBoxAdj."Form No.";
                TempVendFormBoxBuffer."Form Box No." := IRS1099VendorFormBoxAdj."Form Box No.";
                TempVendFormBoxBuffer.Insert();
            end;
        until IRS1099VendorFormBoxAdj.Next() = 0;
        exit(true);
    end;

    local procedure FinalizeVendFormBoxBuffer(var TempVendFormBoxBuffer: Record "IRS 1099 Vend. Form Box Buffer" temporary; var EntryNo: Integer; PeriodNo: Code[20])
    begin
        AddAdjustmentsToVendFormBoxBuffer(TempVendFormBoxBuffer, EntryNo, PeriodNo);
        TempVendFormBoxBuffer.Reset();
        TempVendFormBoxBuffer.SetRange("Buffer Type", TempVendFormBoxBuffer."Buffer Type"::Amount);
        TempVendFormBoxBuffer.SetAutoCalcFields("Adjustment Amount", "Minimum Reportable Amount");
        if not TempVendFormBoxBuffer.FindSet() then
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

    local procedure InsertVendFormBoxBufferFromVendLedgEntry(var VendFormBoxBuffer: Record "IRS 1099 Vend. Form Box Buffer" temporary; var EntryNo: Integer; IRS1099VendEntryBuffer: Record "IRS 1099 Vend. Entry Buffer"; PeriodNo: Code[20])
    begin
        VendFormBoxBuffer.Init();
        EntryNo += 1;
        VendFormBoxBuffer."Entry No." := EntryNo;
        VendFormBoxBuffer."Period No." := PeriodNo;
        VendFormBoxBuffer."Vendor No." := IRS1099VendEntryBuffer."Vendor No.";
        VendFormBoxBuffer."Form No." := IRS1099VendEntryBuffer."IRS 1099 Form No.";
        VendFormBoxBuffer."Form Box No." := IRS1099VendEntryBuffer."IRS 1099 Form Box No.";
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
