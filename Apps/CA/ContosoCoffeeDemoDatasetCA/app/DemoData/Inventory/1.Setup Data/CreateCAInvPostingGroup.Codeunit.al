codeunit 27061 "Create CA Inv. Posting Group"
{

    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoPostingGroup: Codeunit "Contoso Posting Group";
    begin
        ContosoPostingGroup.InsertInventoryPostingGroup(RawMaterial(), RawMaterialsLbl);
        ContosoPostingGroup.InsertInventoryPostingGroup(Finished(), FinishedItemsLbl);
    end;

    procedure RawMaterial(): Code[20]
    begin
        exit(RawMaterialTok);
    end;

    procedure Finished(): Code[20]
    begin
        exit(FinishedTok);
    end;

    var
        RawMaterialTok: Label 'RAW MAT', MaxLength = 20;
        RawMaterialsLbl: Label 'Raw materials', MaxLength = 100;
        FinishedTok: Label 'FINISHED', MaxLength = 20;
        FinishedItemsLbl: Label 'Finished items', MaxLength = 100;
}