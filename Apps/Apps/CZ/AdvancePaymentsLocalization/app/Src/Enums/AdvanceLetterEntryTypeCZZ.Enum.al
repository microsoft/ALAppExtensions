// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

enum 31010 "Advance Letter Entry Type CZZ"
{
    Extensible = true;

    value(0; "Initial Entry")
    {
        Caption = 'Initial Entry';
    }
    value(1; Payment)
    {
        Caption = 'Payment';
    }
    value(2; "VAT Payment")
    {
        Caption = 'VAT Payment';
    }
    value(3; Usage)
    {
        Caption = 'Usage';
    }
    value(4; "VAT Usage")
    {
        Caption = 'VAT Usage';
    }
    value(5; Close)
    {
        Caption = 'Close';
    }
    value(6; "VAT Close")
    {
        Caption = 'VAT Close';
    }
    value(7; "VAT Rate")
    {
        Caption = 'VAT Rate';
    }
    value(8; "VAT Adjustment")
    {
        Caption = 'VAT Adjustment';
    }
}
