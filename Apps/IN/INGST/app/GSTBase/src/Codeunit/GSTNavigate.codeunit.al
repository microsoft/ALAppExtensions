codeunit 18002 "GST Navigate"
{
    [EventSubscriber(ObjectType::Page, Page::Navigate, 'OnAfterNavigateFindRecords', '', false, false)]
    local procedure FindDetailedGSTEntries(
        var DocumentEntry: Record "Document Entry";
        DocNoFilter: Text;
        PostingDateFilter: Text)
    var
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        GSTLedgerEntry: Record "GST Ledger Entry";
        GSTTDSTCSEntry: Record "GST TDS/TCS Entry";
        Navigate: Page Navigate;
    begin
        if GSTLedgerEntry.ReadPermission() then begin
            GSTLedgerEntry.Reset();
            GSTLedgerEntry.SetCurrentKey("Document No.", "Posting Date");
            GSTLedgerEntry.SetFilter("Document No.", DocNoFilter);
            GSTLedgerEntry.SetFilter("Posting Date", PostingDateFilter);
            Navigate.InsertIntoDocEntry(
                DocumentEntry,
                Database::"GST Ledger Entry",
                0,
                CopyStr(GSTLedgerEntry.TableCaption(), 1, 1024),
                GSTLedgerEntry.Count());
        end;

        if DetailedGSTLedgerEntry.ReadPermission() then begin
            DetailedGSTLedgerEntry.Reset();
            DetailedGSTLedgerEntry.SetCurrentKey("Document No.", "Posting Date");
            DetailedGSTLedgerEntry.SetFilter("Document No.", DocNoFilter);
            DetailedGSTLedgerEntry.SetFilter("Posting Date", PostingDateFilter);
            Navigate.InsertIntoDocEntry(
                DocumentEntry,
                Database::"Detailed GST Ledger Entry",
                0,
                CopyStr(DetailedGSTLedgerEntry.TableCaption(), 1, 1024),
                DetailedGSTLedgerEntry.Count());
        end;

        if GSTTDSTCSEntry.ReadPermission() then begin
            GSTTDSTCSEntry.Reset();
            GSTTDSTCSEntry.SetCurrentKey("Document No.", "Posting Date");
            GSTTDSTCSEntry.SetFilter("Document No.", DocNoFilter);
            GSTTDSTCSEntry.SetFilter("Posting Date", PostingDateFilter);
            Navigate.InsertIntoDocEntry(
                DocumentEntry,
                Database::"GST TDS/TCS Entry",
                0,
                CopyStr(GSTTDSTCSEntry.TableCaption(), 1, 1024),
                GSTTDSTCSEntry.Count());
        end;
    end;
}