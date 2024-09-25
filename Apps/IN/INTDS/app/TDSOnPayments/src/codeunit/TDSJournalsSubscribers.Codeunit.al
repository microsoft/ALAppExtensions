// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TDS.TDSOnPayments;

using Microsoft.Bank.BankAccount;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.Payables;
using Microsoft.Purchases.Vendor;
using Microsoft.Purchases.Posting;
using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.TaxBase;
using Microsoft.Finance.TDS.TDSBase;

codeunit 18767 "TDS Journals Subscribers"
{
    var
        SectionErr: Label 'Section Code on Document No. %1 should be %2', Comment = '%1 = Document No.,%2 = Section Code';
        TDSSectionErr: Label '%1 does not exist in table %2.', Comment = '%1= TDS Section Code,%2= TDS Section Table Name';
        WorkTaxNatureofDeductionErr: Label '%1 does not exist in table %2.', Comment = '%1= Work Tax Nature of Deduction,%2= TDS Section Table Name';

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterValidateEvent', 'Account No.', false, false)]
    local procedure AssignTDSSectionCodeGenJournalLine(var Rec: Record "Gen. Journal Line")
    var
        AllowedSections: Record "Allowed Sections";
    begin
        if (Rec."Document Type" in [Rec."Document Type"::Invoice, Rec."Document Type"::Payment]) and
            (Rec."Account Type" = Rec."Account Type"::Vendor) and
            (Rec."Recurring Method" = Rec."Recurring Method"::" ")
        then begin
            AllowedSections.Reset();
            AllowedSections.SetRange("Vendor No", Rec."Account No.");
            AllowedSections.SetRange("Default Section", true);
            if AllowedSections.FindFirst() then begin
                Rec.Validate("TDS Section Code", AllowedSections."TDS Section");
                Rec."Nature of Remittance" := AllowedSections."Nature of Remittance";
                Rec."Act Applicable" := AllowedSections."Act Applicable";
            end else begin
                Rec."TDS Section Code" := '';
                Rec."Nature of Remittance" := '';
                Rec."Act Applicable" := '';
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterValidateEvent', 'TDS Section Code', false, false)]
    local procedure OnAfterValidateTDSSectionCodeGenJournalLine(var Rec: Record "Gen. Journal Line")
    var
        TDSSection: Record "TDS Section";
    begin
        if Rec."TDS Section Code" = '' then
            exit;

        if not TDSSection.Get(Rec."TDS Section Code") then
            Error(TDSSectionErr, Rec."TDS Section Code", TDSSection.TableCaption());
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterValidateEvent', 'Work Tax Nature Of Deduction', false, false)]
    local procedure OnAfterValidateWorkTaxNatureofDeductionGenJournalLine(var Rec: Record "Gen. Journal Line")
    var
        TDSSection: Record "TDS Section";
    begin
        if Rec."Work Tax Nature Of Deduction" = '' then
            exit;

        if not TDSSection.Get(Rec."Work Tax Nature Of Deduction") then
            Error(WorkTaxNatureofDeductionErr, Rec."Work Tax Nature Of Deduction", TDSSection.TableCaption());
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Tax Base Subscribers", 'OnBeforeCallingTaxEngineFromGenJnlLine', '', false, false)]
    local procedure OnBeforeCallingTaxEngineFromGenJnlLine(var GenJnlLine: Record "Gen. Journal Line")
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
    begin
        VendorLedgerEntry.SetLoadFields("Applies-to ID", Prepayment);
        VendorLedgerEntry.SetRange("Applies-to ID", GenJnlLine."Applies-to ID");
        VendorLedgerEntry.SetRange(Prepayment, true);
        if not VendorLedgerEntry.IsEmpty() then
            exit;

        ValidateGenJnlLine(GenJnlLine);
    end;

    local procedure ValidateGenJnlLine(GenJnlLine: Record "Gen. Journal Line")
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        TDSEntry: Record "TDS Entry";
        SectionFoundInTDSEntry: Boolean;
    begin
        if GenJnlLine."TDS Section Code" = '' then
            exit;

        if GenJnlLine."Applies-to ID" = '' then
            exit;

        VendorLedgerEntry.SetRange("Applies-to ID", GenJnlLine."Applies-to ID");
        if VendorLedgerEntry.FindSet() then
            repeat
                TDSEntry.Reset();
                TDSEntry.SetRange("Document Type", VendorLedgerEntry."Document Type");
                TDSEntry.SetRange("Document No.", VendorLedgerEntry."Document No.");
                TDSEntry.SetRange(Section, GenJnlLine."TDS Section Code");
                if not TDSEntry.IsEmpty then
                    SectionFoundInTDSEntry := true;
            until VendorLedgerEntry.Next() = 0;

        if not SectionFoundInTDSEntry then
            Error(SectionErr, VendorLedgerEntry."Document No.", GenJnlLine."TDS Section Code");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch. Post Invoice Events", 'OnPostBalancingEntryOnBeforeGenJnlPostLine', '', false, false)]
    local procedure OnPostBalancingEntryOnBeforeGenJnlPostLine(var GenJnlLine: Record "Gen. Journal Line"; var PurchHeader: Record "Purchase Header")
    begin
        PostBalancingEntryForGenJnlLine(GenJnlLine, PurchHeader);
    end;

    local procedure PostBalancingEntry(var PurchHeader: Record "Purchase Header"; var GenJnlLine: Record "Gen. Journal Line")
    var
        PaymentMethod: Record "Payment Method";
        GLEntry: Record "G/L Entry";
        IsHandled: Boolean;
    begin
        OnBeforePostBalancingGLEntry(PurchHeader, GenJnlLine, IsHandled);
        if IsHandled then
            exit;

        if PurchHeader."Payment Method Code" = '' then
            exit;

        if PaymentMethod.Get(PurchHeader."Payment Method Code") then
            if PaymentMethod."Bal. Account No." = '' then
                exit;

        GLEntry.LoadFields("External Document No.", "Document No.", "G/L Account No.", "Document Type", "Credit Amount", "Debit Amount", Amount);
        GLEntry.SetRange("External Document No.", GenJnlLine."External Document No.");
        GLEntry.SetRange("Document No.", GenJnlLine."Document No.");
        GLEntry.SetRange("G/L Account No.", GetVendorAccount(PurchHeader."Buy-from Vendor No."));
        GetGLEntryFilter(GLEntry, GenJnlLine);
        if GLEntry.FindFirst() then
            GenJnlLine.Validate(Amount, GLEntry.Amount * -1);
    end;

    local procedure GetGLEntryFilter(var GLEntry: Record "G/L Entry"; var GenJnlLine: Record "Gen. Journal Line")
    begin
        if (GenJnlLine."Document Type" = GenJnlLine."Document Type"::Payment) then begin
            GLEntry.SetRange("Document Type", GenJnlLine."Document Type"::Invoice);
            GLEntry.SetFilter("Credit Amount", '<>%1', 0);
        end
        else
            if (GenJnlLine."Document Type" = GenJnlLine."Document Type"::Refund) then begin
                GLEntry.SetRange("Document Type", GenJnlLine."Document Type"::"Credit Memo");
                GLEntry.SetFilter("Debit Amount", '<>%1', 0);
            end;
    end;

    local procedure PostBalancingEntryForGenJnlLine(var GenJnlLine: Record "Gen. Journal Line"; var PurchHeader: Record "Purchase Header")
    var
        Vendor: Record Vendor;
        AllowedSection: Record "Allowed Sections";
        IsHandled: Boolean;
    begin
        OnBeforeApplyVendorAndAllowedSectionFilter(GenJnlLine, PurchHeader, IsHandled);
        if IsHandled then
            exit;

        Vendor.LoadFields("No.", "Assessee Code");
        Vendor.SetRange("No.", PurchHeader."Buy-from Vendor No.");
        Vendor.SetFilter("Assessee Code", '<>%1', '');
        if Vendor.FindFirst() then begin
            AllowedSection.LoadFields("Vendor No", "TDS Section");
            AllowedSection.SetRange("Vendor No", Vendor."No.");
            AllowedSection.SetFilter("TDS Section", '<>%1', '');
            if not AllowedSection.IsEmpty() then
                PostBalancingEntry(PurchHeader, GenJnlLine);
        end;
    end;

    local procedure GetVendorAccount(VendorNo: Code[20]): Code[20]
    var
        Vendor: Record Vendor;
        VendorPostingGroup: Record "Vendor Posting Group";
    begin
        if Vendor.Get(VendorNo) then
            if VendorPostingGroup.Get(Vendor."Vendor Posting Group") then
                exit(VendorPostingGroup."Payables Account");
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostBalancingGLEntry(var PurchHeader: Record "Purchase Header"; var GenJnlLine: Record "Gen. Journal Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeApplyVendorAndAllowedSectionFilter(var GenJnlLine: Record "Gen. Journal Line"; var PurchHeader: Record "Purchase Header"; var IsHandled: Boolean)
    begin
    end;
}
