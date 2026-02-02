// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.ExciseTaxes;

enum 7414 "Excise Tax Basis"
{
    Extensible = true;

    value(0; Weight)
    {
        Caption = 'Weight';
    }
    value(1; "Sugar Content")
    {
        Caption = 'Sugar Content';
    }
    value(2; "THC Content")
    {
        Caption = 'THC Content';
    }
    value(3; Volume)
    {
        Caption = 'Volume';
    }
    value(4; "Spirit Volume")
    {
        Caption = 'Spirit Volume';
    }
}