codeunit 6090 "FA Ledger Entries Scan"
{
    trigger OnRun()
    begin
        FindEntriesForRoundng();
    end;

    local procedure FindEntriesForRoundng()
    var
        FALedgerEntry: Record "FA Ledger Entry";
        FALedgEntryWIssues: Record "FA Ledg. Entry w. Issue";
        FASetup: Record "FA Setup";
        Currency: Record Currency;
        EntryFound: Boolean;
    begin
        FASetup.LockTable();
        if not FASetup.get() then
            exit;
        FASetup."Last time scanned" := CurrentDateTime;
        FASetup.Modify();
        Commit(); // Clear the lock on FA Setup
        CLEAR(Currency);
        Currency.InitRoundingPrecision();
        Session.LogMessage('0000EUE', ScanFALedgerEntriesStartTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', TelemetryCategoryTxt);
        FALedgerEntry.SetFilter("Entry No.", '%1..', FASetup.LastEntryNo);
        if FALedgerEntry.FindSet() then
            repeat
                if FALedgerEntry.Amount <> Round(FALedgerEntry.Amount, Currency."Amount Rounding Precision") then begin
                    if FALedgEntryWIssues.get(FALedgerEntry."Entry No.") then
                        FALedgEntryWIssues.Delete();
                    FALedgEntryWIssues.TransferFields(FALedgerEntry);
                    FALedgEntryWIssues.Insert();
                    EntryFound := true;
                end;
            until FALedgerEntry.Next() = 0;
        if EntryFound then
            Session.LogMessage('0000EUF', ScanFALedgerEntriesStartTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', TelemetryCategoryTxt);

        if FALedgerEntry."Entry No." > FASetup.LastEntryNo then begin
            FASetup.LastEntryNo := FALedgerEntry."Entry No." + 1;
            if FASetup.Modify() then;
        end;
    end;



    var
        ScanFALedgerEntriesStartTxt: Label 'Scan FA Ledger entries start.', Locked = true;
        TelemetryCategoryTxt: Label 'AL FA Ledger Entry', Locked = true;

}