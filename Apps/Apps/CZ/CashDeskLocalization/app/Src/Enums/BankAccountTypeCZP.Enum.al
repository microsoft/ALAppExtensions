// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.CashDesk;

enum 11728 "Bank Account Type CZP"
{
    Extensible = true;

    value(0; "Bank Account")
    {
        Caption = 'Bank Account';
    }
    value(1; "Cash Desk")
    {
        Caption = 'Cash Desk';
    }
}
