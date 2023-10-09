// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Document;

pageextension 20642 "Sales Hist. Sell-to FactBox BF" extends "Sales Hist. Sell-to FactBox"
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

        modify("No. of Pstd. Shipments")
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify(NoofBlanketOrdersTile) // No. of Blanket Orders
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify(NoofOrdersTile) // No. of Orders
        {
            ApplicationArea = Advanced, BFOrders;
        }

        modify(NoofPstdShipmentsTile) // No. of Pstd. Shipments
        {
            ApplicationArea = Advanced, BFOrders;
        }
    }
}
