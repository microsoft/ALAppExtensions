codeunit 31078 "Item Journal Line Handler CZL"
{
    [EventSubscriber(ObjectType::Table, Database::"Item Journal Line", 'OnBeforeValidateEvent', 'Entry Type', false, false)]
    local procedure InvtMovementTemplateOnBeforeValidateEntryType(var Rec: Record "Item Journal Line"; CurrFieldNo: Integer)
    begin
        if (Rec."Invt. Movement Template CZL" <> '') and (CurrFieldNo = Rec.FieldNo("Entry Type")) then
            Rec.TestField("Invt. Movement Template CZL", '');
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Journal Line", 'OnBeforeValidateEvent', 'Gen. Bus. Posting Group', false, false)]
    local procedure InvtMovementTemplateOnBeforeValidateGenBusPostingGroup(var Rec: Record "Item Journal Line"; CurrFieldNo: Integer)
    begin
        if (Rec."Invt. Movement Template CZL" <> '') and (CurrFieldNo = Rec.FieldNo("Gen. Bus. Posting Group")) then
            Rec.TestField("Invt. Movement Template CZL", '');
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Journal Line", 'OnAfterValidateEvent', 'Qty. (Phys. Inventory)', false, false)]
    local procedure UpdateInvtMovementTemplateOnAfterValidateQtyPhysInventory(var Rec: Record "Item Journal Line")
    var
        InventorySetup: Record "Inventory Setup";
    begin
        InventorySetup.Get();
        Rec.Validate("Invt. Movement Template CZL", '');
        if Rec."Qty. (Phys. Inventory)" > Rec."Qty. (Calculated)" then
            if InventorySetup."Def.Tmpl. for Phys.Pos.Adj CZL" <> '' then begin
                Rec.Validate("Invt. Movement Template CZL", InventorySetup."Def.Tmpl. for Phys.Pos.Adj CZL");
                exit;
            end;
        if Rec."Qty. (Phys. Inventory)" < Rec."Qty. (Calculated)" then
            if InventorySetup."Def.Tmpl. for Phys.Neg.Adj CZL" <> '' then begin
                Rec.Validate("Invt. Movement Template CZL", InventorySetup."Def.Tmpl. for Phys.Neg.Adj CZL");
                exit;
            end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Journal Line", 'OnAfterSetupNewLine', '', false, false)]
    local procedure SetInvtMovementTemplateOnAfterSetupNewLine(var ItemJournalLine: Record "Item Journal Line"; var LastItemJournalLine: Record "Item Journal Line")
    begin
        ItemJournalLine.Validate("Invt. Movement Template CZL", LastItemJournalLine."Invt. Movement Template CZL");
    end;
}
