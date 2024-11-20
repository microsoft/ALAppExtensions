codeunit 11093 "Create DE Inv. Posting Setup"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Inventory Posting Setup", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertInventoryPostingSetup(var Rec: Record "Inventory Posting Setup")
    var
        CreateLocation: Codeunit "Create Location";
        CreateDEGLAccount: Codeunit "Create DE GL Acc.";
    begin
        case Rec."Location Code" of
            CreateLocation.EastLocation():
                ValidateInventoryPostingSetup(Rec, CreateDEGLAccount.GoodsforResale(), CreateDEGLAccount.GoodsforResale());
            CreateLocation.MainLocation():
                ValidateInventoryPostingSetup(Rec, CreateDEGLAccount.GoodsforResale(), CreateDEGLAccount.GoodsforResale());
            CreateLocation.OutLogLocation():
                ValidateInventoryPostingSetup(Rec, CreateDEGLAccount.GoodsforResale(), CreateDEGLAccount.GoodsforResale());
            CreateLocation.OwnLogLocation():
                ValidateInventoryPostingSetup(Rec, CreateDEGLAccount.GoodsforResale(), CreateDEGLAccount.GoodsforResale());
            CreateLocation.WestLocation():
                ValidateInventoryPostingSetup(Rec, CreateDEGLAccount.GoodsforResale(), CreateDEGLAccount.GoodsforResale());
            '':
                ValidateInventoryPostingSetup(Rec, CreateDEGLAccount.GoodsforResale(), '');
        end;
    end;

    local procedure ValidateInventoryPostingSetup(var InventoryPostingSetup: Record "Inventory Posting Setup"; InventoryAccount: Code[20]; InventoryAccountInterim: Code[20])
    begin
        InventoryPostingSetup.Validate("Inventory Account", InventoryAccount);
        InventoryPostingSetup.Validate("Inventory Account (Interim)", InventoryAccountInterim);
    end;
}