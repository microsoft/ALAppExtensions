codeunit 148114 "Library Inventory Handler CZL"
{
    var
        LibraryERM: Codeunit "Library - ERM";

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Library - Inventory", 'OnBeforeModifyInventoryPostingSetup', '', false, false)]
    local procedure OnBeforeModifyInventoryPostingSetup(var InventoryPostingSetup: Record "Inventory Posting Setup")
    begin
        InventoryPostingSetup."Consumption Account CZL" := LibraryERM.CreateGLAccountNo();
        InventoryPostingSetup."Change In Inv.Of WIP Acc. CZL" := LibraryERM.CreateGLAccountNo();
        InventoryPostingSetup."Change In Inv.OfProd. Acc. CZL" := LibraryERM.CreateGLAccountNo();
    end;
}