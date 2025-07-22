// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

/// <summary>
/// Enum Shpfy Weight Unit (ID 30163).
/// </summary>
enum 30163 "Shpfy Weight Unit"
{
    Caption = 'Shopify Weight Unit';
    Extensible = false;

    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; Grams)
    {
        Caption = 'Grams';
    }
    value(2; Kilograms)
    {
        Caption = 'Kilograms';
    }
    value(3; Ounces)
    {
        Caption = 'Ounces';
    }
    value(4; Pounds)
    {
        Caption = 'Pounds';
    }
}
