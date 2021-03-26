codeunit 18436 "GST Reverse Trans. Handler"
{
    var
        ReverseDGSTErr: Label 'You cannot reverse the Transaction as GST Adjustment Type is Credit Reversal/Permanent Reversal.';

    local procedure ReverseGST(
        var GSTLedgerEntry: Record "GST Ledger Entry";
        NextTransactionNo: Integer)
    var
        SourceCodeSetup: Record "Source Code Setup";
        GSTLedgerEntryToModify: Record "GST Ledger Entry";
        NewGSTLedgerEntry: Record "GST Ledger Entry";
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
    begin
        SourceCodeSetup.Get();

        if GSTLedgerEntry.FindSet() then begin
            DetailedGSTLedgerEntry.SetCurrentKey("Transaction No.");
            DetailedGSTLedgerEntry.SetRange("Transaction No.", GSTLedgerEntry."Transaction No.");
            ReverseDetailedGST(DetailedGSTLedgerEntry, NextTransactionNo);
            repeat
                NewGSTLedgerEntry.Init();
                NewGSTLedgerEntry.TransferFields(GSTLedgerEntry);
                NewGSTLedgerEntry."Entry No." := 0;
                NewGSTLedgerEntry."Reversed Entry No." := GSTLedgerEntry."Entry No.";
                NewGSTLedgerEntry."Transaction No." := NextTransactionNo;
                NewGSTLedgerEntry."GST Base Amount" := -NewGSTLedgerEntry."GST Base Amount";
                NewGSTLedgerEntry."GST Amount" := -NewGSTLedgerEntry."GST Amount";
                NewGSTLedgerEntry."Source Code" := SourceCodeSetup.Reversal;
                NewGSTLedgerEntry.Reversed := true;
                NewGSTLedgerEntry.Insert();

                GSTLedgerEntryToModify.Reset();
                GSTLedgerEntryToModify.SetRange("Entry No.", GSTLedgerEntry."Entry No.");
                GSTLedgerEntryToModify.FindFirst();
                GSTLedgerEntryToModify."Reversed by Entry No." := NewGSTLedgerEntry."Entry No.";
                GSTLedgerEntryToModify.Reversed := true;
                GSTLedgerEntryToModify.Modify();
            until GSTLedgerEntry.Next() = 0;
        end;
    end;

    local procedure ReverseDetailedGST(
        var DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        NextTransactionNo: Integer)
    var
        DetailedGSTLedgerEntryToModify: Record "Detailed GST Ledger Entry";
        NewDetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        DetailedGSTLedgerEntryInfoToCheck: Record "Detailed GST Ledger Entry Info";
        DetailedGSTLedgerEntryInfo: Record "Detailed GST Ledger Entry Info";
    begin
        if DetailedGSTLedgerEntry.FindSet() then
            repeat
                DetailedGSTLedgerEntry.TestField(Paid, false);
                if DetailedGSTLedgerEntry."Credit Adjustment Type" in [
                    DetailedGSTLedgerEntry."Credit Adjustment Type"::"Credit Reversal",
                    DetailedGSTLedgerEntry."Credit Adjustment Type"::"Permanent Reversal"]
                then
                    Error(ReverseDGSTErr);

                if DetailedGSTLedgerEntryInfoToCheck.Get(DetailedGSTLedgerEntry."Entry No.") then
                    DetailedGSTLedgerEntryInfoToCheck.TestField("Adv. Pmt. Adjustment", false);

                NewDetailedGSTLedgerEntry.Init();
                NewDetailedGSTLedgerEntry.TransferFields(DetailedGSTLedgerEntry);
                NewDetailedGSTLedgerEntry."Entry No." := 0;
                NewDetailedGSTLedgerEntry."Reversed Entry No." := DetailedGSTLedgerEntry."Entry No.";
                NewDetailedGSTLedgerEntry."Transaction No." := NextTransactionNo;
                NewDetailedGSTLedgerEntry."Entry Type" := NewDetailedGSTLedgerEntry."Entry Type"::Application;
                NewDetailedGSTLedgerEntry."GST Base Amount" := -NewDetailedGSTLedgerEntry."GST Base Amount";
                NewDetailedGSTLedgerEntry."GST Amount" := -NewDetailedGSTLedgerEntry."GST Amount";
                NewDetailedGSTLedgerEntry."Remaining Base Amount" := -NewDetailedGSTLedgerEntry."Remaining Base Amount";
                NewDetailedGSTLedgerEntry."Remaining GST Amount" := -NewDetailedGSTLedgerEntry."Remaining GST Amount";
                NewDetailedGSTLedgerEntry."Amount Loaded on Item" := -NewDetailedGSTLedgerEntry."Amount Loaded on Item";
                NewDetailedGSTLedgerEntry.Quantity := -NewDetailedGSTLedgerEntry.Quantity;
                NewDetailedGSTLedgerEntry.Reversed := true;
                NewDetailedGSTLedgerEntry.Insert();

                DetailedGSTLedgerEntryInfo.Init();
                DetailedGSTLedgerEntryInfo.TransferFields(DetailedGSTLedgerEntryInfoToCheck);
                DetailedGSTLedgerEntryInfo."Entry No." := NewDetailedGSTLedgerEntry."Entry No.";
                if DetailedGSTLedgerEntryInfoToCheck.Positive then
                    DetailedGSTLedgerEntryInfo.Positive := false
                else
                    DetailedGSTLedgerEntryInfo.Positive := true;
                DetailedGSTLedgerEntryInfo.Insert();

                DetailedGSTLedgerEntryToModify.Reset();
                DetailedGSTLedgerEntryToModify.SetRange("Entry No.", DetailedGSTLedgerEntry."Entry No.");
                DetailedGSTLedgerEntryToModify.FindFirst();
                DetailedGSTLedgerEntryToModify."Reversed by Entry No." := NewDetailedGSTLedgerEntry."Entry No.";
                DetailedGSTLedgerEntryToModify.Reversed := true;
                DetailedGSTLedgerEntryToModify.Modify();
            until DetailedGSTLedgerEntry.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Reverse", 'OnReverseOnBeforeStartPosting', '', false, false)]
    local procedure GenJnlPostReverseOnReverseOnBeforeStartPosting(
        var GenJournalLine: Record "Gen. Journal Line";
        var ReversalEntry: Record "Reversal Entry")
    var
        GSTReverseTransSessionMgt: Codeunit "GST Reverse Trans. Session Mgt";
    begin
        GSTReverseTransSessionMgt.SetReversalEntry(ReversalEntry);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Reverse", 'OnAfterPostReverse', '', false, false)]
    local procedure GenJnlPostReverseOnAfterPostReverse(var GenJournalLine: Record "Gen. Journal Line")
    var
        TempReversalEntry: Record "Reversal Entry" temporary;
        GSTLedgerEntry: Record "GST Ledger Entry";
        GSTReverseTransSessionMgt: Codeunit "GST Reverse Trans. Session Mgt";
        NextTransactionNo: Integer;
    begin
        GSTReverseTransSessionMgt.GetReversalEntry(TempReversalEntry, NextTransactionNo);
        TempReversalEntry.Reset();
        if TempReversalEntry.FindSet() then
            repeat
                if TempReversalEntry."Reversal Type" = TempReversalEntry."Reversal Type"::Transaction then begin
                    GSTLedgerEntry.Reset();
                    GSTLedgerEntry.SetRange("Transaction No.", TempReversalEntry."Transaction No.");
                    if GSTLedgerEntry.FindSet() then
                        ReverseGST(GSTLedgerEntry, NextTransactionNo);
                end;
            until TempReversalEntry.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnContinuePostingOnBeforeCalculateCurrentBalance', '', false, false)]
    local procedure OnContinuePostingOnBeforeCalculateCurrentBalance(
        var GenJournalLine: Record "Gen. Journal Line";
        var NextTransactionNo: Integer)
    var
        GSTReverseTransSessionMgt: Codeunit "GST Reverse Trans. Session Mgt";
    begin
        GSTReverseTransSessionMgt.SetReversalNextTransactionNo(NextTransactionNo);
    end;
}