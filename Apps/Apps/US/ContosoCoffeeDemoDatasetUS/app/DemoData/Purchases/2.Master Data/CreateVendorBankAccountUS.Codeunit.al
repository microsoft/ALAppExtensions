// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Purchases;

using Microsoft.Purchases.Vendor;
using Microsoft.DemoData.Foundation;

codeunit 10514 "Create Vendor Bank Account US"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Vendor Bank Account", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnInsertRecord(var Rec: Record "Vendor Bank Account")
    var
        CreateCountryRegion: Codeunit "Create Country/Region";
    begin
        ValidateRecordFields(Rec, CreateCountryRegion.GB(), '');
    end;

    local procedure ValidateRecordFields(var VendorBankAccount: Record "Vendor Bank Account"; CountryRegionCode: Code[20]; BankCode: Code[3])
    begin
        VendorBankAccount.Validate("Country/Region Code", CountryRegionCode);
        VendorBankAccount.Validate("Use for Electronic Payments", false);
        VendorBankAccount.Validate("Bank Code", BankCode);
    end;
}
