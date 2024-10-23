codeunit 5189 "Create Job Item Jnl Lines"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        JobsModuleSetup: Record "Jobs Module Setup";
        ItemJournalBatch: Record "Item Journal Batch";
        ItemJournalTemplate: Record "Item Journal Template";
        ItemJournalLine: Record "Item Journal Line";
        ContosoUtilities: Codeunit "Contoso Utilities";
        ContosoItem: Codeunit "Contoso Item";
        CreateJobItemJournal: Codeunit "Create Job Item Journal";
    begin
        JobsModuleSetup.Get();

        ItemJournalTemplate.Get(CreateJobItemJournal.ItemTemplate());
        ItemJournalBatch.Get(ItemJournalTemplate.Name, ContosoUtilities.GetDefaultBatchNameLbl());

        ContosoItem.InsertItemJournalLine(ItemJournalTemplate.Name, ItemJournalBatch.Name, JobsModuleSetup."Item Machine No.", '', Enum::"Item Ledger Entry Type"::"Positive Adjmt.", 10, JobsModuleSetup."Job Location", ContosoUtilities.AdjustDate(19020601D));

        ItemJournalLine.SetRange("Journal Template Name", ItemJournalTemplate.Name);
        ItemJournalLine.SetRange("Journal Batch Name", ItemJournalBatch.Name);
        if ItemJournalLine.FindFirst() then
            CODEUNIT.Run(CODEUNIT::"Item Jnl.-Post Batch", ItemJournalLine);
    end;
}