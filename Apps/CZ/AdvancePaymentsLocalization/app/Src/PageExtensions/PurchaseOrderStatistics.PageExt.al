// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Purchases.Document;

pageextension 31046 "Purchase Order Statistics CZZ" extends "Purchase Order Statistics"
{
    layout
    {
        modify(Prepayment)
        {
            Visible = false;
        }
    }
}
