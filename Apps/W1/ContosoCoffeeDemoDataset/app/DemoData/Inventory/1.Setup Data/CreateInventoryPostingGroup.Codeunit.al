codeunit 5229 "Create Inventory Posting Group"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoPostingGroup: Codeunit "Contoso Posting Group";
    begin
        ContosoPostingGroup.InsertInventoryPostingGroup(Resale(), ResaleItemsLbl);
    end;

    procedure Resale(): Code[20]
    begin
        exit(ResaleTok);
    end;

    var
        ResaleItemsLbl: Label 'Resale items', MaxLength = 100;
        ResaleTok: Label 'RESALE', MaxLength = 20;
}