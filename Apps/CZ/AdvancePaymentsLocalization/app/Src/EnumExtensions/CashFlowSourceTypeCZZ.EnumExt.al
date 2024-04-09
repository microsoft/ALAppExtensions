// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.CashFlow.Setup;

enumextension 31004 "Cash Flow Source Type CZZ" extends "Cash Flow Source Type"
{
    value(31000; "Sales Advance Letters CZZ")
    {
        Caption = 'Sales Advance Letters';
    }
    value(31001; "Purchase Advance Letters CZZ")
    {
        Caption = 'Purchase Advance Letters';
    }
}
