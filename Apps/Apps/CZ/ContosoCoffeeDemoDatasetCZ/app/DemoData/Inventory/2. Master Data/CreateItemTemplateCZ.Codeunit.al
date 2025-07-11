// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Inventory;

using Microsoft.DemoData.Finance;
using Microsoft.Inventory.Item;

codeunit 31335 "Create Item Template CZ"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        CreateVATPostingGroupsCZ: Codeunit "Create VAT Posting Groups CZ";
        CreateItemTemplate: Codeunit "Create Item Template";
    begin
        UpdateItemTemplate(CreateItemTemplate.Item(), CreateVatPostingGroupsCZ.VAT21I());
        UpdateItemTemplate(CreateItemTemplate.Service(), CreateVatPostingGroupsCZ.VAT21S());
        UpdateItemTemplate(CreateItemTemplate.NonInv(), CreateVatPostingGroupsCZ.VAT21I());
    end;

    local procedure UpdateItemTemplate(ItemTemplateCode: Code[20]; VatProdPostingGroup: Code[20])
    var
        ItemTemplate: Record "Item Templ.";
    begin
        ItemTemplate.Get(ItemTemplateCode);
        ItemTemplate.Validate("VAT Prod. Posting Group", VatProdPostingGroup);
        ItemTemplate.Modify(true);
    end;
}