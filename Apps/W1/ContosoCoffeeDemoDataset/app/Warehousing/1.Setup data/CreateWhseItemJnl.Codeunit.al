codeunit 4789 "Create Whse Item Jnl"
{
    Permissions = tabledata "Item Journal Template" = rim,
        tabledata "Item Journal Batch" = rim,
        tabledata "Warehouse Journal Template" = rim;

    var
        WhseDemoDataSetup: Record "Whse Demo Data Setup";

    trigger OnRun()
    begin
        WhseDemoDataSetup.Get();

        CreateItemJournal();
        OnAfterCreatedItemJournal();
    end;

    local procedure CreateItemJournal()
    var
        ItemJournalTemplate: Record "Item Journal Template";
        ItemJournalLine: Record "Item Journal Line";
        ItemJnlManagement: Codeunit ItemJnlManagement;
        ItemJnlBatchName: Code[10];
        JnlSelected: Boolean;
    begin
        ItemJnlManagement.TemplateSelection(PAGE::"Item Journal", 0, false, ItemJournalLine, JnlSelected);
        if ItemJournalTemplate.FindFirst() then
            ItemJnlManagement.CheckTemplateName(ItemJournalTemplate.Name, ItemJnlBatchName);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreatedItemJournal()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreatedWhseItemJournal()
    begin
    end;
}
