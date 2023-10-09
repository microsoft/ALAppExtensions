// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Base;

enum 18002 "Application Doc Type"
{
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
    value(4; Transfer)
    {
        Caption = 'Transfer';
    }
    value(5; "Finance Charge Memo")
    {
        Caption = 'Finance Charge Memo';
    }
    value(6; Reminder)
    {
        Caption = 'Reminder';
    }
    value(7; Refund)
    {
        Caption = 'Refund';
    }
}
