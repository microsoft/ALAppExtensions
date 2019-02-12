// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

tableextension 13618 BankAccReconcilation extends "Bank Acc. Reconciliation"
{
    fields
    {
        field(13601; FIKPaymentReconciliation; Boolean) { Caption = 'FIK Payment Reconciliation'; }
    }
    procedure ImportAndProcessToNewFIK()
    var
        BankAccount: Record "Bank Account";
        BankAccReconciliation: Record "Bank Acc. Reconciliation";
        FIKMgt: Codeunit FIKManagement;
    begin
        IF NOT BankAccReconciliation.SelectBankAccountToUse(BankAccount, FALSE) THEN
            EXIT;
        CreateNewBankPaymentAppBatch(BankAccount."No.", BankAccReconciliation);
        IF NOT FIKMgt.ImportFIKToBankAccRecLine(BankAccReconciliation) THEN
            EXIT;

        CODEUNIT.RUN(CODEUNIT::FIK_MatchBankRecLines, BankAccReconciliation);

        OpenWorksheet(BankAccReconciliation);
    end;
}