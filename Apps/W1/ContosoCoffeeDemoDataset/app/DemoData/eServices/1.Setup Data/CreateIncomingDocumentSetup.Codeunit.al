codeunit 5232 "Create Incoming Document Setup"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoEServices: Codeunit "Contoso eServices";
        CreateGenJournalTemplate: Codeunit "Create Gen. Journal Template";
        CreateGenJournalBatch: Codeunit "Create Gen. Journal Batch";
    begin
        ContosoEServices.InsertEServicesIncomingDocumentSetup(CreateGenJournalTemplate.General(), CreateGenJournalBatch.Default(), false, false);
    end;
}