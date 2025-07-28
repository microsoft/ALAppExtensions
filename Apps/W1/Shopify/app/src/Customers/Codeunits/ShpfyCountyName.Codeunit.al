// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

using Microsoft.Sales.Customer;

/// <summary>
/// Codeunit Shpfy County Name (ID 30109) implements Interface Shpfy ICounty.
/// </summary>
codeunit 30109 "Shpfy County Name" implements "Shpfy ICounty"
{
    Access = Internal;

    /// <summary> 
    /// Description for County.
    /// </summary>
    /// <param name="CustomerAddress">Parameter of type Record "Shopify Customer Address".</param>
    /// <returns>Return variable "Text".</returns>
    internal procedure County(CustomerAddress: Record "Shpfy Customer Address"): Text
    var
        Customer: Record Customer;
    begin
        exit(CopyStr(CustomerAddress."Province Name".Trim(), 1, MaxStrLen(Customer.County)));
    end;

    /// <summary>
    /// Description for County.
    /// </summary>
    /// <param name="CompanyLocation">Parameter of type Record "Shopify Company Location".</param>
    /// <returns>Return variable "Text".</returns>
    internal procedure County(CompanyLocation: Record "Shpfy Company Location"): Text
    var
        Customer: Record Customer;
    begin
        exit(CopyStr(CompanyLocation."Province Name".Trim(), 1, MaxStrLen(Customer.County)));
    end;
}