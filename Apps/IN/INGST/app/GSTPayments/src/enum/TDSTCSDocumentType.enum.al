// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Payments;

enum 18247 "TDSTCS Document Type"
{
    Extensible = true;
    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; Payment)
    {
        Caption = 'Payment';
    }
    value(2; Invoice)
    {
        Caption = 'Invoice';
    }
    value(3; "Credit Memo")
    {
        Caption = 'Credit Memo';
    }
    value(4; "Finance Charge Memo")
    {
        Caption = 'Finance Charge Memo';
    }
    value(5; Reminder)
    {
        Caption = 'Reminder';
    }
    value(6; Refund)
    {
        Caption = 'Refund';
    }
}
