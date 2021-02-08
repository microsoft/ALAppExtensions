codeunit 31076 "Phys.In.Order Line Handler CZL"
{
    [EventSubscriber(ObjectType::Table, Database::"Phys. Invt. Order Line", 'OnBeforeValidateEvent', 'Entry Type', false, false)]
    local procedure InvtMovementTemplateOnBeforeValidateEntryType(var Rec: Record "Phys. Invt. Order Line"; CurrFieldNo: Integer)
    begin
        if (Rec."Invt. Movement Template CZL" <> '') and (CurrFieldNo = Rec.FieldNo("Entry Type")) then
            Rec.TestField("Invt. Movement Template CZL", '');
    end;

    [EventSubscriber(ObjectType::Table, Database::"Phys. Invt. Order Line", 'OnBeforeValidateEvent', 'Gen. Bus. Posting Group', false, false)]
    local procedure InvtMovementTemplateOnBeforeValidateGenBusPostingGroup(var Rec: Record "Phys. Invt. Order Line"; CurrFieldNo: Integer)
    begin
        if (Rec."Invt. Movement Template CZL" <> '') and (CurrFieldNo = Rec.FieldNo("Gen. Bus. Posting Group")) then
            Rec.TestField("Invt. Movement Template CZL", '');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Phys. Invt. Order-Finish", 'OnBeforePhysInvtOrderLineModify', '', false, false)]
    local procedure UpdateInvtMovementTemplateOnBeforePhysInvtOrderLineModify(var PhysInvtOrderLine: Record "Phys. Invt. Order Line")
    var
        InventorySetup: Record "Inventory Setup";
    begin
        InventorySetup.Get();
        PhysInvtOrderLine.Validate("Invt. Movement Template CZL", '');
        if PhysInvtOrderLine."Pos. Qty. (Base)" > 0 then
            if InventorySetup."Def.Tmpl. for Phys.Pos.Adj CZL" <> '' then begin
                PhysInvtOrderLine.Validate("Invt. Movement Template CZL", InventorySetup."Def.Tmpl. for Phys.Pos.Adj CZL");
                exit;
            end;
        if PhysInvtOrderLine."Neg. Qty. (Base)" > 0 then
            if InventorySetup."Def.Tmpl. for Phys.Neg.Adj CZL" <> '' then begin
                PhysInvtOrderLine.Validate("Invt. Movement Template CZL", InventorySetup."Def.Tmpl. for Phys.Neg.Adj CZL");
                exit;
            end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Phys. Invt. Order-Reopen", 'OnBeforePhysInvtOrderLineModify', '', false, false)]
    local procedure ClearInvtMovementTemplateOnBeforePhysInvtOrderLineModify(var PhysInvtOrderLine: Record "Phys. Invt. Order Line")
    begin
        PhysInvtOrderLine.Validate("Invt. Movement Template CZL", '');
    end;
}
