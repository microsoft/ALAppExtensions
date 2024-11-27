codeunit 11505 "Create GB Inv Posting Setup"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Inventory Posting Setup", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnInsertRecord(var Rec: Record "Inventory Posting Setup"; RunTrigger: Boolean)
    var
        CreateInventoryPostingGroup: Codeunit "Create Inventory Posting Group";
        CreateLocation: Codeunit "Create Location";
        CreateGBGLAccounts: Codeunit "Create GB GL Accounts";
    begin
        case Rec."Location Code" of
            BlankLocationLbl,
            CreateLocation.EastLocation(),
            CreateLocation.MainLocation(),
            CreateLocation.OutLogLocation(),
            CreateLocation.OwnLogLocation(),
            CreateLocation.WestLocation():
                if Rec."Invt. Posting Group Code" = CreateInventoryPostingGroup.Resale() then
                    ValidateRecordFields(Rec, CreateGBGLAccounts.GoodsForResale(), '');
        end;
    end;

    local procedure ValidateRecordFields(var InventoryPostingSetup: Record "Inventory Posting Setup"; InventoryAccount: Code[20]; InventoryAccountInterim: Code[20])
    begin
        InventoryPostingSetup.Validate("Inventory Account", InventoryAccount);
        InventoryPostingSetup.Validate("Inventory Account (Interim)", InventoryAccountInterim)
    end;

    var
        BlankLocationLbl: Label '', MaxLength = 10;
}