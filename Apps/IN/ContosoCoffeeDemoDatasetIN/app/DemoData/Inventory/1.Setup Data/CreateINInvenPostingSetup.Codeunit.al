// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Inventory;

using Microsoft.DemoTool.Helpers;
using Microsoft.DemoData.Finance;
using Microsoft.Inventory.Item;

codeunit 19027 "Create IN Inven. Posting Setup"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoPostingSetup: Codeunit "Contoso Posting Setup";
        CreateINLocation: Codeunit "Create IN Location";
        CreateGLAccount: Codeunit "Create G/L Account";
        CreateInvPostingGroup: Codeunit "Create Inventory Posting Group";
    begin
        ContosoPostingSetup.InsertInventoryPostingSetup(CreateINLocation.BlueLocation(), CreateInvPostingGroup.Resale(), CreateGLAccount.ResaleItems(), CreateGLAccount.ResaleItemsInterim());
        ContosoPostingSetup.InsertInventoryPostingSetup(CreateINLocation.RedLocation(), CreateInvPostingGroup.Resale(), CreateGLAccount.ResaleItems(), CreateGLAccount.ResaleItemsInterim());
    end;

    [EventSubscriber(ObjectType::Table, Database::"Inventory Posting Setup", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertInventoryPostingSetup(var Rec: Record "Inventory Posting Setup")
    var
        CreateLocation: Codeunit "Create Location";
        CreateINLocation: Codeunit "Create IN Location";
        CreateInventoryPostingGroup: Codeunit "Create Inventory Posting Group";
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        if Rec."Invt. Posting Group Code" = CreateInventoryPostingGroup.Resale() then
            case Rec."Location Code" of
                '',
                CreateLocation.EastLocation(),
                CreateLocation.MainLocation(),
                CreateLocation.OutLogLocation(),
                CreateLocation.OwnLogLocation(),
                CreateLocation.WestLocation(),
                CreateINLocation.BlueLocation(),
                CreateINLocation.RedLocation():
                    Rec.Validate("Unrealized Profit Account", CreateGLAccount.UnrealizedFXLosses());
            end;
    end;

}
