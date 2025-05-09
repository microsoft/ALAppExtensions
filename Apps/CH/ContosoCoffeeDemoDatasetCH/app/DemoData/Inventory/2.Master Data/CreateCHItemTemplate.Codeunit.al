// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Inventory;

using Microsoft.DemoData.Finance;
using Microsoft.Inventory.Item;

codeunit 11605 "Create CH Item Template"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        CreateCHVatPostingGroups: Codeunit "Create CH VAT Posting Groups";
        CreateItemTemplate: Codeunit "Create Item Template";
    begin
        UpdateItemTemplate(CreateItemTemplate.Item(), CreateCHVatPostingGroups.Normal());
        UpdateItemTemplate(CreateItemTemplate.Service(), CreateCHVatPostingGroups.Normal());
    end;

    local procedure UpdateItemTemplate(ItemTemplateCode: Code[20]; VatProdPostingGrp: Code[20])
    var
        ItemTemplate: Record "Item Templ.";
    begin
        ItemTemplate.Get(ItemTemplateCode);
        ItemTemplate.Validate("VAT Prod. Posting Group", VatProdPostingGrp);
        ItemTemplate.Modify(true);
    end;
}
