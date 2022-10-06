codeunit 31438 "Std. Item Journal Handler CZA"
{
    Access = Internal;

    [EventSubscriber(ObjectType::Report, Report::"Save as Standard Item Journal", 'OnBeforeInsertStandardItemJournalLine', '', false, false)]
    local procedure ClearNewLocationOnBeforeInsertStandardItemJournalLine(var StdItemJnlLine: Record "Standard Item Journal Line"; ItemJnlLine: Record "Item Journal Line")
    begin
        if ItemJnlLine."Entry Type" <> ItemJnlLine."Entry Type"::Transfer then
#if not CLEAN21
#pragma warning disable AL0432
            StdItemJnlLine."New Location Code" := '';
#pragma warning restore AL0432
#else
            StdItemJnlLine."New Location Code CZA" := '';
#endif
    end;
}
