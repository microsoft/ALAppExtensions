// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Purchases;

using Microsoft.Purchases.Vendor;

codeunit 27072 "Create CA Vendor Templ."
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Vendor Templ.", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnInsertRecord(var Rec: Record "Vendor Templ.")
    var
        CreateVendorTemplate: Codeunit "Create Vendor Template";
    begin
        if Rec.Code = CreateVendorTemplate.VendorPerson() then
            Rec.Validate("Prices Including VAT", false);
    end;
}
