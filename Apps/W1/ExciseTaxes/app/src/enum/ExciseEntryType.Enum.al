// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.ExciseTaxes;

enum 7412 "Excise Entry Type"
{
    Extensible = true;

    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; Purchase)
    {
        Caption = 'Purchase';
    }
    value(2; Sale)
    {
        Caption = 'Sales';
    }
    value(3; "Positive Adjmt.")
    {
        Caption = 'Positive Adjustment';
    }
    value(4; "Negative Adjmt.")
    {
        Caption = 'Negative Adjustment';
    }
    value(5; Output)
    {
        Caption = 'Output';
    }
    value(6; "Assembly Output")
    {
        Caption = 'Assembly Output';
    }
}