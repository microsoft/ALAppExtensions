// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Inventory;

using Microsoft.DemoData.Finance;
using Microsoft.Inventory.Item;
using Microsoft.DemoData.Foundation;

codeunit 11096 "Create DE Item Template"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        CreateVatPostingGrp: Codeunit "Create DE VAT Posting Groups";
        CreateNoSeries: Codeunit "Create No. Series";
        CreateItemTemplate: Codeunit "Create Item Template";
    begin
        UpdateItemTemplate(CreateNoSeries.Item(), CreateVatPostingGrp.VAT19());
        UpdateItemTemplate(CreateItemTemplate.Service(), CreateVatPostingGrp.VAT19());
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
