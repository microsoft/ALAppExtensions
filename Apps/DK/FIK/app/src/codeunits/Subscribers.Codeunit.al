// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Bank.Payment;

using Microsoft.Bank.BankAccount;
using Microsoft.Bank.Reconciliation;
using Microsoft.Bank.Statement;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.Payables;
using Microsoft.Purchases.Setup;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;
using Microsoft.Sales.History;
using Microsoft.Sales.Receivables;
using System.IO;

codeunit 13657 FIKSubscribers
{
    var
        PaymentRefrenceLblTxt: Label 'FIK Code', Comment = 'Translate to FIK-kode (FIK is danish abbreviation).';
        DocumentReferenceCaptionTxt: Label 'FIK Code', Comment = 'Translate to FIK-kode (FIK is danish abbreviation).';

        MustBeVendorOrCustomerErr: Label 'The account must be a vendor or customer account.';
        MustBeVendPmtOrCustRefundErr: Label 'Only vendor payments and customer refunds are allowed.';
        EmptyPaymentDetailsErr: Label '%1, %2 or %3 must be used for payments.', Comment = '%1=Field;%2=Field;%3=Field';
        SimultaneousPaymentDetailsErr: Label '%1 and %2 cannot be used simultaneously for payments.', comment = '%1=Field;%2=Field';

    //cod11
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Check Line", 'OnAfterCheckGenJnlLine', '', false, false)]
    procedure OnAfterCheckGenJnlLine(var GenJournalLine: Record "Gen. Journal Line");
    var
        Vendor: Record Vendor;
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
        FIKMgt: Codeunit FIKManagement;
    begin
        PurchasesPayablesSetup.Get();

        if (GenJournalLine."Account Type" = GenJournalLine."Account Type"::Vendor) and Vendor.Get(GenJournalLine."Account No.") and not PurchasesPayablesSetup."Copy Inv. No. To Pmt. Ref." then
            FIKMgt.EvaluateFIK(GenJournalLine."Payment Reference", GenJournalLine."Payment Method Code");
    end;

    //cod 113
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Vend. Entry-Edit", 'OnBeforeVendLedgEntryModify', '', false, false)]
    procedure OnBeforeVendLedgEntryModify(var VendLedgEntry: Record "Vendor Ledger Entry"; FromVendLedgEntry: Record "Vendor Ledger Entry");
    begin
        VendLedgEntry.VALIDATE(GiroAccNo, FromVendLedgEntry.GiroAccNo);
    end;

    //cod1206
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Pmt Export Mgt Gen. Jnl Line", 'OnBeforeInsertPmtExportDataJnlFromGenJnlLine', '', false, false)]
    procedure OnBeforeInsertPmtExportDataJnlFromGenJnlLine(var PaymentExportData: Record "Payment Export Data"; GenJournalLine: Record "Gen. Journal Line"; GeneralLedgerSetup: Record "General Ledger Setup");
    begin
        if GenJournalLine.GiroAccNo <> '' then begin
            PaymentExportData.Amount := GenJournalLine."Amount (LCY)";
            PaymentExportData."Currency Code" := GeneralLedgerSetup."LCY Code";
        end;
        PaymentExportData.RecipientGiroAccNo := GenJournalLine.GiroAccNo;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Pmt Export Mgt Gen. Jnl Line", 'OnBeforeCreateGenJnlDataExchLine', '', false, false)]
    procedure OnBeforeCreateGenJnlDataExchLine(DataExch: Record "Data Exch."; GenJournalLine: Record "Gen. Journal Line"; LineNo: Integer; var LineAmount: Decimal; var TotalAmount: Decimal; var TransferDate: Date; var Handled: Boolean);
    var
        PaymentExportManagement: Codeunit PaymentExportManagement;
    begin
        PaymentExportManagement.CreateGenJnlDataExchLine(DataExch."Entry No.", GenJournalLine, LineNo, LineAmount, TransferDate);
        TotalAmount += LineAmount;
        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Pmt Export Mgt Gen. Jnl Line", 'OnBeforePaymentExport', '', false, false)]
    procedure OnBeforePaymentExport(BalAccountNo: Code[20]; DataExchEntryNo: Integer; LineCount: Integer; TotalAmount: Decimal; TransferDate: Date; var Handled: Boolean);
    var
        PaymentExportManagement: Codeunit PaymentExportManagement;
    begin
        PaymentExportManagement.ExportDataFromBuffer(BalAccountNo, DataExchEntryNo, LineCount, TotalAmount, TransferDate, Handled);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Pmt Export Mgt Gen. Jnl Line", 'OnCheckGenJnlLine', '', false, false)]
    procedure OnCheckGenJnlLine(GenJournalLine: Record "Gen. Journal Line");
    var
        PaymentExportManagement: Codeunit PaymentExportManagement;
    begin
        PaymentExportManagement.CheckFormatSpecificPaymentRules(GenJournalLine);
    end;

    //cod1207
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Pmt Export Mgt Vend Ledg Entry", 'OnBeforeInsertPmtExportDataJnlFromVendorLedgerEntry', '', false, false)]
    procedure OnBeforeInsertPmtExportDataJnlFromVendorLedgerEntry(var PaymentExportData: Record "Payment Export Data"; VendorLedgerEntry: Record "Vendor Ledger Entry"; GeneralLedgerSetup: Record "General Ledger Setup");
    begin
        if VendorLedgerEntry.GiroAccNo <> '' then begin
            VendorLedgerEntry.CALCFIELDS("Amount (LCY)");
            PaymentExportData.Amount := VendorLedgerEntry."Amount (LCY)";
            PaymentExportData."Currency Code" := GeneralLedgerSetup."LCY Code";
        end;
        PaymentExportData.RecipientGiroAccNo := VendorLedgerEntry.GiroAccNo;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Pmt Export Mgt Vend Ledg Entry", 'OnBeforeCreateVendLedgerDataExchLine', '', false, false)]
    procedure OnBeforeCreateVendLedgerDataExchLine(DataExch: Record "Data Exch."; VendorLedgerEntry: Record "Vendor Ledger Entry"; LineNo: Integer; var LineAmount: Decimal; var TotalAmount: Decimal; var TransferDate: Date; var Handled: Boolean);
    var
        PaymentExportManagement: Codeunit PaymentExportManagement;
    begin
        PaymentExportManagement.CreateVendLedgerDataExchLine(DataExch."Entry No.", VendorLedgerEntry, LineNo, LineAmount, TransferDate);
        TotalAmount += LineAmount;
        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Pmt Export Mgt Vend Ledg Entry", 'OnBeforePaymentExportVendorLedgerEntry', '', false, false)]
    procedure OnBeforePaymentExportVendorLedgerEntry(BalAccountNo: code[20]; DataExchEntryNo: Integer; LineCount: Integer; TotalAmount: Decimal; TransferDate: Date; var Handled: Boolean);
    var
        PaymentExportManagement: Codeunit PaymentExportManagement;
    begin
        PaymentExportManagement.ExportDataFromBuffer(BalAccountNo, DataExchEntryNo, LineCount, TotalAmount, TransferDate, Handled);
    end;

    //cod1208
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Pmt Export Mgt Cust Ledg Entry", 'OnBeforeCreateCustLedgerDataExchLine', '', false, false)]
    procedure OnBeforeCreateCustLedgerDataExchLine(DataExch: Record "Data Exch."; CustLedgerEntry: Record "Cust. Ledger Entry"; LineNo: Integer; var LineAmount: Decimal; var TotalAmount: Decimal; var TransferDate: Date; var Handled: Boolean);
    var
        PaymentExportManagement: Codeunit PaymentExportManagement;
    begin
        PaymentExportManagement.CreateCustLedgerDataExchLine(DataExch."Entry No.", CustLedgerEntry, LineNo, LineAmount, TransferDate);
        TotalAmount += LineAmount;
        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Pmt Export Mgt Cust Ledg Entry", 'OnBeforePaymentExportCustLedgerEntry', '', false, false)]
    procedure OnBeforePaymentExportCustLedgerEntry(BalAccountNo: code[20]; DataExchEntryNo: Integer; LineCount: Integer; TotalAmount: Decimal; TransferDate: Date; var Handled: Boolean);
    var
        PaymentExportManagement: Codeunit PaymentExportManagement;
    begin
        PaymentExportManagement.ExportDataFromBuffer(BalAccountNo, DataExchEntryNo, LineCount, TotalAmount, TransferDate, Handled);
    end;

    //cod1211
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Payment Export Gen. Jnl Check", 'OnPaymentExportGenJnlCheck', '', false, false)]
    procedure OnPaymentExportGenJnlCheck(var GenJournalLine: Record "Gen. Journal Line"; var Handled: Boolean);
    var
        PaymentMethod: Record "Payment Method";
        VendBankAcc: Record "Vendor Bank Account";
        CustomerBankAcc: Record "Customer Bank Account";
        PaymentExportManagement: Codeunit PaymentExportManagement;
        PaymentExportGenJnlCheck: Codeunit "Payment Export Gen. Jnl Check";
    begin
        Handled := true;

        if not (GenJournalLine."Account Type" in [GenJournalLine."Account Type"::Customer, GenJournalLine."Account Type"::Vendor, GenJournalLine."Account Type"::Employee]) then
            GenJournalLine.InsertPaymentFileError(MustBeVendorOrCustomerErr);

        if ((GenJournalLine."Account Type" = GenJournalLine."Account Type"::Vendor) and (GenJournalLine."Document Type" <> GenJournalLine."Document Type"::Payment)) or
            ((GenJournalLine."Account Type" = GenJournalLine."Account Type"::Customer) and (GenJournalLine."Document Type" <> GenJournalLine."Document Type"::Refund)) or
            ((GenJournalLine."Account Type" = GenJournalLine."Account Type"::Employee) and (GenJournalLine."Document Type" <> GenJournalLine."Document Type"::Payment))
            then
            GenJournalLine.InsertPaymentFileError(MustBeVendPmtOrCustRefundErr);
        if not (GenJournalLine."Account Type" = GenJournalLine."Account Type"::Employee) and (GenJournalLine."Recipient Bank Account" = '') and
            (GenJournalLine."Creditor No." = '') and (GenJournalLine.GiroAccNo = '')
            then
            GenJournalLine.InsertPaymentFileError(STRSUBSTNO(EmptyPaymentDetailsErr,
                GenJournalLine.FIELDCAPTION("Recipient Bank Account"), GenJournalLine.FIELDCAPTION("Creditor No."), GenJournalLine.FIELDCAPTION(GiroAccNo)));

        if (GenJournalLine."Recipient Bank Account" <> '') and (GenJournalLine.GiroAccNo <> '') then
            GenJournalLine.InsertPaymentFileError(STRSUBSTNO(SimultaneousPaymentDetailsErr,
                GenJournalLine.FIELDCAPTION("Recipient Bank Account"), GenJournalLine.FIELDCAPTION(GiroAccNo)));

        if (GenJournalLine."Creditor No." <> '') and (GenJournalLine."Payment Reference" = '') then
            if PaymentMethod.GET(GenJournalLine."Payment Method Code") then
                if PaymentMethod.PaymentTypeValidation = PaymentMethod.PaymentTypeValidation::"FIK 71" then
                    PaymentExportGenJnlCheck.AddFieldEmptyError(GenJournalLine, GenJournalLine.TABLECAPTION(), GenJournalLine.FIELDCAPTION("Payment Reference"), '');

        if (GenJournalLine.GiroAccNo <> '') and (GenJournalLine."Payment Reference" = '') then
            if PaymentMethod.GET(GenJournalLine."Payment Method Code") then
                if PaymentMethod.PaymentTypeValidation = PaymentMethod.PaymentTypeValidation::"FIK 04" then
                    PaymentExportGenJnlCheck.AddFieldEmptyError(GenJournalLine, GenJournalLine.TABLECAPTION(), GenJournalLine.FIELDCAPTION("Payment Reference"), '');

        case GenJournalLine."Account Type" of
            GenJournalLine."Account Type"::Vendor:
                if VendBankAcc.GET(GenJournalLine."Account No.", GenJournalLine."Recipient Bank Account") then
                    PaymentExportManagement.CheckBankTransferCountryRegion(GenJournalLine, VendBankAcc."Country/Region Code");

            GenJournalLine."Account Type"::Customer:
                if CustomerBankAcc.GET(GenJournalLine."Account No.", GenJournalLine."Recipient Bank Account") then
                    PaymentExportManagement.CheckBankTransferCountryRegion(GenJournalLine, CustomerBankAcc."Country/Region Code");

        end;
    end;

    //cod1212
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Pmt. Export Vend. Ledger Check", 'OnPmtExportVendorLedgerCheck', '', false, false)]
    procedure OnPmtExportVendorLedgerCheck(var VendorLedgerEntry: Record "Vendor Ledger Entry");
    var
        PaymentExportManagement: Codeunit PaymentExportManagement;
    begin
        PaymentExportManagement.CheckCreditorPaymentReference(VendorLedgerEntry);
        PaymentExportManagement.CheckGiroPaymentReference(VendorLedgerEntry);
        PaymentExportManagement.CheckSimultaneousPmtInfoGiroAcc(VendorLedgerEntry);
        PaymentExportManagement.CheckTransferCurrencyCode(VendorLedgerEntry);
        PaymentExportManagement.CheckCreditorCurrencyCode(VendorLedgerEntry);
        PaymentExportManagement.CheckGiroCurrencyCode(VendorLedgerEntry);
        PaymentExportManagement.CheckTransferCountryRegionCode(VendorLedgerEntry);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Pmt. Export Vend. Ledger Check", 'OnCheckEmptyPmtInfoVendorLedgerEntry', '', false, false)]
    procedure OnCheckEmptyPmtInfoVendorLedgerEntry(var VendorLedgerEntry: Record "Vendor Ledger Entry"; var Handled: Boolean);
    begin
        Handled := true;
        VendorLedgerEntry.SETRANGE(GiroAccNo, '');

        if not VendorLedgerEntry.ISEMPTY() then
            ERROR(EmptyPaymentDetailsErr,
            VendorLedgerEntry.FIELDCAPTION("Recipient Bank Account"), VendorLedgerEntry.FIELDCAPTION("Creditor No."), VendorLedgerEntry.FIELDCAPTION(GiroAccNo));
    end;

    //cod1213
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Pmt. Export Cust. Ledger Check", 'OnPmtExportCustLedgerCheck', '', false, false)]
    procedure OnPmtExportCustLedgerCheck(var CustLedgerEntry: Record "Cust. Ledger Entry");
    var
        PaymentExportManagement: Codeunit PaymentExportManagement;
    begin
        PaymentExportManagement.CheckPaymentTypeValidationCustLedgerCheck(CustLedgerEntry);
        PaymentExportManagement.CheckTransferCurrencyCodeCustLedgerCheck(CustLedgerEntry);
        PaymentExportManagement.CheckTransferCountryRegionCodeCustLedgerCheck(CustLedgerEntry);
    end;

    //cod 1247
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Process Gen. Journal  Lines", 'OnBeforeUpdateGenJnlLinesProcedure', '', false, false)]
    procedure OnBeforeUpdateGenJnlLines(var GenJournalLineTemplate: Record "Gen. Journal Line");
    var
        FIKMgt: Codeunit FIKManagement;
    begin
        FIKMgt.UpdateGenJournalLines(GenJournalLineTemplate);
    end;

    //cod1273
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Exp. Pre-Mapping Gen. Jnl.", 'OnBeforeInsertPaymentExoprtData', '', false, false)]
    procedure OnBeforeInsertPaymentExoprtData(var PaymentExportData: Record "Payment Export Data"; GenJournalLine: Record "Gen. Journal Line"; GeneralLedgerSetup: Record "General Ledger Setup");
    var
        VendorBankAccount: Record "Vendor Bank Account";
    begin
        if not VendorBankAccount.GET(GenJournalLine."Account No.", GenJournalLine."Recipient Bank Account") then
            if (GenJournalLine."Creditor No." <> '') or (GenJournalLine.GiroAccNo <> '') then begin
                PaymentExportData.Amount := GenJournalLine."Amount (LCY)";
                PaymentExportData."Currency Code" := GeneralLedgerSetup."LCY Code";
            end;
        PaymentExportData.RecipientGiroAccNo := GenJournalLine.GiroAccNo;
    end;

    //cod1295
    [EventSubscriber(ObjectType::Codeunit, CodeUnit::"Get Bank Stmt. Line Candidates", 'OnBeforeTransferCandidatestoAppliedPmtEntries', '', false, false)]
    procedure OnBeforeTransferCandidatestoAppliedPmtEntries(BankAccReconLine: Record "Bank Acc. Reconciliation Line"; var TempBankStmtMatchingBuffer: Record "Bank Statement Matching Buffer" temporary; var Handled: Boolean);
    var
        MatchBankPayments: Codeunit "Match Bank Payments";
        MatchFIKBankRecLines: Codeunit FIK_MatchBankRecLines;
    begin
        Handled := true;
        BankAccReconLine.SETRECFILTER();
        if BankAccReconLine.PaymentReference = '' then begin
            MatchBankPayments.SetApplyEntries(false);
            MatchBankPayments.RUN(BankAccReconLine);
            MatchBankPayments.GetBankStatementMatchingBuffer(TempBankStmtMatchingBuffer);
        end else
            MatchFIKBankRecLines.GetBankStatementMatchingBuffer(TempBankStmtMatchingBuffer, BankAccReconLine."Statement Line No.");
    end;

    //report 206 - Obsolete
    procedure SetReferenceTextOnGetReferenceText(SalesInvoiceHeader: Record "Sales Invoice Header"; var DocumentReference: Text; var DocumentReferenceText: Text; var Handled: Boolean);
    var
        FIKMgt: Codeunit FIKManagement;
    begin
        if Handled then
            exit;

        DocumentReferenceText := '';
        DocumentReference := FIKMgt.GetFIK71String(SalesInvoiceHeader."No.");
        if DocumentReference <> '' then
            DocumentReferenceText := DocumentReferenceCaptionTxt;
        Handled := true;
    end;

#if not CLEAN22
    //rep 393
    [Obsolete('Replaced by OnBeforeUpdateGnlJnlLineDimensionsFromTempVendorPaymentBuffer.', '22.0')]
    [EventSubscriber(ObjectType::Report, Report::"Suggest Vendor Payments", 'OnBeforeUpdateGnlJnlLineDimensionsFromTempBuffer', '', false, false)]
    procedure OnBeforeUpdateGnlJnlLineDimensionsFromTempBuffer(var GenJournalLine: Record "Gen. Journal Line"; TempPaymentBuffer: Record "Payment Buffer" temporary);
    begin
        GenJournalLine.GiroAccNo := TempPaymentBuffer.GiroAccNo;
        GenJournalLine.UpdateVendorPaymentDetails();
    end;
#endif

    [EventSubscriber(ObjectType::Report, Report::"Suggest Vendor Payments", 'OnBeforeUpdateGnlJnlLineDimensionsFromVendorPaymentBuffer', '', false, false)]
    procedure OnBeforeUpdateGnlJnlLineDimensionsFromTempVendorPaymentBuffer(var GenJournalLine: Record "Gen. Journal Line"; TempVendorPaymentBuffer: Record "Vendor Payment Buffer" temporary);
    begin
        GenJournalLine.GiroAccNo := TempVendorPaymentBuffer.GiroAccNo;
        GenJournalLine.UpdateVendorPaymentDetails();
    end;

#if not CLEAN22
    //rep 393
    [Obsolete('Replaced by OnUpdateTempVendorPaymentBufferFromVendorLedgerEntry.', '22.0')]
    [EventSubscriber(ObjectType::Report, Report::"Suggest Vendor Payments", 'OnUpdateTempBufferFromVendorLedgerEntry', '', false, false)]
    procedure OnUpdateTempBufferFromVendorLedgerEntry(var TempPaymentBuffer: Record "Payment Buffer" temporary; VendorLedgerEntry: Record "Vendor Ledger Entry");
    begin
        TempPaymentBuffer.GiroAccNo := VendorLedgerEntry.GiroAccNo;
    end;
#endif

    [EventSubscriber(ObjectType::Report, Report::"Suggest Vendor Payments", 'OnUpdateVendorPaymentBufferFromVendorLedgerEntry', '', false, false)]
    procedure OnUpdateTempVendorPaymentBufferFromVendorLedgerEntry(var TempVendorPaymentBuffer: Record "Vendor Payment Buffer" temporary; VendorLedgerEntry: Record "Vendor Ledger Entry");
    begin
        TempVendorPaymentBuffer.GiroAccNo := VendorLedgerEntry.GiroAccNo;
    end;

    //table 25
    [EventSubscriber(ObjectType::Table, DATABASE::"Vendor Ledger Entry", 'OnAfterCopyVendLedgerEntryFromGenJnlLine', '', false, false)]
    procedure OnAfterCopyVendLedgerEntryFromGenJnlLine(var VendorLedgerEntry: Record "Vendor Ledger Entry"; GenJournalLine: Record "Gen. Journal Line");
    begin
        VendorLedgerEntry.GiroAccNo := GenJournalLine.GiroAccNo;
    end;

    //tab38
#if not CLEAN22
    [EventSubscriber(ObjectType::Table, DATABASE::"Purchase Header", 'OnValidatePurchaseHeaderPayToVendorNo', '', false, false)]
    [Obsolete('Replaced by event OnValidatePurchaseHeaderPayToVendorNoOnBeforeCheckDocType', '22.0')]
    procedure OnValidatePurchaseHeaderPayToVendorNo(var Sender: Record "Purchase Header"; Vendor: Record Vendor);
    begin
        Sender.VALIDATE(GiroAccNo, Vendor.GiroAccNo);
    end;
#else
    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnValidatePurchaseHeaderPayToVendorNoOnBeforeCheckDocType', '', false, false)]
    local procedure OnValidatePurchaseHeaderPayToVendorNoOnBeforeCheckDocType(Vendor: Record Vendor; var PurchaseHeader: Record "Purchase Header"; var xPurchaseHeader: Record "Purchase Header");
    begin
        PurchaseHeader.Validate(GiroAccNo, Vendor.GiroAccNo)
    end;
#endif

    //table81
    [EventSubscriber(ObjectType::Table, DATABASE::"Gen. Journal Line", 'OnGenJnlLineGetVendorAccount', '', false, false)]
    procedure OnGenJnlLineGetVendorAccount(var Sender: Record "Gen. Journal Line"; Vendor: Record Vendor);
    begin
        Sender.GiroAccNo := Vendor.GiroAccNo;
    end;

    [EventSubscriber(ObjectType::Table, DATABASE::"Gen. Journal Line", 'OnAfterCopyGenJnlLineFromPurchHeaderPayment', '', false, false)]
    procedure OnAfterCopyGenJnlLineFromPurchHeaderPayment(PurchaseHeader: Record "Purchase Header"; var GenJournalLine: Record "Gen. Journal Line");
    begin
        GenJournalLine.GiroAccNo := PurchaseHeader.GiroAccNo;
    end;

    //table112
    [EventSubscriber(ObjectType::Table, DATABASE::"Sales Invoice Header", 'OnGetPaymentReferenceLbl', '', false, false)]
    procedure OnGetPaymentReferenceLbl(var PaymentReferenceLbl: Text);
    begin
        PaymentReferenceLbl := PaymentRefrenceLblTxt;
    end;

    [EventSubscriber(ObjectType::Table, DATABASE::"Sales Invoice Header", 'OnGetPaymentReference', '', false, false)]
    procedure OnGetPaymentReference(var Sender: Record "Sales Invoice Header"; var PaymentReference: Text);
    var
        FIKMgt: Codeunit FIKManagement;
    begin
        PaymentReference := FIKMgt.GetFIK71String(Sender."No.");
    end;

    //page1290
    [EventSubscriber(ObjectType::Page, Page::"Payment Reconciliation Journal", 'OnAtActionApplyAutomatically', '', false, false)]
    local procedure OnAtActionApplyAutomatically(BankAccReconciliation: Record "Bank Acc. Reconciliation"; var SubscriberInvoked: Boolean);
    var
        PaymentReconciliationJournalFikExt: Page "Payment Reconciliation Journal";
    begin
        SubscriberInvoked := true;
        PaymentReconciliationJournalFikExt.UpdateFIKStatus();
        if BankAccReconciliation.FIKPaymentReconciliation then
            CODEUNIT.RUN(CODEUNIT::FIK_MatchBankRecLines, BankAccReconciliation)
        else
            CODEUNIT.RUN(CODEUNIT::"Match Bank Pmt. Appl.", BankAccReconciliation);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Payment Reconciliation Journal", 'OnUpdateSorting', '', false, false)]
    local procedure OnUpdateSorting(var Sender: Page "Payment Reconciliation Journal"; BankAccReconciliation: Record "Bank Acc. Reconciliation"; var SubscriberInvoked: Boolean);
    var
        BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line";
    begin
        SubscriberInvoked := true;
        Sender.GetRecord(BankAccReconciliationLine);
        if BankAccReconciliation.FIKPaymentReconciliation then
            BankAccReconciliationLine.SETCURRENTKEY("Sorting Order", "Transaction Text")
        else
            BankAccReconciliationLine.SETCURRENTKEY("Sorting Order");
    end;

    [EventSubscriber(ObjectType::Page, Page::"Payment Reconciliation Journal", 'OnAfterImportBankTransactions', '', false, false)]
    local procedure OnAfterImportBankTransactions(var SubscriberInvoked: Boolean);
    begin
        SubscriberInvoked := true;
    end;

    //page1292
    [EventSubscriber(ObjectType::Page, Page::"Payment Application", 'OnSetBankAccReconcLine', '', false, false)]
    local procedure OnSetBankAccReconcLine(var Sender: Page "Payment Application"; BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line");
    begin
        if BankAccReconciliationLine.PaymentReference = '' then
            Sender.SetMatchConfidence(true)
        else
            Sender.SetMatchConfidence(false);
    end;
}

