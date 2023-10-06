codeunit 5110 "Create Svc Item Jnl Lines"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        SvcDemoDataSetup: Record "Service Module Setup";
        CreateSvcItemJournal: Codeunit "Create Svc Item Journal";
        ContosoUtilities: Codeunit "Contoso Utilities";

    trigger OnRun()
    var
        ContosoItem: Codeunit "Contoso Item";
    begin
        SvcDemoDataSetup.Get();

        ContosoItem.InsertItemJournalLine(CreateSvcItemJournal.ItemTemplate(), CreateSvcItemJournal.StartServiceBatch(), SvcDemoDataSetup."Item 1 No.", CreateSvcItemJournal.StartServiceBatch(), Enum::"Item Ledger Entry Type"::"Positive Adjmt.", 10, SvcDemoDataSetup."Service Location", ContosoUtilities.AdjustDate(19020601D));
    end;
}