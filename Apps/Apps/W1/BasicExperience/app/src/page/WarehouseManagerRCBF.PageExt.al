﻿// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Warehouse.RoleCenters;

pageextension 20665 "Warehouse Manager RC BF" extends "Warehouse Manager Role Center"
{
    actions
    {
        modify("Orders") // Purchase Orders
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify("Orders1") // Sales Orders
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify("Orders3") // Sales Orders
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify("Posted Purchase Receipts")
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify("Posted Sales Shipments")
        {
            ApplicationArea = Advanced, BFOrders;
        }

    }
}
