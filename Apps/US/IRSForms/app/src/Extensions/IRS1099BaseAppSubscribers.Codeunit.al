// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Reversal;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.Payables;
using Microsoft.Purchases.Vendor;
using Microsoft.Utilities;
using System.Utilities;

codeunit 10032 "IRS 1099 BaseApp Subscribers"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        IRSReportingPeriod: Codeunit "IRS Reporting Period";
        IRS1099VendorFormBox: Codeunit "IRS 1099 Vendor Form Box";

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterCopyGenJnlLineFromPurchHeader', '', false, false)]
    local procedure UpdateIRSDataOnAfterCopyGenJnlLineFromPurchHeader(PurchaseHeader: Record "Purchase Header"; var GenJournalLine: Record "Gen. Journal Line")
    var
        PurchLine: Record "Purchase Line";
        IRS1099ReportingAmount: Decimal;
    begin
        if not (GenJournalLine."Document Type" in [GenJournalLine."Document Type"::Invoice, GenJournalLine."Document Type"::"Credit Memo"]) then
            exit;
        GenJournalLine.Validate("IRS 1099 Reporting Period", PurchaseHeader."IRS 1099 Reporting Period");
        if PurchaseHeader."IRS 1099 Form No." = '' then
            exit;

        PurchLine.SetRange("Document Type", PurchaseHeader."Document Type");
        PurchLine.SetRange("Document No.", PurchaseHeader."No.");
        PurchLine.SetRange("1099 Liable", true);
        if not PurchLine.FindSet() then
            exit;

        GenJournalLine.Validate("IRS 1099 Form No.", PurchaseHeader."IRS 1099 Form No.");
        GenJournalLine.Validate("IRS 1099 Form Box No.", PurchaseHeader."IRS 1099 Form Box No.");
        repeat
            if PurchaseHeader."Document Type" in [PurchaseHeader."Document Type"::"Return Order", PurchaseHeader."Document Type"::"Credit Memo"] then
                IRS1099ReportingAmount += PurchLine."Amount Including VAT"
            else
                IRS1099ReportingAmount += -PurchLine."Amount Including VAT";
        until PurchLine.Next() = 0;
        GenJournalLine.Validate("IRS 1099 Reporting Amount", Round(IRS1099ReportingAmount));
    end;

    [EventSubscriber(ObjectType::Table, Database::"Vendor Ledger Entry", 'OnAfterCopyVendLedgerEntryFromGenJnlLine', '', false, false)]
    local procedure UpdateIRSDataOnAfterCopyVendLedgerEntryFromGenJnlLine(var VendorLedgerEntry: Record "Vendor Ledger Entry"; GenJournalLine: Record "Gen. Journal Line")
    begin
        if GenJournalLine."IRS 1099 Reporting Amount" = 0 then
            exit;
        VendorLedgerEntry."IRS 1099 Subject For Reporting" := true;
        VendorLedgerEntry."IRS 1099 Reporting Period" := GenJournalLine."IRS 1099 Reporting Period";
        VendorLedgerEntry."IRS 1099 Form No." := GenJournalLine."IRS 1099 Form No.";
        VendorLedgerEntry."IRS 1099 Form Box No." := GenJournalLine."IRS 1099 Form Box No.";
        VendorLedgerEntry."IRS 1099 Reporting Amount" := GenJournalLine."IRS 1099 Reporting Amount";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterValidateEvent', 'Posting Date', false, false)]
    local procedure UpdateIRSDataOnAfterValidatePostingDateInGenJnlLine(var Rec: Record "Gen. Journal Line")
    begin
        UpdateIRSDataInGenJnlLine(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterValidateEvent', 'Account No.', false, false)]
    local procedure UpdateIRSDataOnAfterValidateAccNoInGenJnlLine(var Rec: Record "Gen. Journal Line")
    begin
        UpdateIRSDataInGenJnlLine(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterValidateEvent', 'Bal. Account No.', false, false)]
    local procedure UpdateIRSDataOnAfterValidateBalAccNoInGenJnlLine(var Rec: Record "Gen. Journal Line")
    begin
        UpdateIRSDataInGenJnlLine(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterValidateEvent', 'Document Type', false, false)]
    local procedure UpdateIRSDataOnAfterValidateDocumentTypeInGenJnlLine(var Rec: Record "Gen. Journal Line")
    begin
        UpdateIRSDataInGenJnlLine(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterValidateEvent', 'Amount', false, false)]
    local procedure UpdateIRSReportingAmountOnAfterValidateAmountInGenJnlLine(var Rec: Record "Gen. Journal Line")
    begin
        UpdateIRSReportingAmountInGenJnlLine(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterSetupNewLine', '', false, false)]
    local procedure UpdateIRSDataOnOnAfterSetupNewLineInGenJnlLine(var GenJournalLine: Record "Gen. Journal Line")
    begin
        UpdateIRSDataInGenJnlLine(GenJournalLine);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnAfterValidateEvent', 'Posting Date', false, false)]
    local procedure UpdateIRSDataOnAfterValidatePostingDate(var Rec: Record "Purchase Header")
    begin
        IRS1099VendorFormBox.ShowNotificationIfVendorHas1099CodePrevPeriodButNotCurr(Rec."Pay-to Vendor No.", Rec."Posting Date");
        UpdateIRSDataInPurchHeader(Rec, true);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnAfterValidateEvent', 'Pay-To Vendor No.', false, false)]
    local procedure UpdateIRSDataOnAfterValidatePayToVendorNo(var Rec: Record "Purchase Header")
    begin
        UpdateIRSDataInPurchHeader(Rec, Rec."No." <> '');
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnAfterInitRecord', '', false, false)]
    local procedure UpdateIRSDataOnAfterInitRecord(var PurchHeader: Record "Purchase Header")
    begin
        IRS1099VendorFormBox.ShowNotificationIfVendorHas1099CodePrevPeriodButNotCurr(PurchHeader."Pay-to Vendor No.", PurchHeader."Posting Date");
        UpdateIRSDataInPurchHeader(PurchHeader, false);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Vend. Entry-Edit", 'OnBeforeVendLedgEntryModify', '', false, false)]
    local procedure UpdateIRSDataOnBeforeVendLedgEntryModify(var VendLedgEntry: Record "Vendor Ledger Entry"; FromVendLedgEntry: Record "Vendor Ledger Entry")
    begin
        VendLedgEntry."IRS 1099 Reporting Period" := FromVendLedgEntry."IRS 1099 Reporting Period";
        VendLedgEntry."IRS 1099 Form No." := FromVendLedgEntry."IRS 1099 Form No.";
        VendLedgEntry."IRS 1099 Form Box No." := FromVendLedgEntry."IRS 1099 Form Box No.";
        VendLedgEntry."IRS 1099 Reporting Amount" := FromVendLedgEntry."IRS 1099 Reporting Amount";
        VendLedgEntry."IRS 1099 Subject For Reporting" := FromVendLedgEntry."IRS 1099 Subject For Reporting";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnAfterInitHeaderDefaults', '', false, false)]
    local procedure Update1099LiableOnAfterInitHeaderDefaults(var PurchLine: Record "Purchase Line"; PurchHeader: Record "Purchase Header"; var TempPurchLine: record "Purchase Line" temporary)
    begin
        PurchLine."1099 Liable" := (PurchHeader."IRS 1099 Form Box No." <> '')
    end;

    [EventSubscriber(ObjectType::Table, Database::"Standard Vendor Purchase Code", 'OnApplyStdCodesToPurchaseLinesOnAfterPurchLineInsert', '', false, false)]
    local procedure Update1099LiableOnApplyStdCodesToPurchaseLinesOnAfterPurchLineInsert(var PurchaseLine: Record "Purchase Line"; var PurchaseHeader: Record "Purchase Header"; var StandardPurchaseLine: Record "Standard Purchase Line")
    begin
        if PurchaseLine."1099 Liable" = (PurchaseHeader."IRS 1099 Form Box No." <> '') then
            exit;
        PurchaseLine."1099 Liable" := (PurchaseHeader."IRS 1099 Form Box No." <> '');
        PurchaseLine.Modify();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Page Management", 'OnConditionalCardPageIDNotFound', '', true, true)]
    local procedure OnConditionalCardPageIDNotFound(RecordRef: RecordRef; var CardPageID: Integer);
    begin
        case RecordRef.Number of
            Database::"IRS Forms Setup":
                CardPageID := Page::"IRS Forms Setup";
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Error Messages", 'OnOpenRelatedRecord', '', false, false)]
    local procedure OpenTransmissionErrorRelatedRecord(ErrorMessage: Record "Error Message"; var IsHandled: Boolean)
    var
        Vendor: Record Vendor;
        PageManagement: Codeunit "Page Management";
    begin
        if ErrorMessage."Context Table Number" <> Database::"Transmission IRIS" then
            exit;

        case ErrorMessage."Table Number" of
            Database::Vendor:
                if ErrorMessage."Additional Information" <> '' then begin
                    Vendor.SetFilter("No.", ErrorMessage."Additional Information");
                    PageManagement.PageRunList(Vendor);
                    IsHandled := true;
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Reverse", 'OnReverseVendLedgEntryOnBeforeInsertVendLedgEntry', '', false, false)]
    local procedure ReverseIRS1099AmountOnReverseVendLedgEntryOnBeforeInsertVendLedgEntry(var NewVendLedgEntry: Record "Vendor Ledger Entry"; VendLedgEntry: Record "Vendor Ledger Entry")
    begin
        NewVendLedgEntry."IRS 1099 Reporting Amount" := -VendLedgEntry."IRS 1099 Reporting Amount";
    end;

    procedure UpdateIRSDataInPurchHeader(var PurchHeader: Record "Purchase Header"; ModifyRecord: Boolean)
    var
        IRS1099VendorFormBoxSetup: Record "IRS 1099 Vendor Form Box Setup";
        PurchaseLine: Record "Purchase Line";
        NewPeriodNo: Code[20];
        NewFormNo: Code[20];
        NewFormBoxNo: Code[20];
        OldFormBoxNo: Code[20];
    begin
        NewPeriodNo := IRSReportingPeriod.GetReportingPeriod(PurchHeader."Posting Date");
        if NewPeriodNo <> '' then
            if not IRS1099VendorFormBoxSetup.Get(NewPeriodNo, PurchHeader."Pay-To Vendor No.") then
                IRS1099VendorFormBoxSetup.Init();
        NewFormNo := IRS1099VendorFormBoxSetup."Form No.";
        NewFormBoxNo := IRS1099VendorFormBoxSetup."Form Box No.";

        if (PurchHeader."IRS 1099 Reporting Period" = NewPeriodNo) and
           (PurchHeader."IRS 1099 Form No." = NewFormNo) and
           (PurchHeader."IRS 1099 Form Box No." = NewFormBoxNo)
        then
            exit;

        OldFormBoxNo := PurchHeader."IRS 1099 Form Box No.";
        PurchHeader.Validate("IRS 1099 Reporting Period", NewPeriodNo);
        PurchHeader.Validate("IRS 1099 Form No.", NewFormNo);
        PurchHeader.Validate("IRS 1099 Form Box No.", NewFormBoxNo);
        if ModifyRecord and (PurchHeader."No." <> '') then
            if PurchHeader.SystemCreatedAt <> 0DT then      // check if record was already inserted
                if PurchHeader.Modify(true) then;
        if OldFormBoxNo <> PurchHeader."IRS 1099 Form Box No." then begin
            PurchaseLine.ReadIsolation(IsolationLevel::ReadCommitted);
            PurchaseLine.SetRange("Document Type", PurchHeader."Document Type");
            PurchaseLine.SetRange("Document No.", PurchHeader."No.");
            PurchaseLine.ModifyAll("1099 Liable", PurchHeader."IRS 1099 Form Box No." <> '');
        end;
    end;

    procedure UpdateIRSDataInGenJnlLine(var GenJnlLine: Record "Gen. Journal Line")
    var
        IRS1099VendorFormBoxSetup: Record "IRS 1099 Vendor Form Box Setup";
        NewPeriodNo: Code[20];
        NewFormNo: Code[20];
        NewFormBoxNo: Code[20];
    begin
        if not SyncIRSDataInGenJnlLine(GenJnlLine) then
            exit;
        NewPeriodNo := IRSReportingPeriod.GetReportingPeriod(GenJnlLine."Posting Date");
        GetIRS1099VendorFormBoxSetupFromGenJnlLine(IRS1099VendorFormBoxSetup, GenJnlLine, NewPeriodNo);
        NewFormNo := IRS1099VendorFormBoxSetup."Form No.";
        NewFormBoxNo := IRS1099VendorFormBoxSetup."Form Box No.";
        if (GenJnlLine."IRS 1099 Reporting Period" = NewPeriodNo) and
           (GenJnlLine."IRS 1099 Form No." = NewFormNo) and
           (GenJnlLine."IRS 1099 Form Box No." = NewFormBoxNo)
        then
            exit;

        GenJnlLine.Validate("IRS 1099 Reporting Period", NewPeriodNo);
        GenJnlLine.Validate("IRS 1099 Form No.", NewFormNo);
        GenJnlLine.Validate("IRS 1099 Form Box No.", NewFormBoxNo);
        SaveChangesInGenJnlLine(GenJnlLine);
    end;

    local procedure GetIRS1099VendorFormBoxSetupFromGenJnlLine(var IRS1099VendorFormBoxSetup: Record "IRS 1099 Vendor Form Box Setup"; GenJnlLine: Record "Gen. Journal Line"; PeriodNo: Code[20])
    begin
        if PeriodNo = '' then
            exit;
        if GenJnlLine."Account Type" = GenJnlLine."Account Type"::Vendor then
            if IRS1099VendorFormBoxSetup.Get(PeriodNo, GenJnlLine."Account No.") then;
        if GenJnlLine."Bal. Account Type" = GenJnlLine."Bal. Account Type"::Vendor then
            if IRS1099VendorFormBoxSetup.Get(PeriodNo, GenJnlLine."Bal. Account No.") then;
    end;

    procedure UpdateIRSReportingAmountInGenJnlLine(var GenJnlLine: Record "Gen. Journal Line")
    begin
        if not SyncIRSDataInGenJnlLine(GenJnlLine) then
            exit;
        GenJnlLine.Validate("IRS 1099 Reporting Amount", GenJnlLine.Amount);
        SaveChangesInGenJnlLine(GenJnlLine);
    end;

    local procedure SyncIRSDataInGenJnlLine(var GenJnlLine: Record "Gen. Journal Line"): Boolean
    begin
        if GenJnlLine.IsTemporary() then
            exit(false);
        exit(GenJnlLine."Document Type" in [GenJnlLine."Document Type"::Invoice, GenJnlLine."Document Type"::"Credit Memo"]);
    end;

    local procedure SaveChangesInGenJnlLine(var GenJnlLine: Record "Gen. Journal Line")
    begin
        if GenJnlLine."Line No." <> 0 then
            if GenJnlLine.Modify(true) then;
    end;

}
