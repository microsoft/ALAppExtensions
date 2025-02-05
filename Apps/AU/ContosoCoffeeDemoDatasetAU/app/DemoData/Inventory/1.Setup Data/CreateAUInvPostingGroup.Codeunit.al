codeunit 17117 "Create AU Inv Posting Group"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoPostingGroup: Codeunit "Contoso Posting Group";
    begin
        ContosoPostingGroup.SetOverwriteData(true);
        ContosoPostingGroup.InsertInventoryPostingGroup(Finished(), FinishedItemsLbl);
        ContosoPostingGroup.InsertInventoryPostingGroup(RAWMAT(), RawMaterialsLbl);
        ContosoPostingGroup.SetOverwriteData(false);
    end;

    procedure Finished(): Code[20]
    begin
        exit(FinishedTok);
    end;

    procedure RAWMAT(): Code[20]
    begin
        exit(RAWMATTok);
    end;

    var
        FinishedTok: Label 'FINISHED', MaxLength = 20;
        FinishedItemsLbl: Label 'Finished items', MaxLength = 100;
        RAWMATTok: Label 'RAW MAT', MaxLength = 20;
        RawMaterialsLbl: Label 'Raw materials', MaxLength = 100;
}