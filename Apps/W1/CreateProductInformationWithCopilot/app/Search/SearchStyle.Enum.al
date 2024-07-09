// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Item.Substitution;

enum 7332 "Search Style"
{
    Extensible = false;

    value(0; "Permissive")
    {
        Caption = 'Permissive';
    }
    value(1; "Balanced")
    {
        Caption = 'Balanced';
    }
    value(2; "Precise")
    {
        Caption = 'Precise';
    }
}