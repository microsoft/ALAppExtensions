// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.ExciseTax;

enum 6230 "Sust. Excise Jnl. Source Type"
{
    Caption = 'Excise Journal Source Type';

    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; Item)
    {
        Caption = 'Item';
    }
    value(2; "G/L Account")
    {
        Caption = 'G/L Account';
    }
    value(3; Resource)
    {
        Caption = 'Resource';
    }
    value(4; "Charge (Item)")
    {
        Caption = 'Charge (Item)';
    }
    value(5; "Fixed Asset")
    {
        Caption = 'Fixed Asset';
    }
    value(6; Certificate)
    {
        Caption = 'Certificate';
    }
}