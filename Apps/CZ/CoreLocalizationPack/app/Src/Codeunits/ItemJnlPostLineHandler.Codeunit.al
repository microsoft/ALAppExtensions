codeunit 31047 "Item Jnl-Post Line Handler CZL"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", 'OnAfterInitItemLedgEntry', '', false, false)]
    local procedure CopyFieldsOnAfterInitItemLedgEntry(var NewItemLedgEntry: Record "Item Ledger Entry"; ItemJournalLine: Record "Item Journal Line"; var ItemLedgEntryNo: Integer)
    begin
        ItemJournalLine.CheckIntrastatCZL();
        NewItemLedgEntry."Tariff No. CZL" := ItemJournalLine."Tariff No. CZL";
        NewItemLedgEntry."Statistic Indication CZL" := ItemJournalLine."Statistic Indication CZL";
        NewItemLedgEntry."Net Weight CZL" := ItemJournalLine."Net Weight CZL";
        NewItemLedgEntry."Country/Reg. of Orig. Code CZL" := ItemJournalLine."Country/Reg. of Orig. Code CZL";
        NewItemLedgEntry."Intrastat Transaction CZL" := ItemJournalLine."Intrastat Transaction CZL";
        NewItemLedgEntry."Physical Transfer CZL" := ItemJournalLine."Physical Transfer CZL";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", 'OnAfterInitValueEntry', '', false, false)]
    local procedure CopyFieldsOnAfterInitValueEntry(var ValueEntry: Record "Value Entry"; ItemJournalLine: Record "Item Journal Line")
    begin
        ValueEntry."Incl. in Intrastat Amount CZL" := ItemJournalLine."Incl. in Intrastat Amount CZL";
        ValueEntry."Incl. in Intrastat S.Value CZL" := ItemJournalLine."Incl. in Intrastat S.Value CZL";
    end;
}