codeunit 5154 "Create Svc Item Journal"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        SourceCodeSetup: Record "Source Code Setup";
        ContosoItem: Codeunit "Contoso Item";
    begin
        SourceCodeSetup.Get();

        ContosoItem.InsertItemJournalTemplate(ItemTemplate(), ItemJournalTok, "Item Journal Template Type"::Item, false, SourceCodeSetup."Item Journal");

        ContosoItem.InsertItemJournalBatch(ItemTemplate(), StartServiceBatch(), StartServiceDescriptionTok);
    end;

    var
        ItemTok: Label 'ITEM', MaxLength = 10;
        ItemJournalTok: Label 'Item Journal', MaxLength = 80;
        StartServiceTok: Label 'START-SVC', MaxLength = 10;
        StartServiceDescriptionTok: Label 'Start Service', MaxLength = 80;

    procedure ItemTemplate(): Code[10]
    begin
        exit(ItemTok);
    end;

    procedure StartServiceBatch(): Code[10]
    begin
        exit(StartServiceTok);
    end;
}