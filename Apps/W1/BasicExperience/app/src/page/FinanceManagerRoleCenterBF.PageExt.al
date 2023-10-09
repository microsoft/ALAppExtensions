// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.RoleCenters;

pageextension 20620 "Finance Manager Role Center BF" extends "Finance Manager Role Center"
{
    actions
    {
        modify("Posted Sales Shipments")
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify("Posted Purchase Receipts")
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify("Customer - Order Summary")
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify("Customer - Order Detail")
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify("Vendor - Order Detail")
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify("Vendor - Order Summary")
        {
            ApplicationArea = Advanced, BFOrders;
        }
    }
}
