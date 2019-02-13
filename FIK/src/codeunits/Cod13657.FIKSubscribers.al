// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

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
    VAR
        Vendor: Record Vendor;
        FIKMgt: Codeunit FIKManagement;
    begin
        IF (GenJournalLine."Account Type" = GenJournalLine."Account Type"::Vendor) AND Vendor.GET(GenJournalLine."Account No.") THEN
            FIKMgt.EvaluateFIK(GenJournalLine."Payment Reference", GenJournalLine."Payment Method Code");
    end;

    //cod 113
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Vend. Entry-Edit", 'OnBeforeVendLedgEntryModify', '', false, false)]
    procedure OnBeforeVendLedgEntryModify(VAR VendLedgEntry: Record "Vendor Ledger Entry"; FromVendLedgEntry: Record "Vendor Ledger Entry");
    begin
        VendLedgEntry.VALIDATE(GiroAccNo, FromVendLedgEntry.GiroAccNo);
    end;

    //cod1206
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Pmt Export Mgt Gen. Jnl Line", 'OnBeforeInsertPmtExportDataJnlFromGenJnlLine', '', false, false)]
    procedure OnBeforeInsertPmtExportDataJnlFromGenJnlLine(VAR PaymentExportData: Record "Payment Export Data"; GenJournalLine: Record "Gen. Journal Line"; GeneralLedgerSetup: Record "General Ledger Setup");
    begin
        IF GenJournalLine.GiroAccNo <> '' THEN BEGIN
            PaymentExportData.Amount := GenJournalLine."Amount (LCY)";
            PaymentExportData."Currency Code" := GeneralLedgerSetup."LCY Code";
        END;
        PaymentExportData.RecipientGiroAccNo := GenJournalLine.GiroAccNo;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Pmt Export Mgt Gen. Jnl Line", 'OnBeforeCreateGenJnlDataExchLine', '', false, false)]
    procedure OnBeforeCreateGenJnlDataExchLine(DataExch: Record "Data Exch."; GenJournalLine: Record "Gen. Journal Line"; LineNo: Integer; var LineAmount: Decimal; var TotalAmount: Decimal; var TransferDate: Date; VAR Handled: Boolean);
    var
        PaymentExportManagement: Codeunit PaymentExportManagement;
    begin
        PaymentExportManagement.CreateGenJnlDataExchLine(DataExch."Entry No.", GenJournalLine, LineNo, LineAmount, TransferDate);
        TotalAmount += LineAmount;
        Handled := TRUE;
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
    procedure OnBeforeInsertPmtExportDataJnlFromVendorLedgerEntry(VAR PaymentExportData: Record "Payment Export Data"; VendorLedgerEntry: Record "Vendor Ledger Entry"; GeneralLedgerSetup: Record "General Ledger Setup");
    begin
        IF VendorLedgerEntry.GiroAccNo <> '' THEN BEGIN
            VendorLedgerEntry.CALCFIELDS("Amount (LCY)");
            PaymentExportData.Amount := VendorLedgerEntry."Amount (LCY)";
            PaymentExportData."Currency Code" := GeneralLedgerSetup."LCY Code";
        END;
        PaymentExportData.RecipientGiroAccNo := VendorLedgerEntry.GiroAccNo;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Pmt Export Mgt Vend Ledg Entry", 'OnBeforeCreateVendLedgerDataExchLine', '', false, false)]
    procedure OnBeforeCreateVendLedgerDataExchLine(DataExch: Record "Data Exch."; VendorLedgerEntry: Record "Vendor Ledger Entry"; LineNo: Integer; var LineAmount: Decimal; var TotalAmount: Decimal; var TransferDate: Date; VAR Handled: Boolean);
    var
        PaymentExportManagement: Codeunit PaymentExportManagement;
    begin
        PaymentExportManagement.CreateVendLedgerDataExchLine(DataExch."Entry No.", VendorLedgerEntry, LineNo, LineAmount, TransferDate);
        TotalAmount += LineAmount;
        Handled := TRUE;
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
    procedure OnBeforeCreateCustLedgerDataExchLine(DataExch: Record "Data Exch."; CustLedgerEntry: Record "Cust. Ledger Entry"; LineNo: Integer; var LineAmount: Decimal; var TotalAmount: Decimal; var TransferDate: Date; VAR Handled: Boolean);
    var
        PaymentExportManagement: Codeunit PaymentExportManagement;
    begin
        PaymentExportManagement.CreateCustLedgerDataExchLine(DataExch."Entry No.", CustLedgerEntry, LineNo, LineAmount, TransferDate);
        TotalAmount += LineAmount;
        Handled := TRUE;
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
    procedure OnPaymentExportGenJnlCheck(VAR GenJournalLine: Record "Gen. Journal Line"; var Handled: Boolean);
    var
        PaymentMethod: Record "Payment Method";
        VendBankAcc: Record "Vendor Bank Account";
        CustomerBankAcc: Record "Customer Bank Account";
        PaymentExportManagement: Codeunit PaymentExportManagement;
        PaymentExportGenJnlCheck: Codeunit "Payment Export Gen. Jnl Check";
    begin
        Handled := TRUE;

        IF NOT (GenJournalLine."Account Type" IN [GenJournalLine."Account Type"::Customer, GenJournalLine."Account Type"::Vendor, GenJournalLine."Account Type"::Employee]) THEN
            GenJournalLine.InsertPaymentFileError(MustBeVendorOrCustomerErr);

        IF ((GenJournalLine."Account Type" = GenJournalLine."Account Type"::Vendor) AND (GenJournalLine."Document Type" <> GenJournalLine."Document Type"::Payment)) OR
            ((GenJournalLine."Account Type" = GenJournalLine."Account Type"::Customer) AND (GenJournalLine."Document Type" <> GenJournalLine."Document Type"::Refund)) OR
            ((GenJournalLine."Account Type" = GenJournalLine."Account Type"::Employee) AND (GenJournalLine."Document Type" <> GenJournalLine."Document Type"::Payment))
            THEN
            GenJournalLine.InsertPaymentFileError(MustBeVendPmtOrCustRefundErr);
        IF NOT (GenJournalLine."Account Type" = GenJournalLine."Account Type"::Employee) AND (GenJournalLine."Recipient Bank Account" = '') AND
            (GenJournalLine."Creditor No." = '') AND (GenJournalLine.GiroAccNo = '')
            THEN
            GenJournalLine.InsertPaymentFileError(STRSUBSTNO(EmptyPaymentDetailsErr,
                GenJournalLine.FIELDCAPTION("Recipient Bank Account"), GenJournalLine.FIELDCAPTION("Creditor No."), GenJournalLine.FIELDCAPTION(GiroAccNo)));

        IF (GenJournalLine."Recipient Bank Account" <> '') AND (GenJournalLine.GiroAccNo <> '') THEN
            GenJournalLine.InsertPaymentFileError(STRSUBSTNO(SimultaneousPaymentDetailsErr,
                GenJournalLine.FIELDCAPTION("Recipient Bank Account"), GenJournalLine.FIELDCAPTION(GiroAccNo)));

        IF (GenJournalLine."Creditor No." <> '') AND (GenJournalLine."Payment Reference" = '') THEN
            IF PaymentMethod.GET(GenJournalLine."Payment Method Code") THEN
                IF PaymentMethod.PaymentTypeValidation = PaymentMethod.PaymentTypeValidation::"FIK 71" THEN
                    PaymentExportGenJnlCheck.AddFieldEmptyError(GenJournalLine, GenJournalLine.TABLECAPTION(), GenJournalLine.FIELDCAPTION("Payment Reference"), '');

        IF (GenJournalLine.GiroAccNo <> '') AND (GenJournalLine."Payment Reference" = '') THEN
            IF PaymentMethod.GET(GenJournalLine."Payment Method Code") THEN
                IF PaymentMethod.PaymentTypeValidation = PaymentMethod.PaymentTypeValidation::"FIK 04" THEN
                    PaymentExportGenJnlCheck.AddFieldEmptyError(GenJournalLine, GenJournalLine.TABLECAPTION(), GenJournalLine.FIELDCAPTION("Payment Reference"), '');

        CASE GenJournalLine."Account Type" OF
            GenJournalLine."Account Type"::Vendor:
                IF VendBankAcc.GET(GenJournalLine."Account No.", GenJournalLine."Recipient Bank Account") THEN
                    PaymentExportManagement.CheckBankTransferCountryRegion(GenJournalLine, VendBankAcc."Country/Region Code");

            GenJournalLine."Account Type"::Customer:
                IF CustomerBankAcc.GET(GenJournalLine."Account No.", GenJournalLine."Recipient Bank Account") THEN
                    PaymentExportManagement.CheckBankTransferCountryRegion(GenJournalLine, CustomerBankAcc."Country/Region Code");

        END;
    end;

    //cod1212
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Pmt. Export Vend. Ledger Check", 'OnPmtExportVendorLedgerCheck', '', false, false)]
    procedure OnPmtExportVendorLedgerCheck(VAR VendorLedgerEntry: Record "Vendor Ledger Entry");
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
    procedure OnCheckEmptyPmtInfoVendorLedgerEntry(VAR VendorLedgerEntry: Record "Vendor Ledger Entry"; VAR Handled: Boolean);
    begin
        Handled := TRUE;
        VendorLedgerEntry.SETRANGE(GiroAccNo, '');

        IF NOT VendorLedgerEntry.ISEMPTY() THEN
            ERROR(EmptyPaymentDetailsErr,
            VendorLedgerEntry.FIELDCAPTION("Recipient Bank Account"), VendorLedgerEntry.FIELDCAPTION("Creditor No."), VendorLedgerEntry.FIELDCAPTION(GiroAccNo));
    end;

    //cod1213
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Pmt. Export Cust. Ledger Check", 'OnPmtExportCustLedgerCheck', '', false, false)]
    procedure OnPmtExportCustLedgerCheck(VAR CustLedgerEntry: Record "Cust. Ledger Entry");
    var
        PaymentExportManagement: Codeunit PaymentExportManagement;
    begin
        PaymentExportManagement.CheckPaymentTypeValidationCustLedgerCheck(CustLedgerEntry);
        PaymentExportManagement.CheckTransferCurrencyCodeCustLedgerCheck(CustLedgerEntry);
        PaymentExportManagement.CheckTransferCountryRegionCodeCustLedgerCheck(CustLedgerEntry);
    end;

    //cod 1247
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Process Gen. Journal  Lines", 'OnBeforeUpdateGenJnlLines', '', false, false)]
    procedure OnBeforeUpdateGenJnlLines(VAR GenJournalLineTemplate: Record "Gen. Journal Line");
    VAR
        FIKMgt: Codeunit FIKManagement;
    begin
        FIKMgt.UpdateGenJournalLines(GenJournalLineTemplate);
    end;

    //cod1273
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Exp. Pre-Mapping Gen. Jnl.", 'OnBeforeInsertPaymentExoprtData', '', false, false)]
    procedure OnBeforeInsertPaymentExoprtData(VAR PaymentExportData: Record "Payment Export Data"; GenJournalLine: Record "Gen. Journal Line"; GeneralLedgerSetup: Record "General Ledger Setup");
    var
        VendorBankAccount: Record "Vendor Bank Account";
    begin
        IF NOT VendorBankAccount.GET(GenJournalLine."Account No.", GenJournalLine."Recipient Bank Account") THEN
            IF (GenJournalLine."Creditor No." <> '') OR (GenJournalLine.GiroAccNo <> '') THEN BEGIN
                PaymentExportData.Amount := GenJournalLine."Amount (LCY)";
                PaymentExportData."Currency Code" := GeneralLedgerSetup."LCY Code";
            END;
        PaymentExportData.RecipientGiroAccNo := GenJournalLine.GiroAccNo;
    end;

    //cod1295
    [EventSubscriber(ObjectType::Codeunit, CodeUnit::"Get Bank Stmt. Line Candidates", 'OnBeforeTransferCandidatestoAppliedPmtEntries', '', false, false)]
    procedure OnBeforeTransferCandidatestoAppliedPmtEntries(BankAccReconLine: Record "Bank Acc. Reconciliation Line"; VAR TempBankStmtMatchingBuffer: Record "Bank Statement Matching Buffer" temporary; var Handled: Boolean);
    var
        MatchBankPayments: Codeunit "Match Bank Payments";
        MatchFIKBankRecLines: Codeunit FIK_MatchBankRecLines;
    begin
        Handled := TRUE;
        BankAccReconLine.SETRECFILTER();
        IF BankAccReconLine.PaymentReference = '' THEN BEGIN
            MatchBankPayments.SetApplyEntries(FALSE);
            MatchBankPayments.RUN(BankAccReconLine);
            MatchBankPayments.GetBankStatementMatchingBuffer(TempBankStmtMatchingBuffer);
        End ELSE
            MatchFIKBankRecLines.GetBankStatementMatchingBuffer(TempBankStmtMatchingBuffer, BankAccReconLine."Statement Line No.");
    end;

    //report 206
    [EventSubscriber(ObjectType::Report, Report::"Sales - Invoice", 'OnGetDocumentReferenceText', '', false, false)]
    procedure SetReferenceTextOnGetReferenceText(SalesInvoiceHeader: Record "Sales Invoice Header"; VAR DocumentReference: Text; VAR DocumentReferenceText: Text; VAR Handled: Boolean);
    VAR
        FIKMgt: Codeunit FIKManagement;
    begin
        IF Handled THEN
            EXIT;

        DocumentReferenceText := '';
        DocumentReference := FIKMgt.GetFIK71String(SalesInvoiceHeader."No.");
        IF DocumentReference <> '' THEN
            DocumentReferenceText := DocumentReferenceCaptionTxt;
        Handled := TRUE;
    end;

    //rep 393
    [EventSubscriber(ObjectType::Report, Report::"Suggest Vendor Payments", 'OnBeforeUpdateGnlJnlLineDimensionsFromTempBuffer', '', false, false)]
    procedure OnBeforeUpdateGnlJnlLineDimensionsFromTempBuffer(VAR GenJournalLine: Record "Gen. Journal Line"; TempPaymentBuffer: Record "Payment Buffer" temporary);
    begin
        GenJournalLine.GiroAccNo := TempPaymentBuffer.GiroAccNo;
        GenJournalLine.UpdateVendorPaymentDetails();
    end;
    //rep 393
    [EventSubscriber(ObjectType::Report, Report::"Suggest Vendor Payments", 'OnUpdateTempBufferFromVendorLedgerEntry', '', false, false)]
    procedure OnUpdateTempBufferFromVendorLedgerEntry(VAR TempPaymentBuffer: Record "Payment Buffer" temporary; VendorLedgerEntry: Record "Vendor Ledger Entry");
    begin
        TempPaymentBuffer.GiroAccNo := VendorLedgerEntry.GiroAccNo;
    end;

    //table 25
    [EventSubscriber(ObjectType::Table, DATABASE::"Vendor Ledger Entry", 'OnAfterCopyVendLedgerEntryFromGenJnlLine', '', false, false)]
    procedure OnAfterCopyVendLedgerEntryFromGenJnlLine(VAR VendorLedgerEntry: Record "Vendor Ledger Entry"; GenJournalLine: Record "Gen. Journal Line");
    begin
        VendorLedgerEntry.GiroAccNo := GenJournalLine.GiroAccNo;
    end;

    //tab38
    [EventSubscriber(ObjectType::Table, DATABASE::"Purchase Header", 'OnValidatePurchaseHeaderPayToVendorNo', '', false, false)]
    procedure OnValidatePurchaseHeaderPayToVendorNo(VAR Sender: Record "Purchase Header"; Vendor: Record Vendor);
    begin
        Sender.VALIDATE(GiroAccNo, Vendor.GiroAccNo);
    end;

    //table81
    [EventSubscriber(ObjectType::Table, DATABASE::"Gen. Journal Line", 'OnGenJnlLineGetVendorAccount', '', false, false)]
    procedure OnGenJnlLineGetVendorAccount(VAR Sender: Record "Gen. Journal Line"; Vendor: Record Vendor);
    begin
        Sender.GiroAccNo := Vendor.GiroAccNo;
    end;

    [EventSubscriber(ObjectType::Table, DATABASE::"Gen. Journal Line", 'OnAfterCopyGenJnlLineFromPurchHeaderPayment', '', false, false)]
    procedure OnAfterCopyGenJnlLineFromPurchHeaderPayment(PurchaseHeader: Record "Purchase Header"; VAR GenJournalLine: Record "Gen. Journal Line");
    begin
        GenJournalLine.GiroAccNo := PurchaseHeader.GiroAccNo;
    end;

    //table112
    [EventSubscriber(ObjectType::Table, DATABASE::"Sales Invoice Header", 'OnGetPaymentReferenceLbl', '', false, false)]
    procedure OnGetPaymentReferenceLbl(VAR PaymentReferenceLbl: Text);
    begin
        PaymentReferenceLbl := PaymentRefrenceLblTxt;
    end;

    [EventSubscriber(ObjectType::Table, DATABASE::"Sales Invoice Header", 'OnGetPaymentReference', '', false, false)]
    procedure OnGetPaymentReference(VAR Sender: Record "Sales Invoice Header"; VAR PaymentReference: Text);
    VAR
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
        IF BankAccReconciliation.FIKPaymentReconciliation THEN
            CODEUNIT.RUN(CODEUNIT::FIK_MatchBankRecLines, BankAccReconciliation)
        ELSE
            CODEUNIT.RUN(CODEUNIT::"Match Bank Pmt. Appl.", BankAccReconciliation);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Payment Reconciliation Journal", 'OnUpdateSorting', '', false, false)]
    local procedure OnUpdateSorting(VAR Sender: Page "Payment Reconciliation Journal"; BankAccReconciliation: Record "Bank Acc. Reconciliation"; VAR SubscriberInvoked: Boolean);
    var
        BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line";
    begin
        SubscriberInvoked := true;
        Sender.GetRecord(BankAccReconciliationLine);
        IF BankAccReconciliation.FIKPaymentReconciliation THEN
            BankAccReconciliationLine.SETCURRENTKEY("Sorting Order", "Transaction Text")
        ELSE
            BankAccReconciliationLine.SETCURRENTKEY("Sorting Order");
    end;

    [EventSubscriber(ObjectType::Page, Page::"Payment Reconciliation Journal", 'OnAfterImportBankTransactions', '', false, false)]
    local procedure OnAfterImportBankTransactions(var SubscriberInvoked: Boolean);
    begin
        SubscriberInvoked := true;
    end;

    //page1292
    [EventSubscriber(ObjectType::Page, Page::"Payment Application", 'OnSetBankAccReconcLine', '', false, false)]
    local procedure OnSetBankAccReconcLine(VAR Sender: Page "Payment Application"; BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line");
    begin
        IF BankAccReconciliationLine.PaymentReference = '' THEN
            Sender.SetMatchConfidence(TRUE)
        ELSE
            Sender.SetMatchConfidence(FALSE);
    end;
}

