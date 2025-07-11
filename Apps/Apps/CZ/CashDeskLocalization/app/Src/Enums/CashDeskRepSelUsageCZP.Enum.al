// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.CashDesk;

enum 11729 "Cash Desk Rep. Sel. Usage CZP"
{
    Extensible = true;

    value(0; "Cash Receipt")
    {
        Caption = 'Cash Receipt';
    }
    value(1; "Cash Withdrawal")
    {
        Caption = 'Cash Withdrawal';
    }
    value(2; "Posted Cash Receipt")
    {
        Caption = 'Posted Cash Receipt';
    }
    value(3; "Posted Cash Withdrawal")
    {
        Caption = 'Posted Cash Withdrawal';
    }
}
