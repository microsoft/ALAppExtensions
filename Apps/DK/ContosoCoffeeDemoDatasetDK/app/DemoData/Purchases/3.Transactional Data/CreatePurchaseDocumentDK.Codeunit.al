// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Purchases;

using Microsoft.Purchases.Document;
using Microsoft.Projects.Resources.Resource;

codeunit 13722 "Create Purchase Document DK"
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
        Resource: Record Resource;
    begin
        PurchaseLine.SetRange(Type, PurchaseLine.Type::Resource);
        if PurchaseLine.FindSet() then
            repeat
                Resource.Get(PurchaseLine."No.");
                PurchaseLine.Validate("Direct Unit Cost", Resource."Direct Unit Cost");
                PurchaseLine.Modify(true);
            until PurchaseLine.Next() = 0;
    end;
}
