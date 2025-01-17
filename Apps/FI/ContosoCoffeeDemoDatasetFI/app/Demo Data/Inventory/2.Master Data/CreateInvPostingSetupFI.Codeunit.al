codeunit 13426 "Create Inv. Posting Setup FI"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Inventory Posting Setup", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertInvPostingSetup(var Rec: Record "Inventory Posting Setup")
    var
        CreateInvPostingGroup: Codeunit "Create Inventory Posting Group";
        CreateFIGLAccounts: Codeunit "Create FI GL Accounts";
    begin
        case Rec."Invt. Posting Group Code" of
            CreateInvPostingGroup.Resale():
                ValidateRecordFields(Rec, CreateFIGLAccounts.Itemsandsupplies4(), CreateFIGLAccounts.Itemsandsupplies5());
        end;
    end;

    local procedure ValidateRecordFields(var InventoryPostingSetup: Record "Inventory Posting Setup"; InventoryAccount: Code[20]; InventoryAccountInterim: Code[20])
    begin
        InventoryPostingSetup.Validate("Inventory Account", InventoryAccount);
        InventoryPostingSetup.Validate("Inventory Account (Interim)", InventoryAccountInterim);
    end;
}