// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Inventory;

using Microsoft.Inventory.Setup;
using Microsoft.DemoData.Finance;

codeunit 11374 "Create Inv. Setup BE"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        InventorySetup: Record "Inventory Setup";
        CreateGenJnlBatch: Codeunit "Create Gen. Journal Batch";
    begin
        InventorySetup.Get();
        InventorySetup.Validate("Invt. Cost Jnl. Template Name", CreateGenJnlBatch.General());
        InventorySetup.Validate("Invt. Cost Jnl. Batch Name", CreateGenJnlBatch.Default());
        InventorySetup.Modify(true);
    end;
}
