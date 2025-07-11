// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.Payables;

pageextension 20662 "Vendor Hist. Buy-from FB BF" extends "Vendor Hist. Buy-from FactBox"
{
    layout
    {
        modify("No. of Blanket Orders")
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify("No. of Orders")
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify("No. of Pstd. Receipts")
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify(CueBlanketOrders) // No. of Blanket Orders
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify(CueOrders) // No. of Orders
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify(CuePostedReceipts) // No. of Pstd. Receipts
        {
            ApplicationArea = Advanced, BFOrders;
        }
    }
}
