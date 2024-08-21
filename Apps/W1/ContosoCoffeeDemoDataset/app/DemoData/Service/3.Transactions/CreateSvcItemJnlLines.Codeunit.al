codeunit 5110 "Create Svc Item Jnl Lines"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        SvcDemoDataSetup: Record "Service Module Setup";
        ItemJournalBatch: Record "Item Journal Batch";
        ItemJournalTemplate: Record "Item Journal Template";
        ItemJournalLine: Record "Item Journal Line";
        ContosoUtilities: Codeunit "Contoso Utilities";
        CreateSvcItemJournal: Codeunit "Create Svc Item Journal";

    trigger OnRun()
    var
        ContosoItem: Codeunit "Contoso Item";
    begin
        SvcDemoDataSetup.Get();

        ItemJournalTemplate.Get(CreateSvcItemJournal.ItemTemplate());
        ItemJournalBatch.Get(ItemJournalTemplate.Name, ContosoUtilities.GetDefaultBatchNameLbl());

        ContosoItem.InsertItemJournalLine(ItemJournalTemplate.Name, ItemJournalBatch.Name, SvcDemoDataSetup."Item 1 No.", '', Enum::"Item Ledger Entry Type"::"Positive Adjmt.", 10, SvcDemoDataSetup."Service Location", ContosoUtilities.AdjustDate(19020601D));

        ItemJournalLine.SetRange("Journal Template Name", ItemJournalTemplate.Name);
        ItemJournalLine.SetRange("Journal Batch Name", ItemJournalBatch.Name);
        if ItemJournalLine.FindFirst() then
            CODEUNIT.Run(CODEUNIT::"Item Jnl.-Post Batch", ItemJournalLine);
    end;
}