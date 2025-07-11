// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Purchases;

using Microsoft.Purchases.Document;
using Microsoft.Inventory.Item;
using Microsoft.Projects.Resources.Resource;

codeunit 10530 "Create Purchase Line US"
{
    InherentEntitlements = X;
    InherentPermissions = X;


    trigger OnRun()
    begin
        UpdatePurchaseLine();
    end;

    local procedure UpdatePurchaseLine()
    var
        PurchaseLine: Record "Purchase Line";
        Item: Record Item;
        Resource: Record Resource;
    begin
        PurchaseLine.SetRange(Type, PurchaseLine.Type::Item);
        if PurchaseLine.FindSet() then
            repeat
                Item.Get(PurchaseLine."No.");
                PurchaseLine.Validate("Unit Cost", Item."Unit Cost");
                PurchaseLine.Modify(true);
            until PurchaseLine.Next() = 0;

        PurchaseLine.SetRange(Type, PurchaseLine.Type::Resource);
        if PurchaseLine.FindSet() then
            repeat
                Resource.Get(PurchaseLine."No.");
                PurchaseLine.Validate("Unit Cost", Resource."Unit Cost");
                PurchaseLine.Modify(true);
            until PurchaseLine.Next() = 0;
    end;
}
