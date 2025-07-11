// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Payments;

using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Posting;

codeunit 18248 "GST Bank Charge Session Mgt."
{
    SingleInstance = true;

    var
        TempGenJournalLine: Record "Gen. Journal Line" temporary;
        TransactionNo: Integer;
        NextEntryNo: Integer;
        BankChargeAmount: Decimal;
        GSTBankChargesPostingStarted: Boolean;
        BankChargeSign: Integer;

    procedure SetTransactionNo(TransNo: Integer)
    begin
        TransactionNo := TransNo;
    end;

    procedure SetNextEntryNo(EntryNo: Integer)
    begin
        NextEntryNo := EntryNo;
    end;

    procedure GetTranxactionNo(): Integer
    begin
        exit(TransactionNo);
    end;

    procedure GETEntryNo(): Integer
    begin
        exit(NextEntryNo);
    end;

    procedure SetBankChargeAmount(BankChargeAmt: Decimal)
    begin
        BankChargeAmount := BankChargeAmt;
    end;

    procedure GetBankChargeAmount(): Decimal
    begin
        exit(BankChargeAmount);
    end;

    Procedure SetBankChargeSign(ChargeSign: Integer)
    begin
        BankChargeSign := ChargeSign;
    end;

    Procedure GetBankChargeSign(): Integer
    begin
        exit(BankChargeSign);
    end;

    procedure CreateGSTBankChargesGenJournallLine(var GenJournalLine: Record "Gen. Journal Line"; GLAccountNo: Code[20]; Amount: Decimal; AmountLCY: Decimal)
    begin
        TempGenJournalLine.Init();
        TempGenJournalLine := GenJournalLine;
        TempGenJournalLine."Line No." := GetTempGenJournalNextLineNo();
        TempGenJournalLine."Account Type" := TempGenJournalLine."Account Type"::"G/L Account";
        TempGenJournalLine."Account No." := GLAccountNo;
        TempGenJournalLine.Description := GetGLAccountDescription(GLAccountNo);
        TempGenJournalLine."Bal. Account Type" := TempGenJournalLine."Bal. Account Type"::"G/L Account";
        TempGenJournalLine."Bal. Account No." := '';
        TempGenJournalLine.Amount := Amount;
        TempGenJournalLine."Amount (LCY)" := AmountLCY;
        if Amount > 0 then begin
            TempGenJournalLine."Debit Amount" := Amount;
            TempGenJournalLine."Credit Amount" := 0;
        end else begin
            TempGenJournalLine."Debit Amount" := 0;
            TempGenJournalLine."Credit Amount" := Amount;
        end;

        TempGenJournalLine."System-Created Entry" := true;
        TempGenJournalLine.Insert();
    end;

    procedure PostGSTBakChargesGenJournalLine(var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    var
        TempGenJnlLine: Record "Gen. Journal Line" temporary;
    begin
        if GSTBankChargesPostingStarted then
            exit;

        if TempGenJournalLine.FindSet() then begin
            GSTBankChargesPostingStarted := true;
            repeat
                TempGenJnlLine := TempGenJournalLine;
                TempGenJnlLine."Line No." := 0;
                GenJnlPostLine.RunWithoutCheck(TempGenJnlLine);
                TempGenJournalLine.Delete();
            until TempGenJournalLine.Next() = 0;

            ClearTempGenJnlLine();
        end;
    end;

    procedure ClearTempGenJnlLine()
    begin
        Clear(TempGenJournalLine);
        GSTBankChargesPostingStarted := false;
        BankChargeAmount := 0;
        TransactionNo := 0;
    end;

    local procedure GetTempGenJournalNextLineNo(): Integer
    var
        NextLineNo: Integer;
    begin
        if TempGenJournalLine.FindLast() then
            NextLineNo := TempGenJournalLine."Line No.";

        exit(NextLineNo + 10000);
    end;

    local procedure GetGLAccountDescription(GLAccCode: Code[20]): Text[100]
    var
        GLAcc: Record "G/L Account";
    begin
        if GLAcc.Get(GLAccCode) then
            exit(GLAcc.Name);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnBeforePostBankAcc', '', false, false)]
    local procedure DeleteAllTempVariables()
    begin
        TempGenJournalLine.DeleteAll();
    end;
}
