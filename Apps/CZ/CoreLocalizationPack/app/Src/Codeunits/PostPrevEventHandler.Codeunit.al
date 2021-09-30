#pragma warning disable AL0432
codeunit 31113 "Post. Prev. Event Handler CZL"
{
    var
        TempEETEntryCZL: Record "EET Entry CZL" temporary;
        TempEETEntryStatusLogCZL: Record "EET Entry Status Log CZL" temporary;
        TempErrorMessage: Record "Error Message" temporary;
        PostingPreviewEventHandler: Codeunit "Posting Preview Event Handler";

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Posting Preview Event Handler", 'OnGetEntries', '', false, false)]
    local procedure GetEntriesOnGetEntries(TableNo: Integer; var RecRef: RecordRef)
    begin
        GetAllTables();
        case TableNo of
            DATABASE::"EET Entry CZL":
                RecRef.GetTable(TempEETEntryCZL);
            DATABASE::"EET Entry Status Log CZL":
                RecRef.GetTable(TempEETEntryStatusLogCZL);
            DATABASE::"Error Message":
                RecRef.GetTable(TempErrorMessage);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Posting Preview Event Handler", 'OnAfterShowEntries', '', false, false)]
    local procedure ShowEntriesOnAfterShowEntries(TableNo: Integer)
    var
        EETEntryPreviewCardCZL: Page "EET Entry Preview Card CZL";
    begin
        GetAllTables();
        case TableNo of
            DATABASE::"EET Entry CZL":
                begin
                    EETEntryPreviewCardCZL.Set(TempEETEntryCZL, TempEETEntryStatusLogCZL, TempErrorMessage);
                    EETEntryPreviewCardCZL.Run();
                    Clear(EETEntryPreviewCardCZL);
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Posting Preview Event Handler", 'OnAfterFillDocumentEntry', '', false, false)]
    local procedure FillDocumentEntryOnAfterFillDocumentEntry(var DocumentEntry: Record "Document Entry")
    begin
        GetAllTables();
#if not CLEAN18
        DeleteObsoleteTables(DocumentEntry);
#endif
        PostingPreviewEventHandler.InsertDocumentEntry(TempEETEntryCZL, DocumentEntry);
    end;

#if not CLEAN18
    [Obsolete('Moved to Core Localization for Czech.', '18.0')]
    local procedure DeleteObsoleteTables(var DocumentEntry: Record "Document Entry")
    var
        DummyDocumentEntry: Record "Document Entry";
    begin
        DummyDocumentEntry.CopyFilters(DocumentEntry);
        DocumentEntry.Reset();
        DocumentEntry.SetFilter("Table ID", '%1|%2', Database::"EET Entry", Database::"EET Entry Status");
        DocumentEntry.DeleteAll();
        DocumentEntry.CopyFilters(DummyDocumentEntry);
    end;

#endif
    local procedure GetAllTables()
    var
        PostPrevTableHandlerCZL: Codeunit "Post. Prev. Table Handler CZL";
    begin
        PostPrevTableHandlerCZL.GetTempEETEntryCZL(TempEETEntryCZL);
        PostPrevTableHandlerCZL.GetTempEETEntryStatusLogCZL(TempEETEntryStatusLogCZL);
        PostPrevTableHandlerCZL.GetTempErrorMessage(TempErrorMessage);
    end;
}