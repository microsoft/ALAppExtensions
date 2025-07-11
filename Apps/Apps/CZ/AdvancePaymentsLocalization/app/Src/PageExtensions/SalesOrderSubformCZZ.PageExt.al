// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Sales.Document;

pageextension 31029 "Sales Order Subform CZZ" extends "Sales Order Subform"
{
    layout
    {
        modify("Prepayment %")
        {
            Visible = false;
        }
        modify("Prepmt. Line Amount")
        {
            Visible = false;
        }
        modify("Prepmt. Amt. Inv.")
        {
            Visible = false;
        }
        modify("Prepmt Amt to Deduct")
        {
            Visible = false;
        }
        modify("Prepmt Amt Deducted")
        {
            Visible = false;
        }
    }
}
