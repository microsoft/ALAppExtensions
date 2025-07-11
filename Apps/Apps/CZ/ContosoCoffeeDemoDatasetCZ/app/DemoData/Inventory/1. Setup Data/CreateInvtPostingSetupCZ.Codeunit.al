// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Inventory;

using Microsoft.Inventory.Item;
using Microsoft.DemoData.Finance;

codeunit 31201 "Create Invt. Posting Setup CZ"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Inventory Posting Setup", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertInvPostingSetup(var Rec: Record "Inventory Posting Setup")
    var
        CreateGLAccountCZ: Codeunit "Create G/L Account CZ";
    begin
        ValidateRecordFields(Rec,
            CreateGLAccountCZ.GoodsInRetail(), CreateGLAccountCZ.GoodsInRetailInterim(),
            CreateGLAccountCZ.WorkInProgress(), CreateGLAccountCZ.ChangeinWIP(),
            CreateGLAccountCZ.CapacityVariance(), CreateGLAccountCZ.Varianceofoverheadcost(),
            CreateGLAccountCZ.Varianceofoverheadcost(), CreateGLAccountCZ.ConsumptionOfMaterial(),
            CreateGLAccountCZ.ChangeinWIP(), CreateGLAccountCZ.ChangeinWIP());
    end;

    local procedure ValidateRecordFields(var InventoryPostingSetup: Record "Inventory Posting Setup"; InventoryAccount: Code[20]; InventoryAccountInterim: Code[20]; WIPAccount: Code[20]; MaterialVarianceAccount: Code[20]; CapacityVarianceAccount: Code[20]; CapOverheaderVarianceAccount: Code[20]; MfgOverheadVarianceAccount: Code[20]; ConsumptionAccount: Code[20]; ChangeInInvOfWIPAcc: Code[20]; ChangeInInvOfProdAcc: Code[20])
    begin
        InventoryPostingSetup.Validate("Inventory Account", InventoryAccount);
        InventoryPostingSetup.Validate("Inventory Account (Interim)", InventoryAccountInterim);
        InventoryPostingSetup.Validate("WIP Account", WIPAccount);
        InventoryPostingSetup.Validate("Material Variance Account", MaterialVarianceAccount);
        InventoryPostingSetup.Validate("Capacity Variance Account", CapacityVarianceAccount);
        InventoryPostingSetup.Validate("Cap. Overhead Variance Account", CapOverheaderVarianceAccount);
        InventoryPostingSetup.Validate("Mfg. Overhead Variance Account", MfgOverheadVarianceAccount);
        InventoryPostingSetup.Validate("Consumption Account CZL", ConsumptionAccount);
        InventoryPostingSetup.Validate("Change In Inv.Of WIP Acc. CZL", ChangeInInvOfWIPAcc);
        InventoryPostingSetup.Validate("Change In Inv.OfProd. Acc. CZL", ChangeInInvOfProdAcc);
    end;
}
