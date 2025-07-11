// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Sales;

enum 18145 "GST Inv Type"
{
    Extensible = true;

    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; "Bill of Supply")
    {
        Caption = 'Bill of Supply';
    }
    value(2; Export)
    {
        Caption = 'Export';
    }
    value(3; Supplementary)
    {
        Caption = 'Supplementary';
    }
    value(4; "Debit Note")
    {
        Caption = 'Debit Note';
    }
    value(5; "Non-GST")
    {
        Caption = 'Non-GST';
    }
    value(6; Taxable)
    {
        Caption = 'Taxable';
    }
}
