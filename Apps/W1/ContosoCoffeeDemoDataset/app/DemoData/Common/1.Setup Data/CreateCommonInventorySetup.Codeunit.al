// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Common;

using Microsoft.Inventory.Setup;

codeunit 5131 "Create Common Inventory Setup"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions = tabledata "Inventory Setup" = rm;

    trigger OnRun()
    var
        InventorySetup: Record "Inventory Setup";
        CreateContosoNoSeries: Codeunit "Create Common No Series";
    begin
        InventorySetup.Get();

        if InventorySetup."Item Nos." = '' then
            InventorySetup.Validate("Item Nos.", CreateContosoNoSeries.Item());

        InventorySetup.Modify();
    end;
}
