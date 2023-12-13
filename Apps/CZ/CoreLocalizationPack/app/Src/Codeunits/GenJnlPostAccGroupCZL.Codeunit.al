// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GeneralLedger.Posting;

using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Purchases.Posting;
using Microsoft.Sales.Posting;

codeunit 31057 "Gen.Jnl. - Post Acc. Group CZL"
{
    SingleInstance = true;

    var
        BalanceCheckAccountGroupAmount: array[12] of Decimal;

    procedure UpdateCheckAmounts(var TempGLEntry: Record "G/L Entry" temporary)
    var
        GLAccount: Record "G/L Account";
        GLAccountGroup: Integer;
        PostingDate: Date;
        Amount: Decimal;
    begin
        if not GLAccount.Get(TempGLEntry."G/L Account No.") then
            exit;
        GLAccountGroup := GLAccount."G/L Account Group CZL".AsInteger();
        if GLAccountGroup = 0 then
            exit;

        PostingDate := TempGLEntry."Posting Date";
        Amount := TempGLEntry.Amount;
        if PostingDate = NormalDate(PostingDate) then begin
            BalanceCheckAccountGroupAmount[GLAccountGroup] :=
              BalanceCheckAccountGroupAmount[GLAccountGroup] + Amount * ((PostingDate - 00000101D) mod 99 + 1);
            BalanceCheckAccountGroupAmount[GLAccountGroup + 10] := BalanceCheckAccountGroupAmount[GLAccountGroup + 10] +
              Amount * ((PostingDate - 00000101D) mod 98 + 1);
        end else begin
            BalanceCheckAccountGroupAmount[GLAccountGroup] :=
              BalanceCheckAccountGroupAmount[GLAccountGroup] +
              Amount * ((NormalDate(PostingDate) - 00000101D + 50) mod 99 + 1);
            BalanceCheckAccountGroupAmount[GLAccountGroup + 10] :=
              BalanceCheckAccountGroupAmount[GLAccountGroup + 10] +
              Amount * ((NormalDate(PostingDate) - 00000101D + 50) mod 98 + 1);
        end;
    end;

    procedure IsAcountGroupTransactionConsistent(): Boolean
    var
        BalanceCheckAccountGroupConsistent: Boolean;
        Loop: Integer;
    begin
        BalanceCheckAccountGroupConsistent := true;
        for Loop := 1 to 2 do
            BalanceCheckAccountGroupConsistent := BalanceCheckAccountGroupConsistent and (BalanceCheckAccountGroupAmount[Loop] = 0);
        exit(BalanceCheckAccountGroupConsistent);
    end;

    procedure CheckAccountGroupTransactionConsistent()
    var
        AccountGroupConsistentErr: Label 'You cannot post an entry with accounts from different circuits.';
    begin
        if not IsAcountGroupTransactionConsistent() then
            Error(AccountGroupConsistentErr);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnBeforeStartPosting', '', false, false)]
    local procedure ClearBalanceCheckAccountAmount()
    begin
        Clear(BalanceCheckAccountGroupAmount);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Batch", 'OnBeforeCommit', '', false, false)]
    local procedure CheckAccountGroupTransactionConsistentOnGenJnlPost()
    begin
        CheckAccountGroupTransactionConsistent();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterFinalizePostingOnBeforeCommit', '', false, false)]
    local procedure CheckAccountGroupTransactionConsistentOnSalesPost()
    begin
        CheckAccountGroupTransactionConsistent();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnFinalizePostingOnBeforeCommit', '', false, false)]
    local procedure CheckAccountGroupTransactionConsistentOnPurchPost()
    begin
        CheckAccountGroupTransactionConsistent();
    end;
}
