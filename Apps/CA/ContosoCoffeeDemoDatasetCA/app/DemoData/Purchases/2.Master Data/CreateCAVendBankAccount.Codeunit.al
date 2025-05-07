// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Purchases;

using Microsoft.Purchases.Vendor;
using Microsoft.DemoData.Foundation;

codeunit 27073 "Create CA Vend. Bank Account"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Vendor Bank Account", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnInsertRecord(var Rec: Record "Vendor Bank Account")
    var
        CreateCountryRegion: Codeunit "Create Country/Region";
        CreateVendor: Codeunit "Create Vendor";
        CreateVendorBankAccount: Codeunit "Create Vendor Bank Account";
    begin
        if (Rec."Vendor No." = CreateVendor.ExportFabrikam()) and (Rec.Code = CreateVendorBankAccount.ECA()) then
            ValidateRecordField(Rec, CreateCountryRegion.GB());

        if (Rec."Vendor No." = CreateVendor.DomesticFirstUp()) and (Rec.Code = CreateVendorBankAccount.ECA()) then
            ValidateRecordField(Rec, CreateCountryRegion.GB())
    end;

    local procedure ValidateRecordField(var VendorBankAccount: Record "Vendor Bank Account"; CountryRegionCode: Code[10])
    begin
        VendorBankAccount.Validate("Country/Region Code", CountryRegionCode);
    end;
}
