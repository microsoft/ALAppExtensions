// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Compensations;

enum 31273 "Compensation Company Type CZC"
{
    Extensible = true;

    value(0; Customer)
    {
        Caption = 'Customer';
    }
    value(1; Vendor)
    {
        Caption = 'Vendor';
    }
    value(2; Contact)
    {
        Caption = 'Contact';
    }
}
