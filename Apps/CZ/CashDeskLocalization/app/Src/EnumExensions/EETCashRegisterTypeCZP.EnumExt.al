// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.CashDesk;

using Microsoft.Finance;

enumextension 11741 "EET Cash Register Type CZP" extends "EET Cash Register Type CZL"
{
#pragma warning disable AS0098
    value(1; "Cash Desk")
#pragma warning restore AS0098
    {
        Caption = 'Cash Desk';
        Implementation = "EET Cash Register CZL" = "EET Cash Desk CZP";
    }
}
