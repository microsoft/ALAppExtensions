codeunit 11530 "Create Inv. Posting Setup NL"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Inventory Posting Setup", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertInventoryPostingSetup(var Rec: Record "Inventory Posting Setup")
    var
        CreateLocation: Codeunit "Create Location";
        CreateGLAccount: Codeunit "Create G/L Account";
        CreateNLGLAccounts: Codeunit "Create NL GL Accounts";
    begin
        case Rec."Location Code" of
            CreateLocation.EastLocation():
                ValidateInventoryPostingSetup(Rec, CreateNLGLAccounts.GoodsforResale(), CreateNLGLAccounts.GoodsforResale());
            CreateLocation.MainLocation():
                ValidateInventoryPostingSetup(Rec, CreateNLGLAccounts.GoodsforResale(), CreateNLGLAccounts.GoodsforResale());
            CreateLocation.OutLogLocation():
                ValidateInventoryPostingSetup(Rec, CreateNLGLAccounts.GoodsforResale(), CreateNLGLAccounts.GoodsforResale());
            CreateLocation.OwnLogLocation():
                ValidateInventoryPostingSetup(Rec, CreateNLGLAccounts.GoodsforResale(), CreateNLGLAccounts.GoodsforResale());
            CreateLocation.WestLocation():
                ValidateInventoryPostingSetup(Rec, CreateNLGLAccounts.GoodsforResale(), CreateNLGLAccounts.GoodsforResale());
            '':
                ValidateInventoryPostingSetup(Rec, CreateGLAccount.FinishedGoods(), '');
        end;
    end;

    local procedure ValidateInventoryPostingSetup(var InventoryPostingSetup: Record "Inventory Posting Setup"; InventoryAccount: Code[20]; InventoryAccountInterim: Code[20])
    begin
        InventoryPostingSetup.Validate("Inventory Account", InventoryAccount);
        InventoryPostingSetup.Validate("Inventory Account (Interim)", InventoryAccountInterim);
    end;
}