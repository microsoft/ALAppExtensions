// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

enum 31014 "Advance Letter Type CZZ"
{
    Extensible = true;

    value(0; Sales)
    {
        Caption = 'Sales';
    }
    value(1; Purchase)
    {
        Caption = 'Purchase';
    }
}
