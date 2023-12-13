// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;

enum 11515 "Swiss QR-Bill Reports"
{
    Extensible = false;

    value(0; "Posted Sales Invoice")
    {
        Caption = 'Posted Sales Invoice';
    }
    value(1; "Posted Service Invoice")
    {
        Caption = 'Posted Service Invoice';
    }
    value(2; "Issued Reminder")
    {
        Caption = 'Issued Reminder';
    }
    value(3; "Issued Finance Charge Memo")
    {
        Caption = 'Issued Finance Charge Memo';
    }
}
