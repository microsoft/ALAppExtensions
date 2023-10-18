// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.ChargeGroup.ChargeGroupBase;

enum 18504 "Charge Computation Method"
{
    Extensible = true;

    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; "Fixed Value")
    {
        Caption = 'Fixed Value';
    }
    value(2; "Percentage")
    {
        Caption = 'Percentage';
    }
    value(3; "Amount Per Quantity")
    {
        Caption = 'Amount Per Quantity';
    }
}
