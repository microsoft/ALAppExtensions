// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.CashDesk;

enum 11730 "Cash Document Type CZP"
{
    Extensible = true;

    value(0; " ")
    {
    }
    value(1; Receipt)
    {
        Caption = 'Receipt';
    }
    value(2; Withdrawal)
    {
        Caption = 'Withdrawal';
    }
}
