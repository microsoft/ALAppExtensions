// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Inventory;

using Microsoft.Inventory.Setup;

codeunit 31203 "Create Inventory Setup CZ"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        UpdateInventorySetup();
    end;

    local procedure UpdateInventorySetup()
    var
        InventorySetup: Record "Inventory Setup";
        CreateInvtMvmtTemplCZ: Codeunit "Create Invt. Mvmt. Templ. CZ";
    begin
        InventorySetup.Get();
        InventorySetup.Validate("Def.Tmpl. for Phys.Pos.Adj CZL", CreateInvtMvmtTemplCZ.Surplus());
        InventorySetup.Validate("Def.Tmpl. for Phys.Neg.Adj CZL", CreateInvtMvmtTemplCZ.Deficiency());
        InventorySetup.Modify(true);
    end;
}
