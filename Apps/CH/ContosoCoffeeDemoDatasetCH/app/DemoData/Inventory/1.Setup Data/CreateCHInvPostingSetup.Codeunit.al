// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Inventory;

using Microsoft.Inventory.Item;
using Microsoft.DemoData.Finance;

codeunit 11603 "Create CH Inv. Posting Setup"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Inventory Posting Setup", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertInventoryPostingSetup(var Rec: Record "Inventory Posting Setup")
    var
        CreateLocation: Codeunit "Create Location";
        CreateCHGLAccounts: Codeunit "Create CH GL Accounts";
        CreateInventoryPostingGroup: Codeunit "Create Inventory Posting Group";
    begin
        if Rec."Invt. Posting Group Code" = CreateInventoryPostingGroup.Resale() then
            case Rec."Location Code" of
                CreateLocation.EastLocation(),
                CreateLocation.MainLocation(),
                CreateLocation.OutLogLocation(),
                CreateLocation.OwnLogLocation(),
                CreateLocation.WestLocation(),
                '':
                    ValidateInventoryPostingSetup(Rec, CreateCHGLAccounts.InvCommercialGoods(), CreateCHGLAccounts.InvCommercialGoodsInterim());
            end;
    end;

    local procedure ValidateInventoryPostingSetup(var InventoryPostingSetup: Record "Inventory Posting Setup"; InventoryAccount: Code[20]; InventoryAccountInterim: Code[20])
    begin
        InventoryPostingSetup.Validate("Inventory Account", InventoryAccount);
        InventoryPostingSetup.Validate("Inventory Account (Interim)", InventoryAccountInterim);
    end;
}
