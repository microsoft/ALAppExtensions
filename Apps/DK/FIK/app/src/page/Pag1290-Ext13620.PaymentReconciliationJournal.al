// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

pageextension 13620 PaymentReconciliationJournal extends "Payment Reconciliation Journal"
{
    actions
    {
        addafter(ImportBankTransactions)
        {
            action(ImportFIKStatement2)
            {
                Ellipsis = true;
                Caption = 'Import FIK Statement';
                ToolTip = 'Import a file with FIK payments. The Fik payments are automatically applied as suggestions.';
                ApplicationArea = Basic, Suite;
                Promoted = true;
                PromotedIsBig = true;
                Image = Import;
                PromotedCategory = Process;
                trigger OnAction();
                var
                    BankAccReconciliation: Record "Bank Acc. Reconciliation";
                    FIKMgt: Codeunit FIKManagement;
                begin
                    BankAccReconciliation.GET("Statement Type", "Bank Account No.", "Statement No.");
                    IF (COUNT() > 0) AND (NOT BankAccReconciliation.FIKPaymentReconciliation) THEN
                        ERROR(CannotImportFIKLinesErr);

                    IF FIKMgt.ImportFIKToBankAccRecLine(BankAccReconciliation) THEN BEGIN
                        COMMIT();
                        CODEUNIT.RUN(CODEUNIT::FIK_MatchBankRecLines, BankAccReconciliation);
                        CurrPage.UPDATE(FALSE);
                    END;
                end;
            }
        }
        modify(AddMappingRule)
        {
            trigger OnBeforeAction();
            begin
                BankAccReconciliation.GET("Statement Type", "Bank Account No.", "Statement No.");
                UpdateFIKStatus();
                IF BankAccReconciliation.FIKPaymentReconciliation THEN
                    ERROR(CannotAddMappingRulesForFIKLinesErr);
            end;
        }
        modify(ImportBankTransactions)
        {
            trigger OnBeforeAction();
            begin
                BankAccReconciliation.GET("Statement Type", "Bank Account No.", "Statement No.");

                IF (COUNT() > 0) AND BankAccReconciliation.FIKPaymentReconciliation THEN
                    ERROR(CannotImportStatementIntoFIKErr);

                BankAccReconciliation.ImportBankStatement();
                CurrPage.UPDATE(FALSE);

                BankAccReconciliation.GET("Statement Type", "Bank Account No.", "Statement No.");
                BankAccReconciliation.FIKPaymentReconciliation := FALSE;
                BankAccReconciliation.MODIFY();
            end;
        }
    }

    trigger OnClosePage();
    begin
        UpdateFIKStatus();
    end;

    PROCEDURE UpdateFIKStatus();
    begin
        IF BankAccReconciliation.GET("Statement Type", "Bank Account No.", "Statement No.") THEN
            IF COUNT() = 0 THEN begin
                BankAccReconciliation.FIKPaymentReconciliation := FALSE;
                BankAccReconciliation.MODIFY();
            end;
    end;

    var
        BankAccReconciliation: Record "Bank Acc. Reconciliation";
        CannotAddMappingRulesForFIKLinesErr: Label 'You cannot use the Map Text to Account function for payments of type FIK.';
        CannotImportFIKLinesErr: Label 'You cannot import FIK statement files into this payment reconciliation journal, because it contains journal lines for non-FIK payments.\\Import the FIK statement file into a payment reconciliation journal that is empty or contains lines for other FIK payments.';
        CannotImportStatementIntoFIKErr: Label 'You cannot import bank statement files for non-FIK payments into a payment reconciliation journal that already contains journal lines for FIK payments.';
}