// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.ExciseTax;

enum 6231 "Sust. Excise Jnl. Partner Type"
{
    Caption = 'Excise Journal Partner Type';

    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; Vendor)
    {
        Caption = 'Vendor';
    }
    value(2; Customer)
    {
        Caption = 'Customer';
    }
}