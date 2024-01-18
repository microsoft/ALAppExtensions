// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Documents;

using Microsoft.Bank.Reconciliation;

codeunit 31363 "Create Bank Acc. Stmt Line CZB"
{
    TableNo = "Bank Acc. Reconciliation";

    trigger OnRun()
    var
        BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line";
        BankStatementLineCZB: Record "Bank Statement Line CZB";
        LineNo: Integer;
    begin
        BankStatementLineCZB.SetRange("Bank Statement No.", Rec."Statement No.");
        if BankStatementLineCZB.FindLast() then
            LineNo := BankStatementLineCZB."Line No.";

        BankAccReconciliationLine.SetRange("Statement Type", Rec."Statement Type");
        BankAccReconciliationLine.SetRange("Bank Account No.", Rec."Bank Account No.");
        BankAccReconciliationLine.SetRange("Statement No.", Rec."Statement No.");
        if BankAccReconciliationLine.FindSet() then
            repeat
                LineNo += 10000;
                BankStatementLineCZB.Init();
                BankStatementLineCZB."Bank Statement No." := Rec."Statement No.";
                BankStatementLineCZB."Line No." := LineNo;
                BankStatementLineCZB.CopyFromBankAccReconLine(BankAccReconciliationLine);
                BankStatementLineCZB.Insert();
            until BankAccReconciliationLine.Next() = 0;
    end;
}
