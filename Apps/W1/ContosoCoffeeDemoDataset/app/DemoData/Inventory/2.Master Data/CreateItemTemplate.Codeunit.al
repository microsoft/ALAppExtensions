// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Inventory;

using Microsoft.DemoTool.Helpers;
using Microsoft.DemoData.Foundation;
using Microsoft.DemoData.Finance;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Tracking;

codeunit 5448 "Create Item Template"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoInventory: Codeunit "Contoso Inventory";
        CreateInvPostingGroup: Codeunit "Create Inventory Posting Group";
        CreateUnitOfMeasure: Codeunit "Create Unit of Measure";
        CreatePostingGroup: Codeunit "Create Posting Groups";
        CreateVATPostingGroups: Codeunit "Create VAT Posting Groups";
    begin
        ContosoInventory.InsertItemTemplateData(Item(), ItemLbl, CreateUnitOfMeasure.Piece(), Enum::"Item Type"::Inventory, CreateInvPostingGroup.Resale(), CreatePostingGroup.RetailPostingGroup(), CreateVATPostingGroups.Standard(), Enum::"Reserve Method"::Optional);
        ContosoInventory.InsertItemTemplateData(Service(), ServiceLbl, CreateUnitOfMeasure.Hour(), Enum::"Item Type"::Service, '', CreatePostingGroup.ServicesPostingGroup(), CreateVATPostingGroups.Standard(), Enum::"Reserve Method"::Never);
        ContosoInventory.InsertItemTemplateData(NonInv(), NonInvLbl, CreateUnitOfMeasure.Piece(), Enum::"Item Type"::"Non-Inventory", '', CreatePostingGroup.RetailPostingGroup(), CreateVATPostingGroups.Standard(), Enum::"Reserve Method"::Never);
    end;

    procedure Service(): Code[20]
    begin
        exit(ServiceTok);
    end;

    procedure Item(): Code[20]
    begin
        exit(ItemTok);
    end;

    procedure NonInv(): Code[20]
    begin
        exit(NonInvTok);
    end;

    var
        ServiceTok: Label 'SERVICE', MaxLength = 20;
        ServiceLbl: Label 'Service', MaxLength = 100;
        ItemTok: Label 'ITEM', MaxLength = 20;
        ItemLbl: Label 'Item', MaxLength = 100;
        NonInvTok: Label 'NON-INVENTORY', MaxLength = 20;
        NonInvLbl: Label 'Non-inventory item', MaxLength = 100;
}
