// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.RoleCenters;

pageextension 20606 "Bookkeeper Role Center BF" extends "Bookkeeper Role Center"
{
    actions
    {
        modify("Purchase Orders")
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify("Sales Orders")
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify("Posted Sales Shipments")
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify("Posted Return Shipments")
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify("Posted Purchase Receipts")
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify("Posted Return Receipts")
        {
            ApplicationArea = Advanced, BFOrders;
        }
    }
}
