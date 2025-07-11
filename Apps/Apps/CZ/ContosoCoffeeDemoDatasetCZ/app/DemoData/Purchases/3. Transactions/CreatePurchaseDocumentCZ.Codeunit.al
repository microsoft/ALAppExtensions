// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Inventory;

using Microsoft.Purchases.Document;

codeunit 31485 "Create Purchase Document CZ"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertPurchaseLine(var Rec: Record "Purchase Line")
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        if not PurchaseHeader.Get(Rec."Document Type", Rec."Document No.") then
            exit;
        if PurchaseHeader."Currency Factor" = 0 then
            exit;

        Rec.Validate("Direct Unit Cost", Round(Rec."Direct Unit Cost" * PurchaseHeader."Currency Factor"));
    end;
}