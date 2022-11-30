codeunit 4789 "Create Whse Item Jnl"
{
    Permissions = tabledata "Item Journal Template" = rim,
        tabledata "Item Journal Batch" = rim,
        tabledata "Warehouse Journal Template" = rim;

    var
        WhseDemoDataSetup: Record "Whse Demo Data Setup";
        DoInsertTriggers: Boolean;

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
        ItemJnlTemplate: Record "Item Journal Template";
        ItemJnlLine: Record "Item Journal Line";
        ItemJnlMgmt: Codeunit ItemJnlManagement;
        ItemJnlBatchName: Code[20];
        JnlSelected: Boolean;
    begin
        ItemJnlMgmt.TemplateSelection(PAGE::"Item Journal", 0, false, ItemJnlLine, JnlSelected);
        if ItemJnlTemplate.FindFirst() then
            ItemJnlMgmt.CheckTemplateName(ItemJnlTemplate.Name, ItemJnlBatchName);
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
