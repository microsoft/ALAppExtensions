﻿// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.Payables;

codeunit 10032 "IRS 1099 BaseApp Subscribers"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
#if not CLEAN25
        IRSFormsFeature: Codeunit "IRS Forms Feature";
#endif
        IRSReportingPeriod: Codeunit "IRS Reporting Period";

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterCopyGenJnlLineFromPurchHeader', '', false, false)]
    local procedure UpdateIRSDataOnAfterCopyGenJnlLineFromPurchHeader(PurchaseHeader: Record "Purchase Header"; var GenJournalLine: Record "Gen. Journal Line")
    begin
#if not CLEAN25
        if not IRSFormsFeature.IsEnabled() then
            exit;
#endif
        if not (GenJournalLine."Document Type" in [GenJournalLine."Document Type"::Invoice, GenJournalLine."Document Type"::"Credit Memo"]) then
            exit;
        GenJournalLine.Validate("IRS 1099 Reporting Period", PurchaseHeader."IRS 1099 Reporting Period");
        if PurchaseHeader."IRS 1099 Form No." = '' then
            exit;
        GenJournalLine.Validate("IRS 1099 Form No.", PurchaseHeader."IRS 1099 Form No.");
        GenJournalLine.Validate("IRS 1099 Form Box No.", PurchaseHeader."IRS 1099 Form Box No.");
        PurchaseHeader.CalcFields("Amount Including VAT");
        if PurchaseHeader."Document Type" in [PurchaseHeader."Document Type"::"Return Order", PurchaseHeader."Document Type"::"Credit Memo"] then
            GenJournalLine.Validate("IRS 1099 Reporting Amount", Round(PurchaseHeader."Amount Including VAT"))
        else
            GenJournalLine.Validate("IRS 1099 Reporting Amount", -Round(PurchaseHeader."Amount Including VAT"));
    end;

    [EventSubscriber(ObjectType::Table, Database::"Vendor Ledger Entry", 'OnAfterCopyVendLedgerEntryFromGenJnlLine', '', false, false)]
    local procedure UpdateIRSDataOnAfterCopyVendLedgerEntryFromGenJnlLine(var VendorLedgerEntry: Record "Vendor Ledger Entry"; GenJournalLine: Record "Gen. Journal Line")
    begin
#if not CLEAN25
        if not IRSFormsFeature.IsEnabled() then
            exit;
#endif
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
        UpdateIRSDataInPurchHeader(PurchHeader, false);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Vend. Entry-Edit", 'OnBeforeVendLedgEntryModify', '', false, false)]
    local procedure UpdateIRSDataOnBeforeVendLedgEntryModify(var VendLedgEntry: Record "Vendor Ledger Entry"; FromVendLedgEntry: Record "Vendor Ledger Entry")
    begin
#if not CLEAN25
        if not IRSFormsFeature.IsEnabled() then
            exit;
#endif
        VendLedgEntry."IRS 1099 Form Box No." := FromVendLedgEntry."IRS 1099 Form Box No.";
        VendLedgEntry."IRS 1099 Reporting Amount" := FromVendLedgEntry."IRS 1099 Reporting Amount";
        VendLedgEntry."IRS 1099 Subject For Reporting" := FromVendLedgEntry."IRS 1099 Subject For Reporting";
    end;

    procedure UpdateIRSDataInPurchHeader(var PurchHeader: Record "Purchase Header"; ModifyRecord: Boolean)
    var
        IRS1099VendorFormBoxSetup: Record "IRS 1099 Vendor Form Box Setup";
        PeriodNo: Code[20];
    begin
#if not CLEAN25
        if not IRSFormsFeature.IsEnabled() then
            exit;
#endif
        PeriodNo := IRSReportingPeriod.GetReportingPeriod(PurchHeader."Posting Date");
        if PeriodNo <> '' then
            if not IRS1099VendorFormBoxSetup.Get(PeriodNo, PurchHeader."Pay-To Vendor No.") then
                IRS1099VendorFormBoxSetup.Init();
        PurchHeader.Validate("IRS 1099 Reporting Period", PeriodNo);
        PurchHeader.Validate("IRS 1099 Form No.", IRS1099VendorFormBoxSetup."Form No.");
        PurchHeader.Validate("IRS 1099 Form Box No.", IRS1099VendorFormBoxSetup."Form Box No.");
        if ModifyRecord then
            PurchHeader.Modify(true);
    end;

    procedure UpdateIRSDataInGenJnlLine(var GenJnlLine: Record "Gen. Journal Line")
    var
        IRS1099VendorFormBoxSetup: Record "IRS 1099 Vendor Form Box Setup";
        PeriodNo: Code[20];
    begin
#if not CLEAN25
        if not IRSFormsFeature.IsEnabled() then
            exit;
#endif
        if GenJnlLine."Document Type" in [GenJnlLine."Document Type"::Invoice, GenJnlLine."Document Type"::"Credit Memo"] then begin
            PeriodNo := IRSReportingPeriod.GetReportingPeriod(GenJnlLine."Posting Date");
            GetIRS1099VendorFormBoxSetupFromGenJnlLine(IRS1099VendorFormBoxSetup, GenJnlLine, PeriodNo);
        end;
        GenJnlLine.Validate("IRS 1099 Reporting Period", PeriodNo);
        GenJnlLine.Validate("IRS 1099 Form No.", IRS1099VendorFormBoxSetup."Form No.");
        GenJnlLine.Validate("IRS 1099 Form Box No.", IRS1099VendorFormBoxSetup."Form Box No.");
        if GenJnlLine."Line No." <> 0 then
            GenJnlLine.Modify(true);
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
#if not CLEAN25
        if not IRSFormsFeature.IsEnabled() then
            exit;
#endif
        GenJnlLine.Validate("IRS 1099 Reporting Amount", GenJnlLine.Amount);
        if GenJnlLine."Line No." <> 0 then
            GenJnlLine.Modify(true);
    end;

}
