codeunit 5198 "Create Job Item Journal"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        SourceCodeSetup: Record "Source Code Setup";
        ContosoItem: Codeunit "Contoso Item";
    begin
        SourceCodeSetup.Get();

        ContosoItem.InsertItemJournalTemplate(ItemTemplate(), ItemJournalLbl, Enum::"Item Journal Template Type"::Item, false, SourceCodeSetup."Item Journal");

        ContosoItem.InsertItemJournalBatch(ItemTemplate(), StartJobBatch(), StartJobDescriptionLbl);
    end;

    var
        ItemTok: Label 'ITEM', MaxLength = 10;
        ItemJournalLbl: Label 'Item Journal', MaxLength = 80;
        StartJobTok: Label 'START-PROJ', MaxLength = 10;
        StartJobDescriptionLbl: Label 'Start Projects', MaxLength = 100;

    procedure ItemTemplate(): Code[10]
    begin
        exit(ItemTok);
    end;

    procedure StartJobBatch(): Code[10]
    begin
        exit(StartJobTok);
    end;
}