codeunit 5198 "Create Job Item Journal"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        SourceCodeSetup: Record "Source Code Setup";
        JobsModuleSetup: Record "Jobs Module Setup";
        ContosoItem: Codeunit "Contoso Item";
        ContosoUtilities: Codeunit "Contoso Utilities";
        ContosoPostingSetup: Codeunit "Contoso Posting Setup";
        CommonGLAccount: Codeunit "Create Common GL Account";
        CommonPostingGroup: Codeunit "Create Common Posting Group";
    begin
        SourceCodeSetup.Get();
        JobsModuleSetup.Get();

        ContosoItem.InsertItemJournalTemplate(ItemTemplate(), ItemJournalLbl, Enum::"Item Journal Template Type"::Item, false, SourceCodeSetup."Item Journal");

        ContosoItem.InsertItemJournalBatch(ItemTemplate(), ContosoUtilities.GetDefaultBatchNameLbl(), '');
        ContosoPostingSetup.InsertInventoryPostingSetup(JobsModuleSetup."Job Location", CommonPostingGroup.Resale(), CommonGLAccount.Resale(), CommonGLAccount.ResaleInterim());
    end;

    var
        ItemTok: Label 'ITEM', MaxLength = 10;
        ItemJournalLbl: Label 'Item Journal', MaxLength = 80;
        StartJobTok: Label 'START-PROJ', MaxLength = 10;

    procedure ItemTemplate(): Code[10]
    begin
        exit(ItemTok);
    end;

    procedure StartJobBatch(): Code[10]
    begin
        exit(StartJobTok);
    end;
}