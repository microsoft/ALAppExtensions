// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.ExciseTax;

enum 6228 "Sust. Excise Jnl. Entry Type"
{
    Caption = 'Excise Journal Entry Type';

    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; Purchase)
    {
        Caption = 'Purchase';
    }
    value(2; Sales)
    {
        Caption = 'Sales';
    }
}