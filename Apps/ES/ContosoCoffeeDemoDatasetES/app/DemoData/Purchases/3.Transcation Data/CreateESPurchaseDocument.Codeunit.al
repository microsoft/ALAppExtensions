// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Purchases;

using Microsoft.Purchases.Document;

codeunit 10814 "Create ES Purchase Document"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        PurchHeader: Record "Purchase Header";
    begin
        if PurchHeader.FindSet() then
            repeat
                PurchHeader.Validate("Buy-from Vendor No.");
            until PurchHeader.Next() = 0;
    end;
}
