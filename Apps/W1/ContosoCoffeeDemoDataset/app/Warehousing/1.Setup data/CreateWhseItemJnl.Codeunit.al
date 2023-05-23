codeunit 4789 "Create Whse Item Jnl"
{
    Permissions = tabledata "Item Journal Template" = ri,
        tabledata "Item Journal Batch" = ri,
        tabledata "Warehouse Journal Template" = ri;

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
        ItemJnlManagement: Codeunit ItemJnlManagement;
        ItemJnlBatchName: Code[10];
    begin
        ItemJournalTemplate.SetRange("Page ID", PAGE::"Item Journal");
        ItemJournalTemplate.SetRange(Recurring, false);
        ItemJournalTemplate.SetRange(Type, ItemJournalTemplate.Type::Item);

        if ItemJournalTemplate.FindFirst() then
            ItemJnlManagement.CheckTemplateName(ItemJournalTemplate.Name, ItemJnlBatchName);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreatedItemJournal()
    begin
    end;
}
