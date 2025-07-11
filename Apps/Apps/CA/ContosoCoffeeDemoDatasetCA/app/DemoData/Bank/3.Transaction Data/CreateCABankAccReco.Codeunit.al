// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Bank;

using Microsoft.Bank.Reconciliation;

codeunit 27036 "Create CA Bank Acc. Reco."
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        UpdateBankAccRecLine();
    end;

    local procedure UpdateBankAccRecLine()
    var
        BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line";
        CreateBankAccount: Codeunit "Create Bank Account";
    begin
        BankAccReconciliationLine.SetRange("Bank Account No.", CreateBankAccount.Checking());
        BankAccReconciliationLine.SetRange("Statement Line No.", 30000);
        if BankAccReconciliationLine.FindFirst() then begin
            BankAccReconciliationLine.Validate("Transaction Text", DeposittoAccountLbl);
            BankAccReconciliationLine.Validate(Description, DeposittoAccountLbl);
            BankAccReconciliationLine.Modify(true);
        end;
    end;

    var
        DeposittoAccountLbl: Label 'Deposit to Account 24-01-18', MaxLength = 100;
}
