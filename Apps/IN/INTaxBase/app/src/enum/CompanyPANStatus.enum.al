// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TaxBase;

enum 18544 "Company P.A.N.Status"
{
    Extensible = true;

    value(0; Available)
    {
        Caption = 'Available';
    }
    value(1; "Not available")
    {
        Caption = 'Not Available';
    }
}
