codeunit 5189 "Create Job Item Jnl Lines"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        JobsModuleSetup: Record "Jobs Module Setup";
        CreateJobItemJournal: Codeunit "Create Job Item Journal";
        ContosoUtilities: Codeunit "Contoso Utilities";
        ContosoItem: Codeunit "Contoso Item";
    begin
        JobsModuleSetup.Get();

        ContosoItem.InsertItemJournalLine(CreateJobItemJournal.ItemTemplate(), CreateJobItemJournal.StartJobBatch(), JobsModuleSetup."Item Machine No.", CreateJobItemJournal.StartJobBatch(), Enum::"Item Ledger Entry Type"::"Positive Adjmt.", 10, JobsModuleSetup."Job Location", ContosoUtilities.AdjustDate(19020601D));
    end;
}