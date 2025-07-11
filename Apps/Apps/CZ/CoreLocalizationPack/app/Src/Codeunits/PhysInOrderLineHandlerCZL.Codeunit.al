// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Counting.Document;

using Microsoft.Inventory.Setup;

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

    [EventSubscriber(ObjectType::Table, Database::"Phys. Invt. Order Line", 'OnBeforeModifyEvent', '', false, false)]
    local procedure UpdateInvtMovementTemplateOnBeforeModifyEvent(var Rec: Record "Phys. Invt. Order Line")
    begin
        Rec.Validate("Invt. Movement Template CZL", GetInvtMovementTemplateName(Rec));
    end;

    local procedure GetInvtMovementTemplateName(PhysInvtOrderLine: Record "Phys. Invt. Order Line"): Code[10]
    var
        InventorySetup: Record "Inventory Setup";
    begin
        InventorySetup.Get();
        case PhysInvtOrderLine."Entry Type" of
            PhysInvtOrderLine."Entry Type"::"Positive Adjmt.":
                exit(InventorySetup."Def.Tmpl. for Phys.Pos.Adj CZL");
            PhysInvtOrderLine."Entry Type"::"Negative Adjmt.":
                exit(InventorySetup."Def.Tmpl. for Phys.Neg.Adj CZL")
            else
                exit('');
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Phys. Invt. Order-Reopen", 'OnBeforePhysInvtOrderLineModify', '', false, false)]
    local procedure ClearInvtMovementTemplateOnBeforePhysInvtOrderLineModify(var PhysInvtOrderLine: Record "Phys. Invt. Order Line")
    begin
        PhysInvtOrderLine.Validate("Invt. Movement Template CZL", '');
    end;
}
