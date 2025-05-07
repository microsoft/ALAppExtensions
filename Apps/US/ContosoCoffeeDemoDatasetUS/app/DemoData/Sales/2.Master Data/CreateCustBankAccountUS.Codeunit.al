// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Sales;

using Microsoft.Sales.Customer;
using Microsoft.DemoData.Foundation;

codeunit 11498 "Create Cust. Bank Account US"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Customer Bank Account", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnInsertRecord(var Rec: Record "Customer Bank Account")
    var
        CreateCountryRegion: Codeunit "Create Country/Region";
    begin
        ValidateRecordFields(Rec, CreateCountryRegion.GB());
    end;

    local procedure ValidateRecordFields(var CustomerBankAccount: Record "Customer Bank Account"; CountryRegionCode: Code[20])
    begin
        CustomerBankAccount.Validate("Country/Region Code", CountryRegionCode);
    end;
}
