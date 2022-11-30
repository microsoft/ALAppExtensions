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

        CreateWhseItemJournal();
        OnAfterCreatedWhseItemJournal();
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

    local procedure CreateWhseItemJournal()
    var
        WarehouseJournalLine: Record "Warehouse Journal Line";
        WarehouseJournalTemplate: Record "Warehouse Journal Template";
        WhseJnlBatchName: Code[10];
    begin
        WarehouseJournalLine.TemplateSelection(PAGE::"Whse. Item Journal", "Warehouse Journal Template Type"::Item, WarehouseJournalLine);
        if WarehouseJournalTemplate.FindFirst() then begin
            WarehouseJournalLine.CheckTemplateName(WarehouseJournalTemplate.Name, WhseDemoDataSetup."Location Basic", WhseJnlBatchName);
            WarehouseJournalLine.CheckTemplateName(WarehouseJournalTemplate.Name, WhseDemoDataSetup."Location Simple Logistics", WhseJnlBatchName);
            WarehouseJournalLine.CheckTemplateName(WarehouseJournalTemplate.Name, WhseDemoDataSetup."Location Advanced Logistics", WhseJnlBatchName);
        end;
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
