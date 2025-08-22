// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.ExciseTax;

enum 6229 "Sust. Excise Document Type"
{
    Caption = 'Excise Document Type';

    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; Invoice)
    {
        Caption = 'Invoice';
    }
    value(2; "Credit Memo")
    {
        Caption = 'Credit Memo';
    }
    value(3; Journal)
    {
        Caption = 'Journal';
    }
}