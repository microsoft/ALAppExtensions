// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Sales.Document;

pageextension 31045 "Sales Order Statistics CZZ" extends "Sales Order Statistics"
{
    layout
    {
        modify(Prepayment)
        {
            Visible = false;
        }
    }
}
