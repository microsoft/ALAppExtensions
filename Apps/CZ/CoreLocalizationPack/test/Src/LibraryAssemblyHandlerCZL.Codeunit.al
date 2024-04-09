codeunit 148117 "Library Assembly Handler CZL"
{
    var
        LibraryERM: Codeunit "Library - ERM";

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Library - Assembly", 'OnBeforeInsertInventoryPostingSetup', '', false, false)]
    local procedure OnBeforeInsertInventoryPostingSetup(var InventoryPostingSetup: Record "Inventory Posting Setup")
    begin
        InventoryPostingSetup."Consumption Account CZL" := LibraryERM.CreateGLAccountNo();
        InventoryPostingSetup."Change In Inv.Of WIP Acc. CZL" := LibraryERM.CreateGLAccountNo();
        InventoryPostingSetup."Change In Inv.OfProd. Acc. CZL" := LibraryERM.CreateGLAccountNo();
    end;
}