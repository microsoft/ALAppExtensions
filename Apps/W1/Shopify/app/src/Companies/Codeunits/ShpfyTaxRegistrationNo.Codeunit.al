// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

using Microsoft.Sales.Customer;

/// <summary>
/// Codeunit Shpfy Tax Registration No. (ID 30367) implements Interface Shpfy Tax Registration Id Mapping.
/// </summary>
codeunit 30367 "Shpfy Tax Registration No." implements "Shpfy Tax Registration Id Mapping"
{
    Access = Internal;

    procedure GetTaxRegistrationId(var Customer: Record Customer): Text[150];
    begin
        exit(Customer."Registration Number");
    end;

    procedure SetMappingFiltersForCustomers(var Customer: Record Customer; CompanyLocation: Record "Shpfy Company Location")
    begin
        Customer.SetRange("Registration Number", CompanyLocation."Tax Registration Id");
    end;
}