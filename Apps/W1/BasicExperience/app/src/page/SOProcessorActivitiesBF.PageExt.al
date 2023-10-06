// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.RoleCenters;

pageextension 20659 "SO Processor Activities BF" extends "SO Processor Activities"
{
    layout
    {
        modify("Sales Orders - Open")
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify("Sales Orders Released Not Shipped")
        {
            Visible = false;
        }
    }
    actions
    {
        modify("New Sales Order")
        {
            ApplicationArea = Advanced, BFOrders;
        }
    }
}
