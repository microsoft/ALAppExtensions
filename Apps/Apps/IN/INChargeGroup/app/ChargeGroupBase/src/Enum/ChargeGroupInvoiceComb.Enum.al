// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.ChargeGroup.ChargeGroupBase;

enum 18505 "Charge Group Invoice Comb."
{
    Caption = 'Charge Group Invoice Combination';
    Extensible = true;

    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; "Combine Invoice")
    {
        Caption = 'Combine Invoice';
    }
    value(2; "Separate Invoice")
    {
        Caption = 'Seperate Invoice';
    }
}
