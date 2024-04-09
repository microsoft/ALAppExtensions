// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Documents;

using Microsoft.Bank.Reconciliation;

codeunit 31388 "Bank Acc. Reconc. Handler CZB"
{
    [EventSubscriber(ObjectType::Table, Database::"Bank Acc. Reconciliation", 'OnAfterInsertEvent', '', false, false)]
    local procedure CheckBankStatementExistOnAfterBankAccReconciliationInsert(var Rec: Record "Bank Acc. Reconciliation")
    var
        BankStatementHeaderCZB: Record "Bank Statement Header CZB";
        IssBankStatementHeaderCZB: Record "Iss. Bank Statement Header CZB";
        BankStatementExistsErr: Label 'Cannot create Payment Reconciliation Journal because Bank Statement exists for Bank Account %1.', Comment = '%1 = Bank Account No.';
        IssBankStatementExistsErr: Label 'Cannot create Payment Reconciliation Journal because Issued Bank Statement exists for Bank Account %1.', Comment = '%1 = Bank Account No.';
    begin
        if Rec."Statement Type" <> Rec."Statement Type"::"Payment Application" then
            exit;
        if Rec."Created From Bank Stat. CZB" then
            exit;

        BankStatementHeaderCZB.SetRange("Bank Account No.", Rec."Bank Account No.");
        if not BankStatementHeaderCZB.IsEmpty() then
            Error(BankStatementExistsErr, Rec."Bank Account No.");

        IssBankStatementHeaderCZB.SetRange("Bank Account No.", Rec."Bank Account No.");
        if not IssBankStatementHeaderCZB.IsEmpty() then
            Error(IssBankStatementExistsErr, Rec."Bank Account No.");
    end;
}
