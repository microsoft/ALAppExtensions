// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.ChargeGroup.ChargeGroupBase;

enum 18506 "Charge Group Type"
{
    Extensible = true;

    value(0; "Charge (Item)")
    {
        Caption = 'Charge (Item)';
    }
    value(1; "G/L Account")
    {
        Caption = 'G/L Account';
    }
}
