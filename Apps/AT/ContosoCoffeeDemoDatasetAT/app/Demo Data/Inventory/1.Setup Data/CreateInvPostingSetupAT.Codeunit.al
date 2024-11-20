codeunit 11163 "Create Inv. Posting Setup AT"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Inventory Posting Setup", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertInvPostingSetup(var Rec: Record "Inventory Posting Setup")
    var
        CreateInvPostingGroup: Codeunit "Create Inventory Posting Group";
        CreateATGLAccount: Codeunit "Create AT GL Account";
    begin
        case Rec."Invt. Posting Group Code" of
            CreateInvPostingGroup.Resale():
                ValidateRecordFields(Rec, CreateATGLAccount.SupplyTradeGoods(), CreateATGLAccount.SupplyTradeGoodsInterim());
        end;
    end;

    local procedure ValidateRecordFields(var InventoryPostingSetup: Record "Inventory Posting Setup"; InventoryAccount: Code[20]; InventoryAccountInterim: Code[20])
    begin
        InventoryPostingSetup.Validate("Inventory Account", InventoryAccount);
        InventoryPostingSetup.Validate("Inventory Account (Interim)", InventoryAccountInterim);
    end;
}