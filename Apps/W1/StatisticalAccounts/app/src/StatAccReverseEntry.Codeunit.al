codeunit 2630 "Stat. Acc. Reverse Entry"
{
    [EventSubscriber(ObjectType::Table, Database::"Reversal Entry", 'OnBeforeReverseEntries', '', false, false)]
    local procedure HandleOnBeforeInsertReversalEntry(Number: Integer; RevType: Integer; var IsHandled: Boolean; HideDialog: Boolean; var ReversalEntry: Record "Reversal Entry")
    var
        TempReversalEntry: Record "Reversal Entry" temporary;
        StatAccReverseEntries: Page "Stat. Acc. Reverse Entries";
        RevTypeDefinition: Option Transaction,Register;
    begin
        if ReversalEntry."Entry Type" <> ReversalEntry."Entry Type"::"Statistical Account" then
            exit;

        IsHandled := true;
        if RevType = RevTypeDefinition::Register then
            Error(RegisterTypeIsNotSupportedErr);

        InsertReversalEntry(Number, TempReversalEntry, RevType);
        TempReversalEntry.SetCurrentKey("Document No.", "Posting Date", "Entry Type", "Entry No.");
        if not HideDialog then begin
            StatAccReverseEntries.SetReversalEntries(TempReversalEntry);
            StatAccReverseEntries.RunModal();
        end else
            PostReversal(TempReversalEntry);
    end;

    internal procedure PostReversal(ReversalEntry: Record "Reversal Entry")
    var
        StatisticalLedgerEntry: Record "Statistical Ledger Entry";
        LastStatisticalLedgerEntry: Record "Statistical Ledger Entry";
        ReversedStatisticalLedgerEntry: Record "Statistical Ledger Entry";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        StatAccTelemetry: Codeunit "Stat. Acc. Telemetry";
        TransactionNumber: Integer;
        NextEntryNo: Integer;
    begin
        if ReversalEntry."Entry Type" <> ReversalEntry."Entry Type"::"Statistical Account" then
            exit;

        LastStatisticalLedgerEntry.LockTable();
        if LastStatisticalLedgerEntry.FindLast() then begin
            TransactionNumber := LastStatisticalLedgerEntry."Transaction No." + 1;
            NextEntryNo := LastStatisticalLedgerEntry."Entry No." + 1;
        end;

        FeatureTelemetry.LogUptake('0000KE2', StatAccTelemetry.GetFeatureTelemetryName(), Enum::"Feature Uptake Status"::Used);
        FeatureTelemetry.LogUsage('0000KE3', StatAccTelemetry.GetFeatureTelemetryName(), 'Posting reverse transaction for Statistical Accounts');

        StatisticalLedgerEntry.SetRange("Transaction No.", ReversalEntry."Transaction No.");
        if StatisticalLedgerEntry.FindSet() then
            repeat
                ReversedStatisticalLedgerEntry := StatisticalLedgerEntry;
                ReversedStatisticalLedgerEntry.Amount := -StatisticalLedgerEntry.Amount;
                ReversedStatisticalLedgerEntry."Entry No." := NextEntryNo;
                ReversedStatisticalLedgerEntry."Transaction No." := TransactionNumber;
                ReversedStatisticalLedgerEntry.Reversed := true;
                ReversedStatisticalLedgerEntry."Reversed Entry No." := StatisticalLedgerEntry."Entry No.";
                SetReversalDescription(StatisticalLedgerEntry, ReversedStatisticalLedgerEntry.Description);
                ReversedStatisticalLedgerEntry.Insert();
                NextEntryNo += 1;

                StatisticalLedgerEntry."Reversed by Entry No." := ReversedStatisticalLedgerEntry."Entry No.";
                StatisticalLedgerEntry.Reversed := true;
                StatisticalLedgerEntry.Modify();
            until StatisticalLedgerEntry.Next() = 0;
        Commit();
    end;

    local procedure InsertReversalEntry(Number: Integer; var TempReversalEntry: Record "Reversal Entry" temporary; RevType: Integer)
    var
        StatisticalLedgerEntry: Record "Statistical Ledger Entry";
        StatisticalAccount: Record "Statistical Account";
        NextLineNo: Integer;
    begin
        TempReversalEntry.DeleteAll();
        NextLineNo := 1;
        StatisticalLedgerEntry.SetRange("Transaction No.", Number);

        if StatisticalLedgerEntry.FindSet() then
            repeat
                Clear(TempReversalEntry);
                TempReversalEntry."Reversal Type" := RevType;
                TempReversalEntry."Entry Type" := TempReversalEntry."Entry Type"::"Statistical Account";
                if not StatisticalAccount.Get(StatisticalLedgerEntry."Statistical Account No.") then
                    Error(CannotReverseDeletedErr, StatisticalAccount.TableCaption());
                TempReversalEntry."Account No." := StatisticalAccount."No.";
                TempReversalEntry."Account Name" := StatisticalAccount.Name;
                TempReversalEntry."Entry No." := StatisticalLedgerEntry."Entry No.";
                TempReversalEntry."Posting Date" := StatisticalLedgerEntry."Posting Date";
                TempReversalEntry."Transaction No." := StatisticalLedgerEntry."Transaction No.";
                TempReversalEntry.Description := StatisticalLedgerEntry.Description;
                TempReversalEntry.Amount := StatisticalLedgerEntry.Amount;
                TempReversalEntry."Document No." := StatisticalLedgerEntry."Document No.";
                TempReversalEntry."Line No." := NextLineNo;
                NextLineNo := NextLineNo + 1;
                TempReversalEntry.Insert();
            until StatisticalLedgerEntry.Next() = 0;
    end;

    internal procedure SetReversalDescription(StatisticalLedgerEntry: Record "Statistical Ledger Entry"; var Description: Text[100])
    var
        ReversalEntry: Record "Reversal Entry";
    begin
        ReversalEntry.SetRange("Entry Type", ReversalEntry."Entry Type"::"Statistical Account");
        ReversalEntry.SetRange("Entry No.", StatisticalLedgerEntry."Entry No.");

        if ReversalEntry.FindFirst() then
            Description := ReversalEntry.Description;
    end;

    var
        RegisterTypeIsNotSupportedErr: Label 'Register type is not supported for statistical accounts';
        CannotReverseDeletedErr: Label 'The transaction cannot be reversed because %1 has been deleted.', Comment = '%1 table caption';
}