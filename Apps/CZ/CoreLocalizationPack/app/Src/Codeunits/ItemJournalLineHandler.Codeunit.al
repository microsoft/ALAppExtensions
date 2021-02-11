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
        InvtMovementTemplateName: Code[10];
    begin
        InvtMovementTemplateName := GetInvtMovementTemplateName(Rec);
        if InvtMovementTemplateName <> '' then
            Rec.Validate("Invt. Movement Template CZL", InvtMovementTemplateName);
    end;

    local procedure GetInvtMovementTemplateName(ItemJournalLine: Record "Item Journal Line"): Code[10]
    var
        InventorySetup: Record "Inventory Setup";
    begin
        InventorySetup.Get();
        if ItemJournalLine."Qty. (Phys. Inventory)" > ItemJournalLine."Qty. (Calculated)" then
            exit(InventorySetup."Def.Tmpl. for Phys.Pos.Adj CZL");
        if ItemJournalLine."Qty. (Phys. Inventory)" < ItemJournalLine."Qty. (Calculated)" then
            exit(InventorySetup."Def.Tmpl. for Phys.Neg.Adj CZL");
        exit('');
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Journal Line", 'OnAfterSetupNewLine', '', false, false)]
    local procedure SetInvtMovementTemplateOnAfterSetupNewLine(var ItemJournalLine: Record "Item Journal Line"; var LastItemJournalLine: Record "Item Journal Line")
    begin
        ItemJournalLine.Validate("Invt. Movement Template CZL", LastItemJournalLine."Invt. Movement Template CZL");
    end;
}
