codeunit 13725 "Create Inv. Posting Setup DK"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Inventory Posting Setup", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertInvPostingSetup(var Rec: Record "Inventory Posting Setup")
    var
        CreateInvPostingGroup: Codeunit "Create Inventory Posting Group";
        CreateGLAccountDK: Codeunit "Create GL Acc. DK";
    begin
        case Rec."Invt. Posting Group Code" of
            CreateInvPostingGroup.Resale():
                ValidateRecordFields(Rec, CreateGLAccountDK.InventoryPosting(), CreateGLAccountDK.InventoryPosting());
        end;
    end;

    local procedure ValidateRecordFields(var InventoryPostingSetup: Record "Inventory Posting Setup"; InventoryAccount: Code[20]; InventoryAccountInterim: Code[20])
    begin
        InventoryPostingSetup.Validate("Inventory Account", InventoryAccount);
        InventoryPostingSetup.Validate("Inventory Account (Interim)", InventoryAccountInterim);
    end;
}